@isTest
public class newCompetitiveIntelligenceControllerTest {

    public static User currentUser = [SELECT Id,Name,Username,Sales_Region__c,Profile.Name FROM User WHERE Id =:UserInfo.getUserId()]; 

    @isTest
    static void testMethod1(){
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;

        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        shop1.Sales_Region__c = currentUser.Sales_Region__c;
        Insert shop1;

        Inspection_Shop_Plan__c ispTest = new Inspection_Shop_Plan__c();
        ispTest.OwnerId = currentUser.Id;
        ispTest.Status__c = 'New';
        ispTest.Inspection_Year__c = '2024';
        ispTest.Inspection_Month__c = '9';
        INSERT ispTest;

        Daily_Inspection_Report__c testDIR = new Daily_Inspection_Report__c();
        testDIR.Report_Date__c = System.today();
        testDIR.Inspection_Shop_Plan__c = ispTest.id;
        testDIR.Store__c = shop1.id;
        testDIR.OwnerId = UserInfo.getUserId();
        testDIR.Status__c = 'New';
        testDIR.NeedCheckIn__c = true;
        Insert testDIR;

        Inspection_Product_Item__c testDIRItem = new Inspection_Product_Item__c();
        testDIRItem.Inspection_Report__c = testDIR.Id;
        testDIRItem.Product_Line__c = 'TV';
        testDIRItem.Status__c = 'Start';
        Insert testDIRItem;

        Inspection_Product_Item__c testDIRItem2 = new Inspection_Product_Item__c();
        testDIRItem2.Inspection_Report__c = testDIR.Id;
        testDIRItem2.Product_Line__c = 'Refrigerator';
        testDIRItem2.Status__c = 'Start';
        Insert testDIRItem2;

        Inspection_Product_Item__c testDIRItem3 = new Inspection_Product_Item__c();
        testDIRItem3.Inspection_Report__c = testDIR.Id;
        testDIRItem3.Product_Line__c = 'Sound Bar';
        testDIRItem3.Status__c = 'Start';
        Insert testDIRItem3;

        Competitive_Intelligence__c ci = new Competitive_Intelligence__c();
        ci.Inspection_Product_Item__c = testDIRItem.id;
        ci.Competitive_Brand__c = 'Hisense';
        ci.Total_Number_Of_Competitors__c = '0';
        ci.Competition_Something__c = 'test';
        Insert ci;

        Competitive_Intelligence_Brand__c cibTotal = new Competitive_Intelligence_Brand__c();
        cibTotal.Brand__c = 'Hisense';
        cibTotal.Brand_Total__c = '10';
        cibTotal.Status__c = 'Total';
        cibTotal.Competitive_Intelligence__c = ci.id;
        Insert cibTotal;

        Competitive_Intelligence_Brand__c cibPrice = new Competitive_Intelligence_Brand__c();
        cibPrice.Brand__c = 'Hisense';
        cibPrice.Brand_Total__c = '10';
        cibPrice.Status__c = 'Price';
        cibPrice.Competitive_Intelligence__c = ci.id;
        Insert cibPrice;

        Competitive_Intelligence_Brand__c cibTotalDel = new Competitive_Intelligence_Brand__c();
        cibTotalDel.Brand__c = 'Hisense';
        cibTotalDel.Brand_Total__c = '10';
        cibTotalDel.Status__c = 'Total';
        cibTotalDel.Competitive_Intelligence__c = ci.id;
        Insert cibTotalDel;

        Competitive_Intelligence_Brand__c cibPriceDel = new Competitive_Intelligence_Brand__c();
        cibPriceDel.Brand__c = 'Hisense';
        cibPriceDel.Brand_Total__c = '10';
        cibPriceDel.Status__c = 'Price';
        cibPriceDel.Competitive_Intelligence__c = ci.id;
        Insert cibPriceDel;

        // Competitive_Intelligence_Brand__c cibModel = new Competitive_Intelligence_Brand__c();
        // cibModel.Brand__c = 'Hisense';
        // cibModel.Brand_Total__c = '10';
        // cibModel.Status__c = 'Model';
        // cibModel.Competitive_Intelligence__c = ci.id;
        // Insert cibModel;

        // Competitive_Intelligence_Brand__c cibBrand = new Competitive_Intelligence_Brand__c();
        // cibBrand.Brand__c = 'Hisense';
        // cibBrand.Brand_Total__c = '10';
        // cibBrand.Status__c = 'Brand';
        // cibBrand.Competitive_Intelligence__c = ci.id;
        // Insert cibBrand;

        String competitionIntelligenceInfoJson = JSON.serialize(ci);
        List<Competitive_Intelligence_Brand__c> totalList = new List<Competitive_Intelligence_Brand__c>();
        totalList.add(cibTotal);
        String brandNameTotalOpenInfoJson = JSON.serialize(totalList);
        List<Competitive_Intelligence_Brand__c> priceList = new List<Competitive_Intelligence_Brand__c>();
        priceList.add(cibPrice);
        String brandNamePriceOpenInfoJson = JSON.serialize(priceList);
        List<Competitive_Intelligence_Brand__c> totalDelList = new List<Competitive_Intelligence_Brand__c>();
        totalDelList.add(cibTotalDel);
        String brandNameTotalOpenDelJson = JSON.serialize(totalDelList);
        List<Competitive_Intelligence_Brand__c> priceDelList = new List<Competitive_Intelligence_Brand__c>();
        priceDelList.add(cibPriceDel);
        String brandNamePriceOpenDelJson = JSON.serialize(priceDelList);


        test.startTest();
        newCompetitiveIntelligenceController.getCompetitiveIntelligence(testDIRItem.id);
        newCompetitiveIntelligenceController.getCompetitiveIntelligence(testDIRItem2.id);

        newCompetitiveIntelligenceController.getCompetitiveIntelligenceCanada(testDIRItem.id);
        newCompetitiveIntelligenceController.getCompetitiveIntelligenceCanada(testDIRItem3.id);

        newCompetitiveIntelligenceController.saveCompetitiveIntelligence(competitionIntelligenceInfoJson, brandNameTotalOpenInfoJson, brandNamePriceOpenInfoJson, brandNameTotalOpenDelJson, brandNamePriceOpenDelJson);

        newCompetitiveIntelligenceController.saveCompetitiveIntelligenceCanada(competitionIntelligenceInfoJson, brandNameTotalOpenInfoJson, brandNamePriceOpenInfoJson);

        newCompetitiveIntelligenceController.getCompetitiveIntelligenceCheckNumber(testDIRItem.id);

        newCompetitiveIntelligenceController.getCompetitiveIntelligenceCheckCanadaNumber(testDIRItem.id);
        test.stopTest();
    }
}