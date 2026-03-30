/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AnnualEventNotificationEmailAndSmsTest {

    static testMethod void testMethod1() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-1, 
        	EndDate__c = Date.today()+10,
        	Name = '2025展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = '陶靖朋',
            Name = '陶靖朋',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

        // e2.Approval_Status__c = '审批通过';
        e2.Approval_Status__c = '高级权限';
        update e2;

        Internal_Registration__c a2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = 'tutu',
            Name = 'tutu',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT a2;

        // e2.Approval_Status__c = '审批通过';
        a2.Approval_Status__c = '审批通过';

        update a2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        INSERT e3;

        AnnualEventNotificationEmailAndSmsMethod.processMailCC(new List<String>{a2.Id});
        
    }

    static testMethod void testMethod2() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-1, 
        	EndDate__c = Date.today()+10,
        	Name = '2025展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = '陶靖朋',
            Name = '陶靖朋',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

        // e2.Approval_Status__c = '审批通过';
        e2.Approval_Status__c = '高级权限';

        update e2;

        Internal_Registration__c a2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = 'tutu',
            Name = 'tutu',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT a2;

        // e2.Approval_Status__c = '审批通过';
        a2.Approval_Status__c = '审批通过';

        update a2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        INSERT e3;

        AnnualEventNotificationTwoMethod.processMailCC();
        
    }

    static testMethod void testMethod3() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-1, 
        	EndDate__c = Date.today()+10,
        	Name = '2025展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = '陶靖朋',
            Name = '陶靖朋',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

        // e2.Approval_Status__c = '审批通过';
        e2.Approval_Status__c = '高级权限';

        update e2;

        Internal_Registration__c a2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = 'tutu',
            Name = 'tutu',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT a2;

        // e2.Approval_Status__c = '审批通过';
        a2.Approval_Status__c = '审批通过';

        update a2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        INSERT e3;

        AnnualEventNotificationThreeMethod.processMailCC();
        
    }

    static testMethod void testMethod4() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-1, 
        	EndDate__c = Date.today()+10,
        	Name = '2025展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = '陶靖朋',
            Name = '陶靖朋',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

        // e2.Approval_Status__c = '审批通过';
        e2.Approval_Status__c = '高级权限';

        update e2;

        Internal_Registration__c a2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = 'tutu',
            Name = 'tutu',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT a2;

        // e2.Approval_Status__c = '审批通过';
        a2.Approval_Status__c = '审批通过';

        update a2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        INSERT e3;

        AnnualEventNotificationFourMethod.processMailCC();
        
    }

    static testMethod void testMethod5() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-1, 
        	EndDate__c = Date.today()+10,
        	Name = '2025展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = '陶靖朋',
            Name = '陶靖朋',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

        // e2.Approval_Status__c = '审批通过';
        e2.Approval_Status__c = '高级权限';
        update e2;

        Internal_Registration__c a2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = 'tutu',
            Name = 'tutu',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT a2;

        // e2.Approval_Status__c = '审批通过';
        a2.Approval_Status__c = '审批通过';

        update a2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        INSERT e3;

        AnnualEventNotificationFiveMethod.processMailCC();
        
    }

    static testMethod void testMethod6() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-1, 
        	EndDate__c = Date.today()+10,
        	Name = '2025展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = '陶靖朋',
            Name = '陶靖朋',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

        // e2.Approval_Status__c = '审批通过';
        e2.Approval_Status__c = '高级权限';

        update e2;

        Internal_Registration__c a2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = 'tutu',
            Name = 'tutu',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT a2;

        // e2.Approval_Status__c = '审批通过';
        a2.Approval_Status__c = '审批通过';

        update a2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        INSERT e3;

        AnnualEventNotificationSixMethod.processMailCC();
        
    }

    static testMethod void testMethod7() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-1, 
        	EndDate__c = Date.today()+10,
        	Name = '2025展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = '陶靖朋',
            Name = '陶靖朋',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

        // e2.Approval_Status__c = '审批通过';
        e2.Approval_Status__c = '高级权限';

        update e2;

        Internal_Registration__c a2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = 'tutu',
            Name = 'tutu',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT a2;

        // e2.Approval_Status__c = '审批通过';
        a2.Approval_Status__c = '审批通过';

        update a2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        INSERT e3;

        AnnualEventNotificationSevenMethod.processMailCC();
        
    }

    static testMethod void testMethod8() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
        	StartDate__c = Date.today()-1, 
        	EndDate__c = Date.today()+10,
        	Name = '2025展会信息',
        	TitleEN__c = 'Exhibition Informatino',
        	DisplayInThePortal__c = true
        	);
        INSERT e1;

        Internal_Registration__c e2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = '陶靖朋',
            Name = '陶靖朋',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

        // e2.Approval_Status__c = '审批通过';
        e2.Approval_Status__c = '高级权限';

        update e2;

        Internal_Registration__c a2 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'taojingpeng.ex@hx-partners.com',
        	Position__c = '个人',
        	Phone__c = '18037506005',
        	Name_CN__c = 'tutu',
            Name = 'tutu',
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT a2;

        // e2.Approval_Status__c = '审批通过';
        a2.Approval_Status__c = '审批通过';

        update a2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        INSERT e3;

        AnnualEventNotificationEightMethod.processMailCC();
        
    }

}