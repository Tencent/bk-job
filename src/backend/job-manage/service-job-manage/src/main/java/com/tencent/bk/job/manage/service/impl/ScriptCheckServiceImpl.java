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

package com.tencent.bk.job.manage.service.impl;

import com.tencent.bk.job.common.constant.ErrorCode;
import com.tencent.bk.job.common.exception.InternalException;
import com.tencent.bk.job.common.util.json.JsonUtils;
import com.tencent.bk.job.manage.common.consts.script.ScriptTypeEnum;
import com.tencent.bk.job.manage.dao.globalsetting.DangerousRuleDAO;
import com.tencent.bk.job.manage.manager.script.check.ScriptCheckParam;
import com.tencent.bk.job.manage.manager.script.check.checker.BuildInDangerousScriptChecker;
import com.tencent.bk.job.manage.manager.script.check.checker.DangerousRuleScriptChecker;
import com.tencent.bk.job.manage.manager.script.check.checker.DeviceCrashScriptChecker;
import com.tencent.bk.job.manage.manager.script.check.checker.IOScriptChecker;
import com.tencent.bk.job.manage.manager.script.check.checker.ScriptGrammarChecker;
import com.tencent.bk.job.manage.manager.script.check.checker.ScriptLogicChecker;
import com.tencent.bk.job.manage.model.db.DangerousRuleDO;
import com.tencent.bk.job.manage.model.dto.ScriptCheckResultItemDTO;
import com.tencent.bk.job.manage.model.dto.globalsetting.DangerousRuleDTO;
import com.tencent.bk.job.manage.service.ScriptCheckService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.jooq.DSLContext;
import org.slf4j.helpers.MessageFormatter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
public class ScriptCheckServiceImpl implements ScriptCheckService {

    private final DSLContext dslContext;
    private final DangerousRuleDAO dangerousRuleDAO;
    private final RedisTemplate redisTemplate;
    private final ExecutorService executor = new ThreadPoolExecutor(
        10, 50, 60L, TimeUnit.SECONDS,
        new LinkedBlockingQueue<Runnable>());

    @Autowired
    public ScriptCheckServiceImpl(DSLContext dslContext, DangerousRuleDAO dangerousRuleDAO,
                                  @Qualifier("jsonRedisTemplate") RedisTemplate redisTemplate) {
        this.dslContext = dslContext;
        this.dangerousRuleDAO = dangerousRuleDAO;
        this.redisTemplate = redisTemplate;
    }

    public List<DangerousRuleDTO> listDangerousRuleFromCache(Integer scriptType) throws ExecutionException {
        Object dangerousRules = redisTemplate.opsForHash().get("job:manage:dangerousRules", String.valueOf(scriptType));
        if (dangerousRules == null) {
            log.info("dangerousRules is not in cache!");
            List<DangerousRuleDTO> dangerousRuleDTOList = dangerousRuleDAO.listDangerousRulesByScriptType(dslContext,
                scriptType);
            if (CollectionUtils.isEmpty(dangerousRuleDTOList)) {
                redisTemplate.opsForHash().put("job:manage:dangerousRules", String.valueOf(scriptType),
                    new ArrayList<DangerousRuleDO>());
                return new ArrayList<DangerousRuleDTO>();
            }
            try {
                log.info("Refresh dangerousRules cache, dangerousRules:{}", JsonUtils.toJson(dangerousRuleDTOList));
                List<DangerousRuleDO> dangerousRuleDOList = new ArrayList<>();
                dangerousRuleDTOList.forEach(dangerousRuleDTO -> {
                    dangerousRuleDOList.add(convertToDangerousRuleDO(dangerousRuleDTO));
                });
                redisTemplate.opsForHash().put("job:manage:dangerousRules", String.valueOf(scriptType),
                    dangerousRuleDOList);
            } catch (Exception e) {
                log.error("Refresh dangerousRules cache fail", e);
            }
            return dangerousRuleDTOList;
        }
        List<DangerousRuleDO> dangerousRuleDOList = (List<DangerousRuleDO>) dangerousRules;
        List<DangerousRuleDTO> dangerousRuleDTOList = new ArrayList<>();
        dangerousRuleDOList.forEach(dangerousRuleDO -> {
            dangerousRuleDTOList.add(convertToDangerousRuleDTO(dangerousRuleDO));
        });
        return dangerousRuleDTOList;
    }

    private DangerousRuleDTO convertToDangerousRuleDTO(DangerousRuleDO dangerousRuleDO) {
        DangerousRuleDTO dangerousRuleDTO = new DangerousRuleDTO();
        dangerousRuleDTO.setId(dangerousRuleDO.getId());
        dangerousRuleDTO.setExpression(dangerousRuleDO.getExpression());
        dangerousRuleDTO.setPriority(dangerousRuleDO.getPriority());
        dangerousRuleDTO.setScriptType(dangerousRuleDO.getScriptType());
        dangerousRuleDTO.setCreator(dangerousRuleDO.getCreator());
        dangerousRuleDTO.setCreateTime(dangerousRuleDO.getCreateTime());
        dangerousRuleDTO.setLastModifier(dangerousRuleDO.getLastModifier());
        dangerousRuleDTO.setLastModifyTime(dangerousRuleDO.getLastModifyTime());
        dangerousRuleDTO.setAction(dangerousRuleDO.getAction());
        dangerousRuleDTO.setStatus(dangerousRuleDO.getStatus());
        return dangerousRuleDTO;
    }

