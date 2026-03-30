/**
 * @description       : 每日凌晨1点定时任务
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
global class SystemCallSchedualByMorningGetPerson implements Schedulable {

    public String companyCode;

    global SystemCallSchedualByMorningGetPerson() {
        this.companyCode = '8410';
    }

    global void execute(SchedulableContext sc) {

        String ISDATE = System.now().addDays(-1).format('yyyyMMdd') + '';
        String IEDATE = System.now().addDays(-1).format('yyyyMMdd') + '';

        if (!Test.isRunningTest()) {

            //门店巡店员接口
            GetResponsiblePersonFROMSAP.getPersonInfo(companyCode, ISDATE, IEDATE);
        }
    }
}