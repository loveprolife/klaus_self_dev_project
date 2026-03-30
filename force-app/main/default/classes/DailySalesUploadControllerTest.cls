@isTest
public class DailySalesUploadControllerTest {

    @isTest
    static void testMethod1(){
        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '区域经理', email='DailySalesUploadControllerTest@noemail.com',
        emailencodingkey='UTF-8', lastname='DailySalesUploadControllerTest', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,Department='总部',
        timezonesidkey='America/Los_Angeles', username='DailySalesUploadControllerTest@noemail.com',Sales_Region__c='Hisense South Africa');
        INSERT user1;

        Product__c productTest = new Product__c();
        productTest.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        productTest.Name = 'NTC-33K';
        productTest.CurrencyIsoCode = 'USD';
        productTest.Product_External_Id__c = 'DELOITTE';
        productTest.Sales_Region__c = 'Hisense South Africa';
        Insert productTest;

        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.SAP_Customer_Code__c = '0101010101';
        acc.Sales_Region__c = 'Hisense South Africa';
        Insert acc;

        //shop
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'shop1';
        shop1.City__c = '北京市';    
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        shop1.Sales_Region__c = 'Hisense South Africa';
        Insert shop1;

        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(8, 30, 0, 0);
        testPAR.End_time__c = Time.newInstance(18, 30, 0, 0);
        testPAR.Name = 'testPAR';
        Insert testPAR;

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Shop_Name__c = shop1.Id;
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '促销员';
        rp.Promoter_Attendance_Rule__c = testPAR.Id;
        INSERT rp; 

        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Shop__c = shop1.id;
        testReport1.Report_Date__c = Date.valueOf('2023-09-01');
        Insert testReport1;
        // System.runAs(user1) {
            Blob b = Blob.valueOf('Date,Store,Store Code,Product,Price,Quantities\r\n'
                                    + '2023-09-01,shop1,00001,NTC-33K,2,3\r\n'
                                    + '2023-09-02,shop1,00001,NTC-33K,2,3\r\n'
                                    + '2023-09-03,shop1,00001,NTC-33K,2,3\r\n'
            );

            String s = EncodingUtil.base64Encode(b);
            DailySalesUploadController.saveFile('Test2.csv',  s);

            Blob bb = Blob.valueOf('Date,Store,Store Code,Product,Price,Quantities\r\n'
                                    + '2023-09-04,shop1,00001,NTC-33kK,2,3\r\n'
            );

            String ss = EncodingUtil.base64Encode(bb);
            DailySalesUploadController.saveFile('Test3.csv',  ss);

            Blob bbb = Blob.valueOf('Sales Region,Year,Month,Task Type,User,Product Line,Store Code,Value\r\n'
                                    + 'Hisense South Africa,2023,9,1,DailySalesUploadControllerTest@noemail.com,AC,00001,3\r\n'
                                    + 'Hisense South Africa,2023,9,2,DailySalesUploadControllerTest@noemail.com,AC,,3\r\n'
                                    + 'Hisense South Africa,2023,9,3,DailySalesUploadControllerTest@noemail.com,AC,,3\r\n'
                                    + 'Hisense South Africa,2023,9,4,DailySalesUploadControllerTest@noemail.com,AC,,3\r\n'
                                    + 'Hisense South Africa,2023,9,5,DailySalesUploadControllerTest@noemail.com,AC,00001,3\r\n'
                                    + 'Hisense South Africa,2023,9,5,DailySalesUploadControllerTest@noemail.com,AC,,3\r\n'
            );

            String sss = EncodingUtil.base64Encode(bbb);
            DailySalesUploadController.saveFileStoreInspectionManage('Test2.csv',  sss);

            Blob bbbb = Blob.valueOf('Store Code,Store,Product Line,Product,number\r\n'
                                    + '00001,shop1,TV,50A6H,20\r\n'
            );

