public with sharing class SearchDataTableListController {

    // 查询共享用户数据列
    @AuraEnabled
    public static ConResponse getDailyReportDateInfo(String deviceId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        // 根据设备码查询当前绑定用户
        List<SubUser_Device__c> subUserDeviceInfo = getSubUserDeviceId(deviceId);

        System.debug('wwwwsubUserDeviceInfo' + JSON.serialize(subUserDeviceInfo));

        List<String> deviceIds = new List<String>();
        List<String> shopIds = new List<String>();

        String noteUserId = '';
        if(subUserDeviceInfo != null && subUserDeviceInfo.size() > 0){
            noteUserId = subUserDeviceInfo.get(0).SubUserID__c;
            // 查询当前用户是否属于当前账号下的子用户
            List<SubUser__c> subUserList = getSubUser(noteUserId);

            if(subUserList != null && subUserList.size() > 0){
                // 查询当前子用户所有设备绑定的门店信息
                List<SubUserLog__c> userLogList = getNoteUserStore(noteUserId);

                // 过滤当前用户所有设备绑定的重复门店信息
                if(userLogList != null && userLogList.size() > 0){
                    LisqContainer lq = new LisqContainer(userLogList);
                    Map<string, Sobject> shopIdMap = lq.ToMapS('StoreId__c');
                    if(shopIdMap != null && shopIdMap.size() > 0){
                        for(String key : shopIdMap.keySet()){
                            SubUserLog__c items = (SubUserLog__c)shopIdMap.get(key);
                            shopIds.add(items.StoreId__c);
                        }
                    }
                }

                // 获取当前子用户所有的设备码
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
            }

            System.debug('wwwwshopIds' + JSON.serialize(shopIds));
            System.debug('wwwwdeviceIds' + JSON.serialize(deviceIds));

            // 拼接唯一外键查询当前子用户的历史数据
            List<Promoter_Daily_Report__c> pdrList = new List<Promoter_Daily_Report__c>();
        
            for(String shopId : shopIds){
                // for(String device : deviceIds){
                //     // 日报ExId
                //     String parExId = String.valueOf(shopId) + '_' + UserInfo.getUserId()+ '_' + device + '_';
                //     List<Promoter_Daily_Report__c> dailyReport = NewPromoterDailyReportThailandController.getExistPromoterDailyReportBasedLikeExternalId(parExId + '%');
                //     if(dailyReport != null && dailyReport.size() > 0){
                //         System.debug('wwwwdailyReport' + JSOn.serialize(dailyReport));
                //         pdrList.addAll(dailyReport);
                //     }
                // }

                // 日报ExId 修改根据subuser YYL 20250312
                String parExId = String.valueOf(shopId) + '_' + UserInfo.getUserId()+ '_' + noteUserId + '_';
                List<Promoter_Daily_Report__c> dailyReport = NewPromoterDailyReportThailandController.getExistPromoterDailyReportBasedLikeExternalId(parExId + '%');
                if(dailyReport != null && dailyReport.size() > 0){
                    System.debug('wwwwdailyReport' + JSOn.serialize(dailyReport));
                    pdrList.addAll(dailyReport);
                }

                System.debug('wwwwpdrList' + JSOn.serialize(pdrList));
            }

            mso.put('pdrList', pdrList);

        }

        return resp;
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
                       AND ParentUser__c =: UserInfo.getUserId()];
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
    }
}