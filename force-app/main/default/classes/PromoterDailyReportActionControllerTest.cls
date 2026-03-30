/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-11-2022
 * @last modified by  : ryshen@deloitte.com.cn
**/
@isTest
public class PromoterDailyReportActionControllerTest {
    public static Account acc;
    public static Shop__c shop;
    static testMethod void testPromoterDailyReportActionController(){
        String profileName = 'System Admin'; 
        Id profileId = [SELECT Id FROM profile WHERE Name = :profileName][0].Id;
        User user1 = new User(alias = 'Admin', email='test1231q1@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test1231q1@noemail.com');
        INSERT user1;

        
        acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        INSERT shop;
        system.runAs(user1){
        Id recordId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PromoterSaleData'][0].Id;
        Id recordId2 = [SELECT Id FROM RecordType WHERE DeveloperName = 'ALL_Product_Japan'][0].Id;
        

        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Shop_Name__c = shop.Id;
        rp.Principal__c = user1.Id;
        rp.RecordType__c = '促销员';
        INSERT rp; 

        WeekResearchResponse__c wrr = new WeekResearchResponse__c();
        wrr.StartDate__c = Date.newInstance(2022, 02, 21);
        wrr.EndDate__c = Date.newInstance(2022, 02, 27);
        wrr.Shop__c = shop.Id;
        INSERT wrr;

        Promoter_Daily_Report__c pdr = new Promoter_Daily_Report__c();
        pdr.PromoterDailyReport__c = wrr.Id;
        pdr.Shop__c = shop.Id;
        pdr.Report_Date__c = system.today()  + 2;
        pdr.OwnerId = user1.Id;
        INSERT pdr;

        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.OwnerId = user1.Id;
        pro.RecordTypeId = recordId2;
        INSERT pro;

        Retail_Number__c rn = new Retail_Number__c();
        rn.Shop__c = shop.Id;
        rn.PromoterDailyReport__c = pdr.Id;
        rn.Product__c = pro.Id;
        rn.Number__c = 1;
        INSERT rn;

        List<Retail_Number__c> retailSaleList = [SELECT Shop__c,PromoterDailyReport__c, Product__c FROM Retail_Number__c WHERE Shop__c =: shop.Id];
        retailSaleList.add(rn);

        List<Retail_Number__c> retailSaleList1 = [SELECT Shop__c,PromoterDailyReport__c, Product__c,Number__c FROM Retail_Number__c WHERE Shop__c =: shop.Id];
        retailSaleList1.add(rn);

        system.debug('retailSaleList'+retailSaleList);

        Week_Research__c wr = new Week_Research__c();
        wr.Promoter__c = user1.Id;
        wr.Shop__c = shop.Id;
        //wr.Start_Date__c = Date.newInstance(2022, 02, 21);
        //wr.End_Date__c = Date.newInstance(2022, 02, 27);
        wr.IsActive__c = TRUE;
        INSERT wr;

        /*
        Week_Brand_Item__c wbi = new Week_Brand_Item__c();
        wbi.Competitive_Brand__c = 'TCL';
        wbi.Week_Research__c = wr.Id;
        INSERT wbi;
            */


        Week_Question_Item__c wqi = new Week_Question_Item__c();
        wqi.Shop_Research__c = wr.Id;
        wqi.Status__c ='有效';
        wqi.Question__c = 'test';
        INSERT wqi;

        WeekResearchResponseItem__c wri = new WeekResearchResponseItem__c();
        wri.WeekResearchResponse__c = wrr.Id;
        wri.Week_Question_Item__c = wqi.Id;
        wri.Question__c = 'test question';
        wri.Response__c = 'test response';
        INSERT wri;


        PromoterDailyReportActionController.ReturnData  rd = new PromoterDailyReportActionController.ReturnData();
        rd.reportDate = System.today() ;
        rd.retailSaleList = retailSaleList;
        rd.thisDay = System.today();
        rd.shopId = shop.Id;
        rd.createdDate = Date.today();
        rd.dayOfWeek = 0;
        
        rd.researchResponseId = wri.Id;
        rd.ownerId = user1.Id;
        rd.noPerformance = true;

        PromoterDailyReportActionController.ReturnData  rd1 = new PromoterDailyReportActionController.ReturnData();
        rd1.reportDate = System.today() ;
        rd1.retailSaleList = retailSaleList;
        rd1.thisDay = System.today();
        rd1.shopId = shop.Id;
        rd1.createdDate = Date.today();
        rd1.dayOfWeek = 0;
        
        rd1.researchResponseId = wri.Id;
        rd1.ownerId = user1.Id;
        rd1.noPerformance = true;



        Promoter_Attendance__c pa = new Promoter_Attendance__c();
        pa.ExternalId__c = user1.Id + '_' + String.valueOf(rd.reportDate);
        pa.CheckInStatus__c = '已签到';
        pa.Shop__c = shop.Id;
        pa.CheckOutShop__c = shop.Id;
        pa.CheckIn_Date__c = System.today()-1;
        pa.AddCheckSignInTime__c = Time.newInstance(18, 30, 00, 00);
        pa.ApprovalStatus__c = '补签申请审批通过';
        INSERT pa;


        
        Shop_Retail_Detail__c srd = new Shop_Retail_Detail__c();
        srd.Shop__c = shop.Id;
        srd.CP_Brand__c = 'TCL';
        //srd.OwnerId = user1.Id;
        srd.DiscountPrice__c = 1111;
        srd.Point__c = '1';
        srd.PromoterDailyReport__c = pdr.Id;
        srd.RecordTypeId = recordId;
        srd.CompetitiveProduct__c = 'TCL';
        srd.Product__c = pro.Id;
        INSERT srd;

        List<Shop_Retail_Detail__c> retailDetailList = [SELECT 
                    Id,
                    Product__c,
                    Price__c,
                    DiscountPrice__c,
                    Point__c,
                    (SELECT Id, CP_Brand__c, CompetitiveProduct__c, Price__c, DiscountPrice__c, Point__c 
                    FROM ComtitiveShopRetailDetails__r)
                FROM Shop_Retail_Detail__c
                WHERE 
                PromoterDailyReport__c =: pdr.Id
                AND 
                    RecordTypeId =: recordId];
        retailDetailList.add(srd);
		rd.productPriceListJson =JSON.serialize(retailDetailList); 

        List<WeekResearchResponseItem__c> responseList = new List<WeekResearchResponseItem__c>();
        responseList.add(wri);

        List<String> deleteIdList = new List<String>();
        deleteIdList.add(wr.Id);

        Supplementary_Information__c supplementaryItem = new Supplementary_Information__c();
        supplementaryItem.Reson__c = 'test';
        supplementaryItem.Supplementary_SignIn_Time__c = Time.newInstance(18, 30, 00, 00);
        //INSERT supplementaryItem;

        test.startTest();

        PromoterDailyReportActionController.initReportInfo(pdr.Id,rd.reportDate,shop.Id,'');
        PromoterDailyReportActionController.initReportInfo(pdr.Id,null,'','');
        PromoterDailyReportActionController.initReportInfo('',null,'','');
        PromoterDailyReportActionController.saveReport(pdr.Id, shop.Id, rd.reportDate, '', retailSaleList, rd.productPriceListJson, pa, wrr.Id, responseList, deleteIdList, supplementaryItem ,false);
        PromoterDailyReportActionController.saveReport('', shop.Id, rd.reportDate, '', retailSaleList, rd.productPriceListJson, null, '', responseList, deleteIdList, supplementaryItem, false);
        PromoterDailyReportActionController.saveReport(pdr.Id, shop.Id, rd.reportDate, '', retailSaleList, rd.productPriceListJson, pa, wrr.Id, responseList, deleteIdList, supplementaryItem ,true);
        PromoterDailyReportActionController.saveReport(pdr.Id, shop.Id, rd.reportDate, '', retailSaleList1, rd.productPriceListJson, pa, wrr.Id, responseList, deleteIdList, supplementaryItem ,false);

        test.stopTest();
        
        }
    }
}