public class ReportConfigurationTriggerHandlerHelper {

    public static String chileMonthly = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('ChileMonthlyReport').getRecordTypeId();
    public static String chileWeekly  = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('ChileWeeklyReport').getRecordTypeId();
    public static String indonesiaMonthly = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('IndonesiaMonthlyReport').getRecordTypeId();
    public static String indonesiaWeekly  = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('IndonesiaWeeklyReport').getRecordTypeId();
    public static String southAfricaMonthly = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('SouthAfricaMonthlyReport').getRecordTypeId();
    public static String southAfricaWeekly  = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('SouthAfricaWeeklyReport').getRecordTypeId();
    public static String vietnamMonthly = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('VietnamMonthlyReport').getRecordTypeId();
    public static String vietnamWeekly  = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('VietnamWeeklyReport').getRecordTypeId();
    public static String philippinesMonthly = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('Philippines_Monthly_Report').getRecordTypeId();
    public static String philippinesWeekly  = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('Philippines_Weekly_Report').getRecordTypeId();
    public static String singaporeMonthly = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('Singapore_Monthly_Report').getRecordTypeId();
    public static String singaporeWeekly  = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('Singapore_Weekly_Report').getRecordTypeId();
    public static String peruMonthly = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('Peru_Monthly_Report').getRecordTypeId();
    public static String peruWeekly  = Schema.SObjectType.ReportConfigurationInformation__c.getRecordTypeInfosByDeveloperName().get('Peru_Weekly_Report').getRecordTypeId();
    
    public static List<String> monthlyReportTypeIdList = new List<String>{chileMonthly, indonesiaMonthly, southAfricaMonthly, vietnamMonthly, philippinesMonthly, singaporeMonthly, peruMonthly};
    public static List<String> weeklyReportTypeIdList = new List<String>{chileWeekly, indonesiaWeekly, southAfricaWeekly, vietnamWeekly, philippinesWeekly, singaporeWeekly, peruWeekly};
       
    public static Date today = Date.today();
    // 今天这周的开始日期，今天往前最近的一个周天
    public static Date weekStart = today.toStartofWeek();
    // 当前年份
    public static Integer thisYear = today.year();
    // 当前月
    public static Integer thisMonth= today.month();
    // 今天是周几
    public static Integer numberDaysDue = weekStart.daysBetween(today); 
    // 今年的1号
    public static Date firstdayOfThisYear =  date.newinstance(thisYear, 1, 1);
    // 今年1号往前最近的一个周日
    public static Date weekStartOfThisYear = firstdayOfThisYear.toStartofWeek();
    // 今年的1号是周几
    public static Integer numberDaysDueOfYearFirstDay = weekStartOfThisYear.daysBetween(firstdayOfThisYear);

