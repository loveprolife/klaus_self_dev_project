/**********************************************************************
* Name: OrderShareBatch1
* Object: Order__c 
* Purpose: 
* Order 美国share权限
* Create Date: 2020-06-12
*************************************************************************/
global class OrderShareBatch1 implements Database.Batchable<sObject> {
    public String query;
    public String Manual;
    public String OwnerId1;
    public String OwnerId2;
    public String OwnerId3;
    public String HisenseEntity;
    public Set<String> ownerIdSet;

    global OrderShareBatch1(String HisenseEntity, Set<String> ownerIdSet) {
        this.Manual = 'Manual';
        // this.OwnerId1 = '0050o00000X2d4OAAR';
        // this.OwnerId2 = '0050o00000VK8f1AAD';
        // this.OwnerId3 = '0050o00000XQeznAAD';
        this.ownerIdSet = ownerIdSet;
        this.HisenseEntity = HisenseEntity;
        this.query = 'select id,Customer__c,OwnerId,(select id,Product_Line__c from Order_Products__r where Product_Line__c != null LIMIT 1) from Order__c where Customer__c!=null '+ 
                     ' and Hisense_Entity__c = :HisenseEntity and OwnerId in:ownerIdSet';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Order__c> orderList) {
        Set<Id> cusIdSet = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();

        for (Order__c orderData : orderList) {
            orderIdSet.add(orderData.Id);
            cusIdSet.add(orderData.Customer__c);
        }

        List<Sales__c> salesList = [SELECT id, Customer__c, Sales__c, Sales__r.IsActive,IsKeyUser__c, Product_Line__c FROM Sales__c WHERE Customer__c IN : cusIdSet AND Sales__r.IsActive = TRUE];
        Map<String, List<Sales__c>> salesMap = new Map<String, List<Sales__c>>();
        for (Sales__c salesData : salesList) {
            if(salesMap.containsKey(salesData.Customer__c)){
                salesMap.get(salesData.Customer__c).add(salesData);
            }else{
                salesMap.put(salesData.Customer__c,new List<Sales__c>{salesData});
            }
        }


        List<Order__Share> insertOrderShareList = new List<Order__Share>();
        // List<Order__Share> existOrderShareList =[SELECT ParentId,UserOrGroupId FROM Order__Share WHERE ParentId IN :orderIdSet];
        // Map<String,Set<String>> accessUserMap = new Map<String,Set<String>>();

        // for(Order__Share salesTargetShareData : existOrderShareList){
        //     if(accessUserMap.containsKey(salesTargetShareData.ParentId)){
        //         accessUserMap.get(salesTargetShareData.ParentId).add(salesTargetShareData.UserOrGroupId);
        //     }else{
        //         accessUserMap.put(salesTargetShareData.ParentId, new Set<String>{salesTargetShareData.UserOrGroupId});
        //     }
        // }

        //设置Share
        Map<String, Order__Share> insertOrderMap = new Map<String, Order__Share>();
        List<Order__c> updateOrderList = new List<Order__c>();//需要更新记录所有的订单集合
        for (Order__c orderData : orderList) {
            
            Boolean flag = false;
            List<Sales__c> salescList = salesMap.get(orderData.Customer__c);
            List<Sales__c> productLineSalesList = new List<Sales__c>();
            if (salescList == null) {
                continue;
            }
            //取Order Product 上的 productLine
            List<Order_Product__c> orderProductList = orderData.Order_Products__r;
            if (orderProductList.size() == 0) {
                continue;
            }
            Order_Product__c orderProductData = orderProductList[0];
            
            for (Sales__c salesme : salescList) {
                // if (orderData.OwnerId != salesme.Sales__c) {
                //     if(accessUserMap.containsKey(orderData.Id) && accessUserMap.get(orderData.Id).contains(salesme.Sales__c)){
                //         continue;
                //     }
                // }
                
                if (Utility.isExistProductLine(salesme.Product_Line__c,orderProductData.Product_Line__c)) {
                    //设置owner则不设置share
                    Order__Share orderShareData = new Order__Share();
                    orderShareData.RowCause = 'Manual';
                    orderShareData.ParentId = orderData.Id;
                    orderShareData.UserOrGroupId  = salesme.Sales__c;
                    orderShareData.AccessLevel = 'Read';
                    String idKeyString = String.valueOf(orderData.Id)+String.valueOf(salesme.Sales__c);
                    insertOrderMap.put(idKeyString, orderShareData);
                    productLineSalesList.add(salesme);
                    //如果为keyuser，设置为owner
                    if (salesme.IsKeyUser__c 
                    && !orderData.OwnerId.equals(salesme.Sales__c)) {
                        orderData.OwnerId = salesme.Sales__c;
                        updateOrderList.add(orderData);
                        flag = true;
                    }
                }
            }
            if (flag == false 
                && productLineSalesList.size() > 0
                && !orderData.OwnerId.equals(productLineSalesList[0].Sales__c)) {
                orderData.OwnerId = productLineSalesList[0].Sales__c;
                updateOrderList.add(orderData);
            }
            String mapString = String.valueOf(orderData.Id)+String.valueOf(orderData.OwnerId);
            if (insertOrderMap.containsKey(mapString)) {
                insertOrderMap.remove(mapString);
            }
        }
        
                

        try{
            update updateOrderList;
        }catch(Exception e){
            system.debug('error message'+e.getMessage());
            system.debug('line number'+e.getLineNumber());
        }

        if(insertOrderMap.size() > 0){
            insertOrderShareList = insertOrderMap.values();
            try{
                Database.upsert(insertOrderShareList);
            }catch(Exception e){
                system.debug('error message'+e.getMessage());
                system.debug('line number'+e.getLineNumber());
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}