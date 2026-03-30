/**********************************************************************
 * function:将客户信息表数据推送给大数据
 * @author:lizunxing
 * @url: /services/apexrest
 * @data: Customer_Information__c
 * date:2022-07-06
*************************************************************************/
@RestResource(urlMapping='/sendCustomerInfoToBigData')
global with sharing class SendCustomerInfoToBigData {

    global class AppInput{
        public String updateDate;  
    }
    global class AppOutPut{
        List<AppOutPutInfo> CustomerInfoList;
    }
    global class AppOutPutInfo{
        
        public String kunnr;  
        public String name1;  
        public String zkhjc; 
        public String updateDate;
        public String customerManagementNameCode;
    }   
      
    @HttpPost
    global static sendCustomerInfoToBigData.AppOutPut adoPost() {
        //RestRequest req = RestContext.request;
        //String reqBody = req.requestBody.tostring(); 
        //SendCustomerInfoToBigData.AppInput appInput = new SendCustomerInfoToBigData.AppInput();
        
        SendCustomerInfoToBigData.AppOutPut result = new SendCustomerInfoToBigData.AppOutPut();
        
        List<AppOutPutInfo> outPutList = new List<AppOutPutInfo>();
        // try{
            //appInput = (SendCustomerInfoToBigData.AppInput)JSON.deserialize(reqBody, SendCustomerInfoToBigData.AppInput.class);
            //List<Test_Send_Cm_To_Bigdate__c> resList = [select kunnr__c,name1__c,zkhjc__c,LastModifiedDate from Test_Send_Cm_To_Bigdate__c];
            List<Account> resList = [SELECT SAP_Customer_Code__c,Name,Customer_Management_Name__r.Name,Customer_Management_Name__r.Customer_Management_Name_Code__c,LastModifiedDate FROM Account where SAP_Customer_Code__c != null];
            
            //for (Test_Send_Cm_To_Bigdate__c ci : resList) {
            for (Account ci : resList) {    
                AppOutPutInfo outPut = new AppOutPutInfo();
                // outPut.kunnr = ci.kunnr__c;
                // outPut.name1 = ci.name1__c;
                // outPut.zkhjc = ci.zkhjc__c;

                if(!Pattern.matches('\\d+$',ci.SAP_Customer_Code__c)){
                    continue;
                }

                outPut.kunnr = ci.SAP_Customer_Code__c;
                outPut.name1 = ci.Name;

                if(ci.Customer_Management_Name__r.Name == null){
                    outPut.zkhjc = '';
                }else{
                    outPut.zkhjc = ci.Customer_Management_Name__r.Name;
                }

                outPut.updateDate = ci.LastModifiedDate.format('yyyyMMdd');
                outPut.customerManagementNameCode = ci.Customer_Management_Name__r.Customer_Management_Name_Code__c;

                outPutList.add(outPut);
            }
            result.CustomerInfoList = outPutList;
            System.debug('result :' + outPutList);
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'sendCustomerInfoToBigData';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '1';
            //ic.Req_Json__c = reqBody;
            insert ic;
        // }catch(Exception e){
        //     //log
        //     InterfaceLog__c ic = new InterfaceLog__c();
        //     ic.Class__c = 'sendCustomerInfoToBigData';
        //     ic.Time__c = System.Now();
        //     ic.ReturnCode__c = '0';
        //     //ic.Req_Json__c = reqBody;
        //     ic.ErrorMsg__c = e.getMessage();
        //     insert ic;
        // }
        

        return result; 
    }
}