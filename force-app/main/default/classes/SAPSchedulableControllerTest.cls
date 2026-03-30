/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : ryshen@deloitte.com.cn
**/
@isTest
public class SAPSchedulableControllerTest {
    @isTest
    static void testSAPSchedulableController(){
        //String companyCode = Label.Company_code;
        TestDataUtility.createCustomSettings();
        Test.startTest();
        SAPSchedulableController schedulable = new SAPSchedulableController(1,3,5,3);
        SchedulableContext sc;
        schedulable.execute(sc);
        SAPSchedulableController schedulable2 = new SAPSchedulableController(1,1,5,2);
        schedulable2.execute(sc);
        SAPSchedulableController schedulable3 = new SAPSchedulableController(0,1,1,1);
        schedulable3.execute(sc);

        SAPSchedulableByDateController schedulable4 = new SAPSchedulableByDateController(0,1,1,1,'2024-01-01','2024-01-01');
        schedulable4.execute(sc);

        SAPSchedulableByDateController schedulable5 = new SAPSchedulableByDateController(1,0,0,1,'2024-01-01','2024-01-01');
        schedulable5.execute(sc);

        SAPSchedulableByDateController schedulable6 = new SAPSchedulableByDateController('2024-01-01','8110', 1);
        schedulable6.execute(sc);
        Test.stopTest();
        
    }
}