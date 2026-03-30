public without sharing class CustomerVisitPrintPDFController {
    
    // public CustomerVisitPrintPDFController(ApexPages.StandardController controller){}
    public Customer_Visit__c customerVisit{get;set;}
    public Customer_Visit_Detail__c visitDetail{get;set;}
    public Account customer{get;set;}
    public String customerName{get;set;}

    public String competitorTrends{get;set;}
    public String hisenseClientOperatingConditions{get;set;}
    public String hisenseStrategicProgramProgress{get;set;}
    public String problemsToBeSolvedByHisense{get;set;}
    //Status_Quo_of_Industry__c
    public String StatusQuoOfIndustry{get;set;}
    public String hisenseOtherIssues{get;set;}
    //Order
    public String order{get;set;}
    public String inventory{get;set;}
    //Promotion
    public String promotion{get;set;}
    //10
    public String SKUDisplay{get;set;}
    //11 Products Recommendation
    public String productsRecommendation{get;set;}
    //12 Rebate and Support
    public String rebateAndSupport{get;set;}
    
    public List<Visit_Participant__c> visitParticipantList{get;set;}

    public List<String[]> hisenseList{get;set;}
    public List<String[]> customerList{get;set;}

    public Boolean showVisitDetailInfo{get;set;}

    // 审批人集合
    public List<User> actorList{get;set;}
    // header时间
    public String dateStr{get;set;}

    public CustomerVisitPrintPDFController() {
        System.debug('CustomerVisitPrintPDFController starts...');

        String customerVisitId = ApexPages.CurrentPage().getParameters().get('ID');
        customerVisit = [SELECT Name, Customer__c, Visit_Category__c, Visit_Date__c, 
        Sales_Expected_Remind_Date__c, Place__c, Visit_Purpose__c, Status__c,
        Achivement__c, Visit_Matter__c,
        Id,Meeting_Minutes__c,MeetingContent__c,
        Att__c,CC__c,Description__c,Customer__r.name,Customer_Visit_Code__c,
        VisitCompletedDate__c
        FROM Customer_Visit__c 
        WHERE id=: customerVisitId LIMIT 1];

        List<Customer_Visit_Detail__c> cvdList = [SELECT Attend_From_Customer__c, Attend_From_Hisense__c,Meetting_Topic__c, Meetting_Method__c, Representative_From_Customer__c, Representative_From_Hisense__c, Date_Time__c  FROM Customer_Visit_Detail__c WHERE Customer_Visit_Lookup__c=:CustomerVisitId  order by CreatedDate DESC];
        if(cvdList != null && cvdList.size() > 0){
            visitDetail = cvdList[0];
        }
        
        if (String.isNotBlank(customerVisit.Customer__c)) {
            customer = [SELECT Name FROM Account WHERE id=: customerVisit.Customer__c];
            if (customer <> null) {
                customerName = customer.Name;
            } else {
                customerName = '';
            }
        } else {
            customerName = '';
        }

        ApexPages.currentPage().getHeaders().put('content-disposition', 
            '; filename=Visit Report-' + customerName + '-' + Datetime.now().format('yyyyMMdd')+'.pdf');
        
        // visit participant
        visitParticipantList = [SELECT  Customer_Participant__c, Customer_Participant_Position_del__c,
        Hisense_Participant__c,Hisense_Participant_Position__c, Customer_Visit__c
        FROM Visit_Participant__c WHERE Customer_Visit__c=: customerVisitId];
        //WHERE Customer_Visit__c=: customerVisit.Customer__c

        if (visitParticipantList == null) {
            visitParticipantList = new List<Visit_Participant__c>();
        } else {

            hisenseList = new List<String[]>();
            customerList = new List<String[]>();
            for (Visit_Participant__c visitParticipant : visitParticipantList) {
                // hisense participant
                if (visitParticipant.Hisense_Participant__c <> null)  {
                    String[] tempHisense = new String[2];
                    User user = [SELECT Position__c, Name FROM User where id=:visitParticipant.Hisense_Participant__c];
                    if (user <> null) {
                        tempHisense[0] = user.Name;
                    } else {
                        tempHisense[0] = '';
                    }
                    
                    if (visitParticipant.Hisense_Participant_Position__c == null) {
                        tempHisense[1] = '';
                    } else {
                        tempHisense[1] = visitParticipant.Hisense_Participant_Position__c;
                    }                
                    hisenseList.add(tempHisense);
                }

                // customer participant
                if (visitParticipant.Customer_Participant__c <> null) {
                    String[] tempCustomer = new String[2];
                    Contact contact = [SELECT Name FROM Contact where id=:visitParticipant.Customer_Participant__c];
                    if (contact <> null) {
                        tempCustomer[0] = contact.Name;
                    } else {
                        tempCustomer[0] = '';
                    }

                    if (visitParticipant.Customer_Participant_Position_del__c == null) {
                        tempCustomer[1] = '';
                    } else {
                        tempCustomer[1] = visitParticipant.Customer_Participant_Position_del__c;
                    }         
                    customerList.add(tempCustomer); 
                }
            }
        }
        // 获取流程信息
        try {
           
            ProcessInstance processResult = [SELECT Id,(SELECT StepStatus, Comments,ActorId FROM Steps order by createddate desc) FROM ProcessInstance
                                 WHERE targetObjectId =: customerVisitId limit 1];          
            // 总步数
            Integer setpSize = processResult.Steps.size();
            if(setpSize > 0){
                actorList = new List<User>();
                // 流程审批人
                for (Integer i = setpSize - 1 ; i >= 0; i--) {
                    String actorId = processResult.Steps[i].ActorId;
                    User actor = [select Id,Name,Title from User where Id = :actorId limit 1];
                    actorList.add(actor);
                }   
            }
        } catch (Exception e) {
            system.debug('error message: '+e.getMessage());
            system.debug('line number: '+e.getLineNumber());
        }
        // header日期
        List<String> month = new List<String>{'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};
        Date visitCompletedDate = customerVisit.VisitCompletedDate__c != null ? customerVisit.VisitCompletedDate__c : DATE.today();
        Integer yearStr = visitCompletedDate.year();
        Integer month_c = visitCompletedDate.month();
        Integer day_c = visitCompletedDate.day();
        dateStr = day_c + ' ' + month.get(month_c - 1) + ' ' + yearStr;
        
    }
}