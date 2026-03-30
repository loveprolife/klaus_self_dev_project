global class Php_StoreSoInventorySchedulable implements Schedulable{
    
    global void execute(SchedulableContext SC){
        System.debug('定时任务启动');

        // 清除库存销量报表历史数据
        Database.executeBatch(new Php_StoreSoInventoryClearReportBatch(),200);
        Php_StoreSoInventoryBatch ps = new Php_StoreSoInventoryBatch('Hisense Philippines');
        Database.executeBatch(ps,10);
    }
}