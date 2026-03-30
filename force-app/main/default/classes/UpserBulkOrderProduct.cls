/**********************************************************************
* Name: UpserBulkOrderProduct
* Object: Orderproduct 
* Purpose: 
* upsert Order_Product__c
* Author: Gerry
* Create Date: 2019-05-08
*************************************************************************/
public class UpserBulkOrderProduct implements Queueable {
    
    private List<Order_Product__c> orderProductList;
    
    public UpserBulkOrderProduct(List<Order_Product__c> OrderProductList) {
        this.orderProductList = OrderProductList;
    }

    public void execute(QueueableContext context) {
        try {
            List<Order_Product__c> orderProductList1 = new List<Order_Product__c>();
            List<Order_Product__c> orderProductList2 = new List<Order_Product__c>();
            //如果超过9999，把之后的纪录放到另一个异步处理中。如果没有超过就是这个异步中全部处理
            if (OrderProductList.size()>9999) {
                for (Integer i=0;i<orderProductList.size();i++) {
                    if (i>9998) {
                        orderProductList2.add(orderProductList[i]);
                    }else{
                        orderProductList1.add(orderProductList[i]);
                    }
                }
            }else{
                orderProductList1 = orderProductList;
            }
            List<Database.upsertResult> resultsOrderProduct = Database.upsert(orderProductList1,Order_Product__c.Fields.External_Key__c,false);
            if (orderProductList2.size()>0 && !Test.isRunningTest()) {
                //进行另一个异步处理
                UpserBulkOrderProductSecond bulkorderProduct = new UpserBulkOrderProductSecond(orderProductList2);
                ID jobID = System.enqueueJob(bulkorderProduct);
            }
            //日志内容
            Utility.insertLog('UpserBulkOrderProduct', '1', null, null);
        }
        catch (Exception e) {
            //日志内容
            String errorMsg = 'upsert order_product__c失败：'+e.getMessage()+e.getLineNumber();
            Utility.insertLog('UpserBulkOrderProduct', '0', null, errorMsg);
        }
    }   
}