/**********************************************************************
* Name: UpserBulkOrderProduct
* Object: Orderproduct 
* Purpose: 
* upsert Order_Product__c
* Author: Gerry
* Create Date: 2019-05-08
*************************************************************************/
public class UpserBulkOrderProductSecond implements Queueable {
    
    private List<Order_Product__c> orderProductList;
    
    public UpserBulkOrderProductSecond(List<Order_Product__c> OrderProductList) {
        this.orderProductList = OrderProductList;
    }

    public void execute(QueueableContext context) {
        List<Database.upsertResult> resultsOrderProduct = Database.upsert(orderProductList,Order_Product__c.Fields.External_Key__c,false);
        //日志内容
        Utility.insertLog('UpserBulkOrderProduct', '1', null, null);
    }   
}