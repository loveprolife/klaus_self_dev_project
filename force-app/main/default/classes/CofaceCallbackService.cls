@RestResource(urlMapping = '/callback/*')
global without sharing class CofaceCallbackService{
    @HttpPost
    global static void handlePost(){
        // 1. 读取请求体
        String body = RestContext.request.requestBody.toString();
        System.debug('Coface Callback Body: ' + body);
        RestRequest req = RestContext.request;

        // 2. 处理业务回调
        // 解析 /services/apexrest 后面的内容
        String apexRestPath = extractApexRestPath(req.requestURI);

        // Example: create Coface_Report__c and optionally relate it using incomingId
        Cofase_Test__c cr = new Cofase_Test__c();
        cr.Key__c = apexRestPath;

        try{
            // Insert with standard context; switch to Database.insert with USER_MODE if required for FLS/sharing
            insert cr;
            // 示例：简单返回成功
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf('{"status":"success","message":"Callback received"}');
        } catch (DmlException e){
            
        }
    }

    // 提取 /services/apexrest 后面的路径
    private static String extractApexRestPath(String requestURI){
        String apexRestMarker = '/services/apexrest';
        Integer markerIndex = requestURI.indexOf(apexRestMarker);

        if (markerIndex != -1){
            // 返回 marker 之后的部分
            return requestURI.substring(markerIndex + apexRestMarker.length());
        }

        return requestURI;
    }

}