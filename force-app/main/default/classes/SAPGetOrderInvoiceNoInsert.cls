/*
 * @Author: WFC
 * @Date: 2025-08-20 16:19:12
 * @LastEditors: WFC
 * @LastEditTime: 2025-11-18 10:58:08
 * @Description: 只调用接口，不插入数据，触发sap给信数系统生成数据
 * @FilePath: \testuat\force-app\main\default\classes\SAPGetOrderInvoiceNoInsert.cls
 */
public without sharing class SAPGetOrderInvoiceNoInsert{
    private static String basicUrl = Interface_Url__c.getValues('SAP').Basic_Url__c;
    private static List<String> urlList = new List<String>{ basicUrl + 'CC_REST_SALESORDER_SEND', basicUrl + 'CC_REST_DELIVERYORDER_SEND', basicUrl + 'CC_REST_INVOICE_SEND' };
    private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    private static String password = Interface_Url__c.getValues('SAP').Password__c;
    public class Output{
        List<String> CompanyCodeList;
        String SyncStartDate;
        String SyncEndDate;
        List<String> OrderTypeCodeList;
    }

    @Future(callout = true)
    public static void executionInterface(List<String> companyCodeList, String syncStartDate, String syncEndDate, List<String> orderTypeCodeList, Integer urlIndex){
        System.debug('wwww----Start');
        Datetime startTime = System.now();
        Output out = new Output();
        out.CompanyCodeList = companyCodeList;
        if (String.isBlank(syncStartDate)){
            syncStartDate = String.valueOf(Date.today().addDays(-1));
        }
        if (String.isBlank(syncEndDate)){
            syncEndDate = String.valueOf(Date.today().addDays(-1));
        }
        out.SyncStartDate = syncStartDate;
        out.SyncEndDate = syncEndDate;
        out.OrderTypeCodeList = orderTypeCodeList;
        String body = JSON.serialize(out);
        String url = urlList[urlIndex];
        try{
            Blob headerValue = Blob.valueOf(user + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            req.setEndpoint(url);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', authorizationHeader);
            req.setBody(body);
            req.setTimeout(120000); // timeout in milliseconds
            res = http.send(req);
            // for (String url : urlList){
            //     HttpRequest req = new HttpRequest();
            //     HttpResponse res = new HttpResponse();
            //     Http http = new Http();
            //     req.setEndpoint(url);
            //     req.setMethod('POST');
            //     req.setHeader('Content-Type', 'application/json');
            //     req.setHeader('Authorization', authorizationHeader);
            //     req.setBody(body);
            //     req.setTimeout(120000); // timeout in milliseconds
            //     res = http.send(req);
            // }
            Utility.insertLog('SAPGetOrderInvoiceNoInsert', '1', body, url);
        } catch (Exception e){
            String errorMsg = 'sfdc调用接口失败' + e.getMessage() + ' 报错行:' + e.getLineNumber() + ' 开始时间：' + startTime + ' 结束时间：' + System.now() + '--' + url;
            //日志内容
            Utility.insertLog('SAPGetOrderInvoiceNoInsert', '0', body, errorMsg + '--' + url);
            return;
        }
    }

}