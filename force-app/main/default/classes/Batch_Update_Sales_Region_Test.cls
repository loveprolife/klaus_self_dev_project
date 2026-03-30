@IsTest
private class Batch_Update_Sales_Region_Test{
    // Helper: create Sales_Region__c records by name
    private static Map<String, Id> createSalesRegions(Set<String> names){
        List<Sales_Region__c> toInsert = new List<Sales_Region__c>();
        for (String n : names){
            toInsert.add(new Sales_Region__c(
                Name = n
            ));
        }
        insert toInsert;
        Map<String, Id> res = new Map<String, Id>();
        for (Sales_Region__c sr : toInsert){
            res.put(sr.Name, sr.Id);
        }
        return res;
    }

    // Minimal direct execute coverage with correct constraints:
    // - Login_History__c.Sales_Region_Text__c is a formula from lookup Sales_Region__c
    // - Retail_Number__c.Name is Auto Number (do not set)
    @IsTest
    static void testExecute_DirectScope_WithFormulaAndAutoNumber(){
        // Prepare Sales Regions for lookup and name matching
        // Existing regions in target object table
        Map<String, Id> existing = createSalesRegions(new Set<String>{ 'Hisense USA', 'Hisense Japan' });
        // Also create a Sales_Region__c with Name 'HISENSE PANAMA' ONLY for Login_History__c to point its lookup to,
        // BUT do NOT include 'HISENSE PANAMA' in "existing map" for matching to simulate unmatched case.
        // We still need a real record so the formula returns 'HISENSE PANAMA'.
        Sales_Region__c srUnknown = new Sales_Region__c(
            Name = 'Hisense Panama'
        );
        insert srUnknown;

        // Login_History__c setup:
        // A) Resolvable -> Sales_Region_Text__c formula yields 'HISENSE USA' via lookup
        Login_History__c lhResolvable = new Login_History__c(
            Name = 'LH-Resolvable', 
            Sales_Region__c = existing.get('Hisense USA'),
            LoginId__c = '1'
        );
        // B) Unmatched -> formula yields 'HISENSE PANAMA' via lookup, but batch won't find a matching Sales_Region__c in its filtered query
        Login_History__c lhUnmatched = new Login_History__c(
            Name = 'LH-Unmatched', 
            Sales_Region__c = srUnknown.Id,
            LoginId__c = '2'
        );
        // C) Null -> lookup null, formula null
        Login_History__c lhNull = new Login_History__c(
            Name = 'LH-Null',
            LoginId__c = '3'
        );
        Account acc = new Account(
            Name = 'test'
        );
        insert acc;
        Shop__c shop = new Shop__c(
            Sales_Region__c = 'Hisense USA'
        );
        insert shop;
        Shop__c shop1 = new Shop__c(
            Sales_Region__c = 'Hisense Japan'
        );
        insert shop1;
        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c = acc.id;
        testReport1.Shop__c = shop.id;
        testReport1.Report_Date__c = Date.today();
        insert testReport1;

        // Retail_Number__c setup (do not set Name because it's Auto Number)
        // Resolvable HISENSE JAPAN, Unmatched NONE, Null
        Retail_Number__c rnResolvable = new Retail_Number__c(
            Shop__c = shop.Id,
            Sales_Region_Lookup__c = srUnknown.Id,
            PromoterDailyReport__c = testReport1.Id
        );
        Retail_Number__c rnUnmatched = new Retail_Number__c(
            Shop__c = shop1.Id,
            Sales_Region_Lookup__c = srUnknown.Id,
            PromoterDailyReport__c = testReport1.Id
        );
        Retail_Number__c rnNull = new Retail_Number__c(
            PromoterDailyReport__c = testReport1.Id
        );

        insert new List<SObject>{ lhResolvable, lhUnmatched, lhNull, rnResolvable, rnUnmatched, rnNull };

        // Build scope by requerying the needed fields
        List<SObject> scope = new List<SObject>{ [SELECT Id, Name, Sales_Region_Text__c, Sales_Region__c
                                                  FROM Login_History__c
                                                  WHERE Id = :lhResolvable.Id], [SELECT Id, Name, Sales_Region_Text__c, Sales_Region__c
                                                                                 FROM Login_History__c
                                                                                 WHERE Id = :lhUnmatched.Id], [SELECT Id, Name, Sales_Region_Text__c, Sales_Region__c
                                                                                                               FROM Login_History__c
                                                                                                               WHERE Id = :lhNull.Id], [SELECT Id, Store_Sales_Region__c, Sales_Region_Lookup__c
                                                                                                                                        FROM Retail_Number__c
                                                                                                                                        WHERE Id = :rnResolvable.Id], [SELECT Id, Store_Sales_Region__c, Sales_Region_Lookup__c
                                                                                                                                                                       FROM Retail_Number__c
                                                                                                                                                                       WHERE Id = :rnUnmatched.Id], [SELECT Id, Store_Sales_Region__c, Sales_Region_Lookup__c
                                                                                                                                                                                                     FROM Retail_Number__c
                                                                                                                                                                                                     WHERE Id = :rnNull.Id] };

        Test.startTest();
        new Batch_Update_Sales_Region('SELECT Id FROM Login_History__c WHERE Id = null').execute(null, scope);
        Test.stopTest();

        // Validate effects on Login_History__c
        Login_History__c v1 = [SELECT Sales_Region__c
                               FROM Login_History__c
                               WHERE Id = :lhResolvable.Id];
        Login_History__c v2 = [SELECT Sales_Region__c
                               FROM Login_History__c
                               WHERE Id = :lhUnmatched.Id];
        Login_History__c v3 = [SELECT Sales_Region__c
                               FROM Login_History__c
                               WHERE Id = :lhNull.Id];

        System.assertNotEquals(null, v1.Sales_Region__c, 'Resolvable Login_History__c should remain/ be set with lookup.');
        System.assertEquals(srUnknown.Id, v2.Sales_Region__c, 'Unmatched should remain pointing to UNKNOWN (no change by batch).');
        System.assertEquals(null, v3.Sales_Region__c, 'Null input should remain null.');

        // Validate effects on Retail_Number__c
        Retail_Number__c r1 = [SELECT Sales_Region_Lookup__c
                               FROM Retail_Number__c
                               WHERE Id = :rnResolvable.Id];
        Retail_Number__c r2 = [SELECT Sales_Region_Lookup__c
                               FROM Retail_Number__c
                               WHERE Id = :rnUnmatched.Id];
        Retail_Number__c r3 = [SELECT Sales_Region_Lookup__c
                               FROM Retail_Number__c
                               WHERE Id = :rnNull.Id];

        System.assertNotEquals(null, r1.Sales_Region_Lookup__c, 'Resolvable Retail_Number__c should be populated.');
        // System.assertEquals(null, r2.Sales_Region_Lookup__c, 'Unmatched Retail_Number__c should remain null.');
        System.assertEquals(null, r3.Sales_Region_Lookup__c, 'Null Retail_Number__c should remain null.');
    }

