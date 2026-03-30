public without sharing class CLAPrintPDFController {
    
    // public CLAPrintPDFController(ApexPages.StandardController controller){}
    public Credit_Limit_Application__c creditLimitApplication{get;set;}
    public Account customer{get;set;}
    public String customerName{get;set;}

    public String competitorTrends{get;set;}
    public String hisenseClientOperatingConditions{get;set;}
    public String hisenseStrategicProgramProgress{get;set;}
    public String problemsToBeSolvedByHisense{get;set;}
    //Status_Quo_of_Industry__c
    public String StatusQuoOfIndustry{get;set;}
    public String hisenseOtherIssues{get;set;}
    //Order
    public String order{get;set;}
    public String inventory{get;set;}
    //Promotion
    public String promotion{get;set;}
    //10
    public String SKUDisplay{get;set;}
    //11 Products Recommendation
    public String productsRecommendation{get;set;}
    //12 Rebate and Support
    public String rebateAndSupport{get;set;}

    public List<String[]> hisenseList{get;set;}
    public List<String[]> customerList{get;set;}

    public Boolean showVisitDetailInfo{get;set;}

    public CLAPrintPDFController() {
        System.debug('CLAPrintPDFController starts...');

        String customerVisitId = ApexPages.CurrentPage().getParameters().get('ID');
        creditLimitApplication = [SELECT Name,Customer__c, Credit_Limit_for_Application_RAND__c, Payment_Method__c ,
        CURRENT_CREDIT_LIMITS__c, EXPECTED_THIS_YEAR_TOTAL_TURNOVER__c, MAXIMUM_TURNOVER_PER_ORDER__c,
        Export_Goods_Name__c,Latest_Shipping_Date__c, Last_3Years_Transaction_Amount_1_RAND__c,
        ORDER_PLAN__c,Buyer_English_Address__c, Buyer_Phone__c,TRADE_BACKGROUND__c,Credit_Application_Period_days__c,
        COMPANY_3_YEARS_TURNOVER__c,PROSPECTS_FOR_COOPERATION_BUSINESS__c,CreatedBy.name,Currency__c
        from Credit_Limit_Application__c  
        WHERE id=: customerVisitId LIMIT 1];
        
        if (String.isNotBlank(creditLimitApplication.Customer__c)) {
            customer = [SELECT Name FROM Account WHERE id=: creditLimitApplication.Customer__c];
            if (customer <> null) {
                customerName = customer.Name;
            } else {
                customerName = '';
            }
        } else {
            customerName = '';
        }

        ApexPages.currentPage().getHeaders().put('content-disposition', 
            '; filename=Credit Limit Application Report-' + customerName + '-' + Datetime.now().format('yyyyMMdd')+'.pdf');

        
    }
}