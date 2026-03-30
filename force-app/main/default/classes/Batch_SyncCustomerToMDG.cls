/******************************************************************************
 ************************
 * Name: Batch_SyncCustomerToMDG
 * Description:  批量同步客户
 * TestClassName:  Batch_SyncCustomerToMDGTest
 * Version History: 0.01
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
public with sharing class Batch_SyncCustomerToMDG implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    
    public List<String> idList;
    public String action;

    public Batch_SyncCustomerToMDG(List<String> idList, String action){
        this.idList = idList;
        this.action = action;
    }
    
    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Description: 进入Batch前执行方法
     */
    public Iterable<String> start(Database.BatchableContext BC) {
        return idList;
    }

    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Description: 
     */
    public void execute(Database.BatchableContext BC, list<String> idList) {
        if('GetCustomerInfoByCustomerCodeFromSAP1'.equals(action)){
            GetCustomerInfoByCustomerCodeFromSAP1.getCustomerInfo(idList.get(0), Date.today().toString().substring(0, 10).replace('-',''), Date.today().toString().substring(0, 10).replace('-',''));
        }else if('GetCustomerInfoByCustomerCodeFromSAP2'.equals(action)){
            GetCustomerInfoByCustomerCodeFromSAP2.getCustomerInfo(idList.get(0), Date.today().toString().substring(0, 10).replace('-',''), Date.today().toString().substring(0, 10).replace('-',''));
        }else if('SyncCustomerToMDG'.equals(action)){
            for(String idStr : idList){
                if(!Test.isRunningTest()){
                    SyncCustomerInfoToMDGPro1.postCustomerInfomationToMDG(idStr);
                }
            }
        }else if('Email'.equals(action)){
            List<Account> accUpdate = new List<Account>();
            for(String sapCode : idList){
                
                List<Customer_Email__c> emailList = [Select Email__c from Customer_Email__c where Customer__r.SAP_Customer_Code__c = :sapCode
                    or Customer_Address__r.SAP_Customer_Code__c = :sapCode order by No__c];

                if(emailList != null && emailList.size() > 0){
                    List<Account> acc = [Select Id,Email_Multiple__c from Account where SAP_Customer_Code__c = :sapCode];
                    if(acc != null && acc.size() > 0 && String.isBlank(acc[0].Email_Multiple__c)){
                        String emails = '';
                        for(Customer_Email__c ce : emailList){
                            emails += ce.Email__c + ';';
                        }

                        Account a = new Account(
                            Id = acc[0].Id,
                            Email_Multiple__c = emails.removeEnd(';')
                        );
                        accUpdate.add(a);
                    }
                }
  
            }
            if(accUpdate.size() > 0){
                update accUpdate;
            }
        }

        
    }

    /**
     * @Param: 
     * @Return: void
     * @Author: lizunxing
     * @Description: 执行完Batch后进入，记录日志
     */
    public void finish(Database.BatchableContext BC) {
        Utility.insertLog('Batch_SyncCustomerToMDG', '1', '', '');
    }

}