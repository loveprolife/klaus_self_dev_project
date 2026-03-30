public without sharing class PromoterRemindersController {
    
    private static String SOBJECT_NOT_FOUND = System.Label.INSPECTION_REPORT_MSG_SOBJECT_NOT_FOUND; //未找到{0}信息，请联系系统管理员
    private static String VIEW_LABEL = System.Label.Preview; //Preview
    private static String NEW_LABEL = System.Label.INSPECTION_REPORT_NEW; //New
    private static String InHouseShare = Schema.PromoterShare__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('InHouseShare').getRecordTypeId();
    private static String ShelfShare = Schema.PromoterShare__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('ShelfShare').getRecordTypeId();
    @AuraEnabled
    public static ConResponse getInitData(){

        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
		resp.data = mso;        

        // 当前用户UserId
        String userId = UserInfo.getUserId();
        // 当前日期
        Date today = Date.today();
        mso.put('today', today);
        // 获取 Sales Region
        User user = [SELECT Id, Name, Sales_Region__c FROM User WHERE Id = : userId];
        mso.put('salesRegion', user.Sales_Region__c);

        // 获取门店负责人信息，拿到负责门店
        List<Responsible_Person__c> rpList = getResponsiblePerson(userId);
        if (rpList.size()==0) {
            resp.code = -1;
            return resp;
        }

        // CehckIn/Out
        List<Promoter_Attendance__c> paList = getAttendance(userId, today);
        if (paList.size()==0) {
            mso.put('needCheckIn', true);
            mso.put('needCheckOut', false);
        } else {
            mso.put('needCheckIn', false);
            Promoter_Attendance__c pa = paList[0];
            if (pa.CheckInStatus__c == '已签到') {
                mso.put('needCheckOut', true);
            } else {
                mso.put('needCheckOut', false);
            }
        }

        List<Map<String, Object>> reports = new List<Map<String, Object>>();
        List<Map<String, Object>> markets = new List<Map<String, Object>>();
        List<Map<String, Object>> marketInsights = new List<Map<String, Object>>();
        List<Map<String, Object>> marketInHouseShares = new List<Map<String, Object>>();
        List<Map<String, Object>> marketShelfShares = new List<Map<String, Object>>();

        // 门店Id->门店负责人 Map
        Map<String, Responsible_Person__c> shopMap = new Map<String, Responsible_Person__c>();
        for (Responsible_Person__c rp : rpList) {
            shopMap.put(rp.Shop_Name__c, rp);
        }
        mso.put('shopMap', shopMap);
        
        // 日报门店 Ids
        Set<String> reportStoreIds = new Set<String>();
        // 三天前
        Date befor3Day = today.addDays(-3);
        // 日报门店Id -> 日报
        // Map<String, List<Promoter_Daily_Report__c>> reportStoreIdMap = new Map<String, List<Promoter_Daily_Report__c>>();
        Map<String, Set<Date>> reportStoreIdMap = new Map<String, Set<Date>>();
        List<Promoter_Daily_Report__c> reportList = [
            SELECT Id,Shop__c,Status__c,Report_Date__c 
            FROM Promoter_Daily_Report__c 
            WHERE OwnerId = :userId 
            AND Report_Date__c > : befor3Day
            ORDER BY Name DESC];
        System.debug('reportList='+JSON.serialize(reportList));
        for (Promoter_Daily_Report__c item : reportList) {
            reportStoreIds.add(item.Shop__c);
            if (reportStoreIdMap.containskey(item.Shop__c)) {
                Set<Date> pdrList = reportStoreIdMap.get(item.Shop__c);
                pdrList.add(item.Report_Date__c);
            } else {
                Set<Date> pdrList = new Set<Date>();
                pdrList.add(item.Report_Date__c);
                reportStoreIdMap.put(item.Shop__c, pdrList);
            }
        }
        System.debug('reportStoreIdMap='+JSON.serialize(reportStoreIdMap));
        // 考勤信息门店 Ids
        Set<String> paiStoreIds = new Set<String>();
        // Map<String, List<Promoter_Attendance_Information__c>> storePaiMap = new Map<String, List<Promoter_Attendance_Information__c>>();
        Map<String, Set<Date>> storePaiMap = new Map<String, Set<Date>>();
        List<Promoter_Attendance_Information__c> paiList = getAttendanceInformation(userId, befor3Day);
        System.debug('paiList='+paiList);
        for (Promoter_Attendance_Information__c pai : paiList) {
            paiStoreIds.add(pai.Shop__c);
            if (storePaiMap.containskey(pai.Shop__c)) {
                Set<Date> paiItemList = storePaiMap.get(pai.Shop__c);
                paiItemList.add(pai.CheckIn_Date__c);
            } else {
                Set<Date> paiItemList = new Set<Date>();
                paiItemList.add(pai.CheckIn_Date__c);
                storePaiMap.put(pai.Shop__c, paiItemList);
            }
        }
        mso.put('storePaiMap', storePaiMap);

        DateTime todayDT = (DateTime)today;
        Integer todayWeek = Integer.valueOf(todayDT.format('u'));
        // 当周的第几天
        mso.put('todayWeek', todayWeek);
        // 本周一
        Date monday = today.addDays(-todayWeek+1);
        mso.put('monday', monday);
        // 本周五
        Date friday = monday.addDays(4);
        mso.put('friday', friday);
        // 最近的四个周一
        List<Date> mondaysWithinMonthList = new List<Date>();
        for (Integer i = 0; i < 4; i++) {
            mondaysWithinMonthList.add(monday.addDays(-7*i));
        }
        mso.put('mondaysWithinMonthList', mondaysWithinMonthList);
        
        // 存在竞品数据的周报门店
        // 周报门店Id -> 周报日期Map -> 所属周
        Map<String, Map<Date, Integer>> marketStoreIdMap = new Map<String, Map<Date, Integer>>();
        List<Shop_Retail_Detail__c> srdList = getShopRetailDetail(userId, mondaysWithinMonthList[3]);
        for (Shop_Retail_Detail__c srd : srdList) {
            if (marketStoreIdMap.containsKey(srd.Market__r.Shop__c)) {
                Map<Date, Integer> objItem = marketStoreIdMap.get(srd.Market__r.Shop__c);
                if (!objItem.containsKey(srd.Market__r.Report_Date__c)) {
                    objItem.put(srd.Market__r.Report_Date__c, checkDateWhichRange(srd.Market__r.Report_Date__c, mondaysWithinMonthList));
                }
            } else {
                Map<Date, Integer> objItem = new Map<Date, Integer>();
                objItem.put(srd.Market__r.Report_Date__c, checkDateWhichRange(srd.Market__r.Report_Date__c, mondaysWithinMonthList));
                marketStoreIdMap.put(srd.Market__r.Shop__c, objItem);
            }
        }
        mso.put('marketStoreIdMap', marketStoreIdMap);
        
        // 存在市场调查的周报门店
        // 周报门店Id -> 周报日期Map -> 所属周
        Map<String, Map<Date, Integer>> marketInsightStoreIdMap = new Map<String, Map<Date, Integer>>();
        List<MarketInsight__c> miList = getMarketInsight(userId, mondaysWithinMonthList[3]);
        for (MarketInsight__c mi : miList) {
            if (marketInsightStoreIdMap.containsKey(mi.Market__r.Shop__c)) {
                Map<Date, Integer> objItem = marketInsightStoreIdMap.get(mi.Market__r.Shop__c);
                if (!objItem.containsKey(mi.Market__r.Report_Date__c)) {
                    objItem.put(mi.Market__r.Report_Date__c, checkDateWhichRange(mi.Market__r.Report_Date__c, mondaysWithinMonthList));
                }
            } else {
                Map<Date, Integer> objItem = new Map<Date, Integer>();
                objItem.put(mi.Market__r.Report_Date__c, checkDateWhichRange(mi.Market__r.Report_Date__c, mondaysWithinMonthList));
                marketInsightStoreIdMap.put(mi.Market__r.Shop__c, objItem);
            }
        }
        mso.put('marketInsightStoreIdMap', marketInsightStoreIdMap);
        
        // 本月1号
        Date thisMonth1st = Date.newInstance(today.year(), today.month(), 1);
        mso.put('thisMonth1st', thisMonth1st);
        // 本月25号
        Date thisMonth25th = Date.newInstance(today.year(), today.month(), 25);
        mso.put('thisMonth25th', thisMonth25th);
        // 上月1号
        Date lastMonth1st = thisMonth1st.addMonths(-1);
        mso.put('lastMonth1st', lastMonth1st);
        
        List<Date> month1st = new List<Date>();
        month1st.add(thisMonth1st);
        month1st.add(lastMonth1st);
        
        // 存在InHouseShare的月报门店
        // 月报门店Id -> 月报日期Map -> 所有月
        Map<String, Map<Date, Integer>> inHouseShareStoreIdMap = new Map<String, Map<Date, Integer>>();
        List<PromoterShare__c> ihsList = getPromoterShare(userId, month1st[1], InHouseShare);
        for (PromoterShare__c ihs : ihsList) {
            if (inHouseShareStoreIdMap.containsKey(ihs.Market__r.Shop__c)) {
                Map<Date, Integer> objItem = inHouseShareStoreIdMap.get(ihs.Market__r.Shop__c);
                if (!objItem.containsKey(ihs.Market__r.Report_Date__c)) {
                    objItem.put(ihs.Market__r.Report_Date__c, checkDateWhichRange(ihs.Market__r.Report_Date__c, month1st));
                }
            } else {
                Map<Date, Integer> objItem = new Map<Date, Integer>();
                objItem.put(ihs.Market__r.Report_Date__c, checkDateWhichRange(ihs.Market__r.Report_Date__c, month1st));
                inHouseShareStoreIdMap.put(ihs.Market__r.Shop__c, objItem);
            }
        }
        mso.put('inHouseShareStoreIdMap', inHouseShareStoreIdMap);

        // 存在ShelfShare的月报门店
        // 月报门店Id -> 月报日期Map -> 所有月
        Map<String, Map<Date, Integer>> shelfShareStoreIdMap = new Map<String, Map<Date, Integer>>();
        List<PromoterShare__c> ssList = getPromoterShare(userId, month1st[1], ShelfShare);
        for (PromoterShare__c ss : ssList) {
            if (shelfShareStoreIdMap.containsKey(ss.Market__r.Shop__c)) {
                Map<Date, Integer> objItem = shelfShareStoreIdMap.get(ss.Market__r.Shop__c);
                if (!objItem.containsKey(ss.Market__r.Report_Date__c)) {
                    objItem.put(ss.Market__r.Report_Date__c, checkDateWhichRange(ss.Market__r.Report_Date__c, month1st));
                }
            } else {
                Map<Date, Integer> objItem = new Map<Date, Integer>();
                objItem.put(ss.Market__r.Report_Date__c, checkDateWhichRange(ss.Market__r.Report_Date__c, month1st));
                shelfShareStoreIdMap.put(ss.Market__r.Shop__c, objItem);
            }
        }
        mso.put('shelfShareStoreIdMap', shelfShareStoreIdMap);

        // 根据门店负责人信息循环门店数据
        for (String shopId : shopMap.keySet()) {
            System.debug('shopId='+JSON.serialize(shopId));
            // 门店名
            String storeName = shopMap.get(shopId).Shop_Name__r.Name;
            // 判断日报显示部分
            /*
            if (reportStoreIdMap.containskey(shopId)) {
                List<Promoter_Daily_Report__c> pdrList = reportStoreIdMap.get(shopId);
                for (Promoter_Daily_Report__c pdr : pdrList) {
                    if (pdr.Report_Date__c == today) {
                        Map<String, Object> reportStoreMap = new Map<String, Object>();
                        reportStoreMap.put('storeId',shopId);
                        reportStoreMap.put('storeName',storeName);
                        reportStoreMap.put('storeDate',pdr.Report_Date__c);
                        reportStoreMap.put('storeDateFormat',String.valueof(pdr.Report_Date__c).right(5));
                        reportStoreMap.put('status',VIEW_LABEL);
                        reports.add(reportStoreMap);
                    }
                }
            } else if (storePaiMap.containskey(shopId)) {
                // List<Promoter_Attendance_Information__c> paiItemList = storePaiMap.get(shopId);
                Set<Date> paiItemList = storePaiMap.get(shopId);
                for (Date pai : paiItemList) {
                    Map<String, Object> reportStoreMap = new Map<String, Object>();
                    reportStoreMap.put('storeId',shopId);
                    reportStoreMap.put('storeName',storeName);
                    reportStoreMap.put('storeDate',pai);
                    reportStoreMap.put('storeDateFormat',String.valueof(pai).right(5));
                    reportStoreMap.put('status',NEW_LABEL);
                    reports.add(reportStoreMap);
                }
            }
            */
            if (reportStoreIdMap.containskey(shopId)) {
                Set<Date> pdrList = reportStoreIdMap.get(shopId);
                if (pdrList.contains(today)) {
                    Map<String, Object> reportStoreMap = new Map<String, Object>();
                    reportStoreMap.put('storeId',shopId);
                    reportStoreMap.put('storeName',storeName);
                    reportStoreMap.put('storeDate',today);
                    reportStoreMap.put('storeDateFormat',String.valueof(today).right(5));
                    reportStoreMap.put('status',VIEW_LABEL);
                    reports.add(reportStoreMap);
                } else if (storePaiMap.containsKey(shopId)) {
                    Set<Date> dateSet = storePaiMap.get(shopId);
                    for (Date dateItem : dateSet) {
                        Map<String, Object> reportStoreMap = new Map<String, Object>();
                        reportStoreMap.put('storeId',shopId);
                        reportStoreMap.put('storeName',storeName);
                        reportStoreMap.put('storeDate',dateItem);
                        reportStoreMap.put('storeDateFormat',String.valueof(dateItem).right(5));
                        reportStoreMap.put('status',NEW_LABEL);
                        reports.add(reportStoreMap);
                    }
                }
            } else if (storePaiMap.containsKey(shopId)) {
                Set<Date> dateSet = storePaiMap.get(shopId);
                for (Date dateItem : dateSet) {
                    Map<String, Object> reportStoreMap = new Map<String, Object>();
                    reportStoreMap.put('storeId',shopId);
                    reportStoreMap.put('storeName',storeName);
                    reportStoreMap.put('storeDate',dateItem);
                    reportStoreMap.put('storeDateFormat',String.valueof(dateItem).right(5));
                    reportStoreMap.put('status',NEW_LABEL);
                    reports.add(reportStoreMap);
                }
            }

            // 周任务
            // 判断周报 竞品显示部分
            markets.addAll(marketWeek(shopId,storeName,marketStoreIdMap,mondaysWithinMonthList,today,friday));
            // 判断周报 市场调查显示部分
            marketInsights.addAll(marketWeek(shopId,storeName,marketInsightStoreIdMap,mondaysWithinMonthList,today,friday));

            // 月任务
            // 判断周报 竞品显示部分
            marketInHouseShares.addAll(marketWeek(shopId,storeName,inHouseShareStoreIdMap,month1st,today,thisMonth25th));
            // 判断周报 市场调查显示部分
            marketShelfShares.addAll(marketWeek(shopId,storeName,shelfShareStoreIdMap,month1st,today,thisMonth25th));
        }

        mso.put('reports', reports);
        mso.put('markets', markets);
        mso.put('marketInsights', marketInsights);
        mso.put('marketInHouseShares', marketInHouseShares);
        mso.put('marketShelfShares', marketShelfShares);

        return resp;
    }

    public static Integer checkDateWhichRange(Date checkDate, List<Date> dateList) {
        Integer returnInteger = 0;
        for (Integer i = 0; i < dateList.size(); i++) {
            if (checkDate>=dateList[i]) {
                return i;
            }
        }
        return returnInteger;
    }

    public static Map<String, Object> setStoreMap(String shopId, String storeName, Date dateItem, String status) {
        Map<String, Object> storeMap = new Map<String, Object>();
        storeMap.put('storeId',shopId);
        storeMap.put('storeName',storeName);
        storeMap.put('storeDate',dateItem);
        storeMap.put('storeDateFormat',String.valueof(dateItem).right(5));
        storeMap.put('status',status);
        return storeMap;
    }

    public static List<Map<String, Object>> marketWeek(
        String shopId, 
        String storeName, 
        Map<String, Map<Date, Integer>> storeIdMap, 
        List<Date> dateRange,
        Date today,
        Date specifyDate) {

        List<Map<String, Object>> returnMarket = new List<Map<String, Object>>();
        if (storeIdMap.containsKey(shopId)) {
            Map<Date, Integer> objItem = storeIdMap.get(shopId);
            Set<Integer> withinWeek = new Set<Integer>();
            // 门店近 四周/两月 有历史情况（含本周/月）
            for (Date dateItem : objItem.keySet()) {
                Integer within = objItem.get(dateItem);
                withinWeek.add(within);
                if (within==0) {
                    // 本周/月已存在的market
                    returnMarket.add(setStoreMap(shopId,storeName,dateItem,VIEW_LABEL));
                }
            }
            for (Integer i = 0; i < dateRange.size(); i++) {
                if (i==0 && !withinWeek.contains(0) && today>=specifyDate) {
                    // 本周/月不存在market，并且当天大于等于 周五/25号
                    returnMarket.add(setStoreMap(shopId,storeName,today,NEW_LABEL));
                } else if (i!=0 && !withinWeek.contains(i)) {
                    // 过去周/月是否存在market，不存在显示新建，并且日期定位 周一/一号
                    returnMarket.add(setStoreMap(shopId,storeName,dateRange[i],NEW_LABEL));
                }
            }
        } else {
            // 门店近四周/两月无历史情况（含本周/月）
            for (Integer i = 0; i < dateRange.size(); i++) {
                if (i==0 && today>=specifyDate) {
                    returnMarket.add(setStoreMap(shopId,storeName,today,NEW_LABEL));
                } else if (i!=0) {
                    returnMarket.add(setStoreMap(shopId,storeName,dateRange[i],NEW_LABEL));
                }
            }
        }
        return returnMarket;
    }

    // 获取门店负责人
    public static List<Responsible_Person__c> getResponsiblePerson(String userId) {
        return [SELECT 
                    Id,
                    Shop_Name__c,
                    Shop_Name__r.Name
                FROM Responsible_Person__c 
                WHERE Principal__c = : userId AND RecordType__c = '促销员'];
    }
    // 考勤
    public static List<Promoter_Attendance__c> getAttendance(String userId, Date today) {
        return [SELECT 
                    Id,
                    Name,
                    CheckInStatus__c
                FROM Promoter_Attendance__c 
                WHERE OwnerId = : userId 
                AND CheckIn_Date__c = : today];
    }
    // 考勤信息
    public static List<Promoter_Attendance_Information__c> getAttendanceInformation(String userId, Date today) {
        return [SELECT 
                    Id,
                    Name,
                    Shop__c,
                    CheckIn_Date__c
                FROM Promoter_Attendance_Information__c 
                WHERE Promoter_Attendance__r.OwnerId = : userId 
                AND CheckIn_Date__c > : today];
    }
    // 竞品信息
    public static List<Shop_Retail_Detail__c> getShopRetailDetail(String userId, Date monday) {
        return [SELECT 
                    Id,
                    Name,
                    Market__c,
                    Market__r.Name,
                    Market__r.Report_Date__c,
                    Market__r.Shop__c,
                    Market__r.ownerId
                FROM Shop_Retail_Detail__c 
                WHERE Market__r.Report_Date__c >= : monday 
                AND Market__r.ownerId = : userId 
                ORDER BY Market__r.Name DESC];
    }
    // 市场调查
    public static List<MarketInsight__c> getMarketInsight(String userId, Date monday) {
        return [SELECT 
                    Id,
                    Name,
                    Market__c,
                    Market__r.Report_Date__c,
                    Market__r.Shop__c,
                    Market__r.ownerId
                FROM MarketInsight__c 
                WHERE Market__r.Report_Date__c >= : monday 
                AND Market__r.ownerId = : userId 
                ORDER BY Market__r.Name DESC];
    }
    
    // Promoter Share
    public static List<PromoterShare__c> getPromoterShare(String userId, Date month1st, String recordTypeId) {
        return [SELECT 
                    Id,
                    Name,
                    Market__c,
                    Market__r.Report_Date__c,
                    Market__r.Shop__c,
                    Market__r.ownerId
                FROM PromoterShare__c 
                WHERE Market__r.Report_Date__c >= : month1st 
                AND Market__r.ownerId = : userId 
                AND RecordTypeId = : recordTypeId
                ORDER BY Market__r.Name DESC];
    }

}