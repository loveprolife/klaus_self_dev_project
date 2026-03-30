/******************************************************************************
 ************************
 * Name: Rest_GetCustomerCreatorTest
 * Description: Rest_GetCustomerCreator测试类
 * Version History: 0.01
 * Date: 2024-11-22
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
@isTest
private class Rest_GetCustomerCreatorTest {

    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Date: 2025-01-13
     * @Description: Rest_GetCustomerCreator.doPost 测试
     */
    static testMethod void testMethod1() {

        Test.startTest();

        Account acc1 = new Account(
            Name = 'TestAccount 1',
            SAP_Customer_Code__c = '0000504263',
            External_Key__c = '0000504263',
            Sales_Region__c = 'Hisense USA'
        );
        Database.insert(acc1); 

        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;

        //正常返回
        req.requestBody = Blob.valueOf('["0000504263","0000504751"]');
		Rest_GetCustomerCreator.doPost();

        //异常情况
        req.requestBody = Blob.valueOf('["0000504263","0000504');
        Rest_GetCustomerCreator.doPost();

        Test.stopTest();
    }
}