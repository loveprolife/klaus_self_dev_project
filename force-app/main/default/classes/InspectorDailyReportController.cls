/**********************************************************************
* 名称: InspectorDailyReportController
* 功能: 
* 巡店日报控制类
* Author: Gerry
* Create Date: 2022-01-04
*************************************************************************/
public without sharing class InspectorDailyReportController {

	@AuraEnabled
	public static OutPut initData(String reportId) {
        try {
            if (String.isBlank(reportId)) {
                OutPut out = new OutPut();
                out = getNewCreateData(System.today());
                out.owner = System.UserInfo.getName();  
                out.dateToday = String.valueOf(System.today());
                out.dateTodayStart = String.valueOf(System.today().addDays(-Integer.valueOf(Label.Fill_Day)));// wfc label设置天数

                //获取最后一次结束里程
                // List<Mileage__c> mileageList = [SELECT End__c 
                //                             FROM Mileage__c 
                //                             WHERE Mileage_OwnerId__c = :System.UserInfo.getUserId() 
                //                             AND Report__r.Report_Date__c < :System.today()  
                //                             ORDER BY Report__r.Report_Date__c DESC Limit 1];
                // if (!mileageList.isEmpty()) {
                //     Mileage__c mileage = new Mileage__c();
                //     mileage.Start__c = mileageList[0].End__c;
                //     out.mileage = mileage;
                // }
                return out;
            }else{
                return getEditData(reportId);   
            }    
        }
        catch (Exception e) {
            OutPut out = new OutPut();
            out.isSucess = false;
            out.errorMsg = System.Label.Error+e.getMessage()+e.getLineNumber();
            return out;    
        }
	}

    @AuraEnabled
    public static OutPut saveAttachment(String contentDocumentId,String contentVersionId){
        SavePoint sp = Database.setSavepoint();
        try{
            OutPut out = new OutPut();
            out.isSucess = true;
            ContentDocument cd = [SELECT Id,ContentSize,FileType,Title FROM ContentDocument WHERE Id = :contentDocumentId];
            ContentDistribution cdl = new ContentDistribution();
            cdl.ContentVersionId = contentVersionId;
            cdl.Name = 'PublicShare';
            cdl.PreferencesAllowViewInBrowser= true;
            cdl.PreferencesLinkLatestVersion=true;
            cdl.PreferencesNotifyOnVisit=false;
            cdl.PreferencesPasswordRequired=false;
            cdl.PreferencesAllowOriginalDownload= true;
            cdl.PreferencesNotifyRndtnComplete = false;
            insert cdl;
            out.imageUrl = [SELECT DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE Id = :cdl.Id LIMIT 1].ContentDownloadUrl;
            out.viewImageUrl = [SELECT DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE Id = :cdl.Id LIMIT 1].DistributionPublicUrl; 
            //KB
            if (cd.ContentSize > 30000000) {
                out.isSucess = false;
                out.errorMsg = System.Label.IamgeLimit;
                DELETE cd;
                return out;
            }
            return out;
        }catch(Exception e){
            Database.rollback(sp);
            OutPut out = new OutPut();
            out.isSucess = false;
            out.errorMsg = System.Label.Error+e.getMessage()+e.getLineNumber();
            return out;   
        }
    }

    @AuraEnabled
    public static OutPut validationData(
        Daily_Inspection_Report__c dailyInspectionReport, 
        List<Store> stores,
        Mileage__c mileage,
        Promoter_Attendance__c supplementary
    ) {
        try {
            OutPut out = new OutPut();
            out.isSucess = true;
            out.isShowAddEvaluation = true;
            out.saveErrorMsgList = new List<String>();
            Set<String> errorMsgSet = new Set<String>();
            system.debug(supplementary.Id);
            //如果没有考勤信息
            // if (String.isBlank(supplementary.Id)) {
            //     if (supplementary.AddCheckSignInTime__c==null || String.isBlank(supplementary.AddCheckInReason__c) || String.isBlank(supplementary.Add_Check_Shop__c)) {
            //         out.isShowAddEvaluation = false;  
            //         errorMsgSet.add(System.Label.HaveSignIn);        
            //     } 
            // }else{
            //     System.debug('supplementary数据:'+supplementary);
            //     if (supplementary.CheckInStatus__c == '已签退' || supplementary.CheckInStatus__c=='未签到') {
            //         if (supplementary.AddCheckSignInTime__c==null || String.isBlank(supplementary.AddCheckInReason__c) || String.isBlank(supplementary.Add_Check_Shop__c)) {
            //             out.isShowAddEvaluation = false;  
            //             errorMsgSet.add(System.Label.HaveSignIn);   
            //         } 
            //     }else{
            //         if (
            //             !((supplementary.AddCheckSignInTime__c==null && String.isBlank(supplementary.AddCheckInReason__c) && String.isBlank(supplementary.Add_Check_Shop__c))
            //             || (supplementary.AddCheckSignInTime__c!=null && String.isNotBlank(supplementary.AddCheckInReason__c) && String.isNotBlank(supplementary.Add_Check_Shop__c)))
            //         ) {
            //             out.isShowAddEvaluation = false;
            //             errorMsgSet.add(System.Label.FlexibleTicket);    
            //         }    
            //     }
            // }



            //日报信息是否全部填写
            if (String.isBlank(dailyInspectionReport.Report_Detail__c)) {
                out.isShowAddEvaluation = false;  
                errorMsgSet.add(System.Label.SummaryFieldsRequired);  
            }

            //里程是否全部填写
            if (mileage.Start__c==null || mileage.End__c==null) {
                out.isShowAddEvaluation = false;  
                errorMsgSet.add(System.Label.MileageNotification);        
            }

            for (Store st : stores) {
                if (st.taskStatus) {
                    continue;    
                }
                // if (String.isBlank(st.inspectionStatus)  || String.isBlank(st.shopReport)) {
                //     out.isShowAddEvaluation = false;  
                //     errorMsgSet.add('巡店日报明细中\''+st.storeLabel+'\'模块中有必填字段未填写。');        
                // }

                //出样检查
                for (SamplingInspectionData sd  : st.samplingInspectionDataList) {
                    if (String.isBlank(sd.samplingInspection.Placement_Status__c) || String.isBlank(sd.samplingInspection.Product__c)) {
                        out.isShowAddEvaluation = false;  
                        errorMsgSet.add(System.Label.ReportDetail+'\''+st.storeLabel+'\''+System.Label.Module+','+System.Label.SamplingInspectionRequired); 
                        break;         
                    }      
                }

                //定期访问是否填写
                if (String.isBlank(st.productCatalogConfirm) || String.isBlank(st.storeMaintain)) {
                    out.isShowAddEvaluation = false;  
                    errorMsgSet.add(System.Label.ReportDetail+'\''+st.storeLabel+'\''+System.Label.Module+','+System.Label.RegularVisitRequired); 
                }
            

                //竞品调查
                // for (ShopCompetitiveProductData cpd  : st.shopCompetitiveProductDataList) {
                //     if (cpd.shopCompetitiveProduct.Tag_Price__c==null) {
                //         out.isShowAddEvaluation = false;  
                //         errorMsgSet.add('巡店日报明细中\''+st.storeLabel+'\'模块\'竞品调查\'有必填字段未填写。');  
                //         break;        
                //     }      
                // }  
            }
            out.saveErrorMsgList.addAll(errorMsgSet);
            return out;
        }
        catch (Exception e) {
            OutPut out = new OutPut();
            out.isSucess = false;
            out.errorMsg = System.Label.Error+e.getMessage()+e.getLineNumber();
            return out;        
        }
    }

	@AuraEnabled
    public static OutPut getNewCreateData(Date dateSelect) {
        System.debug(LoggingLevel.INFO, '*** dateSelect: ' + dateSelect);
        try {
            List<Daily_Inspection_Report__c> reportList = [SELECT Name 
                                                           FROM Daily_Inspection_Report__c 
                                                           WHERE OwnerId= :System.UserInfo.getUserId() 
                                                           AND Report_Date__c = :dateSelect];
            if (!reportList.isEmpty()) {
                return getEditData(reportList[0].Id);
            }

            OutPut out = new OutPut();
            if (dateSelect.daysBetween(System.today()) > Integer.valueOf(Label.Fill_Day)) {// wfc 补签天数修改
                out.isSucess = true;
                out.isCanNotCreate = true;
                out.errorMsg = System.Label.SevenDays;
                return out;
            }
            if (dateSelect > System.today()) {
                out.isSucess = true;
                out.isCanNotCreate = true;
                out.errorMsg = System.Label.BeforeToday;
                return out;
            }
            //考勤信息
            List<Promoter_Attendance__c> promoterAttendanceList = [SELECT ApprovalStatus__c,
                                                                          SignInTime__c,
                                                                          SignOutTime__c,
                                                                          Shop__c,
                                                                          CheckInStatus__c 
                                                                    FROM Promoter_Attendance__c 
                                                                    WHERE CheckIn_Date__c = :dateSelect 
                                                                    AND OwnerId = :System.UserInfo.getUserId() 
                                                                    AND RecordType.DeveloperName = 'InspectorAttendace' 
                                                                    LIMIT 1];
            if (!promoterAttendanceList.isEmpty()) {
                out.supplementary = promoterAttendanceList[0]; 
                out.signInTime = String.valueOf(out.supplementary.SignInTime__c);
                out.signOutTime = String.valueOf(out.supplementary.SignOutTime__c);
                if (out.supplementary.ApprovalStatus__c=='补签申请审批通过' || out.supplementary.ApprovalStatus__c=='未创建') {
                    out.isCanAdd = true;     
                }else{
                    out.isCanAdd = false;
                }
                if (out.supplementary.ApprovalStatus__c=='已提交补签申请') {
                    List<Supplementary_Information__c> supplementaryInformationExist = [SELECT Id,Shop__c,Supplementary_SignIn_Time__c,Reson__c FROM Supplementary_Information__c WHERE Status__c='已提交补签申请' AND Attendance__c=:promoterAttendanceList[0].Id AND RecordType.DeveloperName='CheckInSupplementary'];
                    if (supplementaryInformationExist.size()>0) {
                        out.supplementary.Add_Check_Shop__c = supplementaryInformationExist[0].Shop__c;
                        out.supplementary.AddCheckSignInTime__c = supplementaryInformationExist[0].Supplementary_SignIn_Time__c;
                        out.addCheckSignInTime = String.valueOf(supplementaryInformationExist[0].Supplementary_SignIn_Time__c);
                        System.debug('addCheckSignInTime'+out.addCheckSignInTime);
                        out.supplementary.AddCheckInReason__c = supplementaryInformationExist[0].Reson__c;        
                    }    
                }
            }else{
                Promoter_Attendance__c pa = new Promoter_Attendance__c();
                pa.SignInTime__c = null;
                pa.SignOutTime__c = null;
                pa.Shop__c = null;
                pa.CheckInStatus__c = '未签到';
                out.signInTime = '';
                out.signOutTime = '';
                out.addCheckSignInTime = '';
                out.supplementary = pa;
                out.isCanAdd = true;
            }
            out.isCanNotCreate = false;
            out.dailyInspectionReport = new Daily_Inspection_Report__c();
            out.dailyInspectionReport.Report_Date__c = dateSelect;
            out.dailyInspectionReport.Report_Detail__c = '';
            out.dailyInspectionReport.Id = null;
            out.owner = System.UserInfo.getUserId();
            List<Mileage__c> mileage = [SELECT Id,End__c,Start__c 
                                        FROM Mileage__c 
                                        WHERE Mileage_OwnerId__c = :System.UserInfo.getUserId() 
                                        AND Report__r.Report_Date__c < :dateSelect  
                                        ORDER BY Report__r.Report_Date__c DESC Limit 1];

            Mileage__c newMileage = new Mileage__c();
            out.mileageFirst = false;
            out.lastMileageStart = 0;
            out.mileageEnd = 0; 
            newMileage.Start__c = 0;
            if (mileage.size()>0) {
                out.mileageEnd = mileage[0].End__c;
                newMileage.Start__c = mileage[0].End__c;
                out.lastMileageStart = mileage[0].End__c;
                if(mileage[0].End__c == null){
                    out.mileageFirst = true;// 上次巡店里程为空，改变字段
                    out.lastMileageId = mileage[0].Id;
                    out.lastMileageStart = mileage[0].Start__c;
                }     
            }
            // 补签开始里程和结束里程小于之后日报的里程
            List<Mileage__c> mileageNext = [SELECT Id,End__c,Start__c 
                                        FROM Mileage__c 
                                        WHERE Mileage_OwnerId__c = :System.UserInfo.getUserId() 
                                        AND Report__r.Report_Date__c > :dateSelect  
                                        ORDER BY Report__r.Report_Date__c Limit 1];
            if(mileageNext.size()>0){
                out.nextMileageStart = mileageNext[0].Start__c;
            }else {
                out.nextMileageStart = -1;
            }
            
            out.mileage = newMileage;
            out.isCanEdit = true;
            out.isCanEditAmountTo = true;
            List<Inspection_Shop_Task__c> inspectionShopTask = [SELECT 
                                                                    Status__c,
                                                                    Id,
                                                                    Shop__r.Name,
                                                                    Shop__c,
                                                                    Shop__r.Account__c,
                                                                    Shop__r.Account__r.Name,
                                                                    ProductCatalogConfirm__c,
                                                                    StoreMaintain__c,
                                                                    CorporateInformation__c,
                                                                    StoreInformation__c,
                                                                    CompetitiveInformation__c
                                                                FROM Inspection_Shop_Task__c 
                                                                WHERE OwnerId = :System.UserInfo.getUserId() 
                                                                AND Inspection_Date__c = :dateSelect];

            //门店IdSet
            Set<String> shopIdSet = new Set<String>();

            //门店客户IsSet
            for (Inspection_Shop_Task__c shopTask : inspectionShopTask) {
                shopIdSet.add(shopTask.Shop__c);
            }

            Map<String,List<ShopSelect>> shopMap = new Map<String,List<ShopSelect>>();
            for (Responsible_Person__c person : [SELECT Shop_Name__c,
                                                        Principal__c,
                                                        Shop_Name__r.Owner.Name,
                                                        Shop_Name__r.Name,
                                                        Shop_Name__r.Shop_Level__c,
                                                        Shop_Name__r.Account__r.Name
                                                FROM Responsible_Person__c
                                                WHERE Principal__c =: System.UserInfo.getUserId()
                                                AND RecordType__c = '巡店员']){
                if (!shopIdSet.contains(person.Shop_Name__c)) {
                    if (shopMap.containsKey(person.Shop_Name__r.Account__r.Name)) {
                        ShopSelect shopSelect = new ShopSelect();
                        shopSelect.label = person.Shop_Name__r.Name;
                        shopSelect.value = person.Shop_Name__c;
                        shopMap.get(person.Shop_Name__r.Account__r.Name).add(shopSelect);                
                    }else{
                        Map<String,String> newMap = new Map<String,String>();
                        ShopSelect shopSelect = new ShopSelect();
                        shopSelect.label = person.Shop_Name__r.Name;
                        shopSelect.value = person.Shop_Name__c;
                        shopMap.put(person.Shop_Name__r.Account__r.Name, new List<ShopSelect>{shopSelect});
                    }    
                }
            }
            out.shopMap = shopMap;
            out.accountShopList = shopMap.keySet();

            //门店与出样明细Map
            Map<String,List<Sampling_Detail__c>> samplingDetailMap = new Map<String,List<Sampling_Detail__c>>();
            for (Sampling_Detail__c samplingDetail : sortSamplingDetail(
                    [SELECT Display_Status__c,Id,Shop__c,Sampling_Standard__r.Name,Sampling_Standard__r.Level__c, 
                    Sampling_Standard__r.Flag__c,Product__c,Product__r.Name,Product__r.Product_Line__c,Product__r.Series__c, Sort__c
                    FROM Sampling_Detail__c WHERE Shop__c IN:shopIdSet AND Is_Add__c='是' AND (Not_Show_Time__c = NULL OR Display_Status__c ='展出') 
                    ORDER BY Product__r.Product_Line__c,Sort__c])) {
                if (samplingDetailMap.containsKey(samplingDetail.Shop__c)) {
                    samplingDetailMap.get(samplingDetail.Shop__c).add(samplingDetail);        
                }else{
                    samplingDetailMap.put(samplingDetail.Shop__c, new List<Sampling_Detail__c>{samplingDetail});
                }    
            }
            List<Store> storeList = new List<Store>();
            
            Integer i = 1;
            List<Store> stores = new List<Store>();
            for (Inspection_Shop_Task__c shopTask : inspectionShopTask) {
                Store store = new Store();
                store.productCatalogConfirm = shopTask.ProductCatalogConfirm__c;
                store.storeMaintain = shopTask.StoreMaintain__c;
                store.corporateInformation = shopTask.CorporateInformation__c;
                store.storeInformation = shopTask.StoreInformation__c;
                store.competitiveInformation = shopTask.CompetitiveInformation__c;
                if (shopTask.Status__c == '未到访') {
                    store.taskStatus = false;   
                }
                if (shopTask.Status__c == '计划外到访') {
                    store.taskStatus = false;        
                }
                if (shopTask.Status__c == '已到访') {
                    store.taskStatus = true;
                }

                if (shopTask.Status__c == '计划外到访') {
                    store.isCanChangeStatus = false;        
                }
                if (shopTask.Status__c == '未到访'){
                    store.isCanChangeStatus = true;    
                }
                if (shopTask.Status__c == '已到访') {
                    store.isCanChangeStatus = true;    
                }

                store.taskStatusString = shopTask.Status__c;
                
                store.storeId = String.valueOf(i);
                store.storeLabel = shopTask.Shop__r.Name;
                // store.shopReport = '';
                // store.inspectionStatus = '';
                // store.inspectionPicture = '';
                // store.viewImageUrl = '';
                store.taskId = shopTask.Id;
                store.shop = shopTask.Shop__c;
                store.accountName = shopTask.Shop__r.Account__r.Name;
                List<SamplingInspectionData> samplingInspectionDataList = new List<SamplingInspectionData>();
                Integer samplingInspectionDataIndex = 1;
                if (samplingDetailMap.get(shopTask.Shop__c)!=null) {
                    for (Sampling_Detail__c samplingDetail : samplingDetailMap.get(shopTask.Shop__c)) {
                        SamplingInspectionData samplingInspectionData = new SamplingInspectionData();
                        samplingInspectionData.index = String.valueOf(samplingInspectionDataIndex);
                        samplingInspectionData.key = i + '-' + samplingInspectionData.index;
                        samplingInspectionData.placementStatusShow = true;// wfc
                        Sampling_Inspection__c samplingInspection = new Sampling_Inspection__c();
                        samplingInspection.Shop__c = shopTask.Shop__c;
                        samplingInspection.Placement_Status__c = samplingDetail.Display_Status__c;
                        samplingInspection.Flag__c = samplingDetail.Sampling_Standard__r.Flag__c;
                        // 若定番等级为廃番 出样选项追加第三项「 処分推進」标黄色
                        if(samplingDetail.Sampling_Standard__r.Flag__c){
                            samplingInspectionData.placementStatusYellow = true;
                        }else {
                            samplingInspectionData.placementStatusYellow = false;
                        }
                        if(samplingInspection.Placement_Status__c == '未展出'){
                            samplingInspectionData.placementStatusNo = true;
                        }else {
                            samplingInspectionData.placementStatusNo = false;
                        }
                        samplingInspection.Product__c = samplingDetail.Product__c;
                        samplingInspectionData.productName = samplingDetail.Product__r.Name;
                        samplingInspection.ReRe__c = '';
                        samplingInspection.Sample_Images_Url__c = '';
                        samplingInspection.Sample_Item__c = samplingDetail.Id;
                        samplingInspectionData.series = samplingDetail.Product__r.Series__c;
                        samplingInspectionData.samplingInspection = samplingInspection;
                        samplingInspectionData.sampleImageList = new List<SampleImagesData>();
                        samplingInspectionData.imageNum = 0;
                        samplingInspectionDataList.add(samplingInspectionData);
                        samplingInspectionDataIndex++;  
                    }   
                }
                store.samplingInspectionDataList = samplingInspectionDataList;
                stores.add(store);
                i++;
            }
            out.stores = stores;
            out.isSucess = true;
            out.errorMsg = '';  
            return out;
        }
        catch (Exception e) {
            OutPut out = new OutPut();
            out.isSucess = false;
            out.errorMsg = System.Label.Error+e.getMessage()+e.getLineNumber();
            return out;
        }
    }

    public static OutPut getEditData(String reportId) {
        // //Savepoint sp=Database.setSavepoint();
        // try {
        OutPut out = new OutPut();
        out.isCanNotCreate = false;

        out.dailyInspectionReport = [SELECT CreatedDate,Id,Report_Date__c,Owner.Name,Report_Detail__c,OwnerId FROM Daily_Inspection_Report__c WHERE Id=:reportId limit 1];
        out.supplementary = [SELECT Add_Check_Shop__c,AddCheckSignInTime__c,AddCheckInReason__c,Id,SignInTime__c,SignOutTime__c,Shop__c,CheckInStatus__c,ApprovalStatus__c,CheckOutApprovalStatus__c FROM Promoter_Attendance__c WHERE Daily_Inspection_Report__c =:reportId AND RecordType.DeveloperName='InspectorAttendace' limit 1];
        out.signInTime = String.valueOf(out.supplementary.SignInTime__c);
        out.signOutTime = String.valueOf(out.supplementary.SignOutTime__c);
        System.debug('审批状态'+out.supplementary.SignInTime__c );
        if (out.supplementary.ApprovalStatus__c=='补签申请审批通过' || out.supplementary.ApprovalStatus__c=='未创建') {
            out.isCanAdd = true;     
        }else{
            out.isCanAdd = false;
        }
        if (out.supplementary.ApprovalStatus__c=='已提交补签申请') {
            List<Supplementary_Information__c> supplementaryInformationExist = [SELECT Id,Shop__c,Supplementary_SignIn_Time__c,Reson__c FROM Supplementary_Information__c WHERE Status__c='已提交补签申请' AND Attendance__c=:out.supplementary.Id AND RecordType.DeveloperName='CheckInSupplementary'];
            if (supplementaryInformationExist.size()>0) {
                out.supplementary.Add_Check_Shop__c = supplementaryInformationExist[0].Shop__c;
                out.supplementary.AddCheckSignInTime__c = supplementaryInformationExist[0].Supplementary_SignIn_Time__c;
                out.addCheckSignInTime = String.valueOf(supplementaryInformationExist[0].Supplementary_SignIn_Time__c);
                out.supplementary.AddCheckInReason__c = supplementaryInformationExist[0].Reson__c;        
            }    
        }
        String createDate = out.dailyInspectionReport.CreatedDate.format('yyyy-MM-dd HH:mm:ss', String.valueOf(System.UserInfo.getTimeZone()));
        String todayString = String.valueOf(System.today());

        if (createDate.contains(todayString) && System.UserInfo.getUserId()==out.dailyInspectionReport.OwnerId) {
            out.isCanEdit = true;
        }else{
            out.isCanEdit = false; 
        }
         // 日本零售经理修改巡店员日报中出样明细信息 wfc isCanEditSpecialUser
         out.isCanEditSpecialUser = false;
         List<GroupMember> userIdList = [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Update_Sampling_Detail'];
         for(GroupMember gm : userIdList){
             if(gm.UserOrGroupId == System.UserInfo.getUserId()){
                 out.isCanEditSpecialUser = true;
                 break;
             }
         }
         // 加油量30天内的值可编辑 显示保存按钮 wfc
         Date lastMonthString = System.today().addDays(-30);
         Date nowDate = out.dailyInspectionReport.Report_Date__c;
         if(nowDate >= lastMonthString && System.UserInfo.getUserId()==out.dailyInspectionReport.OwnerId){
             out.isCanEditAmountTo = true;
         }else {
             out.isCanEditAmountTo = false;
         }
        if (System.UserInfo.getUserId()==out.dailyInspectionReport.OwnerId) {
            out.isShowAddEvaluation = false;    
        }else{
            out.isShowAddEvaluation = true;    
        }
        out.evaluationDatas = new List<EvaluationData>();
        addEvaluation(reportId,out);
        // if (out.dailyInspectionReport.OwnerId==System.UserInfo.getUserId()) {
        //     out.isCanEvaluate = false;  
        // }else{
        //     out.isCanEvaluate = true;
        // }
        out.owner = out.dailyInspectionReport.Owner.Name;
        out.mileage = [SELECT Id,Start__c,End__c,Gas_Date__c,Amount_To__c FROM Mileage__c WHERE Report__c = :reportId limit 1];
        System.debug('存在日报逻辑'+out.mileage);
        List<Mileage__c> mileage = [SELECT Id,End__c,Start__c 
                                    FROM Mileage__c 
                                    WHERE Mileage_OwnerId__c = :out.dailyInspectionReport.OwnerId 
                                    AND Report__r.Report_Date__c < :out.dailyInspectionReport.Report_Date__c 
                                    ORDER BY Report__r.Report_Date__c DESC Limit 1];
        out.mileageFirst = false;
        out.lastMileageStart = 0;
        out.mileageEnd = 0; 
        if (!mileage.isEmpty()) {
            out.mileageEnd = mileage[0].End__c;
            out.lastMileageStart = mileage[0].End__c;
            if(mileage[0].End__c == null){
                out.mileageFirst = true;// 上次巡店里程为空，改变字段
                out.lastMileageId = mileage[0].Id;
                out.lastMileageStart = mileage[0].Start__c;
            }
        }
        // 补签开始里程和结束里程小于之后日报的里程
        List<Mileage__c> mileageNext = [SELECT Id,End__c,Start__c 
                                        FROM Mileage__c 
                                        WHERE Mileage_OwnerId__c = :out.dailyInspectionReport.OwnerId 
                                        AND Report__r.Report_Date__c > :out.dailyInspectionReport.Report_Date__c   
                                        ORDER BY Report__r.Report_Date__c Limit 1];
        if(mileageNext.size()>0){
            out.nextMileageStart = mileageNext[0].Start__c;
        }else {
            out.nextMileageStart = -1;
        }

        List<Inspection_Shop_Task__c> inspectionShopTask = [
                                                                SELECT 
                                                                    Status__c,
                                                                    Result__c,
                                                                    Remark__c,
                                                                    ImageUrl__c,
                                                                    Id,
                                                                    Shop__r.Name,
                                                                    Shop__c,
                                                                    Shop__r.Account__c,
                                                                    Is_Create_Report__c,
                                                                    Shop__r.Account__r.Name,
                                                                    ProductCatalogConfirm__c,
                                                                    StoreMaintain__c,
                                                                    CorporateInformation__c,
                                                                    StoreInformation__c,
                                                                    CompetitiveInformation__c
                                                                    // (SELECT Id,
                                                                    //     SignInTime__c,
                                                                    //     SignOutTime__c,
                                                                    //     CheckInStatus__c,
                                                                    //     AddCheckInReason__c,
                                                                    //     ApprovalStatus__c,
                                                                    //     AddCheckSignInTime__c,
                                                                    //     AddCheckSignOutTime__c 
                                                                    // FROM Inspector_Attendance__r) 
                                                                FROM Inspection_Shop_Task__c 
                                                                WHERE Daily_Inspection_Report__c =:reportId];
        
        //门店IdSet
        Set<String> shopIdSet = new Set<String>();

        //门店客户IsSet
        // Set<String> shopAccountIdSet = new Set<String>();

        //任务Id
        Set<String> taskIdSet = new Set<String>();

        //未到访任务Id
        Set<String> notCampleteTaskShopSet = new Set<String>();
        for (Inspection_Shop_Task__c shopTask : inspectionShopTask) {
            shopIdSet.add(shopTask.Shop__c);
            if (shopTask.Status__c == '未到访') {
                notCampleteTaskShopSet.add(shopTask.Shop__c); 
                // shopAccountIdSet.add(shopTask.Shop__r.Account__c);     
            }else{
                taskIdSet.add(shopTask.Id);    
            }  
        }

        //门店与出样明细Map
        Map<String,List<Sampling_Detail__c>> samplingDetailnotCampleteMap = new Map<String,List<Sampling_Detail__c>>();
        for (Sampling_Detail__c samplingDetail : sortSamplingDetail([
                SELECT Display_Status__c,Id,Shop__c,Sampling_Standard__r.Name,Product__c,Product__r.Name,Product__r.Product_Line__c,Product__r.Series__c,Sort__c 
                FROM Sampling_Detail__c WHERE Shop__c IN:shopIdSet AND Is_Add__c='是' AND (Not_Show_Time__c = NULL OR Display_Status__c ='展出') 
                ORDER BY Product__r.Product_Line__c,Sort__c DESC])) {
            if (samplingDetailnotCampleteMap.containsKey(samplingDetail.Shop__c)) {
                samplingDetailnotCampleteMap.get(samplingDetail.Shop__c).add(samplingDetail);        
            }else{
                samplingDetailnotCampleteMap.put(samplingDetail.Shop__c, new List<Sampling_Detail__c>{samplingDetail});
            }    
        }

        Map<String,List<ShopSelect>> shopMap = new Map<String,List<ShopSelect>>();
        for (Responsible_Person__c person : [
                                                    SELECT 
                                                        Id,
                                                        Shop_Name__c,
                                                        Principal__c,
                                                        Shop_Name__r.Owner.Name,
                                                        Shop_Name__r.Name,
                                                        Shop_Name__r.Shop_Level__c,
                                                        Shop_Name__r.Account__r.Name
                                                    FROM 
                                                        Responsible_Person__c
                                                    WHERE 
                                                        Principal__c =: System.UserInfo.getUserId()
                                                        AND RecordType__c = '巡店员'
                                                ]) 
        {
            if (String.isBlank(person.Shop_Name__r.Account__r.Name)) {
                continue;    
            }
            if (!shopIdSet.contains(person.Shop_Name__c)) {
                if (shopMap.containsKey(person.Shop_Name__r.Account__r.Name)) {
                    ShopSelect shopSelect = new ShopSelect();
                    shopSelect.label = person.Shop_Name__r.Name;
                    shopSelect.value = person.Shop_Name__c;
                    shopMap.get(person.Shop_Name__r.Account__r.Name).add(shopSelect);                
                }else{
                    Map<String,String> newMap = new Map<String,String>();
                    ShopSelect shopSelect = new ShopSelect();
                    shopSelect.label = person.Shop_Name__r.Name;
                    shopSelect.value = person.Shop_Name__c;
                    shopMap.put(person.Shop_Name__r.Account__r.Name, new List<ShopSelect>{shopSelect});
                }    
            }else{
                if (!shopMap.containsKey(person.Shop_Name__r.Account__r.Name)) {
                    shopMap.put(person.Shop_Name__r.Account__r.Name, new List<ShopSelect>());
                }
            }
        }
        out.shopMap = shopMap;
        out.accountShopList = shopMap.keySet();
        //任务与出样检查Map
        System.debug('*** taskIdSet:' + taskIdSet);
        Map<String,List<Sampling_Inspection__c>> samplingDetailMap = new Map<String,List<Sampling_Inspection__c>>();
        for (Sampling_Inspection__c samplingInspection : sortSamplingInspection([
                SELECT (SELECT Id,ReRe__c,Sample_Images__c FROM Sample_Images__r),Placement_Status__c,Product__r.Name,
                Product__r.Series__c,Product__r.Product_Line__c,Shop__c,Inspection_Shop_Task__c,Sample_Images_Url__c,ReRe__c,Sample_Item__c,Flag__c,Sort__c 
                FROM Sampling_Inspection__c WHERE Inspection_Shop_Task__c IN:taskIdSet AND (Sample_Item__r.Not_Show_Time__c = null OR Placement_Status__c ='展出') 
                ORDER BY Sort__c])) {
            if (samplingDetailMap.containsKey(samplingInspection.Inspection_Shop_Task__c)) {
                samplingDetailMap.get(samplingInspection.Inspection_Shop_Task__c).add(samplingInspection);        
            }else{
                samplingDetailMap.put(samplingInspection.Inspection_Shop_Task__c, new List<Sampling_Inspection__c>{samplingInspection});
            }    
        }
        List<Store> storeList = new List<Store>();
        
        Integer i = 1;
        List<Store> stores = new List<Store>();
        for (Inspection_Shop_Task__c shopTask : inspectionShopTask) {
            Store store = new Store();
            store.productCatalogConfirm = shopTask.ProductCatalogConfirm__c;
            store.storeMaintain = shopTask.StoreMaintain__c;
            store.corporateInformation = shopTask.CorporateInformation__c;
            store.storeInformation = shopTask.StoreInformation__c;
            store.competitiveInformation = shopTask.CompetitiveInformation__c;
            store.storeId = String.valueOf(i);
            store.storeLabel = shopTask.Shop__r.Name;
            store.taskId = shopTask.Id;
            store.shop = shopTask.Shop__c;
            store.taskStatusString = shopTask.Status__c;
            store.accountName = shopTask.Shop__r.Account__r.Name;
            if (shopTask.Status__c == '未到访') {
                store.taskStatus = true;   
            }else{
                store.taskStatus = false;
            }
            if (shopTask.Status__c == '计划外到访') {
                if (shopTask.Is_Create_Report__c) {
                    store.isShowDelete = true;
                }
                store.isCanChangeStatus = false;        
            }
            if (shopTask.Status__c == '未到访'){
                store.isCanChangeStatus = true;    
            }
            if (shopTask.Status__c == '已到访') {
                store.isCanChangeStatus = true;    
            }
            List<SamplingInspectionData> samplingInspectionDataList = new List<SamplingInspectionData>();
            Integer samplingInspectionDataIndex = 1;
            if (shopTask.Status__c != '未到访') {
                if (samplingDetailMap.get(shopTask.Id)!=null) {
                    for (Sampling_Inspection__c samplingInspection : samplingDetailMap.get(shopTask.Id)) {
                        SamplingInspectionData samplingInspectionData = new SamplingInspectionData();
                        System.debug('大小'+samplingInspection.Sample_Images__r.size());
                        if (samplingInspection.Sample_Images__r.size()>0) {
                            samplingInspectionData.imageNum = samplingInspection.Sample_Images__r.size();
                            samplingInspectionData.sampleImageList = new List<SampleImagesData>();
                            for (Integer siIndex = 0 ; siIndex<samplingInspection.Sample_Images__r.size(); siIndex++) {
                                SampleImagesData sid = new SampleImagesData();
                                sid.index = String.valueOf(siIndex+1);
                                sid.sampleImages = samplingInspection.Sample_Images__r[siIndex];
                                samplingInspectionData.sampleImageList.add(sid);  
                            }
                        }else{
                            samplingInspectionData.imageNum = 0;
                            samplingInspectionData.sampleImageList = new List<SampleImagesData>();
                        }
                        samplingInspectionData.series = samplingInspection.Product__r.Series__c;
                        samplingInspectionData.index = String.valueOf(samplingInspectionDataIndex);
                        samplingInspectionData.key = i + '-' + samplingInspectionData.index;
                        samplingInspectionData.productName = samplingInspection.Product__r.Name;
                        samplingInspectionData.samplingInspection = samplingInspection;
                        samplingInspectionData.placementStatusShow = true;// wfc
                        if(samplingInspection.Placement_Status__c == '未展出'){
                            samplingInspectionData.placementStatusNo = true;
                        }else {
                            samplingInspectionData.placementStatusNo = false;
                        }
                        // 若定番等级为廃番 出样选项追加第三项「 処分推進」标黄色saveData
                        if(samplingInspection.Flag__c){
                            samplingInspectionData.placementStatusYellow = true;
                        }else {
                            samplingInspectionData.placementStatusYellow = false;
                        }
                        
                        samplingInspectionDataList.add(samplingInspectionData);
                        samplingInspectionDataIndex++;  
                    }   
                }    
            }

            if (shopTask.Status__c == '未到访') {
                if (samplingDetailnotCampleteMap.get(shopTask.Shop__c)!=null) {
                    for (Sampling_Detail__c samplingDetail : samplingDetailnotCampleteMap.get(shopTask.Shop__c)) {
                        SamplingInspectionData samplingInspectionData = new SamplingInspectionData();
                        samplingInspectionData.series = samplingDetail.Product__r.Series__c;
                        samplingInspectionData.index = String.valueOf(samplingInspectionDataIndex);
                        samplingInspectionData.key = i + '-' + samplingInspectionData.index;
                        Sampling_Inspection__c samplingInspection = new Sampling_Inspection__c();
                        samplingInspection.Shop__c = shopTask.Shop__c;
                        samplingInspection.Placement_Status__c = samplingDetail.Display_Status__c;
                        samplingInspectionData.placementStatusShow = true;// wfc
                        if(samplingInspection.Placement_Status__c == '未展出'){
                            samplingInspectionData.placementStatusNo = true;
                        }else {
                            samplingInspectionData.placementStatusNo = false;
                        }
                        // 若定番等级为廃番 出样选项追加第三项「 処分推進」标黄色
                        if(samplingInspection.Flag__c){
                            samplingInspectionData.placementStatusYellow = true;
                        }else {
                            samplingInspectionData.placementStatusYellow = false;
                        }
                        // samplingInspectionData.samplingStandardName = samplingDetail.Sampling_Standard__r.Name;
                        samplingInspection.Product__c = samplingDetail.Product__c;
                        samplingInspectionData.productName = samplingDetail.Product__r.Name;
                        // samplingInspection.Tag_Price__c = null;
                        // samplingInspection.Point__c = null;
                        samplingInspection.ReRe__c = '';
                        samplingInspection.Sample_Images_Url__c = '';
                        // samplingInspection.Sample_Images__c = '';
                        samplingInspection.Sample_Item__c = samplingDetail.Id;
                        samplingInspectionData.samplingInspection = samplingInspection;
                        samplingInspectionDataList.add(samplingInspectionData);
                        samplingInspectionDataIndex++;  
                    }   
                }    
            }
            
            
            store.samplingInspectionDataList = samplingInspectionDataList;

            Integer shopCompetitiveProductIndex = 1;
            stores.add(store);
            i++;
        }

        out.stores = stores;
        out.isSucess = true;
        out.errorMsg = '';  
        return out;
    }

    @AuraEnabled
    public static OutPut addShopData(String shopId, Integer shoreSize, Map<String,List<ShopSelect>> shopMap) {
        try {

            Shop__c shop = [SELECT Id,Account__c,Name,Account__r.Name FROM Shop__c WHERE Id=:shopId limit 1];
            List<ShopSelect> shopSelectList = shopMap.get(shop.Account__r.Name);
            Integer shopSelectIndex  = 0;
            if(shopSelectList != null && shopSelectList.size() > 0){ //wfc
                for (ShopSelect shopSelect : shopSelectList) {
                    if (shopSelect.label==shop.Name) {
                        shopSelectList.remove(shopSelectIndex);
                        break;    
                    }
                    shopSelectIndex++;
                }
            }
            shopMap.put(shop.Account__r.Name, shopSelectList);
            OutPut out = new OutPut();
            out.shopMap = shopMap;
            //门店与出样明细Map
            Map<String,List<Sampling_Detail__c>> samplingDetailMap = new Map<String,List<Sampling_Detail__c>>();
            for (Sampling_Detail__c samplingDetail : sortSamplingDetail([
                    SELECT Display_Status__c,Id,Shop__c,Sampling_Standard__r.Name,Sampling_Standard__r.Flag__c, 
                    Product__c,Product__r.Name,Product__r.Product_Line__c,Product__r.Series__c, Sort__c
                    FROM Sampling_Detail__c WHERE Shop__c =:shop.Id AND Shop__r.Account__c =:shop.Account__c 
                    AND Is_Add__c='是' AND (Not_Show_Time__c = NULL OR Display_Status__c ='展出') 
                    ORDER BY Product__r.Product_Line__c,Sort__c])) {
                if (samplingDetailMap.containsKey(samplingDetail.Shop__c)) {
                    samplingDetailMap.get(samplingDetail.Shop__c).add(samplingDetail);        
                }else{
                    samplingDetailMap.put(samplingDetail.Shop__c, new List<Sampling_Detail__c>{samplingDetail});
                }    
            }
            List<Store> storeList = new List<Store>();
            
            Integer i = shoreSize+1;
            List<Store> stores = new List<Store>();
            // SupplementaryData supplementary = new SupplementaryData();
            // supplementary.checkInStatus = '';
            // supplementary.status = '';
            // supplementary.signInTime = null;
            // supplementary.signOutTime = null;
            // supplementary.supplementSignOutTime = null;
            // supplementary.supplementSignInTime = null;
            // supplementary.reson = '';
            Store store = new Store();
            /*Promoter_Attendance__c newPromoterAttendance = new Promoter_Attendance__c();
            newPromoterAttendance.SignInTime__c = null;
            newPromoterAttendance.SignOutTime__c = null;
            newPromoterAttendance.CheckInStatus__c = '未签到';
            newPromoterAttendance.AddCheckInReason__c = null;
            newPromoterAttendance.ApprovalStatus__c = '未提交补签申请';
            newPromoterAttendance.AddCheckSignInTime__c = null;
            newPromoterAttendance.AddCheckSignOutTime__c = null;
            store.supplementary = newPromoterAttendance;*/
            // store.isCanAdd = true;
            store.storeId = String.valueOf(i);
            store.storeLabel = shop.Name;
            // store.shopReport = '';
            // store.inspectionStatus = '';
            // store.inspectionPicture = '';
            store.isShowDelete = true;
            store.shop = shopId;
            store.taskStatus = false;
            store.isCanChangeStatus = false;
            store.accountName = shop.Account__r.Name;
            List<SamplingInspectionData> samplingInspectionDataList = new List<SamplingInspectionData>();
            Integer samplingInspectionDataIndex = 1;
            if (samplingDetailMap.get(shop.Id)!=null) {
                for (Sampling_Detail__c samplingDetail : samplingDetailMap.get(shop.Id)) {
                    SamplingInspectionData samplingInspectionData = new SamplingInspectionData();
                    samplingInspectionData.series = samplingDetail.Product__r.Series__c;
                    samplingInspectionData.index = String.valueOf(samplingInspectionDataIndex);
                    samplingInspectionData.key = i + '-' + samplingInspectionData.index;
                    Sampling_Inspection__c samplingInspection = new Sampling_Inspection__c();
                    samplingInspection.Shop__c = shop.Id;
                    samplingInspection.Placement_Status__c = samplingDetail.Display_Status__c;
                    samplingInspection.Flag__c = samplingDetail.Sampling_Standard__r.Flag__c;
                    samplingInspection.Sample_Item__c = samplingDetail.Id;
                    samplingInspectionData.placementStatusShow = true;// wfc
                    // 若定番等级为廃番 出样选项追加第三项「 処分推進」标黄色
                    if(samplingDetail.Sampling_Standard__r.Flag__c){
                        samplingInspectionData.placementStatusYellow = true;
                    }else {
                        samplingInspectionData.placementStatusYellow = false;
                    }
                    if(samplingInspection.Placement_Status__c == '未展出'){
                        samplingInspectionData.placementStatusNo = true;
                    }else {
                        samplingInspectionData.placementStatusNo = false;
                    }
                    // samplingInspectionData.samplingStandardName = samplingDetail.Sampling_Standard__r.Name;
                    samplingInspection.Product__c = samplingDetail.Product__c;
                    samplingInspectionData.productName = samplingDetail.Product__r.Name;
                    // samplingInspection.Tag_Price__c = null;
                    // samplingInspection.Point__c = null;
                    samplingInspection.ReRe__c = '';
                    samplingInspection.Sample_Images_Url__c = '';
                    samplingInspectionData.samplingInspection = samplingInspection;
                    samplingInspectionDataList.add(samplingInspectionData);
                    samplingInspectionDataIndex++;  
                }   
            }
            
            store.samplingInspectionDataList = samplingInspectionDataList;
            // store.shopCompetitiveProductDataList = new List<ShopCompetitiveProductData>();
            stores.add(store);

            out.stores = stores;
            out.isSucess = true;
            out.errorMsg = '';
            // wfc 巡店员在负责人为空的门店保存日报，将这个巡店员自动添加为门店负责人
            CheckInCheckOutService.autoSaveResponsiblePerson(shopId, UserInfo.getUserId());  
            return out;
        }catch(Exception e){
            OutPut out = new OutPut();
            out.isSucess = false;
            out.errorMsg = System.Label.Error+e.getMessage()+e.getLineNumber();
            return out;
        }        
    }

    @AuraEnabled
    public static OutPut saveData(
        Daily_Inspection_Report__c dailyInspectionReport, 
        List<Store> stores, 
        Mileage__c mileage, 
        Boolean isJump, 
        Date oldSelectDate, 
        List<String> deleteTaskId,
        // List<String> deleteCompetitiveProduct,
        Promoter_Attendance__c supplementary,
        List<String> deletePhoto,
        String lastMileageId,
        Boolean mileageFirst
    ) {
        Savepoint sp=Database.setSavepoint();
        try {
            //删除图片
            if (deletePhoto.size()>0) {
                Database.delete(deletePhoto);    
            }
            //删除任务。删除后操作再trigger中
            if (deleteTaskId.size()>0) {
                Database.delete(deleteTaskId);    
            }

            Boolean isNew = false;
            if (String.isBlank(dailyInspectionReport.Id)) {
                isNew = true;    
            }

            Inspection_Shop_Plan__c newPlan;
            String year = String.valueOf(dailyInspectionReport.Report_Date__c.year());
            String month = String.valueOf(dailyInspectionReport.Report_Date__c.month());
            List<Inspection_Shop_Plan__c> plan = [SELECT Id FROM Inspection_Shop_Plan__c WHERE Inspection_Year__c=:year AND Inspection_Month__c=:month AND OwnerId__c=:System.UserInfo.getUserId()];
            if (plan.size()==0) {
                newPlan = new Inspection_Shop_Plan__c();
                newPlan.Inspection_Year__c = year;
                newPlan.Inspection_Month__c = month;
                Insert newPlan;    
            }else{
                newPlan = plan[0];
            }
            dailyInspectionReport.Inspection_Shop_Plan__c = newPlan.Id;
            System.debug('dailyInspectionReport'+dailyInspectionReport);    
            
            Date jumpDate = dailyInspectionReport.Report_Date__c;
            if (isJump) {
                dailyInspectionReport.Report_Date__c = oldSelectDate;    
            }
            Database.upsert(dailyInspectionReport);

            // //需要插入的考勤数据
            // List<Promoter_Attendance__c> promoterAttendanceList = new List<Promoter_Attendance__c>();
            // //需要插入的补签数据
            // List<Supplementary_Information__c> supplementaryInformationList = new List<Supplementary_Information__c>();

            //考勤信息
            if (String.isBlank(supplementary.Id)) {
                supplementary.RecordTypeId = Schema.SObjectType.Promoter_Attendance__c.getRecordTypeInfosByDeveloperName().get('InspectorAttendace').getRecordTypeId();
                supplementary.Daily_Inspection_Report__c = dailyInspectionReport.Id;
                if (isJump) {
                    supplementary.CheckIn_Date__c = oldSelectDate;    
                }else{
                    supplementary.CheckIn_Date__c = dailyInspectionReport.Report_Date__c;
                }
                
                String addCheckShop = supplementary.Add_Check_Shop__c;
                Time signInTime = supplementary.AddCheckSignInTime__c;
                String reson = supplementary.AddCheckInReason__c;
                supplementary.Add_Check_Shop__c = null;
                supplementary.AddCheckSignInTime__c = null;
                supplementary.AddCheckInReason__c = null;
                Insert supplementary;
                // promoterAttendanceList.add(supplementary);
                // 补签逻辑删除 wfc
                // Supplementary_Information__c si = new Supplementary_Information__c();
                // si.RecordTypeId = Schema.SObjectType.Supplementary_Information__c.getRecordTypeInfosByDeveloperName().get('CheckInSupplementary').getRecordTypeId();
                // si.Shop__c = addCheckShop;
                // si.Supplementary_SignIn_Time__c = signInTime;
                // si.Reson__c = reson;
                // si.Attendance__c = supplementary.Id;
                // // si.Type__c = '补签签到';
                // Insert si;

                // //发起审批流
                // OutPut sendApprovalOut = sendApproval(si); 
                // if (!sendApprovalOut.isSucess) {
                //     Database.rollback(sp);
                //     return sendApprovalOut;    
                // }
            }else{
                String addCheckShop = supplementary.Add_Check_Shop__c;
                Time signInTime = supplementary.AddCheckSignInTime__c;
                String reson = supplementary.AddCheckInReason__c;
                supplementary.Daily_Inspection_Report__c = dailyInspectionReport.Id;
                supplementary.Add_Check_Shop__c = null;
                supplementary.AddCheckSignInTime__c = null;
                supplementary.AddCheckInReason__c = null;
                Update supplementary;
                System.debug('supplementary数据：'+supplementary);
                // 补签逻辑删除 wfc
                // if (supplementary.ApprovalStatus__c!='未提交补签申请'&&supplementary.ApprovalStatus__c != '补签申请审批拒绝'&&supplementary.ApprovalStatus__c != '已提交补签申请'&&(signInTime!=null && String.isNotBlank(addCheckShop) && String.isNotBlank(reson))) {
                //     Supplementary_Information__c si = new Supplementary_Information__c();
                //     si.RecordTypeId = Schema.SObjectType.Supplementary_Information__c.getRecordTypeInfosByDeveloperName().get('CheckInSupplementary').getRecordTypeId();
                //     si.Shop__c = addCheckShop;
                //     si.Supplementary_SignIn_Time__c = signInTime;
                //     si.Reson__c = reson;
                //     si.Attendance__c = supplementary.Id;
                //     // si.Type__c = '补签签到';
                //     Insert si;
                //     //发起审批流
                //     OutPut sendApprovalOut = sendApproval(si); 
                //     if (!sendApprovalOut.isSucess) {
                //         Database.rollback(sp);
                //         return sendApprovalOut;    
                //     }   
                // }
            }

            
            //任务
            List<Inspection_Shop_Task__c> needTaskList = new List<Inspection_Shop_Task__c>();


            //需要提交的审批数据
            List<Promoter_Attendance__c> needSubmitData = new List<Promoter_Attendance__c>();

            //出样明细
            List<Sampling_Detail__c> needSamplingDetailList = new List<Sampling_Detail__c>();

            //出样图片
            Map<String,List<Sample_Images__c>> sampleImagesMap = new Map<String,List<Sample_Images__c>>();

            //需要给出样明细的出样检查
            Map<String,Sampling_Inspection__c> needSamplingDetailIdMap = new Map<String,Sampling_Inspection__c>();
            
            List<Sampling_Detail__c> needLoopList = new List<Sampling_Detail__c>();

            //竞品
            // Map<String,Competitive_products__c> competitiveproductsMap = new Map<String,Competitive_products__c>();
            
            //taskIdMap
            Map<String,List<Sampling_Inspection__c>> samplingInspectionMap = new Map<String,List<Sampling_Inspection__c>>();
            
            //有图片的出样检查
            Map<String,Sampling_Inspection__c> samplingInspectionImageMap = new Map<String,Sampling_Inspection__c>(); 
            List<Sampling_Standard__c> samplingStandard = [SELECT Id FROM Sampling_Standard__c WHERE Is_Add_ByReport__c = true AND Channel_Name__c = null AND Product__c = null];
            //Account acc = [SELECT Id FROM Account WHERE External_Key__c = '999999' limit 1];
            Sampling_Standard__c sampling;
            if (samplingStandard.size()==0) {
                sampling = new Sampling_Standard__c();
                sampling.Is_Add_ByReport__c = true;
                //sampling.Channel_Name__c = acc.Id;
                Database.insert(sampling);    
            }else{
                sampling = samplingStandard[0];
            }

            //出样明细外键Set
            Set<String> detailExternalIdSet = new Set<String>();

            //出样明细查询
            for (Store st : stores) {
                for (SamplingInspectionData samplingInspectionData : st.samplingInspectionDataList) {
                    detailExternalIdSet.add(samplingInspectionData.samplingInspection.Shop__c+'-'+samplingInspectionData.samplingInspection.Product__c);
                }
            }

            //出样明细最近的出样检查Map
            Map<String,Sampling_Inspection__c> samplingDateMap = new Map<String,Sampling_Inspection__c>(); 
            if (detailExternalIdSet.size()>0) {
                for (Sampling_Detail__c sd : [SELECT Id,ExternalID__c,(SELECT Id,Inspection_Shop_Task__r.Daily_Inspection_Report__r.Report_Date__c FROM MVrr__r Order by Inspection_Shop_Task__r.Daily_Inspection_Report__r.Report_Date__c desc limit 1) FROM Sampling_Detail__c WHERE ExternalID__c IN:detailExternalIdSet]) {
                    if (sd.MVrr__r.size()>0) {
                        samplingDateMap.put(sd.ExternalID__c, sd.MVrr__r[0]);    
                    }
                }    
            }

            //门店名称
            String shopName = '';
            // Integer stIndex = 0;
            for (Store st : stores) {
                if (String.isBlank(shopName)) {
                    shopName = st.storeLabel;    
                }else{
                    shopName = shopName+','+st.storeLabel;
                }

                Inspection_Shop_Task__c task = new Inspection_Shop_Task__c();
                task.Id = st.taskId;
                task.Daily_Inspection_Report__c = dailyInspectionReport.Id;
                task.Shop__c = st.shop;
                task.Inspection_Date__c = dailyInspectionReport.Report_Date__c;
                task.ProductCatalogConfirm__c = st.productCatalogConfirm;
                task.StoreMaintain__c = st.storeMaintain;
                task.CorporateInformation__c = st.corporateInformation;
                task.StoreInformation__c = st.storeInformation;
                task.CompetitiveInformation__c = st.competitiveInformation;
                System.debug('st.storeMaintain'+st.storeMaintain);
                System.debug('task.Inspection_Date__c'+String.valueOf(task.Inspection_Date__c));
                task.ExternalID__c = String.valueOf(task.Inspection_Date__c)+'-'+task.Shop__c;
                System.debug('task.ExternalID__c'+task.ExternalID__c);
                needTaskList.add(task);
                //新建时如果没有到访直接跳过
                if (st.taskStatus) {
                    if (!isNew) {//从到访到未到访 出样明细检查在trigger中去处理
                        task.Status__c = '未到访';  
                        task.Result__c = null;
                        task.Remark__c = null;
                        task.ImageUrl__c = null; 
                        // task.Inspection_Picture__c = null; 
                    }
                    continue;    
                }
                // task.Result__c = st.inspectionStatus;
                // task.Remark__c = st.shopReport;
                // task.ImageUrl__c = st.inspectionPicture;
                // task.Inspection_Picture__c = st.viewImageUrl;
                System.debug('st.taskStatus'+st.taskStatus);
                if(!st.taskStatus){
                    task.Status__c = '已到访'; 
                    if (!st.isCanChangeStatus) {
                        task.Status__c = '计划外到访';
                    }   
                }
                if (String.isBlank(task.Id)) {
                    task.Is_Create_Report__c = true;
                    task.Status__c = '计划外到访';
                    task.Inspection_Plan__c = newPlan.Id; 
                    // task.CheckInStatus__c = '未签到';   
                }
                
                for (SamplingInspectionData samplingInspectionData : st.samplingInspectionDataList) {
                    // 验证产品是否填写(wfc)
                    if (String.isBlank(samplingInspectionData.samplingInspection.Placement_Status__c) || String.isBlank(samplingInspectionData.samplingInspection.Product__c)) {
                        OutPut out = new OutPut();
                        out.isSucess = false;
                        out.errorMsg = System.Label.ReportDetail+'\''+st.storeLabel+'\''+System.Label.Module+','+System.Label.SamplingInspectionRequired;
                        return out;   
                    }      

                    samplingInspectionData.samplingInspection.ExternalID__c = '-'+samplingInspectionData.samplingInspection.Product__c;
                    samplingInspectionData.samplingInspection.Inspection_Date__c = dailyInspectionReport.Report_Date__c;
                    // samplingInspectionList.add(samplingInspectionData.samplingInspection);
                    if (samplingInspectionData.sampleImageList!=null && samplingInspectionData.sampleImageList.size()>0) {
                        
                        //出样图片
                        for (SampleImagesData sid: samplingInspectionData.sampleImageList) {
                            samplingInspectionImageMap.put(samplingInspectionData.key,samplingInspectionData.samplingInspection);
                            if (sampleImagesMap.containsKey(samplingInspectionData.key)) {
                                sampleImagesMap.get(samplingInspectionData.key).add(sid.sampleImages);    
                            }else{
                                sampleImagesMap.put(samplingInspectionData.key, new List<Sample_Images__c>{sid.sampleImages});
                            }
                        }    
                    }
                    
                    if (String.isBlank(samplingInspectionData.samplingInspection.Shop__c)) {
                        samplingInspectionData.samplingInspection.Shop__c = st.shop;    
                    }
                    if (samplingInspectionMap.containsKey(task.ExternalID__c)) {
                        samplingInspectionMap.get(task.ExternalID__c).add(samplingInspectionData.samplingInspection);    
                    }else{
                        samplingInspectionMap.put(task.ExternalID__c, new List<Sampling_Inspection__c>{samplingInspectionData.samplingInspection});
                    }


                    Sampling_Detail__c samplingDetail = new Sampling_Detail__c();     
                    samplingDetail.Display_Status__c = samplingInspectionData.samplingInspection.Placement_Status__c;
                    samplingDetail.ExternalID__c = samplingInspectionData.samplingInspection.Shop__c+'-'+samplingInspectionData.samplingInspection.Product__c;  
                    samplingDetail.Flag__c = samplingInspectionData.samplingInspection.Flag__c;// 出样详情“処分推進”标记
                    if (samplingDateMap.get(samplingDetail.ExternalID__c)!=null && dailyInspectionReport.Report_Date__c < samplingDateMap.get(samplingDetail.ExternalID__c).Inspection_Shop_Task__r.Daily_Inspection_Report__r.Report_Date__c) {
                        System.debug('www--' + samplingDetail.ExternalID__c);
                        System.debug('www--' + samplingDateMap.get(samplingDetail.ExternalID__c).Inspection_Shop_Task__r.Daily_Inspection_Report__r.Report_Date__c);
                        continue;    
                    }
                    // 隐藏的出样明细再展出不会挂在特殊出样标准上
                    if (String.isBlank(samplingInspectionData.samplingInspection.Sample_Item__c) && samplingDateMap.get(samplingDetail.ExternalID__c) == null) {
                        samplingDetail.Sampling_Standard__c = sampling.Id; 
                        needSamplingDetailIdMap.put(samplingDetail.ExternalID__c, samplingInspectionData.samplingInspection);    
                        System.debug(samplingInspectionData.samplingInspection);
                        samplingDetail.Unplanned_Sample__c = '是';  
                        samplingDetail.Shop__c = samplingInspectionData.samplingInspection.Shop__c;
                        samplingDetail.Product__c = samplingInspectionData.samplingInspection.Product__c;
                        samplingDetail.Is_Add__c = '是';
                        needLoopList.add(samplingDetail);
                        System.debug('samplingDetail.Shop__c'+samplingDetail.Shop__c+'----'+'samplingDetail.Product__c'+samplingDetail.Product__c);  
                    }
                    needSamplingDetailList.add(samplingDetail);
                } 
                // stIndex++;
            }
            // 修改上一次巡店里程结束里程为空的数据 wfc
            if(mileageFirst){
                Mileage__c lastMileage = [SELECT Id,End__c FROM Mileage__c WHERE Id =:lastMileageId limit 1];
                lastMileage.End__c = mileage.Start__c;
                Database.upsert(lastMileage);
            }
            system.debug(mileage.Id);
            mileage.Report__c = dailyInspectionReport.Id;
            mileage.Pass_Place__c = shopName;
            if (mileage.Amount_To__c != null) {
                if (mileage.Id == null) {
                    
                    //新建
                    mileage.Gas_Date__c = dailyInspectionReport.Report_Date__c;
                    List<Mileage__c> lastMileageList = [SELECT CreatedDate,Report__r.Report_Date__c 
                                              FROM Mileage__c 
                                              WHERE Gas_Mileage__c!=null 
                                              AND Mileage_OwnerId__c = :System.UserInfo.getUserId()
                                              AND Report__r.Report_Date__c < :dailyInspectionReport.Report_Date__c
                                              Order by Report__r.Report_Date__c desc Limit 1];
                    if (lastMileageList.size()>0) {
                        for(Mileage__c mileageNeed : [SELECT Mileage_Of_Today__c 
                                                  FROM Mileage__c 
                                                  WHERE Mileage_OwnerId__c = :System.UserInfo.getUserId()
                                                  AND End__c != null
                                                  AND Report__r.Report_Date__c > :lastMileageList[0].Report__r.Report_Date__c
                                                  AND Report__r.Report_Date__c<= :dailyInspectionReport.Report_Date__c ]){
                            if (mileage.Gas_Mileage__c == null) {
                                mileage.Gas_Mileage__c = mileageNeed.Mileage_Of_Today__c;
                            }else{
                                mileage.Gas_Mileage__c += mileageNeed.Mileage_Of_Today__c;
                            }    
                        } 
                        if (mileage.End__c!=null) {
                            if(mileage.Gas_Mileage__c == null) {
                                mileage.Gas_Mileage__c = mileage.End__c - mileage.Start__c;
                            }else{
                                mileage.Gas_Mileage__c += mileage.End__c - mileage.Start__c;
                            }                          
                        }
                    }else{
                        for(Mileage__c mileageNeed : [SELECT Mileage_Of_Today__c 
                                                      FROM Mileage__c 
                                                      WHERE Mileage_OwnerId__c = :System.UserInfo.getUserId()
                                                      AND End__c != null
                                                      AND Report__r.Report_Date__c< :dailyInspectionReport.Report_Date__c ]){
                                if (mileage.Gas_Mileage__c == null) {
                                    mileage.Gas_Mileage__c = mileageNeed.Mileage_Of_Today__c;
                                }else{
                                    mileage.Gas_Mileage__c += mileageNeed.Mileage_Of_Today__c;
                                }
                            } 
                        if (mileage.End__c!=null) {
                            mileage.Gas_Mileage__c += mileage.End__c - mileage.Start__c;
                        }
                    }                       
                    Database.upsert(mileage);  
                }else{           
                    //编辑
                    Mileage__c existMileage = [SELECT Amount_To__c, Report__r.Report_Date__c, Mileage_Of_Today__c, End__c
                                               FROM Mileage__c 
                                               WHERE Id=: mileage.Id Limit 1];
                    if (existMileage.Amount_To__c != mileage.Amount_To__c) {
                        mileage.Gas_Mileage__c = 0;
                        List<Mileage__c> lastMileageList = [SELECT CreatedDate,Report__r.Report_Date__c 
                                                  FROM Mileage__c 
                                                  WHERE Gas_Mileage__c!=null
                                                  AND Mileage_OwnerId__c = :System.UserInfo.getUserId()
                                                  AND Report__r.Report_Date__c < :existMileage.Report__r.Report_Date__c 
                                                  Order by Report__r.Report_Date__c desc limit 1];                                                
                        if (lastMileageList.size()>0) {
                            for(Mileage__c mileageNeed : [SELECT Mileage_Of_Today__c 
                                                      FROM Mileage__c 
                                                      WHERE Mileage_OwnerId__c = :System.UserInfo.getUserId()
                                                      AND End__c != null
                                                      AND Report__r.Report_Date__c> :lastMileageList[0].Report__r.Report_Date__c
                                                      AND Report__r.Report_Date__c<= :existMileage.Report__r.Report_Date__c ]){
                                if (mileage.Gas_Mileage__c == null) {
                                    mileage.Gas_Mileage__c = mileageNeed.Mileage_Of_Today__c;
                                }else{
                                    mileage.Gas_Mileage__c += mileageNeed.Mileage_Of_Today__c;
                                }
                            } 
                            if (existMileage.End__c == null) {
                                mileage.Gas_Mileage__c += mileage.End__c-mileage.Start__c; 
                            }  
                        }else{
                            for(Mileage__c mileageNeed : [SELECT Mileage_Of_Today__c 
                                                      FROM Mileage__c 
                                                      WHERE Mileage_OwnerId__c = :System.UserInfo.getUserId()
                                                      AND End__c != null
                                                      AND Report__r.Report_Date__c< :existMileage.Report__r.Report_Date__c ]){
                                if (mileage.Gas_Mileage__c == null) {
                                    mileage.Gas_Mileage__c = mileageNeed.Mileage_Of_Today__c;
                                }else{
                                    mileage.Gas_Mileage__c += mileageNeed.Mileage_Of_Today__c;
                                }
                            } 
                            if (mileage.End__c != null) {
                                mileage.Gas_Mileage__c += mileage.End__c-mileage.Start__c; 
                            }
                        } 
                        Database.upsert(mileage);    
                    }
                }
                
            }else{

                mileage.Gas_Mileage__c = null;
                Database.upsert(mileage);
            }

            // 变更下一次加油量的巡店里程 wfc
            List<Mileage__c> nextMileageList = [SELECT Report__r.Report_Date__c,Gas_Mileage__c 
                                                FROM Mileage__c 
                                                WHERE Gas_Mileage__c!=null
                                                AND Mileage_OwnerId__c = :System.UserInfo.getUserId()
                                                AND Report__r.Report_Date__c > :dailyInspectionReport.Report_Date__c
                                                Order by Report__r.Report_Date__c limit 1];
            if(nextMileageList != null && nextMileageList.size() > 0){
                Mileage__c nextMileage = nextMileageList[0];
                nextMileage.Gas_Mileage__c = null;
                // 加油量有值与无值区别
                if(mileage.Amount_To__c == null){
                    // 找上一个有加油量的数据
                    List<Mileage__c> lastMileageList = [SELECT Report__r.Report_Date__c,Gas_Mileage__c 
                                                        FROM Mileage__c 
                                                        WHERE Gas_Mileage__c!=null
                                                        AND Mileage_OwnerId__c = :System.UserInfo.getUserId()
                                                        AND Report__r.Report_Date__c < :dailyInspectionReport.Report_Date__c
                                                        Order by Report__r.Report_Date__c DESC limit 1];
                    if(lastMileageList != null && lastMileageList.size() > 0){
                        // 可以找到上一个加油量
                        for(Mileage__c mileageNeed : [SELECT Mileage_Of_Today__c 
                                                    FROM Mileage__c 
                                                    WHERE Mileage_OwnerId__c = :System.UserInfo.getUserId()
                                                    AND End__c != null
                                                    AND Report__r.Report_Date__c > :lastMileageList[0].Report__r.Report_Date__c
                                                    AND Report__r.Report_Date__c <= :nextMileage.Report__r.Report_Date__c ]){
                            if (nextMileage.Gas_Mileage__c == null) {
                                nextMileage.Gas_Mileage__c = mileageNeed.Mileage_Of_Today__c;
                            }else{
                                nextMileage.Gas_Mileage__c += mileageNeed.Mileage_Of_Today__c;
                            }   
                        }
                    }else {
                        // 找不到上一个加油量，下一个加油量是第一次
                        for(Mileage__c mileageNeed : [SELECT Mileage_Of_Today__c 
                                                FROM Mileage__c 
                                                WHERE Mileage_OwnerId__c = :System.UserInfo.getUserId()
                                                AND End__c != null
                                                AND Report__r.Report_Date__c <= :nextMileage.Report__r.Report_Date__c ]){
                            if (nextMileage.Gas_Mileage__c == null) {
                                nextMileage.Gas_Mileage__c = mileageNeed.Mileage_Of_Today__c;
                            }else{
                                nextMileage.Gas_Mileage__c += mileageNeed.Mileage_Of_Today__c;
                            }   
                        }
                    }                                    
                }else {
                    for(Mileage__c mileageNeed : [SELECT Mileage_Of_Today__c 
                                                    FROM Mileage__c 
                                                    WHERE Mileage_OwnerId__c = :System.UserInfo.getUserId()
                                                    AND End__c != null
                                                    AND Report__r.Report_Date__c > :dailyInspectionReport.Report_Date__c
                                                    AND Report__r.Report_Date__c <= :nextMileage.Report__r.Report_Date__c ]){
                        if (nextMileage.Gas_Mileage__c == null) {
                            nextMileage.Gas_Mileage__c = mileageNeed.Mileage_Of_Today__c;
                        }else{
                            nextMileage.Gas_Mileage__c += mileageNeed.Mileage_Of_Today__c;
                        }   
                    }

                }
                Database.upsert(nextMileage); 
            }           

            Database.upsert(needTaskList);

            List<Sampling_Inspection__c> upsertSamplingInspectionList = new List<Sampling_Inspection__c>();
            for(Inspection_Shop_Task__c shopTask : needTaskList){
                if (samplingInspectionMap.get(shopTask.ExternalID__c)!=null) {
                    for(Sampling_Inspection__c samplingInspection : samplingInspectionMap.get(shopTask.ExternalID__c)) {
                        samplingInspection.Inspection_Shop_Task__c = shopTask.Id;
                        samplingInspection.ExternalID__c = shopTask.Id+samplingInspection.ExternalID__c;
                        upsertSamplingInspectionList.add(samplingInspection);
                    }    
                }
            }
            
            System.debug('needSamplingDetailList'+needSamplingDetailList);
            if (needSamplingDetailList.size()>0) {
                List<Database.UpsertResult> upsertResult = Database.upsert(needSamplingDetailList,Sampling_Detail__c.Fields.ExternalID__c);
            }


            for (Sampling_Detail__c sd : needLoopList) {
                if (needSamplingDetailIdMap.get(sd.ExternalID__c)!=null) {
                    needSamplingDetailIdMap.get(sd.ExternalID__c).Sample_Item__c = sd.Id;        
                }
            }

            if (upsertSamplingInspectionList.size()>0) {
                Database.upsert(upsertSamplingInspectionList,Sampling_Inspection__c.Fields.ExternalID__c);
            }
            System.debug('sampleImagesMap'+sampleImagesMap);
            if (sampleImagesMap.size()>0) {
                List<Sample_Images__c> upsertData = new List<Sample_Images__c>();
                for (String key : samplingInspectionImageMap.keySet()) {
                    if (sampleImagesMap.get(key)!=null) {
                        for (Sample_Images__c image : sampleImagesMap.get(key)) {
                            image.Sampling_Inspection__c = samplingInspectionImageMap.get(key).Id;  
                            upsertData.add(image);          
                        }        
                    }    
                }
                
                Database.upsert(upsertData);   
            }

            if (isJump) {
                return getNewCreateData(jumpDate);    
            }else{
                return getEditData(dailyInspectionReport.Id);
            }
        }catch(Exception e){
            Database.rollback(sp);
            OutPut out = new OutPut();
            out.isSucess = false;
            out.errorMsg = System.Label.Error+e.getMessage()+e.getLineNumber();
            system.debug(e.getMessage());
            system.debug(e.getLineNumber());
            return out; 
        }
    }

    @AuraEnabled
    public static OutPut getProductSeries(String productId) {
        try{
            Product__c pro = [SELECT Series__c FROM Product__c WHERE Id=:productId];
            OutPut out = new OutPut();
            out.series = pro.Series__c;
            out.isSucess = true;
            return out;
        }catch(Exception e){
            OutPut out = new OutPut();
            out.isSucess = false;
            out.errorMsg = System.Label.Error+e.getMessage()+e.getLineNumber();
            return out;
        }
    }

    public static OutPut sendApproval(Supplementary_Information__c si) {
        List<Approval.ProcessSubmitRequest> submitRequest = new List<Approval.ProcessSubmitRequest>();
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments(si.Reson__c);
        req.setObjectId(si.Id);
        req.setSubmitterId(UserInfo.getUserId());
        req.setSkipEntryCriteria(false);
        submitRequest.add(req); 
        List<Approval.ProcessResult> approvalResult = Approval.process(submitRequest);
        for (Approval.ProcessResult re : approvalResult) {
            if(!re.isSuccess()) {
                String errorMessage = '';
                for(Database.Error err : re.getErrors()) {
                    errorMessage = errorMessage + err.getMessage() + ':' +  err.getFields() + ';';
                }
                
                OutPut out = new OutPut();
                out.isSucess = false;
                out.errorMsg = System.Label.Error+errorMessage;
                return out; 
            }    
        }  
        OutPut out = new OutPut();
        out.isSucess = true;
        return out;    
    }
    // @AuraEnabled
    // public static OutPut isExistProductsData(CompetitiveProducts productName) {
    //     try{
    //         String external = productName.productsName+'_'+productName.brand+'_'+productName.size+'_'+productName.posttype;
    //         System.debug('external'+external);
    //         OutPut out = new OutPut();
    //         out.competitiveproducts = new List<CompetitiveProductsData>();
    //         List<Competitive_products__c> competitiveproducts = [SELECT Id FROM Competitive_products__c WHERE ExternalId__c=:external AND Is_Active__c=true];
    //         if (competitiveproducts.size()>0) {
    //             CompetitiveProductsData cpd = new CompetitiveProductsData();
    //             cpd.isSelect = true;
    //             cpd.competitiveProducts = competitiveproducts[0];   
    //             out.competitiveproducts.add(cpd);
    //         }
    //         out.isSucess = true;
    //         return out;
    //     }catch(Exception e) {
    //         OutPut out = new OutPut();
    //         out.isSucess = false;
    //         out.errorMsg = System.Label.Error+e.getMessage()+e.getLineNumber();
    //         return out; 
    //     }
    // }

    @AuraEnabled
    public static OutPut saveEvaluation(String evaluation, String reportId) {
        try {
            OutPut output = new OutPut();
            Shop_Report__c evaluationData = new Shop_Report__c();
            evaluationData.Comment__c = evaluation;
            evaluationData.User__c = System.UserInfo.getUserId();
            evaluationData.Daily_Inspection_Report__c = reportId;
            Database.insert(evaluationData);
            output.evaluationDatas = new List<EvaluationData>();
            addEvaluation(reportId,output);
            output.isSucess = true;

            //发送通知邮件 wfc 2022-06-14 零售经理在巡店员日报中评价后，发送给巡店员的通知
            // Set<String> userEmailSet = new Set<String>();
            // Daily_Inspection_Report__c dir = [SELECT Id,OwnerId,Owner.Email FROM Daily_Inspection_Report__c WHERE Id =:reportId limit 1];
            // if (dir.OwnerId != System.UserInfo.getUserId()) {
            //     userEmailSet.add(dir.Owner.Email);        
            // }

            // if (userEmailSet.size()>0) {
            //     sendRelateSingleRecordEmailNotification(evaluationData.Id, new List<String>(userEmailSet), 'ManagerReplyEmailTemplate');
            //     //sentEmail('日报有新的评论请前往日报查看/回复。评论内容为：'+evaluationData.Comment__c,userEmailSet,'新建评论通知');        
            // }
            return output;    
        }
        catch (Exception e) {
            OutPut out = new OutPut();
            out.isSucess = false;
            out.errorMsg = System.Label.Error+e.getMessage()+e.getLineNumber();
            return out;     
        }
    }

    @AuraEnabled
    public static OutPut saveResponse(String evaluationId, String reportId, String comment) {
        try {

            Shop_Report__c sr = [SELECT Id,User__c,User__r.Email,Comment__c FROM Shop_Report__c WHERE Id =:evaluationId limit 1];
            OutPut output = new OutPut();
            Responde__c responde = new Responde__c();
            responde.Shop_Report__c = evaluationId;
            responde.Responde__c = comment;
            responde.User__c = System.UserInfo.getUserId();
            responde.Name = System.UserInfo.getName()+System.Label.Reply;
            responde.Evaluate__c = sr.Comment__c;
            Database.insert(responde);
            output.evaluationDatas = new List<EvaluationData>();
            addEvaluation(reportId,output);
            output.isSucess = true;
            //发送通知邮件 wfc 2022-06-14 巡店员回复了日报评价后发送给评价者的邮件通知
            // Set<String> userEmailSet = new Set<String>();

            // if (sr.User__c != System.UserInfo.getUserId()) {
            //     userEmailSet.add(sr.User__r.Email);        
            // }else{
            //     Daily_Inspection_Report__c dir = [SELECT Id,OwnerId,Owner.Email FROM Daily_Inspection_Report__c WHERE Id =:reportId limit 1];
            //     if (dir.OwnerId != System.UserInfo.getUserId()) {
            //         userEmailSet.add(dir.Owner.Email);        
            //     }    
            // }

            // if (userEmailSet.size()>0) {
            //     sendRelateSingleRecordEmailNotification(responde.Id, new List<String>(userEmailSet), 'InspectorReplyEmailTemplate');
            //     // sentEmail('日报评价'+sr.Comment__c+'有新的回复。回复内容为：'+responde.Responde__c,userEmailSet,'评论回复通知');        
            // }
            return output;    
        }
        catch (Exception e) {
            OutPut out = new OutPut();
            out.isSucess = false;
            out.errorMsg = System.Label.Error+e.getMessage()+e.getLineNumber();
            return out;     
        }
    }

    // @AuraEnabled
    // public static void sendRelateSingleRecordEmailNotification(String recordId, List<String> emailAddressList,String templateName){
    //     List<EmailTemplate> etList = EmailNotificationUtility.getEmailTemplate(templateName);
    //     if(etList.size() > 0) {
    //         List<Messaging.SingleEmailMessage> semList = new List<Messaging.SingleEmailMessage>();
    //         Messaging.SingleEmailMessage craMail = new Messaging.SingleEmailMessage();
    //         craMail.setWhatId(recordId);
    //         craMail.setToAddresses(emailAddressList);
    //         craMail.setSaveAsActivity(false);
    //         craMail.setUseSignature(false);
    //         craMail.setTreatTargetObjectAsRecipient(false); 
    //         semList.add(craMail);
    //         EmailNotificationUtility.sendEmailNotificationWithDummyContact(etList[0],semList);
    //     }
    // }

    @AuraEnabled
    public static OutPut deleteEvaluation(String evaluationId, String reportId) {
        try {
            Database.delete(evaluationId);
            OutPut output = new OutPut();
            output.evaluationDatas = new List<EvaluationData>();
            addEvaluation(reportId,output);
            output.isSucess = true;
            //发送通知邮件
            Set<String> userEmailSet = new Set<String>();
            Daily_Inspection_Report__c dir = [SELECT Id,OwnerId,Owner.Email FROM Daily_Inspection_Report__c WHERE Id =:reportId limit 1];
            if (dir.OwnerId != System.UserInfo.getUserId()) {
                userEmailSet.add(dir.Owner.Email);        
            }

            if (userEmailSet.size()>0) {
                // sentEmail('日报评论删除通知。评论内容为：'+evaluationData.Comment__c,userEmailSet,'删除评论通知');        
            }
            return output;    
        }
        catch (Exception e) {
            OutPut out = new OutPut();
            out.isSucess = false;
            out.errorMsg = System.Label.Error+e.getMessage()+e.getLineNumber();
            return out;     
        }
    }

    @AuraEnabled
    public static OutPut deleteResponde(String respondeId, String reportId, String evaluationId) {
        try {
            Database.delete(respondeId);
            OutPut output = new OutPut();
            output.evaluationDatas = new List<EvaluationData>();
            addEvaluation(reportId,output);
            output.isSucess = true;
            //发送通知邮件
            Set<String> userEmailSet = new Set<String>();
            Shop_Report__c sr = [SELECT Id,User__c,User__r.Email,Comment__c FROM Shop_Report__c WHERE Id =:evaluationId limit 1];
            if (sr.User__c != System.UserInfo.getUserId()) {
                userEmailSet.add(sr.User__r.Email);        
            }else{
                Daily_Inspection_Report__c dir = [SELECT Id,OwnerId,Owner.Email FROM Daily_Inspection_Report__c WHERE Id =:reportId limit 1];
                if (dir.OwnerId != System.UserInfo.getUserId()) {
                    userEmailSet.add(dir.Owner.Email);        
                }    
            }

            if (userEmailSet.size()>0) {
                // sentEmail('日报评价'+sr.Comment__c+'删除回复。回复内容为：'+responde.Responde__c,userEmailSet,'评论回复删除通知');        
            }
            
            return output;    
        }
        catch (Exception e) {
            OutPut out = new OutPut();
            out.isSucess = false;
            out.errorMsg = System.Label.Error+e.getMessage()+e.getLineNumber();
            system.debug(e.getMessage()+e.getLineNumber());
            return out;     
        }
    }

    // public static void sentEmail(String body, Set<String> userEmailSet, String titile) {
    //     List<String> userEmialList = new List<String>();
    //     userEmialList.addAll(userEmailSet);
    //     Messaging.SingleEmailMessage dealerReopenEmail = new Messaging.SingleEmailMessage();
    //     dealerReopenEmail.setPlainTextBody(body);
    //     dealerReopenEmail.setSubject(titile);
    //     dealerReopenEmail.setCharset('UTF-8');
    //     dealerReopenEmail.setToAddresses(userEmialList);
    //     List<Messaging.SendEmailResult> SendResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { dealerReopenEmail });
    // }

    // 出样明细排序
    public static List<Sampling_Detail__c> sortSamplingDetail(List<Sampling_Detail__c> samplingDetailList) {
        // 排序后返回明细list
        List<Sampling_Detail__c> sortSamplingDetailList = new List<Sampling_Detail__c>();
        // 不同产品线明细list 绿-黄-红
        Map<String, List<Sampling_Detail__c>> colorGreenProductLineMap = new Map<String, List<Sampling_Detail__c>>();
        colorGreenProductLineMap.put('TV', new List<Sampling_Detail__c>());
        colorGreenProductLineMap.put('Sound Bar', new List<Sampling_Detail__c>());
        colorGreenProductLineMap.put('Refrigerator', new List<Sampling_Detail__c>());
        colorGreenProductLineMap.put('WM', new List<Sampling_Detail__c>());
        colorGreenProductLineMap.put('AC', new List<Sampling_Detail__c>());
        colorGreenProductLineMap.put('', new List<Sampling_Detail__c>());
        Map<String, List<Sampling_Detail__c>> colorYellowproductLineMap = new Map<String, List<Sampling_Detail__c>>();
        colorYellowproductLineMap.put('TV', new List<Sampling_Detail__c>());
        colorYellowproductLineMap.put('Sound Bar', new List<Sampling_Detail__c>());
        colorYellowproductLineMap.put('Refrigerator', new List<Sampling_Detail__c>());
        colorYellowproductLineMap.put('WM', new List<Sampling_Detail__c>());
        colorYellowproductLineMap.put('AC', new List<Sampling_Detail__c>());
        colorYellowproductLineMap.put('', new List<Sampling_Detail__c>());
        Map<String, List<Sampling_Detail__c>> colorRedproductLineMap = new Map<String, List<Sampling_Detail__c>>();
        colorRedproductLineMap.put('TV', new List<Sampling_Detail__c>());
        colorRedproductLineMap.put('Sound Bar', new List<Sampling_Detail__c>());
        colorRedproductLineMap.put('Refrigerator', new List<Sampling_Detail__c>());
        colorRedproductLineMap.put('WM', new List<Sampling_Detail__c>());
        colorRedproductLineMap.put('AC', new List<Sampling_Detail__c>());
        colorRedproductLineMap.put('', new List<Sampling_Detail__c>());

        for(Sampling_Detail__c samplingDetail : samplingDetailList){
            if(samplingDetail.Sort__c == 1){
                if(colorGreenProductLineMap.containsKey(samplingDetail.Product__r.Product_Line__c)){
                    colorGreenProductLineMap.get(samplingDetail.Product__r.Product_Line__c).add(samplingDetail);
                }else {
                    colorGreenProductLineMap.get('').add(samplingDetail);
                }
            }else if(samplingDetail.Sort__c == 2){
                if(colorGreenProductLineMap.containsKey(samplingDetail.Product__r.Product_Line__c)){
                    colorYellowproductLineMap.get(samplingDetail.Product__r.Product_Line__c).add(samplingDetail);
                }else {
                    colorYellowproductLineMap.get('').add(samplingDetail);
                }
            }else {
                if(colorGreenProductLineMap.containsKey(samplingDetail.Product__r.Product_Line__c)){
                    colorRedproductLineMap.get(samplingDetail.Product__r.Product_Line__c).add(samplingDetail);
                }else {
                    colorRedproductLineMap.get('').add(samplingDetail);
                }
            }
        }
        sortSamplingDetailList.addAll(colorGreenProductLineMap.get('TV'));
        sortSamplingDetailList.addAll(colorGreenProductLineMap.get('Sound Bar'));
        sortSamplingDetailList.addAll(colorGreenProductLineMap.get('Refrigerator'));
        sortSamplingDetailList.addAll(colorGreenProductLineMap.get('WM'));
        sortSamplingDetailList.addAll(colorGreenProductLineMap.get('AC'));
        sortSamplingDetailList.addAll(colorGreenProductLineMap.get(''));

        sortSamplingDetailList.addAll(colorYellowproductLineMap.get('TV'));
        sortSamplingDetailList.addAll(colorYellowproductLineMap.get('Sound Bar'));
        sortSamplingDetailList.addAll(colorYellowproductLineMap.get('Refrigerator'));
        sortSamplingDetailList.addAll(colorYellowproductLineMap.get('WM'));
        sortSamplingDetailList.addAll(colorYellowproductLineMap.get('AC'));
        sortSamplingDetailList.addAll(colorYellowproductLineMap.get(''));

        sortSamplingDetailList.addAll(colorRedproductLineMap.get('TV'));
        sortSamplingDetailList.addAll(colorRedproductLineMap.get('Sound Bar'));
        sortSamplingDetailList.addAll(colorRedproductLineMap.get('Refrigerator'));
        sortSamplingDetailList.addAll(colorRedproductLineMap.get('WM'));
        sortSamplingDetailList.addAll(colorRedproductLineMap.get('AC'));
        sortSamplingDetailList.addAll(colorRedproductLineMap.get(''));
        

        return sortSamplingDetailList;
    }

    // 出样检查排序
    public static List<Sampling_Inspection__c> sortSamplingInspection(List<Sampling_Inspection__c> samplingInspectionList) {
        // 排序后返回明细list
        List<Sampling_Inspection__c> sortSamplingInspectionList = new List<Sampling_Inspection__c>();
        // 不同产品线明细list 绿-黄-红
        Map<String, List<Sampling_Inspection__c>> colorGreenProductLineMap = new Map<String, List<Sampling_Inspection__c>>();
        colorGreenProductLineMap.put('TV', new List<Sampling_Inspection__c>());
        colorGreenProductLineMap.put('Sound Bar', new List<Sampling_Inspection__c>());
        colorGreenProductLineMap.put('Refrigerator', new List<Sampling_Inspection__c>());
        colorGreenProductLineMap.put('WM', new List<Sampling_Inspection__c>());
        colorGreenProductLineMap.put('AC', new List<Sampling_Inspection__c>());
        colorGreenProductLineMap.put('', new List<Sampling_Inspection__c>());
        Map<String, List<Sampling_Inspection__c>> colorYellowproductLineMap = new Map<String, List<Sampling_Inspection__c>>();
        colorYellowproductLineMap.put('TV', new List<Sampling_Inspection__c>());
        colorYellowproductLineMap.put('Sound Bar', new List<Sampling_Inspection__c>());
        colorYellowproductLineMap.put('Refrigerator', new List<Sampling_Inspection__c>());
        colorYellowproductLineMap.put('WM', new List<Sampling_Inspection__c>());
        colorYellowproductLineMap.put('AC', new List<Sampling_Inspection__c>());
        colorYellowproductLineMap.put('', new List<Sampling_Inspection__c>());
        Map<String, List<Sampling_Inspection__c>> colorRedproductLineMap = new Map<String, List<Sampling_Inspection__c>>();
        colorRedproductLineMap.put('TV', new List<Sampling_Inspection__c>());
        colorRedproductLineMap.put('Sound Bar', new List<Sampling_Inspection__c>());
        colorRedproductLineMap.put('Refrigerator', new List<Sampling_Inspection__c>());
        colorRedproductLineMap.put('WM', new List<Sampling_Inspection__c>());
        colorRedproductLineMap.put('AC', new List<Sampling_Inspection__c>());
        colorRedproductLineMap.put('', new List<Sampling_Inspection__c>());

        for(Sampling_Inspection__c samplingInspection : samplingInspectionList){
            if(samplingInspection.Sort__c == 1){
                if(colorGreenProductLineMap.containsKey(samplingInspection.Product__r.Product_Line__c)){
                    colorGreenProductLineMap.get(samplingInspection.Product__r.Product_Line__c).add(samplingInspection);
                }else {
                    colorGreenProductLineMap.get('').add(samplingInspection);
                }
            }else if(samplingInspection.Sort__c == 2){
                if(colorGreenProductLineMap.containsKey(samplingInspection.Product__r.Product_Line__c)){
                    colorYellowproductLineMap.get(samplingInspection.Product__r.Product_Line__c).add(samplingInspection);
                }else {
                    colorYellowproductLineMap.get('').add(samplingInspection);
                }
            }else {
                if(colorGreenProductLineMap.containsKey(samplingInspection.Product__r.Product_Line__c)){
                    colorRedproductLineMap.get(samplingInspection.Product__r.Product_Line__c).add(samplingInspection);
                }else {
                    colorRedproductLineMap.get('').add(samplingInspection);
                }
            }
        }
        sortSamplingInspectionList.addAll(colorGreenProductLineMap.get('TV'));
        sortSamplingInspectionList.addAll(colorGreenProductLineMap.get('Sound Bar'));
        sortSamplingInspectionList.addAll(colorGreenProductLineMap.get('Refrigerator'));
        sortSamplingInspectionList.addAll(colorGreenProductLineMap.get('WM'));
        sortSamplingInspectionList.addAll(colorGreenProductLineMap.get('AC'));
        sortSamplingInspectionList.addAll(colorGreenProductLineMap.get(''));

        sortSamplingInspectionList.addAll(colorYellowproductLineMap.get('TV'));
        sortSamplingInspectionList.addAll(colorYellowproductLineMap.get('Sound Bar'));
        sortSamplingInspectionList.addAll(colorYellowproductLineMap.get('Refrigerator'));
        sortSamplingInspectionList.addAll(colorYellowproductLineMap.get('WM'));
        sortSamplingInspectionList.addAll(colorYellowproductLineMap.get('AC'));
        sortSamplingInspectionList.addAll(colorYellowproductLineMap.get(''));

        sortSamplingInspectionList.addAll(colorRedproductLineMap.get('TV'));
        sortSamplingInspectionList.addAll(colorRedproductLineMap.get('Sound Bar'));
        sortSamplingInspectionList.addAll(colorRedproductLineMap.get('Refrigerator'));
        sortSamplingInspectionList.addAll(colorRedproductLineMap.get('WM'));
        sortSamplingInspectionList.addAll(colorRedproductLineMap.get('AC'));
        sortSamplingInspectionList.addAll(colorRedproductLineMap.get(''));

        return sortSamplingInspectionList;
    }
    

    public static void addEvaluation(String reportId, OutPut out) {
        Integer evaluationIndex = 1;
        for (Shop_Report__c shopReport : [SELECT CreatedDate,User__r.Name,Id,User__c,Comment__c,(SELECT CreatedDate,Id,Name,Responde__c,User__c FROM Responde__r Order by CreatedDate) FROM Shop_Report__c WHERE Daily_Inspection_Report__c =:reportId Order by CreatedDate]) {
            EvaluationData evaluation = new EvaluationData(); 
            evaluation.createTime = shopReport.CreatedDate.format('yyyy-MM-dd HH:mm:ss', String.valueOf(System.UserInfo.getTimeZone()));
            evaluation.evaluationIndex = String.valueOf(evaluationIndex);
            if (shopReport.User__c!=System.UserInfo.getUserId()) {
                evaluation.isCanDeleteEvaluation = false;            
            }else{
                evaluation.isCanDeleteEvaluation = true;    
            }
            evaluation.evaluation = shopReport;
            evaluation.responde = new List<RespondeData>();
            Integer respondeIndex = 1;
            for (Responde__c responde : shopReport.Responde__r) {
                RespondeData respondeData = new RespondeData();
                respondeData.indexNumber = String.valueOf(respondeIndex);
                respondeData.createTime = responde.CreatedDate.format('yyyy-MM-dd HH:mm:ss', String.valueOf(System.UserInfo.getTimeZone()));
                respondeData.respondeIndex = evaluationIndex+'-'+respondeIndex;
                if (responde.User__c!=System.UserInfo.getUserId()) {
                    respondeData.isCanDeleteResponde = false;    
                }else{
                    respondeData.isCanDeleteResponde = true;    
                }
                respondeData.responde = responde;
                evaluation.responde.add(respondeData);  
                respondeIndex++;  
            }
            out.evaluationDatas.add(evaluation);
            evaluationIndex++;
        }
    }

    public class OutPut {

        @AuraEnabled
        public String series {get; set;} 

        @AuraEnabled
        public String signInTime {get; set;} 

        @AuraEnabled
        public String signOutTime {get; set;}

        @AuraEnabled
        public String addCheckSignInTime {get; set;}

        @AuraEnabled
        public Boolean isCanAdd {get; set;}

        @AuraEnabled
        public Promoter_Attendance__c supplementary {get;set;}

        @AuraEnabled
        public String viewImageUrl {get;set;}

        @AuraEnabled
        public boolean isCanNotCreate {get;set;}

        @AuraEnabled
        public String imageUrl {get;set;}

        // @AuraEnabled
        // public Boolean isCanEvaluate
        @AuraEnabled
        public Boolean isShowAddEvaluation {get; set;}

        @AuraEnabled
        public Double mileageEnd {get; set;}

        @AuraEnabled
        public Set<String> accountShopList {get; set;}

        @AuraEnabled
        public Map<String,List<ShopSelect>> shopMap {get; set;}

        @AuraEnabled
        public Boolean isCanEdit {get; set;}

    	@AuraEnabled
		public Boolean isSucess {get; set;}

		@AuraEnabled
		public String errorMsg {get; set;}

        @AuraEnabled
        public List<String> saveErrorMsgList {get; set;}

		@AuraEnabled
		public String dateToday {get; set;}

        @AuraEnabled
        public String dateTodayStart {get; set;}

		@AuraEnabled
		public String owner {get; set;}

		@AuraEnabled
		public Daily_Inspection_Report__c dailyInspectionReport {get; set;}

    	@AuraEnabled
    	public List<Store> stores {get; set;}

        @AuraEnabled
        public Mileage__c mileage {get; set;}

        @AuraEnabled
        public Boolean mileageFirst {get; set;}// 是否是第一次巡店里程

        @AuraEnabled
        public String lastMileageId {get; set;}// 上一次没有结束里程的巡店里程Id

        @AuraEnabled
        public Double lastMileageStart {get; set;}// 上一次没有结束里程的巡店里程的出发里程

        @AuraEnabled
        public Double nextMileageStart {get; set;}// 下一次里程的开始里程

        @AuraEnabled
        public Boolean isCanEditAmountTo {get; set;}// 加油量30天内的值可编辑

        // @AuraEnabled
        // public List<CompetitiveProductsData> competitiveproducts {get; set;}

        @AuraEnabled
        public List<EvaluationData> evaluationDatas {get; set;}

        @AuraEnabled
        public List<DataSet> otherShopList {get; set;}

        @AuraEnabled
        public Boolean isCanEditSpecialUser {get; set;}// 特殊权限 修改日报中的出样明细
    } 

    public class EvaluationData {
        @AuraEnabled
        public String createTime {get; set;}

        @AuraEnabled
        public String evaluationIndex {get; set;}

        @AuraEnabled
        public Boolean isCanDeleteEvaluation {get; set;}

        @AuraEnabled
        public Shop_Report__c evaluation {get; set;} 

        @AuraEnabled
        public List<RespondeData> responde {get; set;}     
    }

    public class RespondeData {
        @AuraEnabled
        public String createTime {get; set;}

        @AuraEnabled
        public String respondeIndex {get; set;}

        @AuraEnabled
        public String indexNumber {get; set;}

        @AuraEnabled
        public Boolean isCanDeleteResponde {get; set;}

        @AuraEnabled
        public Responde__c responde {get; set;}   
    }

    // public class CompetitiveProductsData {
    //     @AuraEnabled
    //     public Competitive_products__c competitiveProducts {get; set;} 

    //     @AuraEnabled
    //     public Boolean isSelect {get; set;}    
    // }

    public class ShopSelect {
        @AuraEnabled
        public String label {get; set;}
        
        @AuraEnabled
        public String value {get; set;}    
    }

    public class Store {
        @AuraEnabled
        public String productCatalogConfirm {get; set;}
        
        @AuraEnabled
        public String storeMaintain {get; set;}

        @AuraEnabled
        public String corporateInformation {get; set;}
        
        @AuraEnabled
        public String storeInformation {get; set;}

        @AuraEnabled
        public String competitiveInformation {get; set;}

        // @AuraEnabled
        // public String viewImageUrl {get; set;}

        @AuraEnabled
        public String taskStatusString {get; set;}

        @AuraEnabled
        public String accountName {get;set;}

        @AuraEnabled
        public Boolean isCanChangeStatus {get; set;}

        @AuraEnabled
        public Boolean taskStatus {get; set;}

        @AuraEnabled
        public String shop {get; set;}

        @AuraEnabled
        public String taskId {get; set;}

        @AuraEnabled
        public Boolean isShowDelete {get; set;}

    	@AuraEnabled
    	public String storeId {get; set;}

    	@AuraEnabled
    	public String storeLabel {get; set;}

    	// @AuraEnabled
    	// public String inspectionReport {get; set;}

    	@AuraEnabled
    	public List<SamplingInspectionData> samplingInspectionDataList {get; set;}
    }

    public class SamplingInspectionData {

    	@AuraEnabled
    	public String key {get; set;}

    	@AuraEnabled
    	public String index {get; set;}

        @AuraEnabled
        public Boolean showDelete {get; set;} 

        @AuraEnabled
        public Integer imageNum {get; set;}

    	// @AuraEnabled
    	// public String samplingStandardName {get; set;}

    	@AuraEnabled
    	public String productName {get; set;}

        @AuraEnabled
        public String series {get; set;}

    	@AuraEnabled
    	public Sampling_Inspection__c samplingInspection {get; set;}

        @AuraEnabled
        public List<SampleImagesData> sampleImageList {get; set;}   

        // 未展示标记 wfc
        @AuraEnabled
        public Boolean placementStatusNo {get; set;}

         // 「 処分推進」标黄色 wfc
         @AuraEnabled
         public Boolean placementStatusYellow {get; set;}

        // 展示情况是否显示颜色 wfc
        @AuraEnabled
        public Boolean placementStatusShow {get; set;}
    }

    public class SampleImagesData {
        @AuraEnabled
        public Sample_Images__c sampleImages {get; set;}   

        @AuraEnabled
        public String index {get; set;} 
    }

    // public class CompetitiveProducts {
    //     @AuraEnabled
    //     public String productsName {get; set;}

    //     @AuraEnabled
    //     public String brand {get; set;}

    //     @AuraEnabled
    //     public String size {get; set;}   

    //     @AuraEnabled
    //     public String posttype {get; set;} 
    // }

    public class DataSet{
        @AuraEnabled public String Id;
        @AuraEnabled public String Name; //门店名称W
        @AuraEnabled public String Channel; //经销商渠道
    }

    //查找门店
    @AuraEnabled
    public static OutPut getStoreInfo(String searchInfo){
        OutPut out = new OutPut();
        try {
            out.otherShopList = new List<DataSet>();
            searchInfo = searchInfo + '%';
            List<Shop__c> searchList = [SELECT Id,Name,Account__r.name 
                                                FROM Shop__c 
                                                WHERE Id NOT IN (SELECT Shop_Name__c FROM Responsible_Person__c  WHERE RecordType__c = '巡店员' ) 
                                                AND name LIKE :searchInfo  
                                                ORDER BY Name 
                                                LIMIT 100
            ];
            for(Shop__c shopItem : searchList) {
                //显示门店
                DataSet dataItem = new DataSet();
                dataItem.Id = shopItem.Id;
                dataItem.Name = shopItem.Name;
                dataItem.Channel = shopItem.Account__r.Name;
                out.otherShopList.add(dataItem);
            }
            
            out.isSucess = true;
            return out;
        } catch (Exception e) {
    		out.isSucess = false;
	    	out.errorMsg = System.Label.Error+e.getMessage()+e.getLineNumber();
	    	return out;
        }
        
    }
}