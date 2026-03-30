/**
 * InspectionShopPlanSetField
 * Invocable class for Flow to query Inspection_Shop_Plan__c records by Sales Region and last three months,
 * and return the related Inspection_Shop_Task__c count per plan.
 *
 * Requirements followed:
 * - Invocable Apex callable from Flow
 * - Bulkified, no SOQL/DML in loops
 * - with sharing and USER_MODE for queries
 * - Return Early pattern and exception handling
 *
 * Input:
 *  - planSalesRegionList: List of Sales Region values
 *
 * Output:
 *  - For each Inspection_Shop_Plan__c meeting criteria, return a record with PlanId and TaskCount
 *
 * Assumptions:
 *  - Inspection_Shop_Task__c has a lookup/master-detail field Inspection_Shop_Plan__c to the plan
 *  - Inspection_Year__c is a Number/Integer year field, Inspection_Month__c is a Number/Integer month (1-12)
 */
public with sharing class InspectionShopPlanSetField {

    /**
     * Flow input wrapper
     */
    public class Request {
        @InvocableVariable(required=true label='Sales Region List' description='Sales_Region__c values to filter Inspection_Shop_Plan__c')
        public List<String> planSalesRegionList;

        @InvocableVariable(required=true label='Full Data Flag' description='是否执行全量数据标记')
        public Boolean idFullData = false;
    }

    /**
     * Flow output wrapper
     */
    public class Response {
        @InvocableVariable(label='Plan Id' description='Inspection_Shop_Plan__c Id')
        public Id planId;

        @InvocableVariable(label='Visit Target' description='Number of related Inspection_Shop_Task__c')
        public Integer visitTargetNumber;

        @InvocableVariable(label='Visit Actual' description='Number of related Inspection_Shop_Task__c By Visited')
        public Integer visitActualNumber;

        public Response(Id planId, Integer visitTargetNumber, Integer visitActualNumber) {
            this.planId = planId;
            this.visitTargetNumber = visitTargetNumber;
            this.visitActualNumber = visitActualNumber;
        }
    }

    /**
     * 供Flow调用的方法：
     * - 参数：Sales Region集合
     * - 逻辑：查询 Sales_Region__c ∈ 参数，且 Inspection_Year__c / Inspection_Month__c 在最近三个月（含本月）的 Inspection_Shop_Plan__c
     * - 结果：返回每个计划对应的 Inspection_Shop_Task__c 数量
     */
    @InvocableMethod(label='查询巡检计划任务数量' description='按Sales Region与最近三个月筛选巡检计划，并返回每个计划的任务数量')
    public static List<Response> getPlanTaskCounts(List<Request> requests) {
        // Return early on invalid input
        if (requests == null || requests.isEmpty()) {
            return new List<Response>();
        }
        List<String> regions = (requests[0] == null) ? null : requests[0].planSalesRegionList;
        if (regions == null || regions.isEmpty()) {
            return new List<Response>();
        }
        // List<String> regions = new List<String>{'Hisense Australia'};
        try {
            // Compute last three (year, month) pairs including current month
            Set<String> years = new Set<String>();
            Set<String> months = new Set<String>();

            Date today = Date.today();
            // current month and previous two months
            for (Integer i = 0; i < 3; i++) {
                Date d = today.addMonths(-i);
                Integer y = d.year();
                Integer m = d.month();
                years.add(y + '');
                months.add(m + '');
            }

            // Query plans filtered by Sales Region and candidate year/month ranges first
            // Note: year and month IN filters reduce rows; exact month/year match enforced in code via key set.
            List<Inspection_Shop_Plan__c> plans;
            if(requests[0].idFullData){
                plans = [
                    SELECT Id, Sales_Region__c, Inspection_Year__c, Inspection_Month__c
                    FROM Inspection_Shop_Plan__c
                    WHERE Sales_Region__c IN :regions
                ];
            }else {
                plans = [
                    SELECT Id, Sales_Region__c, Inspection_Year__c, Inspection_Month__c
                    FROM Inspection_Shop_Plan__c
                    WHERE Sales_Region__c IN :regions
                    AND Inspection_Year__c IN :years
                    AND Inspection_Month__c IN :months
                ];
            }
            

            if (plans.isEmpty()) {
                return new List<Response>();
            }

            // Further filter plans to exact last three months by constructing yyyy-mm key
            Map<Id, Inspection_Shop_Plan__c> planMap = new Map<Id, Inspection_Shop_Plan__c>();
            for (Inspection_Shop_Plan__c p : plans) {
                planMap.put(p.Id, p);
            }

            if (planMap.isEmpty()) {
                return new List<Response>();
            }

            // Aggregate query to count tasks per plan
            // Assuming child object/field API name: Inspection_Shop_Task__c.Inspection_Shop_Plan__c
            List<AggregateResult> grouped = [
                SELECT Inspection_Plan__c planId, COUNT(Id) cnt
                FROM Inspection_Shop_Task__c
                WHERE Inspection_Plan__c IN :planMap.keySet()
                GROUP BY Inspection_Plan__c
            ];
            List<AggregateResult> groupedVisited = [
                SELECT Inspection_Plan__c planId, COUNT(Id) cnt
                FROM Inspection_Shop_Task__c
                WHERE Inspection_Plan__c IN :planMap.keySet()
                AND Status__c != '未到访'
                GROUP BY Inspection_Plan__c
            ];

            // Build count map
            Map<Id, Integer> countByPlan = new Map<Id, Integer>();
            for (AggregateResult ar : grouped) {
                Id pid = (Id) ar.get('planId');
                Integer c = (Integer) ar.get('cnt');
                countByPlan.put(pid, c);
            }

            Map<Id, Integer> countByPlanVisited = new Map<Id, Integer>();
            for (AggregateResult ar : groupedVisited) {
                Id pid = (Id) ar.get('planId');
                Integer c = (Integer) ar.get('cnt');
                countByPlanVisited.put(pid, c);
            }

            // Build response. Include all qualifying plans; zero if no tasks.
            List<Response> out = new List<Response>();
            for (Id pid : planMap.keySet()) {
                out.add(new Response(pid, countByPlan.containsKey(pid) ? countByPlan.get(pid) : 0, countByPlanVisited.containsKey(pid) ? countByPlanVisited.get(pid) : 0));
                planMap.get(pid).Visit_Target__c = countByPlan.containsKey(pid) ? countByPlan.get(pid) : null;
                planMap.get(pid).Visit_Actual__c = countByPlanVisited.containsKey(pid) ? countByPlanVisited.get(pid) : null;
            }
            //忽略触发器更新
            GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'InspectionShopPlanSetField');
            Database.update(planMap.values());
            //恢复触发器
            Utility.IgnoreAction(false,false,false,'');
            return out;
        } catch (Exception e) {
            // Surface a safe error back to Flow by throwing; no System.debug in prod per rules.
            // You could also choose to return empty on error, but throwing is clearer to the Flow admin.
            throw new AuraHandledException('查询巡检计划任务数量时发生错误: ' + e.getMessage());
        }
    }
}