/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@IsTest
public class Share_Common_IntegrationBatchTest {
    @IsTest
    static void Share_Common_IntegrationBatchTestExecute() {
        Share_Object__c shareObject1 = new Share_Object__c(Name = '出样检查',
                                        Object_API__c = 'Sampling_Inspection__c',
                                        Object_Share__c = 'Sampling_Inspection__Share',
										Shop_Filed_API__c = 'Shop__c',
                                        Share_Chunk__c = 'Share_Chunk__c'
        );
        INSERT shareObject1;
        Share_Object__c shareObject2 = new Share_Object__c(Name = '巡店任务',
                                        Object_API__c = 'Inspection_Shop_Task__c',
                                        Object_Share__c = 'Inspection_Shop_Task__Share',
										Shop_Filed_API__c = 'Shop__c',
                                        Share_Chunk__c = 'Share_Chunk__c'                 
                                        
        );
        INSERT shareObject2;
        Share_Object__c shareObject3 = new Share_Object__c(Name = '促销员日报',
                                        Object_API__c = 'Promoter_Daily_Report__c',
                                        Object_Share__c = 'Promoter_Daily_Report__Share',
										Shop_Filed_API__c = 'Shop__c',
                                        Share_Chunk__c = 'Share_Chunk__c'
        );
        INSERT shareObject3;
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
        Account acc2 = new Account();
        acc2.Name = 'Edion';
        INSERT acc2;
        Account acc3 = new Account();
        acc3.Name = 'test3';
        INSERT acc3;

        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.City__c = '北京市';
        INSERT shop;
        
        Sampling_Inspection__c si = new Sampling_Inspection__c();
        // si.IsNew__c = true;
        si.ExternalID__c = acc.Id;
        
        INSERT si;
        
        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        // ist.IsNew__c = true;
        ist.ExternalID__c = acc2.Id;
        INSERT ist;
        
        Promoter_Daily_Report__c pdr = new Promoter_Daily_Report__c();
        // pdr.IsNew__c = true;
        pdr.ExternalID__c = acc3.Id;
        pdr.shop__c = shop.Id;
        INSERT pdr;
        List<Sobject> scope = new List<Sobject>();
        scope.add(shareObject1);
        scope.add(shareObject2);
        scope.add(shareObject3);
        Test.startTest();
		//促销员日报
        Share_Common_IntegrationBatch promoterDailyReportBatch = new Share_Common_IntegrationBatch(
            'Promoter_Daily_Report__c', 
            true, 
            'NatificationPlanSchedulable',
            20,
            ''
        );
        Database.executeBatch(promoterDailyReportBatch, 20);

        Share_Common_IntegrationBatch promoterDailyReportBatch1 = new Share_Common_IntegrationBatch(
            'Promoter_Daily_Report__c', 
            false, 
            '',
            0,
            '',
            true
        );
        Database.executeBatch(promoterDailyReportBatch1, 20);

        // //出样检查
        // Share_Common_IntegrationBatch samplingInspectionBatch = new Share_Common_IntegrationBatch(
        //     'Sampling_Inspection__c', 
        //     true, 
        //     'PositionShare_Half_Hour_Schedulable',
        //     40,
        //     ''
        // );
        // Database.executeBatch(samplingInspectionBatch, 20);
            
        // Share_Common_IntegrationBatch inspectionShopTaskBatch = new Share_Common_IntegrationBatch(
        //     'Inspection_Shop_Task__c', 
        //     true, 
        //     'PositionShare_Half_Hour_Schedulable',
        //     60,
        //     ''
        // );
        // Database.executeBatch(inspectionShopTaskBatch, 20);
        
        Test.stopTest();
    }
}