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

package com.tencent.bk.job.backup.auth;

import com.tencent.bk.job.backup.client.ServiceApplicationResourceClient;
import com.tencent.bk.job.common.app.ApplicationUtil;
import com.tencent.bk.job.common.iam.constant.ResourceTypeEnum;
import com.tencent.bk.job.common.iam.model.ResourceAppInfo;
import com.tencent.bk.job.common.iam.service.ResourceAppInfoQueryService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class BackupResourceAppInfoQueryService implements ResourceAppInfoQueryService {

    private final ServiceApplicationResourceClient applicationService;

    @Autowired
    public BackupResourceAppInfoQueryService(ServiceApplicationResourceClient applicationService) {
        this.applicationService = applicationService;
    }

    private ResourceAppInfo getResourceAppInfoById(Long appId) {
        if (appId == null || appId <= 0) {
            return null;
        }
        return ApplicationUtil.convertToResourceApp(applicationService.queryAppById(appId));
    }

    @Override
    public ResourceAppInfo getResourceAppInfo(ResourceTypeEnum resourceType, String resourceId) {
        if (resourceType == ResourceTypeEnum.BUSINESS) {
            long appId = Long.parseLong(resourceId);
            if (appId > 0) {
                return getResourceAppInfoById(appId);
            }
        } else {
            return null;
        }
        return null;
    }
}
