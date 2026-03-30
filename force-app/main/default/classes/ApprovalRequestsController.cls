/*
 * @Author: WFC
 * @Date: 2024-02-20 14:11:32
 * @LastEditors: WFC
 * @LastEditTime: 2025-01-06 09:37:36
 * @Description: 批量审批页面controller
 * @FilePath: \hisense005\force-app\main\default\classes\ApprovalRequestsController.cls
 */
public without sharing class ApprovalRequestsController {

    // 初始化审批信息
    @AuraEnabled
    public static ConResponse getApprovalData(List<String> typeFilter) {
        System.debug('wwww--typeFilter-' + typeFilter);
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        
        // 流程id集合
        Set<Id> piIdSet = new Set<Id>();
        // 每一步审批记录信息
        Map<String, Map<String, String>> pisMap = new Map<String, Map<String, String>>();
        // 查询当前用户审批信息
        List<ProcessInstanceWorkitem> piwList = [SELECT Id, 
                                                        CreatedDate, 
                                                        ActorId, 
                                                        ProcessInstanceId, 
                                                        ProcessInstance.TargetObject.name, 
                                                        ProcessInstance.TargetObjectId 
                                                    FROM ProcessInstanceWorkitem 
                                                    WHERE ActorId = :UserInfo.getUserId() 
                                                    ORDER BY CreatedDate DESC, ProcessInstance.TargetObject.name DESC
                                                ];
        for(ProcessInstanceWorkitem piw : piwList){
            piIdSet.add(piw.ProcessInstanceId);
        }
        // 查询上一个审批信息
        List<ProcessInstanceStep> pisList = [SELECT ActorId, Actor.name, ProcessInstanceId, Comments 
                                                                FROM ProcessInstanceStep 
                                                                WHERE ProcessInstanceId IN :piIdSet 
                                                                ORDER BY CreatedDate ];
        
        for(ProcessInstanceStep pis : pisList){
            Map<String, String> mapTemp = new Map<String, String>();
            mapTemp.put('ActorId', pis.ActorId);
            mapTemp.put('Actor', pis.Actor.name);
            mapTemp.put('Comments', pis.Comments);
            if(String.isBlank(pis.Comments) && pisMap.get(pis.ProcessInstanceId) != null){
                mapTemp.put('Comments', pisMap.get(pis.ProcessInstanceId).get('Comments'));
            }
            pisMap.put(pis.ProcessInstanceId, mapTemp);
        }
        List<ApprovalData> approvalDataList = new List<ApprovalData>();
        // 审批type类型集合
        Set<String> typeSet = new Set<String>();
        for(ProcessInstanceWorkitem piw : piwList){
            // 过滤条件select选择框值
            typeSet.add(piw.ProcessInstance.TargetObjectId.getSObjectType().getDescribe().getLabel());
            // 过滤条件
            if(typeFilter.size() != 0 && !typeFilter.contains(piw.ProcessInstance.TargetObjectId.getSObjectType().getDescribe().getLabel())){
                continue;
            }
            ApprovalData approvalData = new ApprovalData();
            approvalData.id = piw.id;
            approvalData.relatedToUrl = '/lightning/r/' + piw.id + '/view';
            approvalData.relatedTo = piw.ProcessInstance.TargetObject.name;
            approvalData.objectId = piw.ProcessInstance.TargetObjectId;
            approvalData.type = piw.ProcessInstance.TargetObjectId.getSObjectType().getDescribe().getLabel();
            approvalData.mostRecentApproverUrl = '/lightning/r/' + pisMap.get(piw.ProcessInstanceId).get('ActorId') + '/view';
            approvalData.mostRecentApprover = pisMap.get(piw.ProcessInstanceId).get('Actor');
            approvalData.dateSubmitted = Datetime.valueOf(piw.CreatedDate);
            approvalData.comments = pisMap.get(piw.ProcessInstanceId).get('Comments');
            approvalDataList.add(approvalData);
            
        }
        List<String> typeList = new List<String>(typeSet);
        typeList.sort();
        mso.put('typeList', typeList);

        mso.put('ApprovalData', JSON.serialize(approvalDataList));
        System.debug('wwww---' + JSON.serialize(approvalDataList));
        return resp;
    }

    // 批量提交审批验证是否全部成功
    @AuraEnabled
    public static ConResponse submitVerifyApprovalRequests(String buttonLabel, String comments, String reassignUser, String selectRows) {
        ConResponse resp = new ConResponse();
        resp.code = 0;
        System.debug('wwwww---' + buttonLabel);
        System.debug('wwwww---' + comments);
        System.debug('wwwww---' + reassignUser);
        System.debug('wwwww---' + selectRows);
        // 流程提交报错信息
        List<ErrorData> errorList = new List<ErrorData>();
        Savepoint sp = Database.setSavepoint();
        List<ApprovalData> dataList = (List<ApprovalData>)JSON.deserialize(selectRows, List<ApprovalData>.class);
        for(ApprovalData approvalData: dataList){
            // approve or reject
            if(buttonLabel != 'Reassign'){
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                pwr.setAction(buttonLabel);
                pwr.setWorkitemId(approvalData.id);
                pwr.setComments(comments);
                try{
                    Approval.ProcessResult result =  Approval.process(pwr);
                    if(!result.isSuccess()){
                        resp.code = -1;                 
                    }
                }catch(Exception e){
                    System.debug('wwwww---' + e.getMessage().substring(e.getMessage().indexOf(',', e.getMessage().indexOf('first error:') + 12) + 1, e.getMessage().lastIndexOf(': [')));
                    resp.code = -1;
                    // 错误信息保存到前端显示
                    ErrorData rd = new ErrorData();
                    rd.id = approvalData.id;
                    rd.errorInfo = e.getMessage().substring(e.getMessage().indexOf(',', e.getMessage().indexOf('first error:') + 12) + 1, e.getMessage().lastIndexOf(': ['));
                    errorList.add(rd);
                    
                }
            }else { 
                // Reassign
                ProcessInstanceWorkItem pi = new ProcessInstanceWorkItem();
                pi.Id = approvalData.id;
                pi.ActorId = reassignUser;
                update pi; 
            }
        }
        
        Database.rollback(sp);

        resp.data = JSON.serialize(errorList);
        System.debug('wwwww--errorList--' + JSON.serialize(errorList));
        return resp;
    }
    
    // 批量提交审批
    @AuraEnabled
    public static ConResponse submitApprovalRequests(String buttonLabel, String comments, String reassignUser, String selectRows) {
        ConResponse resp = new ConResponse();
        System.debug('wwwww---' + buttonLabel);
        System.debug('wwwww---' + comments);
        System.debug('wwwww---' + reassignUser);
        System.debug('wwwww---' + selectRows);
        // 流程提交报错信息
        List<ErrorData> errorList = new List<ErrorData>();
        Savepoint sp = Database.setSavepoint();
        List<ApprovalData> dataList = (List<ApprovalData>)JSON.deserialize(selectRows, List<ApprovalData>.class);
        List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>();
        List<ProcessInstanceWorkItem> piwList = new List<ProcessInstanceWorkItem>();
        for(ApprovalData approvalData: dataList){
            // approve or reject
            if(buttonLabel != 'Reassign'){
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                pwr.setAction(buttonLabel);
                pwr.setWorkitemId(approvalData.id);
                pwr.setComments(comments);
                pwrList.add(pwr);
                
            }else { 
                // Reassign
                ProcessInstanceWorkItem pi = new ProcessInstanceWorkItem();
                pi.Id = approvalData.id;
                pi.ActorId = reassignUser;
                piwList.add(pi); 
            }
        }
        try{
            if(buttonLabel != 'Reassign'){
                List<Approval.ProcessResult> result =  Approval.process(pwrList);
            }else {
                update(piwList);
            }
            resp.code = 0;                
        }catch(Exception e){
            resp.code = -1;  
        }
        if(!resp.isSuccess){
            Database.rollback(sp);
        }
        resp.data = JSON.serialize(errorList);
        System.debug('wwwww--errorList--' + JSON.serialize(errorList));
        return resp;
    }

    public class ApprovalData{
        public String id;
        public String relatedTo;
        public String relatedToUrl;
        public String type;
        public String objectId;
        public String mostRecentApprover;
        public String mostRecentApproverUrl;
        public Datetime dateSubmitted;
        public String comments;
    }

     public class ErrorData{
        public String id;
        public String errorInfo;
    }

    // // 回溯法
    // @AuraEnabled
    // public static ConResponse handleTest() {
    //     ConResponse resp = new ConResponse();
    //     Rectangle largeRectangle = new Rectangle(5, 5);

    //     List<Rectangle> rectangles = new List<Rectangle>();
    //     rectangles.add(new Rectangle(1, 1));
    //     rectangles.add(new Rectangle(2, 2));
    //     rectangles.add(new Rectangle(3, 3));

    //     List<Rectangle> result = new List<Rectangle>();
    //     packRectangles(largeRectangle, rectangles, result);

    //     return resp;
    // }

    // public class Rectangle {
    //     public Integer width;
    //     public Integer height;

    //     public Rectangle(Integer height, Integer width) {
    //         this.width = width;
    //         this.height = height;
    //     }
    // }

    // public static Boolean packRectangles(Rectangle largeRectangle, List<Rectangle> remainingRectangles, List<Rectangle> result) {
    //     if (remainingRectangles.isEmpty()) {
    //         // 所有小长方形都已经放置完成
    //         return true;
    //     }

    //     for (Integer i = 0; i < remainingRectangles.size(); i++) {
    //         Rectangle currentRect = remainingRectangles.get(i);
    //         // 尝试将当前小长方形放置到大长方形中
    //         if (currentRect.width <= largeRectangle.width && currentRect.height <= largeRectangle.height) {
    //             result.add(currentRect);
    //             // 更新大长方形的剩余空间
    //             Rectangle remainingArea = new Rectangle(
    //                     largeRectangle.height - currentRect.height,
    //                     largeRectangle.width - currentRect.width
    //             );
    //             // 递归调用，尝试放置剩余的小长方形
    //             if (packRectangles(remainingArea, remainingRectangles, result)) {
    //                 return true;
    //             }

    //             // 如果递归失败，回溯，尝试其他可能性
    //             result.remove(result.size() - 1);
    //         }
    //     }

    //     // 无法将当前小长方形放置到大长方形中
    //     system.debug('wwww----' + result.size());
    //     for(Rectangle rect : result){
    //         system.debug('wwww----' + '------' +rect);
    //     }
    //     return false;
    // }
    
}