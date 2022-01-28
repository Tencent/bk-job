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

package com.tencent.bk.job.execute.service.impl;

import com.tencent.bk.job.execute.dao.AgentTaskDAO;
import com.tencent.bk.job.execute.dao.StepInstanceDAO;
import com.tencent.bk.job.execute.engine.consts.IpStatus;
import com.tencent.bk.job.execute.model.StepInstanceBaseDTO;
import com.tencent.bk.job.execute.service.StepInstanceService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;

@Slf4j
@Service
public class StepInstanceServiceImpl implements StepInstanceService {

    private final StepInstanceDAO stepInstanceDAO;
    private final AgentTaskDAO agentTaskDAO;

    @Autowired
    public StepInstanceServiceImpl(StepInstanceDAO stepInstanceDAO,
                                   AgentTaskDAO agentTaskDAO) {
        this.stepInstanceDAO = stepInstanceDAO;
        this.agentTaskDAO = agentTaskDAO;
    }

    @Override
    public void updateStepCurrentBatch(long stepInstanceId, int batch) {
        stepInstanceDAO.updateStepCurrentBatch(stepInstanceId, batch);
    }

    @Override
    public void updateStepCurrentExecuteCount(long stepInstanceId, int executeCount) {
        stepInstanceDAO.updateStepCurrentExecuteCount(stepInstanceId, executeCount);
    }

    @Override
    public void updateStepRollingConfigId(long stepInstanceId, long rollingConfigId) {
        stepInstanceDAO.updateStepRollingConfigId(stepInstanceId, rollingConfigId);
    }

    @Override
    public Map<IpStatus, Integer> countStepGseAgentTaskGroupByStatus(
        long stepInstanceId, int executeCount) {
        return agentTaskDAO.countStepAgentTaskGroupByStatus(stepInstanceId, executeCount);
    }

    @Override
    public StepInstanceBaseDTO getNextStepInstance(long taskInstanceId,
                                                   int currentStepOrder) {
        return stepInstanceDAO.getNextStepInstance(taskInstanceId, currentStepOrder);
    }
}