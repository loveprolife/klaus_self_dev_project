@isTest
public class ShopSalesDataCreateControllerTest {
    @IsTest
    static void testShopSalesDataCreateController(){
        String str = 's.tring_1ijkt567___';
        Integer num = 1;
        Test.startTest();
        ShopSalesDataCreateController.getcolumnsData();
        ShopSalesDataCreateController.ConvertString(str, num);
        Test.stopTest();
        
    }
}