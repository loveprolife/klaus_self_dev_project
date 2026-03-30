@isTest
private class HisenseSSORegHandlerTest {
static testMethod void testCreateAndUpdateUser() {
    HisenseSSORegHandler handler = new HisenseSSORegHandler();

    User u = new User();
    Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
    u.username = 'HisenseSSORegHandlerTest@salesforce.com';
    u.email = 'HisenseSSORegHandlerTest@salesforce.com';
    u.lastName = 'HisenseSSORegHandlerTest';
    String alias = 'aa';
    u.alias = alias;
    u.languagelocalekey = 'en_US';
    u.localesidkey = 'en_US';
    u.emailEncodingKey = 'UTF-8';
    u.timeZoneSidKey = 'America/Los_Angeles';
    u.profileId = p.Id;
    u.HisenseSSOName__c = 'testId';
    insert u;
    Auth.UserData sampleData = new Auth.UserData(u.id, 'testFirst', 'testLast',
        'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
        null, new Map<String, String>{'language' => 'en_US'});
    User uc = handler.createUser(null, sampleData);

    handler.updateUser(u.id, null, sampleData);
}
}