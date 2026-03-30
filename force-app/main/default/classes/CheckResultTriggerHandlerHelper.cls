public without sharing class CheckResultTriggerHandlerHelper {

    public static User currentUser = [SELECT Id,Name,Username,Sales_Region__c,UserRole.Name,UserRole.ParentRoleId,UserRole.ParentRole.Name FROM User WHERE Id =:UserInfo.getUserId()]; 

    /**
     * @description 不满分的检查项创建时，自动创建ticket
     * @param       oldList     更改前数据
     * @param       newList     更改后数据
    */
    public static void createTickets(List<CheckResult__c> oldList, List<CheckResult__c> newList){
        // if(Test.isRunningTest()){
        //     gabige();
        // }
        System.debug('CheckResultTriggerHandlerHelper ——> createTickets:' );
        Map<Id, CheckResult__c> oldMap = new Map<Id, CheckResult__c>();
        Boolean isInsert = true;
        if(oldList != null) {
            isInsert = false;
            oldMap = new Map<Id, CheckResult__c>(oldList);
        }

        LisqContainer lc = new LisqContainer(newList);

        // YYL 20240517 针对南非新增时自动带入门店下网格负责人
        Map<String,SObject> reportMap;
        Map<String,SObject> storeMap;
        Map<String,SObject> gridMap;

        if(currentUser.Sales_Region__c == 'Hisense South Africa'){

            // 获取当前日报的门店信息
            List<String> inspectorDailyReportIdList = lc.selectsField('InspectorDailyReport__c');
            List<Daily_Inspection_Report__c> reports = [SELECT Id, Name,Store__c FROM Daily_Inspection_Report__c WHERE Id IN :inspectorDailyReportIdList];
            LisqContainer lcReport = new LisqContainer(reports);
            
            List<String> storeList = lcReport.SelectsField('Store__c');
            if(storeList != null && storeList.size() > 0){
                List<Shop__c> shops = [SELECT Id,Grid__c FROM Shop__c where Id IN : storeList];

                // 根据门店信息查询网格信息
                LisqContainer lcStore = new LisqContainer(shops);
                List<String> gridList = lcStore.SelectsField('Grid__c');

                if(gridList != null && gridList.size() > 0){
                    // 获取网格负责人信息
                    List<Gridding__c> griddings = [SELECT Id,Grid_Manager__c FROM Gridding__c where Id IN : gridList];
                    LisqContainer lcGrid = new LisqContainer(griddings);
                    List<String> gridManagerList = lcGrid.SelectsField('Grid_Manager__c');

                    if(gridManagerList != null && gridManagerList.size() > 0){
                        // 存放日报,门店和网格的详情信息
                        reportMap = lcReport.ToMapS('Id');
                        storeMap = lcStore.ToMapS('Id');
                        gridMap = lcGrid.ToMapS('Id');
                    }

                }
            }
        }
        

        // Map<Id, Daily_Inspection_Report__c> reportMap = Map<Id, Daily_Inspection_Report__c>(reports);

        List<CheckItem__c> checkItemList = [SELECT Id, Name, Active__c, MaximumScore__c, ResponsibleDepartment__c, Sales_Region__c, Description__c, Description_CN__c, Description_EN__c, Automatic_Generation_Ticket__c
                                                FROM CheckItem__c 
                                                WHERE Id IN: (lc.selectsField('CheckItem__c'))];
        Map<Id, CheckItem__c> checkItemMap = new Map<Id, CheckItem__c>(checkItemList);
        Map<Id, String> checkItemAndDepartmentNameMap = new Map<Id, String>();

        Set<String> departmentNameSet = new Set<String>();
        for(CheckItem__c item : checkItemList) {
            if(String.isNotBlank(item.ResponsibleDepartment__c)) {
                checkItemAndDepartmentNameMap.put(item.Id, item.Sales_Region__c.remove(' ') + '_' + item.ResponsibleDepartment__c);
                departmentNameSet.add(item.ResponsibleDepartment__c);
                System.debug('departmentName:' + item.ResponsibleDepartment__c);
            }
        }
        System.debug('groupNameSet:' + departmentNameSet);

        List<User> departmentUserList = [SELECT Id, Name, IsActive, Department__c, Sales_Region__c 
                                            FROM User 
                                            WHERE Department__c IN :departmentNameSet AND IsActive = true];
        Map<String, String> departmentNameAndUserIdsMap = new Map<String, String>();
        for(User item : departmentUserList) {
            String departName = String.isEmpty(item.Department__c) ? '' : item.Department__c;
            String region = String.isEmpty(item.Sales_Region__c) ? '' : item.Sales_Region__c.remove(' ');
            String deName = region + '_' + departName;
            if(departmentNameAndUserIdsMap.containsKey(deName)) {
                String userIds = departmentNameAndUserIdsMap.get(deName) + ';' + item.Id;
                departmentNameAndUserIdsMap.put(deName, userIds);
            } else {
                departmentNameAndUserIdsMap.put(deName, item.Id);
            }
        }
        System.debug('departmentNameAndUserIdsMap:' + departmentNameAndUserIdsMap);

        String recordTypeId = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType= 'Ticket__c' AND DeveloperName = 'Floorwalker'].Id;
        List<Ticket__c> newTicketList = new List<Ticket__c>();
        List<String> deleteTicketRelatedIdList = new List<String>();
        String ticketSubject = System.label.Department_Ticket_Subject;
        //lastby TJP 2025-06-24 d:计算到期日
        Integer buff = Integer.valueOf(System.label.Expire_Buff);
        Date newDate = Date.today().addDays(buff);
        //lastby TJP 2025-06-24 d:获取当前符合指派的门店经理
        String roleName = currentUser.UserRole.ParentRole.Name;
        String roleId = currentUser.UserRole.ParentRoleId;
        List<User> assignedUser = new List<User>();
        if(String.isNotEmpty(roleName) && roleName.contains('SouthAfrica Regional Manager')){
            assignedUser = [SELECT Id FROM User WHERE UserRoleId =: roleId AND IsActive = true Limit 1];
        }
        
        for(CheckResult__c item : newList) {
            System.debug('isInsert: ' + isInsert);
            if(!isInsert) {
                System.debug('CheckResult__c ---> old item: ' + oldMap.get(item.Id));
            }
            System.debug('CheckResult__c ---> item: ' + item);

            // 不需要生成和删除Ticket的情况：新建 和 分数未更改 和 产品未出样（自动生成-1 ——> 删除-2）
            if ( 
                item.Scores__c == -1 
                // add by DTT-Sunny 20240430 START
                || (
                    !isInsert 
                    && (
                        (item.Scores__c == oldMap.get(item.Id).Scores__c) 
                        || (item.Scores__c == -2 && oldMap.get(item.Id).Scores__c == -1)
                    )
                ) 
                // add by DTT-Sunny 20240430 END     
            ) {
                continue;
            }

            // if(checkItemAndDepartmentNameMap.containsKey(item.CheckItem__c) && checkItemMap.containsKey(item.CheckItem__c)) {
            // wfc 2024-01-30 check item增加配置项是否不合格自动生成ticket
            Boolean flag =  checkItemMap.get(item.CheckItem__c).Automatic_Generation_Ticket__c;
            if(
                !isInsert 
                && (
                    ((item.Scores__c == item.Max_Scores__c) && (oldMap.get(item.Id).Scores__c < item.Max_Scores__c))
                    // || (oldMap.get(item.Id).Scores__c > 0 && oldMap.get(item.Id).Scores__c < item.Max_Scores__c && item.Scores__c == -2)  //填过一次产品出样，题目非满分，然后改为不出样，需要删除自动生成的ticket
                    || item.Scores__c == -2 // 分数为-2代表该检查项对应的产品未出样，提交时会删除这部分检查结果，对应也需要删除这部分检查结果自动生成的ticket
                )
            ){
                deleteTicketRelatedIdList.add(item.Id);
            } else if((isInsert && flag && (item.Scores__c < item.Max_Scores__c))
            || (!isInsert && flag && (item.Scores__c < item.Max_Scores__c) && ((oldMap.get(item.Id).Scores__c == item.Max_Scores__c) || (oldMap.get(item.Id).Scores__c < 0)))) {                
                // if((item.Status__c == 'Submitted') && (item.Scores__c < item.Max_Scores__c)) {
                    // if(isInsert || (!isInsert && (item.Status__c != oldMap.get(item.Id).Status__c))) {
                System.debug('new ticket:' );
                Ticket__c ticket = new Ticket__c();
                ticket.CheckResult__c = item.Id;
                ticket.CheckItem__c = item.CheckItem__c;
                ticket.RecordTypeId = recordTypeId;
                ticket.Subject__c = String.format(ticketSubject, new List<Object>{item.InspectorReportName__c});
                ticket.InspectionReport__c = item.InspectorDailyReport__c;
                //lastby TJP 2025-06-24 d:增加DueDate__c,Generate_Date__c赋值
                ticket.DueDate__c = newDate;  
                // ticket.Generate_Date__c = newDate;   
                if(checkItemMap.containsKey(item.CheckItem__c)) {
                    //lastby TJP 2025-06-24 d:增加Description__c赋值
                    ticket.Description__c = checkItemMap.get(item.CheckItem__c).Description__c + '-' + item.Scores__c;
                    ticket.Subject__c = checkItemMap.get(item.CheckItem__c).Name + ' - ' + checkItemMap.get(item.CheckItem__c).Description__c;
                    // #多语言 add by DTT-Bright 20240729 START
                    String descn = checkItemMap.get(item.CheckItem__c).Description_CN__c;
                    if (String.isBlank(descn)) {
                        descn = checkItemMap.get(item.CheckItem__c).Description__c;
                    }
                    ticket.SubjectCN__c = checkItemMap.get(item.CheckItem__c).Name + ' - ' + descn;
                    String desen = checkItemMap.get(item.CheckItem__c).Description_EN__c;
                    if (String.isBlank(desen)) {
                        desen = checkItemMap.get(item.CheckItem__c).Description__c;
                    }
                    ticket.SubjectEN__c = checkItemMap.get(item.CheckItem__c).Name + ' - ' + desen;
                    // #多语言  add by DTT-Bright 20240729 END
                    ticket.Department__c = checkItemMap.get(item.CheckItem__c).ResponsibleDepartment__c;
                }
                if(checkItemAndDepartmentNameMap.containsKey(item.CheckItem__c)) {
                    String deName = checkItemAndDepartmentNameMap.get(item.CheckItem__c);
                    if(departmentNameAndUserIdsMap.containsKey(deName)) {
                        ticket.ResponsibleDepartment__c = deName;
                        ticket.ResponsibleDepartmentUserIds__c = departmentNameAndUserIdsMap.get(deName);
                    }
                }
                ticket.SystemGeneration__c = true;


                // YYL 20240517 针对南非新增时自动带入门店下网格负责人
                // if(currentUser.Sales_Region__c == 'Hisense South Africa'){
                //     if(gridMap != null && gridMap.size() > 0){

                //         Daily_Inspection_Report__c report = (Daily_Inspection_Report__c)reportMap.get(item.InspectorDailyReport__c);
                //         Shop__c shop = (Shop__c)storeMap.get(report.Store__c);
                //         Gridding__c gridding = (Gridding__c)gridMap.get(shop.Grid__c);
                        
                //         if(gridding != null){
                //             ticket.AssignedTo__c = gridding.Grid_Manager__c;
                //         }
                //     }
                // }
                // TJP 20250626 根据角色树查找对应门店经理
                if(currentUser.Sales_Region__c == 'Hisense South Africa'){
                    if(assignedUser.size() > 0) {
                        ticket.AssignedTo__c = assignedUser[0].Id;
                    }
                }

                newTicketList.add(ticket);
                    // }
                // }
            }
        }
        if(newTicketList.size() > 0) {
            insert newTicketList;
        }

        if(deleteTicketRelatedIdList.size() > 0) {
            List<Ticket__c> deleteTicketList = [SELECT Id FROM Ticket__c WHERE CheckResult__c IN :deleteTicketRelatedIdList AND SystemGeneration__c = true];
            if(deleteTicketList.size() > 0) {
                delete deleteTicketList;
            }
        }
    }

    public static void createTrainingDetails(List<CheckResult__c> oldList,List<CheckResult__c> newList) {
        Map<Id, CheckResult__c> oldMap = new Map<Id, CheckResult__c>(oldList);
        LisqContainer lcCheckResult = new LisqContainer(newList);
        Map<string,LisqContainer> salesRegionLc = lcCheckResult.GroupByS('Sales_Region__c');
        LisqContainer ls = salesRegionLc.containsKey('Hisense Australia') ? salesRegionLc.get('Hisense Australia') : LisqContainer.NewEmpty();
        if(ls.Size() > 0) {
            List<Id> australiaId = ls.SelectSField('Id');
            List<CheckResult__c> resultList = [SELECT Id, InspectorDailyReport__c, CheckItem__c, CheckItem__r.Description__c, Response__c FROM CheckResult__c WHERE Id IN :australiaId AND CheckItem__r.Item_Type__c = 'Training' AND CheckItem__r.Question_Type__c = 'Multiple Selection' AND InspectorDailyReport__c != NULL];
            List<Id> delId = new List<Id>();
            System.debug('测试' + resultList.size());
            if(resultList.size() > 0) {
                List<Training_Detail__c> trainList = new List<Training_Detail__c>();
                for(CheckResult__c cr : resultList) {
                    CheckResult__c oldCheck = oldMap.get(cr.Id);
                    if(oldCheck.Response__c != cr.Response__c) {
  
                        delId.add(oldCheck.Id);
                    }
                    if(String.isNotEmpty(cr.Response__c) && cr.Response__c.contains(';')) {
                        List<String> stringList = cr.Response__c.split(';');
                    
                        for(String Str : stringList){
                            Training_Detail__c tr = new Training_Detail__c(
                                Check_Result__c = cr.Id,
                                Description__c = cr.CheckItem__r.Description__c,
                                Result__c = Str,
                                ExternalKey__c = cr.InspectorDailyReport__c + '-' + cr.Id + '-' + Str
                            );
                            trainList.add(tr);
                        }
                    } else if(String.isNotEmpty(cr.Response__c)){
              
                        Training_Detail__c tr = new Training_Detail__c(
                            Check_Result__c = cr.Id,
                            Description__c = cr.CheckItem__r.Description__c,
                            Result__c = cr.Response__c,
                            ExternalKey__c = cr.InspectorDailyReport__c + '-' + cr.Id + '-' + cr.Response__c
                            
                        );
                        trainList.add(tr);
                    }
                }
                if(delId.size() > 0) {
                    List<Training_Detail__c> deleteTrainList = [SELECT Id FROM Training_Detail__c WHERE Check_Result__c IN :delId];
                    If (deleteTrainList.size() > 0) delete deleteTrainList;
                }
                if(trainList.size() > 0) {
                    UPSERT trainList ExternalKey__c;
                }
            }
            
        }
    }

    public static void createUnplannedSamples(List<CheckResult__c> oldList,List<CheckResult__c> newList) {
        List<Unplanned_Sample__c> us = new List<Unplanned_Sample__c>();
        Map<Id, CheckResult__c> oldMap = new Map<Id, CheckResult__c>(oldList);
        LisqContainer lcCheckResult = new LisqContainer(newList);
        Map<string,LisqContainer> salesRegionLc = lcCheckResult.GroupByS('Sales_Region__c');
        LisqContainer ls = salesRegionLc.containsKey('Hisense Australia') ? salesRegionLc.get('Hisense Australia') : LisqContainer.NewEmpty();
        if(ls.Size() > 0) {
            List<Id> australiaId = ls.SelectSField('Id');
            List<CheckResult__c> resultList = [SELECT Id, Sales_Region__c, Index__c, InspectorDailyReport__c, CheckItem__c,CheckItem__r.Question_Type__c, CheckItem__r.Description__c, Response__c FROM CheckResult__c WHERE Id IN :australiaId AND CheckItem__r.Item_Type__c = 'Sample Display Check' AND InspectorDailyReport__c != NULL];
            if(resultList.size() > 0) {
                Map<string,LisqContainer> reportLs = new LisqContainer(resultList).GroupByS('InspectorDailyReport__c');
                for(String dailyId : reportLs.keySet()) {
                    LisqContainer dailyLs = reportLs.get(dailyId);

                    List<CheckResult__c> resultGroupParent = (List<CheckResult__c>)dailyLs.ToSobjectList();
                    if(containSampleResult(resultGroupParent)) {
                        List<Unplanned_Sample__c> samples = generateUnplannedSample(resultGroupParent);
                        us.addAll(samples);
                    }

                }

                if(us.size() > 0) {
                    UPSERT us ExternalKey__c;
                }
            }
        }
    }

    public static Boolean containSampleResult(List<CheckResult__c> results){
        for (CheckResult__c result : results) {
            if(result.CheckItem__r.Question_Type__c == 'Yes/No' && String.isNotEmpty(result.Response__c) && ('No').equals(result.Response__c)) {
                return true;
            }
        }
        return false;
    }

    public static List<Unplanned_Sample__c> generateUnplannedSample(List<CheckResult__c> results){
        List<Unplanned_Sample__c> us = new List<Unplanned_Sample__c>();
        System.debug('拼接参数值' + results.size());
        Map<String,Unplanned_Sample__c> sampleMap = new Map<String,Unplanned_Sample__c>();
        for(CheckResult__c result : results) {
            String key = result.Index__c + '';
            if(String.isNotEmpty(key)) {
                if(result.CheckItem__r.Question_Type__c == 'Picklist') {
                    if (!sampleMap.containsKey(key)) {
                        sampleMap.put(key, new Unplanned_Sample__c());
                    }
                    sampleMap.get(key).Description__c = result.Response__c;
                }
                if(result.CheckItem__r.Question_Type__c == 'Object') {
                    if (!sampleMap.containsKey(key)) {
                        sampleMap.put(key, new Unplanned_Sample__c());
                    }
                    sampleMap.get(key).Product__c = result.Response__c;
                    sampleMap.get(key).Check_Result__c = result.Id;
                }
            } 
        }
        System.debug('参数解析' + sampleMap.keySet());
        for(String key : sampleMap.keySet()) {
            Unplanned_Sample__c ones = sampleMap.get(key);
            ones.Inspection_Report__c = results[0].InspectorDailyReport__c;
            ones.SBU__c = results[0].Sales_Region__c;
            ones.Placement_Status__c = '未展出';
            ones.Planned_Display__c = 'No';
            ones.ExternalKey__c = results[0].InspectorDailyReport__c + key;
            us.add(ones);
        }
        System.debug('参数列' + us.size());    
        return us;
    }

    public static void deleteTrainDetail(){
        List<Training_Detail__c> deleteTrainList = [SELECT Id FROM Training_Detail__c WHERE Check_Result__c = NULL];
        if(deleteTrainList.size() > 0) {
            delete deleteTrainList;
        }
    }

    public static void deleteUnplannedSample(List<CheckResult__c> oldList,List<CheckResult__c> newList){
        LisqContainer lc = new LisqContainer(oldList);
        // 获取当前日报的门店信息
        List<String> idList = lc.selectsField('Id');
        List<Unplanned_Sample__c> deleteSampleList = [SELECT Id FROM Unplanned_Sample__c WHERE Check_Result__c IN: idList];
        if(deleteSampleList.size() > 0) {
            delete deleteSampleList;
        }
    }
    
}