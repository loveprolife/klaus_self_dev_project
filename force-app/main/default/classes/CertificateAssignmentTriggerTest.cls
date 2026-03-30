@isTest
private class CertificateAssignmentTriggerTest {
    static testMethod void testMethod1() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-1, 
        	EndDate__c = Date.today()+10,
        	Name = '展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        Expo_Certificate_Assignment__c ass = new Expo_Certificate_Assignment__c(
            Exhibition_Management__c = e1.Id,
            Approver__c = 'wang@hisense.com',
            Region__c = '总部-HQ',
            Certificate_Quantity__c = 10,
            Expend_Quantity__c = 0,
            Validity__c = 20,
            Validity_Date__c = 0
        );
        INSERT ass;

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
            Approval_Status__c = '未审批',
            Certificate_Type__c = '筹展证|Day Voucher for booth construction ;临时证|Day Voucher',
            Approver__c = 'wang@hisense.com',
            Company__c = '总部-HQ',
            Validity_Date__c='03-01',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

		ass.Is_Arranged__c = TRUE;
        UPDATE ass;
    }
}