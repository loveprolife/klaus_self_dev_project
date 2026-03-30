/**************************************************************************************************
 * Name:InitCustomerOrderReportBatch
 * Purpose: 初始化CustomerOrderReport
 * Author:   
***************************************************************************************************/
global class InitCustomerOrderReportBatch implements Database.Batchable<sObject> {
    public String query;
    public Integer currentYear = Date.today().year();
    
    global InitCustomerOrderReportBatch() {
        this.query = 'select Order__c ' +  
                     'from Delivery_Order_Item__c where Order__r.Customer__r.Guarantor_Country_Code__c = \'US\' ' + 
                     'and Order__r.Order_Classification__c = \'S\' ' +
                     'and SAP_Product_Line__r.name in(\'66\',\'67\') ' +
                     'and CALENDAR_YEAR(Order__r.Order_Date__c) = :currentYear';


                    //  this.query = 'select Order__r.Customer__c,Order__c, ' + 
                    //  'Delivery_Quantity__c,Total_Amount__c ' +   
                    //  'from Delivery_Order_Item__c where Order__r.Customer__r.Guarantor_Country_Code__c = \'US\' ' + 
                    //  'and Order__r.Order_Classification__c = \'S\' ' +
                    //  'and SAP_Product_Line__r.name in(\'66\',\'67\') ' +
                    //  'and CALENDAR_YEAR(Order__r.Order_Date__c) = :currentYear';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Delivery_Order_Item__c> doiList) {


        List<Customer_Order_Report__c> corList = new List<Customer_Order_Report__c>();
        Set<String> checkSet = new Set<String>();
        for(Delivery_Order_Item__c doi : doiList){
            checkSet.add(doi.Order__c);
        }

        for(String orderId : checkSet){
            List<AggregateResult> arList = [select max(Order__r.Customer__c) Customer__c, Order__c,
            sum(Delivery_Quantity__c) Delivery_Quantity__c,sum(Total_Amount__c) Total_Amount__c 
            from Delivery_Order_Item__c where Order__c = :orderId and SAP_Product_Line__r.name in('66','67') group by order__c limit 1];

            AggregateResult ar = arList.get(0);
            Customer_Order_Report__c cor = new Customer_Order_Report__c();
            cor.order__c = String.valueOf(ar.get('Order__c'));
            cor.Customer__c = String.valueOf(ar.get('Customer__c'));
            cor.Shipped_Billed_Amount__c = Decimal.valueOf(String.valueOf(ar.get('Total_Amount__c')));
            cor.Shipped_Billed_Num__c = Decimal.valueOf(String.valueOf(ar.get('Delivery_Quantity__c')));
            corList.add(cor);
        }

        Database.insert(corList);
    }

    global void finish(Database.BatchableContext BC) {}
}