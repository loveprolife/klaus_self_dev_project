@isTest
private class ReceiveDataFromWithoutExecutiveTest {
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
        Map<String, String> jsonMap = new Map<String, String>{'fdId'=>e2.Approval_FDID__c, 'docStatus' =>'30','opinion'=>'e07609832048604'};
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(JSON.serialize(jsonMap));

        ReceiveDataFromWithoutExecutive.doPost() ; 
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
        Map<String, String> jsonMap = new Map<String, String>{'fdId'=>e2.Approval_FDID__c, 'docStatus' =>'11','opinion'=>'e07609832048604'};
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf(JSON.serialize(jsonMap));

        ReceiveDataFromWithoutExecutive.doPost() ; 
        Test.stopTest();
    }
}