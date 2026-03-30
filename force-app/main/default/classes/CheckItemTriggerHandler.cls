public class CheckItemTriggerHandler extends BaseTriggerHandler {

    public override String getClassName() {
        return super.getClassName();
    }
    
    public override void beforeInsert(){
        CheckItemTriggerHandlerHelper.duplicateCheck(this.oldList, this.newList);
    }

    public override void beforeUpdate(){
        CheckItemTriggerHandlerHelper.duplicateCheck(this.oldList, this.newList);
    }
    
    public override void afterUpdate(){

        Map<Id, CheckItem__c> oldMap = new Map<Id, CheckItem__c>();
        if(this.oldList != null) {
            oldMap = new Map<Id, CheckItem__c>((list<CheckItem__c>)this.oldList);
        }

        List<User> userList = [select id,Email from user where Sales_Region__c = 'Hisense South Africa' and IsActive = true 
            and UserRole.Name in ('SouthAfrica Third Regional Manager',
                                    'SouthAfrica BA\'s EC/Garden/FS',
                                    'SouthAfrica BA\'s GP1',
                                    'SouthAfrica BA\'s GP&NW',
                                    'SouthAfrica BA\'s KZN',
                                    'SouthAfrica BA\'s LP&MP',
                                    'SouthAfrica BA\'s WC/NC',
                                    'SouthAfrica Blitz Field Reps EC/Garden/FS',
                                    'SouthAfrica Blitz Field Reps GP1',
                                    'SouthAfrica Blitz Field Reps GP&NW',
                                    'SouthAfrica Blitz Field Reps KZN',
                                    'SouthAfrica Blitz Field Reps LP&MP',
                                    'SouthAfrica Blitz Field Reps WC/NC',
                                    'SouthAfrica Ops Regional Manager For GP/NW/LP&MP',
                                    'SouthAfrica Ops Regional Manager For WC/EC&FS/KZN',
                                    'SouthAfrica Regional Manager EC/Garden/FS',
                                    'SouthAfrica Regional Manager GP1',
                                    'SouthAfrica Regional Manager GP&NW',
                                    'SouthAfrica Regional Manager KZN',
                                    'SouthAfrica Regional Manager LP&MP',
                                    'SouthAfrica Regional Manager WC/NC',
                                    'SouthAfrica Third BA GP1',
                                    'SouthAfrica Market Manager',
                                    'SouthAfrica Third Blitz GP1'
                                    )];
        List<Responsible_Person__c> rpList = [select RecordType__c, Principal__r.id, Principal__r.Email, Principal__r.UserRole.Name, Shop_Name__r.Account__r.id  from Responsible_Person__c where Shop_Name__r.Sales_Region__c = 'Hisense South Africa' and Principal__r.IsActive = true];
        Map<String, List<Responsible_Person__c>> rpMap = new Map<String, List<Responsible_Person__c>>();
        for(Responsible_Person__c rp : rpList){
            if('巡店员'.equals(rp.RecordType__c) || 'Backup Floorwalker'.equals(rp.RecordType__c)){
                rp.RecordType__c = 'Floorwalker';
            }
            if(rpMap.containsKey(rp.Shop_Name__r.Account__r.id)){
                rpMap.get(rp.Shop_Name__r.Account__r.id).add(rp);
            }else{
                List<Responsible_Person__c> rpMapList = new List<Responsible_Person__c>();
                rpMapList.add(rp);
                rpMap.put(rp.Shop_Name__r.Account__r.id, rpMapList);
            }
        }
        
        List<CheckListScope__c> clsList = [select id, CheckItem__c, Role__c, Customer__c from CheckListScope__c where Sales_Region__c = 'Hisense South Africa'];
        Map<String, List<CheckListScope__c>> clsMap = new Map<String, List<CheckListScope__c>>();
        for(CheckListScope__c cls : clsList){
            if(clsMap.containsKey(cls.CheckItem__c)){
                clsMap.get(cls.CheckItem__c).add(cls);
            }else{
                List<CheckListScope__c> clsMapList = new List<CheckListScope__c>();
                clsMapList.add(cls);
                clsMap.put(cls.CheckItem__c, clsMapList);
            }
        }

        
        for (CheckItem__c item : ((list<CheckItem__c>)this.newList)) {

            if(oldMap.get(item.id).Description__c == item.Description__c){
                continue;
            }
            List<User> sendUserList = new List<User>();
            if('Hisense South Africa'.equals(item.Sales_Region__c) && clsMap.containsKey(item.id)){  
                for(CheckListScope__c cls : clsMap.get(item.id)){
                    sendUserList.addAll(getSendUser(cls, rpMap, userList));
                }
                sendNotAndMail(sendUserList, item, oldMap.get(item.id));
            }
        }
        
    }
    public static void sendNotAndMail(List<User> sendUserList, CheckItem__c newData, CheckItem__c oldData){

        List<UserLogin> UserLoginList = [select UserId, IsFrozen from UserLogin];
        Map<String, Boolean> UserLoginMap = new Map<String, Boolean>();
        for(UserLogin u : UserLoginList){
            UserLoginMap.put(u.UserId, u.IsFrozen);
        }
        
        String title = 'SS has been changed'.replace('SS', newData.Name);
        String body = 'Change XX to YY in the Check List'.replace('XX', '"' + oldData.Description__c + '"').replace('YY', '"' + newData.Description__c + '"');

        List<CustomNotificationType> cntList = [SELECT id,DeveloperName FROM CustomNotificationType WHERE DeveloperName =: 'Custom_Notification'];
        if(sendUserList != null && sendUserList.size()>0){

            Set<String> targetIdList = new Set<String>();
            Set<String> mailList = new Set<String>();
            for(User user : sendUserList){
                if(UserLoginMap.get(user.id)){
                    continue;
                }
                targetIdList.add(user.id);
                mailList.add(user.Email);
            }

            System.debug('targetIdList'+targetIdList);
            System.debug('mailList'+mailList);
            Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
            currNotification.setTitle(title);
            currNotification.setBody(body);
            currNotification.setNotificationTypeId(cntList[0].Id);
            currNotification.setTargetId(oldData.Id);
            currNotification.send(targetIdList);

            try{
                List<String> toAddress = new List<String>(mailList);
                Utility.sendMail(title, body, toAddress, 'Salesforce System', '');
            }catch(Exception e){
                System.debug('CheckItemTriggerHandler SendMail Faild' + e.getMessage());
            }
        }
    }
    
    public static List<User> getSendUser(CheckListScope__c cls, Map<String, List<Responsible_Person__c>> rpMap, List<User> userList){
        List<User> resultUserList = new List<User>();

        if(String.isNotBlank(cls.Customer__c) && String.isBlank(cls.Role__c)){
            List<Responsible_Person__c> rpList = rpMap.get(cls.Customer__c);
            if(rpList != null && rpList.size() > 0){
                for(Responsible_Person__c rp : rpList){
                    User user = new User(
                        id = rp.Principal__r.id, Email = rp.Principal__r.Email
                    );
                    resultUserList.add(user);
                }
            }
        }else if(String.isBlank(cls.Customer__c) && String.isNotBlank(cls.Role__c)){
            for (List<Responsible_Person__c> rpList : rpMap.values()) {
                if(rpList != null && rpList.size() > 0){
                    for(Responsible_Person__c rp : rpList){
                        if(cls.Role__c.equals(rp.RecordType__c)){
                            User user = new User(
                                id = rp.Principal__r.id, Email = rp.Principal__r.Email
                            );
                            resultUserList.add(user);
                        }
                    }
                }
            }
        }else if(String.isNotBlank(cls.Customer__c) && String.isNotBlank(cls.Role__c)){
            List<Responsible_Person__c> rpList = rpMap.get(cls.Customer__c);
            if(rpList != null && rpList.size() > 0){
                for(Responsible_Person__c rp : rpList){
                    if(cls.Role__c.equals(rp.RecordType__c)){
                        User user = new User(
                            id = rp.Principal__r.id, Email = rp.Principal__r.Email
                        );
                        resultUserList.add(user);
                    }
                }
            }
        }else {
            resultUserList = userList;
        }

        return resultUserList;
    }
}