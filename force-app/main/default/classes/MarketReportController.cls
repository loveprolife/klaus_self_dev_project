public without sharing class MarketReportController {

    private static String SOBJECT_NOT_FOUND = System.Label.INSPECTION_REPORT_MSG_SOBJECT_NOT_FOUND; //未找到{0}信息，请联系系统管理员
    private static String Daily_Report_Is_Null = System.Label.PromoterDailyReport_Daily_Report_Is_Null; //未找到{0}信息，请联系系统管理员
    // 初始化
    @AuraEnabled
    public static ConResponse getInitData(String recordId) {
        System.debug('recordId' + recordId);
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        // 获取Hisense Account Id
        List<Brand__c> hisenseAcc = getHisenseAccount();
        if (hisenseAcc.size()==0) {
            resp.code= -1;
            resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Account.getLabel()});
            return resp;
        }
        mso.put('hisenseAccId', hisenseAcc.size()>0 ? hisenseAcc[0].Id : null); 
        // 获取门店负责人信息，确定可选门店
        List<Responsible_Person__c> responsiblePersonList = getResponsiblePerson();
        mso.put('responsiblePersonList', responsiblePersonList); 
        // 获取Today
        mso.put('todayDate', System.today()); 
        // 日报ExId（不包含门店）
        String parExId = '_' + UserInfo.getUserId() + '_' + String.valueOf(System.today()) + ' 00:00:00';
        // 考勤ExId
        String paExId = UserInfo.getUserId() + '_' + String.valueOf(System.today());
        // 查询当天考勤信息
        List<Promoter_Attendance__c> paList = getExistAttendanceBasedExternalId(paExId);
        // 存在recordId
        if (String.isNotBlank(recordId)) {
            List<Market__c> pdrList = getExistMarketBasedId(recordId);
            if (pdrList.size()==0) {
                resp.code= -1;
                resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Market__c.getLabel()});
                return resp;
            }
            Market__c pdr = pdrList[0];
            mso.put('record', pdr);
            
            List<Shop__c> shopList = getShopNameBase(pdr.Shop__c);
            if (shopList.size()==0) {
                resp.code= -1;
                resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Shop__c.getLabel()});
                return resp;
            }
            Shop__c shop = shopList[0];
            mso.put('recordShopName', shop);
            List<Retail_Number__c> rnList = getExistRetailNumberBasedPdr(recordId);
            mso.put('retailNumberList', rnList); 
            //goods receiving  
            List<GoodsInOut__c> grList = getExistGoodsReceivingBasedPdr(recordId);
            mso.put('goodsReceivingList', grList); 
            System.debug('goodsReceivingList=======>'+grList);
            //intelligence  
            List<Shop_Retail_Detail__c> srdList = getExistIntelligenceBasedPdr(recordId);
            mso.put('intelligenceList', srdList); 
        // 不存在recordId
        } else {
            List<Market__c> pdr = getExistMarketBasedLikeExternalId('%'+parExId);
            // 判断是否为门店负责人
            List<Responsible_Person__c> rpList = new List<Responsible_Person__c>();
            if (pdr.size()>0) {
                rpList = getResponsiblePersonBaseShop(pdr[0].Shop__c);
            }
            // 如果存在当天日报，取最后更新记录
            if (pdr.size()>0 && rpList.size()>0) {
                mso.put('record', pdr[0]);
                List<Retail_Number__c> rnList = getExistRetailNumberBasedPdr(pdr[0].Id);
                mso.put('retailNumberList', rnList); 
                //goods receiving 
                List<GoodsInOut__c> grList = getExistGoodsReceivingBasedPdr(pdr[0].Id);
                mso.put('goodsReceivingList', grList);  
                //intelligence
                List<Shop_Retail_Detail__c> srdList = getExistIntelligenceBasedPdr(pdr[0].Id);
                mso.put('intelligenceList', srdList);
            // 如果不存在当天日报
            } else {
                // 存在考勤信息，并且有签到门店记录
                if (paList.size()>0 && paList[0].Shop__c!=null) {
                    mso.put('record', new Market__c(
                        Report_Date__c = System.today(),
                        Shop__c = paList[0].Shop__c
                    ));
                    mso.put('retailNumberList', new List<Retail_Number__c>());
                    mso.put('goodsReceivingList', new List<GoodsInOut__c>()); 
                    mso.put('intelligenceList', new List<Shop_Retail_Detail__c>());  
                // 不存在考勤信息
                } else {
                    if (responsiblePersonList.size()>0) {
                        mso.put('record', new Market__c(
                            Report_Date__c = System.today(),
                            Shop__c = responsiblePersonList[0].Shop_Name__c,
                            Status__c = 'New'
                        ));
                    } else {
                        mso.put('record', new Market__c(
                            Report_Date__c = System.today(),
                            Status__c = 'New'
                        ));
                    }
                    mso.put('retailNumberList', new List<Retail_Number__c>());
                    mso.put('goodsReceivingList', new List<GoodsInOut__c>());  
                    mso.put('intelligenceList', new List<Shop_Retail_Detail__c>());  
                }
            }
        }


        // added by sunny 【2023-09-24】
        List<WhitePrice__c> whitePriceList = [SELECT Product__c, convertCurrency(WhitePrice__c) price, FORMAT(WhitePrice__c) FROM WhitePrice__c];
        Map<String, Decimal> whitePriceMap = new Map<String, Decimal>();
        for(WhitePrice__c item : whitePriceList) {
            whitePriceMap.put(item.Product__c, (Decimal)item.get('price'));
        }
        mso.put('whitePriceMap', whitePriceMap);
        mso.put('intelligenceFields', SObjectHelper.getFieldLabelMap('Shop_Retail_Detail__c'));


        System.debug('resp======>'+resp);
        return resp;
    }
    
    // 刷新数据
    @AuraEnabled
    public static ConResponse refreshData(String reportDate, String ShopId) {
        System.debug('reportDate' + reportDate);
        System.debug('ShopId' + ShopId);
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        
        // 日报ExId
        String parExId = String.valueOf(ShopId) + '_' + UserInfo.getUserId() + '_' + String.valueOf(reportDate) + ' 00:00:00';

        List<Market__c> pdrList = getExistMarketBasedExternalId(parExId);
        if (pdrList.size()>0) {
            mso.put('record', pdrList[0]);
            List<Retail_Number__c> rnList = getExistRetailNumberBasedPdr(pdrList[0].Id);
            mso.put('retailNumberList', rnList); 
            //goods receiving  
            List<GoodsInOut__c> grList = getExistGoodsReceivingBasedPdr(pdrList[0].Id);
            mso.put('goodsReceivingList', grList);  
            //intelligence  
            List<Shop_Retail_Detail__c> srdList = getExistIntelligenceBasedPdr(pdrList[0].Id);
            mso.put('intelligenceList', srdList); 
        } else {
            // mso.put('record', new Promoter_Daily_Report__c(
            //     Report_Date__c = Date.valueOf(reportDate),
            //     Shop__c = ShopId
            // ));
            mso.put('retailNumberList', new List<Retail_Number__c>());
            mso.put('goodsReceivingList', new List<GoodsInOut__c>());
            mso.put('intelligenceList', new List<Shop_Retail_Detail__c>());     
        }
        System.debug('resp======>'+resp);
        return resp;
    }

    // 创建日报信息
    @AuraEnabled
    public static ConResponse createData(String recordJson) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        Market__c report = (Market__c)JSON.deserializeStrict(recordJson, Market__c.class);
        report.Status__c = 'New';

        upsert report;

        Market__c pdr = getExistMarketBasedId(report.Id)[0];
        mso.put('record', pdr);
        return resp;
    }

    // 保存日报信息
    @AuraEnabled
    public static ConResponse saveData(String recordJson,String retailNumberJson,String goodsReceivingJson, String intelligenceJson, Boolean isSubmit, 
    String retailNumberFilesMapJson, String goodsReceivingFilesMapJson, String intelligenceFilesMapJson) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        if (isSubmit == null) {
            isSubmit = false;
        }
        System.debug('recordJson' + recordJson);
        System.debug('isSubmit' + isSubmit);
        Market__c report = (Market__c)JSON.deserializeStrict(recordJson, Market__c.class);
        System.debug('id=====>'+report.Id);
        System.debug('isSubmit1' + isSubmit);
        System.debug('String.isNotBlank(report.Id)1=====>'+String.isNotBlank(report.Id));
        System.debug('report.status' + report.Status__c);
        // submit操作/save操作
        if (isSubmit && report.Status__c == 'New') {
            /** 
            report.Status__c = 'Submitted';
            //用于记录提交日期，以便审批判断时间,一级审批分级按照不同role审批
            report.ReportSubmittedDate__c = System.today();
            System.debug('ReportSubmittedDate__c=====>'+report.ReportSubmittedDate__c);
            User currentUser = [SELECT Id,Sales_Region__c ,UserRole.Name,UserRole.DeveloperName FROM User WHERE Id =:UserInfo.getUserId() and IsActive = true];
            // User approverSARm = [SELECT Id,UserRole.Name, UserRole.DeveloperName from user where UserRole.DeveloperName= 'SA Regional Manager' ORDER BY CreatedDate DESC LIMIT 1][0];
            // User approverSAOps = [SELECT Id,UserRole.Name, UserRole.DeveloperName from user where UserRole.DeveloperName= 'SA Ops Regional Manager' ORDER BY CreatedDate DESC LIMIT 1][0];
            // User approverCL = [SELECT Id,UserRole.Name, UserRole.DeveloperName from user where UserRole.DeveloperName= 'Chile_KAM' ORDER BY CreatedDate DESC LIMIT 1][0];
            // User approverID = [SELECT Id,UserRole.Name, UserRole.DeveloperName from user where UserRole.DeveloperName= 'Indonesia_Training_Manager' ORDER BY CreatedDate DESC LIMIT 1][0];
            if(currentUser.Sales_Region__c  == 'Hisense South Africa'){
                List<String> userRoleList = currentUser.UserRole.Name.split(' ');
                String userRoleName = 'SouthAfrica Regional Manager '+userRoleList[userRoleList.size()-1];
                List<UserRole> roleList = [SELECT Id,Name,DeveloperName,ParentRoleId FROM UserRole WHERE Name =: userRoleName];
                if (roleList.size()==0) {
                    resp.code= -1;
                    resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{'UserRole'});
                    return resp;
                }
                UserRole role = roleList[0];

                List<User> approverSARmList = [SELECT Id,UserRole.Name, UserRole.DeveloperName from user where UserRole.Name=: userRoleName ORDER BY CreatedDate DESC LIMIT 1];
                List<User> approverSAOpsList = [SELECT Id,UserRole.Name, UserRole.DeveloperName from user where UserRoleId=: role.ParentRoleId ORDER BY CreatedDate DESC LIMIT 1];
                if (approverSARmList.size()==0 || approverSAOpsList.size()==0) {
                    resp.code= -1;
                    resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{'Approver '+SObjectType.User.getLabel()});
                    return resp;
                }
                User approverSARm = approverSARmList[0];
                User approverSAOps = approverSAOpsList[0];
                
                report.SARegionalManager__c = approverSARm.Id;
                report.SAOpsRegionalManager__c = approverSAOps.Id;
            }else if(currentUser.Sales_Region__c  == 'Hisense Chile'){
                List<User> approverCLList = [SELECT Id,UserRole.Name, UserRole.DeveloperName from user where UserRole.DeveloperName= 'Chile_KAM' ORDER BY CreatedDate DESC LIMIT 1];
                if (approverCLList.size()==0) {
                    resp.code= -1;
                    resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{'Approver '+SObjectType.User.getLabel()});
                    return resp;
                }
                User approverCL = approverCLList[0];
                report.CLKeyAccountManager__c = approverCL.Id;
            }else if(currentUser.Sales_Region__c  == 'Hisense Indonesia'){
                List<User> approverIDList = [SELECT Id,UserRole.Name, UserRole.DeveloperName from user where UserRole.DeveloperName= 'Indonesia_Training_Manager' ORDER BY CreatedDate DESC LIMIT 1];
                if (approverIDList.size()==0) {
                    resp.code= -1;
                    resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{'Approver '+SObjectType.User.getLabel()});
                    return resp;
                }
                User approverID = approverIDList[0];
                report.IDTrainingManager__c = approverID.Id;
            }
            */
        } else if ((!isSubmit) && (report.Status__c == 'New' || report.Status__c == null || report.Status__c == '')) {
            report.Status__c = 'New';
        }
        System.debug('isSubmit2' + isSubmit);
        System.debug('String.isNotBlank(report.Id)2=====>'+String.isNotBlank(report.Id));
        System.debug('report.status' + report.Status__c);
        // 避免新建情况没有日报Id
        if (!isSubmit) {
            upsert report;
            System.debug('report====submit====>'+report);
        }
        /**
        ConResponse saveDailySalesData = saveDailySalesData(JSON.serialize(report), retailNumberJson, retailNumberFilesMapJson);
        if (!saveDailySalesData.issuccess) {
            resp = saveDailySalesData;
            return resp;
        }
        ConResponse saveGoodsReceivingData = saveGoodsReceivingData(JSON.serialize(report), goodsReceivingJson, isSubmit, goodsReceivingFilesMapJson);
        if (!saveGoodsReceivingData.issuccess) {
            resp = saveGoodsReceivingData;
            return resp;
        }
         */

        // 日报ExId
        String parExId = String.valueOf(report.Shop__c) + '_' + report.OwnerId + '_' + String.valueOf(report.Report_Date__c)+' 00:00:00';
        List<Promoter_Daily_Report__c> pdrList = getExistPromoterDailyReportBasedExternalId(parExId);
        // List<Promoter_Daily_Report__c> pdrList = [SELECT Id,Name FROM Promoter_Daily_Report__c WHERE IsStaticData__c = true];
        Promoter_Daily_Report__c pdr = new Promoter_Daily_Report__c();
        if (pdrList.size()==0) {
            // resp.code= -1;
            // resp.message = Daily_Report_Is_Null;
            // return resp;
            pdr.Shop__c = report.Shop__c;
            pdr.Report_Date__c = report.Report_Date__c;
            insert pdr;
        } else {
            pdr = pdrList[0];
        }

        ConResponse saveIntelligenceData = saveIntelligenceData(JSON.serialize(report), intelligenceJson, intelligenceFilesMapJson, pdr.Id);
        if (!saveIntelligenceData.issuccess) {
            resp = saveIntelligenceData;
            return resp;
        }
        if (isSubmit) {
            upsert report;
            System.debug('report====submit====>'+report);
        }
        
        Market__c mk = getExistMarketBasedId(report.Id)[0];
        mso.put('record', mk);
        List<Retail_Number__c> rnList = getExistRetailNumberBasedPdr(report.Id);
        mso.put('retailNumberList', rnList); 
        //goods receiving  
        List<GoodsInOut__c> grList = getExistGoodsReceivingBasedPdr(report.Id);
        mso.put('goodsReceivingList', grList); 
        System.debug('goodsReceivingList=======>'+grList);
        //intelligence  
        List<Shop_Retail_Detail__c> srdList = getExistIntelligenceBasedPdr(report.Id);
        mso.put('intelligenceList', srdList); 
        return resp;
    }

    // 保存零售信息
    @AuraEnabled
    public static ConResponse saveDailySalesData(String recordJson,String retailNumberJson,String retailNumberFilesMapJson) {
        System.debug('recordJson' + recordJson);
        System.debug('retailNumberJson' + retailNumberJson);
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        /** 
        try{
            Promoter_Daily_Report__c report = (Promoter_Daily_Report__c)JSON.deserializeStrict(recordJson, Promoter_Daily_Report__c.class);
            // 零售逻辑==================================================================================
            // 获取已存在的零售记录，转换为Map

            List<InputDataInfo> inputDataList = (List<InputDataInfo>)JSON.deserialize(retailNumberJson, List<InputDataInfo>.class);
            Shop__c store = [SELECT Id,Account__c FROM Shop__c WHERE id = :report.Shop__c];
                if(!inputDataList.isEmpty() && inputDataList.size()!=0){
                    System.debug('inputDataList--- '+  JSON.serialize(inputDataList));//add by tiger
                    Map<List<String>, Retail_Number__c> inputMap = new Map<List<String>, Retail_Number__c>();
                    List<Map<String,String>> filesKeyMap = new List<Map<String,String>>();
                    // 更新所有零售数据
                    for (InputDataInfo inputData : inputDataList) {
                        // 补充日报Id
                        inputData.dailySaleDataInfo.PromoterDailyReport__c = report.Id;
                        inputData.dailySaleDataInfo.Shop__c = report.Shop__c;
                        inputData.dailySaleDataInfo.Customer__c = store.Account__c;
                        // 整理附件新建用Map fileList => Retail_Number__c
                        inputMap.put(inputData.filesInfo, inputData.dailySaleDataInfo);
    
                        if (inputData.dailySaleDataInfo.Id == null && inputData.filesInfo.size()>0) {
                            // 关联附件
                            Map<String, String> keyMap = new Map<String, String>();
                            keyMap.put('index', inputData.filesInfo[0]);
                            filesKeyMap.add(keyMap);
                        }
                    }
                    // 更新零售信息，获取Id
                    system.debug('零售业绩map-----------'+inputMap.values());
                    if(report.Status__c == 'New'){
                        upsert inputMap.values(); 
                    }
                    
                    // 附件关联
                    UploadFilesController.saveFiles(JSON.serialize(filesKeyMap), retailNumberFilesMapJson, inputMap.values(), report.Id);
                    // 收集Id，数据删除用
                    Set<Id> rnIds = new Set<Id>();
                    // 重新整理附件Map Id => fileList
                    Map<String, List<String>> idFileMap = new Map<String, List<String>>();
                    for (List<String> filesInfo : inputMap.keySet()) {
                        Retail_Number__c rn = inputMap.get(filesInfo);
                        // 前端有处理，files为保证有唯一键值，第一条数据为数据files id
                        if (filesInfo.size()>1) {
                            idFileMap.put(rn.Id, filesInfo);
                        }
                        rnIds.add(rn.Id);
                    }
                    // 附件新建
                    System.debug('idFileMap--->'+idFileMap);
                    // 废弃
                    // if (idFileMap.keySet().size()>0) {
                    //     createUploadFile(idFileMap);
                    // }
                    // 查询日报绑定的所有零售信息
                    List<Retail_Number__c> allRnList = getExistRetailNumberBasedPdr(report.Id);
                    // Map<String, Retail_Number__c> allRnMap = new Map<String, Retail_Number__c>();
                    // for (Retail_Number__c rn : allRnList) {
                    //     allRnMap.put(rn.Id, rn);
                    // }
                    // 需要删除的零售数据
                    List<Retail_Number__c> delRnList = new List<Retail_Number__c>();
                    for (Retail_Number__c rn : allRnList) {
                        if (!rnIds.contains(rn.Id)) {
                            delRnList.add(rn);
                        }
                    }
                    // 数据删除
                    if (delRnList.size()>0) {
                        delete delRnList;
                    }
                } else {
                    // 查询日报绑定的所有零售信息
                    List<Retail_Number__c> allRnList = getExistRetailNumberBasedPdr(report.Id);
                    if (allRnList.size()!=0) {
                        delete allRnList;
                    }
                }
                // 重置零售信息
                List<Retail_Number__c> rnList = getExistRetailNumberBasedPdr(report.Id);
                mso.put('retailNumberList', rnList); 
        
        }catch(exception e) {
            resp.code = -1;
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        */
        return resp;
    }

    // 保存入库信息
    @AuraEnabled
    public static ConResponse saveGoodsReceivingData(String recordJson,String goodsReceivingJson, Boolean isSubmit, String goodsReceivingFilesMapJson) {
        System.debug('recordJson' + recordJson);
        System.debug('goodsReceivingJson' + goodsReceivingJson);
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        /**
        try{
            Promoter_Daily_Report__c report = (Promoter_Daily_Report__c)JSON.deserializeStrict(recordJson, Promoter_Daily_Report__c.class);
            // 收货逻辑==================================================================================
            // 获取已存在的收货记录，转换为Map
            Shop__c store = [SELECT Id,Account__c FROM Shop__c WHERE id = :report.Shop__c];
            List<InputDataInfo> inputDataList = (List<InputDataInfo>)JSON.deserialize(goodsReceivingJson, List<InputDataInfo>.class);
            if(!inputDataList.isEmpty() && inputDataList.size()!=0){
                Map<List<String>, GoodsInOut__c> inputMap = new Map<List<String>, GoodsInOut__c>();
                List<Map<String,String>> filesKeyMap = new List<Map<String,String>>();
                // 更新所有入库数据
                for (InputDataInfo inputData : inputDataList) {
                    // 补充日报Id
                    // if (isSubmit && inputData.goodsReceivingDataInfo.Status__c == 'New') {
                    //     inputData.goodsReceivingDataInfo.Status__c = 'Submitted';
                    // } else if (!isSubmit && inputData.goodsReceivingDataInfo.Status__c == 'New') {
                    //     inputData.goodsReceivingDataInfo.Status__c = 'New';
                    // }
                    inputData.goodsReceivingDataInfo.PromoterDailyReport__c = report.Id;
                    inputData.goodsReceivingDataInfo.StroeCode__c = report.Shop__c;
                    inputData.goodsReceivingDataInfo.Customer__c = store.Account__c;
                    // 整理附件新建用Map fileList => GoodsInOut__c
                    System.debug('inputData--- '+  JSON.serialize(inputData));//add by tiger
                    if (inputData.goodsReceivingDataInfo.Status__c=='New') {
                        if (isSubmit) {
                            inputData.goodsReceivingDataInfo.Status__c = 'Submitted';
                            inputData.goodsReceivingDataInfo.ReportDate__c = System.now();
                        }
                        inputMap.put(inputData.filesInfo, inputData.goodsReceivingDataInfo);
                        
                        if (inputData.goodsReceivingDataInfo.Id == null && inputData.filesInfo.size()>0) {
                            // 关联附件
                            Map<String, String> keyMap = new Map<String, String>();
                            keyMap.put('index', inputData.filesInfo[0]);
                            filesKeyMap.add(keyMap);
                        }
                    }
                }
                // 更新零售信息，获取Id
                upsert inputMap.values();
                // 附件关联
                UploadFilesController.saveFiles(JSON.serialize(filesKeyMap), goodsReceivingFilesMapJson, inputMap.values(), report.Id);
                // 收集Id，数据删除用
                Set<Id> grIds = new Set<Id>();
                // 重新整理附件Map Id => fileList
                Map<String, List<String>> idFileMap = new Map<String, List<String>>();
                for (List<String> filesInfo : inputMap.keySet()) {
                    GoodsInOut__c cio = inputMap.get(filesInfo);
                    // 前端有处理，files为保证有唯一键值，第一条数据为数据files id
                    if (filesInfo.size()>1) {
                        idFileMap.put(cio.Id, filesInfo);
                    }
                    grIds.add(cio.Id);
                }
                // 附件新建
                // 废弃
                // System.debug('idFileMap--->'+idFileMap);
                // if (idFileMap.keySet().size()>0) {
                //     createUploadFile(idFileMap);
                // }
                // 查询日报绑定的所有状态为New的入库信息
                List<GoodsInOut__c> allNewGrList = getExistGoodsReceivingBasedPdrStatus(report.Id, 'New');
                // Map<String, GoodsInOut__c> allGrMap = new Map<String, GoodsInOut__c>();
                // for (GoodsInOut__c gr : allGrList) {
                //     allGrMap.put(gr.Id, gr);
                // }
                // 需要删除的入库数据
                List<GoodsInOut__c> delGrList = new List<GoodsInOut__c>();
                for (GoodsInOut__c gr : allNewGrList) {
                    if (!grIds.contains(gr.Id)) {
                        delGrList.add(gr);
                    }
                }
                // 数据删除
                if (delGrList.size()>0) {
                    delete delGrList;
                }
            } else {
                // 查询日报绑定的所有入库数据
                List<GoodsInOut__c> allGrList = getExistGoodsReceivingBasedPdr(report.Id);
                if (allGrList.size()!=0) {
                    delete allGrList;
                }
            }
            // 重置入库信息
            List<GoodsInOut__c> grList = getExistGoodsReceivingBasedPdr(report.Id);
            mso.put('goodsReceivingList', grList); 
        }catch(exception e) {
            resp.code = -1;
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
         */
        return resp;
    }

    // 保存竞品信息
    @AuraEnabled
    public static ConResponse saveIntelligenceData(String recordJson,String intelligenceJson, String intelligenceFilesMapJson, String parId) {
        System.debug('recordJson' + recordJson);
        System.debug('intelligenceJson' + intelligenceJson);
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        try{
            Market__c report = (Market__c)JSON.deserializeStrict(recordJson, Market__c.class);
            // 竞品逻辑==================================================================================
            // 获取已存在的收货记录，转换为Map
            Shop__c store = [SELECT Id,Account__c FROM Shop__c WHERE id = :report.Shop__c];
            List<List<InputDataInfo>> inputDataList = (List<List<InputDataInfo>>)JSON.deserialize(intelligenceJson, List<List<InputDataInfo>>.class);
            if(!inputDataList.isEmpty() && inputDataList.size()!=0){
                Map<String, Shop_Retail_Detail__c> hisenseDataMap = new Map<String, Shop_Retail_Detail__c>();
                Map<String, Shop_Retail_Detail__c> otherDataMap = new Map<String, Shop_Retail_Detail__c>();
                Map<String, List<String>> fileDataMap = new Map<String, List<String>>();
                List<Map<String,String>> filesKeyMap = new List<Map<String,String>>();
                List<Shop_Retail_Detail__c> filesObjList = new List<Shop_Retail_Detail__c>();
                // 收集Id，数据删除用
                // Set<Id> srdIds = new Set<Id>();
                for (List<InputDataInfo> inputData : inputDataList) {
                    for (InputDataInfo item : inputData) {
                        // intelligence_Index_Idx
                        // Index相同为一组
                        if (item.filesInfo.size()==0) {
                            resp.code= -1;
                            resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{'Hisense'});
                            return resp;
                        }
                        String  dataId = item.filesInfo[0];
                        Shop_Retail_Detail__c srd = item.intelligenceDataInfo;
                        srd.RecordTypeId = Schema.SObjectType.Shop_Retail_Detail__c.getRecordTypeInfosByDeveloperName().get('CompetiveSaleData').getRecordTypeId();
                        srd.PromoterDailyReport__c = parId;
                        srd.Market__c = report.Id;
                        srd.Shop__c = report.Shop__c;
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
                UploadFilesController.saveFiles(JSON.serialize(filesKeyMap), intelligenceFilesMapJson, filesObjList, report.Id);
                
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
                List<Shop_Retail_Detail__c> allSrdList = getExistIntelligenceBasedPdr(report.Id);
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
                List<Shop_Retail_Detail__c> allSrdList = getExistIntelligenceBasedPdr(report.Id);
                if (allSrdList.size()!=0) {
                    delete allSrdList;
                }
            }

            // 重置竞品信息
            List<Shop_Retail_Detail__c> srdList = getExistIntelligenceBasedPdr(report.Id);
            mso.put('intelligenceList', srdList); 
        }catch(exception e) {
            resp.code = -1;
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        return resp;
    }

    //自动带出产品主数据
    @AuraEnabled
    public static ConResponse autoShowProductDes(String product) {
        String proId = product;
        ConResponse resp = new ConResponse();
        // Product__c pro = [SELECT Id, Description__c FROM Product__c WHERE Id =: proId];
        // resp.data = pro.Description__c;
        Product__c pro = [SELECT Id,Name, Categorys__c FROM Product__c WHERE Id =: proId];
        //String description = '';
        // if(String.isNotBlank(pro.Product_Line__c) && String.isNotBlank(pro.Series__c)){
        //     description = pro.Product_Line__c + '_' +pro.Series__c;
        // }else if(String.isBlank(pro.Product_Line__c) && String.isNotBlank(pro.Series__c)){
        //     description = pro.Series__c;
        // }else if(String.isNotBlank(pro.Product_Line__c) && String.isBlank(pro.Series__c)){
        //     description = pro.Product_Line__c;
        // }
        resp.data = pro.Categorys__c;
        System.debug('resp======>'+resp);
        return resp;
    }
    //判断是南非国家
    @AuraEnabled
    public static ConResponse judgeCountry() {
        //String Id = ownerId;
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        User currentUser = [SELECT Id,Sales_Region__c  FROM User WHERE Id =:UserInfo.getUserId() and IsActive = true];
        if(currentUser.Sales_Region__c  == 'Hisense South Africa'){
            mso.put('SouthAfrica',true);
        }else if(currentUser.Sales_Region__c  == 'Hisense Chile'){
            mso.put('Chile',true);
        }else if(currentUser.Sales_Region__c  == 'Hisense Indonesia'){
            mso.put('Indonesia',true);
        }else if(currentUser.Sales_Region__c  == 'Hisense Malaysia'){
            mso.put('Malaysia',true);
        }else{
            mso.put('Other',false); 
        }
        System.debug('resp======>'+resp);
        return resp;
    }

    //得到相应国家相应产品的提成
    @AuraEnabled
    public static ConResponse getProductSpiv(String product){
        String proId = product;
        ConResponse resp = new ConResponse();
        try{
            //Product__c productGet = [SELECT Id,Name, Product_Line__c,Series__c FROM Product__c WHERE Id =: proId];
            //User promoter =  [SELECT id,Name,Country__c FROM User where id = :recordPromoter];
            //String promoterCountry = promoter.Country__c;
            String promoterCountry = 'Hisense South Africa';
            //String promoterCountry = 'ZA';
            DateTime getTime = System.now();
            //system.debug('11111111111111111111111111111111111111111111111111111111'+getTime);
            ProductSpiv__c productSpivGet= [SELECT id,SPIV__c,Product__c FROM ProductSpiv__c WHERE Sales_Region__c = :promoterCountry AND Product__c = :product AND IsActive__c = true AND StartTime__c < :getTime AND EndTime__c > :getTime];
            system.debug(productSpivGet);
            Decimal Spiv = productSpivGet.SPIV__c;
            if(productSpivGet != null){
                resp.data = Spiv;
                System.debug('resp======>'+resp);
                return resp;
            }else{
                resp.code = -1;
            }
        }catch(exception e){
            resp.code = -1;
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        return resp;
    }

    // 创建附件
    // public static void createUploadFile(Map<String, List<String>> idFileMap) {
    //     Map<Blob, String> recordIdBaseBlob = new Map<Blob, String>();
    //     Map<Blob, ContentVersion> cvBaseBlob = new Map<Blob, ContentVersion>();
    //     for (String recordId : idFileMap.keySet()) {
    //         List<String> filesList = idFileMap.get(recordId);
    //         for (Integer i = 1; i < filesList.size(); i++) {
    //             String fileStream = filesList[i];
    //             String fileName = System.now().format('yyyyMMddHHmmss') + '.jpeg';

    //             Blob blobObj = EncodingUtil.base64Decode(fileStream.substring(23,fileStream.length()));
    //             ContentVersion cv = new ContentVersion();
    //             cv.VersionData = blobObj;
    //             cv.Title = fileName;
    //             cv.PathOnClient = fileName;
    //             cvBaseBlob.put(blobObj, cv);
    //             recordIdBaseBlob.put(blobObj, recordId);
    //         }
    //     }

    //     insert cvBaseBlob.values();

    //     Set<Id> cvIds = new Set<Id>();
    //     Map<String, String> recordIdBaseCvId = new Map<String, String>();
    //     for (Blob blobObj : cvBaseBlob.keySet()) {
    //         ContentVersion cv = cvBaseBlob.get(blobObj);
    //         cvIds.add(cv.Id);
    //         recordIdBaseCvId.put(cv.Id, recordIdBaseBlob.get(blobObj));
    //     }

    //     List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
    //     List<ContentVersion> qrcv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =:cvIds];
    //     for (ContentVersion cv : qrcv) {
    //         ContentDocumentLink cdl = new ContentDocumentLink();
    //         cdl.ContentDocumentId = cv.ContentDocumentId;
    //         cdl.LinkedEntityId = recordIdBaseCvId.get(cv.Id);
    //         cdl.ShareType = 'V';
    //         cdlList.add(cdl);
    //     }

    //     insert cdlList;
    // }

    // 获取Hisense Account Id (Brand) (竞品信息用)
    public static List<Brand__c> getHisenseAccount() {
        return [SELECT id FROM Brand__c WHERE Name = 'Hisense' LIMIT 1];
    }

    // 查询门店名
    public static List<Shop__c> getShopNameBase(String recordId) {
        return [SELECT Id, Name FROM Shop__c WHERE Id = : recordId];
    }

    // 获取门店负责人 (获取可选择门店)
    public static List<Responsible_Person__c> getResponsiblePerson() {
        return [SELECT 
                    Id,
                    Shop_Name__c,
                    Shop_Name__r.Name
                FROM Responsible_Person__c 
                WHERE Principal__c = : UserInfo.getUserId() AND RecordType__c = '促销员'];
    }
    public static List<Responsible_Person__c> getResponsiblePersonBaseShop(String shopId) {
        return [SELECT 
                    Id,
                    Shop_Name__c,
                    Shop_Name__r.Name
                FROM Responsible_Person__c 
                WHERE Principal__c = : UserInfo.getUserId() 
                AND RecordType__c = '促销员' 
                AND Shop_Name__c = : shopId];
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
    public static List<Promoter_Daily_Report__c> getExistPromoterDailyReportBasedLikeExternalId(String externalId) {
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
                    ExternalId__c 
                LIKE : externalId
                ORDER BY LastModifiedDate DESC];
    }
    public static List<Promoter_Daily_Report__c> getExistPromoterDailyReportBasedId(String recordId) {
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
                    Id =: recordId];
    }

    // Market信息
    public static List<Market__c> getExistMarketBasedExternalId(String externalId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Status__c,
                    Shop__c,
                    Report_Date__c,
                    OwnerId,
                    Owner_text__c
                FROM Market__c 
                WHERE 
                    ExternalId__c =: externalId];
    }
    public static List<Market__c> getExistMarketBasedLikeExternalId(String externalId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Status__c,
                    Shop__c,
                    Report_Date__c,
                    OwnerId,
                    Owner_text__c
                FROM Market__c 
                WHERE 
                    ExternalId__c 
                LIKE : externalId
                ORDER BY LastModifiedDate DESC];
    }
    public static List<Market__c> getExistMarketBasedId(String recordId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Status__c,
                    Shop__c,
                    Report_Date__c,
                    OwnerId,
                    Owner_text__c
                FROM Market__c 
                WHERE 
                    Id =: recordId];
    }

    // 获取存在的考勤信息
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

    // 获取零售信息
    public static List<Retail_Number__c> getExistRetailNumberBasedPdr(String pdrId) {
        return [
                SELECT 
                    Id,
                    Comments__c,
                    Description__c,
                    Gift__c,
                    GiftQuantity__c,
                    HasGift__c,
                    Price__c,
                    StoreDelivery__c,
                    Product__c,
                    Number__c,
                    Kiosk__c, 
                    SPIV__c,
                    PromoterDailyReport__c,
                    TotalPrice__c 
                FROM Retail_Number__c 
                WHERE 
                    PromoterDailyReport__c = :pdrId];
    }
    //获取收货信息 All
    public static List<GoodsInOut__c> getExistGoodsReceivingBasedPdr(String grId) {
        return [
            SELECT
                Id,
                ProductModel__c,
                PromoterDailyReport__c,
                Quantities__c,
                Status__c,
                Description__c
            FROM GoodsInOut__c
            WHERE PromoterDailyReport__c = :grId
        ];
    }
    //获取收货信息 Status__c
    public static List<GoodsInOut__c> getExistGoodsReceivingBasedPdrStatus(String grId, String status) {
        return [
            SELECT
                Id,
                ProductModel__c,
                PromoterDailyReport__c,
                Quantities__c,
                Status__c,
                Description__c
            FROM GoodsInOut__c
            WHERE PromoterDailyReport__c = :grId 
            AND Status__c = : status
        ];
    }
    //获取竞品信息
    public static List<Shop_Retail_Detail__c> getExistIntelligenceBasedPdr(String grId) {
        return [
            SELECT
                Id,
                Brands__c,
                ProductInformation__c,
                PromoterDailyReport__c,
                Market__c,
                Commission__c,
                Discount__c,
                Price__c,
                HisenseShopRetailDetail__c,
                NewProduct__c,
                DiscountPrice__c,
                CampaignType__c, 
                CampaignDescription__c,
                Shop__c,
                Product__c,
                WhitePrice__c, DebitPrice__c, CrebitPrice__c
            FROM Shop_Retail_Detail__c
            WHERE Market__c = :grId
            ORDER BY CreatedDate
        ];
    }
    
    public class InputDataInfo {     
        @AuraEnabled public Retail_Number__c dailySaleDataInfo{get;set;}
        @AuraEnabled public GoodsInOut__c goodsReceivingDataInfo{get;set;}
        @AuraEnabled public Shop_Retail_Detail__c intelligenceDataInfo{get;set;}
        @AuraEnabled public List<String> filesInfo{get;set;}
    }

}