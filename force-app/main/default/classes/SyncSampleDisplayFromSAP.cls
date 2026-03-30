/******************************************************************************
 ************************
 * Name: SyncSampleDisplayFromSAP
 * Description: 从SAP获取 Sample_Display_Customer_Confirm__c、SAP_Customer_Detail__c信息更新到SF
 * TestClassName:  SyncSampleDisplayFromSAPTest
 * Version History: 0.01
 * Date: 2024-10-28
 * Author: lizunxing
 * Comments:
 *******************************************************************************
 **************************/
public with sharing class SyncSampleDisplayFromSAP{
    private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_GET_SO_YANGJI_SENDER';
    private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    private static String password = Interface_Url__c.getValues('SAP').Password__c;
    public class ReqInfo{
        String ZDATE; //2024-10-29
    }

    public class ResInfo{
        String ZMSG;
        String ZTYPE;
        List<ITAB> ITAB;
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
     * @Param: ZDATE: 20241030
     * @Return:
     * @throws:
     * @Author: lizunxing
     * @Date: 2024-10-28
     * @Description: 调用SAP接口
     */
    @future(callout = true)
    public static void syncSampleDisplayFromSAP(String ZDATE){
        System.debug('url... ' + url);
        System.debug('user... ' + user);
        System.debug('password... ' + password);

        //暂时把SAP测试地址发布到正式
        // url = 'https://crmxip.hisense.com:8443/RESTAdapter/CC_REST_GET_SO_YANGJI_SENDER';
        // user = 'qinyanhao';
        // password = 'PassHi123';

        ReqInfo reqInfo = new ReqInfo();
        reqInfo.ZDATE = ZDATE;

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
            System.debug('bodyRes:' + bodyRes);

            // bodyRes = '{"Success": "1", "ErrorMessage": "", "Data": [{"ApprovalStage": "限额申请", "ApprovalStatus": "已审批", "Approver": "雷慧敏", "ApprovalTime": "2023-02-03 17:48:02", "ApprovalResult": "同意", "ApprovedLimit": "", "ApprovedTerm": ""}, {"ApprovalStage": "信保申请", "ApprovalStatus": "已提交已批复", "Approver": "", "ApprovalTime": "2023-02-06 15:10:15", "ApprovalResult": "", "ApprovedLimit": "3000000.00", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "雷慧敏", "ApprovalTime": "2023-02-15 14:08:30", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "李伟", "ApprovalTime": "2023-02-15 14:13:29", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "易小兵", "ApprovalTime": "2023-02-16 06:09:58", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "王云利", "ApprovalTime": "2023-02-16 07:55:22", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "胡剑涌", "ApprovalTime": "2023-02-16 08:52:38", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "常惠甜", "ApprovalTime": "2023-02-16 09:41:14", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "李强", "ApprovalTime": "2023-02-17 13:45:51", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}, {"ApprovalStage": "限额复评", "ApprovalStatus": "已审批", "Approver": "王艳凤", "ApprovalTime": "2023-02-21 00:00:35", "ApprovalResult": "同意", "ApprovedLimit": "1800000", "ApprovedTerm": "60"}]}';
            resInfo = (ResInfo)JSON.deserialize(bodyRes, ResInfo.class);
            if ('S'.equals(resInfo.ZTYPE) && resInfo.ITAB != null && resInfo.ITAB.size() > 0){

                List<String> VBELNList = new List<String>();
                for (ITAB itab : resInfo.ITAB){
                    VBELNList.add(itab.VBELN);
                }

                List<SAP__c> sdccList = [SELECT id, SO__c, Sample_Display__c
                                         FROM SAP__c
                                         WHERE SO__c in:VBELNList];
                LisqContainer lcSL = new LisqContainer(sdccList);
                Map<String, SObject> sdccMap = lcSL.ToMapS('SO__c');

                List<SAP__c> sdccUpdateList = new List<SAP__c>();
                List<POD__c> scdUpdateList = new List<POD__c>();

                Set<String> keySet = new Set<String>();
                for (ITAB itab : resInfo.ITAB){
                    if (!sdccMap.containsKey(itab.VBELN)){
                        continue;
                    }
                    SAP__c sdcc = (SAP__c) sdccMap.get(itab.VBELN);
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

                    if (keySet.add(itab.VBELN)){
                        sdccUpdateList.add(sdcc);
                    }

                    POD__c scd = new POD__c();
                    scd.Sample_Display__c = sdcc.Sample_Display__c;
                    scd.VBELN_POSNR__c = itab.VBELN + '_' + itab.POSNR;
                    scd.Net_Value__c = itab.NETWR;
                    scd.TAX__c = itab.MWSBP;
                    scd.Status__c = itab.PDSTK;
                    if(String.isNotBlank(itab.PODMG)){
                        scd.Number__c = Decimal.valueOf(itab.PODMG);
                    }
                    if (keySet.add(scd.VBELN_POSNR__c)){
                        scdUpdateList.add(scd);
                    }

                }

                if (sdccUpdateList.size() > 0){
                    Database.update (sdccUpdateList);
                }
                if (scdUpdateList.size() > 0){
                    Database.upsert (scdUpdateList, POD__c.Fields.VBELN_POSNR__c, false);
                }

            }
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SyncSampleDisplayFromSAP';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = body;
            ic.Res_Json__c = bodyRes;
            ic.ErrorMsg__c = '';
            insert ic;
        } catch (Exception e){
            //Integration Log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SyncSampleDisplayFromSAP';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = body;
            ic.Res_Json__c = '';
            ic.ErrorMsg__c = 'failure: SF SyncSampleDisplayFromSAP Failed! ' + e.getMessage();
            insert ic;
        }
    }

}