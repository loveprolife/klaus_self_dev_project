global class SAPSchedulableByDateController implements Schedulable {

   // 定时任务初始化标识
   public Integer index;
   // 国家下标
   public Integer companyIndex;
   // 订单类型下标
   public Integer typeIndex;
   // 订单信息:1 发货单:2 发票:3
   public Integer flag;
   // 开始月份日期
   public String startTime;
   // 结束月份日期
   public String endTime;
   // 国家编号
   public String companyNum;
   // 执行方法
   public Integer methodNum;

   global SAPSchedulableByDateController (Integer index, Integer companyIndex, Integer typeIndex, Integer flag, String startTime, String endTime){
      this.index = index;
      this.companyIndex = companyIndex;
      this.typeIndex = typeIndex;
      this.flag = flag;
      this.startTime = String.valueOf(Date.valueOf(startTime));
      this.endTime = String.valueOf(Date.valueOf(endTime));
   }

   global SAPSchedulableByDateController (String startTime, String companyNum, Integer methodNum){
      this.companyNum = companyNum;
      this.startTime = String.valueOf(Date.valueOf(startTime));
      this.methodNum = methodNum;
   }

   //call the web service to get the store info
   global void execute(SchedulableContext SC) {
      // 每个国家的定时开始时间
      List<String> timeList = Label.Company_Code_SAP_Time_Date.split(',');

      // 国家code
      List<String> companyCodeList = Label.Company_Code_SAP_Date.split('-');

      // 订单类型
      List<String> orderTypeList = Label.Order_Type_SAP_Date.split('-');

      // 定时间隔时间
      Integer interval = Integer.valueOf(Label.SAP_Scheduled_Interval_Time_Date);

      // 当前定时国家
      String companyCode;
      // 当前定时订单类型
      String orderType;
      // 当前定时方法
      Integer methods = flag;
      // 下一天开始标记
      Boolean nextDayFlag = false;
      try {
         // 当前时间N分钟，下一次定时时间
         DateTime reTime = System.Now().addMinutes(interval);
         Integer minute = reTime.minute();
         Integer hour = reTime.hour();  
         String con = '0 ' + minute + ' ' + hour + ' * * ?';
         // 判断index值，写入新的定时
         if(index == 0 && methodNum == null){
            // 初始化定时任务
            for (Integer i = 0; i < companyCodeList.size(); i++) {
               System.schedule('orderSapSchedulableDate-' + companyCodeList.get(i) + '-' + orderTypeList.get(0) + '-1', timeList.get(i), new SAPSchedulableController(1, i, 0, 1));
            }

            // 删除初始化定时
            deleteSchedulable('orderSapSchedulableDate-start');
         }else if(index == 1 && methodNum == null) {
            // 获取国家
            companyCode = companyCodeList.get(companyIndex);
            // 获取订单类型
            orderType = orderTypeList.get(typeIndex);

            // 删除定时任务
            String name = 'orderSapSchedulableDate-' + companyCode + '-' + '%';
            deleteSchedulable(name);

            // 判断orderType是否循环完成
            if(typeIndex < orderTypeList.size() - 1){
               typeIndex = typeIndex + 1;
            }else if(typeIndex == orderTypeList.size() - 1 && flag != 3){
               typeIndex = 0;
               flag = flag + 1; 
            }else if(typeIndex == orderTypeList.size() - 1 && flag == 3){
               typeIndex = 0;
               flag = 1;
               nextDayFlag = true;
            }
            // 判断日期是否小于昨天或者是否是当月最后一天
            if(Date.valueOf(startTime).addDays(1) < Date.valueOf(endTime) && nextDayFlag){
               nextDayFlag = false;
               Date reDate = Date.valueOf(startTime).addDays(1);
               System.schedule('orderSapSchedulableDate-' + companyCode + '-' + orderTypeList.get(typeIndex) + '-' + flag + '-' + String.valueOf(reDate), con, new SAPSchedulableByDateController(index, companyIndex, typeIndex, flag, String.valueOf(reDate), String.valueOf(endTime)));
            }else if (!nextDayFlag) {
               System.schedule('orderSapSchedulableDate-' + companyCode + '-' + orderTypeList.get(typeIndex) + '-' + flag + '-' + startTime, con, new SAPSchedulableByDateController(index, companyIndex, typeIndex, flag, startTime, endTime));
            }

            // 执行方法
            executeOrder(companyCode.split(','), orderType.split(','), methods, startTime);
         } else if(methodNum != null){
            deleteSchedulable('OrderDeliveryInvoiceInit');
            Date reDate = Date.valueOf(startTime).addDays(1);
            List<String> companyList = new List<String>();
            companyList.add(companyNum);
            List<String> orderList = new List<String>();
            orderList.add('ALL');
            System.debug('wfc--'+ companyNum + '-' + methodNum + '-' + con + '-' + startTime);
            // 执行方法
            if(methodNum == 1){
               SAPGetSalesOrder.getSalesOrderFromSAP(companyList, startTime, startTime, orderList);
            }else if(methodNum == 2){
               SAPGetDeliveryOrder.getDeliveryOrderFromSAP(companyList, startTime, startTime, orderList);
            }else if(methodNum == 3){
               SAPGetInvoice.getInvoiceFromSAP(companyList, startTime, startTime, orderList);
            }
            if(Date.valueOf(startTime) < System.today() - 1){
               System.schedule('OrderDeliveryInvoiceInit', con, new SAPSchedulableByDateController(String.valueOf(reDate), companyNum ,methodNum));
            }
            Utility.insertLog('OrderDeliveryInvoiceInit', '1', null,startTime + '- methods:' + methodNum + 'Sales Order Params:' + companyList.toString() + orderList.toString());     
         }
      } catch (Exception e) {
         // 日志内容
         Utility.insertLog('SAPSchedulableByDateController', '0', null, '定时任务报错：companyCode:' + companyCode + ' orderType:' + orderType + ' methods：' + methods + ' startTime:' + startTime);     
      }
      
   }

   global void deleteSchedulable(String name) {
      // 删除定时任务
      List<CronTrigger> cronTriggers = [select Id from CronTrigger where CronJobDetail.Name like :name and CronJobDetail.JobType = '7'];
      if(cronTriggers.size() > 0){
         for(cronTrigger cronTrigger : cronTriggers){
            System.abortJob(cronTrigger.id);
         }
      }
   }

  
   global void executeOrder(List<String> companyCodeList, List<String> orderTypeCodeList, Integer methods, String syncStartDate) {
      // String syncEndDate = String.valueOf(Date.valueOf(syncStartDate).addDays(1));
      String syncEndDate = syncStartDate;
      for (String str : companyCodeList) {
         List<String> companyCodeListRun = new List<String>();
         companyCodeListRun.add(str);
         //do订单
         for (String str1 : orderTypeCodeList) {
            List<String> orderTypeCodeListRun = new List<String>();
            orderTypeCodeListRun.add(str1);
            Utility.insertLog('wfctest', '1', null,syncStartDate + '-' + syncEndDate + ' methods:' + methods + 'Sales Order Params:' + companyCodeListRun.toString() + orderTypeCodeListRun.toString());     
            if(methods == 1){
               System.debug('Sales Order Params:' + companyCodeListRun.toString() + orderTypeCodeListRun.toString());
               // 订单信息
               SAPGetSalesOrderDate.getSalesOrderFromSAP(companyCodeListRun,syncStartDate,syncEndDate,orderTypeCodeListRun);
            }else if(methods == 2){
               System.debug('Delivery Order Params' + companyCodeListRun.toString() + orderTypeCodeListRun.toString());
               // 发货单
               SAPGetDeliveryOrderDate.getDeliveryOrderFromSAP(companyCodeListRun,syncStartDate,syncEndDate,orderTypeCodeListRun);
            }else if(methods == 3){
               System.debug('Invoice Params' + companyCodeListRun.toString() + orderTypeCodeListRun.toString());
               // 发票
               SAPGetInvoiceDate.getInvoiceFromSAP(companyCodeListRun,syncStartDate,syncEndDate,orderTypeCodeListRun);
            }
            
         }
      }
   }

   // global Boolean isLastDayOfMonth(String reTime) {
   //    // 判断是否是当月最后一天
   //    Date addDay = Date.valueOf(reTime).addDays(1);
   //    Date addMonth = Date.valueOf(reTime).addMonths(1);
   //    Integer addDayYear = addDay.year();
   //    Integer addDayMonth = addDay.month();

   //    Integer addMonthYear = addMonth.year();
   //    Integer addMonthMonth = addMonth.month();

   //    if(Date.valueOf(addDayYear + '-' + addDayMonth + '-' + '01') == Date.valueOf(addMonthYear+ '-' + addMonthMonth  + '-' + '01')){
   //       return true;
   //    }else {
   //       return false;
   //    }
   // }


}