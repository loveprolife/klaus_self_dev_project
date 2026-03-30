/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-29-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
public class Share_Common_IntegrationTDGWTest {
    static testMethod void testShare_Common_IntegrationTDGW(){
        Id profileId = [SELECT Id FROM profile WHERE Name = 'System Administrator' OR Name = '系统管理员'][0].Id;
        User user1 = new User(alias = '巡店员', email='test123TDGW@noemail.com',
        emailencodingkey='UTF-8', lastname='test123TDGW', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123TDGW@noemail.com');
        INSERT user1;
      	Share_Object__c shareObject = new Share_Object__c(Name = '巡店任务',
                                        Object_API__c = 'Inspection_Shop_Task__c',
                                        Object_Share__c = 'Inspection_Shop_Task__Share',
                                        Shop_Filed_API__c = 'Share_Shop__c',
                                        Share_Type__c = 'ParentId'                             
		);    
		INSERT shareObject;  
        
        
        //system.debug('testShareObject' +testShareObject);
        Account acc2 = new Account();
        acc2.Name = 'Edion';
        INSERT acc2;
        Inspection_Shop_Task__c ist = new Inspection_Shop_Task__c();
        ist.OwnerId = user1.Id;
        // ist.IsNew__c = true;
        ist.ExternalID__c = acc2.Id;
        ist.Status__c = '未到访';
        ist.Inspection_Date__c = DATE.today();
        INSERT ist;



        Share_Relation_Object__c sro = new Share_Relation_Object__c();
        sro.Name = '巡店员日报';
        sro.Relation_Object_API__c = 'Daily_Inspection_Report__c';
        sro.Object_Lookup_API__c = 'Daily_Inspection_Report__c';
        sro.Object_Share__c = 'Daily_Inspection_Report__Share';
        sro.Share_Type__c = 'ParentId';
        sro.Share_RowCause__c = 'Position_Share__c';
        sro.Share_Object__c = shareObject.Id;
        INSERT sro;

        Share_Relationship_Item__c sri = new Share_Relationship_Item__c();
        sri.Share_Relationship_ID__c = sro.Id;
        sri.ShareItemId__c = shareObject.Id;
        sri.External_Key_ID__c = acc2.Id;
        INSERT sri;
                        
        Share_Log__c log = new Share_Log__c();
        log.Share_Object__c = shareObject.Id;
        log.Row_Cause__c = sro.Share_RowCause__c;
        INSERT log;
        
        List<String> deleteSriList = new List<String>();
        deleteSriList.add(sri.Id);
        
        Map<String, String> causeMap = new Map<String, String>();
        causeMap.put(sri.Id,log.Row_Cause__c);
        
        Map<String, List<String>> parameterList = new Map<String, List<String>>();
        parameterList.put(sri.Id,deleteSriList);
        
        List<Object> shareDataList = new List<Object>();
        shareDataList.add(shareObject);

        List<SObject> scope = new List<SObject>();
        scope.add(shareObject);

        Set<String> changeIdSet = new Set<String>();
        changeIdSet.add('ParentId');

        Set<String> shareRelatIdSet = new Set<String>();
        shareRelatIdSet.add(sro.Id);
        
		List<String> slist = new List<String>();
		slist.add(shareObject.Id);
        Map<String, List<String>> checkShareDataIdMap = new Map<String, List<String>>();
        checkShareDataIdMap.put(sri.Share_Relationship_ID__c,slist);
        
        test.startTest();
        List<Share_Object__c> soList = Share_Common_IntegrationService.queryShareObject('Inspection_Shop_Task__c');
        Share_Object__c testShareObject = soList[0];
        Share_Common_IntegrationTDGW.deleteChangeDataShare(testShareObject,checkShareDataIdMap,shareDataList,deleteSriList,changeIdSet);
        Share_Common_IntegrationTDGW.sortChunks(scope);
        Share_Common_IntegrationTDGW.writeShareLogs(testShareObject.Name,parameterList,causeMap);
        test.stopTest();
	}

}