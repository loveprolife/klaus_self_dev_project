public class MetricCalculator {

    // 用户数量：当前Active的用户数量
    // 月活用户数量：本月登陆过的用户去重
    // 月活率：月活用户数量/用户数量
    // 环比：（当月月活用户数量-上月月活数量）/用户数量x100%
    // 月均日活用户数量：本月每天登陆过的用户数加和/本月天数
    // 日活率：月均日活用户数量/用户数量
    // 日活率环比：（本月月均日活用户数量-上月月均日活用户数量）/用户数量x100%
    // 业务单据数量：各模块数据量加和（可以分模块统计出来更好）  --  sellout 巡店 工单 打卡 门店 客户 信用申请

    // 数据模型：用于存储计算结果
    public class MetricsResult {
        public Integer totalActiveUsers; // 当前Active的用户数量
        public Integer monthlyActiveUsers; // 本月登陆过的用户去重
        public Decimal mauRate; // 月活率
        public Decimal mauGrowthRate; // 月活环比
        public Decimal avgDailyActiveUsers; // 月均日活用户数量
        public Decimal dauRate; // 日活率
        public Decimal dauGrowthRate; // 日活率环比
        public Map<String, Integer> businessRecordsCount; // 各模块业务单据数量
        public Integer totalBusinessRecords; // 业务单据总数量
    }
    
    /**
     * 计算所有指标
     */
    public static MetricsResult calculateAllMetrics(Integer month, Integer lastMonth, Integer monthlyActiveUsers, Integer lastMonthMAU) {
        MetricsResult result = new MetricsResult();
        
        // 1. 计算用户相关指标
        result.totalActiveUsers = getActiveUserCount(); //获取当前Active的用户数量
        if (result.totalActiveUsers > 0) {
            result.monthlyActiveUsers = monthlyActiveUsers; //getMonthlyActiveUserCount
            result.mauRate = calculateMAURate(result.monthlyActiveUsers, result.totalActiveUsers);

            result.mauGrowthRate = calculateGrowthRate(result.monthlyActiveUsers, lastMonthMAU, result.totalActiveUsers);
            
            result.avgDailyActiveUsers = getAverageDailyActiveUsers(month);
            result.dauRate = calculateDAURate(result.avgDailyActiveUsers, result.totalActiveUsers);
            
            Decimal lastMonthAvgDAU = getAverageDailyActiveUsers(lastMonth);
            result.dauGrowthRate = calculateGrowthRate(result.avgDailyActiveUsers, lastMonthAvgDAU, result.totalActiveUsers);
        }
        
        // 2. 计算业务单据数量
        result.businessRecordsCount = getBusinessRecordsCountByModule();
        result.totalBusinessRecords = calculateTotalBusinessRecords(result.businessRecordsCount);

        Metric_Calculator__c mc = new Metric_Calculator__c();
        mc.totalActiveUsers__c = result.totalActiveUsers;
        mc.monthlyActiveUsers__c = result.monthlyActiveUsers;
        mc.mauRate__c = result.mauRate;
        mc.mauGrowthRate__c = result.mauGrowthRate;
        mc.avgDailyActiveUsers__c = result.avgDailyActiveUsers;
        mc.dauRate__c = result.dauRate;
        mc.dauGrowthRate__c = result.dauGrowthRate;
        mc.businessRecordsCount__c = '';

        // 遍历所有键
        for (String key : result.businessRecordsCount.keySet()) {
            System.debug('模块名称: ' + key);
            mc.businessRecordsCount__c = mc.businessRecordsCount__c + '模块: ' + key + ', 数量: ' + (result.businessRecordsCount.get(key)) + ';';
        }
        
        mc.totalBusinessRecords__c = result.totalBusinessRecords;
        insert mc;
        
        return result;
    }
    
    /**
     * 获取当前Active的用户数量
     */
    private static Integer getActiveUserCount() {
        List<AggregateResult> results = [
            SELECT COUNT(Id) cnt 
            FROM User 
            WHERE IsActive = TRUE AND Profile.UserType = 'Standard'
        ];
        return results.size() > 0 ? (Integer)results[0].get('cnt') : 0;
    }
    
    /**
     * 获取本月登录过的用户数量（去重）
     */
    // private static Integer getMonthlyActiveUserCount(Integer month) {
    //     List<AggregateResult> results = [
    //         SELECT COUNT_DISTINCT(UserId) cnt 
    //         FROM LoginHistory 
    //         WHERE CALENDAR_MONTH(LoginTime ) = :month
    //     ];
    //     return results.size() > 0 ? (Integer)results[0].get('cnt') : 0;
    // }
    
    /**
     * 计算月活率
     */
    private static Decimal calculateMAURate(Integer mau, Integer totalUsers) {
        return totalUsers > 0 ? (Decimal)mau / totalUsers * 100 : 0;
    }
    
    /**
     * 计算月均日活用户数量
     */
    private static Decimal getAverageDailyActiveUsers(Integer month) {
        Date today = Date.today();
        Integer dayOfMonth = today.day(); // 直接通过日期实例调用 day() 方法
        System.debug('今天是本月的第' + dayOfMonth + '天');
        
        // 查询每日登录用户数并累加
        List<AggregateResult> results = [
            select COUNT_DISTINCT(UserId) dayTotalLogins  from LoginHistory where CALENDAR_MONTH(LoginTime ) = :month group by DAY_IN_MONTH(LoginTime)
        ];

        Integer totalLogins = 0;
        for(AggregateResult ar : results){
            totalLogins += (Integer)ar.get('dayTotalLogins');
        }
        
        return dayOfMonth > 0 ? (Decimal)totalLogins / dayOfMonth : 0;
    }
    
    /**
     * 计算日活率
     */
    private static Decimal calculateDAURate(Decimal avgDAU, Integer totalUsers) {
        return totalUsers > 0 ? avgDAU / totalUsers * 100 : 0;
    }
    
    /**
     * 计算环比增长率
     */
    private static Decimal calculateGrowthRate(Decimal current, Decimal previous, Integer totalUsers) {
        if (totalUsers == 0) return 0;
        return (current - previous) / totalUsers * 100;
    }
    
    /**
     * 按模块统计业务单据数量
     */
    private static Map<String, Integer> getBusinessRecordsCountByModule() {
        Map<String, Integer> moduleCounts = new Map<String, Integer>();
        
        // 巡店记录（假设有自定义对象StoreVisit__c）
        moduleCounts.put('巡店', getRecordCount(' Daily_Inspection_Report__c ', Date.today().year(), Date.today().month()));
        
        // 工单（使用标准对象Case）
        moduleCounts.put('工单', getRecordCount(' Ticket__c ', Date.today().year(), Date.today().month()));
        
        // 打卡记录（假设有自定义对象CheckIn__c）
        moduleCounts.put('打卡', getRecordCount(' Promoter_Attendance__c ', Date.today().year(), Date.today().month()));
        
        // 门店（假设有自定义对象Store__c）
        moduleCounts.put('门店', getRecordCount('Shop__c', Date.today().year(), Date.today().month()));
        
        // 客户（使用标准对象Account）
        moduleCounts.put('客户', getRecordCount(' Account ', Date.today().year(), Date.today().month()));
        
        // 信用申请（假设有自定义对象CreditApplication__c）
        moduleCounts.put('信用申请', getRecordCount(' Credit_Limit_Application__c ', Date.today().year(), Date.today().month()));
        
        // sellout记录（假设有自定义对象Sellout__c）
        moduleCounts.put('sellout', getRecordCount(' Retail_Number__c ', Date.today().year(), Date.today().month()));
        
        return moduleCounts;
    }
    
    /**
     * 获取指定对象的记录总数
     */
    private static Integer getRecordCount(String objectName, Integer year, Integer month) {
        try {
            String soql = 'SELECT COUNT(Id) cnt FROM ' + objectName + ' CALENDAR_YEAR(CreatedDate ) = :year and CALENDAR_MONTH(CreatedDate ) = :month';
            List<AggregateResult> results = Database.query(soql);
            return results.size() > 0 ? (Integer)results[0].get('cnt') : 0;
        } catch (Exception e) {
            System.debug('Error counting records for ' + objectName + ': ' + e.getMessage());
            return 0;
        }
    }
    
    /**
     * 计算业务单据总数量
     */
    private static Integer calculateTotalBusinessRecords(Map<String, Integer> moduleCounts) {
        Integer total = 0;
        for (Integer count : moduleCounts.values()) {
            total += count;
        }
        return total;
    }
}