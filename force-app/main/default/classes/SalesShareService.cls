/**
 * 用于销售关系发生变化后，提供数据 share变更
 */
public class SalesShareService {

    /**
     * 添加 share
     * @Author   Xiaoqian
     * @DateTime 2019-09-10
     * @param    dataList           [description]
     * @param    salesList          [description]
     * @param    customerIdSet      [description]
     * @param    shareObjName       [description]
     * @param    customerAPIName    [description]
     * @param    productLineAPIName [description]
     */
    public void shareData(List<SObject> dataList,
        List<Sales__c> salesList, 
        Set<String> customerIdSet,
        Map<String,Set<String>> summaryProductLineMap,
        String shareObjName, String customerAPIName, String productLineAPIName)
    {

        if(dataList == null || dataList.isEmpty()){
            return;
        }

        //if(salesList == null || salesList.isEmpty()){
        //    return;
        //}

        Set<String> dataIdSet = new Set<String>();

        for (SObject sobj : dataList) {
            dataIdSet.add(String.valueOf(sobj.get('Id')));
        }

        if(salesList == null) {
            salesList = [SELECT id, Customer__c, Sales__c, 
            Sales__r.IsActive,IsKeyUser__c, Product_Line__c 
            FROM Sales__c 
            WHERE Customer__c IN : customerIdSet 
            AND Sales__r.IsActive = TRUE];
        }
        
        if(salesList == null || salesList.isEmpty()) {
            return ;
        }

        Map<String, List<Sales__c>> salesMap = new Map<String, List<Sales__c>>();
        for (Sales__c sales : salesList) {
            Id customerId = sales.Customer__c;
            if(salesMap.containsKey(customerId)){
                salesMap.get(customerId).add(sales);
            }else{
                salesMap.put(customerId,new List<Sales__c>{sales});
            }
        }
        Map<String,SObject> shareObjMap = 
            new Map<String,SObject>();

        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType pType = objGlobalMap.get(shareObjName);
        List<sObject> shareObjList=new List<sObject>();

        for (SObject data : dataList) {
            List<Sales__c> salescList = salesMap.get(String.valueOf(data.get(customerAPIName)));
            List<Sales__c> productLineSalesList = new List<Sales__c>();
            Boolean flag = false;
            if (salescList == null) {
                continue;
            }
            Set<String> productLineSet =  null;
            if(summaryProductLineMap!=null){
                productLineSet = summaryProductLineMap.get(String.valueOf(data.get(customerAPIName)) 
                        + String.valueOf(data.get(productLineAPIName)));
                if(productLineSet == null){
                    continue;
                }
            }
            for (Sales__c salesme : salescList) {

                if(productLineSet != null){
                    for(String pcrrProductLine : productLineSet){
                        if (Utility.isExistProductLine(salesme.Product_Line__c,pcrrProductLine)) {
                            SObject shareObj = pType.newSObject();
                            shareObj.put('RowCause', 'Manual');
                            shareObj.put('ParentId', data.get('Id'));
                            shareObj.put('UserOrGroupId', salesme.Sales__c);
                            shareObj.put('AccessLevel', 'Read');
                            
                            String idKeyString = String.valueOf(data.Id)+String.valueOf(salesme.Sales__c);
                            shareObjMap.put(idKeyString, shareObj);
                            productLineSalesList.add(salesme);

                            //如果为keyuser，设置为owner
                            if (salesme.IsKeyUser__c) {
                                data.put('OwnerId', salesme.Sales__c);
                                //data.OwnerId = salesme.Sales__c;
                                flag = true;
                            } 
                            break;//只要销售负责其中一条产品线即可Share，因此跳出该层循环
                        }
                    }
                } else {
                    if (Utility.isExistProductLine(salesme.Product_Line__c,
                            String.valueOf(data.get(productLineAPIName)))) {
                        SObject shareObj = pType.newSObject();
                        shareObj.put('RowCause', 'Manual');
                        shareObj.put('ParentId', data.get('Id'));
                        shareObj.put('UserOrGroupId', salesme.Sales__c);
                        shareObj.put('AccessLevel', 'Read');
                        
                        String idKeyString = String.valueOf(data.Id)+String.valueOf(salesme.Sales__c);
                        shareObjMap.put(idKeyString, shareObj);
                        productLineSalesList.add(salesme);

                        //如果为keyuser，设置为owner
                        if (salesme.IsKeyUser__c) {
                            data.put('OwnerId', salesme.Sales__c);
                            //data.OwnerId = salesme.Sales__c;
                            flag = true;
                        }
                    }
                }
            }

            if (flag == false && productLineSalesList.size() > 0) {
                data.put('OwnerId', productLineSalesList[0].Sales__c);
                //data.OwnerId = productLineSalesList[0].Sales__c;
            }

            String mapString = String.valueOf(data.get('Id'))+String.valueOf(data.get('OwnerId'));
            if (shareObjMap.containsKey(mapString)) {
                shareObjMap.remove(mapString);
            }
        }
        
                
        try{
            update dataList;
            if(shareObjMap.size() > 0){
                List<SObject> upsertAPRShareList = shareObjMap.values();
                Database.insert(upsertAPRShareList);
                System.debug('----------------');
                System.debug(Json.serialize(upsertAPRShareList));
            }
        }catch(Exception e){
            system.debug('error message'+e.getMessage());
            system.debug('line number'+e.getLineNumber());
        }
    }

