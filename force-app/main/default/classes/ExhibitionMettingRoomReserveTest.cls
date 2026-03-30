@isTest
private class ExhibitionMettingRoomReserveTest {
	static Exhibition_Meeting_Room_Info__c e2 = NULL;

	static void makeData() {
		ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-1, 
        	EndDate__c = Date.today()+10,
        	Name = '展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        e2 = new Exhibition_Meeting_Room_Info__c(
        	Exhibition_Management__c = e1.Id,
        	Start_Date__c = Date.today(),
        	End_Date__c = Date.today()+5,
        	Start_Time__c = Time.newInstance(7, 7, 7, 7),
        	End_Time__c = Time.newInstance(17, 7, 7, 7)
        	);
        INSERT e2;

        Exhibition_Meeting_Room_Reservation__c e3 = new Exhibition_Meeting_Room_Reservation__c(
        	Exhibition_Metting_Room_Info__c = e2.Id,
        	Metting_Start_Time__c = Time.newInstance(8, 7, 7, 7),
        	Metting_End_Time__c = Time.newInstance(11, 7, 7, 7),
        	Is_Active__c = true,
        	Applicant_Name__c = '张三',
        	Applicant_Phone_Number__c = '18716731234',
        	Metting_Date__c = Date.today()+2,
        	Hisense_Participates_Leader__c = 'Li Si',
        	Meeting_Purpose__c = 'retoijeroghewoihgoiewhgoiewhgoihewoihewhgiewhoitewjtoewjgoihdifogewihgoiewhoiewgoiewhgoiewhoighewoighewoihfoiehfudshkjdsagkjehgiewhiorewoighdksgkewhg'
        	);
        INSERT e3;
	}

	static testMethod void testMethod0() {
        makeData();
        Test.startTest();
        Exhibition_Meeting_Room_Reservation__c e311 = new Exhibition_Meeting_Room_Reservation__c(
        	Exhibition_Metting_Room_Info__c = e2.Id,
        	Metting_Start_Time__c = Time.newInstance(8, 7, 7, 7),
        	Metting_End_Time__c = Time.newInstance(11, 7, 7, 7),
        	Is_Active__c = false,
        	Applicant_Name__c = '张三1',
        	Applicant_Phone_Number__c = '18716731239',
        	Metting_Date__c = Date.today()+4,
        	Hisense_Participates_Leader__c = 'Li Si',
        	Meeting_Purpose__c = 'retoijeroghewoihgoiewhgoiewhgoihewoihewhgiewhoitewjtoewjgoihdifogewihgoiewhoiewgoiewhgoiewhoighewoighewoihfoiehfudshkjdsagkjehgiewhiorewoighdksgkewhg'
        	);
        INSERT e311;

        e311.Is_Active__c = true;
        UPDATE e311;
        Test.stopTest();
        
    }

    static testMethod void testMethod1() {
        makeData();
        Test.startTest();
        Exhibition_Meeting_Room_Reservation__c e31 = new Exhibition_Meeting_Room_Reservation__c(
        	Exhibition_Metting_Room_Info__c = e2.Id,
        	Metting_Start_Time__c = Time.newInstance(7, 7, 7, 7),
        	Metting_End_Time__c = Time.newInstance(11, 7, 7, 7),
        	Is_Active__c = true,
        	Applicant_Name__c = '张三1',
        	Applicant_Phone_Number__c = '18716731234',
        	Metting_Date__c = Date.today()+6,
        	Hisense_Participates_Leader__c = 'Li Si',
        	Meeting_Purpose__c = 'retoijeroghewoihgoiewhgoiewhgoihewoihewhgiewhoitewjtoewjgoihdifogewihgoiewhoiewgoiewhgoiewhoighewoighewoihfoiehfudshkjdsagkjehgiewhiorewoighdksgkewhg'
        	);
        Test.stopTest();
        // INSERT e31;
        try {
            INSERT e31;
        }
        catch (Exception e) {
            System.debug('ANY o'+e.getStackTraceString());
        }
    }

    static testMethod void testMethod2() {
        makeData();
        Test.startTest();
        
        Exhibition_Meeting_Room_Reservation__c e33 = new Exhibition_Meeting_Room_Reservation__c(
        	// Exhibition_Metting_Room_Info__c = e2.Id,
        	Metting_Start_Time__c = Time.newInstance(7, 7, 7, 7),
        	Metting_End_Time__c = Time.newInstance(11, 7, 7, 7),
        	Is_Active__c = true,
        	Applicant_Name__c = '张三2',
        	Applicant_Phone_Number__c = '18716731234',
        	Metting_Date__c = Date.today()+2,
        	Hisense_Participates_Leader__c = 'Li Si',
        	Meeting_Purpose__c = 'retoijeroghewoihgoiewhgoiewhgoihewoihewhgiewhoitewjtoewjgoihdifogewihgoiewhoiewgoiewhgoiewhoighewoighewoihfoiehfudshkjdsagkjehgiewhiorewoighdksgkewhg'
        	);
        // INSERT e31;
        try {
            INSERT e33;
        }
        catch (Exception e2) {
            System.debug('ANY o'+e2.getStackTraceString());
        }
    }

    static testMethod void testMethod3() {
        makeData();
        Test.startTest();
        Exhibition_Meeting_Room_Reservation__c e32 = new Exhibition_Meeting_Room_Reservation__c(
        	Exhibition_Metting_Room_Info__c = e2.Id,
        	Metting_Start_Time__c = Time.newInstance(17, 7, 7, 7),
        	Metting_End_Time__c = Time.newInstance(11, 7, 7, 7),
        	Is_Active__c = true,
        	Applicant_Name__c = '张三3',
        	Applicant_Phone_Number__c = '18716731234',
        	Metting_Date__c = Date.today()+2,
        	Hisense_Participates_Leader__c = 'Li Si',
        	Meeting_Purpose__c = 'retoijeroghewoihgoiewhgoiewhgoihewoihewhgiewhoitewjtoewjgoihdifogewihgoiewhoiewgoiewhgoiewhoighewoighewoihfoiehfudshkjdsagkjehgiewhiorewoighdksgkewhg'
        	);
        // INSERT e31;
        try {
            INSERT e32;
        }
        catch (Exception e1) {
            System.debug('ANY o'+e1.getStackTraceString());
        }
    }

    static testMethod void testMethod4() {
        makeData();
        Test.startTest();
        
        Exhibition_Meeting_Room_Reservation__c e34 = new Exhibition_Meeting_Room_Reservation__c(
        	Exhibition_Metting_Room_Info__c = e2.Id,
        	Metting_Start_Time__c = Time.newInstance(7, 7, 7, 7),
        	Metting_End_Time__c = Time.newInstance(10, 7, 7, 7),
        	Is_Active__c = true,
        	Applicant_Name__c = '张三4',
        	Applicant_Phone_Number__c = '18716731234',
        	Metting_Date__c = Date.today()+2,
        	Hisense_Participates_Leader__c = 'Li Si',
        	Meeting_Purpose__c = 'retoijeroghewoihgoiewhgoiewhgoihewoihewhgiewhoitewjtoewjgoihdifogewihgoiewhoiewgoiewhgoiewhoighewoighewoihfoiehfudshkjdsagkjehgiewhiorewoighdksgkewhg'
        	);
        // INSERT e31;

        try {
            INSERT e34;
        }
        catch (Exception e3) {
            System.debug('ANY o'+e3.getStackTraceString());
        }
    }






}