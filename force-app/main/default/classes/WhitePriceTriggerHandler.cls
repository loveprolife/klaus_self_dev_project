public class WhitePriceTriggerHandler extends BaseTriggerHandler {

    protected override String getClassName() {
        return super.getClassName();
    }

    public override void beforeInsert(){
		List<String> productIdList = new LisqContainer(this.newList).selectsField('Product__c');
        Map<Id, Product__c> producMap = new Map<Id, Product__c>([SELECT Id, Name, sales_region__c FROM Product__c WHERE sales_region__c != null AND Id IN :productIdList]);
        for(WhitePrice__c item : (List<WhitePrice__c>)this.newList) {
            if(!String.isBlank(item.Product__c) && producMap.containsKey(item.Product__c)) {
                item.Match__c = producMap.get(item.Product__c).Id;
                item.SalesRegion__c = producMap.get(item.Product__c).sales_region__c;
            }
        }
    }
    
    public override void beforeUpdate(){
        Map<Id, WhitePrice__c> oldMap = new Map<Id, WhitePrice__c>((List<WhitePrice__c>)this.oldList);
		List<String> productIdList = new LisqContainer(this.newList).selectsField('Product__c');
        Map<Id, Product__c> producMap = new Map<Id, Product__c>([SELECT Id, Name, sales_region__c FROM Product__c WHERE sales_region__c != null AND Id IN :productIdList]);
        for(WhitePrice__c item : (List<WhitePrice__c>)this.newList) {
            if(!String.isBlank(item.Product__c) && (item.Product__c != oldMap.get(item.Id).Product__c) && producMap.containsKey(item.Product__c)) {
                item.Match__c = producMap.get(item.Product__c).Id;
                item.SalesRegion__c = producMap.get(item.Product__c).sales_region__c;
            }
        }
    }

}