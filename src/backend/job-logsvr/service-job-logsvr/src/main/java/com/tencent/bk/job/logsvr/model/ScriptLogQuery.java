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

package com.tencent.bk.job.logsvr.model;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Collections;
import java.util.List;

@Data
@NoArgsConstructor
public class ScriptLogQuery {
    /**
     * 作业实例创建时间,格式yyyy_MM_dd
     */
    private String jobCreateDate;
    /**
     * 作业步骤实例ID
     */
    private Long stepInstanceId;
    /**
     * 执行任务的主机ip
     */
    private List<String> ips;
    /**
     * 执行次数
     */
    private Integer executeCount;

    public ScriptLogQuery(String jobCreateDate, Long stepInstanceId, String ip, Integer executeCount) {
        this.jobCreateDate = jobCreateDate;
        this.stepInstanceId = stepInstanceId;
        this.ips = Collections.singletonList(ip);
        this.executeCount = executeCount;
    }

    public ScriptLogQuery(String jobCreateDate, Long stepInstanceId, List<String> ips, Integer executeCount) {
        this.jobCreateDate = jobCreateDate;
        this.stepInstanceId = stepInstanceId;
        this.ips = ips;
        this.executeCount = executeCount;
    }
}
