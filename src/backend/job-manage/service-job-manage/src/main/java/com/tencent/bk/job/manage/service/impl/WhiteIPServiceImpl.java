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

import com.google.common.collect.Lists;
import com.tencent.bk.job.common.RequestIdLogger;
import com.tencent.bk.job.common.cc.model.CcCloudAreaInfoDTO;
import com.tencent.bk.job.common.cc.sdk.CmdbClientFactory;
import com.tencent.bk.job.common.constant.AppTypeEnum;
import com.tencent.bk.job.common.constant.ErrorCode;
import com.tencent.bk.job.common.exception.InternalException;
import com.tencent.bk.job.common.exception.InvalidParamException;
import com.tencent.bk.job.common.i18n.service.MessageI18nService;
import com.tencent.bk.job.common.model.BaseSearchCondition;
import com.tencent.bk.job.common.model.PageData;
import com.tencent.bk.job.common.model.dto.ApplicationDTO;
import com.tencent.bk.job.common.model.dto.IpDTO;
import com.tencent.bk.job.common.model.dto.ResourceScope;
import com.tencent.bk.job.common.model.vo.CloudAreaInfoVO;
import com.tencent.bk.job.common.service.AppScopeMappingService;
import com.tencent.bk.job.common.util.ArrayUtil;
import com.tencent.bk.job.common.util.JobContextUtil;
import com.tencent.bk.job.common.util.LogUtil;
import com.tencent.bk.job.common.util.SimpleRequestIdLogger;
import com.tencent.bk.job.common.util.StringUtil;
import com.tencent.bk.job.common.util.ip.IpUtils;
import com.tencent.bk.job.common.util.json.JsonUtils;
import com.tencent.bk.job.manage.common.consts.whiteip.ActionScopeEnum;
import com.tencent.bk.job.manage.dao.ApplicationDAO;
import com.tencent.bk.job.manage.dao.whiteip.ActionScopeDAO;
import com.tencent.bk.job.manage.dao.whiteip.WhiteIPRecordDAO;
import com.tencent.bk.job.manage.model.dto.whiteip.ActionScopeDTO;
import com.tencent.bk.job.manage.model.dto.whiteip.CloudIPDTO;
import com.tencent.bk.job.manage.model.dto.whiteip.WhiteIPActionScopeDTO;
import com.tencent.bk.job.manage.model.dto.whiteip.WhiteIPIPDTO;
import com.tencent.bk.job.manage.model.dto.whiteip.WhiteIPRecordDTO;
import com.tencent.bk.job.manage.model.inner.ServiceWhiteIPInfo;
import com.tencent.bk.job.manage.model.inner.request.ServiceCheckNotAllowedInWhiteIpReq;
import com.tencent.bk.job.manage.model.web.request.whiteip.WhiteIPRecordCreateUpdateReq;
import com.tencent.bk.job.manage.model.web.vo.AppVO;
import com.tencent.bk.job.manage.model.web.vo.whiteip.ActionScopeVO;
import com.tencent.bk.job.manage.model.web.vo.whiteip.WhiteIPRecordVO;
import com.tencent.bk.job.manage.service.ApplicationService;
import com.tencent.bk.job.manage.service.WhiteIPService;
import lombok.extern.slf4j.Slf4j;
import lombok.val;
import lombok.var;
import org.apache.commons.collections4.CollectionUtils;
import org.jooq.DSLContext;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Slf4j
@Service
public class WhiteIPServiceImpl implements WhiteIPService {

    private static final RequestIdLogger LOG =
        new SimpleRequestIdLogger(LoggerFactory.getLogger(WhiteIPServiceImpl.class));
    private static final String SEPERATOR_COMMA = ",";
    private static final String SEPERATOR_ENTER = "\n";
    private final MessageI18nService i18nService;
    private final DSLContext dslContext;
    private final ActionScopeDAO actionScopeDAO;
    private final WhiteIPRecordDAO whiteIPRecordDAO;
    private final ApplicationDAO applicationDAO;
    private final ApplicationService applicationService;
    private final AppScopeMappingService appScopeMappingService;

