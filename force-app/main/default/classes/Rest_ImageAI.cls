/**********************************************************************
* Name: 图片AI
* Object: 
* Purpose: 
* Author: lizunxing
* Create Date: 2025-03-24
*************************************************************************/
public without sharing class Rest_ImageAI {

    @AuraEnabled
    public static Boolean checkSI(String interfaceName, String fielBase64){
        try{
            Image_Ai_Interface__c imageAi = [Select Name, Type__c, Url__c from Image_Ai_Interface__c where Name =: interfaceName limit 1];
            String method = imageAi.Type__c;
            String url = imageAi.Url__c;
    
            // List<ContentDocumentLink> links = [Select ContentDocumentId from ContentDocumentLink where linkedEntityId =:linkedEntityId];
            // List<String> ids = new List<String>();
            // LisqContainer lqLinks = new LisqContainer(links);
            // ids.addAll(lqLinks.SelectSField('ContentDocumentId'));
            // ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id in: ids order by CreatedDate desc limit 1];
    
            String result = imageAi(imageAi.Type__c, imageAi.Url__c, fielBase64);
            System.debug('fielBase64::: ' + fielBase64);
            return result.contains('TV');
        }catch(Exception e){
            return true;
        }
        
    }

    public static String imageAi(String method, String url, String fielBase64) {
        // 方法执行开始时间
        DateTime mint = System.Now();
        System.debug('wwww--mint-- '+ mint);
        
        System.debug('wwww---- '+ url + '-----' + fielBase64);

        DateTime dt = DateTime.now(); // 获取当前日期时间
        String formattedDate = dt.format('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');

        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('image_file', fielBase64);
        
        String body = JSON.serialize(paramMap);
        System.debug('body：：： '+body);

        String bodyRes;
        try {
            String[] arg = url.split('\\?')[1].split('&');
            String appid = arg[0].split('=')[1];
            String secretKey = arg[1].split('=')[1];
            String reqUrl = url.substring(url.indexOf('com/') + 3, url.indexOf('?'));
    
            String message = method + '\n' +
            reqUrl + '\n' +
            'app_id=' + appid + '&app_key=' + secretKey + '\n' +
            appid + '\n' + 
            formattedDate + '\n';

            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url.replace(' ','%20'));
            request.setMethod(method);
            request.setHeader('X-HMAC-SIGNATURE', generateHmacSha256(message, secretKey));
            request.setHeader('X-HMAC-ALGORITHM', 'hmac-sha256');
            request.setHeader('X-HMAC-ACCESS-KEY', appid);
            request.setBody(body);
            request.setHeader('Date', formattedDate);
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000); // timeout in milliseconds
            
            System.debug('request::: '+request);
            response = http_login.send(request);
            System.debug('response '+response);
            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes.length());
            // 方法执行结束时间
            DateTime maxt = System.Now();
            System.debug('wwww--mint-- '+ maxt);
            Long minms = mint.getTime(), maxms = maxt.getTime(), diff = maxms - minms;
            Utility.insertLog('Rest_ImageAI', '1', bodyRes, ',sfdc调用获取AI图片接口成功！,开始时间：' + mint.time()+ ',结束时间：' + maxt.time() + ',时间差：' + diff + '毫秒');
            return bodyRes;
        }catch(Exception e) {
            //Integration Log
            Utility.insertLog('Rest_ImageAI', '0', body, 'failure: SF Rest_ImageAI Failed! ' + e.getMessage());
            return '';
        }
    }

    @future(callout=true)
    public static void imageAi(String imageId, String method, String url, String fielBase64) {
        
        System.debug('wwww---- '+ url + '-----' + fielBase64);

        DateTime dt = DateTime.now(); // 获取当前日期时间
        String formattedDate = dt.format('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');

        Map<String, String> paramMap = new Map<String, String>();
        paramMap.put('image_file', fielBase64);
        
        String body = JSON.serialize(paramMap);
        System.debug('body：：： '+body);

        String bodyRes;
        try {
            String[] arg = url.split('\\?')[1].split('&');
            String appid = arg[0].split('=')[1];
            String secretKey = arg[1].split('=')[1];
            String reqUrl = url.substring(url.indexOf('com/') + 3, url.indexOf('?'));
    
            String message = method + '\n' +
            reqUrl + '\n' +
            'app_id=' + appid + '&app_key=' + secretKey + '\n' +
            appid + '\n' + 
            formattedDate + '\n';

            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url.replace(' ','%20'));
            request.setMethod(method);
            request.setHeader('X-HMAC-SIGNATURE', generateHmacSha256(message, secretKey));
            request.setHeader('X-HMAC-ALGORITHM', 'hmac-sha256');
            request.setHeader('X-HMAC-ACCESS-KEY', appid);
            request.setBody(body);
            request.setHeader('Date', formattedDate);
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000); // timeout in milliseconds
            
            System.debug('request::: '+request);
            response = http_login.send(request);
            System.debug('response '+response);
            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes.length());

            Image image = new Image(
                                Id = imageId,
                                Result__c = bodyRes
                            );
                            update image;
            //Integration Log
            Utility.insertLog('Rest_ImageAI', '1', bodyRes, '');
        }catch(Exception e) {
            //Integration Log
            Utility.insertLog('Rest_ImageAI', '0', body, 'failure: SF Rest_ImageAI Failed! ' + e.getMessage());
        }

        // 品类检核
        // {
        // "result":["TV"],----检测到的品类，当前包括TV、fridge、washing machine、Laser TV、dishwasher
        
        // "code":0      -----正常返回0，异常返回-1
        // }

        // 门店logo检核
        // {
        // "result":[{"qualified":true,"bbox":[784,340,1122,421]},{"qualified":false,"bbox":[1474,58,1650,221]},{"qualified":true,"bbox":[620,2,1061,117]}],
        // ----未检测到logo，result为[],
        // 如果检测到logo，qualified为true表示合格，qualified为false表示不合格，bbox为检测到的logo在图像中的坐标。
        
        // "code":0-----正常返回0，异常返回-1
        
        // }

        // 空样检核
        // {
        // "result":{"result":"存在空样","reason":"样机下方的展台有明显的空位，未放置样品，符合空样判断条件。"},----有空样result返回存在空样，无空样result返回不存在空样，reason返回原因
        // "code":0----正常返回0，异常返回-1
        
        // }

        // 电视黑屏检核
        // {
        // "result":{"result":["Black Screen","Blue Screen"]},----如果存在黑屏、白屏、蓝屏，result返回的检测到的类型（一阶段只检测黑屏），不存在返回未检测到
        // "code":0----正常返回0，异常返回-1
        // }

    }

    public static String convertFileToBase64(String fileId) {
        // 查询 ContentVersion 记录
        ContentVersion contentVersion = [SELECT VersionData 
                                         FROM ContentVersion 
                                         WHERE ContentDocumentId = :fileId 
                                         LIMIT 1];
        if (contentVersion != null && contentVersion.VersionData != null) {
            // 将文件内容转换为 Base64 编码
            return EncodingUtil.base64Encode(contentVersion.VersionData);
        }
        return null;
    }

    public static String generateHmacSha256(String message, String secretKey){
        Blob mac = Crypto.generateMac('HmacSHA256', blob.valueof(message),blob.valueof(secretKey));
        return EncodingUtil.base64Encode(mac);
    }
}