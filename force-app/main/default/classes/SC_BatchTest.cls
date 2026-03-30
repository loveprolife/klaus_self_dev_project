@isTest
private class SC_BatchTest {
    @TestSetUp
    static void setup(){

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];

        List<User> users = new List<User>();
        User owner = new User(
            Alias = 'admin', Email='systemadmin2@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='systemadmin2@hisensetest.com',IsActive=true
        );

        User shareUser = new User(
            Alias = 'share', Email='share@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales share', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='share@hisensetest.com',IsActive=true
        );

        users.add(owner);
        users.add(shareUser);
        Database.insert(users);

        TaxCountryMapping__c tcm = new TaxCountryMapping__c();
        tcm.name = '8110';
        tcm.Country__c = 'US';
        insert tcm;

        National_tax_category__c ntc = new National_tax_category__c();
        ntc.National_code__c = 'US';
        ntc.sort__c = 1;
        ntc.Tax_category__c = 'UTXJ';
        insert ntc;

        Account acc1 = new Account(
            Name = 'TestAccount 1',
            SAP_Customer_Code__c = '0000504263',
            External_Key__c = '0000504263',
            Sales_Region__c = 'Hisense USA',
            Hisense_Entity__c = '8110'
        );
        Database.insert(acc1);
        // ID acc1.Id = TestDataUtility.createAccount('TestAccount 1', '0000504263', '0000504263','Hisense USA');
        Customer_Product_Line__c customerProductLine = new Customer_Product_Line__c();
        customerProductLine.Product_Line_Name__c = 'TV';
        customerProductLine.Customer__c = acc1.Id;
        customerProductLine.Management_Customer__c = acc1.Id;
        customerProductLine.Management_Customer_Branch_Company__c = acc1.Id;
        customerProductLine.Classification__c = 'Customer of Oversea Company';
        Database.insert(customerProductLine);

        TestDataUtility.createCustomerModelProduct('H359BI-WD', null,null);
        TestDataUtility.createCustomerModelProduct('H359BI-WD1', 'Hisense USA','TV');
        //Cooking用出口型号
        TestDataUtility.createProduct('65M7000UWG');
        //电视  手机用工厂型号
        TestDataUtility.createProduct('HA65M7000UWTG');
        //冰冷洗用工厂型号建relation
        TestDataUtility.createProductRelation('HA65M7000UWTG');

        //添加产品线
        TestDataUtility.insertMapping('62','Refrigerator');
        TestDataUtility.insertMapping('65', 'Cooking');
        TestDataUtility.insertMapping('14', 'TV');

        Mapping__c mpp = new Mapping__c();
        mpp.Name = '8010';
        mpp.Mapping_Code__c = '8010';
        mpp.RecordTypeId =  Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('Business Orgnization and Name Mapping').getRecordTypeId();
        Database.insert(mpp);

        Mapping__c mpp1 = new Mapping__c();
        mpp1.Name = '0104';
        mpp1.Mapping_Code__c = 'TV';
        mpp1.RecordTypeId =  Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('Business Scope and Product Line Mapping').getRecordTypeId();
        Database.insert(mpp1);

        Order__c order = new Order__c(
            Customer__c = acc1.Id,
            SAP_Order_No__c = '4500004397',
            External_Key__c = '45000043970000504263'
        );
        Database.insert(order);

        Order_Product__c orderProduct = new Order_Product__c();
        orderProduct.Order__c = order.Id;
        orderProduct.External_Key__c = '4500004397000010';
        orderProduct.SAP_Product_Line__c = mpp1.Id;
        Database.insert(orderProduct);
        Delivery_Order__c deliveryOrder = new Delivery_Order__c();
        deliveryOrder.Customer__c = acc1.Id;
        deliveryOrder.SAP_Delivery_Order_No__c = '0080002649';
        Database.insert(deliveryOrder);
        Delivery_Order_Item__c doi = new Delivery_Order_Item__c();
        doi.Delivery_Order__c = deliveryOrder.Id;
        doi.External_Key__c = '0080002649000010';
        doi.Order_Product__c = orderProduct.Id;
        Database.insert(doi);

        Invoice__c inv = new Invoice__c();
        inv.Customer__c = acc1.Id;
        inv.Invoice_Posting_Date__c = Date.newInstance(2019, 1, 15);
        insert inv;
        Invoice_Item__c invItem = new Invoice_Item__c();
        invItem.Invoice__c = inv.Id;
        invItem.SAP_Product_Line__c = mpp1.Id;
        invItem.Sales_Order_Item__c = orderProduct.Id;
        insert invItem;

