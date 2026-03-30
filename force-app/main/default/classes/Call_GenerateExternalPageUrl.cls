/******************************************************************************
 ************************
 * Name: Call_GenerateExternalPageUrl
 * Description: DT_外部系统获取报表地址
 * TestClassName:  Call_GenerateExternalPageUrlTest
 * Version History: 0.01
 * Date: 2024-11-05
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
public without sharing class Call_GenerateExternalPageUrl {

    // public static String url = System.Label.Call_GenerateExternalPageUrl_Config;
    // public static String methodType = 'POST';
    // public static String app_id = 'kfomcoyz';
    // public static String app_key = 'lpv6jgoii11igcqgymaihdbvyvfzapob';
    // public static String name = '&name=sanghong';
    // public static String resourceId = '&resourceId=36fe9bd0f0234326a06d7e7266393628';
    // public static String systemName = '&systemName=S0218';

    

    public class ResInfo {
        String data;
        String message;
        String status;
        Boolean success;
    }

    public static String generateExternalPageUrl(String resourceId) {

        User user = [SELECT Id,HisenseSSOName__c FROM User WHERE Id = : UserInfo.getUserId()][0];
        if(String.isBlank(user.HisenseSSOName__c)){
            return System.Label.NO_SSO;
        }

        String name = user.HisenseSSOName__c;

        api_platform__mdt setting = api_platform__mdt.getInstance('Call_GenerateExternalPageUrl');
        String app_id = setting.app_id__c;    
        String app_key = setting.app_key__c;    
        String methodType = setting.methodType__c;  
        String systemName = setting.systemName__c;  
        String url = setting.url__c;  

        String params = 'app_id=' + app_id + '&app_key=' + app_key + '&name=' + name + '&resourceId=' + resourceId + '&systemName=' + systemName;

        Call_GenerateExternalPageUrl.ResInfo resInfo = new Call_GenerateExternalPageUrl.ResInfo();

        String message = methodType + '\n'+ 
        '/dt/api/dtconfig/demo/generateExternalPageUrl\n' +
        params + '\n' +
        app_id + '\n' +
        'Mon, 01 Apr 2024 03:55:01 GMT\n';

        String bodyRes;
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url + '?' + params);
            request.setMethod(methodType);
            request.setHeader('X-HMAC-SIGNATURE', generateHmacSha256(message, app_key));
            request.setHeader('X-HMAC-ALGORITHM', 'hmac-sha256');
            request.setHeader('X-HMAC-ACCESS-KEY', app_id);
            request.setHeader('Date', 'Mon, 01 Apr 2024 03:55:01 GMT');
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000); // timeout in milliseconds
            
            System.debug('request::: '+request);
            response = http_login.send(request);
            System.debug('response '+response);
            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes);

            if(String.isNotBlank(bodyRes) && !'""'.equals(bodyRes)){
                
                resInfo = (Call_GenerateExternalPageUrl.ResInfo) JSON.deserialize(bodyRes, Call_GenerateExternalPageUrl.ResInfo.class);

                if(resInfo.success){
                    
                    return resInfo.data;
                }else{
                    return resInfo.message;
                }

            }
        }catch(Exception e) {
            //Integration Log
            Utility.insertLog('Call_GenerateExternalPageUrl', '0', '', 'failure: SF Call_GenerateExternalPageUrl Failed! ' + e.getMessage());
        }

        return '';
    }

    public static String generateHmacSha256(String message, String secretKey){
        // 'GET\n'+
        // '/apex/ords/edw_apex/hs/odsgjyxec_odsrpa_total_makro_za_week_dispo\n'+
        // 'app_id=vadyskme&app_key=8thzb2cugghhukjjgdnpuntyeflummbx&datatime=26.02.2024to03.03.2024\n'+
        // 'vadyskme\n'+
        // 'Mon, 01 Apr 2024 03:55:01 GMT\n';

        Blob mac = Crypto.generateMac('HmacSHA256', blob.valueof(message),blob.valueof(secretKey));
        return EncodingUtil.base64Encode(mac);
    }
    
}