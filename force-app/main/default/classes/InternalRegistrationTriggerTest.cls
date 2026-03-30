@isTest
private class InternalRegistrationTriggerTest {
    static testMethod void testMethodbeforeInsert() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+5, 
        	StartDate__c = Date.today()-10, 
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
            Certificate_Type__c = '筹展证|Day Voucher for booth construction ;临时证|Day Voucher',
            Approver__c = 'wang@hisense.com',
            Company__c = '总部-HQ',
            Validity_Date__c='03-01',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
            try {
                INSERT e2;
            }
            catch (Exception e) {
                
            }

        // Internal_Registration__c e4 = new Internal_Registration__c(
        // Exhibition_Id__c = e1.Id,
        // Email__c = 'etpeng@deloitte1.com.cn',
        // Position__c = '经理',
        // Phone__c = '18712345678',
        // Name_CN__c = '张三',
        // Certificate_Type__c = 'Day Voucher for booth construction |筹展证;',
        // Approver__c = 'wang@hisense.com',
        // //Purpose_Of_Exhibition__c = '参展目的',
        // Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
		// );
        // INSERT e4;

        Expo_Date_Controller__c d = new Expo_Date_Controller__c(
        	Name = 'Exhibition Date',
            Exhibition_Management__c = e1.Id,
        	SignUp_End_Date__c = Date.today()
        );

