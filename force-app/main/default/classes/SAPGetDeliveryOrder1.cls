/**********************************************************************
* Name: SAPGetDeliveryOrder1
* Object: DeliveryOrder 
* Purpose: 
* SAP中的发货单信息每天定时，以增量的形式传递给salesforce
* Author: Gerry
* Create Date: 2019-03-06
*************************************************************************/
public with sharing class SAPGetDeliveryOrder1 {

    private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_DELIVERYORDER_SEND';
    private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    private static String password = Interface_Url__c.getValues('SAP').Password__c;

    // private static String url = 'https://crmxip.hisense.com:8443/RESTAdapter/'+ 'CC_REST_DELIVERYORDER_SEND';
    // private static String user = 'xiaxiaoyang';
    // private static String password = 'hs123456';
    
    public class Output{
        List<String> CompanyCodeList;
        String SyncStartDate;
        String SyncEndDate;
        List<String> OrderTypeCodeList;
    }

    public class Input{
        public List<OrderList> orderList;
        public String isSuccess;
        public String failReason;
        public String token;
    }

    public class OrderList{
        public String deliveryOrderNo;
        public String deliveryOrderStatus;
        public String actualDeliveryDate;
        public String podStatus;
        public String SAPCustomerCode;
        public String HisenseEntity;
        public List<OrderLine> orderLine;
        //add by johnson 20190709
        public String PlannedGIDate;
        public String PickingDate;
        public String DeliveryDate;
        public String Date940;
        public String Date945;
        public String CreateDate;
        public String LoadingDate;
        public String TransPlanningDate;
        public String BillOfLad;
        public String GRGISlip;
        public String ExtDelivery;
        public String NotesForShipment;
        //add by johnson 20190722
        public String SpecialInstruction;
        public String ShippingMemo;
        public String CarrierName;
        public String SealNumber;
        public String SCACNumber;
        public String LoadID;
        public String TotalAmount;

    }

    public class OrderLine{
        public String deliveryOrderItemNo;
        public String salesOrderNo;
        public String salesOrderItemNo;
        public String productCustomerModel;
        public String productExportModel;
        public String productFactoryModel;
        public String DeliveryQuantity;
        public String deliveryOrderItemStatus;
        public String podQuantity;
        public String podReason;
        public String podLineStatus;
        public String podDate;
        public String productLine;
        public String MaterialNumber;
        public String isDeleted;
        //add by johnson 20190709
        public String Batch;
        //add by johnson 20190722
        public String UnitPrice;
        public String TotalAmount;
    }

    public class ErrorMessageFactoryModel {
        public String ErrorMessageProductExportModel;
        public String ErrorMessageProductFactoryModel;
        public String ErrorMessageSapProductLine;
        public String ErrorMessageSalesforceProductLine;
        public String ErrorMessageCustomerSAPCode;
        public String ErrorMessageOrderNumber;
        public String ErrorMessageOrderLineItemNumber;
        public String ErrorMessageHisenseEntity;
        public String ErrorMessageSalesRegion;
    }

    public class ErrorMessageCustomerModel {
        public String ErrorMessageProductCustomerModel;
        public String ErrorMessageSapProductLine;
        public String ErrorMessageSalesforceProductLine;
        public String ErrorMessageCustomerSAPCode;
        public String ErrorMessageOrderNumber;
        public String ErrorMessageOrderLineItemNumber;
        public String ErrorMessageHisenseEntity;
        public String ErrorMessageSalesRegion;
    }
    @Future(callout =true)
    public static void getDeliveryOrderFromSAP(List<String> CompanyCodeList,String SyncStartDate,String SyncEndDate,List<String> orderTypeCodeList){
        Output out = new Output();
        out.CompanyCodeList = CompanyCodeList;
        out.SyncStartDate = SyncStartDate;
        out.SyncEndDate = SyncEndDate;
        out.OrderTypeCodeList = orderTypeCodeList;
        String body = JSON.serialize(out);
        String bodyUserNotExist = '';
        SAPGetDeliveryOrder1.Input input = new SAPGetDeliveryOrder1.Input();
        String bodyRes_login;
        try {
            Blob headerValue = Blob.valueOf(user + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            //登陆获取token
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http_login = new Http();    
            request.setEndpoint(url);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', authorizationHeader);
            request.setBody(body);
            request.setTimeout(120000); // timeout in milliseconds
            response = http_login.send(request);
            bodyRes_login = response.getBody();
            //System.debug('bodyRes:' + bodyRes_login);
            input =(SAPGetDeliveryOrder1.Input)JSON.deserialize(bodyRes_login,SAPGetDeliveryOrder1.Input.class );
            System.debug('~~~~~~~~~~~~~~');               
        }catch (Exception e) {
            String errorMsg = 'sfdc调用获取发货单信息接口失败'+e.getMessage();
            //日志内容
            Utility.insertLog('SAPGetDeliveryOrder1', '0', body, errorMsg);
            return; 
        }

        if (input.isSuccess == 'False') {
            String errorMsg = input.failReason;
            //日志内容   
            if(errorMsg.equals('No data')){
                Utility.insertLog('SAPGetDeliveryOrder1', '1', body, errorMsg);
            }else {
                Utility.insertLog('SAPGetDeliveryOrder1', '0', body, errorMsg);
            }
            return;
        }

        if (!(input.orderList == null || input.orderList.isEmpty())) {
            //Export Model Product Not Exist Error Log List
            List<ErrorMessageFactoryModel> exportModelNotExistList = new List<ErrorMessageFactoryModel>();
            //customer Model Product Not Exist Error Log List
            List<ErrorMessageCustomerModel> customerModelNotExistList = new List<ErrorMessageCustomerModel>();
            
            List<Delivery_Order__c> deliveryOrderList = new List<Delivery_Order__c>();
            List<Delivery_Order_Item__c> deOrderItemList = new List<Delivery_Order_Item__c>();
            List<Id> deleteDeliveryOrderItem = new List<Id>();
            try {
                //订单编号集合
                Set<String> orderSet = new Set<String>();
                Set<String> orderProductSet = new Set<String>();
                //工厂型号集合
                Set<String> productFactoryModelSet = new Set<String>();
                //客户型号集合
                Set<String> productCustomerModelSet = new Set<String>();
                Set<String> deliveryOrderItemNoSet = new Set<String>();
                //产品线集合
                Set<String> mpSet = new Set<String>();
                //sap客户编码集合
                Set<String> sapCustomerCodeSet = new Set<String>();
                //出口型号编码
                Set<String> exportModelSet = new Set<String>();
                //modified by johnson20190808
                Set<String> errorStringCannotFindOrderItem = new Set<String>();

                for (OrderList orList : input.orderList) {
                    sapCustomerCodeSet.add(orList.SAPCustomerCode);
                    if (!(orList.OrderLine!=null&&orList.OrderLine.size()>0)) {
                        continue;
                    }
                    for (OrderLine orLine : orList.orderLine) {
                        orderSet.add(orline.salesOrderNo);
                        orderProductSet.add(orLine.salesOrderNo + orline.salesOrderItemNo);
                        if (String.isNotBlank(orLine.productFactoryModel)) {
                            productFactoryModelSet.add(orLine.productFactoryModel);
                        }
                        productCustomerModelSet.add(orLine.productCustomerModel);
                        deliveryOrderItemNoSet.add(orList.deliveryOrderNo + orLine.deliveryOrderItemNo);
                        mpSet.add(orLine.productLine);
                        exportModelSet.add(orLine.productExportModel);
                        exportModelSet.add(orLine.productFactoryModel);
                    }
                }

                Set<String> hisenseSet = new Set<String>();
                Map<String,String> accMap = new Map<String,String>();
                Map<String,String> customerSAPCode2HisenseEntityMap = new Map<String,String>();
                //客户编码对应的acc
                Map<String,ID> accIdMap = new Map<String,ID>();
                //客户编码找不到客户  就挂到这个客户上
                List<Account> notFoundCustomer = [SELECT Id,SAP_Customer_Code__c FROM Account WHERE SAP_Customer_Code__c='CANNOTFINDCUSTOMERORDER'];
                //对应的客户
                for (Account acc : [SELECT Id,SAP_Customer_Code__c,Hisense_Entity__c,Sales_Region__c FROM Account WHERE SAP_Customer_Code__c IN:sapCustomerCodeSet]) {
                    hisenseSet.add(acc.Sales_Region__c);
                    accMap.put(acc.SAP_Customer_Code__c, acc.Sales_Region__c);
                    customerSAPCode2HisenseEntityMap.put(acc.SAP_Customer_Code__c, acc.Hisense_Entity__c);
                    accIdMap.put(acc.SAP_Customer_Code__c, acc.Id);
                }

                Map<String,ID> modelMap = new Map<String,ID>();
                Map<String,ID> modelMapMobileandOther = new Map<String,ID>();

                //对应的客户型号
                for (Customer_Model_Product__c cmp : [SELECT Id,Country_Code__c,Name,Product_Line__c FROM Customer_Model_Product__c WHERE Name IN :productCustomerModelSet]) {
                    if('TV'.equals(cmp.Product_Line__c) || 'Laser TV'.equals(cmp.Product_Line__c) || 'AC'.equals(cmp.Product_Line__c) || 'LCAC'.equals(cmp.Product_Line__c) || 'WM'.equals(cmp.Product_Line__c) || 'Refrigerator'.equals(cmp.Product_Line__c) || 'Freezer'.equals(cmp.Product_Line__c)){
                        modelMap.put(cmp.Name.toUpperCase() +cmp.Country_Code__c, cmp.Id);
                    }else{
                        modelMapMobileandOther.put(cmp.Name.toUpperCase(), cmp.Id);
                    }
                }

                //对应的产品线
                Map<String,Id> productFactoryModelMap = new Map<String,Id>();
                for (Product__c pr : [SELECT ID,Name FROM Product__c WHERE Name IN :exportModelSet]) {
                    productFactoryModelMap.put(pr.Name.toUpperCase(), pr.Id);
                }

                Map<String,List<Mapping__c>> mpMap = new Map<String,List<Mapping__c>>();
                Map<String,String> businessScope2ProductLineMapping = new Map<String,String>();
                //对应的产品线 businessScope的Mapping
                for (Mapping__c mp : [SELECT ID,Name,RecordType.DeveloperName,Mapping_Code__c FROM Mapping__c WHERE Name IN :mpSet]) {
                    businessScope2ProductLineMapping.put(mp.Name,mp.Mapping_Code__c);
                    if (mpMap.containsKey(mp.Name)) {
                        mpMap.get(mp.Name).add(mp);
                    }else{
                        mpMap.put(mp.Name, new List<Mapping__c>{mp});
                    }
                }

                Map<String,List<Id>> productRelationMap = new Map<String,List<Id>>();
                //对应的产品关系
                for (Product_Relation__c pr : [SELECT Factory_Model__c,Product_Export_Model__c FROM Product_Relation__c WHERE Product_Export_Model__c IN:productFactoryModelSet]) {
                    if (productRelationMap.containsKey(pr.Product_Export_Model__c.toUpperCase())) {
                        productRelationMap.get(pr.Product_Export_Model__c.toUpperCase()).add(pr.Factory_Model__c);
                    }else{
                        productRelationMap.put(pr.Product_Export_Model__c.toUpperCase(), new List<Id>{pr.Factory_Model__c});
                    }
                }

                //对应的订单行
                Map<String,ID> sOrderItemMap = new Map<String,ID>();
                for (Order_Product__c opc : [SELECT Id,Name,SAP_Order_Item_No__c,External_Key__c FROM Order_Product__c WHERE External_Key__c IN :orderProductSet]) {
                    sOrderItemMap.put(opc.External_Key__c, opc.Id);
                }
                String recordTypeID = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();

                Map<String,List<Delivery_Order_Item__c>> deOrderMap = new Map<String,List<Delivery_Order_Item__c>>();
                for (OrderList orList : input.orderList) {
                    Delivery_Order__c deliveryOrder = new Delivery_Order__c();
                    deliveryOrder.Hisense_Entity__c = orList.HisenseEntity;
                    deliveryOrder.SAP_Delivery_Order_No__c = orList.deliveryOrderNo;
                    deliveryOrder.Delivery_Order_Status__c = orList.deliveryOrderStatus;
                    if(String.isNotBlank(orList.actualDeliveryDate)){
                        deliveryOrder.Actual_Delivery_Date__c = Date.valueOf(orList.actualDeliveryDate);
                    }else{
                        deliveryOrder.Actual_Delivery_Date__c = null;
                    }
                    deliveryOrder.POD_Status__c = orList.podStatus;
                    deliveryOrder.SAP_Customer_Code__c = orList.SAPCustomerCode;
                    //如果客户编码对应的客户找不到 就挂到特殊客户上
                    if (String.isNotBlank(orList.SAPCustomerCode)&&accIdMap.get(orList.SAPCustomerCode)==null) {
                        deliveryOrder.Customer__c = notFoundCustomer[0].Id;
                    }else{
                        deliveryOrder.Customer__c = accIdMap.get(orList.SAPCustomerCode);
                    }
                    //add by johnson 20190709
                    deliveryOrder.Planned_GIDate__c = orList.PlannedGIDate;
                    deliveryOrder.Picking_Date__c = orList.PickingDate;
                    deliveryOrder.Delivery_Date__c = orList.DeliveryDate;
                    deliveryOrder.Date940__c = orList.Date940;
                    deliveryOrder.Date945__c = orList.Date945;
                    deliveryOrder.Create_Date__c = orList.CreateDate;
                    deliveryOrder.Loading_Date__c = orList.LoadingDate;
                    deliveryOrder.Trans_Planning_Date__c = orList.TransPlanningDate;
                    deliveryOrder.Bill_Of_Lad__c = orList.BillOfLad;
                    deliveryOrder.GRGISlip__c = orList.GRGISlip;
                    deliveryOrder.ExtDelivery__c = orList.ExtDelivery;
                    deliveryOrder.Notes_For_Shipment__c = orList.NotesForShipment;
                    //add by johnson 20190722
                    deliveryOrder.Special_Instruction__c = orList.SpecialInstruction;
                    deliveryOrder.Shipping_Memo__c = orList.ShippingMemo;
                    deliveryOrder.Carrier_Name__c = orList.CarrierName;
                    deliveryOrder.Seal_Number__c = orList.SealNumber;
                    deliveryOrder.SCAC_Number__c = orList.SCACNumber;
                    deliveryOrder.Load_ID__c = orList.LoadID;
                    deliveryOrder.Total_Amount__c = Decimal.valueOf(String.isBlank(orList.TotalAmount)? '0':orList.TotalAmount);

                    deliveryOrderList.add(deliveryOrder);
                    if (!(orList.OrderLine!=null&&orList.OrderLine.size()>0)) {
                        continue;
                    }
                    for (OrderLine orLine : orList.orderLine) {
                        String salesforceProductLine = businessScope2ProductLineMapping.get(orLine.productLine);
                        Delivery_Order_Item__c deOrderItem = new Delivery_Order_Item__c();
                        deOrderItem.Material_Number__c = orLine.MaterialNumber;
                        String productLine;
                        deOrderItem.Sap_Product_Line_Code__c = orLine.productLine;
                        if (String.isNotBlank(orLine.productLine)&&mpMap.get(orLine.productLine)!=null) {
                            for (Mapping__c mp : mpMap.get(orLine.productLine)) {
                                if (recordTypeID.equals(mp.RecordTypeId)) {
                                    deOrderItem.SAP_Product_Line__c = mp.Id;
                                    productLine = mp.Mapping_Code__c;
                                    break;
                                }
                            }
                        }else{
                            deOrderItem.SAP_Product_Line__c = null;
                        }
                        deOrderItem.SAP_Customer_Model_Product__c = orLine.productCustomerModel;
                        deOrderItem.SAP_Product_Export_Model__c = orLine.productExportModel;
                        deOrderItem.Product_Factory_Model__c = orLine.productFactoryModel;
                        deOrderItem.SAP_Delivery_Order_Item_No__c = orLine.deliveryOrderItemNo;

                        if('TV'.equals(salesforceProductLine) || 'AC'.equals(salesforceProductLine) || 'Laser TV'.equals(salesforceProductLine) || 'LCAC'.equals(salesforceProductLine) || 'Refrigerator'.equals(salesforceProductLine) || 'Freezer'.equals(salesforceProductLine) || 'WM'.equals(salesforceProductLine)){
                            deOrderItem.Customer_Model_Product__c = modelMap.get(orLine.productCustomerModel.toUpperCase() + accMap.get(orList.SAPCustomerCode));
                        }else{//手机&小家电&other
                            deOrderItem.Customer_Model_Product__c = modelMapMobileandOther.get(orLine.productCustomerModel.toUpperCase());
                        }

                        if ('Refrigerator'.equals(productLine)||'Freezer'.equals(productLine)||'WM'.equals(productLine)) {
                            List<Id> IdList = productRelationMap.get(orLine.productFactoryModel.toUpperCase());
                            deOrderItem.Product_Export_Model__c = IdList==null? null:IdList[0];
                        }else if ('Laser TV'.equals(productLine)||'TV'.equals(productLine)||'Mobile'.equals(productLine)) {
                            //当产品线为TV 或者Mobile的时候通过sap过来的工厂型号去找到相应的product
                            deOrderItem.Product_Export_Model__c = productFactoryModelMap.get(orLine.ProductFactoryModel.toUpperCase());
                        }else{
                            //其他的产品线通过sap过来的出口型号找到对应的product
                            deOrderItem.Product_Export_Model__c = productFactoryModelMap.get(orLine.ProductExportModel.toUpperCase());
                        }
                        deOrderItem.Delivery_Quantity__c = Decimal.valueOf(String.isBlank(orLine.DeliveryQuantity)? '0':orLine.DeliveryQuantity);
                        deOrderItem.Delivery_Order_Item_Status__c = orLine.deliveryOrderItemStatus;
                        deOrderItem.POD_Quantity__c = Decimal.valueOf(String.isBlank(orLine.podQuantity)? '0':orLine.podQuantity);
                        deOrderItem.POD_Reason__c = orLine.podReason;
                        deOrderItem.POD_Line_Status__c = orLine.podLineStatus;
                        //add by johnson 20190709
                        deOrderItem.Batch__c = orLine.Batch;
                        if(String.isNotBlank(orLine.podDate)){
                            deOrderItem.POD_Date__c = Date.valueOf(orLine.podDate);
                        }else{
                            deOrderItem.POD_Date__c = null;
                        }
                        //add by johnson 20190722
                        deOrderItem.Unit_Price__c = Decimal.valueOf(String.isBlank(orLine.UnitPrice)? '0':orLine.UnitPrice);
                        deOrderItem.Total_Amount__c = Decimal.valueOf(String.isBlank(orLine.TotalAmount)? '0':orLine.TotalAmount);

                        Order__c order = new Order__c();
                        order.External_Key__c = orLine.salesOrderNo+orList.SAPCustomerCode;
                        deOrderItem.Order__r = order;

                        Order_Product__c orderProduct = new Order_Product__c();
                        orderProduct.External_Key__c = orLine.salesOrderNo + orLine.salesOrderItemNo;
                        //当找不到订单订单行时，写入Log
                        if(sOrderItemMap.get(orderProduct.External_Key__c) == null){
                            errorStringCannotFindOrderItem.add(orList.deliveryOrderNo+ '_' + orLine.deliveryOrderItemNo + '_' +orLine.salesOrderNo + '_'+ orLine.salesOrderItemNo+ '@END');
                        }

                        deOrderItem.Order_Product__r = orderProduct;
                        //对应DO头下面的行
                        if (deOrderMap.containsKey(deliveryOrder.SAP_Delivery_Order_No__c)) {
                            deOrderMap.get(deliveryOrder.SAP_Delivery_Order_No__c).add(deOrderItem);
                        }else{
                            deOrderMap.put(deliveryOrder.SAP_Delivery_Order_No__c, new List<Delivery_Order_Item__c>{deOrderItem});
                        }
                        deOrderItemList.add(deOrderItem);
                    }
                }
                
                List<Database.upsertResult> resultsOrder = Database.upsert(deliveryOrderList,Delivery_Order__c.Fields.SAP_Delivery_Order_No__c,false);
                List<String> customerNotExistList = new List<String>();
                Set<String> customerNotExistListNew = new Set<String>();
                //客户编码不存在的order
                for(Database.upsertResult dbur : resultsOrder){
                    if(dbur.isSuccess() == false){
                        for(Database.Error error : dbur.getErrors()){
                            customerNotExistList.add(error.message);
                            //System.debug('error:'+error.message);
                        }
                    }
                }
                for(String cnel : customerNotExistList){
                    customerNotExistListNew.add(cnel.substring(25,35));
                }

                bodyUserNotExist = JSON.serialize(customerNotExistListNew);
                for (Delivery_Order__c doc : deliveryOrderList) {
                    if (deOrderMap.get(doc.SAP_Delivery_Order_No__c)==null) {
                        continue;
                    }
                    for (Delivery_Order_Item__c doic : deOrderMap.get(doc.SAP_Delivery_Order_No__c)) {
                        doic.Delivery_Order__c = doc.Id;
                        doic.External_Key__c = doc.SAP_Delivery_Order_No__c+doic.SAP_Delivery_Order_Item_No__c;
                    }
                }
                if(errorStringCannotFindOrderItem.size() > 0){
                    Utility.insertLog('SAPGetDeliveryOrder1', '0', body, JSON.serialize(errorStringCannotFindOrderItem));
                }
                List<Database.upsertResult> resultsOrderItem = Database.upsert(deOrderItemList,Delivery_Order_Item__c.Fields.External_Key__c,false);
            }
            catch (Exception e) {
                System.debug(e.getMessage()+e.getLineNumber());
                String errorMsg = '新建数据出错'+e.getMessage()+e.getLineNumber();
                //日志内容
                Utility.insertLog('SAPGetDeliveryOrder1', '0', body, errorMsg);
                return; 
            }
            //日志内容
            String exportModelNotExistString ;
            if(exportModelNotExistList == null){
                exportModelNotExistString = '';
            }else{
                exportModelNotExistString = JSON.serialize(exportModelNotExistList);
            }
            String customerModelNotExistString ;
            if(customerModelNotExistList == null){
                customerModelNotExistString = '';
            }else{
                customerModelNotExistString = JSON.serialize(customerModelNotExistList);
            }
            String errorMsg = bodyUserNotExist;
            Utility.insertLog('SAPGetDeliveryOrder1', '1', body, errorMsg);
        }
    }
}