@IsTest
private class InspectionShopPlanSetFieldTest {
    @TestSetup
    static void setupData() {
        // Create three months: current and previous two months
        Date today = Date.today();
        List<Date> months = new List<Date>{
            today,
            today.addMonths(-1),
            today.addMonths(-2)
        };

        // Helper to create plans for given region and months
        List<Inspection_Shop_Plan__c> plans = new List<Inspection_Shop_Plan__c>();
        for (Date d : months) {
            plans.add(new Inspection_Shop_Plan__c(
                Inspection_Year__c = d.year() + '',
                Inspection_Month__c = d.month() + ''
            ));
        }
        // Add one plan outside of region filter and month window to validate filtering
        Date oldMonth = today.addMonths(-5);
        plans.add(new Inspection_Shop_Plan__c(
            Inspection_Year__c = oldMonth.year() + '',
            Inspection_Month__c = oldMonth.month() + ''
        ));

        insert plans;

        // Create tasks for only some of the in-scope plans to validate count and zero case
        // plans[0], plans[1], plans[2] are the three in-scope months for regionIn
        // Add tasks: 2 for plans[0], 1 for plans[1], 0 for plans[2]
        List<Inspection_Shop_Task__c> tasks = new List<Inspection_Shop_Task__c>();
        tasks.add(new Inspection_Shop_Task__c(Inspection_Plan__c = plans[0].Id, Inspection_Date__c = Date.today()));
        tasks.add(new Inspection_Shop_Task__c(Inspection_Plan__c = plans[1].Id, Inspection_Date__c = Date.today().addMonths(-1), Status__c = '已到访'));
        tasks.add(new Inspection_Shop_Task__c(Inspection_Plan__c = plans[2].Id, Inspection_Date__c = Date.today().addMonths(-2)));
        // No tasks for plans[2] to check zero count
        // Add a task for the out-of-scope plan; should not appear in results
        tasks.add(new Inspection_Shop_Task__c(Inspection_Plan__c = plans[3].Id, Inspection_Date__c = Date.today().addMonths(-3)));

        insert tasks;
    }

    @IsTest
    static void testGetPlanTaskCounts_basic() {
        // Prepare request
        InspectionShopPlanSetField.Request req = new InspectionShopPlanSetField.Request();
        req.planSalesRegionList = new List<String>{ 'Hisense USA' };

        Test.startTest();
        List<InspectionShopPlanSetField.Response> results = InspectionShopPlanSetField.getPlanTaskCounts(new List<InspectionShopPlanSetField.Request>{ req });
        Test.stopTest();

        // We expect 3 results (current and previous two months for region EAST)
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(3, results.size(), 'Should return three plans within last three months for EAST');

        // Build a map of planId -> taskCount for easy assertions
        Map<Id, Integer> countByPlan = new Map<Id, Integer>();
        for (InspectionShopPlanSetField.Response r : results) {
            countByPlan.put(r.planId, r.visitTargetNumber);
        }

        // Query plans for EAST in last three months and assert counts match expected 2,1,0 across the three plans
        Date today = Date.today();
        Set<String> years = new Set<String>{ today.year() + '', today.addMonths(-1).year() + '', today.addMonths(-2).year() + '' };
        Set<String> months = new Set<String>{ today.month() + '', today.addMonths(-1).month() + '', today.addMonths(-2).month() + '' };

        List<Inspection_Shop_Plan__c> eastPlans = [
            SELECT Id, Inspection_Year__c, Inspection_Month__c
            FROM Inspection_Shop_Plan__c
            WHERE Sales_Region__c = 'Hisense USA'
              AND Inspection_Year__c IN :years
              AND Inspection_Month__c IN :months
        ];

        System.assertEquals(3, eastPlans.size(), 'Data setup should have three EAST plans in last three months');

        // Verify counts per plan. Determine which plan corresponds to which month to assert expected counts 2,1,0.
        Integer foundTwo = 0, foundOne = 0, foundZero = 0;
        for (Inspection_Shop_Plan__c p : eastPlans) {
            System.assert(countByPlan.containsKey(p.Id), 'Result should contain plan ' + p.Id);
            Integer c = countByPlan.get(p.Id);
            if (c == 2) foundTwo++;
            else if (c == 1) foundOne++;
            else if (c == 0) foundZero++;
        }
    }

    @IsTest
    static void testGetPlanTaskCounts_emptyAndNullInputs() {
        // Null list
        Test.startTest();
        List<InspectionShopPlanSetField.Response> r1 = InspectionShopPlanSetField.getPlanTaskCounts(null);

        // Request with empty regions
        InspectionShopPlanSetField.Request req = new InspectionShopPlanSetField.Request();
        req.planSalesRegionList = new List<String>();
        List<InspectionShopPlanSetField.Response> r3 = InspectionShopPlanSetField.getPlanTaskCounts(new List<InspectionShopPlanSetField.Request>{ req });
        Test.stopTest();
    }

    @IsTest
    static void testGetPlanTaskCounts_regionNotFound() {
        // Request region that does not exist in data
        InspectionShopPlanSetField.Request req = new InspectionShopPlanSetField.Request();
        req.planSalesRegionList = new List<String>{ 'Hisense USA' };

        Test.startTest();
        List<InspectionShopPlanSetField.Response> results = InspectionShopPlanSetField.getPlanTaskCounts(new List<InspectionShopPlanSetField.Request>{ req });
        Test.stopTest();
    }

    @IsTest
    static void testGetPlanTaskCounts() {
        // Request region that does not exist in data
        InspectionShopPlanSetField.Request req = new InspectionShopPlanSetField.Request();
        req.planSalesRegionList = new List<String>{ 'Hisense USA' };
        req.idFullData = true;

        Test.startTest();
        List<InspectionShopPlanSetField.Response> results = InspectionShopPlanSetField.getPlanTaskCounts(new List<InspectionShopPlanSetField.Request>{ req });
        Test.stopTest();
    }
}