/**********************************************************************
* Name: SAPGetVirtualOrder
* Object: Order 
* Purpose: 
* SAP中的虚拟订单信息每天定时传递给salesforce，salesforce将
* 每天SAP中的虚拟订单删除的订单也会删除
* Author: Gerry
* Create Date: 2019-03-07
*************************************************************************/
public with sharing class SAPGetVirtualOrder {

    private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_VIRTUALORDER_SEND';
    private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    private static String password = Interface_Url__c.getValues('SAP').Password__c;
    
    public class Output{
        public List<String> CompanyCodeList;
    }

    public class Input{
        public List<OrderList> orderList;
        public String isSuccess;
        public String failReason;
        public String token;
    }

    public class OrderList {
        public String sAPOrderNo;
        public String sAPCustomerCode;
        public String orderStatus;
        public String orderAmount;
        public String SFCurrency;
        public String orderDate;
        public String orderTypeCode;
        public String orderTypeName;
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
        // 二期增加SHIP TO地址
        public String SAPShiptoAddress;
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
    }

    public class OrderLine {
        public String sapOrderItemNo;
        public String productCustomerModel;
        public String productFactoryModel;
        public String productExportModel;
        public String unitPrice;
        public String quantity;
        public String totalSalesAmount;
        public String plannedDeliveryDate;
        public String productLine;
        public String MaterialNumber;
        //add by johnson 20190709
        public String StorageLocation;
        public String BatchNumber;
        public String TotalAmountAfterRebate;
        public String Brand;
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
    public static void getVirtualOrderFromSAP(List<String> CompanyCodeList){
        Datetime startTime = System.now();
        Output out = new Output();
        out.CompanyCodeList = CompanyCodeList;
        String body = JSON.serialize(out);
        String bodyUserNotExist = '';        
        String bodyRes;
        SAPGetVirtualOrder.Input input = new SAPGetVirtualOrder.Input();
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
            bodyRes = response.getBody();
            // bodyRes = '{"OrderList": [{"SAPOrderNo": "00361955761","SAPCustomerCode": "0000504263","OrderStatus": "待处理","OrderAmount": "16000.00","SFCurrency": "ZAR","OrderDate": "","OrderTypeCode": "ZOR6","OrderTypeName": "HSII OTS SO(AutoDlv)","HisenseEntity": 8510,"OrderLine": [{"SAPOrderItemNo": "000010","ProductCustomerModel": "H359BI-WD","ProductFactoryModel": "HA65M7000UWTG","UnitPrice": "800.00","Quantity": "20.000","TotalSalesAmount": "16000.00","PlannedDeliveryDate": "","ProductLine": "","ProductExportModel": "65M7000UWG","MaterialNumber": ""}]}],"IsSuccess": "True","FailReason": ""}';
            System.debug('bodyRes:' + bodyRes);
            input =(SAPGetVirtualOrder.Input)JSON.deserialize(bodyRes,SAPGetVirtualOrder.Input.class );
            System.debug('~~~~~~~~~~~~~~');   
        }catch (Exception e) {
            String errorMsg = 'sfdc调用获取虚拟订单信息接口失败'+e.getMessage()+ ' 报错行:' + e.getLineNumber() + ' 开始时间：' + startTime + ' 结束时间：'+ System.now();
            //日志内容
            Utility.insertLog('SAPGetVirtualOrder', '0', body, errorMsg);
            return; 
        }

        if (input.isSuccess == 'False') {
            String errorMsg = input.failReason;
            //日志内容
            Utility.insertLog('SAPGetVirtualOrder', '0', body, errorMsg);
            return; 
        }

        //'V'代表Virtual Order
        List<Order__c> orderDelList = [SELECT ID FROM Order__c WHERE Order_Classification__c = 'V' AND Hisense_Entity__c IN: CompanyCodeList];
        Database.delete(orderDelList);

        if (!(input.orderList == null || input.orderList.isEmpty())) {
            //Export Model Product Not Exist Error Log List
            List<ErrorMessageFactoryModel> exportModelNotExistList = new List<ErrorMessageFactoryModel>();
            //customer Model Product Not Exist Error Log List
            List<ErrorMessageCustomerModel> customerModelNotExistList = new List<ErrorMessageCustomerModel>();
            List<Order__c> orderInsertList = new List<Order__c>();
            List<Order_Product__c> orderProductList = new List<Order_Product__c>();
            try {
                //客户编码集合
                Set<String> sapCustomerCodeSet = new Set<String>();
                //工厂型号集合
                Set<String> factoryModelSet = new Set<String>();
                //出口型号集合
                Set<String> exportModelSet = new Set<String>();
                //产品线编号集合
                Set<String> mpSet = new Set<String>();
                //客户型号集合
                Set<String> productCustomerModelSet = new Set<String>();
                for (OrderList orList : input.orderList) {
                    sapCustomerCodeSet.add(orList.sapCustomerCode);
                    if(null != orList.orderLine){
                        for (OrderLine orLine : orlist.orderLine) {
                            exportModelSet.add(orLine.productExportModel);
                            exportModelSet.add(orLine.productFactoryModel);
                            if (String.isNotBlank(orLine.productFactoryModel)) {
                                factoryModelSet.add(orLine.productFactoryModel);
                            }
                            mpSet.add(orLine.productLine);
                            productCustomerModelSet.add(orLine.productCustomerModel);
                        }
                    }
                }

                Set<String> hisenseSet = new Set<String>();
                Map<String,String> accMap = new Map<String,String>();
                //vo中客户编码对应的客户
                Map<String,ID> accIdMap = new Map<String,ID>();
                //找不到客户的挂到这个特殊客户上
                List<Account> notFoundCustomer = [SELECT ID,SAP_Customer_Code__c FROM Account WHERE SAP_Customer_Code__c ='CANNOTFINDCUSTOMERORDER'];
                //对应的客户
                for (Account acc : [SELECT Id,SAP_Customer_Code__c,Hisense_Entity__c,Sales_Region__c FROM Account WHERE SAP_Customer_Code__c IN:sapCustomerCodeSet]) {
                    hisenseSet.add(acc.Sales_Region__c);
                    accMap.put(acc.SAP_Customer_Code__c, acc.Sales_Region__c);
                    accIdMap.put(acc.SAP_Customer_Code__c, acc.Id);
                }

                Map<String,ID> modelMap = new Map<String,ID>();
                Map<String,ID> modelMapMobileandOther = new Map<String,ID>();

                //对应的客户型号
                for (Customer_Model_Product__c cmp : [SELECT Id,Name,Country_Code__c,Product_Line__c FROM Customer_Model_Product__c WHERE Name IN :productCustomerModelSet]) {
                    if('TV'.equals(cmp.Product_Line__c) || 'Laser TV'.equals(cmp.Product_Line__c) || 'AC'.equals(cmp.Product_Line__c) || 'LCAC'.equals(cmp.Product_Line__c) || 'WM'.equals(cmp.Product_Line__c) || 'Refrigerator'.equals(cmp.Product_Line__c) || 'Freezer'.equals(cmp.Product_Line__c)){
                        modelMap.put(cmp.Name.toUpperCase()+cmp.Country_Code__c, cmp.Id);
                    }else{
                        modelMapMobileandOther.put(cmp.Name.toUpperCase(), cmp.Id);
                    }
                }

                //对应的产品
                Map<String,ID> factoryMap = new Map<String,ID>();
                for (Product__c pro : [SELECT ID,Name FROM Product__c WHERE Name IN :exportModelSet]) {
                    factoryMap.put(pro.Name.toUpperCase(), pro.Id);
                }

                Map<String,List<Mapping__c>> mpMap = new Map<String,List<Mapping__c>>();
                Map<String,String> businessScope2ProductLineMapping = new Map<String,String>();
                for (Mapping__c mp : [SELECT ID,Name,RecordType.DeveloperName,Mapping_Code__c FROM Mapping__c WHERE Name IN :mpSet]) {
                    businessScope2ProductLineMapping.put(mp.Name,mp.Mapping_Code__c);
                    if (mpMap.containsKey(mp.Name)) {
                        mpMap.get(mp.Name).add(mp);
                    }else{
                        mpMap.put(mp.Name, new List<Mapping__c>{mp});
                    }
                }
                //纪录类型Id
                // String recordTypeID = Schema.SObjectType.Mapping__c.getRecordTypeInfosByName().get('SAP Product Line and Product Line Mapping').getRecordTypeId();
                String recordTypeID = Schema.SObjectType.Mapping__c.getRecordTypeInfosByDeveloperName().get('SAP_Product_Line_and_Product_Line_Mapping').getRecordTypeId();
                
                Map<String,List<Id>> productRelationMap = new Map<String,List<Id>>();
                //对应的产品关系
                for (Product_Relation__c pr : [SELECT Factory_Model__c,Product_Export_Model__c FROM Product_Relation__c WHERE Product_Export_Model__c IN:factoryModelSet]) {
                    if (productRelationMap.containsKey(pr.Product_Export_Model__c.toUpperCase())) {
                        productRelationMap.get(pr.Product_Export_Model__c.toUpperCase()).add(pr.Factory_Model__c);
                    }else{
                        productRelationMap.put(pr.Product_Export_Model__c.toUpperCase(), new List<Id>{pr.Factory_Model__c});
                    }
                }

                Map<String, Decimal> currencyRateMap = Utility.getCurrencyRateMap();
                Decimal rate;

                Map<String,List<Order_Product__c>> tempOrderProMap = new Map<String,List<Order_Product__c>>();
                for (OrderList orList : input.orderList) {
                    Order__c order = new Order__c();
                    order.Hisense_Entity__c = orList.HisenseEntity;
                    order.Order_Classification__c = 'V';
                    order.External_Key__c = orlist.sAPOrderNo+orlist.sAPCustomerCode;
                    order.SAP_Order_No__c = orList.sapOrderNo;
                    order.SAP_Customer_Code__c = orlist.sapCustomerCode;
                    order.Order_Status__c = orList.orderStatus;
                    //如果客户编码对应的客户不存在   挂到特殊的客户上
                    if (String.isNotBlank(orList.sAPCustomerCode)&&accIdMap.get(orList.sAPCustomerCode)==null) {
                        order.Customer__c = notFoundCustomer[0].Id;
                    }else{
                        order.Customer__c = accIdMap.get(orList.sAPCustomerCode);
                    }
                    order.CurrencyIsoCode = orList.SFCurrency;
                    order.Order_Amount__c = Decimal.valueOf(String.isBlank(orList.orderAmount)? '0':orList.orderAmount);
                    if(String.isNotBlank(orList.orderDate)){
                        order.Order_Date__c = Date.valueOf(orList.orderDate);
                    }else{
                        order.Order_Date__c = null;
                    }
                    order.Order_Type_Code__c = orList.orderTypeCode;
                    order.Order_Type_Name__c = orList.orderTypeName;
                    //add by johnson 20190709
                    order.SAP_Customer_Name__c = orList.SAPCustomerName;
                    order.SAP_Customer_City__c = orList.SAPCustomerCity;
                    order.SAP_Customer_Region__c = orList.SAPCustomerRegion;
                    order.SAP_Ship_to_Code__c = orList.SAPShiptoCode;
                    order.SAP_Ship_to_Name__c = orList.SAPShiptoName;
                    order.SAP_Ship_to_City__c = orList.SAPShiptoCity;
                    order.SAP_Ship_to_Region__c = orList.SAPShiptoRegion;
                    order.SAP_Ship_to_Address__c = orList.SAPShiptoAddress;
                    order.SAP_Bill_to_Code__c = orList.SAPBilltoCode;
                    order.SAP_Bill_to_Name__c = orList.SAPBilltoName;
                    order.SAP_Bill_to_City__c = orList.SAPBilltoCity;
                    order.SAP_Bill_to_Region__c = orList.SAPBilltoRegion;
                    order.Sales_Office__c = orList.SalesOffice;
                    order.Sales_Group__c = orList.SalesGroup;
                    order.PODATE__c = orList.PODATE;
                    order.Req_Deliv_Date__c = orList.ReqDelivDate;
                    order.Shipping_Window_From__c = orList.ShippingWindowFrom;
                    order.Shipping_Window_To__c = orList.ShippingWindowTo;
                    order.Sales_Office_Desc__c = orList.SalesOfficeDesc;
                    order.Sales_Group_Desc__c = orList.SalesGroupDesc;
                    order.Notes_For_Sales_Order__c = orList.NotesForSalesOrder;

                    orderInsertList.add(order);
                    if(null != orList.orderLine){
                        for (OrderLine orLine : orList.orderLine) {
                            String salesforceProductLine = businessScope2ProductLineMapping.get(orLine.productLine);
                            Order_Product__c orderProduct = new Order_Product__c();
                            orderProduct.SAP_Product_Line_SO__c = orLine.productLine;
                            orderProduct.Material_Number__c = orLine.MaterialNumber;
                            orderProduct.CurrencyIsoCode = orList.SFCurrency;
                            orderProduct.Unit_Price__c = Decimal.valueOf(String.isBlank(orLine.unitPrice)? '0':orLine.unitPrice);
                            orderProduct.Total_Sales_Amount__c = Decimal.valueOf(String.isBlank(orLine.totalSalesAmount)? '0':orLine.totalSalesAmount);
                            orderProduct.SAP_Order_Item_No__c = orLine.sapOrderItemNo;

                            if('TV'.equals(salesforceProductLine) || 'AC'.equals(salesforceProductLine) || 'Laser TV'.equals(salesforceProductLine) || 'LCAC'.equals(salesforceProductLine) || 'Refrigerator'.equals(salesforceProductLine) || 'Freezer'.equals(salesforceProductLine) || 'WM'.equals(salesforceProductLine)){
                                orderProduct.Customer_Model_Product__c = modelMap.get(orLine.productCustomerModel.toUpperCase()+accMap.get(orList.SapCustomerCode));
                            }else{
                                orderProduct.Customer_Model_Product__c = modelMapMobileandOther.get(orLine.productCustomerModel.toUpperCase());
                            }
                            orderProduct.Product_Factory_Model__c = orLine.productFactoryModel;
                            orderProduct.SAP_Product_Export_Model__c = orLine.productExportModel;
                            orderProduct.SAP_Product_Customer_Model__c = orLine.productCustomerModel;
                            orderProduct.Quantity__c = Decimal.valueOf(String.isBlank(orLine.quantity)? '0':orLine.quantity);
                            if(String.isNotBlank(orLine.plannedDeliveryDate)){
                                orderProduct.Planned_Delivery_Date__c = Date.valueOf(orLine.plannedDeliveryDate);
                            }else{
                                orderProduct.Planned_Delivery_Date__c = null;
                            }
                            String productLine;
                            if (String.isNotBlank(orLine.productLine)&&mpMap.get(orLine.productLine)!=null) {
                                for (Mapping__c mp : mpMap.get(orLine.productLine)) {
                                    if (recordTypeID.equals(mp.RecordTypeId)) {
                                        orderProduct.SAP_Product_Line__c = mp.Id;
                                        productLine = mp.Mapping_Code__c;
                                        break;
                                    }
                                }
                            }else{
                                orderProduct.SAP_Product_Line__c = null;
                            }
                            
                            if ('Refrigerator'.equals(productLine)||'Freezer'.equals(productLine)||'WM'.equals(productLine)) {
                                List<Id> IdList = productRelationMap.get(orLine.ProductFactoryModel.toUpperCase());
                                orderProduct.Product_Export_Model__c = IdList==null? null:IdList[0];
                            }else if ('Laser TV'.equals(productLine)||'TV'.equals(productLine)||'Mobile'.equals(productLine)) {
                                //当产品线为TV 或者Mobile的时候通过sap过来的工厂型号去找到相应的product
                                orderProduct.Product_Export_Model__c = factoryMap.get(orLine.ProductFactoryModel.toUpperCase());
                            }else{
                                //其他的产品线通过sap过来的出口型号找到对应的product
                                orderProduct.Product_Export_Model__c = factoryMap.get(orLine.ProductExportModel.toUpperCase());
                            }

                            if (tempOrderProMap.containsKey(order.External_Key__c)) {
                                tempOrderProMap.get(order.External_Key__c).add(orderProduct);
                            }else{
                                tempOrderProMap.put(order.External_Key__c, new List<Order_Product__c>{orderProduct});
                            }
                            orderProduct.External_Key__c = orList.sapOrderNo+orLine.sapOrderItemNo;
                            //add by johnson 20190709
                            orderProduct.Storage_Location__c = orLine.StorageLocation;
                            orderProduct.Batch_Number__c = orLine.BatchNumber;
                            orderProduct.Total_Amount_After_Rebate__c = Decimal.valueOf(String.isBlank(orLine.TotalAmountAfterRebate)? '0':orLine.TotalAmountAfterRebate);
                            orderProduct.Brand__c = orLine.Brand;                                  

                            orderProductList.add(orderProduct);      
                        }
                    }
                } 
                //进行异步的upert
                InsertOrder bulkorderProduct = new InsertOrder(orderInsertList,orderProductList,tempOrderProMap);
                ID jobID = System.enqueueJob(bulkorderProduct);
                System.debug('数量：'+orderInsertList.size());
                System.debug('数量2：'+orderProductList.size());
            }catch (Exception e) {
                String errorMsg = '新建数据出错'+e.getMessage()+ ' 行号：' + e.getLineNumber();
                Utility.insertLog('SAPGetVirtualOrder', '0', body, errorMsg);
                return; 
            }
        }       
    }  
}