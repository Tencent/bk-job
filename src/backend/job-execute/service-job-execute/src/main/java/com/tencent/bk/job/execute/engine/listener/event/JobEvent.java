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

package com.tencent.bk.job.execute.engine.listener.event;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.tencent.bk.job.execute.engine.consts.JobActionEnum;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.StringJoiner;

/**
 * 执行引擎-Job事件
 */
@Getter
@Setter
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class JobEvent extends Event {
    /**
     * 作业操作
     *
     * @see com.tencent.bk.job.execute.engine.consts.JobActionEnum
     */
    private int action;
    /**
     * 作业实例ID
     */
    private long taskInstanceId;

    public static JobEvent startJob(long taskInstanceId) {
        JobEvent jobEvent = new JobEvent();
        jobEvent.setTaskInstanceId(taskInstanceId);
        jobEvent.setAction(JobActionEnum.START.getValue());
        jobEvent.setTime(LocalDateTime.now());
        return jobEvent;
    }

    public static JobEvent stopJob(long taskInstanceId) {
        JobEvent jobEvent = new JobEvent();
        jobEvent.setTaskInstanceId(taskInstanceId);
        jobEvent.setAction(JobActionEnum.STOP.getValue());
        jobEvent.setTime(LocalDateTime.now());
        return jobEvent;
    }

    public static JobEvent restartJob(long taskInstanceId) {
        JobEvent jobEvent = new JobEvent();
        jobEvent.setTaskInstanceId(taskInstanceId);
        jobEvent.setAction(JobActionEnum.RESTART.getValue());
        jobEvent.setTime(LocalDateTime.now());
        return jobEvent;
    }

    public static JobEvent refreshJob(long taskInstanceId, EventSource eventSource) {
        JobEvent jobEvent = new JobEvent();
        jobEvent.setTaskInstanceId(taskInstanceId);
        jobEvent.setSource(eventSource);
        jobEvent.setAction(JobActionEnum.REFRESH.getValue());
        jobEvent.setTime(LocalDateTime.now());
        return jobEvent;
    }

    @Override
    public String toString() {
        return new StringJoiner(", ", JobEvent.class.getSimpleName() + "[", "]")
            .add("action=" + action)
            .add("actionDesc=" + JobActionEnum.valueOf(action))
            .add("taskInstanceId=" + taskInstanceId)
            .add("eventSource=" + source)
            .add("time=" + time)
            .toString();
    }
}
