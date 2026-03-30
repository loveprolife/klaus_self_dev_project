/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 05-11-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
global class SAPSchedulableController implements Schedulable {

    // 定时任务初始化标识
    public Integer index;
    // 国家下标
    public Integer companyIndex;
    // 订单类型下标
    public Integer typeIndex;
    // 订单信息:1 发货单:2 发票:3
    public Integer flag;

    global SAPSchedulableController (Integer index, Integer companyIndex, Integer typeIndex, Integer flag){
        this.index = index;
        this.companyIndex = companyIndex;
        this.typeIndex = typeIndex;
        this.flag = flag;
    }

   //call the web service to get the store info
    global void execute(SchedulableContext SC) {
      // 每个国家的定时开始时间
      List<String> timeList = Label.Company_Code_SAP_Time.split(',');

      // 国家code
      List<String> companyCodeList = Label.Company_Code_SAP.split('-');

      // 订单类型
      List<String> orderTypeList = Label.Order_Type_SAP.split('-');

      // 定时间隔时间
      Integer interval = Integer.valueOf(Label.SAP_Scheduled_Interval_Time);

      // 当前定时国家
      String companyCode;
      // 当前定时订单类型
      String orderType;
      // 当前定时方法
      Integer methods = flag;
        try {
            // 当前时间N分钟，下一次定时时间
            DateTime reTime = System.Now().addMinutes(interval);
            Integer minute = reTime.minute();
            Integer hour = reTime.hour();  
            String con = '0 ' + minute + ' ' + hour + ' * * ?';
            // 判断index值，写入新的定时
            if(index == 0){
                // 初始化定时任务
                for (Integer i = 0; i < companyCodeList.size(); i++) {
                System.schedule('orderSapSchedulable-' + companyCodeList.get(i) + '-' + orderTypeList.get(0) + '-1', timeList.get(i), new SAPSchedulableController(1, i, 0, 1));
                }

                // 删除初始化定时
                deleteSchedulable('orderSapSchedulable-start');
            }else if(index == 1) {

                // 获取国家
                companyCode = companyCodeList.get(companyIndex);

                // 获取订单类型
                orderType = orderTypeList.get(typeIndex);

                // 删除定时任务
                String name = 'orderSapSchedulable-' + companyCode + '-' + '%';
                deleteSchedulable(name);
                System.debug(orderTypeList.size());

                // 判断orderType是否循环完成
                if(typeIndex < orderTypeList.size() - 1){
                    typeIndex = typeIndex + 1;
                }else if(typeIndex == orderTypeList.size() - 1 && flag != 3){
                    typeIndex = 0;
                    flag = flag + 1; 
                }else if(typeIndex == orderTypeList.size() - 1 && flag == 3){
                    typeIndex = 0;
                    flag = 1;
                    con = timeList.get(companyIndex);

                    //处理订单共享
                    Share_Common_IntegrationBatch OrderShareBatch = new Share_Common_IntegrationBatch(
                        'Order_Product__c', 
                        false, 
                        '',
                        0,
                        ''
                    );
                    Database.executeBatch(OrderShareBatch, 30);
                }
                System.schedule('orderSapSchedulable-' + companyCode + '-' + orderTypeList.get(typeIndex) + '-' + flag, con, new SAPSchedulableController(index, companyIndex, typeIndex, flag));

                // 执行方法
                executeOrder(companyCode.split(','), orderType.split(','), methods);
            }
        } catch (Exception e) {
         // 日志内容
         Utility.insertLog('SAPSchedulableController', '0', null, '定时任务报错：companyCode:' + companyCode + ' orderType:' + orderType + ' methods：' + methods);     
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

  
   global void executeOrder(List<String> companyCodeList, List<String> orderTypeCodeList, Integer methods) {
      String syncStartDate = String.valueOf(System.today() - 1);
      String syncEndDate = String.valueOf(System.today() - 1);
      for (String str : companyCodeList) {
         List<String> companyCodeListRun = new List<String>();
         companyCodeListRun.add(str);
         //do订单
         for (String str1 : orderTypeCodeList) {
            List<String> orderTypeCodeListRun = new List<String>();
            orderTypeCodeListRun.add(str1);
            if(methods == 1){
               System.debug('Sales Order Params:' + companyCodeListRun.toString() + orderTypeCodeListRun.toString());
               // 订单信息
               SAPGetSalesOrder1.getSalesOrderFromSAP(companyCodeListRun,syncStartDate,syncEndDate,orderTypeCodeListRun);
            }else if(methods == 2){
               System.debug('Delivery Order Params' + companyCodeListRun.toString() + orderTypeCodeListRun.toString());
               // 发货单
               SAPGetDeliveryOrder1.getDeliveryOrderFromSAP(companyCodeListRun,syncStartDate,syncEndDate,orderTypeCodeListRun);
            }else if(methods == 3){
               System.debug('Invoice Params' + companyCodeListRun.toString() + orderTypeCodeListRun.toString());
               // 发票
               SAPGetInvoice1.getInvoiceFromSAP(companyCodeListRun,syncStartDate,syncEndDate,orderTypeCodeListRun);
            }
            
         }
      }
   }

}