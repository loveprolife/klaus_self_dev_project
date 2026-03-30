@isTest
public with sharing class CommonGoogleMapControllerTest {
    static testMethod void testMethod1(){
        CommonGoogleMapController cgmc = new CommonGoogleMapController();
        String str = cgmc.lexOrigin;
        CommonGoogleMapController.getVisualforceOrigin();
    }
}