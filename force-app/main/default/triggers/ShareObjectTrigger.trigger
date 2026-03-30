/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 01-26-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
trigger ShareObjectTrigger on Share_Object__c (before insert, before update) {
    List<Share_Object__c> shareList = (List<Share_Object__c>)Trigger.new;

    Map<String, List<String>> shareConditionMap = new Map<String, List<String>>();
    Set<String> soIdSet = new Set<String>();
    Map<String, List<Share_Relation_Object__c>> sroListMap = new Map<String, List<Share_Relation_Object__c>>();
    for (Share_Object__c so : shareList) {
        soIdSet.add(so.Id);
    }

    //查询关系对象
    for (Share_Relation_Object__c sro : [SELECT Object_Lookup_API__c,
                                                Share_Object__c
                                         FROM Share_Relation_Object__c 
                                         WHERE Share_Object__c IN :soIdSet]) {
        if (sroListMap.containsKey(sro.Share_Object__c)) {
            sroListMap.get(sro.Share_Object__c).add(sro);
        }else {
            sroListMap.put(sro.Share_Object__c, new List<Share_Relation_Object__c>{sro});
        }
    }

    for (Share_Object__c so : shareList) {
        List<String> shareConditionList = new List<String>();
        List<String> queryConditionList = new List<String>();
        if (String.isNotBlank(so.Gridding_Filed_API__c)) {
            shareConditionList.add(so.Gridding_Filed_API__c);

            queryConditionList.add(' ' + so.Gridding_Filed_API__c + ' IN :graddingSet ');
        }

        if(String.isNotBlank(so.Account_API__c)) {
            shareConditionList.add(so.Account_API__c);
            queryConditionList.add(' ' + so.Account_API__c + ' IN :accountSet ');
        }

        if (String.isNotBlank(so.Account_Product_Line__c)) {
            shareConditionList.add(so.Account_Product_Line__c);
            queryConditionList.add(' ' + so.Account_Product_Line__c + ' IN :accountProductLineSet ');
        }

        if (String.isNotBlank(so.Shop_Filed_API__c)) {
            shareConditionList.add(so.Shop_Filed_API__c);
            queryConditionList.add(' ' + so.Shop_Filed_API__c + ' IN :shopSet ');
        }
        if (String.isNotBlank(so.Owner_Filed_API__c)) {
            shareConditionList.add(so.Owner_Filed_API__c);
            queryConditionList.add(' ' + so.Owner_Filed_API__c + ' IN :ownerSet ');
        }
        //关系表中的LookUp字段
        if(sroListMap.containsKey(so.Id)){
            for (Share_Relation_Object__c sro : sroListMap.get(so.Id)) {
                shareConditionList.add(sro.Object_Lookup_API__c);
            }
        }

        String queryBasicStatement = 'SELECT IsNew__c,IsChange__c,';
        queryBasicStatement += String.join(shareConditionList, ',') + ' FROM ' + so.Object_API__c + ' WHERE ';
        String queryStatement = queryBasicStatement + ' IsNew__c = true OR IsChange__c = true';

        String refreshQueryStatement = queryBasicStatement + String.join(queryConditionList, 'AND');
        so.Refresh_Query_Statement__c = refreshQueryStatement;
        so.Query_Statement__c = queryStatement;
    }
}