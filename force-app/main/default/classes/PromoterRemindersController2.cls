public without sharing class PromoterRemindersController2 {
    private static String SOBJECT_NOT_FOUND = System.Label.INSPECTION_REPORT_MSG_SOBJECT_NOT_FOUND; //未找到{0}信息，请联系系统管理员
    private static String VIEW_LABEL = System.Label.Preview; //Preview
    private static String NEW_LABEL = System.Label.INSPECTION_REPORT_NEW; //New
   
    @AuraEnabled
    public static ConResponse getInitData(){

        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
		resp.data = mso; 
        
        // 日期信息
        Date today = Date.today();
        Date threeDaysBefore = today.addDays(-3);
        Date thirtyDaysBefore = today.addDays(-30);
        Integer thisYear = today.year();
        // 今天是周几
        Integer numberDaysDue = today.toStartofWeek().daysBetween(today); 

        // 当前用户信息
        String userId = UserInfo.getUserId(); 
        List<User> currentUser = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :userId ];
        String salesRegion = currentUser[0].Sales_Region__c;
        mso.put('salesRegion', salesRegion);

        // 负责门店
        List<Responsible_Person__c> resStoreList = [SELECT Id, Name, Principal__c, Shop_Name__c, Shop_Name__r.Account__c, Shop_Name__r.Name
                                                        FROM Responsible_Person__c 
                                                        WHERE RecordType__c = '促销员' AND Principal__c = :userId
                                                        ORDER BY Shop_Name__r.Name];
        if(resStoreList.size() == 0) {
            return resp;
        }

        // 签到签退信息
        Boolean needCheckIn = true;
        Boolean needCheckOut = true;
        List<Promoter_Attendance__c> attendanceList = [SELECT Id, Name, CheckInStatus__c, Shop__c, CheckIn_Date__c
                                                        FROM Promoter_Attendance__c 
                                                        WHERE OwnerId = :userId AND CheckIn_Date__c > :threeDaysBefore
                                                        ORDER BY CheckIn_Date__c DESC];
        // 三天内的签到签退门店信息
        Map<String, Promoter_Attendance__c> storeIdAndAttendanceMap = new Map<String, Promoter_Attendance__c>();
        for(Promoter_Attendance__c item : attendanceList) {
            storeIdAndAttendanceMap.put(item.Shop__c, item);
        }
        // 当天签到签退信息
        List<String> attendanceStatus = new LisqContainer(attendanceList).Where1('CheckIn_Date__c', '=', today).selectsField('CheckInStatus__c');
        if(attendanceStatus.contains('已签到') || attendanceStatus.contains('已签到签退')) {
            needCheckIn = false;
            if(attendanceStatus.contains('已签退') || attendanceStatus.contains('已签到签退')) {
                needCheckOut = false;
            }
        } else {
            needCheckOut = false;
        }
        mso.put('needCheckIn', needCheckIn);
        mso.put('needCheckOut', needCheckOut);

        // 日报信息
        List<Promoter_Daily_Report__c> reportList = [SELECT Id, Shop__c, Status__c, Report_Date__c 
                                                        FROM Promoter_Daily_Report__c 
                                                        WHERE OwnerId = :userId AND Report_Date__c > :threeDaysBefore
                                                        ORDER BY Name DESC];
        // 三天内的日报信息
        Map<String, List<Promoter_Daily_Report__c>> storeIdAndReportMap = new Map<String, List<Promoter_Daily_Report__c>>();
        for(Promoter_Daily_Report__c item : reportList) {
            if(storeIdAndReportMap.containsKey(item.Shop__c)) {
                storeIdAndReportMap.get(item.Shop__c).add(item);
            } else {
                storeIdAndReportMap.put(item.Shop__c, new List<Promoter_Daily_Report__c>{item});
            }
        }
        List<Map<String, Object>> reports = new List<Map<String, Object>>();
        for(Responsible_Person__c item : resStoreList) {
            if(storeIdAndReportMap.containsKey(item.Shop_Name__c)) {
                for(Promoter_Daily_Report__c reportItem : storeIdAndReportMap.get(item.Shop_Name__c)) {
                    Map<String, Object> reportStoreMap = new Map<String, Object>();
                    reportStoreMap.put('storeId', item.Shop_Name__c);
                    reportStoreMap.put('storeName', item.Shop_Name__r.Name);
                    Date reportDate = reportItem.Report_Date__c;
                    reportStoreMap.put('storeDate', reportDate);
                    reportStoreMap.put('storeDateFormat',String.valueof(reportDate).right(5));
                    reportStoreMap.put('status', VIEW_LABEL);
                    reports.add(reportStoreMap);
                }
            } else {
                if(storeIdAndAttendanceMap.containsKey(item.Shop_Name__c)) {
                    Map<String, Object> reportStoreMap = new Map<String, Object>();
                    reportStoreMap.put('storeId', item.Shop_Name__c);
                    reportStoreMap.put('storeName', item.Shop_Name__r.Name);
                    Date attendanceDate = storeIdAndAttendanceMap.get(item.Shop_Name__c).CheckIn_Date__c;
                    reportStoreMap.put('storeDate', attendanceDate);
                    reportStoreMap.put('storeDateFormat', String.valueof(attendanceDate).right(5));
                    reportStoreMap.put('status', NEW_LABEL);
                    reports.add(reportStoreMap);
                }
            }
        }
        mso.put('reports', reports);

        // 周报配置信息
        List<ReportConfigurationInformation__c> weeklyReportConfiguration = new List<ReportConfigurationInformation__c>();
        weeklyReportConfiguration = [SELECT Id, Name, RecordTypeId, RecordType.Name, Customer__c, FirstDayOfReminderWeeklyReport__c, FirstDayOfCreateWeeklyReport__c
                                        FROM ReportConfigurationInformation__c
                                        WHERE Active__c = true AND RecordType.Name LIKE '%Weekly Report%' AND SalesRegion__c = :salesRegion
                                        ORDER BY CreatedDate];
        if(weeklyReportConfiguration.size() != 0) {
            Map<String, ReportConfigurationInformation__c> customeIdAndConfigMap = new Map<String, ReportConfigurationInformation__c>();
            for(ReportConfigurationInformation__c item : weeklyReportConfiguration) {
                if(String.isBlank(item.Customer__c)) {
                    customeIdAndConfigMap.put('All', item);
                } else {
                    customeIdAndConfigMap.put(item.Customer__c, item);
                }
            }
            Map<String, ReportConfigurationInformation__c> storeIdAndConfigMap = new Map<String, ReportConfigurationInformation__c>();
            for(Responsible_Person__c item : resStoreList) {
                if(customeIdAndConfigMap.containsKey(item.Shop_Name__r.Account__c)) {
                    storeIdAndConfigMap.put(item.Shop_Name__c, customeIdAndConfigMap.get(item.Shop_Name__r.Account__c));
                } else {
                    storeIdAndConfigMap.put(item.Shop_Name__c, customeIdAndConfigMap.get('All'));
                }
            }

            // 周数信息
            List<String> configIdList = new LisqContainer(storeIdAndConfigMap.values()).selectsField('Id');
            List<ReportConfigurationItem__c> weeklyInfoList= [SELECT Id, Name, Year__c, ReportConfigurationInformation__c, Cyclical__c, StartDay__c, EndDate__c 
                                                                FROM ReportConfigurationItem__c  
                                                                WHERE ReportConfigurationInformation__c = :configIdList AND Year__c = :thisYear AND StartDay__c <= :today AND StartDay__c >= :thirtyDaysBefore
                                                                ORDER BY Cyclical__c DESC];
            Map<String, LisqContainer> weeklyItemGroupByConfig = new LisqContainer(weeklyInfoList).GroupByS('ReportConfigurationInformation__c');

            // 周报信息
            List<Market__c> weeklyReportList = [SELECT Id, Name, CreatedDate, Shop__c, Report_Date__c, ExternalId__c, Owner_text__c, Status__c, Weeks__c, CreatedById
                                                    FROM Market__c 
                                                    WHERE ownerId = :userId  AND StartDate__c >= :thirtyDaysBefore ];
            Map<String, Market__c> externalIdAndWeeklyMap = new Map<String, Market__c>();
            for(Market__c item : weeklyReportList) {
                externalIdAndWeeklyMap.put(item.ExternalId__c, item);
            }
            List<Map<String, Object>> weeklyReports = new List<Map<String, Object>>();
            for(Responsible_Person__c item : resStoreList) {
                if(storeIdAndConfigMap.containsKey(item.Shop_Name__c)) {
                    ReportConfigurationInformation__c storeConfig = storeIdAndConfigMap.get(item.Shop_Name__c);

                    Boolean setReminder = !String.isBlank(storeConfig.FirstDayOfReminderWeeklyReport__c);
                    Boolean isReminderDate = setReminder && (numberDaysDue >= Integer.valueOf(storeConfig.FirstDayOfReminderWeeklyReport__c));

                    Boolean setCreate = !String.isBlank(storeConfig.FirstDayOfCreateWeeklyReport__c);
                    Boolean isCreateDate = setCreate && (numberDaysDue >= Integer.valueOf(storeConfig.FirstDayOfCreateWeeklyReport__c));

                    if(weeklyItemGroupByConfig.containsKey(storeConfig.Id)) {
                        List<ReportConfigurationItem__c> storeConfigItemList = (List<ReportConfigurationItem__c>)weeklyItemGroupByConfig.get(storeConfig.Id).ToSobjectList();
                        Integer weekCount = 0;
                        for(ReportConfigurationItem__c configItem : storeConfigItemList) {
                            String reportExternalId = item.Shop_Name__c + '_' + userId + '_' + thisYear + '-' + configItem.Cyclical__c;
                            Map<String, Object> weeklyReportStoreMap = new Map<String, Object>();
                            weeklyReportStoreMap.put('storeId', item.Shop_Name__c);
                            weeklyReportStoreMap.put('storeName', item.Shop_Name__r.Name);
                            weeklyReportStoreMap.put('storeWeek', thisYear + '-' + configItem.Cyclical__c);
                            weeklyReportStoreMap.put('storeDate', configItem.StartDay__c);
                            weeklyReportStoreMap.put('storeDateFormat', String.valueof(configItem.StartDay__c).right(5));
                            if(externalIdAndWeeklyMap.containsKey(reportExternalId)) {
                                weeklyReportStoreMap.put('status', VIEW_LABEL);
                            } else {
                                weeklyReportStoreMap.put('status', NEW_LABEL);
                            }

                            if((configItem.StartDay__c <= today && configItem.EndDate__c >= today)) {
                                if(!(setReminder || setCreate) || isReminderDate || (!setReminder && isCreateDate)) {
                                    weeklyReports.add(weeklyReportStoreMap);
                                }
                            } else {
                                weeklyReports.add(weeklyReportStoreMap);
                            }
                            weekCount += 1;
                            if(weekCount == 4) {
                                break;
                            }
                        }

                    }
                }
            }
            mso.put('weeklyReports', weeklyReports);
        }

        // 月报配置信息
        List<ReportConfigurationInformation__c> monthlyReportConfiguration = new List<ReportConfigurationInformation__c>();
        monthlyReportConfiguration = [SELECT Id, Name, RecordTypeId, RecordType.Name, Customer__c, 	FirstDayOfCreateMonthlyReport__c, FirstDayOfReminderMonthlyReport__c 
                                        FROM ReportConfigurationInformation__c
                                        WHERE Active__c = true AND RecordType.Name Like '%Monthly Report%' AND SalesRegion__c = :salesRegion
                                        ORDER BY CreatedDate];
        if(weeklyReportConfiguration.size() != 0) {
            Map<String, ReportConfigurationInformation__c>  customerIdAndMonthConfigMap = new Map<String, ReportConfigurationInformation__c>();
            for(ReportConfigurationInformation__c item : monthlyReportConfiguration) {
                if(String.isBlank(item.Customer__c)) {
                    customerIdAndMonthConfigMap.put('All', item);
                } else {
                    customerIdAndMonthConfigMap.put(item.Customer__c, item);
                }
            }

            // 月报信息
            List<Research__c> monthlyReportList = [SELECT Id, Name, CreatedDate, Shop__c, Report_Date__c, ExternalId__c, Owner_text__c, Status__c, Months__c, CreatedById
                                                    FROM Research__c 
                                                    WHERE ownerId = :userId  AND StartDate__c >= :today.addDays(-66)];
            Map<String, Research__c> externalIdAndMonthlyMap = new Map<String, Research__c>();
            for(Research__c item : monthlyReportList) {
                externalIdAndMonthlyMap.put(item.ExternalId__c, item);
            }
            List<Map<String, Object>> monthlyReports = new List<Map<String, Object>>();
            for(Responsible_Person__c item : resStoreList) {
                ReportConfigurationInformation__c storeMonthConfig = new ReportConfigurationInformation__c();
                if(customerIdAndMonthConfigMap.containsKey(item.Shop_Name__r.Account__c)) {
                    storeMonthConfig = customerIdAndMonthConfigMap.get(item.Shop_Name__r.Account__c);
                } else {
                    storeMonthConfig = customerIdAndMonthConfigMap.get('All');
                }

                Boolean setMonthReminder = storeMonthConfig.FirstDayOfReminderMonthlyReport__c != 1;
                Boolean isMonthReminderDate = setMonthReminder && (today.day() >= storeMonthConfig.FirstDayOfReminderMonthlyReport__c);

                Boolean setMonthCreate = storeMonthConfig.FirstDayOfCreateMonthlyReport__c != 1;
                Boolean isMonthCreateDate = setMonthCreate && (today.day() >= storeMonthConfig.FirstDayOfCreateMonthlyReport__c);

                Integer monthCount = today.month();
                for(Integer index = monthCount; index >= monthCount - 1; index--) {
                    String monthrReportExternalId = item.Shop_Name__c + '_' + userId + '_' + thisYear + '-' + index;
                    Map<String, Object> monthlyReportStoreMap = new Map<String, Object>();
                    Date monthDate =  date.newinstance(thisYear, index, 1);
                    monthlyReportStoreMap.put('storeId', item.Shop_Name__c);
                    monthlyReportStoreMap.put('storeName', item.Shop_Name__r.Name);
                    monthlyReportStoreMap.put('storeMonth', thisYear + '-' + index);
                    monthlyReportStoreMap.put('storeDate', monthDate);
                    monthlyReportStoreMap.put('storeDateFormat', String.valueof(monthDate).right(5));
                    if(externalIdAndMonthlyMap.containsKey(monthrReportExternalId)) {
                        monthlyReportStoreMap.put('status', VIEW_LABEL);
                    } else {
                        monthlyReportStoreMap.put('status', NEW_LABEL);
                    }
                    
                    if(index == monthCount) {
                        if(!(setMonthReminder || isMonthCreateDate) || isMonthReminderDate || (!setMonthReminder && isMonthCreateDate)) {
                            monthlyReports.add(monthlyReportStoreMap);
                        }
                    } else {
                        monthlyReports.add(monthlyReportStoreMap);
                    }
                }
            }
            mso.put('monthlyReports', monthlyReports);
        }
        return resp;
    }
}