@isTest
public with sharing class PersonalTargetControllerTest {
    @isTest
    public static void PersonalTargetControllerTest() {
        Test.startTest();
        PersonalTargetController.getTargetAndCompletedAmount(null,null);
        Test.stopTest();
    }
}