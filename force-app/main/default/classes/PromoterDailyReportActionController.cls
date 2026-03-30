/**
 * Name : PromoterDailyReportActionController
 * Author : Chiara
 * Date : 2022/01/17
 * -------------------------------------------
 * History Tracking
 * 
 */
public with sharing class PromoterDailyReportActionController {

    public static Date thisDay = System.today();
    private static String PROMOTE_PROFILE = '促销员'; //不需要翻译
    private static String RETAIL_NUMBER = 'Retail_Number__c'; //不需要翻译
    private static String RETAIL_SALE = System.Label.CheckInCheckOut_RETAIL_SALE;//零售业绩
    private static String RETAIL_DETAIL_SALE = System.Label.PromoterDailyReport_PRODUCT_PRICE;//门店价格调查
    //private static String COMPETITIVE_SALE = '门店竞品价格';
    private static String CHECK_IN = System.Label.PromoterDailyReport_CHECK_IN_STATUS;//考勤情况
    private static String WEEK_RESPONSE = System.Label.PromoterDailyReport_WEEK_PROBLEM;// '周报告问题';
    private static String RECORD_SAVE_FAIL = System.Label.PromoterDailyReport_SAVE_FAIL;// '记录保存失败，请检查页面错误信息.';
    @AuraEnabled
    public static ReturnData initReportInfo(String recordId, Date reportDate, String shopId, String productLine){
        //变更日期和门店id，如果没有对应的记录，则更新画面的周报和考勤信息
        ReturnData rd = new ReturnData();
        rd.isSuccess = true;
        System.debug('reportDate:' + reportDate);
        try{
            //变更时，不传recordId
            rd.thisDay = thisDay;
            rd.productPriceList = new List<ProductPrice> ();
            rd.retailSaleList = new List<Retail_Number__c>();
            rd.responseList = new List<WeekResearchResponseItem__c>();

            Boolean isRecordPage = false;
            if(String.isNotBlank(recordId) && reportDate == null && String.isBlank(shopId) ){
                //1、点击进入记录页面时初始化
                rd = initReportInfoWithRecordId(rd, recordId);
                rd.existRecordId = recordId;
                isRecordPage = true;
            }else{
                /**促销员日报 */
                //2、点击进入新建页面初始化,recordId,reportDate,shopId为空
                if(reportDate == null && String.isBlank(shopId)) {
                    rd.reportDate = thisDay;
                    List<Responsible_Person__c> rpList= CheckInCheckOutController.getResponsibleShop(UserInfo.getUserId(), PROMOTE_PROFILE);
                    if(rpList.size() > 0){
                        rd.shopId = rpList[0].Shop_Name__c;
                    } 
                }
                //3、点击记录页面，或在新建页面更改头, recordId可能非空或空，reportDate, shopId一定非空
                if(reportDate <> null && String.isNotBlank(shopId)) { //2、新建
                    rd.reportDate = reportDate;
                    rd.shopId = shopId;
                }

                //2、3场景需要去重判断
                List<Promoter_Daily_Report__c> pdrList= getCurrentUserDuplicateInfo(recordId, rd.shopId, String.valueof(rd.reportDate));
                if(pdrList.size() > 0){
                    rd.existRecordId = pdrList[0].Id;//重复则直接返回重复值，进行页面跳转
                    isRecordPage = true;
                    recordId = pdrList[0].Id;
                    rd = initReportInfoWithRecordId(rd, recordId);
                    //return rd;
                }
            }
            rd.dayOfWeek = getDayOfWeek(rd.reportDate);
            Date lastEditDate = thisDay.addDays(-Integer.valueOf(Label.Fill_Day));// wfc 10天
            if(isRecordPage){
                //点击进入记录页面时初始化
                //若为已创建报表，报表日期七天以内，今日创建，且为所有人可编辑
                if( lastEditDate <=rd.reportDate && String.valueOf(rd.createdDate) == String.valueOf(thisDay)  && rd.ownerId == UserInfo.getUserId() ) {
                    rd.isAllowEdit = true;
                }else{
                    rd.isAllowEdit = false;
                }
            }else{
                //若为未创建报表，报表日期七天以内，可创建
                if( lastEditDate <= rd.reportDate ) {
                    rd.isAllowEdit = true;
                }else{
                    rd.isAllowEdit = false;
                }
            }

            if(isRecordPage) {
                //1、点击进入记录页面时初始化
                List<Shop_Retail_Detail__c> srdList = getShopRetailDetailList(recordId);
                if(srdList.size() > 0) {
                    Integer index = 0;
                    for(Shop_Retail_Detail__c hisenseItem : srdList) {
                        ProductPrice ppItem = new ProductPrice();
                        ppItem.Index = index;
                        ppItem.IsActive = true;
                        ppItem.RetailDetail = hisenseItem;
                        ppItem.ComtitiveShopRetailDetails = new List<Shop_Retail_Detail__c>();
                        for (Shop_Retail_Detail__c competitiveItem : hisenseItem.ComtitiveShopRetailDetails__r) {
                            ppItem.ComtitiveShopRetailDetails.add(competitiveItem);
                        }
                        index ++;
                        rd.productPriceList.add(ppItem);
                    }
                }
            }else if(rd.isAllowEdit){
                //其余情况未存在记录，则仅允许编辑时初始化昨天的数据
                Date startDate = rd.reportDate.addDays(1-rd.dayOfWeek);
                Date endDate = rd.reportDate.addDays(7-rd.dayOfWeek);
                List<Shop_Retail_Detail__c> srdList = getYesterdayShopRetailDetailList(endDate, startDate, rd.shopId);
                if(srdList.size() > 0) {
                    Integer index = 0;
                    //取一周内上次编辑的门店调查
                    Date bigYesterday = null;
                    for(Shop_Retail_Detail__c hisenseItem : srdList) {
                        if(bigYesterday == null){
                            bigYesterday = hisenseItem.PromoterDailyReport__r.Report_Date__c;
                        }else if(bigYesterday > hisenseItem.PromoterDailyReport__r.Report_Date__c){
                            break;
                        }
                        ProductPrice ppItem = new ProductPrice();
                        ppItem.Index = index;
                        ppItem.IsActive = true;
                        
                        hisenseItem.Id = null;
                        hisenseItem.PromoterDailyReport__c = null;
                        ppItem.RetailDetail = hisenseItem;
                        ppItem.ComtitiveShopRetailDetails = new List<Shop_Retail_Detail__c>();
                        for (Shop_Retail_Detail__c competitiveItem : hisenseItem.ComtitiveShopRetailDetails__r) {
                            competitiveItem.Id = null;
                            competitiveItem.PromoterDailyReport__c = null;
                            ppItem.ComtitiveShopRetailDetails.add(competitiveItem);
                        }
                        index ++;
                        rd.productPriceList.add(ppItem);
                    }
                }
            }

            rd.productPriceListJson = JSON.serialize(rd.productPriceList);
            /**考勤情况 */
            List<Promoter_Attendance__c> paList =  getExistAttendance(UserInfo.getUserId() + '_' + String.valueOf(rd.reportDate));
            if(paList.size() > 0) {
                rd.promoterItem = paList[0];
            }else{
                rd.promoterItem = new Promoter_Attendance__c(Id = null, CheckInStatus__c = '未签到');
            }
        

            //寻找已存在的回复
            Map<String, WeekResearchResponseItem__c> wriMap = new Map<String, WeekResearchResponseItem__c> ();
            System.debug('isRecordPage:' +  isRecordPage);
            System.debug('rd.researchResponseId:' + rd.researchResponseId);
            
            System.debug('reportDate:' + reportDate);
            System.debug('shopId:' + shopId);
            System.debug('rd.reportDate:' + rd.reportDate);
            System.debug('rd.shopId:' + rd.shopId);
            if(isRecordPage ){
                if(rd.researchResponseId <> null && rd.researchResponseId <> '') {
                    //若存在关联周报，则通过关联周报查找
                    List<WeekResearchResponseItem__c> wrrList = getWeekResearchResponseList(rd.researchResponseId, rd.reportDate);
                    if(wrrList != null && wrrList.size()>0) {
                        rd.responseList = wrrList;
                        for(WeekResearchResponseItem__c wriItem : rd.responseList) {
                            wriMap.put(wriItem.Week_Question_Item__c, wriItem);
                        }
                    }
                }
            }else{
                // List<WeekResearchResponse__c> wrrList = getWeekResearchResponseList(rd.reportDate, rd.shopId);
                // System.debug('wrrList:' + wrrList);
                // if(wrrList.size() > 0) {
                //     rd.researchResponseId = wrrList[0].Id;
                //     rd.responseList = wrrList[0].WeekResearchResponseItems__r;
                //     System.debug('rd.responseList:' + rd.responseList);
                //     for(WeekResearchResponseItem__c wriItem : rd.responseList) {
                //         wriMap.put(wriItem.Week_Question_Item__c, wriItem);
                //     }
                // }

            }

            /**可编辑时，添加门店调查要求的问题 */
            if(rd.isAllowEdit) {
                List<Week_Research__c>  wrList = getWeelResearchList(rd.shopId,  rd.reportDate);
                System.debug('wrList:' + wrList);
                System.debug('rd.shopId:' + rd.shopId);
                System.debug('rd.reportDate:' + rd.reportDate);
                if(wrList.size() > 0){
                    /**周报 */
                    if(wrList[0].Week_Question_Item__r.size() > 0){
                        for(Week_Question_Item__c wqiItem : wrList[0].Week_Question_Item__r) {
                            if(!wriMap.containskey(wqiItem.Id)) {
                                WeekResearchResponseItem__c wrriItem = new WeekResearchResponseItem__c();
                                wrriItem.WeekResearchResponse__c = rd.researchResponseId;
                                wrriItem.Week_Question_Item__c = wqiItem.Id;
                                wrriItem.Question__c = wqiItem.Question__c;
                                rd.responseList.add(wrriItem);
                            }
                        }
                    }
                }
            }


        }catch(Exception e) {
            rd.isSuccess = false;
            rd.failMessage = e.getMessage() + '[' + e.getLineNumber() + ']';
            System.debug(e.getStackTraceString());
        }
        return rd;
    }
    //初始化记录页面
    public static ReturnData initReportInfoWithRecordId(ReturnData rd, String recordId){
        Promoter_Daily_Report__c pdItem= getPromoterDailyReportList(recordId);
        /**促销员日报 */
        rd.reportDate = pdItem.Report_Date__c;
        rd.ownerId = pdItem.OwnerId;
        rd.shopId = pdItem.shop__c;
        rd.productLine = pdItem.Product_Line__c;
        rd.createdDate = Date.valueOf(pdItem.CreatedDate) ;
        rd.noPerformance = pdItem.IsPerformance__c;

        /**零售业绩 */
        if(pdItem.RetailNumbers__r.size() > 0){
            rd.retailSaleList = pdItem.RetailNumbers__r;
        }

        /**周报Id */
        rd.researchResponseId = pdItem.PromoterDailyReport__c;

        return rd;
    }
    /**
     * Name : saveReport
     * Author : Chiara
     * Purpose : 任意DML操作失败，则全部失败rollback，页面显示报错信息，若全部成功，则返回成功，以及成功记录id
     * 若保存时，UserInfo.getUserId() <> 日报OwnerId，不允许编辑
     * Date : 2022/01/17
     */
    @AuraEnabled
    public static ReturnData saveReport(
        String recordId,String shopId, Date reportDate, String productLine,
        List<Retail_Number__c> retailSaleList,  //零售业绩
        String productPriceListJson,//门店价格调查json，从前端直接传过来自定义对象出错
        //List<ProductPrice> productPriceList,//门店价格调查
        Promoter_Attendance__c promoterItem , //考勤
        String researchResponseId,//周报Id
        List<WeekResearchResponseItem__c> responseList,//周报反馈
        List<String> deleteIdList,
        Supplementary_Information__c supplementaryItem,//补签
        Boolean noPerformance// 勾选参数(wfc)  
        ) {
        ReturnData rd = new ReturnData();
        rd.isSuccess = true;
        Savepoint sp = Database.setSavepoint();
        try{
            /**处理周报告问题 */
            if(responseList.size() > 0){
                try{
                    System.debug('responseList:' + responseList);
                    List<Week_Research__c>  wrList = getWeelResearchList(shopId,  reportDate);
                    Integer dayOfWeek = getDayOfWeek(reportDate);
                    Date startOfWeekDate = reportDate.addDays(1-dayOfWeek);
                    Date endOfWeekDate = reportDate.addDays(7-dayOfWeek);
                    if(String.isBlank(researchResponseId)){//如果没有周报则生成周报
                        WeekResearchResponse__c wrrItem = new WeekResearchResponse__c();
                        wrrItem.Shop__c = shopId;
                        wrrItem.StartDate__c = startOfWeekDate;
                        wrrItem.EndDate__c = endOfWeekDate;
                        wrrItem.ExternalId__c = wrrItem.Shop__c + '_' + UserInfo.getUserId() + '_' + wrrItem.StartDate__c + '_' + wrrItem.EndDate__c;
                        wrrItem.WeekResearch__c = wrList[0].Id;
                        upsert wrrItem ExternalId__c;
                        researchResponseId = wrrItem.Id;
                    }
                    for(WeekResearchResponseItem__c  wrriItem : responseList ){
                        if(String.isBlank(String.valueOf(wrriItem.WeekResearchResponse__c)) ){
                            wrriItem.WeekResearchResponse__c = researchResponseId;
                        }
                        //改为每日创建问题回复
                        wrriItem.Report_Date__c = reportDate;
                        wrriItem.ExternalId__c = wrriItem.WeekResearchResponse__c + '_'+ wrriItem.Week_Question_Item__c + '_' + reportDate;
                    }
                    System.debug('responseList:' + responseList);
                    upsert responseList ExternalId__c;

                }catch(Exception e){
                    rd.isSuccess = false;
                    rd.responseListError =  Utility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
                    System.debug(e.getStackTraceString());
                }
            }            
            /**处理考勤 */
           // if(reportDate == thisDay){
            //若考勤的签到审批状态为未创建或审批通过，可以创建并提交补签
            //其余情况，不处理
            try{
                if(promoterItem == null || String.isBlank(promoterItem.Id)) {
                    promoterItem.CheckIn_Date__c = reportDate;
                    promoterItem.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('PromoterAttendance').getRecordTypeId();
                    promoterItem.ExternalId__c = UserInfo.getUserId() + '_' + String.valueOf(reportDate);
                    upsert promoterItem ExternalId__c;
                }
                System.debug(promoterItem);
                if(supplementaryItem<>null && (String.isNotBlank(supplementaryItem.Reson__c) || String.isNotBlank(supplementaryItem.Shop__c) || supplementaryItem.Supplementary_SignIn_Time__c<> null )){
                    System.debug('supplementaryItem:' + supplementaryItem);
                    supplementaryItem.RecordTypeId = Schema.SObjectType.Supplementary_Information__c.getRecordTypeInfosByDeveloperName().get('CheckInSupplementary').getRecordTypeId();
                    supplementaryItem.Attendance__c = promoterItem.Id;
                    supplementaryItem.Status__c = '已提交补签申请';
                    insert supplementaryItem;
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments(supplementaryItem.Reson__c);
                    req.setObjectId(supplementaryItem.Id);
                    req.setSubmitterId(UserInfo.getUserId());
                    req.setSkipEntryCriteria(false);
                    Approval.ProcessResult approvalResult = Approval.process(req);
                    if(!approvalResult.isSuccess()) {
                        String errorMessage = '';
                        for(Database.Error err : approvalResult.getErrors()) {
                            errorMessage = errorMessage + err.getMessage() + ':' +  err.getFields() + ';';
                        }
                        rd.isSuccess = false;
                        rd.promoterItemError = errorMessage;
                    }
                }   
            }catch(Exception e){
                rd.isSuccess = false;
                rd.promoterItemError = Utility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
                system.debug(e.getMessage());
                System.debug(e.getStackTraceString());
            }
            //}
            /**处理考勤 */
            
            /**处理促销员日报 */

            WeekResearchResponse__c wrr = new WeekResearchResponse__c();
            wrr.id = researchResponseId;
            if(String.isNotBlank(recordId)) {
                Promoter_Daily_Report__c pdrItem = new Promoter_Daily_Report__c(
                    Id = recordId,
                    Report_Date__c = reportDate,
                    Shop__c = shopId,
                    Product_Line__c = productLine,
                    PromoterDailyReport__c = researchResponseId,
                    Attendance__c = promoterItem.Id,
                    // 保存'当日実績なし'勾选项（wfc）
                    IsPerformance__c = noPerformance
                );
                update pdrItem;
                rd.existRecordId = pdrItem.Id;
                wrr.Daily_Report__c = pdrItem.Id;
            }else{
                Promoter_Daily_Report__c pdrItem = new Promoter_Daily_Report__c(
                    Report_Date__c = reportDate,
                    Shop__c = shopId,
                    Product_Line__c = productLine,
                    PromoterDailyReport__c = researchResponseId,
                    Attendance__c = promoterItem.Id,
                    // 保存'当日実績なし'勾选项（wfc）
                    IsPerformance__c = noPerformance
                );
                insert pdrItem;
                rd.existRecordId = pdrItem.Id;
                wrr.Daily_Report__c = pdrItem.Id;
            }

            if(String.isNotBlank(researchResponseId)){
                update wrr;
            }
            system.debug('retailSaleList'+ retailSaleList.size());
            /**处理零售业绩 */
            try{
                // 先删除旧数据 （wfc）
                List<Retail_Number__c> delRetailNumber = [SELECT id FROM Retail_Number__c WHERE PromoterDailyReport__c =:rd.existRecordId AND Shop__c =: shopId];
                delete delRetailNumber;
                // 当日実績なし勾选 新建一条空数据（wfc）
                if(noPerformance){
                    Retail_Number__c rnItemNo = new Retail_Number__c();
                    rnItemNo.PromoterDailyReport__c = rd.existRecordId;
                    rnItemNo.Shop__c = shopId;
                    rnItemNo.Number__c = 0;
                    insert rnItemNo;
                }else if(retailSaleList.size() > 0) {
                    List<Retail_Number__c> addRetailNumberList = new List<Retail_Number__c>();
                    for(Retail_Number__c rnItem : retailSaleList) {
                        Retail_Number__c rnItemAdd = new Retail_Number__c();
                        rnItemAdd.PromoterDailyReport__c = rd.existRecordId;
                        rnItemAdd.Shop__c = shopId;
                        rnItemAdd.Product__c = rnItem.Product__c;
                        rnItemAdd.Number__c = rnItem.Number__c;

                        addRetailNumberList.add(rnItemAdd);
                    }

                    insert addRetailNumberList;
                }
            }catch(Exception e) {
                rd.isSuccess = false;
                rd.retailSaleListError = Utility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
                System.debug(e.getStackTraceString());
            }

            /**处理零售业绩 */

            /**门店产品价格调查 */
            String hisenseRTId = Schema.SObjectType.Shop_Retail_Detail__c.getRecordTypeInfosByDeveloperName().get('PromoterSaleData').getRecordTypeId();
            String competitiveRTId = Schema.SObjectType.Shop_Retail_Detail__c.getRecordTypeInfosByDeveloperName().get('CompetiveSaleData').getRecordTypeId();
            System.debug(productPriceListJson);
            List<ProductPrice> productPriceList = (List<ProductPrice>)JSON.deserialize(productPriceListJson, List<ProductPrice>.class);
            if(productPriceList.size() > 0) {
                try{
                    System.debug(productPriceList);
                    List<Shop_Retail_Detail__c> hisenseList = new List<Shop_Retail_Detail__c>();
                    List<Shop_Retail_Detail__c> competitiveList = new List<Shop_Retail_Detail__c>();
                    for(ProductPrice ppItem : productPriceList) {
                        Shop_Retail_Detail__c hisenseItem = ppItem.RetailDetail;
                        hisenseItem.RecordTypeId = hisenseRTId;
                        hisenseItem.PromoterDailyReport__c = rd.existRecordId;
                        hisenseItem.Shop__c = shopId;
                        hisenseList.add(hisenseItem);
                    }
                    upsert hisenseList;
                    for(ProductPrice ppItem : productPriceList) {
                        if(ppItem.ComtitiveShopRetailDetails <> null && ppItem.ComtitiveShopRetailDetails.size() > 0) {
                            for(Shop_Retail_Detail__c competitiveItem : ppItem.ComtitiveShopRetailDetails) {
                                competitiveItem.RecordTypeId = competitiveRTId;
                                competitiveItem.HisenseShopRetailDetail__c = ppItem.RetailDetail.Id;
                                competitiveItem.PromoterDailyReport__c = rd.existRecordId;
                                competitiveItem.Shop__c = shopId;
                                competitiveList.add(competitiveItem);
                            }
                        }
                    }
                    upsert competitiveList;
                }catch(Exception e) {
                    rd.isSuccess = false;
                    rd.productPriceListError = Utility.getProperErrorMessage(e.getMessage()) + '[' + e.getLineNumber() + ']';
                    System.debug(e.getStackTraceString());
                }
            }
            /**门店产品价格调查 */

            /**删除移除的记录 */
            Database.DeleteResult[] deleteResults = Database.delete(deleteIdList, true);
            for(Database.DeleteResult dr : deleteResults) {                   
                if (!dr.isSuccess()) {
                    String errorMessage = '';
                    for(Database.Error err : dr.getErrors()) {
                        errorMessage = errorMessage + err.getMessage() + ':' +  err.getFields() + ';';
                    }
                    rd.isSuccess = false;
                    rd.failMessage = errorMessage;
                }
            }

        }catch(Exception e) {
            rd.isSuccess = false;
            rd.failMessage = e.getMessage() + '[' + e.getLineNumber() + ']';
            system.debug('e.getMessage()'+ e.getMessage());
            System.debug(e.getStackTraceString());
        }
        if(!rd.isSuccess){
            //任意DML错误，则回滚，若无failMessage，则让用户检查页面报错信息
            if(String.isBlank(rd.failMessage)){
                rd.failMessage = RECORD_SAVE_FAIL;
                if(String.isNotBlank(rd.retailSaleListError)) {
                    rd.failMessage = rd.failMessage + '：' + RETAIL_SALE +';';
                }
                if(String.isNotBlank(rd.promoterItemError)) {
                    rd.failMessage = rd.failMessage + '：' + CHECK_IN + ';';
                }
                if(String.isNotBlank(rd.productPriceListError)) {
                    rd.failMessage = rd.failMessage + '：' + RETAIL_DETAIL_SALE + ';';
                }
                /*
                if(String.isNotBlank(rd.retailDetailListError)) {
                    rd.failMessage = rd.failMessage + '：' + RETAIL_DETAIL_SALE + ';';
                }
                if(String.isNotBlank(rd.competitiveSaleError)) {
                    rd.failMessage = rd.failMessage + ':' + COMPETITIVE_SALE + ';';
                }*/
                if(String.isNotBlank(rd.responseListError)) {
                    rd.failMessage = rd.failMessage + ':' + WEEK_RESPONSE + ';';
                }
            }
            Database.rollback(sp);
        }
        return rd;
    }

    // 获取存在的考勤信息
    public static List<Promoter_Attendance__c> getExistAttendance(String externalId) {
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


    /**
     * Name : getCurrentUserDuplicateInfo
     * Author : Chiara
     * Purpose : 1、编辑门店或日报日期寻找指定记录是否存在 2、新建时做重复判定 ,所以跳转记录以操作用户为准，筛选条件UserInfo.getUerId()
     * Date :2022/01
     */
    @AuraEnabled
    public static List<Promoter_Daily_Report__c> getCurrentUserDuplicateInfo(String recordId, String shopId, String reportDate) {
        return [
                SELECT 
                    Id,
                    Shop__c,
                    Report_Date__c,
                    Product_Line__c
                FROM Promoter_Daily_Report__c
                WHERE 
                    ReportDateFormula__c  =: reportDate
                AND 
                    Shop__c =: shopId
                AND 
                    OwnerId =: UserInfo.getUserId()
                AND 
                    Id <>: recordId
        ];
    }
    //获取周天
    public static Integer getDayOfWeek(Date dateItem) {
        Datetime datetimeItem = (Datetime)dateItem;
        return  Integer.valueOf(datetimeItem.format('u'));

    }


    //获取日报信息
    public static Promoter_Daily_Report__c getPromoterDailyReportList(String recordId) {
        return [
                SELECT 
                    Id, 
                    Shop__c,
                    Product_Line__c,
                    Report_Date__c,
                    PromoterDailyReport__c,
                    OwnerId,
                    CreatedDate,
                    IsPerformance__c,
                    (SELECT Id,Product__c,
                    ProductCategory__c,
                    ProductSeries__c,
                    Number__c FROM RetailNumbers__r)//,
                FROM Promoter_Daily_Report__c 
                WHERE 
                    Id =: recordId];
    }

    /**
     * Name : getYesterdayShopRetailDetailList
     * Author : Chiara
     * Purpose : 获取昨天的门店价格调查记录，因为允许编辑的情况下，即记录所有人操作才获取昨天的门店销售记录，此时使用UserInfo.getUserId()无误
     * Date : 2022/01
     */
    public static List<Shop_Retail_Detail__c> getYesterdayShopRetailDetailList(Date endDate, Date startDate, String shopId){
        return [SELECT 
                    Id,
                    Product__c,
                    Price__c,
                    DiscountPrice__c,
                    Point__c,
                    Shop__c,
                    PromoterDailyReport__r.Report_Date__c,
                    (SELECT Id, CP_Brand__c, CompetitiveProduct__c, Price__c, DiscountPrice__c, Point__c 
                    FROM ComtitiveShopRetailDetails__r)
                FROM Shop_Retail_Detail__c
                WHERE 
                    PromoterDailyReport__r.Report_Date__c >=: startDate
                AND 
                    PromoterDailyReport__r.Report_Date__c <=: endDate
                AND 
                    PromoterDailyReport__r.OwnerId =: UserInfo.getUserId()
                AND     
                    Shop__c =: shopId
                AND 
                    RecordType.DeveloperName = 'PromoterSaleData'
                ORDER BY PromoterDailyReport__r.Report_Date__c DESC];
    }
    //获取该日报关联的门店价格调查记录
    public static List<Shop_Retail_Detail__c> getShopRetailDetailList(String reportId){
        return [SELECT 
                    Id,
                    Product__c,
                    Price__c,
                    DiscountPrice__c,
                    Point__c,
                    (SELECT Id, CP_Brand__c, CompetitiveProduct__c, Price__c, DiscountPrice__c, Point__c 
                    FROM ComtitiveShopRetailDetails__r)
                FROM Shop_Retail_Detail__c
                WHERE 
                PromoterDailyReport__c =: reportId
                AND 
                    RecordType.DeveloperName = 'PromoterSaleData'];
    }
    /**
     * Name : getWeelResearchList
     * Author : Chiara
     * Purpose : 获取周报，允许编辑的情况下，即本人操作才额外获取周报信息，添加未存在的问卷调查，使用UserInfo.getUserId()无误
     * Date : 2022/01
     */
    public static List<Week_Research__c> getWeelResearchList(String shopId, Date reportDate) {
        return [SELECT 
                    Id,
                    IsActive__c,
                    (SELECT Id,Number__c,Question__c FROM Week_Question_Item__r  WHERE Status__c ='有效'  ORDER BY Number__c)
                FROM Week_Research__c
                WHERE 
                    Promoter__c =: UserInfo.getUserId()
                AND 
                    Shop__c =: shopId
                /*AND 
                    Start_Date__c <=: reportDate 
                AND 
                    End_Date__c >=: reportDate
                    */
                AND 
                    IsActive__c = TRUE];
    }
    //通过日期获取周反馈明细
    public static List<WeekResearchResponse__c> getWeekResearchResponseList(Date reportDate, String shopId) {
        return [SELECT 
                    Id,
                    Shop__c,
                    (SELECT Id,Week_Question_Item__c,WeekResearchActive__c,QuestionItemActive__c,Response__c,Question__c FROM WeekResearchResponseItems__r)
                FROM WeekResearchResponse__c
                WHERE
                    StartDate__c <=:reportDate
                AND
                    EndDate__c >=:reportDate
                AND 
                    OwnerId =: UserInfo.getUserId()
                AND 
                    Shop__c =: shopId
            ];
    }

    //获取周反馈
    public static List<WeekResearchResponseItem__c> getWeekResearchResponseList(String researchResponseId, Date reportDate) {
        return [SELECT Id,Week_Question_Item__c,WeekResearchActive__c,QuestionItemActive__c,Response__c,Question__c,Report_Date__c 
                FROM WeekResearchResponseItem__c
                WHERE 
                    WeekResearchResponse__c =: researchResponseId and Report_Date__c = :reportDate
            ];
    }

    public class ProductPrice{
        Integer Index;
        Boolean IsActive;
        Shop_Retail_Detail__c RetailDetail;
        List<Shop_Retail_Detail__c> ComtitiveShopRetailDetails;
    }

    public class ReturnData {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String failMessage;

        @AuraEnabled public Date thisDay;//今天日期
        @AuraEnabled public Date reportDate;//报告日期
        @AuraEnabled public Date createdDate;//创建日期
        @AuraEnabled public String ownerId;//所有人
        @AuraEnabled public String shopId;//门店
        @AuraEnabled public String productLine;//产品线
        @AuraEnabled public String existRecordId;//若为新建recordId为空时，判断是否存在该日期的日报
        

        @AuraEnabled public List<Retail_Number__c> retailSaleList;//零售
        @AuraEnabled public String retailSaleListError;

        @AuraEnabled public String productPriceListJson;//价格调查Json
        @AuraEnabled public List<ProductPrice> productPriceList;//价格调查
        @AuraEnabled public String productPriceListError;//价格调查
       // @AuraEnabled public List<Shop_Retail_Detail__c> retailDetailList;//销售
       // @AuraEnabled public String retailSaleRTId;
        //@AuraEnabled public String retailDetailListError;

        @AuraEnabled public Promoter_Attendance__c promoterItem;//考勤
        @AuraEnabled public String promoterItemError;

        @AuraEnabled public String researchResponseId;//周报Id
        @AuraEnabled public List<WeekResearchResponseItem__c> responseList;//调研反馈
        @AuraEnabled public String responseListError;

        @AuraEnabled public Integer dayOfWeek; //星期几
        @AuraEnabled public Boolean isAllowEdit;//是否七天以内，且当前用户是否为本人，且创建日期为今日

        @AuraEnabled public Boolean noPerformance;//在促销员，新增"当日実績なし"勾选项。勾选后不能“+”当日业绩。勾选后，保存时，需要生成一条业绩为0的数据
    }
}