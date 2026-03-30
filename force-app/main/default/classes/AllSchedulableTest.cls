@isTest
private class AllSchedulableTest {
    static testMethod void testMethod1() {
        TestDataUtility.createCustomSettings();
        SchedulableContext sc;
        //����share
        OrderShareBatchSchedulable orb = new OrderShareBatchSchedulable();
        orb.execute(sc);
        //��ȡpo
        SAPGetPOOrderSchedulable1 po = new SAPGetPOOrderSchedulable1();
        po.execute(sc);
        //��ȡso
        SAPGetSalesOrderSchedulable1 so = new SAPGetSalesOrderSchedulable1();
        so.getOrder();
        //��ȡvo
        SAPGetVirtualOrderSchedulable1 vo = new SAPGetVirtualOrderSchedulable1();
        vo.execute(sc);
        //��ȡinv
        SAPGetInvoiceSchedulable1 inv = new SAPGetInvoiceSchedulable1();
        inv.getOrder();
        //��ȡdo
        SAPGetDeliveryOrderSchedulable1 dOrder = new SAPGetDeliveryOrderSchedulable1();
        dOrder.getOrder();
        //������ʷ����
        CurrencyRateHistoryBackupSchedulable crh = new CurrencyRateHistoryBackupSchedulable();
        crh.execute(sc);

        SAPGetFOBSchedulable sfob = new SAPGetFOBSchedulable();
        sfob.execute(sc);

        GetFobFromGSSSchedulable gffgs = new GetFobFromGSSSchedulable();
        gffgs.execute(sc);

    }
    static testMethod void testMethod2() {
        TestDataUtility.createCustomSettings();
        SchedulableContext sc;
        
        
        //��ȡvo
        SAPGetVirtualOrderSchedulable vo1 = new SAPGetVirtualOrderSchedulable(new List<String>{'8200'});
        vo1.execute(sc);
        //��ȡinv
        SAPGetInvoiceSchedulable inv1 = new SAPGetInvoiceSchedulable(new List<String>{'8110'},new List<String>{'ZCR1'});
        inv1.execute(sc);

        //ɾ��SAP Sales Actual
        // SAP_Sales_Actual__c sa = new SAP_Sales_Actual__c();
        // sa.Year__c = (Date.today().addDays(-1)+'').substring(0,4);
        // sa.Month__c = (Date.today().addDays(-1)+'').substring(5,7);
        // sa.Date__c = (Date.today().addDays(-1)+'').substring(8,10);
        // sa.Sales_Orgnization__c = '8110';
        // insert sa;
        SAPActualSalesDeletionBatchSchedule sap_asDeletion = new SAPActualSalesDeletionBatchSchedule(new List<String>{'8110'});
        sap_asDeletion.execute(sc);

        SAPActualSalesDelUSAOneBatchSchedule sap_asDeletionUSA = new SAPActualSalesDelUSAOneBatchSchedule(new List<String>{'8110'});
        sap_asDeletionUSA.execute(sc);
    }
    static testMethod void testMethod3() {
        TestDataUtility.createCustomSettings();
        SchedulableContext sc;
        //��ȡso
        SAPGetSalesOrderSchedulable so1 = new SAPGetSalesOrderSchedulable(new List<String>{'8110'},new List<String>{'ZCR1'});
        so1.execute(sc);

        //��ȡpo
        SAPGetPOOrderSchedulable po1 = new SAPGetPOOrderSchedulable(new List<String>{'8110'});
        po1.execute(sc);
    }
    static testMethod void testMethod4() {
        TestDataUtility.createCustomSettings();
        SchedulableContext sc;
        //��ȡdo
        SAPGetDeliveryOrderSchedulable dOrder1 = new SAPGetDeliveryOrderSchedulable(new List<String>{'8110'},new List<String>{'ZCR1'});
        dOrder1.execute(sc);
        //��ȡSAP Cost Revenue
        SAPGetRevenueCostSchedulable rcr = new SAPGetRevenueCostSchedulable(new List<String>{'8110'});
        rcr.execute(sc);
    }
    static testMethod void testMethod5() {
        SchedulableContext sc;
        //����ʵ��ͬ��
        ActualAndSamePeriodReportSchedule asp = new ActualAndSamePeriodReportSchedule();
        asp.execute(sc);
        //����ʵ��ͬ��
        RevenueCostSummarySchedule rcSummary = new RevenueCostSummarySchedule();
        rcSummary.execute(sc);
        //ɾ���ƻ�����
        DeletePlannedCompletionRateSchedule delPCC = new DeletePlannedCompletionRateSchedule();
        delPCC.execute(sc);
        AseanProductSummarySchedule apSummary = new AseanProductSummarySchedule();
        apSummary.execute(sc);
        //���ɼƻ�����
        PlannedCompletionRateReportSchedule pcc = new PlannedCompletionRateReportSchedule();
        pcc.execute(sc);
        //��ʷ����ȡƽ��ֵ
        Datetime lastMonthTime = System.now().addHours(8).addMonths(-1);//����ϵͳʱ��ΪGMT����Ҫ��8Сʱ����ɱ���ʱ��
        String year = lastMonthTime.format('yyyy');
        String month = lastMonthTime.format('MM');
        Currency_Rate_History__c rateHistory = new Currency_Rate_History__c();
        rateHistory.Name = 'Currency Rate' + System.now().format('yyyyMM');
        rateHistory.Year__c = year;
        rateHistory.Month__c = month;
        rateHistory.CurrencyIsoCode = 'MYR';
        rateHistory.Conversion_Rate__c = 1.7327;
        rateHistory.IsActive__c = TRUE;
        rateHistory.IsCorporate__c = FALSE;
        insert rateHistory;
        CurrencyRateHistoryGetAverageSchedulable crs = new CurrencyRateHistoryGetAverageSchedulable();
        crs.execute(sc);
    }

