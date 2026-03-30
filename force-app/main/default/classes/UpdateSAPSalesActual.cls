global class UpdateSAPSalesActual implements Database.Batchable<sObject> {
    public String query;

    global UpdateSAPSalesActual() {
        this.query = 'SELECT CurrencyIsoCode,Back_Order_Qty__c,Back_Order_Amount_BC__c,Back_Order_Amount_USD__c,ID,Order_Item_No__r.Quantity__c,Order_Item_No__r.Total_Sales_Amount__c FROM SAP_Sales_Actual__c WHERE Order_Item_No__r.Order__r.Order_Classification__c=\'V\' OR Order_Item_No__r.Order__r.Order_Classification__c=\'E\'';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<SAP_Sales_Actual__c> SAPSalesActualList) {
        for (SAP_Sales_Actual__c salesActual : SAPSalesActualList) {
            salesActual.Back_Order_Qty__c = salesActual.Order_Item_No__r.Quantity__c;
            salesActual.Back_Order_Amount_BC__c = salesActual.Order_Item_No__r.Total_Sales_Amount__c;
            if (!salesActual.CurrencyIsoCode.equals('USD')&&salesActual.Back_Order_Amount_BC__c!=null) {
                Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateMap();
                Decimal rate = currencyRateMap.get(salesActual.CurrencyIsoCode);
                salesActual.Back_Order_Amount_USD__c = salesActual.Back_Order_Amount_BC__c/rate;
            }else{
                salesActual.Back_Order_Amount_USD__c = salesActual.Back_Order_Amount_BC__c;
            }
        }
        Savepoint sp = Database.setSavepoint();
        try {
            Database.update(SAPSalesActualList);
        }
        catch (Exception e) {
            Database.rollback(sp);
            String errorMsg = e.getMessage()+e.getLineNumber();
            Utility.insertBatchLog('UpdateSAPSalesActual', errorMsg);
        }
        
    }

    global void finish(Database.BatchableContext BC) {

    }
}