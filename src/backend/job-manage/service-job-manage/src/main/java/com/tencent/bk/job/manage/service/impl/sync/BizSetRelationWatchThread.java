/*
 * Tencent is pleased to support the open source community by making BK-JOB蓝鲸智云作业平台 available.
 *
 * Copyright (C) 2021 THL A29 Limited, a Tencent company.  All rights reserved.
 *
 * BK-JOB蓝鲸智云作业平台 is licensed under the MIT License.
 *
 * License for BK-JOB蓝鲸智云作业平台:
 * --------------------------------------------------------------------
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 * documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
 * to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of
 * the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
 * THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

package com.tencent.bk.job.manage.service.impl.sync;

import brave.Span;
import brave.Tracing;
import com.tencent.bk.job.common.cc.model.req.ResourceWatchReq;
import com.tencent.bk.job.common.cc.model.result.BizSetRelationEventDetail;
import com.tencent.bk.job.common.cc.model.result.ResourceEvent;
import com.tencent.bk.job.common.cc.model.result.ResourceWatchResult;
import com.tencent.bk.job.common.cc.sdk.IBizSetCmdbClient;
import com.tencent.bk.job.common.constant.ResourceScopeTypeEnum;
import com.tencent.bk.job.common.model.dto.ApplicationAttrsDO;
import com.tencent.bk.job.common.model.dto.ApplicationDTO;
import com.tencent.bk.job.common.model.dto.ResourceScope;
import com.tencent.bk.job.common.redis.util.LockUtils;
import com.tencent.bk.job.common.redis.util.RedisKeyHeartBeatThread;
import com.tencent.bk.job.common.util.ThreadUtils;
import com.tencent.bk.job.common.util.TimeUtil;
import com.tencent.bk.job.common.util.ip.IpUtils;
import com.tencent.bk.job.common.util.json.JsonUtils;
import com.tencent.bk.job.manage.service.ApplicationService;
import com.tencent.bk.job.manage.service.impl.BizSetService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;

import java.util.List;

/**
 * 业务集与业务关系事件监听
 */
@Slf4j
public class BizSetRelationWatchThread extends Thread {

    private static final String REDIS_KEY_RESOURCE_WATCH_BIZ_SET_RELATION_JOB_LOCK
        = "resource-watch-biz-set-relation-job-lock";
    private static final String machineIp = IpUtils.getFirstMachineIP();

    static {
        try {
            //进程重启首先尝试释放上次加上的锁避免死锁
            LockUtils.releaseDistributedLock(REDIS_KEY_RESOURCE_WATCH_BIZ_SET_RELATION_JOB_LOCK, machineIp);
        } catch (Throwable t) {
            log.info("Redis key:" + REDIS_KEY_RESOURCE_WATCH_BIZ_SET_RELATION_JOB_LOCK
                + " does not need to be released ignore");
        }
    }

    private final RedisTemplate<String, String> redisTemplate;
    private final ApplicationService applicationService;
    private final IBizSetCmdbClient bizSetCmdbClient;
    private final BizSetService bizSetService;
    private final Tracing tracing;

    public BizSetRelationWatchThread(RedisTemplate<String, String> redisTemplate,
                                     ApplicationService applicationService,
                                     IBizSetCmdbClient bizSetCmdbClient,
                                     BizSetService bizSetService,
                                     Tracing tracing) {
        this.redisTemplate = redisTemplate;
        this.applicationService = applicationService;
        this.bizSetCmdbClient = bizSetCmdbClient;
        this.bizSetService = bizSetService;
        this.tracing = tracing;
        this.setName("[" + getId() + "]-BizSetRelationWatchThread-");
    }

    @Override
    public void run() {
        log.info("BizSetRelationWatch arranged");
        RedisKeyHeartBeatThread bizSetRelationWatchRedisKeyHeartBeatThread = null;
        try {
            while (true) {
                try {
                    if (!bizSetService.isBizSetMigratedToCMDB()) {
                        log.warn("Job BizSets have not been migrated to CMDB, " +
                            "do not watch bizSet event from CMDB, " +
                            "please use upgrader in package to migrate as soon as possible"
                        );
                        ThreadUtils.sleep(60_000);
                        continue;
                    }

                    boolean lockGotten = tryGetTaskLockPeriodically();
                    if (!lockGotten) {
                        // 30s之后重试
                        ThreadUtils.sleep(30_000);
                        continue;
                    }

                    // 获取任务锁之后通过心跳线程维持锁的占有
                    bizSetRelationWatchRedisKeyHeartBeatThread = startBizSetRelationWatchRedisKeyHeartBeatThread();

                    watchEvent();
                } catch (Throwable t) {
                    log.error("Watching event caught exception", t);
                    if (bizSetRelationWatchRedisKeyHeartBeatThread != null) {
                        bizSetRelationWatchRedisKeyHeartBeatThread.stopAtOnce();
                    }
                    LockUtils.releaseDistributedLock(REDIS_KEY_RESOURCE_WATCH_BIZ_SET_RELATION_JOB_LOCK, machineIp);
                    // 过5s后重新尝试监听事件
                    ThreadUtils.sleep(5000);
                }
            }
        } finally {
            // 正常退出监听处理
            log.info("Quit watching bizSetRelation event, release task lock");
            if (bizSetRelationWatchRedisKeyHeartBeatThread != null) {
                bizSetRelationWatchRedisKeyHeartBeatThread.stopAtOnce();
            }
            LockUtils.releaseDistributedLock(REDIS_KEY_RESOURCE_WATCH_BIZ_SET_RELATION_JOB_LOCK, machineIp);
        }
    }

