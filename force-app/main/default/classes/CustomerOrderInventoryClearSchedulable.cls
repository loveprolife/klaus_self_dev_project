/*
 * @Author: WFC
 * @Date: 2023-09-08 17:40:26
 * @LastEditors: WFC
 * @LastEditTime: 2023-09-08 17:50:58
 * @Description: System.schedule('CustomerOrderInventoryClearSchedulable', '0 0 12 * * ?', new CustomerOrderInventoryClearSchedulable('8110','2023-01-01'));
 * @FilePath: \HisenseAllThree\force-app\main\default\classes\CustomerOrderInventoryClearSchedulable.cls
 */
global class CustomerOrderInventoryClearSchedulable implements Schedulable {

    public String orderDate;
    public String entity;

    global CustomerOrderInventoryClearSchedulable (String entity, String orderDate){
        this.entity = entity;
        this.orderDate = orderDate;
    }

    global void execute(SchedulableContext SC) {
        CustomerOrderInventoryClearBatch ss  = new CustomerOrderInventoryClearBatch(this.entity, this.orderDate);
		Database.executeBatch(ss);
   }
}