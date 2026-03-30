/*
 * @Author: WFC
 * @Date: 2022-12-13 09:59:33
 * @LastEditors: WFC
 * @LastEditTime: 2023-03-09 09:07:31
 * @Description: 更新南非信用申请，发送预警邮件
 * @FilePath: \Hitest_2022\force-app\main\default\classes\SAPGetCreditLimitDataSASchedulable.cls
 */
global class SAPGetCreditLimitDataSASchedulable implements Schedulable {
    // hisense entity
    public List<String> hisenseEntityList;
    // 发送邮件开关
    public Boolean sendEmailFlag;

    global SAPGetCreditLimitDataSASchedulable (String hisenseEntity, Boolean sendEmailFlag){
        this.hisenseEntityList = hisenseEntity.split(',');
        this.sendEmailFlag = sendEmailFlag;
    }

    global void execute(SchedulableContext SC) {
        //List<Account> accountList = [SELECT id,SAP_Customer_Code__c FROM Account WHERE SAP_Customer_Code__c != NULL AND Hisense_Entity__c in:hisenseEntityList AND SA_Credit_Send_Email_Flag__c = true];
        List<Customer_Extend__c> extendList = [SELECT id,Customer__r.Id,Customer__r.SAP_Customer_Code__c FROM Customer_Extend__c  WHERE Customer__r.SAP_Customer_Code__c != NULL AND Hisense_Entity__c in:hisenseEntityList and Customer__r.SA_Credit_Send_Email_Flag__c = true];
        List<Account> accountList = new List<Account>();
        for(Customer_Extend__c customerExtend : extendList){
            accountList.add(customerExtend.Customer__r);
        }
        String schedulableName = 'SAPGetCreditLimitDataSASchedulable-' + hisenseEntityList.toString();
        System.schedule(schedulableName, Utility.nextSchedulableTime(1), new SAPGetCreditLimitSchedulableController(accountList, schedulableName, sendEmailFlag, 'SA'));
        Utility.insertLog('SAPGetCreditLimitDataSASchedulable', '1', accountList.size() + '', hisenseEntityList.toString());
    }
}