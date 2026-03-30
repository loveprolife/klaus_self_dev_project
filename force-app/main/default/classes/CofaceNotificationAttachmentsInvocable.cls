/*
 * @Author: WFC
 * @Date: 2026-03-27 16:21:42
 * @LastEditors: WFC
 * @LastEditTime: 2026-03-30 12:08:50
 * @Description: 获取coface监控报告的pdf和json
 * @FilePath: \testuat\force-app\main\default\classes\CofaceNotificationAttachmentsInvocable.cls
 */
public with sharing class CofaceNotificationAttachmentsInvocable{
    public class CofaceNotificationAttachmentsResponse{
        public String fileName;
        public String mimeType;
    }

    @InvocableMethod
    public static void CofaceNotificationAttachmentsInvocable(List<String> historyIdLsit){
        system.debug('wwwww-----' + JSON.serialize(historyIdLsit));
        Blob pdfBlob = null;
        Blob jsonBlob = null;
        // 获取 Coface Report History
        Coface_Report_History__c historyReport = [SELECT Id, Coface_Report__c, Notification_Id__c, Format__c, Delivery_Date__c
                                                  FROM Coface_Report_History__c
                                                  WHERE Id = :historyIdLsit[0]
                                                  LIMIT 1];
        // 调用token接口获取
        String tokenData = CofaceModuleController.getCofaceToken();
        String idToken = '';
        Map<String, Object> tokenMap = (Map<String, Object>)JSON.deserializeUntyped(tokenData);
        if (tokenMap.get('idToken') != null){
            idToken = String.valueOf(tokenMap.get('idToken'));

            CofaceModuleController.CofaceConfig cfg = new CofaceModuleController.CofaceConfig();
            // 查询Attachment接口
            String reqUrl = cfg.dataAPIBaseUrl + '/notifications/' + historyReport.Notification_Id__c + '/attachments';

            HttpRequest req = new HttpRequest();
            req.setEndpoint(reqUrl);
            req.setMethod('GET');
            req.setHeader('authorization', idToken);
            req.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
            req.setTimeout(120000);

            Http http = new Http();
            HttpResponse res = http.send(req);
            List<CofaceNotificationAttachmentsResponse> attachmentsList = null;
            String responseBody = '';
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300 && res.getBody() != null){
                responseBody = res.getBody();
                attachmentsList = (List<CofaceNotificationAttachmentsResponse>)JSON.deserialize(responseBody, List<CofaceNotificationAttachmentsResponse>.class);
            }
            if (attachmentsList != null && !attachmentsList.isEmpty()){
                for (CofaceNotificationAttachmentsResponse attachmentResponse : attachmentsList){
                    if ('application/pdf'.equals(attachmentResponse.mimeType)){
                        String reqUrlPdf = cfg.dataAPIBaseUrl + '/notifications/' + historyReport.Notification_Id__c + '/attachments/' + attachmentResponse.fileName;
                        HttpRequest reqPdf = new HttpRequest();
                        reqPdf.setEndpoint(reqUrlPdf);
                        reqPdf.setMethod('GET');
                        reqPdf.setHeader('authorization', idToken);
                        reqPdf.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
                        reqPdf.setTimeout(120000);

                        Http httpPdf = new Http();
                        HttpResponse resPdf = httpPdf.send(reqPdf);
                        if (resPdf.getStatusCode() >= 200 && resPdf.getStatusCode() < 300 && resPdf.getBody() != null){
                            pdfBlob = resPdf.getBodyAsBlob();
                        }
                    }
                    if ('application/json'.equals(attachmentResponse.mimeType)){
                        String reqUrlJson = cfg.dataAPIBaseUrl + '/notifications/' + historyReport.Notification_Id__c + '/attachments/' + attachmentResponse.fileName;
                        HttpRequest reqJson = new HttpRequest();
                        reqJson.setEndpoint(reqUrlJson);
                        reqJson.setMethod('GET');
                        reqJson.setHeader('authorization', idToken);
                        reqJson.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
                        reqJson.setTimeout(120000);

                        Http httpJson = new Http();
                        HttpResponse resJson = httpJson.send(reqJson);
                        if (resJson.getStatusCode() >= 200 && resJson.getStatusCode() < 300 && resJson.getBody() != null){
                            jsonBlob = Blob.valueOf(responseBody);
                        }
                    }
                }
            }
            // 获取pdf文件成功
            if (pdfBlob != null){
                // 现将文件保存到history中
                String titel = 'Coface_Report_' + historyReport.Delivery_Date__c;
                String pathOnClient = 'Coface_Report_'+ historyReport.Delivery_Date__c +'.pdf';
                CofaceModuleController.saveDocumentToRecord(pdfBlob, titel, pathOnClient, historyReport.Id);

                // 保存数据到主report上
                CofaceModuleController.delectDocumentByRecordId(historyReport.Coface_Report__c, new List<String>{ 'PDF' });
                CofaceModuleController.saveDocumentToRecord(jsonBlob, titel, pathOnClient, historyReport.Coface_Report__c);
            }
            if (jsonBlob != null){
                // 现将文件保存到history中
                String titel = 'Coface_Report_JSON_' + historyReport.Delivery_Date__c;
                String pathOnClient = 'Coface_Report_JSON' + historyReport.Delivery_Date__c + '.json';
                CofaceModuleController.saveDocumentToRecord(pdfBlob, titel, pathOnClient, historyReport.Id);

                // 保存数据到主report上
                CofaceModuleController.delectDocumentByRecordId(historyReport.Coface_Report__c, new List<String>{ 'JSON' });
                CofaceModuleController.saveDocumentToRecord(jsonBlob, titel, pathOnClient, historyReport.Coface_Report__c);
            }
        }
    }

}