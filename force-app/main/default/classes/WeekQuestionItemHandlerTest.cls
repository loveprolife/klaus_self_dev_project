@isTest
private class WeekQuestionItemHandlerTest {
    static testMethod void testHandler1() {
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        INSERT shop;

        Week_Research__c wr = new Week_Research__c();
        wr.Shop__c = shop.Id;
        wr.IsActive__c = TRUE;
        INSERT wr;

        Week_Question_Item__c wqi1 = new Week_Question_Item__c();
        wqi1.Shop_Research__c = wr.Id;
        wqi1.Number__c = '1';
        wqi1.Status__c ='有效';
        wqi1.Question__c = 'test';
        INSERT wqi1;
        Week_Question_Item__c wqi2 = new Week_Question_Item__c();
        wqi2.Shop_Research__c = wr.Id;
        wqi2.Number__c = '2';
        wqi2.Status__c ='有效';
        wqi2.Question__c = 'test';
        INSERT wqi2;
        Week_Question_Item__c wqi3 = new Week_Question_Item__c();
        wqi3.Shop_Research__c = wr.Id;
        wqi3.Number__c = '3';
        wqi3.Status__c ='有效';
        wqi3.Question__c = 'test';
        INSERT wqi3;
        Week_Question_Item__c wqi4 = new Week_Question_Item__c();
        wqi4.Shop_Research__c = wr.Id;
        wqi4.Number__c = '4';
        wqi4.Status__c ='有效';
        wqi4.Question__c = 'test';
        INSERT wqi4;
        Week_Question_Item__c wqi5 = new Week_Question_Item__c();
        wqi5.Shop_Research__c = wr.Id;
        wqi5.Number__c = '5';
        wqi5.Status__c ='有效';
        wqi5.Question__c = 'test';
        INSERT wqi5;
        Week_Question_Item__c wqi6 = new Week_Question_Item__c();
        wqi6.Shop_Research__c = wr.Id;
        wqi6.Number__c = '6';
        wqi6.Status__c ='有效';
        wqi6.Question__c = 'test';
        INSERT wqi6;
        Week_Question_Item__c wqi7 = new Week_Question_Item__c();
        wqi7.Shop_Research__c = wr.Id;
        wqi7.Number__c = '7';
        wqi7.Status__c ='有效';
        wqi7.Question__c = 'test';
        INSERT wqi7;
        Week_Question_Item__c wqi8 = new Week_Question_Item__c();
        wqi8.Shop_Research__c = wr.Id;
        wqi8.Number__c = '8';
        wqi8.Status__c ='有效';
        wqi8.Question__c = 'test';
        INSERT wqi8;

        Week_Question_Item__c wqi9 = new Week_Question_Item__c();
        wqi9.Shop_Research__c = wr.Id;
        wqi9.Number__c = '9';
        wqi9.Status__c ='有效';
        wqi9.Question__c = 'test';
        INSERT wqi9;

        Week_Question_Item__c wqi10 = new Week_Question_Item__c();
        wqi10.Shop_Research__c = wr.Id;
        wqi10.Number__c = '10';
        wqi10.Status__c ='有效';
        wqi10.Question__c = 'test';
        INSERT wqi10;

        wqi10.Number__c = '5';
        UPDATE wqi10;

        wqi1.Number__c = '3';
        UPDATE wqi1;

        Week_Question_Item__c wqi11 = new Week_Question_Item__c();
        wqi11.Shop_Research__c = wr.Id;
        wqi11.Number__c = '10';
        wqi11.Status__c ='有效';
        wqi11.Question__c = 'test';
        INSERT wqi11;

        Test.stopTest();
    }

