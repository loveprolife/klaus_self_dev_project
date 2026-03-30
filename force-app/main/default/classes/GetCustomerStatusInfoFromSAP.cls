/**********************************************************************
 * 
 *客户冻结状态变化

SAPCustomerCode SAP客户编号 Y   String  
CustomerStatus  客户状态    Y   String  "FD32：信用冻结
                                        XD05：业务冻结
                                        XD06：客户标记删除"
StatusChangingTime  客户状态变更时间    Y   String  YYYY-MM-DD HH24:MI:SS

*************************************************************************/
@RestResource(urlMapping='/getCustomerStatusInfoFromSAP')

global with sharing class GetCustomerStatusInfoFromSAP {

    //对象属性
    public class CustomerStatusObject {
        public String SAPCustomerCode;
        public String CustomerStatus;
        public String StatusChangingTime;
    }
    //返回值类
    global class SFOutputResult{
        String IsSuccess;
        String FailReason;
    }

    @HttpPost
    global static GetCustomerStatusInfoFromSAP.SFOutputResult doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 

        String reqBody = req.requestBody.tostring();  //收到的值
        system.debug('doPost now, body : ' + reqBody);
        //String reqBody = '{"SAPCustomerCode": "0005001234","CustomerStatus": "FD32","StatusChangingTime": "2014-01-22 10:29:48"}';

        GetCustomerStatusInfoFromSAP.CustomerStatusObject customerStatusUpdate = new GetCustomerStatusInfoFromSAP.CustomerStatusObject();//创建要进行更新的对象
        GetCustomerStatusInfoFromSAP.SFOutputResult result = new GetCustomerStatusInfoFromSAP.SFOutputResult();//创建返回对象
        try {

            customerStatusUpdate = (GetCustomerStatusInfoFromSAP.CustomerStatusObject) Json.deserialize(reqBody, GetCustomerStatusInfoFromSAP.CustomerStatusObject.class);//解析JSON
            if (customerStatusUpdate == null ) {

                //log
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'GetCustomerStatusInfoFromSAP';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '0';
                ic.Req_Json__c = reqBody;
                ic.ErrorMsg__c = 'Error Input JSON, Please Check the Input Data Structure！';
                insert ic;

                result.IsSuccess = 'False';
                result.FailReason = 'Error Input JSON, Please Check the Input Data Structure！';
                return result;
            }else{

                List<Account> customerTmpList = [SELECT Id FROM Account WHERE SAP_Customer_Code__c =: customerStatusUpdate.SAPCustomerCode]; //把SF对应此SAP客户号的SF的ID取出来
                if (customerTmpList.size() < 1 ) {

                    //log
                    InterfaceLog__c ic = new InterfaceLog__c();
                    ic.Class__c = 'GetCustomerStatusInfoFromSAP';
                    ic.Time__c = System.Now();
                    ic.ReturnCode__c = '1';
                    ic.Req_Json__c = reqBody;
                    ic.ErrorMsg__c = 'No Customer Exist in SF';
                    insert ic;

                    result.IsSuccess = 'True';
                    result.FailReason = 'No Customer Exist in SF';
                    
                    return result;
                }
                Account customerTmp = customerTmpList.get(0);
                
                Account customer = new Account();
                customer.Id = customerTmp.Id;
                customer.Customer_Status__c = customerStatusUpdate.CustomerStatus;
                customer.Status_Changing_Time_From_SAP__c = customerStatusUpdate.StatusChangingTime;//时间格式YYYY-MM-DD HH24:MI:SS

                System.debug('customer::: '+customer);
                Database.update(customer);//更新这条客户信息

                //log
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'GetCustomerStatusInfoFromSAP';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                ic.Req_Json__c = reqBody;
                ic.ErrorMsg__c = '';
                insert ic;

                result.IsSuccess = 'true';
                result.FailReason = '';
                return result;
            }
        }
        catch(Exception e){
            //log
            System.debug('wfc04');
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'GetCustomerStatusInfoFromSAP';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = reqBody;
            ic.ErrorMsg__c = e.getMessage();
            insert ic;

            result.IsSuccess = 'False';
            result.FailReason = e.getMessage();
            return result;
        }
    }
}