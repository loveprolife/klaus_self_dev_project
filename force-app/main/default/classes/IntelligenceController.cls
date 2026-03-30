public without sharing class IntelligenceController {
    @AuraEnabled
    public static ConResponse getInitData(String recordId) {
        System.debug('getInitData ——> recordId : ' + recordId );

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        String objectApiName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(!((objectApiName == 'Market__c') || (objectApiName == 'Research__c'))) {
            resp.message = 'error recordId type';
            resp.code = -1;
            return resp;
        }

        List<Shop_Retail_Detail__c> srdList = new List<Shop_Retail_Detail__c>();
        if(!String.isBlank(recordId)) {
            srdList = getExistIntelligenceBasedPdr(recordId, objectApiName);
        }
        mso.put('intelligenceList', srdList); 
        mso.put('fields', SObjectHelper.getFieldLabelMap('Shop_Retail_Detail__c'));

        String userId = UserInfo.getUserId();   
        List<User> currentUser = [SELECT Id, Name, Profile.Name, Email, Sales_Region__c FROM User WHERE Id = :userId ];
        Boolean isChile = (currentUser[0].Sales_Region__c == 'Hisense Chile');
        Boolean isSouthAfrica = (currentUser[0].Sales_Region__c == 'South Africa');
        mso.put('isChile', isChile);
        mso.put('isSouthAfrica', isSouthAfrica);

        // added by sunny 【2023-09-24】
        List<WhitePrice__c> whitePriceList = [SELECT Product__c, convertCurrency(WhitePrice__c) price, FORMAT(WhitePrice__c) FROM WhitePrice__c];
        Map<String, Decimal> whitePriceMap = new Map<String, Decimal>();
        for(WhitePrice__c item : whitePriceList) {
            whitePriceMap.put(item.Product__c, (Decimal)item.get('price'));
        }
        mso.put('whitePriceMap', whitePriceMap);

        // 获取Hisense Account Id
        List<Brand__c> hisense = getHisenseAccount();
        if (hisense.size()==0) {
            resp.code= -1;
            resp.message = String.format(System.Label.INSPECTION_REPORT_MSG_SOBJECT_NOT_FOUND, new List<String>{SObjectType.Account.getLabel()});
            return resp;
        }
        mso.put('hisenseAccId', hisense.size()>0 ? hisense[0].Id : null); 

        return resp;
    }

    // 保存竞品信息
    @AuraEnabled
    public static ConResponse saveRecord(String recordId, String intelligenceJson, String intelligenceFilesMapJson) {
        System.debug('recordId : ' + recordId);
        System.debug('intelligenceJson : ' + intelligenceJson);
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        System.Savepoint sp = Database.setSavepoint();
        try{
            // Market__c report = (Market__c)JSON.deserializeStrict(recordJson, Market__c.class);
            // Market__c report = [SELECT Id, Name, Report_Date__c, Shop__c, Shop__r.Name, OwnerId FROM Market__c WHERE Id = :recordId];
            String objectApiName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            if(!((objectApiName == 'Market__c') || (objectApiName == 'Research__c'))) {
                resp.message = 'error recordId type';
                resp.code = -1;
                return resp;
            }
    
            String reportQueryString = 'SELECT Id, Name, Report_Date__c, Shop__c, OwnerId FROM ' + objectApiName + ' WHERE Id = :recordId';
            List<SObject> reportList = Database.query(reportQueryString);
            if(reportList.size() == 0) {
                resp.message = 'error recordId';
                resp.code = -1;
                return resp;
            }


            // 竞品逻辑==================================================================================
            // 获取已存在的收货记录，转换为Map
            Shop__c store = [SELECT Id,Account__c FROM Shop__c WHERE id = :String.valueOf(reportList[0].get('Shop__c'))];
            List<List<InputDataInfo>> inputDataList = (List<List<InputDataInfo>>)JSON.deserialize(intelligenceJson, List<List<InputDataInfo>>.class);
            if(!inputDataList.isEmpty() && inputDataList.size()!=0){

                // 构造促销员日报
                // 日报ExId
                // String parExId = String.valueOf(report.Shop__c) + '_' + report.OwnerId + '_' + String.valueOf(report.Report_Date__c)+' 00:00:00';
                String parExId = reportList[0].get('Shop__c') + '_' + reportList[0].get('OwnerId') + '_' + reportList[0].get('Report_Date__c');
                System.debug('parExId=' + parExId);
                List<Promoter_Daily_Report__c> pdrList = getExistPromoterDailyReportBasedExternalId(parExId);
                Promoter_Daily_Report__c pdr = new Promoter_Daily_Report__c();
                if (pdrList.size()==0) {
                    pdr.Shop__c = String.valueOf(reportList[0].get('Shop__c'));
                    pdr.Report_Date__c = Date.valueOf(reportList[0].get('Report_Date__c'));
                    insert pdr;
                } else {
                    pdr = pdrList[0];
                }

                Map<String, Shop_Retail_Detail__c> hisenseDataMap = new Map<String, Shop_Retail_Detail__c>();
                Map<String, Shop_Retail_Detail__c> otherDataMap = new Map<String, Shop_Retail_Detail__c>();
                Map<String, List<String>> fileDataMap = new Map<String, List<String>>();
                List<Map<String,String>> filesKeyMap = new List<Map<String,String>>();
                List<Shop_Retail_Detail__c> filesObjList = new List<Shop_Retail_Detail__c>();
                // 收集Id，数据删除用
                // Set<Id> srdIds = new Set<Id>();
                for (List<InputDataInfo> inputData : inputDataList) {
                    for (InputDataInfo item : inputData) {
                        if (item.filesInfo.size()==0) {
                            continue;
                        }
                        // intelligence_Index_Idx
                        // Index相同为一组
                        String  dataId = item.filesInfo[0];
                        Shop_Retail_Detail__c srd = item.intelligenceDataInfo;
                        srd.RecordTypeId = Schema.SObjectType.Shop_Retail_Detail__c.getRecordTypeInfosByDeveloperName().get('CompetiveSaleData').getRecordTypeId();
                        srd.PromoterDailyReport__c = pdr.Id;
                        srd.put(objectApiName, recordId);
                        srd.Shop__c = String.valueOf(reportList[0].get('Shop__c'));
                        srd.Customer__c = store.Account__c;
                        // if (srd.Id!=null) {
                        //     srdIds.add(srd.Id);
                        // }
                        // 如果Idx为1，证明为海信竞品主数据，否则为竞品数据
                        if (dataId.split('_')[2] == '1') {
                            hisenseDataMap.put(dataId, srd);
                        } else {
                            otherDataMap.put(dataId, srd);
                        }
                        // DataId和附件键值对
                        fileDataMap.put(dataId, item.filesInfo);
                        
                        if (srd.Id==null) {
                            // 关联附件
                            Map<String, String> keyMap = new Map<String, String>();
                            keyMap.put('index', dataId);
                            filesKeyMap.add(keyMap);
                            filesObjList.add(srd);
                        }
                    }
                }
                // 更新主数据，获取主数据Id
                upsert hisenseDataMap.values();
                // 关联主数据与竞品数据
                for (String dataId : otherDataMap.keySet()) {
                    String hisenseDataId = dataId.split('_')[0] + '_' + dataId.split('_')[1] + '_1';
                    Shop_Retail_Detail__c hisenseSrd = hisenseDataMap.get(hisenseDataId);
                    Shop_Retail_Detail__c otherSrd = otherDataMap.get(dataId);
                    otherSrd.HisenseShopRetailDetail__c = hisenseSrd.Id;
                }
                // 更新竞品数据
                upsert otherDataMap.values();
                // 附件关联
                UploadFilesController.saveFiles(JSON.serialize(filesKeyMap), intelligenceFilesMapJson, filesObjList, recordId);
                
                // 数据删除
                // 收集Id，数据删除用
                Set<Id> srdIds = new Set<Id>();
                for (Shop_Retail_Detail__c srd : hisenseDataMap.values()) {
                    srdIds.add(srd.Id);
                }
                for (Shop_Retail_Detail__c srd : otherDataMap.values()) {
                    srdIds.add(srd.Id);
                }
                // 查询日报绑定的所有竞品数据
                List<Shop_Retail_Detail__c> allSrdList = getExistIntelligenceBasedPdr(recordId, objectApiName);
                // 需要删除的竞品数据
                List<Shop_Retail_Detail__c> delSrnList = new List<Shop_Retail_Detail__c>();
                for (Shop_Retail_Detail__c srn : allSrdList) {
                    if (!srdIds.contains(srn.Id)) {
                        delSrnList.add(srn);
                    }
                }
                // 数据删除
                if (delSrnList.size()>0) {
                    delete delSrnList;
                }
            } else {
                List<Shop_Retail_Detail__c> allSrdList = getExistIntelligenceBasedPdr(recordId, objectApiName);
                if (allSrdList.size()!=0) {
                    delete allSrdList;
                }
            }

            // 重置竞品信息
            List<Shop_Retail_Detail__c> srdList = getExistIntelligenceBasedPdr(recordId, objectApiName);
            mso.put('intelligenceList', srdList); 
        }catch(exception e) {
            Database.rollback(sp);
        	resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        	resp.code = -1;
        }
        return resp;
    }

    // 获取Hisense Account Id (Brand) (竞品信息用)
    public static List<Brand__c> getHisenseAccount() {

        // return [SELECT Id, Name FROM Account WHERE Name = 'Hisense' AND RecordType.DeveloperName = 'Brand' limit 1];

        // 更换Brand存储对象
        return [SELECT Id FROM Brand__c WHERE Name = 'Hisense' LIMIT 1];
    }


    //获取竞品信息
    public static List<Shop_Retail_Detail__c> getExistIntelligenceBasedPdr(String grId, String objectApiName) {
        // return [
        //     SELECT
        //         Id,
        //         Brands__c,
        //         ProductInformation__c,
        //         PromoterDailyReport__c,
        //         Market__c,
        //         Commission__c,
        //         Discount__c,
        //         Price__c,
        //         HisenseShopRetailDetail__c,
        //         NewProduct__c,
        //         DiscountPrice__c,
        //         CampaignType__c, 
        //         CampaignDescription__c,
        //         Shop__c,
        //         Product__c
        //         Brands__c, WhitePrice__c, DebitPrice__c, CrebitPrice__c
        //     FROM Shop_Retail_Detail__c
        //     WHERE Market__c = :grId
        //     ORDER BY CreatedDate
        // ];
        String recordQueryString = 'SELECT Id, Brands__c, ProductInformation__c, PromoterDailyReport__c, Commission__c, Discount__c, Price__c, HisenseShopRetailDetail__c, ';
        recordQueryString += 'NewProduct__c, DiscountPrice__c, CampaignType__c, CampaignDescription__c, Shop__c, Product__c, ';
        recordQueryString += 'WhitePrice__c, DebitPrice__c, CrebitPrice__c, ' + objectApiName;
        recordQueryString += ' FROM Shop_Retail_Detail__c WHERE ' + objectApiName + ' = :grId ORDER BY CreatedDate ';
        return Database.query(recordQueryString);
    }

    // 日报信息
    public static List<Promoter_Daily_Report__c> getExistPromoterDailyReportBasedExternalId(String externalId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Status__c,
                    Shop__c,
                    Report_Date__c,
                    OwnerId,
                    Owner_text__c
                FROM Promoter_Daily_Report__c 
                WHERE 
                    ExternalId__c =: externalId];
    }

    public class InputDataInfo {     
        @AuraEnabled public Retail_Number__c dailySaleDataInfo{get;set;}
        @AuraEnabled public GoodsInOut__c goodsReceivingDataInfo{get;set;}
        @AuraEnabled public Shop_Retail_Detail__c intelligenceDataInfo{get;set;}
        @AuraEnabled public List<String> filesInfo{get;set;}
    }



}