    static testMethod void testMethod6() {
        SchedulableContext sc;
       
        FreezeUserSchedulable fus = new FreezeUserSchedulable();
        fus.execute(sc);
    }

    static testMethod void testMethod7() {

        TaxCountryMapping__c tcm = new TaxCountryMapping__c();
        tcm.name = '8410';
        tcm.Country__c = 'JP';
        insert tcm;

        National_tax_category__c ntc = new National_tax_category__c();
        ntc.National_code__c = 'JP';
        ntc.sort__c = 1;
        ntc.Tax_category__c = 'UTXJ';
        insert ntc;

        Account acc1 = new Account(
            Name = 'Test sap1000000',
            SAP_Customer_Code__c = 'sap1000000',
            External_Key__c = 'sap1000000',
            Sales_Region__c = 'salesRegion',
            Approval_Status__c = 'Approved',
            isGoFinApprove__c = 'fin_approved',
            Automatic_updates__c = true,
            Hisense_Entity__c = '8410'
        );
        Database.insert(acc1);

        TestDataUtility.createCustomSettings();
    }

    static testMethod void testMethod8() {

        TaxCountryMapping__c tcm = new TaxCountryMapping__c();
        tcm.name = '8410';
        tcm.Country__c = 'JP';
        insert tcm;

        National_tax_category__c ntc = new National_tax_category__c();
        ntc.National_code__c = 'JP';
        ntc.sort__c = 1;
        ntc.Tax_category__c = 'UTXJ';
        insert ntc;

        Account acc1 = new Account(
            Name = 'Test sap1000000',
            SAP_Customer_Code__c = 'sap1000000',
            External_Key__c = 'sap1000000',
            Sales_Region__c = 'salesRegion',
            Approval_Status__c = 'Approved',
            isGoFinApprove__c = 'fin_approved',
            Automatic_updates__c = true,
            Hisense_Entity__c = '8410'
        );
        Database.insert(acc1);

        TestDataUtility.createCustomSettings();
        SchedulableContext sc;
        SAPGetCreditLimitDataSchedulable scd = new SAPGetCreditLimitDataSchedulable('8410', true);
        SAPGetCreditLimitDataSASchedulable scd1 = new SAPGetCreditLimitDataSASchedulable('8500,8510', true);
        SAPGetCreditLimitSchedulableController scl = new SAPGetCreditLimitSchedulableController(new List<Account>{acc1},'test', true, 'JP');
        scl.execute(sc);
        scd.execute(sc);
        scd1.execute(sc);
    }
}