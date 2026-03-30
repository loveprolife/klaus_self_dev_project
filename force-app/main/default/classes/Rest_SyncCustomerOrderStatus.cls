/******************************************************************************
 ************************
 * Name: Rest_SyncCustomerOrderStatus
 * Description: 同步客户订单状态
 * TestClassName:  Rest_SyncCustomerOrderStatusTest
 * Version History: 0.01
 * Date: 2024-12-16
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
@RestResource(urlMapping='/SyncCustomerOrderStatus')
global with sharing class Rest_SyncCustomerOrderStatus {  

    //接收参数
    global class InputInfo{
        List<CustomerInfo> customerInfoList;
    }
    global class CustomerInfo{
        String sap_customer_code;
        String sales_office; // 销售部门
        String Hisense_Entity; //公司编码
        String order_status; // 0：锁定   1：未锁定
    }

    //返回参数
    global class OutPutInfo{
        public Boolean isSuccess;
        public String msg;
    }

    /**
     * @Param: 
     * @Return: OutPutInfo
     * @Author: lizunxing
     * @Date: 2024-12-16
     * @Description: 同步客户订单状态
     */
    @HttpPost
    global static OutPutInfo doPost() {

        //接收参数
        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 

        //返回参数
        OutPutInfo result = new OutPutInfo();
        result.msg = '';
        
        List<Account> updateAccountList = new List<Account>();
        List<Customer_Extend__c> updateAccountExtendList = new List<Customer_Extend__c>();

        Set<String> checkCode = new Set<String>();
        Set<String> sapCodes = new Set<String>();

        try {
            InputInfo ii = (InputInfo)JSON.deserialize(reqBody, InputInfo.class);

            if(ii != null && ii.customerInfoList != null && ii.customerInfoList.size() > 0){

                for(CustomerInfo ci : ii.customerInfoList){

                    if(ci != null && String.isNotBlank(ci.sap_customer_code) && String.isNotBlank(ci.Hisense_Entity) && String.isNotBlank(ci.order_status)){
                        sapCodes.add(ci.sap_customer_code);
                    }
                }

                List<Customer_Extend__c> accountExtendList = [select id,customer__r.SAP_Customer_Code__c, Hisense_Entity__c, Hisense_Entity_Sales__c, Sales_Office__r.Value__c from Customer_Extend__c where customer__r.SAP_Customer_Code__c in:sapCodes and (Hisense_Entity__c != null or Hisense_Entity_Sales__c != null)];
                Map<String, Customer_Extend__c> accountExtendMap = new Map<String, Customer_Extend__c>();
                for(Customer_Extend__c ce : accountExtendList){
                    if(String.isNotBlank(ce.Hisense_Entity__c)){
                        accountExtendMap.put(ce.customer__r.SAP_Customer_Code__c + ce.Hisense_Entity__c, ce);
                    }else{
                        accountExtendMap.put(ce.customer__r.SAP_Customer_Code__c + ce.Hisense_Entity_Sales__c, ce);
                    }
                }

                for(CustomerInfo ci : ii.customerInfoList){

                    if(ci != null && String.isNotBlank(ci.sap_customer_code) && String.isNotBlank(ci.Hisense_Entity) && String.isNotBlank(ci.order_status)){

                        if(!checkCode.add(ci.sap_customer_code + ci.Hisense_Entity)){
                            continue;
                        }

                        for(Customer_Extend__c ce : accountExtendList){
                            if(ce.customer__r.SAP_Customer_Code__c.equals(ci.sap_customer_code) && 
                                (ci.Hisense_Entity.equals(ce.Hisense_Entity__c) || ci.Hisense_Entity.equals(ce.Hisense_Entity_Sales__c))){
                                
                                if(String.isNotBlank(ci.sales_office) && !ci.sales_office.equals(ce.Sales_Office__r.Value__c)){
                                    continue;
                                }

                                ce.Order_Status__c = ci.order_status;
        
                                //更新
                                updateAccountExtendList.add(ce);
                            }
                        }

                        // if(accountMap.containsKey(ci.sap_customer_code + ci.Hisense_Entity)){
                        //     Account account = accountMap.get(ci.sap_customer_code + ci.Hisense_Entity);
                        //     account.Order_Status__c = ci.order_status;
        
                        //     //更新
                        //     updateAccountList.add(account);
                        // }else 
                        if(accountExtendMap.containsKey(ci.sap_customer_code + ci.Hisense_Entity)){
                            Customer_Extend__c ce = accountExtendMap.get(ci.sap_customer_code + ci.Hisense_Entity);
                        }else {
                            result.msg += ci.sap_customer_code + ' - ' + ci.Hisense_Entity + ',';
                        }
                    }
                }
            }

            // if(updateAccountList.size() > 0){
            //     // 忽略触发器更新
            //     Utility.IgnoreAction(true, true, true, 'AccountTriggerHandler');
            //     //更新
            //     Database.update(updateAccountList);
            //     //恢复触发器
            //     Utility.IgnoreAction(false,false,false,'');
            // }

            if(updateAccountExtendList.size() > 0){
                // 忽略触发器更新
                Utility.IgnoreAction(true, true, true, 'CustomerExtendTriggerHandler');
                //更新
                Database.update(updateAccountExtendList);
                //恢复触发器
                Utility.IgnoreAction(false,false,false,'');
            }
           
            if(String.isNotBlank(result.msg)){
                result.isSuccess = false;
                result.msg += 'Not found';
            }else{
                result.isSuccess = true;
                result.msg += 'Success';
            }

            //插入Log
            Utility.insertLog('Rest_SyncCustomerOrderStatus', '1', reqBody, '');

        } catch(Exception e) {

            result.isSuccess = false;
            result.msg = e.getMessage();

            //插入Log
            Utility.insertLog('Rest_SyncCustomerOrderStatus', '0', reqBody, 'failure: SF Rest_SyncCustomerOrderStatus Failed! ' + e.getMessage() + '-------' + reqBody);
        }

        return result;
    }
    
}