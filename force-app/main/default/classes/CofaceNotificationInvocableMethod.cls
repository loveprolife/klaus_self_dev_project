/*
 * @Author: WFC
 * @Date: 2026-03-27 15:23:57
 * @LastEditors: WFC
 * @LastEditTime: 2026-03-30 12:43:14
 * @Description: coface定时执行，查询监控订单
 * @FilePath: \testuat\force-app\main\default\classes\CofaceNotificationInvocableMethod.cls
 */
public without sharing class CofaceNotificationInvocableMethod{
    public class CofaceNotificationResponse{
        public String id;
        public String monitoringId;
        public String deliveryDate;
        public String format;
        public String externalId;
        public String slug;
        public String language;
        public String countryCode;
        public String channelDelivery;
    }

    @InvocableMethod
    public static void CofaceNotificationInvocableMethod(){
        // 获取昨天日期
        Date yesterday = Date.today().addDays(-1);
        // 调用token接口获取
        String tokenData = CofaceModuleController.getCofaceToken();
        String idToken = '';
        Map<String, Object> tokenMap = (Map<String, Object>)JSON.deserializeUntyped(tokenData);
        if (tokenMap.get('idToken') != null){
            idToken = String.valueOf(tokenMap.get('idToken'));

            // 查询coface接口 /notifications 参数：deliveryDateFrom=2026-03-27 deliveryDateTo=2026-03-27 获取监控的数据
            CofaceModuleController.CofaceConfig cfg = new CofaceModuleController.CofaceConfig();
            // String reqUrl = cfg.dataAPIBaseUrl + '/notifications?deliveryDateFrom=' + String.valueOf(yesterday) + '&deliveryDateTo=' + String.valueOf(yesterday);
            String reqUrl = cfg.dataAPIBaseUrl + '/notifications?deliveryDateFrom=' + '2026-03-18' + '&deliveryDateTo=' + '2026-03-27';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(reqUrl);
            req.setMethod('GET');
            req.setHeader('authorization', idToken);
            req.setHeader(cfg.apiKeyHeaderName, cfg.apiKeyValue);
            req.setTimeout(120000);

            Http http = new Http();
            HttpResponse res = http.send(req);
            String responseBody = '';
            // 接口返回成功，解析数据保存到Coface Reports History数据库中
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300 && res.getBody() != null){
                responseBody = res.getBody();
                List<CofaceNotificationResponse> notificationList = (List<CofaceNotificationResponse>)JSON.deserialize(responseBody, List<CofaceNotificationResponse>.class);
                List<Coface_Report_History__c> historyList = new List<Coface_Report_History__c>();
                Set<String> reportIdSet = new Set<String>();
                for (CofaceNotificationResponse nofitication : notificationList){
                    reportIdSet.add(nofitication.monitoringId);
                }
                List<Coface_Report__c> reportList = [SELECT Id, Order_Report_Id__c
                                                     FROM Coface_Report__c
                                                     WHERE Order_Report_Id__c IN:reportIdSet];
                Map<String, SObject> reportMap = new LisqContainer(reportList).toMapS('Order_Report_Id__c');
                // 查询Coface_Reports
                for (CofaceNotificationResponse nofitication : notificationList){
                    Coface_Report_History__c history = new Coface_Report_History__c();
                    history.Coface_Report__c = reportMap.get(nofitication.monitoringId).Id;
                    history.Notification_Id__c = nofitication.id;
                    history.Delivery_Date__c = nofitication.deliveryDate;
                    history.Format__c = nofitication.format;
                    historyList.add(history);
                }
                Database.upsert (historyList, Coface_Report_History__c.Fields.Notification_Id__c);
            }
        }
    }

}