        Invoice__c inv2 = new Invoice__c();
        inv2.Customer__c = acc1.Id;
        inv2.Invoice_Posting_Date__c = Date.newInstance(2019, 2, 14);
        insert inv2;
        Invoice_Item__c invItem2 = new Invoice_Item__c();
        invItem2.Invoice__c = inv.Id;
        invItem2.SAP_Product_Line__c = mpp1.Id;
        invItem2.Sales_Order_Item__c = orderProduct.Id;
        insert invItem2;

        Sales_Target_Branch_Company_Use__c salesTarget1 = new Sales_Target_Branch_Company_Use__c();
        salesTarget1.Customer_Name__c = acc1.Id;
        salesTarget1.Product_Line__c = 'TV';
        salesTarget1.Year__c = '2019';
        //Database.insert(salesTarget1);

        Planned_Completion_Rate_Report__c pcrr = new Planned_Completion_Rate_Report__c(
            Management_Customer__c = acc1.Id,
            Product_Line__c = 'TV',
            Year__c = '2019',
            Month__c = '01',
            CurrencyIsoCode = 'USD'
        );
        Planned_Completion_Rate_Report__c pcrr2 = new Planned_Completion_Rate_Report__c(
            Management_Customer__c = acc1.Id,
            Product_Line__c = 'TV',
            Year__c = '2019',
            Month__c = '02',
            CurrencyIsoCode = 'USD'
        );
        Planned_Completion_Rate_Report__c pcrr3 = new Planned_Completion_Rate_Report__c(
            Management_Customer__c = acc1.Id,
            Product_Line__c = 'TV',
            Year__c = '2019',
            Month__c = '03',
            CurrencyIsoCode = 'USD'
        );

        List<Planned_Completion_Rate_Report__c> pcrrs = new List<Planned_Completion_Rate_Report__c>();
        pcrrs.add(pcrr);
        pcrrs.add(pcrr2);
        pcrrs.add(pcrr3);
        insert pcrrs;

        SAP_Cost_Revenue_Data__c costRevenueData = new SAP_Cost_Revenue_Data__c();
        costRevenueData.Year__c = '2019';
        costRevenueData.Month__c = '01';
        costRevenueData.CurrencyIsoCode = 'USD';
        costRevenueData.Company_Code__c = mpp.Id;
        costRevenueData.Business_Scope__c = mpp1.Id;
        costRevenueData.Customer_Product_Line__c = customerProductLine.Id;
        costRevenueData.Customer__c = acc1.Id;
        costRevenueData.Sales_Volume__c = 10;
        costRevenueData.Sales_Revenue__c = 10;
        costRevenueData.Sales_Revenue_USD__c = 10;
        costRevenueData.Sales_Gross_Revenue__c = 10;
        costRevenueData.Sales_Gross_Revenue_USD__c = 10;
        Database.insert(costRevenueData);

        SAP_Cost_Revenue_Data__c costRevenueData1 = new SAP_Cost_Revenue_Data__c();
        costRevenueData1.Year__c = '2019';
        costRevenueData1.Month__c = '02';
        costRevenueData1.CurrencyIsoCode = 'USD';
        costRevenueData1.Company_Code__c = mpp.Id;
        costRevenueData1.Business_Scope__c = mpp1.Id;
        costRevenueData1.Customer_Product_Line__c = customerProductLine.Id;
        costRevenueData1.Customer__c = acc1.Id;
        costRevenueData1.Sales_Volume__c = 10;
        costRevenueData1.Sales_Revenue__c = 10;
        costRevenueData1.Sales_Revenue_USD__c = 10;
        costRevenueData1.Sales_Gross_Revenue__c = 10;
        costRevenueData1.Sales_Gross_Revenue_USD__c = 10;
        Database.insert(costRevenueData1);

        Comparison_Sales_Report_YoY__c csr1 = new Comparison_Sales_Report_YoY__c();
        csr1.Customer__c = acc1.Id;
        csr1.Product_Line_Code__c = 'TV';
        csr1.Year__c = System.now().format('yyyy');
        csr1.Month__c = System.now().month() + '';
        Database.insert(csr1);

