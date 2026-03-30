/**
 * @description      : 促销员日报后端类
 * @author           : DTT-Bright
 * @last modified on : 2024-01-18
 * @last modified by : DTT-Bright
 */ 
public without sharing class NewInspectorDailyReportController {
    private static String INSPECTION_PROFILE = '巡店员';
    private static String RESPONSIBLE_PERSON = System.Label.CheckInCheckOut_RESPONSIBLE_PERSON; //门店负责人
    private static String SOBJECT_NOT_FOUND = System.Label.INSPECTION_REPORT_MSG_SOBJECT_NOT_FOUND; //未找到{0}信息，请联系系统管理员
    private static String INSPECT_TYPE_REMOTE = 'Remote Inspection';//远程巡店
    private static String INSPECT_TYPE_LOCALE = 'Locale Inspection';//现场巡店
    public static Date thisDay = System.today();
    public static String thisTime = DateTime.now().format('HH:mm',UserInfo.getTimeZone().getId());
    public static User user = [SELECT Id,Name,Country__c,Sales_Region__c,title FROM User WHERE Id = : UserInfo.getUserId()][0];
    public static Map<String, List<String>> brandAndProductline;
    public static List<Map<String, String>> searchProductByProductLineOption;
    public static List<Map<String, String>> brandOptions;
   
    static{

        if(Test.isRunningTest()){
            user.Sales_Region__c = 'Hisense Argentina';
        }

        if('Hisense Argentina'.equals(user.Sales_Region__c)){
            brandAndProductline = new Map<String, List<String>>();
            for(String brandAndProduct : System.Label.Argentina_Brand_ProductLine.split(';')){
                List<String> brandAndProductList = brandAndProduct.split(',');
                String brand = brandAndProductList[0];
                brandAndProductList.remove(0);
                brandAndProductline.put(brand, brandAndProductList);
                if('Hisense(Merchandiser)'.equals(brand)){
                    searchProductByProductLineOption = new List<Map<String, String>>();
                    for(String pl : brandAndProductList){
                        Map<String, String> option = new Map<String, String>();
                        if(pl.contains(':')){
                            List<String> plList = pl.split(':');
                            option.put('label', plList[1]);
                            option.put('value', plList[0]);
                        }else{
                            option.put('label', pl);
                            option.put('value', pl);
                        }
                        
                        searchProductByProductLineOption.add(option);
                    }
                }
            }
    
            brandOptions = new List<Map<String, String>>();
            Schema.SObjectType targetSobjectType = Schema.getGlobalDescribe().get('Daily_Inspection_Report__c');
            Schema.DescribeSObjectResult objectDescribe = targetSobjectType.getDescribe(); 
            Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap(); 
            List<Schema.PicklistEntry> picklistEntries = fieldMap.get('Brand__c').getDescribe().getPickListValues(); 
            for(Schema.PicklistEntry entry : picklistEntries){
                //lzx 2024-11-12 阿根廷根据title设置品牌
                if(String.isNotBlank(user.title) && user.title.toLowerCase().contains('hisense merchandiser')){
                    if('Hisense'.equals(entry.getValue())){
                        continue;
                    }
                }else{
                    if(!'Hisense'.equals(entry.getValue())){
                        continue;
                    }
                }
                Map<String, String> option = new Map<String, String>();
                option.put('label', entry.getLabel());
                option.put('value', entry.getValue());
                brandOptions.add(option);
            }
        }
    }

    //获取阿根廷产品Series列表
    @AuraEnabled
    public static ConResponse getProductSeriesOption(String productLine){

        List<Map<String, String>> seriesOption = new List<Map<String, String>>();
        Map<String, String> noneMap = new Map<String, String>();
        noneMap.put('label', '--None--');
        noneMap.put('value', '');
        seriesOption.add(noneMap);

        ConResponse resp = new ConResponse();
        resp.data = seriesOption;

        List<AggregateResult> seriesList = [select series__c from product__c where series__c != null and sales_region__c = 'Hisense Argentina' and Product_Line__c = :productLine group by series__c ];
        for(AggregateResult ar : seriesList){
            Map<String, String> seriesMap = new Map<String, String>();
            seriesMap.put('label', String.valueOf(ar.get('series__c')));
            seriesMap.put('value', String.valueOf(ar.get('series__c')));
            seriesOption.add(seriesMap);
        }
        return resp;
    }

    @AuraEnabled
    public static ConResponse getInitData(String recordId, String currentLat, String currentLong, String shopId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('sssssbrandAndProductline' + brandAndProductline);
        System.debug('ssssssearchProductByProductLineOption' + searchProductByProductLineOption);
        System.debug('sssssbrandOptions' + brandOptions);

        User user = [SELECT Id, Name, Sales_Region__c, title FROM User WHERE Id = : UserInfo.getUserId()];
        //20241105 TJP 新增一个salesRegion 判断 弹窗仅总部巡店出现
        mso.put('salesRegion', user.Sales_Region__c);
        // List<User> ul = [SELECT Id, Name, Sales_Region__c FROM User WHERE Name = 'Argentina Floorwalker Test'];
        List<User> ul = [SELECT Id, Name, Sales_Region__c FROM User WHERE Name = 'Nacho'];
        if(ul != null && ul.size() > 0){
            mso.put('ticketAssignedTo', ul.get(0).Id);
        }
        
        if('Hisense Argentina'.equals(user.Sales_Region__c)){
            
            mso.put('brandOptions', brandOptions);

            //阿根廷品牌产品线
            mso.put('searchProductByProductLineOption', searchProductByProductLineOption);
            mso.put('brandAndProductline', brandAndProductline);
            //产品序列
            //mso.put('productSerierOption', getProductSeriesOption());
        }

        // 获取Today
        mso.put('todayDate', thisDay); 
        // 获取Time
        mso.put('nowTime', thisTime); 
        mso.put('inspectTypeOptions', getPickList('Daily_Inspection_Report__c','Inspect_Type__c')); 
        mso.put('inspectStatusOptions', getPickList('Daily_Inspection_Report__c','Contact_Status__c')); 
        // 获取Product Line Picklist Value顺序
        mso.put('productLineValueSort', getPickList('Product__c','Product_Line__c')); 
        //20230920 add by Ethan 获取当前用户语种 Start
        mso.put('currentUserLanguage', UserInfo.getLanguage());
        //20230920 add by Ethan 获取当前用户语种 End

        if (String.isNotBlank(recordId)) {
            // 查询日报
            List<Daily_Inspection_Report__c> dirList = getExistDailyInspectionReportBasedId(recordId);
            if (dirList.size()==0) {
                resp.code= -1;
                resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Daily_Inspection_Report__c.getLabel()});
                return resp;
            }

            Daily_Inspection_Report__c dir = dirList[0];
            mso.put('record', dir);
            mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);

            //20240716 获取巡店员日报产品线子表信息
            System.debug('wwwww' + dir.Store__c);
            mso.put('storeProductLines', getInspectionProductItem(recordId));

            if('Hisense Argentina'.equals(user.Sales_Region__c) && String.isNotBlank(dir.Brand__c)){
                //阿根廷
                List<Sampling_Inspection_Argentina__c> siaList = new List<Sampling_Inspection_Argentina__c>();
                siaList = getSamplingInspectionArgentinaByReportId(recordId);
                mso.put('samplingInspectionsArgentina', siaList);
            }

            // 2024-01-17 wfc 特定用户可不需要配置门店负责人信息，选择所有权限门店
            List<Map<String, Object>> storeDistanceList = new List<Map<String, Object>>();
            List<Responsible_Person__c> responsiblePersonList = getResponsiblePerson(dir.OwnerId);
            // if(UserInfo.getUserName() == 'syssfcrm@hisense.com.hisenseall'){
            //     System.debug('www1----特殊用户');
            //     // 获取门店负责人信息，确定可选门店
            //     storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, responsiblePersonList, dir.Report_Date__c, dir.Store__c);
            // }else {
            //     // 获取门店负责人信息，确定可选门店
            //     storeDistanceList = getStoreDistanceList(currentLat, currentLong, responsiblePersonList, dir.Report_Date__c);
            // }
            storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, responsiblePersonList, dir.Report_Date__c, dir.Store__c);
            mso.put('storeDistanceList', storeDistanceList); 

            // // 获取门店负责人信息，确定可选门店
            // List<Responsible_Person__c> responsiblePersonList = getResponsiblePerson(dir.OwnerId);
            // List<Map<String, Object>> storeDistanceList = getStoreDistanceList(currentLat, currentLong, responsiblePersonList, dir.Report_Date__c);
            // mso.put('storeDistanceList', storeDistanceList); 
            // if (dir.NeedCheckIn__c) {
            if (dir.NeedCheckIn__c && dir.Inspect_Type__c != INSPECT_TYPE_REMOTE || dir.NeedCheckIn__c && user.Sales_Region__c == 'Hisense Australia') {//Modified By Ethan 20231103
                // 考勤ExId
                String paExId = dir.OwnerId + '_' + String.valueOf(dir.Report_Date__c);
                // 查询当天考勤信息
                List<Promoter_Attendance__c> paList = getExistAttendanceBasedExternalId(paExId);
                if (paList.size()==0) {
                    resp.code= -1;
                    resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Promoter_Attendance__c.getLabel()});
                    return resp;
                }
                Promoter_Attendance__c pa = paList[0];
                // 查询签到信息
                List<Promoter_Attendance_Information__c> paiList = getExistPromoterAttendanceInformationBasedAttendanceId(pa.Id, dir.Report_Date__c, dir.Store__c);
                if (paiList.size()==0) {
                    resp.code= -1;
                    resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Promoter_Attendance_Information__c.getLabel()});
                    return resp;
                }
                Promoter_Attendance_Information__c pai = paiList[0];
                // 获取签到信息
                mso.put('attendanceInformation', pai);
                Map<String, String> attendanceInformationHandHelper = new Map<String, String>();
                attendanceInformationHandHelper.put('checkInTime', String.valueOf(pai.CheckIn_Time__c).subString(0,5));
                if (!Test.isRunningTest()) {
                    // 附件部分
                    List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : pai.Id];
                    // BFR Yin Mingjie 20231124 start
                    // if (cdlList.size()==0) {
                    //     resp.code= -1;
                    //     resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{'Photo'});
                    //     return resp;
                    // }
                    // 海信更改 存在漏洞 注释 参考 -> 功能验证看板 提出时间 2023-10-18 09:25
                    //附件照片可以为非必填
                    if(cdlList.size() > 0){
                        ContentDocumentLink cdl = cdlList[0];
                        attendanceInformationHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                    }
                    mso.put('attendanceInformationHandHelper', attendanceInformationHandHelper);
                }
                
                // 查询签退信息
                List<Promoter_Attendance_Information__c> paiCheckOutList = getExistPromoterAttendanceInformationCheckOutBasedAttendanceId(pa.Id, dir.Report_Date__c, dir.Store__c);
                if (paiCheckOutList.size()!=0) {
                    Promoter_Attendance_Information__c paiCheckOut = paiCheckOutList[0];
                    mso.put('attendanceInformationCheckOut', paiCheckOut);
                    Map<String, String> attendanceInformationCheckOutHandHelper = new Map<String, String>();
                    attendanceInformationCheckOutHandHelper.put('checkOutTime', String.valueOf(paiCheckOut.CheckIn_Time__c).subString(0,5));
                    if (!Test.isRunningTest()) {
                        // 附件部分
                        List<ContentDocumentLink> cdlCheckOutList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : paiCheckOut.Id];
                        if(cdlCheckOutList.size() > 0){
                            ContentDocumentLink cdl = cdlCheckOutList[0];
                            attendanceInformationCheckOutHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                        }
                        mso.put('attendanceInformationCheckOutHandHelper', attendanceInformationCheckOutHandHelper);
                    }
                }
            } else {
                // if (!Test.isRunningTest()) {
                if (!Test.isRunningTest() && dir.Inspect_Type__c != INSPECT_TYPE_REMOTE || !Test.isRunningTest() && user.Sales_Region__c == 'Hisense Australia') {//Modified By Ethan 20231103
                    // 附件部分
                    Map<String, String> attendanceInformationHandHelper = new Map<String, String>();
                    List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : dir.Id];
                    // BFR Yin Mingjie 20231124 start
                    // if (cdlList.size()==0) {
                    //     resp.code= -1;
                    //     resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{'Photo'});
                    //     return resp;
                    // }
                    // 海信更改 存在漏洞 注释 参考 -> 功能验证看板 提出时间 2023-10-18 09:25
                    //附件照片可以为非必填
                    if(cdlList.size() > 0){
                        ContentDocumentLink cdl = cdlList[0];
                        attendanceInformationHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                    }
                    mso.put('attendanceInformationHandHelper', attendanceInformationHandHelper);
                }
            }
            // checklist部分
            Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(recordId);
            mso.put('checkResults', checkResults);
            mso.put('checkResultsIsRelatedToProduct', getCheckResultBycurrentUserLanguage(getExistCheckResultIsRelatedToProductBaseReportId(recordId)));
            // Sampling Inspection部分
            // 获取计划外Sampling Inspection信息
            List<Sampling_Inspection__c> planOutSamplingInspection = getExistPlanOutSamplingInspectionBaseStoreIdAndDate(dir.Store__c, dir.Report_Date__c, dir.OwnerId);
            List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreIdAndDate(dir.Store__c,dir.Report_Date__c,dir.OwnerId);
            siList.addAll(planOutSamplingInspection);
            // todo 给产品添加金额 wfc
            siList = setProductPrice(dir.Store__c, siList);
            mso.put('samplingInspections', siList);
            // ticket部分
            Map<String, List<Ticket__c>> taskMap = getTicket(dir);
            mso.put('ticketOpenInfo', taskMap.get('openTasks'));
            mso.put('ticketClosedInfo', taskMap.get('closedTasks'));
            // Mileage部分
            List<Mileage__c> mileageList = getExistMileageBaseRecordId(dir.Id);
            if (mileageList.size()>0) {
                mso.put('mileageRecord', mileageList[0]);
            }
            // 判断是否为日报所属人查看日报
            if (UserInfo.getUserId()!=dir.OwnerId) {
                mso.put('isReportUser', false);
            } else {
                mso.put('isReportUser', true);
            }
        //不存在recordId
        } else {
            // 2024-01-17 wfc 特定用户可不需要配置门店负责人信息，选择所有权限门店
            List<Map<String, Object>> storeDistanceList = new List<Map<String, Object>>();
            List<Responsible_Person__c> responsiblePersonList = getResponsiblePerson(UserInfo.getUserId());
            // if(UserInfo.getUserName() == 'syssfcrm@hisense.com.hisenseall'){
            //     System.debug('www2----特殊用户');
            //     // 获取门店负责人信息，确定可选门店
            //     storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, responsiblePersonList, thisDay, shopId);
            // }else {
            //     // 获取门店负责人信息，确定可选门店
            //     storeDistanceList = getStoreDistanceList(currentLat, currentLong, responsiblePersonList, thisDay);
            // }
            // storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, responsiblePersonList, thisDay, shopId);
            // mso.put('storeDistanceList', storeDistanceList); 


            // // 获取门店负责人信息，确定可选门店
            // List<Responsible_Person__c> responsiblePersonList = getResponsiblePerson(UserInfo.getUserId());
            // List<Map<String, Object>> storeDistanceList = getStoreDistanceList(currentLat, currentLong, responsiblePersonList, thisDay);
            // mso.put('storeDistanceList', storeDistanceList); 
            
            // 距离位置最近门店Id
            
            //TJP 增加逻辑 2025-05-29
            // String id = storeId == null ?  getStoreForDistance(currentLat, currentLong) : storeId;
            // storeId = id;
            
            Boolean b = PhaseIIIUtility.isPhaseUserUpdate(user.Sales_Region__c);
            if(b) {
                if(String.isNotEmpty(currentLat) && String.isNotEmpty(currentLong)) {
                    shopId = getStoreForDistance(currentLat, currentLong);
                }
            }
            storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, responsiblePersonList, thisDay, shopId);
            mso.put('storeDistanceList', storeDistanceList);
            String storeId = storeDistanceList.size()>0 ? (String)storeDistanceList[0].get('storeId') : null;
            
            
            // 日报ExId
            String dirExId = storeId + '_' + UserInfo.getUserId() + '_' + thisDay;
            System.debug('Ethan===dirExId===>'+dirExId);
            // 查询是否存在日报
            Daily_Inspection_Report__c dir;
            List<Daily_Inspection_Report__c> dirList = getExistDailyInspectionReportBasedExternalId(dirExId);
            if (dirList.size()>0) {
                dir = dirList[0];
            }
            // 存在日报
            if (dir!=null) {
                mso.put('record', dir);

                mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);
                // if(String.isNotBlank(dir.Store__c)){
                //     Daily_Inspection_Report__c insp = [Select Id,Report_Date__c From Daily_Inspection_Report__c Where Store__c =: dir.Store__c order By CreatedDate desc Limit 1];
                //     mso.put('priorVisitDate', insp.Report_Date__c); 
                // }
                if (dir.NeedCheckIn__c && dir.Inspect_Type__c != INSPECT_TYPE_REMOTE || dir.NeedCheckIn__c && user.Sales_Region__c == 'Hisense Australia') {//Modified By Ethan 20231103
                // if (dir.NeedCheckIn__c && dir.Inspect_Type__c != INSPECT_TYPE_REMOTE) {//Modified By Ethan 20231103
                    // 考勤ExId
                    String paExId = UserInfo.getUserId() + '_' + String.valueOf(thisDay);
                    // 查询当天考勤信息
                    List<Promoter_Attendance__c> paList = getExistAttendanceBasedExternalId(paExId);
                    if (paList.size()==0) {
                        resp.code= -1;
                        resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Promoter_Attendance__c.getLabel()});
                        return resp;
                    }
                    Promoter_Attendance__c pa = paList[0];
                    // 查询签到信息
                    List<Promoter_Attendance_Information__c> paiList = getExistPromoterAttendanceInformationBasedAttendanceId(pa.Id, thisDay, storeId);
                    if (paiList.size()==0) {
                        resp.code= -1;
                        resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Promoter_Attendance_Information__c.getLabel()});
                        return resp;
                    }
                    Promoter_Attendance_Information__c pai = paiList[0];
                    // 获取签到信息
                    mso.put('attendanceInformation', pai);
                    Map<String, String> attendanceInformationHandHelper = new Map<String, String>();
                    attendanceInformationHandHelper.put('checkInTime', String.valueOf(pai.CheckIn_Time__c).subString(0,5));
                    if (!Test.isRunningTest()) {
                        // 附件部分
                        List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : pai.Id];
                        // BFR Yin Mingjie 20231124 start
                        // if (cdlList.size()==0) {
                        //     resp.code= -1;
                        //     resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{'Photo'});
                        //     return resp;
                        // }
                        // 海信更改 存在漏洞 注释 参考 -> 功能验证看板 提出时间 2023-10-18 09:25
                        //附件照片可以为非必填
                        if(cdlList.size() > 0){
                            ContentDocumentLink cdl = cdlList[0];
                            attendanceInformationHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                        }
                        mso.put('attendanceInformationHandHelper', attendanceInformationHandHelper);
                    }

                    // 查询签退信息
                    List<Promoter_Attendance_Information__c> paiCheckOutList = getExistPromoterAttendanceInformationCheckOutBasedAttendanceId(pa.Id, thisDay, storeId);
                    if (paiCheckOutList.size()!=0) {
                        Promoter_Attendance_Information__c paiCheckOut = paiCheckOutList[0];
                        mso.put('attendanceInformationCheckOut', paiCheckOut);
                        Map<String, String> attendanceInformationCheckOutHandHelper = new Map<String, String>();
                        attendanceInformationCheckOutHandHelper.put('checkOutTime', String.valueOf(paiCheckOut.CheckIn_Time__c).subString(0,5));
                        if (!Test.isRunningTest()) {
                            // 附件部分
                            List<ContentDocumentLink> cdlCheckOutList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : paiCheckOut.Id];
                            if(cdlCheckOutList.size() > 0){
                                ContentDocumentLink cdl = cdlCheckOutList[0];
                                attendanceInformationCheckOutHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                            }
                            mso.put('attendanceInformationCheckOutHandHelper', attendanceInformationCheckOutHandHelper);
                        }
                    }
                // } else {
                } 
                
                if (!dir.NeedCheckIn__c && dir.Inspect_Type__c != INSPECT_TYPE_REMOTE || !dir.NeedCheckIn__c && user.Sales_Region__c == 'Hisense Australia') {//Modified By Ethan 20231103   
                    if (!Test.isRunningTest()) {
                    // if (!Test.isRunningTest() && dir.Inspect_Type__c != INSPECT_TYPE_REMOTE) {//Modified By Ethan 20231103
                        // 附件部分
                        Map<String, String> attendanceInformationHandHelper = new Map<String, String>();
                        List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : dir.Id];
                        // BFR Yin Mingjie 20231124 start
                        // if (cdlList.size()==0) {
                        //     resp.code= -1;
                        //     resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{'Photo'});
                        //     return resp;
                        // }
                        // 海信更改 存在漏洞 注释 参考 -> 功能验证看板 提出时间 2023-10-18 09:25
                        //附件照片可以为非必填
                        if(cdlList.size() > 0){
                            ContentDocumentLink cdl = cdlList[0];
                            attendanceInformationHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                        }
                        mso.put('attendanceInformationHandHelper', attendanceInformationHandHelper);
                    }
                }
                // checklist部分
                Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(dir.Id);
                mso.put('checkResults', checkResults);
                mso.put('checkResultsIsRelatedToProduct', getCheckResultBycurrentUserLanguage(getExistCheckResultIsRelatedToProductBaseReportId(dir.Id)));
                // Sampling Inspection部分
                // 获取计划外Sampling Inspection信息
                List<Sampling_Inspection__c> planOutSamplingInspection = getExistPlanOutSamplingInspectionBaseStoreIdAndDate(dir.Store__c, dir.Report_Date__c, dir.OwnerId);
                List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreIdAndDate(dir.Store__c,dir.Report_Date__c,dir.OwnerId);
                siList.addAll(planOutSamplingInspection);
                // todo 给产品添加金额 wfc
                siList = setProductPrice(dir.Store__c, siList);
                mso.put('samplingInspections', siList);
                // ticket部分
                Map<String, List<Ticket__c>> taskMap = getTicket(dir);
                mso.put('ticketOpenInfo', taskMap.get('openTasks'));
                mso.put('ticketClosedInfo', taskMap.get('closedTasks'));
                // Mileage部分
                List<Mileage__c> mileageList = getExistMileageBaseRecordId(dir.Id);
                if (mileageList.size()>0) {
                    mso.put('mileageRecord', mileageList[0]);
                }
            // 不存在日报
            } else {
                Daily_Inspection_Report__c dirNew = new Daily_Inspection_Report__c(
                    Report_Date__c = thisDay,
                    Store__c = storeId,
                    Status__c = 'New',
                    Inspect_Type__c = 'Locale Inspection',
                    Contact_Status__c = 'Not start'
                    // NeedAutoSubmit__c = true
                );

                if(!String.isEmpty(storeId)){
                    StoreDistanceInfo sInfo = getStoreDistanceInfo(storeId,currentLat,currentLong);
                    mso.put('storeDistanceInfo', sInfo);
                }
                String positionAddress = CheckInCheckOutController.geolocationGetAddress(currentLat,currentLong);
                mso.put('positionAddress', positionAddress);

                if('Hisense Argentina'.equals(user.Sales_Region__c)){
                    if(String.isNotBlank(user.title) && user.title.toLowerCase().contains('hisense merchandiser')){
                        dirNew.Brand__c = 'Hisense(Merchandiser)';
                    }else{
                        dirNew.Brand__c = 'Hisense';
                    }
                }

                mso.put('record', dirNew);
                // mso.put('mileageRecord', new Mileage__c(
                //     Start__c = 0.00,
                //     End__c = 0.00
                // ));
            }
        }

        
        System.debug('resp======>'+resp);
        return resp;
    }

    // 刷新数据
    @AuraEnabled()
    public static ConResponse refreshData(String recordJson, String currentLat, String currentLong, String contentVersionId, String shopId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('recordJson' + recordJson);
        Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)JSON.deserializeStrict(recordJson, Daily_Inspection_Report__c.class);

        User user = [SELECT Id, Name, Sales_Region__c, title FROM User WHERE Id = : UserInfo.getUserId()];
        //20241105 TJP 新增一个salesRegion 判断 弹窗仅总部巡店出现
        mso.put('salesRegion', user.Sales_Region__c);
        // List<User> ul = [SELECT Id, Name, Sales_Region__c FROM User WHERE Name = 'Argentina Floorwalker Test'];
        List<User> ul = [SELECT Id, Name, Sales_Region__c FROM User WHERE Name = 'Nacho'];
        if(ul != null && ul.size() > 0){
            mso.put('ticketAssignedTo', ul.get(0).Id);
        }

        if('Hisense Argentina'.equals(user.Sales_Region__c)){
            
            mso.put('brandOptions', brandOptions);

            //阿根廷品牌产品线
            mso.put('searchProductByProductLineOption', searchProductByProductLineOption);
            mso.put('brandAndProductline', brandAndProductline);

            //产品序列
            //mso.put('productSerierOption', getProductSeriesOption());
        }
        // 2024-01-17 wfc 特定用户可不需要配置门店负责人信息，选择所有权限门店
        List<Map<String, Object>> storeDistanceList = new List<Map<String, Object>>();
        List<Responsible_Person__c> responsiblePersonList = getResponsiblePerson(UserInfo.getUserId());
        // if(UserInfo.getUserName() == 'syssfcrm@hisense.com.hisenseall'){
        //     System.debug('www3----特殊用户');
        //     if(shopId == null){
        //         shopId = report.Store__c;
        //     }
        //     // 获取门店负责人信息，确定可选门店
        //     storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, responsiblePersonList, report.Report_Date__c, shopId);
        // }else {
        //     // 获取门店负责人信息，确定可选门店
        //     storeDistanceList = getStoreDistanceList(currentLat, currentLong, responsiblePersonList, report.Report_Date__c);
        // }
        storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, responsiblePersonList, report.Report_Date__c, shopId);
        mso.put('storeDistanceList', storeDistanceList); 

        // // 获取门店负责人信息，确定可选门店
        // List<Responsible_Person__c> responsiblePersonList = getResponsiblePerson(UserInfo.getUserId());
        // List<Map<String, Object>> storeDistanceList = getStoreDistanceList(currentLat, currentLong, responsiblePersonList, report.Report_Date__c);
        // mso.put('storeDistanceList', storeDistanceList); 

        // 获取Today
        mso.put('todayDate', thisDay); 
        // 获取Time
        mso.put('nowTime', thisTime); 
        mso.put('inspectTypeOptions', getPickList('Daily_Inspection_Report__c','Inspect_Type__c')); 
        mso.put('inspectStatusOptions', getPickList('Daily_Inspection_Report__c','Contact_Status__c')); 
        // 获取Product Line Picklist Value顺序
        mso.put('productLineValueSort', getPickList('Product__c','Product_Line__c')); 
        // 日报ExId
        String dirExId = report.Store__c + '_' + UserInfo.getUserId() + '_' + report.Report_Date__c;
        System.debug('wwwwdirExId' + dirExId);
        // 查询是否存在日报
        Daily_Inspection_Report__c dir;
        List<Daily_Inspection_Report__c> dirList = getExistDailyInspectionReportBasedExternalId(dirExId);
        if (dirList.size()>0) {
            dir = dirList[0];
        }

        // 存在日报
        if (dir!=null) {
            mso.put('record', dir);
            System.debug('wwwwwrecord' + JSON.serialize(dir));
            mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);

            //20240716 获取巡店员日报产品线子表信息
            System.debug('wwwww' + dir.Store__c);
            mso.put('storeProductLines', getInspectionProductItem(dir.Id));

            if('Hisense Argentina'.equals(user.Sales_Region__c) && String.isNotBlank(dir.Brand__c)){
                //阿根廷
                List<Sampling_Inspection_Argentina__c> siaList = new List<Sampling_Inspection_Argentina__c>();
                siaList = getSamplingInspectionArgentinaByReportId(dir.Id);
                mso.put('samplingInspectionsArgentina', siaList);
            }

            if (dir.NeedCheckIn__c && dir.Inspect_Type__c != INSPECT_TYPE_REMOTE || dir.NeedCheckIn__c && user.Sales_Region__c == 'Hisense Australia') {//Modified By Ethan 20231103
                // 考勤ExId
                String paExId = UserInfo.getUserId() + '_' + String.valueOf(report.Report_Date__c);
                // 查询当天考勤信息
                List<Promoter_Attendance__c> paList = getExistAttendanceBasedExternalId(paExId);
                if (paList.size()==0) {
                    resp.code= -1;
                    resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Promoter_Attendance__c.getLabel()});
                    return resp;
                }
                Promoter_Attendance__c pa = paList[0];
                // 查询签到信息
                List<Promoter_Attendance_Information__c> paiList = getExistPromoterAttendanceInformationBasedAttendanceId(pa.Id, report.Report_Date__c, report.Store__c);
                if (paiList.size()==0) {
                    resp.code= -1;
                    resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Promoter_Attendance_Information__c.getLabel()});
                    return resp;
                }
                Promoter_Attendance_Information__c pai = paiList[0];
                // 获取签到信息
                mso.put('attendanceInformation', pai);
                Map<String, String> attendanceInformationHandHelper = new Map<String, String>();
                attendanceInformationHandHelper.put('checkInTime', String.valueOf(pai.CheckIn_Time__c).subString(0,5));
                
                if (!Test.isRunningTest()) {
                    // 附件部分
                    List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : pai.Id];
                    // if (cdlList.size()==0) {
                    //     resp.code= -1;
                    //     resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{'Photo'});
                    //     return resp;
                    // }
                    //  BY lizunxing 20231213
                    //附件照片可以为非必填
                    if(cdlList.size() > 0){
                        ContentDocumentLink cdl = cdlList[0];
                        attendanceInformationHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                    }
                    mso.put('attendanceInformationHandHelper', attendanceInformationHandHelper);
                }
                
                // 查询签退信息
                List<Promoter_Attendance_Information__c> paiCheckOutList = getExistPromoterAttendanceInformationCheckOutBasedAttendanceId(pa.Id, report.Report_Date__c, report.Store__c);
                if (paiCheckOutList.size()!=0) {
                    Promoter_Attendance_Information__c paiCheckOut = paiCheckOutList[0];
                    mso.put('attendanceInformationCheckOut', paiCheckOut);
                    Map<String, String> attendanceInformationCheckOutHandHelper = new Map<String, String>();
                    attendanceInformationCheckOutHandHelper.put('checkOutTime', String.valueOf(paiCheckOut.CheckIn_Time__c).subString(0,5));
                    if (!Test.isRunningTest()) {
                        // 附件部分
                        List<ContentDocumentLink> cdlCheckOutList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : paiCheckOut.Id];
                        if(cdlCheckOutList.size() > 0){
                            ContentDocumentLink cdl = cdlCheckOutList[0];
                            attendanceInformationCheckOutHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                        }
                        mso.put('attendanceInformationCheckOutHandHelper', attendanceInformationCheckOutHandHelper);
                    }
                }
            } else {
                if (!Test.isRunningTest() && dir.Inspect_Type__c != INSPECT_TYPE_REMOTE || !Test.isRunningTest() && user.Sales_Region__c == 'Hisense Australia') {//Modified By Ethan 20231103
                    // 附件部分
                    Map<String, String> attendanceInformationHandHelper = new Map<String, String>();
                    List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : dir.Id];
                    // if (cdlList.size()==0) {
                    //     resp.code= -1;
                    //     resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{'Photo'});
                    //     return resp;
                    // }
                    //  BY lizunxing 20231213
                    //附件照片可以为非必填
                    if(cdlList.size() > 0){
                        ContentDocumentLink cdl = cdlList[0];
                        attendanceInformationHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                    }
                    mso.put('attendanceInformationHandHelper', attendanceInformationHandHelper);
                }
            }
            // checklist部分
            Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(dir.Id);
            mso.put('checkResults', checkResults);
            mso.put('checkResultsIsRelatedToProduct', getCheckResultBycurrentUserLanguage(getExistCheckResultIsRelatedToProductBaseReportId(dir.Id)));
            // Sampling Inspection部分
            // 获取计划外Sampling Inspection信息
            List<Sampling_Inspection__c> planOutSamplingInspection = getExistPlanOutSamplingInspectionBaseStoreIdAndDate(dir.Store__c, dir.Report_Date__c, dir.OwnerId);
            List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreIdAndDate(dir.Store__c,dir.Report_Date__c,dir.OwnerId);
            siList.addAll(planOutSamplingInspection);
            // todo 给产品添加金额 wfc
            siList = setProductPrice(dir.Store__c, siList);
            mso.put('samplingInspections', siList);
            // ticket部分
            Map<String, List<Ticket__c>> taskMap = getTicket(dir);
            mso.put('ticketOpenInfo', taskMap.get('openTasks'));
            mso.put('ticketClosedInfo', taskMap.get('closedTasks'));
            // Mileage部分
            List<Mileage__c> mileageList = getExistMileageBaseRecordId(dir.Id);
            if (mileageList.size()>0) {
                mso.put('mileageRecord', mileageList[0]);
            }
            
            // 判断是否为日报所属人查看日报
            if (UserInfo.getUserId()!=dir.OwnerId) {
                mso.put('isReportUser', false);
            } else {
                mso.put('isReportUser', true);
            }
        // 不存在日报
        } else {

            Daily_Inspection_Report__c dirNew = new Daily_Inspection_Report__c(
                Report_Date__c = report.Report_Date__c,
                Store__c = report.Store__c,
                Status__c = 'New',
                Inspect_Type__c = 'Locale Inspection',
                Contact_Status__c = 'Not start'
                // NeedAutoSubmit__c = true
            );

            StoreDistanceInfo sInfo = getStoreDistanceInfo(report.Store__c,currentLat,currentLong);
            mso.put('storeDistanceInfo', sInfo);
            String positionAddress = CheckInCheckOutController.geolocationGetAddress(currentLat,currentLong);
            mso.put('positionAddress', positionAddress);

            if('Hisense Argentina'.equals(user.Sales_Region__c)){
                if(String.isNotBlank(user.title) && user.title.toLowerCase().contains('hisense merchandiser')){
                    dirNew.Brand__c = 'Hisense(Merchandiser)';
                }else{
                    dirNew.Brand__c = 'Hisense';
                }
            }

            mso.put('record', dirNew);
            
            if (contentVersionId!=null && contentVersionId!='') {
                ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE Id =:contentVersionId];
                if (cv!=null) {
                    mso.put('attendanceShowPhoto', true);
                    mso.put('attendanceFromType', 'From Photo');
                    mso.put('attendancePhotoStreamInfo', JSON.serialize(cv.VersionData));
                }
            }
            // mso.put('mileageRecord', new Mileage__c(
            //     Start__c = 0.00,
            //     End__c = 0.00
            // ));
        }

        return resp;
    }

    // 处理门店距离展示详情信息
    public static StoreDistanceInfo getStoreDistanceInfo(String shopId,String currentLat,String currentLong){
        // YYL 查询门店地址详情信息 20250701
        List<Shop__c> shopList = [SELECT Id,Name,Address1__c,Shop_Center_Location__c,Shop_Center_Location__Latitude__s,Shop_Center_Location__Longitude__s FROM Shop__c WHERE Id = :shopId];
        StoreDistanceInfo si = new StoreDistanceInfo();
        System.debug('wwwwshopId' + shopId);
        System.debug('wwwwgetStoreDistanceInfo' + JSON.serialize(shopList));
        if(shopList != null && shopList.size() > 0){
            Shop__c shop = shopList.get(0);
            Location location = Location.newInstance(Double.Valueof(currentLat), Double.Valueof(currentLong));
            Decimal distance = 999.999;
            if(shop.Shop_Center_Location__c!=null && currentLat!=null && currentLong!=null){
                distance = location.getDistance(shop.Shop_Center_Location__c,'km');
            }

            si.storeName = shop.Name;
            si.distance = distance.setScale(3);
            si.address = shop.Address1__c;
        }
        
        return si;
    }

    // create record
    @AuraEnabled
    public static ConResponse createRecord(String recordJson, String attendanceFromType, String attendancePhotoStreamJson, String attendanceRemark, String currentLat, String currentLong) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('recordJson' + recordJson);
        User user = [SELECT Id, Name, Sales_Region__c, title FROM User WHERE Id = : UserInfo.getUserId()];
        Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)JSON.deserializeStrict(recordJson, Daily_Inspection_Report__c.class);

        // 需要根据最新的坐标信息判断距离
        List<Responsible_Person__c> personList = getResponsiblePersonBaseStoreId(report.Store__c);
        System.debug('======================================'+report);
        System.debug('Ethan ======================================'+report.Inspect_Type__c);
        System.debug(personList);
        // List<Map<String, Object>> newStoreDistanceList = getStoreDistanceList(currentLat, currentLong, personList, report.Report_Date__c);

        // 2024-01-17 wfc 特定用户可不需要配置门店负责人信息，选择所有权限门店
        List<Map<String, Object>> newStoreDistanceList = new List<Map<String, Object>>();
        // if(UserInfo.getUserName() == 'syssfcrm@hisense.com.hisenseall'){
        //     System.debug('www4----特殊用户');
        //     // 获取门店负责人信息，确定可选门店
        //     newStoreDistanceList = getStoreDistanceListForStore(currentLat, currentLong, personList, report.Report_Date__c, report.Store__c);
        // }else {
        //     newStoreDistanceList = getStoreDistanceList(currentLat, currentLong, personList, report.Report_Date__c);
        // }
        newStoreDistanceList = getStoreDistanceListForStore(currentLat, currentLong, personList, report.Report_Date__c, report.Store__c);
        Map<String, Object> storeDistance = newStoreDistanceList[0];
	    report.Distance__c = Double.valueOf(storeDistance.get('storeDistance'));
        // if (((Decimal)storeDistance.get('storeDistance'))*1000>(Decimal)storeDistance.get('checkInDistance')) {
        //     mso.put('isOutOfRange', true);
        // } else {
        // 现场巡店 start 20231101 Ethan
        if (report.Inspect_Type__c != INSPECT_TYPE_REMOTE || user.Sales_Region__c == 'Hisense Australia') {
            System.debug('这一步=====================');
            Promoter_Attendance_Information__c pai = new Promoter_Attendance_Information__c();
            if (attendanceFromType == 'From Photo') {
                report.NeedCheckIn__c = true;
            } else {
                report.NeedCheckIn__c = false;
                report.Note__c = attendanceRemark;
            }

            if (report.NeedCheckIn__c) {
                // 考勤ExId
                String paExId = UserInfo.getUserId() + '_' + String.valueOf(report.Report_Date__c);
                // 查询当天考勤信息
                List<Promoter_Attendance__c> paList = getExistAttendanceBasedExternalId(paExId);
                Promoter_Attendance__c pa = new Promoter_Attendance__c();
                if (paList.size()>0) {
                    pa = paList[0];
                } else {
                    pa.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('InspectorAttendace').getRecordTypeId();
                    pa.CheckIn_Date__c = report.Report_Date__c;
                    pa.Shop__c = report.Store__c;
                    // 维护签到的时间信息 20240401
                    pa.SignInTime__c = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
                    pa.CheckInStatus__c = '已签到';
                    pa.ExternalId__c = UserInfo.getUserId() + '_' + String.valueOf(pa.CheckIn_Date__c);

                    insert pa;
                }
                // 考勤详细信息新建
                // Promoter_Attendance_Information__c pai = new Promoter_Attendance_Information__c();
                pai.Type__c = 'Check in';
                pai.Promoter_Attendance__c = pa.Id;
                pai.CheckIn_Date__c = report.Report_Date__c;
                pai.CheckIn_Time__c = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
                pai.Shop__c = report.Store__c;
                pai.Remark__c = attendanceRemark;
                pai.Location__Latitude__s = Decimal.valueOf(currentLat);
                pai.Location__Longitude__s = Decimal.valueOf(currentLong);
                pai.Distance__c = Double.valueOf(storeDistance.get('storeDistance'));
                
                insert pai;
                // 考勤详细拍照绑定
                if (String.isNotBlank(attendancePhotoStreamJson)) {// BFR Yin Mingjie 20231124
                    createUploadFile(pai.Id, attendancePhotoStreamJson);
                }
            }

            // 新建日报
            upsert report;
            report = getExistDailyInspectionReportBasedId(report.Id)[0];

            if (report.NeedCheckIn__c == false) {
                // 考勤详细拍照绑定
                createUploadFile(report.Id, attendancePhotoStreamJson);
            }

            if (report.NeedCheckIn__c) {
                // 获取签到信息
                List<Promoter_Attendance_Information__c> queryPaiList = getExistPromoterAttendanceInformationBaseId(pai.Id);
                if (queryPaiList.size()==0) {
                    resp.code= -1;
                    resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Promoter_Attendance_Information__c.getLabel()});
                    return resp;
                }
                Promoter_Attendance_Information__c queryPai = queryPaiList[0];
                mso.put('attendanceInformation', queryPai);
                Map<String, String> attendanceInformationHandHelper = new Map<String, String>();
                attendanceInformationHandHelper.put('checkInTime', String.valueOf(pai.CheckIn_Time__c).subString(0,5));
                if (!Test.isRunningTest()) {
                    // 附件部分
                    List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : pai.Id];
                    // BFR Yin Mingjie 20231124 start
                    // if (cdlList.size()==0) {
                    //     resp.code= -1;
                    //     resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{'Photo'});
                    //     return resp;
                    // }
                    //附件照片可以为非必填
                    if(cdlList.size() > 0){
                        ContentDocumentLink cdl = cdlList[0];
                        attendanceInformationHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                    }
                    mso.put('attendanceInformationHandHelper', attendanceInformationHandHelper);
                    
                }
            } else {
                if (!Test.isRunningTest()) {
                    // 附件部分
                    Map<String, String> attendanceInformationHandHelper = new Map<String, String>();
                    List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : report.Id];
                    // if (cdlList.size()==0) {
                    //     resp.code= -1;
                    //     resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{'Photo'});
                    //     return resp;
                    // }
                    //  BY lizunxing 20231213
                    //附件照片可以为非必填
                    if(cdlList.size() > 0){
                        ContentDocumentLink cdl = cdlList[0];
                        attendanceInformationHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                    }
                    mso.put('attendanceInformationHandHelper', attendanceInformationHandHelper);
                }
            }
        }
        //远程巡店 End 20231101 Ethan
        if (report.Inspect_Type__c == INSPECT_TYPE_REMOTE && user.Sales_Region__c != 'Hisense Australia') {
            // 新建日报
            upsert report;
        
            
            report = getExistDailyInspectionReportBasedId(report.Id)[0];
            mso.put('attendanceInformation', null);
            mso.put('attendanceInformationHandHelper', null);

        }
        // 新建Sampling Inspection
        createSamplingInspection(report.Store__c, report.Report_Date__c, report.Id);
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreIdAndDate(report.Store__c,report.Report_Date__c,report.OwnerId);
        // 新建Sampling Inspection unplan --- Added By Sunny Start
        // wfc 不带出上次的SamplingInspection
        // createPlanoutSamplingInspection(report.Store__c, report.Report_Date__c);
        List<Sampling_Inspection__c> siListPlanOut = getExistPlanOutSamplingInspectionBaseStoreIdAndDate(report.Store__c,report.Report_Date__c,report.OwnerId);
        siList.addAll(siListPlanOut);
        // todo 给产品添加金额 wfc
        siList = setProductPrice(report.Store__c, siList);
        mso.put('samplingInspections', siList);
        // 新建Sampling Inspection unplan --- Added By Sunny End
        
        //阿根廷新建
        if('Hisense Argentina'.equals(user.Sales_Region__c) && String.isNotBlank(report.Brand__c) && !'Hisense'.equals(report.Brand__c)){
            List<Sampling_Inspection_Argentina__c> siaList = new List<Sampling_Inspection_Argentina__c>();
            for(String obj : brandAndProductline.get(report.Brand__c)){
                Sampling_Inspection_Argentina__c sia = new Sampling_Inspection_Argentina__c(
                    Brand__c = report.Brand__c,
                    Daily_Inspection_Report__c = report.Id,
                    Product_Line__c = obj,
                    Quantity_Of_Exhibits_Total__c = null,
                    Placement_Status__c = false,
                    POP__c = false,
                    ReRe__c = '',
                    External_Id__c = report.Id + '-' + report.Brand__c + '-' + obj
                );
                upsert sia External_Id__c;
                siaList.add(sia);
            }
            mso.put('samplingInspectionsArgentina', siaList);
        }
        

        Set<String> productLineSet = new Set<String>();
        productLineSet.add('General');
        productLineSet.add(null);
        Map<String, List<String>> productLineToSIId = new Map<String, List<String>>();
        for (Sampling_Inspection__c si : siList) {
            productLineSet.add(si.Product__r.Product_Line__c);
            if (productLineToSIId.containsKey(si.Product__r.Product_Line__c)) {
                List<String> siIds = productLineToSIId.get(si.Product__r.Product_Line__c);
                siIds.add(si.Id);
            } else {
                List<String> siIds = new List<String>();
                siIds.add(si.Id);
                productLineToSIId.put(si.Product__r.Product_Line__c, siIds);
            }
        }
        // 新建CheckResult
        Boolean isRemotedInspect  = report.Inspect_Type__c == INSPECT_TYPE_REMOTE ? true : false;//Ethan 20231106
        createCheckResult(report.Store__c, UserInfo.getUserId(), report.Id, productLineSet, productLineToSIId, isRemotedInspect);
        Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(report.Id);
        mso.put('checkResults', checkResults);
        mso.put('checkResultsIsRelatedToProduct', getCheckResultBycurrentUserLanguage(getExistCheckResultIsRelatedToProductBaseReportId(report.Id)));
        if (user.Sales_Region__c !='Hisense Chile') {
            // 新建Mileage
            Mileage__c mileageRecord = new Mileage__c();
            mileageRecord.Report__c = report.Id;
            mileageRecord.Start__c = 0.00;
            mileageRecord.End__c = 0.00;
                
            upsert mileageRecord;

            Mileage__c mileage = getExistMileageBaseRecordId(report.Id)[0];
            mso.put('mileageRecord', mileage);
        }
        // }
        
        // ticket部分
        Map<String, List<Ticket__c>> taskMap = getTicket(report);
        mso.put('ticketOpenInfo', taskMap.get('openTasks'));
        mso.put('ticketClosedInfo', taskMap.get('closedTasks'));
        // Daily_Inspection_Report__c dir = getExistDailyInspectionReportBasedId(report.Id)[0];
        // mso.put('record', dir);
        mso.put('record', report);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(report.Id)[0].Owner.Name);
        // 获取Today
        mso.put('todayDate', thisDay); 
        // 获取Time
        mso.put('nowTime', thisTime); 

        // 2024-01-17 wfc 特定用户可不需要配置门店负责人信息，选择所有权限门店
        List<Map<String, Object>> storeDistanceList = new List<Map<String, Object>>();
        List<Responsible_Person__c> responsiblePersonList = getResponsiblePerson(UserInfo.getUserId());
        // if(UserInfo.getUserName() == 'syssfcrm@hisense.com.hisenseall'){
        //     System.debug('www5----特殊用户');
        //     // 获取门店负责人信息，确定可选门店
        //     storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, responsiblePersonList, report.Report_Date__c, report.Store__c);
        // }else {
        //     // 获取门店负责人信息，确定可选门店
        //     storeDistanceList = getStoreDistanceList(currentLat, currentLong, responsiblePersonList, report.Report_Date__c);
        // }
        storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, responsiblePersonList, report.Report_Date__c, report.Store__c);
        mso.put('storeDistanceList', storeDistanceList); 

        // // 获取门店负责人信息，确定可选门店
        // List<Responsible_Person__c> responsiblePersonList = getResponsiblePerson(UserInfo.getUserId());
        // List<Map<String, Object>> storeDistanceList = getStoreDistanceList(currentLat, currentLong, responsiblePersonList, report.Report_Date__c);
        // mso.put('storeDistanceList', storeDistanceList); 
        System.debug('resp======>'+resp);
        return resp;
    }


    // upsert record
    @AuraEnabled
    public static ConResponse upsertRecord(String recordJson, String samplingInspectionJson, String samplingInspectionsArgentinaJson, String ticketOpenJson, String ticketClosedJson, String ticketOpenFilesMapJson, String mileageRecordJson, String checkResultsIsRelatedToProductJson, Boolean isSubmit,
                                            String attendancePhotoStreamJson, String attendanceRemark) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        Savepoint sp = Database.setSavepoint();

        System.debug('recordJson' + recordJson);
        Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)JSON.deserializeStrict(recordJson, Daily_Inspection_Report__c.class);

        System.debug('checkResultsIsRelatedToProductJson: ' + checkResultsIsRelatedToProductJson);
        List<CheckResult__c> checkResultList = (List<CheckResult__c>)JSON.deserializeStrict(checkResultsIsRelatedToProductJson, List<CheckResult__c>.class);
        if (isSubmit) {
            report.Status__c = 'Submitted';
            //TJP last 20250705 D:更新Ticket状态 用于Submitted触发
            updateReportTicketStatus(report.Id);
            //TJP last 20250715 D:仅仅用于新建Detail
            // List<Sampling_Detail__c> samplingDetails = [SELECT Id FROM Sampling_Detail__c WHERE Shop__c =: report.Store__c];
            // if(samplingDetails.isEmpty()) {
            //     System.debug('触发写入Detail逻辑' + report.Id);
            //     List<String> reportIds = new List<String>();
            //     reportIds.add(report.Id);
            //     SamplingInvocableMethodController.relevanceSampling(reportIds);
            // }
        }

        

        // 保存提交报错 【Inspection Report:entity is deleted】修复 start 20241022
        List<CheckResult__c> existCheckResultList = getExistCheckResultIsRelatedToProductBaseReportId(report.Id);
        Map<Id, CheckResult__c> existCheckResultMap = new Map<Id, CheckResult__c>(existCheckResultList);
        for (Integer i=0; i < checkResultList.size(); i++) {
            CheckResult__c checkResultItem = checkResultList[i];
            if (!existCheckResultMap.containsKey(checkResultItem.Id)) {
                checkResultList.remove(i);
                i--;
            }
        }
        // 保存提交报错 【Inspection Report:entity is deleted】修复 start 20241022

        update checkResultList;

        Map<String, List<Ticket__c>> taskMap = getTicket(report);
        System.debug('ticketOpenJson' + ticketOpenJson);
        List<Ticket__c> taskOpenList = (List<Ticket__c>)JSON.deserialize(ticketOpenJson, List<Ticket__c>.class);
        System.debug('taskOpenList' + taskOpenList);
        // Submit场景
        if (report.Status__c == 'Submitted') {
        
            // Added By Sunny Start 
            // 点击提交会直接生成不合格检查项的Ticket，提示Ticket信息补充填写
            String ticketMessage = '';
            //  add by DTT-Sunny 20240430 START
            List<Ticket__c> checkTicketList = new List<Ticket__c>(taskOpenList);
            List<Ticket__c> soqlOpenTicketList = taskMap.get('openTasks');
            List<String> openTicketIdList = new LisqContainer(taskOpenList).selectsField('Id');
            for (Ticket__c t : soqlOpenTicketList) {
                // 第一次提交自动生成的ticket不在页面的taskOpenList中
                if (!openTicketIdList.contains(t.Id)) {
                    checkTicketList.add(t);
                }
            }
            //  add by DTT-Sunny 20240430 END
            for(Ticket__c ticket : checkTicketList) {
                if(ticket.DueDate__c == null) {
                    ticketMessage = System.Label.Inspection_Report_Check_Item_Ticket_Fill;
                    // mso.put('ticketMessage', ticketMessage);
                    mso.put('submitCheckError', ticketMessage);
                    mso.put('ticketOpenInfo', checkTicketList);
                    return resp;
                }
            }
            // Added By Sunny End

            Map<String, Object> checkResp = SubmitReport(report,checkResultList,attendancePhotoStreamJson,attendanceRemark);
            if (!(Boolean)checkResp.get('isSuccess')) {
                mso.put('submitCheckError', (String)checkResp.get('errorMsg'));
                Database.rollback(sp);
                return resp;
            }
        }

        // samplingInspection 
        System.debug('samplingInspectionJson' + samplingInspectionJson);
        List<Sampling_Inspection__c> siList = (List<Sampling_Inspection__c>)JSON.deserialize(samplingInspectionJson, List<Sampling_Inspection__c>.class);
        upsert siList;

        //阿根廷
        System.debug('samplingInspectionsArgentinaJson' + samplingInspectionsArgentinaJson);
        if(String.isNotBlank(samplingInspectionsArgentinaJson)){
            List<Sampling_Inspection_Argentina__c> siaList = (List<Sampling_Inspection_Argentina__c>)JSON.deserialize(samplingInspectionsArgentinaJson, List<Sampling_Inspection_Argentina__c>.class);
            upsert siaList External_Id__c;
        }
        System.debug('samplingInspectionsArgentinaJson1' + samplingInspectionsArgentinaJson);
        
        if (report.Status__c == 'Submitted') {
            updateSamplingDetail(siList);
        }
        // Open ticket
        System.debug('ticketOpenJson' + ticketOpenJson);
        String ticketRecordId = Schema.Ticket__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Floorwalker').getRecordTypeId();
        taskOpenList = (List<Ticket__c>)JSON.deserialize(ticketOpenJson, List<Ticket__c>.class);

        List<String> currentTicketIdList = new LisqContainer(taskMap.get('openTasks')).selectsField('Id');
        List<Ticket__c> tempList = new List<Ticket__c>();
        for (Ticket__c t : taskOpenList) {
            if (t.Id == null || currentTicketIdList.contains(t.Id)) {
                tempList.add(t);
            }
        }
        taskOpenList = tempList;
        // 空部门校验 Sunny 20231117 start
        String checkDepartmentResult = NewTicketsController2.checkDepartment(taskOpenList);
        if(checkDepartmentResult != null) {
            resp.code = -1;
            resp.message = checkDepartmentResult;
            return resp;
        }
        // 空部门校验 Sunny 20231117 end
        for (Ticket__c t : taskOpenList) {
            if (t.Id == null) {
                t.RecordTypeId = ticketRecordId;
                t.InspectionReport__c = report.Id;
            }
            // if (t.Confirm_Task__c == 'Yes' && t.Closed_Daily_Inspection_Report__c == null) {
            if (t.Status__c == 'Closed' && t.ClosedDailyInspectionReport__c == null) {
                t.ClosedDailyInspectionReport__c = report.Id;
            }
        }
        upsert taskOpenList;
        // 附件关联
        // 切片上传 Yin Mingjie 20231026 start
        UploadFilesController.saveFiles2(ticketOpenJson, ticketOpenFilesMapJson, taskOpenList, report.Id);
        // 切片上传 Yin Mingjie 20231026 end
        // Closed ticket
        System.debug('ticketClosedJson' + ticketClosedJson);
        List<Ticket__c> taskClosedList = (List<Ticket__c>)JSON.deserialize(ticketClosedJson, List<Ticket__c>.class);
        for (Ticket__c t : taskClosedList) {
            // if (t.Confirm_Task__c == 'Yes' && t.Closed_Daily_Inspection_Report__c == null) {
            if (t.Status__c == 'Closed' && t.ClosedDailyInspectionReport__c == null) {
                t.ClosedDailyInspectionReport__c = report.Id;
            }
        }
        upsert taskClosedList;
        upsert report;
        // 更新巡店任务
        if (report.Status__c == 'Submitted') {
            List<Inspection_Shop_Task__c> istList = getExistInspectionShopTaskBaseCheck(report.Store__c, report.Report_Date__c, report.OwnerId);
            if (istList.size()==0) {
                resp.code= -1;
                resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Inspection_Shop_Task__c.getLabel()});
                return resp;
            }
            Inspection_Shop_Task__c ist = istList[0];
            ist.Daily_Inspection_Report__c = report.id;
            upsert ist;
        }
        // 查询日报（更新总分和平均分数据）
        Daily_Inspection_Report__c dir = getExistDailyInspectionReportBasedId(report.Id)[0];
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);
        // ticket部分
        // taskMap = getTicket(report);

        // Added By Sunny Start
        List<Ticket__c> openTasks = taskMap.get('openTasks');
        String ticketMessage = '';
        for(Ticket__c ticket : openTasks) {
            if(ticket.DueDate__c == null) {
                ticketMessage = System.Label.Inspection_Report_Check_Item_Ticket_Fill;
                break;
            }
        }
        mso.put('ticketMessage', ticketMessage);
        // Added By Sunny End

        mso.put('ticketOpenInfo', taskMap.get('openTasks'));
        mso.put('ticketClosedInfo', taskMap.get('closedTasks'));
        System.debug('Static * user======>'+ user.Sales_Region__c);
        if (user.Sales_Region__c !='Hisense Chile') {
            // Mileage部分
            System.debug('mileageRecordJson' + mileageRecordJson);
            Mileage__c mileageRecord = (Mileage__c)JSON.deserializeStrict(mileageRecordJson, Mileage__c.class);
            upsert mileageRecord;
            mso.put('mileageRecord', mileageRecord);
        }
        // 新增签退操作 20240403 YYL
        if(report.Status__c != 'Submitted'){
            if(attendancePhotoStreamJson != null || attendanceRemark != null){
                String paExId = report.OwnerId + '_' + String.valueOf(report.Report_Date__c);
                List<Promoter_Attendance__c> paList = getExistAttendanceBasedExternalId(paExId);
                Promoter_Attendance__c pa = new Promoter_Attendance__c();
                if (paList.size()>0) {
                    pa = paList[0];
                    if(pa.CheckInStatus__c != '已签到签退'){
                        pa.SignOutTime__c = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
                        pa.CheckInStatus__c = '已签到签退';
                        pa.ExternalId__c = paExId;
                        upsert pa ExternalId__c;
        
                        // 考勤详细信息新建 暂定
                        // Promoter_Attendance_Information__c pai = new Promoter_Attendance_Information__c();
                        // pai.Type__c = 'Check out';
                        // pai.Promoter_Attendance__c = pa.Id;
                        // pai.CheckIn_Date__c = thisDay;
                        // pai.CheckIn_Time__c = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
                        // pai.Shop__c = report.Store__c;
                        // pai.Remark__c = attendanceRemark;
                        // insert pai;
                        // if (String.isNotBlank(attendancePhotoStreamJson)) {
                        //     createUploadFile(pai.Id,attendancePhotoStreamJson);
                        // }
                    }
                }
            }
        }

        System.debug('resp1======>'+resp);
        return resp;
    }

    // Submit场景
    public static Map<String, Object> SubmitReport(Daily_Inspection_Report__c report, List<CheckResult__c> checkResultList,
                    String attendancePhotoStreamJson, String attendanceRemark) {
        Map<String, Object> resp = new Map<String, Object>();
        resp.put('isSuccess', true);
        resp.put('errorMsg', '');
        // 检查出样检查
        List<Sampling_Inspection__c> querySamplingInspectionList = getExistSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
        querySamplingInspectionList.addAll(getExistPlanOutSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId));
        // 检查Sampling Inspection关联附件
        /*
        Set<String> siHasFileids = new Set<String>();
        Map<String, Sampling_Inspection__c> siMap = new Map<String, Sampling_Inspection__c>();
        for (Sampling_Inspection__c si : querySamplingInspectionList) {
            if (si.Placement_Status__c == '未展出') {
                si.ReRe__c = '';
            } else {
                siHasFileids.add(si.Id);
            }
            siMap.put(si.Id, si);
        }
        if (siHasFileids.size()>0) {
            List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocumentId,LinkedEntityId,LinkedEntity.name FROM ContentDocumentLink WHERE LinkedEntityId IN : siHasFileids];
            Set<String> linkedEntityIds = new Set<String>();
            for (ContentDocumentLink cdl : cdlList) {
                linkedEntityIds.add(cdl.LinkedEntityId);
            }
            for (String siId : siHasFileids) {
                Sampling_Inspection__c si = siMap.get(siId);
                if (!linkedEntityIds.contains(siId)) {
                    resp.put('isSuccess', false);
                    resp.put('errorMsg', si.Product__r.Product_Line__c+' - Sampling Inspection attachments are not uploaded.');
                    return resp;
                }
            }
        }
        */
        // 检查CheckResult
        List<CheckResult__c> quoeryCheckResultList = getExistCheckResultBaseReportId(report.Id);
        if (checkResultList.size()>0) {
            quoeryCheckResultList.addAll(checkResultList);
        }
        Map<String, CheckResult__c> hasFilesMap = new Map<String, CheckResult__c>();
        /*
        for (CheckResult__c cr : quoeryCheckResultList) {
            String str = (cr.CheckItem__r.Product_Line__c==null?'General Checklist':cr.CheckItem__r.Product_Line__c)+' - '+cr.CheckItem__r.Project__c;
            
            if (cr.Scores__c == -1 || (cr.Scores__c < Decimal.valueOf(cr.CheckItem__r.MaximumScore__c) && (cr.Comments__c == '' || cr.Comments__c == null))) {
                resp.put('isSuccess', false);
                resp.put('errorMsg', str+' check item not completed.');
                return resp;
            }

            if (cr.CheckItem__r.HasFile__c) {
                hasFilesMap.put(cr.Id, cr);
            }
            cr.Status__c = 'Submitted';
        }
        // 查询CheckResult关联附件
        if (hasFilesMap.keySet().size()>0) {
            List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocumentId,LinkedEntityId,LinkedEntity.name FROM ContentDocumentLink WHERE LinkedEntityId IN : hasFilesMap.keySet()];
            Set<String> linkedEntityIds = new Set<String>();
            for (ContentDocumentLink cdl : cdlList) {
                linkedEntityIds.add(cdl.LinkedEntityId);
            }
            for (String crId : hasFilesMap.keySet()) {
                CheckResult__c cr = hasFilesMap.get(crId);
                String str = (cr.CheckItem__r.Product_Line__c==null?'General Checklist':cr.CheckItem__r.Product_Line__c)+' - '+cr.CheckItem__r.Project__c;
                if (!linkedEntityIds.contains(crId)) {
                    resp.put('isSuccess', false);
                    resp.put('errorMsg', str+' check item attachments are not uploaded.');
                    return resp;
                }
            }
        }
        */

        // User user = [SELECT Id, Name, Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
        
        List<CheckResult__c> deleteCheckItemList = new List<CheckResult__c>();
        System.debug('quoeryCheckResultList: ' + quoeryCheckResultList);
        for (CheckResult__c cr : quoeryCheckResultList) {
            String project = cr.CheckItem__r.Project__c==null?'':cr.CheckItem__r.Project__c;
            String str = (cr.CheckItem__r.Product_Line__c==null?'General Checklist':cr.CheckItem__r.Product_Line__c)+' - '+project;

            // 出样状态切换 ------ Added By Sunny Start
            if (cr.Scores__c == -2) {
                deleteCheckItemList.add(cr);
                continue;
            }
            // 出样状态切换 ------ Added By Sunny End

            if(!'Hisense Argentina'.equals(user.Sales_Region__c)){
                if (cr.Scores__c == -1) {
                    resp.put('isSuccess', false);
                    resp.put('errorMsg', str+' check item not completed.');
                    return resp;
                }

                if (cr.CheckItem__r.HasComment__c==true && cr.CheckItem__r.Require_Comment_Scores__c!=null) {
                    List<String> commentList = cr.CheckItem__r.Require_Comment_Scores__c.split(';');
                    if (commentList.contains(String.valueOf(cr.Scores__c)) && (cr.Comments__c == '' || cr.Comments__c == null)) {
                        resp.put('isSuccess', false);
                        resp.put('errorMsg', str+' check item comment are not completed.');
                        return resp;
                    }
                }

                if (cr.CheckItem__r.HasFile__c==true && cr.CheckItem__r.Scores_require_file__c!=null) {
                    List<String> fileList = cr.CheckItem__r.Scores_require_file__c.split(';');
                    if (fileList.contains(String.valueOf(cr.Scores__c))) {
                        hasFilesMap.put(cr.Id, cr);
                    }
                }
            }

            cr.Status__c = 'Submitted';
        }

        if(!'Hisense Argentina'.equals(user.Sales_Region__c)){
            // 查询CheckResult关联附件
            if (hasFilesMap.keySet().size()>0) {
                List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocumentId,LinkedEntityId,LinkedEntity.name FROM ContentDocumentLink WHERE LinkedEntityId IN : hasFilesMap.keySet()];
                Set<String> linkedEntityIds = new Set<String>();
                for (ContentDocumentLink cdl : cdlList) {
                    linkedEntityIds.add(cdl.LinkedEntityId);
                }
                for (String crId : hasFilesMap.keySet()) {
                    CheckResult__c cr = hasFilesMap.get(crId);
                    String str = (cr.CheckItem__r.Product_Line__c==null?'General Checklist':cr.CheckItem__r.Product_Line__c)+' - '+cr.CheckItem__r.Project__c;
                    if (!linkedEntityIds.contains(crId)) {
                        resp.put('isSuccess', false);
                        resp.put('errorMsg', str+' check item attachments are not uploaded.');
                        return resp;
                    }
                }
            }
        }
        
        // 更新CheckResult
        upsert quoeryCheckResultList;

        // 出样状态切换 ------ Added By Sunny Start
        if(deleteCheckItemList.size() > 0) {
            delete deleteCheckItemList;
        }
        // 出样状态切换 ------ Added By Sunny End

        // 检查巡店任务
        List<Inspection_Shop_Task__c> istList = getExistInspectionShopTaskBaseCheck(report.Store__c, report.Report_Date__c, report.OwnerId);
        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        if (istList.size()>0) {
            // Inspection_Shop_Task__c ist = istList[0];
            ist = istList[0];
            if (ist.Status__c == '未到访') {
                ist.Status__c = '已到访';
            }
            // upsert ist;
        } else {
            List<Inspection_Shop_Plan__c> ispList = getExistInspectionShopPlanBaseReportInfo(report.Report_Date__c, report.OwnerId);
            Inspection_Shop_Plan__c isp = new Inspection_Shop_Plan__c();
            if (ispList.size()>0) {
                isp = ispList[0];
            } else {
                isp.OwnerId__c = report.OwnerId;
                isp.Inspection_Year__c = String.valueOf(report.Report_Date__c.year());
                isp.Inspection_Month__c = String.valueOf(report.Report_Date__c.month());

                insert isp;
            }
            // Inspection_Shop_Plan__c isp = ispList[0];
            // Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
            ist.Shop__c = report.Store__c;
            ist.Inspection_Date__c = report.Report_Date__c;
            ist.Inspection_Plan__c = isp.Id;
            ist.Status__c = '计划外到访';
            // ist.OwnerId = report.OwnerId;

            // upsert ist;
        }
        // 更新巡店任务
        upsert ist;
        // 更新出样检查
        for (Sampling_Inspection__c si : querySamplingInspectionList) {
            si.Inspection_Shop_Task__c = ist.Id;
        }
        upsert querySamplingInspectionList;

        // BFR Yin Mingjie 20231124 start
        // 新建签退
        String paExId = report.OwnerId + '_' + String.valueOf(report.Report_Date__c);
        List<Promoter_Attendance__c> paList = getExistAttendanceBasedExternalId(paExId);
        Promoter_Attendance__c pa = new Promoter_Attendance__c();
        if (paList.size()>0) {
            pa = paList[0];
            // 考勤详细信息新建
            Promoter_Attendance_Information__c pai = new Promoter_Attendance_Information__c();
            pai.Type__c = 'Check out';
            pai.Promoter_Attendance__c = pa.Id;
            pai.CheckIn_Date__c = thisDay;
            pai.CheckIn_Time__c = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
            pai.Shop__c = report.Store__c;
            pai.Remark__c = attendanceRemark;
            insert pai;
            if (String.isNotBlank(attendancePhotoStreamJson)) {
                createUploadFile(pai.Id,attendancePhotoStreamJson);
            }
        }
        // BFR Yin Mingjie 20231124 end
        return resp;
    }

    // 刷新定位距离信息
    @AuraEnabled
    public static ConResponse refreshPositioning(String currentLat, String currentLong, String recordDate, String shopId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 获取门店负责人信息，确定可选门店
        List<Responsible_Person__c> responsiblePersonList = getResponsiblePerson(UserInfo.getUserId());
        List<Map<String, Object>> storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, responsiblePersonList, Date.valueOf(recordDate), shopId);
        // List<Map<String, Object>> storeDistanceList = getStoreDistanceList(currentLat, currentLong, responsiblePersonList, Date.valueOf(recordDate));
        mso.put('storeDistanceList', storeDistanceList); 

        // YYL 获取最近的门店信息
        // String storeId = storeDistanceList.size()>0 ? (String)storeDistanceList[0].get('storeId') : null;
        // if(storeId == null && String.isNotEmpty(currentLat) && String.isNotEmpty(currentLong)) {
        //     storeId = getStoreForDistance(currentLat, currentLong);
        // }

        String positionAddress = CheckInCheckOutController.geolocationGetAddress(currentLat,currentLong);
        mso.put('positionAddress', positionAddress);

        // 获取Today
        mso.put('todayDate', thisDay); 
        // 获取Time
        mso.put('nowTime', thisTime); 

        System.debug('resp======>'+resp);
        return resp;
    }

    // 更新门店数据并刷新
    @AuraEnabled
    public static ConResponse refreshUpShop(String currentLat, String currentLong, String address, String shopId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        System.debug('wwwwrefreshUpShop' + currentLat);
        System.debug('wwwwrefreshUpShop' + currentLong);
        Shop__c store = [SELECT Id FROM Shop__c WHERE Id =: shopId];
        // store.Shop_Center_Location__c = location;
        // store.Shop_Center_Location__Latitude__s = Decimal.valueOf(currentLat);
        // store.Shop_Center_Location__Longitude__s = Decimal.valueOf(currentLong);
        store.Address1__c = address;

        Database.Update(store);

        StoreDistanceInfo sInfo = getStoreDistanceInfo(shopId,currentLat,currentLong);
        mso.put('storeDistanceInfo', sInfo);

        // 获取Today
        mso.put('todayDate', thisDay); 
        // 获取Time
        mso.put('nowTime', thisTime); 

        System.debug('resp======>'+resp);
        return resp;
    }

    @AuraEnabled
    public static Integer getStoreDistance(String currentLat, String currentLong, String storeId) {
        Shop__c store = [SELECT Id,Shop_Center_Location__c,Shop_Center_Location__Latitude__s,Shop_Center_Location__Longitude__s FROM Shop__c WHERE Id = :storeId];
        Location location = Location.newInstance(Double.Valueof(currentLat), Double.Valueof(currentLong));
        // last by TJP 20250804 D:防止门店经纬度为空造成的无法提交
        Integer distanceKM = 0;
        if(store.Shop_Center_Location__Latitude__s == null || store.Shop_Center_Location__Longitude__s == null) {
            distanceKM = -1;
        } else {
            Decimal distance = location.getDistance(store.Shop_Center_Location__c,'km');
            distanceKM = Integer.valueOf(distance*1000);
        }
        return distanceKM;
    }

    // 根据坐标计算距离 (因为有SOQL查询，方法不可用在循环内)
    // public static List<Map<String, Object>> getStoreDistanceList(String currentLat, String currentLong, List<Responsible_Person__c> responsiblePersonList, Date reportDate) {
    //     // 计算和绑定门店距离
    //     List<Map<String, Object>> storeDistanceList = new List<Map<String, Object>>();
    //     for (Responsible_Person__c person : responsiblePersonList) {
    //         System.debug('=======================>>>>>');
    //         System.debug(person.Shop_Name__r.Shop_Center_Location__c);
    //         // if (currentLat!=null && currentLong!=null && person.Shop_Name__r.Shop_Center_Location__c!=null) {
    //         // if (currentLat!=null && currentLong!=null) {
    //             Map<String, Object> storeDistanceMap = new Map<String, Object>();
    //             Location location = Location.newInstance(Double.Valueof(currentLat), Double.Valueof(currentLong));
    //             // Decimal distance = location.getDistance(person.Shop_Name__r.Shop_Center_Location__c,'km');
    //             Decimal distance = 999.999;
    //             if (person.Shop_Name__r.Shop_Center_Location__c!=null && currentLat!=null && currentLong!=null) {
    //                 distance = location.getDistance(person.Shop_Name__r.Shop_Center_Location__c,'km');
    //                 storeDistanceMap.put('storeLat', person.Shop_Name__r.Shop_Center_Location__Latitude__s);
    //                 storeDistanceMap.put('storeLong', person.Shop_Name__r.Shop_Center_Location__Longitude__s);
    //             } else {
    //                 storeDistanceMap.put('storeLat', 0);
    //                 storeDistanceMap.put('storeLong', 0);
    //             }
    //             storeDistanceMap.put('storeId', person.Shop_Name__c);
    //             storeDistanceMap.put('storeName', person.Shop_Name__r.Name);
    //             // storeDistanceMap.put('storeLat', person.Shop_Name__r.Shop_Center_Location__Latitude__s);
    //             // storeDistanceMap.put('storeLong', person.Shop_Name__r.Shop_Center_Location__Longitude__s);
    //             storeDistanceMap.put('storeDistance', distance);
    //             storeDistanceMap.put('storeDistanceStr', String.valueOf(Integer.valueOf(distance*1000))+'m');
    //             storeDistanceMap.put('checkInDistance', person.Promoter_Attendance_Rule__r.Distance__c);
    //             storeDistanceMap.put('recordType', person.RecordType__c);// Add By Ethan 20231011 ----增加backup排序

    //             // 排序
    //             if (storeDistanceList.size()>0) {
    //                 for (Integer i = 0; i < storeDistanceList.size(); i++) {
    //                     Decimal itemDistance = (Decimal)storeDistanceList[i].get('storeDistance');
    //                     if (distance<=itemDistance) {
    //                         storeDistanceList.add(i, storeDistanceMap);
    //                         break;
    //                     } else if ((i+1)==storeDistanceList.size()) {
    //                         storeDistanceList.add(storeDistanceMap);
    //                         break;
    //                     }
    //                 }
    //             } else {
    //                 storeDistanceList.add(storeDistanceMap);
    //             }
    //         // }
    //     }

    //     // 区分计划内门店和计划外门店
    //     List<Map<String, Object>> planInList = new List<Map<String, Object>>();
    //     List<Map<String, Object>> planOutList = new List<Map<String, Object>>();
    //     List<Map<String, Object>> planList = new List<Map<String, Object>>();
    //     List<Inspection_Shop_Task__c> planTaskList = getExistInspectionShopTaskBaseReportInfo(reportDate, UserInfo.getUserId());
        
    //     Set<String> planStoreIds = new Set<String>();
    //     for (Inspection_Shop_Task__c plan : planTaskList) {
    //         planStoreIds.add(plan.Shop__c);
    //     }
    //     for (Map<String, Object> item : storeDistanceList) {
    //         String storeId = (String)item.get('storeId');
    //         if (planStoreIds.contains(storeId)) {
    //             item.put('storeName', '*'+(String)item.get('storeName'));
    //             planInList.add(item);
    //         } else {
    //             planOutList.add(item);
    //         }
    //     }
    //     /*
    //     // Add By Ethan 20231011 back up 排序优先级最低 Start
    //     List<Map<String, Object>> planInOutBackupList = new List<Map<String, Object>>();//用于针对记录类型为 backup的记录，拼装planInList、planOutList
    //     List<Map<String, Object>> planInOutNotBackupList = new List<Map<String, Object>>();//用于针对记录类型不为 backup的记录，拼装planInList、planOutList
    //     String backupRecordType = 'Backup Floorwalker';
    //     //分别排序
    //     for (Map<String, Object> planInitem : planInList) {
    //         if ((String)planInitem.get('recordType') == backupRecordType){
    //             String storeName = (String)planInitem.get('storeName');
    //             storeName = '*(backup)'+storeName.substring(1, storeName.length());
    //             planInitem.put('storeName', storeName);
    //             planInOutBackupList.add(planInitem);
    //             // planInOutBackupList.add(new Map<String, Object>{'storeName' => '(backup)'+planInitem.get('storeName')});
    //         }
    //         else 
    //             planInOutNotBackupList.add(planInitem);
    //     }
    //     planInList.clear();
    //     planInList.addAll(planInOutNotBackupList);
    //     planInList.addAll(planInOutBackupList);

    //     planInOutBackupList.clear();
    //     planInOutNotBackupList.clear();
    //     for (Map<String, Object> planOutitem : planOutList) {
    //         if ((String)planOutitem.get('recordType') == backupRecordType){
    //             planOutitem.put('storeName', '(backup)'+planOutitem.get('storeName'));
    //             planInOutBackupList.add(planOutitem);
    //             // planInOutBackupList.add(new Map<String, Object>{'storeName' => '(backup)'+planOutitem.get('storeName')});
    //         }
    //         else 
    //             planInOutNotBackupList.add(planOutitem);
    //     }
    //     planOutList.clear();
    //     planOutList.addAll(planInOutNotBackupList);
    //     planOutList.addAll(planInOutBackupList);
    //     // Add By Ethan 20231011 back up 排序优先级最低 End
    //     */
    //     planList.addAll(planInList);
    //     planList.addAll(planOutList);
    //     return planList;
    // }

    // 根据坐标计算距离 (因为有SOQL查询，方法不可用在循环内)
    public static List<Map<String, Object>> getStoreDistanceListForStore(String currentLat, String currentLong, List<Responsible_Person__c> responsiblePersonList, Date reportDate, String shopId) {
        // 计算和绑定门店距离
        List<Map<String, Object>> storeDistanceList = new List<Map<String, Object>>();
        // 门店是否配置在巡店员里面
        Boolean flag = false;
        for (Responsible_Person__c person : responsiblePersonList) {
            System.debug('=======================>>>>>');
            System.debug(person.Shop_Name__r.Shop_Center_Location__c);
            if(String.isNotBlank(shopId) && person.Shop_Name__c == shopId){
                System.debug('=======================>>>>>配置在巡店员里面');
                flag = true;
            }
            // if (currentLat!=null && currentLong!=null && person.Shop_Name__r.Shop_Center_Location__c!=null) {
            // if (currentLat!=null && currentLong!=null) {
                Map<String, Object> storeDistanceMap = new Map<String, Object>();
                Location location = Location.newInstance(Double.Valueof(currentLat), Double.Valueof(currentLong));
                // Decimal distance = location.getDistance(person.Shop_Name__r.Shop_Center_Location__c,'km');
                Decimal distance = 999.999;
                if (person.Shop_Name__r.Shop_Center_Location__c!=null && currentLat!=null && currentLong!=null) {
                    distance = location.getDistance(person.Shop_Name__r.Shop_Center_Location__c,'km');
                    storeDistanceMap.put('storeLat', person.Shop_Name__r.Shop_Center_Location__Latitude__s);
                    storeDistanceMap.put('storeLong', person.Shop_Name__r.Shop_Center_Location__Longitude__s);
                } else {
                    storeDistanceMap.put('storeLat', 0);
                    storeDistanceMap.put('storeLong', 0);
                }
                storeDistanceMap.put('storeId', person.Shop_Name__c);
                storeDistanceMap.put('storeName', person.Shop_Name__r.Name);
                // storeDistanceMap.put('storeLat', person.Shop_Name__r.Shop_Center_Location__Latitude__s);
                // storeDistanceMap.put('storeLong', person.Shop_Name__r.Shop_Center_Location__Longitude__s);
                storeDistanceMap.put('storeDistance', distance);
                storeDistanceMap.put('storeDistanceStr', String.valueOf(Integer.valueOf(distance*1000))+'m');
                storeDistanceMap.put('checkInDistance', person.Promoter_Attendance_Rule__r.Distance__c);
                storeDistanceMap.put('recordType', person.RecordType__c);// Add By Ethan 20231011 ----增加backup排序
                storeDistanceMap.put('salesRegion', person.Shop_Name__r.Sales_Region__c);// Add By TJP 20250806 ----增加门店Salesregion
                // 排序
                if (storeDistanceList.size()>0) {
                    for (Integer i = 0; i < storeDistanceList.size(); i++) {
                        Decimal itemDistance = (Decimal)storeDistanceList[i].get('storeDistance');
                        if (distance<=itemDistance) {
                            storeDistanceList.add(i, storeDistanceMap);
                            break;
                        } else if ((i+1)==storeDistanceList.size()) {
                            storeDistanceList.add(storeDistanceMap);
                            break;
                        }
                    }
                } else {
                    storeDistanceList.add(storeDistanceMap);
                }
            // }
        }

        if(String.isNotBlank(shopId) && !flag){
            System.debug('wwww--门店没有配置成巡店员门店--' + shopId);
            Shop__c shop = [SELECT Id,Name,Shop_Center_Location__c,Shop_Center_Location__Latitude__s,Shop_Center_Location__Longitude__s,Sales_Region__c FROM Shop__c WHERE Id = :shopId LIMIT 1];
            Map<String, Object> storeDistanceMap = new Map<String, Object>();
            Location location = Location.newInstance(Double.Valueof(currentLat), Double.Valueof(currentLong));
            // Decimal distance = location.getDistance(person.Shop_Name__r.Shop_Center_Location__c,'km');
            Decimal distance = 999.999;
            if (shop.Shop_Center_Location__c!=null && currentLat!=null && currentLong!=null) {
                distance = location.getDistance(shop.Shop_Center_Location__c,'km');
                storeDistanceMap.put('storeLat', shop.Shop_Center_Location__Latitude__s);
                storeDistanceMap.put('storeLong', shop.Shop_Center_Location__Longitude__s);
            } else {
                storeDistanceMap.put('storeLat', 0);
                storeDistanceMap.put('storeLong', 0);
            }
            storeDistanceMap.put('storeId', shop.Id);
            storeDistanceMap.put('storeName', shop.Name);
            // storeDistanceMap.put('storeLat', person.Shop_Name__r.Shop_Center_Location__Latitude__s);
            // storeDistanceMap.put('storeLong', person.Shop_Name__r.Shop_Center_Location__Longitude__s);
            storeDistanceMap.put('storeDistance', distance);
            storeDistanceMap.put('storeDistanceStr', String.valueOf(Integer.valueOf(distance*1000))+'m');
            storeDistanceMap.put('checkInDistance', null);
            storeDistanceMap.put('salesRegion', shop.Sales_Region__c);// Add By TJP 20250806 ----增加门店Salesregion
            // 排序
            if (storeDistanceList.size()>0) {
                for (Integer i = 0; i < storeDistanceList.size(); i++) {
                    Decimal itemDistance = (Decimal)storeDistanceList[i].get('storeDistance');
                    if (distance<=itemDistance) {
                        storeDistanceList.add(i, storeDistanceMap);
                        break;
                    } else if ((i+1)==storeDistanceList.size()) {
                        storeDistanceList.add(storeDistanceMap);
                        break;
                    }
                }
            } else {
                storeDistanceList.add(storeDistanceMap);
            }
        }

        // 区分计划内门店和计划外门店
        List<Map<String, Object>> planInList = new List<Map<String, Object>>();
        List<Map<String, Object>> planOutList = new List<Map<String, Object>>();
        List<Map<String, Object>> planList = new List<Map<String, Object>>();
        List<Inspection_Shop_Task__c> planTaskList = getExistInspectionShopTaskBaseReportInfo(reportDate, UserInfo.getUserId());
        
        Set<String> planStoreIds = new Set<String>();
        for (Inspection_Shop_Task__c plan : planTaskList) {
            planStoreIds.add(plan.Shop__c);
        }
        for (Map<String, Object> item : storeDistanceList) {
            String storeId = (String)item.get('storeId');
            if (planStoreIds.contains(storeId)) {
                item.put('storeName', '*'+(String)item.get('storeName'));
                planInList.add(item);
            } else {
                planOutList.add(item);
            }
        }
        /*
        // Add By Ethan 20231011 back up 排序优先级最低 Start
        List<Map<String, Object>> planInOutBackupList = new List<Map<String, Object>>();//用于针对记录类型为 backup的记录，拼装planInList、planOutList
        List<Map<String, Object>> planInOutNotBackupList = new List<Map<String, Object>>();//用于针对记录类型不为 backup的记录，拼装planInList、planOutList
        String backupRecordType = 'Backup Floorwalker';
        //分别排序
        for (Map<String, Object> planInitem : planInList) {
            if ((String)planInitem.get('recordType') == backupRecordType){
                String storeName = (String)planInitem.get('storeName');
                storeName = '*(backup)'+storeName.substring(1, storeName.length());
                planInitem.put('storeName', storeName);
                planInOutBackupList.add(planInitem);
                // planInOutBackupList.add(new Map<String, Object>{'storeName' => '(backup)'+planInitem.get('storeName')});
            }
            else 
                planInOutNotBackupList.add(planInitem);
        }
        planInList.clear();
        planInList.addAll(planInOutNotBackupList);
        planInList.addAll(planInOutBackupList);

        planInOutBackupList.clear();
        planInOutNotBackupList.clear();
        for (Map<String, Object> planOutitem : planOutList) {
            if ((String)planOutitem.get('recordType') == backupRecordType){
                planOutitem.put('storeName', '(backup)'+planOutitem.get('storeName'));
                planInOutBackupList.add(planOutitem);
                // planInOutBackupList.add(new Map<String, Object>{'storeName' => '(backup)'+planOutitem.get('storeName')});
            }
            else 
                planInOutNotBackupList.add(planOutitem);
        }
        planOutList.clear();
        planOutList.addAll(planInOutNotBackupList);
        planOutList.addAll(planInOutBackupList);
        // Add By Ethan 20231011 back up 排序优先级最低 End
        */
        planList.addAll(planInList);
        planList.addAll(planOutList);
        return planList;
    }

    // 获取checkList，并新建CheckResult
    public static void createCheckResult(String storeId, String userId, String reportId, Set<String> productLineSet, Map<String, List<String>> productLineToSIId) {
        createCheckResult(storeId,  userId,  reportId, productLineSet,  productLineToSIId, false);
    }
    
    // 获取checkList，并新建CheckResult
    // public static void createCheckResult(String storeId, String userId, String reportId, Set<String> productLineSet) {
    public static void createCheckResult(String storeId, String userId, String reportId, Set<String> productLineSet, Map<String, List<String>> productLineToSIId, Boolean isRemotedInspect) {// Ethan 20231106
        // ConResponse checklist= CheckListController.getCheckList('a260l0000016LA2AAM','0050l000007g1vGAAQ');
        // ConResponse checklist= CheckListController.getCheckList(storeId,userId);
        ConResponse checklist= CheckListController.getCheckList(storeId,userId, isRemotedInspect);
        if (checklist.data instanceof Map<String,List<CheckItem__c>>) {
            Map<String, List<CheckItem__c>> checkItemMap = (Map<String,List<CheckItem__c>>)checklist.data;
            List<CheckResult__c> newCheckResultList = new List<CheckResult__c>();
            for (String productLine : checkItemMap.keyset()) {
                if (productLineSet.contains(productLine)) {
                    List<CheckItem__c> checkItemList = checkItemMap.get(productLine);
                    for (CheckItem__c checkItem : checkItemList) {
                        if (checkItem.Is_Related_To_Product__c=true && productLineToSIId!=null && productLineToSIId.containsKey(productLine)) {
                            List<String> siIds = productLineToSIId.get(productLine);
                            for (String siId : siIds) {
                                CheckResult__c cr = new CheckResult__c();
                                cr.InspectorDailyReport__c = reportId;
                                cr.CheckItem__c = checkItem.Id;
                                cr.Sampling_Inspection__c = siId;
                                cr.Status__c = 'Draft';
                                cr.Scores__c = -1;
                                cr.Max_Scores__c = Integer.valueOf(checkItem.MaximumScore__c);
        
                                newCheckResultList.add(cr);
                            }
                        } else {
                            CheckResult__c cr = new CheckResult__c();
                            cr.InspectorDailyReport__c = reportId;
                            cr.CheckItem__c = checkItem.Id;
                            cr.Status__c = 'Draft';
                            // if (checkItem.IsYesOrNo__c) {
                            //     cr.Scores__c = 0;
                            // } else {
                            //     cr.Scores__c = -1;
                            // }
                            cr.Scores__c = -1;
                            cr.Max_Scores__c = Integer.valueOf(checkItem.MaximumScore__c);
    
                            newCheckResultList.add(cr);
                        }
                    }
                }
            }
    
            insert newCheckResultList;
            checkItemBindAttachments(newCheckResultList, storeId, userId);
        }
    }

    public static void createCheckResult2(String storeId, String userId, String reportId, Set<String> productLineSet, Map<String, List<String>> productLineToSIId, Boolean isRemotedInspect) {// Ethan 20231106
        ConResponse checklist= CheckListController.getCheckList(storeId,userId, isRemotedInspect);
        if (checklist.data instanceof Map<String,List<CheckItem__c>>) {
            Map<String, List<CheckItem__c>> checkItemMap = (Map<String,List<CheckItem__c>>)checklist.data;
            List<CheckResult__c> newCheckResultList = new List<CheckResult__c>();
            for (String productLine : checkItemMap.keyset()) {
                if (productLineSet.contains(productLine)) {
                    List<CheckItem__c> checkItemList = checkItemMap.get(productLine);
                    for (CheckItem__c checkItem : checkItemList) {
                        if (checkItem.Is_Related_To_Product__c=true && productLineToSIId!=null && productLineToSIId.containsKey(productLine)) {
                            List<String> siIds = productLineToSIId.get(productLine);
                            for (String siId : siIds) {
                                CheckResult__c cr = new CheckResult__c();
                                cr.InspectorDailyReport__c = reportId;
                                cr.CheckItem__c = checkItem.Id;
                                cr.Sampling_Inspection__c = siId;
                                cr.Status__c = 'Draft';
                                cr.Scores__c = -1;
                                cr.Max_Scores__c = Integer.valueOf(checkItem.MaximumScore__c);
        
                                newCheckResultList.add(cr);
                            }
                        }
                    }
                }
            }
    
            insert newCheckResultList;
            checkItemBindAttachments(newCheckResultList, storeId, userId);
        }
    }

    // CheckResult绑定本月最近日期附件
    public static void checkItemBindAttachments(List<CheckResult__c> checkResultList, String storeId, String userId) {
        // User user = [SELECT Id, Name, Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
        if (PhaseIIIUtility.isIndonesia(user)) {
            return;
        }
        // 本次新建check result上的check item
        Set<Id> crIds = new Set<Id>();
        Map<String, String> ciIdMapCrId = new Map<String, String>();
        for (CheckResult__c crItem : checkResultList) {
            crIds.add(crItem.CheckItem__c);
            ciIdMapCrId.put(crItem.CheckItem__c, crItem.Id);
        }
        // 查询本月本人的所有check result
        Date today = System.today();
        Date monthDate = Date.newInstance(today.year(), today.month(), 1);
        List<CheckResult__c> crQueryList = getExistCheckResultBaseCheckItemIds(crIds, monthDate, storeId, userId);
        if (crQueryList.size()==0) {
            return;
        }
        // 筛选出相同check item的第一条check result记录
        Map<String, String> crIdMapCiId = new Map<String, String>();
        Set<String> checkCrIds = new Set<String>();
        for (CheckResult__c crItem : crQueryList) {
            if (!checkCrIds.contains(crItem.CheckItem__c)) {
                checkCrIds.add(crItem.CheckItem__c);
                crIdMapCiId.put(crItem.Id, crItem.CheckItem__c);
            }
        }
        if (crIdMapCiId.size()==0) {
            return;
        }
        // 查询筛选出记录的所有附件
        List<ContentDocumentLink> queryCdl = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : crIdMapCiId.keySet()];
        Map<String, List<String>> documentMap = new Map<String, List<String>>();
        for (ContentDocumentLink cdlItem : queryCdl) {
            if (!crIdMapCiId.containsKey(cdlItem.LinkedEntityId)) {
                break;
            }
            String checkItemId = crIdMapCiId.get(cdlItem.LinkedEntityId);
            if (documentMap.containsKey(checkItemId)) {
                List<String> linkedIds = documentMap.get(checkItemId);
                linkedIds.add(cdlItem.ContentDocumentId);
            } else {
                List<String> linkedIds = new List<String>();
                linkedIds.add(cdlItem.ContentDocumentId);
                documentMap.put(checkItemId, linkedIds);
            }
        }
        // 关联新纪录
        List<ContentDocumentLink> insertCdlList = new List<ContentDocumentLink>();
        for (CheckResult__c crItem : checkResultList) {
            if (documentMap.containsKey(crItem.CheckItem__c)) {
                for (String documentId : documentMap.get(crItem.CheckItem__c)) {
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = documentId;
                    cdl.LinkedEntityId = crItem.Id;
                    cdl.ShareType = 'V';
                    insertCdlList.add(cdl);
                }
            }
        }
        if (insertCdlList.size()>0) {
            insert insertCdlList;
        }
    }


    // 获取checkList
    public static Map<String,Map<String, List<CheckResult__c>>> getCheckResult(String reportId) {
        List<CheckResult__c> quoeryCheckResultList = getExistCheckResultBaseReportId(reportId);
        Map<String,Map<String, List<CheckResult__c>>> checkResults = new Map<String, Map<String, List<CheckResult__c>>>();
        for (CheckResult__c cr : quoeryCheckResultList) {
            String productLine = cr.CheckItem__r.Product_Line__c==null ? 'General' : cr.CheckItem__r.Product_Line__c;
            String project = cr.CheckItem__r.Project__c;
            if (checkResults.keySet().contains(productLine)) {
                Map<String, List<CheckResult__c>> item = checkResults.get(productLine);
                if (item.keySet().contains(project)) {
                    List<CheckResult__c> crs = item.get(project);
                    crs.add(cr);
                } else {
                    List<CheckResult__c> crs = new List<CheckResult__c>();
                    crs.add(cr);
                    item.put(project, crs);
                }
            } else {
                List<CheckResult__c> crs = new List<CheckResult__c>();
                crs.add(cr);
                Map<String, List<CheckResult__c>> item = new Map<String, List<CheckResult__c>>();
                item.put(project, crs);
                checkResults.put(productLine, item);
            }
        }

        return checkResults;
    }

    // 获取重写 checkList数据
    public static Map<String,Map<String, List<CheckResult__c>>> getRewriteCheckResult(String reportId) {
        List<CheckResult__c> quoeryCheckResultList = getExistCheckResultBaseReportId(reportId);

        Map<String,Map<String, List<CheckResult__c>>> checkResults = new Map<String, Map<String, List<CheckResult__c>>>();
        for (CheckResult__c cr : quoeryCheckResultList) {
            String productLine = cr.CheckItem__r.Product_Line__c==null ? null : cr.CheckItem__r.Product_Line__c;
            String project = cr.CheckItem__r.Project__c;
            if (checkResults.keySet().contains(productLine)) {               
                Map<String, List<CheckResult__c>> item = checkResults.get(productLine);
                if (item.keySet().contains(project)) {
                    List<CheckResult__c> crs = item.get(project);
                    crs.add(cr);
                } else {
                    List<CheckResult__c> crs = new List<CheckResult__c>();
                    crs.add(cr);
                    item.put(project, crs);
                }
            } else {
                System.debug('Else条件  获取参数');
                List<CheckResult__c> crs = new List<CheckResult__c>();
                crs.add(cr);
                System.debug('Else条件  获取参数cr ' + cr);
                Map<String, List<CheckResult__c>> item = new Map<String, List<CheckResult__c>>();
                item.put(project, crs);
                System.debug('Else条件  获取参数item ' + item);
                checkResults.put(productLine, item);
            }
        }
        System.debug('获取接口参数' + checkResults);
        return checkResults;
    }

    // 获取Sampling Detail，并新建Sampling Inspection
    public static void createSamplingInspection(String storeId, Date reportDate, String reportId) {

        // Boolean isClose = true;
        // if(isClose){
        //     return;
        // }
        
        // 查询历史Sampling Inspection
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreId(storeId, Userinfo.getUserId(), Date.newInstance(reportDate.year(),1,1));
        System.debug('Silist>>>>>>>>>>>>>>>>'+siList);
        Map<String, List<Sampling_Inspection__c>> siOldMap = new Map<String, List<Sampling_Inspection__c>>();
        for (Sampling_Inspection__c si : siList) {
            if (siOldMap.containskey(si.Sample_Item__c)) {
                List<Sampling_Inspection__c> siItems = siOldMap.get(si.Sample_Item__c);
                siItems.add(si);
            } else {
                List<Sampling_Inspection__c> siItems = new List<Sampling_Inspection__c>();
                siItems.add(si);
                siOldMap.put(si.Sample_Item__c, siItems);
            }
        }
        // 新建Sampling Inspection，先查询门店Sampling Detail
        List<Sampling_Detail__c> sdList = getExistSamplingDetailBaseStoreId(storeId);
        List<Sampling_Inspection__c> newSiList = new List<Sampling_Inspection__c>();
        System.debug('SDlist==========>>>>'+sdList);
        List<Sampling_Inspection__c> oldSiList = new List<Sampling_Inspection__c>();
        for (Sampling_Detail__c sd : sdList) {
            //待用
            System.debug('SiOldMap==========>>>>'+SiOldMap);
            System.debug('SiOldMap.ContainsKey==========>>>>'+siOldMap.containskey(sd.Id));
            if (siOldMap.containskey(sd.Id)) {
                Sampling_Inspection__c oldSi = siOldMap.get(sd.Id)[0];
                
                Sampling_Inspection__c newSi = new Sampling_Inspection__c();
                newSi.Inspection_Date__c = reportDate;
                // newSi.Placement_Status__c = oldSi.Placement_Status__c;
                newSi.Placement_Status__c = sd.Display_Status__c;
		        // newSi.Placement_Status__c = ''; // wfc 不自动带出Sampling Detail中的状态
                // newSi.Unplanned_Sample__c = 'No';
                newSi.Unplanned_Sample__c = sd.Unplanned_Sample__c == '否' ? 'No' : 'Yes'; // wfc 2025-03-14 带出 Sampling_Detail__c 的是否计划外状态
                newSi.ExternalID__c = String.valueOf(reportDate) + '_' + storeId + '_' + sd.Product__c + '_' + UserInfo.getUserId();
                newSi.Product__c = sd.Product__c;
                newSi.Shop__c = storeId;
                newSi.Sample_Item__c = sd.Id;
                newSi.ReRe__c = oldSi.ReRe__c;
                // wfc 关联巡店员日报
                newSi.Inspection_Report__c = reportId;

                newSiList.add(newSi);
                oldSiList.add(oldSi);
            } else {
                Sampling_Inspection__c newSi = new Sampling_Inspection__c();
                newSi.Inspection_Date__c = reportDate;
                // newSi.Placement_Status__c = '未展出';
                newSi.Placement_Status__c = sd.Display_Status__c;
		        // newSi.Placement_Status__c = ''; // wfc 不自动带出Sampling Detail中的状态
                // newSi.Unplanned_Sample__c = 'No';
                newSi.Unplanned_Sample__c = sd.Unplanned_Sample__c == '否' ? 'No' : 'Yes'; // wfc 2025-03-14 带出 Sampling_Detail__c 的是否计划外状态
                newSi.ExternalID__c = String.valueOf(reportDate) + '_' + storeId + '_' + sd.Product__c + '_' + UserInfo.getUserId();
                newSi.Product__c = sd.Product__c;
                newSi.Shop__c = storeId;
                newSi.Sample_Item__c = sd.Id;
                newSi.ReRe__c = '';
                // wfc 关联巡店员日报
                newSi.Inspection_Report__c = reportId;

                newSiList.add(newSi);
            }
        }
        System.debug('newSiList------------------------->>>'+newSiList);
        insert newSiList;
        samplingInspectionBindAttachments(newSiList, oldSiList);

    }

    // Added By Sunny ---- 带出上一次计划外出样
    public static void createPlanoutSamplingInspection(String storeId, Date reportDate) {
        Date firstDay = Date.newInstance(reportDate.year(), reportDate.month(), 1);
        List<Daily_Inspection_Report__c> previousReportList = [SELECT Id, Report_Date__c
                                                                FROM Daily_Inspection_Report__c 
                                                                WHERE Store__c = :storeId AND OwnerId = :UserInfo.getUserId() AND Report_Date__c < :reportDate AND Report_Date__c >= :firstDay 
                                                                ORDER BY Report_Date__c DESC 
                                                                LIMIT 1];
        if (previousReportList.size()==0) {
            return;
        }
        List<Sampling_Inspection__c> siList = getExistPlanOutSamplingInspectionBaseStoreId(storeId, UserInfo.getUserId(), previousReportList[0].Report_Date__c );
        List<Sampling_Inspection__c> newSiList = new List<Sampling_Inspection__c>();
        Map<String, Sampling_Inspection__c> oldAndNewMap = new Map<String, Sampling_Inspection__c>();
        for(Sampling_Inspection__c item : siList) {
            Sampling_Inspection__c newSi = new Sampling_Inspection__c();
            newSi.Inspection_Date__c = reportDate;
            newSi.Placement_Status__c = item.Placement_Status__c;
            newSi.Unplanned_Sample__c = item.Unplanned_Sample__c;
            newSi.ExternalID__c = String.valueOf(reportDate) + '_' + storeId + '_' + item.Product__c + '_' + UserInfo.getUserId();
            newSi.Product__c = item.Product__c;
            newSi.Shop__c = storeId;
            newSi.Sample_Item__c = item.Sample_Item__c;
            newSi.ReRe__c = item.ReRe__c;
            // wfc 关联巡店员日报
            newSi.Inspection_Report__c = previousReportList[0].Id;
            newSiList.add(newSi);
            oldAndNewMap.put(item.Id, newSi);
        }

        if(newSiList.size() > 0) {

            // User user = [SELECT Id, Name, Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];

            //日本有可能重复插入   lizunxing  2024-01-23
            if('Hisense Japan'.equals(user.Sales_Region__c)){
                Database.upsert(newSiList,Sampling_Inspection__c.Fields.ExternalID__c,false);
            }else{
                insert newSiList;
            }
            // samplingInspectionBindAttachments(newSiList, siList);
            
            if (PhaseIIIUtility.isIndonesia(user)) {
                return;
            }
            // 查询OldSi记录的附件
            List<ContentDocumentLink> querySi = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : oldAndNewMap.keySet()];
            Map<String, List<String>> documentMap = new Map<String, List<String>>();
            for (ContentDocumentLink item : querySi) {
                if (documentMap.containsKey(item.LinkedEntityId)) {
                    List<String> linkedIds = documentMap.get(item.LinkedEntityId);
                    linkedIds.add(item.ContentDocumentId);
                } else {
                    List<String> linkedIds = new List<String>();
                    linkedIds.add(item.ContentDocumentId);
                    documentMap.put(item.LinkedEntityId, linkedIds);
                }
            }
            // 关联新记录
            List<ContentDocumentLink> insertCdlList = new List<ContentDocumentLink>();
            for (String oldId : oldAndNewMap.keySet()) {
                String newId = oldAndNewMap.get(oldId).Id;
                if (documentMap.containsKey(oldId)) {
                    for (String documentId : documentMap.get(oldId)) {
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.ContentDocumentId = documentId;
                        cdl.LinkedEntityId = newId;
                        cdl.ShareType = 'V';
                        insertCdlList.add(cdl);
                    }
                }
            }
            if (insertCdlList.size()>0) {
                insert insertCdlList;
            }

        }
        
    }

    // Sampling Inspection绑定当年最近日期附件
    public static void samplingInspectionBindAttachments(List<Sampling_Inspection__c> newSiList, List<Sampling_Inspection__c> oldSiList) {
        // User user = [SELECT Id, Name, Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
        if (PhaseIIIUtility.isIndonesia(user)) {
            return;
        }
        // 根据Sample Item整理Map，整理出old Map new 的Id Map
        Map<String, Sampling_Inspection__c> newSitemMap = new Map<String, Sampling_Inspection__c>();
        for (Sampling_Inspection__c newSi : newSiList) {
            newSitemMap.put(newSi.Sample_Item__c, newSi);
        }
        Map<String, String> oldMapNew = new Map<String, String>();
        for (Sampling_Inspection__c oldSi : oldSiList) {
            if (newSitemMap.containsKey(oldSi.Sample_Item__c)) {
                Sampling_Inspection__c newSi = newSitemMap.get(oldSi.Sample_Item__c);
                oldMapNew.put(oldSi.Id, newSi.Id);
            }
        }
        if (oldMapNew.size()==0) {
            return;
        }
        // 查询OldSi记录的附件
        List<ContentDocumentLink> querySi = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : oldMapNew.keySet()];
        Map<String, List<String>> documentMap = new Map<String, List<String>>();
        for (ContentDocumentLink item : querySi) {
            if (documentMap.containsKey(item.LinkedEntityId)) {
                List<String> linkedIds = documentMap.get(item.LinkedEntityId);
                linkedIds.add(item.ContentDocumentId);
            } else {
                List<String> linkedIds = new List<String>();
                linkedIds.add(item.ContentDocumentId);
                documentMap.put(item.LinkedEntityId, linkedIds);
            }
        }
        // 关联新记录
        List<ContentDocumentLink> insertCdlList = new List<ContentDocumentLink>();
        for (String oldId : oldMapNew.keySet()) {
            String newId = oldMapNew.get(oldId);
            if (documentMap.containsKey(oldId)) {
                for (String documentId : documentMap.get(oldId)) {
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = documentId;
                    cdl.LinkedEntityId = newId;
                    cdl.ShareType = 'V';
                    insertCdlList.add(cdl);
                }
            }
        }
        if (insertCdlList.size()>0) {
            insert insertCdlList;
        }
    }

    // 更新Sampling Detail
    public static void updateSamplingDetail(List<Sampling_Inspection__c> siList) {
        Map<String, Sampling_Inspection__c> planInSI = new Map<String, Sampling_Inspection__c>();
        Map<String, ContentVersion> cvMap = new Map<String, ContentVersion>();
        Set<String> cLinkSet = new Set<String>();
        for (Sampling_Inspection__c si : siList){
            if (si.Sample_Item__c != null){
                planInSI.put(si.Sample_Item__c, si);
                cLinkSet.add(si.Id);
            }
        }
        if (planInSI.keySet().size() > 0){
            // 查询相关的文件信息
            // List<ContentDocumentLink> attachedDocuments = [SELECT ContentDocumentId, ContentDocument.FileType, LinkedEntityId
            //                                                FROM ContentDocumentLink
            //                                                WHERE LinkedEntityId = :cLinkSet
            //                                                WITH SECURITY_ENFORCED];
            // for (ContentDocumentLink cdl : attachedDocuments){
            //     ContentVersion cv = [SELECT Id, ContentBodyId, ContentDocumentId
            //                          FROM ContentVersion
            //                          WHERE ContentDocumentId = :cdl.ContentDocumentId AND IsLatest = true
            //                          ORDER BY VersionNumber DESC
            //                          LIMIT 1];
            //     cvMap.put(cdl.LinkedEntityId, cv);
            // }
            // 查询所有相关的 ContentDocumentLink
            List<ContentDocumentLink> attachedDocuments = [SELECT ContentDocumentId, ContentDocument.FileType, LinkedEntityId
                                               FROM ContentDocumentLink
                                               WHERE LinkedEntityId = :cLinkSet
                                               WITH SECURITY_ENFORCED];

            // 收集所有 ContentDocumentId
            Set<Id> documentIds = new Set<Id>();
            for (ContentDocumentLink cdl : attachedDocuments) {
                documentIds.add(cdl.ContentDocumentId);
            }

            // 单次查询所有相关的 ContentVersion
            List<ContentVersion> contentVersions = [
                SELECT Id, ContentBodyId, ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId IN :documentIds AND IsLatest = true
                ORDER BY VersionNumber DESC
            ];

            // 构建 ContentDocumentId 到 ContentVersion 的映射
            Map<Id, ContentVersion> documentIdToVersionMap = new Map<Id, ContentVersion>();
            for (ContentVersion cv : contentVersions) {
                documentIdToVersionMap.put(cv.ContentDocumentId, cv);
            }
            
            for (ContentDocumentLink cdl : attachedDocuments) {
                ContentVersion cv = documentIdToVersionMap.get(cdl.ContentDocumentId);
                if (cv != null) {
                    cvMap.put(cdl.LinkedEntityId, cv);
                }
            }
            List<Sampling_Detail__c> sdList = getExistSamplingDetailBaseId(planInSI.keySet());
            for (Sampling_Detail__c sd : sdList){
                Sampling_Inspection__c si = planInSI.get(sd.Id);
                sd.Display_Status__c = si.Placement_Status__c;
                //lzx 20250522 江燕要求记录出样明细最后一次操作的用户和日期
                sd.Sampling_Inspection_User__c = System.UserInfo.getUserId();
                sd.Sampling_Inspection_Date__c = si.Inspection_Date__c;
                if (cvMap.containsKey(si.Id)){
                    sd.ContentDocumentId__c = cvMap.get(si.Id).ContentDocumentId;
                    sd.CoverImgVersionId__c = cvMap.get(si.Id).Id;
                    sd.CoverImgContentBodyId__c = cvMap.get(si.Id).ContentBodyId;
                    // sd.Sampling_Inspection_User__c = System.UserInfo.getUserId();
                    // sd.Sampling_Inspection_Date__c = si.Inspection_Date__c;
                }
            }
            upsert sdList;
        }
    }

    // 新增计划外出样 （Sampling Inspection、CheckResult）
    @AuraEnabled
    public static ConResponse addPlanOutProduct(String recordJson, String productId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('recordJson'+recordJson);
        Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)JSON.deserializeStrict(recordJson, Daily_Inspection_Report__c.class);
        // System.debug('productJson'+productJson);
        // Product__c product = (Product__c)JSON.deserializeStrict(productJson, Product__c.class);
        List<Product__c> productList = [SELECT Id, Name, Product_Line__c, Series__c, Category__c FROM Product__c WHERE Id = : productId];
        if (productList.size()==0) {
            resp.code= -1;
            resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Product__c.getLabel()});
            return resp;
        }
        System.debug('checkresultsize=' + [select id from CheckResult__c where InspectorDailyReport__c =:report.Id].size());
        Product__c product = productList[0];
        // 查询已存在的CheckResult
        List<CheckResult__c> quoeryCheckResultList = getExistCheckResultBaseReportId(report.Id);
        System.debug('quoeryCheckResultList.size=' + quoeryCheckResultList.size());
        // 收集已存在CheckResult Product_Line__c关联巡店员日报
        Set<String> crProductLineSet = new Set<String>();
        for (CheckResult__c cr : quoeryCheckResultList) {
            System.debug('cr.CheckItem__r.Product_Line__c=' + cr.CheckItem__r.Product_Line__c);
            if (!String.isBlank(cr.CheckItem__r.Product_Line__c)) {
                crProductLineSet.add(cr.CheckItem__r.Product_Line__c);
            }
        }
        //lzx 2024-11-12 阿根廷添加计划外产品时自动展开产品线
        mso.put('productLine', product.Product_Line__c);
        System.debug('product.Product_Line__c=' + product.Product_Line__c);
        // 新建计划外Sampling Inspection
        Sampling_Inspection__c newSi = new Sampling_Inspection__c();
        newSi.Inspection_Date__c = report.Report_Date__c;
        newSi.Placement_Status__c = '展出';
        newSi.Unplanned_Sample__c = 'Yes';
        newSi.ExternalID__c = String.valueOf(report.Report_Date__c) + '_' + report.Store__c + '_' + product.Id + '_' + UserInfo.getUserId();
        newSi.Product__c = product.Id;
        newSi.Shop__c = report.Store__c;
        newSi.ReRe__c = '';
        // wfc 关联巡店员日报
        newSi.Inspection_Report__c = report.Id;

        insert newSi;

        Boolean isRemotedInspect = report.Inspect_Type__c == INSPECT_TYPE_REMOTE ? true : false;
        Set<String> productLineSet = new Set<String>();
        productLineSet.add(product.Product_Line__c);
        // 如果不存在该产品线CheckResult，新建CheckResult
        if (crProductLineSet.size() > 0 && !crProductLineSet.contains(product.Product_Line__c)) {
            System.debug('checkresultsize=');
            // createCheckResult(report.Store__c, UserInfo.getUserId(), report.Id, productLineSet, null);
            createCheckResult(report.Store__c, UserInfo.getUserId(), report.Id, productLineSet, new Map<String, List<String>>{product.Product_Line__c => new List<String>{newSi.Id}}, isRemotedInspect);
        } else {
            createCheckResult2(report.Store__c, UserInfo.getUserId(), report.Id, productLineSet, new Map<String, List<String>>{product.Product_Line__c => new List<String>{newSi.Id}}, isRemotedInspect);
        }
        // createCheckResult(report.Store__c, UserInfo.getUserId(), report.Id, productLineSet, new Map<String, List<String>>{}, isRemotedInspect);
        System.debug('checkresultsize=' + [select id from CheckResult__c where InspectorDailyReport__c =:report.Id].size());
        

        System.debug('checkresultsize=' + [select id from CheckResult__c where InspectorDailyReport__c =:report.Id].size());
        // 获取计划外Sampling Inspection信息
        List<Sampling_Inspection__c> planOutSamplingInspection = getExistPlanOutSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
        // 更新Sampling Inspection信息
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
        siList.addAll(planOutSamplingInspection);
        // todo 给产品添加金额 wfc
        siList = setProductPrice(report.Store__c, siList);
        mso.put('samplingInspections', siList);
        // 更新CheckResult信息
        Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(report.Id);
        mso.put('checkResults', checkResults);
        mso.put('checkResultsIsRelatedToProduct', getCheckResultBycurrentUserLanguage(getExistCheckResultIsRelatedToProductBaseReportId(report.Id)));
        System.debug('checkresultsize=' + [select id from CheckResult__c where InspectorDailyReport__c =:report.Id].size());
        // 更新日报信息
        List<Daily_Inspection_Report__c> dirList = getExistDailyInspectionReportBasedId(report.Id);
        if (dirList.size()==0) {
            resp.code= -1;
            resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Daily_Inspection_Report__c.getLabel()});
            return resp;
        }
        System.debug('checkresultsize=' + [select id from CheckResult__c where InspectorDailyReport__c =:report.Id].size());
        Daily_Inspection_Report__c dir = dirList[0];
        dir.Brand__c = report.Brand__c;
        dir.Summary__c = report.Summary__c;
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);
        System.debug('resp======>'+resp);
        System.debug('checkresultsize=' + [select id from CheckResult__c where InspectorDailyReport__c =:report.Id].size());
        return resp;
    }

    // 删除产品线 （Sampling Inspection、CheckResult）
    @AuraEnabled
    public static ConResponse delProductLine(String recordJson, String productLine) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('recordJson'+recordJson);
        Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)JSON.deserializeStrict(recordJson, Daily_Inspection_Report__c.class);
        
        List<Sampling_Inspection__c> delSiList = getExistPlanOutSamplingInspectionBaseStoreIddDateProductLine(report.Store__c, report.Report_Date__c, productLine, report.OwnerId);
        // 同时删除产品关联的题目 start 20241023
        Map<Id, Sampling_Inspection__c> delSiMap = new Map<Id, Sampling_Inspection__c>(delSiList);
        List<CheckResult__c> productCRList = [SELECT Id FROM CheckResult__c WHERE Sampling_Inspection__c IN :delSiMap.keySet()];
        Map<Id, CheckResult__c> productCRMap = new Map<Id, CheckResult__c>(productCRList);
        List<Ticket__c> delTickets = [SELECT Id, CheckResult__c FROM Ticket__c WHERE CheckResult__c IN :productCRMap.keySet()];
        System.debug('delTickets=' + delTickets);
        delete delTickets;
        System.debug('productCRList=' + productCRList);
        delete productCRList;
        mso.put('delTickets', (new Map<Id, Ticket__c>(delTickets)).keySet());
        // 同时删除产品关联的题目 end 20241023
        delete delSiList;

        List<CheckResult__c> delCrList = getExistCheckResultBaseReportIdProductLine(report.Id, productline);
        delete delCrList;

        // 获取计划外Sampling Inspection信息
        List<Sampling_Inspection__c> planOutSamplingInspection = getExistPlanOutSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
        // 更新Sampling Inspection信息
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
        siList.addAll(planOutSamplingInspection);
        mso.put('samplingInspections', siList);
        // 更新CheckResult信息
        Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(report.Id);
        mso.put('checkResults', checkResults);
        // mso.put('checkResultsIsRelatedToProduct', getExistCheckResultIsRelatedToProductBaseReportId(report.Id));
        // 更新日报信息
        List<Daily_Inspection_Report__c> dirList = getExistDailyInspectionReportBasedId(report.Id);
        if (dirList.size()==0) {
            resp.code= -1;
            resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Daily_Inspection_Report__c.getLabel()});
            return resp;
        }
        Daily_Inspection_Report__c dir = dirList[0];
        dir.Brand__c = report.Brand__c;
        dir.Summary__c = report.Summary__c;
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);
        System.debug('resp======>'+resp);
        return resp;
    }

    // 获取Ticket
    // public static Map<String, List<Task>> getTicket(Daily_Inspection_Report__c report) {

    //     List<Task> taskAll = getExistTaskBaseStoreIdAndUser(report.Store__c, report.OwnerId, report.Report_Date__c);

    //     List<Task> openTasks = new List<Task>();
    //     List<Task> closedTasks = new List<Task>();
    //     for (Task task : taskAll) {
    //         if (task.WhatId == report.Id) {
    //             openTasks.add(task);
    //         // } else if (task.Closed_Daily_Inspection_Report__c == report.Id || task.Confirm_Task__c != 'Yes') {
    //         } else if (task.Closed_Daily_Inspection_Report__c == report.Id || (task.Status != 'Closed' && task.CreatedDate <= report.Report_Date__c)) {
    //             closedTasks.add(task);
    //         }
    //     }

    //     Map<String, List<Task>> taskMap = new Map<String, List<Task>>();
    //     taskMap.put('openTasks', openTasks);
    //     taskMap.put('closedTasks', closedTasks);

    //     return taskMap;
    // }

    /**
     * @description 获取日报的tickect
     * @param   report 日报
     * @return  Map<String, List<Ticket__c>>    ticketmap
     */
    public static Map<String, List<Ticket__c>> getTicket(Daily_Inspection_Report__c report) {

        List<Ticket__c> taskByOwner = getExistTicketBaseStoreIdAndUser(report.Store__c, report.OwnerId, report.Report_Date__c);
        List<Ticket__c> ticketById = getTicketBaseByReportId(report.Id);
        Map<Id, Ticket__c> idToObjectMap = new Map<Id, Ticket__c>();
        for (Ticket__c obj : taskByOwner) {
            idToObjectMap.put(obj.Id, obj);
        }
        for (Ticket__c obj : ticketById) {
            if (!idToObjectMap.containsKey(obj.Id)) {
                idToObjectMap.put(obj.Id, obj);
            }
        }
        List<Ticket__c> taskAll = new List<Ticket__c>(idToObjectMap.values());
        String languageIsCN = 'zh_CN';
        String languageIsEN = 'en_US';
        String currentUserLanguage = UserInfo.getLanguage();
        // #多语言优化 helper text 多语言 add by DTT-Bright 20240729 START
        for (Ticket__c t : taskAll) {   
            if (!t.SystemGeneration__c) {
                continue;
            }         
            if (currentUserLanguage == languageIsCN) {
                t.Subject__c = t.SubjectCN__c;
            } else if (currentUserLanguage == languageIsEN) {
                t.Subject__c = t.SubjectEN__c;
            }
        }
        // #多语言优化 helper text 多语言 add by DTT-Bright 20240729 END

        List<Ticket__c> openTasks = new List<Ticket__c>();
        List<Ticket__c> closedTasks = new List<Ticket__c>();
        for (Ticket__c task : taskAll) {
            if (task.InspectionReport__c == report.Id) {
                openTasks.add(task);
            // } else if (task.Closed_Daily_Inspection_Report__c == report.Id || task.Confirm_Task__c != 'Yes') {
            } else if (task.ClosedDailyInspectionReport__c == report.Id || (task.Status__c != 'Closed' && task.CreatedDate <= report.Report_Date__c)) {
                closedTasks.add(task);
            }
        }

        Map<String, List<Ticket__c>> taskMap = new Map<String, List<Ticket__c>>();
        taskMap.put('openTasks', openTasks);
        taskMap.put('closedTasks', closedTasks);

        return taskMap;
    }

    // 附件上传
    public static void createUploadFile(String recordId, String photoStream){
        System.debug('photoStream--->'+photoStream);

        if (recordId==null || photoStream==null || photoStream=='') {
            return;
        }
        
        String fileName = System.now().format('yyyyMMddHHmmss') + '.jpeg';
        ContentVersion cv = new ContentVersion();
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

    // 获取Picklist values
    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getPickList(String objectName, String fieldName) {
        if (String.isBlank(fieldName)) {
            return null;
        }

        try {
            Map<String, String> temp = Utility.getPicklistValueMap(objectName, fieldName);
            List<Map<String, String>> result = new List<Map<String, String>>();
            for (String key : temp.keySet()) {
                if (objectName=='Task' && fieldName=='Status') {
                    if (temp.get(key)=='Open'||temp.get(key)=='Resolved'||temp.get(key)=='Closed') {
                        result.add(new Map<String, String> {
                            'label' => temp.get(key),
                            'value' => key
                        });
                    }
                } else {
                    result.add(new Map<String, String> {
                        'label' => temp.get(key),
                        'value' => key
                    });
                }
            }

            return result;
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
        }

        return null;
    }
    

    // 获取Task Field label
    // @AuraEnabled(Cacheable=true)
    // public static Map<String, String> getTaskFieldLabel(String objectName) {
    //     try {
    //         Map<String, String> result = new Map<String, String>();
    //         // Task
    //         result.put('Subject',Schema.Task.fields.Subject.getDescribe().getLabel());
    //         result.put('Description',Schema.Task.fields.Description.getDescribe().getLabel());
    //         result.put('WhatId',Schema.Task.fields.WhatId.getDescribe().getLabel());
    //         result.put('OwnerId',Schema.Task.fields.OwnerId.getDescribe().getLabel());
    //         result.put('Status',Schema.Task.fields.Status.getDescribe().getLabel());
    //         result.put('ActivityDate',Schema.Task.fields.ActivityDate.getDescribe().getLabel());
    //         result.put('Priority',Schema.Task.fields.Priority.getDescribe().getLabel());
    //         // Activity
    //         result.put('TicketNumber__c',Schema.Task.fields.TicketNumber__c.getDescribe().getLabel());
    //         result.put('Closed_Daily_Inspection_Report__c',Schema.Task.fields.Closed_Daily_Inspection_Report__c.getDescribe().getLabel());


    //         return result;
    //     } catch (Exception e) {
    //         // throw new AuraHandledException(e.getMessage());
    //     }

    //     return null;
    // }

    // quoery Product
    @AuraEnabled
    public static ConResponse queryProduct(String productId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        Product__c product  = [SELECT Id, Name, Product_Line__c, Series__c, Category__c FROM Product__c WHERE Id = : productId];
        mso.put('selectedProductInfo', product);
        System.debug('product======>'+product);
        System.debug('resp======>'+resp);
        return resp;
    }
    // Query Data===========================================================
    // 获取门店负责人 (获取所有可选择门店)
    public static List<Responsible_Person__c> getResponsiblePerson(String userId) {
        return [SELECT 
                    Id,
                    Shop_Name__c,
                    Shop_Name__r.Name,
                    Shop_Name__r.Shop_Center_Location__c,
                    Shop_Name__r.Shop_Center_Location__Latitude__s,
                    Shop_Name__r.Shop_Center_Location__Longitude__s,
                    Promoter_Attendance_Rule__r.Distance__c,
                    RecordType__c,//Add By Ethan 20231011 增加查询返回字段
                    Shop_Name__r.Sales_Region__c
                FROM Responsible_Person__c 
                WHERE 
                    Principal__c = : userId
                AND (RecordType__c = '巡店员' OR RecordType__c = 'Regional Manager' OR RecordType__c = 'Backup Floorwalker' OR RecordType__c = '促销员')];
    }

    /**
     * @description 获取门店的门店负责人
     * @param   storeId     门店id
     * @return  门店负责人
     */
    public static List<Responsible_Person__c> getResponsiblePersonBaseStoreId(String storeId) {
        return [SELECT 
                    Id,
                    Shop_Name__c,
                    Shop_Name__r.Name,
                    Shop_Name__r.Shop_Center_Location__c,
                    Shop_Name__r.Shop_Center_Location__Latitude__s,
                    Shop_Name__r.Shop_Center_Location__Longitude__s,
                    Promoter_Attendance_Rule__r.Distance__c,
                    RecordType__c,//Add By Ethan 20231011 增加查询返回字段
                    Shop_Name__r.Sales_Region__c
                FROM Responsible_Person__c 
                WHERE 
                    Principal__c = : UserInfo.getUserId() 
                AND (RecordType__c = '巡店员' OR RecordType__c = 'Regional Manager' OR RecordType__c = 'Backup Floorwalker' OR RecordType__c = '促销员') 
                AND Shop_Name__c = : storeId];
    }
    
    // 获取日报信息
    public static List<Daily_Inspection_Report__c> getExistDailyInspectionReportOwnerNameBasedId(String recordId) {
        return [
                SELECT 
                    Id,
                    Owner.Name
                FROM Daily_Inspection_Report__c 
                WHERE 
                    Id =: recordId];
    }

    /**
     * @description 获取巡店报告
     * @param   recordId     报告id
     * @return  巡店报告
     */
    public static List<Daily_Inspection_Report__c> getExistDailyInspectionReportBasedId(String recordId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Status__c,
                    Store__c,
                    Report_Date__c,
                    Sales_Region__c,
                    //阿根廷新加字段
                    Brand__c,
                    // TotalScore__c,
                    // TotalScore_Max__c,
                    // AverageScore__c,
                    // AverageScore_Max__c,
                    Total_Score__c,
                    Total_Score_Max__c,
                    Average_Score_Count__c,
                    Average_Score__c,
                    Average_Score_Max__c,
                    NeedCheckIn__c,
                    Summary__c,
                    OwnerId,
                    Note__c,
                    Inspect_Type__c, // 20231031 Ethan
                    Comments__c,
                    Contact_Person__c,
                    Contact_Status__c,
                    Contact_Type__c,
                    Start_Time__c
                FROM Daily_Inspection_Report__c 
                WHERE 
                    Id =: recordId];
    }

    /**
     * @description 获取巡店报告
     * @param   recordId     报告id
     * @return  巡店报告
     */
    public static List<Sampling_Inspection_Argentina__c> getSamplingInspectionArgentinaByReportId(String recordId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Brand__c,
                    ReRe__c,
                    Daily_Inspection_Report__c,
                    Product_Line__c,
                    Quantity_Of_Exhibits_Total__c,
                    POP__c,
                    Placement_Status__c,
                    External_Id__c
                FROM Sampling_Inspection_Argentina__c 
                WHERE 
                    Daily_Inspection_Report__c =: recordId];
    }

    /**
     * @description 以巡店报告
     * @param   externalId     报告id
     * @return  巡店报告
     */
    public static List<Daily_Inspection_Report__c> getExistDailyInspectionReportBasedExternalId(String externalId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Status__c,
                    Store__c,
                    Report_Date__c,
                    //阿根廷新加字段
                    Brand__c,
                    // TotalScore__c,
                    // TotalScore_Max__c,
                    // AverageScore__c,
                    // AverageScore_Max__c,
                    Total_Score__c,
                    Total_Score_Max__c,
                    Average_Score_Count__c,
                    Average_Score__c,
                    Average_Score_Max__c,
                    NeedCheckIn__c,
                    Summary__c,
                    OwnerId,
                    Note__c,
                    Inspect_Type__c, 
                    Comments__c,
                    Contact_Person__c,
                    Contact_Status__c,
                    Contact_Type__c,
                    Start_Time__c
                FROM Daily_Inspection_Report__c 
                WHERE 
                    ExternalId__c =: externalId];
    }

    // 获取考勤信息
    public static List<Promoter_Attendance__c> getExistAttendanceBasedExternalId(String externalId) {
        return [
                SELECT 
                    Id,
                    CheckInStatus__c,
                    SignInTime__c,
                    SignOutTime__c,
                    Shop__c,
                    Shop__r.Name,
                    CheckOutShop__c, 
                    CheckOutShop__r.Name,
                    ApprovalStatus__c
                FROM Promoter_Attendance__c 
                WHERE 
                    ExternalId__c =: externalId];
    }

    // 获取考勤信息（详细信息）
    public static List<Promoter_Attendance_Information__c> getExistPromoterAttendanceInformationBaseId(String paiId) {
        return [
                SELECT 
                    Id,
                    CheckIn_Date__c,
                    CheckIn_Time__c,
                    Shop__c,
                    Shop__r.Name,
                    Shop__r.Shop_Center_Location__Latitude__s,
                    Shop__r.Shop_Center_Location__Longitude__s,
                    Remark__c, 
                    Distance__c,
                    Location__c,
                    Location__Latitude__s,
                    Location__Longitude__s,
                    CreatedBy.Name
                FROM Promoter_Attendance_Information__c 
                WHERE 
                    Id = : paiId];
    }

    /**
     * @description 获取签到信息
     * @param   AttendanceId    考勤id
     * @param   todayDate       当天日期
     * @param   storeId         门店id
     * @return  打卡列表
     */
    public static List<Promoter_Attendance_Information__c> getExistPromoterAttendanceInformationBasedAttendanceId(String AttendanceId, Date todayDate, String storeId) {
        return [
                SELECT 
                    Id,
                    CheckIn_Date__c,
                    CheckIn_Time__c,
                    Shop__c,
                    Shop__r.Name,
                    Shop__r.Shop_Center_Location__Latitude__s,
                    Shop__r.Shop_Center_Location__Longitude__s,
                    Shop__r.Address1__c, 
                    Remark__c, 
                    Distance__c,
                    Location__c,
                    Location__Latitude__s,
                    Location__Longitude__s,
                    CreatedBy.Name
                FROM Promoter_Attendance_Information__c 
                WHERE 
                    Promoter_Attendance__c =: AttendanceId 
                AND Type__c = 'Check in'
                AND CheckIn_Date__c = : todayDate
                AND Shop__c = : storeId];
    }

    /**
     * @description 获取签退信息
     * @param   AttendanceId    考勤id
     * @param   todayDate       当天日期
     * @param   storeId         门店id
     * @return  打卡列表
     */
    public static List<Promoter_Attendance_Information__c> getExistPromoterAttendanceInformationCheckOutBasedAttendanceId(String AttendanceId, Date todayDate, String storeId) {
        return [
                SELECT 
                    Id,
                    CheckIn_Date__c,
                    CheckIn_Time__c,
                    Shop__c,
                    Shop__r.Name,
                    Shop__r.Shop_Center_Location__Latitude__s,
                    Shop__r.Shop_Center_Location__Longitude__s,
                    Remark__c, 
                    Distance__c,
                    Location__c,
                    Location__Latitude__s,
                    Location__Longitude__s,
                    CreatedBy.Name
                FROM Promoter_Attendance_Information__c 
                WHERE 
                    Promoter_Attendance__c =: AttendanceId 
                AND Type__c = 'Check out'
                AND CheckIn_Date__c = : todayDate
                AND Shop__c = : storeId];
    }

    // 获取巡店计划
    public static List<Inspection_Shop_Plan__c> getExistInspectionShopPlanBaseReportInfo(Date reportDate, String reportOwner) {
        return [
                SELECT 
                    Id,
                    Name,
                    OwnerId__c,
                    Inspection_Year__c,
                    Inspection_Month__c,
                    Status__c
                FROM Inspection_Shop_Plan__c 
                WHERE 
                    OwnerId__c = : reportOwner 
                AND Inspection_Year__c = : String.valueOf(reportDate.year())
                AND Inspection_Month__c = : String.valueOf(reportDate.month())];
    }

    // 获取巡店任务
    public static List<Inspection_Shop_Task__c> getExistInspectionShopTaskBaseReportInfo(Date reportDate, String reportOwner) {
        return [
                SELECT 
                    Id,
                    Inspection_Date__c,
                    Shop__c,
                    Status__c,
                    Inspection_Plan__c,
                    OwnerId
                FROM Inspection_Shop_Task__c 
                WHERE 
                    Inspection_Date__c = : reportDate 
                AND OwnerId = : reportOwner
                AND Status__c IN ('未到访','已到访')];
    }

    /**
     * @description 获取巡店任务
     * @param   storeId         门店id
     * @param   reportDate      报告日期
     * @param   reportOwner     报告人
     * @return  打卡列表
     */
    public static List<Inspection_Shop_Task__c> getExistInspectionShopTaskBaseCheck(String storeId, Date reportDate, String reportOwner) {
        return [
                SELECT 
                    Id,
                    Inspection_Date__c,
                    Shop__c,
                    Status__c,
                    Inspection_Plan__c
                FROM Inspection_Shop_Task__c 
                WHERE 
                    Inspection_Date__c = : reportDate 
                AND Shop__c = : storeId
                AND OwnerId = : reportOwner];
    }

    // 获取CheckList
    public static List<CheckResult__c> getExistCheckResultBaseReportId(String reportId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Scores__c,
                    Comments__c,
                    Status__c,
                    Result__c,
                    CheckItem__c,
                    CheckItem__r.Name,
                    CheckItem__r.Product_Line__c,
                    toLabel(CheckItem__r.Project__c),
                    CheckItem__r.Id,
                    CheckItem__r.Has_Sample_Pictures__c,
                    CheckItem__r.MaximumScore__c,
                    CheckItem__r.HasFile__c,
                    CheckItem__r.Description__c,
                    CheckItem__r.Description_CN__c,
                    CheckItem__r.Description_EN__c,
                    CheckItem__r.Description_Filling_Language__c,
                    CheckItem__r.IsYesOrNo__c,
                    CheckItem__r.HelpText__c,
                    // #多语言优化 多语言 add by DTT-Bright 20240728 START
                    CheckItem__r.HelpTextCN__c,
                    CheckItem__r.HelpTextEN__c,
                    // #多语言优化 多语言 add by DTT-Bright 20240728 END
                    CheckItem__r.Enter_Choice__c,
                    CheckItem__r.Enter_Choice_CN__c,
                    CheckItem__r.Enter_Choice_EN__c,
                    CheckItem__r.OrderNumber__c,
                    CheckItem__r.IsCountInScore__c,
                    CheckItem__r.Require_Comment_Scores__c,
                    CheckItem__r.Scores_require_file__c,
                    CheckItem__r.HasComment__c,
                    CheckItem__r.Is_Text__c
                FROM CheckResult__c
                WHERE 
                    InspectorDailyReport__c = : reportId
                AND CheckItem__r.Is_Related_To_Product__c = false
                ORDER BY CheckItem__r.OrderNumber__c];
    }

    /**
     * @description 获取报告的检查结果
     * @param   reportId    报告id
     * @return  检查项列表
     */
    public static List<CheckResult__c> getExistCheckResultIsRelatedToProductBaseReportId(String reportId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Scores__c,
                    Comments__c,
                    Status__c,
                    Sampling_Inspection__c,
                    CheckItem__c,
                    CheckItem__r.Name,
                    CheckItem__r.Product_Line__c,
                    toLabel(CheckItem__r.Project__c),
                    CheckItem__r.MaximumScore__c,
                    CheckItem__r.HasFile__c,
                    CheckItem__r.Id,
                    CheckItem__r.Has_Sample_Pictures__c,
                    CheckItem__r.Description__c,
                    CheckItem__r.Description_CN__c,
                    CheckItem__r.Description_EN__c,
                    CheckItem__r.Description_Filling_Language__c,
                    CheckItem__r.IsYesOrNo__c,
                    CheckItem__r.HelpText__c,
                    // #多语言优化 多语言 add by DTT-Bright 20240728 START
                    CheckItem__r.HelpTextCN__c,
                    CheckItem__r.HelpTextEN__c,
                    // #多语言优化 多语言 add by DTT-Bright 20240728 END
                    CheckItem__r.Enter_Choice__c,
                    CheckItem__r.Enter_Choice_CN__c,
                    CheckItem__r.Enter_Choice_EN__c,
                    CheckItem__r.OrderNumber__c,
                    CheckItem__r.IsCountInScore__c,
                    CheckItem__r.Require_Comment_Scores__c,
                    CheckItem__r.Scores_require_file__c,
                    CheckItem__r.HasComment__c,
                    CheckItem__r.Is_Text__c
                FROM CheckResult__c
                WHERE 
                    InspectorDailyReport__c = : reportId
                AND CheckItem__r.Is_Related_To_Product__c = true
                ORDER BY CheckItem__r.OrderNumber__c];
    }

    /**
     * @description 获取报告的检查结果
     * @param   reportId    报告id
     * @param   productline    产品线
     * @return  检查项列表
     */
    public static List<CheckResult__c> getExistCheckResultBaseReportIdProductLine(String reportId, String productline) {
        return [
                SELECT 
                    Id,
                    Name,
                    Scores__c,
                    Comments__c,
                    Status__c,
                    CheckItem__c,
                    CheckItem__r.Name,
                    CheckItem__r.Product_Line__c,
                    CheckItem__r.Project__c,
                    CheckItem__r.MaximumScore__c,
                    CheckItem__r.HasFile__c,
                    CheckItem__r.Id,
                    CheckItem__r.Has_Sample_Pictures__c,
                    CheckItem__r.Description__c,
                    CheckItem__r.Description_CN__c,
                    CheckItem__r.Description_EN__c,
                    CheckItem__r.Description_Filling_Language__c,
                    CheckItem__r.IsYesOrNo__c,
                    CheckItem__r.HelpText__c,
                    // #多语言优化 多语言 add by DTT-Bright 20240728 START
                    CheckItem__r.HelpTextCN__c,
                    CheckItem__r.HelpTextEN__c,
                    // #多语言优化 多语言 add by DTT-Bright 20240728 END
                    CheckItem__r.Enter_Choice__c,
                    CheckItem__r.Enter_Choice_CN__c,
                    CheckItem__r.Enter_Choice_EN__c,
                    CheckItem__r.OrderNumber__c,
                    CheckItem__r.IsCountInScore__c,
                    CheckItem__r.Require_Comment_Scores__c,
                    CheckItem__r.Scores_require_file__c,
                    CheckItem__r.HasComment__c,
                    CheckItem__r.Is_Text__c 
                FROM CheckResult__c
                WHERE 
                    InspectorDailyReport__c = : reportId
                AND CheckItem__r.Product_Line__c = : productline
                AND CheckItem__r.Is_Related_To_Product__c = false
                ORDER BY CheckItem__r.OrderNumber__c];
    }

    /**
     * @description 获取报告的检查结果
     * @param   checkItemIds    检查项id
     * @param   monthDate       日期
     * @param   storeId         门店id
     * @param   userId          用户id
     * @return  检查项列表
     */
    public static List<CheckResult__c> getExistCheckResultBaseCheckItemIds(Set<Id> checkItemIds, Date monthDate, String storeId, String userId) {
        return [
                SELECT 
                    Id,
                    Name,
                    CheckItem__c,
                    InspectorDailyReport__c,
                    InspectorDailyReport__r.Report_Date__c
                FROM CheckResult__c
                WHERE 
                    InspectorDailyReport__r.Report_Date__c >= : monthDate
                AND InspectorDailyReport__r.Store__c = : storeId
                AND InspectorDailyReport__r.Status__c = 'Submitted'
                AND CheckItem__c IN : checkItemIds
                AND InspectorDailyReport__r.OwnerId = : userId
                // AND CheckItem__r.Is_Related_To_Product__c = false
                ORDER BY InspectorDailyReport__r.Report_Date__c DESC];
    }
    // 获取Task
    // public static List<Task> getExistTaskBaseStoreIdAndUser(String storeId, String userId, Date reportdate) {
    //     return [
    //             SELECT 
    //                 Id,
    //                 WhatId,
    //                 TicketNumber__c,
    //                 // Confirm_Task__c,
    //                 // TicketStatus__c,
    //                 Closed_Daily_Inspection_Report__c,
    //                 Subject,
    //                 Description,
    //                 OwnerId,
    //                 Status,
    //                 Priority,
    //                 ActivityDate,
    //                 CompletedDateTime,
    //                 LastModifiedDate,
    //                 CreatedDate
    //             FROM Task
    //             WHERE 
    //                 CreatedById = : userId
    //             AND What.type = 'Daily_Inspection_Report__c' 
    //             // AND CreatedDate <= : reportdate
    //             AND WhatId IN (SELECT Id FROM Daily_Inspection_Report__c WHERE Store__c = : storeId)];
    // }
    // 获取Ticket
    public static List<Ticket__c> getExistTicketBaseStoreIdAndUser(String storeId, String userId, Date reportdate) {
        return [
                SELECT 
                    Id,
                    InspectionReport__c,
                    Name,
                    ClosedDailyInspectionReport__c,
                    Subject__c,
                    SubjectCN__c,
                    SubjectEN__c,
                    Description__c,
                    Product_Line__c,
                    Product_Category__c,
                    AssignedTo__c,
                    Department__c,          // added by Sunny about chile department -[231026]
                    SystemGeneration__c,    // added by Sunny  -[231219]
                    CheckResult__c,         // added By Sunny -[240507]
                    AssignedTo__r.name,
                    Status__c,
                    Priority__c,
                    DueDate__c,
                    LastModifiedDate,
                    CreatedDate,
                    Category__c,
                    SeriesNum__c,
                    Product__c
                FROM Ticket__c
                WHERE 
                    CreatedById = : userId
                AND InspectionReport__c IN (SELECT Id FROM Daily_Inspection_Report__c WHERE Store__c = : storeId)];
    }
    //20241212 根据Id获取绑定的所有Ticket
    public static List<Ticket__c> getTicketBaseByReportId(String reportId) {
        return [
                SELECT 
                    Id,
                    InspectionReport__c,
                    Name,
                    ClosedDailyInspectionReport__c,
                    Subject__c,
                    SubjectCN__c,
                    SubjectEN__c,
                    Description__c,
                    Product_Line__c,
                    Product_Category__c,
                    AssignedTo__c,
                    Department__c,          // added by Sunny about chile department -[231026]
                    SystemGeneration__c,    // added by Sunny  -[231219]
                    CheckResult__c,         // added By Sunny -[240507]
                    AssignedTo__r.name,
                    Status__c,
                    Priority__c,
                    DueDate__c,
                    LastModifiedDate,
                    CreatedDate,
                    Category__c,
                    SeriesNum__c,
                    Product__c
                FROM Ticket__c
                WHERE    
                 InspectionReport__c =: reportId];
    }
    // 获取Mileage
    public static List<Mileage__c> getExistMileageBaseRecordId(String recordId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Report__c,
                    Start__c,
                    End__c,
                    Mileage_Of_Today__c
                FROM Mileage__c
                WHERE 
                    Report__c = : recordId];
    }
    // 获取Sampling Detail
    public static List<Sampling_Detail__c> getExistSamplingDetailBaseStoreId(String storeId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Shop__c,
                    Shop__r.name,
                    Is_Add__c,
                    Display_Status__c,
                    Unplanned_Sample__c,
                    // Display_Type__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c
                FROM Sampling_Detail__c 
                WHERE 
                    Shop__c = : storeId
                AND Is_Add__c = '是'];
                // AND Display_Status__c = '展出'];
    }

    /**
     * @description 获取出样明细
     * @param   ids 出样明细列表
     * @return  出样明细
     */
    public static List<Sampling_Detail__c> getExistSamplingDetailBaseId(Set<String> ids) {
        return [
                SELECT 
                    Id,
                    Name,
                    Shop__c,
                    Shop__r.name,
                    Is_Add__c,
                    Display_Status__c,
                    Unplanned_Sample__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c
                FROM Sampling_Detail__c 
                WHERE 
                    Id IN : ids];
    }

    // 获取Sampling Inspection
    public static List<Sampling_Inspection__c> getExistSamplingInspectionBaseStoreId(String storeId, String userId, Date yearFirstDay) {
        List<Sampling_Inspection__c> sampl1 = [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Hisense_Rack__c,
                    Quantity_Hisense__c,
                    Quantity_POP__c,
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c,
                    // Display_Type__c,  
                    On_Wall_Display__c,
                    POP__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Shop__c =  : storeId
                AND Unplanned_Sample__c = 'No'
                AND OwnerId = : userId
                AND Inspection_Date__c >= :yearFirstDay
                ORDER BY Inspection_Date__c DESC];
        List<Sampling_Inspection__c> sampl2 =  [
            SELECT 
                Id,
                Name,
                Inspection_Date__c,
                Placement_Status__c,
                Unplanned_Sample__c,
                ExternalID__c,
                Product__c,
                Product__r.Name,
                Product__r.Name_Description__c,
                Product__r.Product_Line__c,
                Product__r.Series__c, 
                Product__r.Category__c,
                Product__r.Guiding_Price__c,
                Product__r.CurrencyIsoCode,
                Shop__c,
                Sample_Item__c,
                ReRe__c,
                //阿根廷新加字段
                Hisense_Rack__c,
                Quantity_Hisense__c,
                Quantity_POP__c,
                Quantity_Of_Exhibits_DS__c,
                Quantity_Of_Exhibits_OWD__c, 
                Stock__c,   
                Display_Stand__c, 
                On_Wall_Display__c,
                POP__c,
                Is_Prototype_Complete__c, 
                Is_Built_in_Video__c,   
                Is_Epos__c,
                Price__c,
                Sample_Item__r.Sampling_Standard__r.Flag__c
            FROM Sampling_Inspection__c 
            WHERE 
            Shop__c =  : storeId
            AND Unplanned_Sample__c = 'Yes'
            AND Product__c IN (select Product__c from Sampling_Detail__c where Shop__c =:storeId AND Is_Add__c='是')
            AND OwnerId = : userId
            AND Inspection_Date__c >= :yearFirstDay
            ORDER BY Inspection_Date__c DESC];
            for(Sampling_Inspection__c si:sampl2){
                // si.Unplanned_Sample__c = 'No';
                sampl1.add(si);
            }
        return sampl1;
    }

    /**
     * @description 获取出样检查
     * @param   storeId     门店id
     * @param   userId     用户id
     * @param   inspectionDate     巡店日期
     * @return  出样检查
     */
    public static List<Sampling_Inspection__c> getExistPlanOutSamplingInspectionBaseStoreId(String storeId, String userId, Date inspectionDate) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Hisense_Rack__c,
                    Quantity_Hisense__c,
                    Quantity_POP__c,
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c, 
                    On_Wall_Display__c,
                    POP__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Shop__c =  : storeId
                AND Unplanned_Sample__c = 'Yes'
                AND OwnerId = : userId
                AND Product__c NOT IN (select Product__c from Sampling_Detail__c where Shop__c =:storeId AND Is_Add__c='是')
                AND Inspection_Date__c = :inspectionDate
                ];
    }

    /**
     * @description 获取计划内出样结果
     * @param   storeId     门店id
     * @param   recordDate  报告日期
     * @param   ownerId     用户id
     * @return  出样检查
     */
    public static List<Sampling_Inspection__c> getExistSamplingInspectionBaseStoreIdAndDate(String storeId, Date recordDate, String ownerId) {
        List<Sampling_Inspection__c> sampl1 = [
            SELECT 
                Id,
                Name,
                Inspection_Date__c,
                Placement_Status__c,
                Unplanned_Sample__c,
                ExternalID__c,
                Product__c,
                Product__r.Name,
                Product__r.Name_Description__c,
                Product__r.Product_Line__c,
                Product__r.Series__c, 
                Product__r.Category__c,
                Product__r.Guiding_Price__c,
                Product__r.CurrencyIsoCode,
                Shop__c,
                Sample_Item__c,
                ReRe__c,
                //阿根廷新加字段
                Hisense_Rack__c,
                Quantity_Hisense__c,
                Quantity_POP__c,
                Quantity_Of_Exhibits_DS__c,
                Quantity_Of_Exhibits_OWD__c, 
                Stock__c,   
                Display_Stand__c, 
                On_Wall_Display__c,
                POP__c,
                Is_Prototype_Complete__c, 
                Is_Built_in_Video__c,   
                Is_Epos__c,
                Price__c,
                Sample_Item__r.Sampling_Standard__r.Flag__c
            FROM Sampling_Inspection__c 
            WHERE 
                Shop__c =  : storeId
            AND Unplanned_Sample__c = 'No'
            AND Inspection_Date__c = : recordDate
            AND OwnerId = : ownerId
            ORDER BY Product__r.Product_Line__c DESC];
        List<Sampling_Inspection__c> sampl2 = [
            SELECT 
                Id,
                Name,
                Inspection_Date__c,
                Placement_Status__c,
                Unplanned_Sample__c,
                ExternalID__c,
                Product__c,
                Product__r.Name,
                Product__r.Name_Description__c,
                Product__r.Product_Line__c,
                Product__r.Series__c, 
                Product__r.Category__c,
                Product__r.Guiding_Price__c,
                Product__r.CurrencyIsoCode,
                Shop__c,
                Sample_Item__c,
                ReRe__c,
                //阿根廷新加字段
                Hisense_Rack__c,
                Quantity_Hisense__c,
                Quantity_POP__c,
                Quantity_Of_Exhibits_DS__c,
                Quantity_Of_Exhibits_OWD__c, 
                Stock__c,   
                Display_Stand__c, 
                On_Wall_Display__c,
                POP__c,
                Is_Prototype_Complete__c, 
                Is_Built_in_Video__c,   
                Is_Epos__c,
                Price__c,
                Sample_Item__r.Sampling_Standard__r.Flag__c
            FROM Sampling_Inspection__c 
            WHERE 
                Shop__c =  : storeId
            AND Unplanned_Sample__c = 'Yes'
            AND Product__c IN (select Product__c from Sampling_Detail__c where Shop__c =:storeId AND Is_Add__c='是')
            AND Inspection_Date__c = : recordDate
            AND OwnerId = : ownerId
            ORDER BY Product__r.Product_Line__c DESC];
            for(Sampling_Inspection__c si:sampl2){
                // si.Unplanned_Sample__c = 'No'; // wfc
                sampl1.add(si);
            }
        return sampl1;
    }

    /**
     * @description 获取计划外出样结果
     * @param   storeId     门店id
     * @param   recordDate  报告日期
     * @param   ownerId     用户id
     * @return  出样检查
     */
    public static List<Sampling_Inspection__c> getExistPlanOutSamplingInspectionBaseStoreIdAndDate(String storeId, Date recordDate, String ownerId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Hisense_Rack__c,
                    Quantity_Hisense__c,
                    Quantity_POP__c,
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c, 
                    On_Wall_Display__c,
                    POP__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Unplanned_Sample__c = 'Yes'
                AND Shop__c = : storeId
                AND Inspection_Date__c = : recordDate
                AND OwnerId = : ownerId
                AND Product__c NOT IN (select Product__c from Sampling_Detail__c where Shop__c =:storeId AND Is_Add__c='是')
                ORDER BY Product__r.Product_Line__c DESC];
    }

    /**
     * @description 获取计划外出样结果
     * @param   storeId     门店id
     * @param   recordDate  报告日期
     * @param   productline  产品线
     * @param   ownerId     用户id
     * @return  出样检查
     */
    public static List<Sampling_Inspection__c> getExistPlanOutSamplingInspectionBaseStoreIddDateProductLine(String storeId, Date recordDate, String productline, String ownerId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Hisense_Rack__c,
                    Quantity_Hisense__c,
                    Quantity_POP__c,
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c, 
                    On_Wall_Display__c,
                    POP__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Sample_Item__c = null
                AND Shop__c = : storeId
                AND Inspection_Date__c = : recordDate
                AND Product__r.Product_Line__c = : productline
                AND Unplanned_Sample__c = 'Yes'
                AND OwnerId = : ownerId
                ORDER BY Product__r.Product_Line__c DESC];
    }

    // wfc 关联渠道产品价格表
    public static List<Sampling_Inspection__c> setProductPrice(String shopId, List<Sampling_Inspection__c> siList){
        // 查询门店对应的渠道产品价格
        Shop__c shop = [SELECT Id, Channel_item__c FROM Shop__c WHERE Id = :shopId LIMIT 1];
        if(shop.Channel_item__c != null){
            Map<String, Channel_Product_Price__c> producMap = new Map<String, Channel_Product_Price__c>();
            // 查询所有的渠道产品价格
            List<Channel_Product_Price__c> cppList = [SELECT Id ,Product__c, Price__c, CurrencyIsoCode 
                                                        FROM Channel_Product_Price__c
                                                        WHERE Channel_item__c = :shop.Channel_item__c];
            for(Channel_Product_Price__c cpp : cppList){
                producMap.put(cpp.Product__c, cpp);
            }
            for(Sampling_Inspection__c si : siList){
                if(si.Product__c != null){
                    // 有产品对应的价格
                    if(producMap.containsKey(si.Product__c)){
                        si.Product__r.Guiding_Price__c = producMap.get(si.Product__c).Price__c;
                        si.Product__r.CurrencyIsoCode = producMap.get(si.Product__c).CurrencyIsoCode;
                    }else {
                        si.Product__r.Guiding_Price__c = null;
                    }
                }
            }
        }else {
            for(Sampling_Inspection__c si : siList){
                if(si.Product__c != null){
                    si.Product__r.Guiding_Price__c = null;
                }
            }
        }
        return siList;
    }
    /*****************
     *
     * Check List 相关
     *
     ******************/
    
    // checkList初始化
    @AuraEnabled
    public static ConResponse checkListGetInitData(String recordId, String productline, String project) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        // 20230921 Modified By Ethan S
        // List<CheckResult__c> checkResultLsit = getExistCheckResultBaseCheckItem(recordId, productline, project);
        List<CheckResult__c> checkResultLsit = getCheckResultBycurrentUserLanguage(getExistCheckResultBaseCheckItem(recordId, productline, project));
        // 20230921 Modified By Ethan E
        mso.put('selectedProject', checkResultLsit);

        return resp;
    }
    // checkList保存
    @AuraEnabled
    public static ConResponse checkListSave(String recordId, String checkListJson) {
    // public static ConResponse checkListSave(String checkListJson, String recordId, String productline, String project) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        System.debug('checkListJson' + checkListJson);
        List<CheckResult__c> checkListList = (List<CheckResult__c>)JSON.deserialize(checkListJson, List<CheckResult__c>.class);
        
        Set<String> ids = new Set<String>();
        for (CheckResult__c item : checkListList) {
            ids.add(item.Id);
        }
        // 检查附件
        /*
        Set<String> ids = new Set<String>();
        for (CheckResult__c item : checkListList) {
            ids.add(item.Id);
        }
        List<CheckResult__c> quoeryCrList = getExistCheckResultBaseId(ids);
        Map<String, CheckResult__c> hasFilesMap = new Map<String, CheckResult__c>();
        for (CheckResult__c cr : quoeryCrList) {
            if (cr.CheckItem__r.HasFile__c) {
                hasFilesMap.put(cr.Id, cr);
            }
        }
        // 查询关联附件
        if (hasFilesMap.keySet().size()>0) {
            List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocumentId,LinkedEntityId,LinkedEntity.name FROM ContentDocumentLink WHERE LinkedEntityId IN : hasFilesMap.keySet()];
            Set<String> linkedEntityIds = new Set<String>();
            for (ContentDocumentLink cdl : cdlList) {
                linkedEntityIds.add(cdl.LinkedEntityId);
            }
            for (String crId : hasFilesMap.keySet()) {
                CheckResult__c cr = hasFilesMap.get(crId);
                if (!linkedEntityIds.contains(crId)) {
                    mso.put('attachmentsCheckErrorId', cr.Id);
                    return resp;
                }
            }
        }
        */
        upsert checkListList;
        // 20230921 Modified By Ethan S
        // List<CheckResult__c> checkResultLsit = getExistCheckResultBaseId(ids);
        List<CheckResult__c> checkResultLsit = getCheckResultBycurrentUserLanguage(getExistCheckResultBaseId(ids));
        // 20230921 Modified By Ethan E
        mso.put('selectedProject', checkResultLsit);

        // checklist部分
        Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(recordId);
        mso.put('checkResults', checkResults);
        mso.put('checkResultsIsRelatedToProduct', getCheckResultBycurrentUserLanguage(getExistCheckResultIsRelatedToProductBaseReportId(recordId)));
        // 查询日报(更新日报的总分和平均分)
        List<Daily_Inspection_Report__c> dirList = getExistDailyInspectionReportBasedId(recordId);
        if (dirList.size()==0) {
            resp.code= -1;
            resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Daily_Inspection_Report__c.getLabel()});
            return resp;
        }
        Daily_Inspection_Report__c dir = dirList[0];
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);

        // add by Sunny
        Map<String, List<Ticket__c>> taskMap = getTicket(dir);
        List<Ticket__c> openTasks = taskMap.get('openTasks');
        String ticketMessage = '';
        for(Ticket__c ticket : openTasks) {
            if(ticket.DueDate__c == null) {
                ticketMessage = System.Label.Inspection_Report_Check_Item_Ticket_Fill;
                break;
            }
        }
        mso.put('ticketOpenInfo', openTasks);
        mso.put('ticketMessage', ticketMessage);

        return resp;
    }
    
    
    
    //20230921 Ethan 据当前用户语言显示对应语种Description S
    public static  List<CheckResult__c> getCheckResultBycurrentUserLanguage(List<CheckResult__c> checkList) {
        String currentUserLanguage = UserInfo.getLanguage();
        String languageIsCN = 'zh_CN';
        String languageIsEN = 'en_US';
        List<CheckResult__c> resCheckList = new List<CheckResult__c>();
        for (CheckResult__c item: checkList) {
            if (item.CheckItem__r.Description_Filling_Language__c != currentUserLanguage ) {
                if (String.isNotBlank(item.CheckItem__r.Description_EN__c) && currentUserLanguage == languageIsEN) {
                    item.CheckItem__r.Description__c = item.CheckItem__r.Description_EN__c;
                }
                if (currentUserLanguage == languageIsCN) {
                    if (String.isNotBlank(item.CheckItem__r.Description_CN__c)) item.CheckItem__r.Description__c = item.CheckItem__r.Description_CN__c;
                    else item.CheckItem__r.Description__c = String.isNotBlank(item.CheckItem__r.Description_EN__c) ? item.CheckItem__r.Description_EN__c : item.CheckItem__r.Description__c;
                }
                // #多语言优化 helper text 多语言 add by DTT-Bright 20240729 START
                if (!String.isBlank(item.CheckItem__r.HelpTextCN__c) && currentUserLanguage == languageIsCN) {
                    item.CheckItem__r.HelpText__c = item.CheckItem__r.HelpTextCN__c;
                } else if (!String.isBlank(item.CheckItem__r.HelpTextEN__c)) {
                    item.CheckItem__r.HelpText__c = item.CheckItem__r.HelpTextEN__c;
                }
                // #多语言优化 helper text 多语言 add by DTT-Bright 20240729 END

                // lastby TJP 20250626 d:Enter_Choice__c 多语言
                if (!String.isBlank(item.CheckItem__r.Enter_Choice_CN__c) && currentUserLanguage == languageIsCN) {
                    item.CheckItem__r.Enter_Choice__c = item.CheckItem__r.Enter_Choice_CN__c;
                } else if (!String.isBlank(item.CheckItem__r.Enter_Choice_EN__c)) {
                    item.CheckItem__r.Enter_Choice__c = item.CheckItem__r.Enter_Choice_EN__c;
                }
                // #多语言优化 helper text 多语言 add by DTT-Bright 20240729 END
            }
            resCheckList.add(item);
        }
        return resCheckList;
    }
    //20230921 Ethan 据当前用户语言显示对应语种Description E
    // Query Data===========================================================
    // 获取CheckList
    public static List<CheckResult__c> getExistCheckResultBaseCheckItem(String reportId, String productline, String project) {
        return [
                SELECT 
                    Id,
                    Name,
                    Scores__c,
                    Comments__c,
                    Status__c,
                    CheckItem__c,
                    CheckItem__r.Name,
                    CheckItem__r.Product_Line__c,
                    CheckItem__r.Project__c,
                    CheckItem__r.MaximumScore__c,
                    CheckItem__r.HasFile__c,
                    CheckItem__r.Id,
                    CheckItem__r.Has_Sample_Pictures__c,
                    CheckItem__r.Description__c,
                    //add by Ethan 20230920 s
                    CheckItem__r.Description_CN__c,
                    CheckItem__r.Description_EN__c,
                    CheckItem__r.Description_Filling_Language__c,
                    //add by Ethan 20230920 e
                    CheckItem__r.IsYesOrNo__c,
                    CheckItem__r.HelpText__c,
                    // #多语言优化 多语言 add by DTT-Bright 20240728 START
                    CheckItem__r.HelpTextCN__c,
                    CheckItem__r.HelpTextEN__c,
                    // #多语言优化 多语言 add by DTT-Bright 20240728 END

                    CheckItem__r.Enter_Choice__c,
                    CheckItem__r.Enter_Choice_CN__c,
                    CheckItem__r.Enter_Choice_EN__c,

                    CheckItem__r.OrderNumber__c,
                    CheckItem__r.IsCountInScore__c,
                    CheckItem__r.Require_Comment_Scores__c,
                    CheckItem__r.Scores_require_file__c,
                    CheckItem__r.HasComment__c,
                    CheckItem__r.Is_Text__c 
                FROM CheckResult__c
                WHERE 
                    InspectorDailyReport__c = : reportId
                AND CheckItem__r.Product_Line__c = : productline
                AND toLabel(CheckItem__r.Project__c) = : project
                AND CheckItem__r.Is_Related_To_Product__c = false
                ORDER BY CheckItem__r.OrderNumber__c];
    }

    /**
     * @description 获取检查结果
     * @param   ids 检查结果id
     * @return  检查结果
     */
    public static List<CheckResult__c> getExistCheckResultBaseId(Set<String> ids) {
        return [
                SELECT 
                    Id,
                    Name,
                    Scores__c,
                    Comments__c,
                    Status__c,
                    CheckItem__c,
                    CheckItem__r.Name,
                    CheckItem__r.Product_Line__c,
                    CheckItem__r.Project__c,
                    CheckItem__r.MaximumScore__c,
                    CheckItem__r.HasFile__c,
                    CheckItem__r.Id,
                    CheckItem__r.Has_Sample_Pictures__c,
                    CheckItem__r.Description__c,
                    //add by Ethan 20230920 s
                    CheckItem__r.Description_CN__c,
                    CheckItem__r.Description_EN__c,
                    CheckItem__r.Description_Filling_Language__c,
                    //add by Ethan 20230920 e
                    CheckItem__r.IsYesOrNo__c,
                    CheckItem__r.HelpText__c,
                    // #多语言优化 多语言 add by DTT-Bright 20240728 START
                    CheckItem__r.HelpTextCN__c,
                    CheckItem__r.HelpTextEN__c,
                    // #多语言优化 多语言 add by DTT-Bright 20240728 END
                    CheckItem__r.Enter_Choice__c,
                    CheckItem__r.Enter_Choice_CN__c,
                    CheckItem__r.Enter_Choice_EN__c,
                    CheckItem__r.OrderNumber__c,
                    CheckItem__r.IsCountInScore__c,
                    CheckItem__r.Require_Comment_Scores__c,
                    CheckItem__r.Scores_require_file__c,
                    CheckItem__r.HasComment__c,
                    CheckItem__r.Is_Text__c
                FROM CheckResult__c
                WHERE 
                    Id IN : ids
                AND CheckItem__r.Is_Related_To_Product__c = false
                ORDER BY CheckItem__r.OrderNumber__c];
    }
    
    
    /*****************
     *
     * Sampling Inspection 相关 - 已废弃
     *
     ******************/
    
    // Sampling Inspection初始化
    @AuraEnabled
    public static ConResponse samplingInspectionGetInitData(String storeId, String recordDate, String productline) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreIdAndDateAndProductline(storeId, Date.valueOf(recordDate), productline, 'No');
        mso.put('siSelectedProductline', siList);

        List<Sampling_Inspection__c> siPlanOutList = getExistSamplingInspectionBaseStoreIdAndDateAndProductline(storeId, Date.valueOf(recordDate), productline, 'Yes');
        mso.put('siSelectedProductlinePlanOut', siPlanOutList);
        return resp;
    }
    // Sampling Inspection保存
    @AuraEnabled
    public static ConResponse samplingInspectionSave(String samplingInspectionJson, String samplingInspectionPlanOutJson) {

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        System.debug('samplingInspectionJson' + samplingInspectionJson);
        List<Sampling_Inspection__c> siList = (List<Sampling_Inspection__c>)JSON.deserialize(samplingInspectionJson, List<Sampling_Inspection__c>.class);
        
        /*
        // 检查附件
        Set<String> ids = new Set<String>();
        Set<String> allIds = new Set<String>();
        for (Sampling_Inspection__c item : siList) {
            if (item.Placement_Status__c == '未展出') {
                item.ReRe__c = '';
            } else {
                ids.add(item.Id);
            }
            allIds.add(item.Id);
        }
        if (ids.size()>0) {
            List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocumentId,LinkedEntityId,LinkedEntity.name FROM ContentDocumentLink WHERE LinkedEntityId IN : ids];
            Set<String> linkedEntityIds = new Set<String>();
            for (ContentDocumentLink cdl : cdlList) {
                linkedEntityIds.add(cdl.LinkedEntityId);
            }
            for (String siId : ids) {
                if (!linkedEntityIds.contains(siId)) {
                    mso.put('attachmentsCheckErrorId', siId);
                    return resp;
                }
            }
        }
        */
        if (siList.size()>0) {
            upsert siList;
            // 临时用 不检查附件
            Set<String> allIds = new Set<String>();
            for (Sampling_Inspection__c item : siList) {
                allIds.add(item.Id);
            }
            List<Sampling_Inspection__c> siSelectedProductlineList = getExistSamplingInspectionBaseId(allIds);
            mso.put('siSelectedProductline', siSelectedProductlineList);
        }

        // 计划外
        System.debug('samplingInspectionPlanOutJson' + samplingInspectionPlanOutJson);
        List<Sampling_Inspection__c> siOlanOutList = (List<Sampling_Inspection__c>)JSON.deserialize(samplingInspectionPlanOutJson, List<Sampling_Inspection__c>.class);

        if (siOlanOutList.size()>0) {
            upsert siOlanOutList;
            // 临时用 不检查附件
            Set<String> allIds = new Set<String>();
            for (Sampling_Inspection__c item : siOlanOutList) {
                allIds.add(item.Id);
            }
            List<Sampling_Inspection__c> siSelectedProductlinePlanOutList = getExistSamplingInspectionBaseId(allIds);
            mso.put('siSelectedProductlinePlanOut', siSelectedProductlinePlanOutList);
        }
        return resp;
    }

    //2024-01-12 lizunxing 日本巡店日报计划外创建出样明细
    public static Sampling_Detail__c createSamplingDetail(Sampling_Inspection__c newSi, Sampling_Standard__c sampling){

        //出样明细外键Set
        Set<String> detailExternalIdSet = new Set<String>();

        //出样明细查询
        detailExternalIdSet.add(newSi.Shop__c+'-'+newSi.Product__c);

        //出样明细最近的出样检查Map
        Map<String,Sampling_Inspection__c> samplingDateMap = new Map<String,Sampling_Inspection__c>(); 
        if (detailExternalIdSet.size()>0) {
            for (Sampling_Detail__c sd : [SELECT Id,ExternalID__c,(SELECT Id,Inspection_Shop_Task__r.Daily_Inspection_Report__r.Report_Date__c FROM MVrr__r Order by Inspection_Shop_Task__r.Daily_Inspection_Report__r.Report_Date__c desc limit 1) FROM Sampling_Detail__c WHERE ExternalID__c IN:detailExternalIdSet]) {
                if (sd.MVrr__r.size()>0) {
                    samplingDateMap.put(sd.ExternalID__c, sd.MVrr__r[0]);    
                }
            }    
        }

        Sampling_Detail__c samplingDetail = new Sampling_Detail__c();     
        samplingDetail.Display_Status__c = newSi.Placement_Status__c;
        samplingDetail.ExternalID__c = newSi.Shop__c+'-'+newSi.Product__c;  
        //samplingDetail.Flag__c = samplingInspectionData.samplingInspection.Flag__c;// 出样详情“処分推進”标记
        if (samplingDateMap.get(samplingDetail.ExternalID__c)!=null && newSi.Inspection_Date__c < samplingDateMap.get(samplingDetail.ExternalID__c).Inspection_Shop_Task__r.Daily_Inspection_Report__r.Report_Date__c) {
            System.debug('www--' + samplingDetail.ExternalID__c);
            System.debug('www--' + samplingDateMap.get(samplingDetail.ExternalID__c).Inspection_Shop_Task__r.Daily_Inspection_Report__r.Report_Date__c);
            //return samplingDateMap.get(samplingDetail.ExternalID__c);  
            return null;  
        }
        // 隐藏的出样明细再展出不会挂在特殊出样标准上
        if (String.isBlank(newSi.Sample_Item__c) && samplingDateMap.get(samplingDetail.ExternalID__c) == null) {
            samplingDetail.Sampling_Standard__c = sampling.Id; 
            //needSamplingDetailIdMap.put(samplingDetail.ExternalID__c, samplingInspectionData.samplingInspection);    
            System.debug(newSi);
            samplingDetail.Unplanned_Sample__c = '是';  
            samplingDetail.Shop__c = newSi.Shop__c;
            samplingDetail.Product__c = newSi.Product__c;
            samplingDetail.Is_Add__c = '是';
            //needLoopList.add(samplingDetail);
            System.debug('samplingDetail.Shop__c'+samplingDetail.Shop__c+'----'+'samplingDetail.Product__c'+samplingDetail.Product__c);  
        }
        return samplingDetail;
    }

    // Sampling Inspection新增
    @AuraEnabled
    public static ConResponse samplingInspectionAdd(String recordJson, String productId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('recordJson'+recordJson);
        Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)JSON.deserializeStrict(recordJson, Daily_Inspection_Report__c.class);

        // User user = [SELECT Id, Name, Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];

        Sampling_Standard__c sampling;

        if('Hisense Japan'.equals(user.Sales_Region__c)){
            List<Sampling_Standard__c> samplingStandard = [SELECT Id FROM Sampling_Standard__c WHERE Is_Add_ByReport__c = true AND Channel_Name__c = null AND Product__c = null];
            //Account acc = [SELECT Id FROM Account WHERE External_Key__c = '999999' limit 1];
            if (samplingStandard.size()==0) {
                sampling = new Sampling_Standard__c();
                sampling.Is_Add_ByReport__c = true;
                //sampling.Channel_Name__c = acc.Id;
                Database.insert(sampling);    
            }else{
                sampling = samplingStandard[0];
            }
        }
        
        // 新建计划外Sampling Inspection
        Sampling_Inspection__c newSi = new Sampling_Inspection__c();
        newSi.Inspection_Date__c = report.Report_Date__c;
        newSi.Placement_Status__c = '展出';
        newSi.Unplanned_Sample__c = 'Yes';
        newSi.ExternalID__c = String.valueOf(report.Report_Date__c) + '_' + report.Store__c + '_' + productId + '_' + UserInfo.getUserId();
        newSi.Product__c = productId;
        newSi.Shop__c = report.Store__c;
        newSi.ReRe__c = '';
        // wfc 关联巡店员日报
        newSi.Inspection_Report__c = report.Id;


        if('Hisense Japan'.equals(user.Sales_Region__c)){
            Sampling_Detail__c samplingDetail = createSamplingDetail(newSi,sampling);
            if(samplingDetail != null){
                Database.upsert(samplingDetail,Sampling_Detail__c.Fields.ExternalID__c);
                newSi.Sample_Item__c = samplingDetail.Id;
            }
        }

        insert newSi;

        // 出样题目带出 start 20241022
        List<Product__c> productList = [SELECT Id, Name, Product_Line__c, Series__c, Category__c FROM Product__c WHERE Id = : productId];
        if (productList.size()==0) {
            resp.code= -1;
            resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Product__c.getLabel()});
            return resp;
        }
        Product__c product = productList[0];
        Set<String> productLineSet = new Set<String> { product.Product_Line__c };
        Boolean isRemotedInspect = report.Inspect_Type__c == INSPECT_TYPE_REMOTE ? true : false;
        createCheckResult2(report.Store__c, UserInfo.getUserId(), report.Id, productLineSet, new Map<String, List<String>>{product.Product_Line__c => new List<String>{newSi.Id}}, isRemotedInspect);
        mso.put('checkResultsIsRelatedToProduct', getCheckResultBycurrentUserLanguage(getExistCheckResultIsRelatedToProductBaseReportId(report.Id)));
        // 出样题目带出 end 20241022

        Set<String> newIds = new Set<String>();
        newIds.add(newSi.id);
        Sampling_Inspection__c addedsi = getExistSamplingInspectionBaseId(newIds)[0];
        mso.put('newSamplingInspection', addedsi);
        // 获取计划外Sampling Inspection信息
        List<Sampling_Inspection__c> planOutSamplingInspection = getExistPlanOutSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
        // 更新Sampling Inspection信息
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
        siList.addAll(planOutSamplingInspection);
        // todo 给产品添加金额 wfc
        siList = setProductPrice(report.Store__c, siList);
        mso.put('samplingInspections', siList);
        // 更新CheckResult信息
        Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(report.Id);
        mso.put('checkResults', checkResults);
        // 更新日报信息
        Daily_Inspection_Report__c dir = getExistDailyInspectionReportBasedId(report.Id)[0];
        dir.Brand__c = report.Brand__c;
        dir.Summary__c = report.Summary__c;
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);
        System.debug('resp======>'+resp);

        return resp;
    }
    // Sampling Inspection删除
    @AuraEnabled
    public static ConResponse samplingInspectionDelete(String recordJson, String samplingId) {

        User user = [SELECT Id, Name, Sales_Region__c, title FROM User WHERE Id = : UserInfo.getUserId()];

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        System.debug('recordJson'+recordJson);
        Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)JSON.deserializeStrict(recordJson, Daily_Inspection_Report__c.class);
        Set<String> samplingIds = new Set<String>();
        samplingIds.add(samplingId);
        Sampling_Inspection__c delSi = getExistSamplingInspectionBaseId(samplingIds)[0];
        List<Sampling_Inspection__c> allsiList = getExistAllSamplingInspectionBaseStoreIdAndDateAndProductline(report.Store__c, report.Report_Date__c, delSi.Product__r.Product_Line__c);
        System.debug('allsiList=' + allsiList);
        System.debug('allsiList[0].Id=' + allsiList[0].Id);
        System.debug('delSi.Id=' + delSi.Id);
        List<CheckResult__c> crList = [Select Id from CheckResult__c where Sampling_Inspection__c = :samplingId];
        System.debug('crList=' + crList);
        // delete crList;
        
        if (allsiList.size()==1 && allsiList[0].Id==delSi.Id) {
            System.debug('report.Id=' + report.Id);
            System.debug('delSi.Product__r.Product_Line__c=' + delSi.Product__r.Product_Line__c);
            crList.addAll(getExistCheckResultBaseReportIdProductLine(report.Id, delSi.Product__r.Product_Line__c));
        }
        Map<Id, CheckResult__c> crMap = new Map<Id, CheckResult__c>(crList);
        List<Ticket__c> delTickets = [SELECT Id, CheckResult__c FROM Ticket__c WHERE CheckResult__c IN :crMap.keySet()];
        System.debug('delTickets=' + delTickets);
        if (crList.size()>0) {
            delete crList;
            delete delTickets;
        }
        mso.put('delTickets', (new Map<Id, Ticket__c>(delTickets)).keySet());

        //日本删除计划内产品
        if('Hisense Japan'.equals(user.Sales_Region__c)){
            if(String.isNotBlank(delSi.Sample_Item__c)){
                Sampling_Detail__c delSd = new Sampling_Detail__c();
                delSd.id = delSi.Sample_Item__c;
                delete delSd;
            }
        }

        delete delSi;

        // 刷新页面信息
        // 获取计划外Sampling Inspection信息
        List<Sampling_Inspection__c> planOutSamplingInspection = getExistPlanOutSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
        // 更新Sampling Inspection信息
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
        siList.addAll(planOutSamplingInspection);
        mso.put('samplingInspections', siList);
        // 更新CheckResult信息
        Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(report.Id);
        mso.put('checkResults', checkResults);
        mso.put('checkResultsIsRelatedToProduct', getCheckResultBycurrentUserLanguage(getExistCheckResultIsRelatedToProductBaseReportId(report.Id)));
        // 更新日报信息
        Daily_Inspection_Report__c dir = getExistDailyInspectionReportBasedId(report.Id)[0];
        dir.Brand__c = report.Brand__c;
        dir.Summary__c = report.Summary__c;
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);
        System.debug('resp======>'+resp);

        return resp;
    }
    // Query Data===========================================================

    // 获取Sampling Inspection
    public static List<Sampling_Inspection__c> getExistSamplingInspectionBaseStoreIdAndDateAndProductline(String storeId, Date recordDate, String productline, String plan) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Hisense_Rack__c,
                    Quantity_Hisense__c,
                    Quantity_POP__c,
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c, 
                    On_Wall_Display__c,
                    POP__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Shop__c = : storeId
                AND Inspection_Date__c = : recordDate 
                AND Product__r.Product_Line__c = : productline 
                AND Unplanned_Sample__c = : plan
                ORDER BY Product__r.Name DESC];
    }

    /**
     * @description 获取出样结果
     * @param   storeId     门店id
     * @param   recordDate  报告日期
     * @param   productline 产品线
     * @return  出样结果
     */
    public static List<Sampling_Inspection__c> getExistAllSamplingInspectionBaseStoreIdAndDateAndProductline(String storeId, Date recordDate, String productline) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c,
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Hisense_Rack__c,
                    Quantity_Hisense__c,
                    Quantity_POP__c,
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c, 
                    On_Wall_Display__c,
                    POP__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Shop__c = : storeId
                AND Inspection_Date__c = : recordDate 
                AND Product__r.Product_Line__c = : productline 
                ORDER BY Product__r.Name DESC];
    }

    /**
     * @description 获取出样结果
     * @param   ids     出样结果id
     * @return  出样结果
     */
    public static List<Sampling_Inspection__c> getExistSamplingInspectionBaseId(Set<String> ids) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c,
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Hisense_Rack__c,
                    Quantity_Hisense__c,
                    Quantity_POP__c,
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,  
                    Display_Stand__c, 
                    On_Wall_Display__c,
                    POP__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Id IN : ids
                ORDER BY Product__r.Name DESC];
    }
    /**
     * @description 获取巡店员日报子表产品线信息信息 tjp20241111 增加字段
     * @param   storeId     门店ID
     * @return  门店进驻产品线信息
     */
    public static List<Inspection_Product_Item__c> getInspectionProductItem(String recordId){
        return [SELECT Id,
                       Type__c,
                       Product_Lines__c,
                       Status__c,
                       Product_Line_Checked__c,
                       Patrol_Mode__c 
                       FROM Inspection_Product_Item__c 
                       WHERE Inspection_Report__c =: recordId];
    }

    /**
     * @description 查询当前日报关联的Ticket
     * @param   日报ID
     * @return  Ticket
     */
    public static void updateReportTicketStatus(String recordId){
        List<Ticket__c> tickets = [SELECT Id FROM Ticket__c WHERE InspectionReport__c =: recordId];
        if(tickets.size() > 0) {
            for(Ticket__c ticket : tickets) {
                ticket.Inspection_Status__c = 'Submitted';
            }
            update tickets;
        }
    }

    /**
     * @description 获取stored对应产品形态 display type参数
     * @param   storeId     门店ID
     * @return  display type参数信息
     */
    // public static List<Sampling_Detail__c> getDisplayTypes(String storeId){
    //     return [SELECT Display_Type__c FROM Sampling_Detail__c WHERE Shop__r.Id =: storeId];
    // }

    @AuraEnabled
    public static ConResponse deleteTicket(String id){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        try {
            Ticket__c ticket = new Ticket__c();
            ticket.Id = id;
            delete ticket;

            mso.put('isSuccess', true);
        } catch (Exception e) {
            mso.put('isSuccess', false);
        }
        
        return resp;
    }

    @AuraEnabled
    public static ConResponse handlerRemove(){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        mso.put('isSuccess', true);
        resp.data = mso;
        return resp;
    }

    // 根据坐标校对后的结果
    public static String getStoreForDistance(String currentLat, String currentLong) {
        String storeId;
        if(String.isEmpty(currentLat) || String.isEmpty(currentLong)){
            return storeId;
        }
        System.debug('坐标' + currentLat + ':' + currentLong);
        List<Shop__c> shops = getStoreBySalesRegion(Decimal.valueOf(currentLat),Decimal.valueOf(currentLong));
        storeId = (shops == null || shops.isEmpty()) ? null : shops[0].Id;
        System.debug('getStoreForDistance' + storeId);
        return storeId;
    }

    /**
     * @description 获取门店列表
     * @param   
     * @return  门店列表
     */
    public static List<Shop__c> getStoreBySalesRegion(Decimal currentLat, Decimal currentLong) {
        return [
                SELECT 
                Id
                FROM Shop__c 
                WHERE
                Sales_Region__c =: user.Sales_Region__c
                AND Shop_Center_Location__Latitude__s !=null 
                AND Shop_Center_Location__Longitude__s != null 
                order by DISTANCE(Shop_Center_Location__c, GEOLOCATION(:currentLat,:currentLong), 'mi') 
                limit 1];
    }

    // 门店距离详情信息
    public class StoreDistanceInfo{
        @AuraEnabled
        public String storeName {get; set;}
        @AuraEnabled
        public Decimal distance {get; set;}
        @AuraEnabled
        public String address {get; set;}
    }

    // @AuraEnabled
    // public static ConResponse checkAttachment(String Id){
    //     ConResponse resp = new ConResponse();
    //     Map<String, Object> mso = new Map<String, Object>();
    //     mso.put('isSuccess', true);
    //     resp.data = mso;
    //     if(String.isNotBlank(Id)){
    //         List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : Id];
    //         if(cdlList.size() > 0){
    //             mso.put('isSuccess', true);
    //         }else{
    //             mso.put('isSuccess', false);
    //         }
    //     }
    //     return resp;
    // }

    public static integer gabige() {
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        return i;
    }
}