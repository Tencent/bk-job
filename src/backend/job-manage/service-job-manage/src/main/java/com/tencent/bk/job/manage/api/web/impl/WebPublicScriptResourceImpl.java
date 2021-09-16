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

package com.tencent.bk.job.manage.api.web.impl;

import com.tencent.bk.job.common.model.PageData;
import com.tencent.bk.job.common.model.ServiceResponse;
import com.tencent.bk.job.manage.api.web.WebPublicScriptResource;
import com.tencent.bk.job.manage.api.web.WebScriptResource;
import com.tencent.bk.job.common.constant.JobConstants;
import com.tencent.bk.job.manage.model.web.request.ScriptCreateUpdateReq;
import com.tencent.bk.job.manage.model.web.request.ScriptInfoUpdateReq;
import com.tencent.bk.job.manage.model.web.request.ScriptSyncReq;
import com.tencent.bk.job.manage.model.web.vo.BasicScriptVO;
import com.tencent.bk.job.manage.model.web.vo.ScriptVO;
import com.tencent.bk.job.manage.model.web.vo.script.ScriptCiteCountVO;
import com.tencent.bk.job.manage.model.web.vo.script.ScriptCiteInfoVO;
import com.tencent.bk.job.manage.model.web.vo.script.ScriptRelatedTemplateStepVO;
import com.tencent.bk.job.manage.model.web.vo.script.ScriptSyncResultVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@Slf4j
public class WebPublicScriptResourceImpl implements WebPublicScriptResource {
    private static final Long PUBLIC_APP_ID = JobConstants.PUBLIC_APP_ID;
    /**
     * 脚本处理的通用服务，与普通脚本不同的是，公共脚本的业务ID=0
     * 鉴权在通用脚本逻辑中处理
     */
    private final WebScriptResource scriptResourceProxy;

    @Autowired
    public WebPublicScriptResourceImpl(@Qualifier("webScriptResourceImpl") WebScriptResource scriptResourceProxy) {
        this.scriptResourceProxy = scriptResourceProxy;
    }

    @Override
    public ServiceResponse<ScriptVO> getScriptVersionDetail(String username, Long scriptVersionId) {
        return scriptResourceProxy.getScriptVersionDetail(username, PUBLIC_APP_ID, scriptVersionId);
    }

    @Override
    public ServiceResponse<ScriptVO> getScript(String username, String scriptId) {
        return scriptResourceProxy.getScript(username, PUBLIC_APP_ID, scriptId);
    }

    @Override
    public ServiceResponse<ScriptVO> getScriptBasicInfo(String username, String scriptId) {
        return scriptResourceProxy.getScriptBasicInfo(username, PUBLIC_APP_ID, scriptId);
    }

    @Override
    public ServiceResponse<ScriptVO> getOnlineScriptVersionByScriptId(String username, String scriptId) {
        return scriptResourceProxy.getOnlineScriptVersionByScriptId(username, PUBLIC_APP_ID, scriptId, true);
    }

    @Override
    public ServiceResponse<PageData<ScriptVO>> listPageScript(String username, String name, Integer type, String tags,
                                                              String creator, String lastModifyUser, String scriptId,
                                                              Integer start, Integer pageSize, String orderField,
                                                              Integer order) {
        return scriptResourceProxy.listPageScript(username, PUBLIC_APP_ID, true, name, type, tags, creator,
            lastModifyUser,
            scriptId, start, pageSize, orderField, order);
    }

    @Override
    public ServiceResponse<List<ScriptVO>> listScriptVersion(String username, String scriptId) {
        return scriptResourceProxy.listScriptVersion(username, PUBLIC_APP_ID, scriptId);
    }

    @Override
    public ServiceResponse listAppScriptNames(String username, String scriptName) {
        return scriptResourceProxy.listAppScriptNames(username, PUBLIC_APP_ID, scriptName);
    }

    @Override
    public ServiceResponse<List<BasicScriptVO>> listScriptOnline(String username, Boolean publicScript) {
        return scriptResourceProxy.listScriptOnline(username, PUBLIC_APP_ID, true);
    }

    @Override
    public ServiceResponse updateScriptInfo(String username, String scriptId, ScriptInfoUpdateReq scriptInfoUpdateReq) {
        return scriptResourceProxy.updateScriptInfo(username, PUBLIC_APP_ID, scriptId, scriptInfoUpdateReq);
    }

    @Override
    public ServiceResponse<ScriptVO> saveScript(String username, ScriptCreateUpdateReq scriptCreateUpdateReq) {
        return scriptResourceProxy.saveScript(username, PUBLIC_APP_ID, scriptCreateUpdateReq);
    }

    @Override
    public ServiceResponse publishScriptVersion(String username, String scriptId, Long scriptVersionId) {
        return scriptResourceProxy.publishScriptVersion(username, PUBLIC_APP_ID, scriptId, scriptVersionId);
    }

    @Override
    public ServiceResponse disableScriptVersion(String username, String scriptId, Long scriptVersionId) {
        return scriptResourceProxy.disableScriptVersion(username, PUBLIC_APP_ID, scriptId, scriptVersionId);
    }

    @Override
    public ServiceResponse deleteScriptByScriptId(String username, String scriptId) {
        return scriptResourceProxy.deleteScriptByScriptId(username, PUBLIC_APP_ID, scriptId);
    }

    @Override
    public ServiceResponse deleteScriptByScriptVersionId(String username, Long scriptVersionId) {
        return scriptResourceProxy.deleteScriptByScriptVersionId(username, PUBLIC_APP_ID, scriptVersionId);
    }

    @Override
    public ServiceResponse<List<ScriptRelatedTemplateStepVO>> listScriptSyncTemplateSteps(String username,
                                                                                          String scriptId,
                                                                                          Long scriptVersionId) {
        return scriptResourceProxy.listScriptSyncTemplateSteps(username, PUBLIC_APP_ID, scriptId, scriptVersionId);
    }

    @Override
    public ServiceResponse<List<ScriptSyncResultVO>> syncScripts(String username, String scriptId,
                                                                 Long scriptVersionId, ScriptSyncReq scriptSyncReq) {
        return scriptResourceProxy.syncScripts(username, PUBLIC_APP_ID, scriptId, scriptVersionId, scriptSyncReq);
    }

    @Override
    public ServiceResponse<ScriptCiteCountVO> getPublicScriptCiteCount(String username, String scriptId,
                                                                       Long scriptVersionId) {
        return scriptResourceProxy.getScriptCiteCount(username, PUBLIC_APP_ID, scriptId, scriptVersionId);
    }

    @Override
    public ServiceResponse<ScriptCiteInfoVO> getPublicScriptCiteInfo(String username, String scriptId,
                                                                     Long scriptVersionId) {
        return scriptResourceProxy.getScriptCiteInfo(username, PUBLIC_APP_ID, scriptId, scriptVersionId);
    }
}
