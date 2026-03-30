public with sharing class NewCheckInCheckOutTrainController {

    private static String WITHOUT_DISTANCE = System.Label.CheckInCheckOut_WITHOUT_POSITION;//未获取当前定位信息，不可签到
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
    private static String TrainRoleDistance = System.Label.CheckInCheckOut_Train_Role_Distance;//培训签到限制签到距离

    public static Date thisDay = System.today();//Date.newInstance(2021, 12, 25); //测试后改成System.today()
    public static String thisTime = DateTime.now().format('HH:mm',UserInfo.getTimeZone().getId());//Date.newInstance(2021, 12, 25); //测试后改成System.today()
    
    @AuraEnabled
    public static string importImg(String name,String documentId,String contentVersionId){
        System.debug('name--=='+name);
        ConResponse resp = new ConResponse();
        List<String> strList =  name.split('\\.');
        System.debug('strList--=='+strList);
        try {
            String title = strList[0];
            List<ContentDocument> contDocList =  [SELECT FileType, Id FROM ContentDocument WHERE Id =: documentId];
            ContentDistribution cd = new ContentDistribution();
            cd.Name = title;
            cd.ContentVersionId = contentVersionId;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            CD.PreferencesAllowPDFDownload = false;
            insert cd;

            cd = [SELECT id, ContentVersion.VersionDataUrl
                  FROM ContentDistribution 
                  WHERE id =: cd.id];

            System.debug('wwww=====测试图片上传' + JSON.serialize(cd));
            return cd.ContentVersion.VersionDataUrl;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //初始化考勤信息页面
    @AuraEnabled
    public static ReturnData initStoreInfo(String lati, String lng, String searchInfo) {
        ReturnData rd = new ReturnData();
        rd.dataList = new List<DataSet>();
        rd.isSuccess = true;
        rd.isShowProductLine = false;
        rd.thisDay = thisDay;
        rd.thisTime = thisTime;
        try{

            Profile profileItem = getProfileItem(UserInfo.getProfileId());
            system.debug('profileItem--:'+profileItem);
            rd.userType = profileItem.Name;
            rd.userName = UserInfo.getName();

            // 判断当前人员是否展示激光产品线培训表单
            if(profileItem.name == 'South Africa Trainer(Laser TV)'){
                rd.isShowProductLine = true;
            }
            
            rd = initStoreInfoPromote(lati, lng, rd, searchInfo);
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

    // 获取门店的打卡信息
    @AuraEnabled
    public static ReturnData checkStoreAttendance(String storeId) {
        ReturnData rd = new ReturnData();
        rd.isSuccess = true;
        
        System.debug('<><<<><><><><><><<>><><><><>'+UserInfo.getUserId() + '_' + String.valueOf(thisDay) + '_' + storeId);
        List<Promoter_Attendance__c> attendanceList = getExistAttendance(UserInfo.getUserId() + '_' + String.valueOf(thisDay) + '_' + storeId);
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

            rd.trainingTheme = attendanceList[0].Training_Theme__c;
            rd.trainingObject = attendanceList[0].Training_Object__c;
            rd.trainingContent = attendanceList[0].Training_Content__c;
        }else{
            //不存在考勤信息
            rd.checkInStatus = '未签到';
            rd.checkInStatusLabel = NOT_CHECK_IN;

            rd.trainingTheme = '';
            rd.trainingObject = '';
            rd.trainingContent = '';
        }
        return rd;
    }

    // 获取文件的base64
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
    public static ReturnData checkIn(String curStatus,String storeId, Decimal lati, Decimal lng, String device, String addressStr, String remark, String photoStream, String navigatorInfo, String trainingTheme, String trainingObject, String trainingContent){
        ReturnData rd = new ReturnData();
        rd.dataList = new List<DataSet>();
        rd.isSuccess = true;
        try {
            Shop__c shopItem = CheckInCheckOutService.getShopItem(storeId);
            if( lati<>null && lng <>null) {
                Promoter_Attendance__c paItem = new Promoter_Attendance__c();
                List<Promoter_Attendance__c> attendanceList = getExistAttendance(UserInfo.getUserId() + '_' + String.valueOf(thisDay) + '_' + storeId);

                Profile profileItem = getProfileItem(UserInfo.getProfileId());
                rd.userType = profileItem.Name;
                
                Time nowTime = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
                Decimal distance;
                if(shopItem.Shop_Center_Location__c <> null) {
                    Location locItem = Location.newInstance(Double.Valueof(lati), Double.Valueof(lng));
                    distance = Location.getDistance(locItem, shopItem.Shop_Center_Location__c, 'km')*1000;
                }

                String checkInDistance = 'Onsite';
                String CheckInStatus = 'Check in';

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
                // 培训内容
                paItem.Training_Theme__c = trainingTheme;
                paItem.Training_Object__c = trainingObject;
                paItem.Training_Content__c = trainingContent;
                paItem.Is_Training__c = true;
                
                paItem.ExternalId__c = UserInfo.getUserId() + '_' + String.valueOf(thisDay) + '_' + storeId;
                paItem.OwnerId = UserInfo.getUserId();
                paItem.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('TrainAttendace').getRecordTypeId();
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

                pai.Type__c = 'Check in';
                pai.Status__c = CheckInStatus;
                pai.Remark__c = remark;
                pai.Navigator_Information__c = navigatorInfo;
                pai = UserDeviceRelated.setPromoterAttendanceInformation(pai);  // IMEI
                insert pai;

                createUploadFile(pai.Id, photoStream);
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
    public static ReturnData checkOut(String curStatus,String storeId, Decimal lati, Decimal lng, String device, String addressStr, String remark, String photoStream, String navigatorInfo, 
                                        String trainer,String customer,String nameOfStoreManager,String nameOfBA,
                                        String nameOfFSPs,String productFeaturesSalesSkill,String promotionFocus,
                                        String marketingDisplayCondition,String displayPictures,String secondShow,
                                        String trainingTheme, String trainingObject, String trainingContent){
        ReturnData rd = new ReturnData();
        rd.dataList = new List<DataSet>();
        rd.isSuccess = true;
        try {
            Shop__c shopItem = CheckInCheckOutService.getShopItem(storeId);
            if( lati<>null && lng <>null) {
                Promoter_Attendance__c paItem = new Promoter_Attendance__c();

                Profile profileItem = getProfileItem(UserInfo.getProfileId());
                rd.userType = profileItem.Name;
                
                Time nowTime = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
                Decimal distance;
                if(shopItem.Shop_Center_Location__c <> null) {
                    Location locItem = Location.newInstance(Double.Valueof(lati), Double.Valueof(lng));
                    distance = Location.getDistance(locItem, shopItem.Shop_Center_Location__c, 'km')*1000;
                }

                String checkOutDistance = 'Onsite';
                String CheckOutStatus = 'Check out';

                paItem.CheckOutShop__c = storeId;//签退门店
                paItem.CheckIn_Date__c = thisDay;
                paItem.CheckOutDevice__c = device;
                paItem.SignOutLocation__Latitude__s = lati;
                paItem.SignOutLocation__Longitude__s = lng;
                paItem.SignOutTime__c = nowTime;
                paItem.CheckOutAddress__c = addressStr;

                // 南非激光产品线定制培训表单
                paItem.Trainer__c = trainer;
                paItem.Customer__c = customer;
                paItem.Name_of_Store_Manager__c = nameOfStoreManager;
                paItem.Name_of_BA__c = nameOfBA;
                paItem.Name_of_FSPs__c = nameOfFSPs;
                paItem.Product_Features_Sales_Skill__c = productFeaturesSalesSkill;
                paItem.Promotion_Focus__c = promotionFocus;
                paItem.Marketing_display_condition__c = marketingDisplayCondition;
                paItem.Display_Pictures__c = displayPictures;
                paItem.Second_Show__c = secondShow;

                paItem.Training_Theme__c = trainingTheme;
                paItem.Training_Object__c = trainingObject;
                paItem.Training_Content__c = trainingContent;
                paItem.Is_Training__c = true;

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
                paItem.ExternalId__c = UserInfo.getUserId() + '_' + String.valueOf(paItem.CheckIn_Date__c) + '_' + storeId;
                paItem.OwnerId = UserInfo.getUserId();
                paItem.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('TrainAttendace').getRecordTypeId();
                upsert paItem ExternalId__c;

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

                pai.Type__c = 'Check out';
                pai.Status__c = CheckOutStatus;
                pai.Remark__c = remark;
                pai.Navigator_Information__c = navigatorInfo;
                pai = UserDeviceRelated.setPromoterAttendanceInformation(pai);  // IMEI
                insert pai;

                createUploadFile(pai.Id, photoStream);
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
                    Signin_Distance__c,
                    Training_Theme__c,
                    Training_Object__c,
                    Training_Content__c
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
    // 初始化考勤门店选择数据
    public static ReturnData initStoreInfoPromote(String lati, String lng, ReturnData rd, String serachInfo) {
        Location locItem;
        if(String.isNotBlank(lati) && String.isNotBlank(lng)){
            locItem = Location.newInstance(Double.Valueof(lati), Double.Valueof(lng));
        }
        system.debug('www--lati:'+lati);
        system.debug('www--lng:'+lng);
        system.debug('www--locItem:'+locItem);
        String query = '';
        if(String.isBlank(serachInfo)){
            query = ' SELECT Id,Name,Shop_Center_Location__Latitude__s,Shop_Center_Location__Longitude__s, ' + 
                    ' Account__c,Account__r.Name,Shop_Center_Location__c ' + 
                    ' FROM Shop__c ORDER BY LastViewedDate DESC NULLS LAST LIMIT 1000' ;
        }else {
            query = ' SELECT Id,Name,Shop_Center_Location__Latitude__s,Shop_Center_Location__Longitude__s, ' + 
                    ' Account__c,Account__r.Name,Shop_Center_Location__c ' + 
                    ' FROM Shop__c WHERE Name LIKE \'%'+serachInfo+'%\' ORDER BY LastViewedDate DESC NULLS LAST ' ;
        }
        List<Shop__c> shopList = Database.query(query);
        System.debug('www--shopList:'+shopList.size());

        Boolean checkInResponsibleflag = false;
        Boolean checkOutResponsibleflag = false;

        for (Shop__c shop : shopList) {
            DataSet dataItem = new DataSet();
            dataItem.Id = shop.Id;
            dataItem.Name = shop.Name;
            dataItem.Lat = shop.Shop_Center_Location__Latitude__s;
            dataItem.Lng = shop.Shop_Center_Location__Longitude__s;
            dataItem.Channel = shop.Account__r.Name;
            dataItem.ChannelId = shop.Account__c;
            dataItem.Remark = RESPONSIBLE_PERSON;
            if(locItem<>null && shop.Shop_Center_Location__c <> null) {
                Decimal distance = Location.getDistance(locItem, shop.Shop_Center_Location__c, 'km');
                dataItem.Distance = distance.setScale(2);
            }
            // if(rd.checkInShop == dataItem.Id && rd.checkOutShop == dataItem.Id) {
            //     dataItem.CheckInStatusLabel = CHECK_IN_OUT_SHOP;
            //     checkInResponsibleflag = true;
            //     checkOutResponsibleflag = true;
            // }else if(rd.checkInShop == dataItem.Id) {
            //     dataItem.CheckInStatusLabel = CHECK_IN_SHOP;
            //     checkInResponsibleflag = true;
            // }else if(rd.checkOutShop == dataItem.Id) {
            //     dataItem.CheckInStatusLabel = CHECK_OUT_SHOP;
            //     checkOutResponsibleflag = true;
            // }

            dataItem.roleNeedCheckDistance = false;
            dataItem.roleDistanceFlag = false;
            dataItem.roleDistance = Integer.valueOf(TrainRoleDistance);// 1000米
            System.debug('www--dataItem.Id:' + dataItem.Id);
            System.debug('www--dataItem.Distance:' + dataItem.Distance);
            System.debug('www--dataItem.roleDistance:' + dataItem.roleDistance);
            if (dataItem.Distance != null && dataItem.roleDistance > 0) {
                if (dataItem.roleDistance >= (dataItem.Distance * 1000)) {
                    dataItem.roleDistanceText = WITHIN_RANGE;
                    dataItem.roleDistanceFlag = true;
                } else {
                    dataItem.roleDistanceText = String.valueOf(Integer.valueOf(dataItem.Distance*1000))+'m';
                }
            } else {
                dataItem.roleDistanceText = '';
            }
            
            rd.dataList.add(dataItem);
        }
        rd.needCheckStore = (1000 == shopList.size());
        System.debug('www--shopList.size():' + shopList.size());
        // rd.needCheckStore = false;
        System.debug('www--needCheckStore:'+rd.needCheckStore);
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
           // String requestUrl = 'https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyAucQYfZ2tw2RBO7jieFwG27-BeldZVgFY&sensor=false';
            String requestUrl = 'https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyAevReUCBK5ntbBf525M-O31NcDc_Q-130&sensor=false';
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

    public class DataSet implements Comparable {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name; //门店名称
        @AuraEnabled public Double Lat; //门店经度
        @AuraEnabled public Double Lng; //门店纬度
        @AuraEnabled public String Channel; //经销商渠道
        @AuraEnabled public Decimal Distance; //距离km
        @AuraEnabled public String Remark;//标记
        @AuraEnabled public String ChannelId;//渠道ID

        // Role内容
        @AuraEnabled public String roleStartTime;
        @AuraEnabled public String roleEndTime;
        @AuraEnabled public Decimal roleTimeBuffer;
        @AuraEnabled public Boolean roleNeedCheckDistance;
        @AuraEnabled public Decimal roleDistance;
        @AuraEnabled public String roleDistanceText;
        @AuraEnabled public Boolean roleDistanceFlag;

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

    public class ReturnData {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public Boolean isShowProductLine;
        @AuraEnabled public String failMessage;
        @AuraEnabled public List<DataSet> dataList;
        @AuraEnabled public Date thisDay;
        @AuraEnabled public String thisTime;
        @AuraEnabled public String userType;
        @AuraEnabled public String userName;
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
        @AuraEnabled public Boolean needCheckStore;
        @AuraEnabled public String trainingTheme;
        @AuraEnabled public String trainingObject;
        @AuraEnabled public String trainingContent;
        
    }
}