/**********************************************************************
* Name: SyncCustomerInfoCheckToSAP
* Object: Account 
* Purpose: When customer get approved from salesforce,customer information
* send to MDG automatically
* Author: Chen Fen
* Create Date: 2024-10-29
*************************************************************************/
public without sharing class SyncCustomerInfoCheckToSAP {

    //接口主信息
    public class InterfaceInfo {
        public SyncCustomerInfoToMDGPro.InterfaceBody IV_OUTPUT;
    }

    public class ResDeta {
        public String RTMSG;
        public String RTYPE;
        //public List<String> ET_MESSAGE;
    }

    public static String syncCustomerInfoCheckToSAP(SyncCustomerInfoToMDGPro.InterfaceBody IV_INPUT, String customerId) {

        String url = MDG_Interface__c.getValues('SyncCustomerInfoCheckToSAP').Url__c;
        String appid = MDG_Interface__c.getValues('SyncCustomerInfoCheckToSAP').AppId__c;       
        String secretKey = MDG_Interface__c.getValues('SyncCustomerInfoCheckToSAP').SecretKey__c;
        String server = MDG_Interface__c.getValues('SyncCustomerInfoCheckToSAP').Server__c;

        // String url = 'https://open-apisix-test.hisense.com/SAP810/SAP810S0235/K/ZSF_CUSTOMER_CHECK?app_id=vbp3safz&app_key=dztipzjwhv6mdlh5aw2ydkoxhmc6jip3';
        // String appid = 'vbp3safz';
        // String secretKey = 'dztipzjwhv6mdlh5aw2ydkoxhmc6jip3';
        // String server = '/SAP810/SAP810S0235/K/ZSF_CUSTOMER_CHECK';
        String message = 'POST\n'+
                          server+'\n'+
                        //  '/mdg-cus-uwh/sap/bc/zmdg\n'+
                         'app_id='+appid+'&app_key=' + secretKey +'\n'+
                          appid+'\n'+
                         'Mon, 01 Apr 2024 03:55:01 GMT\n';

        InterfaceInfo interfaceInfo = new InterfaceInfo();
        interfaceInfo.IV_OUTPUT = IV_INPUT;


        String body = JSON.serialize(interfaceInfo).replace('true,','"X",').replace('false,', 'null,');
        System.debug(LoggingLevel.DEBUG,'body:: ' + body); 

        ResDeta input = new ResDeta();
        String bodyRes;

        InterfaceLog__c ic = new InterfaceLog__c();
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();
            request.setEndpoint(url.replace(' ','%20'));
            request.setMethod('POST');
            request.setHeader('X-HMAC-SIGNATURE', generateHmacSha256(message, secretKey)); //generateHmacSha256(message, secretKey)
            request.setHeader('X-HMAC-ALGORITHM', 'hmac-sha256');
            request.setHeader('X-HMAC-ACCESS-KEY', appid);
            request.setHeader('Date', 'Mon, 01 Apr 2024 03:55:01 GMT');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds
            System.debug('request::: '+request);
            response = http_login.send(request);
            bodyRes = response.getBody();
            System.debug('bodyRes:' + bodyRes);
            System.debug('********:');
            SyncCustomerInfoCheckToSAP.ResDeta input_login = new SyncCustomerInfoCheckToSAP.ResDeta();
            input_login = (SyncCustomerInfoCheckToSAP.ResDeta) JSON.deserialize(bodyRes, SyncCustomerInfoCheckToSAP.ResDeta.class);
            System.debug('input_login:'+input_login);
            
            if (input_login.RTYPE == 'S' ) {
                
            }else {
                Utility.insertLog('SyncCustomerInfoCheckToSAP', '0', body, input_login.RTMSG);
                // if(!Label.SyncCustomerInfoToMDG_Error.contains('测试不发')){
                //     List<String> toAddress = Label.SyncCustomerInfoToMDG_Error.split(',');
                //     Utility.sendMail('SyncCustomerInfoCheckToSAP接口失败：' + customerId, input_login.RTMSG, toAddress, 'Salesforce System', '');
                // }
                return input_login.RTMSG;
            }      
        }catch(Exception e) {
            Utility.IgnoreAction(false,false,false,'');
            //Integration Log
            // Utility.insertLog('SyncCustomerInfoCheckToSAP', '0', body, 'failure: SF SyncCustomerInfoCheckToSAP Failed! ' + e.getMessage() + '-------' + bodyRes);
            // if(!Label.SyncCustomerInfoToMDG_Error.contains('测试不发')){
            //     List<String> toAddress = Label.SyncCustomerInfoToMDG_Error.split(',');
            //     Utility.sendMail('SyncCustomerInfoCheckToSAP接口失败：' + customerId, 'failure: SF SyncCustomerInfoCheckToSAP Failed! ' + e.getMessage() + '-------' + bodyRes, toAddress, 'Salesforce System', '');
            // }
            return 'failure: SF SyncCustomerInfoCheckToSAP Failed! ' + e.getMessage();
        }

        return 'SUCCESS'; 
    }

    public static String generateHmacSha256(String message, String secretKey){
        System.debug('message' + message);
        Blob mac = Crypto.generateMac('HmacSHA256', blob.valueof(message),blob.valueof(secretKey));
        String sigture = EncodingUtil.base64Encode(mac);
        System.debug('sigture' + sigture);
        return sigture;
    }
    
}