/*
 * @Author: WFC
 * @Date: 2024-01-15 17:10:46
 * @LastEditors: WFC
 * @LastEditTime: 2024-01-15 17:18:05
 * @Description: System.schedule('RealTimeInventorySchedulable', '0 0 12 * * ?', new RealTimeInventorySchedulable('Hisense South Africa', '2023-01-01'));
 * @FilePath: \hisenseall-231026\force-app\main\default\classes\RealTimeInventorySchedulable.cls
 */
global class RealTimeInventorySchedulable implements Schedulable {

    public String orderDate;
    public String salesRegion;

    global RealTimeInventorySchedulable (String salesRegion, String orderDate){
        this.salesRegion = salesRegion;
        this.orderDate = orderDate;
    }

    global void execute(SchedulableContext SC) {
        Utility.insertLog('RealTimeInventorySchedulable', '1', this.salesRegion + '-' + this.orderDate, String.valueOf(Datetime.now()));

        RealTimeInventoryDeleteBatch ss  = new RealTimeInventoryDeleteBatch(this.salesRegion, this.orderDate);
		Database.executeBatch(ss);
   }
}