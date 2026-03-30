/******************************************************************************
 ************************
 * Name: Rest_SyncCustomerOrderStatusTest
 * Description: Rest_SyncCustomerOrderStatus测试类
 * Version History: 0.01
 * Date: 2024-12-16
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
@isTest
private class Rest_SyncCustomerOrderStatusTest {

    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Date: 2024-11-22
     * @Description: Rest_SyncCustomerOrderStatus.doPost 测试
     */
    static testMethod void testMethod1() {

        Account account = new Account(
            sap_customer_code__c = '0005000454',
            Hisense_Entity__c = '0000',
            Name = 'test',
            E_commerce_Customer_Label__c = '10'
        );
        
        insert account;

        Customer_Extend__c ce = new Customer_Extend__c();
        ce.Customer__c = account.id;
        ce.Approval_Status__c = 'Draft';
        ce.Show_Company__c = true;
        ce.Hisense_Entity__c = '0000';
        insert ce;

        Test.startTest();
        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;

        //正常返回
        req.requestBody = Blob.valueOf('{"customerInfoList": [{"sap_customer_code":"0005000454","order_status":"0","Hisense_Entity":"0000"},{"sap_customer_code":"0005000454","order_status":"0","Hisense_Entity":"8110"}]}');
		Rest_SyncCustomerOrderStatus.doPost();

        //异常情况
        req.requestBody = Blob.valueOf('{"contract_filing_id":"test_');
        Rest_SyncCustomerOrderStatus.doPost();

        Test.stopTest();
    }
}