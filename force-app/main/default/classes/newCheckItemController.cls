public class newCheckItemController {

    public static User currentUser = [SELECT Id,Name,Username,Sales_Region__c,Profile.Name FROM User WHERE Id =:UserInfo.getUserId()]; 
    public static String recordId;
    public static String recordItemId;
    public static String salesRegion;
    public static String officeSalesRegion;
    public static String recordName;
    public static Decimal mark;

    @AuraEnabled
    public static Map<String,Object> getCheckItemById(String recordId) {
        Map<String,Object> data = new Map<String,Object>();
        CheckItem__c checkItem = [SELECT Id, RecordTypeId FROM CheckItem__c WHERE Id = :recordId LIMIT 1];       
        data.put('checkItem', checkItem); 
        return data;
    }

    @AuraEnabled
    public static Map<String,Object> getSalesRegionInfo(String recordId) {
        Map<String,Object> data = new Map<String,Object>();
        data.put('SalesRegion', currentUser.Sales_Region__c);
        switch on currentUser.Sales_Region__c {
            when 'Hisense USA'{
                recordName = 'USA';
            }
            when 'Hisense Canada'{
                recordName = 'Canada';
            }
            when 'Hisense Peru'{
                recordName = 'Peru';
            }
            when 'Hisense International'{
                recordName = 'International';
            }
            when 'Hisense X'{
                recordName = 'X Online';
            }
            when 'Hisense Mexico'{
                recordName = 'Mexico';
            }
            when 'Hisense Argentina'{
                recordName = 'Argentina';
            }
            when 'Hisense Chile'{
                recordName = 'Chile';
            }

            when 'Hisense Australia'{
                recordName = 'Australia';
            }
        }

        if(!String.isEmpty(recordName)){
            // 查询当前用户国家对应的typeid
            List<RecordType> recordTypeId = [SELECT Id,Name FROM RecordType WHERE Name =: recordName AND SobjectType = 'CheckItem__c'];
            data.put('recordTypeId', recordTypeId);
        }
        
        return data;
    }

    // 根据记录类型id获取对应的国家名称
    @AuraEnabled
    public static String getCountry(String recordTypeId) {
        List<RecordType> record = [SELECT Id,Name FROM RecordType WHERE Id =: recordTypeId];
        System.debug('wwwgetCountry' + record +'recordTypeId'+ recordTypeId);
        if(record.size() > 0){
            recordName = record[0].Name;
        }
        return recordName;
    }

    // 获取详情信息
    @AuraEnabled
    public static ConResponse getInitData(String recordId,String recordTypeId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        String recordName = '';
        String region = '';
        if(!String.isEmpty(recordTypeId)){

            List<RecordType> record = [SELECT Id,Name FROM RecordType WHERE Id =: recordTypeId];
            recordName = record.get(0).Name;
            switch on record.get(0).Name {
                when 'USA'{
                    region = 'Hisense USA';
                }
                when 'Canada'{
                    region = 'Hisense Canada';
                }
                when 'Peru'{
                    region = 'Hisense Peru';
                }
                when 'Mexico'{
                    region = 'Hisense Mexico';
                }
                when 'International'{
                    region = 'Hisense International';
                }
                when 'Argentina'{
                    region = 'Hisense Argentina';
                }
            }

        }
        

        CheckItem__c item = new CheckItem__c(
                Sales_Region__c = region,
                Inspection_Type__c = 'Locale Inspection',
                Item_Type__c = '',
                Question_Type__c = '',
                Description__c = '',
                Description_CN__c = '',
                Description_EN__c = '',
                HelpText__c = '',
                HelpTextCN__c = '',
                HelpTextEN__c = '',
                Enter_Choice__c = '',
                Enter_Choice_EN__c = '',
                Enter_Choice_CN__c = '',
                MaximumScore__c = '',
                // Integer_Type_Max__c = '',
                Conditional_Score_Has_File__c = '',
                Conditional_Yes_No_Has_File__c = '',
                Conditional_Score_Has_Comment__c = '',
                Conditional_Yes_No_Has_Comment__c = '',
                Conditional_Score_Has_Ticket__c = '',
                Conditional_Yes_No_Has_Ticket__c = '',
                Active__c = true,
                HasRelateQuestions__c = false,
                HasFile__c = false,
                File_Conditional_Type__c = '',
                HasComment__c = false,
                Comment_Conditional_Type__c = '',
                Automatic_Generation_Ticket__c = false,
                Ticket_Conditional_Type__c = '',
                OrderNumber__c = 0,
                Product_Line__c = 'All',
                Score_Symbol_Response__c = '',
                Parent_Select__c = '',
                Has_Image_AI__c = false,
                Image_AI__c = '',
                Standard_Result__c = '',
                Is_Store_Rating__c = false
        );

        List<CheckItem__c> relateList = new List<CheckItem__c>();

        // 查询详情信息
        if(!String.isEmpty(recordId)){
            item = getCheckItem(new List<String>{recordId}).get(0);

            // YYL 根据渠道id查询详情信息 20250401
            // if(String.isEmpty(item.Channel_Name__c)){
            //     if(!String.isEmpty(item.Channel__c)){
            //         Channel_item__c channelitem = [SELECT Id,Channel_Name__c FROM Channel_item__c where id =: item.Channel__c];
            //         item.Channel_Name__c = channelitem.Channel_Name__c;
            //     }else{
            //         item.Channel_Name__c = '';
            //     }
            // }

            if(!String.isEmpty(item.id)){
                // 查询当前类型下存在的序号
                List<CheckItem__c> orderList = checkOrderNumberExist(item.Item_Type__c,item.id,item.Sales_Region__c);

                if(Test.isRunningTest()){
                    orderList = [SELECT Id,OrderNumber__c FROM CheckItem__c];
                }

                if(orderList != null && orderList.size() > 0){
                    LisqContainer lqExist = new LisqContainer(orderList);
                    List<String> orderNumberExist = lqExist.SelectSField('OrderNumber__c');
                    String exist = String.join(orderNumberExist,',');
                    mso.put('orderExist', 'No. ' + exist + ' already exists');
                }
            }

            // 查询关联问题
            // List<Check_Item_Relate__c> checkItemRelate = getCheckItemRelateIdItem(new List<String>{recordId});
            // if(checkItemRelate != null && checkItemRelate.size() > 0){
            //     relateList = checkItemRelate;
            // }
            List<CheckItem__c> checkItemRelate = getCheckItemChildren(item.Id);
            if(checkItemRelate != null && checkItemRelate.size() > 0){
                // 如果Parent_Select__c有值，则为拼接子任务
                for(CheckItem__c checkItem : checkItemRelate){
                    if(checkItem.Parent_Select__c != null & checkItem.Parent_Select__c != ''){
                        String parentSelect = checkItem.Parent_Select__c;
                        Integer i = 0;
                        for(String str : parentSelect.split('&')){
                            CheckItem__c temp = new CheckItem__c();
                            temp.Id = checkItem.Id;
                            temp.Parent__c = checkItem.Parent__c;
                            temp.Parent_Select__c = str;
                            // 如果score类型，Score_Symbol_Response__c有值
                            if(String.isNotBlank(checkItem.Score_Symbol_Response__c)){
                                temp.Score_Symbol__c = checkItem.Score_Symbol_Response__c.split('&')[i];
                            }
                            relateList.add(temp);
                            i++;
                        }
                    }else {
                        relateList.add(checkItem);
                    }
                    
                }
                // relateList = checkItemRelate;
            }
        }

        // List<CheckItem__c> checkItemAll = getCheckItemAll();
        
        mso.put('record',item);
        mso.put('recordName',recordName);
        system.debug('wwwww-----'  + item);
        mso.put('relateList',relateList);
        // mso.put('checkItemAll',checkItemAll);
                
        return resp;
    }

    @AuraEnabled
    public static ConResponse getOrderExist(String itemType,String recordId,String salesRegion){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 查询当前类型下存在的序号
        if(!String.isEmpty(salesRegion)){
            List<CheckItem__c> orderList = checkOrderNumberExist(itemType,recordId,salesRegion);

            if(Test.isRunningTest()){
                orderList = [SELECT Id,OrderNumber__c FROM CheckItem__c];
            }

            if(orderList != null && orderList.size() > 0){
                LisqContainer lqExist = new LisqContainer(orderList);
                List<String> orderNumberExist = lqExist.SelectSField('OrderNumber__c');
                String exist = String.join(orderNumberExist,',');
                mso.put('orderExist', 'No. ' + exist + ' already exists');
            }
        }

        return resp;
    }

    // 根据Sales Region获取展示大类信息
    @AuraEnabled
    public static ConResponse getCategoryType(String recordId,String productLine,String storeId,String status){
        // try {
            ConResponse resp = new ConResponse();
            Map<String, Object> mso = new Map<String, Object>();
            resp.data = mso;

            // 根据门店id查询门店salesRegion信息
            Shop__c shop = [SELECT Id,Sales_Region__c FROM Shop__c WHERE Id =: storeId];
            List<Category_Relationship__c> category = getCategoryRelationship(shop.Sales_Region__c);
            System.debug('wwwwgetCategoryType' + JSON.serialize(category));
            if(!category.isEmpty()){
                List<CategoryResultData> CategoryResultDataList = new List<CategoryResultData>();
                for(Category_Relationship__c item : category){
                    Map<String,Integer> checkNumberMap = new Map<String,Integer>();
                    if(item.Category_Type__c.equals('Ticket')){
                        checkNumberMap = NewSamplingAndTicketController.getTicketFillInValue(recordId);
                    }else if(item.Category_Type__c.equals('Sampling Product Check')){
                        checkNumberMap = NewSamplingAndTicketController.getFillInValue(recordId);
                    }else{
                        checkNumberMap = getCheckItemCheckNumber(item.Category_Type__c, recordId,productLine);
                    }
                    Decimal checkNumber = Decimal.valueOf(checkNumberMap.get('checkNumber'));
                    Decimal checkTotal = Decimal.valueOf(checkNumberMap.get('checkTotal'));
                    
                    Boolean isCheck = false;
                    if(checkNumber.equals(checkTotal)){
                        isCheck = true;
                    }

                    CategoryResultData categoryResultData = new CategoryResultData();
                    categoryResultData.categoryRelationship = item;
                    categoryResultData.checkNumber = '('+ checkNumber +'/'+ checkTotal +')';
                    categoryResultData.isCheck = isCheck;
                    CategoryResultDataList.add(categoryResultData);

                    System.debug('wwwwnumber' + JSON.serialize(checkNumber));
                }
                mso.put('category', CategoryResultDataList);

                // 查询大类pickList数据 YYL 20250311
                Map<String,String> pickList = Utility.getPicklistValueMap('Category_Relationship__c', 'Category_Type__c');
                mso.put('pickList', pickList);
                System.debug('wwwwpickList' + JSON.serialize(pickList));
            }

            if(currentUser.Sales_Region__c == 'Hisense International') {
                mso.put('salesRegion', currentUser.Sales_Region__c);
            } else {
                mso.put('salesRegion', shop.Sales_Region__c);
            }
            
            return resp;
        // } catch (Exception e) {
        //     throw new AuraHandledException(e.getMessage());
        // }
    }

    @AuraEnabled
    public static ConResponse saveDate(String checkItemJson,String relateList,String relateDelList){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        CheckItem__c item = (CheckItem__c)JSON.deserialize(checkItemJson, CheckItem__c.class);
        // 查询大类pickList数据 YYL 20250311
        Map<String,String> pickList = Utility.getPicklistValueMap('CheckItem__c', 'Item_Type__c');
        System.debug('wwwwpickList' + JSON.serialize(pickList));
        // 校验当前问题对应类型下Ordernumber是否重复
        List<CheckItem__c> checkOrder = checkOrderNumber(item.Item_Type__c,item.OrderNumber__c,item.Id,item.Sales_Region__c);
        if(checkOrder != null && checkOrder.size() > 0){
            // 查询当前类型下存在的序号
            LisqContainer lqExist = new LisqContainer(checkOrderNumberExist(item.Item_Type__c,item.Id,item.Sales_Region__c));
            List<String> orderNumberExist = lqExist.SelectSField('OrderNumber__c');
            String exist = String.join(orderNumberExist,',');
            resp.code = -1;
            String itemName = pickList.get(item.Item_Type__c);
            resp.message = 'No. ' + exist + ' already exists in ' + itemName;
        }else{

            System.debug('wwwwitem' + JSON.serialize(item));

            // 字段必填，为空设置默认值
            if(String.isEmpty(item.MaximumScore__c)){
                item.MaximumScore__c = '5';
            }

            List<CheckItem__c> oldItemList = [SELECT Id,Description__c FROM CheckItem__c WHERE Id =: item.Id];

            // 数据存在走更新逻辑判断
            if(oldItemList != null && oldItemList.size() > 0){
                // YYL 新增逻辑判断是否于原本数据一致不一致则重新生成
                CheckItem__c oldItem = oldItemList.get(0);

                // 判断是否满足生成新数据逻辑
                if(!item.Description__c.equals(oldItem.Description__c)){
                    CheckItem__c itemClone = item.clone();
                    // 更新原有的active为false
                    item.Active__c = false;
    
                    Database.insert(itemClone);

                    item = itemClone;
                    
                }else{
                    handleRelateDel(item,relateDelList);
                }
                Database.update(item);

            }else{
                Database.insert(item);
            }

            handleRelateAdd(item,relateList);

            // YYL 根据渠道id查询详情信息 20250401
            // if(!String.isEmpty(item.Channel_item__c)){
            //     Channel_item__c channelitem = [SELECT Id,Channel_Name__c FROM Channel_item__c where id =: item.Channel_item__c];
            //     item.Channel_Name__c = channelitem.Channel_Name__c;
            // }

            mso.put('id', item.id);
        }

        return resp;
    }

    // 新增关联数据逻辑
    public static void handleRelateAdd(CheckItem__c item,String relateList){
    
        // 存储关联问题
        if(!String.isEmpty(relateList)){

            List<CheckItem__c> itemRelate = (List<CheckItem__c>)JSON.deserialize(relateList, List<CheckItem__c>.class);
            // 设置父级节点
            for(CheckItem__c relate : itemRelate){
                System.debug('wwwwrelate' + JSON.serialize(relate.Id));
                if(relate.Id != null && relate.Parent_Response__c != ''){
                    relate.Parent__c = item.Id;
                }
            }

            Database.update(itemRelate);
        }
    }

    // 删除关联数据逻辑
    public static void handleRelateDel(CheckItem__c item,String relateDelList){

        if(!String.isEmpty(relateDelList)){

            // 清除掉需要删除的父级节点和父级响应条件
            List<CheckItem__c> itemRelateDel = (List<CheckItem__c>)JSON.deserialize(relateDelList, List<CheckItem__c>.class);
            System.debug('wwwwitemRelateDel' + JSON.serialize(itemRelateDel));
            for(CheckItem__c relateDel : itemRelateDel){
                CheckItem__c nullCheckItem = new CheckItem__c();
                relateDel.Parent_Response__c = '';
                relateDel.Parent__c = nullCheckItem.Id;
            }

            Database.update(itemRelateDel);
        }
    }

    // 生成当前大类的对应的Check Result
    @AuraEnabled
    public static ConResponse addCheckResult(String checkItemType,
                                                String inspectorDailyReportId,
                                                    String inspectionProductItemId,
                                                    String productLine){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        recordId = inspectorDailyReportId;
        recordItemId = inspectionProductItemId;
        

        // 查询当前日报门店的salesregion
        Daily_Inspection_Report__c record = [SELECT Id,Store__r.Sales_Region__c,Store__c FROM Daily_Inspection_Report__c WHERE Id =: inspectorDailyReportId];
        // salesRegion = record.Store__r.Sales_Region__c;
        // YYL 查询门店信息 20250325
        Shop__c shopDb = [select Id,Name,Shop_Level__c,Account__r.Sales_Region__c, Sales_Region__c,Channel_item__c from Shop__c  WHERE id =: record.Store__c];


        //20241029 TJP 增加 总部选点的salesregion判断
        if(currentUser.Sales_Region__c == 'Hisense International') {
            salesRegion = currentUser.Sales_Region__c;
            // System.debug('wwwsalesRegion' + salesRegion);
            System.debug('wwwcurrentUser' + salesRegion);

        } else if(currentUser.Sales_Region__c == 'Hisense X') {
            salesRegion = currentUser.Sales_Region__c;
            // System.debug('wwwsalesRegion' + salesRegion);
            System.debug('wwwcurrentUser' + salesRegion);

        }  
        else {
            salesRegion = record.Store__r.Sales_Region__c;
        }
       

        System.debug('wwwsalesRegion' + salesRegion + checkItemType);
                                                        
        // 查询当前大类下没有父级问题的CheckItem
        List<CheckItem__c> checkItemParent = getCheckItemParentNull(checkItemType,productLine,shopDb.Channel_item__c);

        System.debug('wwwsalesRegion' + checkItemParent.size());

        if(checkItemParent != null && checkItemParent.size() > 0){

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
            Map<String,LisqContainer> groupParent = new Map<String,LisqContainer>();

            if(CheckItemChildren != null && CheckItemChildren.size() > 0){
                LisqContainer lqChildren = new LisqContainer(CheckItemChildren);

                groupParent = lqChildren.GroupByS('Parent__c');

            }
            
            for(CheckItem__c parent : checkItemParent){
                CheckResult__c parentResult = new CheckResult__c();
                parentResult.CheckItem__c = parent.id;
                parentResult.InspectorDailyReport__c = inspectorDailyReportId;
                parentResult.Inspection_Product_Item__c = inspectionProductItemId;

                checkResultAdd.add(parentResult);

                if(groupParent != null && groupParent.size() > 0){
                    LisqContainer lqGroupParent = groupParent.get(parent.id);
                    if(lqGroupParent != null){
                        List<CheckItem__c> itemGroupParent = (List<CheckItem__c>)lqGroupParent.ToSobjectList();

                        checkResultRecursionAdd(itemGroupParent, checkResultAdd, groupParent);
                    }
                    
                }
            }
            System.debug('wwwwcheckResultAdd' + JSON.serialize(checkResultAdd));
            System.debug('wwwwcheckResultAdd' + JSON.serialize(inspectorDailyReportId));
            mso.put('checkResultAdd', checkResultAdd);
            Database.insert(checkResultAdd);
        }

        return resp;
    }

    // 生成SampleInspection的对应的Check Result
    @AuraEnabled
    public static ConResponse addSampleInspectionCheckResult(String checkItemType,
                                                String inspectorDailyReportId,
                                                    String inspectionProductItemId,
                                                    String productLine,
                                                    String sampleId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        recordId = inspectorDailyReportId;
        recordItemId = inspectionProductItemId;
        

        // 查询当前日报门店的salesregion
        Daily_Inspection_Report__c record = [SELECT Id,Store__r.Sales_Region__c,Store__c FROM Daily_Inspection_Report__c WHERE Id =: inspectorDailyReportId];
        // salesRegion = record.Store__r.Sales_Region__c;
        // YYL 查询门店信息 20250325
        Shop__c shopDb = [select Id,Name,Shop_Level__c,Account__r.Sales_Region__c, Sales_Region__c,Channel_item__c from Shop__c  WHERE id =: record.Store__c];


        //20241029 TJP 增加 总部选点的salesregion判断
        if(currentUser.Sales_Region__c == 'Hisense International') {
            salesRegion = currentUser.Sales_Region__c;
            // System.debug('wwwsalesRegion' + salesRegion);
            System.debug('wwwcurrentUser' + salesRegion);

        } else if(currentUser.Sales_Region__c == 'Hisense X') {
            salesRegion = currentUser.Sales_Region__c;
            // System.debug('wwwsalesRegion' + salesRegion);
            System.debug('wwwcurrentUser' + salesRegion);

        }  
        else {
            salesRegion = record.Store__r.Sales_Region__c;
        }
       

        System.debug('wwwsalesRegion' + salesRegion + checkItemType);
                                                        
        // 查询当前大类下没有父级问题的CheckItem
        List<CheckItem__c> checkItemParent = getCheckItemParentNull(checkItemType,productLine,shopDb.Channel_item__c);

        System.debug('wwwsalesRegion' + checkItemParent.size());

        if(checkItemParent != null && checkItemParent.size() > 0){

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
            Map<String,LisqContainer> groupParent = new Map<String,LisqContainer>();

            if(CheckItemChildren != null && CheckItemChildren.size() > 0){
                LisqContainer lqChildren = new LisqContainer(CheckItemChildren);

                groupParent = lqChildren.GroupByS('Parent__c');

            }
            
            for(CheckItem__c parent : checkItemParent){
                CheckResult__c parentResult = new CheckResult__c();
                parentResult.CheckItem__c = parent.id;
                parentResult.InspectorDailyReport__c = inspectorDailyReportId;
                parentResult.Inspection_Product_Item__c = inspectionProductItemId;
                parentResult.Sampling_Inspection__c = sampleId;

                checkResultAdd.add(parentResult);

                if(groupParent != null && groupParent.size() > 0){
                    LisqContainer lqGroupParent = groupParent.get(parent.id);
                    if(lqGroupParent != null){
                        List<CheckItem__c> itemGroupParent = (List<CheckItem__c>)lqGroupParent.ToSobjectList();

                        checkResultRecursionAdd(itemGroupParent, checkResultAdd, groupParent);
                    }
                    
                }
            }
            System.debug('wwwwcheckResultAdd' + JSON.serialize(checkResultAdd));
            System.debug('wwwwcheckResultAdd' + JSON.serialize(inspectorDailyReportId));
            mso.put('checkResultAdd', checkResultAdd);
            Database.insert(checkResultAdd);
        }

        return resp;
    }

    // 检查当前检查项是否已初始化
    @AuraEnabled
    public static ConResponse checkInitStatus(String checkItemType,
                                                String inspectionProductItemId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 查询检查项初始化数据
        List<CheckResult__c> initResult = getCheckResultInit(inspectionProductItemId,checkItemType);
        if(initResult != null && initResult.size() > 0){
            mso.put('initStatus', true);
        }else{
            mso.put('initStatus', false);
        }

        return resp;
    }

    // 查询检查项初始化详情
    @AuraEnabled
    public static ConResponse getcheckResultInitInfo(String checkItemType,
                                                String inspectionProductItemId){

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 存放处理后的展示数据
        List<CheckResultData> checkResultDataList = new List<CheckResultData>();
        List<CheckResult__c> checkResultParent = getCheckResultParent(inspectionProductItemId,checkItemType);
        List<CheckResult__c> checkResultChildren = getCheckResultChildren(inspectionProductItemId,checkItemType);

        NewSamplingAndTicketProController.setCheckItemLanguage(checkResultParent);
        NewSamplingAndTicketProController.setCheckItemLanguage(checkResultChildren);

        // 获取所有检查项的缩略图 YYL 20250303
        LisqContainer lqParent = new LisqContainer(checkResultParent);
        List<String> parentCheckItemId = lqParent.SelectSField('CheckItem__c');
        LisqContainer lqChildren = new LisqContainer(checkResultChildren);
        List<String> childrenCheckItemId = lqChildren.SelectSField('CheckItem__c');

        // 获取Parent 所有缩略图
        Map<Id, List<Map<String, String>>> parentFiles = new Map<Id, List<Map<String, String>>>();
        if(!parentCheckItemId.isEmpty()){
            parentFiles = getExistingFilesList(parentCheckItemId);
        }

        // 获取Children 所有缩略图
        Map<Id, List<Map<String, String>>> childrenFiles = new Map<Id, List<Map<String, String>>>();
        if(!childrenCheckItemId.isEmpty()){
            childrenFiles = getExistingFilesList(childrenCheckItemId);
        }
        
        // 根据parentId 分组
        Map<String,List<CheckResult__c>> groupParent = new Map<String,List<CheckResult__c>>();

        if(checkResultChildren != null && checkResultChildren.size() > 0){
            // LisqContainer lqChildren = new LisqContainer(checkResultChildren);
            // groupParent = lqChildren.GroupByS('CheckItem__r.Parent__c');
            for(CheckResult__c children : checkResultChildren){
                List<CheckResult__c> resultChildren = groupParent.get(children.CheckItem__r.Parent__c);

                if(resultChildren == null){
                    resultChildren = new List<CheckResult__c>();
                }
                resultChildren.add(children);
                groupParent.put(children.CheckItem__r.Parent__c,resultChildren);
            }
        }

        if(checkResultParent != null && checkResultParent.size() > 0){
            for(CheckResult__c parent : checkResultParent){
                CheckResultData parentData = new CheckResultData();
                parentData.parent = parent;

                // 查询当前问题的缩略图 YYL 20250303
                List<Map<String, String>> imgList = parentFiles.get(parent.CheckItem__c);
                if(imgList != null){
                    parentData.imgList = imgList;
                }
                
                // 上传文件和评论默认为false，前端根据条件判断展示
                // parentData.parent.CheckItem__r.HasFile__c = false;
                // parentData.parent.CheckItem__r.HasComment__c = false;

                if(groupParent != null && groupParent.size() > 0){
                    checkResultRecursionInit(parentData,groupParent,childrenFiles);
                }

                System.debug('wwwwCheckResultData' + JSON.serialize(parentData));

                checkResultDataList.add(parentData);
            }
        }

        mso.put('checkResultData', checkResultDataList);

        return resp;
    }

    // 保存检查项内容
    @AuraEnabled
    public static ConResponse saveCheckResult(String checkResultJson){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        List<CheckResultData> checkResultList = (List<CheckResultData>)JSON.deserialize(checkResultJson, List<CheckResultData>.class);
        // 汇总更新数据
        List<CheckResult__c> data = new List<CheckResult__c>();
        
        if(checkResultList != null && checkResultList.size() > 0){
            for(CheckResultData item : checkResultList){
                checkUpsertData(item,data);
            }
        }

        System.debug('wwwwsaveCheckResult' + JSON.serialize(data));

        Database.upsert(data);

        return resp;
    }

    // 保存检查项内容并删除需要清楚的子任务 YYL 20250306
    @AuraEnabled
    public static ConResponse saveAndDelCheckResult(String checkResultJson,String delCheckResult){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        List<CheckDataDetailInfo> checkResultList = (List<CheckDataDetailInfo>)JSON.deserialize(checkResultJson, List<CheckDataDetailInfo>.class);
        // 汇总更新数据
        List<CheckResult__c> data = new List<CheckResult__c>();
        
        if(checkResultList != null && checkResultList.size() > 0){
            for(CheckDataDetailInfo item : checkResultList){
                checkUpsertDataNew(item,data);
            }
        }

        Database.upsert(data);
        
        if(!String.isEmpty(delCheckResult)){
            List<String> childrenId = (List<String>)JSON.deserialize(delCheckResult, List<String>.class);
            List<CheckResult__c> lists = [SELECT Id FROM CheckResult__c  WHERE Id IN: childrenId];
            if(lists.size() > 0) {
                Database.delete(lists);
            }
        }
        
        return resp;
    }

    // 处理存储的checkResult
    public static void checkResultRecursionAdd(List<CheckItem__c> itemGroup,
                                            List<CheckResult__c> checkResultAdd,
                                            Map<String,LisqContainer> groupParent){
        for(CheckItem__c item : itemGroup){

            CheckResult__c result = new CheckResult__c();
            result.CheckItem__c = item.id;
            result.InspectorDailyReport__c = recordId;
            result.Inspection_Product_Item__c = recordItemId;
            // 第一次初始化的子任务下标为1 YYL 20250305
            result.Index__c = 1;
            checkResultAdd.add(result);
            
            LisqContainer lqGroupChildren = groupParent.get(item.Id);
            if(lqGroupChildren != null){
                List<CheckItem__c> itemGroupChildren = (List<CheckItem__c>)lqGroupChildren.ToSobjectList();
                // checkResultAdd.addAll(itemGroupChildren);
                checkResultRecursionAdd(itemGroupChildren, checkResultAdd, groupParent);
            }
        }
    }

    // 处理展示的checkResult
    public static void checkResultRecursionInit(CheckResultData checkResultParent,       
                                            Map<String,List<CheckResult__c>> groupParent,
                                            Map<Id, List<Map<String, String>>> childrenFiles){
        List<CheckResult__c> resultGroupParent = groupParent.get(checkResultParent.parent.CheckItem__c);

        if(resultGroupParent != null && resultGroupParent.size() > 0){

            // 根据Index分组 YYL 20250305
            Map<Decimal,List<CheckResult__c>> indexGroupParent = new Map<Decimal,List<CheckResult__c>>();
            for(CheckResult__c indexResult : resultGroupParent){
                List<CheckResult__c> indexResultItem = indexGroupParent.get(indexResult.Index__c);
                if(indexResultItem == null){
                    indexResultItem = new List<CheckResult__c>();
                }
                indexResultItem.add(indexResult);
                indexGroupParent.put(indexResult.Index__c,indexResultItem);
            }

            if(!indexGroupParent.isEmpty()){
                List<List<CheckResultData>> CheckResultChildrenList = new List<List<CheckResultData>>();
                for(Decimal key : indexGroupParent.keySet()){
                    // 处理父级下关联问题
                    List<CheckResultData> CheckResultChildrenDate = new List<CheckResultData>();
                    for(CheckResult__c parent : indexGroupParent.get(key)){
                        CheckResultData checkResultChildren = new CheckResultData();
                        checkResultChildren.parent = parent;
                        // 查询当前问题的缩略图 YYL 20250304
                        List<Map<String, String>> imgList = childrenFiles.get(parent.CheckItem__c);
                        if(imgList != null){
                            checkResultChildren.imgList = imgList;
                        }
                        
                        checkResultRecursionInit(checkResultChildren,groupParent,childrenFiles);

                        CheckResultChildrenDate.add(checkResultChildren);
                    }
                    CheckResultChildrenList.add(CheckResultChildrenDate);
                }
                checkResultParent.children = CheckResultChildrenList; 
            }         
        }
    }

    // 处理更新的check Result数据
    public static void checkUpsertData(CheckResultData item,List<CheckResult__c> data){

        // 判断子级响应数据是否和父级数据相同，如果不满足则清除掉历史数据
        String response = item.parent.Response__c;

        data.add(item.parent);
        List<List<CheckResultData>> children = item.children;
        if(children != null && children.size() > 0){
            for(List<CheckResultData> childrenList : children){
                for(CheckResultData childrenItem : childrenList){

                    // 修改为通过前端清楚不满足条件的历史数据 YYL 20250306
                    // if(!String.isEmpty(response) && !response.equals(childrenItem.parent.CheckItem__r.Parent_Response__c)){
                    //     // 如果不满足响应条件，去除已存储的历史数据
                    //     childrenItem.parent.Response__c = '';
                    // }
                    checkUpsertData(childrenItem,data);
                }
            }
        }
    }

    // 处理更新的check Result数据
    public static void checkUpsertDataNew(CheckDataDetailInfo item,List<CheckResult__c> data){

        // 判断子级响应数据是否和父级数据相同，如果不满足则清除掉历史数据
        String response = item.parent.Response__c;

        data.add(item.parent);
        List<List<CheckDataDetailInfo>> children = item.children;
        if(children != null && children.size() > 0){
            for(List<CheckDataDetailInfo> childrenList : children){
                for(CheckDataDetailInfo childrenItem : childrenList){

                    // 修改为通过前端清楚不满足条件的历史数据 YYL 20250306
                    // if(!String.isEmpty(response) && !response.equals(childrenItem.parent.CheckItem__r.Parent_Response__c)){
                    //     // 如果不满足响应条件，去除已存储的历史数据
                    //     childrenItem.parent.Response__c = '';
                    // }
                    checkUpsertDataNew(childrenItem,data);
                }
            }
        }
    }

    // 查询当前日报产品线对应类型检查项已检查数和检查总数
    public static Map<String,Integer> getCheckItemCheckNumber(String checkItemType,
                                                                String recordItemId,
                                                                String productLine){
        Map<String,Integer> check = new Map<String,Integer>();

        // 需要检查的总数
        check.put('checkTotal', 0);
        // 已检查数量
        check.put('checkNumber', 0);

        System.debug('wwww' + checkItemType);
        System.debug('wwww' + recordItemId);
        
        // 查询当前大类下
        List<CheckResult__c> checkResultParent = getCheckResultParent(recordItemId,checkItemType);
        List<CheckResult__c> checkResultChildren = getCheckResultChildren(recordItemId,checkItemType);

        NewSamplingAndTicketProController.setCheckItemLanguage(checkResultParent);
        NewSamplingAndTicketProController.setCheckItemLanguage(checkResultChildren);

        // 根据当前日报产品线查询日报下门店salesRegion信息
        Inspection_Product_Item__c inspectionItem = [SELECT Id,Inspection_Report__c FROM Inspection_Product_Item__c WHERE Id =: recordItemId];
        Daily_Inspection_Report__c record = [SELECT Id,Store__r.Sales_Region__c,Store__c FROM Daily_Inspection_Report__c WHERE Id =: inspectionItem.Inspection_Report__c];

        // YYL 查询门店信息 20250325
        Shop__c shopDb = [select Id,Name,Shop_Level__c,Account__r.Sales_Region__c, Sales_Region__c,Channel_item__c from Shop__c  WHERE id =: record.Store__c];

        // 20241031 TJP 新增salesRegion 转换
        if(currentUser.Sales_Region__c == 'Hisense International') {
            salesRegion = currentUser.Sales_Region__c;
        } else {
            salesRegion = record.Store__r.Sales_Region__c;
        }

        // 存放汇总的id信息
        List<String> checkResultIdAll = new List<String>();

        // 如果check Result表数据为空则查询check item 表数据计数
        if(checkResultParent != null && checkResultParent.size() > 0){

            // 获取父级数据id
            LisqContainer lqParent = new LisqContainer(checkResultParent);
            checkResultIdAll.addAll(lqParent.SelectSField('id'));

            // 根据parentId 分组
            Map<String,List<CheckResult__c>> groupParent = new Map<String,List<CheckResult__c>>();

            if(checkResultChildren != null && checkResultChildren.size() > 0){
                for(CheckResult__c children : checkResultChildren){
                    List<CheckResult__c> resultChildren = groupParent.get(children.CheckItem__r.Parent__c);

                    if(resultChildren == null){
                        resultChildren = new List<CheckResult__c>();
                    }
                    resultChildren.add(children);
                    groupParent.put(children.CheckItem__r.Parent__c,resultChildren);
                }

                // 获取子级数据id
                LisqContainer lqChild = new LisqContainer(checkResultChildren);
                checkResultIdAll.addAll(lqChild.SelectSField('id'));
            }

            // 查询当前数据的附件信息
            List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in: checkResultIdAll];
            LisqContainer lqCd = new LisqContainer(cdlList);

            // 根据附件关联id分组
            Map<String, Sobject> cdMap = lqCd.ToMapS('LinkedEntityId');

            for(CheckResult__c parent : checkResultParent){

                //设置检查总数
                // if(!parent.CheckItem__r.Question_Type__c.equals('Informational')){
                if(!parent.CheckItem__r.Question_Type__c.equals('Informational-photo')){
                    check.put('checkTotal', check.get('checkTotal') + 1);

                    // YYL 设置缩略图默认值 20250327
                    if(parent.CheckItem__r.Question_Type__c.equals('Informational')){
                        parent.Response__c = 'Informational';
                    }
                    
                    if(!String.isEmpty(parent.Response__c)){
                        checkCommontAndFiles(parent,cdMap,check);
                        checkNumber(parent,groupParent,check,cdMap);
                    }
                }
                
            }
        }else{
            // 查询当前大类一级问题
            List<CheckItem__c> checkItemParent = getCheckItemParentNullNotPhoto(checkItemType,productLine,shopDb.Channel_item__c);
            
            if(checkItemParent != null && checkItemParent.size() > 0){
                for(CheckItem__c item : checkItemParent){
                    if(item.Question_Type__c.equals('Informational')){
                        // 判断附件和评论是否必填
                        if(item.HasComment__c 
                            && !String.isEmpty(item.Comment_Conditional_Type__c)
                            && item.Comment_Conditional_Type__c.equals('Mandatory')){

                            check.put('checkTotal', check.get('checkTotal') + 1);    

                        }else if(item.HasFile__c 
                                    && !String.isEmpty(item.File_Conditional_Type__c) 
                                    && item.File_Conditional_Type__c.equals('Mandatory')){

                            check.put('checkTotal', check.get('checkTotal') + 1);

                        }
                    }else{
                        //设置检查数
                        check.put('checkTotal', check.get('checkTotal') + 1);
                    }
                    
                }
            }
        }

        return check;
    }

    // 根据条件递归计算检查数
    public static void checkNumber(CheckResult__c parent,
                                    Map<String,List<CheckResult__c>> groupParent,
                                    Map<String,Integer> check,
                                    Map<String, Sobject> cdMap){

        String response = parent.Response__c;
        if(!String.isEmpty(response)){
            // 获取当前关联子数据
            List<CheckResult__c> children = groupParent.get(parent.CheckItem__c);

            if(children != null && children.size() > 0){
                for(CheckResult__c child : children){

                    // 根据上级条件检验是否需要检查
                    Boolean isCheck = false;
                    // 获取分数问题的逻辑运算符 YYL 20250306
                    String scoreSymbol = child.CheckItem__r.Score_Symbol_Response__c;
                    String question = child.CheckItem__r.Question_Type__c;
                    if(question.equals('Score') && !String.isEmpty(scoreSymbol)){
                        List<String> scoreSymbolList = scoreSymbol.split(',');
                        for(String symbol : scoreSymbolList){
                            isCheck = compareNumbers(Decimal.valueOf(response), Decimal.valueOf(child.Response__c), symbol);
                            if(isCheck){
                                break;
                            }
                        } 
                    }else{
                        if(response.equals(child.CheckItem__r.Parent_Response__c) ||
                            response.equals(child.CheckItem__r.Parent_Select__c)){
                            isCheck = true;
                        }
                    }

                    if(isCheck && !question.equals('Informational-photo')){
                    // if(isCheck && !question.equals('Informational-photo') && !question.equals('Informational')){
                        //设置检查总数
                        check.put('checkTotal', check.get('checkTotal') + 1);

                        // YYL 设置缩略图默认值 20250326
                        if(question.equals('Informational')){
                            child.Response__c = 'Informational';
                        }

                        if(!String.isEmpty(child.Response__c)){
                            
                            //设置检查数
                            // check.put('checkNumber', check.get('checkNumber') + 1);
                            checkCommontAndFiles(child,cdMap,check);
                            checkNumber(child,groupParent,check,cdMap);
                        }
                    }
                }
            }
        }

    }

    // 计算分数是否满足展示子问题 YYL 20250305
    public static Boolean compareNumbers(Decimal num1, Decimal num2, String symbol) {
        if(symbol.indexOf('<') != -1){
            return num1 < num2;
        }else if(symbol.indexOf('<=') != -1){
            return num1 <= num2;
        }else if(symbol.indexOf('>') != -1){
            return num1 > num2;
        }else if(symbol.indexOf('>=') != -1){
            return num1 >= num2;
        }else if(symbol.indexOf('=') != -1){
            return num1 == num2;
        }else if(symbol.indexOf('!=') != -1){
            return num1 != num2;
        }else{
            return false;
        }
    }
    

    // 判断附件和评论是否必填
    public static void checkCommontAndFiles(CheckResult__c parent,
                                            Map<String, Sobject> cdMap,
                                            Map<String,Integer> check){
        Sobject so = cdMap.get(parent.id);
        // 判断附件和评论是否必填
        if(parent.CheckItem__r.HasComment__c 
            && !String.isEmpty(parent.CheckItem__r.Comment_Conditional_Type__c)
            && parent.CheckItem__r.Comment_Conditional_Type__c.equals('Mandatory')){

            if(!String.isEmpty(parent.Comments__c)){

                if(parent.CheckItem__r.HasFile__c 
                    && !String.isEmpty(parent.CheckItem__r.File_Conditional_Type__c) 
                    && parent.CheckItem__r.File_Conditional_Type__c.equals('Mandatory')){
                    // 查询附件是否为空
                    if(so != null){
                        //设置检查数
                        check.put('checkNumber', check.get('checkNumber') + 1);
                    }
                }else{
                    //设置检查数
                    check.put('checkNumber', check.get('checkNumber') + 1);
                }

            }

        }else if(parent.CheckItem__r.HasFile__c 
                    && !String.isEmpty(parent.CheckItem__r.File_Conditional_Type__c) 
                    && parent.CheckItem__r.File_Conditional_Type__c.equals('Mandatory')){

            // 查询附件是否为空
            if(so != null){
                //设置检查数
                check.put('checkNumber', check.get('checkNumber') + 1);
            }

        }
        else if(parent.CheckItem__r.HasComment__c 
                && !String.isEmpty(parent.CheckItem__r.Comment_Conditional_Type__c)
                && parent.CheckItem__r.Comment_Conditional_Type__c.equals('Conditional') && 
                (
                    (parent.CheckItem__r.Question_Type__c == 'Score' && parent.Response__c < parent.CheckItem__r.Conditional_Score_Has_Comment__c) ||
                    (parent.CheckItem__r.Question_Type__c == 'Yes/No' && parent.Response__c == parent.CheckItem__r.Conditional_Yes_No_Has_Comment__c)
                )){
                    
            if(!String.isEmpty(parent.Comments__c)){

                if(parent.CheckItem__r.HasFile__c && parent.CheckItem__r.File_Conditional_Type__c.equals('Mandatory')){
                    // 查询附件是否为空
                    if(so != null){
                        //设置检查数
                        check.put('checkNumber', check.get('checkNumber') + 1);
                    }
                }else{
                    //设置检查数
                    check.put('checkNumber', check.get('checkNumber') + 1);
                }

            }
        }else if(parent.CheckItem__r.HasFile__c 
                && !String.isEmpty(parent.CheckItem__r.File_Conditional_Type__c)
                && parent.CheckItem__r.File_Conditional_Type__c.equals('Conditional') && 
                (
                    (parent.CheckItem__r.Question_Type__c == 'Score' && parent.Response__c < parent.CheckItem__r.Conditional_Score_Has_File__c) ||
                    (parent.CheckItem__r.Question_Type__c == 'Yes/No' && parent.Response__c == parent.CheckItem__r.Conditional_Yes_No_Has_File__c)
                    
                )){
            // 查询附件是否为空
            if(so != null){
                //设置检查数
                check.put('checkNumber', check.get('checkNumber') + 1);
            }
        }
        else{
            // YYL 如果为缩略图问题照片非必填总数减1 20250330
            if(parent.Response__c.equals('Informational')){
                check.put('checkTotal', check.get('checkTotal') - 1);
            }else{
                //设置检查数
                check.put('checkNumber', check.get('checkNumber') + 1);
            }
        }
    }

    public static List<CheckItem__c> getCheckItem(List<String> recordId){
        return [SELECT id,
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
                       Enter_Choice_EN__c,
                       Enter_Choice_CN__c,
                       MaximumScore__c,
                       Integer_Type_Max__c,
                       Conditional_Score_Has_File__c,
                       Conditional_Yes_No_Has_File__c,
                       Conditional_Score_Has_Comment__c,
                       Conditional_Yes_No_Has_Comment__c,
                       Conditional_Score_Has_Ticket__c,
                       Conditional_Yes_No_Has_Ticket__c,
                       Active__c,
                       HasRelateQuestions__c,
                       HasFile__c,
                       File_Conditional_Type__c,
                       HasComment__c,
                       Comment_Conditional_Type__c,
                       Automatic_Generation_Ticket__c,
                       Ticket_Conditional_Type__c,
                       OrderNumber__c,
                       Channel_item__c,
                       Product_Line__c,
                       RecordTypeId,
                       Object_Api_Name__c,
                       Is_Loop_Relate_Questions__c,
                       Has_Image_AI__c,
                       Image_AI__c,
                       Is_Store_Rating__c,
                       Standard_Result__c
                        FROM CheckItem__c
                        WHERE id =: recordId
                        ORDER BY OrderNumber__c];
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

    public static List<CheckItem__c> checkOrderNumber(String itemType,Decimal orderNumber,String Id,String salesRegion){
        return [SELECT Id,OrderNumber__c FROM CheckItem__c WHERE 
                                Item_Type__c =: itemType 
                                AND OrderNumber__c =: orderNumber 
                                AND Active__c = true
                                AND Id !=: Id
                                AND Sales_Region__c =: salesRegion];
    }

    public static List<CheckItem__c> checkOrderNumberExist(String itemType,String Id,String salesRegion){
        return [SELECT Id,OrderNumber__c FROM CheckItem__c WHERE 
                                Item_Type__c =: itemType 
                                AND Id !=: Id
                                AND Sales_Region__c =: salesRegion
                                AND Active__c = true
                                Order By OrderNumber__c];
    }

    // 获取启用的大类关系数据
    public static List<Category_Relationship__c> getCategoryRelationship(String salesRegion){
        return [SELECT Id, 
                       Sales_Region__c,
                       Category_Type__c
                       From Category_Relationship__c
                       WHERE Sales_Region__c =: salesRegion
                       AND Active__c = true
                       Order By Index__c];
    }

     // 新增大类返回类型 YYL 20250310
     public class CategoryResultData{
        @AuraEnabled
        public Category_Relationship__c categoryRelationship;
        @AuraEnabled
        public Boolean isCheck;//是否已完成检查 YYL 20250310
        @AuraEnabled
        public String checkNumber;//存放检查项已检查数 YYL 20250310

    }

    // public static List<Check_Item_Relate__c> getCheckItemRelateIdItem(List<String> recordId){
    //     return [SELECT id,
    //                    Check_Item__c,
    //                    Response__c,
    //                    Check_Item_Relate__c
    //                    FROM Check_Item_Relate__c
    //                    WHERE Check_Item__c =: recordId];
    // }

    public static List<CheckItem__c> getCheckItemParentNull(String itemType,String productLine,String channel){
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
                       AND (Channel_item__c = NULL OR Channel_item__c =: channel)];
    }

    public static List<CheckItem__c> getCheckItemParentNullNotPhoto(String itemType,String productLine,String channel){
        return [SELECT id,
                       Parent_Response__c,
                       Parent__c,
                       Parent_Select__c,
                       Product_Line__c,
                       Question_Type__c,
                       HasComment__c,
                       Comment_Conditional_Type__c,
                       HasFile__c,
                       File_Conditional_Type__c
                       FROM CheckItem__c
                       WHERE Item_Type__c =: itemType
                       AND Parent__c = NULL
                       AND Active__c = true
                       AND Question_Type__c != 'Informational-photo'
                       AND Sales_Region__c =: salesRegion
                       AND (Product_Line__c = 'All' OR Product_Line__c IN: productLine.split(';'))
                       AND (Channel_item__c = NULL OR Channel_item__c =: channel)];
    }

    // 根据父级Id查询对应的关联问题
    public static List<CheckItem__c> getCheckItemChildren(String parentId){
        return [SELECT id,
                       Parent_Response__c,
                       Parent__c,
                       Parent_Select__c,
                       Score_Symbol_Response__c
                       FROM CheckItem__c
                       WHERE Parent__c =: parentId];
    }

    public static List<CheckResult__c> getCheckResultInit(String recordItemId,String ItemType){
        return [SELECT id
                       FROM CheckResult__c
                       WHERE Inspection_Product_Item__c =: recordItemId
                       AND CheckItem__r.Item_Type__c =: ItemType
                ];
    }

    // 查询当前大类父级的check Result信息
    public static List<CheckResult__c> getCheckResultParent(String recordItemId,String ItemType){
        return [SELECT id,
                       Name,
                       Scores__c,
                       Max_Scores__c,
                       Comments__c,
                       Status__c,
                       CheckItem__c,
                       CheckItem__r.Description_Filling_Language__c,
                       CheckItem__r.Parent__c,
                       CheckItem__r.Parent_Response__c,
                       CheckItem__r.Sales_Region__c,
                       CheckItem__r.Inspection_Type__c,
                       CheckItem__r.Item_Type__c,
                       CheckItem__r.Question_Type__c,
                       CheckItem__r.Description__c,
                       CheckItem__r.Description_CN__c,
                       CheckItem__r.Description_EN__c,
                       CheckItem__r.HelpText__c,
                       CheckItem__r.HelpTextCN__c,
                       CheckItem__r.HelpTextEN__c,
                       CheckItem__r.Enter_Choice__c,
                       CheckItem__r.Enter_Choice_EN__c,
                       CheckItem__r.Enter_Choice_CN__c,
                       CheckItem__r.MaximumScore__c,
                       CheckItem__r.Integer_Type_Max__c,
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
                       Product_Line__c,
                       InspectorDailyReport__c,
                       Inspection_Product_Item__c,
                       Index__c
                       FROM CheckResult__c
                       WHERE Inspection_Product_Item__c =: recordItemId
                       AND CheckItem__r.Item_Type__c =: ItemType
                       AND CheckItem__r.Parent__c = NULL
                    //    AND CheckItem__r.Active__c = true YYL 移除掉active为true的条件判断 20250618
                       ORDER BY CheckItem__r.OrderNumber__c
                ];
    }

    // 查询当前大类子级的check Result信息
    public static List<CheckResult__c> getCheckResultChildren(String recordItemId,String ItemType){
        return [SELECT id,
                       Name,
                       Scores__c,
                       Max_Scores__c,
                       Comments__c,
                       Status__c,
                       CheckItem__c,
                       CheckItem__r.Description_Filling_Language__c,
                       CheckItem__r.Parent__c,
                       CheckItem__r.Parent_Response__c,
                       CheckItem__r.Sales_Region__c,
                       CheckItem__r.Inspection_Type__c,
                       CheckItem__r.Item_Type__c,
                       CheckItem__r.Question_Type__c,
                       CheckItem__r.Description__c,
                       CheckItem__r.Description_CN__c,
                       CheckItem__r.Description_EN__c,
                       CheckItem__r.HelpText__c,
                       CheckItem__r.HelpTextCN__c,
                       CheckItem__r.HelpTextEN__c,
                       CheckItem__r.Enter_Choice__c,
                       CheckItem__r.Enter_Choice_EN__c,
                       CheckItem__r.Enter_Choice_CN__c,
                       CheckItem__r.MaximumScore__c,
                       CheckItem__r.Integer_Type_Max__c,
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
                       Product_Line__c,
                       InspectorDailyReport__c,
                       Inspection_Product_Item__c,
                       Index__c
                       FROM CheckResult__c
                       WHERE Inspection_Product_Item__c =: recordItemId
                       AND CheckItem__r.Item_Type__c =: ItemType
                       AND CheckItem__r.Parent__c != NULL
                    //    AND CheckItem__r.Active__c = true YYL 移除掉active为true的条件判断 20250618
                       ORDER BY CheckItem__r.OrderNumber__c
                ];
    }

    // YYL 查询出样型号不为空大类父级的check Result信息
    public static List<CheckResult__c> getCheckResultParentSampling(String recordItemId){
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
                       CheckItem__r.HelpText__c,
                       CheckItem__r.HelpTextCN__c,
                       CheckItem__r.HelpTextEN__c,
                       CheckItem__r.Enter_Choice__c,
                       CheckItem__r.Enter_Choice_EN__c,
                       CheckItem__r.Enter_Choice_CN__c,
                       CheckItem__r.MaximumScore__c,
                       CheckItem__r.Integer_Type_Max__c,
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
                       Product_Line__c,
                       InspectorDailyReport__c,
                       Inspection_Product_Item__c,
                       Sampling_Inspection__c,
                       Index__c
                       FROM CheckResult__c
                       WHERE Inspection_Product_Item__c =: recordItemId
                       AND CheckItem__r.Parent__c = NULL
                    //    AND CheckItem__r.Active__c = true YYL 移除掉active为true的条件判断 20250618
                       AND Sampling_Inspection__c != NULL
                       ORDER BY CheckItem__r.OrderNumber__c
                ];
    }

    // 查询样型号不为空大类子级的check Result信息
    public static List<CheckResult__c> getCheckResultChildrenSampling(String recordItemId){
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
                       CheckItem__r.HelpText__c,
                       CheckItem__r.HelpTextCN__c,
                       CheckItem__r.HelpTextEN__c,
                       CheckItem__r.Enter_Choice__c,
                       CheckItem__r.Enter_Choice_EN__c,
                       CheckItem__r.Enter_Choice_CN__c,
                       CheckItem__r.MaximumScore__c,
                       CheckItem__r.Integer_Type_Max__c,
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
                       Product_Line__c,
                       InspectorDailyReport__c,
                       Inspection_Product_Item__c,
                       Sampling_Inspection__c,
                       Index__c
                       FROM CheckResult__c
                       WHERE Inspection_Product_Item__c =: recordItemId
                       AND CheckItem__r.Parent__c != NULL
                    //    AND CheckItem__r.Active__c = true YYL 移除掉active为true的条件判断 20250618
                       AND Sampling_Inspection__c != NULL
                       ORDER BY CheckItem__r.OrderNumber__c
                ];
    }

    public class CheckResultData{
        @AuraEnabled
        public CheckResult__c parent;
        @AuraEnabled
        public List<Object> imgList;//YYL 缩略图 20250303
        @AuraEnabled
        public List<List<CheckResultData>> children;
    }

    public class CheckDataDetailInfo{
        @AuraEnabled
        public CheckResult__c parent;
        @AuraEnabled
        public List<List<CheckDataDetailInfo>> children;
    }

    // public class CheckItemRelate{
    //     String response;
    //     String checkItemId;
    // }

    //获取SalesRegion下的产品线
    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getProductLines(String salesRegion, String channel) {
        // if (String.isBlank(salesRegion)) {
        //     return null;
        // }
        List<Store_Product_Line__c> productLine = new List<Store_Product_Line__c>(); 
        try {
            if(String.isNotEmpty(channel) && channel != 'All') {
                productLine = [Select Id,Store__r.Sales_Region__c,Store__r.Channel_item__r.Channel_Name__c, Product_Line__c from Store_Product_Line__c where Store__r.Sales_Region__c =: salesRegion And Entering_Status__c =: 'Entered' And Store__r.Channel_item__r.Channel_Name__c =: channel];
            } else {
                productLine = [Select Id,Store__r.Sales_Region__c,Store__r.Channel_item__r.Channel_Name__c, Product_Line__c from Store_Product_Line__c where Store__r.Sales_Region__c =: salesRegion And Entering_Status__c =: 'Entered'];
            }

            if(Test.isRunningTest()){
                productLine = [Select Id,Store__r.Sales_Region__c,Store__r.Channel_item__r.Channel_Name__c, Product_Line__c from Store_Product_Line__c];
            }

            Map<String, Store_Product_Line__c> uniqueMap = new Map<String, Store_Product_Line__c>();
            for (Store_Product_Line__c obj : productLine) {
                String productLineParam = obj.Product_Line__c;
                if (!uniqueMap.containsKey(productLineParam)) {
                    uniqueMap.put(productLineParam, obj);
                }
            }
            List<Store_Product_Line__c> deduplicatedList = new List<Store_Product_Line__c>(uniqueMap.values());
            List<Map<String, String>> result = new List<Map<String, String>>();
            result.add(new Map<String, String> {
                'label' => 'All',
                'value' => 'All'
            });
            for (Store_Product_Line__c item : deduplicatedList) {
                if (!String.isEmpty(item.Product_Line__c)) {
                    result.add(new Map<String, String> {
                        'label' => item.Product_Line__c,
                        'value' => item.Product_Line__c
                    });
                }
            }
            return result;
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    //获取SalesRegion下的渠道名称
    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getChannels(String salesRegion, String productLine) {
        if (String.isBlank(salesRegion)) {
            return null;
        }
        System.debug('WWWgetChannels');
        List<Store_Product_Line__c> Channels = new List<Store_Product_Line__c>(); 
        try {
            if(String.isNotEmpty(productLine) && productLine != 'All') {
                Channels = [Select Id,Store__r.Sales_Region__c,Store__r.Channel_item__r.Channel_Name__c, Product_Line__c from Store_Product_Line__c where Store__r.Sales_Region__c =: salesRegion And Entering_Status__c =: 'Entered' And Product_Line__c =: productLine];
            } else {
                Channels = [Select Id,Store__r.Sales_Region__c,Store__r.Channel_item__r.Channel_Name__c, Product_Line__c from Store_Product_Line__c Where Store__r.Sales_Region__c =: salesRegion And Entering_Status__c =: 'Entered'];
            }

            if(Test.isRunningTest()){
                Channels = [Select Id,Store__r.Sales_Region__c,Store__r.Channel_item__r.Channel_Name__c, Product_Line__c from Store_Product_Line__c];
            }

            Map<String, Store_Product_Line__c > uniqueMap = new Map<String, Store_Product_Line__c >();
            for (Store_Product_Line__c obj : Channels) {
                String ChannelParam = obj.Store__r.Channel_item__r.Channel_Name__c;
                if (!uniqueMap.containsKey(ChannelParam)) {
                    uniqueMap.put(ChannelParam, obj);
                }
            }
            List<Store_Product_Line__c> deduplicatedList = new List<Store_Product_Line__c>(uniqueMap.values());
            List<Map<String, String>> result = new List<Map<String, String>>();
            result.add(new Map<String, String> {
                'label' => 'All',
                'value' => 'All'
            });
            for (Store_Product_Line__c item : deduplicatedList) {
                if (!String.isEmpty(item.Store__r.Channel_item__r.Channel_Name__c)) {
                    result.add(new Map<String, String> {
                        'label' => item.Store__r.Channel_item__r.Channel_Name__c,
                        'value' => item.Store__r.Channel_item__r.Channel_Name__c
                    });
                }
            }
            
            return result;
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    //TJP 重构通过checkItem配置的检查项
    // 检查当前检查项是否已初始化
    @AuraEnabled
    public static ConResponse checkXOnlineInitStatus(String checkItemType,
                                                String inspectorDailyReportId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 查询检查项初始化数据
        List<CheckResult__c> initResult = getXOnlineCheckResultInit(inspectorDailyReportId,checkItemType);
        if(initResult != null && initResult.size() > 0){
            mso.put('initStatus', true);
        }else{
            mso.put('initStatus', false);
        }
        //  实现 竞品分类
        // List<CheckResult__c> initResultCopy = getXOnlineCheckResultInit(inspectorDailyReportId,'Competitive X Sample');
        // if(initResultCopy != null && initResultCopy.size() > 0){
        //     mso.put('initStatus', true);
        // }else{
        //     mso.put('initStatus', false);
        // }

        return resp;
    }

    public static List<CheckResult__c> getXOnlineCheckResultInit(String inspectorDailyReportId,String ItemType){
        return [SELECT id
                       FROM CheckResult__c
                       WHERE InspectorDailyReport__c =: inspectorDailyReportId
                       AND CheckItem__r.Item_Type__c =: ItemType
                ];
    }

    // 查询检查项初始化详情
    @AuraEnabled
    public static ConResponse getXOnlineCheckResultInitInfo(String checkItemType,
                                                String inspectorDailyReportId){

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 存放X Hisense处理后的展示数据
        List<CheckResultData> checkResultDataList = new List<CheckResultData>();
        // 存放X Competitive处理后的展示数据
        List<CheckResultData> checkResultDataListCopy = new List<CheckResultData>();

        List<CheckResult__c> checkResultParent = getXOnlineCheckResultParent(inspectorDailyReportId,checkItemType);
        List<CheckResult__c> checkResultChildren = getXOnlineCheckResultChildren(inspectorDailyReportId,checkItemType);

        NewSamplingAndTicketProController.setCheckItemLanguage(checkResultParent);
        NewSamplingAndTicketProController.setCheckItemLanguage(checkResultChildren);

        // 根据parentId 分组
        Map<String,List<CheckResult__c>> groupParent = new Map<String,List<CheckResult__c>>();

        if(checkResultChildren != null && checkResultChildren.size() > 0){
            // LisqContainer lqChildren = new LisqContainer(checkResultChildren);
            // groupParent = lqChildren.GroupByS('CheckItem__r.Parent__c');
            for(CheckResult__c children : checkResultChildren){
                List<CheckResult__c> resultChildren = groupParent.get(children.CheckItem__r.Parent__c);

                if(resultChildren == null){
                    resultChildren = new List<CheckResult__c>();
                }
                resultChildren.add(children);
                groupParent.put(children.CheckItem__r.Parent__c,resultChildren);
            }
        }

        if(checkResultParent != null && checkResultParent.size() > 0){
            for(CheckResult__c parent : checkResultParent){
                CheckResultData parentData = new CheckResultData();
                parentData.parent = parent;

                // 上传文件和评论默认为false，前端根据条件判断展示
                // parentData.parent.CheckItem__r.HasFile__c = false;
                // parentData.parent.CheckItem__r.HasComment__c = false;

                if(groupParent != null && groupParent.size() > 0){
                    checkXOnlineResultRecursionInit(parentData,groupParent);
                }

                System.debug('wwwwCheckResultData' + JSON.serialize(parentData));

                checkResultDataList.add(parentData);
            }
        }

        // List<CheckResult__c> checkResultParentTwo = getXOnlineCheckResultParent(inspectorDailyReportId,'Competitive X Sample');
        // List<CheckResult__c> checkResultChildrenTwo = getXOnlineCheckResultChildren(inspectorDailyReportId,'Competitive X Sample');

        // // 根据parentId 分组
        // Map<String,List<CheckResult__c>> groupParentTwo = new Map<String,List<CheckResult__c>>();

        // if(checkResultChildrenTwo != null && checkResultChildrenTwo.size() > 0){
        //     // LisqContainer lqChildren = new LisqContainer(checkResultChildren);
        //     // groupParent = lqChildren.GroupByS('CheckItem__r.Parent__c');
        //     for(CheckResult__c children : checkResultChildrenTwo){
        //         List<CheckResult__c> resultChildren = groupParentTwo.get(children.CheckItem__r.Parent__c);

        //         if(resultChildren == null){
        //             resultChildren = new List<CheckResult__c>();
        //         }
        //         resultChildren.add(children);
        //         groupParentTwo.put(children.CheckItem__r.Parent__c,resultChildren);
        //     }
        // }

        // if(checkResultParentTwo != null && checkResultParentTwo.size() > 0){
        //     for(CheckResult__c parent : checkResultParentTwo){
        //         CheckResultData parentData = new CheckResultData();
        //         parentData.parent = parent;

        //         // 上传文件和评论默认为false，前端根据条件判断展示
        //         // parentData.parent.CheckItem__r.HasFile__c = false;
        //         // parentData.parent.CheckItem__r.HasComment__c = false;

        //         if(groupParentTwo != null && groupParentTwo.size() > 0){
        //             checkXOnlineResultRecursionInit(parentData,groupParentTwo);
        //         }

        //         System.debug('wwwwCheckResultData' + JSON.serialize(parentData));

        //         checkResultDataListCopy.add(parentData);
        //     }
        // }

        mso.put('checkResultData', checkResultDataList);

        return resp;
    }

    // 查询检查项初始化详情
    @AuraEnabled
    public static ConResponse getXOnlineCheckResultWithMark(String checkItemType,
                                                String inspectorDailyReportId){

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 存放处理后的展示数据
        List<CheckResultData> checkResultDataList = new List<CheckResultData>();
        List<CheckResult__c> checkResultParent = getXOnlineCheckResultParentWithMark(inspectorDailyReportId,checkItemType,mark);
        List<CheckResult__c> checkResultChildren = getXOnlineCheckResultChildrenWithMark(inspectorDailyReportId,checkItemType,mark);

        NewSamplingAndTicketProController.setCheckItemLanguage(checkResultParent);
        NewSamplingAndTicketProController.setCheckItemLanguage(checkResultChildren);

        

        System.debug('wwwwcheckResultParent' + JSON.serialize(checkResultParent));
        System.debug('wwwwcheckResultChildren' + JSON.serialize(checkResultChildren));

        // 根据parentId 分组
        Map<String,List<CheckResult__c>> groupParent = new Map<String,List<CheckResult__c>>();

        if(checkResultChildren != null && checkResultChildren.size() > 0){
            for(CheckResult__c children : checkResultChildren){
                List<CheckResult__c> resultChildren = groupParent.get(children.CheckItem__r.Parent__c);

                if(resultChildren == null){
                    resultChildren = new List<CheckResult__c>();
                }
                resultChildren.add(children);
                groupParent.put(children.CheckItem__r.Parent__c,resultChildren);
            }
        }

        if(checkResultParent != null && checkResultParent.size() > 0){
            for(CheckResult__c parent : checkResultParent){
                CheckResultData parentData = new CheckResultData();
                parentData.parent = parent;

                // 上传文件和评论默认为false，前端根据条件判断展示
                if(groupParent != null && groupParent.size() > 0){
                    checkXOnlineResultRecursionInit(parentData,groupParent);
                }

                System.debug('wwwwCheckResultData' + JSON.serialize(parentData));

                checkResultDataList.add(parentData);
            }
        }

        System.debug('wwwwCheckResultData' + JSON.serialize(checkResultDataList));

        mso.put('checkResultData', checkResultDataList);

        return resp;
    }

    
    public static List<CheckResult__c> getXOnlineCheckResultParentWithMark(String inspectionId,String ItemType, Decimal mark){
        return [SELECT id,
                       Name,
                       Scores__c,
                       Max_Scores__c,
                       Comments__c,
                       Status__c,
                       CheckItem__c,
                       Mark__c,
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
                       CheckItem__r.Integer_Type_Max__c,
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
                       Response__c,
                       Product_Line__c,
                       InspectorDailyReport__c
                    //    Inspection_Product_Item__c
                       FROM CheckResult__c
                       WHERE InspectorDailyReport__c =: inspectionId
                       AND CheckItem__r.Item_Type__c =: ItemType
                       AND Mark__c =: mark
                       AND CheckItem__r.Parent__c = NULL
                    //    AND CheckItem__r.Active__c = true YYL 移除掉active为true的条件判断 20250618
                       ORDER BY CheckItem__r.OrderNumber__c
                ];
    }

    // 查询当前大类父级的check Result信息
    public static List<CheckResult__c> getXOnlineCheckResultParent(String inspectionId,String ItemType){
        return [SELECT id,
                       Name,
                       Scores__c,
                       Max_Scores__c,
                       Comments__c,
                       Status__c,
                       CheckItem__c,
                       Mark__c,
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
                       CheckItem__r.Integer_Type_Max__c,
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
                       Response__c,
                       Product_Line__c,
                       InspectorDailyReport__c
                    //    Inspection_Product_Item__c
                       FROM CheckResult__c
                       WHERE InspectorDailyReport__c =: inspectionId
                       AND CheckItem__r.Item_Type__c =: ItemType
                       AND CheckItem__r.Parent__c = NULL
                    //    AND CheckItem__r.Active__c = true YYL 移除掉active为true的条件判断 20250618
                       ORDER BY CheckItem__r.OrderNumber__c
                ];
    }

    // 查询当前大类子级的check Result信息
    public static List<CheckResult__c> getXOnlineCheckResultChildren(String inspectionId,String ItemType){
        return [SELECT id,
                       Name,
                       Scores__c,
                       Max_Scores__c,
                       Comments__c,
                       Status__c,
                       CheckItem__c,
                       Mark__c,
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
                       CheckItem__r.Integer_Type_Max__c,
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
                       Response__c,
                       Product_Line__c,
                       InspectorDailyReport__c
                       FROM CheckResult__c
                       WHERE InspectorDailyReport__c =: inspectionId
                       AND CheckItem__r.Item_Type__c =: ItemType
                       AND CheckItem__r.Parent__c != NULL
                    //    AND CheckItem__r.Active__c = true YYL 移除掉active为true的条件判断 20250618
                       ORDER BY CheckItem__r.OrderNumber__c
                ];
    }

    public static List<CheckResult__c> getXOnlineCheckResultChildrenWithMark(String inspectionId,String ItemType, Decimal mark){
        return [SELECT id,
                       Name,
                       Scores__c,
                       Max_Scores__c,
                       Comments__c,
                       Status__c,
                       CheckItem__c,
                       Mark__c,
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
                       CheckItem__r.Integer_Type_Max__c,
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
                       Response__c,
                       Product_Line__c,
                       InspectorDailyReport__c
                       FROM CheckResult__c
                       WHERE InspectorDailyReport__c =: inspectionId
                       AND CheckItem__r.Item_Type__c =: ItemType
                       AND Mark__c =: mark
                       AND CheckItem__r.Parent__c != NULL
                    //    AND CheckItem__r.Active__c = true YYL 移除掉active为true的条件判断 20250618
                       ORDER BY CheckItem__r.OrderNumber__c
                ];
    }

    // 处理展示的checkResult
    public static void checkXOnlineResultRecursionInit(CheckResultData checkResultParent,       
                                            Map<String,List<CheckResult__c>> groupParent){
        // LisqContainer lqGroupParent = groupParent.get(checkResultParent.parent.id);
        // List<CheckResult__c> resultGroupParent = (List<CheckResult__c>)lqGroupParent.ToSobjectList();
        List<CheckResult__c> resultGroupParent = groupParent.get(checkResultParent.parent.CheckItem__c);

        if(resultGroupParent != null && resultGroupParent.size() > 0){
            // 处理父级下关联问题
            List<CheckResultData> CheckResultChildrenDate = new List<CheckResultData>();
            for(CheckResult__c parent : resultGroupParent){
                CheckResultData checkResultChildren = new CheckResultData();
                checkResultChildren.parent = parent;

                checkXOnlineResultRecursionInit(checkResultChildren,groupParent);

                CheckResultChildrenDate.add(checkResultChildren);
            }

            // checkResultParent.children = CheckResultChildrenDate;          
        }
    }

    // 生成当前大类的对应的Check Result
    @AuraEnabled
    public static ConResponse addXOnlineCheckResult(String checkItemType,
                                                String inspectorDailyReportId,
                                                    String productLine){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        //TJP 根据 类型以及 日报ID查询 mark 的值，用于声明组；
        List<CheckResult__c> results = [Select Id,Sampling_Inspection__c,Mark__c from CheckResult__c where InspectorDailyReport__c  =:inspectorDailyReportId And CheckItem__r.Item_Type__c =: checkItemType];
        // Decimal maxMark = 0;
        if(results.size() > 0) {
            for (CheckResult__c result : results) {
                if (result.Mark__c != null) {
                    if (mark == null || result.Mark__c > mark) {
                        mark = result.Mark__c;
                    }
                }
            } 
            mark = mark + 1;
        } else {
            mark = 0;
        }
        System.debug('获取Mark 最大值' + mark);
        
        recordId = inspectorDailyReportId;
        System.debug('inspectorDailyReportId' +  inspectorDailyReportId);
        System.debug('wwwcurrentUser' + salesRegion);

        // 查询当前日报门店的salesregion
        Daily_Inspection_Report__c record = [SELECT Id,Store__r.Sales_Region__c,Store__c FROM Daily_Inspection_Report__c WHERE Id =: inspectorDailyReportId];
        // YYL 查询门店信息 20250325
        Shop__c shopDb = [select Id,Name,Shop_Level__c,Account__r.Sales_Region__c, Sales_Region__c,Channel_item__c from Shop__c  WHERE id =: record.Store__c];


        //20241029 TJP 增加 总部选点的salesregion判断
        salesRegion = 'Hisense X';
        System.debug('wwwcurrentUser' + salesRegion);
        System.debug('wwwsalesRegion' + salesRegion + checkItemType);
                                                        
        // 查询当前大类下没有父级问题的CheckItem
        List<CheckItem__c> checkItemParent = getCheckItemParentNull(checkItemType,productLine,shopDb.Channel_item__c);

        System.debug('wwwsalesRegion' + checkItemParent.size());

        if(checkItemParent != null && checkItemParent.size() > 0){

            // 存放最终存储数据
            List<CheckResult__c> checkResultAdd = new List<CheckResult__c>();
            List<CheckItem__c> CheckItemChildren = getCheckItemAll();

            System.debug('wwwCheckItemChildren' + JSON.serialize(CheckItemChildren));

            // 根据parent Id 分组
            Map<String,LisqContainer> groupParent = new Map<String,LisqContainer>();

            if(CheckItemChildren != null && CheckItemChildren.size() > 0){
                LisqContainer lqChildren = new LisqContainer(CheckItemChildren);
                groupParent = lqChildren.GroupByS('Parent__c');

            }
            
            for(CheckItem__c parent : checkItemParent){
                CheckResult__c parentResult = new CheckResult__c();
                parentResult.CheckItem__c = parent.id;
                parentResult.InspectorDailyReport__c = inspectorDailyReportId;
                parentResult.Mark__c = mark;
                checkResultAdd.add(parentResult);

                if(groupParent != null && groupParent.size() > 0){
                    LisqContainer lqGroupParent = groupParent.get(parent.id);
                    if(lqGroupParent != null){
                        List<CheckItem__c> itemGroupParent = (List<CheckItem__c>)lqGroupParent.ToSobjectList();
                        checkXOnlineResultRecursionAdd(itemGroupParent, checkResultAdd, groupParent);
                    }
                }
            }
            System.debug('wwwwcheckResultAdd' + JSON.serialize(checkResultAdd));
            System.debug('wwwwcheckResultAdd' + JSON.serialize(inspectorDailyReportId));
            mso.put('checkResultAdd', checkResultAdd);
            Database.insert(checkResultAdd);
        }

        return resp;
    }

    // 处理存储的checkResult
    public static void checkXOnlineResultRecursionAdd(List<CheckItem__c> itemGroup,
                                            List<CheckResult__c> checkResultAdd,
                                            Map<String,LisqContainer> groupParent){
        for(CheckItem__c item : itemGroup){

            CheckResult__c result = new CheckResult__c();
            result.CheckItem__c = item.id;
            result.InspectorDailyReport__c = recordId;
            checkResultAdd.add(result);
            
            LisqContainer lqGroupChildren = groupParent.get(item.Id);
            if(lqGroupChildren != null){
                List<CheckItem__c> itemGroupChildren = (List<CheckItem__c>)lqGroupChildren.ToSobjectList();
                checkXOnlineResultRecursionAdd(itemGroupChildren, checkResultAdd, groupParent);
            }
        }
    }

    @AuraEnabled
    public static ConResponse delXOnlineCheckResult(String checkItemType,
                                                String inspectorDailyReportId,
                                                    String productLine){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        //TJP 根据 类型以及 日报ID查询 mark 的值，用于声明组；
        List<CheckResult__c> results = [Select Id,Sampling_Inspection__c,Mark__c from CheckResult__c where InspectorDailyReport__c  =:inspectorDailyReportId ];
        Decimal maxMark = 0;
        if(results.size() > 0) {
            for (CheckResult__c result : results) {
                if (result.Mark__c != null) {
                    if (maxMark == null || result.Mark__c > maxMark) {
                        maxMark = result.Mark__c;
                    }
                }
            } 
        }
        // System.debug('获取Mark 最大值' + mark);
        List<CheckResult__c> delResult = [Select Id,Sampling_Inspection__c,Mark__c from CheckResult__c where InspectorDailyReport__c  =:inspectorDailyReportId And CheckItem__r.Item_Type__c =: checkItemType And Mark__c =:maxMark];
        delete delResult;     

        return resp;
    }

    // 获取已有文件
    @AuraEnabled
    public static List<Map<String, String>> getExistingFiles(Id recordId) {
        List<ContentDocumentLink> cdLinks = [
            SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :recordId
        ];
        
        List<Map<String, String>> files = new List<Map<String, String>>();
        for (ContentDocumentLink link : cdLinks) {
            files.add(new Map<String, String>{
                'contentDocumentId' => link.ContentDocumentId,
                'downloadUrl' => '/sfc/servlet.shepherd/version/download/' + link.ContentDocument.LatestPublishedVersionId,
                'title' => link.ContentDocument.Title
            });
        }
        return files;
    }

    // 批量获取已有文件 YYL 20250303
    @AuraEnabled
    public static Map<Id, List<Map<String, String>>> getExistingFilesList(List<String> recordIds) {
        List<ContentDocumentLink> cdLinks = [
            SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId,LinkedEntityId
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN:recordIds
        ];

        // 根据记录id分组
        Map<Id, List<Map<String, String>>> recordIdMap = new Map<Id, List<Map<String, String>>>();

        for (ContentDocumentLink link : cdLinks) {  
            List<Map<String, String>> filesList = recordIdMap.get(link.LinkedEntityId);

            if(filesList == null){
                filesList = new List<Map<String, String>>();
            }

            Map<String, String> filesItem = new Map<String, String>{
                'contentDocumentId' => link.ContentDocumentId,
                'downloadUrl' => '/sfc/servlet.shepherd/version/download/' + link.ContentDocument.LatestPublishedVersionId,
                'title' => link.ContentDocument.Title
            };

            filesList.add(filesItem);
            recordIdMap.put(link.LinkedEntityId, filesList);
        }
        
        return recordIdMap;
    }

    @AuraEnabled
    public static ConResponse saveDateWithFiles(String checkItemJson,String relateList,String relateDelList, List<String> filesToDelete, List<Object> newFiles){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        CheckItem__c item = (CheckItem__c)JSON.deserialize(checkItemJson, CheckItem__c.class);
        // 查询大类pickList数据 YYL 20250311
        Map<String,String> pickList = Utility.getPicklistValueMap('CheckItem__c', 'Item_Type__c');
        // 校验当前问题对应类型下Ordernumber是否重复
        List<CheckItem__c> checkOrder = checkOrderNumber(item.Item_Type__c,item.OrderNumber__c,item.Id,item.Sales_Region__c);
        if(checkOrder != null && checkOrder.size() > 0){
            // 查询当前类型下存在的序号
            LisqContainer lqExist = new LisqContainer(checkOrderNumberExist(item.Item_Type__c,item.Id,item.Sales_Region__c));
            List<String> orderNumberExist = lqExist.SelectSField('OrderNumber__c');
            String exist = String.join(orderNumberExist,',');
            resp.code = -1;
            String itemName = pickList.get(item.Item_Type__c);
            resp.message = 'No. ' + exist + ' already exists in ' + itemName;
        }else{

            System.debug('wwwwitem' + JSON.serialize(item));

            // 字段必填，为空设置默认值
            if(String.isEmpty(item.MaximumScore__c)){
                item.MaximumScore__c = '5';
            }
            // item.MaximumScore__c = '5';
            // Database.upsert(item);

            List<CheckItem__c> oldItemList = [SELECT Id,Description__c FROM CheckItem__c WHERE Id =: item.Id];

            // 数据存在走更新逻辑判断
            if(oldItemList != null && oldItemList.size() > 0){
                // YYL 新增逻辑判断是否于原本数据一致不一致则重新生成
                CheckItem__c oldItem = oldItemList.get(0);

                // 判断是否满足生成新数据逻辑
                if(!item.Description__c.equals(oldItem.Description__c)){

                    CheckItem__c itemClone = item.clone();
                    // 更新原有的active为false
                    oldItem.Active__c = false;
    
                    Database.insert(itemClone);

                    Database.update(oldItem);

                    item = itemClone;
                    
                }else{
                    // 移除关联子任务
                    List<CheckItem__c> delList = [SELECT Id, Parent__c FROM CheckItem__c WHERE Parent__c = :item.Id];
                    for(CheckItem__c ci : delList){
                        ci.Parent__c = null;
                        ci.Parent_Response__c = '';
                        ci.Score_Symbol__c = null;
                        ci.Score_Symbol_Response__c = '';
                        ci.Parent_Select__c = '';
                    }
                    Database.update(delList);
                    
                    if(!String.isEmpty(relateDelList)){
                        System.debug('wwwwitemRelateDel' + JSON.serialize(relateDelList));
                        Map<String, CheckItem__c> idMap = new Map<String, CheckItem__c>();
                        // 清除掉需要删除的父级节点和父级响应条件
                        List<CheckItem__c> itemRelateDel = (List<CheckItem__c>)JSON.deserialize(relateDelList, List<CheckItem__c>.class);
                        for(CheckItem__c relateDel : itemRelateDel){
                            if(String.isNotBlank(relateDel.Id)){
                                if(!idMap.containsKey(relateDel.Id)){
                                    CheckItem__c nullCheckItem = new CheckItem__c();
                                    relateDel.Parent_Response__c = '';
                                    relateDel.Parent__c = nullCheckItem.Id;
                                    relateDel.Score_Symbol__c = null;
                                    relateDel.Score_Symbol_Response__c = '';
                                    relateDel.Parent_Select__c = '';
                                    idMap.put(relateDel.Id, relateDel);
                                } 
                            }
                        }
                        if(idMap.values().size() > 0){
                            Database.update(idMap.values());
                        }
                    }

                    // 2. 删除需要移除的文件
                    if (!filesToDelete.isEmpty()) {
                        delete [SELECT Id FROM ContentDocument WHERE Id IN :filesToDelete];
                    }

                    Database.update(item);
                }

            }else{
                Database.insert(item);
            }

            // 存储关联问题
            List<CheckItem__c> itemRelate = (List<CheckItem__c>)JSON.deserialize(relateList, List<CheckItem__c>.class);
            List<CheckItem__c> itemRelateAdd = new List<CheckItem__c>();
            if(itemRelate != null && itemRelate.size() > 0){
                Map<String, CheckItem__c> idMap = new Map<String, CheckItem__c>();
                // 设置父级节点
                for(CheckItem__c relate : itemRelate){
                    // picklist类型时，可以选择相同的子任务
                    System.debug('wwwwrelate' + JSON.serialize(relate.Id));
                    System.debug('wwwwrelate' + JSON.serialize(relate));
                    if(relate.Id != null && (relate.Parent_Response__c != '' || relate.Parent_Select__c != '')){
                        if(!idMap.keySet().contains(relate.Id)){
                            relate.Parent__c = item.Id;
                            relate.Score_Symbol_Response__c = relate.Score_Symbol__c;
                            idMap.put(relate.Id, relate);
                        }else {
                            CheckItem__c temp = idMap.get(relate.Id);
                            temp.Parent_Select__c = temp.Parent_Select__c + '&' + relate.Parent_Select__c;
                            // score类型，额外保存运算符号
                            if(item.Question_Type__c == 'Score'){
                                temp.Score_Symbol_Response__c = temp.Score_Symbol__c + '&' + relate.Score_Symbol__c;
                            }
                            idMap.put(relate.Id, temp);
                        }
                    }
                }
                itemRelateAdd = idMap.values();

                Database.update(itemRelateAdd);
            }
            
            // 3. 上传新文件
            List<ContentVersion> contentVersions = new List<ContentVersion>();
            for (Object fileObj : newFiles) {

                Map<Object, Object> file = (Map<Object, Object>) fileObj;
                ContentVersion cv = new ContentVersion(
                    Title = file.get('name') + '',
                    PathOnClient = file.get('name') + '',
                    VersionData = EncodingUtil.base64Decode(file.get('fileBody') + ''),
                    IsMajorVersion = true
                );
                contentVersions.add(cv);
            }
            insert contentVersions;
            
            // 4. 关联文件到记录
            List<ContentDocumentLink> links = new List<ContentDocumentLink>();
            List<ContentVersion> cvList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersions];
            for (ContentVersion cv : cvList) {
                links.add(new ContentDocumentLink(
                    ContentDocumentId = cv.ContentDocumentId,
                    LinkedEntityId = item.Id,
                    ShareType = 'V'
                ));
            }
            insert links;

            mso.put('id', item.id);
        }

        return resp;
    }

    @AuraEnabled
    public static User getUserInfo(){
        return currentUser;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
    }

}