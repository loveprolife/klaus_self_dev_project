/**********************************************************************
* Name: UpserBulkOrderProduct
* Object: Orderproduct 
* Purpose: 
* upsert Order_Product__c
* Author: Gerry
* Create Date: 2019-05-08
*************************************************************************/
public class InsertOrder implements Queueable {
    
    private List<Order__c> orderList;
    private List<Order_Product__c> orderProductList;
    Map<String,List<Order_Product__c>> tempOrderProMap;
    public InsertOrder(List<Order__c> OrderList,List<Order_Product__c> orderProductList,Map<String,List<Order_Product__c>> tempOrderProMap) {
        this.orderList = orderList;
        this.orderProductList = orderProductList;
        this.tempOrderProMap = tempOrderProMap;
    }

    public void execute(QueueableContext context) {
        try {
            List<Database.upsertResult> resultsOrder = Database.upsert(orderList,Order__c.Fields.External_Key__c,false);
            //进行订单行的头关联
            for (Order__c ord : orderList) {
                if(tempOrderProMap.get(ord.External_Key__c) != null){
                    for (Order_Product__c orderProduct : tempOrderProMap.get(ord.External_Key__c)) {
                        orderProduct.Order__c = ord.Id;
                    }
                }
            }
            List<String> customerNotExistList = new List<String>();
            Set<String> customerNotExistListNew = new Set<String>();
            //如果有出现upser错误的时候，进行错误日志创建
            for(Database.upsertResult dbur : resultsOrder){
                if(dbur.isSuccess() == false){
                    for(Database.Error error : dbur.getErrors()){
                        customerNotExistList.add(error.message);
                    }
                }
            }
            //获取到错误信息里想要的部分
            for(String cnel : customerNotExistList){
                // customerNotExistListNew.add(cnel.substring(25,35));
                customerNotExistListNew.add(cnel);
            }

            String bodyUserNotExist = JSON.serialize(customerNotExistListNew);

            if (!Test.isRunningTest()) {
                UpserBulkOrderProduct bulkorderProduct = new UpserBulkOrderProduct(orderProductList);
                ID jobID = System.enqueueJob(bulkorderProduct);
            }
            //日志内容
            String errorMsg = bodyUserNotExist;
            Utility.insertLog('InsertOrder', '1', null, errorMsg);
        }
        catch (Exception e) {
            //日志内容
            String errorMsg = 'InsertOrder失败：'+e.getMessage()+e.getLineNumber();
            Utility.insertLog('InsertOrder', '0', null, errorMsg);
        }
    }   
}