public without sharing class CommonCaptureController {
    public CommonCaptureController() {

    }

    @RemoteAction
    public static String createAttendance(String photoStream) {
        
        String fileName = System.now().format('yyyyMMddHHmmss') + '.jpeg';
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(photoStream.substring(23,photoStream.length()));
        cv.Title = 'PhotoBase64By'+fileName;
        cv.PathOnClient = fileName;
        
        insert cv;

        return cv.Id;
    }

    
    @RemoteAction
    public static void createLog(String type, String info) {
        TIMBASURVEYS__Log__c log = new TIMBASURVEYS__Log__c();
        log.Equipment_type__c = type;
        log.Equipment_Info__c = info;
        insert log;
    }
}