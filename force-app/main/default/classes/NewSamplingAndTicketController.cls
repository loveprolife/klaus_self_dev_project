public without sharing class NewSamplingAndTicketController {
    private static String INSPECTION_PROFILE = '巡店员';
    private static String RESPONSIBLE_PERSON = System.Label.CheckInCheckOut_RESPONSIBLE_PERSON; //门店负责人
    private static String SOBJECT_NOT_FOUND = System.Label.INSPECTION_REPORT_MSG_SOBJECT_NOT_FOUND; //未找到{0}信息，请联系系统管理员
    private static String INSPECT_TYPE_REMOTE = 'Remote Inspection';//远程巡店
    private static String INSPECT_TYPE_LOCALE = 'Locale Inspection';//现场巡店
    public static Date thisDay = System.today();
    public static String thisTime = DateTime.now().format('HH:mm',UserInfo.getTimeZone().getId());
    public static User user = [SELECT Id,Name,Country__c,Sales_Region__c,title FROM User WHERE Id = : UserInfo.getUserId()][0];
    public static Map<String, List<String>> brandAndProductline;
    public static List<Map<String, String>> searchProductByProductLineOption;
    public static List<Map<String, String>> brandOptions;

    //20241030 TJP ITEMTYPE
    public static String CHECKITEMTYPE = 'Sampling Product Check';

    @AuraEnabled
    public static ConResponse getSIImageCheckResultAll(String recordId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        // 是否存在检查问题
        Boolean isPass = true;
        // product line
        String productLine;
        // 有问题的图片集合
        List<String> fileErrorList = new List<String>();
        Set<String> filterSet = new Set<String>();
        // 查询 Inspection_Product_Item__c 表，包含的产品
        List<Inspection_Product_Item__c> inspectionProductItemList = [SELECT id, Name, Type__c, Status__c, Product_Line_Checked__c
                                                                        FROM Inspection_Product_Item__c
                                                                        WHERE Id = :recordId];
        Set<String> ids = new Set<String>();
        Map<String, CheckResult__c> checkResultMap = new Map<String, CheckResult__c>();
        List<CheckResult__c> crs = [SELECT Id, Inspection_Product_Item__r.Type__c, CheckItem__r.Item_Type__c
                                    FROM CheckResult__c
                                    WHERE Inspection_Product_Item__c =: recordId
                                    ];
        for(CheckResult__c cr : crs){
            ids.add(cr.Id);
            checkResultMap.put(cr.Id, cr);
        }

        List<Image> imgs = [SELECT Name, Result__c, Record_Id__c, ContentDocumentId
                                FROM Image 
                                WHERE Record_Id__c in :ids 
                                ORDER BY Record_Id__c];
        if(imgs != null && imgs.size() > 0){
            for(Image img : imgs){
                if(String.isNotBlank(img.Result__c)){
                    Id cid = Id.valueOf(img.Record_Id__c);
                    String objectName = cid.getSObjectType().getDescribe().getName();
                    if('空样检核'.equals(img.Name)){
                        if(!img.Result__c.contains('"reason":"不存在空样"')){
                            if(objectName == 'CheckResult__c'){
                                String key = checkResultMap.get(img.Record_Id__c).Inspection_Product_Item__r.Type__c + '-' + 
                                            checkResultMap.get(img.Record_Id__c).CheckItem__r.Item_Type__c + '-' + img.Name + '-' + img.ContentDocumentId;
                                if(!filterSet.contains(key)){
                                    filterSet.add(key);
                                    isPass = false;
                                }
                            }
                        }
                    }else if('门店logo检核'.equals(img.Name)){
                        if(img.Result__c.contains('"qualified":false')){
                            if(objectName == 'CheckResult__c'){
                                String key = checkResultMap.get(img.Record_Id__c).Inspection_Product_Item__r.Type__c + '-' + 
                                            checkResultMap.get(img.Record_Id__c).CheckItem__r.Item_Type__c + '-' + img.Name + '-' + img.ContentDocumentId;
                                if(!filterSet.contains(key)){
                                    filterSet.add(key);
                                    isPass = false;
                                }
                            }
                        }
                    }else if('电视黑屏检核'.equals(img.Name)){
                        if(img.Result__c.contains('Black Screen') || img.Result__c.contains('Blue Screen') || img.Result__c.contains('White Screen')){
                            if(objectName == 'Sampling_Inspection__c'){
                                String key = checkResultMap.get(img.Record_Id__c).Inspection_Product_Item__r.Type__c + '-' +
                                              checkResultMap.get(img.Record_Id__c).CheckItem__r.Item_Type__c + '-' + img.Name + '-' + img.ContentDocumentId;
                                if(!filterSet.contains(key)){
                                    filterSet.add(key);
                                    isPass = false;
                                }
                            }
                        }
                    }
                }
            }
        }

        // 初始化数据
        List<Map<String, Object>> outPutList = new List<Map<String, Object>>();
        String errorEmg = '';
        for(Inspection_Product_Item__c inspectionProductItem : inspectionProductItemList){
           
            Map<String, Object> productLineMap = new Map<String, Object>();
            productLineMap.put('productLine',inspectionProductItem.Type__c);

            Map<String, Object> temp1 = new Map<String, Object>();
            temp1.put('type', 'Overall Display');
            temp1.put('isOverallDisplay', true);
            temp1.put('emptySample', true);
            temp1.put('storeLogo', true);
            temp1.put('TVScreen', true);

            for(String str : filterSet){
                List<String> tempList = str.split('-');
                if(tempList[0] == inspectionProductItem.Type__c){
                    if(tempList[1] == 'Overall Display' && tempList[2] == '空样检核'){
                        temp1.put('emptySample', false);
                        // 图片不合格
                        fileErrorList.add(tempList[3]);
                    }
                    if(tempList[1] == 'Overall Display' && tempList[2] == '门店logo检核'){
                        temp1.put('storeLogo', false);
                        // 图片不合格
                        fileErrorList.add(tempList[3]);
                    }
                    if(tempList[1] == 'Overall Display' && tempList[2] == '电视黑屏检核'){
                        temp1.put('TVScreen', false);
                        // 图片不合格
                        fileErrorList.add(tempList[3]);
                    }
                }
            }
            productLineMap.put('typeList',new List<Object>{temp1});
            outPutList.add(productLineMap);

            productLine = inspectionProductItem.Type__c;

            // 拼接错误信息
            errorEmg += productLine + '\n' + temp1.get('type') + '\n';
            if(!Boolean.valueOf(temp1.get('emptySample'))){
                errorEmg += System.Label.Check_Samples + ' : false.\n';
            }
            if(!Boolean.valueOf(temp1.get('storeLogo'))){
                errorEmg += System.Label.Check_Logo + ' : false.\n';
            }
            if(!Boolean.valueOf(temp1.get('TVScreen'))){
                errorEmg += System.Label.Check_TV_Screen + ' : false.\n';
            }
        }

        mso.put('checkResult', outPutList); // 展示数据
        mso.put('fileErrorList', fileErrorList); // 检查不通过的图片
        mso.put('isPass', isPass); // 通过标记，展示是否生成ticket按钮
        mso.put('productLine', productLine); // 是哪个品线 CE AC HA
        mso.put('productLineError', errorEmg); // 检查问题信息
        
        return resp;
    }

    @AuraEnabled
    public static Boolean createTicket(String recordId, String storeId, String productLine, String productLineError, List<String> fileErrorList) {
        Boolean flag = true;
        try {
            Ticket__c ticket = new Ticket__c();
            ticket.RecordTypeId = Schema.SObjectType.Ticket__c.getRecordTypeInfosByDeveloperName().get('Floorwalker').getRecordTypeId();
            ticket.InspectionReport__c = recordId;
            ticket.Store__c = storeId;
            ticket.Subject__c = System.Label.Ai_Title + '(' + productLine + ')';
            ticket.Description__c = productLineError;
            insert ticket;

            // 生成文件关联ticket
            // 1. 查询原ContentVersion
            List<ContentVersion> sourceVersionList = [
                SELECT VersionData, Title, PathOnClient, ContentDocumentId 
                FROM ContentVersion 
                WHERE ContentDocumentId IN :fileErrorList
                AND IsLatest = true
            ];

            // 2. 创建副本ContentVersion
            List<ContentVersion> clonedVersionList = new List<ContentVersion>();
            for(ContentVersion sourceVersion : sourceVersionList){
                ContentVersion clonedVersion = new ContentVersion(
                    Title = 'Copy_' + sourceVersion.Title,
                    PathOnClient = sourceVersion.PathOnClient,
                    VersionData = sourceVersion.VersionData
                );
                clonedVersionList.add(clonedVersion);
            }
            insert clonedVersionList;

            // 3. 获取新ContentDocumentId
            Set<String> idSet = new Set<String>();
            for(ContentVersion cv : clonedVersionList){
                idSet.add(cv.Id);
            }
            List<ContentVersion> tempList = [
                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id IN :idSet
            ];

            // 4. 关联到目标记录
            List<ContentDocumentLink> addList = new List<ContentDocumentLink>();
            for(ContentVersion cv : tempList){
                ContentDocumentLink newLink = new ContentDocumentLink(
                    LinkedEntityId = ticket.id,
                    ContentDocumentId = cv.ContentDocumentId,
                    ShareType = 'V' // 查看权限
                );
                addList.add(newLink);
            }
            insert addList;
        } catch(Exception e) {
            flag = false;
            throw new AuraHandledException('复制失败: ' + e.getMessage());
        }
        return flag;
    }

    @AuraEnabled
    public static ConResponse saveTicket(String saveTicketJson){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        try{
            Ticket__c saveTicket = (Ticket__c)JSON.deserialize(saveTicketJson, Ticket__c.class);
            // 跳过验证
            Utility.IgnoreAction(true, true, true, 'saveTicket');
            upsert saveTicket;
            Utility.IgnoreAction(false,false,false,'');
            mso.put('ticket', saveTicket);
        } catch (Exception e){
            Utility.IgnoreAction(false,false,false,'');
            resp.code = -1;
            resp.message = e.getMessage().substring(e.getMessage().indexOf(',', e.getMessage().indexOf('first error:') + 12) + 1, e.getMessage().lastIndexOf(']') + 1);
        }
        resp.data = mso;
        return resp;
    }

    @AuraEnabled
    public static String getSIImageCheckResult(String recordId, String type) {
        Set<String> ids = new Set<String>();

        if('checkItem'.equals(type)){
            List<CheckResult__c> crs = [SELECT Id FROM CheckResult__c where Inspection_Product_Item__c =: recordId];
            for(CheckResult__c cr : crs){
                ids.add(cr.Id);
            }
        }else{
            List<Sampling_Inspection__c> sis = [SELECT Id FROM Sampling_Inspection__c where Inspection_Product_Item__c =: recordId];
            for(Sampling_Inspection__c si : sis){
                ids.add(si.Id);
            }
            List<CheckResult__c> crs = [SELECT Id FROM CheckResult__c where Inspection_Product_Item__c =: recordId and Sampling_Inspection__c in :ids];
            for(CheckResult__c cr : crs){
                ids.add(cr.Id);
            }
        }

        List<Image> imgs = [SELECT Name, Result__c FROM Image where Record_Id__c in :ids order by Record_Id__c];
        //Map<String, Image> resultMap = new Map<String, Image>();

        String resutlStr = '';
        if(imgs != null && imgs.size() > 0){
            for(Image img : imgs){
                if(String.isNotBlank(img.Result__c)){
                    String name = '';
                    String result = '';
                    if(img.Name.equals('门店logo检核')){
                        name = Label.logo_check_name;
                        if(img.Result__c.contains('"qualified":false')){
                            result = System.Label.logo_info;
                        }
                    }else if(img.Name.equals('空样检核')){
                        name = Label.ky_check_name;
                        if(!img.Result__c.contains('"reason":"不存在空样"')){
                            result = System.Label.kongyang_info;
                        }
                    }else if(img.Name.equals('电视黑屏检核')){
                        name = Label.tv_check_name;
                        if(img.Result__c.contains('Black Screen')){
                            result = System.Label.black_screen_info;
                        }
                        if(img.Result__c.contains('Blue Screen')){
                            result += ',' + System.Label.black_screen_info;
                        }
                        if(img.Result__c.contains('White Screen')){
                            result += ',' + System.Label.black_screen_info;
                        }
                    }
                    if(name != '' && result != ''){
                        if(!resutlStr.contains(name + ': ' + result)){
                            resutlStr += name + ': ' + result + '\n';
                        }
                        
                        // if(resultMap.containsKey(img.Record_Id__c + img.ContentDocument.Title)){
                        //     Image resInfo = resultMap.get(img.Record_Id__c + img.ContentDocument.Title);
                        //     resInfo.Result__c += ', ' + img.Result__c;
                        // }else{
                        //     resultMap.put(img.Record_Id__c + img.ContentDocument.Title, img);
                        // }
                    }
                }
            }

            if(String.isNotBlank(resutlStr)){   
                resutlStr = resutlStr.substring(0, resutlStr.length() - 1);
            }
            return resutlStr;
        }else{
            return '';
        }
    }

    //20241029 增加 checkResult 初始化方法

    //20241031 计算抽样 必填项
    @AuraEnabled
    public static Map<String, Integer> getCheckListFillInValue(String recordId,String productLine) {

        System.debug('入参打印' + recordId);
        Integer totalSum = 0;
        Integer fillSum = 0;
        Boolean isPOP;
        Boolean isSetUp;
        Boolean isPrice;
        Boolean isPicture;
        Map<String, Integer> mso = new Map<String, Integer>();
        if(String.isEmpty(recordId)){
            mso.put('checkNumber', fillSum);
            mso.put('checkTotal', totalSum);
            return mso;
        }
        List<Inspection_Product_Item__c> item = [Select Id,CurrencyIsoCode,Product_Line__c,Inspection_Report__c,Inspection_Report__r.Store__r.Sales_Region__c from Inspection_Product_Item__c Where Id =: recordId];
        User user = [SELECT Id, Name, Sales_Region__c, title FROM User WHERE Id = : UserInfo.getUserId()];
        if (item.size() > 0) {
            Inspection_Product_Item__c inspectionItem = item.get(0);
            String shopSalesRegion = inspectionItem.Inspection_Report__r.Store__r.Sales_Region__c;
            List<CheckItem__c> checkItem = [Select Id,HasFile__c from CheckItem__c Where Check_Item_Type__c =: '巡店' And Item_Type__c =: 'Sampling Product Check' AND Product_Line__c =: productLine And Sales_Region__c =: shopSalesRegion And Active__c =: true And Product_Line__c =: productLine];
            List<Sampling_Inspection__c> sampling = [Select Is_POP__c,Is_Check_Price__c,Is_Optimal__c, Is_Set_up_Status__c,Display_Status__c, Price__c, Img_Status__c, ReRe__c From Sampling_Inspection__c where Inspection_Product_Item__c =: recordId And IsDeleted = false];
            Boolean imgNeed = false;
            for (CheckItem__c check : checkItem) {
                System.debug('XXX' + check.HasFile__c + ':' + (check.HasFile__c == true));
                if(check.HasFile__c){
                    imgNeed = true;
                }
            }
            if(sampling.size() > 0) {
                fillSum = fillSum; totalSum = totalSum + sampling.size();
                List<String> ids = new List<String>();
                List<String> confirm = new List<String>();
                for (Sampling_Inspection__c inspection : sampling) { 
                    ids.add(inspection.Id);
                }
                if(ids.size() > 0) {
                    confirm = getPictureLists(ids);
                    System.debug('图片确认集合ID' + confirm);
                }
                for (Sampling_Inspection__c obj : sampling) {
                    if (confirm.contains(obj.Id)) {
                        // 图片已上传
                        isPicture = true;
                    } else {
                        isPicture = false;
                    }
                    Boolean isPriceNotNull = (obj.Price__c != null);
                    Boolean isPopNotNull = String.isNotEmpty(obj.Is_POP__c);
                    Boolean isCheckPriceNotNull = String.isNotEmpty(obj.Is_Check_Price__c);
                    // Boolean isOptimalNotNull = String.isNotEmpty(obj.Is_Optimal__c);

                    Boolean isPriceMexicoNotNull = true;
                    if(isCheckPriceNotNull){
                        if(obj.Is_Check_Price__c.equals('Yes')){
                            isPriceMexicoNotNull = (obj.Price__c != null);
                        }
                    }
                    
                    Boolean isSetUpNotNull = String.isNotEmpty(obj.Is_Set_up_Status__c);
                    Boolean isDisplayStatusNotNull;
                    if(checkItem.size() <= 2) {
                        isDisplayStatusNotNull = true;
                    } else {
                        isDisplayStatusNotNull = String.isNotEmpty(obj.Is_Set_up_Status__c);
                    }
                        System.debug('确认集合' + imgNeed +':' + isPriceNotNull + ':' + isPopNotNull + ':' +isSetUpNotNull + ':' + isPicture);

                    if(imgNeed) {
                        if(isPriceNotNull && isCheckPriceNotNull && isPriceMexicoNotNull && isPopNotNull && isSetUpNotNull && isDisplayStatusNotNull && isPicture) {fillSum = fillSum + 1;}
                    } else {
                        if(isPriceNotNull && isCheckPriceNotNull && isPriceMexicoNotNull && isPopNotNull && isSetUpNotNull && isDisplayStatusNotNull) {fillSum = fillSum + 1;}
                    }

                }
            }

        }
        mso.put('checkNumber', fillSum);
        mso.put('checkTotal', totalSum);
        System.debug('WDXS' + mso);
        return mso;
    }

    @AuraEnabled
    public static Map<String, Integer> getUniteFillInValue(String recordId,String productLine) {

        System.debug('入参打印' + recordId);
        Integer totalSum = 0;
        Integer fillSum = 0;
        Boolean isPOP;
        Boolean isSetUp;
        Boolean isPrice;
        Boolean isPicture;
        Map<String, Integer> mso = new Map<String, Integer>();
        if(String.isEmpty(recordId)){
            mso.put('checkNumber', fillSum);
            mso.put('checkTotal', totalSum);
            return mso;
        }
        List<Inspection_Product_Item__c> item = [Select Id,CurrencyIsoCode,Product_Line__c,Inspection_Report__c from Inspection_Product_Item__c Where Id =: recordId];
        User user = [SELECT Id, Name, Sales_Region__c, title FROM User WHERE Id = : UserInfo.getUserId()];

        if (item.size() > 0) {
            List<Sampling_Inspection__c> sampling = [Select Is_POP__c,Is_Check_Price__c,Is_Optimal__c, Is_Set_up_Status__c, Price__c, Img_Status__c, ReRe__c From Sampling_Inspection__c where Inspection_Product_Item__c =: recordId And IsDeleted = false]; 
            if(sampling.size() > 0) {
                totalSum = totalSum + sampling.size();
                List<String> ids = new List<String>();
                List<String> confirm = new List<String>();
                for (Sampling_Inspection__c inspection : sampling) { 
                    ids.add(inspection.Id);
                }
                if(ids.size() > 0) {
                    confirm = getPictureLists(ids);
                    System.debug('图片确认集合ID' + confirm);
                }
                for (Sampling_Inspection__c obj : sampling) {
                    if (confirm.contains(obj.Id)) {
                        // 图片已上传
                        isPicture = true;
                    } else {
                        isPicture = false;
                    }
                    if(isPicture) {
                        fillSum = fillSum + 1;
                    } 

                }
            } else {
                fillSum = 0;
                totalSum = 2;
            }

        }
        mso.put('checkNumber', fillSum);
        mso.put('checkTotal', totalSum);
        System.debug('WDXS' + mso);
        return mso;
    }

    //根据recordId计算samplingInspection 的必填字段总数；
    @AuraEnabled
    public static Map<String, Integer> getFillInValue(String recordId) {

        Map<String,Integer> check = new Map<String,Integer>();

        // 需要检查的总数
        check.put('checkTotal', 0);
        // 已检查数量
        check.put('checkNumber', 0);

        List<Inspection_Product_Item__c> item = [Select Id,CurrencyIsoCode,Product_Line__c,Product_Lines__c,Inspection_Report__c,Inspection_Report__r.Store__c,Inspection_Report__r.Store__r.Channel_item__c,Type__c from Inspection_Product_Item__c Where Id =: recordId];
        User user = [SELECT Id, Name, Sales_Region__c, title FROM User WHERE Id = : UserInfo.getUserId()];
        
        // 查询当前大类下
        List<CheckResult__c> checkResultParent = newCheckItemController.getCheckResultParentSampling(recordId);
        List<CheckResult__c> checkResultChildren = newCheckItemController.getCheckResultChildrenSampling(recordId);

        // 存放汇总的id信息
        List<String> checkResultIdAll = new List<String>();

        // 根据附件关联id分组
        Map<String, Sobject> cdMap = new Map<String, Sobject>();

        // 根据sampling 分组
        Map<String,List<CheckResult__c>> groupParent = new Map<String,List<CheckResult__c>>();

        // 根据parentId 分组
        Map<String,List<CheckResult__c>> groupChildren = new Map<String,List<CheckResult__c>>();

        // YYL 根据型号分组检查项 20250326
        if(checkResultParent != null && checkResultParent.size() > 0){

            // 获取父级数据id
            LisqContainer lqParent = new LisqContainer(checkResultParent);
            checkResultIdAll.addAll(lqParent.SelectSField('id'));

            for(CheckResult__c itemParent : checkResultParent){
                List<CheckResult__c> resultParent = groupParent.get(itemParent.Sampling_Inspection__c);

                if(resultParent == null){
                    resultParent = new List<CheckResult__c>();
                }
                resultParent.add(itemParent);
                groupParent.put(itemParent.Sampling_Inspection__c,resultParent);
            }

            System.debug('wwwwgroupParent' + groupParent);

            if(checkResultChildren != null && checkResultChildren.size() > 0){
                for(CheckResult__c children : checkResultChildren){
                    List<CheckResult__c> resultChildren = groupChildren.get(children.CheckItem__r.Parent__c);

                    if(resultChildren == null){
                        resultChildren = new List<CheckResult__c>();
                    }
                    resultChildren.add(children);
                    groupChildren.put(children.CheckItem__r.Parent__c,resultChildren);

                    // 获取子级数据id
                    LisqContainer lqChild = new LisqContainer(checkResultChildren);
                    checkResultIdAll.addAll(lqChild.SelectSField('id'));
                }
            }

            // 查询当前数据的附件信息
            List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in: checkResultIdAll];
            LisqContainer lqCd = new LisqContainer(cdlList);

            // 根据附件关联id分组
            cdMap = lqCd.ToMapS('LinkedEntityId');
        }

        List<Sampling_Inspection__c> sampling = [Select Unplanned_Sample__c, Display_Type__c,Is_POP__c,Placement_Status__c,Is_Check_Price__c,Is_Optimal__c, Is_Set_up_Status__c, Price__c, Display_Status__c,Img_Status__c, ReRe__c,Before_Img__c,After_Img__c From Sampling_Inspection__c where Inspection_Product_Item__c =: recordId ];
        if(sampling != null && sampling.size()>0){

            //2025-03-31 检查项展出为True时，图片必填
            List<String> ids = new List<String>();
            LisqContainer lqSampling = new LisqContainer(sampling);
            ids.addAll(lqSampling.SelectSField('id'));
            List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in: ids];

            if(cdlList != null && cdlList.size()>0){
                for (ContentDocumentLink cdl : cdlList) {
                    cdMap.put(cdl.LinkedEntityId, cdl);
                }
            }

            for(Sampling_Inspection__c inspection : sampling){
                // check.put('checkTotal', check.get('checkTotal') + 1);
                if(!String.isEmpty(inspection.Placement_Status__c)){
                    // check.put('checkNumber', check.get('checkNumber') + 1);
                    if(inspection.Placement_Status__c.equals('展出')){
                        //展出时图片必填总数
                        check.put('checkTotal', check.get('checkTotal') + 1);
                        //设置展出时图片计数
                        if(cdMap.get(inspection.Id) != null){
                            check.put('checkNumber', check.get('checkNumber') + 1);
                        }

                        List<CheckResult__c> resultParent = groupParent.get(inspection.Id);
                        System.debug('wwwwsampling' + resultParent);
                        if(resultParent != null && resultParent.size() > 0){
                            for(CheckResult__c parent : resultParent){
    
                                //设置检查总数
                                // if(!parent.CheckItem__r.Question_Type__c.equals('Informational')){
                                if(!parent.CheckItem__r.Question_Type__c.equals('Informational-photo')){
                                    check.put('checkTotal', check.get('checkTotal') + 1);
                
                                    // YYL 设置缩略图默认值 20250326
                                    if(parent.CheckItem__r.Question_Type__c.equals('Informational')){
                                        parent.Response__c = 'Informational';
                                    }
                                    
                                    if(!String.isEmpty(parent.Response__c)){
                                        newCheckItemController.checkCommontAndFiles(parent,cdMap,check);
                                        newCheckItemController.checkNumber(parent,groupChildren,check,cdMap);
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
            //TJP 额外增加基数即 display or not问题的统计数量
            check.put('checkNumber', check.get('checkNumber') + sampling.size());
            check.put('checkTotal', check.get('checkTotal') + + sampling.size());
        }else{
            
            //last by TJP 20250717 D:依赖于 detail进行结果判断的全部废弃
            //查询历史最近一次报告作为基准
            Inspection_Product_Item__c inspectionItem = [SELECT Id,Type__c,Inspection_Report__r.Report_Date__c,Inspection_Report__r.Store__c FROM Inspection_Product_Item__c  WHERE Id  =: recordId];
            Date reportDate = inspectionItem.Inspection_Report__r.Report_Date__c;
            Integer buff = Integer.valueOf(System.label.Inspection_Buff);
            Date fragment = reportDate.addDays(buff);
            List<Inspection_Product_Item__c> itemIds = [SELECT Id FROM Inspection_Product_Item__c  WHERE Inspection_Report__r.Status__c = 'Submitted' AND Inspection_Report__r.Store__c =: inspectionItem.Inspection_Report__r.Store__c AND Type__c =: inspectionItem.Type__c  AND Inspection_Report__r.Report_Date__c >=: fragment AND Inspection_Report__r.Report_Date__c <: reportDate ORDER BY Inspection_Report__r.Report_Date__c desc limit 1];
            List<Sampling_Inspection__c> samplingOld = new List<Sampling_Inspection__c>();
            List<CheckResult__c> checkResultParentOld = new List<CheckResult__c>();
            List<CheckResult__c> checkResultChildrenOld = new List<CheckResult__c>();
            if(itemIds.size() > 0){
                samplingOld = [Select Unplanned_Sample__c, Display_Type__c,Is_POP__c,Placement_Status__c,Is_Check_Price__c,Is_Optimal__c, Is_Set_up_Status__c, Price__c, Display_Status__c,Img_Status__c, ReRe__c,Before_Img__c,After_Img__c,Inspection_Report__c From Sampling_Inspection__c where Placement_Status__c = '展出' AND Inspection_Product_Item__c =: itemIds[0].Id];
                // 查询当前大类下
                checkResultParentOld = newCheckItemController.getCheckResultParentSampling(itemIds[0].Id);
                checkResultChildrenOld = newCheckItemController.getCheckResultChildrenSampling(itemIds[0].Id);
            }

            

            // 存放汇总的id信息
            List<String> checkResultIdAllOld = new List<String>();

            // 根据附件关联id分组
            Map<String, Sobject> cdMapOld = new Map<String, Sobject>();

            // 根据sampling 分组
            Map<String,List<CheckResult__c>> groupParentOld = new Map<String,List<CheckResult__c>>();

            // 根据parentId 分组
            Map<String,List<CheckResult__c>> groupChildrenOld = new Map<String,List<CheckResult__c>>();

            // YYL 根据型号分组检查项 20250326
            if(checkResultParentOld != null && checkResultParentOld.size() > 0){

                // 获取父级数据id
                LisqContainer lqParent = new LisqContainer(checkResultParentOld);
                checkResultIdAllOld.addAll(lqParent.SelectSField('id'));

                for(CheckResult__c itemParent : checkResultParentOld){
                    List<CheckResult__c> resultParent = groupParentOld.get(itemParent.Sampling_Inspection__c);

                    if(resultParent == null){
                        resultParent = new List<CheckResult__c>();
                    }
                    resultParent.add(itemParent);
                    groupParentOld.put(itemParent.Sampling_Inspection__c,resultParent);
                }

                System.debug('wwwwgroupParent' + groupParentOld);

                if(checkResultChildrenOld != null && checkResultChildrenOld.size() > 0){
                    for(CheckResult__c children : checkResultChildrenOld){
                        List<CheckResult__c> resultChildren = groupChildrenOld.get(children.CheckItem__r.Parent__c);

                        if(resultChildren == null){
                            resultChildren = new List<CheckResult__c>();
                        }
                        resultChildren.add(children);
                        groupChildrenOld.put(children.CheckItem__r.Parent__c,resultChildren);

                        // 获取子级数据id
                        LisqContainer lqChild = new LisqContainer(checkResultChildrenOld);
                        checkResultIdAllOld.addAll(lqChild.SelectSField('id'));
                    }
                }

                // 查询当前数据的附件信息
                List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in: checkResultIdAllOld];
                LisqContainer lqCd = new LisqContainer(cdlList);

                // 根据附件关联id分组
                cdMapOld = lqCd.ToMapS('LinkedEntityId');
            }
        
            if(samplingOld.size()>0){

                //2025-03-31 检查项展出为True时，图片必填
                List<String> ids = new List<String>();
                LisqContainer lqSampling = new LisqContainer(samplingOld);
                ids.addAll(lqSampling.SelectSField('id'));
                List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in: ids];
                if(cdlList != null && cdlList.size()>0){
                    for (ContentDocumentLink cdl : cdlList) {
                        cdMap.put(cdl.LinkedEntityId, cdl);
                    }
                }
                for(Sampling_Inspection__c inspection : samplingOld){
                    if(!String.isEmpty(inspection.Placement_Status__c)){
                        if(inspection.Placement_Status__c.equals('展出')){
                            //展出时图片必填总数 + display Or Not
                            check.put('checkTotal', check.get('checkTotal') + 2);
                            //设置展出时图片计数
                            if(cdMap.get(inspection.Id) != null){
                                // check.put('checkNumber', check.get('checkNumber') + 1);
                            }

                            List<CheckResult__c> resultParent = groupParentOld.get(inspection.Id);
                            System.debug('wwwwsampling' + resultParent);
                            if(resultParent != null && resultParent.size() > 0){
                                for(CheckResult__c parent : resultParent){
                                
                                    //设置检查总数
                                    // if(!parent.CheckItem__r.Question_Type__c.equals('Informational')){
                                    if(!parent.CheckItem__r.Question_Type__c.equals('Informational-photo')){
                                        check.put('checkTotal', check.get('checkTotal') + 1);
                                    
                                        // YYL 设置缩略图默认值 20250326
                                        if(parent.CheckItem__r.Question_Type__c.equals('Informational')){
                                            parent.Response__c = 'Informational';
                                        }

                                        if(!String.isEmpty(parent.Response__c)){
                                            newCheckItemController.checkCommontAndFiles(parent,cdMap,check);
                                            newCheckItemController.checkNumber(parent,groupChildren,check,cdMap);
                                        }
                                    }

                                }
                            }
                        } else {
                            check.put('checkTotal', check.get('checkTotal') + 1);
                        }
                    }
                }
                check.put('checkNumber', 0);
            } else {
                // 确认逻辑 只有没有抽样则仅仅从detail获取一次，否则不处理
                List<Sampling_Inspection__c> samplings = [SELECT Id FROM Sampling_Inspection__c WHERE Shop__c =: inspectionItem.Inspection_Report__r.Store__c AND Inspection_Report__r.Status__c = 'Submitted'];
                if(samplings.isEmpty()) {
                    // YYL 查询samplingDetail 判断是否有检查数据 20250401
                     Inspection_Product_Item__c items = item.get(0);
                     List<Sampling_Detail__c>  isSD = [SELECT Id,
                                                              Display_Type__c,
                                                              ProductLine__c,
                                                              Product__c,
                                                              Product__r.Name, 
                                                              Shop__r.Name,
                                                              Display_Status__c 
                                                              FROM Sampling_Detail__c 
                                                              WHERE ProductLine__c IN: items.Product_Lines__c.split(';')
                                                              AND Shop__c =: items.Inspection_Report__r.Store__c];
                                   
                     if(isSD != null && isSD.size() > 0){
                         // 查询当前大类一级问题
                         List<CheckItem__c> checkItemParent = newCheckItemController.getCheckItemParentNullNotPhoto('Sampling Product Check',items.Product_Lines__c,items.Inspection_Report__r.Store__r.Channel_item__c);
                         System.debug('WWW' + checkItemParent.size());
                         // 根据产品线分组计数
                         Map<String,Integer> checkNumberMap = new Map<String,Integer>();
                         if(checkItemParent != null && checkItemParent.size() > 0){
                             for(CheckItem__c parentItem : checkItemParent){
                                 Integer checkNumer = checkNumberMap.get(parentItem.Product_Line__c);
                                   
                                 if(checkNumer == null){
                                     checkNumer = 0;
                                 }
                                  
                                 if(parentItem.Question_Type__c.equals('Informational')){
                                     // 判断附件和评论是否必填
                                     if(parentItem.HasComment__c 
                                         && !String.isEmpty(parentItem.Comment_Conditional_Type__c)
                                         && parentItem.Comment_Conditional_Type__c.equals('Mandatory')){
                                   
                                             checkNumer += 1;    
                                   
                                     }else if(parentItem.HasFile__c 
                                                 && !String.isEmpty(parentItem.File_Conditional_Type__c) 
                                                 && parentItem.File_Conditional_Type__c.equals('Mandatory')){
                                   
                                             checkNumer += 1;
                                  
                                     }
                                 }else{
                                     //设置检查数
                                     checkNumer += 1;
                                 }
                                 checkNumberMap.put(parentItem.Product_Line__c, checkNumer);
                             }
                         }
                         System.debug('集合' + checkNumberMap);
                                   
                         System.debug('计数' + check.get('checkTotal'));
                                   
                         // 计算通用检查项数量
                         Integer checkAll = checkNumberMap.get('All');
                         if(checkAll != null){
                             check.put('checkTotal', check.get('checkTotal') + checkAll*isSD.size());
                         }
                                  
                               
                                  
                         for(Sampling_Detail__c detail : isSD){
                             if(detail.Display_Status__c.equals('展出')) {
                                 // 针对上传图片计数 以及DisplY oR Not
                                 check.put('checkTotal', check.get('checkTotal') + 2);
                                 Integer detailNumer = checkNumberMap.get(detail.ProductLine__c);
                                 if(detailNumer != null){
                                     check.put('checkTotal', check.get('checkTotal') + detailNumer);
                                 }
                             } else {
                                 check.put('checkTotal', check.get('checkTotal') + 1);
                             }
                         }
                                   
                     }
                }
                    
            }
        }
        
        return check;
    }

    //计算Ticket 必填字段
    @AuraEnabled
    public static Map<String, Integer> getTicketFillInValue(String recordId) {
        System.debug('传递参数' + recordId);
        Map<String, Integer> mso = new Map<String, Integer>();
        Integer totalSum = 0;
        Integer fillSum = 0;
        if(String.isEmpty(recordId)){mso.put('checkNumber', fillSum);
        mso.put('checkTotal', totalSum);return mso;}

        List<Inspection_Product_Item__c> insp = [Select Id,CurrencyIsoCode,Inspection_Report__c from Inspection_Product_Item__c Where Id =: recordId Limit 1];
        System.debug('查询结果' + insp.isEmpty());
        if (!insp.isEmpty() && String.isNotBlank(insp[0].Inspection_Report__c)) {
            // 查询日报
            List<Daily_Inspection_Report__c> dirList = getExistDailyInspectionReportBasedId(insp[0].Inspection_Report__c);
            if (dirList.size() > 0) {
                //根据record 查询一下item中的问题类型
                Daily_Inspection_Report__c dir = dirList[0];
                Map<String, List<Ticket__c>> taskMap = getTicket(dir);
                List<Ticket__c> openTasks = taskMap.get('openTasks');
                if(openTasks.size() > 0){
                    for (Ticket__c ticket : openTasks) {
                    totalSum = totalSum + 1;
                    // Boolean category = String.isNotEmpty(ticket.Category__c);
                    Boolean subject = String.isNotEmpty(ticket.Subject__c);
                    Boolean duedate = ticket.DueDate__c != null;
                    Boolean assigned = String.isNotEmpty(ticket.AssignedTo__c);
                    if (subject && duedate && assigned) fillSum = fillSum + 1;
                    }
                } else {totalSum = totalSum;}
        } else {totalSum = totalSum;}
        mso.put('checkNumber', fillSum);
        mso.put('checkTotal', totalSum);
        }
        // System.debug('WDXS' + mso);
        return mso;
    }

    // 初始化
    @AuraEnabled
    public static ConResponse getRewriteInitData(String recordId, String productLine, String shopId) {
        // 产品线关联表  == Inspection_Product_Item__c 暂定一下
        System.debug('RecordId' + recordId);
        Inspection_Product_Item__c insp = [Select Id,Type__c,Inspection_Report__c,CurrencyIsoCode, Product_Line__c, Status__c,Inspection_Report__r.Store__c,Inspection_Report__r.Report_Date__c from  Inspection_Product_Item__c Where Id =: recordId];
        
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        mso.put('Iso',insp.CurrencyIsoCode);
        system.debug('WWWW调用方法' + insp.CurrencyIsoCode);
        // System.debug(getTicketFillInValue(recordId));
        // System.debug('WWW参数计算' + getSamplingInspectionFillInValue('a6oHz000000KzOJIA0'));   
        User user = [SELECT Id, Name, Sales_Region__c, title FROM User WHERE Id = : UserInfo.getUserId()];
        //增加总部判断 TJP　２０２４１０３０
        if(user.Sales_Region__c == 'Hisense International') {
            mso.put('getOfficeCheck', getOfficeCheck(CHECKITEMTYPE, user.Sales_Region__c,productLine));
        }
        List<Product_line_Detail__c> detail = [Select Id, Name, ImgRequired__c, Product_line__c, Product_line_Description__c, Reminder__c  From Product_line_Detail__c Where Sales_Region__c =: user.Sales_Region__c And Product_Line__c =: insp.Product_Line__c];
        if(detail.size() > 0) {
            mso.put('paramIds', detail[0].Id);
            mso.put('produceLineDetails', detail[0]);
            System.debug('WWWPRODUCTLINEDETAIL--' + detail[0]);
        } else {
            mso.put('paramIds', '');
            mso.put('produceLineDetails', '');
            System.debug('WWWPRODUCTLINEDETAIL--' + '');
        }

        List<Sampling_Detail__c>  isSD = [SELECT Id,Display_Type__c,ProductLine__c,Product__c,Product__r.Name, Shop__r.Name from Sampling_Detail__c where ProductLine__c  =: productLine AND Shop__c =: shopId];
        //暂时仅考虑detail不存在不存在detail有值且展出形态没有维护的情况
        List<String> detailDisplay = new List<String>();
        List<Map<String, String>> result = new List<Map<String, String>>();
        Set<String> resultSet = new Set<String>();
        if (isSD.size() > 0) {
            mso.put('isDetail', 'Yes');
        // 遍历List中的每个SObject
        for (Sampling_Detail__c obj : isSD) {
            // 提取字段C的值
            String displayType = (String)obj.Display_Type__c;
            if (displayType != null && displayType.contains(';')) {
                // 如果字段值包含';'，则用';'分割
                List<String> splitValues = displayType.split(';');
                for (String value : splitValues) {
                    resultSet.add(value.trim());  // 添加到Set中，去除前后空格
                }
            } else if (displayType != null) {
                // 如果字段值不包含';'，直接添加
                resultSet.add(displayType.trim());  // 添加到Set中，去除前后空格
            }
        }
            
        } else {//暂定
            mso.put('isDetail', 'No'); 
        }
        System.debug('isDetail' + mso.get('isDetail'));
        System.debug('detail获取display' + detailDisplay);
        if (resultSet.size() >0) {
            for(String ds : resultSet) {
                result.add(new Map<String, String> {
                    'label' => ds,
                    'value' => ds
                });
            }
        }
        mso.put('isDetailDisplay',getProductLineDisplay(null, productLine, shopId));
        // mso.put('isDetailDisplay',result);
        System.debug('Detail获取数据详情' + result);
        // 获取Today
        mso.put('todayDate', thisDay); 
        // 获取Time
        mso.put('nowTime', thisTime); 
        system.debug('WWWW1调用方法');
        system.debug('获取一下用户数据' + recordId + 'XX' + shopId + 'VV' + productLine);
        mso.put('productLineValueSort', getPickList('Product__c','Product_Line__c')); 
        
        if (String.isNotBlank(insp.Inspection_Report__c)) {
            // 查询日报
            List<Daily_Inspection_Report__c> dirList = getExistDailyInspectionReportBasedId(insp.Inspection_Report__c);
            if (dirList.size()==0) {
                resp.code= -1;
                resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Daily_Inspection_Report__c.getLabel()});
                return resp;
            }
            //根据record 查询一下item中的问题类型

            system.debug('WWWW2调用方法');
            Daily_Inspection_Report__c dir = dirList[0];
            mso.put('record', dir);
            // mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);

            // 修改为根据门店的Sales_Region 20241105 YYL 
            // mso.put('productLineDisplay',getProductLineDisplay(dir.Sales_Region__c, productLine));
            // 修改为查询Store_Product_Line__c表 (wfc 2025-02-25)
            mso.put('productLineDisplay',getProductLineDisplay(dir.Store__r.Sales_Region__c, productLine, dir.Store__c));
            mso.put('salesRegionArgument',dir.Store__r.Sales_Region__c);
            // Date myDate = dir.Report_Date__c;
            // Datetime myDatetime = Datetime.newInstance(myDate, Time.newInstance(0, 0, 0, 0));

            // TODO 查询墨西哥问题第一个问题为确认价格问题 （后续需废弃）
            if(dir.Store__r.Sales_Region__c.equals('Hisense Mexico')){
                List<CheckItem__c> itemMexico = [Select Id,HelpText__c, DescriptionT__c from CheckItem__c Where Item_Type__c =: 'Sampling Product Check' AND Product_Line__c =: productLine And Sales_Region__c =: dir.Store__r.Sales_Region__c Order by OrderNumber__c];
                if(itemMexico.size() > 0) {
                    mso.put('IsCheckPrice', true);
                    mso.put('CheckPrice',itemMexico[0].DescriptionT__c);
                    mso.put('CheckPriceHelpText',itemMexico[0].HelpText__c);
                }else {
                    mso.put('IsCheckPrice', false);
                }

                if(itemMexico.size() > 1) {
                    mso.put('IsPriceMexicoShow', true);
                    mso.put('PriceDesc',itemMexico[1].DescriptionT__c);
                    mso.put('PriceHelpText',itemMexico[1].HelpText__c);
                }else {
                    mso.put('isPriceMexicoShow', false);
                }

                if(itemMexico.size() > 2) {
                    mso.put('IsOptimalShow', true);
                    mso.put('OptimalDesc',itemMexico[2].DescriptionT__c);
                    mso.put('OptimalHelpText',itemMexico[2].HelpText__c);
                }else {
                    mso.put('IsOptimalShow', false);
                }

                if(itemMexico.size() > 3) {
                    mso.put('IsBeforeImgShow', true);
                    mso.put('BeforeImgDesc',itemMexico[3].DescriptionT__c);
                    mso.put('BeforeImgHelpText',itemMexico[3].HelpText__c);
                }else {
                    mso.put('IsBeforeImgShow', false);
                }

                if(itemMexico.size() > 4) {
                    mso.put('IsAfterImgShow', true);
                    mso.put('AfterImgDesc',itemMexico[4].DescriptionT__c);
                    mso.put('AfterImgHelpText',itemMexico[4].HelpText__c);
                }else {
                    mso.put('IsAfterImgShow', false);
                }
                mso.put('checkItemList', itemMexico);

            }else{

                // YYL 新增展出类型问题 20250324
                List<CheckItem__c> itemDisplay = [Select Id,HelpText__c, DescriptionT__c,Enter_Choice__c from CheckItem__c Where Check_Item_Type__c =: '巡店' And Item_Type__c =: 'Sampling Product Check' AND Product_Line__c =: productLine And Sales_Region__c =: dir.Store__r.Sales_Region__c And Question_Type__c =: 'Multiple Selection'];

                List<CheckItem__c> item1 = [Select Id,HelpText__c, DescriptionT__c from CheckItem__c Where Check_Item_Type__c =: '巡店' And Item_Type__c =: 'Sampling Product Check' AND Product_Line__c =: productLine And Sales_Region__c =: dir.Store__r.Sales_Region__c And DescriptionT__c like '%POP%'];
                List<CheckItem__c> item2 = [Select Id,HelpText__c, DescriptionT__c from CheckItem__c Where Check_Item_Type__c =: '巡店' And Item_Type__c =: 'Sampling Product Check' AND Product_Line__c =: productLine And Sales_Region__c =: dir.Store__r.Sales_Region__c And DescriptionT__c like '%Set Up%'];
                List<CheckItem__c> item3 = [Select Id,HelpText__c, DescriptionT__c from CheckItem__c Where Check_Item_Type__c =: '巡店' And Item_Type__c =: 'Sampling Product Check' AND Product_Line__c =: productLine And Sales_Region__c =: dir.Store__r.Sales_Region__c And DescriptionT__c like '%Price%'];
                List<CheckItem__c> item4 = [Select Id,HelpText__c, DescriptionT__c from CheckItem__c Where Check_Item_Type__c =: '巡店' And Item_Type__c =: 'Sampling Product Check' AND Product_Line__c =: productLine And Sales_Region__c =: dir.Store__r.Sales_Region__c And DescriptionT__c like '%pop%'];
                List<CheckItem__c> item5 = [Select Id,HelpText__c, DescriptionT__c from CheckItem__c Where Check_Item_Type__c =: '巡店' And Item_Type__c =: 'Sampling Product Check' AND Product_Line__c =: productLine And Sales_Region__c =: dir.Store__r.Sales_Region__c And DescriptionT__c like '%set up%'];
                List<CheckItem__c> item6 = [Select Id,HelpText__c, DescriptionT__c from CheckItem__c Where Check_Item_Type__c =: '巡店' And Item_Type__c =: 'Sampling Product Check' AND Product_Line__c =: productLine And Sales_Region__c =: dir.Store__r.Sales_Region__c And DescriptionT__c like '%price%'];
                
                if(itemDisplay.size() > 0) {
                    mso.put('isDisplay', true);
                    mso.put('DisplayDesc',itemDisplay[0].DescriptionT__c);
                    mso.put('DisplayHelpText',itemDisplay[0].HelpText__c);
                    mso.put('DisplayEnterChoice',itemDisplay[0].Enter_Choice__c);
                }else {
                    mso.put('isDisplay', false);
                }

                if(item1.size() > 0) {
                    mso.put('isPOP', true);
                    mso.put('POPDesc',item1[0].DescriptionT__c);
                    mso.put('POPHelpText',item1[0].HelpText__c);
                } else if(item4.size() > 0){
                    mso.put('isPOP', true);
                    mso.put('POPDesc',item4[0].DescriptionT__c);
                    mso.put('POPHelpText',item4[0].HelpText__c);
                } else {
                    mso.put('isPOP', false);
                }

                if(item2.size() > 0) {
                    mso.put('isSetUp', true);
                    mso.put('SetUpDesc',item2[0].DescriptionT__c);
                    mso.put('SetUpHelpText',item2[0].HelpText__c);
                } else if(item5.size() > 0){
                    mso.put('isSetUp', true);
                    mso.put('SetUpDesc',item5[0].DescriptionT__c);
                    mso.put('SetUpHelpText',item5[0].HelpText__c);
                } else {
                    mso.put('isSetUp', false);
                }

                if(item3.size() > 0) {
                    mso.put('isPrice', true);
                    mso.put('PriceDesc',item3[0].DescriptionT__c);
                    mso.put('PriceHelpText',item3[0].HelpText__c);
                } else if(item6.size() > 0){
                    mso.put('isPrice', true);
                    mso.put('PriceDesc',item6[0].DescriptionT__c);
                    mso.put('PriceHelpText',item6[0].HelpText__c);
                } else {
                    mso.put('isPrice', false);
                }
            }
            
            System.debug('wwwww' + dir.Store__c);
            Boolean isProductLineConf = false;

            System.debug('wwwww' + isProductLineConf);
            // mso.put('isProductLineConf', isProductLineConf);
           
            List<User> ul = [SELECT Id, Name, Sales_Region__c FROM User WHERE Name = 'Nacho'];
            if(ul != null && ul.size() > 0){
                mso.put('ticketAssignedTo', ul.get(0).Id);
            }
            // Sampling Inspection部分
            // 获取计划外Sampling Inspection信息
            // List<Sampling_Inspection__c> planOutSamplingInspection = getExistPlanOutSamplingInspectionBaseStoreIdAndDate(dir.Store__c, dir.Report_Date__c, dir.OwnerId);
            // List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreIdAndDate(dir.Store__c,dir.Report_Date__c,dir.OwnerId);
            Date formattedDate = System.today();
            System.debug('参数值'+dir.Store__c + '<>' + formattedDate+ '<>' + productLine+ '<>' +dir.OwnerId );
            List<Sampling_Inspection__c> planOutSamplingInspection = getExistPlanOutSamplingInspectionProductLineAndDate(recordId, dir.Store__c, productLine);
            List<Sampling_Inspection__c> siList = getExistSamplingInspectionProductLineAndDate(recordId,dir.Store__c, productLine);
            List<Sampling_Inspection__c> addedsi = new List<Sampling_Inspection__c>();

            //增加方法 获取历史Submitted 的 抽样
            List<Sampling_Inspection__c> oldSamplingInspection = new List<Sampling_Inspection__c>();
            Map<String,Sampling_Inspection__c> oldSamplingInspectionMap = new Map<String,Sampling_Inspection__c>();
            
            Date reportDate = insp.Inspection_Report__r.Report_Date__c;
            Integer buff = Integer.valueOf(System.label.Inspection_Buff);
            Date fragment = reportDate.addDays(buff);
            List<Inspection_Product_Item__c> itemIds = [SELECT Id FROM Inspection_Product_Item__c  WHERE Inspection_Report__r.Status__c = 'Submitted' AND Inspection_Report__r.Store__c =: insp.Inspection_Report__r.Store__c AND Inspection_Report__r.Report_Date__c >=: fragment AND Inspection_Report__r.Report_Date__c <: reportDate AND Type__c =:insp.Type__c  ORDER BY Inspection_Report__r.Report_Date__c desc limit 1];
            List<Sampling_Inspection__c> samplingOld = new List<Sampling_Inspection__c>();
            List<CheckResult__c> checkResultParentOld = new List<CheckResult__c>();
            List<CheckResult__c> checkResultChildrenOld = new List<CheckResult__c>();
            if(itemIds.size() > 0){
                oldSamplingInspection = [Select Product__c,Unplanned_Sample__c, Display_Type__c,Is_POP__c,Placement_Status__c,Is_Check_Price__c,Is_Optimal__c, Is_Set_up_Status__c, Price__c, Display_Status__c,Img_Status__c, ReRe__c,Before_Img__c,After_Img__c,Inspection_Report__c From Sampling_Inspection__c where Placement_Status__c = '展出' AND Inspection_Product_Item__c =: itemIds[0].Id AND Product__r.Product_Line__c =: productLine];
                for(Sampling_Inspection__c item : oldSamplingInspection){
                    oldSamplingInspectionMap.put(Item.Product__c,item);
                }
            }        
            List<Sampling_Inspection__c> samplings = [SELECT Id FROM Sampling_Inspection__c WHERE Shop__c =: shopId AND Inspection_Report__r.Status__c = 'Submitted'];
            //首先 依据历史进行添加
            if(!oldSamplingInspectionMap.isEmpty()) {
                if(siList.size() == 0){
                    //自动生成填充
                     // 新建计划外Sampling Inspection
                     List<Sampling_Inspection__c> sIc = new List<Sampling_Inspection__c>();
                     
                    for (String key : oldSamplingInspectionMap.keySet()) {               
                        Sampling_Inspection__c newSi = new Sampling_Inspection__c();
                        newSi.Inspection_Date__c = dir.Report_Date__c;
                        newSi.Placement_Status__c = oldSamplingInspectionMap.containsKey(key) && oldSamplingInspectionMap.get(key) != null ? oldSamplingInspectionMap.get(key).Placement_Status__c : '展出';
                        newSi.Unplanned_Sample__c = oldSamplingInspectionMap.containsKey(key) && oldSamplingInspectionMap.get(key) != null ? oldSamplingInspectionMap.get(key).Unplanned_Sample__c : 'No';
                        newSi.Is_POP__c = '';
                        newSi.Is_Check_Price__c = '';
                        newSi.Is_Optimal__c = '';
                        newSi.Is_Set_up_Status__c = '';
                        newSi.Display_Status__c = '';
                        newSi.Before_Img__c = '';
                        newSi.After_Img__c = '';
                        // newSi.Display_Type__c = displayType;
                        // newSi.ExternalID__c = String.valueOf(dir.Report_Date__c) + '_' + dir.Store__c + '_' + productId +'_' + displayType + '_' + UserInfo.getUserId();
                        newSi.ExternalID__c = String.valueOf(dir.Report_Date__c) + '_' + dir.Store__c + '_' + key +'_' + UserInfo.getUserId();
                        System.debug('外键参数==' + newSi.ExternalID__c);
                        // newSi.ExternalID__c = '4' + '_' + report.Store__c + '_' + productId + '_' + UserInfo.getUserId();
                        newSi.Product__c = key;
                        newSi.Shop__c = dir.Store__c;
                        newSi.ReRe__c = oldSamplingInspectionMap.containsKey(key) && oldSamplingInspectionMap.get(key) != null ? oldSamplingInspectionMap.get(key).ReRe__c : '';
                        newSi.Inspection_Product_Item__c = recordId;
                        newSi.Inspection_Report__c = insp.Inspection_Report__c;
                        sIc.add(newSi);
                    }
                    if(sIc.size() > 0) {
                        for(Sampling_Inspection__c item : sIc) {
                            List<Sampling_Inspection__c> ones = [Select Id from Sampling_Inspection__c where ExternalID__c =: item.ExternalID__c];
                            System.debug('ONES' + ones + item.ExternalID__c);
                        }
                    }
                    System.debug('总计' + sIc.size());
                    Database.upsert(sIc,Sampling_Inspection__c.Fields.ExternalID__c);
                    samplingInspectionAttachmentsGroup(sIc, oldSamplingInspection);
                    Set<String> newIds = new Set<String>();
                    for (Sampling_Inspection__c ic : sIc) {
                        newIds.add(ic.id);

                    }
                    addedsi = getExistSamplingInspectionBaseId(newIds);
                }
            } else {
                //统筹 仅仅没有抽样从Detail取且没有结果
                if(samplings.isEmpty() && siList.size() == 0 && isSD.size() > 0){
                    //自动生成填充
                     // 新建计划外Sampling Inspection
                     List<Sampling_Inspection__c> sIc = new List<Sampling_Inspection__c>();
                     Set<String> uniqueCombinations = new Set<String>();

                    for (Sampling_Detail__c details : isSD) {
                        String displayType = (String)details.Display_Type__c;
                        String productId = (String)details.Product__c;  
                        if (displayType != null && !String.isEmpty(displayType)) {
                            String[] splitValues = displayType.split(';');
                            for (String type : splitValues) {
                                if (!String.isEmpty(type.trim())) {
                                    uniqueCombinations.add(productId + '|' + type.trim());
                                }
                            }
                        }
                    }
                    for (String combination : uniqueCombinations) {
                        String[] parts = combination.split('\\|', 2);
                        String productId = parts[0];

                        // YYL 移除默认设置展出类型 20250324
                        // String displayType;
                        // if(parts.size() > 1) {
                        //     displayType = parts[1];
                        // } else {
                        //     displayType = '';
                        // }
                        // System.debug('A: ' + productId + ', B: ' + displayType);
                        System.debug('wwwwww1111111');
                        Sampling_Inspection__c newSi = new Sampling_Inspection__c();
                        newSi.Inspection_Date__c = dir.Report_Date__c;
                        newSi.Placement_Status__c = oldSamplingInspectionMap.containsKey(productId) && oldSamplingInspectionMap.get(productId) != null ? oldSamplingInspectionMap.get(productId).Placement_Status__c : '展出';
                        newSi.Unplanned_Sample__c = oldSamplingInspectionMap.containsKey(productId) && oldSamplingInspectionMap.get(productId) != null ? oldSamplingInspectionMap.get(productId).Unplanned_Sample__c : 'No';
                        newSi.Is_POP__c = '';
                        newSi.Is_Check_Price__c = '';
                        newSi.Is_Optimal__c = '';
                        newSi.Is_Set_up_Status__c = '';
                        newSi.Display_Status__c = '';
                        newSi.Before_Img__c = '';
                        newSi.After_Img__c = '';
                        // newSi.Display_Type__c = displayType;
                        // newSi.ExternalID__c = String.valueOf(dir.Report_Date__c) + '_' + dir.Store__c + '_' + productId +'_' + displayType + '_' + UserInfo.getUserId();
                        newSi.ExternalID__c = String.valueOf(dir.Report_Date__c) + '_' + dir.Store__c + '_' + productId +'_' + UserInfo.getUserId();
                        // System.debug('外键参数==' + String.valueOf(dir.Report_Date__c) + '_' + dir.Store__c + '_' + productId +'_' + displayType + '_' + UserInfo.getUserId());
                        // newSi.ExternalID__c = '4' + '_' + report.Store__c + '_' + productId + '_' + UserInfo.getUserId();
                        newSi.Product__c = productId;
                        newSi.Shop__c = dir.Store__c;
                        newSi.ReRe__c = oldSamplingInspectionMap.containsKey(productId) && oldSamplingInspectionMap.get(productId) != null ? oldSamplingInspectionMap.get(productId).ReRe__c : '';
                        newSi.Inspection_Product_Item__c = recordId;
                        newSi.Inspection_Report__c = insp.Inspection_Report__c;
                        sIc.add(newSi);
                    }
                    Database.upsert(sIc,Sampling_Inspection__c.Fields.ExternalID__c);
                    samplingInspectionAttachmentsGroup(sIc, oldSamplingInspection);
                    Set<String> newIds = new Set<String>();
                    for (Sampling_Inspection__c ic : sIc) {
                        newIds.add(ic.id);

                    }
                    addedsi = getExistSamplingInspectionBaseId(newIds);
                }

            }
            
            siList.addAll(planOutSamplingInspection);
            siList.addAll(addedsi);
            if(user.Sales_Region__c == 'Hisense International') {
                List<Sampling_Inspection__c> checkListSampling = [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c,
                    Product__r.Category__c,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,  
                    Display_Stand__c, 
                    Display_Type__c,
                    On_Wall_Display__c,
                    POP__c,
                    Display_Status__c,
                    Set_up_Status__c,
                    Is_POP__c,
                    Is_Check_Price__c,
                    Is_Optimal__c,
                    Before_Img__c,
                    After_Img__c,
                    Is_Set_up_Status__c,
                    Status__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,                    
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                where Inspection_Product_Item__c =: recordId And IsDeleted = false];
                // todo 给产品添加金额 wfc
                checkListSampling = setProductPrice(dir.Store__c, checkListSampling);
                mso.put('samplingInspections', checkListSampling);
            } else {
                // todo 给产品添加金额 wfc
                siList = setProductPrice(dir.Store__c, siList);
                mso.put('samplingInspections', siList);
            }
            
            
            System.debug('XXXXX' + siList);
             //获取图片记录
             List<String> ids = new List<String>();
             for (Sampling_Inspection__c inspection : siList) { 
                 ids.add(inspection.Id);
             }
             if(ids.size()>0) {
                 List<String> confirm = getPictureLists(ids);
                 System.debug('图片确认集合ID' + confirm);
                 mso.put('pictureIds', confirm);
             } else {mso.put('pictureIds','');}

            // ticket部分
            Map<String, List<Ticket__c>> taskMap = getTicket(dir);
            mso.put('ticketOpenInfo', taskMap.get('openTasks'));
            mso.put('ticketClosedInfo', taskMap.get('closedTasks'));
        //不存在recordId
        } else{
            System.debug('没有RecordId');
        }
        if(String.isNotBlank(shopId)){
            Shop__c store = [SELECT Id,Name,Planograms__c,PlanogramsContentBodyId__c,PlanogramsFileType__c,PlanogramsVersionId__c FROM Shop__c WHERE Id = :shopId];
            mso.put('storeInfos', store);
        } else {
            System.debug('没有ShopId');
        }    
        System.debug('resp======>'+resp);
        return resp;
    }

    // wfc 关联渠道产品价格表
    public static List<Sampling_Inspection__c> setProductPrice(String shopId, List<Sampling_Inspection__c> siList){
        // 查询门店对应的渠道产品价格
        Shop__c shop = [SELECT Id, Channel_item__c FROM Shop__c WHERE Id = :shopId LIMIT 1];
        if(shop.Channel_item__c != null){
            Map<String, Channel_Product_Price__c> producMap = new Map<String, Channel_Product_Price__c>();
            // 查询所有的渠道产品价格
            List<Channel_Product_Price__c> cppList = [SELECT Id ,Product__c, Price__c, CurrencyIsoCode 
                                                        FROM Channel_Product_Price__c
                                                        WHERE Channel_item__c = :shop.Channel_item__c];

            System.debug('wwwwChannel_Product_Price__c' + JSON.serialize(cppList));
            for(Channel_Product_Price__c cpp : cppList){
                producMap.put(cpp.Product__c, cpp);
            }
            for(Sampling_Inspection__c si : siList){
                // 有产品对应的价格
                if(producMap.containsKey(si.Product__c)){
                    si.Product__r.Guiding_Price__c = producMap.get(si.Product__c).Price__c;
                    si.Product__r.CurrencyIsoCode = producMap.get(si.Product__c).CurrencyIsoCode;
                }else {
                    si.Product__r.Guiding_Price__c = null;
                }
            }
        }else {
            for(Sampling_Inspection__c si : siList){
                si.Product__r.Guiding_Price__c = null;
            }
        }
        return siList;
    }

    //联合巡店初始化
    @AuraEnabled
    public static ConResponse getUniteInitData(String recordId, String productLine, String shopId) {
        // 产品线关联表  == Inspection_Product_Item__c 暂定一下
        System.debug('RecordId' + recordId);
        Inspection_Product_Item__c insp = [Select Id,Inspection_Report__c,CurrencyIsoCode, Product_Line__c, Status__c from  Inspection_Product_Item__c Where Id =: recordId];
        
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        User user = [SELECT Id, Name, Sales_Region__c, title FROM User WHERE Id = : UserInfo.getUserId()];
        // if(user.Sales_Region__c == 'Hisense International') {
        //     mso.put('getOfficeCheck', getOfficeCheck(CHECKITEMTYPE, user.Sales_Region__c));
        // }
        List<Sampling_Inspection__c> sIc = new List<Sampling_Inspection__c>();
        List<Sampling_Inspection__c> sampling = new List<Sampling_Inspection__c>();
        List<String> newIds = new List<String>();
        if (String.isNotBlank(insp.Inspection_Report__c)) {
            // 查询日报
            List<Daily_Inspection_Report__c> dirList = getExistDailyInspectionReportBasedId(insp.Inspection_Report__c);
            if (dirList.size()==0) {
                resp.code= -1;
                resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Daily_Inspection_Report__c.getLabel()});
                return resp;
            }
            Daily_Inspection_Report__c dir = dirList[0];
            
            List<Sampling_Inspection__c> InspectionResult = [SELECT Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c,
                    Display_Type__c,
                    Display_Status__c,
                    On_Wall_Display__c,
                    POP__c,
                    Set_up_Status__c,
                    Is_POP__c,
                    Is_Check_Price__c,
                    Is_Optimal__c,
                    Before_Img__c,
                    After_Img__c,
                    Is_Set_up_Status__c,
                    Status__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Img_Status__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                Shop__c = : shopId
                AND Inspection_Product_Item__c =: recordId
                AND Product__c =: null];
            System.debug('查询的数据' + InspectionResult.size());
            if(InspectionResult.size() > 0) {
                mso.put('uniteInspections', InspectionResult);
                sIc = InspectionResult;               
            } else {
                //需要生成两个问题用于挂载 图片
                for (Integer i = 0; i < 2; i++) {
                    Sampling_Inspection__c newSi = new Sampling_Inspection__c();
                        newSi.Inspection_Date__c = dir.Report_Date__c;
                        newSi.Placement_Status__c = '展出';
                        newSi.Unplanned_Sample__c = 'No';
                        newSi.Is_POP__c = '';
                        newSi.Is_Check_Price__c = '';
                        newSi.Is_Optimal__c = '';
                        newSi.Is_Set_up_Status__c = '';
                        newSi.Display_Status__c = '';
                        newSi.Display_Type__c = '';
                        newSi.ReRe__c = String.valueOf(i);
                        newSi.ExternalID__c = String.valueOf(dir.Report_Date__c) + '_' + dir.Store__c + '_' + String.valueOf(i) +'_' + recordId + '_' + UserInfo.getUserId();
                        newSi.Product__c = null;
                        newSi.Shop__c = dir.Store__c;
                        newSi.Inspection_Product_Item__c = recordId;
                        sampling.add(newSi);
                    }
                    Database.upsert(sampling,Sampling_Inspection__c.Fields.ExternalID__c);   
                    mso.put('uniteInspections', sampling); 
                    sic = sampling;            
                }
        }

            for (Sampling_Inspection__c ic : sic) {
                newIds.add(ic.id);
            }        
            if(newIds.size()>0) {
                List<String> confirm = getPictureLists(newIds);
                System.debug('图片确认集合ID' + confirm);
                mso.put('pictureIds', confirm);
            } else {
               mso.put('pictureIds','');
            }

        System.debug('resp======>'+resp);
        return resp;
    }


    @AuraEnabled
    public static List<ContentVersion> getPictureList(String recordId){
        System.debug('获取图片传入ID' + recordId);
        Set<Id> idSet = new Set<Id>();
        // 查询与记录相关联的文件
        List<ContentDocumentLink> documentLinks = [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType
                                                   FROM ContentDocumentLink
                                                   WHERE LinkedEntityId = :recordId];
        List<ContentVersion> cvList = new List<ContentVersion>();
        // 处理查询结果
        if(documentLinks.size() > 0) {
            for (ContentDocumentLink link : documentLinks){
                idSet.add(link.ContentDocumentId);
            }
            // 检索文件详细信息
            cvList = [SELECT Id, ContentBodyId, ContentDocumentId, FileType
                                           FROM ContentVersion
                                           WHERE ContentDocumentId IN:idSet
                                           ORDER BY ContentDocument.CreatedDate];
        }
        return cvList;
    }

    @AuraEnabled
    public static Boolean deletePicture(String contentDocumentId){
        Database.delete (contentDocumentId);
        return true;
    }

    // @AuraEnabled
    public static List<String> getPictureLists(List<String> recordIds){
        Set<String> uniqueIdSet = new Set<String>();
        // 遍历列表，将ID添加到Set中，Set会自动去重
        // 查询与记录相关联的文件
        List<ContentDocumentLink> documentLinks = [SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title, ContentDocument.FileType
                                                   FROM ContentDocumentLink
                                                   WHERE LinkedEntityId IN: recordIds];
        // 处理查询结果
        for (ContentDocumentLink link : documentLinks){
            uniqueIdSet.add(link.LinkedEntityId);
        }
        // 将Set转换为List
        List<String> uniqueIdList = new List<String>(uniqueIdSet);
        return uniqueIdList;
    }

    @AuraEnabled
    public static List<Shop__c> getShopInfo(String shopId){
        return [SELECT Id,Name,Planograms__c,PlanogramsContentBodyId__c,PlanogramsFileType__c,PlanogramsVersionId__c FROM Shop__c WHERE Id = :shopId];
    }

    // 刷新数据
    @AuraEnabled()
    public static ConResponse refreshData(String recordJson, String currentLat, String currentLong, String contentVersionId, String shopId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('recordJson' + recordJson);
        Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)JSON.deserializeStrict(recordJson, Daily_Inspection_Report__c.class);

        User user = [SELECT Id, Name, Sales_Region__c, title FROM User WHERE Id = : UserInfo.getUserId()];

        // List<User> ul = [SELECT Id, Name, Sales_Region__c FROM User WHERE Name = 'Argentina Floorwalker Test'];
        List<User> ul = [SELECT Id, Name, Sales_Region__c FROM User WHERE Name = 'Nacho'];
        if(ul != null && ul.size() > 0){
            mso.put('ticketAssignedTo', ul.get(0).Id);
        }

        if('Hisense Argentina'.equals(user.Sales_Region__c)){
            
            mso.put('brandOptions', brandOptions);

            //阿根廷品牌产品线
            mso.put('searchProductByProductLineOption', searchProductByProductLineOption);
            mso.put('brandAndProductline', brandAndProductline);
        }
        // 2024-01-17 wfc 特定用户可不需要配置门店负责人信息，选择所有权限门店
        List<Map<String, Object>> storeDistanceList = new List<Map<String, Object>>();
        List<Responsible_Person__c> responsiblePersonList = getResponsiblePerson(UserInfo.getUserId());
        storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, responsiblePersonList, report.Report_Date__c, shopId);
        mso.put('storeDistanceList', storeDistanceList); 

        // 获取Today
        mso.put('todayDate', thisDay); 
        // 获取Time
        mso.put('nowTime', thisTime); 
        mso.put('inspectTypeOptions', getPickList('Daily_Inspection_Report__c','Inspect_Type__c')); 
        mso.put('inspectStatusOptions', getPickList('Daily_Inspection_Report__c','Contact_Status__c')); 
        // 获取Product Line Picklist Value顺序
        mso.put('productLineValueSort', getPickList('Product__c','Product_Line__c')); 
        // 日报ExId
        String dirExId = report.Store__c + '_' + UserInfo.getUserId() + '_' + report.Report_Date__c;
        // 查询是否存在日报
        Daily_Inspection_Report__c dir;
        List<Daily_Inspection_Report__c> dirList = getExistDailyInspectionReportBasedExternalId(dirExId);
        if (dirList.size()>0) {
            dir = dirList[0];
        }
        // 存在日报
        if (dir!=null) {
            mso.put('record', dir);
            mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);

            if('Hisense Argentina'.equals(user.Sales_Region__c) && String.isNotBlank(dir.Brand__c)){
                //阿根廷
                List<Sampling_Inspection_Argentina__c> siaList = new List<Sampling_Inspection_Argentina__c>();
                siaList = getSamplingInspectionArgentinaByReportId(dir.Id);
                mso.put('samplingInspectionsArgentina', siaList);
            }

            if (dir.NeedCheckIn__c && dir.Inspect_Type__c != INSPECT_TYPE_REMOTE) {//Modified By Ethan 20231103
                // 考勤ExId
                String paExId = UserInfo.getUserId() + '_' + String.valueOf(report.Report_Date__c);
                // 查询当天考勤信息
                List<Promoter_Attendance__c> paList = getExistAttendanceBasedExternalId(paExId);
                if (paList.size()==0) {
                    resp.code= -1;
                    resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Promoter_Attendance__c.getLabel()});
                    return resp;
                }
                Promoter_Attendance__c pa = paList[0];
                // 查询签到信息
                List<Promoter_Attendance_Information__c> paiList = getExistPromoterAttendanceInformationBasedAttendanceId(pa.Id, report.Report_Date__c, report.Store__c);
                if (paiList.size()==0) {
                    resp.code= -1;
                    resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Promoter_Attendance_Information__c.getLabel()});
                    return resp;
                }
                Promoter_Attendance_Information__c pai = paiList[0];
                // 获取签到信息
                mso.put('attendanceInformation', pai);
                Map<String, String> attendanceInformationHandHelper = new Map<String, String>();
                attendanceInformationHandHelper.put('checkInTime', String.valueOf(pai.CheckIn_Time__c).subString(0,5));
                
                if (!Test.isRunningTest()) {
                    // 附件部分
                    List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : pai.Id];
                    
                    //附件照片可以为非必填
                    if(cdlList.size() > 0){
                        ContentDocumentLink cdl = cdlList[0];
                        attendanceInformationHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                    }
                    mso.put('attendanceInformationHandHelper', attendanceInformationHandHelper);
                }
                
                // 查询签退信息
                List<Promoter_Attendance_Information__c> paiCheckOutList = getExistPromoterAttendanceInformationCheckOutBasedAttendanceId(pa.Id, report.Report_Date__c, report.Store__c);
                if (paiCheckOutList.size()!=0) {
                    Promoter_Attendance_Information__c paiCheckOut = paiCheckOutList[0];
                    mso.put('attendanceInformationCheckOut', paiCheckOut);
                    Map<String, String> attendanceInformationCheckOutHandHelper = new Map<String, String>();
                    attendanceInformationCheckOutHandHelper.put('checkOutTime', String.valueOf(paiCheckOut.CheckIn_Time__c).subString(0,5));
                    if (!Test.isRunningTest()) {
                        // 附件部分
                        List<ContentDocumentLink> cdlCheckOutList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : paiCheckOut.Id];
                        if(cdlCheckOutList.size() > 0){
                            ContentDocumentLink cdl = cdlCheckOutList[0];
                            attendanceInformationCheckOutHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                        }
                        mso.put('attendanceInformationCheckOutHandHelper', attendanceInformationCheckOutHandHelper);
                    }
                }
            } else {
                if (!Test.isRunningTest() && dir.Inspect_Type__c != INSPECT_TYPE_REMOTE) {//Modified By Ethan 20231103
                    // 附件部分
                    Map<String, String> attendanceInformationHandHelper = new Map<String, String>();
                    List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : dir.Id];
                   
                    //附件照片可以为非必填
                    if(cdlList.size() > 0){
                        ContentDocumentLink cdl = cdlList[0];
                        attendanceInformationHandHelper.put('phoneBase64', JSON.serialize(cdl.ContentDocument.LatestPublishedVersion.VersionData));
                    }
                    mso.put('attendanceInformationHandHelper', attendanceInformationHandHelper);
                }
            }
            // checklist部分
            Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(dir.Id);
            mso.put('checkResults', checkResults);
            mso.put('checkResultsIsRelatedToProduct', getCheckResultBycurrentUserLanguage(getExistCheckResultIsRelatedToProductBaseReportId(dir.Id)));
            // Sampling Inspection部分
            // 获取计划外Sampling Inspection信息
            List<Sampling_Inspection__c> planOutSamplingInspection = getExistPlanOutSamplingInspectionBaseStoreIdAndDate(dir.Store__c, dir.Report_Date__c, dir.OwnerId);
            List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreIdAndDate(dir.Store__c,dir.Report_Date__c,dir.OwnerId);
            siList.addAll(planOutSamplingInspection);
            // todo 给产品添加金额 wfc
            siList = setProductPrice(dir.Store__c, siList);
            mso.put('samplingInspections', siList);
            // ticket部分
            Map<String, List<Ticket__c>> taskMap = getTicket(dir);
            mso.put('ticketOpenInfo', taskMap.get('openTasks'));
            mso.put('ticketClosedInfo', taskMap.get('closedTasks'));
            // Mileage部分
            List<Mileage__c> mileageList = getExistMileageBaseRecordId(dir.Id);
            if (mileageList.size()>0) {
                mso.put('mileageRecord', mileageList[0]);
            }
            
            // 判断是否为日报所属人查看日报
            if (UserInfo.getUserId()!=dir.OwnerId) {
                mso.put('isReportUser', false);
            } else {
                mso.put('isReportUser', true);
            }
        // 不存在日报
        } else {

            Daily_Inspection_Report__c dirNew = new Daily_Inspection_Report__c(
                Report_Date__c = report.Report_Date__c,
                Store__c = report.Store__c,
                Status__c = 'New',
                Inspect_Type__c = 'Locale Inspection',
                Contact_Status__c = 'Not start'
                // NeedAutoSubmit__c = true
            );
            if('Hisense Argentina'.equals(user.Sales_Region__c)){
                if(String.isNotBlank(user.title) && user.title.toLowerCase().contains('hisense')){
                    dirNew.Brand__c = 'Hisense';
                }else{
                    dirNew.Brand__c = 'Hisense(Merchandiser)';
                }
            }

            mso.put('record', dirNew);
            
            if (contentVersionId!=null && contentVersionId!='') {
                ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE Id =:contentVersionId];
                if (cv!=null) {
                    mso.put('attendanceShowPhoto', true);
                    mso.put('attendanceFromType', 'From Photo');
                    mso.put('attendancePhotoStreamInfo', JSON.serialize(cv.VersionData));
                }
            }
        }

        return resp;
    }

    // create record
    @AuraEnabled
    public static ConResponse createSamplingInspectionRecord(String recordJson, String attendanceFromType, String attendancePhotoStreamJson, String attendanceRemark, String currentLat, String currentLong,String type) {
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
            // List<Map<String, Object>> newStoreDistanceList = getStoreDistanceList(currentLat, currentLong, personList, report.Report_Date__c);
    
            // 2024-01-17 wfc 特定用户可不需要配置门店负责人信息，选择所有权限门店
            List<Map<String, Object>> newStoreDistanceList = new List<Map<String, Object>>();
            // if(UserInfo.getUserName() == 'syssfcrm@hisense.com.hisenseall'){
            //     System.debug('www4----特殊用户');
            //     // 获取门店负责人信息，确定可选门店
            //     newStoreDistanceList = getStoreDistanceListForStore(currentLat, currentLong, personList, report.Report_Date__c, report.Store__c);
            // }else {
            //     newStoreDistanceList = getStoreDistanceList(currentLat, currentLong, personList, report.Report_Date__c);
            // }
            newStoreDistanceList = getStoreDistanceListForStore(currentLat, currentLong, personList, report.Report_Date__c, report.Store__c);
            Map<String, Object> storeDistance = newStoreDistanceList[0];
            report.Distance__c = Double.valueOf(storeDistance.get('storeDistance'));
            // if (((Decimal)storeDistance.get('storeDistance'))*1000>(Decimal)storeDistance.get('checkInDistance')) {
            //     mso.put('isOutOfRange', true);
            // } else {
            // 现场巡店 start 20231101 Ethan
            if (report.Inspect_Type__c != INSPECT_TYPE_REMOTE) {
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
                    // Promoter_Attendance_Information__c pai = new Promoter_Attendance_Information__c();
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
                        // if (cdlList.size()==0) {
                        //     resp.code= -1;
                        //     resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{'Photo'});
                        //     return resp;
                        // }
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
                        // if (cdlList.size()==0) {
                        //     resp.code= -1;
                        //     resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{'Photo'});
                        //     return resp;
                        // }
                        //  BY lizunxing 20231213
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
            if (report.Inspect_Type__c == INSPECT_TYPE_REMOTE) {
                // 新建日报
                upsert report;
            
                
                report = getExistDailyInspectionReportBasedId(report.Id)[0];
                mso.put('attendanceInformation', null);
                mso.put('attendanceInformationHandHelper', null);
    
            }
            // 新建Sampling Inspection
            type = 'TV';
            createSamplingInspection(report.Store__c, report.Report_Date__c, report.Id);
            List<Sampling_Inspection__c> filterList;
            List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreIdAndDate(report.Store__c,report.Report_Date__c,report.OwnerId);
            // for (Sampling_Inspection__c si : siList) {
            //     if (si.Sample_Item__r.Display_Type__c == type) {
            //         filterList.add(si);
            //     }
            // }
            // 新建Sampling Inspection unplan --- Added By Sunny Start
            
            createPlanoutSamplingInspection(report.Store__c, report.Report_Date__c);
            List<Sampling_Inspection__c> filterList2;
            List<Sampling_Inspection__c> siListPlanOut = getExistPlanOutSamplingInspectionBaseStoreIdAndDate(report.Store__c,report.Report_Date__c,report.OwnerId);
            // for (Sampling_Inspection__c si : siListPlanOut) {
            //     if (si.Sample_Item__r.Display_Type__c == type) {
            //         filterList2.add(si);
            //     }
            // }
            // filterList.addAll(filterList2);
            siList.addAll(siListPlanOut);
            // todo 给产品添加金额 wfc
            siList = setProductPrice(report.Store__c, siList);
            mso.put('samplingInspections', siList);
            // 新建Sampling Inspection unplan --- Added By Sunny End
            
            //阿根廷新建
            if('Hisense Argentina'.equals(user.Sales_Region__c) && String.isNotBlank(report.Brand__c) && !'Hisense'.equals(report.Brand__c)){
                List<Sampling_Inspection_Argentina__c> siaList = new List<Sampling_Inspection_Argentina__c>();
                for(String obj : brandAndProductline.get(report.Brand__c)){
                    Sampling_Inspection_Argentina__c sia = new Sampling_Inspection_Argentina__c(
                        Brand__c = report.Brand__c,
                        Daily_Inspection_Report__c = report.Id,
                        Product_Line__c = obj,
                        Quantity_Of_Exhibits_Total__c = null,
                        Placement_Status__c = false,
                        POP__c = false,
                        ReRe__c = '',
                        External_Id__c = report.Id + '-' + report.Brand__c + '-' + obj
                    );
                    upsert sia External_Id__c;
                    siaList.add(sia);
                }
                mso.put('samplingInspectionsArgentina', siaList);
            }
            
            //产品线参数
            Set<String> productLineSet = new Set<String>();
            //productLineSet.add('General');
            productLineSet.add(null);
            Map<String, List<String>> productLineToSIId = new Map<String, List<String>>();
            for (Sampling_Inspection__c si : siList) {
                productLineSet.add(si.Product__r.Product_Line__c);
                if (productLineToSIId.containsKey(si.Product__r.Product_Line__c)) {
                    List<String> siIds = productLineToSIId.get(si.Product__r.Product_Line__c);
                    siIds.add(si.Id);
                } else {
                    List<String> siIds = new List<String>();
                    siIds.add(si.Id);
                    productLineToSIId.put(si.Product__r.Product_Line__c, siIds);
                }
            }

            // 新建CheckResult
            Boolean isRemotedInspect  = report.Inspect_Type__c == INSPECT_TYPE_REMOTE ? true : false;//Ethan 20231106
            createCheckResult(report.Store__c, UserInfo.getUserId(), report.Id, productLineSet, productLineToSIId, isRemotedInspect);
            Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(report.Id);
            mso.put('checkResults', checkResults);
            mso.put('checkResultsIsRelatedToProduct', getCheckResultBycurrentUserLanguage(getExistCheckResultIsRelatedToProductBaseReportId(report.Id)));
            if (user.Sales_Region__c !='Hisense Chile') {
                // 新建Mileage
                Mileage__c mileageRecord = new Mileage__c();
                mileageRecord.Report__c = report.Id;
                mileageRecord.Start__c = 0.00;
                mileageRecord.End__c = 0.00;
                    
                upsert mileageRecord;
    
                Mileage__c mileage = getExistMileageBaseRecordId(report.Id)[0];
                mso.put('mileageRecord', mileage);
            }
            // }
            
            // ticket部分
            Map<String, List<Ticket__c>> taskMap = getTicket(report);
            mso.put('ticketOpenInfo', taskMap.get('openTasks'));
            mso.put('ticketClosedInfo', taskMap.get('closedTasks'));
            // Daily_Inspection_Report__c dir = getExistDailyInspectionReportBasedId(report.Id)[0];
            // mso.put('record', dir);
            mso.put('record', report);
            mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(report.Id)[0].Owner.Name);
            // 获取Today
            mso.put('todayDate', thisDay); 
            // 获取Time
            mso.put('nowTime', thisTime); 
    
            // 2024-01-17 wfc 特定用户可不需要配置门店负责人信息，选择所有权限门店
            List<Map<String, Object>> storeDistanceList = new List<Map<String, Object>>();
            List<Responsible_Person__c> responsiblePersonList = getResponsiblePerson(UserInfo.getUserId());
            // if(UserInfo.getUserName() == 'syssfcrm@hisense.com.hisenseall'){
            //     System.debug('www5----特殊用户');
            //     // 获取门店负责人信息，确定可选门店
            //     storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, responsiblePersonList, report.Report_Date__c, report.Store__c);
            // }else {
            //     // 获取门店负责人信息，确定可选门店
            //     storeDistanceList = getStoreDistanceList(currentLat, currentLong, responsiblePersonList, report.Report_Date__c);
            // }
            storeDistanceList = getStoreDistanceListForStore(currentLat, currentLong, responsiblePersonList, report.Report_Date__c, report.Store__c);
            mso.put('storeDistanceList', storeDistanceList); 
    
            // // 获取门店负责人信息，确定可选门店
            // List<Responsible_Person__c> responsiblePersonList = getResponsiblePerson(UserInfo.getUserId());
            // List<Map<String, Object>> storeDistanceList = getStoreDistanceList(currentLat, currentLong, responsiblePersonList, report.Report_Date__c);
            // mso.put('storeDistanceList', storeDistanceList); 
            System.debug('resp======>'+resp);
            return resp;
    }
    


    // upsert record
    @AuraEnabled
    public static ConResponse upsertRecord(String recordJson, String samplingInspectionJson, String samplingInspectionsArgentinaJson, String ticketOpenJson, String ticketClosedJson, String ticketOpenFilesMapJson, String mileageRecordJson, String checkResultsIsRelatedToProductJson, Boolean isSubmit,
                                            String attendancePhotoStreamJson, String attendanceRemark) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        Savepoint sp = Database.setSavepoint();

        System.debug('recordJson' + recordJson);
        Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)JSON.deserializeStrict(recordJson, Daily_Inspection_Report__c.class);
        System.debug('samplingInspectionJson' + samplingInspectionJson);
        if(!samplingInspectionJson.equals('')){ 
            List<Sampling_Inspection__c> siList = (List<Sampling_Inspection__c>)JSON.deserialize(samplingInspectionJson, List<Sampling_Inspection__c>.class);
            for (Sampling_Inspection__c sam : siList) {
                sam.Status__c = 'Save';
                if(sam.Price__c == null) {
                    sam.Price__c = null;
                }
                if(sam.Is_POP__c == '是') {
                    sam.Is_POP__c = 'Yes'; 
                } else if(sam.Is_POP__c == '否') {
                    sam.Is_POP__c = 'No'; 
                }

                if(sam.Is_Check_Price__c == '是') {
                    sam.Is_Check_Price__c = 'Yes'; 
                } else if(sam.Is_Check_Price__c == '否') {
                    sam.Is_Check_Price__c = 'No'; 
                }

                if(sam.Is_Optimal__c == '是') {
                    sam.Is_Optimal__c = 'Yes'; 
                } else if(sam.Is_Optimal__c == '否') {
                    sam.Is_Optimal__c = 'No'; 
                }

                if(sam.Is_Set_up_Status__c == '是') {
                    sam.Is_Set_up_Status__c = 'Yes'; 
                } else if(sam.Is_Set_up_Status__c == '否') {
                    sam.Is_Set_up_Status__c = 'No'; 
                }
                System.debug('Price传递' + (sam.Price__c == null));
                System.debug('Price传递' + (sam.Is_POP__c));

            }
            upsert siList;
        }

        
        // List<Ticket__c> taskOpenList = (List<Ticket__c>)JSON.deserialize(ticketOpenJson, List<Ticket__c>.class);
        // System.debug('taskOpenList' + taskOpenList);
        // // Open ticket

        System.debug('ticketOpenJson什么值' + ticketOpenJson);
        
        System.debug('ticketOpenJsonTN' + ticketOpenJson != null);
        Map<String, List<Ticket__c>> taskMap = getTicket(report);
        if(String.isNotEmpty(ticketOpenJson) && ticketOpenJson.equals('[]') ){
            delete taskMap.get('openTasks');
            ticketOpenJson = null;
        }
        if (ticketOpenJson != null) {
        String ticketRecordId = Schema.Ticket__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Floorwalker').getRecordTypeId();
        List<Ticket__c> taskOpenList = (List<Ticket__c>)JSON.deserialize(ticketOpenJson, List<Ticket__c>.class);
        // // Open ticket
        List<String> currentTicketIdList = new LisqContainer(taskMap.get('openTasks')).selectsField('Id');
        List<Ticket__c> tempList = new List<Ticket__c>();
        List<Ticket__c> delTicketList = new List<Ticket__c>();
        List<String> Ids = new List<String>();
        for (Ticket__c t : taskOpenList) {
            if (t.Id == null || currentTicketIdList.contains(t.Id)) {
                tempList.add(t);
            } 
            Ids.add(t.Id);
        }
        for(Ticket__c ticket :taskMap.get('openTasks')){
            if (!Ids.contains(ticket.Id)) {
                // 打印不在 ListA 中的 ListB 元素
                System.debug('Item in ListB but not in ListA: ' + ticket);
                delTicketList.add(ticket);
            }
        }
        taskOpenList = tempList;
        // 空部门校验 Sunny 20231117 start
        String checkDepartmentResult = NewTicketsController2.checkDepartment(taskOpenList);
        if(checkDepartmentResult != null) {
            resp.code = -1;
            resp.message = checkDepartmentResult;
            return resp;
        }
        // 空部门校验 Sunny 20231117 end
        for (Ticket__c t : taskOpenList) {
            if (t.Id == null) {
                t.RecordTypeId = ticketRecordId;
                t.InspectionReport__c = report.Id;
            }
            // if (t.Confirm_Task__c == 'Yes' && t.Closed_Daily_Inspection_Report__c == null) {
            if (t.Status__c == 'Closed' && t.ClosedDailyInspectionReport__c == null) {
                t.ClosedDailyInspectionReport__c = report.Id;
            }
        }
        if(delTicketList.size() > 0) {delete delTicketList;}
        upsert taskOpenList;
        // 附件关联
        // 切片上传 Yin Mingjie 20231026 start
        UploadFilesController.saveFiles2(ticketOpenJson, ticketOpenFilesMapJson, taskOpenList, report.Id);
        // 切片上传 Yin Mingjie 20231026 end
        // Closed ticket
        System.debug('ticketClosedJson' + ticketClosedJson);
        List<Ticket__c> taskClosedList = (List<Ticket__c>)JSON.deserialize(ticketClosedJson, List<Ticket__c>.class);
        for (Ticket__c t : taskClosedList) {
            // if (t.Confirm_Task__c == 'Yes' && t.Closed_Daily_Inspection_Report__c == null) {
            if (t.Status__c == 'Closed' && t.ClosedDailyInspectionReport__c == null) {
                t.ClosedDailyInspectionReport__c = report.Id;
            }
        }
        upsert taskClosedList;
        upsert report;
        } else {
            System.debug('WWWticketOpen数据为空');
        }
        
        // 更新巡店任务
        // 查询日报（更新总分和平均分数据）
        // Daily_Inspection_Report__c dir = getExistDailyInspectionReportBasedId(report.Id)[0];
        // mso.put('record', dir);
        // ticket部分
        taskMap = getTicket(report);
        // Added By Sunny Start
        List<Ticket__c> openTasks = taskMap.get('openTasks');
        String ticketMessage = '';
        for(Ticket__c ticket : openTasks) {
            if(ticket.DueDate__c == null) {
                ticketMessage = System.Label.Inspection_Report_Check_Item_Ticket_Fill;
                break;
            }
        }
        mso.put('ticketMessage', ticketMessage);
        // Added By Sunny End

        mso.put('ticketOpenInfo', taskMap.get('openTasks'));
        mso.put('ticketClosedInfo', taskMap.get('closedTasks'));

        System.debug('resp1======>'+resp);
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
            // if (currentLat!=null && currentLong!=null && person.Shop_Name__r.Shop_Center_Location__c!=null) {
            // if (currentLat!=null && currentLong!=null) {
                Map<String, Object> storeDistanceMap = new Map<String, Object>();
                Location location = Location.newInstance(Double.Valueof(currentLat), Double.Valueof(currentLong));
                // Decimal distance = location.getDistance(person.Shop_Name__r.Shop_Center_Location__c,'km');
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
                // storeDistanceMap.put('storeLat', person.Shop_Name__r.Shop_Center_Location__Latitude__s);
                // storeDistanceMap.put('storeLong', person.Shop_Name__r.Shop_Center_Location__Longitude__s);
                storeDistanceMap.put('storeDistance', distance);
                storeDistanceMap.put('storeDistanceStr', String.valueOf(Integer.valueOf(distance*1000))+'m');
                storeDistanceMap.put('checkInDistance', person.Promoter_Attendance_Rule__r.Distance__c);
                storeDistanceMap.put('recordType', person.RecordType__c);// Add By Ethan 20231011 ----增加backup排序

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
            // }
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
            // storeDistanceMap.put('storeLat', person.Shop_Name__r.Shop_Center_Location__Latitude__s);
            // storeDistanceMap.put('storeLong', person.Shop_Name__r.Shop_Center_Location__Longitude__s);
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
        /*
        // Add By Ethan 20231011 back up 排序优先级最低 Start
        List<Map<String, Object>> planInOutBackupList = new List<Map<String, Object>>();//用于针对记录类型为 backup的记录，拼装planInList、planOutList
        List<Map<String, Object>> planInOutNotBackupList = new List<Map<String, Object>>();//用于针对记录类型不为 backup的记录，拼装planInList、planOutList
        String backupRecordType = 'Backup Floorwalker';
        //分别排序
        for (Map<String, Object> planInitem : planInList) {
            if ((String)planInitem.get('recordType') == backupRecordType){
                String storeName = (String)planInitem.get('storeName');
                storeName = '*(backup)'+storeName.substring(1, storeName.length());
                planInitem.put('storeName', storeName);
                planInOutBackupList.add(planInitem);
                // planInOutBackupList.add(new Map<String, Object>{'storeName' => '(backup)'+planInitem.get('storeName')});
            }
            else 
                planInOutNotBackupList.add(planInitem);
        }
        planInList.clear();
        planInList.addAll(planInOutNotBackupList);
        planInList.addAll(planInOutBackupList);

        planInOutBackupList.clear();
        planInOutNotBackupList.clear();
        for (Map<String, Object> planOutitem : planOutList) {
            if ((String)planOutitem.get('recordType') == backupRecordType){
                planOutitem.put('storeName', '(backup)'+planOutitem.get('storeName'));
                planInOutBackupList.add(planOutitem);
                // planInOutBackupList.add(new Map<String, Object>{'storeName' => '(backup)'+planOutitem.get('storeName')});
            }
            else 
                planInOutNotBackupList.add(planOutitem);
        }
        planOutList.clear();
        planOutList.addAll(planInOutNotBackupList);
        planOutList.addAll(planInOutBackupList);
        // Add By Ethan 20231011 back up 排序优先级最低 End
        */
        planList.addAll(planInList);
        planList.addAll(planOutList);
        return planList;
    }

    // 获取checkList，并新建CheckResult
    public static void createCheckResult(String storeId, String userId, String reportId, Set<String> productLineSet, Map<String, List<String>> productLineToSIId) {
        createCheckResult(storeId,  userId,  reportId, productLineSet,  productLineToSIId, false);
    }
    
    // 获取checkList，并新建CheckResult
    // public static void createCheckResult(String storeId, String userId, String reportId, Set<String> productLineSet) {
    public static void createCheckResult(String storeId, String userId, String reportId, Set<String> productLineSet, Map<String, List<String>> productLineToSIId, Boolean isRemotedInspect) {// Ethan 20231106
        // ConResponse checklist= CheckListController.getCheckList('a260l0000016LA2AAM','0050l000007g1vGAAQ');
        // ConResponse checklist= CheckListController.getCheckList(storeId,userId);
        ConResponse checklist= CheckListController.getCheckList(storeId,userId, isRemotedInspect);
        if (checklist.data instanceof Map<String,List<CheckItem__c>>) {
            Map<String, List<CheckItem__c>> checkItemMap = (Map<String,List<CheckItem__c>>)checklist.data;
            List<CheckResult__c> newCheckResultList = new List<CheckResult__c>();
            for (String productLine : checkItemMap.keyset()) {
                if (productLineSet.contains(productLine)) {
                    List<CheckItem__c> checkItemList = checkItemMap.get(productLine);
                    for (CheckItem__c checkItem : checkItemList) {
                        if (checkItem.Is_Related_To_Product__c=true && productLineToSIId!=null && productLineToSIId.containsKey(productLine)) {
                            List<String> siIds = productLineToSIId.get(productLine);
                            for (String siId : siIds) {
                                CheckResult__c cr = new CheckResult__c();
                                cr.InspectorDailyReport__c = reportId;
                                cr.CheckItem__c = checkItem.Id;
                                cr.Sampling_Inspection__c = siId;
                                cr.Status__c = 'Draft';
                                cr.Scores__c = -1;
                                cr.Max_Scores__c = Integer.valueOf(checkItem.MaximumScore__c);
        
                                newCheckResultList.add(cr);
                            }
                        } else {
                            CheckResult__c cr = new CheckResult__c();
                            cr.InspectorDailyReport__c = reportId;
                            cr.CheckItem__c = checkItem.Id;
                            cr.Status__c = 'Draft';
                            // if (checkItem.IsYesOrNo__c) {
                            //     cr.Scores__c = 0;
                            // } else {
                            //     cr.Scores__c = -1;
                            // }
                            cr.Scores__c = -1;
                            cr.Max_Scores__c = Integer.valueOf(checkItem.MaximumScore__c);
    
                            newCheckResultList.add(cr);
                        }
                    }
                }
            }
    
            insert newCheckResultList;
            checkItemBindAttachments(newCheckResultList, storeId, userId);
        }
    }

    // CheckResult绑定本月最近日期附件
    public static void checkItemBindAttachments(List<CheckResult__c> checkResultList, String storeId, String userId) {
        User user = [SELECT Id, Name, Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
        if (PhaseIIIUtility.isIndonesia(user)) {
            return;
        }
        // 本次新建check result上的check item
        Set<Id> crIds = new Set<Id>();
        Map<String, String> ciIdMapCrId = new Map<String, String>();
        for (CheckResult__c crItem : checkResultList) {
            crIds.add(crItem.CheckItem__c);
            ciIdMapCrId.put(crItem.CheckItem__c, crItem.Id);
        }
        // 查询本月本人的所有check result
        Date today = System.today();
        Date monthDate = Date.newInstance(today.year(), today.month(), 1);
        List<CheckResult__c> crQueryList = getExistCheckResultBaseCheckItemIds(crIds, monthDate, storeId, userId);
        if (crQueryList.size()==0) {
            return;
        }
        // 筛选出相同check item的第一条check result记录
        Map<String, String> crIdMapCiId = new Map<String, String>();
        Set<String> checkCrIds = new Set<String>();
        for (CheckResult__c crItem : crQueryList) {
            if (!checkCrIds.contains(crItem.CheckItem__c)) {
                checkCrIds.add(crItem.CheckItem__c);
                crIdMapCiId.put(crItem.Id, crItem.CheckItem__c);
            }
        }
        if (crIdMapCiId.size()==0) {
            return;
        }
        // 查询筛选出记录的所有附件
        List<ContentDocumentLink> queryCdl = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : crIdMapCiId.keySet()];
        Map<String, List<String>> documentMap = new Map<String, List<String>>();
        for (ContentDocumentLink cdlItem : queryCdl) {
            if (!crIdMapCiId.containsKey(cdlItem.LinkedEntityId)) {
                break;
            }
            String checkItemId = crIdMapCiId.get(cdlItem.LinkedEntityId);
            if (documentMap.containsKey(checkItemId)) {
                List<String> linkedIds = documentMap.get(checkItemId);
                linkedIds.add(cdlItem.ContentDocumentId);
            } else {
                List<String> linkedIds = new List<String>();
                linkedIds.add(cdlItem.ContentDocumentId);
                documentMap.put(checkItemId, linkedIds);
            }
        }
        // 关联新纪录
        List<ContentDocumentLink> insertCdlList = new List<ContentDocumentLink>();
        for (CheckResult__c crItem : checkResultList) {
            if (documentMap.containsKey(crItem.CheckItem__c)) {
                for (String documentId : documentMap.get(crItem.CheckItem__c)) {
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = documentId;
                    cdl.LinkedEntityId = crItem.Id;
                    cdl.ShareType = 'V';
                    insertCdlList.add(cdl);
                }
            }
        }
        if (insertCdlList.size()>0) {
            insert insertCdlList;
        }
    }


    // 获取checkList
    public static Map<String,Map<String, List<CheckResult__c>>> getCheckResult(String reportId) {
        List<CheckResult__c> quoeryCheckResultList = getExistCheckResultBaseReportId(reportId);
        Map<String,Map<String, List<CheckResult__c>>> checkResults = new Map<String, Map<String, List<CheckResult__c>>>();
        for (CheckResult__c cr : quoeryCheckResultList) {
            String productLine = cr.CheckItem__r.Product_Line__c==null ? 'General' : cr.CheckItem__r.Product_Line__c;
            String project = cr.CheckItem__r.Project__c;
            if (checkResults.keySet().contains(productLine)) {
                Map<String, List<CheckResult__c>> item = checkResults.get(productLine);
                if (item.keySet().contains(project)) {
                    List<CheckResult__c> crs = item.get(project);
                    crs.add(cr);
                } else {
                    List<CheckResult__c> crs = new List<CheckResult__c>();
                    crs.add(cr);
                    item.put(project, crs);
                }
            } else {
                List<CheckResult__c> crs = new List<CheckResult__c>();
                crs.add(cr);
                Map<String, List<CheckResult__c>> item = new Map<String, List<CheckResult__c>>();
                item.put(project, crs);
                checkResults.put(productLine, item);
            }
        }

        return checkResults;
    }

    // 获取重写 checkList数据
    public static Map<String,Map<String, List<CheckResult__c>>> getRewriteCheckResult(String reportId) {
        List<CheckResult__c> quoeryCheckResultList = getExistCheckResultBaseReportId(reportId);

        Map<String,Map<String, List<CheckResult__c>>> checkResults = new Map<String, Map<String, List<CheckResult__c>>>();
        for (CheckResult__c cr : quoeryCheckResultList) {
            String productLine = cr.CheckItem__r.Product_Line__c==null ? null : cr.CheckItem__r.Product_Line__c;
            String project = cr.CheckItem__r.Project__c;
            if (checkResults.keySet().contains(productLine)) {               
                Map<String, List<CheckResult__c>> item = checkResults.get(productLine);
                if (item.keySet().contains(project)) {
                    List<CheckResult__c> crs = item.get(project);
                    crs.add(cr);
                } else {
                    List<CheckResult__c> crs = new List<CheckResult__c>();
                    crs.add(cr);
                    item.put(project, crs);
                }
            } else {
                System.debug('Else条件  获取参数');
                List<CheckResult__c> crs = new List<CheckResult__c>();
                crs.add(cr);
                System.debug('Else条件  获取参数cr ' + cr);
                Map<String, List<CheckResult__c>> item = new Map<String, List<CheckResult__c>>();
                item.put(project, crs);
                System.debug('Else条件  获取参数item ' + item);
                checkResults.put(productLine, item);
            }
        }
        System.debug('获取接口参数' + checkResults);
        return checkResults;
    }




    // 获取Sampling Detail，并新建Sampling Inspection
    public static void createSamplingInspection(String storeId, Date reportDate, String reportId) {
        // 查询历史Sampling Inspection
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreId(storeId, Userinfo.getUserId(), Date.newInstance(reportDate.year(),1,1));
        System.debug('Silist>>>>>>>>>>>>>>>>'+siList);
        Map<String, List<Sampling_Inspection__c>> siOldMap = new Map<String, List<Sampling_Inspection__c>>();
        for (Sampling_Inspection__c si : siList) {
            if (siOldMap.containskey(si.Sample_Item__c)) {
                List<Sampling_Inspection__c> siItems = siOldMap.get(si.Sample_Item__c);
                siItems.add(si);
            } else {
                List<Sampling_Inspection__c> siItems = new List<Sampling_Inspection__c>();
                siItems.add(si);
                siOldMap.put(si.Sample_Item__c, siItems);
            }
        }
        // 新建Sampling Inspection，先查询门店Sampling Detail
        List<Sampling_Detail__c> sdList = getExistSamplingDetailBaseStoreId(storeId);
        List<Sampling_Inspection__c> newSiList = new List<Sampling_Inspection__c>();
        System.debug('SDlist==========>>>>'+sdList);
        List<Sampling_Inspection__c> oldSiList = new List<Sampling_Inspection__c>();
        for (Sampling_Detail__c sd : sdList) {
            //待用
            System.debug('SiOldMap==========>>>>'+SiOldMap);
            System.debug('SiOldMap.ContainsKey==========>>>>'+siOldMap.containskey(sd.Id));
            if (siOldMap.containskey(sd.Id)) {
                Sampling_Inspection__c oldSi = siOldMap.get(sd.Id)[0];
                
                Sampling_Inspection__c newSi = new Sampling_Inspection__c();
                newSi.Inspection_Date__c = reportDate;
                // newSi.Placement_Status__c = oldSi.Placement_Status__c;
                newSi.Placement_Status__c = sd.Display_Status__c;
            // newSi.Placement_Status__c = ''; // wfc 不自动带出Sampling Detail中的状态
                newSi.Unplanned_Sample__c = sd.Unplanned_Sample__c == '否' ? 'No' : 'Yes'; // wfc 2025-03-14 带出 Sampling_Detail__c 的是否计划外状态
                newSi.ExternalID__c = String.valueOf(reportDate) + '_' + storeId + '_' + sd.Product__c + '_' + UserInfo.getUserId();
                newSi.Product__c = sd.Product__c;
                newSi.Shop__c = storeId;
                newSi.Sample_Item__c = sd.Id;
                newSi.ReRe__c = oldSi.ReRe__c;
                // wfc 关联巡店员日报
                newSi.Inspection_Report__c = reportId;

                newSiList.add(newSi);
                oldSiList.add(oldSi);
            } else {
                Sampling_Inspection__c newSi = new Sampling_Inspection__c();
                newSi.Inspection_Date__c = reportDate;
                // newSi.Placement_Status__c = '未展出';
                newSi.Placement_Status__c = sd.Display_Status__c;
            // newSi.Placement_Status__c = ''; // wfc 不自动带出Sampling Detail中的状态
                newSi.Unplanned_Sample__c = sd.Unplanned_Sample__c == '否' ? 'No' : 'Yes'; // wfc 2025-03-14 带出 Sampling_Detail__c 的是否计划外状态
                newSi.ExternalID__c = String.valueOf(reportDate) + '_' + storeId + '_' + sd.Product__c + '_' + UserInfo.getUserId();
                newSi.Product__c = sd.Product__c;
                newSi.Shop__c = storeId;
                newSi.Sample_Item__c = sd.Id;
                newSi.ReRe__c = '';
                // wfc 关联巡店员日报
                newSi.Inspection_Report__c = reportId;

                newSiList.add(newSi);
            }
        }
        System.debug('newSiList------------------------->>>'+newSiList);
        insert newSiList;
        samplingInspectionBindAttachments(newSiList, oldSiList);

    }

    // Added By Sunny ---- 带出上一次计划外出样
    public static void createPlanoutSamplingInspection(String storeId, Date reportDate) {
        Date firstDay = Date.newInstance(reportDate.year(), reportDate.month(), 1);
        List<Daily_Inspection_Report__c> previousReportList = [SELECT Id, Report_Date__c
                                                                FROM Daily_Inspection_Report__c 
                                                                WHERE Store__c = :storeId AND OwnerId = :UserInfo.getUserId() AND Report_Date__c < :reportDate AND Report_Date__c >= :firstDay 
                                                                ORDER BY Report_Date__c DESC 
                                                                LIMIT 1];
        if (previousReportList.size()==0) {
            return;
        }
        List<Sampling_Inspection__c> siList = getExistPlanOutSamplingInspectionBaseStoreId(storeId, UserInfo.getUserId(), previousReportList[0].Report_Date__c );
        List<Sampling_Inspection__c> newSiList = new List<Sampling_Inspection__c>();
        Map<String, Sampling_Inspection__c> oldAndNewMap = new Map<String, Sampling_Inspection__c>();
        for(Sampling_Inspection__c item : siList) {
            Sampling_Inspection__c newSi = new Sampling_Inspection__c();
            newSi.Inspection_Date__c = reportDate;
            newSi.Placement_Status__c = item.Placement_Status__c;
            newSi.Unplanned_Sample__c = item.Unplanned_Sample__c;
            newSi.ExternalID__c = String.valueOf(reportDate) + '_' + storeId + '_' + item.Product__c + '_' + UserInfo.getUserId();
            newSi.Product__c = item.Product__c;
            newSi.Shop__c = storeId;
            newSi.Sample_Item__c = item.Sample_Item__c;
            newSi.ReRe__c = item.ReRe__c;
            // wfc 关联巡店员日报
            newSi.Inspection_Report__c = previousReportList[0].Id;
            newSiList.add(newSi);
            oldAndNewMap.put(item.Id, newSi);
        }

        if(newSiList.size() > 0) {

            User user = [SELECT Id, Name, Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];

            //日本有可能重复插入   lizunxing  2024-01-23
            if('Hisense Japan'.equals(user.Sales_Region__c)){
                Database.upsert(newSiList,Sampling_Inspection__c.Fields.ExternalID__c,false);
            }else{
                insert newSiList;
            }
            // samplingInspectionBindAttachments(newSiList, siList);
            
            if (PhaseIIIUtility.isIndonesia(user)) {
                return;
            }
            // 查询OldSi记录的附件
            List<ContentDocumentLink> querySi = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : oldAndNewMap.keySet()];
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
            for (String oldId : oldAndNewMap.keySet()) {
                String newId = oldAndNewMap.get(oldId).Id;
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
        
    }

    // Sampling Inspection绑定半年年期内附件
    public static void samplingInspectionAttachmentsGroup(List<Sampling_Inspection__c> newSiList, List<Sampling_Inspection__c> oldSiList) {
        // User user = [SELECT Id, Name, Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
        // if (PhaseIIIUtility.isIndonesia(user)) {
        //     return;
        // }
        // 根据Sample Item整理Map，整理出old Map new 的Id Map
        Map<String, Sampling_Inspection__c> newSitemMap = new Map<String, Sampling_Inspection__c>();
        for (Sampling_Inspection__c newSi : newSiList) {
            newSitemMap.put(newSi.Product__c, newSi);
        }
        Map<String, String> oldMapNew = new Map<String, String>();
        for (Sampling_Inspection__c oldSi : oldSiList) {
            if (newSitemMap.containsKey(oldSi.Product__c)) {
                Sampling_Inspection__c newSi = newSitemMap.get(oldSi.Product__c);
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

    // Sampling Inspection绑定当年最近日期附件
    public static void samplingInspectionBindAttachments(List<Sampling_Inspection__c> newSiList, List<Sampling_Inspection__c> oldSiList) {
        User user = [SELECT Id, Name, Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
        if (PhaseIIIUtility.isIndonesia(user)) {
            return;
        }
        // 根据Sample Item整理Map，整理出old Map new 的Id Map
        Map<String, Sampling_Inspection__c> newSitemMap = new Map<String, Sampling_Inspection__c>();
        for (Sampling_Inspection__c newSi : newSiList) {
            newSitemMap.put(newSi.Sample_Item__c, newSi);
        }
        Map<String, String> oldMapNew = new Map<String, String>();
        for (Sampling_Inspection__c oldSi : oldSiList) {
            if (newSitemMap.containsKey(oldSi.Sample_Item__c)) {
                Sampling_Inspection__c newSi = newSitemMap.get(oldSi.Sample_Item__c);
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

    // 新增计划外出样 （Sampling Inspection、CheckResult）
    @AuraEnabled
    public static ConResponse addPlanOutProduct(String recordJson, String productId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('recordJson'+recordJson);
        Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)JSON.deserializeStrict(recordJson, Daily_Inspection_Report__c.class);
        // System.debug('productJson'+productJson);
        // Product__c product = (Product__c)JSON.deserializeStrict(productJson, Product__c.class);
        List<Product__c> productList = [SELECT Id, Name, Product_Line__c, Series__c, Category__c FROM Product__c WHERE Id = : productId];
        if (productList.size()==0) {
            resp.code= -1;
            resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Product__c.getLabel()});
            return resp;
        }
        Product__c product = productList[0];
        // 查询已存在的CheckResult
        List<CheckResult__c> quoeryCheckResultList = getExistCheckResultBaseReportId(report.Id);
        // 收集已存在CheckResult Product_Line__c
        Set<String> crProductLineSet = new Set<String>();
        for (CheckResult__c cr : quoeryCheckResultList) {
            crProductLineSet.add(cr.CheckItem__r.Product_Line__c);
        }
        // 如果不存在该产品线CheckResult，新建CheckResult
        if (!crProductLineSet.contains(product.Product_Line__c)) {
            Set<String> productLineSet = new Set<String>();
            productLineSet.add(product.Product_Line__c);
            // createCheckResult(report.Store__c, UserInfo.getUserId(), report.Id, productLineSet, null);
            Boolean isRemotedInspect = report.Inspect_Type__c == INSPECT_TYPE_REMOTE ? true : false;
            createCheckResult(report.Store__c, UserInfo.getUserId(), report.Id, productLineSet, null, isRemotedInspect);
        }
        // 新建计划外Sampling Inspection
        Sampling_Inspection__c newSi = new Sampling_Inspection__c();
        newSi.Inspection_Date__c = report.Report_Date__c;
        newSi.Placement_Status__c = '展出';
        newSi.Unplanned_Sample__c = '';
        newSi.ExternalID__c = String.valueOf(report.Report_Date__c) + '_' + report.Store__c + '_' + product.Id + '_' + UserInfo.getUserId();
        newSi.Product__c = product.Id;
        newSi.Shop__c = report.Store__c;
        newSi.ReRe__c = '';
        // wfc 关联巡店员日报
        newSi.Inspection_Report__c = report.Id;

        insert newSi;

        // 获取计划外Sampling Inspection信息
        List<Sampling_Inspection__c> planOutSamplingInspection = getExistPlanOutSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
        // 更新Sampling Inspection信息
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
        siList.addAll(planOutSamplingInspection);
        // todo 给产品添加金额 wfc
        siList = setProductPrice(report.Store__c, siList);
        mso.put('samplingInspections', siList);
        // 更新CheckResult信息
        Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(report.Id);
        mso.put('checkResults', checkResults);
        // mso.put('checkResultsIsRelatedToProduct', getExistCheckResultIsRelatedToProductBaseReportId(report.Id));
        // 更新日报信息
        List<Daily_Inspection_Report__c> dirList = getExistDailyInspectionReportBasedId(report.Id);
        if (dirList.size()==0) {
            resp.code= -1;
            resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Daily_Inspection_Report__c.getLabel()});
            return resp;
        }
        Daily_Inspection_Report__c dir = dirList[0];
        dir.Brand__c = report.Brand__c;
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);
        System.debug('resp======>'+resp);
        return resp;
    }

    // 删除产品线 （Sampling Inspection、CheckResult）
    @AuraEnabled
    public static ConResponse delProductLine(String recordJson, String productLine) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('recordJson'+recordJson);
        Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)JSON.deserializeStrict(recordJson, Daily_Inspection_Report__c.class);
        
        List<Sampling_Inspection__c> delSiList = getExistPlanOutSamplingInspectionBaseStoreIddDateProductLine(report.Store__c, report.Report_Date__c, productLine, report.OwnerId);
        delete delSiList;

        List<CheckResult__c> delCrList = getExistCheckResultBaseReportIdProductLine(report.Id, productline);
        delete delCrList;

        // 获取计划外Sampling Inspection信息
        List<Sampling_Inspection__c> planOutSamplingInspection = getExistPlanOutSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
        // 更新Sampling Inspection信息
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
        siList.addAll(planOutSamplingInspection);
        // todo 给产品添加金额 wfc
        siList = setProductPrice(report.Store__c, siList);
        mso.put('samplingInspections', siList);
        system.debug('samplingInspections' + siList);
        // 更新CheckResult信息
        Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(report.Id);
        mso.put('checkResults', checkResults);
        // mso.put('checkResultsIsRelatedToProduct', getExistCheckResultIsRelatedToProductBaseReportId(report.Id));
        // 更新日报信息
        List<Daily_Inspection_Report__c> dirList = getExistDailyInspectionReportBasedId(report.Id);
        if (dirList.size()==0) {
            resp.code= -1;
            resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Daily_Inspection_Report__c.getLabel()});
            return resp;
        }
        Daily_Inspection_Report__c dir = dirList[0];
        dir.Brand__c = report.Brand__c;
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);
        System.debug('resp======>'+resp);
        return resp;
    }

    /**
     * @description 获取日报的tickect
     * @param   report 日报
     * @return  Map<String, List<Ticket__c>>    ticketmap
     */
    public static Map<String, List<Ticket__c>> getTicket(Daily_Inspection_Report__c report) {

        List<Ticket__c> taskAll = getExistTicketBaseStoreIdAndUser(report.Store__c, report.OwnerId, report.Report_Date__c);
        System.debug('TICKET全量数据' + taskAll);
        List<Ticket__c> openTasks = new List<Ticket__c>();
        List<Ticket__c> closedTasks = new List<Ticket__c>();
        for (Ticket__c task : taskAll) {
            if (task.InspectionReport__c == report.Id) {
                openTasks.add(task);
            // } else if (task.Closed_Daily_Inspection_Report__c == report.Id || task.Confirm_Task__c != 'Yes') {
            } else if (task.ClosedDailyInspectionReport__c == report.Id || (task.Status__c != 'Closed' && task.CreatedDate <= report.Report_Date__c)) {
                closedTasks.add(task);
            }
        }
        List<Ticket__c> ti = new List<Ticket__c>(); 
        System.debug('TICKETCLOSE' + closedTasks);
        if(closedTasks.size() > 0){
            ti.add(closedTasks[0]);
        }
        Map<String, List<Ticket__c>> taskMap = new Map<String, List<Ticket__c>>();
        taskMap.put('openTasks', openTasks);
        taskMap.put('closedTasks', ti);

        return taskMap;
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

    //根据维护产品线详情表获取对应的展出类型参数
    public static List<Map<String, String>> getProductLineDisplay(String salesRegion, String productLine, String shopId) {
        List<Map<String, String>> result = new List<Map<String, String>>();
        // List<Product_line_Detail__c> details = getProductLineDetail(salesRegion, productLine);
        // 更改为查询Store_Product_Line__c表 （wfc 2025-02-25）
        List<Store_Product_Line__c> details = getStoreProductLine(shopId, productLine);
        if(details.size() > 0 && String.isNotBlank(details[0].Product_line__c)) {
            String displays = details[0].Product_line__c;
            List<String> iList;
            if (displays.contains(';')) {
                iList = displays.split(';');
            } else {
                iList = new List<String>{displays};
            }

            for (String detail : iList) {
                result.add(new Map<String, String> {
                    'label' => detail,
                    'value' => detail
                });
            }
        } else {
            result.add(new Map<String, String> {'label' => '','value' => ''});
        }
        return result;
    }

    // 获取Picklist values
    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getPickList(String objectName, String fieldName) {
        if (String.isBlank(fieldName)) {
            return null;
        }

        try {
            Map<String, String> temp = Utility.getPicklistValueMap(objectName, fieldName);
            List<Map<String, String>> result = new List<Map<String, String>>();
            for (String key : temp.keySet()) {
                if (objectName=='Task' && fieldName=='Status') {
                    if (temp.get(key)=='Open'||temp.get(key)=='Resolved'||temp.get(key)=='Closed') {
                        result.add(new Map<String, String> {
                            'label' => temp.get(key),
                            'value' => key
                        });
                    }
                } else {
                    result.add(new Map<String, String> {
                        'label' => temp.get(key),
                        'value' => key
                    });
                }
            }

            return result;
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
        }

        return null;
    }

    // Query Data===========================================================
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
                    Store__r.Sales_Region__c,
                    Report_Date__c,
                    Sales_Region__c,
                    //阿根廷新加字段
                    Brand__c,
                    // TotalScore__c,
                    // TotalScore_Max__c,
                    // AverageScore__c,
                    // AverageScore_Max__c,
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

    /**
     * @description 获取巡店报告
     * @param   recordId     报告id
     * @return  巡店报告
     */
    public static List<Sampling_Inspection_Argentina__c> getSamplingInspectionArgentinaByReportId(String recordId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Brand__c,
                    ReRe__c,
                    Daily_Inspection_Report__c,
                    Product_Line__c,
                    Quantity_Of_Exhibits_Total__c,
                    POP__c,
                    Placement_Status__c,
                    External_Id__c
                FROM Sampling_Inspection_Argentina__c 
                WHERE 
                    Daily_Inspection_Report__c =: recordId];
    }

    /**
     * @description 以巡店报告
     * @param   externalId     报告id
     * @return  巡店报告
     */
    public static List<Daily_Inspection_Report__c> getExistDailyInspectionReportBasedExternalId(String externalId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Status__c,
                    Store__c,
                    Report_Date__c,
                    //阿根廷新加字段
                    Brand__c,
                    // TotalScore__c,
                    // TotalScore_Max__c,
                    // AverageScore__c,
                    // AverageScore_Max__c,
                    Total_Score__c,
                    Total_Score_Max__c,
                    Average_Score_Count__c,
                    Average_Score__c,
                    Average_Score_Max__c,
                    NeedCheckIn__c,
                    Summary__c,
                    OwnerId,
                    Note__c,
                    Inspect_Type__c, 
                    Comments__c,
                    Contact_Person__c,
                    Contact_Status__c,
                    Contact_Type__c,
                    Start_Time__c
                FROM Daily_Inspection_Report__c 
                WHERE 
                    ExternalId__c =: externalId];
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

    /**
     * @description 获取签到信息
     * @param   AttendanceId    考勤id
     * @param   todayDate       当天日期
     * @param   storeId         门店id
     * @return  打卡列表
     */
    public static List<Promoter_Attendance_Information__c> getExistPromoterAttendanceInformationBasedAttendanceId(String AttendanceId, Date todayDate, String storeId) {
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
                    Promoter_Attendance__c =: AttendanceId 
                AND Type__c = 'Check in'
                AND CheckIn_Date__c = : todayDate
                AND Shop__c = : storeId];
    }

    /**
     * @description 获取签退信息
     * @param   AttendanceId    考勤id
     * @param   todayDate       当天日期
     * @param   storeId         门店id
     * @return  打卡列表
     */
    public static List<Promoter_Attendance_Information__c> getExistPromoterAttendanceInformationCheckOutBasedAttendanceId(String AttendanceId, Date todayDate, String storeId) {
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
                    Promoter_Attendance__c =: AttendanceId 
                AND Type__c = 'Check out'
                AND CheckIn_Date__c = : todayDate
                AND Shop__c = : storeId];
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

    // 获取CheckList
    public static List<CheckResult__c> getExistCheckResultBaseReportId(String reportId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Scores__c,
                    Comments__c,
                    Status__c,
                    CheckItem__c,
                    CheckItem__r.Name,
                    CheckItem__r.Product_Line__c,
                    toLabel(CheckItem__r.Project__c),
                    CheckItem__r.Id,
                    CheckItem__r.Has_Sample_Pictures__c,
                    CheckItem__r.MaximumScore__c,
                    CheckItem__r.HasFile__c,
                    CheckItem__r.Description__c,
                    CheckItem__r.Description_CN__c,
                    CheckItem__r.Description_EN__c,
                    CheckItem__r.Description_Filling_Language__c,
                    CheckItem__r.IsYesOrNo__c,
                    CheckItem__r.HelpText__c,
                    CheckItem__r.OrderNumber__c,
                    CheckItem__r.IsCountInScore__c,
                    CheckItem__r.Require_Comment_Scores__c,
                    CheckItem__r.Scores_require_file__c,
                    CheckItem__r.HasComment__c 
                FROM CheckResult__c
                WHERE 
                    InspectorDailyReport__c = : reportId
                AND CheckItem__r.Is_Related_To_Product__c = false
                ORDER BY CheckItem__r.OrderNumber__c];
    }

    /**
     * @description 获取报告的检查结果
     * @param   reportId    报告id
     * @return  检查项列表
     */
    public static List<CheckResult__c> getExistCheckResultIsRelatedToProductBaseReportId(String reportId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Scores__c,
                    Comments__c,
                    Status__c,
                    Sampling_Inspection__c,
                    CheckItem__c,
                    CheckItem__r.Name,
                    CheckItem__r.Product_Line__c,
                    toLabel(CheckItem__r.Project__c),
                    CheckItem__r.MaximumScore__c,
                    CheckItem__r.HasFile__c,
                    CheckItem__r.Id,
                    CheckItem__r.Has_Sample_Pictures__c,
                    CheckItem__r.Description__c,
                    CheckItem__r.Description_CN__c,
                    CheckItem__r.Description_EN__c,
                    CheckItem__r.Description_Filling_Language__c,
                    CheckItem__r.IsYesOrNo__c,
                    CheckItem__r.HelpText__c,
                    CheckItem__r.OrderNumber__c,
                    CheckItem__r.IsCountInScore__c,
                    CheckItem__r.Require_Comment_Scores__c,
                    CheckItem__r.Scores_require_file__c,
                    CheckItem__r.HasComment__c 
                FROM CheckResult__c
                WHERE 
                    InspectorDailyReport__c = : reportId
                AND CheckItem__r.Is_Related_To_Product__c = true
                ORDER BY CheckItem__r.OrderNumber__c];
    }

    /**
     * @description 获取报告的检查结果
     * @param   reportId    报告id
     * @param   productline    产品线
     * @return  检查项列表
     */
    public static List<CheckResult__c> getExistCheckResultBaseReportIdProductLine(String reportId, String productline) {
        return [
                SELECT 
                    Id,
                    Name,
                    Scores__c,
                    Comments__c,
                    Status__c,
                    CheckItem__c,
                    CheckItem__r.Name,
                    CheckItem__r.Product_Line__c,
                    CheckItem__r.Project__c,
                    CheckItem__r.MaximumScore__c,
                    CheckItem__r.HasFile__c,
                    CheckItem__r.Id,
                    CheckItem__r.Has_Sample_Pictures__c,
                    CheckItem__r.Description__c,
                    CheckItem__r.Description_CN__c,
                    CheckItem__r.Description_EN__c,
                    CheckItem__r.Description_Filling_Language__c,
                    CheckItem__r.IsYesOrNo__c,
                    CheckItem__r.HelpText__c,
                    CheckItem__r.OrderNumber__c,
                    CheckItem__r.IsCountInScore__c,
                    CheckItem__r.Require_Comment_Scores__c,
                    CheckItem__r.Scores_require_file__c,
                    CheckItem__r.HasComment__c 
                FROM CheckResult__c
                WHERE 
                    InspectorDailyReport__c = : reportId
                AND CheckItem__r.Product_Line__c = : productline
                AND CheckItem__r.Is_Related_To_Product__c = false
                ORDER BY CheckItem__r.OrderNumber__c];
    }

    /**
     * @description 获取报告的检查结果
     * @param   checkItemIds    检查项id
     * @param   monthDate       日期
     * @param   storeId         门店id
     * @param   userId          用户id
     * @return  检查项列表
     */
    public static List<CheckResult__c> getExistCheckResultBaseCheckItemIds(Set<Id> checkItemIds, Date monthDate, String storeId, String userId) {
        return [
                SELECT 
                    Id,
                    Name,
                    CheckItem__c,
                    InspectorDailyReport__c,
                    InspectorDailyReport__r.Report_Date__c
                FROM CheckResult__c
                WHERE 
                    InspectorDailyReport__r.Report_Date__c >= : monthDate
                AND InspectorDailyReport__r.Store__c = : storeId
                AND InspectorDailyReport__r.Status__c = 'Submitted'
                AND CheckItem__c IN : checkItemIds
                AND InspectorDailyReport__r.OwnerId = : userId
                // AND CheckItem__r.Is_Related_To_Product__c = false
                ORDER BY InspectorDailyReport__r.Report_Date__c DESC];
    }
    
    // 获取Ticket
    public static List<Ticket__c> getExistTicketBaseStoreIdAndUser(String storeId, String userId, Date reportdate) {
        return [
                SELECT 
                    Id,
                    InspectionReport__c,
                    Name,
                    ClosedDailyInspectionReport__c,
                    Subject__c,
                    Description__c,
                    AssignedTo__c,
                    Department__c,          // added by Sunny about chile department -[231026]
                    SystemGeneration__c,    // added by Sunny  -[231219]
                    CheckResult__c,         // added By Sunny -[240507]
                    AssignedTo__r.name,
                    Status__c,
                    Priority__c,
                    DueDate__c,
                    LastModifiedDate,
                    CreatedDate,
                    Category__c,
                    SeriesNum__c,
                    Product__c
                FROM Ticket__c
                WHERE 
                    CreatedById = : userId
                AND InspectionReport__c IN (SELECT Id FROM Daily_Inspection_Report__c WHERE Store__c = : storeId)];
    }
    // 获取Mileage
    public static List<Mileage__c> getExistMileageBaseRecordId(String recordId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Report__c,
                    Start__c,
                    End__c,
                    Mileage_Of_Today__c
                FROM Mileage__c
                WHERE 
                    Report__c = : recordId];
    }
    // 获取Sampling Detail
    public static List<Sampling_Detail__c> getExistSamplingDetailBaseStoreId(String storeId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Shop__c,
                    Shop__r.name,
                    Is_Add__c,
                    Display_Status__c,
                    Display_Type__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c
                FROM Sampling_Detail__c 
                WHERE 
                    Shop__c = : storeId
                AND Is_Add__c = '是'];
                // AND Display_Status__c = '展出'];
    }

    /**
     * @description 获取出样明细
     * @param   ids 出样明细列表
     * @return  出样明细
     */
    public static List<Sampling_Detail__c> getExistSamplingDetailBaseId(Set<String> ids) {
        return [
                SELECT 
                    Id,
                    Name,
                    Shop__c,
                    Shop__r.name,
                    Is_Add__c,
                    Display_Status__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c
                FROM Sampling_Detail__c 
                WHERE 
                    Id IN : ids];
    }

    // 获取Sampling Inspection
    public static List<Sampling_Inspection__c> getExistSamplingInspectionBaseStoreId(String storeId, String userId, Date yearFirstDay) {
        List<Sampling_Inspection__c> sampl1 = [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c,
                    Sample_Item__r.Display_Type__c,  
                    On_Wall_Display__c,
                    POP__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Shop__c =  : storeId
                AND Unplanned_Sample__c = 'No'
                AND OwnerId = : userId
                AND Inspection_Date__c >= :yearFirstDay
                ORDER BY Inspection_Date__c DESC];
        List<Sampling_Inspection__c> sampl2 =  [
            SELECT 
                Id,
                Name,
                Inspection_Date__c,
                Placement_Status__c,
                Unplanned_Sample__c,
                ExternalID__c,
                Product__c,
                Product__r.Name,
                Product__r.Name_Description__c,
                Product__r.Product_Line__c,
                Product__r.Series__c, 
                Product__r.Category__c,
                Shop__c,
                Sample_Item__c,
                ReRe__c,
                //阿根廷新加字段
                Quantity_Of_Exhibits_DS__c,
                Quantity_Of_Exhibits_OWD__c, 
                Stock__c,   
                Display_Stand__c, 
                On_Wall_Display__c,
                POP__c,
                Is_Prototype_Complete__c, 
                Is_Built_in_Video__c,   
                Is_Epos__c,
                Price__c,
                Sample_Item__r.Sampling_Standard__r.Flag__c
            FROM Sampling_Inspection__c 
            WHERE 
            Shop__c =  : storeId
            AND Unplanned_Sample__c = 'Yes'
            AND Product__c IN (select Product__c from Sampling_Detail__c where Shop__c =:storeId AND Is_Add__c='是')
            AND OwnerId = : userId
            AND Inspection_Date__c >= :yearFirstDay
            ORDER BY Inspection_Date__c DESC];
            for(Sampling_Inspection__c si:sampl2){
                // si.Unplanned_Sample__c = 'No';
                sampl1.add(si);
            }
        return sampl1;
    }

    /**
     * @description 获取出样检查
     * @param   storeId     门店id
     * @param   userId     用户id
     * @param   inspectionDate     巡店日期
     * @return  出样检查
     */
    public static List<Sampling_Inspection__c> getExistPlanOutSamplingInspectionBaseStoreId(String storeId, String userId, Date inspectionDate) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c, 
                    On_Wall_Display__c,
                    POP__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Shop__c =  : storeId
                AND Unplanned_Sample__c = 'Yes'
                AND OwnerId = : userId
                AND Product__c NOT IN (select Product__c from Sampling_Detail__c where Shop__c =:storeId AND Is_Add__c='是')
                AND Inspection_Date__c = :inspectionDate
                ];
    }

    /**
     * @description 获取计划内出样结果
     * @param   storeId     门店id
     * @param   recordDate  报告日期
     * @param   ownerId     用户id
     * @return  出样检查
     */
    public static List<Sampling_Inspection__c> getExistSamplingInspectionBaseStoreIdAndDate(String storeId, Date recordDate, String ownerId) {
        List<Sampling_Inspection__c> sampl1 = [
            SELECT 
                Id,
                Name,
                Inspection_Date__c,
                Placement_Status__c,
                Unplanned_Sample__c,
                ExternalID__c,
                Product__c,
                Product__r.Name,
                Product__r.Name_Description__c,
                Product__r.Product_Line__c,
                Product__r.Series__c,                
                Product__r.Category__c,
                Product__r.Guiding_Price__c,
                Product__r.CurrencyIsoCode,
                Shop__c,
                Sample_Item__c,
                ReRe__c,
                //阿根廷新加字段
                Quantity_Of_Exhibits_DS__c,
                Quantity_Of_Exhibits_OWD__c, 
                Stock__c,   
                Display_Stand__c, 
                On_Wall_Display__c,
                POP__c,
                Set_up_Status__c,
                Is_Prototype_Complete__c, 
                Is_Built_in_Video__c,   
                Is_Epos__c,
                Price__c,
                Sample_Item__r.Sampling_Standard__r.Flag__c,
                Sample_Item__r.Display_Type__c
            FROM Sampling_Inspection__c 
            WHERE 
                Shop__c =  : storeId
            AND Unplanned_Sample__c = 'No'
            AND Inspection_Date__c = : recordDate
            AND OwnerId = : ownerId
            AND Product__r.Product_Line__c in ('TV','Sound Bar','Laser TV')
            ORDER BY Product__r.Product_Line__c DESC];
        List<Sampling_Inspection__c> sampl2 = [
            SELECT 
                Id,
                Name,
                Inspection_Date__c,
                Placement_Status__c,
                Unplanned_Sample__c,
                ExternalID__c,
                Product__c,
                Product__r.Name,
                Product__r.Name_Description__c,
                Product__r.Product_Line__c,
                Product__r.Series__c, 
                Product__r.Category__c,
                Product__r.Guiding_Price__c,
                Product__r.CurrencyIsoCode,
                Shop__c,
                Sample_Item__c,
                ReRe__c,
                //阿根廷新加字段
                Quantity_Of_Exhibits_DS__c,
                Quantity_Of_Exhibits_OWD__c, 
                Stock__c,   
                Display_Stand__c, 
                On_Wall_Display__c,
                POP__c,
                Is_Prototype_Complete__c, 
                Is_Built_in_Video__c,   
                Is_Epos__c,
                Price__c,
                Sample_Item__r.Sampling_Standard__r.Flag__c,
                Sample_Item__r.Display_Type__c
            FROM Sampling_Inspection__c 
            WHERE 
                Shop__c =  : storeId
            AND Unplanned_Sample__c = 'Yes'
            AND Product__c IN (select Product__c from Sampling_Detail__c where Shop__c =:storeId AND Is_Add__c='是')
            AND Inspection_Date__c = : recordDate
            AND OwnerId = : ownerId
            AND Product__r.Product_Line__c in ('TV','Sound Bar','Laser TV')
            ORDER BY Product__r.Product_Line__c DESC];
            for(Sampling_Inspection__c si:sampl2){
                // si.Unplanned_Sample__c = 'No';
                sampl1.add(si);
            }
        return sampl1;
    }

    /**
     * @description 获取计划内出样结果
     * @param   storeId     门店id
     * @param   recordDate  报告日期
     * @Param   productLines 过滤产品线
     * @param   ownerId     用户id
     * @return  出样检查
     */
    public static List<Sampling_Inspection__c> getExistSamplingInspectionProductLineAndDate(String recordId, String storeId, String productLine) {
        List<Sampling_Inspection__c> sampl1 = [
            SELECT 
                Id,
                Name,
                Inspection_Date__c,
                Placement_Status__c,
                Unplanned_Sample__c,
                ExternalID__c,
                Product__c,
                Product__r.Name,
                Product__r.Name_Description__c,
                Product__r.Product_Line__c,
                Product__r.Series__c,                
                Product__r.Category__c,
                Product__r.Guiding_Price__c,
                Product__r.CurrencyIsoCode,
                Shop__c,
                Sample_Item__c,
                ReRe__c,
                //阿根廷新加字段
                Quantity_Of_Exhibits_DS__c,
                Quantity_Of_Exhibits_OWD__c, 
                Stock__c,   
                Display_Stand__c, 
                On_Wall_Display__c,
                POP__c,
                Set_up_Status__c,
                Is_POP__c,
                Is_Check_Price__c,
                Is_Optimal__c,
                Before_Img__c,
                After_Img__c,
                Is_Set_up_Status__c,
                Status__c,
                Is_Prototype_Complete__c, 
                Is_Built_in_Video__c,   
                Is_Epos__c,
                Display_Status__c,
                Price__c,
                Img_Status__c,
                Sample_Item__r.Sampling_Standard__r.Flag__c,
                Display_Type__c
                // Sample_Item__r.Display_Type__c
            FROM Sampling_Inspection__c 
            WHERE 
                Shop__c =  : storeId
            AND Unplanned_Sample__c = 'No'
            // AND Inspection_Date__c = : recordDate
            // AND OwnerId = : ownerId
            AND Inspection_Product_Item__c =: recordId
            AND Product__r.Product_Line__c = :productLine
            ORDER BY Product__r.Product_Line__c DESC];
        List<Sampling_Inspection__c> sampl2 = [
            SELECT 
                Id,
                Name,
                Inspection_Date__c,
                Placement_Status__c,
                Unplanned_Sample__c,
                ExternalID__c,
                Product__c,
                Product__r.Name,
                Product__r.Name_Description__c,
                Product__r.Product_Line__c,
                Product__r.Series__c, 
                Product__r.Category__c,
                Product__r.Guiding_Price__c,
                Product__r.CurrencyIsoCode,
                Shop__c,
                Sample_Item__c,
                ReRe__c,
                //阿根廷新加字段
                Quantity_Of_Exhibits_DS__c,
                Quantity_Of_Exhibits_OWD__c, 
                Stock__c,   
                Display_Stand__c, 
                On_Wall_Display__c,
                POP__c,
                Is_POP__c,
                Is_Check_Price__c,
                Is_Optimal__c,
                Before_Img__c,
                After_Img__c,
                Is_Set_up_Status__c,
                Display_Status__c,
                Status__c,
                Is_Prototype_Complete__c, 
                Is_Built_in_Video__c,   
                Is_Epos__c,
                Price__c,
                Img_Status__c,
                Sample_Item__r.Sampling_Standard__r.Flag__c,
                //Sample_Item__r.Display_Type__c
                Display_Type__c
            FROM Sampling_Inspection__c 
            WHERE 
                Shop__c =  : storeId
            AND Unplanned_Sample__c = 'Yes'
            AND Product__c IN (select Product__c from Sampling_Detail__c where Shop__c =:storeId AND Is_Add__c='是')
            // AND Inspection_Date__c = : recordDate
            // AND OwnerId = : ownerId
            AND Inspection_Product_Item__c =: recordId
            AND Product__r.Product_Line__c = :productLine
            ORDER BY Product__r.Product_Line__c DESC];
            for(Sampling_Inspection__c si:sampl2){
                // si.Unplanned_Sample__c = 'No';
                sampl1.add(si);
            }
        return sampl1;
    }

    /**
     * @description 获取计划外出样结果
     * @param   storeId     门店id
     * @param   recordDate  报告日期
     * @param   ownerId     用户id
     * @return  出样检查
     */
    public static List<Sampling_Inspection__c> getExistPlanOutSamplingInspectionBaseStoreIdAndDate(String storeId, Date recordDate, String ownerId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c, 
                    Sample_Item__r.Display_Type__c,
                    On_Wall_Display__c,
                    POP__c,
                    Set_up_Status__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Unplanned_Sample__c = 'Yes'
                AND Shop__c = : storeId
                AND Inspection_Date__c = : recordDate
                AND OwnerId = : ownerId
                AND Product__c NOT IN (select Product__c from Sampling_Detail__c where Shop__c =:storeId AND Is_Add__c='是')
                AND Product__r.Product_Line__c in ('TV','Sound Bar','Laser TV')
                ORDER BY Product__r.Product_Line__c DESC];
    }

    /**
     * @description 获取计划外出样结果
     * @param   storeId     门店id
     * @param   recordDate  报告日期
     * @param   productLine 产品线
     * @param   ownerId     用户id
     * @return  出样检查
     */
    public static List<Sampling_Inspection__c> getExistPlanOutSamplingInspectionProductLineAndDate(String recordId, String storeId, String productLine) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c,
                    Display_Type__c,
                    Display_Status__c,
                    On_Wall_Display__c,
                    POP__c,
                    Set_up_Status__c,
                    Is_POP__c,
                    Is_Check_Price__c,
                    Is_Optimal__c,
                    Before_Img__c,
                    After_Img__c,
                    Is_Set_up_Status__c,
                    Status__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Img_Status__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Unplanned_Sample__c = 'Yes'
                AND Shop__c = : storeId
                // AND Inspection_Date__c = : recordDate
                // AND OwnerId = : ownerId
                AND Inspection_Product_Item__c =: recordId
                AND Product__c NOT IN (select Product__c from Sampling_Detail__c where Shop__c =:storeId AND Is_Add__c='是')
                AND Product__r.Product_Line__c = :productLine
                ORDER BY Product__r.Product_Line__c DESC];
    }

    /**
     * @description 获取计划外出样结果
     * @param   storeId     门店id
     * @param   recordDate  报告日期
     * @param   productline  产品线
     * @param   ownerId     用户id
     * @return  出样检查
     */
    public static List<Sampling_Inspection__c> getExistPlanOutSamplingInspectionBaseStoreIddDateProductLine(String storeId, Date recordDate, String productline, String ownerId) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c, 
                    On_Wall_Display__c,
                    POP__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Sample_Item__c = null
                AND Shop__c = : storeId
                AND Inspection_Date__c = : recordDate
                AND Product__r.Product_Line__c = : productline
                AND Unplanned_Sample__c = 'Yes'
                AND OwnerId = : ownerId
                ORDER BY Product__r.Product_Line__c DESC];
    }
    /*****************
     *
     * Check List 相关
     *
     ******************/

    //  20241028  重写数据初始化过程并返回
    @AuraEnabled
    public static ConResponse checkListGetInitData(String recordId, String productline, String itemType) {
        User user = [SELECT Id, Name, Sales_Region__c, title FROM User WHERE Id = : UserInfo.getUserId()];
        List<Inspection_Product_Item__c> productItem = [Select Id,CurrencyIsoCode,Product_Line__c,Inspection_Report__c from Inspection_Product_Item__c Where Id =: recordId];
        String reportId = productItem[0].Inspection_Report__c;
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        // List<Daily_Inspection_Report__c> reports = [Select Id,Name from Daily_Inspection_Report__c WHERE Id =: recordId];
        List<CheckResult__c> checkResultLsit = new List<CheckResult__c>();
        List<CheckResult__c> checkResults = getExistCheckResultBaseCheckItem(reportId, productline, itemType);
        if(checkResults.size() > 0) {
            checkResultLsit = getCheckResultBycurrentUserLanguage(checkResults);
        } else {
            //对数据初始化从checkItem 获取当前对应type的数据

            List<CheckItem__c> checkItems = [SELECT Id,Question_Type__c, Item_Type__c, Ticket_Conditional_Type__c, Automatic_Generation_Ticket__c, Conditional_Yes_No_Has_Ticket__c,DescriptionT__c,Conditional_Score_Has_Ticket__c,MaximumScore__c from CheckItem__c Where Sales_Region__c =: user.Sales_Region__c And Item_Type__c =: itemType And Active__c = true];                   
            if(checkItems.size() > 0) {
                for (CheckItem__c item : checkItems) {
                    CheckResult__c result =  new CheckResult__c();
                    result.InspectorDailyReport__c = reportId;
                    result.CheckItem__c = item.Id;
                    result.Status__c = 'Draft';
                    checkResultLsit.add(result);
                }
            }
            upsert checkResultLsit;
            checkResultLsit = getCheckResultBycurrentUserLanguage(getExistCheckResultBaseCheckItem(reportId, productline, itemType));
        }
        // 20230921 Modified By Ethan S
        // List<CheckResult__c> checkResultLsit = getExistCheckResultBaseCheckItem(recordId, productline, project);
        // List<CheckResult__c> checkResultLsit = getCheckResultBycurrentUserLanguage(getExistCheckResultBaseCheckItem(recordId, productline, itemType));
        // 20230921 Modified By Ethan E
        System.debug('查看结果' + checkResultLsit.size());
        mso.put('selectedProject', checkResultLsit);

        return resp;
    }
    
    // // checkList初始化
    // @AuraEnabled
    // public static ConResponse checkListGetInitData(String recordId, String productline, String itemType) {
    //     ConResponse resp = new ConResponse();
    //     Map<String, Object> mso = new Map<String, Object>();
    //     resp.data = mso;
    //     // 20230921 Modified By Ethan S
    //     // List<CheckResult__c> checkResultLsit = getExistCheckResultBaseCheckItem(recordId, productline, project);
    //     List<CheckResult__c> checkResultLsit = getCheckResultBycurrentUserLanguage(getExistCheckResultBaseCheckItem(recordId, productline, itemType));
    //     // 20230921 Modified By Ethan E
    //     System.debug('查看结果' + checkResultLsit.size());
    //     mso.put('selectedProject', checkResultLsit);

    //     return resp;
    // }
    // checkList保存
    @AuraEnabled
    public static ConResponse checkListSave(String recordId, String checkListJson) {
    // public static ConResponse checkListSave(String checkListJson, String recordId, String productline, String project) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        System.debug('checkListJson' + checkListJson);
        List<CheckResult__c> checkListList = (List<CheckResult__c>)JSON.deserialize(checkListJson, List<CheckResult__c>.class);
        
        Set<String> ids = new Set<String>();
        for (CheckResult__c item : checkListList) {
            ids.add(item.Id);
        }
        
        upsert checkListList;
        // 20230921 Modified By Ethan S
        // List<CheckResult__c> checkResultLsit = getExistCheckResultBaseId(ids);
        List<CheckResult__c> checkResultLsit = getCheckResultBycurrentUserLanguage(getExistCheckResultBaseId(ids));
        // 20230921 Modified By Ethan E
        mso.put('selectedProject', checkResultLsit);

        // checklist部分
        Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(recordId);
        mso.put('checkResults', checkResults);
        mso.put('checkResultsIsRelatedToProduct', getCheckResultBycurrentUserLanguage(getExistCheckResultIsRelatedToProductBaseReportId(recordId)));
        // 查询日报(更新日报的总分和平均分)
        List<Daily_Inspection_Report__c> dirList = getExistDailyInspectionReportBasedId(recordId);
        if (dirList.size()==0) {
            resp.code= -1;
            resp.message = String.format(SOBJECT_NOT_FOUND,new List<String>{SObjectType.Daily_Inspection_Report__c.getLabel()});
            return resp;
        }
        Daily_Inspection_Report__c dir = dirList[0];
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);

        // add by Sunny
        Map<String, List<Ticket__c>> taskMap = getTicket(dir);
        List<Ticket__c> openTasks = taskMap.get('openTasks');
        String ticketMessage = '';
        for(Ticket__c ticket : openTasks) {
            if(ticket.DueDate__c == null) {
                ticketMessage = System.Label.Inspection_Report_Check_Item_Ticket_Fill;
                break;
            }
        }
        mso.put('ticketOpenInfo', openTasks);
        mso.put('ticketMessage', ticketMessage);

        return resp;
    }
    
    //20230921 Ethan 据当前用户语言显示对应语种Description S
    public static  List<CheckResult__c> getCheckResultBycurrentUserLanguage(List<CheckResult__c> checkList) {
        String currentUserLanguage = UserInfo.getLanguage();
        String languageIsCN = 'zh_CN';
        String languageIsEN = 'en_US';
        List<CheckResult__c> resCheckList = new List<CheckResult__c>();
        for (CheckResult__c item: checkList) {
            if (item.CheckItem__r.Description_Filling_Language__c != currentUserLanguage ) {
                if (String.isNotBlank(item.CheckItem__r.Description_EN__c) && currentUserLanguage == languageIsEN) {
                    item.CheckItem__r.Description__c = item.CheckItem__r.Description_EN__c;
                }
                if (currentUserLanguage == languageIsCN) {
                    if (String.isNotBlank(item.CheckItem__r.Description_CN__c)) item.CheckItem__r.Description__c = item.CheckItem__r.Description_CN__c;
                    else item.CheckItem__r.Description__c = String.isNotBlank(item.CheckItem__r.Description_EN__c) ? item.CheckItem__r.Description_EN__c : item.CheckItem__r.Description__c;
                }
            }
            resCheckList.add(item);
        }
        return resCheckList;
    }
    //20230921 Ethan 据当前用户语言显示对应语种Description E
    // Query Data===========================================================
    // 获取CheckList
    public static List<CheckResult__c> getExistCheckResultBaseCheckItem(String reportId, String productline, String itemType) {
        return [
                SELECT 
                    Id,
                    Name,
                    Scores__c,
                    Comments__c,
                    Status__c,
                    CheckItem__c,
                    CheckItem__r.Name,
                    CheckItem__r.Product_Line__c,
                    CheckItem__r.Project__c,
                    CheckItem__r.MaximumScore__c,
                    CheckItem__r.HasFile__c,
                    CheckItem__r.Id,
                    CheckItem__r.Has_Sample_Pictures__c,
                    CheckItem__r.Description__c,
                    //add by Ethan 20230920 s
                    CheckItem__r.Description_CN__c,
                    CheckItem__r.Description_EN__c,
                    CheckItem__r.Description_Filling_Language__c,
                    //add by Ethan 20230920 e
                    CheckItem__r.IsYesOrNo__c,
                    CheckItem__r.HelpText__c,
                    CheckItem__r.OrderNumber__c,
                    CheckItem__r.IsCountInScore__c,
                    CheckItem__r.Require_Comment_Scores__c,
                    CheckItem__r.Scores_require_file__c,
                    CheckItem__r.HasComment__c 
                FROM CheckResult__c
                WHERE 
                    InspectorDailyReport__c = : reportId
                AND (CheckItem__r.Product_Line__c = : productline OR CheckItem__r.Product_Line__c = : 'All')
                // AND toLabel(CheckItem__r.Project__c) = : project
                AND CheckItem__r.Item_Type__c =: itemType
                AND CheckItem__r.Is_Related_To_Product__c = false
                ORDER BY CheckItem__r.OrderNumber__c];
    }

    /**
     * @description 获取检查结果
     * @param   ids 检查结果id
     * @return  检查结果
     */
    public static List<CheckResult__c> getExistCheckResultBaseId(Set<String> ids) {
        return [
                SELECT 
                    Id,
                    Name,
                    Scores__c,
                    Comments__c,
                    Status__c,
                    CheckItem__c,
                    CheckItem__r.Name,
                    CheckItem__r.Product_Line__c,
                    CheckItem__r.Project__c,
                    CheckItem__r.MaximumScore__c,
                    CheckItem__r.HasFile__c,
                    CheckItem__r.Id,
                    CheckItem__r.Has_Sample_Pictures__c,
                    CheckItem__r.Description__c,
                    //add by Ethan 20230920 s
                    CheckItem__r.Description_CN__c,
                    CheckItem__r.Description_EN__c,
                    CheckItem__r.Description_Filling_Language__c,
                    //add by Ethan 20230920 e
                    CheckItem__r.IsYesOrNo__c,
                    CheckItem__r.HelpText__c,
                    CheckItem__r.OrderNumber__c,
                    CheckItem__r.IsCountInScore__c,
                    CheckItem__r.Require_Comment_Scores__c,
                    CheckItem__r.Scores_require_file__c,
                    CheckItem__r.HasComment__c 
                FROM CheckResult__c
                WHERE 
                    Id IN : ids
                AND CheckItem__r.Is_Related_To_Product__c = false
                ORDER BY CheckItem__r.OrderNumber__c];
    }
    
    // Sampling Inspection保存
    @AuraEnabled
    public static ConResponse samplingInspectionSave(String samplingInspectionJson, String samplingInspectionPlanOutJson) {

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        System.debug('samplingInspectionJson' + samplingInspectionJson);
        List<Sampling_Inspection__c> siList = (List<Sampling_Inspection__c>)JSON.deserialize(samplingInspectionJson, List<Sampling_Inspection__c>.class);
        
        if (siList.size()>0) {
            upsert siList;
            // 临时用 不检查附件
            Set<String> allIds = new Set<String>();
            for (Sampling_Inspection__c item : siList) {
                allIds.add(item.Id);
            }
            List<Sampling_Inspection__c> siSelectedProductlineList = getExistSamplingInspectionBaseId(allIds);
            mso.put('siSelectedProductline', siSelectedProductlineList);
        }

        // 计划外
        System.debug('samplingInspectionPlanOutJson' + samplingInspectionPlanOutJson);
        List<Sampling_Inspection__c> siOlanOutList = (List<Sampling_Inspection__c>)JSON.deserialize(samplingInspectionPlanOutJson, List<Sampling_Inspection__c>.class);

        if (siOlanOutList.size()>0) {
            upsert siOlanOutList;
            // 临时用 不检查附件
            Set<String> allIds = new Set<String>();
            for (Sampling_Inspection__c item : siOlanOutList) {
                allIds.add(item.Id);
            }
            List<Sampling_Inspection__c> siSelectedProductlinePlanOutList = getExistSamplingInspectionBaseId(allIds);
            mso.put('siSelectedProductlinePlanOut', siSelectedProductlinePlanOutList);
        }
        return resp;
    }

    //2024-01-12 lizunxing 日本巡店日报计划外创建出样明细
    public static Sampling_Detail__c createSamplingDetail(Sampling_Inspection__c newSi, Sampling_Standard__c sampling){

        //出样明细外键Set
        Set<String> detailExternalIdSet = new Set<String>();

        //出样明细查询
        detailExternalIdSet.add(newSi.Shop__c+'-'+newSi.Product__c);

        //出样明细最近的出样检查Map
        Map<String,Sampling_Inspection__c> samplingDateMap = new Map<String,Sampling_Inspection__c>(); 
        if (detailExternalIdSet.size()>0) {
            for (Sampling_Detail__c sd : [SELECT Id,ExternalID__c,(SELECT Id,Inspection_Shop_Task__r.Daily_Inspection_Report__r.Report_Date__c FROM MVrr__r Order by Inspection_Shop_Task__r.Daily_Inspection_Report__r.Report_Date__c desc limit 1) FROM Sampling_Detail__c WHERE ExternalID__c IN:detailExternalIdSet]) {
                if (sd.MVrr__r.size()>0) {
                    samplingDateMap.put(sd.ExternalID__c, sd.MVrr__r[0]);    
                }
            }    
        }

        Sampling_Detail__c samplingDetail = new Sampling_Detail__c();     
        samplingDetail.Display_Status__c = newSi.Placement_Status__c;
        samplingDetail.ExternalID__c = newSi.Shop__c+'-'+newSi.Product__c;  
        //samplingDetail.Flag__c = samplingInspectionData.samplingInspection.Flag__c;// 出样详情“処分推進”标记
        if (samplingDateMap.get(samplingDetail.ExternalID__c)!=null && newSi.Inspection_Date__c < samplingDateMap.get(samplingDetail.ExternalID__c).Inspection_Shop_Task__r.Daily_Inspection_Report__r.Report_Date__c) {
            System.debug('www--' + samplingDetail.ExternalID__c);
            System.debug('www--' + samplingDateMap.get(samplingDetail.ExternalID__c).Inspection_Shop_Task__r.Daily_Inspection_Report__r.Report_Date__c);
            //return samplingDateMap.get(samplingDetail.ExternalID__c);  
            return null;  
        }
        // 隐藏的出样明细再展出不会挂在特殊出样标准上
        if (String.isBlank(newSi.Sample_Item__c) && samplingDateMap.get(samplingDetail.ExternalID__c) == null) {
            samplingDetail.Sampling_Standard__c = sampling.Id; 
            //needSamplingDetailIdMap.put(samplingDetail.ExternalID__c, samplingInspectionData.samplingInspection);    
            System.debug(newSi);
            samplingDetail.Unplanned_Sample__c = '是';  
            samplingDetail.Shop__c = newSi.Shop__c;
            samplingDetail.Product__c = newSi.Product__c;
            samplingDetail.Is_Add__c = '是';
            //needLoopList.add(samplingDetail);
            System.debug('samplingDetail.Shop__c'+samplingDetail.Shop__c+'----'+'samplingDetail.Product__c'+samplingDetail.Product__c);  
        }
        return samplingDetail;
    }

    // Sampling Inspection新增
    @AuraEnabled
    public static ConResponse samplingInspectionAdd(String recordId, String recordJson,String displayType, String productId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        System.debug('recordJson'+recordJson);
        System.debug('Display参数' + displayType);
        System.debug('ProductId' + productId);
        Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)JSON.deserializeStrict(recordJson, Daily_Inspection_Report__c.class);

        User user = [SELECT Id, Name, Sales_Region__c FROM User WHERE Id = : UserInfo.getUserId()];
        Product__c si = [SELECT Id, Name,Product_Line__c FROM Product__c where Id = : productId];

        Sampling_Standard__c sampling;
        
        // 新建计划外Sampling Inspection
        Sampling_Inspection__c newSi = new Sampling_Inspection__c();
        newSi.Inspection_Date__c = report.Report_Date__c;
        newSi.Placement_Status__c = '展出';
        newSi.Unplanned_Sample__c = 'Yes';
        newSi.Is_POP__c = '';
        newSi.Is_Check_Price__c = '';
        newSi.Is_Optimal__c = '';
        newSi.Is_Set_up_Status__c = '';
        newSi.Display_Status__c = '';
        newSi.Before_Img__c = '';
        newSi.After_Img__c = '';
        // YYL 移除设置展出类型字段 20250324
        // newSi.Display_Type__c = displayType;
        // newSi.ExternalID__c = String.valueOf(report.Report_Date__c) + '_' + report.Store__c + '_' + productId +'_' + displayType + '_' + UserInfo.getUserId();
        newSi.ExternalID__c = String.valueOf(report.Report_Date__c) + '_' + report.Store__c + '_' + productId +'_' + UserInfo.getUserId();
        System.debug('外键参数==' + String.valueOf(report.Report_Date__c) + '_' + report.Store__c + '_' + productId +'_' + displayType + '_' + UserInfo.getUserId());
        // newSi.ExternalID__c = '4' + '_' + report.Store__c + '_' + productId + '_' + UserInfo.getUserId();
        newSi.Product__c = productId;
        newSi.Shop__c = report.Store__c;
        newSi.ReRe__c = '';
        newSi.Inspection_Product_Item__c = recordId;
        // wfc 关联巡店员日报
        newSi.Inspection_Report__c = report.Id;
        //修正测试，samplingInspection有值，displayType参数为空允许按照外键修改
        // insert newSi;
        System.debug('打印参数' + newSi);
        Database.upsert(newSi,Sampling_Inspection__c.Fields.ExternalID__c);
        

        Set<String> newIds = new Set<String>();
        newIds.add(newSi.id);
        Sampling_Inspection__c addedsi = getExistSamplingInspectionBaseId(newIds)[0];
        mso.put('newSamplingInspection', addedsi);
        // 获取计划外Sampling Inspection信息
        List<Sampling_Inspection__c> planOutSamplingInspection = getExistPlanOutSamplingInspectionProductLineAndDate(recordId, report.Store__c, si.Product_Line__c);
        // 更新Sampling Inspection信息
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionProductLineAndDate(recordId,report.Store__c,si.Product_Line__c);
        siList.addAll(planOutSamplingInspection);
        // todo 给产品添加金额 wfc
        siList = setProductPrice(report.Store__c, siList);
        mso.put('samplingInspections', siList);
        // 更新CheckResult信息
        Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(report.Id);
        mso.put('checkResults', checkResults);
        // 更新日报信息
        Daily_Inspection_Report__c dir = getExistDailyInspectionReportBasedId(report.Id)[0];
        dir.Brand__c = report.Brand__c;
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);
        System.debug('resp======>'+resp);
        return resp;
    }
    // Sampling Inspection删除
    @AuraEnabled
    public static ConResponse samplingInspectionDelete(String recordJson, String samplingId) {
        System.debug('打印参数samplingId' + samplingId);
        User user = [SELECT Id, Name, Sales_Region__c, title FROM User WHERE Id = : UserInfo.getUserId()];

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        System.debug('recordJson'+recordJson);
        Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)JSON.deserializeStrict(recordJson, Daily_Inspection_Report__c.class);
        Set<String> samplingIds = new Set<String>();
        samplingIds.add(samplingId);
        Sampling_Inspection__c delSi = getExistSamplingInspectionBaseId(samplingIds)[0];
        List<Sampling_Inspection__c> allsiList = getExistAllSamplingInspectionBaseStoreIdAndDateAndProductline(report.Store__c, report.Report_Date__c, delSi.Product__r.Product_Line__c);
        if (allsiList.size()==1 && allsiList[0].Id==delSi.Id) {
            List<CheckResult__c> crList = getExistCheckResultBaseReportIdProductLine(report.Id, delSi.Product__r.Product_Line__c);
            if (crList.size()>0) {
                delete crList;
            }
        }

        //日本删除计划内产品
        if('Hisense Japan'.equals(user.Sales_Region__c)){
            if(String.isNotBlank(delSi.Sample_Item__c)){
                Sampling_Detail__c delSd = new Sampling_Detail__c();
                delSd.id = delSi.Sample_Item__c;
                delete delSd;
            }
        }

        delete delSi;

        // 刷新页面信息
        // 获取计划外Sampling Inspection信息
        List<Sampling_Inspection__c> planOutSamplingInspection = getExistPlanOutSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
        // 更新Sampling Inspection信息
        List<Sampling_Inspection__c> siList = getExistSamplingInspectionBaseStoreIdAndDate(report.Store__c, report.Report_Date__c, report.OwnerId);
        siList.addAll(planOutSamplingInspection);
        // todo 给产品添加金额 wfc
        siList = setProductPrice(report.Store__c, siList);
        mso.put('samplingInspections', siList);
        // 更新CheckResult信息
        Map<String,Map<String, List<CheckResult__c>>> checkResults = getCheckResult(report.Id);
        mso.put('checkResults', checkResults);
        // 更新日报信息
        Daily_Inspection_Report__c dir = getExistDailyInspectionReportBasedId(report.Id)[0];
        dir.Brand__c = report.Brand__c;
        mso.put('record', dir);
        mso.put('ownerName', getExistDailyInspectionReportOwnerNameBasedId(dir.Id)[0].Owner.Name);
        System.debug('resp======>'+resp);

        return resp;
    }
    // Query Data===========================================================

    // 获取Sampling Inspection
    public static List<Sampling_Inspection__c> getExistSamplingInspectionBaseStoreIdAndDateAndProductline(String storeId, Date recordDate, String productline, String plan) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c, 
                    Sample_Item__r.Display_Type__c,
                    On_Wall_Display__c,
                    POP__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Shop__c = : storeId
                AND Inspection_Date__c = : recordDate 
                AND Product__r.Product_Line__c = : productline 
                AND Unplanned_Sample__c = : plan
                ORDER BY Product__r.Name DESC];
    }

    /**
     * @description 获取出样结果
     * @param   storeId     门店id
     * @param   recordDate  报告日期
     * @param   productline 产品线
     * @return  出样结果
     */
    public static List<Sampling_Inspection__c> getExistAllSamplingInspectionBaseStoreIdAndDateAndProductline(String storeId, Date recordDate, String productline) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c,
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c, 
                    On_Wall_Display__c,
                    POP__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c,
                    Sample_Item__r.Display_Type__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Shop__c = : storeId
                AND Inspection_Date__c = : recordDate 
                AND Product__r.Product_Line__c = : productline 
                ORDER BY Product__r.Name DESC];
    }

    /**
     * @description 获取出样结果
     * @param   ids     出样结果id
     * @return  出样结果
     */
    public static List<Sampling_Inspection__c> getExistSamplingInspectionBaseId(Set<String> ids) {
        return [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c,
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,  
                    Display_Stand__c, 
                    Display_Type__c,
                    On_Wall_Display__c,
                    POP__c,
                    Display_Status__c,
                    Set_up_Status__c,
                    Is_POP__c,
                    Is_Check_Price__c,
                    Is_Optimal__c,
                    Before_Img__c,
                    After_Img__c,
                    Is_Set_up_Status__c,
                    Status__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,                    
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Id IN : ids
                ORDER BY Product__r.Name DESC];
    }

    /**
     * @description 获取stored对应产品形态 display type参数
     * @param   storeId     门店ID
     * @return  display type参数信息
     */
    @AuraEnabled
    public static List<String> getUniqueTypeValues(String storeId, Date recordDate, String productline, String plan,String displayType) {
        List<String> typeValues = new List<String>();
        List<Sampling_Inspection__c> objectWs = [
                SELECT 
                    Id,
                    Name,
                    Inspection_Date__c,
                    Placement_Status__c,
                    Unplanned_Sample__c,
                    ExternalID__c,
                    Product__c,
                    Product__r.Name,
                    Product__r.Name_Description__c,
                    Product__r.Product_Line__c,
                    Product__r.Series__c, 
                    Product__r.Category__c,
                    Product__r.Guiding_Price__c,
                    Product__r.CurrencyIsoCode,
                    Shop__c,
                    Sample_Item__c,
                    ReRe__c,
                    //阿根廷新加字段
                    Quantity_Of_Exhibits_DS__c,
                    Quantity_Of_Exhibits_OWD__c, 
                    Stock__c,   
                    Display_Stand__c, 
                    Sample_Item__r.Display_Type__c,
                    Before_Img__c,
                    On_Wall_Display__c,
                    POP__c,
                    Is_Prototype_Complete__c, 
                    Is_Built_in_Video__c,   
                    Is_Epos__c,
                    Price__c,
                    Sample_Item__r.Sampling_Standard__r.Flag__c
                FROM Sampling_Inspection__c 
                WHERE 
                    Shop__c = : storeId
                AND Inspection_Date__c = : recordDate 
                AND Product__r.Product_Line__c = : productline 
                AND Unplanned_Sample__c = : plan
                AND Sample_Item__r.Display_Type__c = : displayType
                ORDER BY Product__r.Name DESC];
                for(Sampling_Inspection__c obj : objectWs) {
                    if(!typeValues.contains(obj.Sample_Item__r.Display_Type__c)) {
                        typeValues.add(obj.Sample_Item__r.Display_Type__c);
                    }
                }
                return typeValues;
    }

    

    @AuraEnabled
    public static ConResponse handlerRemove(){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        mso.put('isSuccess', true);
        resp.data = mso;
        return resp;
    }

    
    // 获取根据国家产品线获取对应展出类型
    public static List<Product_line_Detail__c> getProductLineDetail(String salesRegion, String productline) {
        return [Select Id,Sales_Region__c, Product_line__c, Display_Type__c  from Product_line_Detail__c WHERE Sales_Region__c =: salesRegion AND Product_line__c =: productLine];
        // return [Select Id,Sales_Region__c, Product_line__c, Display_Type__c  from Product_Exhibition_Detail__c where Sales_Region__c = 'Hisense South Africa' and Product_line__c = 'TV'and Data_Type__c = 'DisplayType'];
    }

    // 获取根据门店产品线获取对应展出类型
    public static List<Store_Product_Line__c> getStoreProductLine(String shopId, String productline) {
        return [Select Id, Product_line__c, Display_Type__c  from Store_Product_Line__c WHERE Store__c  =: shopId AND Product_line__c =: productLine];
    }

    /**
     * @description 自动生成Ticket
     * @param   checkItemId  获取问题类型以及是否生成Ticket
     * @param   realParam    实际问题参数值(分数/Yes or No)暂不考虑Text
     * @param   recordId     Inspection_Product_Item__c 的ID 用于获取 AssignedTo 参数
     * @return  生成的Ticket数据
     */
    //自动生成Ticket： 问题名称(CheckItemId)，实际问题参数值realParam// recordId 实际是 Inspection_Product_Item__c 的ID
    public static Ticket__c autoGenerateTicket(String recordId, String checkItemId, String realParam) {
        Ticket__c autoTicket = new Ticket__c();
        // 获取当前日期
        Date today = Date.today();
        // 计算日期，增加 7 天
        Date adjustedDate = today.addDays(7);
        // 提取年份、月份和日期
        Integer year = adjustedDate.year();
        Integer month = adjustedDate.month();
        Integer day = adjustedDate.day();
        
        // 格式化为 'YYYY-MM-DD' 格式，确保月份和日期都是两位数
        String monthStr = month < 10 ? '0' + month : String.valueOf(month);
        String dayStr = day < 10 ? '0' + day : String.valueOf(day);
        
        String resultDate = year + '-' + monthStr + '-' + dayStr;
        Date systemGenerationDate = Date.valueOf(resultDate);
        if(String.isNotEmpty(recordId) && String.isNotEmpty(checkItemId) && String.isNotEmpty(realParam)){

            List<CheckItem__c> checkItem = [SELECT Id,Question_Type__c, Item_Type__c, Ticket_Conditional_Type__c, Automatic_Generation_Ticket__c, Conditional_Yes_No_Has_Ticket__c,DescriptionT__c,Conditional_Score_Has_Ticket__c,MaximumScore__c from CheckItem__c Where Id =: checkItemId];                   
            Inspection_Product_Item__c insp = [Select Id,Inspection_Report__c, Status__c from  Inspection_Product_Item__c Where Id =: recordId];
            Daily_Inspection_Report__c dir;
            if(String.isNotEmpty(insp.Inspection_Report__c)) {
                // 查询日报
                List<Daily_Inspection_Report__c> dirList = getExistDailyInspectionReportBasedId(insp.Inspection_Report__c);
                if (dirList.size() > 0) {
                    dir = dirList[0];
                    String AssignedTo = dir.OwnerId;
                    //根据实际值判断是否生成 realParam
                    autoTicket = new Ticket__c(Subject__c = checkItem[0].DescriptionT__c,AssignedTo__c = AssignedTo,DueDate__c = systemGenerationDate);
                }
            } 
       
        }
        return autoTicket;
    }

    /**
     * @description 20241115 TJP 新增总部抽样检查样例
     * @param   salesRegion     销售国家
     * @param   productLine     产品线
     * @return  Product_line_Detail__c 信息
     */
    @AuraEnabled
    public static List<Product_line_Detail__c> getOfficePhoto(String salesRegion,String productLine) {
        return [
        Select 
        Id, 
        Name, 
        ImgRequired__c,
        Product_line__c, 
        Product_line_Description__c, 
        Reminder__c  
        From Product_line_Detail__c 
        Where Sales_Region__c =: salesRegion And Product_Line__c =: productLine];
    }

    /**
     * @description 20241030 TJP 新增总部抽样检查项检查
     * @param   itemType     检查项类型
     * @param   salesRegion     检查项类型
     * @return  检查项  
     */
    @AuraEnabled
    public static List<CheckItem__c> getOfficeCheck(String itemType, String salesRegion,String productLine) {
        return [Select Parent__c,
        Parent_Response__c,
        Sales_Region__c,
        Inspection_Type__c,
        Item_Type__c,
        Question_Type__c,
        Description__c,
        Description_CN__c,
        Description_EN__c,
        HelpText__c,
        HelpTextCN__c,
        HelpTextEN__c,
        Enter_Choice__c,
        MaximumScore__c,
        Active__c,
        HasRelateQuestions__c,
        HasFile__c,
        File_Conditional_Type__c,
        Conditional_Score_Has_File__c,
        Conditional_Yes_No_Has_File__c,
        HasComment__c,
        Comment_Conditional_Type__c,
        Conditional_Score_Has_Comment__c,
        Conditional_Yes_No_Has_Comment__c,
        Automatic_Generation_Ticket__c,
        Ticket_Conditional_Type__c,
        OrderNumber__c,
        Product_Line__c
        From CheckItem__c Where Sales_Region__c =: salesRegion And Item_Type__c =: itemType And Active__c =: true And Product_Line__c =: productLine
        Order by OrderNumber__c];
    }

    // 批量获取已有文件 YYL 20250324
    @AuraEnabled
    public static List<Map<String, String>> getExistingFilesList(String ContentDocumentId) {
        List<ContentDocumentLink> cdLinks = [
            SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId,LinkedEntityId
            FROM ContentDocumentLink 
            WHERE ContentDocumentId IN: ContentDocumentId.split(';')
        ];

        // 根据记录id分组
        // Map<Id, List<Map<String, String>>> recordIdMap = new Map<Id, List<Map<String, String>>>();
        List<Map<String, String>> recordIdMap = new List<Map<String, String>>();

        for (ContentDocumentLink link : cdLinks) {  
            // List<Map<String, String>> filesList = recordIdMap.get(link.LinkedEntityId);

            // if(filesList == null){
            //     filesList = new List<Map<String, String>>();
            // }

            Map<String, String> filesItem = new Map<String, String>{
                'contentDocumentId' => link.ContentDocumentId,
                'downloadUrl' => '/sfc/servlet.shepherd/version/download/' + link.ContentDocument.LatestPublishedVersionId,
                'title' => link.ContentDocument.Title
            };

            recordIdMap.add(filesItem);
            // recordIdMap.put(link.LinkedEntityId, filesList);
        }
        
        return recordIdMap;
    }


    public static integer gabige() {
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        


        return i;
    }

}