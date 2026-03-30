global class FreezeUserSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        // 不冻结的username
        List<String> timeList = Label.Not_Freeze_Username.split(',');
        // 查询过期用户
        List<User> userList = [SELECT Id FROM User WHERE LastLoginDate < LAST_90_DAYS AND IsActive = true AND username not in : timeList];
        // 冻结过期用户
        List<Id> idList = new List<Id>();
        for(User u : userList){
            idList.add(u.Id);
        }
        List<UserLogin> loginList = [SELECT Id, IsFrozen, UserId FROM UserLogin WHERE userid in : idList AND IsFrozen = false];
        for(UserLogin ul : loginList){
            ul.IsFrozen = true;
        }
        Database.update(loginList);
    }
}