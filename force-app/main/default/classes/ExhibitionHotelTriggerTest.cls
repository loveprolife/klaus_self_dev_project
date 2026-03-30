@isTest
private class ExhibitionHotelTriggerTest {
	static testMethod void testMethodbeforeInsert() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+5, 
        	StartDate__c = Date.today()-10, 
        	EndDate__c = Date.today()+10,
        	Name = '展会信息 2026',
        	TitleEN__c = 'Exhibition Informatino 2026',
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

        Expo_Date_Controller__c d = new Expo_Date_Controller__c(
        	Name = 'Exhibition Date',
            Exhibition_Management__c = e1.Id,
        	SignUp_End_Date__c = Date.today()
        );

        INSERT d;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        Internal_Registration__c = e2.Id,
		PresenceDate__c = '01-08;01-09',
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
    static testMethod void testMethod1() {
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
        	Name = '展会信息 2026',
        	TitleEN__c = 'Exhibition Informatino 2026',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        Expo_Date_Controller__c d = new Expo_Date_Controller__c(
        	Name = 'Exhibition Date',
            Exhibition_Management__c = e1.Id,
        	SignUp_End_Date__c = Date.today()
        );

        INSERT d;

		Internal_Registration__c ex = new Internal_Registration__c(
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
        INSERT ex;

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

        Internal_Registration__c em = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpeng@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '18712345678',
        	Name_CN__c = '张三',
            Approval_Status__c = '未审批',
            Certificate_Type__c = '筹展证|Day Voucher for booth construction ;临时证|Day Voucher',
            Approver__c = 'wang2@hisense.com',
            Company__c = '总部-HQ',
            Validity_Date__c='03-01',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT em;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        Internal_Registration__c = e2.Id,
		PresenceDate__c = '01-08;01-09',
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

        Hotel_Booked_Info__c b1 = new Hotel_Booked_Info__c(
        	Exhibition_Management__c = e1.Id,
            Internal_Registration__c = em.Id,
        	Residents__c = e2.Id
		);
        INSERT b1;

		Hotel_Booked_Info__c bx = new Hotel_Booked_Info__c(
        	Exhibition_Management__c = e1.Id,
        	Residents__c = ex.Id
		);
        INSERT bx;

		b1.Internal_Registration__c = ex.Id;
		UPDATE b1;

		e2.Approval_Status__c = '审批通过';
		UPDATE e2;

		b1.Is_Warn__c = TRUE;
        UPDATE b1;
		b1.Is_Apply__c = TRUE;
		b1.Is_Verify__c = TRUE;
        UPDATE b1;
		b1.Is_Arranged__c = TRUE;
        UPDATE b1;
        b1.Is_Arranged__c = false;
        UPDATE b1;
        b1.SelfHotel__c = '双人间';
        UPDATE b1;
        b1.Is_Arranged__c = TRUE;
        UPDATE b1;
    }


}