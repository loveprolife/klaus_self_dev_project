/**
 * CheckInCheckOutController
 * Purpose:
 * Author: Chiara
 * Date: 2021/12/29
 * ---------------------------------------------------------------------------
 * History Tracking
 * 
 */
public with sharing class CheckInCheckOutController {

    private static String WITHOUT_DISTANCE = System.Label.CheckInCheckOut_WITHOUT_POSITION;//未获取当前定位信息，不可签到
    private static String PROMOTE_PROFILE = '促销员';
    private static String INSPECTION_PROFILE = '巡店员';
    public static String NOT_PLAN_ATTENDANCE = '计划外到访';
    private static String RESPONSIBLE_PERSON = System.Label.CheckInCheckOut_RESPONSIBLE_PERSON; //门店负责人
    private static String NOT_RESPONSIBLE_PERSON = System.Label.CheckInCheckOut_NOT_RESPONSIBLE_PERSON; //非门店负责人
    private static String PLAN_ATTENDANCE = System.Label.CheckInCheckOut_PLAN_ATTENDANCE;//计划内到访
    private static String CONTACT_ADMIN_OR_REFRESH = System.Label.CheckInCheckOut_CONTACT_ADMIN_OR_REFRESH;//请刷新页面再次尝试或将报错信息提交至管理员。
    private static String WITHOUT_ADDRESS = System.Label.CheckInCheckOut_WITHOUT_ADDR;//无法获取精确地址
    private static String NOT_CHECK_IN = System.Label.CheckInCheckOut_NOT_CHECK_IN;//未签到
    private static String CHECK_IN_SHOP = System.Label.CheckInCheckOut_CHECK_IN_STORE;//签到门店
    private static String CHECK_OUT_SHOP = System.Label.CheckInCheckOut_CHECK_OUT_STORE;//签退门店
    private static String CHECK_IN_OUT_SHOP = System.Label.CheckInCheckOut_CHECK_IN_OUT_STORE;//签到签退门店
    private static String NOT_PLAN_ATTENDANCE_LABEL = System.Label.CheckInCheckOut_VISIT_NO_PLAN;//计划外到访
    private static String HAS_OTHER_USER_SHOP_TASK = System.Label.CheckInCheckOut_NO_DUP_CHECK_IN;//该门店属于其他人的今日巡店任务，不可重复打卡

    public static Date thisDay = System.today();//Date.newInstance(2021, 12, 25); //测试后改成System.today()
    //初始化考勤信息页面
    @AuraEnabled
    public static ReturnData initStoreInfo(String lati, String lng) {
        ReturnData rd = new ReturnData();
        rd.dataList = new List<DataSet>();
        rd.isSuccess = true;
        rd.thisDay = thisDay;
        try{
            List<Promoter_Attendance__c> attendanceList = getExistAttendance(UserInfo.getUserId() + '_' + String.valueOf(thisDay));
            Promoter_Attendance__c existAttendanceLabel;
            if(attendanceList.size() > 0) {
                //存在考勤信息
                Map<Id, Promoter_Attendance__c> attendanceMap = getAttendanceLabel(new List<String>{attendanceList[0].Id});
                rd.checkInId = attendanceList[0].Id;
                rd.checkInStatus = attendanceList[0].CheckInStatus__c;
                rd.checkInShop = attendanceList[0].Shop__c;
                rd.checkOutShop = attendanceList[0].CheckOutShop__c;
                rd.checkInStatusLabel =  attendanceMap.get(attendanceList[0].Id).CheckInStatus__c;
                existAttendanceLabel = attendanceMap.get(attendanceList[0].Id);
            }else{
                //不存在考勤信息
                rd.checkInStatus = '未签到';
                rd.checkInStatusLabel = NOT_CHECK_IN;
            }

            
            Profile profileItem = getProfileItem(UserInfo.getProfileId());
            system.debug('profileItem'+profileItem);
            rd.userType = profileItem.Name;
            if(profileItem.Name == PROMOTE_PROFILE){
                rd = initStoreInfoPromote(lati, lng, rd, existAttendanceLabel);
            }else{
            //else if(profileItem.Name == INSPECTION_PROFILE) {
                rd = initStoreInfoInspection(lati, lng, rd, attendanceList);
            }
            if(String.isNotBlank(lati) && String.isNotBlank(lng)){
                try{
                    rd.addressStr = geolocationGetAddress(lati, lng);
                    if(String.isBlank(rd.addressStr)) {
                        rd.addressStr = WITHOUT_ADDRESS;
                    }
                }catch(Exception e){
                    rd.isSuccess = false;
                    rd.failMessage = WITHOUT_ADDRESS + e.getMessage() + '[' + e.getLineNumber() + ']';
                    System.debug(e.getlineNumber()+e.getMessage());
                }
            }
            
        }catch(Exception e) {
            rd.isSuccess = false;
            rd.failMessage = rd.failMessage + CONTACT_ADMIN_OR_REFRESH + ' ' + getProperErrorMessage(e.getMessage())+ '[' + e.getLineNumber() + ']';
            System.debug(e.getStackTraceString());
        }
        return rd;
    }
    //查找门店
    @AuraEnabled
    public static ReturnData getStoreInfo(String lati, String lng, String searchInfo){
        ReturnData rd = new ReturnData();
        rd.dataList = new List<DataSet>();
        rd.isSuccess = true;
        try{
            Profile profileItem = getProfileItem(UserInfo.getProfileId());
            rd.userType = profileItem.Name;
            rd.thisDay = thisDay;
            Location locItem;
            if(String.isNotBlank(lati) && String.isNotBlank(lng)){
                locItem = Location.newInstance(Double.Valueof(lati), Double.Valueof(lng));
            }
            
            List<List<sObject>> searchList = CheckInCheckOutService.getShopList(searchInfo);
            system.debug('searchList'+searchList);
            Map<Id, Shop__c> shopMap= new Map<Id, Shop__c>();
            List<String> inspectionTaskExternalIdList = new List<String>();
            for(Shop__c shopItem : (List<Shop__c>)searchList[0]) {
                shopMap.put(shopItem.Id, shopItem);
                inspectionTaskExternalIdList.add(String.valueOf(thisDay) + '-' + shopItem.Id);
            }

            /*
            Map<String, Promoter_Attendance__c> paMap = new Map<String, Promoter_Attendance__c>();
            List<String> paIdList = new List<String>();
            List<String> shopIdList = (List<String>)new List<Id>( shopMap.keySet() );
            for(Promoter_Attendance__c paItem : getShopListAttendance(UserInfo.getUserId(), thisDay, shopIdList)){
                paMap.put(paItem.Shop__c, paItem);
                paIdList.add(paItem.Id);
            }
            Map<Id, Promoter_Attendance__c> paLabelMap = getAttendanceLabel(paIdList);*/
            
            List<Promoter_Attendance__c> attendanceList = getExistAttendance(UserInfo.getUserId() + '_' + String.valueOf(thisDay));
            if(profileItem.Name == PROMOTE_PROFILE) {
                List<Responsible_Person__c> rpList = getResponsibleShop(UserInfo.getUserId(), PROMOTE_PROFILE);
                for(Shop__c shopItem : shopMap.values()) {
                    //显示门店
                    DataSet dataItem = new DataSet();
                    dataItem.Id = shopItem.Id;
                    dataItem.Name = shopItem.Name;
                    dataItem.Channel = shopItem.Account__r.Name;
                    if(locItem<>null && shopItem.Shop_Center_Location__c <> null){
                        Decimal distance = Location.getDistance(locItem, shopItem.Shop_Center_Location__c, 'km');
                        dataItem.Distance = distance.setScale(2);
                    }
                    /*
                    if(paMap.containskey(shopItem.Id)){
                        dataItem.CheckInStatus = paMap.get(shopItem.Id).CheckInStatus__c;
                        dataItem.CheckInStatusLabel = paLabelMap.get(paMap.get(shopItem.Id).Id).CheckInStatus__c;
                    }*/
                    //判断促销员是否为门店负责人
                    Boolean isPromote = false;
                    for(Responsible_Person__c rpItem : rpList) {
                        if(rpItem.Shop_Name__c == shopItem.Id) {
                            isPromote = true;
                        }
                    }
                    if(isPromote) {
                        dataItem.Remark = RESPONSIBLE_PERSON;
                    }else{
                        dataItem.Remark = NOT_RESPONSIBLE_PERSON;
                    }

                    //判断门店是否为签到签退门店
                    dataItem = judgeCheckInShop(dataItem, attendanceList);
                    rd.dataList.add(dataItem);
                }

            }else{
                List<Inspection_Shop_Task__c> inspectionTaskList = getInspectionTaskList(inspectionTaskExternalIdList, UserInfo.getUserId());
                for(Shop__c shopItem : shopMap.values()) {
                    DataSet dataItem = new DataSet();
                    dataItem.Id = shopItem.Id;
                    dataItem.Name = shopItem.Name;
                    dataItem.Channel = shopItem.Account__r.Name;
                    if(locItem<>null && shopItem.Shop_Center_Location__c <> null){
                        Decimal distance = Location.getDistance(locItem, shopItem.Shop_Center_Location__c, 'km');
                        dataItem.Distance = distance.setScale(2);
                    }
                    //判断门店是否为计划外到访
                    for(Inspection_Shop_Task__c taskItem : inspectionTaskList) {
                        if(taskItem.Shop__c == dataItem.Id) {
                            if(taskItem.Status__c == NOT_PLAN_ATTENDANCE){
                                dataItem.Remark = NOT_PLAN_ATTENDANCE_LABEL;
                            }else{
                                dataItem.Remark = PLAN_ATTENDANCE;
                            }
                        }
                    }
                    //判断门店是否为签到签退门店
                    dataItem = judgeCheckInShop(dataItem, attendanceList);
                    rd.dataList.add(dataItem);
                }
            }
            /*
            List<Promoter_Attendance__c> attendanceList = getExistAttendance(UserInfo.getUserId() + '_' + thisDay);
            List<Responsible_Person__c> rpList = getResponsibleShop(UserInfo.getUserId(), PROMOTE_PROFILE);
            for(Shop__c shopItem : shopMap.values()) {
                DataSet dataItem = new DataSet();
                dataItem.Id = shopItem.Id;
                dataItem.Name = shopItem.Name;
                dataItem.Channel = shopItem.Account__r.Name;
                if(locItem<>null && shopItem.Shop_Center_Location__c <> null){
                    Decimal distance = Location.getDistance(locItem, shopItem.Shop_Center_Location__c, 'km');
                    dataItem.Distance = distance.setScale(2);
                }
                if(paMap.containskey(shopItem.Id)){
                    dataItem.CheckInStatus = paMap.get(shopItem.Id).CheckInStatus__c;
                    dataItem.CheckInStatusLabel = paLabelMap.get(paMap.get(shopItem.Id).Id).CheckInStatus__c;
                    dataItem.AttendanceId =  paMap.get(shopItem.Id).Id;
                }
                //促销员
                
                if(profileItem.Name == PROMOTE_PROFILE){
                    Boolean isPromote = false;
                    for(Responsible_Person__c rpItem : rpList) {
                        if(rpItem.Shop_Name__c == shopItem.Id) {
                            isPromote = true;
                        }
                    }
                    if(isPromote) {
                        dataItem.Remark = RESPONSIBLE_PERSON;
                    }else{
                        dataItem.Remark = NOT_RESPONSIBLE_PERSON;
                    }
                }else if(paMap.containskey(shopItem.Id) && paMap.get(shopItem.Id).InspectionShopTask__c <> null){
                    //巡店员
                    //dataItem.PlanId = paMap.get(shopItem.Id).InspectionShopTask__c;
                    if(paMap.get(shopItem.Id).InspectionShopTask__r.Status__c == NOT_PLAN_ATTENDANCE){
                        dataItem.PlanStatus = paMap.get(shopItem.Id).InspectionShopTask__r.Status__c;
                        dataItem.PlanStatusLabel = paLabelMap.get(paMap.get(shopItem.Id).Id).InspectionShopTask__r.Status__c;
                    }else{
                        dataItem.PlanStatus = PLAN_ATTENDANCE;
                        dataItem.PlanStatusLabel = PLAN_ATTENDANCE;
                    }
                }
               rd.dataList.add(dataItem);
            } */
            rd.dataList.sort();
        }catch(Exception e) {
            rd.isSuccess = false;
            rd.failMessage = CONTACT_ADMIN_OR_REFRESH + ' ' + getProperErrorMessage(e.getMessage())+ '[' + e.getLineNumber() + ']';
            System.debug(e.getStackTraceString());
        }
        return rd;
    }
    //签到操作
    @AuraEnabled
    public static ReturnData checkIn(String attendanceId, String curStatus,String storeId, String planId, Decimal lati, Decimal lng, String device, String addressStr){
        ReturnData rd = new ReturnData();
        rd.dataList = new List<DataSet>();
        rd.isSuccess = true;
        try {
            Shop__c shopItem = CheckInCheckOutService.getShopItem(storeId);
            if( lati<>null && lng <>null) {
                Promoter_Attendance__c paItem = new Promoter_Attendance__c();
                Profile profileItem = getProfileItem(UserInfo.getProfileId());
                rd.userType = profileItem.Name;
                if(profileItem.Name == PROMOTE_PROFILE){
                    paItem.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('PromoterAttendance').getRecordTypeId();
                 }else{
                    paItem.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('InspectorAttendace').getRecordTypeId();
                    List<Inspection_Shop_Task__c> istOtherList = getOtherShopTaskList(thisDay, UserInfo.getUserId() , storeId);
                    if(istOtherList.size() > 0) {
                        rd.isSuccess = false;
                        rd.failMessage = HAS_OTHER_USER_SHOP_TASK;
                        return rd;
                    }else{
                        CheckInCheckOutService.createInspectionShopTask(storeId);
                    }   
                }             
                paItem.Shop__c = storeId;
                paItem.CheckIn_Date__c = thisDay;
                paItem.CheckInDevice__c = device;
                paItem.SignInLocation__Latitude__s = lati;
                paItem.SignInLocation__Longitude__s = lng;
                paItem.SignInTime__c = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
                paItem.CheckInAddress__c = addressStr;
                if(shopItem.Shop_Center_Location__c <> null) {
                    Location locItem = Location.newInstance(Double.Valueof(lati), Double.Valueof(lng));
                    Decimal distance = Location.getDistance(locItem, shopItem.Shop_Center_Location__c, 'km')*1000;
                    paItem.Signin_Distance__c = distance.setScale(2);
                }
                if(curStatus == '已签退'){
                    paItem.CheckInStatus__c = '已签到签退';
                    
                }else{
                    paItem.CheckInStatus__c = '已签到';
                }
                paItem.ExternalId__c = UserInfo.getUserId() + '_' + String.valueOf(paItem.CheckIn_Date__c);

                // upsert paItem ExternalId__c;
                CheckInCheckOutService.createPromoterAttendance(paItem);
                // wfc 巡店员在负责人为空的门店签到过，将这个巡店员自动添加为门店负责人
                CheckInCheckOutService.autoSaveResponsiblePerson(storeId, UserInfo.getUserId());
            }else{
                rd.isSuccess = false;
                rd.failMessage = WITHOUT_DISTANCE;
            }

        } catch (Exception e) {
            rd.isSuccess = false;
            rd.failMessage = CONTACT_ADMIN_OR_REFRESH + ' ' + getProperErrorMessage(e.getMessage())+ '[' + e.getLineNumber() + ']';
            System.debug(e.getStackTraceString());
        }
        return rd;
    }
    //签退操作
    @AuraEnabled
    public static ReturnData checkOut(String attendanceId, String curStatus,String storeId, String planId, Decimal lati, Decimal lng, String device, String addressStr){
        ReturnData rd = new ReturnData();
        rd.dataList = new List<DataSet>();
        rd.isSuccess = true;
        try {
            Shop__c shopItem = CheckInCheckOutService.getShopItem(storeId);
            if( lati<>null && lng <>null) {
                Promoter_Attendance__c paItem = new Promoter_Attendance__c();
                Profile profileItem = getProfileItem(UserInfo.getProfileId());
                rd.userType = profileItem.Name;
                if(profileItem.Name == PROMOTE_PROFILE){
                    paItem.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('PromoterAttendance').getRecordTypeId();
                    //checkInPromote(attendanceId, curStatus, shopItem, storeId, planId, lati, lng, device, rd);
                }else{
                    paItem.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('InspectorAttendace').getRecordTypeId();
                    List<Inspection_Shop_Task__c> istOtherList = getOtherShopTaskList(thisDay, UserInfo.getUserId() , storeId);
                    if(istOtherList.size() > 0) {
                        rd.isSuccess = false;
                        rd.failMessage = HAS_OTHER_USER_SHOP_TASK;
                        return rd;
                    }else{
                        CheckInCheckOutService.createInspectionShopTask(storeId);
                    }
                }
                paItem.CheckOutShop__c = storeId;//签退门店
                paItem.CheckIn_Date__c = thisDay;
                paItem.CheckOutDevice__c = device;
                paItem.SignOutTime__c = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());

                paItem.SignOutLocation__Latitude__s = lati;
                paItem.SignOutLocation__Longitude__s = lng;
                paItem.CheckOutAddress__c = addressStr;
                
                
                if(shopItem.Shop_Center_Location__c <> null){
                    Location locItem = Location.newInstance(Double.Valueof(lati), Double.Valueof(lng));
                    Decimal distance = Location.getDistance(locItem, shopItem.Shop_Center_Location__c, 'km')*1000;
                    paItem.SignOut_Distance__c = distance.setScale(2);
                }

                if(curStatus == '已签到'){
                    paItem.CheckInStatus__c = '已签到签退';
                    
                }else{
                    paItem.CheckInStatus__c = '已签退';
                    
                }
                paItem.ExternalId__c = UserInfo.getUserId() + '_' + String.valueOf(paItem.CheckIn_Date__c);
                // upsert paItem ExternalId__c;
                CheckInCheckOutService.createPromoterAttendance(paItem);
                // wfc 巡店员在负责人为空的门店签到过，将这个巡店员自动添加为门店负责人
                CheckInCheckOutService.autoSaveResponsiblePerson(storeId, UserInfo.getUserId());
            }else{
                rd.isSuccess = false;
                rd.failMessage = WITHOUT_DISTANCE;
            }
        } catch (Exception e) {
            rd.isSuccess = false;
            rd.failMessage = CONTACT_ADMIN_OR_REFRESH + ' ' + getProperErrorMessage(e.getMessage())+ '[' + e.getLineNumber() + ']';
            System.debug(e.getStackTraceString());
        }
        return rd;
    }
    // 获取存在的考勤信息
    public static List<Promoter_Attendance__c> getExistAttendance(String externalId) {
        return [
                SELECT 
                    Id,
                    CheckInStatus__c,
                    Shop__c,
                    Shop__r.Name,
                    CheckOutShop__c, 
                    CheckOutShop__r.Name
                FROM Promoter_Attendance__c 
                WHERE 
                    ExternalId__c =: externalId];
    }
    // 获取存在的考勤信息的label
    public static Map<Id, Promoter_Attendance__c> getAttendanceLabel(List<String> idList) {
        return new Map<Id, Promoter_Attendance__c>([
            SELECT 
                Id,
                InspectionShopTask__c,
                CheckOutShop__r.Name,
                Shop__r.Name,
                CheckOutShop__r.Account__r.Name,
                Shop__r.Account__r.Name,
                CheckOutShop__r.Shop_Center_Location__c,
                Shop__r.Shop_Center_Location__c,
                TOLABEL(CheckInStatus__c),
                TOLABEL(InspectionShopTask__r.Status__c)
            FROM 
                Promoter_Attendance__c 
            WHERE 
                Id IN: idList
        ]);
    }
    //获取搜索门店对应的巡店任务
    public static List<Inspection_Shop_Task__c> getInspectionTaskList (List<String> externalIdList, String userId){
        return [
                SELECT 
                    Id,
                    Shop__c,
                    Status__c,
                    Inspection_Date__c
                FROM Inspection_Shop_Task__c
                WHERE ExternalId__c IN: externalIdList
                AND OwnerId =: userId
        ];
    }
    //获取存在的巡店任务
    public static List<Inspection_Shop_Task__c> getTaskList(Date day, String userId) {
        return [
                SELECT 
                    Id,
                    Shop__c,
                    Shop__r.Name,
                    Shop__r.Account__r.Name,
                    Shop__r.Shop_Center_Location__c,
                    Status__c
                FROM 
                    Inspection_Shop_Task__c 
                WHERE 
                    Inspection_Date__c =: day
                AND 
                    OwnerId =: userId];
    }
    //获取存在的门店巡店任务
    public static List<Inspection_Shop_Task__c> getShopTaskList(Date day, String userId, String shopId) {
        return [
                SELECT 
                    Id,
                    Shop__c,
                    Shop__r.Name,
                    Shop__r.Account__r.Name,
                    Shop__r.Shop_Center_Location__c,
                    Status__c
                FROM 
                    Inspection_Shop_Task__c 
                WHERE 
                    Inspection_Date__c =: day
                AND 
                    OwnerId =: userId
                AND 
                    Shop__c =: shopId];
    }
    //获取其他人存在的门店巡店任务
    public static List<Inspection_Shop_Task__c> getOtherShopTaskList(Date day, String userId, String shopId) {
        return [
                SELECT 
                    Id,
                    Shop__c,
                    Shop__r.Name,
                    Shop__r.Account__r.Name,
                    Shop__r.Shop_Center_Location__c,
                    Status__c
                FROM 
                    Inspection_Shop_Task__c 
                WHERE 
                    Inspection_Date__c =: day
                AND 
                    OwnerId <>: userId
                AND 
                    Shop__c =: shopId];
    }

    //获取存在的巡店计划
    public static List<Inspection_Shop_Plan__c> getPlan(String year, String month, String userId) {
        return [
            SELECT 
                Id
            FROM Inspection_Shop_Plan__c 
            WHERE 
                Inspection_Year__c =: year
            AND 
                Inspection_Month__c =: month
            AND 
                OwnerId =: userId
            LIMIT 1
        ];
    }
    //获取促销员负责门店
    public static List<Responsible_Person__c> getResponsibleShop(String userId, String type) {
        return [SELECT 
                    Id,
                    Shop_Name__c,
                    Shop_Name__r.Name,
                    Shop_Name__r.Account__r.Name,
                    Shop_Name__r.Shop_Center_Location__c,
                    RecordType__c,
                    Principal__c 
                FROM Responsible_Person__c
                WHERE 
                    Principal__c =: userId
                AND 
                    RecordType__c =: type ];
    }   
    //获取当前用户简档
    public static Profile getProfileItem(String profileId) {
        return [SELECT 
                    Id,
                    Name 
                FROM 
                    Profile 
                WHERE 
                    Id =: profileId ];
    }
    // //获取签到签退时门店经纬度信息
    // public static Shop__c getShopItem(String storeId) {
    //     return [SELECT 
    //                 Id,
    //                 Shop_Center_Location__c
    //             FROM Shop__c 
    //             WHERE 
    //                 Id =: storeId];
    // }
    //通过关键词查找门店
    // public static List<List<sObject>> getShopList(String searchInfo) {
    //     return [
    //             FIND 
    //                 :searchInfo 
    //             IN 
    //                 ALL FIELDS 
    //             RETURNING 
    //                 Shop__c(
    //                     Id,
    //                     Name,
    //                     Account__c,
    //                     Account__r.Name,
    //                     Shop_Center_Location__c WHERE isLocationEmpty__c = false LIMIT 100 )
    //     ];
    // }
    // 初始化促销员考勤门店选择数据
    public static ReturnData initStoreInfoPromote(String lati, String lng, ReturnData rd, Promoter_Attendance__c existAttendanceLabel) {
        Location locItem;
        if(String.isNotBlank(lati) && String.isNotBlank(lng)){
            locItem = Location.newInstance(Double.Valueof(lati), Double.Valueof(lng));
        }
        system.debug('locItem'+locItem);
        List<Responsible_Person__c> rpList = getResponsibleShop(UserInfo.getUserId(), PROMOTE_PROFILE);
        /*
        Map<String, Promoter_Attendance__c> paMap = new Map<String, Promoter_Attendance__c>();
        List<String> paIdList = new List<String>();
        for(Promoter_Attendance__c paItem : getAttendance(UserInfo.getUserId(), thisDay)) {
            paMap.put(paItem.Shop__c, paItem);
            paIdList.add(paItem.Id);
        }
        Map<Id, Promoter_Attendance__c> paLabelMap = getAttendanceLabel(paIdList);
        */
        //促销员作为门店负责人的门店
        Boolean checkInResponsibleflag = false;
        Boolean checkOutResponsibleflag = false;
        for (Responsible_Person__c rpItem : rpList) {
            DataSet dataItem = new DataSet();
            dataItem.Id = rpItem.Shop_Name__c;
            dataItem.Name = rpItem.Shop_Name__r.Name;
            dataItem.Channel = rpItem.Shop_Name__r.Account__r.Name;
            dataItem.Remark = RESPONSIBLE_PERSON;
            //dataItem.PlanStatus = RESPONSIBLE_PERSON;
            //dataItem.PlanStatusLabel = RESPONSIBLE_PERSON;
            if(locItem<>null && rpItem.Shop_Name__r.Shop_Center_Location__c <> null) {
                Decimal distance = Location.getDistance(locItem, rpItem.Shop_Name__r.Shop_Center_Location__c, 'km');
                dataItem.Distance = distance.setScale(2);
            }
            if(rd.checkInShop == dataItem.Id && rd.checkOutShop == dataItem.Id) {
                dataItem.CheckInStatusLabel = CHECK_IN_OUT_SHOP;
                checkInResponsibleflag = true;
                checkOutResponsibleflag = true;
            }else if(rd.checkInShop == dataItem.Id) {
                dataItem.CheckInStatusLabel = CHECK_IN_SHOP;
                checkInResponsibleflag = true;
            }else if(rd.checkOutShop == dataItem.Id) {
                dataItem.CheckInStatusLabel = CHECK_OUT_SHOP;
                checkOutResponsibleflag = true;
            }
            /*2022/02/14 
            if(paMap.containskey(rpItem.Shop_Name__c)) {
                dataItem.CheckInStatus = paMap.get(rpItem.Shop_Name__c).CheckInStatus__c;
                dataItem.AttendanceId = paMap.get(rpItem.Shop_Name__c).Id;
                dataItem.CheckInStatusLabel = paLabelMap.get(dataItem.AttendanceId).CheckInStatus__c;
            }*/
            rd.dataList.add(dataItem);
        }
        //促销员签到签退的门店非负责门店
        if(existAttendanceLabel <> null && (existAttendanceLabel.CheckOutShop__c<> null || existAttendanceLabel.Shop__c <> null)){
            if(!(checkInResponsibleflag && checkOutResponsibleflag) && existAttendanceLabel.CheckOutShop__c == existAttendanceLabel.Shop__c) {
                //签到签退门店都非负责门店，且相同门店
                DataSet dataItem = new DataSet();
                dataItem.Id = existAttendanceLabel.Shop__c;
                dataItem.Name = existAttendanceLabel.Shop__r.Name;
                dataItem.Channel = existAttendanceLabel.Shop__r.Account__r.Name;
                dataItem.Remark = NOT_RESPONSIBLE_PERSON;
                //dataItem.PlanStatus = NOT_RESPONSIBLE_PERSON;
                //dataItem.PlanStatusLabel = NOT_RESPONSIBLE_PERSON;
                if(locItem<>null && existAttendanceLabel.Shop__r.Shop_Center_Location__c <> null) {
                    Decimal distance = Location.getDistance(locItem, existAttendanceLabel.Shop__r.Shop_Center_Location__c, 'km');
                    dataItem.Distance = distance.setScale(2);
                }
                dataItem.CheckInStatusLabel = CHECK_IN_OUT_SHOP;
                rd.dataList.add(dataItem);
            }else{
                if(!checkInResponsibleflag && existAttendanceLabel.Shop__c <> null) {
                    //签到非负责门店
                    DataSet dataItem = new DataSet();
                    dataItem.Id = existAttendanceLabel.Shop__c;
                    dataItem.Name = existAttendanceLabel.Shop__r.Name;
                    dataItem.Channel = existAttendanceLabel.Shop__r.Account__r.Name;
                    dataItem.Remark = NOT_RESPONSIBLE_PERSON;
                    //dataItem.PlanStatus = NOT_RESPONSIBLE_PERSON;
                    //dataItem.PlanStatusLabel = NOT_RESPONSIBLE_PERSON;
                    if(locItem<>null && existAttendanceLabel.Shop__r.Shop_Center_Location__c <> null) {
                        Decimal distance = Location.getDistance(locItem, existAttendanceLabel.Shop__r.Shop_Center_Location__c, 'km');
                        dataItem.Distance = distance.setScale(2);
                    }
                    dataItem.CheckInStatusLabel = CHECK_IN_SHOP;
                    rd.dataList.add(dataItem);
                }
                if(!checkOutResponsibleflag && existAttendanceLabel.CheckOutShop__c<> null) {
                    //签退非负责门店
                    DataSet dataItem = new DataSet();
                    dataItem.Id = existAttendanceLabel.CheckOutShop__c;
                    dataItem.Name = existAttendanceLabel.CheckOutShop__r.Name;
                    dataItem.Channel = existAttendanceLabel.CheckOutShop__r.Account__r.Name;
                    dataItem.Remark = NOT_RESPONSIBLE_PERSON;
                    //dataItem.PlanStatus = NOT_RESPONSIBLE_PERSON;
                    //dataItem.PlanStatusLabel = NOT_RESPONSIBLE_PERSON;
                    if(locItem != null && existAttendanceLabel.CheckOutShop__r.Shop_Center_Location__c != null) {
                        Decimal distance = Location.getDistance(locItem, existAttendanceLabel.CheckOutShop__r.Shop_Center_Location__c, 'km');
                        dataItem.Distance = distance.setScale(2);
                    }
                    dataItem.CheckInStatusLabel = CHECK_OUT_SHOP;
                    rd.dataList.add(dataItem);
                }
            }

        }

        /*
        for(Promoter_Attendance__c paItem : paMap.values()) {
            Boolean flag = true;
            for(DataSet dataItem : rd.dataList) {
                if(dataItem.AttendanceId == paItem.Id) {
                    flag = false;
                }
            }
            if(flag) {
                //如果不是门店负责人，但是打了这个门店的卡，也需要显示在页面
                DataSet dataItem = new DataSet();
                dataItem.Id = paItem.Shop__c;
                dataItem.Name = paItem.Shop__r.Name;
                dataItem.Channel = paItem.Shop__r.Account__r.Name;

                //dataItem.PlanStatus = NOT_RESPONSIBLE_PERSON;
                //dataItem.PlanStatusLabel = NOT_RESPONSIBLE_PERSON;
                if(locItem<>null && paItem.Shop__r.Shop_Center_Location__c <> null) {
                    Decimal distance = Location.getDistance(locItem, paItem.Shop__r.Shop_Center_Location__c, 'km');
                    dataItem.Distance = distance.setScale(2);
                }

                dataItem.CheckInStatusLabel = CHECK_IN_SHOP;
                rd.dataList.add(dataItem);
            }
        }
        */
        rd.dataList.sort();
        return rd;
    }
    //初始化巡店员考勤门店选择数据
    public static ReturnData initStoreInfoInspection(String lati, String lng, ReturnData rd, List<Promoter_Attendance__c> attendanceList) {
        //Date day = System.Today();
        //Date thisDay =  Date.newInstance(2021, 12, 25);
        //rd.thisDay = thisDay;
        Location locItem;
        if(String.isNotBlank(lati) && String.isNotBlank(lng)){
            locItem = Location.newInstance(Double.Valueof(lati), Double.Valueof(lng));
        }

        List<Inspection_Shop_Task__c> shopTaskList = getTaskList(thisDay, UserInfo.getUserId());
        //Map<Id, Inspection_Shop_Task__c> shopTaskMap = getShopTaskListLabel(thisDay, UserInfo.getUserId());
        //获取巡店员的考勤信息
        /*
        Map<String, Promoter_Attendance__c> paMap = new Map<String, Promoter_Attendance__c>();
        List<String> paIdList = new List<String>();
        for(Promoter_Attendance__c paItem : getAttendance(UserInfo.getUserId(), thisDay)) {
            paMap.put(paItem.Shop__c, paItem);
            paIdList.add(paItem.Id);
        }
        Map<Id, Promoter_Attendance__c> paLabelMap = getAttendanceLabel(paIdList);
        */
        
        //已经签到签退的门店一定会有巡店任务，所以不需要额外的添加签到签退门店无巡店任务的情况
        for (Inspection_Shop_Task__c taskItem : shopTaskList) {
            DataSet dataItem = new DataSet();
            dataItem.Id = taskItem.Shop__c;
            dataItem.Name = taskItem.Shop__r.Name;
            dataItem.Channel = taskItem.Shop__r.Account__r.Name;

            //判断是否为计划内任务
            if(taskItem.Status__c == NOT_PLAN_ATTENDANCE){
                dataItem.Remark = NOT_PLAN_ATTENDANCE_LABEL;
            }else{
                dataItem.Remark = PLAN_ATTENDANCE;
            }
            
            if(locItem<>null && taskItem.Shop__r.Shop_Center_Location__c <> null){
                Decimal distance = Location.getDistance(locItem, taskItem.Shop__r.Shop_Center_Location__c, 'km');
                dataItem.Distance = distance.setScale(2);
            }

            //判断是否为签到签退门店
            dataItem = judgeCheckInShop(dataItem, attendanceList);
            //dataItem.CheckInStatus = taskItem.CheckInStatus__c;
            //dataItem.CheckInStatusLabel = shopTaskMap.get(taskItem.Id).CheckInStatus__c;
            /*
            if(taskItem.Status__c == NOT_PLAN_ATTENDANCE) {
                dataItem.PlanStatus = taskItem.Status__c;
                dataItem.PlanStatusLabel = shopTaskMap.get(taskItem.Id).Status__c;
            }else{
                dataItem.PlanStatus = PLAN_ATTENDANCE;
                dataItem.PlanStatusLabel = PLAN_ATTENDANCE;
            }

            dataItem.PlanId = taskItem.Id;

            
            //获取巡店员的考勤信息
            if(paMap.containskey(taskItem.Shop__c)) {
                dataItem.CheckInStatus = paMap.get(taskItem.Shop__c).CheckInStatus__c;
                dataItem.AttendanceId = paMap.get(taskItem.Shop__c).Id;
                dataItem.CheckInStatusLabel = paLabelMap.get(dataItem.AttendanceId).CheckInStatus__c;
            }
            */
            rd.dataList.add(dataItem);
        }
        rd.dataList.sort();
        return rd;
    }
    //判断门店是否为签到签退门店
    public static DataSet judgeCheckInShop(DataSet dataItem,List<Promoter_Attendance__c> attendanceList) {
        if(attendanceList.size() > 0){
            //判断门店是否为签到签退门店
            Boolean checkInflag = false;
            Boolean checkOutflag = false;
            if (dataItem.Id == attendanceList[0].Shop__c) {
                checkInflag = true;
            }
            if( dataItem.Id == attendanceList[0].CheckOutShop__c) {
                checkOutflag = true;
            }

            if(checkInflag && checkOutflag) {
                dataItem.CheckInStatusLabel = CHECK_IN_OUT_SHOP;
            }else if(checkInflag) {
                dataItem.CheckInStatusLabel = CHECK_IN_SHOP;
            }else if(checkOutflag) {
                dataItem.CheckInStatusLabel = CHECK_OUT_SHOP;
            }
        }
        return dataItem;
    }
    // //创建巡店任务
    // public static void createInspectionShopTask(String shopId) {
    //     List<Inspection_Shop_Task__c> istList = getShopTaskList(thisDay, UserInfo.getUserId() , shopId);
    //     if(istList.size() <= 0) {
    //         //若该巡店任务不存在，则需要额外创建
    //         Inspection_Shop_Task__c istItem = new Inspection_Shop_Task__c();   
    //         List<Inspection_Shop_Plan__c> ispList = getPlan(String.valueOf(thisDay.year()) , String.valueOf(thisDay.month()), UserInfo.getUserId());
    //         Inspection_Shop_Plan__c ispItem;
    //         if(ispList.size() > 0){
    //             ispItem = ispList[0];
    //         }else{
    //             ispItem = new Inspection_Shop_Plan__c();
    //             ispItem.Inspection_Year__c = String.valueOf(thisDay.year());
    //             ispItem.Inspection_Month__c = String.valueOf(thisDay.month());
    //             insert ispItem;
    //         }

    //         istItem.Shop__c = shopId;
    //         istItem.Inspection_Date__c = thisDay;
    //         istItem.Status__c = NOT_PLAN_ATTENDANCE;
    //         istItem.Inspection_Plan__c = ispItem.Id;
    //         insert istItem;
    //     }
    // }
    //处理报错信息
    public static String getProperErrorMessage(String exceptionMsg){
        //validation error message
        if(exceptionMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            exceptionMsg = exceptionMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,', ': [');
        }else if(exceptionMsg.contains('ENTITY_IS_LOCKED')){
            exceptionMsg = 'The record has been locked!';    
        }else if(exceptionMsg.contains('FIELD_INTEGRITY_EXCEPTION')){
            exceptionMsg = exceptionMsg.substringBetween('FIELD_INTEGRITY_EXCEPTION,', ': [');
        }else if(exceptionMsg.contains('FIELD_FILTER_VALIDATION_EXCEPTION')){
            exceptionMsg = exceptionMsg.substringBetween('FIELD_FILTER_VALIDATION_EXCEPTION,', ': [');
        }else if(exceptionMsg.contains('DUPLICATE_VALUE')) {
            exceptionMsg = exceptionMsg.substringBetween('DUPLICATE_VALUE,', ': [');
        }else if(exceptionMsg.contains('DUPLICATES_DETECTED')) {
            exceptionMsg = exceptionMsg.substringBetween('DUPLICATES_DETECTED,', ': [');
        }        
        return exceptionMsg;
    }
    /**
     * Method : geolocationGetAddress
     * Function : Get address by geolocation lat&lng through geolocation api
     * Params : String lat, String lng
     * Return : String
     * Author : Chiara
     * Date : 2020/01/12
     */
    @AuraEnabled
    public static String geolocationGetAddress(String lat, String lng){
        String address = '';
        String compoundCode = '';
        try {
            system.debug( 'wwww:' + lat);
            system.debug( 'wwww:' + lng);
            // lng = '120.426940';
            // lat = '36.161250';
            if(String.isNotEmpty(lat) && String.isNotEmpty(lng)) {
                lat = truncateDecimal(lat);
                lng = truncateDecimal(lng);
            }
            // lat = '36.19715';
            // lng = '120.515946';

            system.debug( 'wwww:' + lat);
            system.debug( 'wwww:' + lng);
            //发送请求
            // String requestUrl = 'https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyAucQYfZ2tw2RBO7jieFwG27-BeldZVgFY&location_type=ROOFTOP&result_type=street_address';
            String requestUrl = 'https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyAevReUCBK5ntbBf525M-O31NcDc_Q-130&location_type=ROOFTOP&result_type=street_address';
            User currentUser = [SELECT Id,LanguageLocaleKey FROM User WHERE Id =: UserInfo.getUserId()];
            requestUrl = requestUrl + '&language=' + currentUser.LanguageLocaleKey + '&latlng=' + lat + ',' + lng;
            System.debug(requestUrl);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(requestUrl);
            req.setMethod('GET');
             
            String doc = '';
            Http h = new Http();
            if (!Test.isRunningTest()){ 
                HttpResponse res = h.send(req);
                doc = res.getBody();
            }
            
            //提取地址信息
            Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(doc);
            
            if(String.valueOf(resultMap.get('status')) == 'OK'){
                List<Object> addressList = (List<Object>) resultMap.get('results');
                Map<String, Object> addressMap = (Map<String, Object>)addressList[0];
                address = (String)addressMap.get('formatted_address');
            }
            if(String.isEmpty(address)) {
                System.debug('plusCodeMap ' + resultMap.get('plus_code'));
                String codeResult = resultMap.get('plus_code') + '';
                if(String.isNotEmpty(codeResult)) {
                    Integer startIndex = codeResult.indexOf('=') + 1;
                    Integer endIndex = codeResult.indexOf('global_code');                    
                    compoundCode = codeResult.substring(startIndex, endIndex).trim();
                    Integer resultIndex = compoundCode.lastIndexOf(',');
                    compoundCode = compoundCode.substring(0,resultIndex);
                }
                address = compoundCode;
            }
            system.debug( 'resultMap:' + resultMap);
            system.debug(address);
            return address;
        } catch (Exception e) {
            System.debug(e);
            return address;
        } 
    }

    public static String truncateDecimal(String input) {
        if (String.isBlank(input) || !input.contains('.')) {
            return input;
        }
        String[] parts = input.split('\\.', 2);
        if (parts.size() < 2) {
            return input;
        }
        String decimalPart = parts[1];
        if (decimalPart.length() <= 6) {
            return input;
        }
        String truncatedDecimal = decimalPart.substring(0, 6);
        System.debug('小数' + truncatedDecimal);
        return parts[0] + '.' + truncatedDecimal;
    }

    public class DataSet implements Comparable {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name; //门店名称W
        @AuraEnabled public String Channel; //经销商渠道
        @AuraEnabled public Decimal Distance; //距离km
        @AuraEnabled public String Remark;//标记

        //以下为注释内容
        @AuraEnabled public String CheckInStatusLabel;//考勤状态标签
        @AuraEnabled public String CheckInStatus;//考勤状态
        @AuraEnabled public String PlanStatusLabel;//备注标签,促销员：RESPONSIBLE_PERSON 巡店员：计划内到访，计划外到访
        @AuraEnabled public String PlanStatus;//备注

        @AuraEnabled public String PlanId;//巡店任务id，或促销员考勤id
        @AuraEnabled public String AttendanceId;//巡店员考勤id
        public Integer compareTo(Object compareTo) {
            // Cast argument to FieldInfo
            DataSet compareToObj= (DataSet)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (Distance > compareToObj.Distance) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (Distance < compareToObj.Distance) {
                // Set return value to a negative value.
                returnValue = -1;
            } else if ((Distance == null) && (compareToObj.Distance != null)){
                // nulls-first implementation
                returnValue = 1;
            } else if ((Distance != null) && (compareToObj.Distance == null)){
                // nulls-first implementation
                returnValue = -1;
            }        
            return returnValue;  
        }
    }

    /**
     * Method : getPromoterAttendance
     * Function : 获取用户当天考勤Id
     * Return : String 当天考勤Id
     * Author : Rain
     * Date : 2022/04/24
     */
    @AuraEnabled
    public static string getPromoterAttendance(){
        String recordId = '';
        List<Promoter_Attendance__c> paList = [SELECT Id FROM Promoter_Attendance__c WHERE CheckIn_Date__c = :thisday AND OwnerId = :System.UserInfo.getUserId()];
        if(paList != null && paList.size() > 0) {
            recordId = paList[0].Id;
        }
        return recordId;
    }

    public class ReturnData {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String failMessage;
        @AuraEnabled public List<DataSet> dataList;
        @AuraEnabled public Date thisDay;
        @AuraEnabled public String userType;
        @AuraEnabled public String addressStr;
        @AuraEnabled public String checkInId;//考勤记录
        @AuraEnabled public String checkInStatus;//考勤状态
        @AuraEnabled public String checkInStatusLabel;//考勤状态标签
        @AuraEnabled public String checkInShop;
        @AuraEnabled public String checkOutShop;

    }
}