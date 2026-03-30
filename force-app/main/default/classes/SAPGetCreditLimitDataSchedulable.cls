/*
 * @Author: WFC
 * @Date: 2022-09-23 13:36:59
 * @LastEditors: WFC
 * @LastEditTime: 2022-12-13 10:48:28
 * @Description: 更新日本信用额度
 * @FilePath: \Hitest_2022\force-app\main\default\classes\SAPGetCreditLimitDataSchedulable.cls
 */
global class SAPGetCreditLimitDataSchedulable implements Schedulable {
    // hisense entity
    public String hisenseEntity;
    // 发送邮件开关
    public Boolean sendEmailFlag;

    global SAPGetCreditLimitDataSchedulable (String hisenseEntity, Boolean sendEmailFlag){
        this.hisenseEntity = hisenseEntity;
        this.sendEmailFlag = sendEmailFlag;
    }

    global void execute(SchedulableContext SC) {
        //List<Account> accountList = [SELECT id,SAP_Customer_Code__c FROM Account WHERE SAP_Customer_Code__c != NULL AND Hisense_Entity__c =:hisenseEntity];
        List<Customer_Extend__c> extendList = [SELECT id,Customer__r.Id,Customer__r.SAP_Customer_Code__c FROM Customer_Extend__c  WHERE Customer__r.SAP_Customer_Code__c != NULL AND Hisense_Entity__c =:hisenseEntity and Customer__r.RecordType.DeveloperName != 'Customer_address'];
        List<Account> accountList = new List<Account>();
        for(Customer_Extend__c customerExtend : extendList){
            accountList.add(customerExtend.Customer__r);
        }
        String schedulableName = 'SAPGetCreditLimitDataSchedulable-' + hisenseEntity;
        System.schedule(schedulableName, Utility.nextSchedulableTime(1), new SAPGetCreditLimitSchedulableController(accountList, schedulableName, sendEmailFlag, 'JP'));
        Utility.insertLog('SAPGetCreditLimitDataSchedulable', '1', accountList.size() + '', hisenseEntity);
    }
}