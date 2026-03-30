/**
 * NewCheckInCheckOutController
 * Purpose:
 * Author: Yin Mingjie
 * Date: 2023/06/06
 * ---------------------------------------------------------------------------
 * History Tracking
 * 
 */
public without sharing class NewCheckInCheckOutController {

    private static String WITHOUT_DISTANCE = System.Label.CheckInCheckOut_WITHOUT_POSITION;//未获取当前定位信息，不可签到
    private static String PROMOTE_PROFILE = '促销员';
    private static String PROMOTE_PROFILE_EN = 'Promote';
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
    private static String OUT_OF_RANGE = System.Label.CheckInCheckOut_OUT_OF_RANGE;//超出范围
    private static String WITHIN_RANGE = System.Label.CheckInCheckOut_WITHIN_RANGE;//在范围内
    private static String Attendance_Rule_NULL = System.Label.CheckInCheckOut_Attendance_Rule_NULL;//无考勤规则

    public static Date thisDay = System.today();//Date.newInstance(2021, 12, 25); //测试后改成System.today()
    public static String thisTime = DateTime.now().format('HH:mm',UserInfo.getTimeZone().getId());//Date.newInstance(2021, 12, 25); //测试后改成System.today()
    //初始化考勤信息页面
    @AuraEnabled
    public static ReturnData initStoreInfo(String lati, String lng) {
        ReturnData rd = new ReturnData();
        rd.dataList = new List<DataSet>();
        rd.isSuccess = true;
        rd.thisDay = thisDay;
        rd.thisTime = thisTime;
        try{
            System.debug('<><<<><><><><><><<>><><><><>'+UserInfo.getUserId() + '_' + String.valueOf(thisDay));
            List<Promoter_Attendance__c> attendanceList = getExistAttendance(UserInfo.getUserId() + '_' + String.valueOf(thisDay));
            System.debug('attendanceList>>>>>>>>'+attendanceList);
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

                rd.checkInType = attendanceList[0].Check_in_Type__c;
                rd.checkInTimeStatus = attendanceList[0].Check_in_Status__c;
                rd.checkInShopName = attendanceList[0].Shop__r.Name;
                rd.checkInAddress = attendanceList[0].CheckInAddress__c;
                rd.checkInTime = attendanceList[0].SignInTime__c!=null ? String.valueOf(attendanceList[0].SignInTime__c).subString(0,5) : null;

                rd.checkOutType = attendanceList[0].Check_out_Type__c;
                rd.checkOutTimeStatus = attendanceList[0].Check_out_Status__c;
                rd.checkOutShopName = attendanceList[0].CheckOutShop__r.Name;
                rd.checkOutAddress = attendanceList[0].CheckOutAddress__c;
                rd.checkOutTime = attendanceList[0].SignOutTime__c!=null ? String.valueOf(attendanceList[0].SignOutTime__c).subString(0,5) : null;
            }else{
                //不存在考勤信息
                rd.checkInStatus = '未签到';
                rd.checkInStatusLabel = NOT_CHECK_IN;
            }

            Profile profileItem = getProfileItem(UserInfo.getProfileId());
            system.debug('profileItem'+profileItem);
            rd.userType = profileItem.Name;
            if(profileItem.Name.contains(PROMOTE_PROFILE) || profileItem.Name.contains(PROMOTE_PROFILE_EN)){
                rd = initStoreInfoPromote(lati, lng, rd, existAttendanceLabel);
            }else{
            //else if(profileItem.Name == INSPECTION_PROFILE) {
                // rd = initStoreInfoInspection(lati, lng, rd, attendanceList);
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

    @AuraEnabled
    public static String getBase64Stream(String contentVersionId) {
        String base64Str = '';
        try {
            if (contentVersionId!=null) {
                ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE Id =:contentVersionId];
                if (cv!=null) {
                    base64Str = JSON.serialize(cv.VersionData);
                }
            }
            return base64Str;
        } catch (Exception e) {
            return base64Str;
        }
    }

    //签到操作
    @AuraEnabled(cacheable=false)
    public static ReturnData checkIn(String curStatus,String storeId, Decimal lati, Decimal lng, String device, String addressStr, String remark, String photoStream, String navigatorInfo){
        return checkInCore(curStatus, storeId, lati, lng, device, addressStr, remark, photoStream, navigatorInfo, false);
    }
    
    public static ReturnData checkInCore(String curStatus,String storeId, Decimal lati, Decimal lng, String device, String addressStr, String remark, String photoStream, String navigatorInfo, Boolean isSystemAuto) {
        ReturnData rd = new ReturnData();
        rd.dataList = new List<DataSet>();
        rd.isSuccess = true;
        try {
            Shop__c shopItem = CheckInCheckOutService.getShopItem(storeId);
            if( lati<>null && lng <>null) {
                Promoter_Attendance__c paItem = new Promoter_Attendance__c();
                if (String.isNotBlank(photoStream)) {
                    paItem.Check_In_Has_Photo__c = 'Yes';
                }
                List<Promoter_Attendance__c> attendanceList = getExistAttendance(UserInfo.getUserId() + '_' + String.valueOf(thisDay));

                Profile profileItem = getProfileItem(UserInfo.getProfileId());
                rd.userType = profileItem.Name;
                if(profileItem.Name.contains(PROMOTE_PROFILE) || profileItem.Name.contains(PROMOTE_PROFILE_EN)){
                    paItem.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('PromoterAttendance').getRecordTypeId();
                 }else{
                    // paItem.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('InspectorAttendace').getRecordTypeId();
                    // List<Inspection_Shop_Task__c> istOtherList = getOtherShopTaskList(thisDay, UserInfo.getUserId() , storeId);
                    // if(istOtherList.size() > 0) {
                    //     rd.isSuccess = false;
                    //     rd.failMessage = HAS_OTHER_USER_SHOP_TASK;
                    //     return rd;
                    // }else{
                    //     CheckInCheckOutService.createInspectionShopTask(storeId);
                    // }   
                }    
                
                Time nowTime = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
                Decimal distance;
                if(shopItem.Shop_Center_Location__c <> null) {
                    Location locItem = Location.newInstance(Double.Valueof(lati), Double.Valueof(lng));
                    distance = Location.getDistance(locItem, shopItem.Shop_Center_Location__c, 'km')*1000;
                }
                List<Promoter_Attendance_Rule__c> parList = getPromoterAttendanceRule(UserInfo.getUserId(), storeId, PROMOTE_PROFILE);
                Promoter_Attendance_Rule__c par = parList[0];

                String checkInDistance;
                String CheckInStatus;
                if(distance <> null) {
                    if (par.Distance__c >= distance.setScale(2)) {
                        checkInDistance = 'Onsite';
                    } else {
                        checkInDistance = 'Offsite';
                    }
                }

                Integer addMin = par.Time_buffer__c>0 ? Integer.valueOf(par.Time_buffer__c) : 0;
                if (par.Start_time__c.addMinutes(addMin) >= nowTime) {
                    CheckInStatus = 'Check in';
                } else {
                    CheckInStatus = 'Late Check in';
                }

                if (attendanceList.size()>0) {
                    paItem = attendanceList[0];
                    paItem.Shop__c = paItem.Shop__c==null?storeId:paItem.Shop__c;
                    paItem.CheckIn_Date__c = paItem.CheckIn_Date__c==null?thisDay:paItem.CheckIn_Date__c;
                    paItem.CheckInDevice__c = paItem.CheckInDevice__c==null?device:paItem.CheckInDevice__c;
                    paItem.SignInLocation__Latitude__s = paItem.SignInLocation__Latitude__s==null?lati:paItem.SignInLocation__Latitude__s;
                    paItem.SignInLocation__Longitude__s = paItem.SignInLocation__Longitude__s==null?lng:paItem.SignInLocation__Longitude__s;
                    paItem.SignInTime__c = paItem.SignInTime__c==null?nowTime:paItem.SignInTime__c;
                    paItem.CheckInAddress__c = paItem.CheckInAddress__c==null?addressStr:paItem.CheckInAddress__c;
                    if(distance <> null) {
                        paItem.Signin_Distance__c = paItem.Signin_Distance__c==null?distance.setScale(2):paItem.Signin_Distance__c;
                        paItem.Check_in_Type__c = paItem.Check_in_Type__c==null?checkInDistance:paItem.Check_in_Type__c;
                    }
                    paItem.Check_in_Status__c = paItem.Check_in_Status__c==null?CheckInStatus:paItem.Check_in_Status__c;

                    if(curStatus == '已签退' || curStatus == '已签到签退'){
                        paItem.CheckInStatus__c = '已签到签退';
                    } else {
                        paItem.CheckInStatus__c = '已签到';
                    }
                } else {
                    paItem.Shop__c = storeId;
                    paItem.CheckIn_Date__c = thisDay;
                    paItem.CheckInDevice__c = device;
                    paItem.SignInLocation__Latitude__s = lati;
                    paItem.SignInLocation__Longitude__s = lng;
                    paItem.SignInTime__c = nowTime;
                    paItem.CheckInAddress__c = addressStr;
                    if(distance <> null) {
                        paItem.Signin_Distance__c = distance.setScale(2);
                        paItem.Check_in_Type__c = checkInDistance;
                    }
                    paItem.Check_in_Status__c = CheckInStatus;

                    if(curStatus == '已签退' || curStatus == '已签到签退'){
                        paItem.CheckInStatus__c = '已签到签退';
                    } else {
                        paItem.CheckInStatus__c = '已签到';
                    }
                }
                paItem.ExternalId__c = UserInfo.getUserId() + '_' + String.valueOf(thisDay);
                paItem.OwnerId = UserInfo.getUserId();
                upsert paItem ExternalId__c;
                // CheckInCheckOutService.createPromoterAttendance(paItem);

                Promoter_Attendance_Information__c pai = new Promoter_Attendance_Information__c();
                pai.Promoter_Attendance__c = paItem.Id;
                pai.Shop__c = storeId;
                pai.Address__c = addressStr;
                pai.CheckIn_Date__c = thisDay;
                pai.CheckIn_Time__c = nowTime;
                if(distance <> null) {
                    pai.Distance__c = distance.setScale(2);
                    pai.Check_in_out_Type__c = checkInDistance;
                }
                pai.Location__Latitude__s = lati;
                pai.Location__Longitude__s = lng;
                pai.IsSystemAuto__c = isSystemAuto;
                pai.Type__c = 'Check in';
                pai.Status__c = CheckInStatus;
                pai.Remark__c = remark;
                pai.Navigator_Information__c = navigatorInfo;
                pai = UserDeviceRelated.setPromoterAttendanceInformation(pai);  // IMEI
                insert pai;

                createUploadFile(pai.Id, photoStream);
                // Deloitte Yin Mingjie 20231123 start
                List<Responsible_Person__c> rpList = getResponsibleShop(UserInfo.getUserId(), PROMOTE_PROFILE);
                if (rpList.size()>0) {
                    Map<String, String> inputMap = new Map<String, String>();
                    inputMap.put(rpList[0].Id, pai.Id);
                    SchedulingPlanController.updateTaskStatus(inputMap,System.today(),'checkIn');
                }
                // Deloitte Yin Mingjie 20231123 end
                // update paItem;
                // wfc 巡店员在负责人为空的门店签到过，将这个巡店员自动添加为门店负责人
                // CheckInCheckOutService.autoSaveResponsiblePerson(storeId, UserInfo.getUserId());

                // 发送自动打卡成功提醒
                if (isSystemAuto) {
                    sendNotification('Auto Check in Successfully!', 'Have a Good Day!', UserInfo.getUserId());
                }
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
    public static ReturnData checkOut(String curStatus,String storeId, Decimal lati, Decimal lng, String device, String addressStr, String remark, String photoStream, String navigatorInfo){
        return checkOutCore(curStatus, storeId, lati, lng, device, addressStr, remark, photoStream, navigatorInfo, false);
    }

    public static ReturnData checkOutCore(String curStatus,String storeId, Decimal lati, Decimal lng, String device, String addressStr, String remark, String photoStream, String navigatorInfo, Boolean isSystemAuto){
        ReturnData rd = new ReturnData();
        rd.dataList = new List<DataSet>();
        rd.isSuccess = true;
        try {
            Shop__c shopItem = CheckInCheckOutService.getShopItem(storeId);
            if( lati<>null && lng <>null) {
                Promoter_Attendance__c paItem = new Promoter_Attendance__c();
                if (String.isNotBlank(photoStream)) {
                    paItem.Check_Out_Has_Photo__c = 'Yes';
                }
                // List<Promoter_Attendance__c> attendanceList = getExistAttendance(UserInfo.getUserId() + '_' + String.valueOf(thisDay));

                Profile profileItem = getProfileItem(UserInfo.getProfileId());
                rd.userType = profileItem.Name;
                if(profileItem.Name.contains(PROMOTE_PROFILE) || profileItem.Name.contains(PROMOTE_PROFILE_EN)){
                    paItem.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('PromoterAttendance').getRecordTypeId();
                    //checkInPromote(attendanceId, curStatus, shopItem, storeId, planId, lati, lng, device, rd);
                }else{
                    // paItem.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('InspectorAttendace').getRecordTypeId();
                    // List<Inspection_Shop_Task__c> istOtherList = getOtherShopTaskList(thisDay, UserInfo.getUserId() , storeId);
                    // if(istOtherList.size() > 0) {
                    //     rd.isSuccess = false;
                    //     rd.failMessage = HAS_OTHER_USER_SHOP_TASK;
                    //     return rd;
                    // }else{
                    //     CheckInCheckOutService.createInspectionShopTask(storeId);
                    // }
                }
                
                Time nowTime = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
                Decimal distance;
                if(shopItem.Shop_Center_Location__c <> null) {
                    Location locItem = Location.newInstance(Double.Valueof(lati), Double.Valueof(lng));
                    distance = Location.getDistance(locItem, shopItem.Shop_Center_Location__c, 'km')*1000;
                }
                List<Promoter_Attendance_Rule__c> parList = getPromoterAttendanceRule(UserInfo.getUserId(), storeId, PROMOTE_PROFILE);
                Promoter_Attendance_Rule__c par = parList[0];

                String checkOutDistance;
                String CheckOutStatus;
                if(distance <> null) {
                    if (par.Distance__c >= distance.setScale(2)) {
                        checkOutDistance = 'Onsite';
                    } else {
                        checkOutDistance = 'Offsite';
                    }
                }

                // Integer addMin = par.Time_buffer__c>0 ? Integer.valueOf(par.Time_buffer__c) : 0;
                if (par.End_time__c > nowTime) {
                    CheckOutStatus = 'Early Check out';
                } else {
                    CheckOutStatus = 'Check out';
                }

                paItem.CheckOutShop__c = storeId;//签退门店
                paItem.CheckIn_Date__c = thisDay;
                paItem.CheckOutDevice__c = device;
                paItem.SignOutLocation__Latitude__s = lati;
                paItem.SignOutLocation__Longitude__s = lng;
                paItem.SignOutTime__c = nowTime;
                paItem.CheckOutAddress__c = addressStr;
                if(distance <> null) {
                    paItem.SignOut_Distance__c = distance.setScale(2);
                    paItem.Check_out_Type__c = checkOutDistance;
                }
                paItem.Check_out_Status__c = CheckOutStatus;
                
                if(curStatus == '已签到' || curStatus == '已签到签退'){
                    paItem.CheckInStatus__c = '已签到签退';
                    
                }else{
                    paItem.CheckInStatus__c = '已签退';
                }
                paItem.ExternalId__c = UserInfo.getUserId() + '_' + String.valueOf(paItem.CheckIn_Date__c);
                paItem.OwnerId = UserInfo.getUserId();
                upsert paItem ExternalId__c;
                // CheckInCheckOutService.createPromoterAttendance(paItem);

                Promoter_Attendance_Information__c pai = new Promoter_Attendance_Information__c();
                pai.Promoter_Attendance__c = paItem.Id;
                pai.Shop__c = storeId;
                pai.Address__c = addressStr;
                pai.CheckIn_Date__c = thisDay;
                pai.CheckIn_Time__c = nowTime;
                if(distance <> null) {
                    pai.Distance__c = distance.setScale(2);
                    pai.Check_in_out_Type__c = checkOutDistance;
                }
                pai.Location__Latitude__s = lati;
                pai.Location__Longitude__s = lng;
                pai.IsSystemAuto__c = isSystemAuto;
                pai.Type__c = 'Check out';
                pai.Status__c = CheckOutStatus;
                pai.Remark__c = remark;
                pai.Navigator_Information__c = navigatorInfo;
                pai = UserDeviceRelated.setPromoterAttendanceInformation(pai);  // IMEI
                insert pai;

                createUploadFile(pai.Id, photoStream);
                // Deloitte Yin Mingjie 20231123 start
                List<Responsible_Person__c> rpList = getResponsibleShop(UserInfo.getUserId(), PROMOTE_PROFILE);
                if (rpList.size()>0) {
                    Map<String, String> inputMap = new Map<String, String>();
                    inputMap.put(rpList[0].Id, pai.Id);
                    SchedulingPlanController.updateTaskStatus(inputMap,System.today(),'checkOut');
                }
                // Deloitte Yin Mingjie 20231123 end
                // wfc 巡店员在负责人为空的门店签到过，将这个巡店员自动添加为门店负责人
                // CheckInCheckOutService.autoSaveResponsiblePerson(storeId, UserInfo.getUserId());

                // 发送自动打卡成功提醒
                if (isSystemAuto) {
                    sendNotification('Auto Check out Successfully!', 'Thanks for your hard work!', UserInfo.getUserId());
                }
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
    // 获取考勤规则
    public static List<Promoter_Attendance_Rule__c> getPromoterAttendanceRule (String userId, String shopId, String type) {
        List<Responsible_Person__c> responsiblePersonList = [SELECT
                                                                Id,
                                                                Shop_Name__c,
                                                                Principal__c,
                                                                Promoter_Attendance_Rule__c
                                                            FROM Responsible_Person__c 
                                                            WHERE
                                                                Shop_Name__c = :shopId 
                                                            AND 
                                                                Principal__c = :userId
                                                            AND 
                                                                (
                                                                    RecordType__c = :type
                                                                )];
        if (!(responsiblePersonList.size()>0)) {
            return null;
        }
        // Deloitte Yin Mingjie 20231121 start
        Responsible_Person__c rp = responsiblePersonList[0];
        List<String> rpIds = new List<String>();
        rpIds.add(rp.Id);
        Map<String,Promoter_Attendance_Rule__c> ruleMap = SchedulingPlanController.queryTaskPromoterAttendanceRule(rpIds,System.today());
        if (ruleMap.containsKey(rp.Id)) {
            List<Promoter_Attendance_Rule__c> ruleList = new List<Promoter_Attendance_Rule__c>();
            ruleList.add(ruleMap.get(rp.Id));
            return ruleList;
        }
        // Deloitte Yin Mingjie 20231121 end
        return [SELECT
                    Id,
                    Start_time__c,
                    End_time__c,
                    Time_buffer__c,
                    Need_Check_Distance__c,
                    Distance__c
                FROM Promoter_Attendance_Rule__c 
                WHERE
                    Id = :responsiblePersonList[0].Promoter_Attendance_Rule__c];
    }

    // 获取考勤规则Map
    public static Map<Id, Promoter_Attendance_Rule__c> getPromoterAttendanceRuleMap (Set<Id> idList) {
        return new Map<Id, Promoter_Attendance_Rule__c>([
            SELECT
                Id,
                Start_time__c,
                End_time__c,
                Time_buffer__c,
                Need_Check_Distance__c,
                Distance__c
            FROM Promoter_Attendance_Rule__c 
            WHERE
                Id IN :idList]);
    }

    // 获取存在的考勤信息
    public static List<Promoter_Attendance__c> getExistAttendance(String externalId) {
        return [
                SELECT 
                    Id,
                    CheckInStatus__c,
                    Shop__c,
                    Shop__r.Name,
                    CheckInAddress__c,
                    SignInTime__c,
                    Check_in_Type__c,
                    Check_in_Status__c,
                    CheckOutShop__c, 
                    CheckOutShop__r.Name,
                    CheckOutAddress__c,
                    SignOutTime__c,
                    Check_out_Type__c,
                    Check_out_Status__c,
                    CheckIn_Date__c,
                    CheckInDevice__c,
                    SignInLocation__Latitude__s,
                    SignInLocation__Longitude__s,
                    Signin_Distance__c
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
    //获取促销员负责门店
    public static List<Responsible_Person__c> getResponsibleShop(String userId, String type) {
        
        // Deloitte Yin Mingjie 20231123 start
        List<Responsible_Person__c> rpList = [SELECT 
                                                Id,
                                                Shop_Name__c,
                                                Shop_Name__r.Name,
                                                Shop_Name__r.Shop_Center_Location__Latitude__s,
                                                Shop_Name__r.Shop_Center_Location__Longitude__s,
                                                Shop_Name__r.Account__r.Name,
                                                Shop_Name__r.Shop_Center_Location__c,
                                                RecordType__c,
                                                Principal__c,
                                                Promoter_Attendance_Rule__c 
                                            FROM Responsible_Person__c
                                            WHERE 
                                                Principal__c =: userId
                                            AND 
                                                (
                                                    RecordType__c =: type
                                                )];
        List<String> rpids = new List<String>();
        for (Responsible_Person__c rp : rpList) {
            rpids.add(rp.Id);
        }
        Map<String,Promoter_Attendance_Rule__c> ruleMap = SchedulingPlanController.queryTaskPromoterAttendanceRule(rpIds,System.today());
        for (Responsible_Person__c rp : rpList) {
            if (ruleMap.containsKey(rp.Id)) {
                rp.Promoter_Attendance_Rule__c = ruleMap.get(rp.Id).Id;
            }
        }
        return rpList;
        // return [SELECT 
        //             Id,
        //             Shop_Name__c,
        //             Shop_Name__r.Name,
        //             Shop_Name__r.Shop_Center_Location__Latitude__s,
        //             Shop_Name__r.Shop_Center_Location__Longitude__s,
        //             Shop_Name__r.Account__r.Name,
        //             Shop_Name__r.Shop_Center_Location__c,
        //             RecordType__c,
        //             Principal__c,
        //             Promoter_Attendance_Rule__c 
        //         FROM Responsible_Person__c
        //         WHERE 
        //             Principal__c =: userId
        //         AND 
        //             (RecordType__c =: type
        //             OR 
        //             RecordType__c =: type1)];
        
        // Deloitte Yin Mingjie 20231123 end
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
    // 初始化促销员考勤门店选择数据
    public static ReturnData initStoreInfoPromote(String lati, String lng, ReturnData rd, Promoter_Attendance__c existAttendanceLabel) {
        Location locItem;
        if(String.isNotBlank(lati) && String.isNotBlank(lng)){
            locItem = Location.newInstance(Double.Valueof(lati), Double.Valueof(lng));
        }
        system.debug('locItem'+locItem);
        List<Responsible_Person__c> rpList = getResponsibleShop(UserInfo.getUserId(), PROMOTE_PROFILE);
        System.debug('rpList--->'+rpList);
        //促销员作为门店负责人的门店
        Boolean checkInResponsibleflag = false;
        Boolean checkOutResponsibleflag = false;
        Set<Id> roleIds = new Set<Id>();
        for (Responsible_Person__c rpItem : rpList) {
            roleIds.add(rpItem.Promoter_Attendance_Rule__c);
        }
        Map<Id, Promoter_Attendance_Rule__c> parMap = getPromoterAttendanceRuleMap(roleIds);
        System.debug('parMap--->'+parMap);
        for (Responsible_Person__c rpItem : rpList) {

            if (parMap.get(rpItem.Promoter_Attendance_Rule__c)==null) {
                // rd.isSuccess = false;
                // rd.failMessage = Attendance_Rule_NULL;
                // return rd;
                continue;
            }

            DataSet dataItem = new DataSet();
            dataItem.Id = rpItem.Shop_Name__c;
            dataItem.Name = rpItem.Shop_Name__r.Name;
            dataItem.Lat = rpItem.Shop_Name__r.Shop_Center_Location__Latitude__s;
            dataItem.Lng = rpItem.Shop_Name__r.Shop_Center_Location__Longitude__s;
            dataItem.Channel = rpItem.Shop_Name__r.Account__r.Name;
            dataItem.Remark = RESPONSIBLE_PERSON;
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

            Promoter_Attendance_Rule__c par = parMap.get(rpItem.Promoter_Attendance_Rule__c);
            dataItem.roleStartTime = String.valueOf(par.Start_time__c).subString(0,5);
            dataItem.roleEndTime = String.valueOf(par.End_time__c).subString(0,5);
            dataItem.roleTimeBuffer = par.Time_buffer__c;
            dataItem.roleNeedCheckDistance = par.Need_Check_Distance__c;
            dataItem.roleDistance = par.Distance__c;

            if (dataItem.Distance!=null && dataItem.roleDistance>0) {
                if (dataItem.roleDistance>=(dataItem.Distance*1000)) {
                    dataItem.roleDistanceText = WITHIN_RANGE;
                } else {
                    dataItem.roleDistanceText = String.valueOf(Integer.valueOf(dataItem.Distance*1000))+'m';
                }
            } else {
                dataItem.roleDistanceText = '';
            }
            
            rd.dataList.add(dataItem);
        }
        rd.dataList.sort();
        return rd;
    }

    // 附件上传
    public static void createUploadFile(String recordId, String photoStream){
        System.debug('photoStream--->'+photoStream);

        // System.debug('streamList==null--->'+(streamList==null));
        // System.debug('streamList.size()>0--->'+(streamList.size()==0));
        if (recordId==null || photoStream==null || photoStream=='') {
            return;
        }
        
        // String fileType = photoStream.split(';')[0].split('/')[1];
        String fileName = System.now().format('yyyyMMddHHmmss') + '.jpeg';
        ContentVersion cv = new ContentVersion();
        // cv.VersionData = EncodingUtil.base64Decode(photoStream.split(',')[1]);
        cv.VersionData = EncodingUtil.base64Decode(photoStream.substring(23,photoStream.length()));
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        
        insert cv;

        ContentVersion qrcv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =:cv.id];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = qrcv.ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';

        insert cdl;

    }

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
    public static String geolocationGetAddress(String lat, String lng){
        String address = '';

            //发送请求
            String requestUrl = 'https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyAucQYfZ2tw2RBO7jieFwG27-BeldZVgFY&location_type=ROOFTOP&result_type=street_address';
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
            system.debug( 'resultMap:' + resultMap);
            system.debug(address);

        return address;
    }

    /**
     * @description 发送打卡通知
     * @param title 标题
     * @param body 内容
     * @param userId 用户名
     */
    public static void sendNotification(String title, String body, String userId) {

        Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
        // Set the contents for the delinking notification
        currNotification.setTitle(title);
        currNotification.setBody(body);

        // Set the notification type and target
        currNotification.setNotificationTypeId([SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Custom_Notification'].Id);
        // currNotification.setTargetId('000000000000000AAA');
        String pageRef = 
        '' +
        '{' +
        '       type: \'standard__navItemPage\',' +
        '       attributes: {' +
        '           apiName: \'New_Promoter_Daily_Report\'' +
        '       }' +
        '}';
        currNotification.setTargetPageRef(pageRef);
        
        // Send the notification
        try {
            currNotification.send(new Set<String>{userId});
        }
        catch (Exception ex) {
            string msg = 'Notification Failed: ' + ex.getMessage();
            System.debug(msg);
        }
    }

    public class DataSet implements Comparable {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name; //门店名称
        @AuraEnabled public Double Lat; //门店经度
        @AuraEnabled public Double Lng; //门店纬度
        @AuraEnabled public String Channel; //经销商渠道
        @AuraEnabled public Decimal Distance; //距离km
        @AuraEnabled public String Remark;//标记

        // Role内容
        @AuraEnabled public String roleStartTime;
        @AuraEnabled public String roleEndTime;
        @AuraEnabled public Decimal roleTimeBuffer;
        @AuraEnabled public Boolean roleNeedCheckDistance;
        @AuraEnabled public Decimal roleDistance;
        @AuraEnabled public String roleDistanceText;

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

    // /**
    //  * Method : getPromoterAttendance
    //  * Function : 获取用户当天考勤Id
    //  * Return : String 当天考勤Id
    //  * Author : Rain
    //  * Date : 2022/04/24
    //  */
    // @AuraEnabled
    // public static string getPromoterAttendance(){
    //     String recordId = '';
    //     List<Promoter_Attendance__c> paList = [SELECT Id FROM Promoter_Attendance__c WHERE CheckIn_Date__c = :thisday AND OwnerId = :System.UserInfo.getUserId()];
    //     if(paList != null && paList.size() > 0) {
    //         recordId = paList[0].Id;
    //     }
    //     return recordId;
    // }

    public class ReturnData {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String failMessage;
        @AuraEnabled public List<DataSet> dataList;
        @AuraEnabled public Date thisDay;
        @AuraEnabled public String thisTime;
        @AuraEnabled public String userType;
        @AuraEnabled public String addressStr;
        @AuraEnabled public String checkInId;//考勤记录
        @AuraEnabled public String checkInStatus;//考勤状态
        @AuraEnabled public String checkInStatusLabel;//考勤状态标签
        @AuraEnabled public String checkInShop;
        @AuraEnabled public String checkOutShop;
        @AuraEnabled public String checkInType;
        @AuraEnabled public String checkInTimeStatus;
        @AuraEnabled public String checkInShopName;
        @AuraEnabled public String checkInAddress;
        @AuraEnabled public String checkInTime;
        @AuraEnabled public String checkOutType;
        @AuraEnabled public String checkOutTimeStatus;
        @AuraEnabled public String checkOutShopName;
        @AuraEnabled public String checkOutAddress;
        @AuraEnabled public String checkOutTime;
        
    }
}