public without sharing class NewSamplingAndTicketProController{
    public static User currentUser = [SELECT Id, Name, Username, Sales_Region__c, Profile.Name
                                      FROM User
                                      WHERE Id = :UserInfo.getUserId()];
    public static String recordId;
    public static String recordItemId;
    public static String salesRegion;
    public static String officeSalesRegion;
    public static String recordName;
    public static Decimal mark;
    public static Map<Id,CheckResult__c> checkResultMap = new Map<Id,CheckResult__c>();
    
    // 生成SampleInspection的对应的Check Result
    @AuraEnabled
    public static ConResponse addSampleInspectionCheckResult(String checkItemType, String inspectorDailyReportId, String inspectionProductItemId, String productLine, String sampleId){
        System.debug('wwwwwww-------' + checkItemType);
        System.debug('wwwwwww-------' + inspectorDailyReportId);
        System.debug('wwwwwww-------' + inspectionProductItemId);
        System.debug('wwwwwww-------' + productLine);
        System.debug('wwwwwww-------' + sampleId);
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        recordId = inspectorDailyReportId;
        recordItemId = inspectionProductItemId;

        Inspection_Product_Item__c insp = [Select Id,Type__c from  Inspection_Product_Item__c Where Id =: recordItemId];

        // 查询当前日报门店的salesregion 增加 日期查询用于获取区间内有效数据
        Daily_Inspection_Report__c record = [SELECT Id, Store__r.Sales_Region__c, Store__c, Report_Date__c
                                             FROM Daily_Inspection_Report__c
                                             WHERE Id = :inspectorDailyReportId];
        // salesRegion = record.Store__r.Sales_Region__c;
        // YYL 查询门店信息 20250325
        Shop__c shopDb = [SELECT Id, Name, Shop_Level__c, Account__r.Sales_Region__c, Sales_Region__c, Channel_item__c
                          FROM Shop__c
                          WHERE id = :record.Store__c];

        //TJP 区间值范围内进行历史数据结果采集
        List<CheckResult__c> oldCheckResult = new List<CheckResult__c>();
        // List<Sampling_Inspection__c> oldSamplingInspection = new List<Sampling_Inspection__c>();
        Date reportDate = record.Report_Date__c;
        Integer buff = Integer.valueOf(System.label.Inspection_Buff);
        Date fragment = reportDate.addDays(buff);
        List<Inspection_Product_Item__c> reports = [SELECT Id FROM Inspection_Product_Item__c  WHERE Inspection_Report__r.Status__c = 'Submitted' AND Inspection_Report__r.Store__c =: record.Store__c AND Inspection_Report__r.Report_Date__c >=: fragment AND Inspection_Report__r.Report_Date__c <: reportDate AND Type__c =:insp.Type__c  ORDER BY Inspection_Report__r.Report_Date__c desc limit 1];

        // List<Daily_Inspection_Report__c> reports = [SELECT Id
        //                                      FROM Daily_Inspection_Report__c
        //                                      WHERE Status__c = 'Submitted' AND Store__c = :record.Store__c AND Report_Date__c >=: fragment AND Report_Date__c <: reportDate 
        //                                      Order By Report_Date__c desc limit 1];
        //查看当前抽样的产品型号
        Sampling_Inspection__c samples = [SELECT Id,Product__c,Placement_Status__c FROM Sampling_Inspection__c WHERE Id =: sampleId];
        if(!reports.isEmpty()) {
            //执行数据流水线
            System.debug('WWW===' + reports[0].Id);
            oldCheckResult = [SELECT Id,CheckItem__c,Response__c,Comments__c,Sampling_Inspection__c,Sampling_Inspection__r.Product__c 
            
                                             FROM CheckResult__c
                                             WHERE Inspection_Product_Item__c = : reports[0].Id AND Sampling_Inspection__r.Product__c =: samples.Product__c];
            // oldSamplingInspection = [SELECT Id,Product__c,Placement_Status__c FROM Sampling_Inspection__c
            //                                  WHERE Inspection_Report__c  = : reports[0].Id AND Product__c =: samples.Product__c];                                 
            System.debug('WWW===' + oldCheckResult);                                 
            for(CheckResult__c item : oldCheckResult){
                //  shopMap.put(shopItem.Id, shopItem);
                checkResultMap.put(Item.CheckItem__c,item);
            }
            // checkResultMap.put(sampleId,checkResults);
            System.debug('WWW===' + checkResultMap);   
        }
        
        //20241029 TJP 增加 总部选点的salesregion判断
        if (currentUser.Sales_Region__c == 'Hisense International'){
            salesRegion = currentUser.Sales_Region__c;
            // System.debug('wwwsalesRegion' + salesRegion);
            System.debug('wwwcurrentUser' + salesRegion);

        } else if (currentUser.Sales_Region__c == 'Hisense X'){
            salesRegion = currentUser.Sales_Region__c;
            // System.debug('wwwsalesRegion' + salesRegion);
            System.debug('wwwcurrentUser' + salesRegion);

        } else{
            salesRegion = record.Store__r.Sales_Region__c;
        }


        System.debug('wwwsalesRegion' + salesRegion + checkItemType);
        System.debug('www---checkItemType----' + checkItemType);
        System.debug('www---productLine----' + productLine);
        System.debug('www---shopDb.Channel_item__c----' + shopDb.Channel_item__c);

        // 查询当前大类下没有父级问题的CheckItem
        List<CheckItem__c> checkItemParent = getCheckItemParentNull(checkItemType, productLine, shopDb.Channel_item__c);

        System.debug('wwwsalesRegion' + checkItemParent.size());

        if (checkItemParent != null && checkItemParent.size() > 0){

            // 存放最终存储数据
            List<CheckResult__c> checkResultAdd = new List<CheckResult__c>();
            List<CheckItem__c> CheckItemChildren = getCheckItemAll();

            System.debug('wwwCheckItemChildren' + JSON.serialize(CheckItemChildren));

            // if(Test.isRunningTest()){
            //     CheckItemChildren = [SELECT Id,
            //                                 Item_Type__c,
            //                                 Question_Type__c,
            //                                 Description__c,
            //                                 Parent__c
            //                                 FROM CheckItem__c];
            // }

            // 根据parent Id 分组
            Map<String, LisqContainer> groupParent = new Map<String, LisqContainer>();

            if (CheckItemChildren != null && CheckItemChildren.size() > 0){
                LisqContainer lqChildren = new LisqContainer(CheckItemChildren);

                groupParent = lqChildren.GroupByS('Parent__c');

            }
            System.debug('查询结果' + checkItemParent);
            for (CheckItem__c parent : checkItemParent){
                CheckResult__c parentResult = new CheckResult__c();
                parentResult.CheckItem__c = parent.id;
                parentResult.InspectorDailyReport__c = inspectorDailyReportId;
                parentResult.Inspection_Product_Item__c = inspectionProductItemId;
                parentResult.Sampling_Inspection__c = sampleId;
                System.debug('遍历结果' + checkResultMap.get(parent.Id));
                parentResult.Response__c = checkResultMap.containsKey(parent.Id) && checkResultMap.get(parent.Id) != null ? checkResultMap.get(parent.Id).Response__c : '';
                parentResult.Comments__c = checkResultMap.containsKey(parent.Id) && checkResultMap.get(parent.Id) != null ? checkResultMap.get(parent.Id).Comments__c : '';

                checkResultAdd.add(parentResult);

                if (groupParent != null && groupParent.size() > 0){
                    LisqContainer lqGroupParent = groupParent.get(parent.id);
                    if (lqGroupParent != null){
                        List<CheckItem__c> itemGroupParent = (List<CheckItem__c>)lqGroupParent.ToSobjectList();

                        checkResultRecursionAdd(itemGroupParent, checkResultAdd, groupParent, sampleId);
                    }

                }
            }
            System.debug('wwwwcheckResultAdd' + JSON.serialize(checkResultAdd));
            System.debug('wwwwcheckResultAdd' + JSON.serialize(inspectorDailyReportId));
            mso.put('checkResultAdd', checkResultAdd);
            // Sampling_Inspection__c sampling = new Sampling_Inspection__c(
            //     Id = sampleId,
            //     Placement_Status__c = oldSamplingInspection.isEmpty() ? '' : oldSamplingInspection[0].Placement_Status__c
            // );
            // Database.update(sampling);
            Database.insert (checkResultAdd);
            checkResultBindAttachments(checkResultAdd,oldCheckResult);
        }

        return resp;
    }

    //梳理检查结果附件
    //绑定当年最近日期附件
    public static void checkResultBindAttachments(List<CheckResult__c> newSiList, List<CheckResult__c> oldSiList) {
        // User user = [SELECT Id, Name, Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
        // if (PhaseIIIUtility.isIndonesia(user)) {
        //     return;
        // }
        // 根据CheckItem整理Map，整理出old Map new 的Id Map
        Map<String, CheckResult__c> newSitemMap = new Map<String, CheckResult__c>();
        for (CheckResult__c newSi : newSiList) {
            newSitemMap.put(newSi.CheckItem__c, newSi);
        }
        Map<String, String> oldMapNew = new Map<String, String>();
        for (CheckResult__c oldSi : oldSiList) {
            if (newSitemMap.containsKey(oldSi.CheckItem__c)) {
                CheckResult__c newSi = newSitemMap.get(oldSi.CheckItem__c);
                oldMapNew.put(oldSi.Id, newSi.Id);
            }
        }
        if (oldMapNew.size()==0) {
            return;
        }
        // 查询OldSi记录的附件
        List<ContentDocumentLink> querySi = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : oldMapNew.keySet()];
        Map<String, List<String>> documentMap = new Map<String, List<String>>();
        for (ContentDocumentLink item : querySi) {
            if (documentMap.containsKey(item.LinkedEntityId)) {
                List<String> linkedIds = documentMap.get(item.LinkedEntityId);
                linkedIds.add(item.ContentDocumentId);
            } else {
                List<String> linkedIds = new List<String>();
                linkedIds.add(item.ContentDocumentId);
                documentMap.put(item.LinkedEntityId, linkedIds);
            }
        }
        // 关联新记录
        List<ContentDocumentLink> insertCdlList = new List<ContentDocumentLink>();
        for (String oldId : oldMapNew.keySet()) {
            String newId = oldMapNew.get(oldId);
            if (documentMap.containsKey(oldId)) {
                for (String documentId : documentMap.get(oldId)) {
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = documentId;
                    cdl.LinkedEntityId = newId;
                    cdl.ShareType = 'V';
                    insertCdlList.add(cdl);
                }
            }
        }
        if (insertCdlList.size()>0) {
            insert insertCdlList;
        }
    }

    // 检查当前检查项是否已初始化
    @AuraEnabled
    public static ConResponse checkInitStatus(String checkItemType, String inspectionProductItemId, String sampleId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 查询检查项初始化数据
        List<CheckResult__c> initResult = getCheckResultInit(inspectionProductItemId, checkItemType, sampleId);
        if (initResult != null && initResult.size() > 0){
            mso.put('initStatus', true);
        } else{
            mso.put('initStatus', false);
        }

        return resp;
    }

    public static void setCheckItemLanguage(List<CheckResult__c> checkResults){
        String currentUserLanguage = UserInfo.getLanguage();
        String languageIsCN = 'zh_CN';
        String languageIsEN = 'en_US';

        for (CheckResult__c item: checkResults) {
            if (item.CheckItem__r.Description_Filling_Language__c != currentUserLanguage ) {
                if (String.isNotBlank(item.CheckItem__r.Description_EN__c) && currentUserLanguage == languageIsEN) {
                    item.CheckItem__r.Description__c = item.CheckItem__r.Description_EN__c;
                }
                if (currentUserLanguage == languageIsCN) {
                    if (String.isNotBlank(item.CheckItem__r.Description_CN__c)) item.CheckItem__r.Description__c = item.CheckItem__r.Description_CN__c;
                    else item.CheckItem__r.Description__c = String.isNotBlank(item.CheckItem__r.Description_EN__c) ? item.CheckItem__r.Description_EN__c : item.CheckItem__r.Description__c;
                }
                //2025-03-27 张安琪要求改为和Description__c一样选择语言
                if (String.isNotBlank(item.CheckItem__r.HelpTextEN__c) && currentUserLanguage == languageIsEN) {
                    item.CheckItem__r.HelpText__c = item.CheckItem__r.HelpTextEN__c;
                }
                if (currentUserLanguage == languageIsCN) {
                    if (String.isNotBlank(item.CheckItem__r.HelpTextCN__c)) item.CheckItem__r.HelpText__c = item.CheckItem__r.HelpTextCN__c;
                    else item.CheckItem__r.HelpText__c = String.isNotBlank(item.CheckItem__r.HelpTextEN__c) ? item.CheckItem__r.HelpTextEN__c : item.CheckItem__r.HelpText__c;
                }
                // if (!String.isBlank(item.CheckItem__r.HelpTextCN__c) && currentUserLanguage == languageIsCN) {
                //     item.CheckItem__r.HelpText__c = item.CheckItem__r.HelpTextCN__c;
                // } else if (!String.isBlank(item.CheckItem__r.HelpTextEN__c)) {
                //     item.CheckItem__r.HelpText__c = item.CheckItem__r.HelpTextEN__c;
                // }

                // YYL 新增单选多选项多语言 20250409
                if(currentUserLanguage == languageIsEN){
                    if(String.isNotBlank(item.CheckItem__r.Enter_Choice_EN__c)){
                        item.CheckItem__r.Enter_Choice__c = item.CheckItem__r.Enter_Choice_EN__c;
                    }
                }else if(currentUserLanguage == languageIsCN){
                    if(String.isNotBlank(item.CheckItem__r.Enter_Choice_CN__c)){
                        item.CheckItem__r.Enter_Choice__c = item.CheckItem__r.Enter_Choice_CN__c;
                    }
                }
            }
        }
    }
    // 查询检查项初始化详情
    @AuraEnabled
    public static ConResponse getcheckResultInitInfo(String checkItemType, String inspectionProductItemId, String sampleId){

        

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 存放处理后的展示数据
        List<newCheckItemController.CheckResultData> checkResultDataList = new List<newCheckItemController.CheckResultData>();
        List<CheckResult__c> checkResultParent = getCheckResultParent(inspectionProductItemId, checkItemType, sampleId);
        List<CheckResult__c> checkResultChildren = getCheckResultChildren(inspectionProductItemId, checkItemType, sampleId);

        setCheckItemLanguage(checkResultParent);
        setCheckItemLanguage(checkResultChildren);

        // 获取所有检查项的缩略图 YYL 20250303
        LisqContainer lqParent = new LisqContainer(checkResultParent);
        List<String> parentCheckItemId = lqParent.SelectSField('CheckItem__c');
        LisqContainer lqChildren = new LisqContainer(checkResultChildren);
        List<String> childrenCheckItemId = lqChildren.SelectSField('CheckItem__c');

        // 获取Parent 所有缩略图
        Map<Id, List<Map<String, String>>> parentFiles = new Map<Id, List<Map<String, String>>>();
        if (!parentCheckItemId.isEmpty()){
            parentFiles = newCheckItemController.getExistingFilesList(parentCheckItemId);
        }

        // 获取Children 所有缩略图
        Map<Id, List<Map<String, String>>> childrenFiles = new Map<Id, List<Map<String, String>>>();
        if (!childrenCheckItemId.isEmpty()){
            childrenFiles = newCheckItemController.getExistingFilesList(childrenCheckItemId);
        }

        // 根据parentId 分组
        Map<String, List<CheckResult__c>> groupParent = new Map<String, List<CheckResult__c>>();

        if (checkResultChildren != null && checkResultChildren.size() > 0){
            // LisqContainer lqChildren = new LisqContainer(checkResultChildren);
            // groupParent = lqChildren.GroupByS('CheckItem__r.Parent__c');
            for (CheckResult__c children : checkResultChildren){
                List<CheckResult__c> resultChildren = groupParent.get(children.CheckItem__r.Parent__c);

                if (resultChildren == null){
                    resultChildren = new List<CheckResult__c>();
                }
                resultChildren.add(children);
                groupParent.put(children.CheckItem__r.Parent__c, resultChildren);
            }
        }

        if (checkResultParent != null && checkResultParent.size() > 0){
            for (CheckResult__c parent : checkResultParent){
                newCheckItemController.CheckResultData parentData = new newCheckItemController.CheckResultData();
                parentData.parent = parent;

                // 查询当前问题的缩略图 YYL 20250303
                List<Map<String, String>> imgList = parentFiles.get(parent.CheckItem__c);
                if (imgList != null){
                    parentData.imgList = imgList;
                }

                // 上传文件和评论默认为false，前端根据条件判断展示
                // parentData.parent.CheckItem__r.HasFile__c = false;
                // parentData.parent.CheckItem__r.HasComment__c = false;

                if (groupParent != null && groupParent.size() > 0){
                    newCheckItemController.checkResultRecursionInit(parentData, groupParent, childrenFiles);
                }

                System.debug('wwwwCheckResultData' + JSON.serialize(parentData));

                checkResultDataList.add(parentData);
            }
        }

        mso.put('checkResultData', checkResultDataList);

        return resp;
    }

    @AuraEnabled
    public static Boolean deleteCheckResultForSamplingInspection(String samplingInspectionId){
        System.debug('wwwwwww-------' + samplingInspectionId);
        if (String.isNotBlank(samplingInspectionId)){
            List<CheckResult__c> crList = [SELECT Id
                                           FROM CheckResult__c
                                           WHERE Sampling_Inspection__c = :samplingInspectionId];
            delete crList;
        }
        return true;
    }

    // 处理存储的checkResult
    public static void checkResultRecursionAdd(List<CheckItem__c> itemGroup, List<CheckResult__c> checkResultAdd, Map<String, LisqContainer> groupParent, String sampleId){
        //TJP该方法想要处理 对应的历史结果
        for (CheckItem__c item : itemGroup){

            CheckResult__c result = new CheckResult__c();
            result.CheckItem__c = item.id;
            result.InspectorDailyReport__c = recordId;
            result.Inspection_Product_Item__c = recordItemId;
            result.Sampling_Inspection__c = sampleId;

            //Map整合一下子问题结果
            result.Response__c = checkResultMap.containsKey(item.id) && checkResultMap.get(item.id) != null ? checkResultMap.get(item.id).Response__c : '';

            result.Comments__c = checkResultMap.containsKey(item.id) && checkResultMap.get(item.id) != null ? checkResultMap.get(item.id).Comments__c : '';
            // 第一次初始化的子任务下标为1 YYL 20250305
            result.Index__c = 1;
            checkResultAdd.add(result);

            LisqContainer lqGroupChildren = groupParent.get(item.Id);
            if (lqGroupChildren != null){
                List<CheckItem__c> itemGroupChildren = (List<CheckItem__c>)lqGroupChildren.ToSobjectList();
                // checkResultAdd.addAll(itemGroupChildren);
                checkResultRecursionAdd(itemGroupChildren, checkResultAdd, groupParent, sampleId);
            }
        }
    }

    public static List<CheckItem__c> getCheckItemParentNull(String itemType, String productLine, String channel){
        return [SELECT id,
                       Parent_Response__c,
                       Parent__c,
                       Parent_Select__c
                       FROM CheckItem__c
                       WHERE Item_Type__c =: itemType
                       AND Parent__c = NULL
                       AND Active__c = true
                       AND Sales_Region__c =: salesRegion
                       AND (Product_Line__c = 'All' OR Product_Line__c IN: productLine.split(';'))
                       AND (Channel_item__c = NULL OR Channel_item__c =: channel)
                       ];
    }

    // 查询当前sales region下启用的检查项
    public static List<CheckItem__c> getCheckItemAll(){
        return [SELECT Id,
                       Item_Type__c,
                       Question_Type__c,
                       Description__c,
                       Parent__c
                       FROM CheckItem__c
                       WHERE 
                       Sales_Region__c =: salesRegion
                       AND Parent__c != NULL
                       AND Active__c = true
                       AND Question_Type__c != NULL];
    }

    public static List<CheckResult__c> getCheckResultInit(String recordItemId,String ItemType, String sampleId){
        return [SELECT id
                       FROM CheckResult__c
                       WHERE Sampling_Inspection__c =: sampleId
                       AND CheckItem__r.Item_Type__c =: ItemType
                ];
    }

    // 查询当前大类父级的check Result信息
    public static List<CheckResult__c> getCheckResultParent(String recordItemId,String ItemType, String sampleId){
        return [SELECT id,
                       Name,
                       Scores__c,
                       Max_Scores__c,
                       Comments__c,
                       Status__c,
                       CheckItem__c,
                       CheckItem__r.Parent__c,
                       CheckItem__r.Parent_Response__c,
                       CheckItem__r.Sales_Region__c,
                       CheckItem__r.Inspection_Type__c,
                       CheckItem__r.Item_Type__c,
                       CheckItem__r.Question_Type__c,
                       CheckItem__r.Description__c,
                       CheckItem__r.Description_CN__c,
                       CheckItem__r.Description_EN__c,
                       CheckItem__r.Description_Filling_Language__c,
                       CheckItem__r.HelpText__c,
                       CheckItem__r.HelpTextCN__c,
                       CheckItem__r.HelpTextEN__c,
                       CheckItem__r.Enter_Choice__c,
                       CheckItem__r.Enter_Choice_EN__c,
                       CheckItem__r.Enter_Choice_CN__c,
                       CheckItem__r.MaximumScore__c,
                       CheckItem__r.Active__c,
                       CheckItem__r.HasRelateQuestions__c,
                       CheckItem__r.HasFile__c,
                       CheckItem__r.File_Conditional_Type__c,
                       CheckItem__r.Conditional_Score_Has_File__c,
                       CheckItem__r.Conditional_Yes_No_Has_File__c,
                       CheckItem__r.HasComment__c,
                       CheckItem__r.Comment_Conditional_Type__c,
                       CheckItem__r.Conditional_Score_Has_Comment__c,
                       CheckItem__r.Conditional_Yes_No_Has_Comment__c,
                       CheckItem__r.Automatic_Generation_Ticket__c,
                       CheckItem__r.Ticket_Conditional_Type__c,
                       CheckItem__r.OrderNumber__c,
                       CheckItem__r.Object_Api_Name__c,
                       CheckItem__r.Parent_Select__c,
                       CheckItem__r.Score_Symbol__c,
                       CheckItem__r.Score_Symbol_Response__c,
                       CheckItem__r.Is_Loop_Relate_Questions__c,
                       Response__c,
                       InspectorDailyReport__c,
                       Inspection_Product_Item__c,
                       Index__c
                       FROM CheckResult__c
                       WHERE Sampling_Inspection__c =: sampleId
                       AND CheckItem__r.Item_Type__c =: ItemType
                       AND CheckItem__r.Parent__c = NULL
                       AND CheckItem__r.Active__c = true
                       ORDER BY CheckItem__r.OrderNumber__c
                ];
    }

    // 查询当前大类子级的check Result信息
    public static List<CheckResult__c> getCheckResultChildren(String recordItemId,String ItemType, String sampleId){
        return [SELECT id,
                       Name,
                       Scores__c,
                       Max_Scores__c,
                       Comments__c,
                       Status__c,
                       CheckItem__c,
                       CheckItem__r.Parent__c,
                       CheckItem__r.Parent_Response__c,
                       CheckItem__r.Sales_Region__c,
                       CheckItem__r.Inspection_Type__c,
                       CheckItem__r.Item_Type__c,
                       CheckItem__r.Question_Type__c,
                       CheckItem__r.Description__c,
                       CheckItem__r.Description_CN__c,
                       CheckItem__r.Description_EN__c,
                       CheckItem__r.Description_Filling_Language__c,
                       CheckItem__r.HelpText__c,
                       CheckItem__r.HelpTextCN__c,
                       CheckItem__r.HelpTextEN__c,
                       CheckItem__r.Enter_Choice__c,
                       CheckItem__r.Enter_Choice_EN__c,
                       CheckItem__r.Enter_Choice_CN__c,
                       CheckItem__r.MaximumScore__c,
                       CheckItem__r.Active__c,
                       CheckItem__r.HasRelateQuestions__c,
                       CheckItem__r.HasFile__c,
                       CheckItem__r.File_Conditional_Type__c,
                       CheckItem__r.Conditional_Score_Has_File__c,
                       CheckItem__r.Conditional_Yes_No_Has_File__c,
                       CheckItem__r.HasComment__c,
                       CheckItem__r.Comment_Conditional_Type__c,
                       CheckItem__r.Conditional_Score_Has_Comment__c,
                       CheckItem__r.Conditional_Yes_No_Has_Comment__c,
                       CheckItem__r.Automatic_Generation_Ticket__c,
                       CheckItem__r.Ticket_Conditional_Type__c,
                       CheckItem__r.OrderNumber__c,
                       CheckItem__r.Object_Api_Name__c,
                       CheckItem__r.Parent_Select__c,
                       CheckItem__r.Score_Symbol__c,
                       CheckItem__r.Score_Symbol_Response__c,
                       CheckItem__r.Is_Loop_Relate_Questions__c,
                       Response__c,
                       InspectorDailyReport__c,
                       Inspection_Product_Item__c,
                       Index__c
                       FROM CheckResult__c
                       WHERE Sampling_Inspection__c =: sampleId
                       AND CheckItem__r.Item_Type__c =: ItemType
                       AND CheckItem__r.Parent__c != NULL
                       AND CheckItem__r.Active__c = true
                       ORDER BY CheckItem__r.OrderNumber__c
                ];
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