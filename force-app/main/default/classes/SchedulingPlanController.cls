public without sharing class SchedulingPlanController {
    private static String SCHEDULING_PLAN_ERROR_MSG_13 = System.Label.SCHEDULING_PLAN_ERROR_MSG_13; //促销员{0}没有找到
    private static String SCHEDULING_PLAN_ERROR_MSG_14 = System.Label.SCHEDULING_PLAN_ERROR_MSG_14; //促销员{0}没有找到
    private static String SCHEDULING_PLAN_ERROR_MSG_15 = System.Label.SCHEDULING_PLAN_ERROR_MSG_15; //促销员{0}没有找到

    @AuraEnabled
    public static Map<String, Map<String, String>> initLabel(){
        Map<String, Map<String, String>> resp = new Map<String, Map<String, String>>();
        resp.put('Responsible_Person__c', SObjectHelper.getFieldLabelMap('Responsible_Person__c'));
        resp.put('SchedulingPlan__c', SObjectHelper.getFieldLabelMap('SchedulingPlan__c'));
        resp.put('User', SObjectHelper.getFieldLabelMap('User'));

        Map<String,string> sTaskStatus = Utility.getPicklistValueMap('SchedulingTask__c','Status__c');
        resp.put('SchedulingTask_Status', sTaskStatus);
        return resp;
    }

    @AuraEnabled
    public static ConResponse init(String salesRegion){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        User user = [SELECT Id,Name,Sales_Region__c,Profile.PermissionsModifyAllData FROM User WHERE Id = :UserInfo.getUserId()];
        mso.put('userSalesRegion', user.Sales_Region__c);
        mso.put('isAdmin', user.Profile.PermissionsModifyAllData);

        if (salesRegion=='' || salesRegion==null) {
            salesRegion = user.Sales_Region__c;
        }

        String rpSoql = '';
        rpSoql += 'SELECT ';
        rpSoql += 'Id,';
        rpSoql += 'Name,';
        rpSoql += 'Shop_Name__c,';
        rpSoql += 'Shop_Name__r.Name,';
        rpSoql += 'Principal__c,';
        rpSoql += 'Principal__r.Name,';
        rpSoql += 'Promoter_Attendance_Rule__c';
        rpSoql += ' FROM ';
        rpSoql += 'Responsible_Person__c ';
        rpSoql += ' WHERE ';
        rpSoql += 'RecordType__c = \'促销员\'';
        rpSoql += ' AND ';
        rpSoql += 'Shop_Name__c !=null';
        rpSoql += ' AND ';
        rpSoql += 'Principal__c !=null';
        rpSoql += ' AND ';
        rpSoql += 'Promoter_Attendance_Rule__c !=null';
        rpSoql += ' AND ';
        rpSoql += 'Principal__r.Sales_Region__c = \''+salesRegion+'\'';
        List<SObject> rpList = Database.query(rpSoql);
        mso.put('responsiblePersons', rpList);

        System.debug('resp======>'+resp);
        return resp;
    }

    @AuraEnabled
    public static ConResponse initData(String year, String month, String salesRegion, String storeId, String userId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        Integer year_int = Integer.valueOf(year);
        Integer month_int = Integer.valueOf(month);
        
        // if ((storeId==''||storeId==null||storeId=='All')&&(userId==''||userId==null||userId=='All')) {
        //     mso.put('schedulingTasks', new List<SObject>());
        //     mso.put('responsiblePersons', new List<SObject>());
        //     return resp;
        // }

        // List<SchedulingPlan__c> spList = [SELECT Id,Name,Year__c,Month__c FROM SchedulingPlan__c WHERE Year__c = :year_int AND Month__c = :month_int];
        // SchedulingPlan__c sp  = new SchedulingPlan__c();
        // if (spList.size()>0) {
        //     sp = spList[0];
        // } else {
        //     sp.Year__c = year_int;
        //     sp.Month__c = month_int;
        //     insert sp;
        // }
        // mso.put('schedulingPlanDate', sp);
        Date sDate = Date.valueOf(year+'-'+month+'-1');
        Date eDate = sDate.addMonths(1);

        String stSoql = '';
        stSoql += 'SELECT ';
        stSoql += 'Id,';
        stSoql += 'Name,';
        stSoql += 'IsImport__c,';
        stSoql += 'Status__c,';
        stSoql += 'Store__c,';
        stSoql += 'User__c,';
        // stSoql += 'SchedulingPlan__c,';
        stSoql += 'Scheduling_Date__c,';
        stSoql += 'Responsible_person__c,';
        stSoql += 'Promoter_Attendance_Rule__c,';
        stSoql += 'Application__c';
        stSoql += ' FROM ';
        stSoql += 'SchedulingTask__c ';
        stSoql += ' WHERE ';
        // stSoql += 'SchedulingPlan__c = \''+sp.Id+'\'';
        stSoql += 'Scheduling_Date__c >= '+ String.valueOf(sDate);
        stSoql += ' AND ';
        stSoql += 'Scheduling_Date__c < '+ String.valueOf(eDate);
        stSoql += ' AND ';
        stSoql += 'Responsible_person__c != null';
        stSoql += ' AND ';
        stSoql += 'Responsible_person__r.Principal__r.Sales_Region__c = \''+salesRegion+'\'';
        if (String.isNotBlank(storeId)) {
            stSoql += ' AND ';
            stSoql += 'Responsible_person__r.Shop_Name__c = \''+storeId+'\'';
        }
        if (String.isNotBlank(userId)) {
            stSoql += ' AND ';
            stSoql += 'Responsible_person__r.Principal__c = \''+userId+'\'';
        }
        List<SObject> stList = Database.query(stSoql);
        mso.put('schedulingTasks', stList);
                                            
        System.debug('resp======>'+JSON.serialize(resp));
        return resp;
    }
    
    @AuraEnabled
    public static string upsertSchedulingTask(String taskJson){
        SchedulingTask__c taskDate = (SchedulingTask__c)JSON.deserialize(taskJson, SchedulingTask__c.class);
        taskDate.ExternalId__c = taskDate.Store__c + '_' + taskDate.User__c + '_' + String.valueOf(taskDate.Scheduling_Date__c)+'_'+taskDate.Responsible_person__c;
        upsert taskDate ExternalId__c;
        return taskDate.Id;
    }

    @AuraEnabled
    public static Boolean deleteSchedulingTask(String taskId){
        try {
            Database.DeleteResult resp = Database.delete(taskId);
            if (resp.isSuccess()) {
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static ConResponse uploadCSV(String contentJSON, String year, String month, String salesRegion){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        try {
            Date today = System.today();
            // 转换CSV
            List<Object> contentDate = (List<Object>)Json.deserializeUntyped(contentJSON);
            Set<String> userName = new Set<String>();
            for (Object contentObj : contentDate) {
                Map<String,Object> content = (Map<String,Object>)contentObj;
                userName.add((String)content.get('userName'));
            }
            // 查询门店负责人
            List<Responsible_Person__c> rpList = [
                SELECT 
                    Id,
                    Name,
                    Shop_Name__c,
                    Shop_Name__r.Name,
                    Principal__c,
                    Principal__r.Name,
                    Principal__r.Username,
                    Promoter_Attendance_Rule__c
                FROM 
                    Responsible_Person__c 
                WHERE 
                    RecordType__c = '促销员'
                AND 
                    Shop_Name__c !=null
                AND 
                    Principal__c !=null
                AND 
                    Promoter_Attendance_Rule__c !=null
                AND 
                    Principal__r.Sales_Region__c = :salesRegion
                AND 
                    Principal__r.Username IN :userName
            ];
            // 整理门店负责人 username => Responsible Person List
            Map<String, List<Responsible_Person__c>> usernameRpMap = new Map<String, List<Responsible_Person__c>>();
            for (Responsible_Person__c rp : rpList) {
                if (usernameRpMap.containsKey(rp.Principal__r.Username)) {
                    List<Responsible_Person__c> rpItems = usernameRpMap.get(rp.Principal__r.Username);
                    rpItems.add(rp);
                } else {
                    List<Responsible_Person__c> rpItems = new List<Responsible_Person__c>();
                    rpItems.add(rp);
                    usernameRpMap.put(rp.Principal__r.Username,rpItems);
                }
            }
            // 查询整理考勤规则
            Map<String, String> ruleMap = new Map<String, String>();
            for (Promoter_Attendance_Rule__c rule : [SELECT Id,Name FROM Promoter_Attendance_Rule__c]) {
                ruleMap.put(rule.Name, rule.Id);
            }
            // 新建巡店任务
            List<SchedulingTask__c> newTasks = new List<SchedulingTask__c>();
            List<String> delTasksExIds = new List<String>();
            // 检查数据是否正确
            for (Object contentObj : contentDate) {
                Map<String,Object> content = (Map<String,Object>)contentObj;
                String uName  = (String)content.get('userName');     // 促销员userName
                String sName  = (String)content.get('storeName');   // 促销员StoreName
                // 未找到user
                if (!usernameRpMap.containsKey(uName)) {
                    resp.code= -1;
                    // 'Promoter '+uName+' not found'
                    resp.message = String.format(SCHEDULING_PLAN_ERROR_MSG_13, new List<String>{uName});
                    return resp;
                }
                // 收集门店Id 促销员Id
                Boolean hasStore = false;
                for (Responsible_Person__c rp : usernameRpMap.get(uName)) {
                    if (rp.Shop_Name__r.Name==content.get('storeName')) {
                        hasStore = true;
                        content.put('storeId', rp.Shop_Name__c);
                        content.put('userId', rp.Principal__c);
                        content.put('rpRule', rp.Promoter_Attendance_Rule__c);
                        content.put('rpId', rp.Id);
                        break;
                    }
                }
                // 未找到user关联门店
                if (!hasStore) {
                    resp.code= -1;
                    // Promoter {0} was not found in store {1}.
                    resp.message = String.format(SCHEDULING_PLAN_ERROR_MSG_14, new List<String>{uName,sName});
                    return resp;
                }
                // 收集考勤规则Id
                Map<String, Object> taskMap = (Map<String, Object>)content.get('task');
                Map<String,String> taskDateRule = new Map<String,String>();
                for (Object dateKeyObj : taskMap.keySet()) {
                    String dateKey = (String)dateKeyObj;
                    String dStr = year+'-'+month+'-'+dateKey;
                    // 判断日期
                    Date taskDate = Date.valueOf(dStr);
                    if (taskDate<=today) {
                        continue;
                    }
                    // 新建任务
                    SchedulingTask__c task = new SchedulingTask__c();
                    task.IsImport__c = true;
                    task.Scheduling_Date__c = taskDate;
                    task.Responsible_person__c = (String)content.get('rpId');
                    task.Store__c = (String)content.get('storeId');
                    task.User__c = (String)content.get('userId');
                    task.Status__c = 'Scheduled';
                    task.ExternalId__c = task.Store__c + '_' + task.User__c + '_' + String.valueOf(task.Scheduling_Date__c)+'_'+task.Responsible_person__c;
                    String val = String.valueOf(taskMap.get(dateKey));
                    if (val=='1') {
                        taskDateRule.put(dStr, (String)content.get('rpRule'));
                        task.Promoter_Attendance_Rule__c = (String)content.get('rpRule');
                        newTasks.add(task);
                    } else if (val=='0') {
                        delTasksExIds.add(task.ExternalId__c);
                        // continue;
                    } else if (ruleMap.containsKey(val)) {
                        taskDateRule.put(dStr, ruleMap.get(val));
                        task.Promoter_Attendance_Rule__c = ruleMap.get(val);
                        newTasks.add(task);
                    } else {
                        resp.code= -1;
                        // 'Attendance rule '+taskMap.get(dateKey)+' does not exist'
                        resp.message = String.format(SCHEDULING_PLAN_ERROR_MSG_15, new List<String>{val});
                        return resp;
                    }
                }
                content.put('taskDateRule', taskDateRule);
            }
            System.debug('contentDate---->'+JSON.serialize(contentDate));
            if (newTasks.size()>0) {
                upsert newTasks ExternalId__c;

                Set<String> rpIds = new Set<String>();
                for (SchedulingTask__c item : newTasks) {
                    rpIds.add(item.Responsible_person__c);
                }
                mso.put('csvRpIds', rpIds);

                List<SchedulingTask__c> stList = [
                                            SELECT 
                                                Id,
                                                Name,
                                                IsImport__c,
                                                Status__c,
                                                Store__c,
                                                User__c,
                                                Scheduling_Date__c,
                                                Responsible_person__c,
                                                Promoter_Attendance_Rule__c,
                                                Application__c
                                            FROM 
                                                SchedulingTask__c 
                                            WHERE 
                                            Responsible_person__c IN :rpIds];
                mso.put('schedulingTasks', stList);
            }
            if (delTasksExIds.size()>0) {
                List<SchedulingTask__c> stList = [
                                            SELECT 
                                                Id,
                                                Name,
                                                Status__c
                                            FROM 
                                                SchedulingTask__c 
                                            WHERE 
                                                Status__c != 'OnLeave'
                                            AND
                                                ExternalId__c IN :delTasksExIds];
                if (stList.size()>0) {
                    delete stList;
                }
            }
        } catch (Exception e) {
            resp.code= -1;
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.message = e.getMessage();
        }
        return resp;
    }

    public static void upsertOnLeave(String applicationId, String userId, Date startDate, Date endDate) {
        String rpSoql = '';
        rpSoql += 'SELECT ';
        rpSoql += 'Id,';
        rpSoql += 'Name,';
        rpSoql += 'Shop_Name__c,';
        rpSoql += 'Shop_Name__r.Name,';
        rpSoql += 'Principal__c,';
        rpSoql += 'Principal__r.Name,';
        rpSoql += 'Promoter_Attendance_Rule__c';
        rpSoql += ' FROM ';
        rpSoql += 'Responsible_Person__c ';
        rpSoql += ' WHERE ';
        rpSoql += 'RecordType__c = \'促销员\'';
        rpSoql += ' AND ';
        rpSoql += 'Shop_Name__c !=null';
        rpSoql += ' AND ';
        rpSoql += 'Principal__c = \''+userId+'\'';
        rpSoql += ' AND ';
        rpSoql += 'Promoter_Attendance_Rule__c !=null';
        List<Responsible_Person__c> rpList = (List<Responsible_Person__c>)Database.query(rpSoql);
        if (rpList.size()==0) {
            return;
        }

        List<SchedulingTask__c> tasks = new List<SchedulingTask__c>();
        while (startDate<=endDate) {
            for (Responsible_Person__c rp : rpList) {
                SchedulingTask__c task = new SchedulingTask__c();
                task.IsImport__c = false;
                task.Scheduling_Date__c = startDate;
                task.Responsible_person__c = rp.Id;
                task.Store__c = rp.Shop_Name__c;
                task.User__c = userId;
                task.Status__c = 'OnLeave';
                task.Application__c = applicationId;
                task.Promoter_Attendance_Rule__c = rp.Promoter_Attendance_Rule__c;
                task.ExternalId__c = task.Store__c+'_'+task.User__c+'_'+String.valueOf(task.Scheduling_Date__c)+'_'+task.Responsible_person__c;
                tasks.add(task);
            }
            startDate = startDate.addDays(1);
        }

        upsert tasks ExternalId__c;

    }

    public static Map<String,Promoter_Attendance_Rule__c> queryTaskPromoterAttendanceRule(List<String> rpids, Date d) {

        List<SchedulingTask__c> stList = [SELECT
                                            Id,
                                            Name,
                                            Status__c,
                                            Store__c,
                                            User__c,
                                            Scheduling_Date__c,
                                            Responsible_person__c,
                                            Promoter_Attendance_Rule__c,
                                            Promoter_Attendance_Rule__r.Name,
                                            Promoter_Attendance_Rule__r.Start_time__c,
                                            Promoter_Attendance_Rule__r.End_time__c,
                                            Promoter_Attendance_Rule__r.Time_buffer__c,
                                            Promoter_Attendance_Rule__r.Distance__c,
                                            Promoter_Attendance_Rule__r.Need_Check_Distance__c 
                                        FROM 
                                            SchedulingTask__c
                                        WHERE 
                                            Scheduling_Date__c = :d
                                        AND Responsible_person__c IN :rpids
                                        AND Promoter_Attendance_Rule__c != null];
        
        Map<String,Promoter_Attendance_Rule__c> ruleMap = new Map<String,Promoter_Attendance_Rule__c>();
        for (SchedulingTask__c task : stList) {
            Promoter_Attendance_Rule__c rule = new Promoter_Attendance_Rule__c();
            rule.Id = task.Promoter_Attendance_Rule__c;
            rule.Name = task.Promoter_Attendance_Rule__r.Name;
            rule.Start_time__c = task.Promoter_Attendance_Rule__r.Start_time__c;
            rule.End_time__c = task.Promoter_Attendance_Rule__r.End_time__c;
            rule.Time_buffer__c = task.Promoter_Attendance_Rule__r.Time_buffer__c;
            rule.Distance__c = task.Promoter_Attendance_Rule__r.Distance__c;
            rule.Need_Check_Distance__c = task.Promoter_Attendance_Rule__r.Need_Check_Distance__c;

            ruleMap.put(task.Responsible_person__c,rule);
        }
        Set<String> rpOutIds = new Set<String>();
        for (String rpId : rpids) {
            if (!ruleMap.containsKey(rpId)) {
                rpOutIds.add(rpId);
            }
        }
        if (rpOutIds.size()>0) {
            for (Responsible_Person__c item : [SELECT 
                                                Id,
                                                Promoter_Attendance_Rule__c,
                                                Promoter_Attendance_Rule__r.Name,
                                                Promoter_Attendance_Rule__r.Start_time__c,
                                                Promoter_Attendance_Rule__r.End_time__c,
                                                Promoter_Attendance_Rule__r.Time_buffer__c,
                                                Promoter_Attendance_Rule__r.Distance__c,
                                                Promoter_Attendance_Rule__r.Need_Check_Distance__c 
                                            FROM Responsible_Person__c WHERE Id IN :rpOutIds]) {
                
                Promoter_Attendance_Rule__c rule = new Promoter_Attendance_Rule__c();
                rule.Id = item.Promoter_Attendance_Rule__c;
                rule.Name = item.Promoter_Attendance_Rule__r.Name;
                rule.Start_time__c = item.Promoter_Attendance_Rule__r.Start_time__c;
                rule.End_time__c = item.Promoter_Attendance_Rule__r.End_time__c;
                rule.Time_buffer__c = item.Promoter_Attendance_Rule__r.Time_buffer__c;
                rule.Distance__c = item.Promoter_Attendance_Rule__r.Distance__c;
                rule.Need_Check_Distance__c = item.Promoter_Attendance_Rule__r.Need_Check_Distance__c;

                ruleMap.put(item.Id,rule);
            }
        }

        return ruleMap;
    }

    public static void updateTaskStatus(Map<String,String> rpMap, Date d, String type) {
        if (rpMap.size()==0) {
            return;
        }
        
        List<SchedulingTask__c> stList = [SELECT
                                            Id,
                                            Name,
                                            Status__c,
                                            Store__c,
                                            User__c,
                                            Scheduling_Date__c,
                                            Responsible_person__c,
                                            Check_In_Attendance_Information__c,
                                            Check_Out_Attendance_Information__c
                                        FROM 
                                            SchedulingTask__c
                                        WHERE 
                                            Scheduling_Date__c = :d
                                        AND Responsible_person__c IN :rpMap.keySet()];
        Map<String, SchedulingTask__c> rpTaskMap = new Map<String, SchedulingTask__c>();
        for (SchedulingTask__c task : stList) {
            rpTaskMap.put(task.Responsible_person__c,task);
        }

        List<SchedulingTask__c> needUpdateTasks = new List<SchedulingTask__c>();
        for (String rpId : rpMap.keySet()) {
            String infoId = rpMap.get(rpId);
            if (!rpTaskMap.containsKey(rpId)) {
                continue;
            }
            SchedulingTask__c task = rpTaskMap.get(rpId);
            if (type=='checkIn' && String.isBlank(task.Check_In_Attendance_Information__c)) {
                task.Check_In_Attendance_Information__c = infoId;
                needUpdateTasks.add(task);
            }else if (type=='checkOut') {
                task.Check_Out_Attendance_Information__c = infoId;
                needUpdateTasks.add(task);
            }
        }
        if (needUpdateTasks.size()>0) {
            update needUpdateTasks;
        }
    }
}