/*
 * @Author: WFC
 * @Date: 2024-10-10 16:45:01
 * @LastEditors: WFC
 * @LastEditTime: 2025-01-08 14:19:54
 * @Description:
 * @FilePath: \hisense005\force-app\main\default\classes\SampleDisplayDetailsController.cls
 */
public without sharing class SampleDisplayDetailsController{
    /**
     * @Param: SampleDisplay Id
     * @Return:
     * @Author: WFC
     * @Date: 2024-10-25 09:34:28
     * @Description: 查询sample display相关信息
     */
    @AuraEnabled
    public static Map<String, Object> searchSampleDisplay(String recordId){
        Map<String, Object> result = new Map<String, Object>();
        // 父级Sample_Display__c信息
        Sample_Display__c sampleDisplay = getSampleDisplayById(recordId);
        // 是否展示store details标签里面的submit按钮
        result.put('showSubmit', submitButtonShow(recordId));
        result.put('sampleDisplay', sampleDisplay);
        result.put('productModel', sampleDisplay.Product_Model__r.Name);
        result.put('customerName', sampleDisplay.Customer__r.Name);
        result.put('customerId', sampleDisplay.Customer__c);
        return result;
    }

    /**
     * @Param: base64Data：上传的图片
     * @Return:
     * @Author: WFC
     * @Date: 2024-10-25 09:35:50
     * @Description: 保存PO任务
     */
    @AuraEnabled
    public static Map<String, Object> saveCustomerDetail(String recordId, String productModel, String customerId, String numberData, String addressData, String fileName, String base64Data){
        Map<String, Object> result = new Map<String, Object>();
        try{
            // 创建 ContentVersion 实例
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = fileName;
            contentVersion.PathOnClient = fileName;
            contentVersion.VersionData = EncodingUtil.base64Decode(base64Data); // 解码 Base64 数据
            // 插入 ContentVersion
            insert contentVersion;

            ContentVersion cv = [SELECT Id, ContentBodyId, FileType, ContentDocumentId
                                 FROM ContentVersion
                                 WHERE Id = :contentVersion.Id
                                 LIMIT 1];

            PO__c sdcc = new PO__c();
            sdcc.Sample_Display__c = recordId;
            sdcc.Customer__c = customerId;
            sdcc.Product_Model__c = productModel;
            sdcc.Number__c = Decimal.valueOf(numberData);
            sdcc.Category_of_Delivery_Address__c = addressData;
            sdcc.CoverImgContentBodyId__c = cv.ContentBodyId;
            sdcc.CoverImgFileType__c = cv.FileType;
            sdcc.CoverImgVersionId__c = cv.Id;
            insert sdcc;

            //关联文件
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = sdcc.Id;
            cdl.ShareType = 'V';
            insert cdl;
            result.put('isSuccess', true);
        } catch (Exception e){
            String errorMsg = e.getMessage().substring(e.getMessage().indexOf(',', e.getMessage().indexOf('first error:') + 12) + 1, e.getMessage().lastIndexOf(': ['));
            result.put('isSuccess', false);
            result.put('errorMsg', errorMsg);
        }
        return result;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2024-10-25 09:38:24
     * @Description: 保存store details
     */
    @AuraEnabled
    public static Map<String, Object> saveStoreDetail(String recordId, String productModel, String storeId, String numberData, Boolean priorityData){
        Map<String, Object> result = new Map<String, Object>();
        try{
            Store_Detail__c sdc = new Store_Detail__c();
            sdc.Sample_Display__c = recordId;
            sdc.Product_Model__c = productModel;
            sdc.Number__c = Decimal.valueOf(numberData);
            sdc.Store__c = storeId;
            sdc.Priority__c = priorityData;
            insert sdc;
            result.put('isSuccess', true);
        } catch (Exception e){
            String errorMsg = e.getMessage().substring(e.getMessage().indexOf(',', e.getMessage().indexOf('first error:') + 12) + 1, e.getMessage().lastIndexOf(': ['));
            result.put('isSuccess', false);
            result.put('errorMsg', errorMsg);
        }
        return result;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2024-12-16 13:43:49
     * @Description: 验证store details拆分是否与任务数量相等
     */
    @AuraEnabled
    public static Map<String, Object> verifyStoreDetailsNumber(String recordId){
        Map<String, Object> result = new Map<String, Object>();
        // 查询拆分的store details
        Sample_Display__c sampleDisplay = getSampleDisplayById(recordId);

        if (submitButtonShow(recordId)){
            result.put('showSubmit', true);
            if (sampleDisplay.Number__c != sampleDisplay.Sum_Store_Details_Number__c){
                result.put('isSuccess', false);
                result.put('msg', System.label.Store_Details_Number_Verify);
            } else{
                result.put('isSuccess', true);
            }
        } else{
            result.put('isSuccess', false);
            result.put('showSubmit', false);
            result.put('msg', 'Button is invalid.');
        }
        return result;
    }

    /**
     * @Param: SampleDisplay Id
     * @Return:
     * @Author: WFC
     * @Date: 2024-12-16 17:07:10
     * @Description: 查询sample display下SAP相关信息
     */
    @AuraEnabled
    public static Map<String, Object> searchSampleDisplaySAP(String recordId){
        Map<String, Object> result = new Map<String, Object>();
        // 父级Sample_Display__c信息
        List<SAP__c> sapList = [SELECT Id, SO__c, SAP_Number__c, City__c, Postal_Code__c, Region__c, Sales_Group__c, Sales_Office__c, Storage_Location__c, Storage_Location_Description__c, Street__c, ZD_Customer__c, ZD_Name__c
                                FROM SAP__c
                                WHERE Sample_Display__c = :recordId];
        if (sapList != null && sapList.size() > 0){
            result.put('sapData', sapList[0]);
            result.put('isHaveData', true);
        } else{
            result.put('sapData', null);
            result.put('isHaveData', false);
        }

        return result;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2024-12-18 14:55:11
     * @Description: store details 提交按钮
     */
    @AuraEnabled
    public static Map<String, Object> storeDetailsSubmit(String recordId){
        Map<String, Object> result = new Map<String, Object>();
        // 查询现在的流程信息
        List<ProcessInstanceWorkitem> piwList = [SELECT Id, CreatedDate, ActorId, ProcessInstanceId, ProcessInstance.TargetObject.name, ProcessInstance.TargetObjectId
                                                 FROM ProcessInstanceWorkitem
                                                 WHERE ProcessInstance.TargetObjectId = :recordId
                                                 ORDER BY CreatedDate DESC];
        if (piwList != null && piwList.size() > 0){
            ProcessInstanceWorkitem piw = piwList[0];
            // 启动流程
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            pwr.setAction('Approve');
            pwr.setWorkitemId(piw.id);
            pwr.setComments('Approving request.');
            Approval.ProcessResult processResult = Approval.process(pwr);
            if (processResult.isSuccess()){
                result.put('isSuccess', true);
            } else{
                result.put('isSuccess', false);
            }
        } else{
            result.put('isSuccess', false);
        }

        // 是否展示store details标签里面的submit按钮
        result.put('showSubmit', submitButtonShow(recordId));

        return result;
    }

    /**
     * @Param:
     * @Return:
     * @Author: WFC
     * @Date: 2024-12-18 16:40:23
     * @Description: 是否显示store details模块里面的submit
     */
    public static Boolean submitButtonShow(String recordId){
        // 查询流程表信息
        List<ProcessInstanceWorkitem> piwList = [SELECT Id, ActorId
                                                 FROM ProcessInstanceWorkitem
                                                 WHERE ProcessInstance.TargetObjectId = :recordId
                                                 ORDER BY CreatedDate DESC];
        if (piwList != null && piwList.size() > 0){
            ProcessInstanceWorkitem piw = piwList[0];
            if (piw.ActorId == UserInfo.getUserId()){
                return true;
            }
        }
        return false;
    }

    /**
     * @Param: recordId
     * @Return: Sample_Display__c
     * @Author: WFC
     * @Date: 2025-01-08 14:16:16
     * @Description: 获取Sample_Display__c信息
     */
    public static Sample_Display__c getSampleDisplayById(String recordId){
        return [SELECT Id, Product_Model__c, Product_Model__r.Name, Task_Level__c, Customer__c, Customer__r.Name, Approval_Status__c, Path__c, Number__c, Sum_Store_Details_Number__c 
                FROM Sample_Display__c
                WHERE Id = :recordId
                LIMIT 1];
    }

}