        INSERT d;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        Internal_Registration__c = e2.Id,
		PresenceDate__c = '03-23;03-24',
        Roommate__c = 'shiyong');

        INSERT e3;
        
        Expo_Certificate_Assignment__c ass = new Expo_Certificate_Assignment__c(
            Approver__c = 'wang@hisense.com',
            Region__c = '总部-HQ',
            Certificate_Quantity__c = 10,
            Expend_Quantity__c = 0,
            Validity__c = 20,
            Validity_Date__c = 0
        );
        INSERT ass;
    }

    static testMethod void testMethodUpdate() {

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

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        Internal_Registration__c = e2.Id,
		PresenceDate__c = '03-23;03-24',
        Roommate__c = 'shiyong');
        INSERT e3;
        
        e2.If_Cancel__c= true;
        UPDATE e2;

        e2.If_Cancel__c= false;
        UPDATE e2;

        e2.Certificate_Type__c = '筹展证Day Voucher for booth construction;临时证|Day Voucher';
        e2.Validity_Date__c='03-01';


        List<Internal_Registration__c> intList = new List<Internal_Registration__c>();

        intList.add(e2);
        

        

        Internal_Registration__c e4 = new Internal_Registration__c(
        	id = e2.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
            Approval_Status__c = '审批通过',
            Certificate_Type__c = '筹展证|Day Voucher for booth construction;临时证|Day Voucher',
            Approver__c = 'wang@hisense.com',
            Company__c = '总部-HQ',
            Validity_Date__c='03-01',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        // e2.Approval_Status__c = '审批通过';
        UPDATE e4;

        Internal_Registration__c e5 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'peng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
            Approval_Status__c = '审批通过',
            Certificate_Type__c = '筹展证|Day Voucher for booth construction;参展商证|Exhibition Badge',
            Approver__c = 'wang@hisense.com',
            
            // Validity_Date__c='03-01',
            If_Cancel__c = false,
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        // e2.Approval_Status__c = '审批通过';
        INSERT e5;

        e5.If_Cancel__c= true;
        UPDATE e5;

        e5.If_Cancel__c= false;
        UPDATE e5;

        e5.Certificate_Type__c = '参展商证|Day Voucher';
        // intList.add(e5);
        // UPDATE intList;
        List<Internal_Registration__c> intList10 = new List<Internal_Registration__c>();
        e2.Certificate_Type__c = '参展商证|Day Voucher';
        e2.Validity_Date__c='None';
        e5.Certificate_Type__c = '参展商证|Day Voucher';
        e5.Validity_Date__c='None';

        // List<Internal_Registration__c> intList10 = new List<Internal_Registration__c>();
        intList10.add(e2);
        intList10.add(e5);
        UPDATE intList10;

        List<Internal_Registration__c> intList11 = new List<Internal_Registration__c>();
        e2.Certificate_Type__c = '临时证|Day Voucher';
        e2.Validity_Date__c='03-01;02-28';
        e5.Certificate_Type__c = '临时证|Day Voucher';
        e5.Validity_Date__c='03-01;02-28';

        intList11.add(e2);
        intList11.add(e5);
        UPDATE intList11;

        List<Internal_Registration__c> intList12 = new List<Internal_Registration__c>();
        e2.Certificate_Type__c = '临时证|Day Voucher';
        e2.Validity_Date__c='03-01';
        e5.Certificate_Type__c = '临时证|Day Voucher';
        e5.Validity_Date__c='03-01';

        intList12.add(e2);
        intList12.add(e5);
        UPDATE intList12;



        Internal_Registration__c e6 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'peng@deloitte1.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
            Approval_Status__c = '审批通过',
            
            Company__c = 'VIDAA',

            If_Cancel__c = false,
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        // e2.Approval_Status__c = '审批通过';
        INSERT e6;

        Internal_Registration__c e7 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'peng@deloitte2.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
            Approval_Status__c = '审批通过',
            Certificate_Type__c = 'Day Voucher for booth construction |筹展证;临时证|Day Voucher',
            Company__c = 'VIDAA',
            Validity_Date__c='03-01',
            If_Cancel__c = false,
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        // e2.Approval_Status__c = '审批通过';
        INSERT e7;

        e6.Certificate_Type__c = 'Day Voucher for booth construction |筹展证;Exhibition Badge|参展商证';
        e6.Validity_Date__c='None';
        e7.Certificate_Type__c = 'Day Voucher for booth construction |筹展证;Exhibition Badge|参展商证';
        e7.Validity_Date__c='None';
        List<Internal_Registration__c> intList2 = new List<Internal_Registration__c>();
        intList2.add(e6);
        intList2.add(e7);
        UPDATE intList2;

        List<Internal_Registration__c> intList3 = new List<Internal_Registration__c>();
        e6.Certificate_Type__c = 'Day Voucher for booth construction |筹展证;临时证|Day Voucher';
        e6.Validity_Date__c='03-01;02-28';
        e7.Certificate_Type__c = 'Day Voucher for booth construction |筹展证;临时证|Day Voucher';
        e7.Validity_Date__c='03-01;02-28';

        intList3.add(e6);
        intList3.add(e7);
        UPDATE intList3;

        List<Internal_Registration__c> intList4 = new List<Internal_Registration__c>();
        e6.Certificate_Type__c = 'Day Voucher for booth construction |筹展证;临时证|Day Voucher';
        e6.Validity_Date__c='03-01';
        e7.Certificate_Type__c = 'Day Voucher for booth construction |筹展证;临时证|Day Voucher';
        e7.Validity_Date__c='03-01';

        intList4.add(e6);
        intList4.add(e7);
        UPDATE intList4;
        
        // Get the base URL.
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('Base URL: ' + sfdcBaseURL );       

        // Get the URL for the current request.
        String currentRequestURL = URL.getCurrentRequestUrl().toExternalForm();
        System.debug('Current request URL: ' + currentRequestURL);        

        // Create the account URL from the base URL.
        String accountURL = URL.getSalesforceBaseUrl().toExternalForm() + 
                               '/' + e2.Id;
        System.debug('URL of a particular account: ' + accountURL); 

        // Get some parts of the base URL.
        System.debug('Host: ' + URL.getSalesforceBaseUrl().getHost());   
        System.debug('Protocol: ' + URL.getSalesforceBaseUrl().getProtocol());

        // Get the query string of the current request.
        System.debug('Query: ' + URL.getCurrentRequestUrl().getQuery());
    }
}