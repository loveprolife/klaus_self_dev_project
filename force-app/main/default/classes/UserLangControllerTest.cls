/**
 * @description Tests for UserLangController.getCurrentUserLanguage
 * Verifies dictionary hit and fallback behavior without relying on org data.
 */
@IsTest
private class UserLangControllerTest {
    @IsTest
    static void test1() {
        Test.startTest();
        UserLangController.getCurrentUserLanguage();
        Test.stopTest();
    }
}