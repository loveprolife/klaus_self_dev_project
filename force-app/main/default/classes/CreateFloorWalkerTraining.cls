global class CreateFloorWalkerTraining implements Database.Batchable<sObject> {
    /* 用于判断“今天” */
    private final Date currentDate = Date.today();
    private final Integer currentYear = currentDate.year();
    private final Integer currentMonth = currentDate.month();

    private Integer year;
    private Integer month;

    // 默认构造函数，使用当前日期的年和月
    global CreateFloorWalkerTraining() {
        this.year = currentYear;
        this.month = currentMonth;
    }

    // 带参数的构造函数，允许传入年和月
    global CreateFloorWalkerTraining(Integer year, Integer month) {
        this.year = year;
        this.month = month;
    }

    public static Date getFirstDayOfMonth(Integer year, Integer month) {
        return Date.newInstance(year, month, 1);
    }

    public static Date getLastDayOfMonth(Integer year, Integer month) {
        if (month == 12) {
            return Date.newInstance(year + 1, 1, 1).addDays(-1);
        } else {
            return Date.newInstance(year, month + 1, 1).addDays(-1);
        }
    }

    /* 起始：拉所有明细 */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date firstDay = getFirstDayOfMonth(this.year, this.month);
        Date lastDay = getLastDayOfMonth(this.year, this.month);
        return Database.getQueryLocator([
			 SELECT Id,InspectorDailyReport__r.Store_Name__c, InspectorDailyReport__r.Status__c, Report_Date__c,
             CreatedById,InspectorDailyReport__r.Owner_text__c, CheckItem__r.Description__c, Response__c 
			 FROM CheckResult__c 
			 WHERE InspectorDailyReport__r.Status__c = 'Submitted' 
			 AND Sales_Region__c = 'Hisense Australia' 
			 AND CheckItem__r.Item_Type__c = 'Training' 
			 AND CheckItem__r.Question_Type__c = 'Integer'
			 AND InspectorDailyReport__r.Report_Date__c >= : firstDay
			 AND InspectorDailyReport__r.Report_Date__c <= : lastDay
			 ORDER BY CreatedDate
        ]);
    }

    /* Max:100SQL;50000rows */
    public void execute(Database.BatchableContext bc, List<CheckResult__c> scope) {
        System.debug('数据量' + scope.size());
        List<User> users = [SELECT Id, Name, IsActive FROM User WHERE Profile.Name = 'Australia Floorwalker' and IsActive = true];
        Integer days = Date.daysInMonth(Integer.valueOf(this.year), Integer.valueOf(this.month));
        List<Floorwalk_Training_Plan__c> newPlans = new List<Floorwalk_Training_Plan__c>();
        Map<String, Map<String, List<Decimal>>> summaryMap = new Map<String, Map<String, List<Decimal>>>();
        
        // 遍历查询结果，汇总数据
        for (CheckResult__c result : scope) {
            String createdBy = result.CreatedById;
            Date reportDate = result.Report_Date__c;
            DateTime reportDateTime = DateTime.newInstance(reportDate.year(), reportDate.month(), reportDate.day());
            String reportDateStr = reportDateTime.format('yyyy-MM-dd');
            Decimal responseValue = (result.Response__c != null) ? Decimal.valueOf(result.Response__c) : null;
        
            if (responseValue != null) {
                // 如果用户不存在于 Map 中，初始化
                if (!summaryMap.containsKey(createdBy)) {
                    summaryMap.put(createdBy, new Map<String, List<Decimal>>());
                }
            
                // 如果日期不存在于用户 Map 中，初始化
                if (!summaryMap.get(createdBy).containsKey(reportDateStr)) {
                    summaryMap.get(createdBy).put(reportDateStr, new List<Decimal>());
                }
            
                // 添加响应值到列表
                summaryMap.get(createdBy).get(reportDateStr).add(responseValue);
            }
        }
    
        for (User user : users) {
            for (Integer j = 1; j <= days; j++) {
                Date dtDate = Date.newInstance(Integer.valueOf(this.year), Integer.valueOf(this.month), j);
                Datetime dtDatetime = Datetime.newInstanceGmt(dtDate.year(), dtDate.month(), dtDate.day(), 0, 0, 0);
                Integer week = Integer.valueOf(dtDatetime.format('u'));
                String dtDateStr = dtDatetime.format('yyyy-MM-dd');
            
                Floorwalk_Training_Plan__c newPlan = new Floorwalk_Training_Plan__c(
                    User__c = user.Id,
                    Report_Date__c = dtDate,
                    ExternalKey__c = dtDateStr + '-' + user.Id
                );
            
                if (week == 6 || week == 7) {
                    // 不计算
                    newPlan.Target_number_of_trainees__c = 0;
                    System.debug('周六周天: ' + dtDateStr);
                } else {
                    newPlan.Target_number_of_trainees__c = 5;
                    System.debug('工作日: ' + dtDateStr);
                }
            
                // 获取用户对应的 Map<String, List<Decimal>>
                Map<String, List<Decimal>> dateMap = summaryMap.get(user.Id);
            
                // 初始化响应列表
                List<Decimal> responses = new List<Decimal>();
            
                // 检查 dateMap 是否为空
                if (dateMap != null && dateMap.containsKey(dtDateStr)) {
                    responses = dateMap.get(dtDateStr);
                }
            
                Decimal total = 0;
                for (Decimal response : responses) {
                    total += response;
                }
            
                newPlan.Actual_number_of_trainees__c = total;
                newPlan.Name = dtDateStr + '-' + user.Name + '-' + newPlan.Target_number_of_trainees__c + '-' + total;
            
                newPlans.add(newPlan);
            }
        }
    
        // 插入新的任务记录
        try {
            upsert newPlans ExternalKey__c;
        } catch (Exception e) {
            // 记录异常信息
            System.debug('Error inserting tasks: ' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}