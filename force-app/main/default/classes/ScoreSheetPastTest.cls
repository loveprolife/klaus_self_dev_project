@isTest
private class ScoreSheetPastTest {
 
    static testMethod void testPassSixty(){
        
        Test.startTest();
        Account acc1 = new Account(
            Name = 'Test sap1000000',
            SAP_Customer_Code__c = 'sap1000000',
            External_Key__c = 'sap1000000',
            Sales_Region__c = 'salesRegion',
            Approval_Status__c = 'Approved'
        );
        Database.insert(acc1);

        List<Customer_Product_Line__c> cpls = new List<Customer_Product_Line__c>();
        Customer_Product_Line__c cpl1 = new Customer_Product_Line__c();
        cpl1.Product_Line_Name__c = 'TV';
        cpl1.Customer__c = acc1.Id;
        cpl1.Management_Customer__c = acc1.Id;
        cpl1.Classification__c = 'Agency Customer';//
        cpl1.Development_Stage__c = 'Undeveloped';
        cpl1.Rank__c = 'Strategy Customer';
        cpls.add(cpl1);

        Customer_Product_Line__c cpl2 = new Customer_Product_Line__c();
        cpl2.Product_Line_Name__c = 'WM';
        cpl2.Customer__c = acc1.Id;
        cpl2.Management_Customer__c = acc1.Id;
        cpl2.Classification__c = 'OEM Customer';//OEM Customer
        cpl2.Development_Stage__c = 'Undeveloped';
        
        cpls.add(cpl2);

        Customer_Product_Line__c cpl3 = new Customer_Product_Line__c();
        cpl3.Product_Line_Name__c = 'Freezer';
        cpl3.Customer__c = acc1.Id;
        cpl3.Management_Customer__c = acc1.Id;
        cpl3.Classification__c = 'Customer of Oversea Company';
        cpl3.Development_Stage__c = 'Undeveloped';
        cpl3.Rank__c = 'Strategy Customer';
        cpls.add(cpl3);

        Database.insert(cpls);

        String plids = cpl1.id+';'+cpl2.id+';'+cpl3.id;
        Score_Sheet__c ss = new Score_Sheet__c();
        ss.Customer__c = acc1.id;
        ss.PL_ID_List__c = plids;
        insert ss;

        ss.status__c = 'Approved';
        ss.Evaluated_Rank__c = 'Strategy Customer';
        update ss;

        ss.status__c = 'Submitted';
        ss.Evaluated_Rank__c = 'Potential Eliminated Customer';
        update ss;

        ScoreSheetPast.passSixty(acc1.id);
        
        Test.stopTest();
        
    }

    static testMethod void testSaveData(){
        
        Test.startTest();
        
        Account acc1 = new Account(
            Name = 'Test sap1000000',
            SAP_Customer_Code__c = 'sap1000000',
            External_Key__c = 'sap1000000',
            Sales_Region__c = 'salesRegion',
            Approval_Status__c = 'Approved'
        );
        Database.insert(acc1);

        String comments = 'xxxx';
        String approvalName = 'admin';

        ScoreSheetPast.saveData(comments, acc1.Id, approvalName);
        String noComments = '';
        ScoreSheetPast.saveData(noComments, acc1.Id, approvalName);
        Test.stopTest();
        
    }
}