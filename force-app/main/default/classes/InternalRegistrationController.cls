public without sharing class InternalRegistrationController {
    
    @AuraEnabled
    public static ConResponse getInitData(String recordId){
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
        resp.data = mso;
        return resp;
    }
}