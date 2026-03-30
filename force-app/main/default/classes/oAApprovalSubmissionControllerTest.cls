@isTest
private class oAApprovalSubmissionControllerTest {
    static testMethod void testMethod1() {
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
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        INSERT e3;

        Mapping_Configuration__c m1 = new Mapping_Configuration__c(Map_Name__c = 'OADepartmentApproval',
        	OA_Exhibition_Nmae__c = 'test_OA_Exhibition_Nmae__c',
        	OA_Description__c = 'Test_OA_Description__c',
        	Approval_Node1__c = 'test_Approval_Node1__c',
        	Approval_Node2__c = 'test_Approval_Node2__c',
			OA_Opinion__c = 'test_OA_Opinion__c'
			);
        INSERT m1;

        oAApprovalSubmissionController.saveOAApp(NULL, NULL, NULL,NULL,NULL);
        oAApprovalSubmissionController.saveOAApp('toerutreotw454', NULL,NULL,NULL,NULL);
        oAApprovalSubmissionController.saveOAApp(e1.Id, 'test','test','意见',new List<Object>{'test'});
    }
    static testMethod void testMethod2() {
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
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        INSERT e3;

        oAApprovalSubmissionController.saveOAAppExecutive(NULL, NULL, NULL);
        oAApprovalSubmissionController.saveOAAppExecutive('750946043rewy', NULL,NULL);
        oAApprovalSubmissionController.saveOAAppExecutive(e1.Id, 'test','test');
    }
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
			Certificate_Type__c = '撤展证|Day Voucher for booth dismantle',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Department_Name__c = 'Dept',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

		Internal_Registration__c e6 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
			Certificate_Type__c = '筹展证|Day Voucher for booth construction',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Department_Name__c = 'Dept',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e6;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        INSERT e3;

        String overLimitBicStr = 'e6r7w89e0-ytrewqiurhtirfofuhoidsfhdheiwehriuewhthrfdjiregwdkjgriufedkteiukjfdbvuiolfdkjdtiurfdkjirehfdkjugiwhewoihdsiugvcxkjrfelhdgiuelauhfuiewagfueweiuagiueahfoidshgiurehtgkdhfguiehg';
        String overLimitStr = overLimitBicStr+overLimitBicStr+overLimitBicStr;
        oAApprovalSubmissionController.selIntList('Dept', e1.Id);
        oAApprovalSubmissionController.selIntList(NULL, NULL);
        oAApprovalSubmissionController.selIntList(overLimitStr,overLimitStr);
		oAApprovalSubmissionController.selIntList(NULL,e1.Id,NULL,NULL,NULL,NULL);
        oAApprovalSubmissionController.getInternalRegistList(e1.Id);
    }

    static testMethod void testMethofreyred2() {
            ConResponse resp = new ConResponse();
            resp.code = -1;
            Boolean res = resp.isSuccess;

            Response resp1 = new Response();
            resp1.data = 'test';
            resp1.message = 'test';


        }
}