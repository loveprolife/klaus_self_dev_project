/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-25-2022
 * @last modified by  : ryshen@deloitte.com.cn
**/
@isTest
public class SomeTriggerTest {
    @isTest
    static void OrderProductTriggerTest(){
        Order__c order = new Order__c();
    	INSERT order;
        Order_Product__c orderProduct = new Order_Product__c();
        orderProduct.External_Key__c = '4500004397000010';
        orderProduct.Order__c = order.Id;
        INSERT orderProduct;
        Test.startTest();
        orderProduct.External_Key__c = '4500004397000011';
        UPDATE orderProduct;
        Test.stopTest();
        
    }
    @isTest
    static void Sales_TargetTriggerTest(){
        Sales_Target__c salesTarget = new Sales_Target__c();
    	salesTarget.Hisense_Entity__c = '8510';
    	salesTarget.Year__c = '2022';
        Test.startTest();
        INSERT salesTarget;
        Test.stopTest();
        
    }
    @isTest
    static void SAPCostRevenueDataTriggerTest(){
        SAP_Cost_Revenue_Data__c costRevenueData = new SAP_Cost_Revenue_Data__c();
        costRevenueData.Year__c = '2022';
        costRevenueData.Month__c = '03';
        Test.startTest();
        INSERT costRevenueData;
        Test.stopTest();
        
    }
    @isTest
    static void ActualAndSamePeriodReportTriggerTest(){
        Actual_And_Same_Period_Report__c apr = new Actual_And_Same_Period_Report__c();
        apr.Year__c = '2022';
        apr.Month__c = '03';
        Test.startTest();
        INSERT apr;
        Test.stopTest();
        
    }
    @isTest
    static void PlannedCompletionRateReportTriggerTest(){
        Planned_Completion_Rate_Report__c ocrr = new Planned_Completion_Rate_Report__c();
        ocrr.Year__c = '2022';
        ocrr.Month__c = '03';
        Test.startTest();
        INSERT ocrr;
        Test.stopTest();
        
    }
    @isTest
    static void RevenueStatementReportTriggerTest(){
        Revenue_Statement_Report__c rsr = new Revenue_Statement_Report__c();
        rsr.Product_Line__c = 'TV';
        rsr.Year__c = '2022';
        rsr.Month__c = '3';
        Test.startTest();
        INSERT rsr;
        Test.stopTest();
        
    }
    @isTest
    static void PositionShare_One_Hour_SchedulableTest(){
        test.startTest();
        PositionShare_One_Hour_Schedulable pohs = new PositionShare_One_Hour_Schedulable();
        SchedulableContext sc;
        pohs.execute(sc);
        test.stopTest();
    }
}