    private DangerousRuleDO convertToDangerousRuleDO(DangerousRuleDTO dangerousRuleDTO) {
        DangerousRuleDO dangerousRuleDO = new DangerousRuleDO();
        dangerousRuleDO.setId(dangerousRuleDTO.getId());
        dangerousRuleDO.setExpression(dangerousRuleDTO.getExpression());
        dangerousRuleDO.setPriority(dangerousRuleDTO.getPriority());
        dangerousRuleDO.setScriptType(dangerousRuleDTO.getScriptType());
        dangerousRuleDO.setCreator(dangerousRuleDTO.getCreator());
        dangerousRuleDO.setCreateTime(dangerousRuleDTO.getCreateTime());
        dangerousRuleDO.setLastModifier(dangerousRuleDTO.getLastModifier());
        dangerousRuleDO.setLastModifyTime(dangerousRuleDTO.getLastModifyTime());
        dangerousRuleDO.setAction(dangerousRuleDTO.getAction());
        dangerousRuleDO.setStatus(dangerousRuleDTO.getStatus());
        return dangerousRuleDO;
    }

    @Override
    public List<ScriptCheckResultItemDTO> check(ScriptTypeEnum scriptType, String content) {
        List<ScriptCheckResultItemDTO> checkResultList = new ArrayList<>();
        if (StringUtils.isBlank(content)) {
            return checkResultList;
        }

        try {
            List<DangerousRuleDTO> dangerousRules = listDangerousRuleFromCache(scriptType.getValue());
            int timeout = 5;
            ScriptCheckParam scriptCheckParam = new ScriptCheckParam(scriptType, content);
            Future<List<ScriptCheckResultItemDTO>> dangerousRuleCheckResultItems =
                executor.submit(new DangerousRuleScriptChecker(scriptCheckParam, dangerousRules));
            if (ScriptTypeEnum.SHELL.equals(scriptType)) {
                Future<List<ScriptCheckResultItemDTO>> grammar = executor.submit(new ScriptGrammarChecker(scriptType,
                    content));

                Future<List<ScriptCheckResultItemDTO>> danger =
                    executor.submit(new BuildInDangerousScriptChecker(scriptCheckParam));

                Future<List<ScriptCheckResultItemDTO>> logic =
                    executor.submit(new ScriptLogicChecker(scriptCheckParam));

                Future<List<ScriptCheckResultItemDTO>> io = executor.submit(new IOScriptChecker(scriptCheckParam));

                Future<List<ScriptCheckResultItemDTO>> device =
                    executor.submit(new DeviceCrashScriptChecker(scriptCheckParam));
                checkResultList.addAll(grammar.get(timeout, TimeUnit.SECONDS));
                checkResultList.addAll(logic.get(timeout, TimeUnit.SECONDS));
                checkResultList.addAll(danger.get(timeout, TimeUnit.SECONDS));
                checkResultList.addAll(io.get(timeout, TimeUnit.SECONDS));
                checkResultList.addAll(device.get(timeout, TimeUnit.SECONDS));
            }
            checkResultList.addAll(dangerousRuleCheckResultItems.get(timeout, TimeUnit.SECONDS));
            checkResultList.sort(Comparator.comparingInt(ScriptCheckResultItemDTO::getLine));

        } catch (Exception e) {
            // 脚本检查非强制，如果检查过程中抛出异常不应该影响业务的使用
            String errorMsg = MessageFormatter.format(
                "Check script caught exception! scriptType: {}, content: {}",
                scriptType, content).getMessage();
            log.error(errorMsg, e);
            return Collections.emptyList();
        }
        return checkResultList;
    }

    @Override
    public List<ScriptCheckResultItemDTO> checkScriptWithDangerousRule(ScriptTypeEnum scriptType, String content) {
        List<ScriptCheckResultItemDTO> checkResultList = new ArrayList<>();

        if (StringUtils.isBlank(content)) {
            return Collections.emptyList();
        }

        try {
            int timeout = 5;
            ScriptCheckParam scriptCheckParam = new ScriptCheckParam(scriptType, content);
            List<DangerousRuleDTO> dangerousRules = listDangerousRuleFromCache(scriptType.getValue());
            if (CollectionUtils.isEmpty(dangerousRules)) {
                return Collections.emptyList();
            }
            Future<List<ScriptCheckResultItemDTO>> dangerousRuleCheckResultItems = executor.submit(
                new DangerousRuleScriptChecker(scriptCheckParam, dangerousRules));
            checkResultList.addAll(dangerousRuleCheckResultItems.get(timeout, TimeUnit.SECONDS));
            checkResultList.sort(Comparator.comparingInt(ScriptCheckResultItemDTO::getLine));
        } catch (Exception e) {
            String errorMsg = MessageFormatter.format(
                "Check script caught exception! scriptType: {}, content: {}",
                scriptType, content).getMessage();
            log.error(errorMsg, e);
            throw new InternalException(e, ErrorCode.INTERNAL_ERROR);
        }
        return checkResultList;
    }
}
