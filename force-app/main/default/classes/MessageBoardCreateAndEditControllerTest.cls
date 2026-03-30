@IsTest
private class MessageBoardCreateAndEditControllerTest {
    @IsTest
    static void testEdit(){
        Shop_Message_Board__c messageBoard = new Shop_Message_Board__c();
        insert messageBoard;
        Test.startTest();
        MessageBoardCreateAndEditController.initData(messageBoard.Id);
        MessageBoardCreateAndEditController.ReturnData returnData = new MessageBoardCreateAndEditController.ReturnData();
        returnData.message = '测试';
        MessageBoardCreateAndEditController.saveRecord(JSON.serialize(returnData), messageBoard.Id);

        Test.stopTest();
        
    }

    @IsTest
    static void testNew(){
        Test.startTest();
        MessageBoardCreateAndEditController.initData(null);
        MessageBoardCreateAndEditController.ReturnData returnData = new MessageBoardCreateAndEditController.ReturnData();
        returnData.message = '测试';
        MessageBoardCreateAndEditController.saveRecord(JSON.serialize(returnData), null);

        Test.stopTest();
        
    }
}