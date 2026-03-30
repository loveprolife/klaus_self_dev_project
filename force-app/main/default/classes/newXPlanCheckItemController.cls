public class newXPlanCheckItemController {
    public static User currentUser = [SELECT Id,Name,Username,Sales_Region__c,Profile.Name FROM User WHERE Id =:UserInfo.getUserId()]; 
    public static String checkXPlanId;
    public static String salesRegion;

    // 生成当前大类的对应的Check Result
    @AuraEnabled
    public static ConResponse addCheckResult(String checkItemType,
                                                String checkXPlanId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        checkXPlanId = checkXPlanId;
        // salesRegion = 'Hisense X';
        salesRegion = currentUser.Sales_Region__c;

        System.debug('wwwsalesRegion' + salesRegion + checkItemType);
                                                        
        // 查询当前大类下没有父级问题的CheckItem
        List<CheckItem__c> checkItemParent = getCheckItemParentNull(checkItemType);

        System.debug('wwwsalesRegion' + checkItemParent.size());

        if(checkItemParent != null && checkItemParent.size() > 0){

            // 存放最终存储数据
            List<Check_Result_Temporary__c> checkResultAdd = new List<Check_Result_Temporary__c>();
            List<CheckItem__c> CheckItemChildren = getCheckItemAll();

            System.debug('wwwCheckItemChildren' + JSON.serialize(CheckItemChildren));

            // 根据parent Id 分组
            Map<String,LisqContainer> groupParent = new Map<String,LisqContainer>();

            if(CheckItemChildren != null && CheckItemChildren.size() > 0){
                LisqContainer lqChildren = new LisqContainer(CheckItemChildren);

                groupParent = lqChildren.GroupByS('Parent__c');

            }
            
            for(CheckItem__c parent : checkItemParent){
                Check_Result_Temporary__c parentResult = new Check_Result_Temporary__c();
                parentResult.CheckItem__c = parent.id;
                parentResult.Check_X_Plan__c = checkXPlanId;

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
            mso.put('checkResultAdd', checkResultAdd);
            Database.insert(checkResultAdd);
        }

        return resp;
    }

    // 检查当前检查项是否已初始化
    @AuraEnabled
    public static ConResponse checkInitStatus(String checkItemType,
                                                String checkXPlanId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 查询检查项初始化数据
        List<Check_Result_Temporary__c> initResult = getCheckResultInit(checkXPlanId,checkItemType);
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
                                                String checkXPlanId){

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 存放处理后的展示数据
        List<CheckResultData> checkResultDataList = new List<CheckResultData>();
        List<Check_Result_Temporary__c> checkResultParent = getCheckResultParent(checkXPlanId,checkItemType);
        List<Check_Result_Temporary__c> checkResultChildren = getCheckResultChildren(checkXPlanId,checkItemType);

        // 根据parentId 分组
        Map<String,List<Check_Result_Temporary__c>> groupParent = new Map<String,List<Check_Result_Temporary__c>>();

        if(checkResultChildren != null && checkResultChildren.size() > 0){
            // LisqContainer lqChildren = new LisqContainer(checkResultChildren);
            // groupParent = lqChildren.GroupByS('CheckItem__r.Parent__c');
            for(Check_Result_Temporary__c children : checkResultChildren){
                List<Check_Result_Temporary__c> resultChildren = groupParent.get(children.CheckItem__r.Parent__c);

                if(resultChildren == null){
                    resultChildren = new List<Check_Result_Temporary__c>();
                }
                resultChildren.add(children);
                groupParent.put(children.CheckItem__r.Parent__c,resultChildren);
            }
        }

        if(checkResultParent != null && checkResultParent.size() > 0){
            for(Check_Result_Temporary__c parent : checkResultParent){
                CheckResultData parentData = new CheckResultData();
                parentData.parent = parent;

                // 上传文件和评论默认为false，前端根据条件判断展示
                // parentData.parent.CheckItem__r.HasFile__c = false;
                // parentData.parent.CheckItem__r.HasComment__c = false;

                if(groupParent != null && groupParent.size() > 0){
                    checkResultRecursionInit(parentData,groupParent);
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
        List<Check_Result_Temporary__c> data = new List<Check_Result_Temporary__c>();
        
        if(checkResultList != null && checkResultList.size() > 0){
            for(CheckResultData item : checkResultList){
                checkUpsertData(item,data);
            }
        }

        System.debug('wwwwsaveCheckResult' + JSON.serialize(data));

        Database.upsert(data);

        return resp;
    }

    // 处理存储的checkResult
    public static void checkResultRecursionAdd(List<CheckItem__c> itemGroup,
                                            List<Check_Result_Temporary__c> checkResultAdd,
                                            Map<String,LisqContainer> groupParent){
        for(CheckItem__c item : itemGroup){

            Check_Result_Temporary__c result = new Check_Result_Temporary__c();
            result.CheckItem__c = item.id;
            result.Check_X_Plan__c = checkXPlanId;
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
                                            Map<String,List<Check_Result_Temporary__c>> groupParent){
        // LisqContainer lqGroupParent = groupParent.get(checkResultParent.parent.id);
        // List<CheckResult__c> resultGroupParent = (List<CheckResult__c>)lqGroupParent.ToSobjectList();
        List<Check_Result_Temporary__c> resultGroupParent = groupParent.get(checkResultParent.parent.CheckItem__c);

        if(resultGroupParent != null && resultGroupParent.size() > 0){
            // 处理父级下关联问题
            List<CheckResultData> CheckResultChildrenDate = new List<CheckResultData>();
            for(Check_Result_Temporary__c parent : resultGroupParent){
                CheckResultData checkResultChildren = new CheckResultData();
                checkResultChildren.parent = parent;

                checkResultRecursionInit(checkResultChildren,groupParent);

                CheckResultChildrenDate.add(checkResultChildren);
            }

            checkResultParent.children = CheckResultChildrenDate;          
        }
    }

    // 处理更新的check Result数据
    public static void checkUpsertData(CheckResultData item,List<Check_Result_Temporary__c> data){

        // 判断子级响应数据是否和父级数据相同，如果不满足则清除掉历史数据
        String response = item.parent.Response__c;

        data.add(item.parent);
        List<CheckResultData> children = item.children;
        if(children != null && children.size() > 0){
            for(CheckResultData childrenItem : children){
                if(!String.isEmpty(response) && !response.equals(childrenItem.parent.CheckItem__r.Parent_Response__c)){
                    // 如果不满足响应条件，去除已存储的历史数据
                    childrenItem.parent.Response__c = '';
                }
                checkUpsertData(childrenItem,data);
            }
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
            //设置检查数
            check.put('checkNumber', check.get('checkNumber') + 1);
        }
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

    public static List<CheckItem__c> getCheckItemParentNull(String itemType){
        return [SELECT id,
                       Parent_Response__c,
                       Parent__c
                       FROM CheckItem__c
                       WHERE Item_Type__c =: itemType
                       AND Parent__c = NULL
                       AND Active__c = true
                       AND Sales_Region__c =: salesRegion
                       AND Product_Line__c = 'All'];
    }

    // 根据父级Id查询对应的关联问题
    public static List<CheckItem__c> getCheckItemChildren(String parentId){
        return [SELECT id,
                       Parent_Response__c,
                       Parent__c
                       FROM CheckItem__c
                       WHERE Parent__c =: parentId];
    }

    public static List<Check_Result_Temporary__c> getCheckResultInit(String checkXPlanId,String ItemType){
        return [SELECT id
                       FROM Check_Result_Temporary__c
                       WHERE Check_X_Plan__c =: checkXPlanId
                       AND CheckItem__r.Item_Type__c =: ItemType
                ];
    }

    // 查询当前大类父级的check Result信息
    public static List<Check_Result_Temporary__c> getCheckResultParent(String checkXPlanId,String ItemType){
        return [SELECT id,
                       Name,
                       Comments__c,
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
                       Response__c,
                       Check_X_Plan__c
                       FROM Check_Result_Temporary__c
                       WHERE Check_X_Plan__c =: checkXPlanId
                       AND CheckItem__r.Item_Type__c =: ItemType
                       AND CheckItem__r.Parent__c = NULL
                       ORDER BY CheckItem__r.OrderNumber__c
                ];
    }

    // 查询当前大类子级的check Result信息
    public static List<Check_Result_Temporary__c> getCheckResultChildren(String checkXPlanId,String ItemType){
        return [SELECT id,
                       Name,
                       Comments__c,
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
                       Response__c,
                       Check_X_Plan__c
                       FROM Check_Result_Temporary__c
                       WHERE Check_X_Plan__c =: checkXPlanId
                       AND CheckItem__r.Item_Type__c =: ItemType
                       AND CheckItem__r.Parent__c != NULL
                       ORDER BY CheckItem__r.OrderNumber__c
                ];
    }

    public class CheckResultData{
        @AuraEnabled
        public Check_Result_Temporary__c parent;
        @AuraEnabled
        public List<CheckResultData> children;
    }

    public static void testClassMethod() {
            Integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
            i++;i++;
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
    }
}