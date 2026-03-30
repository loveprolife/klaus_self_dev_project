public class TrainingTriggerHandler implements Triggers.Handler{
    public void handle(){
        if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            // 邮箱集合
            Set<String> emailSet = new Set<String>();
            for (Training__c training : ((list<Training__c>)Trigger.new )){
                emailSet.add(training.Email__c);
            }
            // 根据邮箱查询培训人员名称
            List<User> userList = [SELECT Id, Name, Username
                                   FROM User
                                   WHERE Username IN:emailSet AND IsActive = true];
            Map<String, String> emailMap = new Map<String, String>();
            Map<String, String> userMap = new Map<String, String>();
            for (User user : userList){
                emailMap.put(user.Username, user.Name);
                userMap.put(user.Username, user.Id);
            }
            for (Training__c training : ((list<Training__c>)Trigger.new )){
                training.Trainer_Name__c = emailMap.get(training.Email__c);
                training.Trainer_User__c = userMap.get(training.Email__c);
                training.key__c = training.Year__c + '-' + training.Month__c + '-' + training.Email__c + '-' + training.Training_Theme__c;
                if (userMap.get(training.Email__c) != null){
                    training.OwnerId = userMap.get(training.Email__c);
                }
            }
        }
    }

}