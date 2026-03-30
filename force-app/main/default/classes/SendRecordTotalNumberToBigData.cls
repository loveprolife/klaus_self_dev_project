/**********************************************************************
 * function:将Channel推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: 
 * date:2024-01-31
*************************************************************************/
@RestResource(urlMapping='/SendRecordTotalNumberToBigData')
global with sharing class SendRecordTotalNumberToBigData {  

    global class AppInput{
        //public String startTime; 
        public String endTime; 
    }
    global class AppOutPut{
        public String channelTotalNumber;
        public String samplingDetailTotalNumber;
        public String samplingConditionTotalNumber;
        public String userTotalNumber;
        public String dailySalesTotalNumber;
        public String samplingTargetTotalNumber;
        public String inspectionPlanTotalNumber;
        public String inspectionTaskTotalNumber;
        public String samplingInspectionTotalNumber;
        public String storeTotalNumber;
        public String productTotalNumber;
        public String customerTotalNumber;
        public String promotersTotalNumber;
        public String dailyInspectionReportTotalNumber;
        public String ticketTotalNumber;
        public String customerManagementTotalNumber;
        public String promoterRevenueTotalNumber;
        public String promoterCostTotalNumber;
        public String storeProductlineTotalNumber;
    }

    @HttpPost
    global static SendRecordTotalNumberToBigData.AppOutPut adoPost() {

        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.tostring(); 
        //String reqBody = '{"startTime":"2024-01-09 00:00:00","endTime":"2024-01-10 00:00:00"}'; 
        SendRecordTotalNumberToBigData.AppInput appInput = new SendRecordTotalNumberToBigData.AppInput();
        
        SendRecordTotalNumberToBigData.AppOutPut result = new SendRecordTotalNumberToBigData.AppOutPut();
        
        try{
            appInput = (SendRecordTotalNumberToBigData.AppInput)JSON.deserialize(reqBody, SendRecordTotalNumberToBigData.AppInput.class);

            if(String.isBlank(appInput.endTime)){
                return result;
            }

            //Datetime startTime = Datetime.valueOf(appInput.startTime);
            Datetime endTime = Datetime.valueOf(appInput.endTime).addHours(8);

            List<AggregateResult> c = [select count(id) totalNumber from Channel__c where LastModifiedDate <= :endTime];
            result.channelTotalNumber = c.get(0).get('totalNumber') + '';

            List<AggregateResult> sd = [select count(id) totalNumber from Sampling_Detail__c where LastModifiedDate <= :endTime];
            result.samplingDetailTotalNumber = sd.get(0).get('totalNumber') + '';

            List<AggregateResult> sc = [select count(id) totalNumber from Sampling_Condition__c where LastModifiedDate <= :endTime];
            result.samplingConditionTotalNumber = sc.get(0).get('totalNumber') + '';

            List<AggregateResult> user = [select count(id) totalNumber from user where LastModifiedDate <= :endTime];
            result.userTotalNumber = user.get(0).get('totalNumber') + '';

            List<AggregateResult> ru = [select count(id) totalNumber from Retail_Number__c where LastModifiedDate <= :endTime];
            result.dailySalesTotalNumber = ru.get(0).get('totalNumber') + '';

            List<AggregateResult> st = [select count(id) totalNumber from Sampling_Target__c where LastModifiedDate <= :endTime];
            result.samplingTargetTotalNumber = st.get(0).get('totalNumber') + '';

            List<AggregateResult> isp = [select count(id) totalNumber from Inspection_Shop_Plan__c where LastModifiedDate <= :endTime];
            result.inspectionPlanTotalNumber = isp.get(0).get('totalNumber') + '';

            List<AggregateResult> ist = [select count(id) totalNumber from Inspection_Shop_Task__c where LastModifiedDate <= :endTime];
            result.inspectionTaskTotalNumber = ist.get(0).get('totalNumber') + '';

            List<AggregateResult> si = [select count(id) totalNumber from Sampling_Inspection__c where LastModifiedDate <= :endTime];
            result.samplingInspectionTotalNumber = si.get(0).get('totalNumber') + '';
            
            List<AggregateResult> store = [select count(id) totalNumber from Shop__c where LastModifiedDate <= :endTime];
            result.storeTotalNumber = store.get(0).get('totalNumber') + '';

            List<AggregateResult> p = [select count(id) totalNumber from Product__c where LastModifiedDate <= :endTime];
            result.productTotalNumber = p.get(0).get('totalNumber') + '';

            List<AggregateResult> customer = [select count(id) totalNumber from Account where LastModifiedDate <= :endTime];
            result.customerTotalNumber = customer.get(0).get('totalNumber') + '';

            List<AggregateResult> rp = [select count(id) totalNumber from Responsible_Person__c where LastModifiedDate <= :endTime];
            result.promotersTotalNumber = rp.get(0).get('totalNumber') + '';

            List<AggregateResult> dir = [select count(id) totalNumber from Daily_Inspection_Report__c where LastModifiedDate <= :endTime];
            result.dailyInspectionReportTotalNumber = dir.get(0).get('totalNumber') + '';

            List<AggregateResult> ticket = [select count(id) totalNumber from Ticket__c where LastModifiedDate <= :endTime];
            result.ticketTotalNumber = ticket.get(0).get('totalNumber') + '';

            List<AggregateResult> cm = [select count(id) totalNumber from Customer_Management__c where LastModifiedDate <= :endTime];
            result.customerManagementTotalNumber = cm.get(0).get('totalNumber') + '';

            List<AggregateResult> pr = [select count(id) totalNumber from Promoter_Revenue__c where LastModifiedDate <= :endTime];
            result.promoterRevenueTotalNumber = pr.get(0).get('totalNumber') + '';

            List<AggregateResult> pc = [select count(id) totalNumber from Promoter_Cost__c where LastModifiedDate <= :endTime];
            result.promoterCostTotalNumber = pc.get(0).get('totalNumber') + '';

            List<AggregateResult> spl = [select count(id) totalNumber from Store_Product_Line__c where LastModifiedDate <= :endTime];
            result.storeProductlineTotalNumber = spl.get(0).get('totalNumber') + '';

            System.debug('result :' + result);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendRecordTotalNumberToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            ic.Req_Json__c = reqBody;
            insert ic;

            return result; 
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'SendRecordTotalNumberToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = reqBody;
            ic.ErrorMsg__c = e.getMessage();
            insert ic;

            return result; 
        }
    }

    public static String checkNull(String str){
        if(String.isBlank(str)){
            return '';
        }else if('null'.equals(str)){
            return '';
        }else{
            return str;
        }
    }
}