    /**
     * 删除share
     * @Author   Xiaoqian
     * @DateTime 2019-09-10
     * @param    dataList              [description]
     * @param    salesList             [description]
     * @param    summaryProductLineMap [description]
     * @param    shareObjName          [description]
     * @param    customerAPIName       [description]
     * @param    productLineAPIName    [description]
     */
    public void removeShare(List<SObject> dataList,
        List<Sales__c> salesList, 
        Map<String,Set<String>> summaryProductLineMap,
        String shareObjName, String customerAPIName, String productLineAPIName)
    {

        if(dataList == null || dataList.isEmpty()){
            return;
        }

        if(salesList == null || salesList.isEmpty()){
            return;
        }

        Set<String> data_sales_keySet = new Set<String>();
        Set<String> salesIds = new Set<String>();
        Map<String, Sales__c> salesMap = new Map<String, Sales__c>();
        for (Sales__c sales : salesList) {
            salesIds.add(sales.Sales__c);
            List<String> productLines = sales.Product_Line__c.split(';');
            for(String productLine: productLines){
                salesMap.put(sales.Customer__c + productLine, sales);
            }
        }

        Set<String> dataIds = new Set<String>();
        
        for(SObject data: dataList){
            String key = String.valueOf(data.get(customerAPIName)) + String.valueOf(data.get(productLineAPIName));
            if(summaryProductLineMap!=null){
                Set<String> productLineSet = summaryProductLineMap.get(key);
                if(productLineSet == null){
                    continue;
                }
                for(String pl: productLineSet){
                    if(salesMap.containsKey(String.valueOf(data.get(customerAPIName)) + pl)) {
                        dataIds.add(String.valueOf(data.get('Id')));

                        Sales__c sales = salesMap.get(String.valueOf(data.get(customerAPIName)) + pl);
                        data_sales_keySet.add(String.valueOf(data.get('Id')) + sales.Sales__c);
                    }
                }
            }else{

                if(salesMap.containsKey(key)) {
                    dataIds.add(String.valueOf(data.get('Id')));
                }
            }
        }

        this.removeSharingDataByDataAndUserIds(data_sales_keySet, salesIds,dataIds,shareObjName);
        /*String query = 'SELECT ID FROM '+ shareObjName;
        List<SObject> shareObjList = Database.query(query+' WHERE ParentId in :dataIds AND UserOrGroupId in :salesIds AND RowCause = \'Manual\'');
        if(shareObjList!=null && !shareObjList.isEmpty()) {
            delete shareObjList;
        }*/
    }

