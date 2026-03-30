/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-17-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public withOut sharing class MessageSendEmailBusinessPeopleGroup {
    @AuraEnabled public String emailStr;
    
    public MessageSendEmailBusinessPeopleGroup(){
        List<String> emaillist = new List<String>();
        for (User us : [SELECT Email FROM User WHERE Profile.Name = '巡店员' OR Profile.Name = '促销员']) {
            emaillist.add(us.Email);
        }

        this.emailStr = String.join(emaillist, ',');
    }
}