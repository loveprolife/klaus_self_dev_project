/*
 * @Author: WFC
 * @Date: 2024-04-26 10:00:12
 * @LastEditors: WFC
 * @LastEditTime: 2024-06-21 14:47:53
 * @Description: Learning_Platform_Management__c表trigger
 * @FilePath: \HisenseAll20240426\force-app\main\default\classes\LearningPlatformManagementHandler.cls
 */
public class LearningPlatformManagementHandler implements Triggers.Handler{
    public void handle(){
        // 同步删除关联的文件
        if (Trigger.isBefore && Trigger.isDelete){
            List<String> idList = LisqHelper.ToIds((List<Learning_Platform_Management__c>)Trigger.old);
            List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId
                                                 FROM ContentDocumentLink
                                                 WHERE LinkedEntityId IN:idList];
            if (cdlList != null && cdlList.size() > 0){
                List<String> deleteSet = new LisqContainer(cdlList).SelectSField('ContentDocumentId');
                Database.delete (deleteSet);
            }
        }

        // 新建勾选发送邮件时
        if (Trigger.isAfter && Trigger.isInsert){
            Map<Learning_Platform_Management__c, List<User>> emailMap = new Map<Learning_Platform_Management__c, List<User>>();
            for (Learning_Platform_Management__c lpm : ((list<Learning_Platform_Management__c>)Trigger.new )){
                if (!lpm.Email_Notification__c){
                    continue;
                }
                String salesRegion = lpm.Sales_Region__c;
                String personType = lpm.Person_Type__c;
                String extraPerson = lpm.Extra_Person__c;
                // sql
                String sql = ' SELECT Id, Email, Name, LanguageLocaleKey From User WHERE IsActive = TRUE AND ( ';
                String sqlSalesRegion = '';
                String sqlPersonType = '';
                List<String> salesRegionList = salesRegion.split(';');
                List<String> personTypeList = personType.split(';');
                Set<String> extraPersonSet = new Set<String>();
                for (String str : salesRegionList){
                    sqlSalesRegion += '\'' + str + '\',';
                }
                for (String str : personTypeList){
                    sqlPersonType += '\'' + str + '\',';
                }
                sqlSalesRegion = sqlSalesRegion.substring(0, sqlSalesRegion.length() - 1);
                sqlPersonType = sqlPersonType.substring(0, sqlPersonType.length() - 1);

                sql += ' ( Sales_Region__c IN ( ' + sqlSalesRegion + ' ) AND Role_Type__c INCLUDES ( ' + sqlPersonType + ' ) )';
                // 特殊用户
                if (String.isNotBlank(extraPerson)){
                    extraPersonSet.addAll(extraPerson.split(','));
                    sql += ' OR Username IN :extraPersonSet ';
                }
                sql += ' ) ';
                emailMap.put(lpm, Database.query(sql));
            }
            List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
            for (Learning_Platform_Management__c lpm : emailMap.keySet()){
                List<User> userList = emailMap.get(lpm);
                for (User u : userList){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    // mail.setToAddresses(new List<String>{ u.Email });
                    mail.setTargetObjectId(u.Id);
                    mail.setSaveAsActivity(false);
                    mail.setSubject(lpm.Name);
                    mail.setSenderDisplayName(lpm.Author_Email__c);
                    String html = '';
                    html = '<html>' + '<head>' + '</head>' + '<body>' + '<div">';
                    html += '<P>' + String.format(Label.get('', 'Learning_Platform_Email_One', u.LanguageLocaleKey), new List<Object>{ u.Name }) + '</p>';
                    html += '<P>' + String.format(Label.get('', 'Learning_Platform_Email_Two', u.LanguageLocaleKey), new List<Object>{ lpm.Name }) + '</p>';
                    html += '</div>' + '</body>' + '</html>';
                    mail.setHtmlBody(html);
                    sendEmailList.add(mail);
                }
            }

            if (sendEmailList.size() > 0){
                if (!Test.isRunningTest()){
                    Messaging.sendEmail(sendEmailList);
                }
            }
        }
    }

}