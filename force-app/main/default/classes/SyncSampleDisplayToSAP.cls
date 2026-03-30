/******************************************************************************
 ************************
 * Name: SyncSampleDisplayToSAP
 * Description:  创建 Sample_Display_Customer_Confirm__c 时同步到SAP，SAP返回信息更新到Sample_Display_Customer_Confirm__c
 * TestClassName:  SyncSampleDisplayToSAPTest
 * Version History: 0.01
 * Date: 2024-10-28
 * Author: lizunxing
 * Comments:
 *******************************************************************************
 **************************/
public with sharing class SyncSampleDisplayToSAP{
    private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_CREATE_SO_SENDER';
    private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    private static String password = Interface_Url__c.getValues('SAP').Password__c;
    // {
    //     "VKORG":"8430",
    //     "BNAME":"20241029-0001",
    //     "KUNNR":"5000454",
    //     "ITEM":{
    //         "ZCUSMODEL":"CUST04",
    //         "KWMENG":"2"
    //     }
    // }
    public class ReqInfo{
        String VKORG; //SalesOrg  CHAR(4)  销售组织
        String BNAME; //salesforce样机任务编号
        String KUNNR; //SP--SHIP-TO     CHAR(10)   售达方编码
        ITEM ITEM;
    }

    public class ITEM{
        String ZCUSMODEL; //SP--SHIP-TO     CHAR(10)   售达方编码
        String KWMENG; //Quantity   Num    物料数量
    }

    public class ResInfo{
        String MESSAGE; //消息文本
        String VBELN; //销售和分销凭证号
        String ZTYPE; //消息类型: S 成功,E 错误,W 警告,I 信息,A 中断
        List<ITAB> ITAB; //样机信息
    }

    public class ITAB{
        String VBELN;
        String POSNR;
        String BNAME;
        String VKBUR;
        String VKGRP;
        String KUNNR;
        String ZCUSMODEL;
        String KWMENG;
        String NETWR;
        String MWSBP;
        String WAERK;
        String LGORT;
        String LGOBE;
        String NAME1;
        String CITY1;
        String POST_CODE1;
        String STREET;
        String STR_SUPPL1;
        String STR_SUPPL2;
        String STR_SUPPL3;
        String LOCATION;
        String REGION;
        String PODAT;
        String PDSTK;
        String PODMG;
    }

    /**
     * @Param:
     * @Return:
     * @throws:
     * @Author: lizunxing
     * @Date: 2024-10-28
     * @Description: 调用SAP接口
     */
    @future(callout = true)
    public static void syncSampleDisplayToSAP(String sdccId){
        System.debug('url... ' + url);
        System.debug('user... ' + user);
        System.debug('password... ' + password);

        //暂时把SAP测试地址发布到正式
        // url = 'https://crmxip.hisense.com:8443/RESTAdapter/CC_REST_CREATE_SO_SENDER';
        // user = 'qinyanhao';
        // password = 'PassHi123';

        List<SAP__c> sdccList = [SELECT Id, Sample_Display__r.Customer__r.Hisense_Entity__c, Name, Sample_Display__r.Customer__r.SAP_Customer_Code__c, Sample_Display__r.Product_Model__r.Name, Number__c, Sample_Display__c
                                 FROM SAP__c
                                 WHERE Id = :sdccId];

        if (sdccList == null || sdccList.size() == 0){
            return;
        }

        SAP__c sdcc = sdccList.get(0);

        ITEM item = new ITEM();
        item.ZCUSMODEL = sdcc.Sample_Display__r.Product_Model__r.Name;
        // item.ZCUSMODEL = 'CUST04';
        item.KWMENG = String.valueOf(sdcc.Number__c);

        ReqInfo reqInfo = new ReqInfo();
        reqInfo.VKORG = sdcc.Sample_Display__r.Customer__r.Hisense_Entity__c;
        reqInfo.BNAME = sdcc.Name;
        reqInfo.KUNNR = remove0(sdcc.Sample_Display__r.Customer__r.SAP_Customer_Code__c);
        // reqInfo.VKORG = '8430';
        // reqInfo.BNAME = sdcc.Name;
        // reqInfo.KUNNR = '5000454';
        reqInfo.ITEM = item;

        String body = JSON.serialize(reqInfo);
        System.debug('body:: ' + body);

        ResInfo resInfo = new ResInfo();
        String bodyRes;
        try{
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
            System.debug('request::: ' + request);
            response = http_login.send(request);
            bodyRes = response.getBody();
            System.debug('bodyRes:' + JSON.serialize(bodyRes));

            // bodyRes = '{"Success": "1", "ErrorMessage": "", "Data": [{"ApprovalStage": "限额申请", "ApprovalStatus": "已审批", "Approver": "雷慧敏", "ApprovalTime": "2023-02-03 17:48:02", "ApprovalResult": "同意", "ApprovedLimit": "", "ApprovedTerm": ""}, {"ApprovalStage": "信保申请", "ApprovalStatus": "已提交已批复", "Approver": "", "ApprovalTime": "2023-02-06 15:10:15", "ApprovalResult": "", "ApprovedLimit": "3000000.00", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "雷慧敏", "ApprovalTime": "2023-02-15 14:08:30", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "李伟", "ApprovalTime": "2023-02-15 14:13:29", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "易小兵", "ApprovalTime": "2023-02-16 06:09:58", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "王云利", "ApprovalTime": "2023-02-16 07:55:22", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "胡剑涌", "ApprovalTime": "2023-02-16 08:52:38", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "常惠甜", "ApprovalTime": "2023-02-16 09:41:14", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "李强", "ApprovalTime": "2023-02-17 13:45:51", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "王艳凤", "ApprovalTime": "2023-02-21 00:00:35", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}]}';
            resInfo = (ResInfo)JSON.deserialize(bodyRes, ResInfo.class);
            if ('S'.equals(resInfo.ZTYPE) && resInfo.ITAB != null && resInfo.ITAB.size() > 0){
                //sdcc. = resInfo.ITAB.NETWR;
                //sdcc. = resInfo.ITAB.MWSBP;
                ITAB itab = resInfo.ITAB.get(0);
                sdcc.SO__c = itab.VBELN;
                sdcc.CurrencyIsoCode = itab.WAERK;
                sdcc.Storage_Location__c = itab.LGORT;
                sdcc.Storage_Location_Description__c = itab.LGOBE;
                sdcc.ZD_Customer__c = itab.KUNNR;
                sdcc.ZD_Name__c = itab.NAME1;
                sdcc.City__c = itab.CITY1;
                sdcc.Postal_Code__c = itab.POST_CODE1;
                sdcc.Street__c = itab.STREET;
                sdcc.Region__c = itab.REGION;
                sdcc.Sales_Office__c = itab.VKBUR;
                sdcc.Sales_Group__c = itab.VKGRP;
                sdcc.Edit_Flag__c = true;
                Database.update (sdcc);
            }

            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SyncSampleDisplayToSAP';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = body;
            ic.Res_Json__c = bodyRes;
            ic.ErrorMsg__c = '';
            insert ic;
        } catch (Exception e){
            //Integration Log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SyncSampleDisplayToSAP';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = body;
            ic.Res_Json__c = '';
            ic.ErrorMsg__c = 'failure: SF SyncSampleDisplayToSAP Failed! ' + e.getMessage();
            insert ic;
        }
    }

    public static String remove0(String input){
        if (String.isBlank(input)){
            return '';
        }

        Integer index = 0;
        while (index < input.length() && input.charAt(index) == 48){
            index++;
        }
        return input.substring(index);
    }

}