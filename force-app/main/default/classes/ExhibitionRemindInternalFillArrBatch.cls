/**************************************************************************************************
 * Name: ExhibitionRemindInternalFillArrBatch
 * Object: Exhibition_Arrangement__c
 * Purpose: 提醒未填写行程信息的用户填写                行程信息-参展员工
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0          Ethan             2023-11-17         Created      
 
***************************************************************************************************/
global class ExhibitionRemindInternalFillArrBatch implements Database.Batchable<sObject> {
    private final static String Exhibition_Is_Not_Flight = System.label.Exhibition_Is_Not_Flight;
    private final static String Exhibition_Is_Not_Need_Vehicle = System.label.Exhibition_Is_Not_Need_Vehicle;
    private final static String Exhibition_Designated_Hotel = System.label.Exhibition_Designated_Hotel;
    private final static String SITE_URL_FRO = System.Url.getOrgDomainUrl().toExternalForm().split('.com')[0] + '-sites.com/exhibitionArrangementWithout/apex/ExhibitionArrPublicPage?id=';
    public String query;
    public Date queryDate;

    global ExhibitionRemindInternalFillArrBatch() {
        this.query = query;
        this.queryDate = Date.today();

    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        query = 'SELECT Id, Hotel_Name__c,Hotel_Start_Date__c,Hotel_End_Date__c, Designated_Hotel__c, Is_Not_Flight__c, Inbound_Flight_No__c, Return_Flight_No__c, Is_Not_Need_Vehicle__c, Is_Not_Vehicle__c, '  
            +'Internal_Registration__c,Internal_Registration__r.Name_CN__c,Internal_Registration__r.Name_EN__c,Internal_Registration__r.Email__c, '
            +'Exhibition_Management__r.StartDate__c,Exhibition_Management__r.TitleCN__c, Exhibition_Management__r.LastRegistrationDate__c '  
            +'FROM Exhibition_Arrangement__c WHERE Internal_Registration__r.Approval_Status__c = \'审批通过\' AND  Exhibition_Management__r.StartDate__c >=: queryDate '
            + 'AND ( (Is_Not_Flight__c = FALSE AND Inbound_Flight_No__c = NULL) OR (Designated_Hotel__c = FALSE AND Hotel_Start_Date__c = NULL) OR (Is_Not_Need_Vehicle__c = FALSE AND Is_Not_Vehicle__c = TRUE))';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Exhibition_Arrangement__c> scope) {
        try{
            if (!scope.isEmpty()) sendEmail(scope);
        }catch(Exception e) {
            System.debug('ExhibitionRemindInternalFillArrBatch Error--->'+e.getLineNumber()+e.getMessage());
        }
        
    }

    global void finish(Database.BatchableContext BC) {

    }
    global void sendEmail(List<Exhibition_Arrangement__c> exhArrList){
        EmailTemplate emtemp = [SELECT Id, Name, Subject, HtmlValue, Body, BrandTemplateId, DeveloperName 
            FROM EmailTemplate
            WHERE DeveloperName = 'Exhibition_Remind_Internal_Fill_Exhibitino_Arr' LIMIT 1];
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        for (Exhibition_Arrangement__c item: exhArrList) {
            String toName  = item.Internal_Registration__r.Name_CN__c == NULL ? '用户' : item.Internal_Registration__r.Name_CN__c;
            String strDate = String.valueOf(item.Exhibition_Management__r.StartDate__c);
            String exhiName = item.Exhibition_Management__r.TitleCN__c;
            String vehicleInfo = '';
                if (!item.Is_Not_Flight__c && item.Inbound_Flight_No__c == NULL) 
                    vehicleInfo+=('<li>'+ Exhibition_Is_Not_Flight + '</li>'); 
                if (!item.Designated_Hotel__c && item.Hotel_Start_Date__c == NULL) 
                    vehicleInfo+=('<li>'+ Exhibition_Designated_Hotel + '</li>'); 
                if (!item.Is_Not_Need_Vehicle__c && item.Is_Not_Vehicle__c) 
                    vehicleInfo+=('<li>'+ Exhibition_Is_Not_Need_Vehicle + '</li>'); 

            String bodyFormat = String.format(emtemp.HtmlValue, new List<String>{toName, strDate, exhiName,vehicleInfo, SITE_URL_FRO+item.Id});
            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                singleEmail.setSaveAsActivity(false);
                singleEmail.setTemplateId(emtemp.Id);
                singleEmail.setSubject(emtemp.Subject + '');
                //设置发送人邮箱
                singleEmail.setOrgWideEmailAddressId(System.Label.Exhibition_Public_Mailbox);
                singleEmail.setHtmlBody(bodyFormat);
                System.debug('bodyFormat-->'+bodyFormat);
                singleEmail.setToAddresses(new List<String>{item.Internal_Registration__r.Email__c});
                // singleEmail.setCcAddresses(item.Email__c);
                sendEmailList.add(singleEmail);
        }

            
            
        

        if (sendEmailList.size() > 0) {
            System.debug('------------>already send ! ');
            Messaging.sendEmail(sendEmailList);
        }

        
    }
}