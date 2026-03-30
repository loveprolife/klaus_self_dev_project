public without sharing class WeeklyReportController {

    public static String userId = UserInfo.getUserId(); 
    
    @AuraEnabled
    public static Boolean isPhaseIIIUser(String recordId) {

        List<String> regionList = new List<String>{'Hisense Chile', 'Hisense Indonesia', 'Hisense South Africa'};
        try {
            SObjectType objectType = Id.valueOf(recordId).getSObjectType();
            Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
            
            if(describeResult.fields.getMap().containsKey('Sales_Region__c')) {
                String query = 'SELECT Sales_Region__c FROM ' + describeResult.getName() + ' WHERE Id = :recordId LIMIT 1';
                SObject record = Database.query(query);
                String recordRegion = String.valueOf(record.get('Sales_Region__c'));
                if(regionList.contains(recordRegion)) {
                    return true;
                } else if(String.isBlank(recordRegion)) {
                    User currentUser = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :userId LIMIT 1];
                    if(regionList.contains(currentUser.Sales_Region__c)) {
                        return true;
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e);
        }
        return false;
    }

    @AuraEnabled
    public static ConResponse getInitData(String recordId, String weekInfo, String storeId) {

        System.debug('WeeklyReportController ——> getInitData : ' );
        System.debug('getInitData ——> recordId : ' + recordId );
        System.debug('getInitData ——> weekInfo : ' + weekInfo );
        System.debug('getInitData ——> storeId : ' + storeId );
        
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 当前用户信息
        List<User> currentUser = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :userId ];

        // 周报信息
        Market__c weeklyReport = new Market__c();
        Boolean haveCreated = false;
        Boolean noCondition = false;
        String ExternalString = storeId + '_' + userId + '_' + weekInfo;
        String queryString = 'SELECT Id, Name, CreatedDate, Shop__c, Report_Date__c, ExternalId__c, Owner_text__c, Status__c, ';
        queryString += 'Weeks__c, CreatedById, DisplayUnits__c, ReportConfiguration__c, ReportConfigurationItem__c, OwnerId, StartDate__c, EndDate__c ';
        queryString += 'FROM Market__c ';
        if(!String.isBlank(recordId)) {
            queryString += 'WHERE Id = :recordId';
        } else if(!String.isBlank(weekInfo) && !String.isBlank(storeId)) {
            queryString += 'WHERE ExternalId__c = : ExternalString';
        } else {
            noCondition = true;
        }
        System.debug('weeklyReportList ------> queryString : ' + queryString);

        weeklyReport.Owner_text__c = currentUser[0].Name;
        weeklyReport.Shop__c = String.isBlank(storeId) ? null : storeId;
        weeklyReport.Weeks__c = String.isBlank(weekInfo) ? null : weekInfo;
        Boolean isTitleReadOnly = false;
        if(!noCondition) {
            List<Market__c> weeklyReportList = Database.query(queryString);
            if(weeklyReportList.size() != 0) {
                weeklyReport = weeklyReportList[0];
                haveCreated = true;
                // 创建过的报告, 他人查看使用报告创建人视角
                if(userId != weeklyReport.OwnerId) {
                    userId = weeklyReport.OwnerId;
                    isTitleReadOnly = true;
                }
                
                mso.put('displayUnitList',  getUnitMap(weeklyReport.DisplayUnits__c));
            }
        }
        mso.put('weeklyReport', weeklyReport);
        mso.put('reportFields', SObjectHelper.getFieldLabelMap('Market__c'));

        // 门店负责人相关信息  
        List<Map<String, String>> storeOptionList = new List<Map<String, String>>();
        List<Responsible_Person__c> resStoreList = [SELECT Id, Name, Principal__c, Shop_Name__c, Shop_Name__r.Account__c, Shop_Name__r.Name
                                                        FROM Responsible_Person__c 
                                                        WHERE (RecordType__c = '巡店员' OR RecordType__c = 'Backup Floorwalker' OR RecordType__c = '促销员') AND Principal__c = :userId
                                                        ORDER BY Shop_Name__r.Name];
        List<String> resStoreIdList = new LisqContainer(resStoreList).selectsField('Shop_Name__c');
        if(resStoreList.size() == 0) {
            System.debug('There are no stores associated with this user!');
            resp.message = 'There are no stores associated with this user!';
        	resp.code = -1;
            return resp;
        }

        // 不再负责的门店
        if(haveCreated && (!resStoreIdList.contains(weeklyReport.Shop__c))) {
            isTitleReadOnly = true;
            List<Shop__c> oldStore = [SELECT Id, Name FROM Shop__c WHERE Id = :weeklyReport.Shop__c];
            storeOptionList.add(new Map<String, String>{
                'label' => oldStore[0].Name,
                'value' => oldStore[0].Id
            });
        }

        if(isTitleReadOnly) {
            List<Map<String, String>> weeklsOptionList = new List<Map<String, String>>();
            if(!String.isBlank(weeklyReport.Weeks__c)) {
                String weeklsOptionValue = weeklyReport.Weeks__c;
                String weeklsOptionLabel = String.format(Label.Weekly_Report_Weeks, new List<Object>{weeklsOptionValue.split('-')[1] , weeklyReport.StartDate__c.format(), weeklyReport.EndDate__c.format()});
                
                weeklsOptionList.add(new Map<String, String>{
                    'label' => weeklsOptionLabel,
                    'value' => weeklsOptionValue
                });
            }
            mso.put('storeOptionList', storeOptionList);
            mso.put('isTitleReadOnly', isTitleReadOnly);
            mso.put('weeklsOptionList', weeklsOptionList);
            return resp;
        }

        // 默认门店
        if(!haveCreated && String.isBlank(storeId)) {
            weeklyReport.Shop__c = resStoreList[0].Shop_Name__c;
        }

        String customerIdOfCurrentStore = '';
        Map<String, String> storeIdAndCustomerIdMap = new Map<String, String>();
        for(Responsible_Person__c item : resStoreList) {
            if(!String.isBlank(item.Shop_Name__r.Account__c )) {
                if(item.Shop_Name__c == weeklyReport.Shop__c ){
                    customerIdOfCurrentStore = item.Shop_Name__r.Account__c;
                }
            }
            storeOptionList.add(new Map<String, String>{
                'label' => item.Shop_Name__r.Name,
                'value' => item.Shop_Name__c
            });
        }
        mso.put('storeOptionList', storeOptionList);

        // 获取周报配置信息
        ConResponse configInfoResp = getConfigInfo(customerIdOfCurrentStore, currentUser[0].Sales_Region__c);
        if(configInfoResp.code == -1) {
            resp.message = configInfoResp.message;
        	resp.code = -1;
            return resp;
        } else {
            Map<String, Object> configInfoRespData = (Map<String, Object>)configInfoResp.data;
            ReportConfigurationInformation__c matchConfig = (ReportConfigurationInformation__c)configInfoRespData.get('matchConfig');
            mso.put('matchConfig', matchConfig);
            if(!haveCreated) {
                mso.put('displayUnitList', (List<Map<String, String>>)configInfoRespData.get('displayUnitList'));
            }
            
            // 获取周数信息
            ConResponse configItemResp = getWeeklsOptionList(matchConfig.Id, weeklyReport.Shop__c);
            Map<String, Object> configItemRespData = (Map<String, Object>)configItemResp.data;
            Map<String, String> reprotInfoAndWeekItemIdMap = (Map<String, String>)configItemRespData.get('reprotInfoAndWeekItemIdMap');
            if(!reprotInfoAndWeekItemIdMap.containskey(weeklyReport.Weeks__c)) {
                weeklyReport.ReportConfigurationItem__c = reprotInfoAndWeekItemIdMap.get(weeklyReport.Weeks__c);
            }
            mso.put('weeklsOptionList', (List<Map<String, String>>)configItemRespData.get('weeklsOptionList'));
            mso.put('reprotInfoAndWeekItemIdMap', reprotInfoAndWeekItemIdMap);

            if(!haveCreated) {
                weeklyReport.ReportConfiguration__c = matchConfig.Id;
                weeklyReport.DisplayUnits__c = matchConfig.Units__c;

                weeklyReport.Weeks__c = String.isBlank(weekInfo) ? String.valueOf(configItemRespData.get('currentWeekInfo')) : weekInfo;
                if(reprotInfoAndWeekItemIdMap.containskey(weeklyReport.Weeks__c)) {
                    weeklyReport.ReportConfigurationItem__c = reprotInfoAndWeekItemIdMap.get(weeklyReport.Weeks__c);
                } else {
                    weeklyReport.Weeks__c = String.valueOf(configItemRespData.get('currentWeekInfo'));
                    if(reprotInfoAndWeekItemIdMap.containskey(weeklyReport.Weeks__c)) {
                        weeklyReport.ReportConfigurationItem__c = reprotInfoAndWeekItemIdMap.get(weeklyReport.Weeks__c);
                    }
                }

                // 获得门店日期信息后再次查找是否有周报记录
                ExternalString = weeklyReport.Shop__c + '_' + userId + '_' + weeklyReport.Weeks__c;
                List<Market__c> weeklyReportListAgain = [SELECT Id, Name, CreatedDate, Shop__c, Report_Date__c, ExternalId__c, Owner_text__c, Status__c, Weeks__c, CreatedById, DisplayUnits__c, ReportConfiguration__c, ReportConfigurationItem__c
                                                            FROM Market__c 
                                                            WHERE ExternalId__c = :ExternalString];
                if(weeklyReportListAgain.size()>0) {
                    mso.put('displayUnitList', getUnitMap(weeklyReportListAgain[0].DisplayUnits__c));
                    mso.put('weeklyReport', weeklyReportListAgain[0]);
                    haveCreated = true;
                }
            } 
            mso.put('haveCreated', haveCreated);
        }
        return resp;

    }

    // 创建周报报信息
    @AuraEnabled
    public static ConResponse createReport(String recordJson) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.Savepoint sp = Database.setSavepoint();
        try {
            Market__c report = (Market__c)JSON.deserializeStrict(recordJson, Market__c.class);

            // 判断是否可以创建
            if((!String.isBlank(report.ReportConfiguration__c)) && (!String.isBlank(report.ReportConfigurationItem__c))) {
                List<ReportConfigurationInformation__c> weeklyReportConfiguration = [SELECT Id, FirstDayOfCreateWeeklyReport__c FROM ReportConfigurationInformation__c WHERE Id =: report.ReportConfiguration__c];
                if((weeklyReportConfiguration.size() > 0) && (!String.isBlank(weeklyReportConfiguration[0].FirstDayOfCreateWeeklyReport__c))) {
                    List<ReportConfigurationItem__c> weeklyInfo= [SELECT Id, StartDay__c, EndDate__c FROM ReportConfigurationItem__c WHERE Id = :report.ReportConfigurationItem__c]; 
                    if(weeklyInfo.size() > 0) {
                        Date today = Date.today();
                        Date weekStart = today.toStartofWeek();
                        Integer numberDaysDue = weekStart.daysBetween(today); 
                        if((numberDaysDue < Integer.valueOf(weeklyReportConfiguration[0].FirstDayOfCreateWeeklyReport__c)) && (today > weeklyInfo[0].StartDay__c) && (today < weeklyInfo[0].EndDate__c)) {
                            resp.message = String.format(Label.WeelkyReport_NotTimeToCreate, new List<Object>{Label.Weekly_Report_Title});
        	                resp.code = -1;
                            return resp;
                        }
                    }
                    
                }
            } 

            report.Status__c = 'New';
            report.Report_Date__c = Date.today();
            upsert report;

            report = [SELECT Id, Name, CreatedDate, Shop__c, Report_Date__c, ExternalId__c, Owner_text__c, Status__c, Weeks__c, DisplayUnits__c, ReportConfiguration__c, ReportConfigurationItem__c
                        FROM Market__c 
                        WHERE Id = :report.Id];

            mso.put('displayUnitList', getUnitMap(report.DisplayUnits__c));
            mso.put('weeklyReport', report);
        }catch (Exception e) {
        	Database.rollback(sp);
        	resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        	resp.code = -1;
        }
        return resp;
    }


    // 刷新数据
    // @AuraEnabled
    // public static ConResponse refreshData(String weekInfo, String storeId, String ReportConfigurationId) {
       
    //     System.debug('WeeklyReportController ——> getInitData : ' );
    //     System.debug('getInitData ——> weekInfo : ' + weekInfo );
    //     System.debug('getInitData ——> storeId : ' + storeId );

    //     ConResponse resp = new ConResponse();
    //     Map<String, Object> mso = new Map<String, Object>();
    //     resp.data = mso;

    //     // 当前用户信息
    //     String userId = UserInfo.getUserId(); 
    //     List<User> currentUser = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :userId ];

    //     // String ExternalString = storeId + '_' + userId + '_' + weekInfo.split(';')[0];
    //     String ExternalString = storeId + '_' + userId + '_' + weekInfo;
        
    //     // 周报信息
    //     Market__c weeklyReport = new Market__c();
    //     Boolean haveCreated = false;
    //     if(!String.isBlank(weekInfo) && !String.isBlank(storeId)) {
    //         List<Market__c> weeklyReportList = [SELECT Id, Name, CreatedDate, Shop__c, Report_Date__c, ExternalId__c, Owner_text__c, Status__c, Weeks__c, CreatedById, DisplayUnits__c, ReportConfiguration__c, ReportConfigurationItem__c
    //                                                 FROM Market__c 
    //                                                 // WHERE Weeks__c = :weekInfo AND Shop__c = :storeId AND CreatedById = :userId];
    //                                                 WHERE ExternalId__c = :ExternalString];
                                                    
    //         if(weeklyReportList.size() > 0) {
    //             weeklyReport = weeklyReportList[0];
    //             haveCreated = true;
    //             mso.put('displayUnitList', getUnitMap(weeklyReportList[0].DisplayUnits__c));
    //         } else {
    //             weeklyReport.Weeks__c = weekInfo;
    //             weeklyReport.Shop__c = storeId;

    //             if(!String.isBlank(ReportConfigurationId)) {
    //                 List<ReportConfigurationInformation__c> weeklyReportConfiguration = new List<ReportConfigurationInformation__c>();
    //                 weeklyReportConfiguration = [SELECT Id, Units__c FROM ReportConfigurationInformation__c WHERE Id =: ReportConfigurationId];
    //                 mso.put('displayUnitList', getUnitMap(weeklyReportConfiguration[0].Units__c));
    //             } 
    //         }
    //         mso.put('haveCreated', haveCreated);
    //         mso.put('weeklyReport', weeklyReport);
    //     } else {
    //         System.debug('report information error');
    //         resp.message = 'report information error';
    //     	resp.code = -1;
    //         return resp;
    //     }
    //     return resp;
    // }



    @AuraEnabled
    public static ConResponse saveData(String recordJson) {

        System.debug('WeeklyReportController ——> saveData : ' );
        System.debug('recordJson : ' + recordJson);

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        System.Savepoint sp = Database.setSavepoint();
        try {
            Market__c report = (Market__c)JSON.deserializeStrict(recordJson, Market__c.class);     
            upsert report;
        }catch (Exception e) {
        	Database.rollback(sp);
        	resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        	resp.code = -1;
        }
        return resp;
    }

    // 获取周报配置信息
    public static ConResponse getConfigInfo(String customerId, String userRegion) {
        System.debug('getConfigInfo ------- : ' );
        System.debug('customerId : ' + customerId);
        System.debug('userRegion : ' + userRegion);

        ConResponse configInfoResp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        configInfoResp.data = mso;

        String configId = '';
        String commonConfigId = '';
        List<ReportConfigurationInformation__c> weeklyReportConfiguration = new List<ReportConfigurationInformation__c>();
        weeklyReportConfiguration = [SELECT Id, Name, RecordTypeId, RecordType.Name, Customer__c, SalesRegion__c, FirstDayOfWeeklyReport__c, FirstDayOfCreateWeeklyReport__c, 
                                            FirstDayOfReminderWeeklyReport__c, Active__c, Units__c 
                                        FROM ReportConfigurationInformation__c
                                        WHERE Active__c = true AND RecordType.Name LIKE '%Weekly Report%' AND SalesRegion__c = :userRegion
                                        ORDER BY CreatedDate];
        Map<Id, ReportConfigurationInformation__c> configObjMap = new Map<Id, ReportConfigurationInformation__c>(weeklyReportConfiguration);

        if((weeklyReportConfiguration.size() == 1) && String.isBlank(weeklyReportConfiguration[0].Customer__c)) {
            configId = weeklyReportConfiguration[0].Id;
        } else {
            for(ReportConfigurationInformation__c item : weeklyReportConfiguration) {
                if(String.isBlank(item.Customer__c)) {
                    commonConfigId = item.Id;
                } else {
                    if(!String.isBlank(customerId) && (item.Customer__c == customerId)) {
                        configId = item.Id;
                    }
                }
            }
        }
        if(string.isBlank(configId)) {
            if(string.isBlank(commonConfigId)) {
                System.debug('No information found on weekly configurations!');
                configInfoResp.message = 'No information found on weekly configurations!';
                configInfoResp.code = -1;
                return configInfoResp;
            } else {
                configId = commonConfigId;
            }
        }
        ReportConfigurationInformation__c matchConfig = configObjMap.get(configId);
        mso.put('matchConfig', matchConfig);
        mso.put('displayUnitList', getUnitMap(matchConfig.Units__c));
        return configInfoResp;
    }


    // 获取周数信息
    public static ConResponse getWeeklsOptionList(String configId, String storeId) {
        System.debug('getWeeklsOptionList ------- : ' );
        System.debug('configId : ' + configId);
        System.debug('storeId : ' + storeId);

        ConResponse configItemResp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        configItemResp.data = mso;

        // 周数信息
        Date today = Date.today();
        Integer thisYear = today.year();
        List<Map<String, String>> weeklsOptionList = new List<Map<String, String>>();
        List<ReportConfigurationItem__c> weeklyInfoList= [SELECT Id, Name, Year__c, ReportConfigurationInformation__c, Cyclical__c, StartDay__c, EndDate__c 
                                                            FROM ReportConfigurationItem__c  
                                                            WHERE ReportConfigurationInformation__c = :configId AND Year__c = :thisYear AND StartDay__c <= today 
                                                            ORDER BY Cyclical__c DESC];

        Map<String, Market__c> weeksAndCreatedMarketMap = new Map<String, Market__c>();                                         
        List<Market__c> createdWeeklyReportList = [SELECT Id, EndDate__c, StartDate__c, Weeks__c, ReportConfigurationItem__c
                                                        FROM Market__c 
                                                        WHERE Shop__c = :storeId AND OwnerId = :userId];
        for(Market__c item : createdWeeklyReportList) {
            weeksAndCreatedMarketMap.put(item.Weeks__c, item);
        }
        Map<String, String> reprotInfoAndWeekItemIdMap = new Map<String, String>();                                                  
        for(ReportConfigurationItem__c item : weeklyInfoList) {
            String weeklsOptionValue = item.Year__c + '-' + item.Cyclical__c;
            String weeklsOptionLabel = String.format(Label.Weekly_Report_Weeks, new List<Object>{item.Cyclical__c , item.StartDay__c.format(), item.EndDate__c.format()});
            String configItemId = item.Id;
            if(weeksAndCreatedMarketMap.containskey(weeklsOptionValue)) {
                weeklsOptionLabel = String.format(Label.Weekly_Report_Weeks, new List<Object>{ item.Cyclical__c, 
                                                    weeksAndCreatedMarketMap.get(weeklsOptionValue).StartDate__c.format(), 
                                                    weeksAndCreatedMarketMap.get(weeklsOptionValue).EndDate__c.format()});
                configItemId = weeksAndCreatedMarketMap.get(weeklsOptionValue).ReportConfigurationItem__c;
            } 
            weeklsOptionList.add(new Map<String, String>{
                'label' => weeklsOptionLabel,
                'value' => weeklsOptionValue
            });
            reprotInfoAndWeekItemIdMap.put(weeklsOptionValue, configItemId);
       } 

       mso.put('weeklsOptionList', weeklsOptionList);
       mso.put('currentWeekInfo', weeklsOptionList[0].get('value'));
       mso.put('reprotInfoAndWeekItemIdMap', reprotInfoAndWeekItemIdMap);
       return configItemResp;
    }

    public static List<Map<String, String>> getUnitMap(String displayUnits) {

        List<Map<String, String>> displayUnitList = new List<Map<String, String>>();

        List<Schema.PicklistEntry> unitsValues = ReportConfigurationInformation__c.Units__c.getDescribe().getPicklistValues();
        Map<String, String> unitNameMap = new Map<String, String>();
        for(Schema.PicklistEntry unit : unitsValues) {
            unitNameMap.put(unit.getValue(), unit.getLabel());
        }
        if(!String.isBlank(displayUnits)) {
            for(String unit : displayUnits.split(';')) {
                Map<String, String> unitInfo = new Map<String, String>();
                unitInfo.put('name', unit);
                unitInfo.put('loaderName', 'c/' + unit + 'Lwc');
                unitInfo.put('label', unitNameMap.get(unit));
                displayUnitList.add(unitInfo);
            }
        }
        return displayUnitList;
    }

    // public static Map<String, String> unitLabelMap = new Map<String, String>{
    //     'Store View' => System.label.PromoterDailyReport_STORE_VIEW,
    //     'Intelligence' => System.label.PromoterDailyReport_INTELLIGENCE,
    //     'Market Insight' => System.label.PromoterDailyReport_MARKET_INSGHT,
    //     'Promo Court' => System.label.PromoterDailyReport_PROMO_COURT,
    //     'In House Share' => System.label.PromoterDailyReport_IN_HOUSE_SHARE,
    //     'Shelf Share' => System.label.PromoterDailyReport_SHELF_SHARE,
    //     'Consumer Trait Research' => System.label.PromoterDailyReport_Consumer_Trait_Research,
    //     'Foot Count Inquiry' => System.label.PromoterDailyReport_Foot_Count_Inquiry
    // };

    // public static Map<String, String> loaderNameMap = new Map<String, String>{
    //     'Store View' => 'c/storeViewLwc',
    //     'Intelligence' => 'c/newIntelligenceLwc',
    //     'Market Insight' => 'c/marketInsightLwc',
    //     'Promo Court' => 'c/promoCourtLwc',
    //     'In House Share' => 'c/inHouseShareLwc',
    //     'Shelf Share' => 'c/shelfShareLwc',
    //     'Consumer Trait Research' => 'c/consumerTraitResearchLwc',
    //     'Foot Count Inquiry' => 'c/footCountInquiryLwc'
    // };

}