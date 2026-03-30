/**************************************************************************************************
 * SalesTargetTriggerHandler
 * Purpose: Sales_Target_Branch_Company_Use__c 上传SAP_Customer_Code__c 转换成id
 * Author: wfc
 * Create Date: 2020-09-17 
***************************************************************************************************/
public class SalesTargetTriggerHandler extends TriggerHandler{
    
    public override void beforeInsert(){
        for(Sales_Target_Branch_Company_Use__c cpl : ((list<Sales_Target_Branch_Company_Use__c>)Trigger.new)){
            // year赋值
            if(String.isBlank(cpl.Year__c)){
                cpl.Year__c = (Date.today() + '').subString(0,4);
            }
            // 查询customer表赋值
            if(String.isNotBlank(cpl.Customer_Name_Import__c)){
                String customerNameImport = cpl.Customer_Name_Import__c;
                // 补充‘0’
                Integer num = 10 - customerNameImport.length();
                if(customerNameImport.length() < 10){
                    for (Integer i = 0; i < num; i++) {
                        customerNameImport = '0' + customerNameImport;
                    }
                }

                List<Account> customerList= [select id from Account where SAP_Customer_Code__c =: customerNameImport];
                for(Account account : customerList){
                    cpl.Customer_Name__c = account.id;
                }


            }
        }
    }

}