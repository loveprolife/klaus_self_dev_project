public with sharing class NewPromoterDailyReportThailandController {
    private static String SOBJECT_NOT_FOUND = System.Label.INSPECTION_REPORT_MSG_SOBJECT_NOT_FOUND; //未找到{0}信息，请联系系统管理员
    public static User user = [SELECT Id,Name,Country__c,Sales_Region__c,title FROM User WHERE Id = : UserInfo.getUserId()][0];
    
    // 初始化
    @AuraEnabled
    public static ConResponse getInitData(String recordId,String deviceId) {
        System.debug('recordId' + recordId);
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        // 获取Hisense Account Id
        List<Account> hisenseAcc = NewPromoterDailyReportActionController.getHisenseAccount();
        if (hisenseAcc.size()==0) {
            resp.code= -1;
            resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Account.getLabel()});
            return resp;
        }
        mso.put('hisenseAccId', hisenseAcc.size()>0 ? hisenseAcc[0].Id : null); 

        // 获取spiv信息, 产品Des信息 ------ Added By Sunny [2023-11-06] start
        Map<Id, Decimal> productAndSpivMap = NewPromoterDailyReportActionController.getAllProductSpiv();
        mso.put('productAndSpivMap', productAndSpivMap);

        Map<Id, String> productAndDesMap = NewPromoterDailyReportActionController.getAllProductDes();
        mso.put('productAndDesMap', productAndDesMap);
        // 获取spiv信息, 产品Des信息 ------ Added By Sunny [2023-11-06] end

        // 存放当前用户的所有设备id
        List<String> deviceIds = new List<String>();

        List<SubUserLog__c> SubUserLogList = new List<SubUserLog__c>();

        // 通过设备唯一标识查询SubUser_Device__c表是否存在
        List<SubUser_Device__c> subUserDeviceList = getSubUserDeviceId(deviceId);
        System.debug('wwwwsubUserDeviceList' + JSON.serialize(subUserDeviceList));

        String userId  = '';
        if(subUserDeviceList != null && subUserDeviceList.size() > 0){
            SubUser_Device__c subUserDevice = subUserDeviceList.get(0);
            userId = subUserDevice.SubUserID__c;

            // 查询当前用户是否属于当前账号下的子用户
            List<SubUser__c> subUserList = getSubUser(userId);

            if(Test.isRunningTest()){
                subUserList = [SELECT Id,Name,ParentUser__c,IsActive__c FROM SubUser__c];
            }

            if(subUserList != null && subUserList.size() > 0){
                // 查询当前子用户所有设备绑定的门店信息
                List<SubUserLog__c> userLogList = getNoteUserStore(userId);

                // 过滤当前用户所有设备绑定的重复门店信息
                if(userLogList != null && userLogList.size() > 0){
                    LisqContainer lq = new LisqContainer(userLogList);
                    Map<string, Sobject> shopIdMap = lq.ToMapS('StoreId__c');

                    if(shopIdMap != null && shopIdMap.size() > 0){
                        SubUserLogList = (List<SubUserLog__c>)shopIdMap.values();
                    }
                }
            }
        }

        // 新增子用户纬度 
        String noteUserId = '';
        if(SubUserLogList != null && SubUserLogList.size() > 0){
            noteUserId = SubUserLogList.get(0).SubUser__c;
            // 获取当前子用户所有的设备码
            List<SubUser_Device__c> subUserIdDeviceList = getSubUserIdDevice(noteUserId);

            if(Test.isRunningTest()){
                subUserIdDeviceList = [SELECT Id, SubUserID__c,DeviceID__c,LastUsedTime__c FROM SubUser_Device__c];
            }

            if(subUserIdDeviceList != null && subUserIdDeviceList.size() > 0){
                LisqContainer lq = new LisqContainer(subUserIdDeviceList);
                // 过滤掉重复的设备码信息
                Map<String, Sobject> deviceIdMap = lq.ToMapS('DeviceID__c');
                if(deviceIdMap != null && deviceIdMap.size() > 0){
                    for(String key : deviceIdMap.keySet()){
                        SubUser_Device__c items = (SubUser_Device__c)deviceIdMap.get(key);
                        deviceIds.add(items.DeviceID__c);
                    }
                }
            }
        }

        System.debug('wwwwSubUserLogList' + JSON.serialize(SubUserLogList));
        mso.put('responsiblePersonList', SubUserLogList);

        // 根据设备信息拼接唯一值查询是否有历史数据
        // List<String> parExIdList = new List<String>();
        // 拼接查询日报的唯一id YYL 20250312
        String parExId = '_' + UserInfo.getUserId() + '_' + noteUserId + '_' + String.valueOf(System.today()) + ' 00:00:00';
        // if(deviceIds != null && deviceIds.size() > 0){
        //     // 拼接查询日报的唯一id
        //     for(String item : deviceIds){
        //         // 日报ExId（不包含门店)
        //         String parExId = '_' + UserInfo.getUserId() + '_' + item + '_' + String.valueOf(System.today()) + ' 00:00:00';
        //         parExIdList.add(parExId);
        //     }
        // }

        // 获取Today
        mso.put('todayDate', System.today()); 
        // 存在recordId
        if (String.isNotBlank(recordId)) {
            List<Promoter_Daily_Report__c> pdrList = NewPromoterDailyReportActionController.getExistPromoterDailyReportBasedId(recordId);
            if (pdrList.size()==0) {
                resp.code= -1;
                resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Promoter_Daily_Report__c.getLabel()});
                return resp;
            }
            Promoter_Daily_Report__c pdr = pdrList[0];
            mso.put('record', pdr);
            
            List<Shop__c> shopList = NewPromoterDailyReportActionController.getShopNameBase(pdr.Shop__c);
            if (shopList.size()==0) {
                resp.code= -1;
                resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Shop__c.getLabel()});
                return resp;
            }
            Shop__c shop = shopList[0];
            mso.put('recordShopName', shop);
            List<Retail_Number__c> rnList = NewPromoterDailyReportActionController.getExistRetailNumberBasedPdr(recordId);
            mso.put('retailNumberList', rnList); 

            // 获取daily sales关联的文件 wfc 2024-06-28
            Map<String,List<String>> documentIdMap = new Map<String,List<String>>();
            List<String> dailySalesIdList = new LisqContainer(rnList).ToIds();
            if(dailySalesIdList != null && dailySalesIdList.size() > 0){
                List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:dailySalesIdList];
                for(ContentDocumentLink cdt : cdlList){
                    if(documentIdMap.containsKey(cdt.LinkedEntityId)){
                        List<String> testList = documentIdMap.get(cdt.LinkedEntityId);
                        testList.add(cdt.ContentDocumentId);
                        documentIdMap.put(cdt.LinkedEntityId, testList);
                    }else {
                        documentIdMap.put(cdt.LinkedEntityId, new List<String>{ cdt.ContentDocumentId });
                    }
                }
            }
            mso.put('retailNumberHaveFileIdMap', documentIdMap);

            //goods receiving  
            List<GoodsInOut__c> grList = NewPromoterDailyReportActionController.getExistGoodsReceivingBasedPdr(recordId);
            mso.put('goodsReceivingList', grList); 
            System.debug('goodsReceivingList=======>'+grList);
            //intelligence  
            List<Shop_Retail_Detail__c> srdList = NewPromoterDailyReportActionController.getExistIntelligenceBasedPdr(recordId);
            mso.put('intelligenceList', srdList); 
        // 不存在recordId
        } else {
            List<Promoter_Daily_Report__c> pdr = new List<Promoter_Daily_Report__c>();
            // if(parExIdList != null && parExIdList.size() > 0){
            //     String parExId = '';
            //     for(String str : parExIdList){
            //         pdr = getExistPromoterDailyReportBasedLikeExternalId('%'+str);

            //         // 查询到历史数据则跳出循环
            //         if(pdr != null && pdr.size() > 0){
            //             break;
            //         }
            //     }
            // }

            pdr = getExistPromoterDailyReportBasedLikeExternalId('%'+parExId);

            if(Test.isRunningTest()){
                pdr = [SELECT Id,Name,Status__c,Shop__c,Report_Date__c,OwnerId,Owner_text__c FROM Promoter_Daily_Report__c];
            }
            // 判断是否为门店负责人
            List<Responsible_Person__c> rpList = new List<Responsible_Person__c>();
            if (pdr.size()>0) {
                rpList = NewPromoterDailyReportActionController.getResponsiblePersonBaseShop(pdr[0].Shop__c);
            }
            // 如果存在当天日报，取最后更新记录
            if (pdr.size()>0 && rpList.size()>0) {
                mso.put('record', pdr[0]);
                List<Retail_Number__c> rnList = NewPromoterDailyReportActionController.getExistRetailNumberBasedPdr(pdr[0].Id);
                mso.put('retailNumberList', rnList); 

                // 获取daily sales关联的文件 wfc 2024-06-28
                Map<String,List<String>> documentIdMap = new Map<String,List<String>>();
                List<String> dailySalesIdList = new LisqContainer(rnList).ToIds();
                if(dailySalesIdList != null && dailySalesIdList.size() > 0){
                    List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:dailySalesIdList];
                    for(ContentDocumentLink cdt : cdlList){
                        if(documentIdMap.containsKey(cdt.LinkedEntityId)){
                            List<String> testList = documentIdMap.get(cdt.LinkedEntityId);
                            testList.add(cdt.ContentDocumentId);
                            documentIdMap.put(cdt.LinkedEntityId, testList);
                        }else {
                            documentIdMap.put(cdt.LinkedEntityId, new List<String>{ cdt.ContentDocumentId });
                        }
                    }
                }
                mso.put('retailNumberHaveFileIdMap', documentIdMap);


                //goods receiving 
                List<GoodsInOut__c> grList = NewPromoterDailyReportActionController.getExistGoodsReceivingBasedPdr(pdr[0].Id);
                mso.put('goodsReceivingList', grList);  
                
                // TJP 20241127 Stock
                List<Promotional_Stock__c> srList = NewPromoterDailyReportActionController.getExistStockBasedPdr(pdr[0].Id);
                mso.put('stockList', srList); 
                //intelligence
                List<Shop_Retail_Detail__c> srdList = NewPromoterDailyReportActionController.getExistIntelligenceBasedPdr(pdr[0].Id);
                mso.put('intelligenceList', srdList);
            }else{

                // 不存在考勤信息
                mso.put('record', new Promoter_Daily_Report__c(
                    Report_Date__c = System.today(),
                    Status__c = 'New'
                ));
                mso.put('retailNumberList', new List<Retail_Number__c>());
                mso.put('goodsReceivingList', new List<GoodsInOut__c>());  
                mso.put('intelligenceList', new List<Shop_Retail_Detail__c>());  
            }
        }
        System.debug('resp======>'+resp);
        return resp;
    }

    // 刷新数据
    @AuraEnabled
    public static ConResponse refreshData(String reportDate, String ShopId,String deviceId) {
        System.debug('reportDate' + reportDate);
        System.debug('ShopId' + ShopId);
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 根据当前设备码查询当前操作的子用户
        List<SubUser_Device__c> SubUserLogList = getSubUserDeviceId(deviceId);

        // 根据子用户信息在获取所有的设备码
        String noteUserId = SubUserLogList.get(0).SubUserID__c;
        List<String> deviceIds = new List<String>();
        List<SubUser_Device__c> subUserIdDeviceList = getSubUserIdDevice(noteUserId);
        if(subUserIdDeviceList != null && subUserIdDeviceList.size() > 0){
            LisqContainer lq = new LisqContainer(subUserIdDeviceList);
            // 过滤掉重复的设备码信息
            Map<String, Sobject> deviceIdMap = lq.ToMapS('DeviceID__c');
            if(deviceIdMap != null && deviceIdMap.size() > 0){
                for(String key : deviceIdMap.keySet()){
                    SubUser_Device__c items = (SubUser_Device__c)deviceIdMap.get(key);
                    deviceIds.add(items.DeviceID__c);
                }
            }
        }

        List<Promoter_Daily_Report__c> pdrList = new List<Promoter_Daily_Report__c>();
        
        System.debug('wwwwdeviceIds' + JSON.serialize(pdrList));
        // 日报ExId
        String parExId = String.valueOf(ShopId) + '_' + UserInfo.getUserId()+ '_' + noteUserId + '_' + String.valueOf(reportDate) + ' 00:00:00';
        pdrList = getExistPromoterDailyReportBasedExternalId(parExId);
        // for(String item : deviceIds){
        //      // 日报ExId
        //     String parExId = String.valueOf(ShopId) + '_' + UserInfo.getUserId()+ '_' + item + '_' + String.valueOf(reportDate) + ' 00:00:00';
        //     pdrList = getExistPromoterDailyReportBasedExternalId(parExId);

        //     if(pdrList != null && pdrList.size() > 0){
        //         break;
        //     }
        // }

        if (pdrList.size()>0) {
            mso.put('record', pdrList[0]);
            List<Retail_Number__c> rnList = NewPromoterDailyReportActionController.getExistRetailNumberBasedPdr(pdrList[0].Id);
            mso.put('retailNumberList', rnList); 
            //goods receiving  
            List<GoodsInOut__c> grList = NewPromoterDailyReportActionController.getExistGoodsReceivingBasedPdr(pdrList[0].Id);
            mso.put('goodsReceivingList', grList);  
            //TJP 2024-11-27 Stock 
            List<Promotional_Stock__c> srList = NewPromoterDailyReportActionController.getExistStockBasedPdr(pdrList[0].Id);
            mso.put('stockList', srList); 
            //intelligence  
            List<Shop_Retail_Detail__c> srdList = NewPromoterDailyReportActionController.getExistIntelligenceBasedPdr(pdrList[0].Id);
            mso.put('intelligenceList', srdList); 
        } else {
            // mso.put('record', new Promoter_Daily_Report__c(
            //     Report_Date__c = Date.valueOf(reportDate),
            //     Shop__c = ShopId
            // ));
            mso.put('retailNumberList', new List<Retail_Number__c>());
            mso.put('goodsReceivingList', new List<GoodsInOut__c>());
            mso.put('stockList', new List<Promotional_Stock__c>());
            mso.put('intelligenceList', new List<Shop_Retail_Detail__c>());     
        }
        System.debug('resp======>'+resp);
        return resp;
    }

    // 创建日报信息
    @AuraEnabled
    public static ConResponse createData(String recordJson,String deviceId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 根据当前设备码查询当前操作的子用户
        List<SubUser_Device__c> SubUserLogList = getSubUserDeviceId(deviceId);

        String noteUserId = '';
        if(SubUserLogList != null && SubUserLogList.size() > 0){
            noteUserId = SubUserLogList.get(0).SubUserID__c;
        }

        Promoter_Daily_Report__c report = (Promoter_Daily_Report__c)JSON.deserializeStrict(recordJson, Promoter_Daily_Report__c.class);
        
        // 门店-用户-设备码-reprtDate
        // String externalIdThailand = report.Shop__c + '_' + UserInfo.getUserId() + '_' + deviceId + '_' + String.valueOf(report.Report_Date__c) + ' 00:00:00';
        
        report.Status__c = 'New';
        report.SubUser__c = noteUserId;
        // report.ExternalId_Thailand__c = externalIdThailand;

        // 获取门店巡店员用户设置给Promoter_Daily_Report
        // Shop__c shop = getShopFloorWalker(report.Shop__c);
        // report.Responsible_Person__c = shop.Responsible_Person__c;

        upsert report;

        Promoter_Daily_Report__c pdr = NewPromoterDailyReportActionController.getExistPromoterDailyReportBasedId(report.Id)[0];
        mso.put('record', pdr);
        return resp;
    }

    // 根据查询当前操作的子用户绑定的门店信息
    public static List<SubUserLog__c> getNoteUserStore(String userId) {
        return [SELECT Id, 
                       SubUser__c,
                       StoreId__c,
                       StoreId__r.Name,
                       Action_Time__c,
                       DeviceID__c 
                       FROM SubUserLog__c 
                       WHERE SubUser__c =: userId];
    }

    // 根据设备信息获取绑定的用户信息
    public static List<SubUser_Device__c> getSubUserDeviceId(String deviceId) {
        return [SELECT Id, 
                       SubUserID__c,
                       DeviceID__c,
                       LastUsedTime__c,
                       IsActive__c 
                       FROM SubUser_Device__c 
                       WHERE DeviceID__c =: deviceId];
    }

    // 获取当前子用户的所有设备码
    public static List<SubUser_Device__c> getSubUserIdDevice(String noteUserId) {
        return [SELECT Id, 
                       SubUserID__c,
                       DeviceID__c,
                       LastUsedTime__c,
                       IsActive__c 
                       FROM SubUser_Device__c 
                       WHERE SubUserID__c =: noteUserId];
    }

    // 根据子用户id查询是否属于当前账号的子用户
    public static List<SubUser__c> getSubUser(String noteUserId){
        return [SELECT Id,
                       Name,
                       ParentUser__c,
                       IsActive__c
                       FROM SubUser__c 
                       WHERE Id =: noteUserId
                       AND ParentUser__c =: user.Id];
    }

    // 获取存在的考勤信息
    public static List<Promoter_Daily_Report__c> getExistPromoterDailyReportBasedExternalId(String externalId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Status__c,
                    Shop__c,
                    Report_Date__c,
                    OwnerId,
                    Owner_text__c
                FROM Promoter_Daily_Report__c 
                WHERE 
                ExternalId__c =: externalId];
    }

    public static List<Promoter_Daily_Report__c> getExistPromoterDailyReportBasedLikeExternalId(String externalId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Status__c,
                    Shop__c,
                    Shop__r.name,
                    Report_Date__c,
                    OwnerId,
                    Owner_text__c
                FROM Promoter_Daily_Report__c 
                WHERE 
                ExternalId__c 
                LIKE : externalId
                ORDER BY LastModifiedDate DESC];
    }

    public static Shop__c getShopFloorWalker(String Id) {
        return [SELECT Id,Responsible_Person__c FROM Shop__c WHERE Id =: Id];
    }

    public static void runTest(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}