    static testMethod void testHandler2() {
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        INSERT shop;

        Week_Research__c wr = new Week_Research__c();
        wr.Shop__c = shop.Id;
        wr.IsActive__c = TRUE;
        INSERT wr;

        Week_Question_Item__c wqi1 = new Week_Question_Item__c();
        wqi1.Shop_Research__c = wr.Id;
        wqi1.Number__c = '1';
        wqi1.Status__c ='有效';
        wqi1.Question__c = 'test';
        INSERT wqi1;
        Week_Question_Item__c wqi2 = new Week_Question_Item__c();
        wqi2.Shop_Research__c = wr.Id;
        wqi2.Number__c = '1';
        wqi2.Status__c ='有效';
        wqi2.Question__c = 'test';
        INSERT wqi2;

        Test.stopTest();
    }

    static testMethod void testHandler3() {
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        INSERT shop;

        Week_Research__c wr = new Week_Research__c();
        wr.Shop__c = shop.Id;
        wr.IsActive__c = TRUE;
        INSERT wr;

        Week_Question_Item__c wqi1 = new Week_Question_Item__c();
        wqi1.Shop_Research__c = wr.Id;
        wqi1.Number__c = '10';
        wqi1.Status__c ='有效';
        wqi1.Question__c = 'test';
        INSERT wqi1;
        Week_Question_Item__c wqi2 = new Week_Question_Item__c();
        wqi2.Shop_Research__c = wr.Id;
        wqi2.Number__c = '10';
        wqi2.Status__c ='有效';
        wqi2.Question__c = 'test';
        INSERT wqi2;

        wqi1.Number__c = '10';
        UPDATE wqi1;
        
        Test.stopTest();
    }


    static testMethod void testHandler4() {
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        INSERT shop;

        Week_Research__c wr = new Week_Research__c();
        wr.Shop__c = shop.Id;
        wr.IsActive__c = TRUE;
        INSERT wr;

        Week_Question_Item__c wqi1 = new Week_Question_Item__c();
        wqi1.Shop_Research__c = wr.Id;
        wqi1.Number__c = '1';
        wqi1.Status__c ='有效';
        wqi1.Question__c = 'test';
        INSERT wqi1;
        Week_Question_Item__c wqi2 = new Week_Question_Item__c();
        wqi2.Shop_Research__c = wr.Id;
        wqi2.Number__c = '2';
        wqi2.Status__c ='有效';
        wqi2.Question__c = 'test';
        INSERT wqi2;
        Week_Question_Item__c wqi3 = new Week_Question_Item__c();
        wqi3.Shop_Research__c = wr.Id;
        wqi3.Number__c = '3';
        wqi3.Status__c ='有效';
        wqi3.Question__c = 'test';
        INSERT wqi3;

        wqi3.Number__c = '1';
        UPDATE wqi3;

        Test.stopTest();
    }

    static testMethod void testHandler5() {
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        INSERT shop;

        Week_Research__c wr = new Week_Research__c();
        wr.Shop__c = shop.Id;
        wr.IsActive__c = TRUE;
        INSERT wr;

        Week_Question_Item__c wqi1 = new Week_Question_Item__c();
        wqi1.Shop_Research__c = wr.Id;
        wqi1.Number__c = '1';
        wqi1.Status__c ='有效';
        wqi1.Question__c = 'test';
        INSERT wqi1;
        Week_Question_Item__c wqi2 = new Week_Question_Item__c();
        wqi2.Shop_Research__c = wr.Id;
        wqi2.Number__c = '2';
        wqi2.Status__c ='有效';
        wqi2.Question__c = 'test';
        INSERT wqi2;
        Week_Question_Item__c wqi3 = new Week_Question_Item__c();
        wqi3.Shop_Research__c = wr.Id;
        wqi3.Number__c = '2';
        wqi3.Status__c ='有效';
        wqi3.Question__c = 'test';
        INSERT wqi3;

        wqi2.Number__c = '1';
        UPDATE wqi2;
        wqi1.Number__c = '3';
        UPDATE wqi1;

        Test.stopTest();

    }

