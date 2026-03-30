/**********************************************************************
* Name: GetCustomerCreditInfoFromRR
* Object: Credit_Limit_Application__c 
* Purpose: RR system give back the credit related information back to Salesforce
* Author: Roy
* Create Date: 2019-03-11
*************************************************************************/
@RestResource(urlMapping='/getCustomerCreditInfoFromRR')
global with sharing class GetCustomerCreditInfoFromRR {
    global class SFOutputResult{
        public String IsSuccess;
        public String FailReason;
    }
    global class CustomerCreditInfo{
        public String SFCode;
        public String ChinaCreditInsuranceBuyerCode;
        public String EffectiveStartTime;
        public String EffectiveEndTime;
        public String RRApprovalStatus;
        public String RRRejectionPerson;
        public String RRRejectionTime;
        public String RRApprovalInformation;
        public String Creditrating;
        public String Finalavailability;
        public String RecommendedBillingPeriod;
        public String CustomerNameFromRR;
        public List<AttachmentInformation> AttachmentListFromRR;
    }

    global class AttachmentInformation{
        public String AttachmentLink;
        public String AttachmentName;
    }

    @HttpPost
    global static GetCustomerCreditInfoFromRR.SFOutputResult doPost() {
        RestRequest req = RestContext.request;
        String reqBody = req.requestBody.toString();
        System.debug('do post now , body :' + reqBody);
 
        //String reqBody = '{"access_token":"Bearer 00D0p0000008bDG!ARoAQCFoPchHjEQntM_4k8LnxFQxiB8Ic3fZT8viHug0GQqCDRsiuAHqTcsyU4l0_aU.KvR3p59.XflCZ2Jx1NDEz3Yyhx7z","SFCode":"LA-00021437","ChinaCreditInsuranceBuyerCode":"","EffectiveStartTime":"","EffectiveEndTime":"","RRApprovalStatus":"Risk Post Approved","RRRejectionPerson":"张文艳","RRRejectionTime":"2019-05-22 09:30:46","RRApprovalInformation":"","Creditrating":"A","Finalavailability":"","RecommendedBillingPeriod":"","AttachmentListFromRR":[{"AttachmentLink":"","AttachmentName":""},{"AttachmentLink":"","AttachmentName":""}]}';
        //String reqBody = '{"SFCode": "LA-00021437","CustomerNameFromRR": "Menard, Inc","ChinaCreditInsuranceBuyerCode": "XXXXX","EffectiveStartTime": "2019-5-30","EffectiveEndTime": "2039-5-30","RRApprovalStatus": "Insurance Company Approved","RRRejectionPerson": "","RRRejectionTime": "","RRApprovalInformation": "okokok","Creditrating": "A","Finalavailability": "1000000","RecommendedBillingPeriod": "90","AttachmentListFromRR": [{"AttachmentLink": "www.baidu.com","AttachmentName": "123"}, {"AttachmentLink": "www.sougou.com","AttachmentName": "456"}]}';
        GetCustomerCreditInfoFromRR.CustomerCreditInfo creditLimitInput = new GetCustomerCreditInfoFromRR.CustomerCreditInfo();
        GetCustomerCreditInfoFromRR.SFOutputResult result = new GetCustomerCreditInfoFromRR.SFOutputResult();

        try{
            creditLimitInput = (GetCustomerCreditInfoFromRR.CustomerCreditInfo)JSON.deserialize(reqBody, GetCustomerCreditInfoFromRR.CustomerCreditInfo.class);
            System.debug('input====>'+creditLimitInput);
            if (creditLimitInput.SFCode == null) {
                result.IsSuccess = 'False';
                result.FailReason = 'Error Input JSON, Please Check the Input Data Structure！';
                return result;
            }else{
                List<Credit_Limit_Application__c> claList = new List<Credit_Limit_Application__c>();
                //Map SF CODE to SF Id
                Map<String,String> SFCode2IdMap = new Map<String,String>();
                Map<String,String> SFCode2CustomerNameMap = new Map<String,String>();
                Map<String,String> SFCode2CustomerIdMap = new Map<String,String>();
                Map<String,String> SFCode2CustomerSAPCodeMap = new Map<String,String>();
                Map<String,String> SFCode2ChinaCrditCodeMap = new Map<String,String>();
                for(Credit_Limit_Application__c c: [Select name,CreatedById,id,Customer__c,Customer__r.Name,Customer__r.SAP_Customer_Code__c,Customer__r.RR_China_Credit__c from Credit_Limit_Application__c Where name =: creditLimitInput.SFCode]){
                    claList.add(c);
                    SFCode2IdMap.put(c.Name,c.Id);
                    SFCode2CustomerNameMap.put(c.Name, c.Customer__r.Name);
                    SFCode2CustomerIdMap.put(c.Name,c.Customer__c);
                    SFCode2CustomerSAPCodeMap.put(c.Name, c.Customer__r.SAP_Customer_Code__c);
                    SFCode2ChinaCrditCodeMap.put(c.Name, c.Customer__r.RR_China_Credit__c);
                }

                Map<String,String> SFCode2TypeMap = new Map<String,String>();
                for(Credit_Limit_Application__c c: [Select name,Payment_Method__c from Credit_Limit_Application__c Where name =: creditLimitInput.SFCode]){
                    SFCode2TypeMap.put(c.Name,c.Payment_Method__c);
                }

                //如果RR系统返回的客户名称与现在SF系统中的客户名称不一致
                //如果客户未同步到SAP，直接修改客户的名称
                //如果客户已同步到SAP，邮件通知财务，在SAP中修改客户名称
                System.debug('111');
                String customerName = SFCode2CustomerNameMap.get(creditLimitInput.SFCode); 

                if(String.isNotBlank(creditLimitInput.CustomerNameFromRR) && !customerName.equals(creditLimitInput.CustomerNameFromRR)){
                    if(creditLimitInput.RRApprovalStatus == Label.Insurance_Company_Approved){
                        Account account = new Account();
                        account.Id = SFCode2CustomerIdMap.get(creditLimitInput.SFCode); 
                        account.Name = creditLimitInput.CustomerNameFromRR;
                        Database.update(account);
                        
                        if(SFCode2CustomerSAPCodeMap.get(creditLimitInput.SFCode) != null){
                            // sendingEmail2SubmitterAndFinance(claList);
                        }
                    }    
                }

                //if(creditLimitInput.RRApprovalStatus == Label.Insurance_Company_Approved){
                    if(SFCode2ChinaCrditCodeMap.get(creditLimitInput.SFCode) == null){
                    //if(creditLimitInput.ChinaCreditInsuranceBuyerCode.equals(SFCode2ChinaCrditCodeMap.get(creditLimitInput.SFCode))){
                        Account account = new Account();
                        account.Id = SFCode2CustomerIdMap.get(creditLimitInput.SFCode);
                        account.RR_China_Credit__c = creditLimitInput.ChinaCreditInsuranceBuyerCode; 
                        Database.update(account);
                    }   
                //}

                Credit_Limit_Application__c creditLimitApplication = new Credit_Limit_Application__c();
                creditLimitApplication.Id = SFCode2IdMap.get(creditLimitInput.SFCode); 
                creditLimitApplication.Approval_Status__c = creditLimitInput.RRApprovalStatus; 
                creditLimitApplication.RR_Rejection_Person__c = creditLimitInput.RRRejectionPerson;
                creditLimitApplication.RR_Rejection_Time__c = creditLimitInput.RRRejectionTime;
                creditLimitApplication.RR_Approval_Information__c = creditLimitInput.RRApprovalInformation; 
                System.debug('222');
                //If the customer limit application get final approval, set the quota related information
                If(creditLimitInput.RRApprovalStatus == Label.Insurance_Company_Approved || creditLimitInput.RRApprovalStatus == Label.Credit_Limit_Risk_Management_Committee_Approved){
                    if(String.isNotBlank(creditLimitInput.EffectiveStartTime)){
                        creditLimitApplication.Effective_Start_Time__c = Date.valueOf(creditLimitInput.EffectiveStartTime);
                    }
                    if(String.isNotBlank(creditLimitInput.EffectiveEndTime)){
                        creditLimitApplication.Effective_End_Time__c = Date.valueOf(creditLimitInput.EffectiveEndTime);
                    }
                    creditLimitApplication.Final_Availability__c = Decimal.valueOf(creditLimitInput.Finalavailability);
                    creditLimitApplication.Credit_Rating__c = creditLimitInput.Creditrating;
                    if(String.isNotBlank(creditLimitInput.Creditrating)){
                        Account account = new Account();
                        account.Id = SFCode2CustomerIdMap.get(creditLimitInput.SFCode);
                        account.Credit_Rating__c = creditLimitInput.Creditrating; 
                        Database.update(account);
                    }
                    creditLimitApplication.Recommended_Billing_Period_days__c = Decimal.valueOf(creditLimitInput.RecommendedBillingPeriod);
                }
                System.debug('333');
                //handle attachment,insert the attachment link to sf
                List<Credit_Limit_Attachment__c> attachmentList = new List<Credit_Limit_Attachment__c>();
                for(AttachmentInformation attachmentInfo : creditLimitInput.AttachmentListFromRR){
                    Credit_Limit_Attachment__c cla = new Credit_Limit_Attachment__c();
                    //if(cla.Attachment_URL__c != '' & cla.Attachment_Name__c != '' & cla.Attachment_URL__c != null & cla.Attachment_Name__c != null){
                        cla.Attachment_URL__c = attachmentInfo.AttachmentLink ;
                        cla.Attachment_Name__c = attachmentInfo.AttachmentName ;
                        cla.Credit_Limit_Application__c = SFCode2IdMap.get(creditLimitInput.SFCode); 
                        attachmentList.add(cla);
                    //}
                }
                System.debug('444');
                //insert the attachment 
                Database.insert(attachmentList);
                System.debug('Sync Successfully2！');

                //update the credit limit application
                Database.update(creditLimitApplication);

                System.debug('Sync Successfully1！');

                System.debug('555');
                //log
                InterfaceLog__c ic = new InterfaceLog__c();
                ic.Class__c = 'GetCustomerCreditInfoFromRR';
                ic.Time__c = System.Now();
                ic.ReturnCode__c = '1';
                ic.Req_Json__c = reqBody;
                ic.ErrorMsg__c = '';
                insert ic;

            if(creditLimitInput.RRApprovalStatus == 'Risk Post Rejected' || creditLimitInput.RRApprovalStatus == 'Risk Management Committee Rejected' || creditLimitInput.RRApprovalStatus == 'Insurance Company Rejected'){
                //if the record is rejected by RR system, unlock the record in order to let user resubmit 
                Approval.unlock(SFCode2IdMap.get(creditLimitInput.SFCode));

            }
                //调用RR接口，获取RR信用申请审批信息用于展示在信用申请详情页
                try{
                    CreditLimitApplicationRRInfoController.syncAuditInfoFromRR(creditLimitInput.SFCode);
                }catch(Exception e){
                    System.debug('cell RR get Approve info ' +  e.getMessage());
                }
                result.IsSuccess = 'true';
                result.FailReason = '';
                return result;
            }
        }catch(Exception e){
            //log
            InterfaceLog__c ic = new InterfaceLog__c();
            ic.Class__c = 'GetCustomerCreditInfoFromRR';
            ic.Time__c = System.Now();
            ic.ReturnCode__c = '0';
            ic.Req_Json__c = reqBody;
            ic.ErrorMsg__c = e.getMessage();
            insert ic;
            
            result.IsSuccess = 'False';
            result.FailReason = e.getMessage();
            //result.FailReason = 'why it is this error message??? ';
            return result;
        }

    }


    // private static void sendingEmail2SubmitterAndFinance(List<Credit_Limit_Application__c> creditLimitApplicationList){
        // String submitterId = creditLimitApplicationList[0].CreatedById;
        // String accountId = creditLimitApplicationList[0].Customer__c;
        // Account account = [Select id,name,Sales_Region__c,SAP_Customer_Code__c from Account where id =: accountId limit 1];
        // User submitter = [select Id,Name,Email,ProfileId from User where Id =: submitterId limit 1];
        // System.debug('submitter...'+submitter);
        // List<String> pIdList = new List<String>();
        // Map<String,String> profileId2NameMap = new Map<String,String>();
        // Map<String,String> profileName2IdMap = new Map<String,String>();
        // for(Profile p : [select id,name from Profile]){
        //     profileId2NameMap.put(p.Id,p.Name );
        //     profileName2IdMap.put(p.Name,p.Id);
        // }

        // //判断提交者是属于哪个区域，从而判断哪个区域的财务可以更改客户名称
        // if('Hisense USA'.equals(account.Sales_Region__c)){
        //     pIdList.add(profileName2IdMap.get('Australia Finance Team'));
        // }else if('Hisense Mexico'.equals(account.Sales_Region__c)){
        //    pIdList.add(profileName2IdMap.get('Mexico Finance Team'));
        // }else if('Hisense Australia'.equals(account.Sales_Region__c)){
        //    pIdList.add(profileName2IdMap.get('Australia Finance Team'));
        // }else if('Hisense Malaysia'.equals(account.Sales_Region__c)){
        //    pIdList.add(profileName2IdMap.get('Malaysia Finance Team'));
        // }else if('Hisense South Africa'.equals(account.Sales_Region__c)){
        //    pIdList.add(profileName2IdMap.get('South Africa Finance Team'));
        // }else if('USA(OEM)'.equals(account.Sales_Region__c)||'Communications Sales Department'.equals(account.Sales_Region__c)||'American Sales Department'.equals(account.Sales_Region__c)||'Middle East and Africa Sales Department'.equals(account.Sales_Region__c)||'Asia-Pacific Sales Department'.equals(account.Sales_Region__c)||'Key Account Sales Department'.equals(account.Sales_Region__c)||'Europe Sales Department'.equals(account.Sales_Region__c)){
        //    pIdList.add(profileName2IdMap.get('HQ Finance Team'));
        // }

        // //set submitter email to list
        // List<string> emailList = new List<string>();
        // emailList.add(submitter.Email);

        // for(User u : [select Id,Name,Email from User where ProfileId in: pIdList]){
        //     emailList.add(u.Email);
        // }

        // Messaging.SingleEmailMessage[] theEmails = new Messaging.SingleEmailMessage[]{};
        // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // String emailBody = '<span style="display: inline-block; width:28px;"></span> ' + Label.Dear_User + '<br/> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+ Label.Customer_Name_Should_be_Updated_in_SAP +'<br/> &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+ Label.Customer_SAP_Code+'[' + account.SAP_Customer_Code__c + '].<br/> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; '+ Label.Customer_New_Name +'[' + account.Name + ']';
        // mail.setToAddresses(emailList);
        // mail.setSenderDisplayName(Label.CRM_System_Reminder);
        // mail.setSubject(Label.Customer_Update + account.SAP_Customer_Code__c);
        // mail.setHtmlBody(emailBody);
        // theEmails.add(mail);
        // Messaging.Email[] allMails = new Messaging.Email[]{};
        // for(Integer j = 0; j < theEmails.size(); j++) {
        //   allMails.add(theEmails.get(j));
        // }
        // System.debug('allMails:: '+allMails);
        // // Print error information
        // Messaging.SendEmailResult[] results = Messaging.sendEmail(allMails);
        // System.debug('results... '+results);
        // Messaging.SendEmailError[] errors = new Messaging.SendEmailError[]{};
        // String emailErrorReport = '';
        // for(Messaging.SendEmailResult currentResult : results) {
        //   errors = currentResult.getErrors();
        //   if(null != errors) {
        //     for(Messaging.SendEmailError currentError : errors) {
        //       emailErrorReport = emailErrorReport + ' (' + currentError.getStatusCode() + ') ' + currentError.getMessage();
        //       System.debug('emailErrorReport... '+emailErrorReport);
        //     }
        //   }
        // }
    // }
}