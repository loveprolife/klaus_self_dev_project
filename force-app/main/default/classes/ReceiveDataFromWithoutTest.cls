@isTest
private class ReceiveDataFromWithoutTest {
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

		Expo_Certificate_Assignment__c ass = new Expo_Certificate_Assignment__c(
            Approver__c = 'wang@hisense.com',
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

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Approval_FDID__c = '4096574t3574934643reyw',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

        // Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        // 	Internal_Registration__c = e2.Id,
        // 	Roommate__c = 'shiyong');

        // INSERT e3;

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
        	OAXH__c = 'test_OAXH__c'
        	);
        INSERT m1;


        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Map<String, String> jsonMap = new Map<String, String>{'fdId'=>e2.Approval_FDID__c, 'docStatus' =>'30','opinion'=>'({auditNote=同意, auditTime=2025-03-05 16:18:03, fdActionKey=handler_pass, fdFactNodeId=N4, fdFactNodeName=部门负责人|海外分公司总经理, fdLoginName=wangfang19, fdName=王芳})'};
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(JSON.serialize(jsonMap));

        ReceiveDataFromWithout.doPost() ; 
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
        	OutLineCN__c = 'Test_OutLineCN__c'
        	);
        INSERT e1;

		Expo_Certificate_Assignment__c ass = new Expo_Certificate_Assignment__c(
            Approver__c = 'wang@hisense.com',
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

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Approval_FDID__c = '4096574t3574934643reyw',
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
        	OAXH__c = 'test_OAXH__c'
        	);
        INSERT m1;


        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Map<String, String> jsonMap = new Map<String, String>{'fdId'=>e2.Approval_FDID__c, 'docStatus' =>'11','opinion'=>'({auditNote=同意, auditTime=2025-03-05 16:18:03, fdActionKey=handler_pass, fdFactNodeId=N4, fdFactNodeName=部门负责人|海外分公司总经理, fdLoginName=wangfang19, fdName=王芳}, {auditNote=同意, auditTime=2025-03-05 16:26:28, fdActionKey=handler_pass, fdFactNodeId=N6, fdFactNodeName=大区经理或其他领导, fdLoginName=cuijie3, fdName=崔杰})'};
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(JSON.serialize(jsonMap));

        ReceiveDataFromWithout.doPost() ; 
        Test.stopTest();
    }

}