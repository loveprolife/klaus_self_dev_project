/**********************************************************************
* 名称: SAPGetCreditLimitSchedulableController
* 功能: 
* 更新信用额度
* Author: wfc
* Create Date: 2022-02-25
*************************************************************************/
global class SAPGetCreditLimitSchedulableController implements Schedulable {
    // 更新信用额度的客户list
    public List<Account> accountList;
    // 定时名称
    public String schedulableName;
    // 发送邮件开关
    public Boolean sendEmailFlag;
    // 国家
    public String country;

    global SAPGetCreditLimitSchedulableController (List<Account> accountList, String schedulableName, Boolean sendEmailFlag, String country){
        this.accountList = accountList;
        this.schedulableName = schedulableName;
        this.sendEmailFlag = sendEmailFlag;
        this.country = country;
    }

    global void execute(SchedulableContext SC) {
        if(String.isNotBlank(schedulableName)){
            deleteSchedulable(schedulableName);
        }
        if(null != accountList && accountList.size() > 0){
            Account acc = accountList.get(0);
            SAPGetCreditLimit.syncCreditLimitOverdueFromSAPSchedulable(acc.SAP_Customer_Code__c, sendEmailFlag, country);
            Utility.insertLog('SAPGetCreditLimitSchedulableController', '1', accountList.size() + '', acc.SAP_Customer_Code__c + '-' + sendEmailFlag);
            accountList.remove(0);
            schedulableName = 'SAPGetCreditLimitSchedulableController-' + acc.SAP_Customer_Code__c + '-' + sendEmailFlag;
            System.schedule(schedulableName, Utility.nextSchedulableTime(1), new SAPGetCreditLimitSchedulableController(accountList, schedulableName, sendEmailFlag, country));
        }
        
    }

    public static void deleteSchedulable(String name) {
        // 删除定时任务
        List<CronTrigger> cronTriggers = [select Id from CronTrigger where CronJobDetail.Name = :name and CronJobDetail.JobType = '7'];
        if(cronTriggers.size() > 0){
           for(cronTrigger cronTrigger : cronTriggers){
              System.abortJob(cronTrigger.id);
           }
        }
     }

}