    @Autowired
    public WhiteIPServiceImpl(
        @Qualifier("job-manage-dsl-context") DSLContext dslContext,
        ActionScopeDAO actionScopeDAO,
        WhiteIPRecordDAO whiteIPRecordDAO,
        ApplicationDAO applicationDAO,
        ApplicationService applicationService,
        MessageI18nService i18nService,
        AppScopeMappingService appScopeMappingService) {
        this.dslContext = dslContext;
        this.actionScopeDAO = actionScopeDAO;
        this.whiteIPRecordDAO = whiteIPRecordDAO;
        this.applicationDAO = applicationDAO;
        this.i18nService = i18nService;
        this.applicationService = applicationService;
        this.appScopeMappingService = appScopeMappingService;
    }

    @Override
    public PageData<WhiteIPRecordVO> listWhiteIPRecord(
        String username,
        String ipStr,
        String appIdStr,
        String appNameStr,
        String actionScopeIdStr,
        String creator,
        String lastModifyUser,
        Integer start,
        Integer pageSize,
        String orderField,
        Integer order
    ) {
        LOG.infoWithRequestId(
            LogUtil.getInputLog(
                username, ipStr, appIdStr,
                actionScopeIdStr, lastModifyUser, start,
                pageSize, orderField, order
            )
        );
        //1.参数校验、预处理
        if (null == ipStr) {
            ipStr = "";
        }
        List<Long> appIdList = StringUtil.strToList(appIdStr, Long.class, SEPERATOR_COMMA);
        List<Long> actionScopeIdList = StringUtil.strToList(actionScopeIdStr, Long.class, SEPERATOR_COMMA);
        List<String> appNameList = StringUtil.strToList(appNameStr, String.class, SEPERATOR_COMMA);
        List<String> ipList = StringUtil.strToList(ipStr, String.class, SEPERATOR_COMMA);
        if (start == null || start < 0) {
            start = 0;
        }
        if (pageSize == null || pageSize <= 0) {
            pageSize = 10;
        }
        BaseSearchCondition baseSearchCondition = new BaseSearchCondition();
        baseSearchCondition.setStart(start);
        baseSearchCondition.setLength(pageSize);
        baseSearchCondition.setOrderField(orderField);
        baseSearchCondition.setOrder(order);

        val whiteIPRecordList = whiteIPRecordDAO.listWhiteIPRecord(
            dslContext,
            ipList,
            appIdList,
            appNameList,
            actionScopeIdList,
            creator,
            lastModifyUser,
            baseSearchCondition
        );
        val total = whiteIPRecordDAO.countWhiteIPRecord(
            dslContext,
            ipList,
            appIdList,
            appNameList,
            actionScopeIdList,
            creator,
            lastModifyUser,
            baseSearchCondition
        );

        PageData<WhiteIPRecordVO> whiteIPRecordPageData = new PageData<>(
            start,
            pageSize,
            total,
            whiteIPRecordList
        );
        LOG.infoWithRequestId(
            "Output:whiteIPRecordPageData("
                + start
                + "," + pageSize
                + "," + total
                + "," + whiteIPRecordList.size() + ")"
        );
        return whiteIPRecordPageData;
    }

    @Override
    public List<CloudIPDTO> listWhiteIP(Long appId, ActionScopeEnum actionScope) {
        List<Long> fullAppIds = applicationService.getBizSetAppIdsForBiz(appId);
        log.info("appId={}, contains by fullAppIds={}", appId, fullAppIds);
        ActionScopeDTO actionScopeDTO = null;
        if (actionScope != null) {
            actionScopeDTO = actionScopeDAO.getActionScopeByCode(actionScope.name());
        }
        return whiteIPRecordDAO.listWhiteIPByAppIds(
            dslContext,
            fullAppIds,
            actionScopeDTO == null ? null : actionScopeDTO.getId()
        );
    }

