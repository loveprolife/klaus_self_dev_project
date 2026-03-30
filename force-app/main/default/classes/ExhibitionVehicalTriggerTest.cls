@isTest
private class ExhibitionVehicalTriggerTest {
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
		PresenceDate__c = '10-11;10-12',
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

        

		Vehicle_Allocation_Schedule__c v1 = new Vehicle_Allocation_Schedule__c(
        	Name = 'test',
			Exhibition_Management__c = e1.Id);
        INSERT v1;

        Exhibition_Vehical_Booking__c b1 = new Exhibition_Vehical_Booking__c(
        	Vehicle_Type__c = '大巴',
        	Date__c = Date.today(),
        	Exhibition_Arrangement__c = e3.Id,
        	Internal_Registration__c = e5.Id,
			Plate_Number__c = '鲁12345', 
			Driver_Phone__c = '12345678999', 
			Departure_Time__c = Time.newInstance(9,30,0,0),
			Vehical_Driver__c = '我就是司机',
			Vehicle_Allocation_Schedule__c = v1.id,
			Vehicle_Run_Time__c = Date.today() + ' ' + Time.newInstance(9,30,0,0),
			Pick_Up_Point__c = 'XX机场',
			Return_Date__c = Date.today() + 1,
			Return_Departure_Time__c = Time.newInstance(9,30,0,0),
			Return_Vehicle_Run_Time__c = Date.today() + 1 + ' ' + Time.newInstance(9,30,0,0),
			Return_Pick_Up_Point__c = '桔子酒店',
			Return_Vehicle_Schedule__c = v1.id,
			Is_Warn__c = false,
			Is_Apply__c = false,
			Is_Arranged__c = false,
			Return_Is_Arranged__c = false,
			Cancel_Arrangement__c = false
			);
        INSERT b1;

		b1.Is_Warn__c = TRUE;
        UPDATE b1;
		b1.Is_Apply__c = TRUE;
		b1.Is_Verify__c = TRUE;
        UPDATE b1;
		b1.Is_Arranged__c = TRUE;
        UPDATE b1;
		b1.Return_Is_Arranged__c = TRUE;
        UPDATE b1;
		b1.Is_Arranged__c = false;
        UPDATE b1;

		b1.Cancel_Arrangement__c = true;
        UPDATE b1;

        // try {
        //     b1.Vehicle_Type__c = '布展小巴';
        //     UPDATE b1;
        // }
        // catch (Exception e) {
            
        // }
        
    }
}