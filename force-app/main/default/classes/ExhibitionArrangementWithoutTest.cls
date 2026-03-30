@isTest
private class ExhibitionArrangementWithoutTest {
    static testMethod void testMethod1() {
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
        	// //Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        INSERT e3;

        Internal_Registration__c e21 = new Internal_Registration__c(
        	Exhibition_Id__c = e1.Id,
        	Email__c = 'etpenggg@deloitte.com.cn',
        	Position__c = '经理',
        	Phone__c = '1871233345678',
        	Name_CN__c = '张',
        	// //Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e21;

        Exhibition_Arrangement__c e31 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e21.Id,
        	Roommate__c = 'shiyong');

        INSERT e31;
        Exhibition_Arrangement__c e32 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e21.Id,
        	Roommate__c = 'shiyong');

        INSERT e32;








        ExhibitionArrangementWithoutController.selExhibitionArrangementId('张三', 'etpeng@deloitte.com.cn', e3.Id);

        ExhibitionArrangementWithoutController.selExhibitionArrangementId('张', 'etpenggg@deloitte.com.cn', 'toieyoiueotuewp');


    }

    static testMethod void testMethod2() {
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
        	//Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore',
			Approval_Status__c = '审批通过'
            );
        INSERT e2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
        	Roommate__c = 'shiyong');

        UPSERT e3;
        // Exhibition_Arrangement__c e3  = [SELECT Id FROM Exhibition_Arrangement__c WHERE Internal_Registration__c =: e2.Id LIMIT 1][0];

        ExhibitionArrangementWithoutController.saveExhibitionArrangement('test');
        ExhibitionArrangementWithoutController.saveExhibitionArrangement(JSON.serialize(e3));



    }
    static testMethod void testMethod3() {
        ExpoInfo__c e1 = new ExpoInfo__c(
        	LastRegistrationDate__c = Date.today()+15, 
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
        	// //Purpose_Of_Exhibition__c = '参展目的',
        	Deliverable__c = 'werytukjgfsdtrewertyuilkftgjdfrelgeoiagoewutoewutpewprwqoupwertyuiowytrertyuioiytryuoipiuuweoiriueygwritwerhitoewqhojhewfrihgoierjhotkohgjdslgjrojyore'
			);
        INSERT e2;

        Exhibition_Hotel__c h1 = new Exhibition_Hotel__c(Name = 'hotel1',
        	Exhibition_Management__c = e1.Id);
        INSERT h1;
        Exhibition_Hotel__c h2 = new Exhibition_Hotel__c(Name = 'hotel2',
        	Exhibition_Management__c = e1.Id);
        INSERT h2;

        Exhibition_Arrangement__c e3 = new Exhibition_Arrangement__c(
        	Internal_Registration__c = e2.Id,
            PresenceDate__c ='04-01;04-02',
        	Roommate__c = 'shiyong');

        INSERT e3;

        Exhibition_Vehical_Booking__c b1 = new Exhibition_Vehical_Booking__c(
            Vehicle_Type__c = '大巴',
            Date__c = Date.today(),
            Exhibition_Arrangement__c = e3.Id,
            Internal_Registration__c = e2.Id);
        INSERT b1;
        Exhibition_Vehical_Booking__c b2 = new Exhibition_Vehical_Booking__c(
            Vehicle_Type__c = '大巴',
            Date__c = Date.today(),
            Exhibition_Arrangement__c = e3.Id,
            Internal_Registration__c = e2.Id,
            Is_Arranged__c = TRUE);
        INSERT b2;


        ExhibitionArrangementWithoutController.getInitData('test');
        ExhibitionArrangementWithoutController.getInitData(e3.Id);
        ExhibitionArrangementWithoutController.createdRecord(e2.Id, e3.Id, '大巴', Date.today());
        ExhibitionArrangementWithoutController.getExhibionVeBooking(e2.Id, e3.Id);
        ExhibitionArrangementWithoutController.getExhibionVeBookingNotArranged(e2.Id, e3.Id);
        ExhibitionArrangementWithoutController.delRecord(new List<String>{b1.Id});


        Exhibition_Vehical_Booking__c b11 = new Exhibition_Vehical_Booking__c(
            Vehicle_Type__c = '大巴',
            Date__c = Date.today()
            );

        Exhibition_Vehical_Booking__c b111 = new Exhibition_Vehical_Booking__c(
            Vehicle_Type__c = '大巴',
            Date__c = Date.today(),
            Exhibition_Arrangement__c = e3.Id,
            Internal_Registration__c = e2.Id);
        INSERT b111;
        b111.Date__c = Date.today()-1;


        b2.Date__c = Date.today()-1;
        ExhibitionArrangementWithoutController.upsertRecords(JSON.serialize(new List<Exhibition_Vehical_Booking__c>{b11}),e2.Id, e3.Id);
        ExhibitionArrangementWithoutController.upsertRecords(JSON.serialize(new List<Exhibition_Vehical_Booking__c>{b111}),e2.Id, e3.Id);
        ExhibitionArrangementWithoutController.upsertRecords(JSON.serialize(new List<Exhibition_Vehical_Booking__c>{b2}),e2.Id, e3.Id);

        ExhibitionArrangementWithoutController.delVehicalBookingExpectArranged(e3.Id,e2.Id );



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