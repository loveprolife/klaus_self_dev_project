public class SalesTriggerHandler extends TriggerHandler{
    public override void afterInsert(){
        //共享客户给记录上的user
        Map<String,AccountShare> insertshareMap = new Map<String,AccountShare>();
        for (Sales__c sales : ((list<Sales__c>)Trigger.new)) {
            AccountShare accShare = new AccountShare();
            accShare.RowCause = 'Manual';
            accShare.AccountId = sales.Customer__c;
            accShare.UserOrGroupId = sales.Sales__c;
            accShare.AccountAccessLevel = 'Edit';
            accShare.OpportunityAccessLevel = 'Edit';
            String key = String.valueOf(sales.Customer__c) + String.valueOf(sales.Sales__c);
            insertshareMap.put(key,accShare);
        }
        // system.debug(insertshareList);
        if(insertshareMap.size() > 0){
            try{
                Database.insert(insertshareMap.values(),false);
            }catch(Exception e){
                system.debug('error message'+e.getMessage());
                system.debug('line number'+e.getLineNumber());
            }
        }
    }
    public override void beforeDelete(){        
        Set<String> acccountIdSet = new Set<String>();
        for (Sales__c sales : ((list<Sales__c>)Trigger.old)) {            
            acccountIdSet.add(sales.Customer__c);
        }
        Set<String> deleteSalesIdSet = new Set<String>();
        Map<String,Integer> salesCountMap = getCustomerSalesCount(acccountIdSet);              
        for(Sales__c sales : ((list<Sales__c>)Trigger.old)){
            //System.debug('ID Con:'+String.valueOf(sales.Customer__c)+String.valueOf(sales.Sales__c));
            if(salesCountMap.get(String.valueOf(sales.Customer__c)+String.valueOf(sales.Sales__c))!=null && salesCountMap.get(String.valueOf(sales.Customer__c)+String.valueOf(sales.Sales__c))==1 ){
                deleteSalesIdSet.add(sales.Sales__c);
            }
        }
        //System.debug('deleteSalesIdSet:'+deleteSalesIdSet);

        //查询客户共享数据
        List<AccountShare> shareList = [select id,UserOrGroupId,AccountId from AccountShare where UserOrGroupId in: deleteSalesIdSet AND RowCause = 'Manual'];
        Map<String,AccountShare> delShareMap = new Map<String,AccountShare>();
        for (AccountShare accs : shareList) {
            for (Sales__c sales : ((list<Sales__c>)Trigger.old)) {
                if(accs.AccountId == sales.Customer__c){
                    delShareMap.put(accs.Id,accs);
                }
            }
        }
        //System.debug('delShareMap:'+delShareMap);
        List<AccountShare> delshareList = delShareMap.values();
        if(delshareList.size()>0){
            try{
                delete delshareList;
            }catch(Exception e){
                system.debug('error message'+e.getMessage());
                system.debug('line number'+e.getLineNumber());
            }
        }
    }

    public override void beforeUpdate(){
        Set<String> acccountIdSet = new Set<String>();
        for(Sales__c sales : ((list<Sales__c>)Trigger.new)) { 
            Sales__c oldSales = (Sales__c)Trigger.oldMap.get(sales.Id);
            if(sales.Sales__c!=oldSales.Sales__c){
                acccountIdSet.add(sales.Customer__c);
            }
        }

        Set<String> deleteSalesIdSet = new Set<String>();
        Map<String,Integer> salesCountMap = getCustomerSalesCount(acccountIdSet);              
        for(Sales__c sales : ((list<Sales__c>)Trigger.new)){           
            Sales__c oldSales = (Sales__c)Trigger.oldMap.get(sales.Id);
            System.debug('New Sales Id :'+sales.Sales__c);
            System.debug('Old Sales Id :'+oldSales.Sales__c);
            System.debug('CON Id:'+String.valueOf(oldSales.Customer__c)+String.valueOf(oldSales.Sales__c));         
            if(sales.Sales__c!=oldSales.Sales__c){                
                if(salesCountMap.get(String.valueOf(oldSales.Customer__c)+String.valueOf(oldSales.Sales__c))!=null && salesCountMap.get(String.valueOf(oldSales.Customer__c)+String.valueOf(oldSales.Sales__c))==1 ){
                    deleteSalesIdSet.add(oldSales.Sales__c);
                }   
            }           
        }
        //System.debug('deleteSalesIdSet in before update:'+deleteSalesIdSet);
        List<AccountShare> shareList = [select id,UserOrGroupId,AccountId from AccountShare where UserOrGroupId in: deleteSalesIdSet AND RowCause = 'Manual'];
        Map<String,AccountShare> delShareMap = new Map<String,AccountShare>();
        for (AccountShare accs : shareList) {
            for (Sales__c sales : ((list<Sales__c>)Trigger.new)) {
                Sales__c oldSales = (Sales__c)Trigger.oldMap.get(sales.Id);
                if(accs.AccountId == sales.Customer__c && oldSales.Sales__c!=sales.Sales__c){
                    delShareMap.put(accs.Id,accs);
                }
            }
        }
        //System.debug('delShareMap:'+delShareMap);
        List<AccountShare> delshareList = delShareMap.values();
        if(delshareList.size()>0){
            try{
                delete delshareList;
            }catch(Exception e){
                system.debug('error message'+e.getMessage());
                system.debug('line number'+e.getLineNumber());
            }
        }

        List<AccountShare> insertshareList = new List<AccountShare>();       
        for (Sales__c sales : ((list<Sales__c>)Trigger.new)) {            
            Sales__c oldSales = (Sales__c)Trigger.oldMap.get(sales.Id);
            if(sales.Sales__c!=oldSales.Sales__c){               
                AccountShare accShare = new AccountShare();
                accShare.RowCause = 'Manual';
                accShare.AccountId = sales.Customer__c;
                accShare.UserOrGroupId = sales.Sales__c;
                accShare.AccountAccessLevel = 'Edit';
                accShare.OpportunityAccessLevel = 'Edit';
                insertshareList.add(accShare);               
            } 
        }
        if(insertshareList.size() > 0){
            try{
                insert insertshareList;
            }catch(Exception e){
                system.debug('error message'+e.getMessage());
                system.debug('line number'+e.getLineNumber());
            }
        }                
    }

    public Map<String,Integer> getCustomerSalesCount(Set<String> acccountIdSet){       
        Map<String,Integer> salesCountMap = new Map<String,Integer>();
        List<Sales__c> salesList = [SELECT Id,Customer__c,Product_Line__c,Sales__c FROM Sales__c WHERE Customer__c In :acccountIdSet];
        System.debug('salesList:'+salesList);
        Map<String,List<String>> accSalesMap = new Map<String,List<String>>();
        if(!salesList.isEmpty()){
            for(Sales__c sales : salesList){
                if(accSalesMap.containsKey(sales.Customer__c)){
                    accSalesMap.get(sales.Customer__c).add(sales.Sales__c);
                }else{
                    List<String> tempList = new List<String>();
                    tempList.add(sales.Sales__c);
                    accSalesMap.put(sales.Customer__c,tempList);
                }
            }
            for(String accountId : accSalesMap.keySet()){
                List<String> tempList = accSalesMap.get(accountId);
                if(tempList!=null && !tempList.isEmpty()){                    
                    for(String str : tempList){                    
                        if(salesCountMap.containsKey(accountId+str)){
                            Integer temp = salesCountMap.get(accountId+str);
                            salesCountMap.put(accountId+str,temp+1);
                        }else{
                            salesCountMap.put(accountId+str,1);
                        }
                    }                    
                }
            }
            System.debug('salesCountMap:'+salesCountMap);
        }
        return salesCountMap;
    }

}