/**********************************************************************
* Name: SAPGetSalesOrder
* Object: Order 
* Purpose: 
* SAP中的订单信息每天定时，以增量的形式传递给salesforce
* Author: Gerry
* Create Date: 2019-03-05
*************************************************************************/
public with sharing class SAPGetSalesOrderLog {
    
    private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_SALESORDER_SEND';
    private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    private static String password = Interface_Url__c.getValues('SAP').Password__c;

    public class Output{
        List<String> CompanyCodeList;
        String SyncStartDate;
        String SyncEndDate;
        List<String> OrderTypeCodeList;
    }

    public class Input{
        public List<OrderList> OrderList;
        public String IsSuccess;
        public String FailReason;
    }
    
    public class OrderList {
        public String SapOrderNo;
        public String SapCustomerCode;
        public String OrderStatus;
        public String OrderAmount;
        public String SFCurrency;
        public String OrderDate;
        public String OrderTypeCode;
        public String OrderTypeName;
        public String PurchaseOrderNo;
        public String VirtualOrderNo;
        public String HisenseEntity;
        public List<OrderLine> OrderLine;
        //add by johnson 20190709
        public String SAPCustomerName;
        public String SAPCustomerCity;
        public String SAPCustomerRegion;
        public String SAPShiptoCode;
        public String SAPShiptoName;
        public String SAPShiptoCity;
        public String SAPShiptoRegion;
        public String SAPBilltoCode;
        public String SAPBilltoName;
        public String SAPBilltoCity;
        public String SAPBilltoRegion;
        public String SalesOffice;
        public String SalesGroup;
        public String PODATE;
        public String ReqDelivDate;
        public String ShippingWindowFrom;
        public String ShippingWindowTo;
        public String SalesOfficeDesc;
        public String SalesGroupDesc;
        public String NotesForSalesOrder;
        //add by johnson 20190722
        public String TaxAmount;
        public String TotalAmountIncTax;
    }

    public class OrderLine {
        public String SapOrderItemNo;
        public String ProductCustomerModel;
        public String ProductFactoryModel;
        public String ProductExportModel;
        public String UnitPrice;
        public String Quantity;
        public String TotalSalesAmount;
        public String PlannedDeliveryDate;
        public String SapProductLine;
        public String MaterialNumber;
        public String isDeleted;
        //add by johnson 20190709
        public String StorageLocation;
        public String BatchNumber;
        public String TotalAmountAfterRebate;
        public String Brand;
        public String EAN;
        //add by johnson 20190722
        public String TaxAmount;
        public String TotalAmountIncTax;

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
    @Future(callout =true)
    public static void getSalesOrderFromSAP(List<String> companyCodeList,String syncStartDate,String syncEndDate,List<String> orderTypeCodeList){
        // 方法执行开始时间
        DateTime mint = System.Now();
        system.debug('mint:' + mint);

        Datetime startTime = System.now();
        Output out = new Output();
        out.CompanyCodeList = companyCodeList;
        out.SyncStartDate = syncStartDate;
        out.SyncEndDate = syncEndDate;
        out.OrderTypeCodeList = orderTypeCodeList;
        String body = JSON.serialize(out);
        System.debug('url:' + url);
        System.debug('body:' + body);
        String bodyRes;
        String body111;
        Input input;
        try {
            Blob headerValue = Blob.valueOf(user + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            //信息同步
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();              
            req.setEndpoint(url);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', authorizationHeader);
            req.setBody(body);
            req.setTimeout(120000); // timeout in milliseconds
            res = http.send(req);
            bodyRes = res.getBody();
            System.debug('bodyRes... '+bodyRes);
            // input= (SAPGetSalesOrderLog.Input)JSON.deserialize(bodyRes, SAPGetSalesOrderLog.Input.class);

            // 发送预警邮件
            try {
                if(bodyRes.length() > 1024 * 1024 * 6){
                    sendingEmail2Submitter(CompanyCodeList, SyncStartDate, SyncEndDate, orderTypeCodeList);
                }
            } catch (Exception e) {
                
            }

             // 当前时间N分钟，下一次定时时间
             DateTime reTime = System.Now().addMinutes(2);
             Integer minute = reTime.minute();
             Integer hour = reTime.hour();  
             String con = '0 ' + minute + ' ' + hour + ' * * ?';
 
             // 生成唯一值
             Blob b = Crypto.GenerateAESKey(128);
             String h = EncodingUtil.ConvertTohex(b);
             System.schedule(h, con, new SAPSalesOrderParsingSchedulable(bodyRes, h));
             // System.schedule(h, con, new SAPInvoiceParsingSchedulable(input, h));
             
             // 方法执行结束时间
             DateTime maxt = System.Now();
             system.debug('maxt:' + maxt);
             Long minms = mint.getTime(), maxms = maxt.getTime(), diff = maxms - minms;
             // 日志内容
             Utility.insertLog('SAPGetSalesOrderLog', '1', body, ',sfdc调用获取订单信息接口成功！,开始时间：' + mint.time()+ ',结束时间：' + maxt.time() + ',时间差：' + diff + '毫秒');  
        }
        catch (Exception e) {
            DateTime maxt = System.Now();
            Long minms = mint.getTime(), maxms = maxt.getTime(), diff = maxms - minms;
            String errorMsg = 'sfdc调用获取订单信息接口失败！,开始时间：' + mint.time()+ ',结束时间：' + maxt.time() + ',时间差：' + diff + '毫秒';
            //日志内容
            Utility.insertLog('SAPGetSalesOrderLog', '0', body, errorMsg);
            return;  
        }

        // if (input.IsSuccess == 'False') {
        //     String errorMsg = input.FailReason;
        //     //日志内容
        //     Utility.insertLog('SAPGetSalesOrder', '0', body, errorMsg);
        //     return;
        // }

        // if (!(input.OrderList == null || input.OrderList.isEmpty())) {
        //     List<Order__c> orderInsertList = new List<Order__c>();
        //     List<Order_Product__c> orderProductList = new List<Order_Product__c>();
        //     //Export Model Product Not Exist Error Log List
        //     List<ErrorMessageFactoryModel> exportModelNotExistList = new List<ErrorMessageFactoryModel>();
        //     //customer Model Product Not Exist Error Log List
        //     List<ErrorMessageCustomerModel> customerModelNotExistList = new List<ErrorMessageCustomerModel>();
        //     try {
        //         //客户编码集合
        //         Set<String> sapCustomerCodeSet = new Set<String>();
        //         //工厂型号集合
        //         Set<String> factoryModelSet = new Set<String>();
        //         //出口型号集合
        //         Set<String> exportModelSet = new Set<String>();
        //         //产品线code集合
        //         Set<String> mpSet = new Set<String>();
        //         //客户型号集合
        //         Set<String> productCustomerModelSet = new Set<String>();
        //         Set<String> sapOrderItemExternalKey = new Set<String>();
        //         for (OrderList orList : input.OrderList) {
        //             sapCustomerCodeSet.add(orList.SapCustomerCode);
        //             if (!(orList.OrderLine!=null&&orList.OrderLine.size()>0)) {
        //                 continue;
        //             }
        //             for (OrderLine orLine : orlist.OrderLine) {
        //                 exportModelSet.add(orLine.ProductExportModel);
        //                 exportModelSet.add(orLine.ProductFactoryModel);
        //                 if (String.isNotBlank(orLine.ProductFactoryModel)) {
        //                     factoryModelSet.add(orLine.ProductFactoryModel);
        //                 }
        //                 mpSet.add(orLine.SapProductLine);
        //                 productCustomerModelSet.add(orLine.productCustomerModel);
        //                 sapOrderItemExternalKey.add(orList.SapOrderNo + orLine.SapOrderItemNo);
        //             }
        //         }

        //         Set<String> hisenseSet = new Set<String>();
        //         Map<String,String> accMap = new Map<String,String>();
        //         //客户编码对应的ID
        //         Map<String,ID> accIdMap = new Map<String,ID>();
        //         //找不到客户的时候  挂到这个客户下面
        //         List<Account> notFoundCustomer = [SELECT ID,SAP_Customer_Code__c FROM Account WHERE SAP_Customer_Code__c ='CANNOTFINDCUSTOMERORDER'];

        //         //对应的客户
        //         for (Account acc : [SELECT Id,SAP_Customer_Code__c,Hisense_Entity__c,Sales_Region__c FROM Account WHERE SAP_Customer_Code__c IN:sapCustomerCodeSet]) {
        //             hisenseSet.add(acc.Sales_Region__c);
        //             accMap.put(acc.SAP_Customer_Code__c, acc.Sales_Region__c);
        //             accIdMap.put(acc.SAP_Customer_Code__c, acc.Id);
        //         }

        //         Map<String,ID> modelMap = new Map<String,ID>();
        //         Map<String,ID> modelMapMobileandOther = new Map<String,ID>();
        //         //对应的客户型号
        //         for (Customer_Model_Product__c cmp : [SELECT Id,Name,Country_Code__c,Product_Line__c FROM Customer_Model_Product__c WHERE Name IN :productCustomerModelSet]) {
        //             if('TV'.equals(cmp.Product_Line__c) || 'Laser TV'.equals(cmp.Product_Line__c) || 'AC'.equals(cmp.Product_Line__c) || 'LCAC'.equals(cmp.Product_Line__c) || 'WM'.equals(cmp.Product_Line__c) || 'Refrigerator'.equals(cmp.Product_Line__c) || 'Freezer'.equals(cmp.Product_Line__c)){
        //                 modelMap.put(cmp.Name.toUpperCase()+cmp.Country_Code__c, cmp.Id);
        //             }else{
        //                 modelMapMobileandOther.put(cmp.Name.toUpperCase(), cmp.Id);
        //             }
        //         }

        //         Map<String,ID> factoryMap = new Map<String,ID>();
        //         //对应的产品线
        //         for (Product__c pro : [SELECT ID,Name FROM Product__c WHERE Name IN :exportModelSet]) {
        //             factoryMap.put(pro.Name.toUpperCase(), pro.Id);
        //         }

        //         Map<String,List<Mapping__c>> mpMap = new Map<String,List<Mapping__c>>();
        //         Map<String,String> businessScope2ProductLineMapping = new Map<String,String>();
        //         for (Mapping__c mp : [SELECT ID,Name,RecordType.DeveloperName,Mapping_Code__c FROM Mapping__c WHERE Name IN :mpSet]) {
        //             businessScope2ProductLineMapping.put(mp.Name,mp.Mapping_Code__c);
        //             if (mpMap.containsKey(mp.Name)) {
        //                 mpMap.get(mp.Name).add(mp);
        //             }else{
        //                 mpMap.put(mp.Name, new List<Mapping__c>{mp});
        //             }
        //         }
        //         String recordTypeID = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();

        //         Map<String,List<Id>> productRelationMap = new Map<String,List<Id>>();
        //         //Product_Relation__c中Product_Export_Model__c中存的值是sap中的ProductFactoryModel，Factory_Model__c是lookup到product
        //         for (Product_Relation__c pr : [SELECT Factory_Model__c,Product_Export_Model__c FROM Product_Relation__c WHERE Product_Export_Model__c IN:factoryModelSet]) {
        //             if (productRelationMap.containsKey(pr.Product_Export_Model__c.toUpperCase())) {
        //                 productRelationMap.get(pr.Product_Export_Model__c.toUpperCase()).add(pr.Factory_Model__c);
        //             }else{
        //                 productRelationMap.put(pr.Product_Export_Model__c.toUpperCase(), new List<Id>{pr.Factory_Model__c});
        //             }
        //         }

        //         Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateMap();
        //         Decimal rate;
        //         Map<String,List<Order_Product__c>> tempOrderProMap = new Map<String,List<Order_Product__c>>();

        //         for (OrderList orList : input.OrderList) {
        //             Order__c order = new Order__c();
        //             orList.SFCurrency = orList.SFCurrency.equals('HK$')? 'HKD':orList.SFCurrency;
        //             order.External_Key__c = orlist.SapOrderNo+orlist.SapCustomerCode;
        //             order.Hisense_Entity__c = orList.HisenseEntity;
        //             order.SAP_Order_No__c = orList.SapOrderNo;
        //             order.SAP_Customer_Code__c = orlist.SapCustomerCode;
        //             order.Order_Status__c = orList.OrderStatus;
        //             order.CurrencyIsoCode = orList.SFCurrency;
        //             order.Order_Amount__c = Decimal.valueOf(String.isBlank(orList.OrderAmount)? '0':orList.OrderAmount);
        //             if (String.isNotBlank(orList.OrderDate)) {
        //                 order.Order_Date__c = Date.valueOf(orList.OrderDate);
        //             }else{
        //                 order.Order_Date__c = null;
        //             }
        //             //如果订单中客户编码对应的客户找不到  就挂到一个特殊客户下
        //             if (String.isNotBlank(orList.SapCustomerCode)&&accIdMap.get(orList.SapCustomerCode)==null) {
        //                 order.Customer__c = notFoundCustomer[0].Id;
        //             }else{
        //                 order.Customer__c = accIdMap.get(orList.SapCustomerCode);
        //             }
        //             order.Order_Classification__c = 'S';//固定值

        //             order.Order_Type_Code__c = orList.OrderTypeCode;
        //             order.Order_Type_Name__c = orList.OrderTypeName;
        //             order.Purchase_Order_No__c = orList.PurchaseOrderNo;
        //             order.Virtual_Order_No__c = orList.VirtualOrderNo;
        //             //add by johnson 20190709
        //             order.SAP_Customer_Name__c = orList.SAPCustomerName;
        //             order.SAP_Customer_City__c = orList.SAPCustomerCity;
        //             order.SAP_Customer_Region__c = orList.SAPCustomerRegion;
        //             order.SAP_Ship_to_Code__c = orList.SAPShiptoCode;
        //             order.SAP_Ship_to_Name__c = orList.SAPShiptoName;
        //             order.SAP_Ship_to_City__c = orList.SAPShiptoCity;
        //             order.SAP_Ship_to_Region__c = orList.SAPShiptoRegion;
        //             order.SAP_Bill_to_Code__c = orList.SAPBilltoCode;
        //             order.SAP_Bill_to_Name__c = orList.SAPBilltoName;
        //             order.SAP_Bill_to_City__c = orList.SAPBilltoCity;
        //             order.SAP_Bill_to_Region__c = orList.SAPBilltoRegion;
        //             order.Sales_Office__c = orList.SalesOffice;
        //             order.Sales_Group__c = orList.SalesGroup;
        //             order.PODATE__c = orList.PODATE;
        //             order.Req_Deliv_Date__c = orList.ReqDelivDate;
        //             order.Shipping_Window_From__c = orList.ShippingWindowFrom;
        //             order.Shipping_Window_To__c = orList.ShippingWindowTo;
        //             order.Sales_Office_Desc__c = orList.SalesOfficeDesc;
        //             order.Sales_Group_Desc__c = orList.SalesGroupDesc;
        //             order.Notes_For_Sales_Order__c = orList.NotesForSalesOrder;
        //             //add by johnson 20190722
        //             order.Tax_Amount__c = Decimal.valueOf(String.isBlank(orList.TaxAmount)? '0':orList.TaxAmount);
        //             order.Total_Amount_Inc_Tax__c = Decimal.valueOf(String.isBlank(orList.TotalAmountIncTax)? '0':orList.TotalAmountIncTax);
        //             orderInsertList.add(order);
        //             if (!(orList.OrderLine!=null&&orList.OrderLine.size()>0)) {
        //                 continue;
        //             }
        //             for (OrderLine orLine : orList.OrderLine) {
        //                 String salesforceProductLine = businessScope2ProductLineMapping.get(orLine.SapProductLine);
        //                 Order_Product__c orderProduct = new Order_Product__c();
        //                 orderProduct.Material_Number__c = orLine.MaterialNumber;
        //                 orderProduct.SAP_Order_Item_No__c = orLine.SapOrderItemNo;
        //                 orderProduct.SAP_Product_Line_SO__c = orLine.SapProductLine;
        //                 if('TV'.equals(salesforceProductLine) || 'AC'.equals(salesforceProductLine) || 'Laser TV'.equals(salesforceProductLine) || 'LCAC'.equals(salesforceProductLine) || 'Refrigerator'.equals(salesforceProductLine) || 'Freezer'.equals(salesforceProductLine) || 'WM'.equals(salesforceProductLine)){
        //                     orderProduct.Customer_Model_Product__c = modelMap.get(orLine.productCustomerModel.toUpperCase()+accMap.get(orList.SapCustomerCode));
        //                 }else{//手机&小家电
        //                     orderProduct.Customer_Model_Product__c = modelMapMobileandOther.get(orLine.productCustomerModel.toUpperCase());
        //                 }
        //                 orderProduct.CurrencyIsoCode = orList.SFCurrency;
        //                 orderProduct.Unit_Price__c = Decimal.valueOf(String.isBlank(orLine.UnitPrice)? '0':orLine.UnitPrice);
        //                 orderProduct.Total_Sales_Amount__c = Decimal.valueOf(String.isBlank(orLine.TotalSalesAmount)? '0':orLine.TotalSalesAmount);
        //                 orderProduct.Quantity__c = Decimal.valueOf(String.isBlank(orLine.Quantity)? '0':orLine.Quantity);
        //                 if (String.isNotBlank(orLine.PlannedDeliveryDate)) {
        //                     orderProduct.Planned_Delivery_Date__c = Date.valueOf(orLine.PlannedDeliveryDate);
        //                 }else{
        //                     orderProduct.Planned_Delivery_Date__c = null;
        //                 }
        //                 String productLine;
        //                 if (String.isNotBlank(orLine.SapProductLine)&&mpMap.get(orLine.SapProductLine)!=null) {
        //                     for (Mapping__c mp : mpMap.get(orLine.SapProductLine)) {
        //                         if (recordTypeID.equals(mp.RecordTypeId)) {
        //                             orderProduct.SAP_Product_Line__c = mp.Id;
        //                             productLine = mp.Mapping_Code__c;
        //                             break;
        //                         }
        //                     }
        //                 }else{
        //                     orderProduct.SAP_Product_Line__c = null;
        //                 }
        //                 orderProduct.Product_Factory_Model__c = orLine.ProductFactoryModel;
        //                 orderProduct.SAP_Product_Export_Model__c = orLine.ProductExportModel;
        //                 orderProduct.SAP_Product_Customer_Model__c = orLine.ProductCustomerModel;
        //                 if ('Refrigerator'.equals(productLine)||'Freezer'.equals(productLine)||'WM'.equals(productLine)) {
        //                     //当产品线位冰冷洗的时候通过SAP过来的工厂型号去Relation中查询相应的出口型号
        //                     List<Id> IdList = productRelationMap.get(orLine.ProductFactoryModel.toUpperCase());
        //                     orderProduct.Product_Export_Model__c = IdList==null? null:IdList[0];
        //                 }else if ('Laser TV'.equals(productLine)||'TV'.equals(productLine)||'Mobile'.equals(productLine)) {
        //                     //当产品线为TV 或者Mobile的时候通过sap过来的工厂型号去找到相应的product
        //                     orderProduct.Product_Export_Model__c = factoryMap.get(orLine.ProductFactoryModel.toUpperCase());
        //                 }else{
        //                     //其他的产品线通过sap过来的出口型号找到对应的product
        //                     orderProduct.Product_Export_Model__c = factoryMap.get(orLine.ProductExportModel.toUpperCase());
        //                 }
        //                 if (tempOrderProMap.containsKey(order.External_Key__c)) {
        //                     tempOrderProMap.get(order.External_Key__c).add(orderProduct);
        //                 }else{
        //                     tempOrderProMap.put(order.External_Key__c, new List<Order_Product__c>{orderProduct});
        //                 }
        //                 //add by johnson 20190709
        //                 orderProduct.Storage_Location__c = orLine.StorageLocation;
        //                 orderProduct.Batch_Number__c = orLine.BatchNumber;
        //                 orderProduct.Total_Amount_After_Rebate__c = Decimal.valueOf(String.isBlank(orLine.TotalAmountAfterRebate)? '0':orLine.TotalAmountAfterRebate);
        //                 orderProduct.Brand__c = orLine.Brand;
        //                 orderProduct.EAN__c = orLine.EAN;
        //                 //add by johnson 20190722
        //                 orderProduct.Tax_Amount__c = Decimal.valueOf(String.isBlank(orLine.TaxAmount)? '0':orLine.TaxAmount);
        //                 orderProduct.Total_Amount_Inc_Tax__c = Decimal.valueOf(String.isBlank(orLine.TotalAmountIncTax)? '0':orLine.TotalAmountIncTax);
        //                 orderProductList.add(orderProduct);
        //             }
        //         }  
        //         //System.debug('orderInsertList:'+orderInsertList);
        //         List<Database.upsertResult> resultsOrder = Database.upsert(orderInsertList,Order__c.Fields.External_Key__c,false);
        //         List<String> customerNotExistList = new List<String>();
        //         Set<String> customerNotExistListNew = new Set<String>();
        //         //错误信息获取
        //         for(Database.upsertResult dbur : resultsOrder){
        //             if(dbur.isSuccess() == false){
        //                 for(Database.Error error : dbur.getErrors()){
        //                     customerNotExistList.add(error.message);
        //                     //System.debug('error:'+error.message);
        //                 }
        //             }
        //         }
        //         for(String cnel : customerNotExistList){
        //             customerNotExistListNew.add(cnel.substring(25,35));
        //         }
        //         body111 = JSON.serialize(customerNotExistListNew);
        //         //订单行挂到订单头上
        //         for (Order__c ord : orderInsertList) {
        //             if (tempOrderProMap.get(ord.External_Key__c)==null) {
        //                 continue; 
        //             }
        //             for (Order_Product__c orderProduct : tempOrderProMap.get(ord.External_Key__c)) {
        //                 orderProduct.Order__c = ord.Id;
        //                 orderProduct.External_Key__c = ord.SAP_Order_No__c+orderProduct.SAP_Order_Item_No__c;
        //             }
        //         }
        //         List<Database.upsertResult> resultsOrderItem = Database.upsert(orderProductList,Order_Product__c.Fields.External_Key__c,false);
        //     }catch (Exception e) {
        //         System.debug(e.getMessage()+e.getLineNumber());
        //         String errorMsg = '新建数据出错'+e.getMessage()+ ' 行号：' + e.getLineNumber();
        //         //日志内容
        //         Utility.insertLog('SAPGetSalesOrder', '0', body, errorMsg);
        //         return;
        //     }

        //     String exportModelNotExistString ;
        //     //System.debug('exportModelNotExistList... '+exportModelNotExistList.size());
        //     //System.debug('customerModelNotExistList... '+customerModelNotExistList.size());
        //     if(exportModelNotExistList == null){
        //         exportModelNotExistString = '';
        //     }else{
        //         exportModelNotExistString = JSON.serialize(exportModelNotExistList);
        //     }
        //     String customerModelNotExistString ;
        //     if(customerModelNotExistList == null){
        //         customerModelNotExistString = '';
        //     }else{
        //         customerModelNotExistString = JSON.serialize(customerModelNotExistList);
        //     }
        //     //System.debug('exportModelNotExistString... '+exportModelNotExistString);
        //     //System.debug('customerModelNotExistString... '+customerModelNotExistString);
        //     //日志内容
        //     Utility.insertLog('SAPGetSalesOrder', '1', body, body111);
        // }
    }

    private static void sendingEmail2Submitter(List<String> CompanyCodeList,String SyncStartDate,String SyncEndDate,List<String> orderTypeCodeList){
        // List<String> pIdList = new List<String>();
        // for(Profile p : [select id,name from Profile where name in ('System Admin','System Administrator')]){
        //     pIdList.add(p.Id);
        // }
    
        List<string> emailList = new List<string>();
        // for(User u : [select Id,Name,Email from User where ProfileId in: pIdList]){
        //     emailList.add(u.Email);
        // } 
        emailList.add('qinyanhao@hisense.com');
        //Email list
        Messaging.SingleEmailMessage[] theEmails = new Messaging.SingleEmailMessage[]{};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();       
        String emailBody = '<span style="display: inline-block; width:28px;">国家编号：</span> ' + CompanyCodeList.toString()  + '<br/> ' +
        '<span style="display: inline-block; width:28px;">订单类型：</span> ' + orderTypeCodeList.toString()  + '<br/> '+
        '<span style="display: inline-block; width:28px;">开始时间：</span> ' + SyncStartDate  + '<br/> '+
        '<span style="display: inline-block; width:28px;">结束时间：</span> ' + SyncEndDate;
        mail.setToAddresses(emailList);
        mail.setSenderDisplayName('CRM System Reminder');
        mail.setSubject('SAP拉取订单数量过多预警！');
        mail.setHtmlBody(emailBody);
        theEmails.add(mail);
            //}
        Messaging.Email[] allMails = new Messaging.Email[]{};
        for(Integer j = 0; j < theEmails.size(); j++) {
            allMails.add(theEmails.get(j));
        }

        System.debug('allMails:: '+allMails);
            // Print error information
        Messaging.SendEmailResult[] results = Messaging.sendEmail(allMails);
        System.debug('results... '+results);
        Messaging.SendEmailError[] errors = new Messaging.SendEmailError[]{};
        String emailErrorReport = '';
        for(Messaging.SendEmailResult currentResult : results) {
            errors = currentResult.getErrors();
            if(null != errors) {
                for(Messaging.SendEmailError currentError : errors) {
                emailErrorReport = emailErrorReport + ' (' + currentError.getStatusCode() + ') ' + currentError.getMessage();
                System.debug('emailErrorReport... '+emailErrorReport);
                }
            }
        }
    }
}