/**********************************************************************
* Name: SAPGetFOB
* Object: FOB 
* Author: wfc
* Create Date: 2021-09-28
*************************************************************************/
public with sharing class SAPGetFOB{

    private static String url = Interface_Url__c.getValues('SAP').Basic_Url__c + 'CC_REST_FOB_SEND';
    private static String user = Interface_Url__c.getValues('SAP').User_Name__c;
    private static String password = Interface_Url__c.getValues('SAP').Password__c;
    
    public class Output{
        String ZDATE;//输入日期
        String VKORG;//销售组织
        String INCO1;//贸易条款
        String TCTYP;//合同类型
        String BUKRS;//公司代码
        String AUART;//订单类型
    }

    public class Input{
        public List<FOBList> FOBDataList;
        public String isSuccess;
        public String failReason;
    }

    public class FOBList{
        public String GTMShippingOrder; //VBELN;//落货纸号
        public String SalesDocumentItem;//POSNR;//行项目号 (NUMC)
        public String Orderstatus;//STAT;//落货纸状态
        public String Customer;//KUNNR;//客户编码
        public String CustomerName;//KUNNR_DESC;//客户名称
        public String ExternalDocumentNumber;//TKONN_EX;//外部合同号
        public String BatchNumber;//SPART_DESC;//产品组
        public String Division;//ZBRANDDESC;//品牌
        public String Brand;//ZCHUANM;//船名
        public String ShipsName;//ZBILLNO;//提单号
        public String BLNO;//ZTDDATE;//提单日期 (date)
        public String ActualShipDate;//ZBGZT_DESC;//Production Base
        public String ProductionBase;//ZSHIPPO_DESC;//FOB Port
        public String FOBPort;//ZDESPO_DESC;//Destination Port
        public String DestinationPort;//ZSHIPDATE;//Requested Ship Date (date)
        public String RequestedShipDate;//ZJHDATE;//Requested Delivery Date (date)
        public String RequestedDeliveryDate;//ZETADATE;//Estimated Arrival Date (date)
        public String EstimatedArrivalDate;//ZTDDATE1;//Actual Ship Date (date)
        public String ShippingCompany;//ZSHIPCOM;//Shipping Company
        public String POnumber;//ZPONO;//PO number
        public String CustomerModel;//ZCUSMODEL;//Customer Model #
        public String USAItemNumber;//ZUSAITEM;//U.S.A Item Number
        public String POQty;//KWMENG;//PO Qty (QUAN 15(3))
        public String DestinationDC;//ZMDDDC;//Destination DC #
        public String SAPInvoiceDate;//FKDAT;//SAP Invoice Date (date)
        public String BillingDocument;//VBELN_VF;//开票凭证
        public String Billingitem;//POSNR_VF;//出具发票项目
        public String InvoicePriceByUnit;//NETWR_UNIT;//Invoice Price By Unit
        public String InvoicePriceByContainer;//NETWR_LJH;//Invoice Price By Container
    }

    @Future(callout =true)
    public static void getFOBFromSAP(String zDate){
        Output out = new Output();
        out.ZDATE = zDate;
        String body = JSON.serialize(out);
        String bodyUserNotExist = '';
        SAPGetFOB.Input input = new SAPGetFOB.Input();
        String bodyRes_login;
        try {
            // user = 'qinyanhao';
            // password = 'PassHi123';
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
            input =(SAPGetFOB.Input)JSON.deserialize(bodyRes_login,SAPGetFOB.Input.class );           
        }catch (Exception e) {
            String errorMsg = 'sf调用获取FOB信息接口失败'+e.getMessage();
            //日志内容
            Utility.insertLog('SAPGetFOB', '0', body, errorMsg + e.getMessage());
            return; 
        }

        if (input.isSuccess == 'False') {
            //日志内容
            String errorMsg = input.failReason;
            Utility.insertLog('SAPGetFOB', '0', body, errorMsg);
            return;
        }

        if (!(input.FOBDataList == null || input.FOBDataList.isEmpty())) {
            try {
                //客户编码
                Set<String> sapCustomerCodeSet = new Set<String>();
                //订单编号
                Set<String> sapOrderNoSet = new Set<String>();
                //invoice
                Set<String> sapInvoiceSet = new Set<String>();
                for(FOBList fob : input.FOBDataList){
                    sapCustomerCodeSet.add(fob.Customer);
                    sapOrderNoSet.add(fob.POnumber);
                    sapInvoiceSet.add(fob.BillingDocument);
                }

                //对应的客户
                Map<String,ID> accIdMap = new Map<String,ID>();
                for (Account acc : [SELECT Id,SAP_Customer_Code__c FROM Account WHERE SAP_Customer_Code__c IN:sapCustomerCodeSet]) {
                    accIdMap.put(acc.SAP_Customer_Code__c, acc.Id);
                }

                //对应的
                // Map<String,ID> sOrderNoMap = new Map<String,ID>();
                // for (Order__c order : [SELECT Id,Purchase_Order_No__c FROM Order__c WHERE Purchase_Order_No__c IN :sapOrderNoSet]) {
                //     sOrderNoMap.put(order.Purchase_Order_No__c, order.Id);
                // }

                //对应的订单
                Map<String,ID> sInvoiceNoMap = new Map<String,ID>();
                for (Invoice__c invoice : [SELECT Id,SAP_Invoice_No__c FROM Invoice__c WHERE SAP_Invoice_No__c IN :sapInvoiceSet]) {
                    sInvoiceNoMap.put(invoice.SAP_Invoice_No__c, invoice.Id);
                }

                List<FOB__c> fobListAdd = new List<FOB__c>();
                for(FOBList fob : input.FOBDataList){
                    FOB__c fobAdd = new FOB__c();
                    fobAdd.Actual_Ship_Date__c = toDate(fob.ActualShipDate);
                    fobAdd.Batch_Number__c = fob.BatchNumber;
                    fobAdd.Billing_Document__c = fob.BillingDocument;
                    fobAdd.Billing_item__c = fob.Billingitem;
                    fobAdd.BL_NO__c = fob.BLNO;
                    fobAdd.Brand__c = fob.Brand;
                    fobAdd.Customer_Code__c = fob.Customer;
                    fobAdd.Customer_Model__c = fob.CustomerModel;
                    fobAdd.Customer_Name__c = fob.CustomerName;
                    fobAdd.Destination_DC__c = fob.DestinationDC;
                    fobAdd.Destination_Port__c = fob.DestinationPort;
                    fobAdd.Division__c = fob.Division;
                    fobAdd.Estimated_Arrival_Date__c = toDate(fob.EstimatedArrivalDate);
                    fobAdd.External_Document_Number__c = fob.ExternalDocumentNumber;
                    fobAdd.FOB_Port__c = fob.FOBPort;
                    fobAdd.GTM_Shipping_Order__c = fob.GTMShippingOrder;
                    fobAdd.Invoice_Price_By_Container__c = Decimal.valueOf(String.isBlank(fob.InvoicePriceByContainer)? '0':fob.InvoicePriceByContainer);
                    fobAdd.Invoice_Price_By_Unit__c = Decimal.valueOf(String.isBlank(fob.InvoicePriceByUnit)? '0':fob.InvoicePriceByUnit);
                    fobAdd.Order_status__c = fob.Orderstatus;
                    fobAdd.PO_number__c = fob.POnumber;
                    fobAdd.PO_Qty__c = Decimal.valueOf(String.isBlank(fob.POQty)? '0':fob.POQty);
                    fobAdd.Production_Base__c = fob.ProductionBase;
                    fobAdd.Requested_Delivery_Date__c = toDate(fob.RequestedDeliveryDate);
                    fobAdd.Requested_Ship_Date__c = toDate(fob.RequestedShipDate);
                    fobAdd.Sales_Document_Item__c = fob.SalesDocumentItem;
                    fobAdd.SAP_Invoice_Date__c = toDate(fob.SAPInvoiceDate);
                    fobAdd.Shipping_Company__c = fob.ShippingCompany;
                    fobAdd.Ships_Name__c = fob.ShipsName;
                    fobAdd.USA_Item_Number__c = fob.USAItemNumber;
                    fobAdd.External_Key__c = fob.GTMShippingOrder + '-' + fob.SalesDocumentItem;
                    fobAdd.Customer__c = accIdMap.get(fob.Customer);
                    // fobAdd.Order__c = sOrderNoMap.get(fob.POnumber);
                    fobAdd.Invoice__c = sInvoiceNoMap.get(fob.BillingDocument);
                    fobListAdd.add(fobAdd);
                }   
                List<Database.upsertResult> resultsOrder = Database.upsert(fobListAdd,FOB__c.Fields.External_Key__c,false);
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
            }catch (Exception e) {
                 //日志内容
                 String errorMsg = '新建数据出错'+e.getMessage()+e.getLineNumber();
                 Utility.insertLog('SAPGetFOB', '0', body, errorMsg);
                 return; 
            }
        }

        //日志内容
        Utility.insertLog('SAPGetFOB', '1', body, bodyUserNotExist);
        
    }

    //修复日期问题
    private static Date toDate(String text){
        if(String.isNotBlank(text)){
            if(Integer.valueOf(text.replace('-', '')) == 0){
                return null;
            }
            return Date.valueOf(text);
            // String regExp = '\\d{8}';
            // if(Pattern.matches(regExp, text)){
            //     if(Integer.valueOf(text) == 0){
            //         return null;
            //     }
            //     Integer year = Integer.valueOf(text.left(4));
            //     Integer month = Integer.valueOf(text.substring(4, 6));
            //     Integer day = Integer.valueOf(text.right(2));
            //     return Date.newInstance(year, month, day);
            // } else {
            //     return null;
            // }
        }
        return null;
    }
}