public class CreditShippingPlanTriggerHandler implements Triggers.Handler{
    public void handle() {
        if (Trigger.isBefore) {
            if(Trigger.isDelete){
                for (Credit_Shipping_Plan__c wst : ((list<Credit_Shipping_Plan__c>)Trigger.old)) {
                    Credit_Limit_Application__c credit = [Select id, Approval_Status__c from Credit_Limit_Application__c where id = :wst.Credit_Limit_Application__c];
                    if(!'Draft,Rejected,Risk Post Rejected,Insurance Company Rejected'.contains(credit.Approval_Status__c)){
                        wst.addError(Label.Shipping_Plan_Info);
                    }
                }
            }

            if(Trigger.isInsert || Trigger.isUpdate){
                for (Credit_Shipping_Plan__c wst : ((list<Credit_Shipping_Plan__c>)Trigger.new)) {
                    Credit_Limit_Application__c credit = [Select id, Approval_Status__c from Credit_Limit_Application__c where id = :wst.Credit_Limit_Application__c];
                    if(!'Draft,Rejected,Risk Post Rejected,Insurance Company Rejected'.contains(credit.Approval_Status__c)){
                        wst.addError(Label.Shipping_Plan_Info);
                    }
                }
            }
        }
    }
}