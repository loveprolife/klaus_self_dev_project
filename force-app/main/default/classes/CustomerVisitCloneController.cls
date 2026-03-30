public class CustomerVisitCloneController {

    public static Map<String,Schema.SObjectField> quoteLoopMap = Schema.SObjectType.Customer_Visit__c.fields.getMap();
    
    public class ReturnResult{
        public String code; //code "0" means success, and other codes means failure
        public String msg;  //result message
    }

    @AuraEnabled
    public static String copyCustomerVisit(String cvId) {
        ReturnResult result = new ReturnResult();
        result.code = '0';
        result.msg = 'Copied!';
        Customer_Visit__c newCV = new Customer_Visit__c();
        Savepoint sp = Database.setSavepoint();
        try{
            String querySql1 = 'SELECT ' + Utility.getQueryStringByFieldMap(quoteLoopMap) + ' FROM Customer_Visit__c WHERE Id =:cvId';
            Customer_Visit__c thisCV = Database.query(querySql1);
            newCV = thisCV.clone(false);
            newCV.Name += '_Copy';
            newCV.Status__c = 'Not Started';
            newCV.Approval_Status__c = 'Draft';
            newCV.Visit_Date__c = null;
            newCV.Sales_Expected_Remind_Date__c = null;
            
            insert newCV;
        }catch(Exception e){
            Database.rollback(sp);
            system.debug('error message: '+e.getMessage());
            system.debug('line number: '+e.getLineNumber());
            result.code = '1';
            result.msg = Utility.getProperErrorMessage(e.getMessage());
            return JSON.serialize(result);
        }
        result.msg = newCV.Id;
        return JSON.serialize(result);
    }
}