/******************************************************************************
 ************************
 * Name: Rest_SyncContractInfoTest
 * Description: Rest_SyncContractInfo测试类
 * Version History: 0.01
 * Date: 2024-11-22
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
@isTest
private class Rest_SyncContractInfoTest {

    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Date: 2024-11-22
     * @Description: Rest_SyncContractInfo.doPost 测试
     */
    static testMethod void testMethod1() {

        Test.startTest();
        RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;

        //正常返回
        req.requestBody = Blob.valueOf('{"contractList":[{"contract_filing_id":"test_contract_filing_id"}]}');
		Rest_SyncContractInfo.doPost();

        //异常情况
        req.requestBody = Blob.valueOf('{"contract_filing_id":"test_');
        Rest_SyncContractInfo.doPost();

        Test.stopTest();
    }
}