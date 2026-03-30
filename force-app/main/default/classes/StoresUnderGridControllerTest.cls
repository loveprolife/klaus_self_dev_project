/**
 * @description       : 
 * @author            : fausfeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 07-07-2023
 * @last modified by  : fausfeng@deloitte.com.cn
**/
@isTest
public class StoresUnderGridControllerTest {
	@isTest
    static void testMethod1(){
        Gridding__c testGridding = new Gridding__c();
        testGridding.Name = '测试用重庆';
        testGridding.DivisionUnit__c = '市';
        testGridding.Gridding_Code__c = 'ChongQing';
        testGridding.Gridding_Level__c = 'A';
        testGridding.Parent_Gridding__c = 'a1d0o00000IKmNtAAL';
        Insert testGridding;

        Account acc = new Account();
        acc.Name = '测试用户';
        INSERT acc;
                
        Shop__c shop1 = new Shop__c();
        shop1.Account__c = acc.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '海信店';
        shop1.Grid__c = testGridding.id;
        INSERT shop1;

        Test.startTest();
        //StoresUnderGridController.getStoreList(testGridding.id);
        StoresUnderGridController.getStoreList('a1d0o00000IKmNtAAL');
        Test.stopTest();
    }
}