    /**
     *@description 为周/月报配置创建相应的周/月数信息
     *@param	oldList	旧数据
     *@param	newList	新数据
     *@param	isBatch	是否Batch调用
	 *@param	year 创建年份
     * @return
    */
	public static void createItems(List<ReportConfigurationInformation__c> oldList, List<ReportConfigurationInformation__c> newList, Boolean isBatch, Integer year){

        System.debug('ReportConfigurationTriggerHandlerHelper ——> createItems -------- : ' );
        System.debug('ReportConfigurationTriggerHandlerHelper ——> isBatch : '  + isBatch);
        System.debug('ReportConfigurationTriggerHandlerHelper ——> year : '  + year);
        if(isBatch) {
            thisYear = year;
            // 指定年的一号
            firstdayOfThisYear = date.newinstance(thisYear, 1, 1);
            // 指定年1号往前最近的一个周日
            weekStartOfThisYear = firstdayOfThisYear.toStartofWeek();
            // 指定年的一号是周几
            numberDaysDueOfYearFirstDay = weekStartOfThisYear.daysBetween(firstdayOfThisYear);
        }

        List<ReportConfigurationItem__c> newReportConfigurationItemList = new List<ReportConfigurationItem__c>();

        for(ReportConfigurationInformation__c settingItem : newList) {
            if(settingItem.Active__c) {
                if(weeklyReportTypeIdList.contains(settingItem.RecordTypeId)) {
                    Date firstStartDay = firstdayOfThisYear;
                    Integer settingFirstDay = Integer.valueOf(settingItem.FirstDayOfWeeklyReport__c);
                    if(numberDaysDueOfYearFirstDay < settingFirstDay) {
                        firstStartDay = weekStartOfThisYear.addDays(settingFirstDay);
                        if(isBatch && (firstStartDay < firstdayOfThisYear)) {
                            firstStartDay.addDays(7);
                        }
                    } else if(numberDaysDueOfYearFirstDay > settingFirstDay) {
                        // 已过，找下一周
                        firstStartDay = weekStartOfThisYear.addDays(7 + settingFirstDay);
                    }

                    // 第一周的结束日期
                    Date firstEndDay = firstStartDay.addDays(6);
                    Date nextYear = Date.newInstance(thisYear + 1, 1, 1);

                    System.debug('settingFirstDay : ' + settingFirstDay);
                    System.debug('firstEndDay : ' + firstEndDay);

                    // if(firstEndDay > nextYear) {
                    //     System.debug('firstEndDay > nextYear : ');
                    //     ReportConfigurationItem__c item = new ReportConfigurationItem__c();
                    //     item.Year__c = thisYear;
                    //     item.Cyclical__c = 1;
                    //     item.StartDay__c = firstStartDay;
                    //     item.EndDate__c = firstEndDay;
                    //     item.ReportConfigurationInformation__c = settingItem.Id;
                    //     newReportConfigurationItemList.add(item);
                    // } else {
                    for(Integer index = 1; firstStartDay < nextYear; index++) {
                        ReportConfigurationItem__c item = new ReportConfigurationItem__c();
                        item.Year__c = thisYear;
                        item.Cyclical__c = index;
                        item.StartDay__c = firstStartDay;
                        item.EndDate__c = firstEndDay;
                        item.ReportConfigurationInformation__c = settingItem.Id;
                        newReportConfigurationItemList.add(item);
                        System.debug('weeklyReport ------->item : ' + item);
                        firstStartDay = firstStartDay.addDays(7);
                        firstEndDay = firstEndDay.addDays(7);
                    }
                } else if(monthlyReportTypeIdList.contains(settingItem.RecordTypeId)) {
                    for(Integer index = 1; index <= 12; index++) {
                        ReportConfigurationItem__c item = new ReportConfigurationItem__c();
                        item.Year__c = thisYear;
                        item.Cyclical__c = index;
                        item.StartDay__c = date.newinstance(thisYear, index, 1);
                        item.EndDate__c = date.newinstance(thisYear, index, date.daysInMonth(thisYear, index));
                        item.ReportConfigurationInformation__c = settingItem.Id;
                        newReportConfigurationItemList.add(item);
                        System.debug('monthlyReport -------> item : ' + item);
                    }
                }
            }
        }

        if(newReportConfigurationItemList.size() > 0) {
            System.debug('newReportConfigurationItemList.size() : ');
            insert newReportConfigurationItemList;
        }
    }