        Sales_Target__c st = new Sales_Target__c();
        st.Customer_Name__c = acc1.Id;
        st.Product_Line__c= 'TV';
        st.Year__c= '2019';
        database.insert(st);

        Revenue_Statement_Report__c srsr = new Revenue_Statement_Report__c();
        srsr.Customer__c = acc1.Id;
        srsr.Product_Line__c= 'TV';
        srsr.Year__c= '2019';
        database.insert(srsr);

        Actual_And_Same_Period_Report__c aapr = new Actual_And_Same_Period_Report__c();
        aapr.Customer__c = acc1.Id;
        aapr.Customer_Product_Line__c = customerProductLine.Id;
        aapr.Year__c = '2019';
        aapr.Month__c = '01';
        Database.insert(aapr);

        Growth_Rate_Report_Obj__c grro = new Growth_Rate_Report_Obj__c();
        grro.Management_Customer__c = acc1.Id;
        grro.Product_Line__c = 'TV';
        grro.Year__c = '2019';
        grro.Month__c = '01';
        Database.insert(grro);
    }

    static testMethod void testOneOwnerOneShare() {
        
        Account acc1 = [select Id from Account where External_Key__c='0000504263' limit 1];
        User owner = [select Id from User where Email='systemadmin2@hisensetest.com' limit 1];
        User shareUser = [select Id from User where Email='share@hisensetest.com' limit 1];

        ID accId = acc1.Id;
        Map<Id,SAP_Cost_Revenue_Data__c> scrMap = new Map<Id, SAP_Cost_Revenue_Data__c>(
                [SELECT 
                ID,Product_Line_Text__c,Product_Line__c,Customer__c,OwnerId 
                FROM SAP_Cost_Revenue_Data__c 
                WHERE Product_Line__c ='TV' AND Customer__c = :accId]);
        System.assertEquals(2, scrMap.size());

        Map<Id,Planned_Completion_Rate_Report__c> pesMap = new Map<Id, Planned_Completion_Rate_Report__c>(
                [SELECT 
                    Id,Management_Customer__c,Product_Line__c,OwnerId,Year__c,Month__c
                    FROM Planned_Completion_Rate_Report__c 
                    WHERE Product_Line__c ='TV' AND Management_Customer__c = :accId]);
        System.assertEquals(3, pesMap.size());

        List<Sales__c> sales = new List<Sales__c>();
        Sales__c sales1 = new Sales__c();
        sales1.Customer__c = acc1.Id;
        sales1.Product_Line__c = 'TV';
        sales1.Sales__c = owner.Id;
        sales1.IsKeyUser__c = true;
        sales.add(sales1);

        Sales__c sales2 = new Sales__c();
        sales2.Customer__c = acc1.Id;
        sales2.Product_Line__c = 'TV';
        sales2.Sales__c = shareUser.Id;
        sales2.IsKeyUser__c = false;
        sales.add(sales2);

        Database.insert(sales);

        Test.StartTest();

        SC_OrderShareBatch batch = new SC_OrderShareBatch();
        ID bid = Database.executeBatch(batch);

        Test.StopTest();

        //========================校验数据===============================
        Order__c order_fromDb = [SELECT Id, OwnerId FROM Order__c 
            WHERE External_Key__c = '45000043970000504263' limit 1];
        System.assertEquals(order_fromDb.OwnerId, owner.Id);

        List<Order__Share> os = [SELECT ID FROM Order__Share 
            WHERE ParentId =:order_fromDb.Id 
            AND UserOrGroupId =:shareUser.Id
            AND RowCause = 'Manual' ];
        System.assertEquals(1, os.size());

        List<SAP_Cost_Revenue_Data__Share> scrses = [SELECT ID,ParentId,UserOrGroupId,RowCause 
            FROM SAP_Cost_Revenue_Data__Share 
            WHERE UserOrGroupId =:shareUser.Id
            AND RowCause = 'Manual' 
            ];
        
        System.assertEquals(2, scrses.size());

        List<Planned_Completion_Rate_Report__Share> pes = [SELECT ID,ParentId,UserOrGroupId,RowCause 
            FROM Planned_Completion_Rate_Report__Share 
            WHERE UserOrGroupId =:shareUser.Id
            AND RowCause = 'Manual' 
        ];
        System.debug('=====================');
        //System.debug(Json.serialize(pesMap));
        System.debug(Json.serialize(pes));
        System.debug(shareUser.Id);
        System.debug(owner.Id);
        System.assertEquals(3, pes.size());

        List<Comparison_Sales_Report_YoY__Share> csres = [SELECT ID,ParentId,UserOrGroupId,RowCause 
            FROM Comparison_Sales_Report_YoY__Share 
            WHERE UserOrGroupId =:shareUser.Id
            AND RowCause = 'Manual' 
        ];
        System.debug(Json.serialize(csres));
        System.assertEquals(1, csres.size());

        List<Sales_Target__Share> stes = [SELECT ID,ParentId,UserOrGroupId,RowCause 
            FROM Sales_Target__Share 
            WHERE UserOrGroupId =:shareUser.Id
            AND RowCause = 'Manual' 
        ];
        System.assertEquals(1, stes.size());

        List<Revenue_Statement_Report__Share> rsrses = [SELECT ID,ParentId,UserOrGroupId,RowCause 
            FROM Revenue_Statement_Report__Share 
            WHERE UserOrGroupId =:shareUser.Id
            AND RowCause = 'Manual' 
        ];
        System.assertEquals(1, rsrses.size());

        List<Actual_And_Same_Period_Report__Share> aaspres = [SELECT ID,ParentId,UserOrGroupId,RowCause 
            FROM Actual_And_Same_Period_Report__Share 
            WHERE UserOrGroupId =:shareUser.Id
            AND RowCause = 'Manual' 
        ];
        System.assertEquals(1, aaspres.size());

        List<Growth_Rate_Report_Obj__Share> grroes = [SELECT ID,ParentId,UserOrGroupId,RowCause 
            FROM Growth_Rate_Report_Obj__Share 
            WHERE UserOrGroupId =:shareUser.Id
            AND RowCause = 'Manual' 
        ];
        System.assertEquals(1, grroes.size());
    }

    static testMethod void testOneShare() {
        
        Account acc1 = [select Id from Account where External_Key__c='0000504263' limit 1];
        
        User shareUser = [select Id from User where Email='share@hisensetest.com' limit 1];

        ID accId = acc1.Id;
        Map<Id,SAP_Cost_Revenue_Data__c> scrMap = new Map<Id, SAP_Cost_Revenue_Data__c>(
                [SELECT 
                ID,Product_Line_Text__c,Product_Line__c,Customer__c,OwnerId 
                FROM SAP_Cost_Revenue_Data__c 
                WHERE Product_Line__c ='TV' AND Customer__c = :accId]);
        System.assertEquals(2, scrMap.size());

        Map<Id,Planned_Completion_Rate_Report__c> pesMap = new Map<Id, Planned_Completion_Rate_Report__c>(
                [SELECT 
                    Id,Management_Customer__c,Product_Line__c,OwnerId,Year__c,Month__c
                    FROM Planned_Completion_Rate_Report__c 
                    WHERE Product_Line__c ='TV' AND Management_Customer__c = :accId]);
        System.assertEquals(3, pesMap.size());

        List<Sales__c> sales = new List<Sales__c>();

        Sales__c sales2 = new Sales__c();
        sales2.Customer__c = accId;
        sales2.Product_Line__c = 'TV';
        sales2.Sales__c = shareUser.Id;
        sales2.IsKeyUser__c = false;
        sales.add(sales2);

        Database.insert(sales);

        Test.startTest();

        SC_OrderShareBatch batch = new SC_OrderShareBatch();
        ID bid = Database.executeBatch(batch);

        Test.stopTest();

        //========================校验数据===============================

        Order__c order_fromDb = [SELECT Id, OwnerId FROM Order__c 
            WHERE External_Key__c = '45000043970000504263' limit 1];
        System.assertEquals(order_fromDb.OwnerId, shareUser.Id);

        List<Order__Share> os = [SELECT ID FROM Order__Share 
            WHERE ParentId =:order_fromDb.Id 
            AND UserOrGroupId =:shareUser.Id
            AND RowCause = 'Owner' ];
        System.assertEquals(1, os.size());

        List<SAP_Cost_Revenue_Data__Share> scrses = [SELECT ID,ParentId,UserOrGroupId,RowCause 
            FROM SAP_Cost_Revenue_Data__Share 
            WHERE ParentId in :scrMap.keySet()
            AND UserOrGroupId =:shareUser.Id
            AND RowCause = 'Owner' 
            ];
        
        System.assertEquals(2, scrses.size());

        List<Planned_Completion_Rate_Report__Share> pes = [SELECT ID,ParentId,UserOrGroupId,RowCause 
            FROM Planned_Completion_Rate_Report__Share 
            WHERE ParentId in :pesMap.keySet()
            AND UserOrGroupId =:shareUser.Id
            AND RowCause = 'Owner' 
        ];
        System.assertEquals(3, pes.size());

        List<Comparison_Sales_Report_YoY__Share> csres = [SELECT ID,ParentId,UserOrGroupId,RowCause 
            FROM Comparison_Sales_Report_YoY__Share 
            WHERE UserOrGroupId =:shareUser.Id
            AND RowCause = 'Owner' 
        ];
        System.assertEquals(1, csres.size());

        List<Sales_Target__Share> stes = [SELECT ID,ParentId,UserOrGroupId,RowCause 
            FROM Sales_Target__Share 
            WHERE UserOrGroupId =:shareUser.Id
            AND RowCause = 'Owner' 
        ];
        System.assertEquals(1, stes.size());

        List<Revenue_Statement_Report__Share> rsrses = [SELECT ID,ParentId,UserOrGroupId,RowCause 
            FROM Revenue_Statement_Report__Share 
            WHERE UserOrGroupId =:shareUser.Id
            AND RowCause = 'Owner' 
        ];
        System.assertEquals(1, rsrses.size());

        List<Actual_And_Same_Period_Report__Share> aaspres = [SELECT ID,ParentId,UserOrGroupId,RowCause 
            FROM Actual_And_Same_Period_Report__Share 
            WHERE UserOrGroupId =:shareUser.Id
            AND RowCause = 'Owner' 
        ];
        System.assertEquals(1, aaspres.size());

        List<Growth_Rate_Report_Obj__Share> grroes = [SELECT ID,ParentId,UserOrGroupId,RowCause 
            FROM Growth_Rate_Report_Obj__Share 
            WHERE UserOrGroupId =:shareUser.Id
            AND RowCause = 'Owner' 
        ];
        System.assertEquals(1, grroes.size());
        
    }

    static testMethod void testDelete() {
        
        Account acc1 = [select Id from Account where External_Key__c='0000504263' limit 1];
        User owner = [select Id from User where Email='systemadmin2@hisensetest.com' limit 1];
        User shareUser = [select Id from User where Email='share@hisensetest.com' limit 1];

        ID accId = acc1.Id;
        Map<Id,SAP_Cost_Revenue_Data__c> scrMap = new Map<Id, SAP_Cost_Revenue_Data__c>(
                [SELECT 
                ID,Product_Line_Text__c,Product_Line__c,Customer__c,OwnerId 
                FROM SAP_Cost_Revenue_Data__c 
                WHERE Product_Line__c ='TV' AND Customer__c = :accId]);
        System.assertEquals(2, scrMap.size());

        Map<Id,Planned_Completion_Rate_Report__c> pesMap = new Map<Id, Planned_Completion_Rate_Report__c>(
                [SELECT 
                    Id,Management_Customer__c,Product_Line__c,OwnerId,Year__c,Month__c
                    FROM Planned_Completion_Rate_Report__c 
                    WHERE Product_Line__c ='TV' AND Management_Customer__c = :accId]);
        System.assertEquals(3, pesMap.size());

        List<Sales__c> sales = new List<Sales__c>();
        Sales__c sales1 = new Sales__c();
        sales1.Customer__c = accId;
        sales1.Product_Line__c = 'TV';
        sales1.Sales__c = owner.Id;
        sales1.IsKeyUser__c = true;
        sales.add(sales1);

        Sales__c sales2 = new Sales__c();
        sales2.Customer__c = accId;
        sales2.Product_Line__c = 'TV';
        sales2.Sales__c = shareUser.Id;
        sales2.IsKeyUser__c = false;
        sales.add(sales2);

        Database.insert(sales);

        Database.delete(sales[1]);

        Test.StartTest();
        SC_OrderShareBatch batch = new SC_OrderShareBatch();
        ID bid = Database.executeBatch(batch);

        Test.StopTest();
    }

    static testMethod void testSchedule(){
        String cron = '0 0 * * * ?';
        Test.StartTest();
        
        String jobId = System.schedule('test', cron, new SC_ShareSchedule());

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
            FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cron, ct.CronExpression);
        Test.StopTest();
    }
}