            String ssss = EncodingUtil.base64Encode(bbbb);
            ShopDistributorInventoryController.saveFile(shop1.id, 'Test2.csv',  ssss);

            Blob b1 = Blob.valueOf('Customer Code,Customer Name,Product,number\r\n'
                                    + '0101010101,acc1,50A6H,20\r\n'
            );

            String s1 = EncodingUtil.base64Encode(b1);
            DailySalesUploadController.saveFileInventory('Test4.csv',  s1);

            Blob b2 = Blob.valueOf('TYPE,YEAR,MONTH,DATE,SHOPCODE,SHOPNAME,PRODUCTLINE,PRODUCT,PERSON,NUMBER\r\n'
                                    + 'Day,,,2023/11/1,00001,Teststore,TV,NTC-33K,DailySalesUploadControllerTest@noemail.com,20\r\n'
            );

            String s2 = EncodingUtil.base64Encode(b2);
            DailySalesUploadController.saveFileTargets('Test5.csv',  s2);

            String str = '[{"Date1":"2023-01-01","CustomerCode":"02020202","StoreCode":"1234","Product":"NTC-33K","Price":6,"Quantities":2},{"Date1":"2023-01-01","CustomerCode":"02020202","StoreCode":"12345","Product":"NTC-33K","Price":6,"Quantities":2}]';
            DailySalesUploadController.parsesExcelFiles('Test5.csv', str,  s2);

            String str1 = '[{"Date1":"2023-01-01","CustomerCode":"02020202","StoreCode":"1234","Product":"NTC-33Kk","Price":6,"Quantities":2},{"Date1":"2023-01-01","CustomerCode":"02020202","StoreCode":"12345","Product":"NTC-33K","Price":6,"Quantities":2}]';
            DailySalesUploadController.parsesExcelFiles('Test5.csv', str1,  s2);

            Blob bct = Blob.valueOf('TYPE,YEAR,MONTH,DATE,SHOPCODE,SHOPNAME,PRODUCTLINE,PRODUCT,PERSON,NUMBER,SAP Customer Code,Customer Name,Currency\r\n'
                                    + 'Customer Target,,,2024/1/18,,,,,,20,0101010101,4,USD\r\n'
            );

            Blob bct2 = Blob.valueOf('TYPE,YEAR,MONTH,DATE,SHOPCODE,SHOPNAME,PRODUCTLINE,PRODUCT,PERSON,NUMBER,SAP Customer Code,Customer Name,Currency\r\n'
                                    + 'Customer Target,,,,,,,,,,,,USD\r\n'
            );

            // Account acc1 = new Account();
            // acc1.SAP_Customer_Code__c = '0000503568';
            // acc1.Name = 'testCustomer';
            // insert acc1;

