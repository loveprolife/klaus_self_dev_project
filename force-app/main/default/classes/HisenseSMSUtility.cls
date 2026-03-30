public without sharing class HisenseSMSUtility {

    public static List<TIMBASURVEYS__Log__c> logList = new List<TIMBASURVEYS__Log__c>();

    public static Boolean sendSMS(String phoneNumber, String msg) {
        if (String.isBlank(phoneNumber)) {
            return false;
        }
        return sendSMS(new String[] {phoneNumber}, msg);
    }
    public static Boolean sendSMS(String[] phoneNumbers, String msg) {
        if (phoneNumbers == null || phoneNumbers.size() == 0 || String.isBlank(msg)) {
            return false;
        }

        try{
            Map<String, Object> requestObj = new Map<String, Object> {
                'msgName' => '短信群发',
                'content' => msg,
                'sysCode' => Label.HisenseSMSCode,
                'sendType' => '8',
                'sendTo' => phoneNumbers
            };
            String request = JSON.serialize(requestObj);
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            System.debug('request ----->'+ request);
            // req.setHeader('Authorization', TOKEN);
            req.setHeader('Content-Type','application/json; charset=UTF-8');
            req.setEndpoint(Label.HisenseSMSUrl);
            req.setTimeout(120000);
            req.setMethod('POST');
            req.setBody(request);
            String response = null;
            if (Test.isRunningTest()) {
                response = '{"ts":1702562011599,"data":null,"code":"0","msg":"操作成功","alert":"0"}';
            } else {
                HttpResponse res = http.send(req);
                System.debug('res=' + res);
                if (res.getStatusCode() != 200) {
                    return false;
                }
                response = res.getBody();
                createLog('sendSMS', 'phoneNumbers=' + phoneNumbers + ',msg=' + msg + '\nrequest=' + request + '\nres=' + res + '\nresponse=' + response);
            }
            
            System.debug('response=' + response);
            Map<String, Object> responseObj = (Map<String, Object>)JSON.deserializeUntyped(response);
            return '0'.equals(String.valueOf(responseObj.get('code')));
        }catch(Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            createLog('sendSMS', 'phoneNumbers=' + phoneNumbers + ',msg=' + msg + '\n' + e.getMessage() + '\n' + e.getStackTraceString());
            return false;
        }
    }

    public static void createLog(String type, String info) {
        TIMBASURVEYS__Log__c log = new TIMBASURVEYS__Log__c();
        log.Equipment_type__c = type;
        log.Equipment_Info__c = info;
        logList.add(log);
    }

    public static void saveLog() {
        insert logList;
        logList.clear();
    }
}