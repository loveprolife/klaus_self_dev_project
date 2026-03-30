/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-18-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
public class ShareInsertShareHistoryBatchTest {
    public static Position__c pos;
    public static List<String> shareObjectList;
    public static List<String> shareObjectList2;
    public static User user1;

    private static void makedata(){
        Id profileId = [SELECT Id FROM profile WHERE Name = '系统管理员' OR Name = 'System Administrator'][0].Id;
        user1 = new User(alias = 'Admin', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing123', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='test123@noemail.com');
        INSERT user1;

        pos = new Position__c();
        pos.DeveloperName__c = 'FU_GUAN_PATROLCLERKTEST';
        pos.Grouo_Name__c = '福关网格巡店员TEST';
        pos.Activity__c = true;
        INSERT pos;

        Share_Object__c shareObject = new Share_Object__c(Name = 'Actual And Same Period Report',
                                        Object_API__c = 'Actual_And_Same_Period_Report__c',
                                        Object_Share__c = 'Actual_And_Same_Period_Report__Share',
                                        Account_Product_Line__c = 'Share_Account_Product_Line__c',
                                        Share_Type__c = 'ParentId',
                                        Refresh_Query_Statement__c = 'SELECT IsNew__c,IsChange__c,Share_Account_Product_Line__c,Daily_Inspection_Report__c FROM Actual_And_Same_Period_Report__c '
        );
        INSERT shareObject;

        Actual_And_Same_Period_Report__c apr = new Actual_And_Same_Period_Report__c();
        INSERT apr;

        Actual_And_Same_Period_Report__Share aprShare = new Actual_And_Same_Period_Report__Share();
        aprShare.RowCause = 'Manual';
        aprShare.ParentId = apr.Id;
        aprShare.UserOrGroupId  = user1.Id;
        aprShare.AccessLevel = 'Read';
        INSERT aprShare;

        Position__c queryShareObj = [SELECT Id, GroupId__c FROM Position__c WHERE Id = :pos.Id];

        Share_History__c sh = new Share_History__c();
        sh.Position__c = pos.Id;
        sh.Share_Object_Name__c = shareObject.Object_API__c;
        sh.Is_New_Share__c = False;
        sh.Share_ID__c = pos.Id;
        sh.GroupId__c = user1.Id;
        INSERT sh;

        shareObjectList = new List<String>();
        shareObjectList.add(shareObject.Object_Share__c);

        shareObjectList2 = new List<String>();
        shareObjectList2.add(shareObject.Object_Share__c);
        shareObjectList2.add(shareObject.Object_Share__c);
    }
    @isTest
    static void testShareInsertShareHistoryBatch1(){
        makedata();
        Test.startTest();
        Position__c queryShareObj = [SELECT Id, GroupId__c FROM Position__c WHERE Id = :pos.Id];
        ShareInsertShareHistoryBatch theBatch = new ShareInsertShareHistoryBatch(
            queryShareObj.Id,
            user1.Id, 
            shareObjectList,
            false
        );
        Database.executeBatch(theBatch, 1);
        Test.stopTest();
    }

    @isTest
    static void testShareInsertShareHistoryBatch2(){
        makedata();
        Test.startTest();
        Position__c queryShareObj = [SELECT Id, GroupId__c FROM Position__c WHERE Id = :pos.Id];
        ShareInsertShareHistoryBatch theBatch = new ShareInsertShareHistoryBatch(
            queryShareObj.Id,
            user1.Id, 
            shareObjectList,
            true
        );
        Database.executeBatch(theBatch, 1);
        Test.stopTest();
    }

    // @isTest
    // static void testShareInsertShareHistoryBatch3(){
    //     makedata();
    //     Test.startTest();
    //     ShareInsertShareHistoryBatch batch2 = new ShareInsertShareHistoryBatch(pos.Id,pos.Id,shareObjectList2,false);
    //     Database.executeBatch(batch2);
    //     Test.stopTest();
        
    // }
}