public class ExpoApplyInfoTriggerHander extends BaseTriggerHandler {

    public override String getClassName() {
        return super.getClassName();
    }
    
    public override void beforeInsert(){
        ExpoApplyInfoTriggerHanderHelper.duplicateCheck(this.newList, new List<ExpoApplyInfo__c>());
   		ExpoApplyInfoTriggerHanderHelper.initOwner(this.newList);

        // add by Sunny 
        ExpoApplyInfoTriggerHanderHelper.matchingOnSiteReceptionists(this.oldList, this.newList);
    }
   
   	public override void beforeUpdate(){
        ExpoApplyInfoTriggerHanderHelper.duplicateCheck(this.newList, this.oldList);
        ExpoApplyInfoTriggerHanderHelper.isAllocated(this.oldList, this.newList);

        // add by Sunny 
        ExpoApplyInfoTriggerHanderHelper.matchingOnSiteReceptionists(this.oldList, this.newList);
   	}

    public override void afterInsert(){
        ExpoApplyInfoTriggerHanderHelper.sendNotifyToOwners(NULL, this.newList);

        // add by Sunny 
        ExpoApplyInfoTriggerHanderHelper.messageToSiteReceptionists(this.oldList, this.newList);
    }
    public override void afterUpdate(){
        ExpoApplyInfoTriggerHanderHelper.sendNotifyToOwners(this.oldList, this.newList);

        // add by Sunny 
        ExpoApplyInfoTriggerHanderHelper.messageToSiteReceptionists(this.oldList, this.newList);

    }

}