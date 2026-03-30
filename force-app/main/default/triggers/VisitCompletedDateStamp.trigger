trigger VisitCompletedDateStamp on Customer_Visit__c (before update) {

    for(Customer_Visit__c cv : Trigger.New) {
        if(cv.Status__c == 'Completed') {
            cv.VisitCompletedDate__c  = Date.TODAY();
        }
    }
}