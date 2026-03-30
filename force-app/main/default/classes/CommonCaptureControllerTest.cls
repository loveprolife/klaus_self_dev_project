@isTest
public with sharing class CommonCaptureControllerTest {
    @isTest
    static void testMethod1(){
        String base64 = 'YmluYXJ5AHN0cmluZwHKW89HJjnjd98DD7JL==';
        CommonCaptureController.createAttendance(base64);

        CommonCaptureController.createLog('sendSMS', 'phoneNumbers=');

    }
}