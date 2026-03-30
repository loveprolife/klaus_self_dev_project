@isTest
private class SendChannelToBigDataTest {
    static testMethod void testMethod1() {
        Test.startTest();

        Block_Dimension__c bd = new Block_Dimension__c(
            name = '日本',
            SBU_Code__c = 'rb'
        );
        insert bd;

        Customer_Management__c cm = new Customer_Management__c();
        cm.Name = 'YAMADA';
        insert cm;

        Channel__c c = new Channel__c(
            Name = 'YAMADA',
            Annual_Business_Revenue_Unit_10k_USD__c = '100000.0',
            // Channel_Code__c = '10',
            Cooperating_Customer_Entity_Name__c = '',
            Cooperating_Customer_SAP_Code__c = '',
            Cooperating_Method__c = '代理合作',
            Country__c = '日本',
            Hisense_Value_Share__c = '10.00',
            Market_Share__c = '26.0%',
            Number_of_Entered_Stores__c = '22',
            Number_of_New_Store_Entering_Plan_2024__c = '10.0%',
            Number_of_Stores__c = '998',
            Product_Line__c = '电视',
            SBU__c = '日本',
            Cooperating_Status__c = '已合作',
            Planned_Cooperating_Time__c = '',
            Statistical_Year__c = '2024',
            Cooperating_Time__c = '2024-01'
        );

        insert c;

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","endTime":"2025-02-10 00:00:00"}');
		SendChannelToBigData.adoPost();
        req.requestBody = Blob.valueOf('{"startTime":"2023-12-01 00:00:00","en');
        SendChannelToBigData.adoPost();
        Test.stopTest();
    }
}