    private List<String> checkReqAndGetIpList(WhiteIPRecordCreateUpdateReq createUpdateReq) {
        List<ResourceScope> scopeList = createUpdateReq.getScopeList();
        if (null == scopeList || scopeList.isEmpty()) {
            log.warn("scopeList cannot be null or empty");
            throw new InvalidParamException(ErrorCode.ILLEGAL_PARAM_WITH_PARAM_NAME_AND_REASON,
                ArrayUtil.toArray("scopeList", "scopeList cannot be null or empty"));
        }
        Long cloudAreaId = createUpdateReq.getCloudAreaId();
        if (null == cloudAreaId) {
            log.warn("cloudAreaId cannot be null");
            throw new InvalidParamException(ErrorCode.ILLEGAL_PARAM_WITH_PARAM_NAME_AND_REASON,
                ArrayUtil.toArray("cloudAreaId", "cloudAreaId cannot be null"));
        }
        String remark = createUpdateReq.getRemark();
        if (null != remark && remark.length() > 100) {
            log.warn("remark cannot be null and length cannot be over 100");
            throw new InvalidParamException(ErrorCode.ILLEGAL_PARAM_WITH_PARAM_NAME_AND_REASON,
                ArrayUtil.toArray("remark", "remark cannot be null and length cannot be over 100"));
        }
        String ipStr = createUpdateReq.getIpStr();
        List<String> ipList;
        if (null == ipStr || ipStr.trim().isEmpty()) {
            log.warn("ipStr cannot be null or empty");
            throw new InvalidParamException(ErrorCode.ILLEGAL_PARAM_WITH_PARAM_NAME_AND_REASON,
                ArrayUtil.toArray("ipStr", "length of ipStr cannot be over 5000"));
        } else if (ipStr.length() > 5000) {
            log.warn("length of ipStr cannot be over 5000");
            throw new InvalidParamException(ErrorCode.ILLEGAL_PARAM);
        } else {
            ipList = Arrays.asList(ipStr.trim().split(SEPERATOR_ENTER));
            //过滤空值
            ipList = ipList.stream().filter(ip -> !ip.trim().isEmpty()).collect(Collectors.toList());
            ipList.forEach(ip -> {
                //正则校验
                if (!IpUtils.checkIp(ip.trim())) {
                    log.warn("not a valid ip format");
                    throw new InvalidParamException(ErrorCode.ILLEGAL_PARAM_WITH_PARAM_NAME_AND_REASON,
                        ArrayUtil.toArray("ipStr", "not a valid ip format"));
                }
            });
        }
        List<String> uniqueIpList = new ArrayList<>();
        for (String ip : ipList) {
            if (!uniqueIpList.contains(ip)) {
                uniqueIpList.add(ip);
            }
        }
        return uniqueIpList;
    }