    /**
     *@description 为周/月报配置发生更改时修改相应的周/月数信息
     *@param	oldList	旧数据
     *@param	newList	新数据
     * @return
    */
    public static void modifyItems(List<ReportConfigurationInformation__c> oldList, List<ReportConfigurationInformation__c> newList){

        System.debug('ReportConfigurationTriggerHandlerHelper ——> modifyItems : ' );
        Map<Id, ReportConfigurationInformation__c> oldMap = new Map<Id, ReportConfigurationInformation__c>(oldList);

        System.debug('oldMap.keySet() : ' + oldMap.keySet());
        System.debug('thisYear : ' + thisYear);
        List<ReportConfigurationItem__c> relatedReportConfigurationItemList = [SELECT Name, Id, Year__c, ReportConfigurationInformation__c, Cyclical__c, StartDay__c, EndDate__c 
                                                                                FROM ReportConfigurationItem__c 
                                                                                WHERE ReportConfigurationInformation__c IN :oldMap.keySet() AND Year__c = :thisYear 
                                                                                ORDER BY StartDay__c];

        List<ReportConfigurationItem__c> upsertReportConfigurationItemList = new List<ReportConfigurationItem__c>();
        List<ReportConfigurationItem__c> deleteReportConfigurationItemList = new List<ReportConfigurationItem__c>();
                                                                              
        for(ReportConfigurationInformation__c settingItem : newList) {
            if(weeklyReportTypeIdList.contains(settingItem.RecordTypeId)) {
                Boolean changeCondition1 = (settingItem.Active__c) && (!oldMap.get(settingItem.Id).Active__c);
                Boolean changeCondition2 = (settingItem.FirstDayOfWeeklyReport__c != oldMap.get(settingItem.Id).FirstDayOfWeeklyReport__c);

                if(changeCondition1 || changeCondition2) {
                    // 原来设置的开始日
                    Integer oldSettingFirstDay = Integer.valueOf(oldMap.get(settingItem.Id).FirstDayOfWeeklyReport__c);
                    // 新设置的开始日
                    Integer newSettingFirstDay = Integer.valueOf(settingItem.FirstDayOfWeeklyReport__c);
                    System.debug('oldSettingFirstDay : ' + oldSettingFirstDay);
                    System.debug('newSettingFirstDay : ' + newSettingFirstDay);

                    // 更改开始日后的第一周的开始日期，即往后最近的原来的开始日
                    Date lastOldStartday = today;
                    if(numberDaysDue < oldSettingFirstDay) {
                        // 还未到最近的旧的开始日
                        lastOldStartday = weekStart.addDays(oldSettingFirstDay);
                    } else if( numberDaysDue > oldSettingFirstDay ) {
                        // 已过，找下一周
                        lastOldStartday = weekStart.addDays( 7 + oldSettingFirstDay);
                    }
                    // 更改开始日后的变化第一周的结束日
                    Date newLastOldEndday = weekStart.addDays( 7 + newSettingFirstDay -1);
                    if(newLastOldEndday < lastOldStartday) {
                        newLastOldEndday = newLastOldEndday.addDays(7);
                    }
                    System.debug('lastOldStartday : ' + lastOldStartday);
                    System.debug('newLastOldEndday : ' + newLastOldEndday);


                    // 需改更改的item
                    LisqContainer relatedItemslc = new LisqContainer(relatedReportConfigurationItemList).WhereAnd(new object[]{
                        'StartDay__c', '>=', lastOldStartday,
                        'ReportConfigurationInformation__c', '=', settingItem.Id
                    });
                    List<ReportConfigurationItem__c> needModifyItems = (List<ReportConfigurationItem__c>)relatedItemslc.ToSobjectList();

                    // 该配置所有相关的item
                    LisqContainer thisAllRelatedItemslc = new LisqContainer(relatedReportConfigurationItemList).WhereAnd(new object[]{
                        'Year__c', '=', thisYear,
                        'ReportConfigurationInformation__c', '=', settingItem.Id
                    });
                    List<ReportConfigurationItem__c> thisAllRelatedItems = (List<ReportConfigurationItem__c>)thisAllRelatedItemslc.ToSobjectList();

                    Date newStartDay = newLastOldEndday.addDays(1);
                    Date nextYear = Date.newInstance(thisYear + 1, 1, 1);
                    Integer cyclical = 0;
                    System.debug('newStartDay : ' + newStartDay);

                    System.debug('needModifyItems.size() : ' + needModifyItems.size());
                    for(ReportConfigurationItem__c item : needModifyItems) {
                        if(item.StartDay__c == lastOldStartday) {
                            cyclical = Integer.valueOf(item.Cyclical__c);
                            item.EndDate__c = newLastOldEndday;

                            System.debug('first item : ' + item);
                            upsertReportConfigurationItemList.add(item);
                        } else {
                            if(newStartDay < nextYear) {
                                item.StartDay__c = newStartDay;
                                item.EndDate__c = newStartDay.addDays(6);

                                cyclical = Integer.valueOf(item.Cyclical__c);
                                newStartDay = newStartDay.addDays(7);

                                System.debug('upsert item : ' + item);
                                upsertReportConfigurationItemList.add(item);
                            }
                            else {
                                System.debug('delete item : ' + item);
                                deleteReportConfigurationItemList.add(item);
                            }
                        }

                    }

                    if(thisAllRelatedItems.size() == 0) {
                        Date firstStartDay = firstdayOfThisYear;
                        Integer settingFirstDay = Integer.valueOf(settingItem.FirstDayOfWeeklyReport__c);
                        if(numberDaysDueOfYearFirstDay < settingFirstDay) {
                            firstStartDay = weekStartOfThisYear.addDays(settingFirstDay);
                        } else if(numberDaysDue > settingFirstDay) {
                            firstStartDay = weekStartOfThisYear.addDays(7 + settingFirstDay);
                        }
                        newStartDay = firstStartDay;
                    } 

                    if(newStartDay < nextYear) {
                        for(Integer index = cyclical + 1; newStartDay < nextYear; index++) {
                            ReportConfigurationItem__c item = new ReportConfigurationItem__c();
                            item.Year__c = thisYear;
                            item.Cyclical__c = index;
                            item.StartDay__c = newStartDay;
                            item.EndDate__c = newStartDay.addDays(6);
                            item.ReportConfigurationInformation__c = settingItem.Id;

                            newStartDay = newStartDay.addDays(7);

                            System.debug('add new item : ' + item);
                            upsertReportConfigurationItemList.add(item);
                        }
                    }

                }
            } else if(monthlyReportTypeIdList.contains(settingItem.RecordTypeId)) {
                // 月配置启用
                if((settingItem.Active__c) && (!oldMap.get(settingItem.Id).Active__c)) {
                    LisqContainer relatedMonthlyItemslc = new LisqContainer(relatedReportConfigurationItemList).WhereAnd(new object[]{
                        'Year__c', '=', thisYear,
                        'ReportConfigurationInformation__c', '=', settingItem.Id
                    });
                    if(relatedMonthlyItemslc.ToSobjectList().size() == 0) {
                        for(Integer index = 1; index <= 12; index++) {
                            ReportConfigurationItem__c item = new ReportConfigurationItem__c();
                            item.Year__c = thisYear;
                            item.Cyclical__c = index;
                            item.StartDay__c = date.newinstance(thisYear, index, 1);
                            item.EndDate__c = date.newinstance(thisYear, index, date.daysInMonth(thisYear, index));
                            item.ReportConfigurationInformation__c = settingItem.Id;
                            upsertReportConfigurationItemList.add(item);
                            System.debug('monthlyReport -------> item : ' + item);
                        }
                    }
                    
                }
                
            }
        }   
        
        if(upsertReportConfigurationItemList.size() > 0) {
            upsert upsertReportConfigurationItemList;
        }

        if(deleteReportConfigurationItemList.size() > 0) {
            upsert deleteReportConfigurationItemList;
        }
    }

