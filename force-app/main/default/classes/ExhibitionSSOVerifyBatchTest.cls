@isTest
private class ExhibitionSSOVerifyBatchTest {
    static testMethod void testMethod3() {
    	ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-90, 
        	EndDate__c = Date.today()+10,
        	Name = '展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore',
        	Is_Present__c = FALSE
			);
        INSERT e2;

        Internal_Registration__c e21 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore',
        	Is_Present__c = TRUE
			);
        INSERT e21;
        Internal_Registration__c e22 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore',
        	Is_Present__c = TRUE,
        	XHNumber__c = 'LiMin24'
			);
        INSERT e22;


        ExpoInfo__c e10 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-90, 
        	EndDate__c = Date.today()+10,
        	Name = '展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e10;

         Internal_Registration__c e20 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore',
        	Is_Present__c = FALSE
			);
        INSERT e20;


		Test.startTest();
    	String json1 = '{"resCode": "SUCCESS","resMess": "SUCCESS","tokenId": "8e37cf631b434911be580ade72ed89b9", "effecTime": "2023-08-30 17:50:53"}';
    	Test.setMock(HttpCalloutMock.class, new CalloutMock(json1));
        String json = '{"data": [{ "uid": "LiMin24","mail": "limin24@hisense.com", "title": "业务需求分析师", "ou": "数据流程IT与数据管理部", "cn": "李敏","departmentNumber": "jt_xx","displayid": "0","telephoneNumber": "中国(+86)-809398288-99298882","postalAddress": "中国北京北京市东城区山东省青岛市市南区东海西路257号","o": "海信集团集团公司数据流程IT与数据管理部","mobile": "17660901558"}],"code": 0,"message": "成功获取Ldap账号信息","total": null}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
		RestRequest req = new RestRequest();
		req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody = Blob.valueOf('{"uid":"cuijie3"}');
		GetLDAPInfo.doPost();
        req.requestBody = Blob.valueOf('{"ui');
		GetLDAPInfo.doPost();
        
        ExhibitionSSOVerifyController.verifyInternalRegistration(e2.Id);
        ExhibitionSSOVerifyController.verifyInternalRegistration(e21.Id);
        ExhibitionSSOVerifyController.verifyInternalRegistration(e22.Id);

		ExhibitionSSOVerifyController.IsExistVerify(e1.Id);
        ExhibitionSSOVerifyController.IsExistVerify(e10.Id);


        ExhibitionSSOVerifyController.verifyInternalRegistrations(e1.Id);
        ExhibitionSSOVerifyController.verifyInternalRegistrations(e1.Id);
        ExhibitionSSOVerifyController.verifyInternalRegistrations(e10.Id);

        Test.stopTest();

    }

    static testMethod void testMethod4() {
    	ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-90, 
        	EndDate__c = Date.today()+10,
        	Name = '展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore',
        	Is_Present__c = FALSE
			);
        INSERT e2;

        Internal_Registration__c e21 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore',
        	Is_Present__c = TRUE
			);
        INSERT e21;
        Internal_Registration__c e22 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore',
        	Is_Present__c = TRUE,
        	XHNumber__c = 'LiMin24'
			);
        INSERT e22;


        ExpoInfo__c e10 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-90, 
        	EndDate__c = Date.today()+10,
        	Name = '展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e10;

         Internal_Registration__c e20 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore',
        	Is_Present__c = FALSE
			);
        INSERT e20;


		Test.startTest();
    	String json1 = '{"resCode": "SUCCESS","resMess": "SUCCESS","tokenId": "8e37cf631b434911be580ade72ed89b9", "effecTime": "2023-08-30 17:50:53"}';
    	Test.setMock(HttpCalloutMock.class, new CalloutMock(json1));
        String json = '{"data": [],"code": 0,"message": "成功获取Ldap账号信息","total": null}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));



        ExhibitionSSOVerifyController.verifyInternalRegistration(e2.Id);
        ExhibitionSSOVerifyController.verifyInternalRegistration(e21.Id);
        ExhibitionSSOVerifyController.verifyInternalRegistration(e22.Id);

		ExhibitionSSOVerifyController.IsExistVerify(e1.Id);
        ExhibitionSSOVerifyController.IsExistVerify(e10.Id);


        ExhibitionSSOVerifyController.verifyInternalRegistrations(e1.Id);
        ExhibitionSSOVerifyController.verifyInternalRegistrations(e1.Id);
        ExhibitionSSOVerifyController.verifyInternalRegistrations(e10.Id);

        Test.stopTest();

    }
}