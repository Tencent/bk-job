package com.tencent.bk.job.execute.service.impl;

import com.tencent.bk.job.common.constant.Order;
import com.tencent.bk.job.execute.dao.ScriptAgentTaskDAO;
import com.tencent.bk.job.execute.engine.consts.IpStatus;
import com.tencent.bk.job.execute.model.AgentTaskDTO;
import com.tencent.bk.job.execute.model.AgentTaskResultGroupBaseDTO;
import com.tencent.bk.job.execute.model.AgentTaskResultGroupDTO;
import com.tencent.bk.job.execute.service.ScriptAgentTaskService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections4.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Slf4j
public class ScriptAgentTaskServiceImpl implements ScriptAgentTaskService {
    private final ScriptAgentTaskDAO scriptAgentTaskDAO;

    @Autowired
    public ScriptAgentTaskServiceImpl(ScriptAgentTaskDAO scriptAgentTaskDAO) {
        this.scriptAgentTaskDAO = scriptAgentTaskDAO;
    }

    @Override
    public void batchSaveAgentTasks(List<AgentTaskDTO> agentTasks) {
        scriptAgentTaskDAO.batchSaveAgentTasks(agentTasks);
    }

    @Override
    public void batchUpdateAgentTasks(List<AgentTaskDTO> agentTasks) {
        scriptAgentTaskDAO.batchUpdateAgentTasks(agentTasks);
    }

    @Override
    public int getSuccessAgentTaskCount(long stepInstanceId, int executeCount) {
        return scriptAgentTaskDAO.getSuccessAgentTaskCount(stepInstanceId, executeCount);
    }

    @Override
    public List<AgentTaskResultGroupDTO> listAndGroupAgentTasks(long stepInstanceId, int executeCount, Integer batch) {
        final List<AgentTaskResultGroupDTO> resultGroups = new ArrayList<>();
        List<AgentTaskDTO> agentTasks = listAgentTasks(stepInstanceId, executeCount, batch);
        if (CollectionUtils.isEmpty(agentTasks)) {
            return resultGroups;
        }

        agentTasks.stream().collect(
            Collectors.groupingBy(agentTask -> new AgentTaskResultGroupDTO(agentTask.getStatus(), agentTask.getTag())))
            .forEach((resultGroup, groupedAgentTasks) -> {
                resultGroup.setAgentTasks(groupedAgentTasks);
                resultGroup.setTotalAgentTasks(groupedAgentTasks.size());
                resultGroups.add(resultGroup);
            });

        return resultGroups.stream().sorted().collect(Collectors.toList());
    }

    @Override
    public List<AgentTaskResultGroupBaseDTO> listResultGroups(long stepInstanceId, int executeCount, Integer batch) {
        return scriptAgentTaskDAO.listResultGroups(stepInstanceId, executeCount, batch);
    }

    @Override
    public List<AgentTaskDTO> listAgentTasksByResultGroup(Long stepInstanceId, Integer executeCount, Integer batch,
                                                          Integer status, String tag) {
        return scriptAgentTaskDAO.listAgentTaskByResultGroup(stepInstanceId, executeCount, batch,
            status, tag);
    }

    @Override
    public List<AgentTaskDTO> listAgentTaskByResultGroup(Long stepInstanceId, Integer executeCount, Integer batch,
                                                         Integer status, String tag, Integer limit, String orderField,
                                                         Order order) {
        return scriptAgentTaskDAO.listAgentTaskByResultGroup(stepInstanceId, executeCount, batch, status, tag,
            limit, orderField, order);
    }

    @Override
    public List<AgentTaskDTO> listAgentTasks(Long stepInstanceId, Integer executeCount, Integer batch) {
        return scriptAgentTaskDAO.listAgentTasks(stepInstanceId, executeCount, batch);
    }

    @Override
    public List<AgentTaskDTO> listAgentTasksByGseTaskId(Long gseTaskId) {
        return scriptAgentTaskDAO.listAgentTasksByGseTaskId(gseTaskId);
    }

    @Override
    public Map<IpStatus, Integer> countStepAgentTaskByStatus(long stepInstanceId, int executeCount) {
        return scriptAgentTaskDAO.countStepAgentTaskGroupByStatus(stepInstanceId, executeCount);
    }

    @Override
    public AgentTaskDTO getAgentTaskByIp(Long stepInstanceId, Integer executeCount, Integer batch, String cloudIp) {
        return scriptAgentTaskDAO.getAgentTaskByIp(stepInstanceId, executeCount, batch, cloudIp);
    }

    @Override
    public List<String> fuzzySearchTargetIpsByIpKeyword(Long stepInstanceId, Integer executeCount, String ipKeyword) {
        return scriptAgentTaskDAO.fuzzySearchIpsByIpKeyword(stepInstanceId, executeCount, ipKeyword);
    }

    @Override
    public int getActualSuccessExecuteCount(long stepInstanceId, Integer batch, String cloudIp) {
        return scriptAgentTaskDAO.getActualSuccessExecuteCount(stepInstanceId, batch, cloudIp);
    }

}