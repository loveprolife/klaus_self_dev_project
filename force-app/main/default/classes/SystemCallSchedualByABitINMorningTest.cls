/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
public class SystemCallSchedualByABitINMorningTest {
    static testMethod void testSystemCallSchedualByABitINMorning(){

		test.startTest();
        String fmt = Utility.nextSchedulableTime(300);
        String scheduledJob = 'SystemCallSchedualByABitINMorning' + '_' + fmt;
        Type t = Type.forName('SystemCallSchedualByABitINMorning');
        Schedulable classInstance = (Schedulable)t.newInstance();
        System.schedule(scheduledJob, fmt, classInstance);
        test.stopTest();    
    }
}