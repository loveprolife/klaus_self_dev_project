public class WeeklyMonthlReportReminderBatch implements Database.Batchable<sObject> {

    public String salesRegion;
    public WeeklyMonthlReportReminderBatch(String salesRegion) {
        this.salesRegion = salesRegion;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String resType = '促销员';
        List<String> regionList = new List<String>{'Hisense Chile', 'Hisense Indonesia', 'Hisense South Africa'};
        System.debug('WeeklyMonthlReportReminderBatch ---> salesRegion : ' + salesRegion);
        String query = 'SELECT Id, Name, Principal__c, Shop_Name__c, Shop_Name__r.Account__c, Shop_Name__r.Name, Principal__r.Email, Shop_Name__r.Sales_Region__c, Principal__r.Sales_Region__c ';
        query += 'FROM Responsible_Person__c ';
        query += 'WHERE RecordType__c = :resType AND Shop_Name__r.Sales_Region__c = :salesRegion AND Principal__r.Sales_Region__c = :salesRegion AND Principal__r.IsActive = true ';
        query += 'ORDER BY Shop_Name__r.Name';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Responsible_Person__c> scope){
        try {
            System.debug('WeeklyMonthlReportReminderBatch ---> salesRegion : ' + salesRegion);

            Map<String, String> storeAndAccountMap = new Map<String, String>();
            Map<String, String> storeIdAndNameMap = new Map<String, String>();
            Map<String, List<String>> storeIdAndResPersonIdMap = new Map<String, List<String>>();
            Map<String, String> promoterIdAndEmailMap = new Map<String, String>();
            for(Responsible_Person__c item : scope) {
                storeAndAccountMap.put(item.Shop_Name__c, item.Shop_Name__r.Account__c + '-' + item.Shop_Name__r.Sales_Region__c);
                storeIdAndNameMap.put(item.Shop_Name__c, item.Shop_Name__r.Name);
                if(storeIdAndResPersonIdMap.containsKey(item.Shop_Name__c)) {
                    storeIdAndResPersonIdMap.get(item.Shop_Name__c).add(item.Principal__c);
                } else {
                    storeIdAndResPersonIdMap.put(item.Shop_Name__c, new List<String>{item.Principal__c});
                }

                if(!String.isBlank(item.Principal__r.Email)) {
                    promoterIdAndEmailMap.put(item.Principal__c, item.Principal__r.Email);
                }
            }
            ConResponse resp = findStoreAndConfigLink(storeAndAccountMap, salesRegion);
            Map<String, Object> respData = (Map<String, Object>)resp.data;
            Map<String, String> storeIdAndWeeksMap = (Map<String, String>)respData.get('storeIdAndWeeksMap');
            Map<String, String> storeIdAndMonthsMap = (Map<String, String>)respData.get('storeIdAndMonthsMap');

            // 门店下应创建的周报
            List<String> weeksList = new List<String>();
            Map<String, List<String>> storeIdAndWeeklyReportListMap = new Map<String, List<String>>();
            List<String> weeklyPromoterIdList = new List<String>();
            for(String key : storeIdAndWeeksMap.keySet()) {
                List<String> configInfoList = storeIdAndWeeksMap.get(key).split('_');
                weeksList.add(configInfoList[0]);
                if(storeIdAndResPersonIdMap.containsKey(key)) {
                    List<String> promoterIdList = storeIdAndResPersonIdMap.get(key);
                    for(String promoterId : promoterIdList) {
                        weeklyPromoterIdList.add(promoterId);
                        String reportExternal = key + '_' + promoterId + '_' + configInfoList[0];
                        if(storeIdAndWeeklyReportListMap.containsKey(key)) {
                            storeIdAndWeeklyReportListMap.get(key).add(reportExternal);
                        } else {
                            storeIdAndWeeklyReportListMap.put(key, new List<String>{reportExternal});
                        }
                    }
                }
            }

            // 门店下应创建的月报
            Map<String, List<String>> storeIdAndMonthlyReportListMap = new Map<String, List<String>>();
            List<String> monthlyPromoterIdList = new List<String>();
            for(String key : storeIdAndMonthsMap.keySet()) {
                if(storeIdAndResPersonIdMap.containsKey(key)) {
                    List<String> promoterIdList = storeIdAndResPersonIdMap.get(key);
                    for(String promoterId : promoterIdList) {
                        monthlyPromoterIdList.add(promoterId);
                        String reportExternal = key + '_' + promoterId + '_' + storeIdAndMonthsMap.get(key);
                        if(storeIdAndMonthlyReportListMap.containsKey(key)) {
                            storeIdAndMonthlyReportListMap.get(key).add(reportExternal);
                        } else {
                            storeIdAndMonthlyReportListMap.put(key, new List<String>{reportExternal});
                        }
                    }
                }
            }

            // 已创建的周报
            List<Market__c> weeklyReportList = [SELECT Id, Name, CreatedDate, Shop__c, Report_Date__c, ExternalId__c, Owner_text__c, Status__c, Weeks__c, CreatedById
                                                    FROM Market__c 
                                                    WHERE ownerId IN :weeklyPromoterIdList AND Weeks__c IN :weeklyPromoterIdList];
            Map<String, Market__c> externalIdAndWeeklyMap = new Map<String, Market__c>();
            for(Market__c item : weeklyReportList) {
                externalIdAndWeeklyMap.put(item.ExternalId__c, item);
            }
            // 需要提醒创建周报的促销员和门店信息
            Map<String, List<String>> reminderWeekly = new Map<String, List<String>>();
            Map<String, List<String>> reminderWeeklyEmail = new Map<String, List<String>>();
            for(String storeId : storeIdAndWeeklyReportListMap.keySet()) {
                List<String> reportExternalList = storeIdAndWeeklyReportListMap.get(storeId);
                for(String reportExternal : reportExternalList) {
                    if(!externalIdAndWeeklyMap.containsKey(reportExternal)) {
                        String promoterId = reportExternal.split('_')[1];
                        String storeName = storeIdAndNameMap.get(storeId);
                        if(reminderWeekly.containsKey(storeName + '-' + storeId)) {
                            reminderWeekly.get(storeName + '-' + storeId).add(promoterId);  
                        } else {
                            reminderWeekly.put(storeName + '-' + storeId, new List<String>{promoterId});  
                        }

                        if(promoterIdAndEmailMap.containsKey(promoterId)) {
                            if(reminderWeeklyEmail.containsKey(storeName + '-' + storeId)) {
                                reminderWeeklyEmail.get(storeName + '-' + storeId).add(promoterIdAndEmailMap.get(promoterId));  
                            } else {
                                reminderWeeklyEmail.put(storeName + '-' + storeId, new List<String>{promoterIdAndEmailMap.get(promoterId)});  
                            }
                        }
                    }
                }
            }
            sendNotification(Label.Weekly_Report_Title, 'weeklyReportLwc', reminderWeekly, reminderWeeklyEmail, storeIdAndWeeksMap);

            // 已创建的月报
            List<Research__c> monthlyReportList = [SELECT Id, Name, CreatedDate, Shop__c, Report_Date__c, ExternalId__c, Owner_text__c, Status__c, Months__c, CreatedById
                                                        FROM Research__c 
                                                        WHERE ownerId IN :monthlyPromoterIdList AND Months__c IN :storeIdAndMonthsMap.values()];
            Map<String, Research__c> externalIdAndMonthlyMap = new Map<String, Research__c>();
            for(Research__c item : monthlyReportList) {
                externalIdAndMonthlyMap.put(item.ExternalId__c, item);
            }
            // 需要提醒创建月报的促销员和门店信息
            Map<String, List<String>> reminderMonthly = new Map<String, List<String>>();
            Map<String, List<String>> reminderMonthlyEmail = new Map<String, List<String>>();
            for(String storeId : storeIdAndMonthlyReportListMap.keySet()) {
                List<String> reportExternalList = storeIdAndMonthlyReportListMap.get(storeId);
                for(String reportExternal : reportExternalList) {
                    if(!externalIdAndMonthlyMap.containsKey(reportExternal)) {
                       String promoterId = reportExternal.split('_')[1];
                       String storeName = storeIdAndNameMap.get(storeId);
                       if(reminderMonthly.containsKey(storeName + '-' + storeId)) {
                        reminderMonthly.get(storeName + '-' + storeId).add(promoterId);  
                       } else {
                          reminderMonthly.put(storeName + '-' + storeId, new List<String>{promoterId});  
                       }

                       if(promoterIdAndEmailMap.containsKey(promoterId)) {
                            if(reminderMonthlyEmail.containsKey(storeName + '-' + storeId)) {
                                reminderMonthlyEmail.get(storeName + '-' + storeId).add(promoterIdAndEmailMap.get(promoterId));  
                            } else {
                                reminderMonthlyEmail.put(storeName + '-' + storeId, new List<String>{promoterIdAndEmailMap.get(promoterId)});  
                            }
                        }
                    }
                }
            }
            sendNotification(Label.Monthly_Report_Title, 'monthlyReportLwc', reminderMonthly, reminderMonthlyEmail, new Map<String, String>());
        }
        catch (Exception e) {
            System.debug('WeeklyMonthlReportReminderBatch Error : '+ e.getMessage() + e.getLineNumber());
        } 
    }
    public void finish(Database.BatchableContext bc){
    }


    public static void sendNotification(String title, String lwcName, Map<String, List<String>> reminderInfo, Map<String, List<String>> reminderEmailInfo, Map<String, String> storeIdAndWeeksMap){

        String noticeTitle = String.format(Label.Weekly_Report_Creation_Reminder, new List<Object>{title});
        System.debug('sendNotification ---> noticeTitle : ' + noticeTitle);
        String targetPageRef = URL.getOrgDomainURL().toExternalForm() + '/lightning/cmp/c__lWCWrapper?c__lwcName=' + lwcName + '&c__shopId=';


        // 小铃铛通知
        for(String storeInfo : reminderInfo.keySet()) {
            System.debug('sendNotification ---> storeInfo : ' + storeInfo);
            System.debug('sendNotification ---> promoterInfo : ' + reminderInfo.get(storeInfo));

            List<String> storeInfoList = storeInfo.split('-');
            Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
            currNotification.setTitle(noticeTitle);
            String noticeBody = storeInfoList[0];
            // String targetRef = targetPageRef + storeInfoList[1];
            // "{"type": "standard__objectPage","attributes": {"objectApiName": "Task","actionName": "list"},"state":{"filterName":"Recent"}}"
            Map<String, Object> targetMap = new Map<String, Object>();
            targetMap.put('type', 'standard__component');
            targetMap.put('attributes', new Map<String, String>{'componentName' => 'c__LWCWrapper'});
            targetMap.put('state', new Map<String, Object>{'c__timestamp' => Datetime.now(), 'c__lwcName' => lwcName, 'c__shopId' => storeInfoList[1]});

            if(storeIdAndWeeksMap.containsKey(storeInfoList[1])) {
                List<String> configInfoList = storeIdAndWeeksMap.get(storeInfoList[1]).split('_');
                noticeBody += '\n' + String.format(Label.Weekly_Report_Weeks, new List<Object>{configInfoList[0].split('-')[1] , Date.valueOf(configInfoList[1]).format(), Date.valueOf(configInfoList[2]).format()});

                // targetRef += '&c__weekInfo=' + configInfoList[0];
                ((Map<String, Object>)targetMap.get('state')).put('c__weekInfo', configInfoList[0]);
            }
            String targetRef = Json.serialize(targetMap);
            System.debug('sendNotification ---> noticeBody : ' + noticeBody);
            System.debug('sendNotification ---> targetRef : ' + targetRef);

            currNotification.setBody(noticeBody);
            currNotification.setNotificationTypeId([SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Custom_Notification'].Id);
            // currNotification.setTargetId(record.Id);
            currNotification.setTargetPageRef(targetRef);
            try {
                currNotification.send(new Set<String>(reminderInfo.get(storeInfo)));
            } catch(Exception ex) {
                String msg = 'Notification Failed: ' + ex.getMessage();
                System.debug(msg);
            }
        }

        // 邮件通知
        for(String storeInfo : reminderEmailInfo.keySet()) {
            System.debug('sendNotification ---> email ---> storeInfo : ' + storeInfo);
            System.debug('sendNotification ---> email ---> promoterInfo : ' + reminderEmailInfo.get(storeInfo));

            List<String> storeInfoList = storeInfo.split('-');
            String targetStoreId = targetPageRef + storeInfoList[1];
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(reminderEmailInfo.get(storeInfo));
            mail.setSubject(noticeTitle);
            mail.setSenderDisplayName(title);
            String html = '';
            html = '<html>' +  '<head>' + '</head>' + '<body>' + '<div">';
            html += '<P>' + String.format(Label.Weekly_Report_Not_Created, new List<Object>{storeInfoList[0], title}) + '</p>';
            html += '<P>' + Label.Weekly_Report_Remider_More_Info + '<a href="' + targetStoreId + '"' + 'target="_blank">' + targetStoreId + '</a>' + '</p>' + '<br />';
            html += '<P>' + Label.Weekly_Report_Remider_Beat_Regards + '</p>';
            html += '</div>' + '</body>' + '</html>';
            mail.setHtmlBody(html);
            try {
                // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            } catch(Exception ex) {
                String msg = 'Email Notification Failed: ' + ex.getMessage();
                System.debug(msg);
            }
            
        }
    }

    public static ConResponse findStoreAndConfigLink(Map<String, String> storeAndAccountMap, String salesRegion) {
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
		resp.data = mso; 

        Map<String, String> storeIdAndWeeksMap = new Map<String, String>();
        Map<String, String> storeIdAndMonthsMap = new Map<String, String>();
        // 日期信息
        Date today = Date.today();
        // 今天是周几
        Integer numberDaysDue = today.toStartofWeek().daysBetween(today); 

        // 周报配置
        List<ReportConfigurationInformation__c> weeklyReportConfiguration = new List<ReportConfigurationInformation__c>();
        weeklyReportConfiguration = [SELECT Id, Name, RecordTypeId, RecordType.Name, Customer__c, FirstDayOfReminderWeeklyReport__c, FirstDayOfCreateWeeklyReport__c, SalesRegion__c
                                        FROM ReportConfigurationInformation__c
                                        WHERE Active__c = true AND RecordType.Name LIKE '%Weekly Report%' AND SalesRegion__c = :salesRegion
                                        ORDER BY CreatedDate];
        if(weeklyReportConfiguration.size() != 0) {
            Map<String, String> customeIdAndConfigMap = new Map<String, String>();
            for(ReportConfigurationInformation__c item : weeklyReportConfiguration) {
                Boolean setReminder = !String.isBlank(item.FirstDayOfReminderWeeklyReport__c);
                Boolean isReminderDate = setReminder && (numberDaysDue >= Integer.valueOf(item.FirstDayOfReminderWeeklyReport__c));
                Boolean setCreate = !String.isBlank(item.FirstDayOfCreateWeeklyReport__c);
                Boolean isCreateDate = setCreate && (numberDaysDue >= Integer.valueOf(item.FirstDayOfCreateWeeklyReport__c));

                if(!(setReminder || setCreate) || isReminderDate || (!setReminder && isCreateDate)) {
                    if(String.isBlank(item.Customer__c)) {
                        customeIdAndConfigMap.put(item.SalesRegion__c + '-All', item.Id);
                    } else {
                        customeIdAndConfigMap.put(item.Customer__c, item.Id);
                    }
                }
            }
           
            Map<String, String> storeIdAndWeeklyConfigIdMap = new Map<String, String>();
            for(String key : storeAndAccountMap.keySet()) {
                List<String> storeInfo = storeAndAccountMap.get(key).split('-');
                if(customeIdAndConfigMap.containsKey(storeInfo[0])) {
                    storeIdAndWeeklyConfigIdMap.put(key, customeIdAndConfigMap.get(storeInfo[0]));
                } else {
                    if(customeIdAndConfigMap.containsKey(storeInfo[1] + '-All')) {
                        storeIdAndWeeklyConfigIdMap.put(key, customeIdAndConfigMap.get(storeInfo[1] + '-All'));
                    }
                }
            }

            List<ReportConfigurationItem__c> weeklyInfoList= [SELECT Id, Name, Year__c, ReportConfigurationInformation__c, Cyclical__c, StartDay__c, EndDate__c 
                                                                FROM ReportConfigurationItem__c  
                                                                WHERE ReportConfigurationInformation__c = :storeIdAndWeeklyConfigIdMap.values() AND Year__c = :today.year() AND StartDay__c <= :today AND EndDate__c >= :today
                                                                ORDER BY Cyclical__c DESC];
            Map<String, LisqContainer> weeklyItemGroupByConfig = new LisqContainer(weeklyInfoList).GroupByS('ReportConfigurationInformation__c');
            for(String key : storeIdAndWeeklyConfigIdMap.keySet()) {
                String configId = storeIdAndWeeklyConfigIdMap.get(key);
                if(weeklyItemGroupByConfig.containsKey(configId)) {
                    ReportConfigurationItem__c storeWeeklyConfigItem = (ReportConfigurationItem__c)weeklyItemGroupByConfig.get(configId).ToSobjectList()[0];
                    storeIdAndWeeksMap.put(key, storeWeeklyConfigItem.Year__c + '-' + storeWeeklyConfigItem.Cyclical__c + '_' + storeWeeklyConfigItem.StartDay__c + '_' + storeWeeklyConfigItem.EndDate__c);
                }
            }
        }

        // 月报配置
        List<ReportConfigurationInformation__c> monthlyReportConfiguration = new List<ReportConfigurationInformation__c>();
        monthlyReportConfiguration = [SELECT Id, Name, RecordTypeId, RecordType.Name, Customer__c, 	FirstDayOfCreateMonthlyReport__c, FirstDayOfReminderMonthlyReport__c, SalesRegion__c
                                        FROM ReportConfigurationInformation__c
                                        WHERE Active__c = true AND RecordType.Name Like '%Monthly Report%' AND SalesRegion__c = :salesRegion
                                        ORDER BY CreatedDate];
         if(weeklyReportConfiguration.size() != 0) {
            Map<String, String>  customerIdAndMonthConfigMap = new Map<String, String>();
            for(ReportConfigurationInformation__c item : monthlyReportConfiguration) {
                Boolean setMonthReminder = item.FirstDayOfReminderMonthlyReport__c != 1;
                Boolean isMonthReminderDate = setMonthReminder && (today.day() >= item.FirstDayOfReminderMonthlyReport__c);
                Boolean setMonthCreate = item.FirstDayOfCreateMonthlyReport__c != 1;
                Boolean isMonthCreateDate = setMonthCreate && (today.day() >= item.FirstDayOfCreateMonthlyReport__c);
                if(!(setMonthReminder || setMonthCreate) || isMonthReminderDate || (!setMonthReminder && isMonthCreateDate)) {
                    if(String.isBlank(item.Customer__c)) {
                        customerIdAndMonthConfigMap.put(item.SalesRegion__c + '-All', item.Id);
                    } else {
                        customerIdAndMonthConfigMap.put(item.Customer__c, item.Id);
                    }
                }
            }

            for(String key : storeAndAccountMap.keySet()) {
                List<String> storeInfo = storeAndAccountMap.get(key).split('-');
                if(customerIdAndMonthConfigMap.containsKey(storeInfo[0])) {
                    storeIdAndMonthsMap.put(key, today.year() + '-' + today.month());
                } else {
                    if(customerIdAndMonthConfigMap.containsKey(storeInfo[1] + '-All')) {
                        storeIdAndMonthsMap.put(key, today.year() + '-' + today.month());
                    }
                }
            }
        }
        System.debug('findStoreAndConfigLink ---> storeIdAndWeeksMap : ' + storeIdAndWeeksMap);
        System.debug('findStoreAndConfigLink ---> storeIdAndMonthsMap : ' + storeIdAndMonthsMap);

        mso.put('storeIdAndWeeksMap', storeIdAndWeeksMap);
        mso.put('storeIdAndMonthsMap', storeIdAndMonthsMap);
        return resp;
    }
}