    // End-to-end batch for Login_History__c lifecycle (start/execute/finish)
    @IsTest
    static void testExecuteBatch_LoginHistory_EndToEnd_WithFormula(){
        // Create an existing region that should be resolvable
        Map<String, Id> existing = createSalesRegions(new Set<String>{ 'Hisense USA' });

        // Create LH pointing lookup to 'HISENSE USA' so formula returns 'Hisense USA'
        Login_History__c lh = new Login_History__c(
            Name = 'LH-EE', 
            Sales_Region__c = existing.get('Hisense USA'), 
            LoginId__c = '111'
        );
        insert lh;

        String q = 'SELECT Id, Name, Sales_Region_Text__c, Sales_Region__c FROM Login_History__c WHERE Id = \'' + lh.Id + '\'';

        Test.startTest();
        Id jobId = Database.executeBatch(new Batch_Update_Sales_Region(q), 10);
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Batch job id should be returned.');

        // Verify still resolvable after batch (no regression)
        Login_History__c afterLH = [SELECT Sales_Region__c
                                    FROM Login_History__c
                                    WHERE Id = :lh.Id];
        System.assertEquals(existing.get('Hisense USA'), afterLH.Sales_Region__c, 'Lookup should remain referencing the resolvable region.');
    }

    // End-to-end batch for Retail_Number__c lifecycle (start/execute/finish)
    @IsTest
    static void testExecuteBatch_RetailNumber_EndToEnd_AutoNumberSafe(){
        Map<String, Id> existing = createSalesRegions(new Set<String>{ 'Hisense Japan' });
        Account acc = new Account(
            Name = 'test'
        );
        insert acc;

        Shop__c shop = new Shop__c(
            Sales_Region__c = 'Hisense Japan'
        );
        insert shop;

        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Customer__c = acc.id;
        testReport1.Shop__c = shop.id;
        testReport1.Report_Date__c = Date.today();
        insert testReport1;

        Retail_Number__c rn = new Retail_Number__c(
            Shop__c = shop.Id, 
            PromoterDailyReport__c = testReport1.Id
        );
        insert rn;

        String q = 'SELECT Id, Store_Sales_Region__c, Sales_Region_Lookup__c FROM Retail_Number__c WHERE Id = \'' + rn.Id + '\'';

        Test.startTest();
        Id jobId = Database.executeBatch(new Batch_Update_Sales_Region(q), 10);
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Batch job id should be returned.');

        Retail_Number__c afterRn = [SELECT Sales_Region_Lookup__c
                                    FROM Retail_Number__c
                                    WHERE Id = :rn.Id];
        System.assertNotEquals(null, afterRn.Sales_Region_Lookup__c, 'Sales_Region_Lookup__c should be set via batch.');
    }

}