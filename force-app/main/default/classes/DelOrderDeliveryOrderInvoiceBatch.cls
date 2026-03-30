/**************************************************************************************************
 * Name:DelOrderDeliveryOrderInvoiceBatch
 * Purpose: 删除订单及关联的交货单 发票信息
 * Author: WFC
 * Create Date: 2022-03-29
 * 执行: Database.executeBatch(new DelOrderDeliveryOrderInvoiceBatch('2020-01-01','2020-12-31',new List<String>{'8110','8200'}),200);
***************************************************************************************************/
global class DelOrderDeliveryOrderInvoiceBatch implements Database.Batchable<sObject> {
    
    public Date startDate;
    public Date endDate;
    public List<String> hisenseEntity;
    public String query;

    global DelOrderDeliveryOrderInvoiceBatch (String startDate, String endDate, List<String> hisenseEntity) {
        this.startDate = Date.valueOf(startDate);
        this.endDate = Date.valueOf(endDate);
        this.hisenseEntity = hisenseEntity;
        this.query = 'SELECT Id FROM Order__c' + 
                     ' WHERE Order_Date__c >= :startDate AND Order_Date__c <= :endDate AND Hisense_Entity__c in :hisenseEntity';
    
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Order__c> orderList) {
        // 订单id
        List<Id> orderIdList = new List<Id>();
        // 交货单行
        List<Delivery_Order_Item__c> deliveryOrderItemList = new List<Delivery_Order_Item__c>();
        // 发票行
        List<Invoice_Item__c> invoiceItemList = new List<Invoice_Item__c>();
        // 交货单
        List<Delivery_Order__c> deliveryOrderList = new List<Delivery_Order__c>();
        // 发票
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        // 交货单Id MAP 去重
        Map<String, String> deliveryOrderMap = new Map<String, String>();
        // 发票Id MAP 去重
        Map<String, String> invoiceMap = new Map<String, String>();

        for(Order__c order : orderList){
            orderIdList.add(order.id);
        }
        // 订单对应的交货单行和发票行
        deliveryOrderItemList = [SELECT id,Delivery_Order__c FROM Delivery_Order_Item__c WHERE Order__c IN :orderIdList];
        invoiceItemList = [SELECT id,Invoice__c FROM Invoice_Item__c WHERE Sales_Order__c IN :orderIdList];

        for(Delivery_Order_Item__c deliveryOrder : deliveryOrderItemList){
            if(!deliveryOrderMap.containsKey(deliveryOrder.Delivery_Order__c) && String.isNotBlank(deliveryOrder.Delivery_Order__c)){
                deliveryOrderList.add(new Delivery_Order__c(id = deliveryOrder.Delivery_Order__c));
                deliveryOrderMap.put(deliveryOrder.Delivery_Order__c, deliveryOrder.Delivery_Order__c);
            }
        }

        for(Invoice_Item__c invoiceItem : invoiceItemList){
            if(!invoiceMap.containsKey(invoiceItem.Invoice__c) && String.isNotBlank(invoiceItem.Invoice__c)){
                invoiceList.add(new Invoice__c(id = invoiceItem.Invoice__c));
                invoiceMap.put(invoiceItem.Invoice__c, invoiceItem.Invoice__c);
            }
            
        }

        Database.delete(invoiceItemList);
        Database.delete(invoiceList);
        Database.delete(deliveryOrderItemList);
        Database.delete(deliveryOrderList);
        Database.delete(orderList);
    }

    global void finish(Database.BatchableContext BC) {
        

    }
}