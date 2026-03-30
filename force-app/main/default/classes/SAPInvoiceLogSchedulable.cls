global class SAPInvoiceLogSchedulable implements Schedulable {

   public String startTime = '';

   global SAPInvoiceLogSchedulable(){
   }

   global SAPInvoiceLogSchedulable(String startTime){
      this.startTime = startTime;
   }

   //call the web service to get the store info
   global void execute(SchedulableContext SC) {
      // label信息
      List<String> labelList = Label.SAP_Invoice_Log_Schedulable.split(',');
      // 国家
      String companyCode = labelList.get(0);
      // orderType
      String orderType = labelList.get(1);
      // 开始时间
      String syncStartDate = labelList.get(2);
      // 结束时间
      String syncEndDate = labelList.get(3);
      
      // 删除定时
      deleteSchedulable('SAPInvoiceLogSchedulable');
      // 当前时间N分钟，下一次定时时间
      DateTime reTime = System.Now().addMinutes(2);
      Integer minute = reTime.minute();
      Integer hour = reTime.hour();  
      String con = '0 ' + minute + ' ' + hour + ' * * ?';

      

      try {
         if(!String.isBlank(startTime)){
            syncStartDate = startTime;
            syncEndDate = startTime;
            // 时间加一天
            String endDate = String.valueOf(Date.valueOf(startTime).addDays(1));
            if(Date.valueOf(startTime) < System.today()){
               System.schedule('SAPInvoiceLogSchedulable', con, new SAPInvoiceLogSchedulable(endDate));
            }
         }
        
         // 执行方法
         executeOrder(companyCode, orderType, String.valueOf(Date.valueOf(syncStartDate)), String.valueOf(Date.valueOf(syncEndDate)));
           
      }catch (Exception e) { 
         // 日志内容
         Utility.insertLog('SAPInvoiceLogSchedulable', '0', labelList.toString(), '定时任务出错');       
      }

   }

   global void deleteSchedulable(String name) {
      // 删除定时任务
      List<CronTrigger> cronTriggers = [select Id from CronTrigger where CronJobDetail.Name = :name and CronJobDetail.JobType = '7'];
      if(cronTriggers.size() > 0){
         for(cronTrigger cronTrigger : cronTriggers){
            System.abortJob(cronTrigger.id);
         }
      }
   }

  
   global void executeOrder(String companyCode, String orderType, String syncStartDate, String syncEndDate) {
     
         List<String> companyCodeListRun = new List<String>();
         companyCodeListRun.add(companyCode);
        
         List<String> orderTypeCodeListRun = new List<String>();
         orderTypeCodeListRun.add(orderType);
            
         SAPGetInvoiceLog.getInvoiceFromSAP(companyCodeListRun,syncStartDate,syncEndDate,orderTypeCodeListRun);

   }

}