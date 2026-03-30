/**
 * Name : NotificationPromoterScheduleable
 * Author : Chiara
 * Date : 2022/03/03
 * Purporse: 
 * 每周一上午9点为止如果未提出周报的情况下邮件通知
 */
public without sharing class NotificationPromoterScheduleable implements Schedulable {

    public void execute(SchedulableContext sc) {
		Set<String> userIdSet = new Set<String>();
    	Date today = System.today();//Date.valueOf('2022-02-28');////星期一
		Date startDate = today.addDays(-7);
		Date endDate = today.addDays(-1);
		for (Week_Question_Item__c questionItem : 
				[ SELECT 
						Id,
						Shop_Research__r.Promoter__c,
					( SELECT 
						Id,
						Response__c,
						StartDate__c,
						EndDate__c 
						FROM Question_Item_WeekResearchResponseItems__r 
						WHERE 
						StartDate__c =: startDate
						AND
						EndDate__c =: endDate
					)  
				FROM Week_Question_Item__c 
				WHERE 
					Status__c = '有效' 
				AND 
					Shop_Research__r.IsActive__c = TRUE] ) {
			if(questionItem.Question_Item_WeekResearchResponseItems__r == null || questionItem.Question_Item_WeekResearchResponseItems__r.size() ==0) {
				userIdSet.add(questionItem.Shop_Research__r.Promoter__c);
			}else{
				for(WeekResearchResponseItem__c responseItem : questionItem.Question_Item_WeekResearchResponseItems__r) {
					if(String.isBlank( responseItem.Response__c)) {
						userIdSet.add(questionItem.Shop_Research__r.Promoter__c);
					}
				}
			}
		}
		if(userIdSet.size() > 0) {
			List<EmailTemplate> etList = EmailNotificationUtility.getEmailTemplate('PromoterDailyReportNotification');
			if(etList.size() > 0) {
				EmailNotificationUtility.sendEmailNotificationReplaceTargetUser(etList[0],new List<String>(userIdSet));
			}
		}
    }
}