/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-18-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public withOut sharing class Share_Common_IntegrationService {

    // @future(callout=true)
    // private static void AsyncShareData(String objectApiName, String jsonData) {
    //     shareData(objectApiName, jsonData);
    // }
    
    public static void shareData(String objectApiName, String jsonData, String positionId, Boolean isNeedChange) {
        System.debug(LoggingLevel.INFO, '*** CallTime: ' + System.now().format('HH mm ss ms'));
        System.debug(LoggingLevel.INFO, '*** jsonData: ' + JSON.serialize(jsonData));
        
        //共享关系UPSERT列表
        List<Share_Relationship_Item__c> dmlSriList = new List<Share_Relationship_Item__c>();
        
        //根据 objectApiName 查询共享对象(Share_Object__c)以及 Share_Relation_Object__c
        List<Share_Object__c> soList = queryShareObject(objectApiName);

        if (soList.isEmpty()) {
            return;
        }

        Share_Object__c shareObj = soList[0];
        

        //共享对象的数据反序列化, 存在共享关系对象,查找共享关系对象数据
        List<Object> shareDataList = (List<Object>)JSON.deserializeUntyped(jsonData);
        

        /***************************************Start****************************************************
         * 数据更新前,检查当前关系对象数据,是否存在共享关系对象, 若存在关系对象, 需查询共享关系记录,并记录共享关系行
         * 有共享关系对象, 当前共享数据关系对象无共享关系记录, 添加新的共享关系记录,并添加行
         * 存在共享关系对象, 有共享关系记录, 添加新的行记录
         */
    
        //共享数据父Id与子ID
        Map<String, List<String>> shareDataIdMap = new Map<String, List<String>>();

        //判断数据中是否存在更新维度的数据, 存在change的数据有共享关系对象,记录共享关系
        Map<String, List<String>> checkShareDataIdMap = new Map<String, List<String>>();

        //要删除的共享关系记录
        List<String> deleteSriList = new List<String>();

        //要删除的共享对象__Share数据
        Set<String> changeIdSet = new Set<String>();

        //Share history record
        List<Share_History__c> upsertShList = new List<Share_History__c>();

        if(!shareObj.Share_Object_Relation__r.isEmpty() && !shareObj.IsRelyThisShare__c){
            for(Share_Relation_Object__c sro : shareObj.Share_Object_Relation__r) {
                system.debug('wwwww----sro--' + sro);
                for (Object obj : shareDataList) {
                    Map<String, Object> parsedMap = (Map<String, Object>)obj;
                    system.debug('wwwww----obj--'  + obj);
                    system.debug('wwwww----Object_Lookup_API__c---'  + sro.Object_Lookup_API__c);
                    system.debug('wwwww----parsedMap--'  + parsedMap);
                    system.debug('wwwww----'  + parsedMap.values());
                    String ShareItemId = String.valueOf(parsedMap.get('Id'));
                    String ShareRelationshipID = String.valueOf(parsedMap.get(sro.Object_Lookup_API__c));
                    system.debug('wwwww----ShareRelationshipID---'  + ShareRelationshipID);
                    if (String.isBlank(ShareRelationshipID)) {
                        continue;
                    }
                    if (shareDataIdMap.containsKey(ShareRelationshipID)) {
                        shareDataIdMap.get(ShareRelationshipID).add(ShareItemId);
                    }else {
                        shareDataIdMap.put(ShareRelationshipID, new List<String>{ShareItemId});
                    }

                    Boolean isChange = Boolean.valueOf(parsedMap.get('IsChange__c'));
                    if (isChange || isNeedChange) {
                        if (checkShareDataIdMap.containsKey(ShareRelationshipID)) {
                            checkShareDataIdMap.get(ShareRelationshipID).add(ShareItemId);
                        }else {
                            checkShareDataIdMap.put(ShareRelationshipID, new List<String>{ShareItemId});
                        }

                        String externalKeyID = ShareRelationshipID + '-' + ShareItemId;
                        deleteSriList.add(externalKeyID);
                        changeIdSet.add(ShareItemId);
                    }
                }
            }
            //  Map<String, List<Share_Relationship_Item__c>> chenkShareRelationshipMap = Share_Common_IntegrationTDGW.checkShareRelationshipMap(shareDataIdMap);
        }
        //***************************************END******************************************************

        //删除改变维度的数据共享
        Share_Common_IntegrationTDGW.deleteChangeDataShare(shareObj, checkShareDataIdMap, shareDataList, deleteSriList, changeIdSet);

        //共享关系对象的Id集合
        Set<String> shareRecordIdSet = new Set<String>();

        //最终要共享的数据的Id集合
        Set<String> shareLastRecordIdSet = new Set<String>();

        //根据当前数据的情况查询可以共享的岗位,进行分组;
        Map<String, List<Object>> positionInfoObjMap = new Map<String, List<Object>>();
        if (String.isBlank(positionId)) {
            positionInfoObjMap = searchJobs(shareObj, shareDataList);
        }else {
            positionInfoObjMap.put(positionId, shareDataList);
        } 

        //共享对象总块
        List<SObject> shareInfoSObjectList = new List<SObject>();

        //分块Set
        List<String> chunkList = shareObj.Share_Chunk__c.split(',');

        System.debug(LoggingLevel.INFO, '共享岗位数' + positionInfoObjMap.size());
        System.debug(LoggingLevel.INFO, '共享数据量' + shareDataList.size());
        System.debug(LoggingLevel.INFO, '共享数据positionInfoObjMap' + JSON.serialize(positionInfoObjMap));

        //检查关系对象共享是否存在重复
        Map<String, String> repeatCheckMap = new Map<String, String>();

        for (String position : positionInfoObjMap.keySet()) {
            List<Object> infoObjList = positionInfoObjMap.get(position);

            for (Object obj : positionInfoObjMap.get(position)) {
                Map<String, Object> parsedMap = (Map<String, Object>)obj;

                //共享对象的共享数据
                if(!shareObj.IsRelyThisShare__c) {
                    SObject shareMainObject = (SObject)Type.forName(shareObj.Object_Share__c).newInstance();

                    if (shareObj.Object_Share__c == 'AccountShare') {
                        shareMainObject.put('AccountId', String.valueOf(parsedMap.get('Id')));
                        shareMainObject.put('UserOrGroupId', position);
                        shareMainObject.put('AccountAccessLevel', 'Read');
                        shareMainObject.put('OpportunityAccessLevel', 'Read');
                        shareMainObject.put('CaseAccessLevel','Read');
                    }else {
                        shareMainObject.put(shareObj.Share_Type__c, String.valueOf(parsedMap.get('Id')));
                        shareMainObject.put('AccessLevel', 'Read');
                        shareMainObject.put('UserOrGroupId', position);
                        shareMainObject.put('RowCause', shareObj.Share_RowCause__c);
                    }
                    System.debug('wwwwwwwzzzzzz---shareMainObject---' + shareMainObject);
                    shareInfoSObjectList.add(shareMainObject);
                }

                //共享关系对象的共享数据
                for (Share_Relation_Object__c sro : shareObj.Share_Object_Relation__r) {
                    System.debug('wwwwfff-----' + sro);
                    System.debug('wwwwfff-----' + JSON.serialize(parsedMap));
                    if (repeatCheckMap.containsKey(position + String.valueOf(parsedMap.get(sro.Object_Lookup_API__c)))) {
                        continue;
                    }
                    SObject shareItemObject = (SObject)Type.forName(sro.Object_Share__c).newInstance();
                    System.debug('wwwwjjjj-----' + String.valueOf(parsedMap.get(sro.Object_Lookup_API__c)));
                    System.debug('wwwwjjjj-----' + JSON.serialize(sro.Object_Lookup_API__c));
                    shareItemObject.put(sro.Share_Type__c, String.valueOf(parsedMap.get(sro.Object_Lookup_API__c)));
                    repeatCheckMap.put(position + String.valueOf(parsedMap.get(sro.Object_Lookup_API__c)), String.valueOf(parsedMap.get(sro.Object_Lookup_API__c)));
                    shareItemObject.put('AccessLevel', 'Read');
                    shareItemObject.put('UserOrGroupId', position);
                    shareItemObject.put('RowCause', sro.Share_RowCause__c);
                    System.debug('wwwwwwwzzzzzz---shareItemObject---' + shareItemObject);
                    shareInfoSObjectList.add(shareItemObject);
                }
            }
        }

        System.debug(LoggingLevel.INFO, '*** shareInfoSObjectList: ' + shareInfoSObjectList);
        System.debug(LoggingLevel.INFO, '共享数据大小' + shareInfoSObjectList.size());

        if (!shareInfoSObjectList.isEmpty()) {
            // System.debug(LoggingLevel.INFO, '*** dmlShareInfoSObjectList: ' + dmlShareInfoSObjectList);

            // 尝试分块仍然报错 因为SF报错内容错误(Cannot have more than 10 chunks in a single operation. Please rearrange the data to reduce chunking),
            // 实际错误为 > 2000 条记录和 > 1 个 sobject 类型
            // List<SObject> dmlShareInfoSObjectList = sortChunks(shareInfoSObjectList);
            System.debug(LoggingLevel.INFO, '*** chunkList: ' + chunkList);
            for (String strObjectName : chunkList) {
                List<SObject> dmlShareInfoSObjectList = new List<SObject>();
                for (SObject sis : shareInfoSObjectList) {
                    if (strObjectName == String.valueOf(sis.getSObjectType()) ) {
                        dmlShareInfoSObjectList.add(sis);
                    }
                }
                if (!dmlShareInfoSObjectList.isEmpty()) {
                    System.debug(LoggingLevel.INFO, '*** dmlShareInfoSObjectList: ' + dmlShareInfoSObjectList);
                    List<Database.UpsertResult> infoDmlList = Database.Upsert(dmlShareInfoSObjectList, false);
                    system.debug(infoDmlList);
                    Map<String, List<String>> shareErrorMap = new Map<String, List<String>>();
                    Map<String, String> shareErrorCauseMap = new Map<String, String>();
                    for (Integer i = 0; i < infoDmlList.size(); i++ ) {
                        Database.UpsertResult sr = infoDmlList.get(i);
                        if (!sr.isSuccess()) {
                            String errorMsg;
                            for (Database.Error err : sr.getErrors()) {
                                errorMsg = err.getMessage();
                                System.debug(LoggingLevel.INFO, '*** : 共享发生错误原因' + err.getMessage());
                                System.debug(LoggingLevel.INFO, '*** 错误的数据: ' + dmlShareInfoSObjectList[i].get('ParentId'));
                                System.debug(LoggingLevel.INFO, '*** 错误的岗位小组Id: ' + dmlShareInfoSObjectList[i].get('UserOrGroupId'));
                                System.debug(LoggingLevel.INFO, '*** 错误的共享对象 ' + strObjectName);
                            }

                            if (errorMsg != 'unable to obtain exclusive access to this record') {
                                //共享失败错误记录
                                String groupId = String.valueOf(dmlShareInfoSObjectList[i].get('UserOrGroupId'));
                                String parentId;
                                if (strObjectName == 'AccountShare') {
                                    parentId = String.valueOf(dmlShareInfoSObjectList[i].get('AccountId'));
                                }else {
                                    parentId = String.valueOf(dmlShareInfoSObjectList[i].get('ParentId'));
                                }

                                if (String.isNotBlank(parentId)) {
                                    if (shareErrorMap.containsKey(groupId)) {
                                        shareErrorMap.get(groupId).add(parentId);
                                    }else {
                                        shareErrorMap.put(groupId, new List<String>{parentId});
                                    }
    
                                    shareErrorCauseMap.put(parentId, errorMsg);
                                }
                            }else {

                                //发生错误的数据,从shareDataIdMap移除该数据
                                if (strObjectName == objectApiName) {
                                    List<String> shareRelatDataIdMapKeySet = (List<String>)JSON.deserializeUntyped(JSON.serialize(shareDataIdMap.keySet()));
                                    for (Integer k = 0; k < shareRelatDataIdMapKeySet.size(); k++) {
                                        List<String> shareDataIdMapKeySet = shareDataIdMap.get(shareRelatDataIdMapKeySet[k]);
                                        for (Integer j = 0; j < shareDataIdMapKeySet.size(); j++) {
                                            if(shareDataIdMapKeySet[j] == dmlShareInfoSObjectList[i].get(shareObj.Share_Type__c)) {
                                                shareDataIdMap.get(shareDataIdMapKeySet[j]).remove(j);
                                                j--;
                                            }
                                        }
                                    }
                                }else {
                                    if (shareDataIdMap.containsKey(String.valueOf(dmlShareInfoSObjectList[i].get(shareObj.Share_Type__c)))) {
                                        shareDataIdMap.remove(String.valueOf(dmlShareInfoSObjectList[i].get(shareObj.Share_Type__c)));
                                    }
                                }
                            }
                        }else {
                            if (String.isNotBlank(positionId)) {

                                //Share history record
                                Share_History__c sh = new Share_History__c();
                                sh.GroupId__c = positionId;
                                sh.Share_ID__c = sr.getId();
                                sh.Is_New_Share__c = true;
                                upsertShList.add(sh);
                            }
                        }
                    }

                    if (!shareErrorMap.isEmpty()) {
                        Share_Common_IntegrationTDGW.writeShareLogs(strObjectName, shareErrorMap, shareErrorCauseMap);
                    }
                }
            }
            System.debug(LoggingLevel.INFO, '*** shareDataIdMap: ' + shareDataIdMap);
            if (!shareDataIdMap.isEmpty()) {
                for (String strKey : shareDataIdMap.keySet()) {
                    for (String stritemKey : shareDataIdMap.get(strKey)) {
                        Share_Relationship_Item__c sri = new Share_Relationship_Item__c();
                        sri.ShareItemId__c = stritemKey;
                        sri.Share_Relationship_ID__c = strKey;
                        sri.External_Key_ID__c = strKey + '-' + stritemKey;
                        dmlSriList.add(sri);
                    }
                }
                List<Database.UpsertResult> infoDmlList = Database.Upsert(dmlSriList, Share_Relationship_Item__c.External_Key_ID__c);
            }

            System.debug(LoggingLevel.INFO, '*** upsertShList: ' + upsertShList);
            System.debug(LoggingLevel.INFO, '*** upsertShList.size(): ' + upsertShList.size());
            if (!upsertShList.isEmpty()) {
                Database.Upsert(upsertShList, Share_History__c.Share_ID__c);
            }

            System.debug(LoggingLevel.INFO, '*** EndTime: ' + System.now().format('HH mm ss ms'));
        }
    }

    private static Map<String, List<Object>> searchJobs(Share_Object__c shareObj, List<Object> shareDataList){

        Set<String> griddingIdSet = new Set<String>();
        Set<String> accountIdSet = new Set<String>();
        Set<String> accProductLineIdSet = new Set<String>();
        Set<String> shopIdSet = new Set<String>();
        Set<String> ownerSet = new Set<String>(); // wfc

        Boolean isGridding = false;
        Boolean isAccount = false;
        Boolean isAccProductLine = false;
        Boolean isShop = false;
        Boolean isOwner = false; // wfc

        //岗位数据分配
        Map<String, List<Object>> positionInfoObjMap = new Map<String, List<Object>>();

        //组装查询List
        List<String> queryConditionsList = new List<String>();
        
        for (Object obj : shareDataList) {
            Map<String, Object> parsedMap = (Map<String, Object>)obj;
            if (String.isNotBlank(shareObj.Gridding_Filed_API__c)) {
                isGridding = true;
                griddingIdSet.add(String.valueOf(parsedMap.get(shareObj.Gridding_Filed_API__c)));
            }
            if (String.isNotBlank(shareObj.Account_API__c)) {
                isAccount = true;
                accountIdSet.add(String.valueOf(parsedMap.get(shareObj.Account_API__c)));
            }
            if (String.isNotBlank(shareObj.Account_Product_Line__c)) {
                isAccProductLine = true;
                accProductLineIdSet.add(String.valueOf(parsedMap.get(shareObj.Account_Product_Line__c)));
            }
            if (String.isNotBlank(shareObj.Shop_Filed_API__c)) {
                isShop = true;
                shopIdSet.add(String.valueOf(parsedMap.get(shareObj.Shop_Filed_API__c)));
            }
            // wfc
            if (String.isNotBlank(shareObj.Owner_Filed_API__c)) {
                isOwner = true;
                ownerSet.add(String.valueOf(parsedMap.get(shareObj.Owner_Filed_API__c)));
            }

        }
        System.debug('wwwwwwffff----shareObj---' + shareObj);
        if (!griddingIdSet.isEmpty()) {
            queryConditionsList.add('Gridding_External_Key__c IN :griddingIdSet');
        }
        if (!accountIdSet.isEmpty()) {
            queryConditionsList.add('Account_External_Key__c IN :accountIdSet');
        }
        if (!accProductLineIdSet.isEmpty()) {
            queryConditionsList.add('Account_Product_Line_Key__c IN :accProductLineIdSet');
        }
        if (!shopIdSet.isEmpty()) {
            queryConditionsList.add('Shop_External_Key__c IN :shopIdSet');
        }
        // wfc
        if (!ownerSet.isEmpty()) {
            queryConditionsList.add('Owner_External_Key__c IN :ownerSet');
        }
        // wfc
        String queryPosp ='SELECT Position__r.GroupId__c,Position__r.Activity__c,Gridding_External_Key__c,Account_External_Key__c,Account_Product_Line_Key__c,Shop_External_Key__c,Owner_External_Key__c';
        queryPosp += ' FROM Position_Permissions__c WHERE Position__r.Activity__c = true AND (';
        String queryWhereCondition = queryPosp + String.join(queryConditionsList, ' OR ') + ')';

        //岗位查询,初步过滤
        List<Position_Permissions__c> posList = Database.query(queryWhereCondition);
        System.debug('wwwwwwffff-------' + queryWhereCondition);
        System.debug('wwwwwwffff-------' + ownerSet);
        System.debug('wwwwwwffff-------' + posList);
        Map<String, List<Position_Permissions__c>> posPerListMap = new Map<String, List<Position_Permissions__c>>();
        for (Position_Permissions__c posper : Database.query(queryWhereCondition)) {
            if (posPerListMap.containsKey(posper.Position__r.GroupId__c) && !posPerListMap.get(posper.Position__r.GroupId__c).isEmpty()) {
                posPerListMap.get(posper.Position__r.GroupId__c).add(posper);
            } else {
                posPerListMap.put(posper.Position__r.GroupId__c, new List<Position_Permissions__c>{posper});
            }
        }

        System.debug(LoggingLevel.INFO, '*** posPerListMap.size(): ' + posPerListMap.size());
        for (String pos : posPerListMap.keySet()) {
            //符合当前岗位标准的数据
            List<Object> matchPositionDataList = new List<Object>();
            for (Object obj : shareDataList) {
                Map<String, Object> parsedMap = (Map<String, Object>)obj;

                //该数据是否满足该岗位维度
                Boolean isGriddingMatch = false;
                Boolean isAccountMatch = false;
                Boolean isAccProductLineMatch = false;
                Boolean isShopMatch = false;
                Boolean isOwnerMatch = false; // wfc
                for (Position_Permissions__c posp : posPerListMap.get(pos)) {
                    if (isGridding) {
                        if (String.isNotBlank(posp.Gridding_External_Key__c)) {
                            if (String.valueOf(parsedMap.get(shareObj.Gridding_Filed_API__c)) == posp.Gridding_External_Key__c) {
                                isGriddingMatch = true;
                            }
                        }
                    }
                    if (isAccount) {
                        if (String.isNotBlank(posp.Account_External_Key__c)) {
                            if (String.valueOf(parsedMap.get(shareObj.Account_API__c)) == posp.Account_External_Key__c) {
                                isAccountMatch = true;
                            }
                        }
                    }
                    if (isAccProductLine) {
                        if (String.isNotBlank(posp.Account_Product_Line_Key__c)) {
                            if (String.valueOf(parsedMap.get(shareObj.Account_Product_Line__c)) == posp.Account_Product_Line_Key__c) {
                                isAccProductLineMatch = true;
                            }
                        }
                    }
                    if (isShop) {
                        if (String.isNotBlank(posp.Shop_External_Key__c)) {
                            if (String.valueOf(parsedMap.get(shareObj.Shop_Filed_API__c)) == posp.Shop_External_Key__c) {
                                isShopMatch = true;
                            }
                        }
                    }
                    // wfc
                    if (isOwner) {
                        if (String.isNotBlank(posp.Owner_External_Key__c)) {
                            if (String.valueOf(parsedMap.get(shareObj.Owner_Filed_API__c)) == posp.Owner_External_Key__c) {
                                isOwnerMatch = true;
                            }
                        }
                    }
                }

                //如果维度中存在 门店&网格维度, 需要分别满足两种维度进行共享
                if (isGridding && isShop) {
                    if (((isAccount && isAccountMatch) || (!isAccount && !isAccountMatch)) 
                     && ((isAccProductLine && isAccProductLineMatch) || (!isAccProductLine && !isAccProductLineMatch)) 
                     && ((isGridding && isGriddingMatch) || (isShop && isShopMatch))) {
                        matchPositionDataList.add(obj);
                    }
                }else {
                    if ( ((isGridding && isGriddingMatch) || (!isGridding && !isGriddingMatch)) 
                         && ((isAccount && isAccountMatch) || (!isAccount && !isAccountMatch)) 
                         && ((isAccProductLine && isAccProductLineMatch) || (!isAccProductLine && !isAccProductLineMatch)) 
                         && ((isShop && isShopMatch) || (!isShop && !isShopMatch)) 
                         // wfc
                         && ((isOwner && isOwnerMatch) || (!isOwner && !isOwnerMatch))) {
                            matchPositionDataList.add(obj);
                    }
                }
            }

            System.debug(LoggingLevel.INFO, '*** matchPositionDataList: ' + matchPositionDataList);

            if (!matchPositionDataList.isEmpty()) {
                positionInfoObjMap.put(pos, matchPositionDataList);
            }
        }

        return positionInfoObjMap;
    }

    public static void positionFiledChangeCommon(List<SObject> shareList, Map<Id,SObject> shareOldMap, String objectApiName){
        List<Share_Object__c> soList = queryShareObject(objectApiName);

        if (soList.isEmpty()) {
            return;
        }

        Share_Object__c shareObj = soList[0];

        //最终要更新的SObjectList
        List<SObject> dmlSObjectList = new List<SObject>();

        //网格字段API名
        String griddingFiledAPI = shareObj.Gridding_Filed_API__c;

        //客户字段API名
        String accountAPI = shareObj.Account_API__c;

        //客户产品线字段API名
        String accountProductLineAPI = shareObj.Account_Product_Line__c;

        //门店字段API名
        String shopAPI = shareObj.Shop_Filed_API__c;

        //owner字段API名
        String ownerAPI = shareObj.Owner_Filed_API__c;

        for (SObject sob : shareList) {
            Boolean isChange = false;
            SObject oldSob = shareOldMap.get(String.valueOf(sob.get('Id')));
            SObject newRecordSob = (SObject)Type.forName(objectApiName).newInstance();
            if(String.isNotBlank(griddingFiledAPI) && String.valueOf(sob.get(griddingFiledAPI)) != String.valueOf(oldSob.get(griddingFiledAPI))) {
                isChange = true;
            }
            if(String.isNotBlank(accountAPI) && String.valueOf(sob.get(accountAPI)) != String.valueOf(oldSob.get(accountAPI))) {
                isChange = true;
            }
            if(String.isNotBlank(accountProductLineAPI) && String.valueOf(sob.get(accountProductLineAPI)) != String.valueOf(oldSob.get(accountProductLineAPI))) {
                isChange = true;
            }
            if(String.isNotBlank(shopAPI) && String.valueOf(sob.get(shopAPI)) != String.valueOf(oldSob.get(shopAPI))) {
                isChange = true;
            }
            // wfc
            if(String.isNotBlank(ownerAPI) && String.valueOf(sob.get(ownerAPI)) != String.valueOf(oldSob.get(ownerAPI))) {
                isChange = true;
            }

            if(isChange) {
                newRecordSob.put('Id', String.valueOf(sob.get('Id')));
                newRecordSob.put('IsChange__c', true);
                dmlSObjectList.add(newRecordSob);
            }
        }
        if(!dmlSObjectList.isEmpty()){

            //忽略触发器更新
            GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'PositionShareHandler');
            UPDATE dmlSObjectList;
            
            //恢复触发器
            Utility.IgnoreAction(false,false,false,'');
        }
    }

    public static List<Share_Object__c> queryShareObject(String objectApiName){
        List<Share_Object__c> soList = [SELECT Name, 
                                                Object_API__c,
                                                Gridding_Filed_API__c,
                                                Account_API__c,
                                                Account_Product_Line__c,
                                                Object_Share__c,
                                                Share_Type__c,
                                                Share_RowCause__c,
                                                Share_Chunk__c,
                                                Batch_AddMinutes__c,
                                                Query_Statement__c,
                                                IsRelyThisShare__c,
                                                Product_Line_API__c,
                                                Refresh_Query_Statement__c,
                                                Shop_Filed_API__c,
                                                Owner_Filed_API__c, // wfc
                                                (SELECT Name, 
                                                        Relation_Object_API__c, 
                                                        Object_Lookup_API__c, 
                                                        Object_Lookup_Detail_API__c,
                                                        Object_Share__c,
                                                        Share_Type__c,
                                                        Share_RowCause__c
                                                FROM Share_Object_Relation__r)
                                        FROM Share_Object__c
                                        WHERE Object_API__c = :objectApiName];
        return soList;
    }
}