public with sharing class StoresUnderGridController {
    @AuraEnabled
    public static ConResponse getStoreList(String recordId) {

        System.debug('StoresUnderGridController ——> recordId：' + recordId);

        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();

        List<Gridding__c> allGridList = [SELECT Gridding_Recursion_ID__c, Id, Name, DivisionUnit__c, Gridding_All__c, Gridding_Code__c, Gridding_Level__c, Parent_Gridding__c FROM Gridding__c];
        
        Map<String, LisqContainer> allGridListMap = new Map<String, LisqContainer>();
        LisqContainer lc = new LisqContainer(allGridList);
        allGridListMap = lc.GroupByS('Parent_Gridding__c');

        List<String> gridIdList = new List<String>();
        gridIdList.add(recordId);
        if(allGridListMap.containsKey(recordId)){
            System.debug('StoresUnderGridController ——> allGridListMap.contains：');
            List<Gridding__c> childGridList = allGridListMap.get(recordId).ToSobjectList();
            for(Gridding__c item : childGridList) {
                gridIdList.add(item.Id);
                System.debug('StoresUnderGridController ——> item.Id：' + item.Id);
            }
            
        }


        List<Shop__c> storeList = [SELECT Id, Name, Account__c, Account_Name__c FROM Shop__c WHERE Grid__c IN :gridIdList];
        mso.put('storeList', storeList);

        resp.data = mso;
        return resp;
    }
}