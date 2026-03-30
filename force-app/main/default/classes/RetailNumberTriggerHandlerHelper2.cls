public class RetailNumberTriggerHandlerHelper2 {
	
    /**
     * @description 同步数据字段
     * @param       newList     更改后数据
     * @param       oldList     更改前数据
     */
    public static void dailySalesfieldUpdate(List<Retail_Number__c> oldList, List<Retail_Number__c> newList){
        List<Responsible_Person__c> lrp = [select Shop_Name__c,Shop_Name__r.Name, Principal__c,Principal__r.Name,UserEmail__c from Responsible_Person__c where RecordType__c = '促销员'];
        Map<String, Responsible_Person__c> lrpMap = new Map<String, Responsible_Person__c>();
        for(Responsible_Person__c rp : lrp){
            lrpMap.put(rp.Shop_Name__c + '' + rp.Principal__c, rp);
        }
        for(Retail_Number__c rn : newList){
            if (rn.ResponsiblePerson__c == null && lrpMap.containsKey(rn.Shop__c + '' + rn.OwnerId__c)) {
                rn.ResponsiblePerson__c = lrpMap.get(rn.Shop__c + '' + rn.OwnerId__c).Id;
            }
        }
    }
}