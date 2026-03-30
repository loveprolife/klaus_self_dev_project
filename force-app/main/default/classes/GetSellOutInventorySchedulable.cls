//  startDate   2024-01-01  >=  start     < end
global class GetSellOutInventorySchedulable implements Schedulable {
    public String schedulable_name;
    public String startDate;
    public Boolean isDelete;

    public Integer row_count = 5000;
    public Integer row_offset;

    public Boolean oneDay = false;

    public String data_source;
    public String sub;
 
    global GetSellOutInventorySchedulable (String schedulable_name, String startDate, Integer row_count, Integer row_offset, Boolean oneDay, String data_source, String sub){
        this.schedulable_name = schedulable_name;
        this.startDate = startDate;
        this.row_offset = row_offset;
        this.row_count = row_count;
        this.oneDay = oneDay;

        this.data_source = data_source;
        this.sub = sub;
    }

    global GetSellOutInventorySchedulable (String schedulable_name, String startDate, Boolean isDelete, Boolean oneDay, String data_source, String sub){
        this.schedulable_name = schedulable_name;
        this.startDate = startDate;
        this.isDelete = isDelete;

        this.oneDay = oneDay;
        this.data_source = data_source;
        this.sub = sub;
    }


    global void execute(SchedulableContext sc) {
        try {

            if('GetSellOutInventorySchedulable'.equals(schedulable_name)){
                startDate = String.valueOf(System.today().addDays(-60));
            }else{
                // 删除定时任务
                deleteSchedulable(schedulable_name);
            }
            

            if(isDelete != null && isDelete){
                list<Sell_out_Inventory__c> dl = [select id from Sell_out_Inventory__c where create_dt__c >= :startDate and data_source__c = :data_source and sub__c =:sub limit 9500];
                if(dl !=  null && dl.size() > 0){
                    Database.delete(dl);

                    if(dl.size() < 9500){
                        // 当前时间N分钟，下一次定时时间
                        DateTime reTime = System.Now().addSeconds(5);
                        Integer second = reTime.second();
                        Integer minute = reTime.minute();
                        Integer hour = reTime.hour();  
                        String con = second + ' ' + minute + ' ' + hour + ' * * ?';

                        // 生成唯一值
                        Blob b = Crypto.GenerateAESKey(128);
                        String h = EncodingUtil.ConvertTohex(b);
                        System.schedule(h, con, new GetSellOutInventorySchedulable(h, startDate.substring(0,10).replace('-', ''), row_count, 0, oneDay, data_source, sub));
                        
                    }else{
                        // 当前时间N分钟，下一次定时时间
                        DateTime reTime = System.Now().addSeconds(5);
                        Integer second = reTime.second();
                        Integer minute = reTime.minute();
                        Integer hour = reTime.hour();  
                        String con = second + ' ' + minute + ' ' + hour + ' * * ?';

                        // 生成唯一值
                        Blob b = Crypto.GenerateAESKey(128);
                        String h = EncodingUtil.ConvertTohex(b);
                        System.schedule(h, con, new GetSellOutInventorySchedulable(h, startDate, true, oneDay, data_source, sub));
                    }
                }else{
                    // 当前时间N分钟，下一次定时时间
                    DateTime reTime = System.Now().addSeconds(5);
                    Integer second = reTime.second();
                    Integer minute = reTime.minute();
                    Integer hour = reTime.hour();  
                    String con = second + ' ' + minute + ' ' + hour + ' * * ?';
        
                    // 生成唯一值
                    Blob b = Crypto.GenerateAESKey(128);
                    String h = EncodingUtil.ConvertTohex(b);
                    System.schedule(h, con, new GetSellOutInventorySchedulable(h, startDate.substring(0,10).replace('-', ''), row_count, 0, oneDay, data_source, sub));
                }
            }else{
                //GetSellOutInventory.readTextAndInsert(startDate);  GetSellOutInventory.GetSellOutInventory('20240701','20240702','xxx','5000','0');
                Date endDate = Date.valueOf(startDate.substring(0,4) + '-' + startDate.substring(4,6) + '-' + startDate.substring(6,8));
                GetSellOutInventory.GetSellOutInventory(startDate,String.valueOf(endDate.addDays(1)).substring(0,10).replace('-', ''), row_count, row_offset, oneDay, data_source, sub);
                //GetSellOutInventory.GetSellOutInventory('20240701','20240702', row_count, row_offset);
            }

        } catch (Exception e) {
            system.debug('error message'+e.getMessage());
            Utility.insertLog('GetSellOutInventorySchedulable', '0', null,  '-----' + schedulable_name);
        }
    }

    public static void deleteSchedulable(String name) {
        // 删除定时任务
        List<CronTrigger> cronTriggers = [select Id from CronTrigger where CronJobDetail.Name = :name and CronJobDetail.JobType = '7'];
        if(cronTriggers.size() > 0){
           for(cronTrigger cronTrigger : cronTriggers){
              System.abortJob(cronTrigger.id);
           }
        }
    }
}