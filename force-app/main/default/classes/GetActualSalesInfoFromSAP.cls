/**********************************************************************
 * function:获取来自SAP实时订单状态信息
 * @author:roy
 * @url: /services/apexrest/rest
 * @data: ActualSalesInfo
 * date:2019-07-01
*************************************************************************/
@RestResource(urlMapping='/getActualSalesInfoFromSAP')
global with sharing class GetActualSalesInfoFromSAP {

    global class AppInput{
        List<ActualSalesInfo> ActualSalesInfoList;
    }
    global class AppOutPut{
        String FailReason;
        String IsSuccess;
    }
    global class ActualSalesInfo{
        public String ProductLineCode;
        public String ProductLine;
        public String BrandCode;
        public String Brand;
        public String OrderCategory;
        public String SOType;
        public String PODate;
        public String PONo;
        public String SalesGroup;
        public String CustomerSAPCode;
        public String CustomerSAPName;
        public String ShiptoPartyName;
        public String ShiptoPartyRegion;
        public String ShiptoPartyCity;
        public String CustomerModel;
        public String FactoryModel;
        public String ExportModel;
        public String CustomerGroup2;
        public String CustomerGroup2Desc;
        public String StorLocation;
        public String UnitPrice;
        public String SFCurrency;
        public String RequiredDeliveryDate;
        public String ShipWindowfrom;
        public String ShipWindowto;
        public String SONo;
        public String OrderItemNo;
        public String SOCreatedon;
        public String SOQty;
        public String BackOrderQty;
        public String BackOrderAmount;
        public String DNNo;
        public String DNCreateON;
        public String DNQty;
        public String ShipAmount;
        public String PendingDNQty;
        public String PendingDNAmount;
        public String GoodsMovementStatus;
        public String DeliveryOrderPostingDate;
        public String DeliveryOrderDifference;
        public String PODNumber;
        public String PODdate;
        public String InvoiceStatus;
        public String InvoiceNo;
        public String InvoiceDate;
        public String InvoicedQty;
        public String InvoicedAmount;
        public String Cost;
        public String BackOrderNetIncome;
        public String PendingDBNetIncome;
        public String InvoiceNetIncome;
        public String SalesOrganization;
        public String DNNetIncome;
        public String PendingDNNetIncome;
        //新加SAP三个字段
        public String Programname;
        public String Shippingcondition;
        public String Latestshipoutdate;
        // 关于时间的新加两个字段
        public String LOADINGDATE;
        public String DESIREDSHIPDATE;

    }   
      
    @HttpPost
    global static getActualSalesInfoFromSAP.AppOutPut adoPost() {
        //String yesterdayYear = (Date.today().addDays(-1)+'').substring(0,4);
        //String yesterdayMonth = (Date.today().addDays(-1)+'').substring(6,7);
        //String yesterdayDate = (Date.today().addDays(-1)+'').substring(9,10);


        //List<SAP_Sales_Actual__c> actualSalesInfoDELList = [Select id from SAP_Sales_Actual__c where Year__c =: yesterdayYear and Month__c =: yesterdayMonth and Date__c =: yesterdayDate ];
        //Database.Delete(actualSalesInfoDELList);

        
        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        system.debug('doPost now, body : ' + reqBody);

        AppInput input = new AppInput();
        getActualSalesInfoFromSAP.AppOutPut result = new getActualSalesInfoFromSAP.AppOutPut();
        try{
            input = (getActualSalesInfoFromSAP.AppInput) JSON.deserialize(req.requestBody.tostring(), getActualSalesInfoFromSAP.AppInput.class);
            //System.debug('input===>:' + input);
            //空数据
            System.debug('inputSize... '+input.ActualSalesInfoList.size());
            if (input.ActualSalesInfoList == null || input.ActualSalesInfoList.isEmpty()) {
                result.IsSuccess = 'False';
                result.FailReason = '传输的数据为空，请重新检验传输的json字符串是否正确！';
                return result;
            }else{
                List<SAP_Sales_Actual__c> inserList = new List<SAP_Sales_Actual__c>();
                List<getActualSalesInfoFromSAP.ActualSalesInfo> newProductList = new List<getActualSalesInfoFromSAP.ActualSalesInfo>();
                
                Set<String> CustomerModelSet = new Set<String>();
                Set<String> AccountSAPCodeSet = new Set<String>();
                Set<String> ProductModelSet = new Set<String>();
                Set<String> OrderItemNoSet = new Set<String>();
                Set<String> DeliveryOrderSet = new Set<String>();
                Set<String> InvoiceSet = new Set<String>();
                
                for (getActualSalesInfoFromSAP.ActualSalesInfo reqActualSalesInfo : input.ActualSalesInfoList) {
                    CustomerModelSet.add(reqActualSalesInfo.CustomerModel);
                    AccountSAPCodeSet.add(reqActualSalesInfo.CustomerSAPCode);
                    ProductModelSet.add(reqActualSalesInfo.FactoryModel);
                    ProductModelSet.add(reqActualSalesInfo.ExportModel);
                    
                    if('E'.equals(reqActualSalesInfo.OrderCategory)){
                        OrderItemNoSet.add(reqActualSalesInfo.PONo + reqActualSalesInfo.OrderItemNo + reqActualSalesInfo.CustomerSAPCode);
                    }else{
                        OrderItemNoSet.add(reqActualSalesInfo.SONo + reqActualSalesInfo.OrderItemNo);
                    }
                    
                    DeliveryOrderSet.add(reqActualSalesInfo.DNNo);
                    InvoiceSet.add(reqActualSalesInfo.InvoiceNo);
                }

                Map<String,String> SAPProductLine2SFProductLineMap = new Map<String,String>();
                for(Mapping__c mp : [Select Name,Mapping_Code__c from Mapping__c where recordType.developerName = 'SAP_Product_Line_and_Product_Line_Mapping']){
                    SAPProductLine2SFProductLineMap.put(mp.Name,mp.Mapping_Code__c);
                }


                Map<String,String> HisenseEntity2SFSalesRegionMap = new Map<String,String>();
                for(Mapping__c mp : [Select Name,Mapping_Code__c,Mapping_Description__c from Mapping__c where recordType.developerName = 'Business_Orgnization_and_Name_Mapping']){
                    HisenseEntity2SFSalesRegionMap.put(mp.Name,mp.Mapping_Description__c);
                }


                Map<String,String> CustomerProductEXTID2IDMap = new Map<String,String>();
                for(Customer_Model_Product__c cmp : [Select id,ExternalId__c from Customer_Model_Product__c where name in: CustomerModelSet]){
                    CustomerProductEXTID2IDMap.put(cmp.ExternalId__c,cmp.id);
                }


                Map<String,String> SFPLExtID2IDMap = new Map<String,String>();
                for(Customer_Product_Line__c pl : [Select Product_Line_External_Key__c,Id from Customer_Product_Line__c where Customer_SAP_Code__c in: AccountSAPCodeSet]){
                    SFPLExtID2IDMap.put(pl.Product_Line_External_Key__c,pl.Id);
                }

                Map<String,String> SFCustomerSAPCode2SFCodeMap = new Map<String,String>();
                Map<String,String> SFCustomerSAPCode2IdMap = new Map<String,String>();
                for(Account ac : [Select Id,Customer_SF_Code__c,SAP_Customer_Code__c from Account where SAP_Customer_Code__c in: AccountSAPCodeSet]){
                    SFCustomerSAPCode2SFCodeMap.put(ac.SAP_Customer_Code__c,ac.Customer_SF_Code__c);
                    SFCustomerSAPCode2IdMap.put(ac.SAP_Customer_Code__c,ac.Id);
                }

                Map<String,String> productExtId2IdMap = new Map<String,String>();
                for(Product__c pc : [Select Id,Name from Product__c where name in: ProductModelSet]){
                    productExtId2IdMap.put(pc.Name,pc.Id);
                }


                Map<String,String> orderProductExtId2IdMap = new Map<String,String>();
                for(Order_Product__c op : [Select Id,External_Key__c from Order_Product__c where External_Key__c in: OrderItemNoSet]){
                    orderProductExtId2IdMap.put(op.External_Key__c,op.Id);
                }

                Map<String,String> deliveryOrderExtId2IdMap = new Map<String,String>();
                for(Delivery_Order__c doc : [select SAP_Delivery_Order_No__c,Id from Delivery_Order__c where SAP_Delivery_Order_No__c in: DeliveryOrderSet]){
                    deliveryOrderExtId2IdMap.put(doc.SAP_Delivery_Order_No__c,doc.Id);
                }
                
                Map<String, Decimal> currencyRateMap = new Map<String, Decimal>();
                for(CurrencyType ct : [SELECT  IsoCode, ConversionRate FROM CurrencyType Where IsActive = true]){
                    currencyRateMap.put(ct.IsoCode,ct.ConversionRate);
                }
                
                Map<String, String> invoiceNo2IdMap = new Map<String, String>();
                for(Invoice__c iv : [SELECT  SAP_Invoice_No__c, Id FROM Invoice__c where SAP_Invoice_No__c in: InvoiceSet]){
                    invoiceNo2IdMap.put(iv.SAP_Invoice_No__c,iv.Id);
                }

                

                //同步的产品
                //System.debug('input.ActualSalesInfoList... '+input.ActualSalesInfoList);
                Set<String> currencyTypeSet = new Set<String>();
                for (getActualSalesInfoFromSAP.ActualSalesInfo reqActualSalesInfo : input.ActualSalesInfoList) {
                    SAP_Sales_Actual__c ssa = new SAP_Sales_Actual__c();
                    
                    Decimal rate = currencyRateMap.get(reqActualSalesInfo.SFCurrency);
                    ssa.Year__c = (Date.today() + '').subString(0,4);
                    ssa.Month__c = (Date.today() + '').subString(5,7);
                    ssa.Date__c = (Date.today() + '').subString(8,10);

                    //SAP产品线
                    ssa.Product_Line_Code__c=reqActualSalesInfo.ProductLineCode;
                    //转换成SF产品线代码文本和lookup存储
                    ssa.Product_Line_SF_Text__c=SAPProductLine2SFProductLineMap.get(reqActualSalesInfo.ProductLineCode);
                    //Customer_Product_Line__c cplc = new Customer_Product_Line__c();
                    //cplc.Product_Line_External_Key__c = SFCustomerSAPCode2SFCodeMap.get(reqActualSalesInfo.CustomerSAPCode)+SAPProductLine2SFProductLineMap.get(reqActualSalesInfo.ProductLineCode);
                    //ssa.Customer_Product_Line__r = cplc;
                    
                    ssa.Customer_Product_Line__c=SFPLExtID2IDMap.get(SFCustomerSAPCode2SFCodeMap.get(reqActualSalesInfo.CustomerSAPCode)+SAPProductLine2SFProductLineMap.get(reqActualSalesInfo.ProductLineCode));
                    //SAP产品组
                    ssa.Product_Line__c=reqActualSalesInfo.ProductLine;
                    ssa.Brand_Code__c=reqActualSalesInfo.BrandCode;
                    ssa.Brand__c=reqActualSalesInfo.Brand;
                    ssa.Order_Category__c=reqActualSalesInfo.OrderCategory;
                    ssa.SO_Type__c=reqActualSalesInfo.SOType;
                    ssa.PO_Date__c = toDate(reqActualSalesInfo.PODate);
                    ssa.PO_Date_Date__c= toDate1(reqActualSalesInfo.PODate);
                    ssa.PO_No__c=reqActualSalesInfo.PONo;
                    ssa.SalesGroup__c=reqActualSalesInfo.SalesGroup;
                    //SAP中过来的客户SAP编码，lookup到SF客户
                    //Account act = new Account();
                    //act.External_Key__c = reqActualSalesInfo.CustomerSAPCode;
                    //ssa.Customer__r = act;
                    ssa.Customer__c=SFCustomerSAPCode2IdMap.get(reqActualSalesInfo.CustomerSAPCode);
                    //SAP中过来的客户SAP编码
                    ssa.Customer_SAP_Code_From_SAP__c=reqActualSalesInfo.CustomerSAPCode;
                    ssa.Customer_SAP_Name__c=reqActualSalesInfo.CustomerSAPName;
                    ssa.Shipto_Party_Name__c=reqActualSalesInfo.ShiptoPartyName;
                    ssa.Shipto_Party_Region__c=reqActualSalesInfo.ShiptoPartyRegion;
                    ssa.Shipto_Party_City__c=reqActualSalesInfo.ShiptoPartyCity;
                    //客户型号   工厂型号  出口型号的lookup匹配
                    //Customer_Model_Product__c cmpc = new Customer_Model_Product__c();
                    //cmpc.ExternalId__c = reqActualSalesInfo.CustomerModel + HisenseEntity2SFSalesRegionMap.get(reqActualSalesInfo.SalesOrganization);
                    //ssa.Customer_Model__r = cmpc;
                    ssa.Customer_Model__c=CustomerProductEXTID2IDMap.get(reqActualSalesInfo.CustomerModel + HisenseEntity2SFSalesRegionMap.get(reqActualSalesInfo.SalesOrganization));
                    //Product__c pc = new Product__c();
                    //pc.Product_External_Id__c = reqActualSalesInfo.FactoryModel;
                    //ssa.Factory_Model__r = pc;
                    ssa.Factory_Model__c=productExtId2IdMap.get(reqActualSalesInfo.FactoryModel);
                    //Product__c pc1 = new Product__c();
                    //pc1.Product_External_Id__c = reqActualSalesInfo.ExportModel;
                    //ssa.Export_Model__r = pc1;
                    ssa.Export_Model__c=productExtId2IdMap.get(reqActualSalesInfo.ExportModel);
                    ssa.Customer_Model_From_SAP__c=reqActualSalesInfo.CustomerModel;
                    ssa.Factory_Model_From_SAP__c=reqActualSalesInfo.FactoryModel;
                    ssa.Export_Model_From_SAP__c=reqActualSalesInfo.ExportModel;
                    ssa.Customer_Group2__c=reqActualSalesInfo.CustomerGroup2;
                    ssa.Customer_Group2_Desc__c=reqActualSalesInfo.CustomerGroup2Desc;
                    ssa.Stor_Location__c=reqActualSalesInfo.StorLocation;
                    ssa.Unit_Price__c=Decimal.valueOf(reqActualSalesInfo.UnitPrice.trim());
                    ssa.CurrencyIsoCode=reqActualSalesInfo.SFCurrency;
                    ssa.Required_Delivery_Date__c = toDate(reqActualSalesInfo.RequiredDeliveryDate);
                    ssa.Required_Delivery_Date_Date__c = toDate1(reqActualSalesInfo.RequiredDeliveryDate);
                    ssa.Ship_Window_from__c= toDate(reqActualSalesInfo.ShipWindowfrom);
                    ssa.Ship_Window_to__c= toDate(reqActualSalesInfo.ShipWindowto);
                    ssa.SO_No__c=reqActualSalesInfo.SONo;
                    ssa.Order_Item_No_From_SAP__c=reqActualSalesInfo.OrderItemNo;
                    //行项目master-detail到SF订单行上
                    //Order_Product__c opc = new Order_Product__c();
                    //opc.External_Key__c = reqActualSalesInfo.SONo + reqActualSalesInfo.OrderItemNo;
                    //ssa.Order_Item_No__r = opc;
                    
                    if('E'.equals(reqActualSalesInfo.OrderCategory)){
                        ssa.Order_Item_No__c=orderProductExtId2IdMap.get(reqActualSalesInfo.PONo + reqActualSalesInfo.OrderItemNo + reqActualSalesInfo.CustomerSAPCode);
                    }else{
                        ssa.Order_Item_No__c=orderProductExtId2IdMap.get(reqActualSalesInfo.SONo + reqActualSalesInfo.OrderItemNo);
                    }
                    // 如果关联不上Order_Item_No__c 则保存默认的Order_Item_No__c，赋值Lost_Data_Status__c为1 便于过滤查询
                    if(String.isBlank(ssa.Order_Item_No__c)){
                        ssa.Lost_Data_Status__c = '1';
                        if(reqActualSalesInfo.SalesOrganization == '8110'){
                            ssa.Order_Item_No__c = Label.SAP_Sales_Actual_No_Order_Item_No_USA;
                        }else {
                            ssa.Order_Item_No__c = Label.SAP_Sales_Actual_No_Order_Item_No;
                        }
                    }
                    ssa.SO_Createdon__c=toDate(reqActualSalesInfo.SOCreatedon);
                    ssa.SO_Qty__c=Decimal.ValueOf(reqActualSalesInfo.SOQty.trim());
                    ssa.Back_Order_Qty__c=Decimal.ValueOf(reqActualSalesInfo.BackOrderQty);
                    ssa.Back_Order_Amount_BC__c=Decimal.ValueOf(reqActualSalesInfo.BackOrderAmount);

                    //关联到SF发货单
                    //Delivery_Order__c doc = new Delivery_Order__c();
                    //doc.SAP_Delivery_Order_No__c = reqActualSalesInfo.DNNo;
                    //ssa.DNNo__r = doc;
                    ssa.DNNo__c=deliveryOrderExtId2IdMap.get(reqActualSalesInfo.DNNo);
                    
                    ssa.DN_No_From_SAP__c=reqActualSalesInfo.DNNo;
                    ssa.DN_Create_ON__c=toDate(reqActualSalesInfo.DNCreateON);
                    ssa.DN_Qty__c=Decimal.ValueOf(reqActualSalesInfo.DNQty);
                    ssa.Ship_Amount_BC__c=Decimal.ValueOf(reqActualSalesInfo.ShipAmount);
                
                    ssa.Pending_DN_Qty__c=Decimal.ValueOf(reqActualSalesInfo.PendingDNQty);
                    ssa.Pending_DN_Amount_BC__c=Decimal.ValueOf(reqActualSalesInfo.PendingDNAmount);

                    ssa.Goods_Movement_Status__c=reqActualSalesInfo.GoodsMovementStatus;
                    ssa.Delivery_Order_Posting_Date__c = toDate1(reqActualSalesInfo.DeliveryOrderPostingDate);
                    ssa.Delivery_Order_Difference__c=reqActualSalesInfo.DeliveryOrderDifference;
                    ssa.POD_Number__c=Decimal.ValueOf(reqActualSalesInfo.PODNumber);
                    ssa.POD_date__c= toDate(reqActualSalesInfo.PODdate);
                    ssa.Invoice_Status__c=reqActualSalesInfo.InvoiceStatus;
                    //Invoice__c ivc = new Invoice__c();
                    //ivc.SAP_Invoice_No__c = reqActualSalesInfo.InvoiceNo;
                    //ssa.Invoice_No__r = ivc;
                    ssa.Invoice_No__c=invoiceNo2IdMap.get(reqActualSalesInfo.InvoiceNo);
                    ssa.Invoice_No_From_SAP__c=reqActualSalesInfo.InvoiceNo;
                    ssa.Invoice_Date__c= toDate(reqActualSalesInfo.InvoiceDate);
                    ssa.Invoice_Date_Date__c= toDate1(reqActualSalesInfo.InvoiceDate);
                    ssa.Invoiced_Qty__c=Decimal.ValueOf(reqActualSalesInfo.InvoicedQty);
                    ssa.Invoiced_Amount_BC__c=Decimal.ValueOf(reqActualSalesInfo.InvoicedAmount);
                    ssa.DN_Net_Income_BC__c=Decimal.ValueOf(reqActualSalesInfo.DNNetIncome);
                    ssa.Cost_BC__c=Decimal.ValueOf(reqActualSalesInfo.Cost);
                    
                    ssa.Back_Order_Net_Income_BC__c=Decimal.ValueOf(reqActualSalesInfo.BackOrderNetIncome);
                    ssa.Pending_DN_Net_Income_BC__c=Decimal.ValueOf(reqActualSalesInfo.PendingDNNetIncome);
                    ssa.Invoice_Net_Income_BC__c=Decimal.ValueOf(reqActualSalesInfo.InvoiceNetIncome);

                    ssa.Sales_Orgnization__c=reqActualSalesInfo.SalesOrganization;
                    //根据orgnization匹配sales region
                    ssa.Sales_Region__c=HisenseEntity2SFSalesRegionMap.get(reqActualSalesInfo.SalesOrganization);
                    //取SF中客户产品线的管理客户
                    //ssa.MGT_Customer__c=reqActualSalesInfo.;
                    
                    //System.debug('reqActualSalesInfo.SFCurrency... '+reqActualSalesInfo.SFCurrency);
                    //转换成美元
                    

                    //新加SAP过来的三个字段 Programname__c, Shippingcondition__c, Latestshipoutdate__c ---Yanhao 11-29
                    ssa.Programname__c=reqActualSalesInfo.Programname;
                    ssa.Shippingcondition__c=reqActualSalesInfo.Shippingcondition;
                    ssa.Latestshipoutdate__c=reqActualSalesInfo.Latestshipoutdate;

                    // 关于时间的新加两个字段  Loadingdate, Desiredshipdate ---wfc 20/6/8
                    ssa.Loading_Date__c = toDate(reqActualSalesInfo.LOADINGDATE);
                    ssa.Desired_Ship_On_Date__c = toDate(reqActualSalesInfo.DESIREDSHIPDATE);

                    
                    if('USD'.equals(reqActualSalesInfo.SFCurrency)){
                    ssa.Back_Order_Net_Income_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.BackOrderNetIncome)? '0':reqActualSalesInfo.BackOrderNetIncome);
                        ssa.Pending_DN_Net_Income_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.PendingDNNetIncome)? '0':reqActualSalesInfo.PendingDNNetIncome);
                        ssa.Invoice_Net_Income_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.InvoiceNetIncome)? '0':reqActualSalesInfo.InvoiceNetIncome);
                        ssa.DN_Net_Income_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.DNNetIncome)? '0':reqActualSalesInfo.DNNetIncome);
                        ssa.Cost_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.Cost)? '0':reqActualSalesInfo.Cost);
                        ssa.Invoiced_Amount_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.InvoicedAmount)? '0':reqActualSalesInfo.InvoicedAmount);
                        ssa.Pending_DN_Amount_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.PendingDNAmount)? '0':reqActualSalesInfo.PendingDNAmount);
                        ssa.Ship_Amount_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.ShipAmount)? '0':reqActualSalesInfo.ShipAmount);
                        ssa.Back_Order_Amount_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.BackOrderAmount)? '0':reqActualSalesInfo.BackOrderAmount);
                    }else{
                        if(rate == null){
                            rate = 1;
                            ssa.CurrencyIsoCode = null;
                            currencyTypeSet.add(reqActualSalesInfo.SFCurrency);
                        }
                        ssa.Back_Order_Net_Income_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.BackOrderNetIncome)? '0':reqActualSalesInfo.BackOrderNetIncome) / rate;
                        ssa.Pending_DN_Net_Income_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.PendingDNNetIncome)? '0':reqActualSalesInfo.PendingDNNetIncome) / rate;
                        ssa.Invoice_Net_Income_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.InvoiceNetIncome)? '0':reqActualSalesInfo.InvoiceNetIncome) / rate;
                        ssa.DN_Net_Income_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.DNNetIncome)? '0':reqActualSalesInfo.DNNetIncome) / rate;
                        ssa.Cost_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.Cost)? '0':reqActualSalesInfo.Cost) / rate;
                        ssa.Invoiced_Amount_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.InvoicedAmount)? '0':reqActualSalesInfo.InvoicedAmount) / rate;
                        ssa.Pending_DN_Amount_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.PendingDNAmount)? '0':reqActualSalesInfo.PendingDNAmount) / rate;
                        ssa.Ship_Amount_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.ShipAmount)? '0':reqActualSalesInfo.ShipAmount) / rate;
                        ssa.Back_Order_Amount_USD__c=Decimal.valueOf(String.isBlank(reqActualSalesInfo.BackOrderAmount)? '0':reqActualSalesInfo.BackOrderAmount) / rate;
                        
                    }
                    inserList.add(ssa);
                }
                if(currencyTypeSet.size() > 0){
                    Utility.insertLog('getActualSalesInfoFromSAP', '0', JSON.serialize(currencyTypeSet), '币种有误');
                }

                System.debug(inserList.size());
                List<Database.SaveResult> insertResult = Database.insert(inserList, false);

                // 插入不成功
                for (Database.SaveResult r : insertResult){
			        if (!r.isSuccess()){
                        for (Database.Error e : r.getErrors()){ 
                            //日志内容
                            InterfaceLog__c ic = new InterfaceLog__c();
                            ic.Class__c = 'getActualSalesInfoFromSAPFalse';
                            ic.Time__c = System.Now();
                            ic.ReturnCode__c = '0';
                            //ic.Req_Json__c = reqBody;
                            ic.ErrorMsg__c = '报错的这条库存数据是：'+ r.getId() + 'error has occurred.' + e.getStatusCode() + ': ' + e.getMessage() + '报错eee是：'+ e;
                            insert ic;
                        }
			        }
		        }
                
                System.debug('同步成功！');
              
                //日志内容
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'getActualSalesInfoFromSAP';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                //ic.Req_Json__c = reqBody;
                ic.ErrorMsg__c = '';
                insert ic;

                result.IsSuccess = 'true';
                result.FailReason = '';
                System.debug(result);
                return result;

            }
        //错误数据   
        }catch(Exception e){
            System.debug('eeeeeeee...::: '+e + 'ppppppp::: '+ e.getMessage()+'tttttt   '+e.getLineNumber());
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'getActualSalesInfoFromSAP';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            //ic.Req_Json__c = reqBody;
            ic.ErrorMsg__c = e.getMessage() + ' 报错行：' +e.getLineNumber();
            insert ic;
            
            result.IsSuccess = 'False';
            result.FailReason = e.getMessage();
            return result;
        }
        
    }

    /**
     * parse yyyy-MM-dd to Date
     * @Author   Xiaoqian
     * @DateTime 2019-09-24
     * @param    text       [description]
     * @return              [description]
     */

    //修复日期问题
    private static Datetime toDate(String text){
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

    //修复日期问题
    private static Date toDate1(String text){
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