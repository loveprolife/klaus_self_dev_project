/**************************************************************************************************
 * Name:CreditLimitApplicationRRInfoController
 * Purpose:信用申请RR审批信息展示
 * Author: lizunxing
 * Create Date: 2023-06-07
***************************************************************************************************/
global  without sharing class CreditLimitApplicationRRInfoController{

    private static String url = Interface_Url__c.getValues('RR').Basic_Url__c + 'CC_REST_GET_APPROVAL_SEND';
    private static String user = Interface_Url__c.getValues('RR').User_Name__c;
    private static String password = Interface_Url__c.getValues('RR').Password__c;

    public class ResultData {
        public  String  ErrorMessage;
        public  String  Success;
        public  List<CreditLimitApplicationRRInfo>  Data;
    }

    public class ResultDataObj {
        public  String  ErrorMessage;
        public  String  Success;
        public  CreditLimitApplicationRRInfo  Data;
    }

    public Class CreditLimitApplicationRRInfo{
        public  String  ApprovalStage;
        public  String  ApprovalResult;
        public  String  Approver;
        public  String  ApprovalStatus;
        public  String  ApprovalTime;
        public  String  ApprovedLimit;
        public  String  ApprovedTerm;
    }

    public Class InitData{
        public List<Credit_Limit_Application_RR_INFO__c> rrAuditList;
    }

    @future(callout=true)
    global static Void syncAuditInfoFromRR(String sfCode){
        System.debug('url... '+url);
        System.debug('user... '+user);
        System.debug('password... '+password);
        
        Map<String,String> bodyMap = new Map<String,String>();
        bodyMap.put('sfcode', sfCode);
        String body = JSON.serialize(bodyMap);
        System.debug('body:: '+body);

        CreditLimitApplicationRRInfoController.ResultData resData = new CreditLimitApplicationRRInfoController.ResultData();
        String bodyRes;
        try {
            Blob headerValue = Blob.valueOf(user + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            //登陆获取token
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();    
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', authorizationHeader);
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds
            System.debug('request::: '+request);
            response = http_login.send(request);
            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes);

            // bodyRes = '{"Success": "1", "ErrorMessage": "", "Data": [{"ApprovalStage": "限额申请", "ApprovalStatus": "已审批", "Approver": "雷慧敏", "ApprovalTime": "2023-02-03 17:48:02", "ApprovalResult": "同意", "ApprovedLimit": "", "ApprovedTerm": ""}, {"ApprovalStage": "信保申请", "ApprovalStatus": "已提交已批复", "Approver": "", "ApprovalTime": "2023-02-06 15:10:15", "ApprovalResult": "", "ApprovedLimit": "3000000.00", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "雷慧敏", "ApprovalTime": "2023-02-15 14:08:30", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "李伟", "ApprovalTime": "2023-02-15 14:13:29", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "易小兵", "ApprovalTime": "2023-02-16 06:09:58", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "王云利", "ApprovalTime": "2023-02-16 07:55:22", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "胡剑涌", "ApprovalTime": "2023-02-16 08:52:38", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "常惠甜", "ApprovalTime": "2023-02-16 09:41:14", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "李强", "ApprovalTime": "2023-02-17 13:45:51", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "王艳凤", "ApprovalTime": "2023-02-21 00:00:35", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}]}';
            try{
                resData = (CreditLimitApplicationRRInfoController.ResultData)JSON.deserialize(bodyRes,CreditLimitApplicationRRInfoController.ResultData.class);
            }catch(Exception e){
                CreditLimitApplicationRRInfoController.ResultDataObj resDataObj = (CreditLimitApplicationRRInfoController.ResultDataObj)JSON.deserialize(bodyRes,CreditLimitApplicationRRInfoController.ResultDataObj.class);
                resData.Success = resDataObj.Success;
                resData.ErrorMessage = resDataObj.ErrorMessage;

                List<CreditLimitApplicationRRInfo>  DataList = new List<CreditLimitApplicationRRInfo>();
                DataList.add(resDataObj.Data);

                resData.Data = DataList;

            }
            System.debug('resData... ' + resData);
 
            //handle log
            if('1' != resData.Success){

                //log
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'CreditLimitApplicationRRInfoController';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '0';
                ic.Req_Json__c = body;
                ic.Res_Json__c = bodyRes;
                ic.ErrorMsg__c = resData.ErrorMessage;
                insert ic;
                return;  

            } else {
                List<Credit_Limit_Application__c> creditList = [Select name,id from Credit_Limit_Application__c Where name =:sfCode];
                List<Credit_Limit_Application_RR_INFO__c> infoList = new List<Credit_Limit_Application_RR_INFO__c>();
                
                for(CreditLimitApplicationRRInfo c : resData.Data){
                    Credit_Limit_Application_RR_INFO__c info = new Credit_Limit_Application_RR_INFO__c();

                    info.Audit_Node__c = c.ApprovalStage;
                    info.Audit_Opinion__c = c.ApprovalResult;
                    info.Audit_Person__c = c.Approver;
                    info.Audit_Status__c = c.ApprovalStatus;
                    info.Audit_Time__c = c.ApprovalTime;
                    info.Audti_Limit__c = c.ApprovedLimit;
                    info.Audti_Term__c = c.ApprovedTerm;

                    info.Credit_Limit_Id__c = creditList.get(0).id;
                    info.Credit_limit_No__c = creditList.get(0).name;
                    infoList.add(info);
                }
                Database.delete(getRrInfo(creditList.get(0).id));
                Database.upsert(infoList);

                //log
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'CreditLimitApplicationRRInfoController';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                ic.Req_Json__c = body;
                ic.Res_Json__c = bodyRes;
                ic.ErrorMsg__c = '';
                insert ic;
                return; 
            }
        }catch (Exception e) {
            //Integration Log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'CreditLimitApplicationRRInfoController';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = body;
            ic.Res_Json__c = '';
            ic.ErrorMsg__c = 'failure: SF Sync Credit Information to RR Failed! '+e.getMessage();
            insert ic;
            return; 
        }
    }

    global static Void syncAuditInfoFromRRNoFuture(String sfCode){
        System.debug('url... '+url);
        System.debug('user... '+user);
        System.debug('password... '+password);
        
        Map<String,String> bodyMap = new Map<String,String>();
        bodyMap.put('sfcode', sfCode);
        String body = JSON.serialize(bodyMap);
        System.debug('body:: '+body);

        CreditLimitApplicationRRInfoController.ResultData resData = new CreditLimitApplicationRRInfoController.ResultData();
        String bodyRes;
        try {
            Blob headerValue = Blob.valueOf(user + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            //登陆获取token
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();    
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', authorizationHeader);
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds
            System.debug('request::: '+request);
            if(Test.isRunningTest()){
                resData.Success = '1';
                List<CreditLimitApplicationRRInfoController.CreditLimitApplicationRRInfo> rrList = new List<CreditLimitApplicationRRInfoController.CreditLimitApplicationRRInfo>();
                CreditLimitApplicationRRInfoController.CreditLimitApplicationRRInfo rr = new CreditLimitApplicationRRInfoController.CreditLimitApplicationRRInfo();
                rr.ApprovalStage = '限额申请';
                rr.ApprovalStatus = '已审批';
                rr.Approver = '雷慧敏';
                rr.ApprovalTime = '2023-02-03 17:48:02';
                rr.ApprovalResult = '同意';
                rr.ApprovedLimit = '';
                rr.ApprovedTerm = '';
                rrList.add(rr);
                resData.Data = rrList;
                bodyRes = JSON.serialize(resData);
            }else {
                response = http_login.send(request);
                bodyRes = response.getBody();
                System.debug('bodyRes:' + bodyRes);
    
                // bodyRes = '{"Success": "1", "ErrorMessage": "", "Data": [{"ApprovalStage": "限额申请", "ApprovalStatus": "已审批", "Approver": "雷慧敏", "ApprovalTime": "2023-02-03 17:48:02", "ApprovalResult": "同意", "ApprovedLimit": "", "ApprovedTerm": ""}, {"ApprovalStage": "信保申请", "ApprovalStatus": "已提交已批复", "Approver": "", "ApprovalTime": "2023-02-06 15:10:15", "ApprovalResult": "", "ApprovedLimit": "3000000.00", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "雷慧敏", "ApprovalTime": "2023-02-15 14:08:30", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "李伟", "ApprovalTime": "2023-02-15 14:13:29", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "易小兵", "ApprovalTime": "2023-02-16 06:09:58", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "王云利", "ApprovalTime": "2023-02-16 07:55:22", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "胡剑涌", "ApprovalTime": "2023-02-16 08:52:38", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "常惠甜", "ApprovalTime": "2023-02-16 09:41:14", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "李强", "ApprovalTime": "2023-02-17 13:45:51", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "王艳凤", "ApprovalTime": "2023-02-21 00:00:35", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}]}';
                try{
                    resData = (CreditLimitApplicationRRInfoController.ResultData)JSON.deserialize(bodyRes,CreditLimitApplicationRRInfoController.ResultData.class);
                }catch(Exception e){
                    CreditLimitApplicationRRInfoController.ResultDataObj resDataObj = (CreditLimitApplicationRRInfoController.ResultDataObj)JSON.deserialize(bodyRes,CreditLimitApplicationRRInfoController.ResultDataObj.class);
                    resData.Success = resDataObj.Success;
                    resData.ErrorMessage = resDataObj.ErrorMessage;
    
                    List<CreditLimitApplicationRRInfo>  DataList = new List<CreditLimitApplicationRRInfo>();
                    DataList.add(resDataObj.Data);
    
                    resData.Data = DataList;
    
                }
                System.debug('resData... ' + resData);
            }

            //handle log
            if('1' != resData.Success){

                //log
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'CreditLimitApplicationRRInfoController';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '0';
                ic.Req_Json__c = body;
                ic.Res_Json__c = bodyRes;
                ic.ErrorMsg__c = resData.ErrorMessage;
                insert ic;
                return;  

            } else {
                List<Credit_Limit_Application__c> creditList = [Select name,id from Credit_Limit_Application__c Where name =:sfCode];
                List<Credit_Limit_Application_RR_INFO__c> infoList = new List<Credit_Limit_Application_RR_INFO__c>();
                
                for(CreditLimitApplicationRRInfo c : resData.Data){
                    Credit_Limit_Application_RR_INFO__c info = new Credit_Limit_Application_RR_INFO__c();

                    info.Audit_Node__c = c.ApprovalStage;
                    info.Audit_Opinion__c = c.ApprovalResult;
                    info.Audit_Person__c = c.Approver;
                    info.Audit_Status__c = c.ApprovalStatus;
                    info.Audit_Time__c = c.ApprovalTime;
                    info.Audti_Limit__c = c.ApprovedLimit;
                    info.Audti_Term__c = c.ApprovedTerm;

                    info.Credit_Limit_Id__c = creditList.get(0).id;
                    info.Credit_limit_No__c = creditList.get(0).name;
                    infoList.add(info);
                }
                Database.delete(getRrInfo(creditList.get(0).id));
                Database.upsert(infoList);

                //log
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'CreditLimitApplicationRRInfoController';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                ic.Req_Json__c = body;
                ic.Res_Json__c = bodyRes;
                ic.ErrorMsg__c = '';
                insert ic;
                return; 
            }
        }catch (Exception e) {
            //Integration Log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'CreditLimitApplicationRRInfoController';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = body;
            ic.Res_Json__c = '';
            ic.ErrorMsg__c = 'failure: SF Sync Credit Information to RR Failed! '+e.getMessage();
            insert ic;
            return; 
        }
    }

    @AuraEnabled 
    public static String initData(String recordId){

        Credit_Limit_Application__c credit = [SELECT name,id FROM Credit_Limit_Application__c WHERE id =:recordId LIMIT 1];
        CreditLimitApplicationRRInfoController.syncAuditInfoFromRRNoFuture(credit.name);
        
        InitData initData = new InitData();        
        initData.rrAuditList = new List<Credit_Limit_Application_RR_INFO__c>(); 
        initData.rrAuditList = getRrInfo(recordId);
       
        System.debug('initData==>>>' +initData);

        //getRRInfoIF('LA-00008256');
        return JSON.serialize(initData);
    }

    @AuraEnabled 
    public static String syncData(String recordId){
        
        Credit_Limit_Application__c credit = [SELECT name,id FROM Credit_Limit_Application__c WHERE id =:recordId LIMIT 1];
        CreditLimitApplicationRRInfoController.syncAuditInfoFromRRNoFuture(credit.name);

        InitData initData = new InitData();        
        initData.rrAuditList = new List<Credit_Limit_Application_RR_INFO__c>(); 
        initData.rrAuditList = getRrInfo(recordId);
       
        System.debug('syncData==>>>' +initData);

        return JSON.serialize(initData);
    }

    public static List<Credit_Limit_Application_RR_INFO__c> getRrInfo(String recordId){
        List<Credit_Limit_Application_RR_INFO__c> thisRrInfo = [select id, Audit_Node__c, Credit_Limit_Id__c, Audit_Opinion__c, Audit_Person__c, Audit_Status__c, 
        Audit_Time__c,Audti_Limit__c,Audti_Term__c from Credit_Limit_Application_RR_INFO__c 
        WHERE Credit_Limit_Id__c =:recordId];
        return thisRrInfo;
    }

}