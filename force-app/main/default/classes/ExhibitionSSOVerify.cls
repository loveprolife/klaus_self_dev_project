/**************************************************************************************************
 * Name: ExhibitionSSOVerify
 * Object: Internal_Registration__c
 * Purpose: 通过SSO接口验证员工信息
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0          Ethan             2023-08-23         Created        
 
***************************************************************************************************/
global with sharing class ExhibitionSSOVerify {
    private final static String GET_TOKEN_URL = System.Label.Exhibition_SSO_Get_Token_Url+
        '&appSecretId='+System.Label.Exhibition_SSO_SecretId+'&appSecretKey='+System.Label.Exhibition_SSO_SecretKey+'&eidClass=ldap';
    private final static String VERIFY_API_URL = System.Label.Exhibition_SSO_Verify_API_Url;
    private final static String VERIFY_SECRETID = System.Label.Exhibition_SSO_SecretId;
    
    @AuraEnabled
    public static VerifyData verifyInternalRegistration(String uid) {
        VerifyData verifyData = new VerifyData();
        try{
            VerifySendBody verifySendBody = new VerifySendBody();
            verifySendBody.accessToken = getToken();
            verifySendBody.params = uid;

            Http http = new Http();
            HttpRequest req = new HttpRequest();
            // req.setHeader('Authorization', TOKEN);
            req.setHeader('Content-Type','application/json; charset=UTF-8');
            req.setEndpoint(VERIFY_API_URL);
            req.setTimeout(120000);
            req.setMethod('POST');
            req.setBody(JSON.serialize(verifySendBody));
            HttpResponse res = http.send(req);
            System.debug('res ----->'+ res);
            System.debug('verifySendBody ----->'+ verifySendBody);
            System.debug('res.getBody() ----->'+ res.getBody());
            verifyData = (VerifyData) JSON.deserialize(res.getBody(), VerifyData.class);
        }catch(Exception e) {
            System.debug('error-->'+e.getLineNumber()+e.getMessage());
            verifyData.code = 500;
            verifyData.message ='SSO调用异常：'+e.getLineNumber()+e.getMessage();
        }
        return verifyData;

        


    }


    private static String getToken() {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            // req.setHeader('Authorization', TOKEN);
            // req.setHeader('Content-Type','application/json; charset=UTF-8');
            req.setEndpoint(GET_TOKEN_URL);
            req.setTimeout(120000);
            req.setMethod('GET');
            // req.setBody(JSON.serialize(data));
            HttpResponse res = http.send(req);
            System.debug('----->'+res.getBody());
            TokenWrapper tokenWrapper = new TokenWrapper();
            tokenWrapper = (TokenWrapper) JSON.deserialize(res.getBody(), TokenWrapper.class);
            return tokenWrapper.tokenId;
    }



    public class TokenWrapper{
        public String resCode;
        public String resMess;
        public String tokenId;
        public String effecTime;
    }
    public class Data{
        @AuraEnabled
        public String uid;//信鸿号
        @AuraEnabled
        public String mail;//邮箱
        @AuraEnabled
        public String title;//岗位
        @AuraEnabled
        public String ou;//部门
        @AuraEnabled
        public String cn;//中文名称
        @AuraEnabled
        public String departmentNumber;//部门编号
        @AuraEnabled
        public String displayid;
        // @AuraEnabled
        // public String telephoneNumber;
        @AuraEnabled
        public String postalAddress;
        @AuraEnabled
        public String o;
        @AuraEnabled
        public String mobile;//手机号
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

    public class VerifySendBody{
        public String appSecretId;
        public String accessToken;
        public String params;
        public String eidClass;

        public VerifySendBody(){
            appSecretId = VERIFY_SECRETID;
            eidClass = 'ldap';
        }
    }

    

}