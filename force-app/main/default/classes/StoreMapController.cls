/*
 * @Author: WFC
 * @Date: 2023-11-14 09:15:34
 * @LastEditors: Do not edit
 * @LastEditTime: 2024-12-11 14:27:21
 * @Description: 
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\StoreMapController.cls
 */
public with sharing class StoreMapController {

    public static User currentUser = [SELECT Id,Name,Username,Profile.name FROM User WHERE Id =:UserInfo.getUserId()]; 
    
    // 初始化
    @AuraEnabled
    public static ConResponse getInitData(String currentLat, String currentLong) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        Map<String, Boolean> objectAccessible = new Map<String, Boolean>();
        mso.put('objectAccessible', objectAccessible);
        objectAccessible.put('Retail_Number__c', Retail_Number__c.sObjectType.getDescribe().accessible);
        objectAccessible.put('Daily_Inspection_Report__c', Daily_Inspection_Report__c.sObjectType.getDescribe().accessible);
        String userId = UserInfo.getUserId();

        Double lat = Double.valueOf(currentLat);
        Double lng = Double.valueOf(currentLong);
        if (lat==0 && lng==0) {
            return resp;
        }

        // 获取经纬度100km范围内的门店
        List<Shop__c> stores = getShopByLocation(lat, lng, 100);
        Set<String> storeIds = new Set<String>();
        Map<String, String> storeCurrencyMap = new Map<String, String>();
        for (Shop__c store : stores) {
            storeIds.add(store.Id);
            storeCurrencyMap.put(store.Id, store.CurrencyIsoCode);
        }
        System.debug('stores size ->'+stores.size());
        Map<String, Integer> inspectionReportCount = getInspectionReportCount(storeIds);
        Map<String, String> inspectionReportId = getInspectionReportId(storeIds);
        Map<String, Decimal> dailySalesSellOut = getDailySales(storeCurrencyMap);
        // mso.put('stroreMapMarkets', getStoreDistanceList(lat, lng, stores, inspectionReportCount, dailySalesSellOut));
        mso.put('stroreMapMarkets', getStoreDistanceDetailList(lat, lng, stores, inspectionReportCount,inspectionReportId, dailySalesSellOut));

        List<Responsible_Person__c> responsiblePersons = getResponsiblePerson(userId);
        mso.put('responsiblePersons', responsiblePersons);
        System.debug('resp======>'+resp);
        // 2024-01-17 wfc 特定用户可不需要配置门店负责人信息，选择所有权限门店,去除所有的促销员
        if(!currentUser.Profile.name.contains('Promoter')){
            mso.put('isLeader', true);
        }
        return resp;
    }

    // 门店距离排序
    public static List<Map<String, Object>> getStoreDistanceList(Double lat, Double lng, List<Shop__c> stores, Map<String, Integer> inspectionReportCount, Map<String, Decimal> dailySalesSellOut) {
        
        System.debug('getStoreDistanceList ->');
        List<Map<String, Object>> storeDatas = new List<Map<String, Object>>();
        if (stores.size()==0) {
            System.debug('getStoreDistanceList return->');
            return storeDatas;
        }

        Location location = Location.newInstance(lat, lng);
        System.debug('getStoreDistanceList location->' + location);
        for (Shop__c store : stores) {
            Map<String, Object> storeMap = new Map<String, Object>();
            Decimal distance = location.getDistance(store.Shop_Center_Location__c,'km');
            storeMap.put('Id', store.Id);
            storeMap.put('Name', store.Name);
            storeMap.put('GridName', store.Grid__c!=null?store.Grid__r.Name:'');
            storeMap.put('AccountName', store.Account__c!=null?store.Account__r.Name:'');
            storeMap.put('object', store);
            storeMap.put('distance', distance);
            storeMap.put('distanceStr', String.valueOf(Integer.valueOf(distance*1000))+'m');
            if (inspectionReportCount.containsKey(store.Id)) {
                storeMap.put('inspectionReportCount', inspectionReportCount.get(store.Id));
            } else {
                storeMap.put('inspectionReportCount', 0);
            }
            if (dailySalesSellOut.containsKey(store.Id)) {
                storeMap.put('dailySalesSellOut', dailySalesSellOut.get(store.Id));
            } else {
                storeMap.put('dailySalesSellOut', 0);
            }

            System.debug('distance ->'+distance);
            storeDatas.add(storeMap);
        }

        return storeDatas;
    }
    //么门店距离排序方法增加 最近一次的巡店报告ID
    public static List<Map<String, Object>> getStoreDistanceDetailList(Double lat, Double lng, List<Shop__c> stores, Map<String, Integer> inspectionReportCount, Map<String, String> inspectionReportId, Map<String, Decimal> dailySalesSellOut) {
        
        System.debug('getStoreDistanceList ->');
        List<Map<String, Object>> storeDatas = new List<Map<String, Object>>();
        if (stores.size()==0) {
            System.debug('getStoreDistanceList return->');
            return storeDatas;
        }

        Location location = Location.newInstance(lat, lng);
        System.debug('getStoreDistanceList location->' + location);
        for (Shop__c store : stores) {
            Map<String, Object> storeMap = new Map<String, Object>();
            Decimal distance = location.getDistance(store.Shop_Center_Location__c,'km');
            storeMap.put('Id', store.Id);
            storeMap.put('Name', store.Name);
            storeMap.put('GridName', store.Grid__c!=null?store.Grid__r.Name:'');
            storeMap.put('AccountName', store.Account__c!=null?store.Account__r.Name:'');
            storeMap.put('object', store);
            storeMap.put('distance', distance);
            storeMap.put('distanceStr', String.valueOf(Integer.valueOf(distance*1000))+'m');
            if (inspectionReportCount.containsKey(store.Id)) {
                storeMap.put('inspectionReportCount', inspectionReportCount.get(store.Id));
            } else {
                storeMap.put('inspectionReportCount', 0);
            }
            if (inspectionReportId.containsKey(store.Id)) {
                storeMap.put('inspectionReportId', inspectionReportId.get(store.Id));
            } else {
                storeMap.put('inspectionReportId', null);
            }
            if (dailySalesSellOut.containsKey(store.Id)) {
                storeMap.put('dailySalesSellOut', dailySalesSellOut.get(store.Id));
            } else {
                storeMap.put('dailySalesSellOut', 0);
            }

            System.debug('distance ->'+distance);
            storeDatas.add(storeMap);
        }

        return storeDatas;
    }
    // 获取门店巡店报告数量
    public static Map<String, Integer> getInspectionReportCount(Set<String> storeIds) {
        Map<String, Integer> returnMap = new Map<String, Integer>();
        List<Daily_Inspection_Report__c> dirList = [SELECT Id, Name, Store__c FROM Daily_Inspection_Report__c WHERE Status__c ='Submitted' AND Store__c IN :storeIds];
        for (Daily_Inspection_Report__c dir : dirList) {
            if (returnMap.containsKey(dir.Store__c)) {
                Integer count = returnMap.get(dir.Store__c)+1;
                returnMap.put(dir.Store__c, count);
            } else {
                returnMap.put(dir.Store__c, 1);
            }
        }
        return returnMap;
    }

    // 20241209 TJP 获取门店巡店报告 最近一次的报告ID
    public static Map<String, String> getInspectionReportId(Set<String> storeIds) {
        Map<String, String> returnMap = new Map<String, String>();
        Map<String, Daily_Inspection_Report__c> dailyByDate = new Map<String, Daily_Inspection_Report__c>();

        List<Daily_Inspection_Report__c> dirList = [SELECT Id, Name, Store__c, Report_Date__c FROM Daily_Inspection_Report__c WHERE Status__c ='Submitted' AND Store__c IN :storeIds];
        for (Daily_Inspection_Report__c dir : dirList) {
            if (!dailyByDate.containsKey(dir.Store__c) || dailyByDate.get(dir.Store__c).Report_Date__c < dir.Report_Date__c) {
                dailyByDate.put(dir.Store__c, dir);
            }
        }

        for (String str : dailyByDate.keySet()) {
            returnMap.put(str, dailyByDate.get(str).Id);
        }
        
        return returnMap;
    }
    // 获取门店销售总额
    public static Map<String, Decimal> getDailySales(Map<String, String> storeCurrencyMap) {
        Map<String, Decimal> returnMap = new Map<String, Decimal>();
        List<Retail_Number__c> rnList = [SELECT Id, Name, Shop__c, Price__c, Number__c, TotalPrice__c, CurrencyIsoCode FROM Retail_Number__c WHERE Status__c ='Submitted' AND TotalPrice__c != null AND Shop__c IN :storeCurrencyMap.keySet()];
        for (Retail_Number__c rn : rnList) {
            if (returnMap.containsKey(rn.Shop__c)) {
                Decimal count = returnMap.get(rn.Shop__c)+rn.TotalPrice__c*CurrencyRateHelper.getConversionRate(rn.CurrencyIsoCode,storeCurrencyMap.get(rn.CurrencyIsoCode));
                returnMap.put(rn.Shop__c, count);
            } else {
                returnMap.put(rn.Shop__c, rn.TotalPrice__c*CurrencyRateHelper.getConversionRate(rn.CurrencyIsoCode,storeCurrencyMap.get(rn.CurrencyIsoCode)));
            }
        }
        
        return returnMap;
    }
    
    /**
     * @description 获取门店信息
     * @param   维度
     * @param   经度
     * @param   公里数
     * @return  门店列表
     */
    public static List<Shop__c> getShopByLocation(Double lat, Double lng, Integer distance) {
        return [SELECT 
                Id,
                Name,
                Sales_Region__c,
                City__c,
                Address1__c,
                Shop_Level__c,
                Phone__c,
                CurrencyIsoCode,
                Grid__c,
                Grid__r.Name,
                Account__c,
                Account__r.Name,
                Shop_Center_Location__c,
                Shop_Center_Location__Longitude__s,
                Shop_Center_Location__Latitude__s
            FROM Shop__c 
            WHERE 
                Shop_Center_Location__Latitude__s != null
            AND Shop_Center_Location__Longitude__s!= null
            AND DISTANCE(Shop_Center_Location__c,GEOLOCATION(:lat, :lng),'km') < :distance
            ORDER BY DISTANCE(Shop_Center_Location__c,GEOLOCATION(:lat, :lng),'mi')
            ];
    }

    // 获取门店负责人 (获取所有可选择门店)
    public static List<Responsible_Person__c> getResponsiblePerson(String userId) {
        return [SELECT 
                    Id,
                    Shop_Name__c,
                    RecordType__c
                FROM Responsible_Person__c 
                WHERE 
                    Principal__c = : userId];
    }

    // 自定义lookup相关==================================================================
    @AuraEnabled(cacheable=true)
    public static list<Map<String, Object>> fetchLookupData(string searchKey , string sObjectApiName , String lat, String lng, Integer lmt, Integer oft) {    
        List < Map<String, Object> > returnList = new List < Map<String, Object> > ();
        if (searchKey==null||searchKey=='' ||
            lat==null||lat=='' ||
            lng==null||lng=='' ||
            lmt==null||oft==null) {
            return returnList;
        }
        string sWildCardText = '%' + searchKey + '%';
        Double latD = Double.valueOf(lat);
        Double lngD = Double.valueOf(lng);
        Location location = Location.newInstance(latD, lngD);
        if (sObjectApiName == 'Shop__c') {
            String sQuery = '';
            sQuery += 'Select ';
            sQuery += 'Id,';
            sQuery += 'Name,';
            sQuery += 'Sales_Region__c,';
            sQuery += 'City__c,';
            sQuery += 'Address1__c,';
            sQuery += 'Shop_Level__c,';
            sQuery += 'Phone__c,';
            sQuery += 'CurrencyIsoCode,';
            sQuery += 'Grid__c,';
            sQuery += 'Grid__r.Name,';
            sQuery += 'Account__c,';
            sQuery += 'Account__r.Name,';
            sQuery += 'Shop_Center_Location__c,';
            sQuery += 'Shop_Center_Location__Longitude__s,';
            sQuery += 'Shop_Center_Location__Latitude__s';
            sQuery += ' From ';
            sQuery += sObjectApiName;
            sQuery += ' Where ';
            sQuery += '(';
            sQuery += 'Name Like : sWildCardText';
            sQuery += ' Or ';
            sQuery += 'Grid__r.Name Like : sWildCardText';
            sQuery += ' Or ';
            sQuery += 'Account__r.Name Like : sWildCardText';
            sQuery += ')';
            sQuery += ' And ';
            sQuery += 'Shop_Center_Location__Latitude__s != null';
            sQuery += ' And ';
            sQuery += 'Shop_Center_Location__Longitude__s != null';
            sQuery += ' Order By ';
            sQuery += 'DISTANCE(Shop_Center_Location__c,GEOLOCATION(:latD, :lngD),\'mi\')';
            sQuery += ' Limit : lmt Offset : oft';
            System.debug('sQuery='+sQuery);
            List<Shop__c> stores = new List<Shop__c>();
            Set<String> storeIds = new Set<String>();
            Map<String, String> storeCurrencyMap = new Map<String, String>();
            for (sObject sobj: database.query(sQuery)) {
                Shop__c obj = (Shop__c)sobj;
                stores.add(obj);
                storeIds.add(obj.Id);
                storeCurrencyMap.put(obj.Id, obj.CurrencyIsoCode);
            }
            Map<String, Integer> inspectionReportCount = getInspectionReportCount(storeIds);

            Map<String, String> inspectionReportId = getInspectionReportId(storeIds);
            Map<String, Decimal> dailySalesSellOut = getDailySales(storeCurrencyMap);
            // returnList = getStoreDistanceList(latD, lngD, stores, inspectionReportCount, dailySalesSellOut);
            returnList = getStoreDistanceDetailList(latD, lngD, stores, inspectionReportCount,inspectionReportId, dailySalesSellOut);
        }
        return returnList;
    }
}