    @Override
    public Long saveWhiteIP(String username, WhiteIPRecordCreateUpdateReq createUpdateReq) {
        LOG.infoWithRequestId("Input(" + username + "," + createUpdateReq.toString() + ")");
        // 1.参数校验、预处理
        List<String> ipList = checkReqAndGetIpList(createUpdateReq);
        // 2.appId转换
        List<ResourceScope> scopeList = createUpdateReq.getScopeList();
        Map<ResourceScope, Long> scopeAppIdMap = appScopeMappingService.getAppIdByScopeList(scopeList);
        List<Long> appIdList = scopeList.parallelStream()
            .map(scope -> {
                Long appId = scopeAppIdMap.get(scope);
                if (appId == null) {
                    String msg = "Cannot find appId by scope " + scope;
                    throw new InternalException(msg, ErrorCode.INTERNAL_ERROR);
                }
                return appId;
            }).collect(Collectors.toList());

        List<Long> actionScopeIdList = createUpdateReq.getActionScopeIdList();
        val ipDtoList = ipList.stream().map(ip -> new WhiteIPIPDTO(
            null,
            null,
            createUpdateReq.getCloudAreaId(),
            ip,
            username,
            System.currentTimeMillis(),
            username,
            System.currentTimeMillis()
        )).collect(Collectors.toList());
        val actionScopeDtoList = actionScopeIdList.stream().map(actionScopeId -> new WhiteIPActionScopeDTO(
            null,
            null,
            actionScopeId,
            username,
            System.currentTimeMillis(),
            username,
            System.currentTimeMillis()
        )).collect(Collectors.toList());
        var recordId = createUpdateReq.getId();
        if (recordId != null && recordId > 0) {
            Long finalRecordId = recordId;
            ipDtoList.forEach(it -> it.setRecordId(finalRecordId));
            actionScopeDtoList.forEach(it -> it.setRecordId(finalRecordId));
            WhiteIPRecordDTO whiteIPRecordDTO = whiteIPRecordDAO.getWhiteIPRecordById(dslContext, recordId);
            whiteIPRecordDTO.setAppIdList(appIdList);
            whiteIPRecordDTO.setRemark(createUpdateReq.getRemark());
            whiteIPRecordDTO.setIpList(ipDtoList);
            whiteIPRecordDTO.setActionScopeList(actionScopeDtoList);
            whiteIPRecordDTO.setLastModifier(username);
            whiteIPRecordDTO.setLastModifyTime(System.currentTimeMillis());
            //修改
            whiteIPRecordDAO.updateWhiteIPRecordById(dslContext, whiteIPRecordDTO);
        } else {
            //新增
            recordId = whiteIPRecordDAO.insertWhiteIPRecord(dslContext, new WhiteIPRecordDTO(
                null,
                appIdList,
                createUpdateReq.getRemark(),
                ipDtoList,
                actionScopeDtoList,
                username,
                System.currentTimeMillis(),
                username,
                System.currentTimeMillis()
            ));
            LOG.infoWithRequestId("insert success,recordId=" + recordId);
        }
        return recordId;
    }

    @Override
    public WhiteIPRecordVO getWhiteIPDetailById(String username, Long id) {
        LOG.infoWithRequestId("Input(" + username + "," + id + ")");
        val record = whiteIPRecordDAO.getWhiteIPRecordById(dslContext, id);
        Long cloudAreaId = null;
        if (record.getIpList().size() > 0) {
            cloudAreaId = record.getIpList().get(0).getCloudAreaId();
        }
        val applicationInfoList = applicationDAO.listAppsByAppIds(record.getAppIdList());
        List<AppVO> appVOList = applicationInfoList.stream().map(it -> {
            int appType = -1;
            if (it.getAppType() != null) {
                appType = it.getAppType().getValue();
            }
            return new AppVO(
                it.getId(),
                it.getScope().getType().getValue(),
                it.getScope().getId(),
                it.getName(),
                appType,
                null,
                null,
                null
            );
        }).collect(Collectors.toList());
        return new WhiteIPRecordVO(
            id,
            cloudAreaId,
            record.getIpList().stream().map(WhiteIPIPDTO::getIp).collect(Collectors.toList()),
            record.getActionScopeList().stream().map(actionScopeDTO -> {
                val actionScopeId = actionScopeDTO.getActionScopeId();
                return actionScopeDAO.getActionScopeVOById(actionScopeId);
            }).collect(Collectors.toList()),
            appVOList,
            record.getRemark(),
            record.getCreator(),
            record.getCreateTime(),
            record.getLastModifier(),
            record.getLastModifyTime()
        );
    }

    @Override
    public List<CloudAreaInfoVO> listCloudAreas(String username) {
        LOG.infoWithRequestId("Input(" + username + ")");
        List<CcCloudAreaInfoDTO> cloudAreaInfoList = CmdbClientFactory.getCmdbClient(JobContextUtil.getUserLang())
            .getCloudAreaList();
        return cloudAreaInfoList.stream().map(it ->
            new CloudAreaInfoVO(it.getId(), it.getName())).collect(Collectors.toList());
    }

    @Override
    public List<ActionScopeVO> listActionScope(String username) {
        return actionScopeDAO.listActionScopeDTO().stream().map(it ->
            new ActionScopeVO(
                it.getId(),
                i18nService.getI18n(ActionScopeEnum.getI18nCodeByName(it.getCode())),
                it.getCreator(),
                it.getCreateTime(),
                it.getLastModifier(),
                it.getLastModifyTime()
            )
        ).collect(Collectors.toList());
    }

