@isTest
private class ExhibitionSSOVerifyControllerTest {
    static testMethod void testMethod1() {
        Exhibition_OA_Second_Approver__c eosa = new Exhibition_OA_Second_Approver__c(Name = '二级审批人',XHNumber__c = 'test3',Type__c='部门');
        INSERT eosa;
        ExhibitionSSOVerifyController.getSecondApprover('部门');
        ExhibitionSSOVerifyController.getOAapprover('部门');
        ExhibitionSSOVerifyController.getExhibition();

    }

    static testMethod void testMethod2() {

        Expo_Certificate_Assignment__c ass = new Expo_Certificate_Assignment__c(
            Approver__c = 'wang@hisense.com',
            Region__c = '总部-HQ',
            Certificate_Quantity__c = 10,
            Expend_Quantity__c = 0,
            Validity__c = 20,
            Validity_Date__c = 0
        );
        INSERT ass;

        Expo_Certificate_Assignment__c ass1 = new Expo_Certificate_Assignment__c(
            Region__c = 'VIDAA',
            Certificate_Quantity__c = 10,
            Expend_Quantity__c = 0,
            Validity__c = 20,
            Validity_Date__c = 0
        );
        INSERT ass1;

        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+5, 
        	StartDate__c = Date.today()-10, 
        	EndDate__c = Date.today()+10,
        	Name = '展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        Expo_Date_Controller__c d = new Expo_Date_Controller__c(
        	Name = 'Exhibition Date',
            Exhibition_Management__c = e1.Id,
        	SignUp_End_Date__c = Date.today()
        );

        INSERT d;

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
            Approval_Status__c = '未审批',
            Certificate_Type__c = '筹展证|Day Voucher for booth construction ;临时证|Day Voucher',
            Approver__c = 'wang@hisense.com',
            Company__c = '总部-HQ',
            Validity_Date__c='03-01',
            XHNumber__c = 'taojingpeng.ex',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

        Internal_Registration__c e5 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
            Approval_Status__c = '未审批',
            Certificate_Type__c = '筹展证|Day Voucher for booth construction ;临时证|Day Voucher',
            Approver__c = 'wang@hisense.com',
            Company__c = '总部-HQ',
            Validity_Date__c='03-01',
            XHNumber__c = 'test',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e5;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        Internal_Registration__c = e2.Id,
		PresenceDate__c =  Datetime.now().addDays(-4).format('MM-dd') +';' + Datetime.now().addDays(-4).format('MM-dd'),
        Roommate__c = 'shiyong');
        INSERT e3;

        Test.startTest();
    	String json1 = '{"resCode": "SUCCESS","resMess": "SUCCESS","tokenId": "8e37cf631b434911be580ade72ed89b9", "effecTime": "2023-08-30 17:50:53"}';
    	Test.setMock(HttpCalloutMock.class, new CalloutMock(json1));
        String json = '{"code": "0","timestamp": "1761794259467","data": {    "telephoneNumber": "",    "mail": "taojingpeng.ex@hx-partners.com",    "ou": "%E5%9B%BD%E9%99%85%E8%90%A5%E9%94%80%E8%A7%A3%E5%86%B3%E6%96%B9%E6%A1%88%E9%83%A8",    "otherDepartments": [        "1"    ],    "mobile": "18037506005",    "usertype": "external",    "cn": "%E9%99%B6%E9%9D%96%E6%9C%8B.ex",    "title": "",    "idNumber": "411328199711260679",    "employeeNumber": "",    "o": "%E5%A4%96%E9%83%A8%E4%BA%BA%E5%91%98%5C%E5%A4%96%E5%8D%8F%5C%E9%9B%86%E5%9B%A2%E5%85%AC%E5%8F%B8%5C%E6%95%B0%E8%B4%A8%E4%B8%AD%E5%BF%83%5C%E6%95%B0%E7%A7%91%E5%85%AC%E5%8F%B8%5C%E5%9B%BD%E9%99%85%E8%90%A5%E9%94%80%E8%A7%A3%E5%86%B3%E6%96%B9%E6%A1%88%E9%83%A8",    "uid": "taojingpeng.ex",    "cnen": "taojingpeng.ex",    "sn": "%E9%99%B6"},"msg": "操作成功"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));


        ExhibitionSSOVerifyController.getDepartment(e1.Id);
        ExhibitionSSOVerifyController.verifyInternalRegistration(e2.Id);
        ExhibitionSSOVerifyController.verifyInternalRegistration(e5.Id);
        ExhibitionSSOVerifyController.getCompany(e1.Id);
        ExhibitionSSOVerifyController.getCompanyAbbr(e1.Id,'总部-HQ');
        ExhibitionSSOVerifyController.IsExistVerify(e1.Id);
        ExhibitionSSOVerifyController.verifyInternalRegistrations(e1.Id);
        Test.stopTest();
    }

}