    private boolean tryGetTaskLockPeriodically() {
        boolean lockGotten = false;
        try {
            lockGotten = LockUtils.tryGetReentrantLock(REDIS_KEY_RESOURCE_WATCH_BIZ_SET_RELATION_JOB_LOCK,
                machineIp, 5_000);
            if (!lockGotten) {
                log.info("Get BizSetRelationWatch lock fail");
                return false;
            }
            lockGotten = true;
        } catch (Throwable t) {
            log.error("BizSetRelationThread quit unexpectedly", t);
        }
        return lockGotten;
    }

    private RedisKeyHeartBeatThread startBizSetRelationWatchRedisKeyHeartBeatThread() {
        // 开一个心跳子线程，维护当前机器正在WatchResource的状态
        RedisKeyHeartBeatThread bizSetRelationWatchRedisKeyHeartBeatThread = new RedisKeyHeartBeatThread(
            redisTemplate,
            REDIS_KEY_RESOURCE_WATCH_BIZ_SET_RELATION_JOB_LOCK,
            machineIp,
            5_000L,
            2_000L
        );
        bizSetRelationWatchRedisKeyHeartBeatThread.setName("[" + bizSetRelationWatchRedisKeyHeartBeatThread.getId() +
            "]-bizSetRelationWatchRedisKeyHeartBeatThread");
        bizSetRelationWatchRedisKeyHeartBeatThread.start();
        return bizSetRelationWatchRedisKeyHeartBeatThread;
    }

    private void watchEvent() {
        log.info("Start watch bizSetRelation resource at {},{}", TimeUtil.getCurrentTimeStr("HH:mm:ss"),
            System.currentTimeMillis());
        String cursor = null;
        while (true) {
            Span span = null;
            try {

                ResourceWatchResult<BizSetRelationEventDetail> bizSetRelationWatchResult;
                span = this.tracing.tracer().newTrace();
                if (cursor == null) {
                    // 从10分钟前开始watch
                    long startTime = System.currentTimeMillis() / 1000 - 10 * 60;
                    log.info("Start watch from startTime:{}", TimeUtil.formatTime(startTime * 1000));
                    bizSetRelationWatchResult = bizSetCmdbClient.getBizSetRelationEvents(startTime, null);
                } else {
                    bizSetRelationWatchResult = bizSetCmdbClient.getBizSetRelationEvents(null, cursor);
                }
                log.info("bizSetRelationWatchResult={}", JsonUtils.toJson(bizSetRelationWatchResult));
                cursor = handleBizSetRelationWatchResult(bizSetRelationWatchResult);
                // 10s/watch一次
                ThreadUtils.sleep(10_000);
            } catch (Throwable t) {
                if (span != null) {
                    span.error(t);
                }
                log.error("BizSetRelationWatch thread fail", t);
                cursor = null;
            }
        }
    }

    private String handleBizSetRelationWatchResult(
        ResourceWatchResult<BizSetRelationEventDetail> bizSetRelationWatchResult) {
        String cursor = null;
        boolean isWatched = bizSetRelationWatchResult.getWatched();
        if (isWatched) {
            List<ResourceEvent<BizSetRelationEventDetail>> events = bizSetRelationWatchResult.getEvents();
            //解析事件，进行处理
            for (ResourceEvent<BizSetRelationEventDetail> event : events) {
                handleEvent(event);
            }
            if (events.size() > 0) {
                log.info("Handle bizSetRelation watch events, events.size: {},events: {}",
                    events.size(), JsonUtils.toJson(events));
                cursor = events.get(events.size() - 1).getCursor();
                log.info("Refresh cursor:{}", cursor);
            } else {
                log.info("Handle bizSetRelation watch events, events is empty");
            }
        } else {
            // 只有一个无实际意义的事件，用于换取bk_cursor
            List<ResourceEvent<BizSetRelationEventDetail>> events = bizSetRelationWatchResult.getEvents();
            if (events != null && events.size() > 0) {
                cursor = events.get(0).getCursor();
                log.info("Refresh cursor:{}", cursor);
            } else {
                log.warn("CMDB event error:no refresh event data when watched==false");
            }
        }
        return cursor;
    }

    private void handleEvent(ResourceEvent<BizSetRelationEventDetail> event) {
        log.info("Handle BizSetRelationEvent: {}", event);
        String eventType = event.getEventType();
        switch (eventType) {
            case ResourceWatchReq.EVENT_TYPE_UPDATE:
                try {
                    Long bizSetId = event.getDetail().getBizSetId();
                    List<Long> latestSubBizIds = event.getDetail().getBizIds();
                    ApplicationDTO cacheApplication =
                        applicationService.getAppByScopeIncludingDeleted(
                            new ResourceScope(ResourceScopeTypeEnum.BIZ_SET.getValue(), String.valueOf(bizSetId))
                        );
                    if (cacheApplication == null || cacheApplication.isDeleted()) {
                        return;
                    }
                    cacheApplication.setSubBizIds(latestSubBizIds);
                    ApplicationAttrsDO attrs = cacheApplication.getAttrs();
                    if (attrs != null) {
                        attrs.setSubBizIds(latestSubBizIds);
                    }
                    applicationService.updateApp(cacheApplication);
                } catch (Throwable t) {
                    log.error("Handle biz_set_relation event fail", t);
                }
                break;
            default:
                log.info("No need to handle event: {}", event);
                break;
        }
    }

}
