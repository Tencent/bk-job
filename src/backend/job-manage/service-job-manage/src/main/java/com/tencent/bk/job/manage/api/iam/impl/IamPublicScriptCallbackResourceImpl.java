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

package com.tencent.bk.job.manage.api.iam.impl;

import com.tencent.bk.job.common.app.AppTransferService;
import com.tencent.bk.job.common.model.BaseSearchCondition;
import com.tencent.bk.job.manage.api.iam.IamPublicScriptCallbackResource;
import com.tencent.bk.job.manage.model.query.ScriptQuery;
import com.tencent.bk.job.manage.service.ScriptService;
import com.tencent.bk.sdk.iam.dto.callback.request.CallbackRequestDTO;
import com.tencent.bk.sdk.iam.dto.callback.request.IamSearchCondition;
import com.tencent.bk.sdk.iam.dto.callback.response.CallbackBaseResponseDTO;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.tuple.Pair;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Slf4j
public class IamPublicScriptCallbackResourceImpl implements IamPublicScriptCallbackResource {

    private final ScriptCallbackHelper scriptCallbackHelper;

    @Autowired
    public IamPublicScriptCallbackResourceImpl(ScriptService scriptService,
                                               AppTransferService appTransferService) {
        this.scriptCallbackHelper = new ScriptCallbackHelper(scriptService, new ScriptCallbackHelper.IGetBasicInfo() {
            @Override
            public Pair<ScriptQuery, BaseSearchCondition> getBasicQueryCondition(CallbackRequestDTO callbackRequest) {
                return getBasicQueryConditionImpl(callbackRequest);
            }

            @Override
            public boolean isPublicScript() {
                return true;
            }
        }, appTransferService);
    }

    private Pair<ScriptQuery, BaseSearchCondition> getBasicQueryConditionImpl(CallbackRequestDTO callbackRequest) {
        IamSearchCondition searchCondition = IamSearchCondition.fromReq(callbackRequest);
        BaseSearchCondition baseSearchCondition = new BaseSearchCondition();
        baseSearchCondition.setStart(searchCondition.getStart().intValue());
        baseSearchCondition.setLength(searchCondition.getLength().intValue());

        ScriptQuery scriptQuery = new ScriptQuery();
        scriptQuery.setPublicScript(true);
        return Pair.of(scriptQuery, baseSearchCondition);
    }

    @Override
    public CallbackBaseResponseDTO callback(CallbackRequestDTO callbackRequest) {
        return scriptCallbackHelper.doCallback(callbackRequest);
    }
}
