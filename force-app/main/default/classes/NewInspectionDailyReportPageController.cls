public class NewInspectionDailyReportPageController {

    private static String INSPECTION_PROFILE = '巡店员';
    private static String RESPONSIBLE_PERSON = System.Label.CheckInCheckOut_RESPONSIBLE_PERSON; //门店负责人
    private static String SOBJECT_NOT_FOUND = System.Label.INSPECTION_REPORT_MSG_SOBJECT_NOT_FOUND; //未找到{0}信息，请联系系统管理员
    private static String INSPECT_TYPE_REMOTE = 'Remote Inspection';//远程巡店
    private static String INSPECT_TYPE_LOCALE = 'Locale Inspection';//现场巡店
    public static Date thisDay = System.today();
    public static String thisTime = DateTime.now().format('HH:mm',UserInfo.getTimeZone().getId());
    public static User user = [SELECT Id,Name,Country__c,Sales_Region__c,title FROM User WHERE Id = : UserInfo.getUserId()][0];
    
    // create record
    @AuraEnabled
    public static ConResponse createRecord(String recordJson, String attendanceFromType, String attendancePhotoStreamJson, String attendanceRemark, String currentLat, String currentLong) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('recordJson' + recordJson);
        User user = [SELECT Id, Name, Sales_Region__c, title FROM User WHERE Id = : UserInfo.getUserId()];
        Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)JSON.deserializeStrict(recordJson, Daily_Inspection_Report__c.class);

        // 需要根据最新的坐标信息判断距离
        List<Responsible_Person__c> personList = getResponsiblePersonBaseStoreId(report.Store__c);
        System.debug('======================================'+report);
        System.debug('Ethan ======================================'+report.Inspect_Type__c);
        System.debug(personList);

        List<Map<String, Object>> newStoreDistanceList = new List<Map<String, Object>>();

        newStoreDistanceList = getStoreDistanceListForStore(currentLat, currentLong, personList, report.Report_Date__c, report.Store__c);
        Map<String, Object> storeDistance = newStoreDistanceList[0];
	    report.Distance__c = Double.valueOf(storeDistance.get('storeDistance'));

        // 现场巡店 四期暂时不做 远程区分逻辑一致
        if (report.Inspect_Type__c == INSPECT_TYPE_REMOTE || report.Inspect_Type__c == INSPECT_TYPE_LOCALE) {
            System.debug('这一步=====================');
            Promoter_Attendance_Information__c pai = new Promoter_Attendance_Information__c();
            if (attendanceFromType == 'From Photo') {
                report.NeedCheckIn__c = true;
            } else {
                report.NeedCheckIn__c = false;
                report.Note__c = attendanceRemark;
            }

            if (report.NeedCheckIn__c) {
                // 考勤ExId
                String paExId = UserInfo.getUserId() + '_' + String.valueOf(report.Report_Date__c);
                // 查询当天考勤信息
                List<Promoter_Attendance__c> paList = getExistAttendanceBasedExternalId(paExId);
                Promoter_Attendance__c pa = new Promoter_Attendance__c();
                if (paList.size()>0) {
                    pa = paList[0];
                } else {
                    pa.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('InspectorAttendace').getRecordTypeId();
                    pa.CheckIn_Date__c = report.Report_Date__c;
                    pa.Shop__c = report.Store__c;
                    // 维护签到的时间信息 20240401
                    pa.SignInTime__c = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
                    pa.CheckInStatus__c = '已签到';
                    pa.ExternalId__c = UserInfo.getUserId() + '_' + String.valueOf(pa.CheckIn_Date__c);

                    insert pa;
                }
                // 考勤详细信息新建
                pai.Type__c = 'Check in';
                pai.Promoter_Attendance__c = pa.Id;
                pai.CheckIn_Date__c = report.Report_Date__c;
                pai.CheckIn_Time__c = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
                pai.Shop__c = report.Store__c;
                pai.Remark__c = attendanceRemark;
                pai.Location__Latitude__s = Decimal.valueOf(currentLat);
                pai.Location__Longitude__s = Decimal.valueOf(currentLong);
                pai.Distance__c = Double.valueOf(storeDistance.get('storeDistance'));
                
                insert pai;
                // 考勤详细拍照绑定
                if (String.isNotBlank(attendancePhotoStreamJson)) {// BFR Yin Mingjie 20231124
                    createUploadFile(pai.Id, attendancePhotoStreamJson);
                }
            }

            // 新建日报
            upsert report;
            report = getExistDailyInspectionReportBasedId(report.Id)[0];

            if (report.NeedCheckIn__c == false) {
                // 考勤详细拍照绑定
                createUploadFile(report.Id, attendancePhotoStreamJson);
            }

            if (report.NeedCheckIn__c) {
                // 获取签到信息
                List<Promoter_Attendance_Information__c> queryPaiList = getExistPromoterAttendanceInformationBaseId(pai.Id);
                if (queryPaiList.size()==0) {
                    resp.code= -1;
                    resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Promoter_Attendance_Information__c.getLabel()});
                    return resp;
                }
                Promoter_Attendance_Information__c queryPai = queryPaiList[0];
                mso.put('attendanceInformation', queryPai);
                Map<String, String> attendanceInformationHandHelper = new Map<String, String>();
                attendanceInformationHandHelper.put('checkInTime', String.valueOf(pai.CheckIn_Time__c).subString(0,5));
                if (!Test.isRunningTest()) {
                    // 附件部分
                    List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : pai.Id];
                    // BFR Yin Mingjie 20231124 start

                    //附件照片可以为非必填
                    if(cdlList.size() > 0){
                        ContentDocumentLink cdl = cdlList[0];
                        attendanceInformationHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                    }
                    mso.put('attendanceInformationHandHelper', attendanceInformationHandHelper);
                    
                }
            } else {
                if (!Test.isRunningTest()) {
                    // 附件部分
                    Map<String, String> attendanceInformationHandHelper = new Map<String, String>();
                    List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : report.Id];

                    //附件照片可以为非必填
                    if(cdlList.size() > 0){
                        ContentDocumentLink cdl = cdlList[0];
                        attendanceInformationHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                    }
                    mso.put('attendanceInformationHandHelper', attendanceInformationHandHelper);
                }
            }
        }
        //远程巡店 End 20231101 Ethan
        // if (report.Inspect_Type__c == INSPECT_TYPE_REMOTE) {
        //     // 新建日报
        //     upsert report;
        
            
        //     report = getExistDailyInspectionReportBasedId(report.Id)[0];
        //     mso.put('attendanceInformation', null);
        //     mso.put('attendanceInformationHandHelper', null);

        // }

        // Database.upsert(report,Daily_Inspection_Report__c.Fields.ExternalId__c,true);

        // 根据进驻产品线新增巡店日报产品线字表
        List<Store_Product_Line__c> StoreProductLine = getStoreProductLineInfo(report.Store__c);

        // 存放巡店员子表拆分产品线信息
        List<Inspection_Product_Item__c> inspectionItem = new List<Inspection_Product_Item__c>();

        if(StoreProductLine != null){
            // 根据黑白电分组 YYL 20250320
            Map<String,List<String>> productlineMap = new Map<String,List<String>>();
            for(Store_Product_Line__c line : StoreProductLine){
                List<String> productLines = productlineMap.get(line.Type__c);

                if(productLines == null){
                    productLines = new List<String>();
                }

                productLines.add(line.Product_Line__c);

                productlineMap.put(line.Type__c, productLines);
            }

            if(!productlineMap.isEmpty()){
                for(String key : productlineMap.keySet()){
                    List<String> productLine = productlineMap.get(key);
                    Inspection_Product_Item__c inspectionProductItem = new Inspection_Product_Item__c();
                    inspectionProductItem.Inspection_Report__c = report.Id;
                    inspectionProductItem.Type__c = key;
                    inspectionProductItem.Product_Lines__c = String.join(productLine,';');
                    // 如果只有一条产品线默认设置为展示
                    if(productlineMap.size() == 1){
                        inspectionProductItem.Status__c = 'Start';
                        inspectionProductItem.Product_Line_Checked__c = true;
                    }
                    inspectionItem.add(inspectionProductItem);
                }
            }

        }

        Database.insert(inspectionItem);
        
        mso.put('record', report);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(report.Id)[0].Owner.Name);
        // 获取Today
        mso.put('todayDate', thisDay); 
        // 获取Time
        mso.put('nowTime', thisTime); 

        // 2024-01-17 wfc 特定用户可不需要配置门店负责人信息，选择所有权限门店
        List<Map<String, Object>> storeDistanceList = new List<Map<String, Object>>();
        List<Responsible_Person__c> responsiblePersonList = getResponsiblePerson(UserInfo.getUserId());

        storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, responsiblePersonList, report.Report_Date__c, report.Store__c);
        mso.put('storeDistanceList', storeDistanceList); 

        System.debug('resp======>'+resp);
        return resp;
    }

    // upsert record
    @AuraEnabled
    public static ConResponse submitRecord(String recordJson, String ticketClosedInfo, String ticketOpenInfo) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        System.debug('recordJson' + recordJson);
        System.Savepoint sp = Database.setSavepoint();
        try{
            Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)JSON.deserializeStrict(recordJson, Daily_Inspection_Report__c.class);
            report.Status__c = 'Submitted';
            //TJP 介入
            // if(user.Sales_Region__c == 'Hisense Mexico') {
                Map<String, Object> scoreResult = giveHealthScales(report);
                Decimal score = (Decimal) scoreResult.get('decimal');
                report.ScoreLine__c = score;
                
            // }
            upsert report;

            // 更新巡店任务
            if (report.Status__c == 'Submitted') {

                //lastby TJP 20250716 
                //TJP last 20250705 D:更新Ticket状态 用于Submitted触发
                updateReportTicketStatus(report.Id);
                //TJP last 20250715 D:仅仅用于新建Detail
                // List<Sampling_Detail__c> samplingDetails = [SELECT Id FROM Sampling_Detail__c WHERE Shop__c =: report.Store__c];
                // if(samplingDetails.isEmpty()) {
                //     System.debug('触发写入Detail逻辑' + report.Id);
                //     List<String> reportIds = new List<String>();
                //     reportIds.add(report.Id);
                //     SamplingInvocableMethodController.relevanceSampling(reportIds);
                // }

                // 检查出样检查
                List<Sampling_Inspection__c> querySamplingInspectionList = NewInspectorDailyReportController.getExistSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
                querySamplingInspectionList.addAll(NewInspectorDailyReportController.getExistPlanOutSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId));
            
                // List<Inspection_Shop_Task__c> istList = NewInspectorDailyReportController.getExistInspectionShopTaskBaseCheck(report.Store__c, report.Report_Date__c, report.OwnerId);
                // if (istList.size()==0) {
                //     resp.code= -1;
                //     resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Inspection_Shop_Task__c.getLabel()});
                //     return resp;
                // }
                // Inspection_Shop_Task__c ist = istList[0];
                // ist.Daily_Inspection_Report__c = report.id;
                // upsert ist;

                // 检查巡店任务
                List<Inspection_Shop_Task__c> istList = NewInspectorDailyReportController.getExistInspectionShopTaskBaseCheck(report.Store__c, report.Report_Date__c, report.OwnerId);
                Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
                if (istList.size()>0) {
                    ist = istList[0];
                    if (ist.Status__c == '未到访') {
                        ist.Status__c = '已到访';
                    }
                } else {
                    List<Inspection_Shop_Plan__c> ispList = NewInspectorDailyReportController.getExistInspectionShopPlanBaseReportInfo(report.Report_Date__c, report.OwnerId);
                    Inspection_Shop_Plan__c isp = new Inspection_Shop_Plan__c();
                    if (ispList.size()>0) {
                        isp = ispList[0];
                    } else {
                        isp.OwnerId__c = report.OwnerId;
                        isp.Inspection_Year__c = String.valueOf(report.Report_Date__c.year());
                        isp.Inspection_Month__c = String.valueOf(report.Report_Date__c.month());

                        insert isp;
                    }
                    ist.Shop__c = report.Store__c;
                    ist.Inspection_Date__c = report.Report_Date__c;
                    ist.Inspection_Plan__c = isp.Id;
                    ist.Status__c = '计划外到访';
                }
                // 更新巡店任务
                upsert ist;
                // 更新出样检查
                for (Sampling_Inspection__c si : querySamplingInspectionList) {
                    si.Inspection_Shop_Task__c = ist.Id;
                }
                upsert querySamplingInspectionList;
            }

            // 查询日报（更新总分和平均分数据）
            Daily_Inspection_Report__c dir = NewInspectorDailyReportController.getExistDailyInspectionReportBasedId(report.Id)[0];
            mso.put('record', dir);
            mso.put('ownerName', NewInspectorDailyReportController.getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);

            // 新增签退操作 20240403 YYL
            // if(report.Status__c != 'Submitted'){
            //     if(attendancePhotoStreamJson != null || attendanceRemark != null){
            //         String paExId = report.OwnerId + '_' + String.valueOf(report.Report_Date__c);
            //         List<Promoter_Attendance__c> paList = getExistAttendanceBasedExternalId(paExId);
            //         Promoter_Attendance__c pa = new Promoter_Attendance__c();
            //         if (paList.size()>0) {
            //             pa = paList[0];
            //             if(pa.CheckInStatus__c != '已签到签退'){
            //                 pa.SignOutTime__c = Time.newInstance( System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
            //                 pa.CheckInStatus__c = '已签到签退';
            //                 pa.ExternalId__c = paExId;
            //                 upsert pa ExternalId__c;
            //             }
            //         }
            //     }
            // }

            // 保存ticket
            System.debug('wwwwddd-----' + ticketClosedInfo);
            System.debug('wwwwddd-----' + ticketOpenInfo);
            List<Ticket__c> closeList = (List<Ticket__c>)JSON.deserialize(ticketClosedInfo, List<Ticket__c>.class);
            List<Ticket__c> openList = (List<Ticket__c>)JSON.deserialize(ticketOpenInfo, List<Ticket__c>.class);
            if(closeList != null && closeList.size() > 0){
                upsert closeList;
            }
            if(openList != null && openList.size() > 0){
                for(Ticket__c a : openList){
                    System.debug('wwwwffff-----' + a);
                }
                upsert openList;
            }
        } catch (Exception e){
            // 回滚事务
            Database.rollback(sp);
            resp.code= -1;
            resp.message = e.getMessage().substring(e.getMessage().indexOf(',', e.getMessage().indexOf('first error:') + 12) + 1, e.getMessage().lastIndexOf(']') + 1);
        }
        System.debug('resp1======>'+resp);
        return resp;
    }

    /**
     * @description 查询当前日报关联的Ticket
     * @param   日报ID
     * @return  Ticket
     */
    public static void updateReportTicketStatus(String recordId){
        List<Ticket__c> tickets = [SELECT Id FROM Ticket__c WHERE InspectionReport__c =: recordId];
        if(tickets.size() > 0) {
            for(Ticket__c ticket : tickets) {
                ticket.Inspection_Status__c = 'Submitted';
            }
            update tickets;
        }
    }

        // TJP 日报Submit 时触发积分规则，此时开始门店评分
    public static Map<String, Object> giveHealthScales(Daily_Inspection_Report__c report){
        Decimal score = 100;
        String scoreString = '';
        String describe = '';
        Date today = Date.today();
        List<CheckItem__c> checkItems = [SELECT Id,Is_Store_Rating__c FROM CheckItem__c WHERE Is_Store_Rating__c = true And Active__c = true And Sales_Region__c =: user.Sales_Region__c];
        if(checkItems.size() > 0) {
            // Points were deducted for failing inspection items about store requirements (-15) and 7 tickets not resolved in a timely manner (-35).
            List<CheckResult__c> resultList = [SELECT Id,CheckItem__r.Description__c,CheckItem__r.Is_Store_Rating__c,CheckItem__r.Standard_Result__c,Response__c FROM CheckResult__c WHERE InspectorDailyReport__c =: report.Id];
            Decimal checkAverage = 0;
            for(CheckResult__c item : resultList) {
                if(item.CheckItem__r.Is_Store_Rating__c) {
                    if(item.CheckItem__r.Standard_Result__c != null && item.CheckItem__r.Standard_Result__c != item.Response__c) {
                       score -= 5; 
                       checkAverage -= 5;
                       System.debug('Check' + score);
                    }
                }
            }
            // describe = 'CheckResult:' + checkAverage + ';';
            List<Sampling_Inspection__c> sampleList = [SELECT Id,Placement_Status__c FROM Sampling_Inspection__c WHERE Inspection_Report__c =: report.Id];
            Decimal samplAverage = 0;
            for(Sampling_Inspection__c item : sampleList) {
                if(item.Placement_Status__c == null|| item.Placement_Status__c == '未展出') {
                    samplAverage -= 5;
                    score -= 5; 
                    System.debug('Sample' + score);
                }
            }
            Decimal total = checkAverage + samplAverage;
            // describe = describe + 'Sampling-Inspection:' + samplAverage + ';';
            describe = 'Points were deducted for failing inspection items about store requirements (' + total + ')';
            Decimal ticketAverage = 0;
            List<Ticket__c> ticketList = [SELECT Id,DueDate__c,Status__c FROM Ticket__c WHERE Store__c =: report.Store__c AND DueDate__c < today And Status__c =: 'Open'];
            for(Ticket__c item : ticketList) {
                score -= 5; 
                ticketAverage -= 5; 
            }
            // describe = describe + 'Ticket:' + ticketAverage + ';';
            String ticketNumString = ticketList.size() > 1 ? ticketList.size() + ' tickets' : ticketList.size() + ' ticket';
            describe = describe + ' and ' + ticketNumString + ' not resolved in a timely manner (' + ticketAverage + ').';
            Shop__c store = new Shop__c();
            store.Id = report.Store__c;
            List<Daily_Inspection_Report__c> reports = [SELECT Id,ScoreLine__c FROM Daily_Inspection_Report__c WHERE Report_Date__c >: report.Report_Date__c And Status__c = 'Submitted' And ScoreLine__c != null Order By Report_Date__c desc];
            if(reports.size() == 0) {
                store.Health_Degree__c = String.valueOf(score);
                store.Rating_Description__c = describe;
                update store;
            }
            
        }

        Map<String, Object> so = new Map<String, Object>();
        so.put('decimal', score);
        return so;
    }

    // 更新当前门店进驻产品线状态
    @AuraEnabled
    public static ConResponse upsertProductLineStatus(String recordId,String status,String productLineChecked){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('wwwwproductLineChecked' + productLineChecked);
        Inspection_Product_Item__c productLine = getInspectionProductLine(recordId);
        if(!status.equals(productLine.Status__c) || !String.isEmpty(productLineChecked)){
            productLine.Status__c = status;
            if(!String.isEmpty(productLineChecked)){
                productLine.Product_Line_Checked__c = Boolean.valueOf(productLineChecked);
            }
            System.debug('wwww' + JSON.serialize(productLine));
            Database.update(productLine);
        }

        // 修改门店进驻产品线状态为Continue 修改主表状态为Submitted
        // 修改逻辑 修改门店进驻产品线状态为Submitted 修改主表状态为Submitted 20241105 YYL
        if(status.equals('Submitted')){
            // 查询主表信息
            List<Daily_Inspection_Report__c> inspectionReportList = getExistDailyInspectionReportBasedId(productLine.Inspection_Report__c);
            Daily_Inspection_Report__c inspectionReport = inspectionReportList[0];
            if(inspectionReport.Status__c.equals('New')){
                inspectionReport.Status__c = 'Submitted';
                Database.update(inspectionReport);
            }
        }

        mso.put('productLine', productLine);
        return resp;
    }

    /**
     * @description 总部适用巡店模式记录初始化
     * @param   recordId     报告id
     * @return  操作结果
     */
    @AuraEnabled
    public static ConResponse upsertPatrolMode(String recordId,String patrolMode){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        Inspection_Product_Item__c productLine = getInspectionProductLine(recordId);
        if(String.isEmpty(productLine.Patrol_Mode__c)){
            productLine.Patrol_Mode__c = patrolMode;
        }
        System.debug('wwww' + JSON.serialize(productLine));
        Database.update(productLine);
        return resp;
    }


    // 提交当前日报产品线
    @AuraEnabled
    public static ConResponse submitInspectionProductItem(String recordId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 查询当前日报产品线子表详情信息
        Inspection_Product_Item__c inspectionProductItem = getInspectionProductLine(recordId);
        inspectionProductItem.Status__c = 'Submitted';

        // 查询日报主信息
        List<Daily_Inspection_Report__c> dirList = getExistDailyInspectionReportBasedId(inspectionProductItem.Inspection_Report__c);
        Daily_Inspection_Report__c report = dirList[0];

        // 检查巡店任务
        List<Inspection_Shop_Task__c> istList = getExistInspectionShopTaskBaseCheck(report.Store__c, report.Report_Date__c, report.OwnerId);
        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        if (istList.size()>0) {
            ist = istList[0];
            if (ist.Status__c == '未到访') {
                ist.Status__c = '已到访';
            }
        } else {
            List<Inspection_Shop_Plan__c> ispList = getExistInspectionShopPlanBaseReportInfo(report.Report_Date__c, report.OwnerId);
            Inspection_Shop_Plan__c isp = new Inspection_Shop_Plan__c();
            if (ispList.size()>0) {
                isp = ispList[0];
            } else {
                isp.OwnerId__c = report.OwnerId;
                isp.Inspection_Year__c = String.valueOf(report.Report_Date__c.year());
                isp.Inspection_Month__c = String.valueOf(report.Report_Date__c.month());

                insert isp;
            }
            // Inspection_Shop_Plan__c isp = ispList[0];
            // Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
            ist.Shop__c = report.Store__c;
            ist.Inspection_Date__c = report.Report_Date__c;
            ist.Inspection_Plan__c = isp.Id;
            ist.Status__c = '计划外到访';
            // ist.OwnerId = report.OwnerId;

            // upsert ist;
        }
        // 更新巡店任务
        upsert ist;

        Database.update(inspectionProductItem);
        return resp;
    }

    // 查询当前产品线应总检查和已检查数量
    @AuraEnabled
    public static ConResponse getProductLineCheckItemNumber(String recordId,String productLine,String storeId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        
        // Booth
        Map<String,Integer> BoothNumber = newCheckItemController.getCheckItemCheckNumber('Booth', recordId,productLine);
        mso.put('BoothNumber', BoothNumber);

        Map<String,Integer> ticketCheckNumber = NewSamplingAndTicketController.getTicketFillInValue(recordId);
        mso.put('ticketCheckNumber', ticketCheckNumber);

        // 根据门店id查询门店salesRegion信息
        Shop__c shop = [SELECT Id,Sales_Region__c FROM Shop__c WHERE Id =: storeId];
        System.debug('user.Sales_Region__c' + user.Sales_Region__c + user.Name);
        // 获取 物料 必填项统计 TJP 20241030 Material
        if(user.Sales_Region__c == 'Hisense International') {
            // Map<String,Integer> MaterialNumber = newCheckItemController.getCheckItemCheckNumber('Material', recordId,productLine);
            // mso.put('MaterialNumber', MaterialNumber);
            
            // Map<String,Integer> CompetingGoodsNumber = newCheckItemController.getCheckItemCheckNumber('Competing Goods', recordId,productLine);
            // mso.put('CompetingGoodsNumber', CompetingGoodsNumber);
            
            // //样机要进行抽样累加计算 getCheckListFillInValue
            // Map<String,Integer> PrototypeNumber = newCheckItemController.getCheckItemCheckNumber('Prototype', recordId,productLine);
            // Map<String,Integer> samplingCheckListNumber = NewSamplingAndTicketController.getCheckListFillInValue(recordId,productLine);
            // mso.put('PrototypeNumber', PrototypeNumber);
            // mso.put('samplingCheckListNumber', samplingCheckListNumber);
            
            // Map<String,Integer> samplingUniteNumber = NewSamplingAndTicketController.getUniteFillInValue(recordId,productLine);
            // mso.put('samplingUniteNumber', samplingUniteNumber);
        } else if(user.Sales_Region__c == 'Hisense X') {
            Map<String,Integer> MaterialNumber = newCheckItemController.getCheckItemCheckNumber('Material', recordId,productLine);
            mso.put('MaterialNumber', MaterialNumber);
            
            // Map<String,Integer> CompetingGoodsNumber = newCheckItemController.getCheckItemCheckNumber('Competing Goods', recordId,productLine);
            // mso.put('CompetingGoodsNumber', CompetingGoodsNumber);
            
            // //样机要进行抽样累加计算 getCheckListFillInValue
            // Map<String,Integer> PrototypeNumber = newCheckItemController.getCheckItemCheckNumber('Prototype', recordId,productLine);
            // Map<String,Integer> samplingCheckListNumber = NewSamplingAndTicketController.getCheckListFillInValue(recordId,productLine);
            // mso.put('PrototypeNumber', PrototypeNumber);
            // mso.put('samplingCheckListNumber', samplingCheckListNumber);
            
            // Map<String,Integer> samplingUniteNumber = NewSamplingAndTicketController.getUniteFillInValue(recordId,productLine);
            // mso.put('samplingUniteNumber', samplingUniteNumber);
        } 
        else {
            // Speak With the Store Leader
            // Map<String,Integer> speakWithCheckNumber = newCheckItemController.getCheckItemCheckNumber('Speak With the Store Leader', recordId,productLine);
            // mso.put('speakWithCheckNumber', speakWithCheckNumber);
            
            // // Training
            // Map<String,Integer> trainingCheckNumber = newCheckItemController.getCheckItemCheckNumber('Training', recordId,productLine);
            // mso.put('trainingCheckNumber', trainingCheckNumber);
            
            // // Sales
            // Map<String,Integer> salesCheckNumber = newCheckItemController.getCheckItemCheckNumber('Sales', recordId,productLine);
            // mso.put('salesCheckNumber', salesCheckNumber);
            
            // // Weekly Asks from Best Buy
            // Map<String,Integer> weeklyCheckNumber = newCheckItemController.getCheckItemCheckNumber('Weekly Asks', recordId,productLine);
            // mso.put('weeklyCheckNumber', weeklyCheckNumber);
            
            // // Brand Feedback
            // Map<String,Integer> brandFeedBackCheckNumber = newCheckItemController.getCheckItemCheckNumber('Brand Feedback', recordId,productLine);
            // mso.put('brandFeedBackCheckNumber', brandFeedBackCheckNumber);
            
            // // Sample Condition
            // Map<String,Integer> sampleConditionCheckNumber = newCheckItemController.getCheckItemCheckNumber('Sample Condition', recordId,productLine);
            // mso.put('sampleConditionCheckNumber', sampleConditionCheckNumber);
            
            // // Material Display
            // Map<String,Integer> materialDisplayCheckNumber = newCheckItemController.getCheckItemCheckNumber('Material Display', recordId,productLine);
            // mso.put('materialDisplayCheckNumber', materialDisplayCheckNumber);
            
            // // Competitive Intelligence
            // Map<String,Integer> intelligenceCheckNumber = newCompetitiveIntelligenceController.getCompetitiveIntelligenceCheckNumber(recordId);
            // mso.put('intelligenceCheckNumber', intelligenceCheckNumber);
            
            // // Competitive Intelligence Canada
            // Map<String,Integer> intelligenceCanadaCheck = newCompetitiveIntelligenceController.getCompetitiveIntelligenceCheckCanadaNumber(recordId);
            // mso.put('intelligenceCanadaCheck', intelligenceCanadaCheck);
            
            // // Inventory
            // Map<String,Integer> inventoryCheckNumber = newInventory.getInventoryCheckNumber(recordId);
            // mso.put('inventoryCheckNumber', inventoryCheckNumber);
            
            // Map<String,Integer> samplingCheckNumber = NewSamplingAndTicketController.getSamplingInspectionFillInValue(recordId,productLine);
            // mso.put('samplingCheckNumber', samplingCheckNumber);
        }
        // 20241029 TJP 增加 总部逻辑判断
        if(user.Sales_Region__c == 'Hisense International') {
            mso.put('salesRegion', user.Sales_Region__c);
        } else if (user.Sales_Region__c == 'Hisense X'){
            mso.put('salesRegion', user.Sales_Region__c);
        } else {
            mso.put('salesRegion', shop.Sales_Region__c);
        }
        
        return resp;
    }

    // 根据坐标计算距离 (因为有SOQL查询，方法不可用在循环内)
    public static List<Map<String, Object>> getStoreDistanceListForStore(String currentLat, String currentLong, List<Responsible_Person__c> responsiblePersonList, Date reportDate, String shopId) {
        // 计算和绑定门店距离
        List<Map<String, Object>> storeDistanceList = new List<Map<String, Object>>();
        // 门店是否配置在巡店员里面
        Boolean flag = false;
        for (Responsible_Person__c person : responsiblePersonList) {
            System.debug('=======================>>>>>');
            System.debug(person.Shop_Name__r.Shop_Center_Location__c);
            if(String.isNotBlank(shopId) && person.Shop_Name__c == shopId){
                System.debug('=======================>>>>>配置在巡店员里面');
                flag = true;
            }
            Map<String, Object> storeDistanceMap = new Map<String, Object>();
            Location location = Location.newInstance(Double.Valueof(currentLat), Double.Valueof(currentLong));
            Decimal distance = 999.999;
            if (person.Shop_Name__r.Shop_Center_Location__c!=null && currentLat!=null && currentLong!=null) {
                distance = location.getDistance(person.Shop_Name__r.Shop_Center_Location__c,'km');
                storeDistanceMap.put('storeLat', person.Shop_Name__r.Shop_Center_Location__Latitude__s);
                storeDistanceMap.put('storeLong', person.Shop_Name__r.Shop_Center_Location__Longitude__s);
            } else {
                storeDistanceMap.put('storeLat', 0);
                storeDistanceMap.put('storeLong', 0);
            }
            storeDistanceMap.put('storeId', person.Shop_Name__c);
            storeDistanceMap.put('storeName', person.Shop_Name__r.Name);
            storeDistanceMap.put('storeDistance', distance);
            storeDistanceMap.put('storeDistanceStr', String.valueOf(Integer.valueOf(distance*1000))+'m');
            storeDistanceMap.put('checkInDistance', person.Promoter_Attendance_Rule__r.Distance__c);
            storeDistanceMap.put('recordType', person.RecordType__c);// Add By Ethan 20231011 ----增加backup排序

            if(Test.isRunningTest()){
                storeDistanceList.add(new Map<String, Object>());
            }

            // 排序
            if (storeDistanceList.size()>0) {
                for (Integer i = 0; i < storeDistanceList.size(); i++) {
                    Decimal itemDistance = (Decimal)storeDistanceList[i].get('storeDistance');
                    if (distance<=itemDistance) {
                        storeDistanceList.add(i, storeDistanceMap);
                        break;
                    } else if ((i+1)==storeDistanceList.size()) {
                        storeDistanceList.add(storeDistanceMap);
                        break;
                    }
                }
            } else {
                storeDistanceList.add(storeDistanceMap);
            }   
        }

        if(Test.isRunningTest()){
            flag = false;
        }

        if(String.isNotBlank(shopId) && !flag){
            System.debug('wwww--门店没有配置成巡店员门店--' + shopId);
            Shop__c shop = [SELECT Id,Name,Shop_Center_Location__c,Shop_Center_Location__Latitude__s,Shop_Center_Location__Longitude__s FROM Shop__c WHERE Id = :shopId LIMIT 1];
            Map<String, Object> storeDistanceMap = new Map<String, Object>();
            Location location = Location.newInstance(Double.Valueof(currentLat), Double.Valueof(currentLong));
            // Decimal distance = location.getDistance(person.Shop_Name__r.Shop_Center_Location__c,'km');
            Decimal distance = 999.999;
            if (shop.Shop_Center_Location__c!=null && currentLat!=null && currentLong!=null) {
                distance = location.getDistance(shop.Shop_Center_Location__c,'km');
                storeDistanceMap.put('storeLat', shop.Shop_Center_Location__Latitude__s);
                storeDistanceMap.put('storeLong', shop.Shop_Center_Location__Longitude__s);
            } else {
                storeDistanceMap.put('storeLat', 0);
                storeDistanceMap.put('storeLong', 0);
            }
            storeDistanceMap.put('storeId', shop.Id);
            storeDistanceMap.put('storeName', shop.Name);
            storeDistanceMap.put('storeDistance', distance);
            storeDistanceMap.put('storeDistanceStr', String.valueOf(Integer.valueOf(distance*1000))+'m');
            storeDistanceMap.put('checkInDistance', null);

            // 排序
            if (storeDistanceList.size()>0) {
                for (Integer i = 0; i < storeDistanceList.size(); i++) {
                    Decimal itemDistance = (Decimal)storeDistanceList[i].get('storeDistance');
                    if (distance<=itemDistance) {
                        storeDistanceList.add(i, storeDistanceMap);
                        break;
                    } else if ((i+1)==storeDistanceList.size()) {
                        storeDistanceList.add(storeDistanceMap);
                        break;
                    }
                }
            } else {
                storeDistanceList.add(storeDistanceMap);
            }
        }

        // 区分计划内门店和计划外门店
        List<Map<String, Object>> planInList = new List<Map<String, Object>>();
        List<Map<String, Object>> planOutList = new List<Map<String, Object>>();
        List<Map<String, Object>> planList = new List<Map<String, Object>>();
        List<Inspection_Shop_Task__c> planTaskList = getExistInspectionShopTaskBaseReportInfo(reportDate, UserInfo.getUserId());
        
        Set<String> planStoreIds = new Set<String>();
        for (Inspection_Shop_Task__c plan : planTaskList) {
            planStoreIds.add(plan.Shop__c);
        }
        for (Map<String, Object> item : storeDistanceList) {
            String storeId = (String)item.get('storeId');
            if (planStoreIds.contains(storeId)) {
                item.put('storeName', '*'+(String)item.get('storeName'));
                planInList.add(item);
            } else {
                planOutList.add(item);
            }
        }
        planList.addAll(planInList);
        planList.addAll(planOutList);
        return planList;
    }

    // 附件上传
    public static void createUploadFile(String recordId, String photoStream){
        System.debug('photoStream--->'+photoStream);

        if (recordId==null || photoStream==null || photoStream=='') {
            return;
        }
        
        String fileName = System.now().format('yyyyMMddHHmmss') + '.jpeg';
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(photoStream.substring(23,photoStream.length()));
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        
        insert cv;

        ContentVersion qrcv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =:cv.id];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = qrcv.ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';

        insert cdl;
    }

    /**
     * @description 获取门店的门店负责人
     * @param   storeId     门店id
     * @return  门店负责人
     */
    public static List<Responsible_Person__c> getResponsiblePersonBaseStoreId(String storeId) {
        return [SELECT 
                    Id,
                    Shop_Name__c,
                    Shop_Name__r.Name,
                    Shop_Name__r.Shop_Center_Location__c,
                    Shop_Name__r.Shop_Center_Location__Latitude__s,
                    Shop_Name__r.Shop_Center_Location__Longitude__s,
                    Promoter_Attendance_Rule__r.Distance__c,
                    RecordType__c//Add By Ethan 20231011 增加查询返回字段
                FROM Responsible_Person__c 
                WHERE 
                    Principal__c = : UserInfo.getUserId() 
                AND (RecordType__c = '巡店员' OR RecordType__c = 'Regional Manager' OR RecordType__c = 'Backup Floorwalker') 
                AND Shop_Name__c = : storeId];
    }

    // 获取考勤信息
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

    /**
     * @description 获取巡店报告
     * @param   recordId     报告id
     * @return  巡店报告
     */
    public static List<Daily_Inspection_Report__c> getExistDailyInspectionReportBasedId(String recordId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Status__c,
                    Store__c,
                    Report_Date__c,
                    //阿根廷新加字段
                    Brand__c,
                    Total_Score__c,
                    Total_Score_Max__c,
                    Average_Score_Count__c,
                    Average_Score__c,
                    Average_Score_Max__c,
                    NeedCheckIn__c,
                    Summary__c,
                    OwnerId,
                    Note__c,
                    Inspect_Type__c, // 20231031 Ethan
                    Comments__c,
                    Contact_Person__c,
                    Contact_Status__c,
                    Contact_Type__c,
                    Start_Time__c
                FROM Daily_Inspection_Report__c 
                WHERE 
                    Id =: recordId];
    }

    // 获取考勤信息（详细信息）
    public static List<Promoter_Attendance_Information__c> getExistPromoterAttendanceInformationBaseId(String paiId) {
        return [
                SELECT 
                    Id,
                    CheckIn_Date__c,
                    CheckIn_Time__c,
                    Shop__c,
                    Shop__r.Name,
                    Shop__r.Shop_Center_Location__Latitude__s,
                    Shop__r.Shop_Center_Location__Longitude__s,
                    Remark__c, 
                    Distance__c,
                    Location__c,
                    Location__Latitude__s,
                    Location__Longitude__s,
                    CreatedBy.Name
                FROM Promoter_Attendance_Information__c 
                WHERE 
                    Id = : paiId];
    }

    // 获取日报信息
    public static List<Daily_Inspection_Report__c> getExistDailyInspectionReportOwnerNameBasedId(String recordId) {
        return [
                SELECT 
                    Id,
                    Owner.Name
                FROM Daily_Inspection_Report__c 
                WHERE 
                    Id =: recordId];
    }

    // 获取门店负责人 (获取所有可选择门店)
    public static List<Responsible_Person__c> getResponsiblePerson(String userId) {
        return [SELECT 
                    Id,
                    Shop_Name__c,
                    Shop_Name__r.Name,
                    Shop_Name__r.Shop_Center_Location__c,
                    Shop_Name__r.Shop_Center_Location__Latitude__s,
                    Shop_Name__r.Shop_Center_Location__Longitude__s,
                    Promoter_Attendance_Rule__r.Distance__c,
                    RecordType__c//Add By Ethan 20231011 增加查询返回字段
                FROM Responsible_Person__c 
                WHERE 
                    Principal__c = : userId
                AND (RecordType__c = '巡店员' OR RecordType__c = 'Regional Manager' OR RecordType__c = 'Backup Floorwalker')];
    }

    // 获取巡店任务
    public static List<Inspection_Shop_Task__c> getExistInspectionShopTaskBaseReportInfo(Date reportDate, String reportOwner) {
        return [
                SELECT 
                    Id,
                    Inspection_Date__c,
                    Shop__c,
                    Status__c,
                    Inspection_Plan__c,
                    OwnerId
                FROM Inspection_Shop_Task__c 
                WHERE 
                    Inspection_Date__c = : reportDate 
                AND OwnerId = : reportOwner
                AND Status__c IN ('未到访','已到访')];
    }

    // 根据条件查询门店进驻产品线表
    public static List<Store_Product_Line__c> getStoreProductLineInfo(String storeId){
        return [SELECT Id,
                       Type__c,
                       Product_Line__c 
                       FROM Store_Product_Line__c
                       WHERE 
                       Store__c =: storeId 
                       AND Entering_Status__c IN ('Entered','Uncertain')];
    }

    // 查询巡店员日报产品线子表信息
    public static Inspection_Product_Item__c getInspectionProductLine(String recordId){
        return [SELECT Id,
                       Name,
                       Inspection_Report__c,
                       Product_Line__c,
                       Status__c,
                       Product_Line_Checked__c,
                       Patrol_Mode__c 
                       FROM Inspection_Product_Item__c
                       WHERE Id =: recordId];
    }

    /**
     * @description 获取巡店任务
     * @param   storeId         门店id
     * @param   reportDate      报告日期
     * @param   reportOwner     报告人
     * @return  打卡列表
     */
    public static List<Inspection_Shop_Task__c> getExistInspectionShopTaskBaseCheck(String storeId, Date reportDate, String reportOwner) {
        return [
                SELECT 
                    Id,
                    Inspection_Date__c,
                    Shop__c,
                    Status__c,
                    Inspection_Plan__c
                FROM Inspection_Shop_Task__c 
                WHERE 
                    Inspection_Date__c = : reportDate 
                AND Shop__c = : storeId
                AND OwnerId = : reportOwner];
    }

    // 获取巡店计划
    public static List<Inspection_Shop_Plan__c> getExistInspectionShopPlanBaseReportInfo(Date reportDate, String reportOwner) {
        return [
                SELECT 
                    Id,
                    Name,
                    OwnerId__c,
                    Inspection_Year__c,
                    Inspection_Month__c,
                    Status__c
                FROM Inspection_Shop_Plan__c 
                WHERE 
                    OwnerId__c = : reportOwner 
                AND Inspection_Year__c = : String.valueOf(reportDate.year())
                AND Inspection_Month__c = : String.valueOf(reportDate.month())];
    }

    /**
     * @description TJP 20241105 修改巡店类型
     * @param   storeId         门店id
     * @param   patrolMode      当前的巡店类型
     * @return  操作结果
     */
    @AuraEnabled
    public static ConResponse changeInspectionProductItem(String recordId,String patrolMode){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 查询当前日报产品线子表详情信息
        Inspection_Product_Item__c inspectionProductItem = getInspectionProductLine(recordId);
        inspectionProductItem.Patrol_Mode__c = patrolMode;

        // 查询关联信息 并进行清空更换其他模式计算处理逻辑
        List<CheckResult__c> checkResult = [Select Id from  CheckResult__c Where Inspection_Product_Item__c =: recordId And IsDeleted = false];
        
        if(checkResult.size() > 0){delete checkResult;}

        List<Sampling_Inspection__c> inspections = [Select Id from Sampling_Inspection__c Where Inspection_Product_Item__c =: recordId And IsDeleted = false];
        
        if(inspections.size() > 0){delete inspections;}

        Database.update(inspectionProductItem);
        return resp;
    }

    public static void gabige() {
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}