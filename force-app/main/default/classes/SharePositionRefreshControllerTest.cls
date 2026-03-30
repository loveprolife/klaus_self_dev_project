@isTest
public class SharePositionRefreshControllerTest{
    @IsTest
    static void testSharePositionRefreshController(){
        Position__c pos = new Position__c();
        pos.DeveloperName__c = 'FU_GUAN_PATROLCLERKTEST';
        pos.Grouo_Name__c = '福关网格巡店员TEST';
        pos.Activity__c = true;
        pos.Is_Job__c = true;
        INSERT pos;

        Position__c pos2 = new Position__c();
        pos2.Grouo_Name__c = '福关网格巡店员';
        pos2.Activity__c = true;
        pos2.Is_Job__c = true;
        INSERT pos2;

        Position_Permissions__c position = new Position_Permissions__c();
        position.Position__c = pos.Id;
        position.Product_Line__c = 'Mobile';
        INSERT position;

        Test.startTest();
        SharePositionRefreshController.checkPosition(pos.Id);
        SharePositionRefreshController.checkPosition(pos2.Id);
        SharePositionRefreshController.runRefreshJob(pos.Id);
        Test.stopTest();
        
    }
}