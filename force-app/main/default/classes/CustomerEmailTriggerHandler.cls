public class CustomerEmailTriggerHandler implements Triggers.Handler{
    
    public void handle() {
        List<Customer_Email__c> emailList = new List<Customer_Email__c>(); 

        if (Trigger.isBefore && Trigger.isInsert) {
            for (Customer_Email__c acc : ((list<Customer_Email__c>)Trigger.new)) {
                
                if(String.isNotBlank(acc.Customer__c)){
                    acc.External_key__c = acc.Customer__c + '_' + acc.Email__c;
                }else if(String.isNotBlank(acc.Customer_Address__c)){
                    acc.External_key__c = acc.Customer_Address__c + '_' + acc.Email__c;
                }else{
                    acc.addError('Customer cannot be empty.');
                    return;
                }
            }  
        }

        if (Trigger.isAfter && Trigger.isInsert) {
            for (Customer_Email__c acc : ((list<Customer_Email__c>)Trigger.new)) {
                
                if(String.isNotBlank(acc.Customer__c)){
                    emailList = [select id, No__c from  Customer_Email__c where Customer__c = :acc.Customer__c order by No__c asc, CreatedDate desc];
                }else{
                    emailList = [select id, No__c from  Customer_Email__c where Customer_Address__c =:acc.Customer_Address__c order by No__c asc, CreatedDate desc];
                }
                sortNo(emailList);
              
            }  
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            for (Customer_Email__c acc : ((list<Customer_Email__c>)Trigger.new)) {
                Customer_Email__c accOld = (Customer_Email__c)Trigger.oldMap.get(acc.Id);
                if(accOld.No__c != acc.No__c){
                    if(String.isNotBlank(acc.Customer__c)){
                        emailList = [select id, No__c from  Customer_Email__c where Customer__c = :acc.Customer__c order by No__c asc, CreatedDate desc];
                    }else{
                        emailList = [select id, No__c from  Customer_Email__c where Customer_Address__c =:acc.Customer_Address__c order by No__c asc, CreatedDate desc];
                    }
                    sortNo(emailList);
                }
            }  
        }

        if (Trigger.isAfter && Trigger.isDelete) {
        
            for (Customer_Email__c acc : ((list<Customer_Email__c>)Trigger.old)) {
                
                if(String.isNotBlank(acc.Customer__c)){
                    emailList = [select id, No__c from  Customer_Email__c where Customer__c = :acc.Customer__c order by No__c asc, CreatedDate desc];
                }else{
                    emailList = [select id, No__c from  Customer_Email__c where Customer_Address__c =:acc.Customer_Address__c order by No__c asc, CreatedDate desc];
                }

                sortNo(emailList);

            }
        }
    }

    public static void sortNo(List<Customer_Email__c> ceList){
        Integer index = 1;
        for(Customer_Email__c ce : ceList){
            ce.No__c = index++;
        }

        //忽略触发器更新
        GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'CustomerEmailTriggerHandler');

        if(!Test.isRunningTest()){
            update ceList;
        }
        
        //恢复触发器
        Utility.IgnoreAction(false,false,false,'');


    }
}