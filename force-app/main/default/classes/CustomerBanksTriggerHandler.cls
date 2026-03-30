/*
 * @Author: WFC
 * @Date: 2023-03-23 16:38:33
 * @LastEditors: WFC
 * @LastEditTime: 2023-03-31 16:07:32
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\classes\CustomerExtendTriggerHandler.cls
 */
public class CustomerBanksTriggerHandler implements Triggers.Handler{
    public static User currentUser = [SELECT Id,Name,Username,Profile.name FROM User WHERE Id =:UserInfo.getUserId()]; 
    public void handle() {

        if (Trigger.isAfter && Trigger.isInsert) {        
            for(Customer_Banks__c acc : ((list<Customer_Banks__c>)Trigger.new)){
                String jobID = System.enqueueJob(new AsyncSyncEcssCustomer(acc.Bank_Name__c));
                system.Debug('======== jobID==='+jobID);
            }
        }

        if (Trigger.isBefore && Trigger.isInsert) {
            for(Customer_Banks__c acc : ((list<Customer_Banks__c>)Trigger.new)){
                // List<Account> la = [select E_commerce_Customer_Label__c from Account where id =: acc.Customer__c];
                // if(String.isBlank(la.get(0).E_commerce_Customer_Label__c)){
                //     if(!Test.isRunningTest()){
                //         acc.addError(Label.Customer_E_Required);
                //         return;
                //     }
                // }

                if(acc.MDG_Bank__c != null){
                    MDG_Bank__c mb = [select id, SWIFT__c, BANKA__c, BANKL__c, ZQSBM__c from MDG_Bank__c where id =:acc.MDG_Bank__c];
                    acc.Swift_Code__c = mb.SWIFT__c;
                    acc.Bank_Name__c = mb.BANKA__c;
                    acc.Bank_Code__c = mb.BANKL__c;
                    acc.IBAN__c = mb.ZQSBM__c;
                }
                // if(String.isNotBlank(acc.Bank_Name__c)){
                //     acc.Bank_Name__c = acc.Bank_Name__c.replace(' ', ' ');
                // }
                // String jobID = System.enqueueJob(new AsyncSyncEcssCustomer(acc.Bank_Name__c));
                // system.Debug('======== jobID==='+jobID); 
            }
        }

      

        if (Trigger.isAfter && Trigger.isUpdate) {

            //同步到SAP的客户ID集合
            List<String> accIdList = new List<String>();

            for (Customer_Banks__c acc : ((list<Customer_Banks__c>)Trigger.new)) {
                Customer_Banks__c accOld = (Customer_Banks__c)Trigger.oldMap.get(acc.Id);
                // 审批通过发送sap
                if(acc.Approval_Status__c.equals('Approved') && !acc.Approval_Status__c.equals(accOld.Approval_Status__c)){
                    accIdList.add(acc.Id);
                }
            }

            if(accIdList.size() > 0){ 
                for(String accId : accIdList){
                    if(!Test.isRunningTest()){
                        String jobID = System.enqueueJob(new AccountTriggerHandler.AsyncSyncCustomer(accId));
                        system.Debug('======== jobID==='+jobID);
                    }
                }
            }
        }

        if (Trigger.isBefore && (Trigger.isUpdate)) {
            for (Customer_Banks__c acc : ((list<Customer_Banks__c>)Trigger.new)) {
                Customer_Banks__c accOld = (Customer_Banks__c)Trigger.oldMap.get(acc.Id);

                //lzx 20250122
                if('Approved'.equals(accOld.Approval_Status__c) && !Label.Undo_Changes_Profile_Exclude.contains(currentUser.Profile.name)){

                    String oldBodyJson = JSON.serialize(accOld);
                    String newBodyJson = JSON.serialize(acc);

                    if(!oldBodyJson.equals(newBodyJson)){
                        Utility.insertCusHistoyr(acc.Id, 'Customer_Banks__c', '变更', oldBodyJson, newBodyJson);
                        acc.Approval_Status__c = 'Draft';
                    }
                }

                if(String.isNotBlank(acc.Bank_Name__c) && acc.Bank_Name__c != accOld.Bank_Name__c){
                    acc.Bank_Name__c = acc.Bank_Name__c.replace(' ', ' ');
                    String jobID = System.enqueueJob(new AsyncSyncEcssCustomer(acc.Bank_Name__c));
                    system.Debug('======== jobID==='+jobID);
                }

                if(acc.MDG_Bank__c != null){
                    MDG_Bank__c mb = [select id, SWIFT__c, BANKA__c, BANKL__c, ZQSBM__c from MDG_Bank__c where id =:acc.MDG_Bank__c];
                    acc.Swift_Code__c = mb.SWIFT__c;
                    acc.Bank_Name__c = mb.BANKA__c;
                    acc.Bank_Code__c = mb.BANKL__c;
                    acc.IBAN__c = mb.ZQSBM__c;
                }
                
            }
        }

        if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {

        }

}

    

    //异步调用接口同步ECSS扫描数据到库表
    public class AsyncSyncEcssCustomer implements Queueable, Database.AllowsCallouts {
        public String customerName { get; set; }
        public AsyncSyncEcssCustomer(String idData){
            customerName = idData;
            system.debug('======customerName===='+ customerName);
        }
        public void execute(QueueableContext context) {
            GetCustomerInfoFromECSS.GetBankInfoFromECSS(customerName);
        }
    }
}