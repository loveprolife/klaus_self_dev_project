@isTest
public with sharing class UploadFilesControllerTest {
    // @isTest
    // static void testUploadFilesController(){
    //     Account testAccount = new Account();
    //     testAccount.Name = '测试UploadFilesController用';
    //     Insert testAccount;
    //     ContentVersion testContentVersion1 = new ContentVersion();
    //     testContentVersion1.ContentDocumentId = '0690l000003bfgnAAA';
    //     testContentVersion1.PathOnClient = '新建文本文档.txt';
    //     testContentVersion1.VersionData = Blob.valueOf('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');
    //     //testContentVersion1.VersionData = EncodingUtil.base64Decode(String.valueOf('data:image/png;base64,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'));

    //     ContentVersion testContentVersion2 = new ContentVersion();
    //     testContentVersion2.ContentDocumentId = '0690l000003bhDnAAI';
    //     testContentVersion2.PathOnClient = '新建文本文档.txt';
    //     testContentVersion2.VersionData = Blob.valueOf('iVBORw0KGgoAAAANSUhEUgAAAKYAAABGCAIAAADJrniiAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAEnQAABJ0Ad5mH3gAAAVZSURBVHhe7Z0rU+0wFIWrGCQSiUQikUgkEolEInFIJPJIfgLySCTySIZfgEQiuWuaRSY3KTlJ8+o0+xN3IE3z2KvZ2Xkwd/gROkMk7441SL7dbk9OToZhwL/Pz89M7QP09+LiIqrXa5Bc6a04PDxk6tr5+vq6u7vTvf7+/uaDfaxB8sfHR9VzhUrUQz8vC3EkaMPR0RHbNAzX19d8EMB65nL2/lfyEnor2jqS9/f38/NzNmXk8vIyfIiD1UpuDf2M3N7eqioqA0/+8PCAD47tmOtyqkoOZxsba4RDM/xKviaU2KYnh/D4pvk4kqoGOj4+Vs3l71lRtgD8fS1sNhtTbADHDvfOx/FUNRCbXEYVFr0uyTG42auRLMGjSL5cTL0zrhRE8iVirrlBbEzuRyRfFm6klldvIJIvCDdSy643EMmXQolIbRKRfBEUitQmEckbUzRSm0Qkb0aFSG0SkbwNcN0VIrVJRPLauEdhpSdviyQDqTPp8Bazi71Krjx5+lFYIkkGQotV0wNPSlRmwN+zwqIXKbk7bacchSWSZCDzTJpJXpi1J8ldsUHiUVgiSQYyV5NM8sKshSWH79lsNkw1KHpa7zIpdhNPbjHT+tbNssC7V8xdRnJzjgRoHta7Hx8fsLvZ1EKn9RbQdYFiK2ZaX112UISvLvhCGcnDbz7xhTI0D8j3Et1/d3yHryb5TgGj73Y7jGmzYX9R9Oba09NTbECuVz2Tk1EJQq1vKa1AyufnJ3MEwNfySR6uNIDYUa2NxYxswgNyq/EVtA+1fqBZm4MZB9K+vr6qZr+8vJydnfHZqAQ+kRLC39/fs47IgHxyPiq6fguVPHymbIKltAnmnaurK+YbySu8NXnP2DdF/pubG74/ghaWG+vzfaw1gJrgUdrCbW268O5uWuI+Od41Sys01rNNqyHo/hR1XB4yCm/dYEE5WTplelOUydSsVJUcxi3amUAm/ROClXDtzUgN5N1Nw1hnucNQwr1XldzsDJPa4ZmYIL9ncWXq7c85G+0OQXaPWNv0ujOtfLvFX8KjnZMjDInMUfKE23Lveb+q2pIvxLe7TGpvfZdw+/qTLX2jwQzl8tqqtuSmb8/y8arDkoxz3l8jDD/ozQl8HEX1VpgtyegUG8ypeT9eLQOmWCYl444w058DuASVszQlnGIDyc2Pl0kJaKOAjFuq1gizjpGYqTymU2RSMg0kB+xEjm7AKNCAxY2jIZcP1B/TwcGB+gFU8OcWrFgkN4EM1pZqyH7cXswRpuGzirBikdzFDLkxwWcZjqo0DSYOPqgI6xbJJ8FErifdLPKoojRMrQvrFsn/AmOdRQ/Dbrdj6lxY0EiTIQ5YvUjuQc/r+IFJc1HlKJhUHVYvknvA4GbpyYt1ljLCpOqwepHcj3njIGWxziJGmFQdVi+S+3EX6+EHoyZ8f6TEiVkIrF4k34u7WIfwsbLxzZGMW55RsHqRPBD3fCwqjOc7v5S4sLAX1i2SRwHhT09PVY1RYbx6xeSk4oVzBSsWyWOZF8bzBYeawrNKkXwGZhiPaC5kR5a5x9MU696xBvLPiw1D2G63rEYkn4EVxsPVv7298dkfMOtvOz3Cz14U+DEPbZmUTEeSAzeM9+vETP+30yO8AuP+Nux2vR/zXmXG7d6+JFdgqRZyBd28CcOkKdxFQXai/h+NvbQxOqysOsPfq4ORbTp54G7SaacaYvFywqOd8CusJgdtjK6uGbU6m9IE6hRr8ai/h/UT9bfcgTQbZwvBnd1dmHUt9C65wjPcm7ui7Ijk3SGSd4dI3h0ieXeI5N0hkneHSN4dInl3iOTdIZJ3xs/PP5j+E2VQvcAxAAAAAElFTkSuQmCC');
	// 	//testContentVersion2.VersionData = EncodingUtil.base64Decode(String.valueOf('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAKYAAABGCAIAAADJrniiAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAEnQAABJ0Ad5mH3gAAAVZSURBVHhe7Z0rU+0wFIWrGCQSiUQikUgkEolEInFIJPJIfgLySCTySIZfgEQiuWuaRSY3KTlJ8+o0+xN3IE3z2KvZ2Xkwd/gROkMk7441SL7dbk9OToZhwL/Pz89M7QP09+LiIqrXa5Bc6a04PDxk6tr5+vq6u7vTvf7+/uaDfaxB8sfHR9VzhUrUQz8vC3EkaMPR0RHbNAzX19d8EMB65nL2/lfyEnor2jqS9/f38/NzNmXk8vIyfIiD1UpuDf2M3N7eqioqA0/+8PCAD47tmOtyqkoOZxsba4RDM/xKviaU2KYnh/D4pvk4kqoGOj4+Vs3l71lRtgD8fS1sNhtTbADHDvfOx/FUNRCbXEYVFr0uyTG42auRLMGjSL5cTL0zrhRE8iVirrlBbEzuRyRfFm6klldvIJIvCDdSy643EMmXQolIbRKRfBEUitQmEckbUzRSm0Qkb0aFSG0SkbwNcN0VIrVJRPLauEdhpSdviyQDqTPp8Bazi71Krjx5+lFYIkkGQotV0wNPSlRmwN+zwqIXKbk7bacchSWSZCDzTJpJXpi1J8ldsUHiUVgiSQYyV5NM8sKshSWH79lsNkw1KHpa7zIpdhNPbjHT+tbNssC7V8xdRnJzjgRoHta7Hx8fsLvZ1EKn9RbQdYFiK2ZaX112UISvLvhCGcnDbz7xhTI0D8j3Et1/d3yHryb5TgGj73Y7jGmzYX9R9Oba09NTbECuVz2Tk1EJQq1vKa1AyufnJ3MEwNfySR6uNIDYUa2NxYxswgNyq/EVtA+1fqBZm4MZB9K+vr6qZr+8vJydnfHZqAQ+kRLC39/fs47IgHxyPiq6fguVPHymbIKltAnmnaurK+YbySu8NXnP2DdF/pubG74/ghaWG+vzfaw1gJrgUdrCbW268O5uWuI+Od41Sys01rNNqyHo/hR1XB4yCm/dYEE5WTplelOUydSsVJUcxi3amUAm/ROClXDtzUgN5N1Nw1hnucNQwr1XldzsDJPa4ZmYIL9ncWXq7c85G+0OQXaPWNv0ujOtfLvFX8KjnZMjDInMUfKE23Lveb+q2pIvxLe7TGpvfZdw+/qTLX2jwQzl8tqqtuSmb8/y8arDkoxz3l8jDD/ozQl8HEX1VpgtyegUG8ypeT9eLQOmWCYl444w058DuASVszQlnGIDyc2Pl0kJaKOAjFuq1gizjpGYqTymU2RSMg0kB+xEjm7AKNCAxY2jIZcP1B/TwcGB+gFU8OcWrFgkN4EM1pZqyH7cXswRpuGzirBikdzFDLkxwWcZjqo0DSYOPqgI6xbJJ8FErifdLPKoojRMrQvrFsn/AmOdRQ/Dbrdj6lxY0EiTIQ5YvUjuQc/r+IFJc1HlKJhUHVYvknvA4GbpyYt1ljLCpOqwepHcj3njIGWxziJGmFQdVi+S+3EX6+EHoyZ8f6TEiVkIrF4k34u7WIfwsbLxzZGMW55RsHqRPBD3fCwqjOc7v5S4sLAX1i2SRwHhT09PVY1RYbx6xeSk4oVzBSsWyWOZF8bzBYeawrNKkXwGZhiPaC5kR5a5x9MU696xBvLPiw1D2G63rEYkn4EVxsPVv7298dkfMOtvOz3Cz14U+DEPbZmUTEeSAzeM9+vETP+30yO8AuP+Nux2vR/zXmXG7d6+JFdgqRZyBd28CcOkKdxFQXai/h+NvbQxOqysOsPfq4ORbTp54G7SaacaYvFywqOd8CusJgdtjK6uGbU6m9IE6hRr8ai/h/UT9bfcgTQbZwvBnd1dmHUt9C65wjPcm7ui7Ijk3SGSd4dI3h0ieXeI5N0hkneHSN4dInl3iOTdIZJ3xs/PP5j+E2VQvcAxAAAAAElFTkSuQmCC'));
         
    //     //ContentVersion testContentVersion3 = new ContentVersion();
    //     //testContentVersion3.ContentDocumentId = '0690l000003bfhRAAQ';
    //     //testContentVersion3.PathOnClient = '新建文本文档.txt';
    //     //String codeString = '/services/data/v48.0/sobjects/ContentVersion/0680l000003MPELAA4/VersionData';
    //     //testContentVersion3.VersionData = EncodingUtil.base64Decode(String.valueOf(codeString));
    //     //insert testContentVersion3;
        
    //     List<ContentVersion> contentVersionList1 = new List<ContentVersion>();
    //     contentVersionList1.add(testContentVersion1);
    //     List<ContentVersion> contentVersionList2 = new List<ContentVersion>();
    //     contentVersionList2.add(testContentVersion2);
    //     Map<Id, List<ContentVersion>> filesMap3 = new Map<Id, List<ContentVersion>>();
    //     filesMap3.put('0680l000003MOPrAAO',contentVersionList1);
    //     filesMap3.put('0680l000003MPELAA4',contentVersionList2);
        
    //     Task taskTest1 = new Task();
    //     taskTest1.CurrencyIsoCode = 'USD';
    //     taskTest1.whatId = testAccount.id;
    //     taskTest1.Status = 'Not Started';
    //     taskTest1.Description = '用于测试UploadileController1';
    //     taskTest1.Subject = 'Call';
    //     Insert taskTest1;
    //     Task taskTest2 = new Task();
    //     taskTest2.CurrencyIsoCode = 'USD';
    //     taskTest2.whatId = testAccount.id;
    //     taskTest2.Status = 'Not Started';
    //     taskTest2.Description = '用于测试UploadileController1';
    //     taskTest2.Subject = 'Call';
    //     Insert taskTest2;
    //     List<Task> taskList = new List<Task>();
    //     taskList.add(taskTest1);
    //     taskList.add(taskTest2);
    //     String recordListJson = JSON.serialize(taskList);
    //     Map<String,Object> testTaskMap = new Map<String,Object>();
    //     testTaskMap.put('index',taskTest2);
    //     String fileMapJosn = JSON.serialize(testTaskMap);
        
    //     ContentDocumentLink testContentDocumentLink = new ContentDocumentLink();
    //     testContentDocumentLink.LinkedEntityId = testAccount.id;
    //     testContentDocumentLink.ContentDocumentId = '0690l000003bgSEAAY';
    //     //testContentDocumentLink.ContentDocumentId = '0690l000003bfgnAAA';
    //     System.debug(testContentDocumentLink);
    //     Insert testContentDocumentLink;
        
    //     Map<String,Object> kv = new Map<String,Object>();
    //     kv.put('name','测试用map.txt');
    //     kv.put('versionData','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');
    //     kv.put('src','iVBORw0KGgoAAAANSUhEUgAAAKYAAABGCAIAAADJrniiAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAEnQAABJ0Ad5mH3gAAALbSURBVHhe7ZqhtoJAEIaJRKPRR/ARiEai0Wgk2kweH8Fo1GYkGo0+hpFo9M65O3I4cLgCR2Zn7/xfY2HZPfuxu8NA9ALGgHJzQLk5oNwcUG4OKDcHlJsDys0B5eaAcnNAuTmg3BxQbg4oNweUmwPKzQHl5oByc+hSfj6fd7sdH4Bx0KWcfEcRFp5xwfiaA8rNAeXmkFOe53mSJMfjkY+BJ+SUT6dTCs3iOOZj4Ak55eTbwcfAE1BuDig3B5SbA8rNAeXmgHJzQLk5oNwcepXneT6bzbhOBSrMsuzxePB1grR1qQZdozmvrFR5URQuQfs3NLiHw4HrjE8X3444jiU71gtdyjtOoxrb7Zbrj8x+v+cmu0HXc01N6FLe9L1YLPjcm8vlMp/P+fQbMesfqT4WOr8h6VJeHa+PO+Lz+aQHgq+Oovv9zid8Qw8l96lz4CKJLuV9IetJkrjbpmnKpV6hx3QymbguEVyqibCVEzS5+b4i43s6nbpHG+v1mqtpInjlBN9XRHnovgko70eWZdxYO8vlknYcrqAPKO+H2pixO1Dem2rM6KDVXm3ipQmUD6EaM5boyQ38TdjKi6Kobq5cKgJFZ9xqhY+5BA2EqpxGthY8U9DE52Sp7e76/9oOTHlbEp4G3WOQTE2vVivuiuxiM4DAlDc/r+lZS7lDUF7C4zF0RJrzW9XrL0Xs3C0oL+HxGDoitfnNpTqgx7HMq/sKKboTjHKu/IueXGYzitSz8LQRjHKKhLl+T7612Xf5fUNtXr1KMMr7/pFS5SsvTv/DNxGMcmKw9a/IaGtd+UeUJkLKr9erGyCaK1wEPCGkvExPbjYbLgKeEFJevmLdbjcuAp4QUu58E3wM/AHl5pBwEFAy0gISDsqNXH8y0gISyp1vIqz31//K6MqxqmtjdA3lqp4kCRcBr4yu3Pkm4jjGwq6B0ZWXX8AQuylhdOXuD9Q0TTHFlYCQyhiv1w/nkM0Sn7jVqgAAAABJRU5ErkJggg==');
        
    //     List<Map<String,Object>> msList = new List<Map<String,Object>>();
    //     msList.add(kv);
    //     Map<Id, List<Map<String,Object>>> files = new Map<Id, List<Map<String,Object>>>();
    //     files.put(testAccount.id,msList);
    //     //files.put('iid',msList);
        
    //     Test.startTest();
    //     UploadFilesController.getFiles(testAccount.id);
    //     UploadFilesController.saveFiles(recordListJson,fileMapJosn,taskList,testAccount.id);
        
    //     ContentVersion deleteContentVersion = [Select Id From ContentVersion Limit 1];
    //     //UploadFilesController.saveFiles(files);
    //     UploadFilesController.deleteFiles(new String[]{deleteContentVersion.Id});
    //     Test.stopTest();
    // }

    @isTest
    static void testSaveFiles(){
        Account testAccount = new Account();
        testAccount.Name = '测试UploadFilesController用';
        Insert testAccount;

        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf('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');
        cv.Title = '新建文本文档.txt';
        cv.PathOnClient = '新建文本文档.txt';

        List<ContentVersion> cvList = new List<ContentVersion>();
        cvList.add(cv);

        Map<Id, List<ContentVersion>> testMap = new Map<Id, List<ContentVersion>>();
        testMap.put(testAccount.Id, cvList);

        Test.startTest();
        UploadFilesController.saveFiles(testMap);
        
        Test.stopTest();

    }

    
    @isTest
    static void testGetFilesAndDeleteFiles(){
        Account testAccount = new Account();
        testAccount.Name = '测试UploadFilesController用';
        Insert testAccount;
        
        Account testAccount2 = new Account();
        testAccount2.Name = '测试UploadFilesController用2';
        Insert testAccount2;

        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf('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');
        cv.Title = '新建文本文档.txt';
        cv.PathOnClient = '新建文本文档.txt';
        insert cv;

        ContentVersion qrcv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =:cv.id];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = qrcv.ContentDocumentId;
        cdl.LinkedEntityId = testAccount.Id;
        cdl.ShareType = 'V';

        insert cdl;
        
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.ContentDocumentId = qrcv.ContentDocumentId;
        cdl2.LinkedEntityId = testAccount2.Id;
        cdl2.ShareType = 'V';

        insert cdl2;
        
        Test.startTest();
        UploadFilesController.getFiles(testAccount.Id, null);
        // String[] strs = [cdl.Id];
        List<String> ids = new List<String>();
        ids.add(cdl.Id);
        UploadFilesController.deleteFiles(ids,String.valueof(testAccount2.Id));
        
        Test.stopTest();
    }
    
    @isTest
    static void testSaveFiles2(){
        Account testAccount = new Account();
        testAccount.Name = '测试UploadFilesController用';
        Insert testAccount;

        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf('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');
        cv.Title = '新建文本文档.txt';
        cv.PathOnClient = '新建文本文档.txt';
        insert cv;

        ContentVersion qrcv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =:cv.id];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = qrcv.ContentDocumentId;
        cdl.LinkedEntityId = testAccount.Id;
        cdl.ShareType = 'V';

        insert cdl;

        Test.startTest();


        Map<String, String> item1 = new Map<String, String>();
        item1.put('index', '1');
        List<Map<String, String>> item1List = new List<Map<String, String>>();
        item1List.add(item1);

        Map<String, List<ContentVersion>> item2 = new Map<String, List<ContentVersion>>();
        List<ContentVersion> item22 = new List<ContentVersion>();
        item22.add(qrcv);
        item2.put('1',item22);

        
        Account acc2 = new Account();
        acc2.Name = 'acc2';
        Insert acc2;
        List<Account> acc2List = new List<Account>();
        acc2List.add(acc2);

        UploadFilesController.saveFiles(JSON.serialize(item1List), JSON.serialize(item2),acc2List,testAccount.Id);
        
        Test.stopTest();
    }
    
    @isTest
    static void testSaveFiles22(){
        Account testAccount = new Account();
        testAccount.Name = '测试UploadFilesController用';
        Insert testAccount;

        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf('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');
        cv.Title = '新建文本文档.txt';
        cv.PathOnClient = '新建文本文档.txt';
        insert cv;

        ContentVersion qrcv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =:cv.id];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = qrcv.ContentDocumentId;
        cdl.LinkedEntityId = testAccount.Id;
        cdl.ShareType = 'V';

        insert cdl;

        Test.startTest();


        Map<String, String> item1 = new Map<String, String>();
        item1.put('index', '1');
        List<Map<String, String>> item1List = new List<Map<String, String>>();
        item1List.add(item1);

        Map<String, List<ContentVersion>> item2 = new Map<String, List<ContentVersion>>();
        List<ContentVersion> item22 = new List<ContentVersion>();
        item22.add(qrcv);
        item2.put('1',item22);

        
        Account acc2 = new Account();
        acc2.Name = 'acc2';
        Insert acc2;
        List<Account> acc2List = new List<Account>();
        acc2List.add(acc2);

        UploadFilesController.saveFiles2(JSON.serialize(item1List), JSON.serialize(new Map<String, Object>{
            '1' => new List<object> {
                new Map<String, Object> {
                    'ContentVersionId' => '123',
                    'name' => '234.jpg',
                    'ContentDocumentId' => qrcv.ContentDocumentId
                },
				new Map<String, Object> {
                    'packageId' => '123',
                    'name' => '345.jpg'
                }              
            }
        }),acc2List,testAccount.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetFilesAndDeleteFiles2(){
        Account testAccount = new Account();
        testAccount.Name = '测试UploadFilesController用';
        Insert testAccount;
        
        Account testAccount2 = new Account();
        testAccount2.Name = '测试UploadFilesController用2';
        Insert testAccount2;

        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf('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');
        cv.Title = '新建文本文档.txt';
        cv.PathOnClient = '新建文本文档.txt';
        insert cv;

        ContentVersion qrcv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =:cv.id];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = qrcv.ContentDocumentId;
        cdl.LinkedEntityId = testAccount.Id;
        cdl.ShareType = 'V';

        insert cdl;
        
        ContentDocumentLink cdl2 = new ContentDocumentLink();
        cdl2.ContentDocumentId = qrcv.ContentDocumentId;
        cdl2.LinkedEntityId = testAccount2.Id;
        cdl2.ShareType = 'V';

        insert cdl2;
        
        Test.startTest();
        UploadFilesController.getFileOne(testAccount.Id, null);
        // String[] strs = [cdl.Id];
        // List<String> ids = new List<String>();
        // ids.add(cdl.Id);
        // ConResponse resp = UploadFilesController.deleteFiles(ids,String.valueof(testAccount2.Id));
        Test.stopTest();
    }

    // @isTest
    // static void testGetFilesAndDeleteFiles66(){
    //     Account testAccount = new Account();
    //     testAccount.Name = '测试UploadFilesController用';
    //     Insert testAccount;
        
    //     Account testAccount2 = new Account();
    //     testAccount2.Name = '测试UploadFilesController用2';
    //     Insert testAccount2;

    //     ContentVersion cv = new ContentVersion();
    //     cv.VersionData = Blob.valueOf('iVBORw0KGgoAAAANSUhEUgAAAKYAAABGCAIAAADJrniiAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAEnQAABJ0Ad5mH3gAAAjESURBVHhe7ZwhmNQ8EIZPIpEnkUjkypVI5EkkEolDIk8ikUjkSeRJJPIkEom8/306X4fZpM1m2/TY/dtX3NOkadrmm5lM0oWrx41JXPWoXI0uO/3CVmyST0S6bZKvB+m2Sb4epNsm+XqQbpvk60G6bZKvB+m2Sb4enj17Zsr9+PFDVXXYVaDyk7NJPpGbmxtT7s2bN6qqw64ClZ+cTfKJ4NyS7kRH1zWb5JfC3d3dixcvJFrPfr//9euXWhxD12ySXwrX19dS7BCmdoT/8uWL2o2jCzbJLwXJtTAEks+fP+uWrdkkPwLz9Pv37/Ng/gR8/PhRD9GUTfJhfv/+zYj/E6Uj7969q88SKlmv5My7pih/4xxsbv38+XMb9GkwtX/48OHPnz/qNKAW43M5V71+/VqNuq4+ffqkcy1YqeTMlBrRDoZ1zK3J13C179+/24Wq7QSjvQojvHz58v7+3i50dK6YvqE6y3216x5PJ1qwUsnzxDt368T7DZ3rJloddZLoqDORV69eqdBBzIjBWbUVGfu3b9+854bz+kolt3EcJHHrhKiuQRCOcRiQB1uJNsRVHpxVVbdIw1zU+uqqVXjfJP/LoFsnRA0AsQnCeYRAdTw7NwV6UKFO8jivtwrva5ScadsGMXJUbCPGc9ObeGBFLCZqbLuwnN3tdqrqgryO6iQHbqELqi8psy7JLUcbzMbVokjUGxCDSmYBK1qKvt/vreifW6KnRuxsDbpgk/xU7u7uxpZeOKgajZPoDQQGorfP7pacx88tFskB1WMGbvyrbfm1SB61GQPhx7Y5b29v1ShAh+7TZOlq+vj49u1bqwRXHfKcbmztnqALNsnLTN4+y5O4GnNhQaXWWSSPqtOVansG1+4JarpJPkiTjVIEVncdHpOTBbcTXdwoqK6qQ8oLMDU6W8n9izJ/CwtcZ/J3Cy6JuxyF1MxxbVTu1P358yc1iOQBmce2ZsDrWCV4cp4QXdwZU13lLhWIT2sZ/iBqcbaS5+JdX1/f3NwwTdrgOtRMUDrBZsRk+Aw6txDte22mTYyuZfdCNgKvteQVqLHjBGuck6iOSfEAKnRX8SS+hCv8zsIagMrzaC85g6gHLJJvebbClXZ0oh+yuDgu+Bb4u2BYpocVwRM3sMaDJKo7Hm9ihg88fG6FOne2kjv1EZv3Pxr/c/CYZHJFmERsQ6d7x6KZyv3quTIDiA1iJ91NRkH1fIUWn9NX9k5iiKo9f8kd4jkxnNeOw7QQMVFydO5Qs4YM3jTBfxFr4PqYgs5l5muGaMSPfqqax1NIDphtXK3ap4vER1thAjRJ3RclX57FIM9xkpBaMjGfxSUnYifjHg28PvgvDc/gwZaBVm0XgRn6OP3PgXePpn8SMSrMYVnJk4kTkoA2SGUCOA2cxvIjfzDiTUyVo97Ig+SDC78JIQo3tXcf67NAXDfOZEHJcQ6fwMofoQvkOdpJcG20OZ7H1Y2OSxuzg6g3qiS3jrl3stw6FR4j9jZGjD2tqHrch4cHbozJ10dgWkZDZoDUV1PU++GgF6xELTpwuJhIo3rUO8GGPm7F0IOOGmVVjjpt3a3zt9/l8h3yFN2jNbpBNjrImUwoRrL4AexjsKXjAQDiaoqiji5O8oVkTiCwE0jjlNkE9Z6NDpnw4FZPXPw4hdRst9v5jiHmEo2DGh1dnOQ18KpMPBj70W8+caAHMxSLkGo9G3V6ODo8Z8Fx1eiQwYmASs80OUjaUKmji5Z8vh7qqN9dGlyDoYc1no967EcHj4y/OuJGsWhYy0hhCveJIG9DpY4uTvKGbhfHRVU9SUqVz6nTUHfd7W5vb6Nzk0BgAXinyj3JrRMtCWZfv371TylYDClbEtINrtXRxUnusWsmcV9wbJ/I12yt7Mx6g2QTO/7aRFU9cTrP9bar0FhVh8SYEdtYb01ovr2a06xfn8V94HLiME0O7+e/k3oUHh7rR93ka3LcuRpzm/k0k9weFMphI1nnnAQWQ2Zw6r7VmYOr2Hd0XtDXDjFzbE57yVUeR+2qJf8fuHUNmLK7+EI7V8a5S87LV7r12Eyh093tcB0VeganoeQ7Cm0eHh74q3IPNbrgRAhXJJtkFWOvxlk1XYBzl3xwR8Vh0Os/TNFbkq/t93u7S4SMPSrBLe7v7wcnFCrnh1/kjz+wcYhqTPZq1JRzl1xND8EOyMnxPGsTPbJATIZbkX/zPpWYskE8Bt/rbcj5Ss5Q+qLOGVzd4WpHfZ0o6qOZDGs9dncVMjiL8dVvKic5CnZM58m7jM1Wc2gmuY/jUcO0ZqDyIbwzbz64AzpnKR8jAU9YYyUOYsQvv6od2VFmHI4Kb2Inl8eUjcerH89TaSa5j2nZMKOXqKqHQE24HstoQO0m4TkBxqSqQ+I0Xx5lNer+UVme000jzwQrx3MCzSSPhsnwqbZn8H/I07kuY8rHjt5wxCabXFHOwfVPbJCPfsLYa9LzYHAqMDhPGYynGs2z9ZyW3cXgeRTeliFjis1zcmo45bGxYEk1JFmbagOJ3oy1TowQXxOLVG1PpfAFsR01PWfJGayZgY7L8Xh11xOHeILq0aSSX5AhWJzRa/QG2viyKu7YN8duASo3onF3DEd9WuSgSlx0JSSWdGo640HCd60Ht/Mq9TbidDMt9tSgGzSXvOETM2SktUjC4OYzd4TQh39wa8JgHhtzoupIeNIeRc10c5LeRrTshVRX780lh5pBN2iJSLwhgiWiujMNwlmGFWuov1cCksRbHPX1mp15osu0391CtEJYQnV1vYTkNRTWTmO4zDP3pxy6UtezqcmejpKojvXU78OU4dmisaq2Eeq0Fbvdjjcn8LaSOSHx9UqaCDxIojrPxjwyU3gChrrraP7hXP1WcuocvAT1vr6c0hFUZ0x0yw6EPzrvjJHrTf8614jGQWO1TNiHKUPwaC62sUneklbCL6c3bJI3Bqkm7ExElgjmkU3y1bFJvjo2yVfHJvnq2CRfHZvkq2OTfGU8Pv4H1WlDg98DOL8AAAAASUVORK5CYII=');
    //     cv.Title = '新建文本文档.txt';
    //     cv.PathOnClient = '新建文本文档.txt';
    //     insert cv;

    //     ContentVersion qrcv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =:cv.id];

    //     ContentDocumentLink cdl = new ContentDocumentLink();
    //     cdl.ContentDocumentId = qrcv.ContentDocumentId;
    //     cdl.LinkedEntityId = testAccount.Id;
    //     cdl.ShareType = 'V';

    //     insert cdl;
        
    //     ContentDocumentLink cdl2 = new ContentDocumentLink();
    //     cdl2.ContentDocumentId = qrcv.ContentDocumentId;
    //     cdl2.LinkedEntityId = testAccount2.Id;
    //     cdl2.ShareType = 'V';

    //     insert cdl2;
        
    //     Test.startTest();
    //     UploadFilesController.getFiles(testAccount.Id, null);
    //     Blob bb = Blob.valueOf('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');

    //     UploadFilesController.uploadFile(testAccount.Id, bb, '新建文本文档.txt', null);
    //     Test.stopTest();
    // }
    
    @isTest
    static void testPackage() {
        FileItem__c item = new FileItem__c(
        	packageId__c = '123',
            ItemId__c = '123',
            FileName__c = '123.jpg'
        );
        insert item;
        UploadFilesController.getPackages(new String[] {'123'});
    }

    @isTest
    static void testPackage2() {
        FileItem__c item = new FileItem__c(
        	packageId__c = '123',
            ItemId__c = '123',
            FileName__c = '123.jpg'
        );
        insert item;
        UploadFilesController.deleteCaches(new String[] {'123'});
    }

    @isTest
    static void testPackage3() {
        UploadFilesController.batchDeleteFiles('123');
    }
}