@isTest
public class MessageBoardReadControllerTest {
    @IsTest
    static void testMessageBoardReadController(){
        Shop_Message_Board__c smb = new Shop_Message_Board__c();
        INSERT smb;
        Test.startTest();
        MessageBoardReadController.updateMessageBoardReadStatus(smb.Id);
        Test.stopTest();
        
    }
}