    @Override
    public Long deleteWhiteIPById(String username, Long id) {
        return (long) whiteIPRecordDAO.deleteWhiteIPRecordById(dslContext, id);
    }

    @Override
    public List<String> getWhiteIPActionScopes(Long appId, String ip, Long cloudAreaId) {
        log.info("Input=({},{},{})", appId, ip, cloudAreaId);
        // 1.找出包含当前业务的业务集与全业务
        List<Long> fullAppIds = applicationService.getBizSetAppIdsForBiz(appId);
        // 2.再找对应的白名单
        return whiteIPRecordDAO.getWhiteIPActionScopes(dslContext, fullAppIds, ip, cloudAreaId);
    }

    @Override
    public Map<IpDTO, List<String>> getWhiteIPActionScopes(ServiceCheckNotAllowedInWhiteIpReq scriptCreateUpdateReq) {
        log.info("Input=({})", JsonUtils.toJson(scriptCreateUpdateReq));
        // 1.找出包含当前业务的业务集与全业务
        List<Long> fullAppIds = applicationService.getBizSetAppIdsForBiz(scriptCreateUpdateReq.getAppId());
        // 2.再找对应的白名单
        List<IpDTO> ipDTOList = scriptCreateUpdateReq.getHosts();
        return whiteIPRecordDAO.getWhiteIPActionScopes(dslContext, fullAppIds, ipDTOList);
    }

    @Override
    public List<ServiceWhiteIPInfo> listWhiteIPInfos() {
        List<ServiceWhiteIPInfo> resultList = new ArrayList<>();
        //查出所有Record
        List<WhiteIPRecordDTO> recordList = whiteIPRecordDAO.listAllWhiteIPRecord(dslContext);
        if(CollectionUtils.isEmpty(recordList)){
            return resultList;
        }
        //查询appIdList长度为1的业务信息
        Set<Long> appIdSet = new HashSet<>();
        Set<Long> scopeIdSet = new HashSet<>();
        List<ApplicationDTO> applicationDTOList = new ArrayList<>();
        recordList.parallelStream().forEach(record -> {
            appIdSet.addAll(record.getAppIdList());
            //添加所有包含生效范围id列表，方便后续一次性查出关联的生效范围code
            scopeIdSet.addAll(record.getActionScopeList().parallelStream().map(scope -> scope.getActionScopeId()).collect(Collectors.toSet()));
        });
        if (CollectionUtils.isNotEmpty(appIdSet)) {
            applicationDTOList = applicationService.listAppsByAppIds(appIdSet);
        }

        Map<Long, List<ApplicationDTO>> applicationDTOMap = applicationDTOList.parallelStream().collect(
            Collectors.groupingBy(ApplicationDTO::getId));

        int maxInCount = 1000;
        List<List<Long>> scopeIdsList = Lists.partition(new ArrayList<>(scopeIdSet), maxInCount);
        List<ActionScopeDTO> actionScopeDTOList = new ArrayList<>();
        for (List<Long> scopeIdList : scopeIdsList) {
            actionScopeDTOList.addAll(actionScopeDAO.getActionScopeByIds(scopeIdList));
        }

        Map<Long, List<ActionScopeDTO>> actionScopeDTOMap = actionScopeDTOList.parallelStream().collect(
            Collectors.groupingBy(ActionScopeDTO::getId));

        if (CollectionUtils.isNotEmpty(recordList)) {
            for (WhiteIPRecordDTO whiteIPRecordDTO : recordList) {
                boolean isAllApp = false;
                List<Long> appIdList = whiteIPRecordDTO.getAppIdList();
                for (Long appId : appIdList) {
                    ApplicationDTO applicationDTO = applicationDTOMap.get(appId) == null ? null :
                        applicationDTOMap.get(appId).get(0);
                    if (applicationDTO != null && applicationDTO.getAppType() == AppTypeEnum.ALL_APP) {
                        isAllApp = true;
                        break;
                    }
                }
                if (isAllApp) {
                    //封装全业务
                    List<WhiteIPIPDTO> whiteIPIPDTOList = whiteIPRecordDTO.getIpList();
                    whiteIPIPDTOList.forEach(whiteIPIPDTO -> {
                        ServiceWhiteIPInfo serviceWhiteIPInfo = new ServiceWhiteIPInfo();
                        serviceWhiteIPInfo.setForAllApp(true);
                        List<String> allAppActionScopeList = new ArrayList<>();
                        for (WhiteIPActionScopeDTO actionScope : whiteIPRecordDTO.getActionScopeList()) {
                            ActionScopeDTO actionScopeDTO =
                                actionScopeDTOMap.get(actionScope.getActionScopeId()) == null ? null :
                                    actionScopeDTOMap.get(actionScope.getActionScopeId()).get(0);
                            if (actionScopeDTO == null) {
                                log.error("Cannot find actionScopeDTO by id {}", actionScope.getActionScopeId());
                            } else {
                                allAppActionScopeList.add(actionScopeDTO.getCode());
                            }
                        }
                        serviceWhiteIPInfo.setAllAppActionScopeList(allAppActionScopeList);
                        serviceWhiteIPInfo.setAppIdActionScopeMap(new HashMap<>());
                        serviceWhiteIPInfo.setCloudId(whiteIPIPDTO.getCloudAreaId());
                        serviceWhiteIPInfo.setIp(whiteIPIPDTO.getIp());
                        resultList.add(serviceWhiteIPInfo);
                    });
                } else {
                    genNormalAppWhiteIPInfo(whiteIPRecordDTO, actionScopeDTOMap, resultList);
                }
            }
            log.debug(String.format("WhiteIPInfos before merge:%s", resultList));
            // 合并IP相同的多条记录
            Map<String, ServiceWhiteIPInfo> resultMap = new HashMap<>();
            for (ServiceWhiteIPInfo whiteIPInfo : resultList) {
                String key = whiteIPInfo.getCloudId().toString() + ":" + whiteIPInfo.getIp();
                if (resultMap.containsKey(key)) {
                    resultMap.put(key, mergeServiceWhiteIPInfo(resultMap.get(key), whiteIPInfo));
                } else {
                    resultMap.put(key, whiteIPInfo);
                }
            }
            resultList.clear();
            resultList.addAll(resultMap.values());
            log.debug(String.format("WhiteIPInfos after merge:%s", resultList));
        }
        return resultList;
    }

