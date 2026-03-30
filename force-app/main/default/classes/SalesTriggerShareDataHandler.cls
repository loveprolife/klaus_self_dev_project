public with sharing class SalesTriggerShareDataHandler  extends TriggerHandler{
    public override void afterInsert(){
        Set<String> customerIdSet = new Set<String>();
        for(Sales__c sales: (List<Sales__c>)Trigger.new){
            customerIdSet.add(sales.Customer__c);
        }

        SalesShareService service = new SalesShareService();

        //Order__Share
        service.shareOrder([select id,Customer__c,OwnerId,
                (select id,Product_Line__c FROM Order_Products__r 
                    where Product_Line__c != null LIMIT 1) 
                FROM Order__c where Customer__c in:customerIdSet],
                (List<Sales__c>)Trigger.new);
       /* service.shareData(
            [select id,Customer__c,OwnerId,
                (select id,Product_Line__c FROM Order_Products__r 
                    where Product_Line__c != null LIMIT 1) 
                FROM Order__c where Customer__c in:customerIdSet],
            (List<Sales__c>)Trigger.new,
            customerIdSet,
            null,
            'Order__Share',
            'Customer__c',
            'Product_Line__c');*/

        //SAP_Cost_Revenue_Data__Share
        service.shareData(
            [SELECT 
                Id,Product_Line_Text__c,Product_Line__c,Customer__c,OwnerId 
                FROM SAP_Cost_Revenue_Data__c 
                WHERE Product_Line__c != null AND Customer__c in:customerIdSet],
            (List<Sales__c>)Trigger.new,
            customerIdSet,
            null,
            'SAP_Cost_Revenue_Data__Share',
            'Customer__c',
            'Product_Line__c');

        //Comparison_Sales_Report_YoY__Share
        service.shareData(
            [SELECT Id,Product_Line_Code__c,Customer__c,OwnerId 
                FROM Comparison_Sales_Report_YoY__c 
                WHERE Product_Line_Code__c != null 
                AND Customer__c  in:customerIdSet],
            (List<Sales__c>)Trigger.new,
            customerIdSet,
            null,
            'Comparison_Sales_Report_YoY__Share',
            'Customer__c',
            'Product_Line_Code__c');

        //Sales_Target__Share
        service.shareData(
            [SELECT Id, Customer_Name__c,Product_Line__c,OwnerId 
                FROM Sales_Target__c 
                WHERE Product_Line__c != null 
                AND Customer_Name__c in:customerIdSet],
            (List<Sales__c>)Trigger.new,
            customerIdSet,
            null,
            'Sales_Target__Share',
            'Customer_Name__c',
            'Product_Line__c');

        //Revenue_Statement_Report__Share
        service.shareData(
            [SELECT Id,Customer__c,Product_Line__c,OwnerId 
                FROM Revenue_Statement_Report__c 
                WHERE Product_Line__c != null 
                AND Customer__c in:customerIdSet],
            (List<Sales__c>)Trigger.new,
            customerIdSet,
            null,
            'Revenue_Statement_Report__Share',
            'Customer__c',
            'Product_Line__c');

        //Actual_And_Same_Period_Report__Share
        service.shareData(
            [SELECT Id,Customer__c,Product_Line__c,OwnerId 
                FROM Actual_And_Same_Period_Report__c 
                WHERE Customer__c in:customerIdSet],
            (List<Sales__c>)Trigger.new,
            customerIdSet,
            null,
            'Actual_And_Same_Period_Report__Share',
            'Customer__c',
            'Product_Line__c');

        Map<String,Set<String>> summaryProductLineMap = new Map<String,Set<String>>();

        for(Customer_Product_Line__c cProLine : 
                [SELECT Id,Name,Management_Customer_Branch_Company__c,
                    Product_Line_Name__c,Parent_Product_Line__c 
                  FROM Customer_Product_Line__c 
                  WHERE Management_Customer_Branch_Company__c IN:customerIdSet]) {

            String key = cProLine.Management_Customer_Branch_Company__c + cProLine.Product_Line_Name__c;
            if(summaryProductLineMap.containsKey(key)){
                summaryProductLineMap.get(key).add(cProLine.Product_Line_Name__c);
            }else{
                summaryProductLineMap.put(key,new Set<String>{cProLine.Product_Line_Name__c});
            }
        }
        //Growth_Rate_Report_Obj__Share
        service.shareData(
            [SELECT Id,Management_Customer__c,Product_Line__c,OwnerId,Year__c,Month__c 
                FROM Growth_Rate_Report_Obj__c 
                WHERE Management_Customer__c in:customerIdSet],
            (List<Sales__c>)Trigger.new,
            customerIdSet,
            summaryProductLineMap,
            'Growth_Rate_Report_Obj__Share',
            'Management_Customer__c',
            'Product_Line__c');

        //Planned_Completion_Rate_Report__Share
        service.shareData(
            [SELECT Id,Management_Customer__c,Product_Line__c,OwnerId,Year__c,Month__c 
                FROM Planned_Completion_Rate_Report__c 
                WHERE Management_Customer__c in:customerIdSet],
            (List<Sales__c>)Trigger.new,
            customerIdSet,
            summaryProductLineMap,
            'Planned_Completion_Rate_Report__Share',
            'Management_Customer__c',
            'Product_Line__c');
    }

    public override void beforeDelete(){ 

        // SalesShareService service = new SalesShareService();

        // Set<String> customerIdSet = new Set<String>();
        // Set<String> salesIds = new Set<String>();
        // Map<String, Sales__c> salesMap = new Map<String, Sales__c>();
        // List<Sales__c> salesList = ((List<Sales__c>)Trigger.old);

        // for (Sales__c sales : ((List<Sales__c>)Trigger.old)) {            
        //     customerIdSet.add(sales.Customer__c);
        //     salesIds.add(sales.Sales__c);
        //     if(String.isNotBlank(sales.Product_Line__c)){
        //         List<String> productLines = sales.Product_Line__c.split(';');
        //         for(String productLine: productLines){
        //             salesMap.put(sales.Customer__c + productLine, sales);
        //         }
        //     }
        // }

        // //数据id 与 Sales id成对
        // //根据customer 和 产品线查数据
        // Set<String> data_sales_keySet = new Set<String>();
        // Set<String> dataIds = new Set<String>();
        // List<Order__c> orderList = [select id,Customer__c,OwnerId,
        //         (select id,Product_Line__c FROM Order_Products__r 
        //             where Product_Line__c != null LIMIT 1) 
        //         FROM Order__c where Customer__c in:customerIdSet];
        // for(Order__c data: orderList){
        //     String key = data.Customer__c + data.Order_Products__r[0].Product_Line__c;
        //     if(salesMap.containsKey(key)) {
        //         dataIds.add(data.Id);
        //         Sales__c sales = salesMap.get(key);
        //         data_sales_keySet.add(data.Id +''+ sales.Sales__c);
        //     }
        // }
        // service.removeSharingDataByDataAndUserIds(data_sales_keySet,salesIds,dataIds,'Order__Share');

        // //SAP_Cost_Revenue_Data__Share
        // service.removeShare([SELECT 
        //         ID,Product_Line_Text__c,Product_Line__c,Customer__c,OwnerId 
        //         FROM SAP_Cost_Revenue_Data__c 
        //         WHERE Product_Line__c != null AND Customer__c in:customerIdSet],
        //         salesList,
        //         null,
        //         'SAP_Cost_Revenue_Data__Share',
        //         'Customer__c',
        //         'Product_Line__c');

        // //Comparison_Sales_Report_YoY__Share
        // service.removeShare([SELECT ID,Product_Line_Code__c,
        //             Customer__c,OwnerId 
        //         FROM Comparison_Sales_Report_YoY__c 
        //         WHERE Product_Line_Code__c != null 
        //         AND Customer__c  in:customerIdSet],
        //         salesList,
        //         null,
        //         'Comparison_Sales_Report_YoY__Share',
        //         'Customer__c',
        //         'Product_Line_Code__c');

        // //Sales_Target__Share
        // service.removeShare([
        //     SELECT id, Customer_Name__c,Product_Line__c,OwnerId 
        //         FROM Sales_Target__c 
        //         WHERE Product_Line__c != null 
        //         AND Customer_Name__c in:customerIdSet],
        //         salesList,
        //         null,
        //         'Sales_Target__Share',
        //         'Customer_Name__c',
        //         'Product_Line__c');

        // //Revenue_Statement_Report__Share
        // service.removeShare([SELECT Id,Customer__c,Product_Line__c,OwnerId 
        //         FROM Revenue_Statement_Report__c 
        //         WHERE Product_Line__c != null 
        //         AND Customer__c in:customerIdSet],
        //         salesList,
        //         null,
        //         'Revenue_Statement_Report__Share',
        //         'Customer__c',
        //         'Product_Line__c');

        // //Actual_And_Same_Period_Report__Share
        // service.removeShare([SELECT Id,Customer__c,Product_Line__c,OwnerId 
        //         FROM Actual_And_Same_Period_Report__c 
        //         WHERE Customer__c in:customerIdSet],
        //         salesList,
        //         null,
        //         'Actual_And_Same_Period_Report__Share',
        //         'Customer__c',
        //         'Product_Line__c');

        // Map<String,Set<String>> summaryProductLineMap = new Map<String,Set<String>>();

        // for(Customer_Product_Line__c cProLine : 
        //         [SELECT Id,Name,Management_Customer_Branch_Company__c,
        //             Product_Line_Name__c,Parent_Product_Line__c 
        //           FROM Customer_Product_Line__c 
        //           WHERE Management_Customer_Branch_Company__c IN:customerIdSet]) {

        //     String key = cProLine.Management_Customer_Branch_Company__c + cProLine.Product_Line_Name__c;
        //     if(summaryProductLineMap.containsKey(key)){
        //         summaryProductLineMap.get(key).add(cProLine.Product_Line_Name__c);
        //     }else{
        //         summaryProductLineMap.put(key,new Set<String>{cProLine.Product_Line_Name__c});
        //     }
        // }

        // //Growth_Rate_Report_Obj__Share
        // service.removeShare([SELECT ID,Management_Customer__c,Product_Line__c,OwnerId,Year__c,Month__c 
        //         FROM Growth_Rate_Report_Obj__c 
        //         WHERE Management_Customer__c in:customerIdSet],
        //         salesList,
        //         summaryProductLineMap,
        //         'Growth_Rate_Report_Obj__Share',
        //         'Management_Customer__c',
        //         'Product_Line__c');

        // //Planned_Completion_Rate_Report__Share
        // service.removeShare([SELECT ID,Management_Customer__c,Product_Line__c,OwnerId,Year__c,Month__c 
        //         FROM Planned_Completion_Rate_Report__c 
        //         WHERE Management_Customer__c in:customerIdSet],
        //         salesList,
        //         summaryProductLineMap,
        //         'Planned_Completion_Rate_Report__Share',
        //         'Management_Customer__c',
        //         'Product_Line__c');
    }

    public override void beforeUpdate(){
    }

}