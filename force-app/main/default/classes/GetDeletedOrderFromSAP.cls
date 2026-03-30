/**********************************************************************
 * 
 *
 * @url: /services/apexrest/rest
 * @data:
 *  {
        
    }
*************************************************************************/
@RestResource(urlMapping='/getOrderDeletionFromSAP')
global with sharing class GetDeletedOrderFromSAP {
    global class SFOutputResult{
        String IsSuccess;
        String FailReason;
    }
    public class Input{
        public String Token;
        public List<OrderNumber> OrderNumberList;
    }
    public class OrderNumber{
        public String OrderNumber;
        public String OrderItemNumber;
    }
    @HttpPost
    global static GetDeletedOrderFromSAP.SFOutputResult doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 

        String reqBody = req.requestBody.tostring(); 
        system.debug('doPost now, body : ' + reqBody);

        GetDeletedOrderFromSAP.SFOutputResult result = new GetDeletedOrderFromSAP.SFOutputResult();
        try {
            //json串的序列化
            Input deletedOrderList = (Input) Json.deserialize(reqBody, Input.class);
            if(deletedOrderList == null){
                result.IsSuccess = 'False';
                result.FailReason = 'No Value in Deleted Order List！';
                return result;
            }

            Set<String> orderNoSet = new Set<String>();
            Set<String> externalKeySet = new Set<String>();
            for (OrderNumber order : deletedOrderList.OrderNumberList) {
                if (String.isBlank(order.OrderItemNumber)) {//当OrderItemNumber为空的时候只是进行 头删除
                    orderNoSet.add(order.OrderNumber);
                }else{//进行 行删除
                    externalKeySet.add(order.OrderNumber+order.OrderItemNumber);
                }
            }

            List<Order__c> deleteOrderListSelect = [SELECT Id,External_Key__c,Order_Amount__c,Tax_Amount__c,Total_Amount_Inc_Tax__c FROM Order__c WHERE SAP_Order_No__c IN: orderNoSet];
            List<Order_Product__c> deleteOrderItemListSelect = [SELECT Id,External_Key__c,Tax_Amount__c,Total_Amount_After_Rebate__c,Total_Amount_Inc_Tax__c,Total_Sales_Amount__c FROM Order_Product__c WHERE Order_Text__c IN: orderNoSet];
            
            List<Order_Product__c> orderProductList = [SELECT Id,External_Key__c,Unit_Price__c,Quantity__c,Tax_Amount__c,Total_Amount_After_Rebate__c,Total_Amount_Inc_Tax__c,Total_Sales_Amount__c FROM Order_Product__c WHERE External_Key__c IN: externalKeySet];
            
            List<Order__c> updateOrderList = new List<Order__c>();
            for(Order__c oc : deleteOrderListSelect){
                Order__c orc = new Order__c();
                orc.Id = oc.Id;
                orc.Order_Status__c = Label.SAP_Deleted;
                orc.External_Key__c = oc.External_Key__c;
                orc.Order_Amount__c = 0;
                orc.Tax_Amount__c = 0;
                orc.Total_Amount_Inc_Tax__c = 0;
                updateOrderList.add(orc);
            }
            
            List<Order_Product__c> updateOrderProductList = new List<Order_Product__c>();
            
            for(Order_Product__c opc : deleteOrderItemListSelect){
                Order_Product__c oprc = new Order_Product__c();
                oprc.Id= opc.Id;
                oprc.External_Key__c = opc.External_Key__c;
                oprc.Tax_Amount__c = 0;
                oprc.Tax_Amount__c = 0;
                oprc.Total_Amount_After_Rebate__c = 0;
                oprc.Total_Amount_Inc_Tax__c = 0;
                oprc.Total_Sales_Amount__c = 0;
                oprc.Quantity__c = 0;
                oprc.Unit_Price__c = 0;
                updateOrderProductList.add(oprc);
            }
            
            for(Order_Product__c opc : orderProductList){
                Order_Product__c oprc = new Order_Product__c();
                oprc.Id= opc.Id;
                oprc.External_Key__c = opc.External_Key__c;
                oprc.Tax_Amount__c = 0;
                oprc.Total_Amount_After_Rebate__c = 0;
                oprc.Total_Amount_Inc_Tax__c = 0;
                oprc.Total_Sales_Amount__c = 0;
                oprc.Quantity__c = 0;
                oprc.Unit_Price__c = 0;
                updateOrderProductList.add(oprc);
            }
            
            
            System.debug('updateOrderList.. '+updateOrderList);
            System.debug('updateOrderProductList.. '+updateOrderProductList);
            
            Database.update(updateOrderList,false);
            Database.update(updateOrderProductList,false);
            
            
            //Database.delete(deleteOrderListSelect);
            //Database.delete(orderProductList);

            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'getOrderDeletionFromSAP';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            ic.ErrorMsg__c = '';
            insert ic;

            result.IsSuccess = 'true';
            result.FailReason = '';
            return result;

        } catch (Exception e) {  
            System.debug(e.getMessage()+e.getLineNumber());
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'getOrderDeletionFromSAP';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = reqBody;
            ic.ErrorMsg__c = e.getMessage()+e.getLineNumber();
            insert ic;

            result.IsSuccess = 'False';
            result.FailReason = e.getMessage();
            return result;

        }
    }
}