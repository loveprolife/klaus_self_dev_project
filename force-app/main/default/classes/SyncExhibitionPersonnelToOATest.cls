@isTest
private class SyncExhibitionPersonnelToOATest {
    static testMethod void testMethod1() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-90, 
        	EndDate__c = Date.today()+10,
        	Name = '展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true,
        	OutLineCN__c = 'Test_OutLineCN__c'
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
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
			Department_Name__c = '国际营销解决方案部',
			Company_Abbr__c = '海信集团\\海信信息科技公司\\国际营销解决方案部\\系统开发室',
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
        	OA_Internal_Name__c = 'test_OA_Internal_Name__c',
        	OA_Position__c = 'test_OA_Position__c',
        	OA_Department_Name__c = 'test_OA_Department_Name__c',
        	OA_Department_Code__c = 'test_OA_Department_Code__c',
        	OA_Purpose_Exhibition__c = 'test_OA_Purpose_Exhibition__c',
        	OA_Interactive__c = 'test_OA_Interactive__c',
        	OA_Email__c = 'test_OA_Email__c',
        	OA_Phone__c = 'test_OA_Phone__c',
        	OAXH__c = 'test_OAXH__c',
			OA_Opinion__c = 'test_OA_Opinion__c'
        	);
        INSERT m1;

        Test.startTest();
        String json = '{"fdCode":"1", "fdMessage":"SUCCESS","fdId":"toireote","fdNo":"403967098435-3"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        SyncExhibitionPersonnelToOA.postCustomerInfomationToOA(e1.Id, 'test', 'test','test', new List<Object>{e2.Id});
        SyncExhibitionPersonnelToOA.postCustomerInfomationToOA(e2.Id, 'test', 'test', '',new List<Object>{e2.Id});
        SyncExhibitionPersonnelToOA.postCustomerInfomationToOA(e1.Id, 'test', 'test', NULL,new List<Object>{'test'});
        Test.stopTest();

    }
    static testMethod void testMethod2() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-90, 
        	EndDate__c = Date.today()+10,
        	Name = '展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true,
        	OutLineCN__c = 'Test-OutLineCN__c'
        	);
        INSERT e1;

		Expo_Date_Controller__c d = new Expo_Date_Controller__c(
        	Name = 'Exhibition Date',
            Exhibition_Management__c = e1.Id,
        	SignUp_End_Date__c = Date.today()
        );
		INSERT d;

        ExpoInfo__c e11 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-90, 
        	EndDate__c = Date.today()+10,
        	Name = '展会信息1',
        	TitleEN__c = 'Exhibition Informatino1',
        	DisplayInThePortal__c = true,
        	OutLineCN__c = 'Test-OutLineCN__c'
        	);
        INSERT e11;

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Approval_Status__c = '部门审批通过',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        INSERT e3; 

        Mapping_Configuration__c m1 = new Mapping_Configuration__c(Map_Name__c = 'OAExecutiveApproval',
        	OA_Exhibition_Nmae__c = 'test_OA_Exhibition_Nmae__c',
        	OA_Description__c = 'Test_OA_Description__c',
        	Approval_Node1__c = 'test_Approval_Node1__c',
        	Approval_Node2__c = 'test_Approval_Node2__c',
        	OA_Internal_Name__c = 'test_OA_Internal_Name__c',
        	OA_Position__c = 'test_OA_Position__c',
        	OA_Department_Name__c = 'test_OA_Department_Name__c',
        	OA_Department_Code__c = 'test_OA_Department_Code__c',
        	OA_Purpose_Exhibition__c = 'test_OA_Purpose_Exhibition__c',
        	OA_Interactive__c = 'test_OA_Interactive__c',
        	OA_Email__c = 'test_OA_Email__c',
        	OA_Phone__c = 'test_OA_Phone__c',
        	OAXH__c = 'test_OAXH__c',
			OA_Opinion__c = 'test_OA_Opinion__c'
        	);
        INSERT m1;

        Test.startTest();
        String json = '{"fdCode":"1", "fdMessage":"SUCCESS","fdId":"toireote","fdNo":"403967098435-3"}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        SyncExhibitionPersonnelToOA.postCustomerInfomationToOAExecutive(e1.Id, 'test', 'test');
        SyncExhibitionPersonnelToOA.postCustomerInfomationToOAExecutive(e2.Id, 'test', 'test');
        SyncExhibitionPersonnelToOA.postCustomerInfomationToOAExecutive(e11.Id, 'test', 'test');
        Test.stopTest();

    }
}