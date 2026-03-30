global class InitCustomerOrderReportSchedulable implements Schedulable {

    public String schedulable_name;
 
    global InitCustomerOrderReportSchedulable (String schedulable_name){
        this.schedulable_name = schedulable_name;
     }
  
     global void execute(SchedulableContext SC) {
  
        // DeleteCustomerOrderReportBatch icor = new DeleteCustomerOrderReportBatch();
        // Database.executeBatch(icor,200);

        List<Customer_Order_Report__c> delList = [select id from Customer_Order_Report__c];
        Database.delete(delList);

        try {
            Integer year = System.today().year();
            //美国
            List<Customer_Order_Report__c> corList = new List<Customer_Order_Report__c>();
            List<AggregateResult> doiList = [select max(Order__r.Customer__c) Customer__c,Order__c,  
            max(Order__r.Hisense_Entity__c) Hisense_Entity__c,max(Order__r.Customer__r.Guarantor_Country_Code__c) Guarantor_Country_Code__c,
            sum(Delivery_Quantity__c) Delivery_Quantity__c,sum(Total_Amount__c) Total_Amount__c,max(Order__r.CurrencyIsoCode)  CurrencyIsoCode  
            from Delivery_Order_Item__c where Order__r.Customer__r.Guarantor_Country_Code__c = 'US'  
            and Order__r.Order_Classification__c = 'S' 
            and Order__r.Hisense_Entity__c in ('8110','8120') 
            and SAP_Product_Line__r.name in('66','67') 
            and CALENDAR_YEAR(Order__r.Order_Date__c) = :year
            group by order__c];
            setData(doiList, corList);

            //墨西哥
            List<Customer_Order_Report__c> corList1 = new List<Customer_Order_Report__c>();
            List<AggregateResult> doiList1 = [select max(Order__r.Customer__c) Customer__c,Order__c,  
            max(Order__r.Hisense_Entity__c) Hisense_Entity__c,max(Order__r.Customer__r.Guarantor_Country_Code__c) Guarantor_Country_Code__c,
            sum(Delivery_Quantity__c) Delivery_Quantity__c,sum(Total_Amount__c) Total_Amount__c,max(Order__r.CurrencyIsoCode)  CurrencyIsoCode    
            from Delivery_Order_Item__c where Order__r.Customer__r.Guarantor_Country_Code__c = 'MX'  
            and Order__r.Order_Classification__c = 'S' 
            and Order__r.Hisense_Entity__c in ('8140') 
            and SAP_Product_Line__r.name in('67') 
            and CALENDAR_YEAR(Order__r.Order_Date__c) = :year
            group by order__c];
            setData(doiList1, corList1);

            //澳大利亚
            List<Customer_Order_Report__c> corList2 = new List<Customer_Order_Report__c>();
            List<AggregateResult> doiList2 = [select max(Order__r.Customer__c) Customer__c,Order__c,  
            max(Order__r.Hisense_Entity__c) Hisense_Entity__c,max(Order__r.Customer__r.Guarantor_Country_Code__c) Guarantor_Country_Code__c,
            sum(Delivery_Quantity__c) Delivery_Quantity__c,sum(Total_Amount__c) Total_Amount__c,max(Order__r.CurrencyIsoCode)  CurrencyIsoCode    
            from Delivery_Order_Item__c where Order__r.Customer__r.Guarantor_Country_Code__c = 'AU'  
            and Order__r.Order_Classification__c = 'S' 
            and Order__r.Hisense_Entity__c in ('8200') 
            and SAP_Product_Line__r.name in('61', '66', '67') 
            and CALENDAR_YEAR(Order__r.Order_Date__c) = :year
            group by order__c];
            setData(doiList2, corList2);

            Utility.insertLog('InitCustomerOrderReportSchedulable', '1', null,  '-----' + schedulable_name);
        } catch (Exception e) {
            system.debug('error message'+e.getMessage());
            Utility.insertLog('InitCustomerOrderReportSchedulable', '0', null,  '-----' + schedulable_name);
        }

     }

     public static void setData(List<AggregateResult> doiList, List<Customer_Order_Report__c> corList){
        for(AggregateResult ar : doiList){
            Customer_Order_Report__c cor = new Customer_Order_Report__c();
            cor.order__c = String.valueOf(ar.get('Order__c'));
            cor.Customer__c = String.valueOf(ar.get('Customer__c'));
            cor.Guarantor_Country_Code__c = String.valueOf(ar.get('Guarantor_Country_Code__c'));
            cor.Hisense_Entity__c = String.valueOf(ar.get('Hisense_Entity__c'));
            cor.Shipped_Billed_Amount__c = Decimal.valueOf(String.valueOf(ar.get('Total_Amount__c')));
            cor.Shipped_Billed_Num__c = Decimal.valueOf(String.valueOf(ar.get('Delivery_Quantity__c')));
            cor.CurrencyIsoCode = String.valueOf(ar.get('CurrencyIsoCode'));
            corList.add(cor);
            
        }
        Database.insert(corList);
     }
 
 }