global class SAPInvoiceParsingSchedulable implements Schedulable {

   public String bodyRes_login;
   public String schedulable_name;
   public SAPInvoiceParsingSchedulable.Input Input;
   
   global SAPInvoiceParsingSchedulable (String bodyRes_login, String schedulable_name){
      try {
         this.bodyRes_login = bodyRes_login;
         this.schedulable_name = schedulable_name;
      } catch (Exception e) {
         Utility.insertLog('SAPGetInvoiceLog', '0', '', '执行失败！');
      }
      
   }

  public class Input{
      public List<OrderList> orderList;
      public String isSuccess;
      public String failReason;
  }

  public class OrderList{
      public String invoiceNo;
      public String invoiceTotalAmount;
      public String invoiceDate;
      public String SFCurrency;
      public String SAPCustomerCode;
      public String HisenseEntity;
      public List<OrderLine> OrderLine;
      //add by johnson 20190710
      public String InvoiceRemark;
      //add by johnson 20190722
      public String TaxAmount;
      public String TotalAmountIncTax;

      //addby lxw 20190801
      public String InvoicePostingDate;
      public String InvoiceTotalAmountAfterRebate;
  }

  public class OrderLine{
      public String invoiceItemNo;
      public String salesOrderNo;
      public String salesOrderItemNo;
      public String deliveryOrderNo;
      public String deliveryOrderItemNo;
      public String productCustomerModel;
      public String productFactoryModel;
      //modified by johnson 20190722
      public String InvoiceAmountExVat;

      public String invoiceQuantity;
      public String productExportModel;
      public String productLine;
      public String MaterialNumber;
      //add by johnson 20190710
      public String Batch;
      public String TotalAmountAfterRebate;
      //add by johnson 20190722
      public String TaxAmount;
      public String InvoiceAmountIncVat;
  }

  public class ErrorMessageFactoryModel {
      public String ErrorMessageProductExportModel;
      public String ErrorMessageProductFactoryModel;
      public String ErrorMessageSapProductLine;
      public String ErrorMessageSalesforceProductLine;
      public String ErrorMessageCustomerSAPCode;
      public String ErrorMessageOrderNumber;
      public String ErrorMessageOrderLineItemNumber;
  }

  public class ErrorMessageCustomerModel {
      public String ErrorMessageProductCustomerModel;
      public String ErrorMessageSapProductLine;
      public String ErrorMessageSalesforceProductLine;
      public String ErrorMessageCustomerSAPCode;
      public String ErrorMessageOrderNumber;
      public String ErrorMessageOrderLineItemNumber;
  }

   //call the web service to get the store info
   global void execute(SchedulableContext SC) {

      // 删除定时任务
      deleteSchedulable(schedulable_name);

      // 调用解析方法
      parsing(bodyRes_login);

   }

   global void parsing(String bodyRes_login) {
        // 方法执行开始时间
      DateTime mint = System.Now();

      SAPInvoiceParsingSchedulable.Input input = new SAPInvoiceParsingSchedulable.Input();
      String bodyUserNotExist = '';

      try { 
          input =(SAPInvoiceParsingSchedulable.Input)JSON.deserialize(bodyRes_login,SAPInvoiceParsingSchedulable.Input.class );         
          
          // 方法执行结束时间
          DateTime maxt = System.Now();
          Long minms = mint.getTime(), maxms = maxt.getTime(), diff = maxms - minms;
          // 日志内容
          Utility.insertLog('SAPGetInvoiceLog', '2', '', '解析数据成功！,开始时间：' + mint.time()+ ',结束时间：' + maxt.time() + ',时间差：' + diff + '毫秒');  
      }
      catch (Exception e) {
          DateTime maxt = System.Now();
          Long minms = mint.getTime(), maxms = maxt.getTime(), diff = maxms - minms;
          //日志内容
          String errorMsg = '解析数据失败！,开始时间：' + mint.time()+ ',结束时间：' + maxt.time() + ',时间差：' + diff + '毫秒';
          Utility.insertLog('SAPGetInvoiceLog', '0', '', errorMsg);
          
          return; 
      }

      if (input.isSuccess == 'False') {
          DateTime maxt = System.Now();
          Long minms = mint.getTime(), maxms = maxt.getTime(), diff = maxms - minms;
          //日志内容
          String errorMsg = input.failReason;
          if(errorMsg.equals('No data')){
              Utility.insertLog('SAPGetInvoiceLog', '7', '', errorMsg + 'input.isSuccess == False,开始时间：' + mint.time()+ ',结束时间：' + maxt.time() + ',时间差：' + diff + '毫秒');
          }else {
              Utility.insertLog('SAPGetInvoiceLog', '8', '', errorMsg + 'input.isSuccess == False,开始时间：' + mint.time()+ ',结束时间：' + maxt.time() + ',时间差：' + diff + '毫秒');
          }
          return;
      }
      if (!(input.orderList == null || input.orderList.isEmpty())) {
          //Export Model Product Not Exist Error Log List
          List<ErrorMessageFactoryModel> exportModelNotExistList = new List<ErrorMessageFactoryModel>();
          //customer Model Product Not Exist Error Log List
          List<ErrorMessageCustomerModel> customerModelNotExistList = new List<ErrorMessageCustomerModel>();
          List<Invoice__c> invoiceList = new List<Invoice__c>();
          List<Invoice_Item__c> invoiceItemList = new List<Invoice_Item__c>();
          try {
              //订单编号
              Set<String> sOrderNoSet = new Set<String>();
              //订单行编码
              Set<String> sOrderItemSet = new Set<String>();
              //发货单编号
              Set<String> dOrderNoSet = new Set<String>();
              //发货单行编号
              Set<String> dOrderItemSet = new Set<String>();
              //工厂型号
              Set<String> productFMSet = new Set<String>();
              //客户型号
              Set<String> productCustomerModelSet = new Set<String>();
              //客户编码
              Set<String> sapCustomerCodeSet = new Set<String>();
              //出口型号
              Set<String> exportModelSet = new Set<String>();
              //产品线编号
              Set<String> mpSet = new Set<String>();
              //modified by johnson20190808
              Set<String> errorStringCannotFindOrderItem = new Set<String>();
              for (OrderList orList : input.orderList) {
                  sapCustomerCodeSet.add(orList.SAPCustomerCode);
                  if (!(orList.OrderLine!=null&&orList.OrderLine.size()>0)) {
                      continue;
                  }
                  for (OrderLine orLine : orList.OrderLine) {
                      sOrderNoSet.add(orLine.salesOrderNo+orlist.SAPCustomerCode);
                      sOrderItemSet.add(orLine.salesOrderNo + orLine.salesOrderItemNo);
                      dOrderNoSet.add(orLine.deliveryOrderNo);
                      dOrderItemSet.add(orLine.deliveryOrderNo + orLine.deliveryOrderItemNo);
                      if (String.isNotBlank(orLine.productFactoryModel)) {
                          productFMSet.add(orLine.productFactoryModel);
                      }
                      productCustomerModelSet.add(orLine.productCustomerModel);
                      exportModelSet.add(orLine.productExportModel);
                      exportModelSet.add(orLine.productFactoryModel);
                      mpSet.add(orLine.productLine);
                  }
              }

              Map<String,List<Mapping__c>> mpMap = new Map<String,List<Mapping__c>>();
              Map<String,String> businessScope2ProductLineMapping = new Map<String,String>();
              //对应得产品线
              for (Mapping__c mp : [SELECT ID,Name,RecordType.DeveloperName,Mapping_Code__c FROM Mapping__c WHERE Name IN :mpSet]) {
                  businessScope2ProductLineMapping.put(mp.Name,mp.Mapping_Code__c);
                  if (mpMap.containsKey(mp.Name)) {
                      mpMap.get(mp.Name).add(mp);
                  }else{
                      mpMap.put(mp.Name, new List<Mapping__c>{mp});
                  }
              }
              //纪录类型的ID
              String recordTypeID = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
              //客户ID
              Set<Id> accIdSet = new Set<Id>();
              //salesRegion
              Set<String> hisenseSet = new Set<String>();
              //对应客户编码的salesregion
              Map<String,String> accMap = new Map<String,String>();
              //对应客户编码的客户
              Map<String,Account> accCodeMap = new Map<String,Account>();
              //客户ID
              Map<String,ID> accIdMap = new Map<String,ID>();
              //找不到客户的   挂到这个特殊客户上
              List<Account> notFoundCustomer = [SELECT Id,SAP_Customer_Code__c FROM Account WHERE SAP_Customer_Code__c='CANNOTFINDCUSTOMERORDER'];
              //对应的客户
              for (Account acc : [SELECT Id,SAP_Customer_Code__c,Hisense_Entity__c,Sales_Region__c,Customer_Status__c FROM Account WHERE SAP_Customer_Code__c IN:sapCustomerCodeSet]) {
                  hisenseSet.add(acc.Sales_Region__c);
                  accMap.put(acc.SAP_Customer_Code__c, acc.Sales_Region__c);
                  accIdSet.add(acc.Id);
                  accCodeMap.put(acc.SAP_Customer_Code__c, acc);
                  accIdMap.put(acc.SAP_Customer_Code__c, acc.Id);
              }

              //查询产品线
              Map<String,Customer_Product_Line__c> cplMap = new Map<String,Customer_Product_Line__c>();
              for(Customer_Product_Line__c cpl : [SELECT Customer__c,Customer__r.SAP_Customer_Code__c,Actual_Development_Date__c,Product_Line_Name__c FROM Customer_Product_Line__c WHERE Customer__c IN :accIdSet]){
                  cplMap.put(cpl.Customer__c+cpl.Product_Line_Name__c, cpl);
              }

              Map<String,ID> modelMap = new Map<String,ID>();
              Map<String,ID> modelMapMobileandOther = new Map<String,ID>();

              //对应的客户型号
              for (Customer_Model_Product__c cmp : [SELECT Id,Country_Code__c,Name,Product_Line__c FROM Customer_Model_Product__c WHERE Name IN :productCustomerModelSet]) {
                  if('TV'.equals(cmp.Product_Line__c) || 'Laser TV'.equals(cmp.Product_Line__c) || 'AC'.equals(cmp.Product_Line__c) || 'LCAC'.equals(cmp.Product_Line__c) || 'WM'.equals(cmp.Product_Line__c) || 'Refrigerator'.equals(cmp.Product_Line__c) || 'Freezer'.equals(cmp.Product_Line__c)){
                      modelMap.put(cmp.Name.toUpperCase()+cmp.Country_Code__c, cmp.Id);
                  }else{
                      modelMapMobileandOther.put(cmp.Name.toUpperCase(), cmp.Id);
                  }
              }

              //对应的订单
              Map<String,ID> sOrderNoMap = new Map<String,ID>();
              for (Order__c order : [SELECT Id,Name,External_Key__c FROM Order__c WHERE External_Key__c IN :sOrderNoSet]) {
                  sOrderNoMap.put(order.External_Key__c, order.Id);
              }

              //对应的订单行
              Map<String,ID> sOrderItemMap = new Map<String,ID>();
              for (Order_Product__c opc : [SELECT Id,Name,SAP_Order_Item_No__c,External_Key__c FROM Order_Product__c WHERE External_Key__c IN :sOrderItemSet]) {
                  sOrderItemMap.put(opc.External_Key__c, opc.Id);
              }

              //对应的发货单
              Map<String,ID> dOrderNoMap = new Map<String,ID>();
              for (Delivery_Order__c doc : [SELECT Id,Name,SAP_Delivery_Order_No__c FROM Delivery_Order__c WHERE SAP_Delivery_Order_No__c IN :dOrderNoSet]) {
                  dOrderNoMap.put(doc.SAP_Delivery_Order_No__c, doc.Id);
              }

              //对应的发货单行
              Map<String,ID> dOrderItemMap = new Map<String,ID>();
              for (Delivery_Order_Item__c doic : [SELECT Id,Name,SAP_Delivery_Order_Item_No__c,External_Key__c FROM Delivery_Order_Item__c WHERE External_Key__c IN :dOrderItemSet]) {
                  dOrderItemMap.put(doic.External_Key__c, doic.Id);
              }

              //对应的产品线
              Map<String,ID> productFMMap = new Map<String,ID>();
              for (Product__c pc : [SELECT Id,Name FROM Product__c WHERE Name IN :exportModelSet]) {
                  productFMMap.put(pc.Name.toUpperCase(), pc.Id);
              }

              //对应的产品关系
              Map<String,List<Id>> productRelationMap = new Map<String,List<Id>>();
              for (Product_Relation__c pr : [SELECT Factory_Model__c,Product_Export_Model__c FROM Product_Relation__c WHERE Product_Export_Model__c IN:productFMSet]) {
                  if (productRelationMap.containsKey(pr.Product_Export_Model__c.toUpperCase())) {
                      productRelationMap.get(pr.Product_Export_Model__c.toUpperCase()).add(pr.Factory_Model__c);
                  }else{
                      productRelationMap.put(pr.Product_Export_Model__c.toUpperCase(), new List<Id>{pr.Factory_Model__c});
                  }
              }
              
              String tmpSalesOrderItemId = [SELECT Id,SAP_Order_Item_No__c FROM Order_Product__c where SAP_Order_Item_No__c =: Label.Temp_Sales_Order_No limit 1].Id; 
              System.debug('tmpSalesOrderItemId... '+tmpSalesOrderItemId);
              

              Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateMap();
              Map<String,List<Invoice_Item__c>> invoiceMap = new Map<String,List<Invoice_Item__c>>();
              List<Customer_Product_Line__c> updateCustomerProduct = new List<Customer_Product_Line__c>();
              List<Account> accList = new List<Account>();
              Decimal rate;
              for (OrderList orList : input.orderList) {
                  Invoice__c invo = new Invoice__c();
                  invo.Hisense_Entity__c = orList.HisenseEntity;
                  invo.SAP_Invoice_No__c = orList.invoiceNo;
                  invo.CurrencyIsoCode = orList.SFCurrency;
                  invo.Invoice_Total_Amount__c = Decimal.valueOf(String.isBlank(orList.invoiceTotalAmount)? '0':orList.invoiceTotalAmount);
                  if (String.isNotBlank(orList.invoiceDate)) {
                      invo.Invoice_Date__c = Date.valueOf(orList.invoiceDate);
                  }else{
                      invo.Invoice_Date__c = null;
                  }
                  invo.SAP_Customer_Code__c = orList.SAPCustomerCode;
                  //如果客户编码对应的客户找不到   挂到特殊客户上
                  if (String.isNotBlank(orList.SAPCustomerCode)&&accIdMap.get(orList.SAPCustomerCode)==null) {
                      invo.Customer__c = notFoundCustomer[0].Id;
                  }else{
                      invo.Customer__c = accIdMap.get(orList.SAPCustomerCode);
                  }
                  //add by johnson 20190710
                  invo.Invoice_Remark__c = orList.InvoiceRemark;
                  //add by johnson 20190722
                  invo.Tax_Amount__c = Decimal.valueOf(String.isBlank(orList.TaxAmount)? '0':orList.TaxAmount);
                  invo.Total_Amount_Inc_Tax__c = Decimal.valueOf(String.isBlank(orList.TotalAmountIncTax)? '0':orList.TotalAmountIncTax);

                  //addby lxw 20190801
                  if (String.isNotBlank(orList.InvoicePostingDate)) {
                      invo.Invoice_Posting_Date__c = Date.valueOf(orList.InvoicePostingDate);
                  }else{
                      invo.Invoice_Date__c = null;
                  }
                  invo.InvoiceTotalAmountAfterRebate__c = Decimal.valueOf(String.isBlank(orList.InvoiceTotalAmountAfterRebate)? '0':orList.InvoiceTotalAmountAfterRebate);

                  invoiceList.add(invo);
                  if (!(orList.OrderLine!=null&&orList.OrderLine.size()>0)) {
                      continue;
                  }
                  for (OrderLine orLine : orList.OrderLine) {
                      String salesforceProductLine = businessScope2ProductLineMapping.get(orLine.productLine);
                      Invoice_Item__c invoiceIt = new Invoice_Item__c();
                      invoiceIt.Material_Number__c = orLine.MaterialNumber;
                      String productLine;
                      invoiceIt.Sap_Product_Line_Code__c = orLine.productLine;
                      if (!String.isBlank(orLine.productLine)) {
                          for (Mapping__c mp : mpMap.get(orLine.productLine)) {
                              if (recordTypeID.equals(mp.RecordTypeId)) {
                                  invoiceIt.SAP_Product_Line__c = mp.Id;
                                  productLine = mp.Mapping_Code__c;
                                  break;
                              }
                          }
                      }else{
                          invoiceIt.SAP_Product_Line__c = null;
                      }
                      invoiceIt.SAP_Invoice_Line_No__c = orLine.invoiceItemNo;
                      invoiceIt.Delivery_Order__c = dOrderNoMap.get(orLine.deliveryOrderNo);
                      invoiceIt.Delivery_Order_Item__c = dOrderItemMap.get(orLine.deliveryOrderNo + orLine.deliveryOrderItemNo);
                      invoiceIt.Sales_Order__c = sOrderNoMap.get(orLine.salesOrderNo+orList.SAPCustomerCode);
                      //当找不到订单订单行时，写入Log
                      if(sOrderItemMap.get(orLine.salesOrderNo + orLine.salesOrderItemNo) == null){
                          errorStringCannotFindOrderItem.add(orList.invoiceNo+ '_' + orLine.invoiceItemNo + '_' +orLine.salesOrderNo + '_'+ orLine.salesOrderItemNo+ '@END');
                      }
                      if(sOrderItemMap.get(orLine.salesOrderNo + orLine.salesOrderItemNo) != null){
                          invoiceIt.Sales_Order_Item__c = sOrderItemMap.get(orLine.salesOrderNo + orLine.salesOrderItemNo);
                      }else{
                          invoiceIt.Sales_Order_Item__c = tmpSalesOrderItemId;
                      }
                      
                      invoiceIt.SAP_Product_Export_Model__c = orLine.productExportModel;
                      invoiceIt.SAP_Customer_Model_Product__c = orLine.productCustomerModel;
                      invoiceIt.Product_Factory_Model__c = orLine.productFactoryModel;
                      if('TV'.equals(salesforceProductLine) || 'AC'.equals(salesforceProductLine) || 'Laser TV'.equals(salesforceProductLine) || 'LCAC'.equals(salesforceProductLine) || 'Refrigerator'.equals(salesforceProductLine) || 'Freezer'.equals(salesforceProductLine) || 'WM'.equals(salesforceProductLine)){
                          invoiceIt.Customer_Model_Product__c = modelMap.get(orLine.productCustomerModel.toUpperCase()+accMap.get(orList.SapCustomerCode));
                      }else{//手机&小家电&other
                          invoiceIt.Customer_Model_Product__c = modelMapMobileandOther.get(orLine.productCustomerModel.toUpperCase());
                      }
                      invoiceIt.Invoice_Quantity__c = Decimal.valueOf(String.isBlank(orLine.invoiceQuantity)? '0': orLine.invoiceQuantity);
                      //当产品线位冰冷洗的时候通过SAP过来的工厂型号去Relation中查询相应的出口型号
                      if ('Refrigerator'.equals(productLine)||'Freezer'.equals(productLine)||'WM'.equals(productLine)) {
                          List<Id> IdList = productRelationMap.get(orLine.productFactoryModel.toUpperCase());
                          invoiceIt.Product_Export_Model__c = IdList==null? null:IdList[0];
                      }else if ('Laser TV'.equals(productLine)||'TV'.equals(productLine)||'Mobile'.equals(productLine)) {
                          //当产品线为TV 或者Mobile的时候通过sap过来的工厂型号去找到相应的product
                          invoiceIt.Product_Export_Model__c = productFMMap.get(orLine.productFactoryModel.toUpperCase());
                      }else{
                          //当产品线为TV 或者Mobile的时候通过sap过来的工厂型号去找到相应的product
                          invoiceIt.Product_Export_Model__c = productFMMap.get(orLine.productExportModel.toUpperCase());
                      }
                      //modified by johnson 20190722
                      invoiceIt.Invoice_Amount__c = Decimal.valueOf(String.isBlank(orLine.InvoiceAmountExVat)? '0':orLine.InvoiceAmountExVat);
                      
                      invoiceIt.CurrencyIsoCode = orList.SFCurrency;
                      if (invoiceMap.containsKey(invo.SAP_Invoice_No__c)) {
                          invoiceMap.get(invo.SAP_Invoice_No__c).add(invoiceIt);
                      }else{
                          invoiceMap.put(invo.SAP_Invoice_No__c, new List<Invoice_Item__c>{invoiceIt});
                      }
                      //找到相应的customer product Line   之后进行时间赋值
                      Account accUpdate = accCodeMap.get(orList.SAPCustomerCode);
                      Customer_Product_Line__c customerProductLine;
                      if (accUpdate!=null) {
                          customerProductLine = cplMap.get(accUpdate.Id+productLine);
                      }
                      if (customerProductLine!=null && customerProductLine.Actual_Development_Date__c == null) {
                          customerProductLine.Actual_Development_Date__c = invo.Invoice_Date__c;
                          updateCustomerProduct.add(customerProductLine);
                      }
                      Set<String> customerStatusSet = new Set<String>{'Collaborated','Eliminated','FD32','XD05','XD06'};
                      if (accUpdate != null
                          && !customerStatusSet.contains(accUpdate.Customer_Status__c)) {
                          accUpdate.Customer_Status__c = 'Collaborated';
                          accList.add(accUpdate);
                      }
                      //add by johnson 20190710
                      invoiceIt.Batch__c = orLine.Batch;
                      invoiceIt.Total_Amount_After_Rebate__c = Decimal.valueOf(String.isBlank(orLine.TotalAmountAfterRebate)? '0':orLine.TotalAmountAfterRebate);
                      //add by johnson 20190722
                      invoiceIt.Invoice_Amount_Inc_Vat__c = Decimal.valueOf(String.isBlank(orLine.InvoiceAmountIncVat)? '0':orLine.InvoiceAmountIncVat);
                      invoiceIt.Tax_Amount__c = Decimal.valueOf(String.isBlank(orLine.TaxAmount)? '0':orLine.TaxAmount);
                      invoiceItemList.add(invoiceIt);
                  }
              }
              List<Database.upsertResult> resultsOrder = Database.upsert(invoiceList,Invoice__c.Fields.SAP_Invoice_No__c,false);

              DateTime maxt1= System.Now();
              Long minms1 = mint.getTime(), maxms1 = maxt1.getTime(), diff1 = maxms1 - minms1;
              //日志内容
              String errorMsg1 = '插入更新invoice表,开始时间：' + mint.time()+ ',结束时间：' + maxt1.time() + ',时间差：' + diff1 + ',毫秒';
              Utility.insertLog('SAPGetInvoiceLog', '3', '', errorMsg1);

              List<String> customerNotExistList = new List<String>();
              Set<String> customerNotExistListNew = new Set<String>();
              for(Database.upsertResult dbur : resultsOrder){
                  if(dbur.isSuccess() == false){
                      for(Database.Error error : dbur.getErrors()){
                          customerNotExistList.add(error.message);
                      }
                  }
              }
              for(String cnel : customerNotExistList){
                  customerNotExistListNew.add(cnel.substring(25,35));
              }

              bodyUserNotExist = JSON.serialize(customerNotExistListNew);
              //发票行挂发票头
              for (Invoice__c invo : invoiceList) {
                  if (invoiceMap.get(invo.SAP_Invoice_No__c)==null) {
                      continue;
                  }
                  for (Invoice_Item__c invoiceIt : invoiceMap.get(invo.SAP_Invoice_No__c)) {
                      invoiceIt.Invoice__c = invo.Id;
                      invoiceIt.External_Key__c = invo.SAP_Invoice_No__c+invoiceIt.SAP_Invoice_Line_No__c;
                  }
              }
              if(errorStringCannotFindOrderItem.size() > 0){
                  Utility.insertLog('SAPGetInvoiceLog', '0', '', JSON.serialize(errorStringCannotFindOrderItem));
              }
              List<Database.upsertResult> resultsOrderItem = Database.upsert(invoiceItemList,Invoice_Item__c.Fields.External_Key__c,false);
              List<String> invoiceItemUpsertError = new List<String>();
              for(Database.upsertResult dbur : resultsOrderItem){
                  if(dbur.isSuccess() == false){
                      for(Database.Error error : dbur.getErrors()){
                          invoiceItemUpsertError.add(error.message);
                      }
                  }
              }
              System.debug('invoiceItemUpsertError: ' +invoiceItemUpsertError);

              Database.update(updateCustomerProduct);
              DateTime maxt2 = System.Now();
              Long minms2 = mint.getTime(), maxms2 = maxt2.getTime(), diff2 = maxms2 - minms2;
              //日志内容
              String errorMsg2 = '更新CustomerProduct表,开始时间：' + mint.time()+ ',结束时间：' + maxt2.time() + ',时间差：' + diff2 + ',毫秒';
              Utility.insertLog('SAPGetInvoiceLog', '4', '', errorMsg2);

              Database.update(accList);
              DateTime maxt3 = System.Now();
              Long minms3 = mint.getTime(), maxms3 = maxt3.getTime(), diff3 = maxms3 - minms3;
              //日志内容
              String errorMsg3 = '插入更新Account表,开始时间：' + mint.time()+ ',结束时间：' + maxt3.time() + ',时间差：' + diff3 + ',毫秒';
              Utility.insertLog('SAPGetInvoiceLog', '5', '', errorMsg3);

          }catch (Exception e) {
              DateTime maxt = System.Now();
              Long minms = mint.getTime(), maxms = maxt.getTime(), diff = maxms - minms;
              //日志内容
              String errorMsg = '新建数据出错'+e.getMessage()+e.getLineNumber() + ',开始时间：' + mint.time()+ ',结束时间：' + maxt.time() + ',时间差：' + diff + ',毫秒';
              Utility.insertLog('SAPGetInvoiceLog', '9', '', errorMsg);
              return; 
          }
          //日志内容
          String exportModelNotExistString;
          if(exportModelNotExistList == null){
              exportModelNotExistString = '';
          }else{
              exportModelNotExistString = JSON.serialize(exportModelNotExistList);
          }
          String customerModelNotExistString;
          if(customerModelNotExistList == null){
              customerModelNotExistString = '';
          }else{
              customerModelNotExistString = JSON.serialize(customerModelNotExistList);
          }

          DateTime maxt = System.Now();
          Long minms = mint.getTime(), maxms = maxt.getTime(), diff = maxms - minms;
          //日志内容
          Utility.insertLog('SAPGetInvoiceLog', '6', '', ',开始时间：' + mint.time()+ ',结束时间：' + maxt.time() + ',时间差：' + diff + '毫秒');
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

}