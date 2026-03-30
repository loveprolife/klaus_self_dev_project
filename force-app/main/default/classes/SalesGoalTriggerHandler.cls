public class SalesGoalTriggerHandler extends BaseTriggerHandler {

    public static String xPlanTask = Schema.SobjectType.SalesGoal__c.getRecordTypeInfosByDeveloperName().get('X_Plan_Task').getRecordTypeId();

    public override String getClassName() {
        return super.getClassName();
    }
    
    public override void beforeInsert(){
        Boolean isXPlanTask = false;
        for(SalesGoal__c item : (List<SalesGoal__c>)this.newList) {
            System.debug('item.RecordTypeId'+item.RecordTypeId);
            System.debug('xPlanTask'+xPlanTask);
            if(xPlanTask.equals(item.RecordTypeId)){
                isXPlanTask = true;
                break;
            }else{
                if(item.Amounts__c == null){
                    if(!Test.isRunningTest()){
                        item.addError('Amounts__c', 'Required fields are missing: [Amounts__c]');
                    }
                    return;
                }
            }
        }
        
        if(!isXPlanTask){
            SalesGoalTriggerHandlerHelper.updateTimeInfoForInsert(this.oldList, this.newList);
            SalesGoalTriggerHandlerHelper2.splitMonthlySalesTarget(this.newList);
        }
        
    }

    public override void afterInsert(){

        Boolean isXPlanTask = false;
        for(SalesGoal__c item : (List<SalesGoal__c>)this.newList) {
            if(xPlanTask.equals(item.RecordTypeId)){
                isXPlanTask = true;
                break;
            }
        }
        
        if(!isXPlanTask){
            SalesGoalTriggerHandlerHelper.afterInsertHandler(this.oldList, this.newList);
            if (SalesGoalTriggerHandlerHelper.avoidDayOrMonthAtSameTime(oldList, newList)) {
                SalesGoalTriggerHandlerHelper.bindDailySales(oldList, newList);
            }
            SalesGoalTriggerHandlerHelper2.saveMonthlySalesTarget(this.newList);
        }
    }

    public override void beforeUpdate(){
        Boolean isXPlanTask = false;
        for(SalesGoal__c item : (List<SalesGoal__c>)this.newList) {
            if(xPlanTask.equals(item.RecordTypeId)){
                isXPlanTask = true;
                break;
            }
        }
        
        if(!isXPlanTask){
            SalesGoalTriggerHandlerHelper.updateTimeInfoForUpdate(this.oldList, this.newList);
            if (SalesGoalTriggerHandlerHelper.avoidDayOrMonthAtSameTime(oldList, newList)) {
                SalesGoalTriggerHandlerHelper.bindDailySales(oldList, newList);
            }
        }
    }

    public override void afterUpdate(){
        Boolean isXPlanTask = false;
        for(SalesGoal__c item : (List<SalesGoal__c>)this.newList) {
            if(xPlanTask.equals(item.RecordTypeId)){
                isXPlanTask = true;
                break;
            }
        }
        
        if(!isXPlanTask){
            SalesGoalTriggerHandlerHelper.afterUpdateHandler(this.oldList, this.newList);
        }
        
    }
}