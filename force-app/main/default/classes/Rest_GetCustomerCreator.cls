/******************************************************************************
 ************************
 * Name: Rest_GetCustomerCreator
 * Description: 获取客户创建人
 * TestClassName:  Rest_GetCustomerCreatorTest
 * Version History: 0.01
 * Date: 2025-01-13
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
@RestResource(urlMapping='/GetCustomerCreator')
global with sharing class Rest_GetCustomerCreator {  

    
    //返回参数
    global class OutPutInfo{
        public String SAP_Customer_Code;
        public String Creator;
        public String Email;
    }

    /**
     * @Param: 
     * @Return: OutPutInfo
     * @Author: lizunxing
     * Date: 2025-01-13
     * @Description: 获取客户创建人
     */
    @HttpPost
    global static List<OutPutInfo> doPost() {

        //接收参数
        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 

        //返回参数
        OutPutInfo result = new OutPutInfo();
        List<OutPutInfo> resultAccountList = new List<OutPutInfo>();
        try {
            List<String> sapCodeList = (List<String>)JSON.deserialize(reqBody, List<String>.class);

            if(sapCodeList != null && sapCodeList.size() > 0){
                
                List<Account> accountList = [Select SAP_Customer_Code__c, CreatedBy.name, CreatedBy.Email from Account where SAP_Customer_Code__c in :sapCodeList];
                for(Account a : accountList){
                    OutPutInfo opi = new OutPutInfo();
                    opi.SAP_Customer_Code = a.SAP_Customer_Code__c;
                    opi.Creator = a.CreatedBy.name;
                    opi.Email = a.CreatedBy.Email;
                    resultAccountList.add(opi);
                }
                
            }

            //插入Log
            Utility.insertLog('Rest_GetCustomerCreator', '1', reqBody, '');
        } catch(Exception e) {

            //插入Log
            Utility.insertLog('Rest_GetCustomerCreator', '0', reqBody, 'failure: SF Rest_GetCustomerCreator Failed! ' + e.getMessage() + '-------' + reqBody);
        }

        return resultAccountList;
    }
    
}