    private ServiceWhiteIPInfo mergeServiceWhiteIPInfo(ServiceWhiteIPInfo whiteIPInfo1,
                                                       ServiceWhiteIPInfo whiteIPInfo2) {
        log.debug(String.format("merge ServiceWhiteIPInfo:whiteIPInfo1=%s,whiteIPInfo2=%s", whiteIPInfo1,
            whiteIPInfo2));
        if (whiteIPInfo1 == null) {
            return whiteIPInfo2;
        } else if (whiteIPInfo2 == null) {
            return whiteIPInfo1;
        }
        if (!(whiteIPInfo1.getCloudId().equals(whiteIPInfo2.getCloudId())
            && whiteIPInfo1.getIp().equals(whiteIPInfo2.getIp()))) {
            throw new RuntimeException("Cannot merge ServiceWhiteIPInfo with different cloudId and Ip");
        }
        ServiceWhiteIPInfo finalServiceWhiteIPInfo = new ServiceWhiteIPInfo();
        finalServiceWhiteIPInfo.setCloudId(whiteIPInfo1.getCloudId());
        finalServiceWhiteIPInfo.setIp(whiteIPInfo1.getIp());
        finalServiceWhiteIPInfo.setAllAppActionScopeList(new ArrayList<>());
        finalServiceWhiteIPInfo.setForAllApp(false);
        if (whiteIPInfo1.isForAllApp()) {
            finalServiceWhiteIPInfo.setForAllApp(true);
            finalServiceWhiteIPInfo.setAllAppActionScopeList(
                mergeList(
                    finalServiceWhiteIPInfo.getAllAppActionScopeList(),
                    whiteIPInfo1.getAllAppActionScopeList()
                )
            );
        }
        if (whiteIPInfo2.isForAllApp()) {
            finalServiceWhiteIPInfo.setForAllApp(true);
            finalServiceWhiteIPInfo.setAllAppActionScopeList(
                mergeList(
                    finalServiceWhiteIPInfo.getAllAppActionScopeList(),
                    whiteIPInfo2.getAllAppActionScopeList()
                )
            );
        }
        finalServiceWhiteIPInfo.setAppIdActionScopeMap(mergeMap(finalServiceWhiteIPInfo.getAppIdActionScopeMap(),
            whiteIPInfo1.getAppIdActionScopeMap()));
        finalServiceWhiteIPInfo.setAppIdActionScopeMap(mergeMap(finalServiceWhiteIPInfo.getAppIdActionScopeMap(),
            whiteIPInfo2.getAppIdActionScopeMap()));
        log.debug(String.format("merge ServiceWhiteIPInfo:finalServiceWhiteIPInfo=%s", finalServiceWhiteIPInfo));
        return finalServiceWhiteIPInfo;
    }