            String sct = EncodingUtil.base64Encode(bct);
            DailySalesUploadController.saveFilesCustomerTargets('TestCustomer.csv',  sct);
            String sct2 = EncodingUtil.base64Encode(bct2);
            DailySalesUploadController.saveFilesCustomerTargets('TestCustomer.csv',  sct2);
        // }
    }

    @isTest
    static void testMethod2(){

        String profileName = '巡店员'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id; 
        User user1 = new User(alias = '区域经理', email='DailySalesUploadControllerTest@noemail.com',
        emailencodingkey='UTF-8', lastname='DailySalesUploadControllerTest', languagelocalekey='en_US',
        localesidkey='en_US',profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='DailySalesUploadControllerTest@noemail.com',Sales_Region__c='Hisense South Africa');
        INSERT user1;

        Product__c productTest = new Product__c();
        productTest.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        productTest.Name = 'NTC-33K';
        productTest.CurrencyIsoCode = 'USD';
        productTest.Product_External_Id__c = 'DELOITTE';
        productTest.Sales_Region__c = 'Hisense South Africa';
        Insert productTest;

        //account
        Account acc = new Account();
        acc.Name = 'test';
        acc.SAP_Customer_Code__c = '0101010101';
        acc.Sales_Region__c = 'Hisense South Africa';
        Insert acc;

        //shop
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = 'shop1';
        shop1.City__c = '北京市';    
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        shop1.Sales_Region__c = 'Hisense South Africa';
        Insert shop1;

        Promoter_Attendance_Rule__c testPAR = new Promoter_Attendance_Rule__c();
        testPAR.Start_time__c = Time.newInstance(8, 30, 0, 0);
        testPAR.End_time__c = Time.newInstance(18, 30, 0, 0);
        testPAR.Name = 'testPAR';
        Insert testPAR;

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Shop_Name__c = shop1.Id;
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '促销员';
        rp.Promoter_Attendance_Rule__c = testPAR.Id;
        INSERT rp; 

        Promoter_Daily_Report__c testReport1 = New Promoter_Daily_Report__c();
        testReport1.Shop__c = shop1.id;
        testReport1.Report_Date__c = Date.valueOf('2023-09-01');
        Insert testReport1;

        Customer_Management__c cm = new Customer_Management__c();
            cm.Name = 'YAMADA';
            cm.Management_Name__c = 'YAMADA';
            Insert cm;

            Sampling_Target__c target = new Sampling_Target__c();
            target.Product_Line__c = 'TV';
            target.SBU__c = '日本';
            target.Region__c = '日本';
            target.Channel__c = 'YAMADA';
            target.Targeted_Sample_Numbers_Jan__c = 23;
            target.Actual_Sample_Qty__c = '23';
            Insert target;

            Sampling_Condition__c condition = new Sampling_Condition__c();
            condition.Product_Line__c = 'TV';
            condition.SBU__c = '日本';
            condition.Region__c = '日本';
            condition.Channel__c = 'YAMADA';
            condition.USD__c = 'YAMADA';
            condition.Date__c = Date.valueOf('2024-01-01');
            condition.Actual_Sample_Qty__c = '23';
            Insert condition;

            Block_Dimension__c bd = new Block_Dimension__c();
            bd.Name = '日本';
            bd.SBU_Code__c = '01';
            Insert bd;

            Channel_item__c channelItem  = new Channel_item__c();
            channelItem.Channel_Name__c = 'YAMADA';
            insert channelItem;

            Blob channel = Blob.valueOf('Product Line,Region,SBU,Country,Channel Name,Channel Code,Market Share,Annual Business Revenue (Unit: 10k USD),Cooperating Status,Planned Cooperating Time,Cooperating Method,Cooperating  Customer Entity Name,Cooperating  Customer SAP code,Hisense Value Share,Number of Stores,Number of Entered Stores,Number of New Store Entering Plan 2024\r\n'
                                        +'Product Line,Region,SBU,Country,Channel Name,Channel Code,Market Share,Annual Business Revenue (Unit: 10k USD),Cooperating Status,Planned Cooperating Time,Cooperating Method,Cooperating  Customer Entity Name,Cooperating  Customer SAP code,Hisense Value Share,Number of Stores,Number of Entered Stores,Number of New Store Entering Plan 2024\r\n'
                                        +'Product Line,Region,SBU,Country,Channel Name,Channel Code,Market Share,Annual Business Revenue (Unit: 10k USD),Cooperating Status,Planned Cooperating Time,Cooperating Method,Cooperating  Customer Entity Name,Cooperating  Customer SAP code,Hisense Value Share,Number of Stores,Number of Entered Stores,Number of New Store Entering Plan 2024\r\n'
                                        +'电视,日本,日本,日本,YAMADA,26%,10000,已合作,1,2024-05,品牌直营,KS,222,222,998,2222,12,2024');
            Blob channelCo = Blob.valueOf('Product Line,Region,SBU,Country,Channel Name,Channel Code,Market Share,Annual Business Revenue (Unit: 10k USD),Cooperating Status,Planned Cooperating Time,Cooperating Method,Cooperating  Customer Entity Name,Cooperating  Customer SAP code,Hisense Value Share,Number of Stores,Number of Entered Stores,Number of New Store Entering Plan 2024\r\n'
                                        +'Product Line,Region,SBU,Country,Channel Name,Channel Code,Market Share,Annual Business Revenue (Unit: 10k USD),Cooperating Status,Planned Cooperating Time,Cooperating Method,Cooperating  Customer Entity Name,Cooperating  Customer SAP code,Hisense Value Share,Number of Stores,Number of Entered Stores,Number of New Store Entering Plan 2024\r\n'
                                        +'Product Line,Region,SBU,Country,Channel Name,Channel Code,Market Share,Annual Business Revenue (Unit: 10k USD),Cooperating Status,Planned Cooperating Time,Cooperating Method,Cooperating  Customer Entity Name,Cooperating  Customer SAP code,Hisense Value Share,Number of Stores,Number of Entered Stores,Number of New Store Entering Plan 2024\r\n'
                                        +'电视,日本,日本,日本,YAMADA,26%,10328,未合作,,2024-07,,KS,222,222,998,2222,12,2024');
            Blob channelError = Blob.valueOf('Product Line,,SBU,Country,Channel Name,Channel Code,Market Share,Annual Business Revenue (Unit: 10k USD),Cooperating Status,Planned Cooperating Time,Cooperating Method,Cooperating  Customer Entity Name,Cooperating  Customer SAP code,Hisense Value Share,Number of Stores,Number of Entered Stores,Number of New Store Entering Plan 2024\r\n'
                                        +'Product Line,,SBU,Country,Channel Name,Channel Code,Market Share,Annual Business Revenue (Unit: 10k USD),Cooperating Status,Planned Cooperating Time,Cooperating Method,Cooperating  Customer Entity Name,Cooperating  Customer SAP code,Hisense Value Share,Number of Stores,Number of Entered Stores,Number of New Store Entering Plan 2024\r\n'
                                        +'Product Line,,SBU,Country,Channel Name,Channel Code,Market Share,Annual Business Revenue (Unit: 10k USD),Cooperating Status,Planned Cooperating Time,Cooperating Method,Cooperating  Customer Entity Name,Cooperating  Customer SAP code,Hisense Value Share,Number of Stores,Number of Entered Stores,Number of New Store Entering Plan 2024\r\n'
                                        +',,,,,,,,,,,,,,,,,');
            Blob channelError1 = Blob.valueOf('Product Line,,SBU,Country,Channel Name,Channel Code,Market Share,Annual Business Revenue (Unit: 10k USD),Cooperating Status,Planned Cooperating Time,Cooperating Method,Cooperating  Customer Entity Name,Cooperating  Customer SAP code,Hisense Value Share,Number of Stores,Number of Entered Stores,Number of New Store Entering Plan 2024\r\n'
                                        +'Product Line,SBU,,Country,Channel Name,Channel Code,Market Share,Annual Business Revenue (Unit: 10k USD),Cooperating Status,Planned Cooperating Time,Cooperating Method,Cooperating  Customer Entity Name,Cooperating  Customer SAP code,Hisense Value Share,Number of Stores,Number of Entered Stores,Number of New Store Entering Plan 2024\r\n'
                                        +'Product Line,SBU,,Country,Channel Name,Channel Code,Market Share,Annual Business Revenue (Unit: 10k USD),Cooperating Status,Planned Cooperating Time,Cooperating Method,Cooperating  Customer Entity Name,Cooperating  Customer SAP code,Hisense Value Share,Number of Stores,Number of Entered Stores,Number of New Store Entering Plan 2024\r\n'
                                        +',,,,,,,,,,,,,,,,,2024');
            String channel1 = EncodingUtil.base64Encode(channel);
            DailySalesUploadController.saveFilesChannel('TestChannel.csv', channel1);
            String channel2 = EncodingUtil.base64Encode(channelError);
            DailySalesUploadController.saveFilesChannel('TestChannel.csv', channel2);
            String channel3 = EncodingUtil.base64Encode(channelError1);
            DailySalesUploadController.saveFilesChannel('TestChannel.csv', channel3);
            String channel4 = EncodingUtil.base64Encode(channelCo);
            DailySalesUploadController.saveFilesChannel('TestChannel.csv', channel4);

            Blob samplingCondition = Blob.valueOf('cn,cn,cn,SF00001,TV,111,001,500-1000,1,已完成,20\r\n'
                                                + 'cn,cn,COSTCO,SF00001,TV,111,001,500-1000,1,已完成,20');
            String samplingCondition1 = EncodingUtil.base64Encode(samplingCondition);
            DailySalesUploadController.saveFilesSamplingCondition('TestSamplingCondition.csv', samplingCondition1, '2024-03');
            Blob samplingConditionError = Blob.valueOf('Region,SBU,Channel,Channel code,Product line,Brand,Platform Model,USD,,出样状态,Actual Sample Qty\r\n'
                                                +',,,,,,,,,,1');
            String samplingCondition2 = EncodingUtil.base64Encode(samplingConditionError);
            DailySalesUploadController.saveFilesSamplingCondition('TestSamplingCondition.csv', samplingCondition2, '2024-03');
            
            Blob samplingTarget = Blob.valueOf('cn,cn,cn,TV,111,001,500-1000,已完成,20,30,40,2,3,3,4,5,6,7,8,9,10,11,12\r\n'
                                            + 'cn,cn,cn,TV,111,001,500-1000,已完成,20,30,40,2,3,3,4,5,6,7,8,9,10,11,12\r\n'
                                            + 'cn,cn,cn,TV,111,001,500-1000,已完成,20,30,40,2,3,3,4,5,6,7,8,9,10,11,12');
            String samplingTarget1 = EncodingUtil.base64Encode(samplingTarget);
            DailySalesUploadController.saveFilesSamplingTarget('TestSamplingTarget.csv', samplingTarget1);
            Blob samplingTargetError = Blob.valueOf('cn,cn,cn,TV,111,001,500-1000,已完成,20,30,40,2,3,3,4,5,6,7,8,9,10,11,12\r\n'
                                            + 'cn,cn,cn,TV,111,001,500-1000,已完成,20,30,40,2,3,3,4,5,6,7,8,9,10,11,12\r\n'
                                            + ',,,,,,,,,,,,,,,,,,,,,,1');
            String samplingTarget2 = EncodingUtil.base64Encode(samplingTargetError);
            DailySalesUploadController.saveFilesSamplingTarget('TestSamplingTarget.csv', samplingTarget2);
            new ExportController();
    }

    @isTest
    static void testMethod3(){
        Blob samplingCondition = Blob.valueOf('1,2,3,4,5,6,7,8\r\n'
                                                +'2024,4,jiayisi@hisense.com.invalid,t,,10,,10');
        String samplingCondition1 = EncodingUtil.base64Encode(samplingCondition);
        DailySalesUploadController.saveFilesTraining('Test.csv', samplingCondition1);

        Blob promoterCost = Blob.valueOf('1,2,3,4,5,6,7,8\r\n'
                                                +'2024,4,jiayisi@hisense.com.invalid,t,,10,,10');
        String promoterCost1 = EncodingUtil.base64Encode(promoterCost);
        DailySalesUploadController.saveFilesPromoterCost('Test.csv', promoterCost1,'202401');

        Blob promoterRevenue = Blob.valueOf('1,2,3,4,5,6,7,8\r\n'
                                                +'2024,4,jiayisi@hisense.com.invalid,t,,10,,10');
        String promoterRevenue1 = EncodingUtil.base64Encode(promoterRevenue);
        DailySalesUploadController.saveFilesPromoterRevenue('Test.csv', promoterRevenue1);
        
        
    }
}