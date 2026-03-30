/**********************************************************************
* 名称: ResponsiblePersonTriggerHandler 
* 功能: 
* 门店负责人trigger
* Author: wfc
* Create Date: 2022-03-02
*************************************************************************/
public without sharing class ResponsiblePersonTriggerHandler implements Triggers.Handler{

    public void handle() {

        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {

            // Principal__c MAP
            Map<String, String> userIdMap = new Map<String, String>();

            // UserEmail__c MAP
            Map<String, String> userEmailMap = new Map<String, String>();

            //ShopMap
            Map<String, String> shopPersonMap = new Map<String, String>();

            //ShopMap
            Map<String, String> personMap = new Map<String, String>();

            Map<Id, Responsible_Person__c> rpOldMap = (Map<Id, Responsible_Person__c>)Trigger.oldMap;
            // 门店巡店员个数统计
            Map<String, List<String>> shopUserMap =  new Map<String, List<String>>();
            for (Responsible_Person__c rp : (List<Responsible_Person__c>)Trigger.new) {

                // 设置数据重复检验 重复的判断标准为门店Id+用户Id为重复值 YYL 20250626
                rp.ExternalId__c = String.valueOf(rp.Shop_Name__c) + rp.Principal__c;

                if (Trigger.isUpdate) {
                    if (rpOldMap.get(rp.Id).Principal__c != rp.Principal__c) {
                        userIdMap.put(rp.Principal__c, '');
                    }else if (rpOldMap.get(rp.Id).UserEmail__c != rp.UserEmail__c) {
                        userEmailMap.put(rp.UserEmail__c, '');
                    }
                }else {
                    if (String.isNotBlank(rp.Principal__c)) {
                        userIdMap.put(rp.Principal__c, '');
                    }else if(String.isNotBlank(rp.UserEmail__c)) {
                        userEmailMap.put(rp.UserEmail__c, '');
                    }
                }
                shopPersonMap.put(rp.Shop_Name__c, '');
                personMap.put(rp.Principal__c, '');
            }

            if (!shopPersonMap.isEmpty()) {

                shopUserMap = matchShopTourPerson(shopPersonMap, personMap);
            }

            if (!userIdMap.isEmpty()) {
                List<User> userIdList = [SELECT Email FROM User WHERE Id IN :userIdMap.keySet()];
                for (User us : userIdList) {
                    userIdMap.put(us.Id, us.Email);
                }
            }

            if (!userEmailMap.isEmpty()) {
                List<User> userIdList = [SELECT Email 
                                         FROM User 
                                         WHERE Email IN :userEmailMap.keySet() 
                                         AND IsActive = true];
                for (User us : userIdList) {
                    userEmailMap.put(us.Email, us.Id);
                }
            }

            for (Responsible_Person__c rp : (List<Responsible_Person__c>)Trigger.new) {

                String userId = rp.Principal__c;
                if (Trigger.isUpdate) {
                    if (rpOldMap.get(rp.Id).Principal__c != rp.Principal__c) {
                        if (String.isNotBlank(rp.Principal__c) 
                            && userIdMap.containsKey(rp.Principal__c) 
                            && userIdMap.get(rp.Principal__c) != '') {
                            rp.UserEmail__c = userIdMap.get(rp.Principal__c);
                            // continue;
                        }
                    }else if (rpOldMap.get(rp.Id).UserEmail__c != rp.UserEmail__c) {
                        System.debug(LoggingLevel.INFO, '*** userEmailMap: ' + userEmailMap);
                        if (String.isNotBlank(rp.UserEmail__c) 
                            && userEmailMap.containsKey(rp.UserEmail__c) 
                            && userEmailMap.get(rp.UserEmail__c) != '') {
                            rp.Principal__c = userEmailMap.get(rp.UserEmail__c);
                            userId = userEmailMap.get(rp.UserEmail__c);
                        }else {
                            rp.addError(System.Label.NOT_FIND_THIS_USER);
                        }
                    }
                    // 修改负责人类型 变为巡店员
                    // if(rpOldMap.get(rp.Id).RecordType__c != rp.RecordType__c && '巡店员'.equals(rp.RecordType__c)){
                    //     if(shopUserMap.containsKey(rp.Shop_Name__c)){
                    //         rp.addError(System.Label.Store_patrol_already_exists);
                    //     }
                    // }

                    
                }else {
                    if (String.isNotBlank(rp.Principal__c)) {
                        if (String.isNotBlank(rp.Principal__c) 
                            && userIdMap.containsKey(rp.Principal__c) 
                            && userIdMap.get(rp.Principal__c) != '') {
                            rp.UserEmail__c = userIdMap.get(rp.Principal__c);
                            // continue;
                        }
                    }else if(String.isNotBlank(rp.UserEmail__c)) {
                        if (String.isNotBlank(rp.UserEmail__c) 
                            && userEmailMap.containsKey(rp.UserEmail__c) 
                            && userEmailMap.get(rp.UserEmail__c) != '') {
                            rp.Principal__c = userEmailMap.get(rp.UserEmail__c);
                            userId = userEmailMap.get(rp.UserEmail__c);
                        }else {
                            rp.addError(System.Label.NOT_FIND_THIS_USER);
                        }
                    }

                    // 新建是查看是否存在门店巡店员
                    // if(shopUserMap.containsKey(rp.Shop_Name__c) && rp.RecordType__c == '巡店员'){
                    //     rp.addError(System.Label.Store_patrol_already_exists);
                    // }
                }

                // rp.SAPExternal__c = rp.Shop_Name__c + '-' + userId;

                // if ('巡店员'.equals(rp.RecordType__c) && shopUserMap.containsKey(rp.Shop_Name__c)) {
                //     if (shopUserMap.get(rp.Shop_Name__c).size() > 0) {
                //         List<String> shopPersonList = shopUserMap.get(rp.Shop_Name__c);
                //         if (shopUserMap.get(rp.Shop_Name__c).size() == 1 && (shopPersonList.contains(userEmailMap.get(rp.UserEmail__c)) || shopPersonList.contains(rp.Principal__c))) {
                //             continue;
                //         }else {
                //             rp.addError(System.Label.Store_patrol_already_exists);
                //         }
                //     }
                // }
            }
        }

        if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {

            Map<String, String> shopIdMap = new Map<String, String>();
            Map<String, String> shopOwenrMap = new Map<String, String>();
            // 门店巡店员个数统计
            Map<Id, Integer> shopUserMap =  new Map<Id, Integer>();
            
            for (Responsible_Person__c rp : (List<Responsible_Person__c>)Trigger.new) {

                shopIdMap.put(rp.Shop_Name__c, '');
            }
           
            // 门店owner
            List<Shop__c> shopList = [SELECT OwnerId, Sales_Region__c FROM Shop__c WHERE Id in :shopIdMap.keySet()];
            
            // added by Sunny Zeng 2023/09/13
            Map<String, Shop__c> storeMap = new Map<String, Shop__c>(shopList);

            for(Shop__c shop : shopList){
                shopOwenrMap.put(shop.OwnerId, shop.OwnerId);
            }    
            
            if (!shopIdMap.isEmpty()) {
                List<AggregateResult> shopUserList = [SELECT Shop_Name__c,count(id) userNum FROM Responsible_Person__c WHERE RecordType__c='巡店员' AND Shop_Name__c IN:shopIdMap.keySet() GROUP BY Shop_Name__c];
                for (AggregateResult ar : shopUserList) {
                    shopUserMap.put(Id.valueOf(String.valueOf(ar.get('Shop_Name__c'))), Integer.valueOf(ar.get('userNum')));
                }
            }

            List<Shop__Share> addShopShareList = new List<Shop__Share>();
            List<Shop__c> updateShopList = new List<Shop__c>();
            Map<String, Shop__c> shopMap = new Map<String, Shop__c>();
            
            Map<Id, Responsible_Person__c> rpOldMap = (Map<Id, Responsible_Person__c>)Trigger.oldMap;
            for (Responsible_Person__c rp : (List<Responsible_Person__c>)Trigger.new) {
                if(!shopOwenrMap.containsKey(rp.Principal__c)){
                    // 门店负责人权限增加人员共享门店
                    Shop__Share shopShare = new Shop__Share();
                    shopShare.RowCause = Schema.Shop__Share.RowCause.Shop_Manager__c;
                    shopShare.ParentId = rp.Shop_Name__c;
                    if(rp.Principal__c != null){
                        shopShare.UserOrGroupId  = rp.Principal__c;
                        shopShare.AccessLevel = 'Read';

                        // modified by Sunny Zeng 2023/09/13
                        System.debug('added by Sunny ——> rp.RecordType__c：' + rp.RecordType__c);
                        if(('巡店员'.equals(rp.RecordType__c)) && ((storeMap.containsKey(rp.Shop_Name__c)) && (storeMap.get(rp.Shop_Name__c).Sales_Region__c == 'Hisense Chile'))) {
                            shopShare.AccessLevel = 'Edit';
                            System.debug('added by Sunny ——> chile floorwalker');
                        }

                        addShopShareList.add(shopShare);
                    }   

                }
                // 添加或者修改类型为巡店员 则给门店巡店员字段赋值
                if('巡店员'.equals(rp.RecordType__c)){
                    Shop__c shop = new Shop__c();
                    shop.id = rp.Shop_Name__c;
                    shop.Responsible_Person__c = rp.Principal__c;
                    shopMap.put(rp.Shop_Name__c, shop);
                    //updateShopList.add(shop);
                }
                // 修改从巡店员修改成其他
                if(Trigger.isUpdate && !'巡店员'.equals(rp.RecordType__c) && '巡店员'.equals(rpOldMap.get(rp.Id).RecordType__c)){
                    Shop__c shop = new Shop__c();
                    shop.id = rp.Shop_Name__c;
                    shop.Responsible_Person__c = null;
                    shopMap.put(rp.Shop_Name__c, shop);
                    //updateShopList.add(shop);
                }
            }

            Database.upsert(addShopShareList);

            if(shopMap.size() > 0){
                for(Shop__c shop : shopMap.values()){
                    updateShopList.add(shop);
                }
                //忽略触发器更新
                GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'ResponsiblePersonTriggerHandler');
                UPDATE updateShopList;
                
                //恢复触发器
                Utility.IgnoreAction(false,false,false,'');
            }  
        }

        if (Trigger.isAfter && Trigger.isUpdate) {

            // 删除修改前的负责人权限
            Map<String, String> userIdMap = new Map<String, String>();
            Map<String, Shop__Share> shopShareMap = new Map<String, Shop__Share>();
            for (Responsible_Person__c rpOld : (List<Responsible_Person__c>)Trigger.old) {
                userIdMap.put(rpOld.Principal__c, '');
            }

            // 所有人员的共享门店
            String rowCause = Schema.Shop__Share.RowCause.Shop_Manager__c;
            List<Shop__Share> shopShareList = [SELECT id,UserOrGroupId,ParentId FROM Shop__Share 
                                                WHERE UserOrGroupId = :userIdMap.keySet()
                                                AND RowCause = :rowCause];

            for(Shop__Share shopShare : shopShareList){
                shopShareMap.put(String.valueOf(shopShare.ParentId) + String.valueOf(shopShare.UserOrGroupId), shopShare);
            }                                   
            List<Shop__Share> delShopShareList = new List<Shop__Share>();
            for (Responsible_Person__c rp : (List<Responsible_Person__c>)Trigger.new) {
                Responsible_Person__c rpOld = (Responsible_Person__c)Trigger.oldMap.get(rp.Id);
                if(!rp.Principal__c.equals(rpOld.Principal__c)){

                    if(shopShareMap.get(String.valueOf(rpOld.Shop_Name__c) + String.valueOf(rpOld.Principal__c)) != null){
                        delShopShareList.add(shopShareMap.get(String.valueOf(rpOld.Shop_Name__c) + String.valueOf(rpOld.Principal__c)));   
                    }
                   
                }
            }
            
            Database.delete(delShopShareList);

        }


        if (Trigger.isAfter && Trigger.isDelete) {

            // 删除权限
            Map<String, String> userIdMap = new Map<String, String>();
            Map<String, Shop__Share> shopShareMap = new Map<String, Shop__Share>();
            for (Responsible_Person__c rpOld : (List<Responsible_Person__c>)Trigger.old) {
                userIdMap.put(rpOld.Principal__c, '');
            }

            // 所有人员的共享门店
            String rowCause = Schema.Shop__Share.RowCause.Shop_Manager__c;
            List<Shop__Share> shopShareList = [SELECT id,UserOrGroupId,ParentId FROM Shop__Share 
                                                WHERE UserOrGroupId = :userIdMap.keySet()
                                                AND RowCause = :rowCause];

            for(Shop__Share shopShare : shopShareList){
                shopShareMap.put(String.valueOf(shopShare.ParentId) + String.valueOf(shopShare.UserOrGroupId), shopShare);
            }                                   
            List<Shop__Share> delShopShareList = new List<Shop__Share>();
            List<Shop__c> updateShopList = new List<Shop__c>();
            Set<String> updateShopSet = new Set<String>();
            for (Responsible_Person__c rpOld : (List<Responsible_Person__c>)Trigger.old) {
                if(shopShareMap.get(String.valueOf(rpOld.Shop_Name__c) + String.valueOf(rpOld.Principal__c)) != null){
                    delShopShareList.add(shopShareMap.get(String.valueOf(rpOld.Shop_Name__c) + String.valueOf(rpOld.Principal__c)));   
                }
                if('巡店员'.equals(rpOld.RecordType__c)){
                    if(updateShopSet.add(rpOld.Shop_Name__c)){
                        Shop__c shop = new Shop__c();
                        shop.id = rpOld.Shop_Name__c;
                        shop.Responsible_Person__c = null;
                        updateShopList.add(shop);
                    }
                } 
            }
            
            Database.delete(delShopShareList);

            //忽略触发器更新
            GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'ResponsiblePersonTriggerHandler');
            UPDATE updateShopList;
            
            //恢复触发器
            Utility.IgnoreAction(false,false,false,'');
        }
    }

    public static Map<String, List<String>> matchShopTourPerson(Map<String, String> shopPersonMap, Map<String, String> personMap){
    Map<String, List<String>> shopPrincipalMap = new Map<String, List<String>>();
        for (Responsible_Person__c resPer : [SELECT Shop_Name__c,
                                                    Principal__c
                                            FROM Responsible_Person__c 
                                            WHERE RecordType__c = '巡店员' 
                                            AND (Shop_Name__c IN :shopPersonMap.keySet()
                                            OR Principal__c IN :personMap.keySet())]) {
            if (shopPrincipalMap.containsKey(resPer.Shop_Name__c)) {
                shopPrincipalMap.get(resPer.Shop_Name__c).add(resPer.Principal__c);
            }else {
                shopPrincipalMap.put(resPer.Shop_Name__c, new List<String>{resPer.Principal__c});
            }
        }


        return shopPrincipalMap;
    }
}