    private <T, R> Map<T, List<R>> mergeMap(Map<T, List<R>> map1, Map<T, List<R>> map2) {
        if (map1 == null) {
            return map2;
        } else if (map2 == null) {
            return map1;
        }
        Map<T, List<R>> finalMap = new HashMap<>(map1);
        map2.keySet().forEach(key -> {
            if (finalMap.containsKey(key)) {
                finalMap.put(key, mergeList(finalMap.get(key), map2.get(key)));
            } else {
                finalMap.put(key, map2.get(key));
            }
        });
        return finalMap;
    }

    private <T> List<T> mergeList(List<T> list1, List<T> list2) {
        List<T> finalList = new ArrayList<>();
        if (list1 != null) {
            finalList.addAll(list1);
        }
        if (list2 != null) {
            finalList.addAll(list2);
        }
        HashSet<T> set = new HashSet<>(finalList);
        finalList.clear();
        finalList.addAll(set);
        return finalList;
    }

    private void genNormalAppWhiteIPInfo(WhiteIPRecordDTO whiteIPRecordDTO,
                                         Map<Long, List<ActionScopeDTO>> actionScopeDTOMap,
                                         List<ServiceWhiteIPInfo> resultList) {
        List<Long> appIdList = whiteIPRecordDTO.getAppIdList();
        List<WhiteIPIPDTO> whiteIPIPDTOList = whiteIPRecordDTO.getIpList();

        for (WhiteIPIPDTO whiteIPIPDTO : whiteIPIPDTOList) {
            ServiceWhiteIPInfo serviceWhiteIPInfo = new ServiceWhiteIPInfo();
            serviceWhiteIPInfo.setForAllApp(false);
            serviceWhiteIPInfo.setAllAppActionScopeList(new ArrayList<>());
            serviceWhiteIPInfo.setCloudId(whiteIPIPDTO.getCloudAreaId());
            serviceWhiteIPInfo.setIp(whiteIPIPDTO.getIp());
            HashMap<Long, List<String>> map = new HashMap<>();
            List<String> actionScopeList = new ArrayList<>();
            whiteIPRecordDTO.getActionScopeList().forEach(actionScope -> {
                ActionScopeDTO actionScopeDTO = actionScopeDTOMap.get(actionScope.getActionScopeId()) == null ? null :
                    actionScopeDTOMap.get(actionScope.getActionScopeId()).get(0);
                if (actionScopeDTO == null) {
                    log.warn("Cannot find actionScope by id {}", actionScope.getActionScopeId());
                    actionScopeList.add("");
                } else {
                    actionScopeList.add(actionScopeDTO.getCode());
                }
            });
            for (Long appId : appIdList) {
                map.put(appId, actionScopeList);
            }
            serviceWhiteIPInfo.setAppIdActionScopeMap(map);
            resultList.add(serviceWhiteIPInfo);
        }
    }
}
