public without sharing class ExhibitionRegionHandlerHelper {
    public static void initUserInfo(List<Exhibition_Region_Owner__c> newList){
    	List<String> emailList = new LisqContainer(newList).SelectSField('Email__c');
        Map<String, String> emailRegMap = new Map<String, String>();
        if (emailList.size() > 0) {
            // Exhibition_Region_Owner__c
            for (User item : [SELECT Id, Email FROM User WHERE Email IN: emailList])
                emailRegMap.put(item.Email, item.Id);
            for (Exhibition_Region_Owner__c itemChange: newList) 
                itemChange.User__c = emailRegMap.get(itemChange.Email__c) == NULL ? NULL : emailRegMap.get(itemChange.Email__c);
        }
    }
}