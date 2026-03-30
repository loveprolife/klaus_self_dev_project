@isTest
public with sharing class LookupTest {
    testMethod static void test01() {
        Test.startTest();
        Lookup.runTest();
        Test.stopTest();
    }
}