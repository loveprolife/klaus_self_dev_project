public with sharing class NewStoreMapSubmitController {

    // 查询当前用户信息
    public static User user = [SELECT Id,Name,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()][0];

    @AuraEnabled
    public static ConResponse getInit(String userId,String deviceId){

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 查询当前用户下子用户
        List<SubUser__c> userList = new List<SubUser__c>();

        // 根据设备码查询历史绑定数据
        List<SubUserLog__c> userLog = getSubUserLog(deviceId);
        
        if(userLog.isEmpty()){
            if(String.isNotEmpty(userId)){  

                userList = getSubUser(userId);

                List<SubStore__c> shopList = getSubStore(userId);
                if(!shopList.isEmpty()){
                    mso.put('shopInfo',shopList.get(0));
                }

            }else{
                userList = getSubUser();
            }
        }else{
            SubUserLog__c subLog = userLog.get(0);
            userList = getSubUser(subLog.SubUser__c);

            // mso.put('shopInfo',subLog.StoreId__c);
            mso.put('shopInfo',getShopInfo(subLog.StoreId__c).get(0));
        }

        mso.put('userInfo',userList);
        
        return resp;
    }

    // 记录用户操作记录
    @AuraEnabled
    public static ConResponse actionRecord(String userId, String shopId, String actionDetails, String deviceInfo) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        try {
            // 查询当前设备绑定的记录
            List<SubUserLog__c> userLog = getSubUserLog(deviceInfo);

            // if (userLog != null && userLog.size() > 0) {
            //     // 如果记录存在，则提示不允许重复提交
            //     resp.code = -1;
            //     resp.message = System.Label.Store_Map_Submit_Repeat;
            // } else {
                
            // }

            // 检查设备记录是否存在
            List<SubUser_Device__c> existingDevices = [
                SELECT Id, LastUsedTime__c, IsActive__c
                FROM SubUser_Device__c
                WHERE DeviceID__c = :deviceInfo AND SubUserID__c = :userId
                LIMIT 1
            ];

            SubUser_Device__c device;
            if (!existingDevices.isEmpty()) {
                // 更新已有设备的最后使用时间
                device = existingDevices[0];
                device.LastUsedTime__c = System.now();
                device.IsActive__c = true;
                device.SubUserID__c = userId;
                update device;
            } else {
                // 创建新的设备记录
                device = new SubUser_Device__c();
                device.SubUserID__c = userId;
                device.DeviceID__c = deviceInfo;
                device.LastUsedTime__c = System.now();
                device.IsActive__c = true;
                insert device;
            }

            SubUserLog__c log = new SubUserLog__c();
            if(!userLog.isEmpty()){
                // 存在数据则更新
                log = userLog.get(0);
            }else{
                log.DeviceID__c = device.Id; // 保存设备记录的 Lookup
            }
            // 创建日志记录
            log.SubUser__c = userId;
            log.StoreId__c = shopId;
            log.ActionDetails__c = actionDetails;
            log.Action_Time__c = System.now();
            Database.upsert(log);

            resp.code = 0;
            resp.message = 'Success';
        } catch (Exception e) {
            resp.code = -1;
            resp.message = e.getMessage();
        }

        return resp;
    }


    // public static List<Map<String, Object>> getStoreDistanceListForStore(String currentLat, String currentLong, 
    //                                                                         String shopId, List<SubStore__c> shopList) {

    //     List<Map<String, Object>> storeDistanceList = new List<Map<String, Object>>();
    //     for(SubStore__c item : shopList){
    //         Map<String, Object> storeDistanceMap = new Map<String, Object>();
    //         Location location = Location.newInstance(Double.Valueof(currentLat), Double.Valueof(currentLong));
    //         Decimal distance = 999.999;
    //         if (item.StoreID__r.Shop_Center_Location__c!=null && currentLat!=null && currentLong!=null) {
    //             distance = location.getDistance(item.StoreID__r.Shop_Center_Location__c,'km');
    //             storeDistanceMap.put('storeLat', item.StoreID__r.Shop_Center_Location__Latitude__s);
    //             storeDistanceMap.put('storeLong', item.StoreID__r.Shop_Center_Location__Longitude__s);
    //         } else {
    //             storeDistanceMap.put('storeLat', 0);
    //             storeDistanceMap.put('storeLong', 0);
    //         }
    //         storeDistanceMap.put('storeId', item.StoreID__c);
    //         storeDistanceMap.put('storeName', item.StoreID__r.Name);
    //         storeDistanceMap.put('storeDistance', distance);
    //         storeDistanceMap.put('storeDistanceStr', String.valueOf(Integer.valueOf(distance*1000))+'m');

    //         // 根据距离排序
    //         if (storeDistanceList.size()>0) {
    //             for (Integer i = 0; i < storeDistanceList.size(); i++) {
    //                 Decimal itemDistance = (Decimal)storeDistanceList[i].get('storeDistance');
    //                 if (distance<=itemDistance) {
    //                     storeDistanceList.add(i, storeDistanceMap);
    //                     break;
    //                 } else if ((i+1)==storeDistanceList.size()) {
    //                     storeDistanceList.add(storeDistanceMap);
    //                     break;
    //                 }
    //             }
    //         } else {
    //             storeDistanceList.add(storeDistanceMap);
    //         }

    //     }

    //     return storeDistanceList;
    // }

    private static List<Shop__c> getShopInfo(String shopId){
        return [SELECT Id,
                       name
                       FROM Shop__c WHERE Id =: shopId];
    }

    private static List<SubStore__c> getSubStore(String userId){
        return [SELECT Id,
                       StoreID__c,
                       StoreID__r.name
                       FROM SubStore__c WHERE SubUserID__c =: userId];
    }

    private static List<SubStore__c> getSubStoreAndUser(String storeId){
        return [SELECT Id,
                       SubUserID__c
                       FROM SubStore__c 
                       WHERE StoreID__c =: storeId
                       AND SubUserID__r.ParentUser__c =: user.Id];
    }

    private static List<SubUser__c> getSubUser(){
        return [SELECT Id,
                       Name,
                       ParentUser__c,
                       IsActive__c,
                       Email__c
                       FROM SubUser__c 
                       WHERE ParentUser__c =: user.Id
                       AND IsActive__c = true];
    }

    private static List<SubUser__c> getSubUser(String userId){
        return [SELECT Id,
                       Name,
                       ParentUser__c,
                       IsActive__c,
                       Email__c
                       FROM SubUser__c 
                       WHERE Id =: userId
                       AND ParentUser__c =: user.Id
                       AND IsActive__c = true];
    }
    
    private static List<SubUserLog__c> getSubUserLog(String deviceId) {
        return [
            SELECT Id, StoreId__c, SubUser__c, ActionDetails__c, DeviceID__c
            FROM SubUserLog__c
            // WHERE SubUser__c = :userId
            //   AND StoreId__c = :shopId
            //   AND ActionDetails__c = :actionDetails
            WHERE DeviceID__r.DeviceID__c = :deviceId
        ];
    }
}