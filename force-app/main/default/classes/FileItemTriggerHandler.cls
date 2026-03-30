public class FileItemTriggerHandler extends BaseTriggerHandler {
    protected override String getClassName() {
        return super.getClassName();
    }

    public override void beforeInsert() {
        //FileItemTriggerHandlerHelper.beforeInsertHandler(this.newList);
    }

    public override void afterInsert() {
        //FileItem__c fi = new FileItem__c(Id = this.newList[0].Id, base64__c='abc');
        //update fi;
        String jobID = System.enqueueJob(new CombineFileItems(this.newList));
        system.Debug('======== jobID==='+jobID);
    }
}