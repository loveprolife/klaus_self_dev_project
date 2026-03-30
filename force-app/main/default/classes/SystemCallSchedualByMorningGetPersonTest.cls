/**
 * @description       : 
 * @author            : ryshen@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-24-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
@isTest
public class SystemCallSchedualByMorningGetPersonTest {
    @isTest
    static void testSystemCallSchedualByMorningGetPerson(){
        
		test.startTest();
        String fmt = '0 0 1 * * ?';
        String scheduledJob = 'SystemCallSchedualByMorningGetPerson' + '_' + fmt;
        Type t = Type.forName('SystemCallSchedualByMorningGetPerson');
        Schedulable classInstance = (Schedulable)t.newInstance();
        System.schedule(scheduledJob, fmt, classInstance);
        test.stopTest();   
        
    }
}