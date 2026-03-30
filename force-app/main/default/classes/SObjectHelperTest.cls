@isTest
public class SObjectHelperTest {

    @isTest
    static void testSObjectHelper(){
        Test.startTest();
        
        Account customer = new Account();
        customer.Name = 'Wal-mart';
        insert customer;
        
        SObjectHelper.getFieldLabelMap('Account');
        SObjectHelper.GetFieldDescription('Account', 'Name');
        SObjectHelper.GetFields(customer);
        SObjectHelper.GetSObjectField(customer, 'Name');
        SObjectHelper.GetSObjectField(customer, 'Owner.Name');
        Account a = (Account)SObjectHelper.first([select id from Account where id = null]);
        Test.stopTest();
    }
}