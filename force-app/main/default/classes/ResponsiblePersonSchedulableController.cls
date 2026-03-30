/*
 * @Author: WFC
 * @Date: 2025-03-19 15:25:15
 * @LastEditors: WFC
 * @LastEditTime: 2025-03-20 13:32:42
 * @Description: 处理 Responsible person 与 Position 的关系
 ResponsiblePersonSchedulableController cis = new ResponsiblePersonSchedulableController('Hisense USA');
 SchedulableContext sc;
 cis.execute(sc);
 * @FilePath: \hisense005\force-app\main\default\classes\ResponsiblePersonSchedulableController.cls
 */
global class ResponsiblePersonSchedulableController implements Schedulable{
    public String salesRegion;
    global ResponsiblePersonSchedulableController(String salesRegion){
        this.salesRegion = salesRegion;
    }

    global void execute(SchedulableContext SC){
        // 查询所有的门店巡店员关系
        List<Responsible_Person__c> floorwalkerList = [SELECT Id, Shop_Name__c, Principal__c, Principal__r.Username
                                                       FROM Responsible_Person__c
                                                       WHERE Shop_Name__r.Sales_Region__c = :salesRegion AND RecordType__c = '巡店员'];
        // 查询所有的门店促销员关系
        List<Responsible_Person__c> promoterList = [SELECT Id, Shop_Name__c, Principal__c, Principal__r.Username
                                                    FROM Responsible_Person__c
                                                    WHERE Shop_Name__r.Sales_Region__c = :salesRegion AND RecordType__c = '促销员'];
        String salesRegionTemp = salesRegion.replace(' ', '_').replace('.', '').replace('-', '');
        // 查询岗位信息
        String positionSql = 'SELECT Id, DeveloperName__c FROM Position__c WHERE DeveloperName__c LIKE \'' + salesRegionTemp + '_%\'';
        List<Position__c> positionList = Database.query(positionSql);
        // 查询岗位权限信息
        String positionPermissionsSql = 'SELECT Id, External_Key_ID__c FROM Position_Permissions__c ' + 
                                        ' WHERE User__c != null AND Position__r.DeveloperName__c LIKE \'' + salesRegionTemp + '_%\'';
        List<Position_Permissions__c> positionPermissionsList = Database.query(positionPermissionsSql);

        // 对比门店巡店员关系与岗位信息，更新岗位信息
        Map<String, Responsible_Person__c> floorwalkerMap = new Map<String, Responsible_Person__c>();
        Set<String> floorwalkerSet = new Set<String>();
        // 门店下的巡店员 key:门店id
        Map<String, List<Responsible_Person__c>> shopFloorwalkerMap = new Map<String, List<Responsible_Person__c>>();
        for (Responsible_Person__c rp : floorwalkerList){
            List<String> parts = rp.Principal__r.Username.split('@'); // 按 @ 分割
            String key = salesRegionTemp + '_' + parts[0].replace('.', '');
            floorwalkerSet.add(key);
            floorwalkerMap.put(key, rp);

            if (shopFloorwalkerMap.containsKey(rp.Shop_Name__c)){
                shopFloorwalkerMap.get(rp.Shop_Name__c).add(rp);
            } else{
                shopFloorwalkerMap.put(rp.Shop_Name__c, new List<Responsible_Person__c>{ rp });
            }
        }
        // 已存在的岗位
        Map<String, Position__c> positionMap = new Map<String, Position__c>();
        Set<String> positionSet = new Set<String>();
        for (Position__c position : positionList){
            positionSet.add(position.DeveloperName__c);
            positionMap.put(position.DeveloperName__c, position);
        }
        // 仅在 floorwalker 中存在
        Set<String> diffFloorwalker = floorwalkerSet.clone();
        diffFloorwalker.removeAll(positionSet);

        // 仅在 position 中存在
        Set<String> diffPosition = positionSet.clone();
        diffPosition.removeAll(floorwalkerSet);

        Savepoint sp = Database.setSavepoint();
        try{
            // 新增岗位
            List<Position__c> addPositionList = new List<Position__c>();
            for (String key : diffFloorwalker){
                Responsible_Person__c rp = floorwalkerMap.get(key);
                Position__c addPosition = new Position__c();
                addPosition.Grouo_Name__c = key;
                addPosition.DeveloperName__c = key;
                addPosition.DoesIncludeBosses__c = true;
                addPosition.Activity__c = true;

                addPositionList.add(addPosition);
            }
            Database.insert (addPositionList, true);

            // 新增岗位成员
            List<Position_Member__c> addPositionMemberList = new List<Position_Member__c>();
            for (Position__c po : addPositionList){
                Position_Member__c pm = new Position_Member__c();
                pm.Position__c = po.Id;
                pm.User__c = floorwalkerMap.get(po.DeveloperName__c).Principal__c;

                addPositionMemberList.add(pm);
                // 新增的岗位与原有的岗位合并在一起
                positionMap.put(po.DeveloperName__c, po);
            }
            Database.insert (addPositionMemberList, true);

            // 新增岗位权限 Position_Permissions__c
            List<Position_Permissions__c> addPositionPermissionsList = new List<Position_Permissions__c>();
            // 关联巡店员下所有的促销员
            Map<String, List<Responsible_Person__c>> floorwalkerHasPromoterMap = new Map<String, List<Responsible_Person__c>>();
            // 所有的促销员岗位权限
            Set<String> promoterSet = new Set<String>();
            // 所有促销员账户id
            Set<String> promoterIdSet = new Set<String>();
            for (Responsible_Person__c promoter : promoterList){
                // 门店下的巡店员
                List<Responsible_Person__c> shopFList = shopFloorwalkerMap.get(promoter.Shop_Name__c);
                if (shopFList != null && shopFList.size() > 0){
                    for (Responsible_Person__c rp : shopFList){
                        List<String> parts = rp.Principal__r.Username.split('@'); // 按 @ 分割
                        String key = salesRegionTemp + '_' + parts[0].replace('.', '');
                        // 根据巡店员获取岗位 Position__c 信息
                        Position__c position = positionMap.get(key);
                        // 岗位权限
                        Position_Permissions__c pp = new Position_Permissions__c();
                        pp.Position__c = position.Id;
                        pp.User__c = promoter.Principal__c;
                        pp.External_Key_ID__c = pp.User__c + '-' + pp.Position__c;
                        // 存在可能重复的促销员
                        if (!promoterSet.contains(pp.External_Key_ID__c)){
                            addPositionPermissionsList.add(pp);
                            promoterSet.add(pp.External_Key_ID__c);
                        }
                    }
                }
                promoterIdSet.add(promoter.Principal__c);
            }

            // 要删除的岗位权限信息
            List<Position_Permissions__c> delPositionPermissionsList = new List<Position_Permissions__c>();
            for (Position_Permissions__c pp : positionPermissionsList){
                if (!promoterSet.contains(pp.External_Key_ID__c)){
                    delPositionPermissionsList.add(pp);
                }
            }
            Database.delete (delPositionPermissionsList, true);
            Database.upsert (addPositionPermissionsList, Position_Permissions__c.filed.External_Key_ID__c, true);

            // 删除岗位
            List<Position__c> delPositionList = new List<Position__c>();
            for (String key : diffPosition){
                Position__c po = positionMap.get(key);

                delPositionList.add(po);
            }
            Database.delete (delPositionList, true);

            // 删除岗位对应的权限
            ResponsiblePersonShareDelBatch rpsb = new ResponsiblePersonShareDelBatch('Promoter_Attendance__Share');
            Database.executeBatch(rpsb);

            ResponsiblePersonShareDelBatch rpsb1 = new ResponsiblePersonShareDelBatch('Daily_Inspection_Report__Share');
            Database.executeBatch(rpsb1);

            // 执行权限
            if (promoterIdSet != null && promoterIdSet.size() > 0){
                String ownerSql = '';
                for (String str : promoterIdSet){
                    ownerSql += '\'' + str + '\',';
                }
                String sql = 'SELECT IsNew__c,IsChange__c,Owner_Share__c,Shop__c FROM Promoter_Attendance__c WHERE OwnerId IN (' + ownerSql.substring(0, ownerSql.length() - 1) + ')';
                Share_Common_IntegrationBatch OrderShareBatch = new Share_Common_IntegrationBatch('Promoter_Attendance__c', false, '', 0, sql, true);
                Database.executeBatch(OrderShareBatch, 30);

                String sql1 = 'SELECT IsNew__c,IsChange__c,Owner_Share__c,Store__c FROM Daily_Inspection_Report__c WHERE OwnerId IN (' + ownerSql.substring(0, ownerSql.length() - 1) + ')';
                Share_Common_IntegrationBatch OrderShareBatch1 = new Share_Common_IntegrationBatch('Daily_Inspection_Report__c', false, '', 0, sql1, true);
                Database.executeBatch(OrderShareBatch1, 30);
            }

        } catch (Exception e){
            Database.rollback(sp);
            String errorMsg = e.getMessage() + e.getLineNumber();
            Utility.insertBatchLog('ResponsiblePersonSchedulableController', errorMsg + '--' + JSON.serialize(salesRegion));
        }
    }

}