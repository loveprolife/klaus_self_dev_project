/**************************************************************************************************
 * Name: ExhibitionSSOVerify
 * Object: Internal_Registration__c
 * Purpose: 通过盘古接口验证员工信息
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0         taojingpeng         2025-10-23      Created        
 
***************************************************************************************************/
global with sharing class ExhibitionSSOVerifyPanGu {

    public static VerifyData verifyInternalRegistration(String uid) {


        String param = '&uid=' + uid;

        // String url = 'https://open-apisix-test.hisense.com/iam/esc-idm/api/v1/user/userInfo?app_id=jp9rwsye&app_key=iav2ibpwgahi7cn7xk6l7lvetohtivpq' + param;
        String url = 'https://open-apisix.hisense.com/iam/esc-idm/api/v1/user/userInfo?app_id=4c0qyw7y&app_key=ybrcragsfwoezllwsy21htb6bpfbthof' + param;

        // String appid = 'jp9rwsye';
        // String secretKey = 'iav2ibpwgahi7cn7xk6l7lvetohtivpq';
        String appid = '4c0qyw7y';
        String secretKey = 'ybrcragsfwoezllwsy21htb6bpfbthof';
        String message = 'GET\n'+
        '/iam/esc-idm/api/v1/user/userInfo\n'+
        'app_id='+appid+'&app_key=' + secretKey + param +'\n'+
        appid+'\n'+
        'Mon, 01 Apr 2024 03:55:01 GMT\n';

        String bodyRes;
        VerifyData verifyData = new VerifyData();
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url.replace(' ','%20'));
            request.setMethod('GET');
            request.setHeader('X-HMAC-SIGNATURE', generateHmacSha256(message, secretKey));
            request.setHeader('X-HMAC-ALGORITHM', 'hmac-sha256');
            request.setHeader('X-HMAC-ACCESS-KEY', appid);
            request.setHeader('Date', 'Mon, 01 Apr 2024 03:55:01 GMT');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', JwtUtil.getAuthorizationToken());
            request.setTimeout(120000); // timeout in milliseconds

            // System.debug('bearToken::: '+ JwtUtil.getAuthorizationToken());
            System.debug('request::: '+request);
            response = http_login.send(request);
            System.debug('response '+response);
            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes);

            Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(bodyRes);

            // 2. 只处理 data 节点
            Object result = root.get('data');
            if(result == null ||(result instanceof String && String.isBlank((String) result))) {
                verifyData.code = 500;
                verifyData.message ='用户名:' + uid +'在系统中不存在';
            } else {
                // System.debug('result' + result);
                Map<String, Object> dataNode = (Map<String, Object>) result;
                // System.debug('dataNode' + dataNode);
                for (String key : dataNode.keySet()) {
                    Object val = dataNode.get(key);
                    if (val != null && String.valueOf(val).contains('%')) {
                        // URL 解码
                        dataNode.put(key, EncodingUtil.urlDecode(String.valueOf(val), 'UTF-8'));
                    }
                }
                Data row = new Data();            
                row.uid             = (String) dataNode.get('uid');            
                row.employeeNumber   = (String) dataNode.get('employeeNumber');
                row.cn              = (String) dataNode.get('cn');            
                row.mail            = (String) dataNode.get('mail');           
                row.title           = (String) dataNode.get('title');
                row.sn       = (String) dataNode.get('sn');
                row.cnen       = (String) dataNode.get('cnen');
                row.mobile          = (String) dataNode.get('mobile');
                row.o               = (String) dataNode.get('o');
                row.ou              = (String) dataNode.get('ou');
                row.telephoneNumber               = (String) dataNode.get('telephoneNumber');
                row.usertype               = (String) dataNode.get('usertype');
                row.idNumber               = (String) dataNode.get('idNumber');

                verifyData.code    =  0;
                verifyData.message =  'SUCCESS';
                verifyData.total   = '1';
                verifyData.data    = new List<Data>{ row }; 
            } 

        } catch(Exception e) {
            System.debug('error-->'+e.getLineNumber()+e.getMessage());
            verifyData.code = 500;
            verifyData.message ='SSO调用异常：'+e.getLineNumber()+e.getMessage();
        }
        System.debug(verifyData);
        return verifyData;      
    }

    public static String generateHmacSha256(String message, String secretKey){
        Blob mac = Crypto.generateMac('HmacSHA256', blob.valueof(message),blob.valueof(secretKey));
        // System.debug('AUTH=' + EncodingUtil.base64Encode(mac));
        return EncodingUtil.base64Encode(mac);
    }

    public class Data {
        @AuraEnabled
        public String uid;//信鸿号
        @AuraEnabled
        public String employeeNumber;//部门编号
        @AuraEnabled
        public String cn;//中文名称
        @AuraEnabled
        public String mail;//邮箱
        @AuraEnabled
        public String title;//岗位
        @AuraEnabled
        public String sn;
        @AuraEnabled
        public String cnen;
        @AuraEnabled
        public String mobile;//手机号
        @AuraEnabled
        public String o;
        @AuraEnabled
        public String ou;//部门
        @AuraEnabled
        public String telephoneNumber;
        @AuraEnabled
        public String usertype;
        @AuraEnabled
        public String idNumber;
    }

    global class VerifyData{
        @AuraEnabled
        public Integer code;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String total;
        @AuraEnabled
        public List<Data> data = new List<Data>();
    }
}