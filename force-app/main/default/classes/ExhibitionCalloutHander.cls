public  class ExhibitionCalloutHander extends BaseTriggerHandler {
    public String objectName = '';
    public ExhibitionCalloutHander(String objectName){
        this.objectName = objectName;
    }
    public override String getClassName() {
        return super.getClassName();
    }

    public override void afterInsert(){
        System.debug('Ethan--->'+getClassName());
        ExhibitionCallbackQueueable exh = new ExhibitionCallbackQueueable(getExpoIdList(objectName), objectName);
        ID jobID = System.enqueueJob(exh);
    }

    public override void afterUpdate(){
        System.debug('Ethan--->'+getClassName());
        ExhibitionCallbackQueueable exh = new ExhibitionCallbackQueueable(getExpoIdList(objectName), objectName);
        ID jobID = System.enqueueJob(exh);
    }
    public override void beforeDelete(){
        ExhibitionCallbackQueueable exh = new ExhibitionCallbackQueueable( getOldExpoIdList(objectName), objectName);
        ID jobID = System.enqueueJob(exh);
    }

    public List<String> getExpoIdList(String objectName) {
        if ('ExpoInfo__c' == objectName) 
            return new LisqContainer(this.newList).SelectSField('Id');
        if ('ExpoProductPreference__c' == objectName || 'ExpoBrandPreference__c' ==  objectName || 'ExpoCountrysBazaar__c' == objectName) 
            return new List<String>();

        return new LisqContainer(this.newList).SelectSField('ExpoId__c');
    }
    public List<String> getOldExpoIdList(String objectName) {
        if ('ExpoInfo__c' == objectName) 
            return new LisqContainer(this.oldList).SelectSField('Id');
        if ('ExpoProductPreference__c' == objectName || 'ExpoBrandPreference__c' ==  objectName || 'ExpoCountrysBazaar__c' == objectName) 
            return new List<String>();

        return new LisqContainer(this.oldList).SelectSField('ExpoId__c');
    }

}