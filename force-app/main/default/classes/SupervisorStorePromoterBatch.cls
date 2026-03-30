/*
 * @Author: WFC
 * @Date: 2025-03-28 15:10:27
 * @LastEditors: WFC
 * @LastEditTime: 2025-04-08 09:04:40
 * @Description: Supervisor & Store & Promoter 每天递增数据
 SupervisorStorePromoterBatch ss  = new SupervisorStorePromoterBatch('Hisense Mexico','2025-03-24');
 Database.executeBatch(ss);
 * @FilePath: \hisense005\force-app\main\default\classes\SupervisorStorePromoterBatch.cls
 */
global class SupervisorStorePromoterBatch implements Database.Batchable<sObject>{
    String supervisorRecordType = Schema.SobjectType.Supervisor_Store__c.getRecordTypeInfosByDeveloperName().get('Supervisor').getRecordTypeId();
    String storeRecordType = Schema.SobjectType.Supervisor_Store__c.getRecordTypeInfosByDeveloperName().get('Store').getRecordTypeId();
    String channelRecordType = Schema.SobjectType.Supervisor_Store__c.getRecordTypeInfosByDeveloperName().get('Channel').getRecordTypeId();
    public Date statisticalDate;
    public String salesRegion;
    public String query;
    global SupervisorStorePromoterBatch(String salesRegion){
        this.salesRegion = salesRegion;
        this.query = 'SELECT Id, Channel_item__c FROM Shop__c WHERE Sales_Region__c = :salesRegion AND Channel_item__c != null';
    }

    global SupervisorStorePromoterBatch(String salesRegion, String statisticalDate){
        this.statisticalDate = Date.valueOf(statisticalDate);
        this.salesRegion = salesRegion;
        this.query = 'SELECT Id,Channel_item__c FROM Shop__c WHERE Sales_Region__c = :salesRegion AND Channel_item__c != null';
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Shop__c> shopList){
        List<Supervisor_Store__c> sspAddList = new List<Supervisor_Store__c>();
        List<Supervisor_Store__c> channelAddList = new List<Supervisor_Store__c>();
        List<Supervisor_Promoter_Attendance__c> spaAddList = new List<Supervisor_Promoter_Attendance__c>();
        // 门店下的巡店员 map
        Map<String, List<Responsible_Person__c>> floorwalkerMap = new Map<String, List<Responsible_Person__c>>();
        // 门店下的促销员 map
        Map<String, List<Responsible_Person__c>> promoterMap = new Map<String, List<Responsible_Person__c>>();
        // Supervisor_Store__c 唯一
        Set<String> supervisorSet = new Set<String>();
        // Supervisor_Promoter_Attendance__c 唯一
        Set<String> promoterSet = new Set<String>();
        // 巡店员对应的 Supervisor_Store__c
        Map<String, Supervisor_Store__c> supervisorMap = new Map<String, Supervisor_Store__c>();
        // Attendance 外键set集合
        Set<String> attendanceKeySet = new Set<String>();
        // Channel 外键set集合
        Set<String> channelSet = new Set<String>();
        // 门店channel与 Supervisor_Store__c 的关系 channel 类型
        Map<String, Supervisor_Store__c> channelMap = new Map<String, Supervisor_Store__c>();
        // 汇总日期
        Date checkDate = Date.today();
        if (statisticalDate != null){
            checkDate = statisticalDate;
        }
        // 门店Id set
        Set<Id> shopId = new Set<Id>();
        for (Shop__c shop : shopList){
            shopId.add(shop.Id);
            // 创建门店类型的 Supervisor_Store__c
            if (channelSet.contains(String.valueOf(checkDate) + '_' + shop.Channel_item__c)){
                continue;
            }
            Supervisor_Store__c ss = new Supervisor_Store__c();
            ss.RecordTypeId = channelRecordType;
            ss.Statistical_Date__c = checkDate;
            ss.Channel_item__c = shop.Channel_item__c;
            ss.Sales_Region__c = salesRegion;
            ss.Key__c = String.valueOf(checkDate) + '_' + shop.Channel_item__c;
            channelAddList.add(ss);

            channelMap.put(shop.Channel_item__c, ss);
            channelSet.add(String.valueOf(checkDate) + '_' + shop.Channel_item__c);
        }

        // 查询门店下的巡店员和促销员
        List<Responsible_Person__c> rpList = [SELECT Id, Shop_Name__c, Shop_Name__r.Channel_item__c, Principal__c, RecordType__c
                                              FROM Responsible_Person__c
                                              WHERE RecordType__c IN ('促销员', '巡店员') AND Shop_Name__c IN:shopId AND Is_Active__c = true AND Principal__c != NULL];
        for (Responsible_Person__c rp : rpList){
            if (rp.RecordType__c == '巡店员'){
                if (floorwalkerMap.containsKey(rp.Shop_Name__c)){
                    floorwalkerMap.get(rp.Shop_Name__c).add(rp);
                } else{
                    floorwalkerMap.put(rp.Shop_Name__c, new List<Responsible_Person__c>{ rp });
                }
                if (supervisorSet.contains(String.valueOf(checkDate) + '_' + rp.Principal__c)){
                    continue;
                }
                // 创建 Supervisor_Store__c
                Supervisor_Store__c ssp = new Supervisor_Store__c();
                ssp.RecordTypeId = supervisorRecordType;
                ssp.Statistical_Date__c = checkDate;
                ssp.Supervisor__c = rp.Principal__c;
                ssp.Sales_Region__c = salesRegion;
                ssp.Key__c = String.valueOf(checkDate) + '_' + rp.Principal__c;
                sspAddList.add(ssp);
                supervisorSet.add(String.valueOf(checkDate) + '_' + rp.Principal__c);
                supervisorMap.put(rp.Principal__c, ssp);

            } else if (rp.RecordType__c == '促销员'){
                if (promoterMap.containsKey(rp.Shop_Name__c)){
                    promoterMap.get(rp.Shop_Name__c).add(rp);
                } else{
                    promoterMap.put(rp.Shop_Name__c, new List<Responsible_Person__c>{ rp });
                }
                attendanceKeySet.add(rp.Principal__c + '_' + String.valueOf(checkDate));
            }
        }

        // 保存 Supervisor_Store__c 表
        Database.upsert (sspAddList, Supervisor_Store__c.field.Key__c, true);
        Database.upsert (channelAddList, Supervisor_Store__c.field.Key__c, true);

        // 促销员考勤 map
        Map<String, Promoter_Attendance__c> promoterAttendanceMap = new Map<String, Promoter_Attendance__c>();
        // 查询促销员考勤表
        List<Promoter_Attendance__c> paList = [SELECT ID, ExternalId__c, OwnerId, Shop__c
                                               FROM Promoter_Attendance__c
                                               WHERE ExternalId__c IN:attendanceKeySet];

        for (Promoter_Attendance__c pa : paList){
            promoterAttendanceMap.put(pa.ExternalId__c, pa);
        }
        for (Responsible_Person__c rp : rpList){
            if (rp.RecordType__c == '促销员'){
                Promoter_Attendance__c pa = promoterAttendanceMap.get(rp.Principal__c + '_' + String.valueOf(checkDate));
                // 根据门店获取巡店员
                List<Responsible_Person__c> floorwalkerList = floorwalkerMap.get(rp.Shop_Name__c);
                if (floorwalkerList != null && floorwalkerList.size() > 0){
                    for (Responsible_Person__c floorwalker : floorwalkerList){
                        // 获取 floorwalker 对应的 Supervisor_Store__c
                        Supervisor_Store__c ss = supervisorMap.get(floorwalker.Principal__c);
                        if (promoterSet.contains(ss.Id + '_' + rp.Principal__c)){
                            continue;
                        }
                        // 创建 Supervisor_Promoter_Attendance__c
                        Supervisor_Promoter_Attendance__c spa = new Supervisor_Promoter_Attendance__c();
                        spa.Supervisor_Store__c = ss.Id;
                        spa.Promoter__c = rp.Principal__c;
                        if (pa != null){
                            spa.Attendance__c = pa.Id;
                        }
                        spa.Statistical_Date__c = checkDate;
                        spa.Sales_Region__c = salesRegion;
                        spa.Key__c = ss.Id + '_' + rp.Principal__c;
                        spaAddList.add(spa);
                        promoterSet.add(ss.Id + '_' + rp.Principal__c);
                    }
                }
                // 创建 store类型的 Supervisor_Promoter_Attendance__c
                Supervisor_Store__c ss = channelMap.get(rp.Shop_Name__r.Channel_item__c);
                if (promoterSet.contains(ss.Id + '_' + rp.Principal__c)){
                    continue;
                }
                Supervisor_Promoter_Attendance__c spa = new Supervisor_Promoter_Attendance__c();
                spa.Supervisor_Store__c = ss.Id;
                spa.Promoter__c = rp.Principal__c;
                if (pa != null){
                    spa.Attendance__c = pa.Id;
                }
                spa.Statistical_Date__c = checkDate;
                spa.Sales_Region__c = salesRegion;
                spa.Key__c = ss.Id + '_' + rp.Principal__c;
                spaAddList.add(spa);
                promoterSet.add(ss.Id + '_' + rp.Principal__c);
            }
        }

        // 保存 Supervisor_Promoter_Attendance__c 表
        Database.upsert (spaAddList, Supervisor_Promoter_Attendance__c.field.Key__c, true);
    }

    global void finish(Database.BatchableContext BC){
        SupervisorPromoterAttendanceBatch ss = new SupervisorPromoterAttendanceBatch(salesRegion);
        Database.executeBatch(ss);
    }

}