public class CheckListScopeTriggerHandler extends BaseTriggerHandler {

    public override String getClassName() {
        return super.getClassName();
    }
    
    public override void beforeInsert(){
        CheckListScopeTriggerHandlerHelper.updateCheckItem(this.newList);
        CheckListScopeTriggerHandlerHelper.updateCheckItemIdInfo(this.oldList, this.newList);
    }
    
    public override void beforeUpdate(){
        CheckListScopeTriggerHandlerHelper.updateCheckItem(this.newList);
        CheckListScopeTriggerHandlerHelper.updateCheckItemIdInfo(this.oldList, this.newList);
    }

    public override void afterInsert(){

        List<User> userList = [select id,Email,UserRole.Name from user where Sales_Region__c = 'Hisense South Africa' and IsActive = true 
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
        List<CheckItem__c> ci = [select id, Name, Description__c from CheckItem__c where Sales_Region__c = 'Hisense South Africa'];
        Map<Id, CheckItem__c> ciMap = new Map<Id, CheckItem__c>(ci);
        
        
        for (CheckListScope__c item : ((list<CheckListScope__c>)this.newList)) {
            List<User> sendUserList = new List<User>();
            if('Hisense South Africa'.equals(item.Sales_Region__c)){  
                sendUserList.addAll(getSendUser(item, rpMap, userList));
                System.debug('sendUserList'+sendUserList);
                sendNotAndMail(sendUserList, ciMap.get(item.CheckItem__c), 'Add');
            }
        }
    }

    public override void afterDelete(){

        List<User> userList = [select id,Email from user where Sales_Region__c = 'Hisense South Africa' and IsActive = true];
        List<Responsible_Person__c> rpList = [select Principal__r.id, Principal__r.Email, Principal__r.UserRole.Name, Shop_Name__r.Account__r.id  from Responsible_Person__c where Shop_Name__r.Sales_Region__c = 'Hisense South Africa' and Principal__r.IsActive = true];
        Map<String, List<Responsible_Person__c>> rpMap = new Map<String, List<Responsible_Person__c>>();
        for(Responsible_Person__c rp : rpList){
            if(rpMap.containsKey(rp.Shop_Name__r.Account__r.id)){
                rpMap.get(rp.Shop_Name__r.Account__r.id).add(rp);
            }else{
                List<Responsible_Person__c> rpMapList = new List<Responsible_Person__c>();
                rpMapList.add(rp);
                rpMap.put(rp.Shop_Name__r.Account__r.id, rpMapList);
            }
        }
        
        List<CheckItem__c> ci = [select id, Name, Description__c from CheckItem__c where Sales_Region__c = 'Hisense South Africa'];
        Map<Id, CheckItem__c> ciMap = new Map<Id, CheckItem__c>(ci);

        
        for (CheckListScope__c item : ((list<CheckListScope__c>)this.oldList)) {
            List<User> sendUserList = new List<User>();
            if('Hisense South Africa'.equals(item.Sales_Region__c)){  
                sendUserList.addAll(getSendUser(item, rpMap, userList));
                System.debug('sendUserList'+sendUserList);
                sendNotAndMail(sendUserList, ciMap.get(item.CheckItem__c), 'Delete');
            }
        }
    }

    public override void afterUpdate(){

        Map<Id, CheckListScope__c> oldMap = new Map<Id, CheckListScope__c>();
        if(this.oldList != null) {
            oldMap = new Map<Id, CheckListScope__c>((list<CheckListScope__c>)this.oldList);
        }

        List<User> userList = [select id,Email,UserRole.Name from user where Sales_Region__c = 'Hisense South Africa' and IsActive = true];
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
        
        List<CheckItem__c> ci = [select id, Name, Description__c from CheckItem__c where Sales_Region__c = 'Hisense South Africa'];
        Map<Id, CheckItem__c> ciMap = new Map<Id, CheckItem__c>(ci);

        
        for (CheckListScope__c item : ((list<CheckListScope__c>)this.newList)) {

            List<User> sendUserListOld = new List<User>();
            List<User> sendUserListNew = new List<User>();
            

            if('Hisense South Africa'.equals(item.Sales_Region__c)){  
                sendUserListNew.addAll(getSendUser(item, rpMap, userList));
                CheckListScope__c oldItem = oldMap.get(item.Id);
                sendUserListOld.addAll(getSendUser(oldItem, rpMap, userList));
                
                sendNotAndMail(updateUser(sendUserListNew, sendUserListOld), ciMap.get(item.CheckItem__c), 'Add');
                sendNotAndMail(updateUser(sendUserListOld, sendUserListNew), ciMap.get(item.CheckItem__c), 'Delete');
                
            }
        }
        
    }

    public static List<User> updateUser(List<User> A, List<User> B){
        if(A == null || A.size() == 0){
            return B;
        }else if(B == null || B.size() == 0){
            return A;
        }
        // 找出不同的元素
        boolean flg = true;
        List<User> C = new List<User>();

        for(User u : A){
            flg = true;
            for(User ub : B){
                if(!u.id.equals(ub.id)){
                    continue;
                }
                flg = false;
            }
            if(flg){
                C.add(u);
            }
            flg = true;
        }

        return C;
    }

    public static void sendNotAndMail(List<User> sendUserList, CheckItem__c newData, String action){

        List<UserLogin> UserLoginList = [select UserId, IsFrozen from UserLogin];
        Map<String, Boolean> UserLoginMap = new Map<String, Boolean>();
        for(UserLogin u : UserLoginList){
            UserLoginMap.put(u.UserId, u.IsFrozen);
        }

        Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
        String title = '';
        String body = '';
        if('Add'.equals(action)){
            title = 'SS has been added'.replace('SS', newData.Name);
            body = 'Add XX in the Check List'.replace('XX', '"' + newData.Description__c + '"');
            currNotification.setTargetId(newData.Id);
        }

        if('Delete'.equals(action)){
            title = 'SS has been deleted'.replace('SS', newData.Name);
            body = 'Delete XX in the Check List'.replace('XX', '"' + newData.Description__c + '"');
            currNotification.setTargetId(newData.Id);
        }

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
            
            currNotification.setTitle(title);
            currNotification.setBody(body);
            currNotification.setNotificationTypeId(cntList[0].Id);
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