public without sharing class UserController{

    @Future(callout =true)
    public static void insertUser(List<String> userEmailList){
        // 要新增的用户
        List<User> addUserList = new List<User>();
        try{
            // 查询系统用户
            List<User> userNowList = [SELECT Username FROM User WHERE Username IN :userEmailList];
            Map<String, User> userNowmap = new Map<String, User>();
            for(User u : userNowList){
                userNowmap.put(u.Username, u);
            }
            // 根据邮箱查询名字
            Map<String, String> sendEmailUsermap = new Map<String, String>();
            List<Send_Email_User__c> sendEmailUserList = [SELECT Username__c, Address__c FROM Send_Email_User__c WHERE Address__c IN :userEmailList];
            for(Send_Email_User__c seu : sendEmailUserList){
                sendEmailUsermap.put(seu.Address__c, seu.Username__c);
            }
            // 新用户role和profile
            UserRole r = [SELECT Id FROM UserRole WHERE Name = 'Send Email Role' LIMIT 1];
            Profile p = [SELECT Id FROM Profile WHERE Name = 'Send Email User' LIMIT 1];
            for (String str : userEmailList) {
                if(String.isNotBlank(str) && userNowmap.get(str) == null){
                    User u = new User();
                    u.LastName = sendEmailUsermap.get(str);
                    u.Alias = sendEmailUsermap.get(str) != null ? sendEmailUsermap.get(str).substring(0, 8) : 'hisense';
                    u.Email = str;
                    u.Username = str;
                    u.UserRoleId = r.Id;
                    u.ProfileId = p.id;
                    u.IsActive = true;
                    u.HisenseSSOName__c = str.substring(0, str.indexOf('@'));
                    u.TimeZoneSidKey = 'Asia/Shanghai';
                    u.LocaleSidKey = 'zh_CN';
                    u.DefaultCurrencyIsoCode = 'USD';
                    u.EmailEncodingKey = 'GB2312';
                    u.LanguageLocaleKey = 'zh_CN';
                    addUserList.add(u);
                }
            }
            if(addUserList != null && addUserList.size() > 0){
                Database.insert(addUserList);
            }
        //错误数据   
        }catch(Exception e){
            System.debug(e.getMessage()+e.getLineNumber());
        }

        

    } 
}