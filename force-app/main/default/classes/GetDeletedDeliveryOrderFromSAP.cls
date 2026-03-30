/**********************************************************************
 * 
 *
 * @url: /services/apexrest/rest
 * @data:
 *  {
        
    }
*************************************************************************/
@RestResource(urlMapping='/getDeliveryOrderDeletionFromSAP')
global with sharing class GetDeletedDeliveryOrderFromSAP {
  global class SFOutputResult{
        public String IsSuccess;
        public String FailReason;
    }

    global class DeletedDeliveryOrderInfo{
        public String Token;
        public List<DeliveryOrderNumber> DeliveryOrderNumberList;
    }

    public class DeliveryOrderNumber{
        public String DeliveryOrderNumber;
        public String DeliveryOrderItemNumber;
    }

    @HttpPost
    global static GetDeletedDeliveryOrderFromSAP.SFOutputResult doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 

        String reqBody = req.requestBody.tostring();
        system.debug('doPost now, body : ' + reqBody);

        GetDeletedDeliveryOrderFromSAP.SFOutputResult result = new GetDeletedDeliveryOrderFromSAP.SFOutputResult();

        try {
            DeletedDeliveryOrderInfo deletedDeliveryOrderInput = (GetDeletedDeliveryOrderFromSAP.DeletedDeliveryOrderInfo) Json.deserialize(reqBody, DeletedDeliveryOrderInfo.class);
            //如果没有传过来值就返回
            if(deletedDeliveryOrderInput == null){
                result.IsSuccess = 'False';
                result.FailReason = 'No Value in Deleted Delivery Order List！';
                return result;
            }

            Set<String> doNumSet = new Set<String>();
            Set<String> externalKeySet = new Set<String>();
            for (DeliveryOrderNumber doNum : deletedDeliveryOrderInput.DeliveryOrderNumberList) {
                //如果DeliveryOrderItemNumber为空为删除头业务
                if (String.isBlank(doNum.DeliveryOrderItemNumber)) {
                    doNumSet.add(doNum.DeliveryOrderNumber);
                }else{//DeliveryOrderItemNumber有值为删除行业务
                    externalKeySet.add(doNum.DeliveryOrderNumber + doNum.DeliveryOrderItemNumber);
                }
            }
            
            List<Delivery_Order__c> deletedDeliveryOrderList = [SELECT Id,Total_Amount__c,SAP_Delivery_Order_No__c FROM Delivery_Order__c WHERE SAP_Delivery_Order_No__c IN: doNumSet];
            List<Delivery_Order_Item__c> deletedDeliveryOrderItemList = [SELECT External_Key__c,Id,Delivery_Quantity__c,POD_Quantity__c,Total_Amount__c FROM Delivery_Order_Item__c WHERE Delivery_Order_Text__c IN: doNumSet];
            
            List<Delivery_Order_Item__c> deleteddeliveryOrderItemList1 = [SELECT External_Key__c,Id,Delivery_Quantity__c,POD_Quantity__c,Total_Amount__c FROM Delivery_Order_Item__c WHERE External_Key__c IN: externalKeySet];
            
            List<Delivery_Order__c> updateDeliveryOrderList = new List<Delivery_Order__c>();
            for(Delivery_Order__c oc : deletedDeliveryOrderList){
                Delivery_Order__c orc = new Delivery_Order__c();
                orc.Id = oc.Id;
                orc.Delivery_Order_Status__c = Label.SAP_Deleted;
                orc.SAP_Delivery_Order_No__c = oc.SAP_Delivery_Order_No__c;
                orc.Total_Amount__c = 0;
                updateDeliveryOrderList.add(orc);
            }
            
            List<Delivery_Order_Item__c> updateDeliveryOrderProductList = new List<Delivery_Order_Item__c>();
            
            for(Delivery_Order_Item__c opc : deletedDeliveryOrderItemList){
                Delivery_Order_Item__c oprc = new Delivery_Order_Item__c();
                oprc.Id = opc.Id;
                oprc.External_Key__c = opc.External_Key__c;
                oprc.Delivery_Quantity__c = 0;
                oprc.POD_Quantity__c = 0;
                oprc.Total_Amount__c = 0;
                oprc.Unit_Price__c  = 0;
                updateDeliveryOrderProductList.add(oprc);
            }
            
            for(Delivery_Order_Item__c opc : deleteddeliveryOrderItemList1){
                Delivery_Order_Item__c oprc = new Delivery_Order_Item__c();
                oprc.Id = opc.Id;
                oprc.External_Key__c = opc.External_Key__c;
                oprc.Delivery_Quantity__c = 0;
                oprc.POD_Quantity__c = 0;
                oprc.Total_Amount__c = 0;
                oprc.Unit_Price__c  = 0;
                updateDeliveryOrderProductList.add(oprc);
            }
            
            
            System.debug('updateDeliveryOrderList.. '+updateDeliveryOrderList);
            System.debug('updateDeliveryOrderProductList.. '+updateDeliveryOrderProductList);
            
            Database.update(updateDeliveryOrderList,false);
            Database.update(updateDeliveryOrderProductList,false);
            
            
            //Database.delete(deletedDeliveryOrder);
            //Database.delete(deliveryOrderItem);
            

            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'GetDeletedDeliveryOrderFromSAP';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            ic.ErrorMsg__c = '';
            insert ic;

            result.IsSuccess = 'true';
            result.FailReason = '';
            return result;

        } catch (Exception e) {  
            //日志内容
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'GetDeletedDeliveryOrderFromSAP';
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