    /**
     * 订单的共享，有别于其他数据
     * @Author   Xiaoqian
     * @DateTime 2019-09-10
     * @param    orderList  [description]
     * @param    salesList  [description]
     */
    public void shareOrder(List<Order__c> orderList, List<Sales__c> salesList){
        
        if(orderList == null || orderList.isEmpty()){
            return;
        }

        if(salesList == null || salesList.isEmpty()){
            return;
        }

        Set<Id> cusIdSet = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();

        for (Order__c orderData : orderList) {
            orderIdSet.add(orderData.Id);
            cusIdSet.add(orderData.Customer__c);
        }

        //List<Sales__c> salesList = [SELECT id, Customer__c, Sales__c, Sales__r.IsActive,IsKeyUser__c, Product_Line__c FROM Sales__c WHERE Customer__c IN : cusIdSet AND Sales__r.IsActive = TRUE];
        Map<String, List<Sales__c>> salesMap = new Map<String, List<Sales__c>>();
        for (Sales__c salesData : salesList) {
            if(salesMap.containsKey(salesData.Customer__c)){
                salesMap.get(salesData.Customer__c).add(salesData);
            }else{
                salesMap.put(salesData.Customer__c,new List<Sales__c>{salesData});
            }
        }

        List<Order__Share> insertOrderShareList = new List<Order__Share>();

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

    /**
     * 删除 某用户的 share
     * @Author   Xiaoqian
     * @DateTime 2019-09-09
     * @param    ids          [description]
     * @param    shareObjName [description]
     */
    /*public void removeSharingDataByUserIds(Set<String> userIds, String shareObjName){
        String query = 'SELECT ID FROM '+ shareObjName;
        List<SObject> shareObjList = Database.query(query+' WHERE UserOrGroupId in :userIds AND RowCause = \'Manual\'');
        if(shareObjList!=null && !shareObjList.isEmpty()) {
            delete shareObjList;
        }
    }*/

    /**
     * 删除 某数据项的 share
     * @Author   Xiaoqian
     * @DateTime 2019-09-09
     * @param    ids          [description]
     * @param    shareObjName [description]
     */
    /*public void removeSharingDataByDataIds(Set<String> dataIds, String shareObjName){
        String query = 'SELECT ID FROM '+ shareObjName;
        List<SObject> shareObjList = Database.query(query+' WHERE ParentId in :dataIds AND RowCause = \'Manual\'');
        if(shareObjList!=null && !shareObjList.isEmpty()) {
            delete shareObjList;
        }
    }*/

    /**
     * @Author   Xiaoqian
     * @DateTime 2019-09-12
     * @param    data_sales_keySet [description]
     * @param    userIds           [description]
     * @param    dataIds           [description]
     * @param    shareObjName      [description]
     */
    public void removeSharingDataByDataAndUserIds(Set<String> data_sales_keySet ,Set<String> userIds, Set<String> dataIds, String shareObjName){
        String query = 'SELECT Id,ParentId,UserOrGroupId,RowCause FROM '+ shareObjName;
        List<SObject> shareObjList = Database.query(query+' WHERE ParentId in :dataIds AND UserOrGroupId in :userIds AND RowCause = \'Manual\'');
        
        List<SObject> deleteOnes = new List<SObject>();
        if(shareObjList!=null && !shareObjList.isEmpty()) {
            for(SObject sobj: shareObjList){
                if(data_sales_keySet.contains(String.valueOf(sobj.get('ParentId'))
                    +String.valueOf(sobj.get('UserOrGroupId')))){
                    deleteOnes.add(sobj);
                }
            }
            if(!deleteOnes.isEmpty())
                delete deleteOnes;
        }
    }



}