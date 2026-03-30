/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 02-22-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public withOut sharing class PositionShareHandler implements Triggers.Handler {
    public void handle() {

        List<SObject> shareList = (List<SObject>)Trigger.new;
        Map<Id,SObject> shareOldMap = (Map<Id,SObject>)Trigger.oldMap;

        //判断共享对象中的纬度字段是否发生Change, IsChange__c = true
        Id recordId = Id.valueOf(String.valueOf(shareList[0].get('Id')));
        String objectApiName = recordId.getSObjectType().getDescribe().getName();
        if (!Test.isRunningTest()) {
            Share_Common_IntegrationService.positionFiledChangeCommon(shareList, shareOldMap, objectApiName);
        }
    }
}