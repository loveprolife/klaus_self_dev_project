public without sharing class MonthlyReportController {

    public static String userId = UserInfo.getUserId(); 

    @AuraEnabled
    public static Boolean isPhaseIIIUser(String recordId) {
        return WeeklyReportController.isPhaseIIIUser(recordId);
    }


    @AuraEnabled
    public static ConResponse getInitData(String recordId, String monthInfo, String storeId) {

        System.debug('MonthlyReportController ——> getInitData : ' );
        System.debug('getInitData ——> recordId : ' + recordId );
        System.debug('getInitData ——> monthInfo : ' + monthInfo );
        System.debug('getInitData ——> storeId : ' + storeId );
        
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 当前用户信息
        List<User> currentUser = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :userId ];

        // 月报信息
        Research__c monthlyReport = new Research__c();
        Boolean haveCreated = false;
        Boolean noCondition = false;
        String ExternalString = storeId + '_' + userId + '_' + monthInfo;
        String queryString = 'SELECT Id, Name, CreatedDate, Shop__c, Report_Date__c, ExternalId__c, Owner_text__c, Status__c, ';
        queryString += 'Months__c, CreatedById, DisplayUnits__c, ReportConfiguration__c, ReportConfigurationItem__c, OwnerId, StartDate__c, EndDate__c ';
        queryString += 'FROM Research__c ';
        if(!String.isBlank(recordId)) {
            queryString += 'WHERE Id = :recordId';
        } else if(!String.isBlank(monthInfo) && !String.isBlank(storeId)) {
            queryString += 'WHERE ExternalId__c = : ExternalString';
        } else {
            noCondition = true;
        }
        System.debug('monthlyReportList ------> queryString : ' + queryString);

        monthlyReport.Owner_text__c = currentUser[0].Name;
        monthlyReport.Shop__c = String.isBlank(storeId) ? null : storeId;
        monthlyReport.Months__c = String.isBlank(monthInfo) ? null : monthInfo;
        Boolean isTitleReadOnly = false;
        if(!noCondition) {
            List<Research__c> monthlyReportList = Database.query(queryString);
            if(monthlyReportList.size() != 0) {
                monthlyReport = monthlyReportList[0];
                haveCreated = true;
                // 创建过的报告, 他人查看使用报告创建人视角
                if(userId != monthlyReport.OwnerId) {
                    userId = monthlyReport.OwnerId;
                    isTitleReadOnly = true;
                }
                mso.put('displayUnitList', getUnitMap(monthlyReport.DisplayUnits__c));
            }
        }
        mso.put('monthlyReport', monthlyReport);
        mso.put('reportFields', SObjectHelper.getFieldLabelMap('Research__c'));

        // 门店负责人相关信息  
        List<Map<String, String>> storeOptionList = new List<Map<String, String>>();
        List<Responsible_Person__c> resStoreList = [SELECT Id, Name, Principal__c, Shop_Name__c, Shop_Name__r.Account__c, Shop_Name__r.Name
                                                        FROM Responsible_Person__c 
                                                        WHERE RecordType__c = '促销员' AND Principal__c = :userId
                                                        ORDER BY Shop_Name__r.Name];
        List<String> resStoreIdList = new LisqContainer(resStoreList).selectsField('Shop_Name__c');
        if(resStoreList.size() == 0) {
            System.debug('There are no stores associated with this user!');
            resp.message = 'There are no stores associated with this user!';
        	resp.code = -1;
            return resp;
        }

        // 不再负责的门店
        if(haveCreated && (!resStoreIdList.contains(monthlyReport.Shop__c))) {
            isTitleReadOnly = true;
            List<Shop__c> oldStore = [SELECT Id, Name FROM Shop__c WHERE Id = :monthlyReport.Shop__c];
            storeOptionList.add(new Map<String, String>{
                'label' => oldStore[0].Name,
                'value' => oldStore[0].Id
            });
        }

        if(isTitleReadOnly) {
            List<Map<String, String>> monthlsOptionList = new List<Map<String, String>>();
            if(!String.isBlank(monthlyReport.Months__c)) {
                String monthlsOptionValue = monthlyReport.Months__c;
                String monthlsOptionLabel = String.format(Label.Monthly_Report_Months, new List<Object>{monthlsOptionValue.split('-')[1] , monthlyReport.StartDate__c.format(), monthlyReport.EndDate__c.format()});
                
                monthlsOptionList.add(new Map<String, String>{
                    'label' => monthlsOptionLabel,
                    'value' => monthlsOptionValue
                });
            }
            mso.put('storeOptionList', storeOptionList);
            mso.put('isTitleReadOnly', isTitleReadOnly);
            mso.put('monthlsOptionList', monthlsOptionList);
            return resp;
        }

        // 默认门店
        if(!haveCreated && String.isBlank(storeId)) {
            monthlyReport.Shop__c = resStoreList[0].Shop_Name__c;
        }

        String customerIdOfCurrentStore = '';
        Map<String, String> storeIdAndCustomerIdMap = new Map<String, String>();
        for(Responsible_Person__c item : resStoreList) {
            if(!String.isBlank(item.Shop_Name__r.Account__c )) {
                if(item.Shop_Name__c == monthlyReport.Shop__c ){
                    customerIdOfCurrentStore = item.Shop_Name__r.Account__c;
                }
            }
            storeOptionList.add(new Map<String, String>{
                'label' => item.Shop_Name__r.Name,
                'value' => item.Shop_Name__c
            });
        }
        mso.put('storeOptionList', storeOptionList);

        // 获取月报配置信息
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
            
            // 获取月数信息
            ConResponse configItemResp = getMonthlsOptionList(matchConfig.Id, monthlyReport.Shop__c);
            Map<String, Object> configItemRespData = (Map<String, Object>)configItemResp.data;
            Map<String, String> reprotInfoAndMonthItemIdMap = (Map<String, String>)configItemRespData.get('reprotInfoAndMonthItemIdMap');
            if(!reprotInfoAndMonthItemIdMap.containskey(monthlyReport.Months__c)) {
                monthlyReport.ReportConfigurationItem__c = reprotInfoAndMonthItemIdMap.get(monthlyReport.Months__c);
            }
            mso.put('monthlsOptionList', (List<Map<String, String>>)configItemRespData.get('monthlsOptionList'));
            mso.put('reprotInfoAndMonthItemIdMap', reprotInfoAndMonthItemIdMap);

            if(!haveCreated) {
                monthlyReport.ReportConfiguration__c = matchConfig.Id;
                monthlyReport.DisplayUnits__c = matchConfig.Units__c;

                monthlyReport.Months__c = String.isBlank(monthInfo) ? String.valueOf(configItemRespData.get('currentMonthInfo')) : monthInfo;
                if(reprotInfoAndMonthItemIdMap.containskey(monthlyReport.Months__c)) {
                    monthlyReport.ReportConfigurationItem__c = reprotInfoAndMonthItemIdMap.get(monthlyReport.Months__c);
                } else {
                    monthlyReport.Months__c = String.valueOf(configItemRespData.get('currentMonthInfo'));
                    if(reprotInfoAndMonthItemIdMap.containskey(monthlyReport.Months__c)) {
                        monthlyReport.ReportConfigurationItem__c = reprotInfoAndMonthItemIdMap.get(monthlyReport.Months__c);
                    }
                }

                // 获得门店日期信息后再次查找是否有月报记录
                ExternalString = monthlyReport.Shop__c + '_' + userId + '_' + monthlyReport.Months__c;
                List<Research__c> monthlyReportListAgain = [SELECT Id, Name, CreatedDate, Shop__c, Report_Date__c, ExternalId__c, Owner_text__c, Status__c, Months__c, CreatedById, DisplayUnits__c, ReportConfiguration__c, ReportConfigurationItem__c
                                                            FROM Research__c 
                                                            WHERE ExternalId__c = :ExternalString];
                if(monthlyReportListAgain.size()>0) {
                    mso.put('displayUnitList', getUnitMap(monthlyReportListAgain[0].DisplayUnits__c));
                    mso.put('monthlyReport', monthlyReportListAgain[0]);
                    haveCreated = true;
                }
            } 
            mso.put('haveCreated', haveCreated);
        }
        return resp;

    }

    // 创建月报报信息
    @AuraEnabled
    public static ConResponse createReport(String recordJson) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.Savepoint sp = Database.setSavepoint();
        try {
            Research__c report = (Research__c)JSON.deserializeStrict(recordJson, Research__c.class);
            
            // 判断是否可以创建
            if((!String.isBlank(report.ReportConfiguration__c)) && (!String.isBlank(report.ReportConfigurationItem__c))) {
                List<ReportConfigurationInformation__c> monthlyReportConfiguration = [SELECT Id, FirstDayOfCreateMonthlyReport__c FROM ReportConfigurationInformation__c WHERE Id =: report.ReportConfiguration__c];
                if((monthlyReportConfiguration.size() > 0) && (monthlyReportConfiguration[0].FirstDayOfCreateMonthlyReport__c != 1)) {
                    List<ReportConfigurationItem__c> monthlyInfo= [SELECT Id, StartDay__c, EndDate__c FROM ReportConfigurationItem__c WHERE Id = :report.ReportConfigurationItem__c]; 
                    if(monthlyInfo.size() > 0) {
                        Date today = Date.today();
                        if((today.day() < Integer.valueOf(monthlyReportConfiguration[0].FirstDayOfCreateMonthlyReport__c)) && (today > monthlyInfo[0].StartDay__c) && (today < monthlyInfo[0].EndDate__c)) {
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

            report = [SELECT Id, Name, CreatedDate, Shop__c, Report_Date__c, ExternalId__c, Owner_text__c, Status__c, Months__c, DisplayUnits__c, ReportConfiguration__c, ReportConfigurationItem__c
                        FROM Research__c 
                        WHERE Id = :report.Id];

            mso.put('displayUnitList', getUnitMap(report.DisplayUnits__c));
            mso.put('monthlyReport', report);
        }catch (Exception e) {
        	Database.rollback(sp);
        	resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        	resp.code = -1;
        }
        return resp;
    }


    // 刷新数据
    // @AuraEnabled
    // public static ConResponse refreshData(String monthInfo, String storeId) {
       
    //     System.debug('MonthlyReportController ——> getInitData : ' );
    //     System.debug('getInitData ——> monthInfo : ' + monthInfo );
    //     System.debug('getInitData ——> storeId : ' + storeId );

    //     ConResponse resp = new ConResponse();
    //     Map<String, Object> mso = new Map<String, Object>();
    //     resp.data = mso;

    //     // 当前用户信息
    //     String userId = UserInfo.getUserId(); 
    //     List<User> currentUser = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :userId ];

    //     // String ExternalString = storeId + '_' + userId + '_' + monthInfo.split(';')[0];
    //     String ExternalString = storeId + '_' + userId + '_' + monthInfo;
        
    //     // 月报信息
    //     Research__c monthlyReport = new Research__c();
    //     Boolean haveCreated = false;
    //     if(!String.isBlank(monthInfo) && !String.isBlank(storeId)) {
    //         List<Research__c> monthlyReportList = [SELECT Id, Name, CreatedDate, Shop__c, Report_Date__c, ExternalId__c, Owner_text__c, Status__c, Months__c, CreatedById, Units__c, ReportConfiguration__c, ReportConfigurationItem__c
    //                                                 FROM Research__c 
    //                                                 // WHERE Months__c = :monthInfo AND Shop__c = :storeId AND CreatedById = :userId];
    //                                                 WHERE ExternalId__c = :ExternalString];
                                                    
    //         if(monthlyReportList.size() > 0) {
    //             monthlyReport = monthlyReportList[0];
    //             haveCreated = true;
    //             mso.put('displayUnitList', getUnitMap(monthlyReportList[0].Units__c));
    //         } else {
    //             monthlyReport.Months__c = monthInfo;
    //             monthlyReport.Shop__c = storeId;
    //         }
    //         mso.put('haveCreated', haveCreated);
    //         mso.put('monthlyReport', monthlyReport);
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

        System.debug('MonthlyReportController ——> saveData : ' );
        System.debug('recordJson : ' + recordJson);

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        System.Savepoint sp = Database.setSavepoint();
        try {
            Research__c report = (Research__c)JSON.deserializeStrict(recordJson, Research__c.class);
            upsert report;
        }catch (Exception e) {
        	Database.rollback(sp);
        	resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        	resp.code = -1;
        }
        return resp;
    }

    // 获取月报配置信息
    public static ConResponse getConfigInfo(String customerId, String userRegion) {
        System.debug('getConfigInfo ------- : ' );
        System.debug('customerId : ' + customerId);
        System.debug('userRegion : ' + userRegion);

        ConResponse configInfoResp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        configInfoResp.data = mso;

        String configId = '';
        String commonConfigId = '';
        List<ReportConfigurationInformation__c> monthlyReportConfiguration = new List<ReportConfigurationInformation__c>();
        monthlyReportConfiguration = [SELECT Id, Name, RecordTypeId, RecordType.Name, Customer__c, SalesRegion__c, FirstDayOfCreateMonthlyReport__c, 
                                            FirstDayOfReminderMonthlyReport__c, Active__c, Units__c 
                                        FROM ReportConfigurationInformation__c
                                        WHERE Active__c = true AND RecordType.Name Like '%Monthly Report%' AND SalesRegion__c = :userRegion
                                        ORDER BY CreatedDate];
        Map<Id, ReportConfigurationInformation__c> configObjMap = new Map<Id, ReportConfigurationInformation__c>(monthlyReportConfiguration);

        if((monthlyReportConfiguration.size() == 1) && String.isBlank(monthlyReportConfiguration[0].Customer__c)) {
            configId = monthlyReportConfiguration[0].Id;
        } else {
            for(ReportConfigurationInformation__c item : monthlyReportConfiguration) {
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
                System.debug('No information found on monthly configurations!');
                configInfoResp.message = 'No information found on monthly configurations!';
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


    // 获取月数信息
    public static ConResponse getMonthlsOptionList(String configId, String storeId) {
        System.debug('getMonthlsOptionList ------- : ' );
        System.debug('configId : ' + configId);
        System.debug('storeId : ' + storeId);

        ConResponse configItemResp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        configItemResp.data = mso;

        // 月数信息
        Date today = Date.today();
        Integer thisYear = today.year();
        List<Map<String, String>> monthlsOptionList = new List<Map<String, String>>();
        List<ReportConfigurationItem__c> monthlyInfoList= [SELECT Id, Name, Year__c, ReportConfigurationInformation__c, Cyclical__c, StartDay__c, EndDate__c 
                                                            FROM ReportConfigurationItem__c  
                                                            WHERE ReportConfigurationInformation__c = :configId AND Year__c = :thisYear AND StartDay__c <= today 
                                                            ORDER BY Cyclical__c DESC];

        Map<String, String> reprotInfoAndMonthItemIdMap = new Map<String, String>();                                                  
        for(ReportConfigurationItem__c item : monthlyInfoList) {
            String monthlsOptionLabel = String.format(Label.Monthly_Report_Months, new List<Object>{item.Cyclical__c , item.StartDay__c.format(), item.EndDate__c.format()});
            String monthlsOptionValue = item.Year__c + '-' + item.Cyclical__c;
            monthlsOptionList.add(new Map<String, String>{
                'label' => monthlsOptionLabel,
                'value' => monthlsOptionValue
            });
            reprotInfoAndMonthItemIdMap.put(monthlsOptionValue, item.Id);
       } 

       mso.put('monthlsOptionList', monthlsOptionList);
       mso.put('currentMonthInfo', monthlsOptionList[0].get('value'));
       mso.put('reprotInfoAndMonthItemIdMap', reprotInfoAndMonthItemIdMap);
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