    /**
     * @description 新建或更新时为记录名称赋值
     * @param   oldList     旧数据
     * @param   newList     新数据
     * @return
     */
    public static void assignValue(List<ReportConfigurationInformation__c> oldList, List<ReportConfigurationInformation__c> newList){
        System.debug('ReportConfigurationTriggerHandlerHelper ——> assignValue : ' );

        Boolean isUpdate = false;
        Map<Id, ReportConfigurationInformation__c> oldMap = new Map<Id, ReportConfigurationInformation__c>();
        if(oldList != null) {
            isUpdate = true;
            oldMap = new Map<Id, ReportConfigurationInformation__c>(oldList);
        }

        List<String> customerIdList = new LisqContainer(newList).selectsField('Customer__c');
        List<Account> customerList = [SELECT Id, Name FROM Account WHERE Id IN :customerIdList];
        Map<Id, Account> customerMap = new Map<Id, Account>(customerList);
        List<String> regionSplitList = new List<String>();
        for(ReportConfigurationInformation__c item : newList) {
            if(isUpdate) {
                if((item.RecordTypeId != oldMap.get(item.Id).RecordTypeId) || (item.Active__c != oldMap.get(item.Id).Active__c) ||
                    (item.SalesRegion__c != oldMap.get(item.Id).SalesRegion__c) || (item.Customer__c != oldMap.get(item.Id).Customer__c)) {
                    item.Mark__c = String.valueOf(item.RecordTypeId) + item.SalesRegion__c + item.Customer__c + item.Active__c;
                }

                if((item.SalesRegion__c != oldMap.get(item.Id).SalesRegion__c) || (item.Customer__c != oldMap.get(item.Id).Customer__c)) {
                    if(weeklyReportTypeIdList.contains(item.RecordTypeId)) {
                        item.Name = 'Weekly Of ';
                    } else if(monthlyReportTypeIdList.contains(item.RecordTypeId)) {
                        item.Name = 'Monthly Of ';
                    }
                    if(String.isBlank(item.Customer__c)) {
                        regionSplitList = item.SalesRegion__c.split(' ');
                        item.Name += regionSplitList.size() >= 2 ? regionSplitList[1] : regionSplitList[0];
                    } else {
                        if(customerMap.containsKey(item.Customer__c)) {
                            item.Name  += customerMap.get(item.Customer__c).Name;
                        }
                    }
                }
            } else {
                item.Mark__c = String.valueOf(item.RecordTypeId) + item.SalesRegion__c + item.Customer__c + item.Active__c;
                
                if(weeklyReportTypeIdList.contains(item.RecordTypeId)) {
                    item.Name = 'Weekly Of ';
                } else if(monthlyReportTypeIdList.contains(item.RecordTypeId)) {
                    item.Name = 'Monthly Of ';
                }
                if(String.isBlank(item.Customer__c)) {
                    regionSplitList = item.SalesRegion__c.split(' ');
                    item.Name += regionSplitList.size() >= 2 ? regionSplitList[1] : regionSplitList[0];
                } else {
                    if(customerMap.containsKey(item.Customer__c)) {
                        item.Name  += customerMap.get(item.Customer__c).Name;
                    }
                }
            }
        }
    }

}