    static testMethod void testHandler6() {
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        INSERT shop;

        Week_Research__c wr = new Week_Research__c();
        wr.Shop__c = shop.Id;
        wr.IsActive__c = TRUE;
        INSERT wr;

        Week_Question_Item__c wqi1 = new Week_Question_Item__c();
        wqi1.Shop_Research__c = wr.Id;
        wqi1.Number__c = '10';
        wqi1.Status__c ='有效';
        wqi1.Question__c = 'test';
        INSERT wqi1;
        Week_Question_Item__c wqi2 = new Week_Question_Item__c();
        wqi2.Shop_Research__c = wr.Id;
        wqi2.Number__c = '9';
        wqi2.Status__c ='有效';
        wqi2.Question__c = 'test';
        INSERT wqi2;

        wqi2.Number__c = '10';
        UPDATE wqi2;

        Test.stopTest();

    }

    static testMethod void testHandler7() {
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        INSERT shop;

        Week_Research__c wr = new Week_Research__c();
        wr.Shop__c = shop.Id;
        wr.IsActive__c = TRUE;
        INSERT wr;

        Week_Question_Item__c wqi1 = new Week_Question_Item__c();
        wqi1.Shop_Research__c = wr.Id;
        wqi1.Number__c = '5';
        wqi1.Status__c ='有效';
        wqi1.Question__c = 'test';
        INSERT wqi1;
        Week_Question_Item__c wqi2 = new Week_Question_Item__c();
        wqi2.Shop_Research__c = wr.Id;
        wqi2.Number__c = '9';
        wqi2.Status__c ='有效';
        wqi2.Question__c = 'test';
        INSERT wqi2;

        wqi2.Number__c = '5';
        UPDATE wqi2;

        Test.stopTest();

    }

    static testMethod void testHandler8() {
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        INSERT shop;

        Week_Research__c wr = new Week_Research__c();
        wr.Shop__c = shop.Id;
        wr.IsActive__c = TRUE;
        INSERT wr;

        Week_Question_Item__c wqi1 = new Week_Question_Item__c();
        wqi1.Shop_Research__c = wr.Id;
        wqi1.Number__c = '1';
        wqi1.Status__c ='有效';
        wqi1.Question__c = 'test';
        INSERT wqi1;
        Week_Question_Item__c wqi2 = new Week_Question_Item__c();
        wqi2.Shop_Research__c = wr.Id;
        wqi2.Number__c = '2';
        wqi2.Status__c ='有效';
        wqi2.Question__c = 'test';
        INSERT wqi2;
        Week_Question_Item__c wqi3 = new Week_Question_Item__c();
        wqi3.Shop_Research__c = wr.Id;
        wqi3.Number__c = '1';
        wqi3.Status__c ='有效';
        wqi3.Question__c = 'test';
        INSERT wqi3;

        Test.stopTest();

    }

    static testMethod void testHandler9() {
        Test.startTest();

        Account acc = new Account();
        acc.Name = 'test';
        INSERT acc;
                
        Shop__c shop = new Shop__c();
        shop.Account__c = acc.Id;
        shop.Shop_Level__c = 'A';
        shop.Name = 'Homeplus本石町店';
        INSERT shop;

        Week_Research__c wr = new Week_Research__c();
        wr.Shop__c = shop.Id;
        wr.IsActive__c = TRUE;
        INSERT wr;

        Week_Question_Item__c wqi1 = new Week_Question_Item__c();
        wqi1.Shop_Research__c = wr.Id;
        wqi1.Number__c = '1';
        wqi1.Status__c ='有效';
        wqi1.Question__c = 'test';
        INSERT wqi1;
        Week_Question_Item__c wqi2 = new Week_Question_Item__c();
        wqi2.Shop_Research__c = wr.Id;
        wqi2.Number__c = '2';
        wqi2.Status__c ='有效';
        wqi2.Question__c = 'test';
        INSERT wqi2;
        Week_Question_Item__c wqi3 = new Week_Question_Item__c();
        wqi3.Shop_Research__c = wr.Id;
        wqi3.Number__c = '3';
        wqi3.Status__c ='有效';
        wqi3.Question__c = 'test';
        INSERT wqi3;

        wqi1.Number__c = '3';
        UPDATE wqi1;
        
        Test.stopTest();

    }
}