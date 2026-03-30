/*
 * @Author: tom
 * @Date: 2024-10-23 10:39:30
 * @LastEditors: TJP
 * @LastEditTime: 2025-09-29 16:08:55
 */
public with sharing class CustomLookupProvider {
    
    public class Test implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey, string objName, Map<String, Object> option) {
            System.debug('option=' + option);
            return null;
        }
    }

    public class OfficeTest implements LookupController.IOfficeCustomLookup {

        public List<Sobject> getOfficeData(String salesRegion, string searchKey , string objName, Map<String, Object> option) {
            System.debug('option=' + option);
            return null;
        }
    }

    // YYL 新增渠道筛选逻辑
    public class ChannelAllFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
            
            //YYL 增加查询渠道数据 20250325
            String soql = '';
            if(String.isEmpty(searchKey)){
                soql = 'SELECT Id,Channel_Name__c FROM '+objName+' WHERE SBU__c =\''+option.get('salesRegion')+'\'';
            }else{
                soql = 'SELECT Id,Channel_Name__c FROM '+objName+' WHERE SBU__c =\''+option.get('salesRegion')+'\' AND Channel_Name__c LIKE \'%'+searchKey+'%\'';
            }
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    public class ProductAllFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
            
            //总部使用南非的产品
            if('Hisense International HQ'.equals(user.Sales_Region__c)){
                user.Sales_Region__c = 'Hisense South Africa';
            }
            //增加查询ALL Product RecordType - Japan数据  BY lizunxing 20231031
            String soql = '';
            if('Hisense Japan'.equals(user.Sales_Region__c)){
                soql = 'SELECT Id,Name,Name_Description__c FROM '+objName+' WHERE RecordType.DeveloperName =\'ALL_Product_Japan\' AND Name LIKE \'%'+searchKey+'%\'';
            }else{
                soql = 'SELECT Id,Name,Name_Description__c FROM '+objName+' WHERE RecordType.DeveloperName =\'RegionalProduct\' AND sales_region__c =\''+user.Sales_Region__c+'\' AND Name LIKE \'%'+searchKey+'%\'';
            }
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    public class ProductFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];

            //总部使用南非的产品
            if('Hisense International HQ'.equals(user.Sales_Region__c)){
                user.Sales_Region__c = 'Hisense South Africa';
            }

            //增加查询ALL Product RecordType - Japan数据  BY lizunxing 20231031
            String soql = '';
            if('Hisense Japan'.equals(user.Sales_Region__c)){
                soql = 'SELECT Id,Name,Name_Description__c FROM '+objName+' WHERE RecordType.DeveloperName =\'ALL_Product_Japan\' AND Name LIKE \'%'+searchKey+'%\' ';
            }else if('Hisense Argentina'.equals(user.Sales_Region__c)){
                soql = 'SELECT Id,Name,Name_Description__c FROM '+objName+' WHERE RecordType.DeveloperName =\'RegionalProduct\' AND sales_region__c =\''+user.Sales_Region__c+'\' AND Name LIKE \'%'+searchKey+'%\' ';
            }else {
                soql = 'SELECT Id,Name,Name_Description__c FROM '+objName+' WHERE RecordType.DeveloperName =\'RegionalProduct\' AND sales_region__c =\''+user.Sales_Region__c+'\' AND Name LIKE \'%'+searchKey+'%\' ';
            }
            System.debug('PRODUCTLINE' + option.get('Product_Line__c'));
            String productLine = option.containsKey('Product_Line__c') ? String.valueOf(option.get('Product_Line__c')) : '';
            if(String.isNotBlank(productLine) && productLine != 'All') {
                soql += ' AND Product_Line__c = : productLine  '; 
            }
            soql += ' LIMIT 5';
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }
    //20241029 TJP 总部专用 以门店 salesRegion 查询 
    public class InternationalProductFilter implements LookupController.IOfficeCustomLookup {

        public List<Sobject> getOfficeData(string salesRegion, string searchKey, string objName, Map<String, Object> option) {
            String region;
            System.debug('salesRegion=' + salesRegion);
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];

            if(user.Sales_Region__c == 'Hisense International') {
                region = salesRegion;
            } else {
                region = user.Sales_Region__c;
            }
            //总部使用南非的产品
            if('Hisense International HQ'.equals(user.Sales_Region__c)){
                region = 'Hisense South Africa';
            }

            //增加查询ALL Product RecordType - Japan数据  BY lizunxing 20231031
            String soql = '';
            if('Hisense Japan'.equals(user.Sales_Region__c)){
                soql = 'SELECT Id,Name,Name_Description__c FROM '+objName+' WHERE RecordType.DeveloperName =\'ALL_Product_Japan\' AND Name LIKE \'%'+searchKey+'%\' AND Product_Line__c = \''+option.get('Product_Line__c')+'\' LIMIT 5';
            }else if('Hisense Argentina'.equals(user.Sales_Region__c)){
                soql = 'SELECT Id,Name,Name_Description__c FROM '+objName+' WHERE RecordType.DeveloperName =\'RegionalProduct\' AND sales_region__c =\''+region+'\' AND Name LIKE \'%'+searchKey+'%\' AND Product_Line__c = \''+option.get('Product_Line__c') + '\'';
            }else {
                soql = 'SELECT Id,Name,Name_Description__c FROM '+objName+' WHERE RecordType.DeveloperName =\'RegionalProduct\' AND sales_region__c =\''+region+'\' AND Name LIKE \'%'+searchKey+'%\' AND Product_Line__c = \''+option.get('Product_Line__c')+'\' LIMIT 5';
            }
            
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    //20241218 LZX 阿根廷专用 以门店 salesRegion 查询 
    public class ArgentinaProductFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey, string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);

            String soql = '';
            soql = 'SELECT Id,Name,Name_Description__c FROM '+objName+' WHERE RecordType.DeveloperName =\'RegionalProduct\' AND sales_region__c =\'Hisense Argentina\' AND Name LIKE \'%'+searchKey+'%\' ';
            if(option.get('argentinaPL') != null && String.isNotBlank(String.valueOf(option.get('argentinaPL')))){
                soql += ' AND Product_Line__c = \''+option.get('argentinaPL') + '\'';
            }
            if(option.get('argentinaPS') != null && String.isNotBlank(String.valueOf(option.get('argentinaPS')))){
                soql += ' AND Series__c = \''+option.get('argentinaPS') + '\'';
            }

            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    public class ProductGift implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            String soql = '';
            if (option.containsKey('department')) {
                String department = String.valueOf(option.containsKey('department'));
                soql = 'SELECT Id,Name FROM '+objName+' WHERE RecordType.DeveloperName =\'Gift\' AND Name LIKE \'%'+searchKey+'%\' AMD Department__c = \''+department+'\' LIMIT 5';
            } else {
                soql = 'SELECT Id,Name FROM '+objName+' WHERE RecordType.DeveloperName =\'Gift\' AND Name LIKE \'%'+searchKey+'%\' LIMIT 5';
            
            }
            // String soql = 'SELECT Id,Name FROM '+objName+' WHERE RecordType.DeveloperName =\'Gift\' AND Name LIKE \'%'+searchKey+'%\' LIMIT 5';
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    public class UserFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
            String soql = '';
            if('Hisense Argentina'.equals(user.Sales_Region__c)){
                soql = 'SELECT Id,Name FROM '+objName+' WHERE IsActive = true AND Sales_Region__c = \''+user.Sales_Region__c +'\' AND (Name LIKE \'%'+searchKey+'%\' OR Email LIKE \'%'+searchKey+'%\')';
            }else {
                soql = 'SELECT Id,Name FROM '+objName+' WHERE IsActive = true AND Sales_Region__c = \''+user.Sales_Region__c +'\' AND (Name LIKE \'%'+searchKey+'%\' OR Email LIKE \'%'+searchKey+'%\') LIMIT 5';
            }
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    //TJP门店内可被检测的对应国家客户
    public class AccountFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
            String soql = 'SELECT Id,Name FROM '+objName+' WHERE Sales_Region__c = \''+user.Sales_Region__c +'\' AND (Name LIKE \'%'+searchKey+'%\' OR Email LIKE \'%'+searchKey+'%\') LIMIT 5';
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    public class BrandContainsHisense implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
            // String soql = 'SELECT Id,Name FROM '+objName+' WHERE RecordType.DeveloperName =\'Brand\' AND Name LIKE \'%'+searchKey+'%\' LIMIT 5';
            String soql = 'SELECT Id,Name FROM '+objName+' WHERE Name LIKE \'%'+searchKey+'%\' LIMIT 5';
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    public class BrandDoNotContainsHisense implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
            // String soql = 'SELECT Id,Name FROM '+objName+' WHERE RecordType.DeveloperName =\'Brand\' AND Name LIKE \'%'+searchKey+'%\' AND Name != \'Hisense\' LIMIT 5';
            String soql = 'SELECT Id,Name FROM '+objName+' WHERE Name LIKE \'%'+searchKey+'%\' AND Name != \'Hisense\' LIMIT 5';
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    public class StoreFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
            String soql = 'SELECT Id,Name FROM '+objName+' WHERE sales_region__c =\''+user.Sales_Region__c+'\' AND Name LIKE \'%'+searchKey+'%\' LIMIT 5';
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    // www-添加门店提货
    public class OtherStoreFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('wwwsearchKey=' + searchKey);
            System.debug('wwwobjName=' + objName);
            System.debug('wwwoption=' + option.get('Shop__c'));
            Shop__c shop = [SELECT Id,Account__c FROM Shop__c WHERE Id = : String.valueOf(option.get('Shop__c'))];
            String soql = '';
            if(shop.Account__c != null){
                soql = 'SELECT Id,Name FROM '+objName+' WHERE Name LIKE \'%'+searchKey+'%\' AND Account__c = \''+shop.Account__c+'\' AND Id != \'' + shop.Id+'\' LIMIT 5';
            }else {
                soql = 'SELECT Id,Name FROM '+objName+' WHERE Name LIKE \'%'+searchKey+'%\' AND Id != \'' + shop.Id+'\' LIMIT 5';
            }
            
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    // 排班计划-门店
    public class SchedulingPlanStoreFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            
            String rpSoql = '';
            rpSoql += 'SELECT ';
            rpSoql += 'Id,';
            rpSoql += 'Name,';
            rpSoql += 'Shop_Name__c,';
            rpSoql += 'Shop_Name__r.Name,';
            rpSoql += 'Principal__c,';
            rpSoql += 'Principal__r.Name,';
            rpSoql += 'Promoter_Attendance_Rule__c';
            rpSoql += ' FROM ';
            rpSoql += 'Responsible_Person__c ';
            rpSoql += ' WHERE ';
            rpSoql += 'RecordType__c = \'促销员\'';
            rpSoql += ' AND ';
            rpSoql += 'Shop_Name__c !=null';
            rpSoql += ' AND ';
            rpSoql += 'Principal__c !=null';
            rpSoql += ' AND ';
            rpSoql += 'Principal__r.IsActive = true';
            rpSoql += ' AND ';
            rpSoql += 'Promoter_Attendance_Rule__c !=null';
            rpSoql += ' AND ';
            rpSoql += 'Principal__r.Sales_Region__c = \''+option.get('salesRegion')+'\'';
            rpSoql += ' AND ';
            rpSoql += 'Shop_Name__r.Name LIKE \'%'+searchKey+'%\'';
            System.debug('soql=' + rpSoql);
            List<Shop__c> storeList = new List<Shop__c>();
            for (Sobject rpItem : Database.query(rpSoql)) {
                Responsible_Person__c rp = (Responsible_Person__c)rpItem;
                Shop__c s = new Shop__c();
                s.Id = rp.Shop_Name__c;
                s.Name = rp.Shop_Name__r.Name;
                storeList.add(s);
            }
            return storeList;
        }
    }

    // 排班计划-用户
    public class SchedulingPlanUserFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            
            String rpSoql = '';
            rpSoql += 'SELECT ';
            rpSoql += 'Id,';
            rpSoql += 'Name,';
            rpSoql += 'Shop_Name__c,';
            rpSoql += 'Shop_Name__r.Name,';
            rpSoql += 'Principal__c,';
            rpSoql += 'Principal__r.Name,';
            rpSoql += 'Promoter_Attendance_Rule__c';
            rpSoql += ' FROM ';
            rpSoql += 'Responsible_Person__c ';
            rpSoql += ' WHERE ';
            rpSoql += 'RecordType__c = \'促销员\'';
            rpSoql += ' AND ';
            rpSoql += 'Shop_Name__c !=null';
            rpSoql += ' AND ';
            rpSoql += 'Principal__c !=null';
            rpSoql += ' AND ';
            rpSoql += 'Principal__r.IsActive = true';
            rpSoql += ' AND ';
            rpSoql += 'Promoter_Attendance_Rule__c !=null';
            rpSoql += ' AND ';
            rpSoql += 'Principal__r.Sales_Region__c = \''+option.get('salesRegion')+'\'';
            rpSoql += ' AND ';
            rpSoql += 'Principal__r.Name LIKE \'%'+searchKey+'%\'';
            System.debug('soql=' + rpSoql);
            Set<String> ids = new Set<String>();
            for (Sobject rpItem : Database.query(rpSoql)) {
                Responsible_Person__c rp = (Responsible_Person__c)rpItem;
                ids.add(rp.Principal__c);
            }
            
            return [SELECT Id,Name FROM User WHERE Id IN :ids];
        }
    }

    // 带部门筛选的 UserFilter ---- add by Sunny
    public class DepartmentUserFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            String department = option.containsKey('department') ? String.valueOf(option.get('department')) : '';
            String salesRegion = option.containsKey('salesRegion') ? String.valueOf(option.get('salesRegion')) : '';
            User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
            String soql = 'SELECT Id, Name, Department__c, Username, Email, FullPhotoUrl FROM '+ objName +' WHERE IsActive = true AND (Name LIKE \'%'+searchKey+'%\' OR Email LIKE \'%'+searchKey+'%\') ';
            if(String.isNotBlank(salesRegion)) {
                soql += ' AND Sales_Region__c = \'' + salesRegion + '\''; 
            }else {
                soql += ' AND Sales_Region__c = \'' + user.Sales_Region__c + '\''; 
            }
            if(String.isNotBlank(department)) {
                soql += ' AND Department__c = :department '; 
            }
            soql += ' LIMIT 5';
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    // 巡店员日报门店列表
    public class ShopFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);

            List<shop__c> resultLs = new List<shop__c>();
            if(option != null && option.get('shopOptions') != null){

                List<shopInfo> ls = new List<shopInfo>();
                String shopOptions = option.get('shopOptions') + '';
                ls = (List<shopInfo>)JSON.deserializeStrict(shopOptions, List<shopInfo>.class);
                for(shopInfo si : ls){
                    shop__c s = new shop__c();
                    if(String.isNotBlank(searchKey)){
                        if(si.label.toLowerCase().contains(searchKey.toLowerCase())){
                            s.id = si.value;
                            s.name = si.label;
                            resultLs.add(s);
                        }
                    }else{
                        s.id = si.value;
                        s.name = si.label;
                        resultLs.add(s);
                    }
                }
            }

            return resultLs;
        }
    }

    public class ApprovalFliter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            // User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
            String soql = 'SELECT Id,Name,XHNumber__c FROM '+objName+' WHERE Type__c =\''+ '大区' +'\' AND XHNumber__c LIKE \'%'+searchKey+'%\' ';
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    //tjp 2025-05-27 增加根据CheckResult是否关联图片限定 可选 Store
    public class HavePhotoStoreFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            Set<String> processedNames = new Set<String>();
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
            String channelSql = '';
            String ownerSql = '';
            if (option.containsKey('channelId')) {
                Object startDateObj = option.get('channelId');
                if (startDateObj != null) {
                    channelSql = ' And Store__r.Channel_item__c = ' + '\''+ option.get('channelId') + '\'';
                }
            }
            if (option.containsKey('ownerId')) {
                Object startDateObj = option.get('ownerId');
                if (startDateObj != null) {
                    ownerSql = ' And InspectorDailyReport__r.OwnerId = ' + '\''+ option.get('ownerId') + '\'';
                }
            }

            List<Shop__c> storeList = new List<Shop__c>();
            String rpSoql = '';
            rpSoql += 'SELECT ';
            rpSoql += 'Id, ';
            rpSoql += 'Store__c, ';
            rpSoql += 'Store__r.Name ';
            rpSoql += 'FROM Inspection_Photo_Download__c ';
            rpSoql += 'WHERE SBU__c = \''+user.Sales_Region__c +'\' ';
            rpSoql += ' AND Inspection_Date__c >= ' + option.get('startDate');
            rpSoql += ' AND Inspection_Date__c <= ' + option.get('endDate') ;
            rpSoql += channelSql;
            rpSoql += ownerSql;
            System.debug('soql=' + rpSoql);
            List<Inspection_Photo_Download__c> photoList = Database.query(rpSoql);
            
            if(photoList.size() == 0) {
                return storeList;
            }
            for (Inspection_Photo_Download__c photo : photoList) {
                String shopName = photo.Store__r.Name;
                if (!processedNames.contains(shopName)) {
                    Shop__c s = new Shop__c();
                    s.Id = photo.Store__c;
                    s.Name = shopName;
                    storeList.add(s);
                    processedNames.add(shopName);
                }
            }
            return storeList;
        }
    }

    public class CustomerChannelFliter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            //             String soql = 'SELECT Id,Channel_Name__c FROM '+objName+' WHERE (Marketing_Model__c =\''+ '1' +'\' OR Marketing_Model__c =\''+ '2' +'\') AND Channel_Name__c != null AND Channel_Name__c LIKE \'%'+searchKey+'%\' LIMIT 50';
            String soql = 'SELECT Id,Name FROM '+objName+' WHERE Sales_Region__c =\''+user.Sales_Region__c+'\' AND (Marketing_Model__c =\''+ '1' +'\' OR Marketing_Model__c =\''+ '2' +'\') AND Channel_Name__c != null AND Channel_Name__c LIKE \'%'+searchKey+'%\' LIMIT 50';
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    public class CustomerSapCodeFliter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            User user = [SELECT Id,Name,Country__c,Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
            String soql = 'SELECT Id,SAP_Customer_Code__c FROM '+objName+' WHERE Sales_Region__c =\''+user.Sales_Region__c+'\' AND SAP_Customer_Code__c != null AND SAP_Customer_Code__c LIKE \'%'+searchKey+'%\' LIMIT 50';
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    public class BankFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            String soql = '';
            if(option != null && option.get('country') != null){
                soql = 'SELECT Id,Name,BANKL__c FROM '+objName+' WHERE BANKS__c = \''+option.get('country')+'\' AND Name LIKE \'%'+searchKey+'%\' LIMIT 50';
            }else {
                return null;
            }
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    public class PickListFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            String soql = '';
            if(option != null && option.get('entity') != null){
                soql = 'SELECT Id,Name,Value__c FROM '+objName+' WHERE belong_to_he__c = \''+option.get('entity')+'\' AND Name LIKE \'%'+searchKey+'%\' AND RecordType.DeveloperName = \'Master_Data_Office\' and Freeze__c = false LIMIT 50';
            }else if(option != null && option.get('belongToLocation') != null){
                soql = 'SELECT Id,Name,Value__c FROM '+objName+' WHERE belong_to_Loc__c = \''+option.get('belongToLocation')+'\' AND ( Name LIKE \'%'+searchKey+'%\'' + ' OR Value__c LIKE \'%'+searchKey+'%\' )' + ' AND RecordType.DeveloperName = \'Master_Location\' and Freeze__c = false LIMIT 50';
            }else if(option != null && option.get('belongToOffice') != null){
                soql = 'SELECT Id,Name,Value__c FROM '+objName+' WHERE belong_to_office__c = \''+option.get('belongToOffice')+'\' AND Name LIKE \'%'+searchKey+'%\' AND RecordType.DeveloperName = \'Master_Data_Team\' and Freeze__c = false LIMIT 50';
            }else if(option != null && option.get('belongToCountry') != null){
                soql = 'SELECT Id,Name,Value__c FROM '+objName+' WHERE belong_to_Country__c = \''+option.get('belongToCountry')+'\' AND Name LIKE \'%'+searchKey+'%\' AND RecordType.DeveloperName = \'Master_Data_Unified_Customer_Group\' and Freeze__c = false LIMIT 50';
            }else {
                return null;
            }
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    public class CountryStateFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            String soql = '';
            if(option != null && option.get('belongTo') != null){
                soql = 'SELECT Id,Name FROM '+objName+' WHERE Belong_To__c != null AND Belong_To__c = \''+option.get('belongTo')+'\' AND Name LIKE \'%'+searchKey+'%\' AND IsActive__c = true order by name LIMIT 50';
            }else if(option != null && option.get('belongToProvince') != null){
                soql = 'SELECT Id,Name FROM '+objName+' WHERE BelongTo_CNProvince__c = \''+option.get('belongToProvince')+'\' AND Name LIKE \'%'+searchKey+'%\' AND IsActive__c = true order by name LIMIT 50';
            }else if(option != null && option.get('belongToCity') != null){
                soql = 'SELECT Id,Name FROM '+objName+' WHERE BelongTo_CNCity__c = \''+option.get('belongToCity')+'\' AND Name LIKE \'%'+searchKey+'%\' AND IsActive__c = true order by name LIMIT 50';
            }else if(option != null && option.get('belongToDistrict') != null){
                soql = 'SELECT Id,Name FROM '+objName+' WHERE BelongTo_CNDistrict__c = \''+option.get('belongToDistrict')+'\' AND Name LIKE \'%'+searchKey+'%\' AND IsActive__c = true order by name LIMIT 50';
            }else {
                return null;
            }
            
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    public class TaxCategoryFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            String soql = 'SELECT Id,Name,Description__c FROM '+objName+' WHERE Tax_category__c = \''+option.get('tax')+'\' AND Name LIKE \'%'+searchKey+'%\' LIMIT 50';
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    public class StoreFilterTicket implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            String soql = 'SELECT Id,Name FROM '+objName+' WHERE sales_region__c =\'' + option.get('salesRegion') + '\' AND Name LIKE \'%'+searchKey+'%\' LIMIT 20';
            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    public class productTicketFilter implements LookupController.ICustomLookup {

        public List<Sobject> getData(string searchKey , string objName, Map<String, Object> option) {
            System.debug('searchKey=' + searchKey);
            System.debug('objName=' + objName);
            System.debug('option=' + option);
            
            String soql = '';
            if('Hisense Japan'.equals(option.get('salesRegion'))){
                soql = 'SELECT Id, Name, Name_Description__c, Product_Line__c,Product__c FROM '+ objName + 
                ' WHERE RecordType.DeveloperName =\'ALL_Product_Japan\' AND Name LIKE \'%'+searchKey+'%\' ';
            }else{
                soql = 'SELECT Id, Name, Name_Description__c, Product_Line__c,Product__c FROM '+objName +
                ' WHERE RecordType.DeveloperName =\'RegionalProduct\' AND sales_region__c =\''+option.get('salesRegion')+'\' AND Name LIKE \'%'+searchKey+'%\' ';
            }
            // 拼接参数
            if(option != null && option.get('productCategory') != null && option.get('productCategory') != ''){
                soql += ' AND Product__c=\''+option.get('productCategory')+'\' '; 
            }
            if(option != null && option.get('productLine') != null && option.get('productLine') != ''){
                soql += ' AND Product_Line__c=\''+option.get('productLine')+'\' '; 
            }
            soql += ' LIMIT 30 ';

            System.debug('soql=' + soql);
            return Database.query(soql);
        }
    }

    public class shopInfo{
        String label;
        String value;
    }

}