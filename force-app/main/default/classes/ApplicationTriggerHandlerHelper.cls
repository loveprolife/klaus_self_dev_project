/**********************************************************************
* Name: ApplicationTriggerHandlerHelper
* Object: Application__c
* Purpose: ApplicationTriggerHandler
* Author: yong
* Create Date: 2023-06-12
*************************************************************************/
public without sharing class ApplicationTriggerHandlerHelper {
    /*
    * Name: applicationApproved
    * Purpose: after AdditionalCheckInOut application approved ,new Promoter Attendance and Promoter Attendance Information
    * Timing : after update
    * Author: yong
    * Create Date: 2023-06-12
    */
    public static void applicationApproved(List<Application__c> triggerOld,List<Application__c> triggerNew) {
        Map<String,Application__c> oldMap = new Map<String,Application__c>();
        Map<String,Application__c> newMap = new Map<String,Application__c>();
        Map<String,Set<Date>> userIdDateMap = new Map<String,Set<Date>>();
        Map<String,Promoter_Attendance__c> ownerIdDatePAMap = new Map<String,Promoter_Attendance__c>();//Key: ownerid + date  Value: Promoter_Attendance__c
        Map<String,String> ownerIdDatePAIdMap = new Map<String,String>();//Key: ownerId + date   Value: pa.Id
        Map<String,Responsible_Person__c> ownerIdShopIdRPMap = new Map<String,Responsible_Person__c>();
        Set<Date> allDate = new Set<Date>();
        Set<String> shopIdSet = new Set<String>();
        List<Promoter_Attendance__c> toUpsertPAList = new List<Promoter_Attendance__c>();
        List<Promoter_Attendance_Information__c> toInsertPAIList = new List<Promoter_Attendance_Information__c>();

        String AdditionalCheckInOut = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('AdditionalCheckInOut').getRecordTypeId();
        for(Application__c rq:triggerOld){
            oldMap.put(rq.Id,rq);
        }
        for(Application__c rq:triggerNew){
            //Filter records that have just been approved
            if(rq.recordTypeId == AdditionalCheckInOut && rq.Status__c == 'Approved' && oldMap.get(rq.Id).Status__c != 'Approved'){
                newMap.put(rq.Id,rq);
                if(userIdDateMap.get(rq.OwnerId) != null){
                    userIdDateMap.get(rq.OwnerId).add(rq.CheckDate__c);
                }else{
                    Set<Date> checkDateSet = new Set<Date>();
                    checkDateSet.add(rq.CheckDate__c);
                    userIdDateMap.put(rq.OwnerId,checkDateSet);
                }
                allDate.add(rq.CheckDate__c);
            }
        }
        //Query exist Promoter_Attendance__c 
        List<Promoter_Attendance__c> paList = [SELECT Id,Name ,CheckIn_Date__c,OwnerId,SignInTime__c,SignOutTime__c ,
                                                    Shop__c,Is_Refill_Check_In__c,CheckOutShop__c,Is_Refill_Check_Out__c,AddCheckInReason__c
                                                FROM Promoter_Attendance__c 
                                                WHERE OwnerId IN: userIdDateMap.keySet() 
                                                    AND CheckIn_Date__c IN: allDate];
        if(paList.size() > 0){
            for(Promoter_Attendance__c pa : paList){
                //Key: ownerid + date  Value: Promoter_Attendance__c
                ownerIdDatePAMap.put(pa.OwnerId + String.valueof(pa.CheckIn_Date__c) , pa);
            }
        }
        //upsert Promoter_Attendance__c
        String staticApprover1 = System.Label.Indonesia_Trainer_UserName;
        List<User> staticUserList1 = getStaticApprover(staticApprover1);
        List<Promoter_Attendance__Share> apsList = new List<Promoter_Attendance__Share>();
        for(Application__c rq:newMap.values()){
            Promoter_Attendance__c pa = new Promoter_Attendance__c();
            pa.SignInTime__c = null;
            pa.SignOutTime__c = null;
            if(ownerIdDatePAMap.get(rq.OwnerId + String.valueOf(rq.CheckDate__c)) == null){
                //No mapping record exists, new record
                pa = new Promoter_Attendance__c();
                pa.CheckIn_Date__c = rq.CheckDate__c;
                pa.OwnerId = rq.OwnerId;
            }else{
                //Exist mapping Promoter_Attendance__c
                pa = ownerIdDatePAMap.get(rq.OwnerId + String.valueOf(rq.CheckDate__c));
                for(User u:staticUserList1){
                    Promoter_Attendance__Share apps = new Promoter_Attendance__Share();
                    apps.AccessLevel = 'Edit';
                    apps.RowCause = 'Manual';
                    apps.ParentId = pa.Id;
                    apps.UserOrGroupId = u.Id;
                    apsList.add(apps);
                }
                insert apsList;
            }
            //Check in
            if(rq.CheckInStoreName__c != null){
                pa.Shop__c = rq.CheckInStoreName__c;
                pa.Is_Refill_Check_In__c = true;
                pa.SignInTime__c = rq.RefillCheckInTime__c;

                shopIdSet.add(rq.CheckInStoreName__c);
            }
            //Check out
            if(rq.CheckOutStoreName__c != null){
                pa.CheckOutShop__c = rq.CheckOutStoreName__c;
                pa.Is_Refill_Check_Out__c = true;
                pa.SignOutTime__c = rq.RefillCheckOutTime__c;

                shopIdSet.add(rq.CheckOutStoreName__c);
            }
            if(pa.SignInTime__c != null && pa.SignOutTime__c != null){
                pa.CheckInStatus__c = '已签到签退';
            }else if(pa.SignInTime__c == null && pa.SignOutTime__c != null){
                pa.CheckInStatus__c = '已签退';
            }else if(pa.SignInTime__c != null && pa.SignOutTime__c == null){
                pa.CheckInStatus__c = '已签到';
            }
            //Reaseon
            pa.AddCheckInReason__c = rq.Reason__c;

            toUpsertPAList.add(pa);
        }
        //upsert Promoter_Attendance__c
        upsert toUpsertPAList;

        for(Promoter_Attendance__c pa : toUpsertPAList){
            //Key: ownerId + date   Value: pa.Id
            ownerIdDatePAIdMap.put(pa.OwnerId + String.valueof(pa.CheckIn_Date__c) , pa.Id);
        }
        //Promoter_Attendance_Rule__c mapping
        List<Responsible_Person__c> rpList = [SELECT Id,Name ,Principal__c,Promoter_Attendance_Rule__c,Shop_Name__c ,
                                                    Promoter_Attendance_Rule__r.Start_time__c,Promoter_Attendance_Rule__r.End_time__c,Promoter_Attendance_Rule__r.Time_buffer__c
                                                FROM Responsible_Person__c
                                                WHERE Principal__c IN: userIdDateMap.keySet() AND Shop_Name__c IN: shopIdSet];
        //set mapping                                          
        for(Responsible_Person__c rp:rpList){
            //Key: ownerId + shopId  Value: Responsible_Person__c
            if(ownerIdShopIdRPMap.get(String.valueOf(rp.Principal__c) + String.valueOf(rp.Shop_Name__c)) == null){
                ownerIdShopIdRPMap.put(String.valueOf(rp.Principal__c) + String.valueOf(rp.Shop_Name__c) , rp);
            }
            if(ownerIdShopIdRPMap.get(String.valueOf(rp.Principal__c) + String.valueOf(rp.Shop_Name__c)) != null && rp.Promoter_Attendance_Rule__c != null){
                ownerIdShopIdRPMap.put(String.valueOf(rp.Principal__c) + String.valueOf(rp.Shop_Name__c) , rp);
            }
        }
        //new Promoter Attendance Information
        for(Application__c rq:newMap.values()){
            //Check in
            if(rq.CheckInStoreName__c != null){
                Promoter_Attendance_Information__c pai = new Promoter_Attendance_Information__c();
                pai.Promoter_Attendance__c = ownerIdDatePAIdMap.get(rq.OwnerId + String.valueOf(rq.CheckDate__c));
                pai.CheckIn_Date__c = rq.CheckDate__c;
                pai.CheckIn_Time__c = rq.RefillCheckInTime__c;
                pai.Is_Refill__c = true;
                pai.Shop__c = rq.CheckInStoreName__c;
                pai.Type__c = 'Check in';
                pai.Remark__c = rq.Reason__c;
                //match Promoter Attendance Rule
                if(ownerIdShopIdRPMap.get(String.valueOf(rq.OwnerId) + String.valueOf(rq.CheckInStoreName__c))!=null){
                    Responsible_Person__c rp = ownerIdShopIdRPMap.get(String.valueOf(rq.OwnerId) + String.valueOf(rq.CheckInStoreName__c));
                    if(rp.Promoter_Attendance_Rule__c != null){
                        Time startTime = rp.Promoter_Attendance_Rule__r.Start_time__c.addMinutes(Integer.valueOf(rp.Promoter_Attendance_Rule__r.Time_buffer__c));
                        if(rq.RefillCheckInTime__c <= startTime){
                            pai.Status__c = 'Check in';
                        }else{
                            pai.Status__c = 'Late Check in';
                        }
                    }
                }
                toInsertPAIList.add(pai);
            }
            //Check out
            if(rq.CheckOutStoreName__c != null){
                Promoter_Attendance_Information__c pai = new Promoter_Attendance_Information__c();
                pai.Promoter_Attendance__c = ownerIdDatePAIdMap.get(String.valueOf(rq.OwnerId) + String.valueOf(rq.CheckDate__c));
                pai.CheckIn_Date__c = rq.CheckDate__c;
                pai.CheckIn_Time__c = rq.RefillCheckOutTime__c;
                pai.Is_Refill__c = true;
                pai.Shop__c = rq.CheckOutStoreName__c;
                pai.Type__c = 'Check out';
                pai.Remark__c = rq.Reason__c;
                //match Promoter Attendance Rule
                if(ownerIdShopIdRPMap.get(String.valueOf(rq.OwnerId) + String.valueOf(rq.CheckOutStoreName__c))!=null){
                    Responsible_Person__c rp = ownerIdShopIdRPMap.get(String.valueOf(rq.OwnerId) + String.valueOf(rq.CheckOutStoreName__c));
                    if(rp.Promoter_Attendance_Rule__c != null){
                        Time endtime = rp.Promoter_Attendance_Rule__r.End_time__c;
                        if(rq.RefillCheckOutTime__c >= endtime){
                            pai.Status__c = 'Check out';
                        }else{
                            pai.Status__c = 'Early Check out';
                        }
                    }
                }
                toInsertPAIList.add(pai);
            }
        }
        // insert Promoter_Attendance_Information__c
        insert toInsertPAIList;
    }
    /*
    * Name: applicationLimits
    * Purpose: Verify data validity 
    * Timing : before insert
    * Author: yong
    * Create Date: 2023-06-14
    */
    public static void applicationLimits(List<Application__c> triggerOld,List<Application__c> triggerNew){
        String AdditionalCheckInOut = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('AdditionalCheckInOut').getRecordTypeId();
        String Resignation = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Resignation').getRecordTypeId();
        String Leave = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Leave').getRecordTypeId();
        
        // String userId = UserInfo.getUserId();
        // User currentUser = [SELECT Id, Name, ManagerId, Manager.Name FROM  User WHERE Id = :userId];
        // String managerId;
        // if(currentUser.ManagerId != null){
        //     managerId = currentUser.ManagerId;
        // }

        for(Application__c rq:triggerNew){
            //AdditionalCheckInOut recordtype only
            if(rq.recordTypeId == AdditionalCheckInOut){
                if((rq.CheckInStoreName__c != null && rq.RefillCheckInTime__c == null) || (rq.CheckInStoreName__c == null && rq.RefillCheckInTime__c != null)){
                    //check in shop and check in time must exist simultaneously
                    rq.addError(System.label.Application_Of_Check_In_Out_Limits);
                }
                if((rq.CheckOutStoreName__c != null && rq.RefillCheckOutTime__c == null) || (rq.CheckOutStoreName__c == null && rq.RefillCheckOutTime__c != null)){
                    //check in shop and check in time must exist simultaneously
                    rq.addError(System.label.Application_Of_Check_In_Out_Limits2);
                }
                if(rq.CheckInStoreName__c == null && rq.RefillCheckInTime__c == null && rq.CheckOutStoreName__c == null && rq.RefillCheckOutTime__c == null){
                    //Please input check in/out infomation
                    rq.addError(System.label.Application_Of_Check_In_Out_Limits3);
                }
                if(rq.RefillCheckInTime__c != null && rq.RefillCheckOutTime__c != null && rq.RefillCheckInTime__c > rq.RefillCheckOutTime__c){
                    //The start time must be less than the end time 
                    rq.addError(System.label.Application_Of_Time_Rule);
                }
            }
            //Resignation recordtype only
            if(rq.recordTypeId == Resignation){
                // rq.FirstApprover__c = managerId;
            }
            //Leave recordtype only
            if(rq.recordTypeId == Leave){
                if(rq.From__c != null && rq.To__c != null && rq.From__c > rq.To__c){
                    //The start time must be less than the end time 
                    rq.addError(System.label.Application_Of_Time_Rule);
                }
            }
        }
    }
    /*
    * Name: applicationAutoSubmit
    * Purpose: auto submit application after insert
    * Timing : after insert
    * Author: yong
    * Create Date: 2023-06-14
    */
    public static void applicationAutoSubmit(List<Application__c> triggerOld,List<Application__c> triggerNew){
        String AdditionalCheckInOut = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('AdditionalCheckInOut').getRecordTypeId();
        String Leave = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Leave').getRecordTypeId();
        String Resignation = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Resignation').getRecordTypeId();
        String TransferStore = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('TransferStore').getRecordTypeId();
        List<Approval.ProcessSubmitRequest> processList = new List<Approval.ProcessSubmitRequest>();
        List<Application__Share> apsList = new List<Application__Share>();
        String staticApprover1 = System.Label.Indonesia_Trainer_UserName;
        String staticApprover2 = System.Label.Indonesia_Trainer_UserName + ',' 
                                + System.Label.Indonesia_Training_Manager_UserName + ',' 
                                + System.Label.Indonesia_Retail_Director;
        List<User> staticUserList1 = getStaticApprover(staticApprover1);
        List<User> staticUserList2 = getStaticApprover(staticApprover2);
        User currentUser = [SELECT Id,Name,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,UserRole.DeveloperName,UserRole.parentRoleId,Sales_Region__c FROM User WHERE Id =: UserInfo.getUserId()];
        for(Application__c rq:triggerNew){
            //share record to Successor
            if(rq.recordTypeId == AdditionalCheckInOut || rq.recordTypeId == Leave){
                if(currentUser.Sales_Region__c == 'Hisense Indonesia'){
                    for(User u:staticUserList1){
                        Application__Share apps = new Application__Share();
                        apps.AccessLevel = 'Read';
                        apps.RowCause = 'Manual';
                        apps.ParentId = rq.Id;
                        apps.UserOrGroupId = u.Id;
                        apsList.add(apps);
                    }
                }
            }
            if(rq.recordTypeId == Resignation || rq.recordTypeId == TransferStore){
                if(rq.Successor__c != null){
                    Application__Share apps = new Application__Share();
                    apps.AccessLevel = 'Read';
                    apps.RowCause = 'Manual';
                    apps.ParentId = rq.Id;
                    apps.UserOrGroupId = rq.Successor__c;
                    apsList.add(apps);
                }
                if(currentUser.Sales_Region__c == 'Hisense Indonesia'){
                    for(User u:staticUserList2){
                        Application__Share apps = new Application__Share();
                        apps.AccessLevel = 'Read';
                        apps.RowCause = 'Manual';
                        apps.ParentId = rq.Id;
                        apps.UserOrGroupId = u.Id;
                        apsList.add(apps);
                    }
                }
            }
            //submit approval
            System.debug('applicationAutoSubmit----------'+rq.FirstApprover__c);
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            //req.setComments(approvalMap.get(appId));
            req.setObjectId(rq.Id);
            req.setSkipEntryCriteria(true);
            processList.add(req);
        }
        insert apsList;

        // Annotated by Sunny Zeng [2023/9/19] - 自动审批
        // List<Approval.ProcessResult> resultlist = Approval.process(processList);
    } 
    /*
    * Name: applicationAssignApprover
    * Purpose: auto assign approver before insert
    * Timing : before insert before applicationAutoSubmit
    * Author: yong
    * Create Date: 2023-06-15
    */
    public static void applicationAssignApprover(List<Application__c> triggerOld,List<Application__c> triggerNew){
        String AdditionalCheckInOut = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('AdditionalCheckInOut').getRecordTypeId();
        String Leave = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Leave').getRecordTypeId();
        String Resignation = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Resignation').getRecordTypeId();
        String TransferStore = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('TransferStore').getRecordTypeId();
        User currentUser = [SELECT Id,Name,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,UserRole.DeveloperName,UserRoleId,UserRole.parentRoleId FROM User WHERE Id =: UserInfo.getUserId()];
        User currentUserManager = (User)SObjectHelper.first(UserUtility.getManagerByRoleHierarchy(currentUser.UserRoleId));
        List<User> managerUserList = [SELECT Id,name FROM User WHERE UserRoleId =: currentUser.UserRole.parentRoleId AND IsActive = true];
        // List<Group> groupList = [SELECT Id,name,DeveloperName,type FROM group WHERE type = 'Queue' AND DeveloperName = 'Indonesia_Approval_Queue'];
        for(Application__c app : triggerNew){
            
            if(currentUser.UserRoleId != null && currentUser.UserRole.DeveloperName.contains('Indonesia_Retail_Manager')){
                app.FirstApprover__c = null;
            }else {
                // if(currentUser.UserRoleId != null && currentUser.UserRole.DeveloperName.contains('Indonesia_Promoter') ){
                //     if(managerUserList.size()>0){
                //         app.FirstApprover__c = managerUserList[0].Id;
                //     }else{
                //         app.addError(System.label.Application_Limits);//Submitter should assign a manager
                //     }
                // }
                if (app.FirstApprover__c == null && currentUserManager != null) {
                    app.FirstApprover__c = currentUserManager.Id;
                }
                if(currentUser.ManagerId != null && app.FirstApprover__c == null){
                    app.FirstApprover__c = currentUser.ManagerId;
                }

                if (app.FirstApprover__c==null) {
                    app.addError(System.label.Application_Limits);//Submitter should assign a manager
                }
            }
            
        }
    }
    /*
    * Name: applicationApproverStatusChangeNotification
    * Purpose: send notification to owner after status changed
    * Timing : after update 
    * Author: yong
    * Create Date: 2023-06-20
    */
    public static void applicationApproverStatusChangeNotification(List<Application__c> triggerOld,List<Application__c> triggerNew){
        Map<String,Application__c> oldMap = new Map<String,Application__c>();
        Map<String,Application__c> newMap = new Map<String,Application__c>();
        String title = System.label.Application_Of_Check_In_Out_Notification_Title;
        String body;

        // Added by Sunny Zeng [2023/11/19] - 排班计划 start
        String Leave = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Leave').getRecordTypeId();
        // Added by Sunny Zeng [2023/11/19] - 排班计划 end

        for(Application__c rq:triggerOld){
            oldMap.put(rq.Id,rq);
        }
        for(Application__c rq:triggerNew){
            //Filter records that have just been changed
            if( rq.Status__c != oldMap.get(rq.Id).Status__c && (rq.Status__c == 'Approved' || rq.Status__c == 'Rejected')){
                newMap.put(rq.Id,rq);

                // Added by Sunny Zeng [2023/11/19] - 排班计划 start
                if((rq.Status__c == 'Approved') && (rq.recordTypeId == Leave)) {
                    SchedulingPlanController.upsertOnLeave(rq.Id, rq.OwnerId, Date.ValueOf(rq.From__c), Date.ValueOf(rq.To__c));
                }
                // Added by Sunny Zeng [2023/11/19] - 排班计划 end
            }
        }
        List<CustomNotificationType> cntList = [SELECT id,DeveloperName FROM CustomNotificationType WHERE DeveloperName =: 'Custom_Notification'];
        if(cntList.size()>0){
            for(Application__c rq:newMap.values()){
                body = rq.Name+rq.Status__c;
                Set<String> targetIdList = new Set<String>();
                targetIdList.add(rq.ownerId);
                Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
                currNotification.setTitle(title);
                currNotification.setBody(body);
                currNotification.setNotificationTypeId(cntList[0].Id);
                currNotification.setTargetId(rq.Id);

                currNotification.send(targetIdList);

            }
        }
    }

    /*
    * Name: autoAddCommentsAfterReject
    * Purpose: add comments for auto reject approval
    * Timing : before update 
    * Author: yong
    * Create Date: 2023-08-10
    */
    // public static void autoAddCommentsAfterReject(List<Application__c> triggerOld,List<Application__c> triggerNew){
    //     LisqContainer lc = new LisqContainer(triggerNew);
    //     List<Application__c> appList = lc.Where1('Status__c', 'ISCHANGED', triggerOld).Where1('Status__c', '=', 'Rejected').ToSobjectList();
    //     List<String> appIdList = new List<String>();
    //     User currentUser = [SELECT Id,Name,ManagerId,Manager.ManagerId,Manager.Manager.ManagerId,UserRole.DeveloperName,UserRole.parentRoleId FROM User WHERE Id =: UserInfo.getUserId()];
    //     // Map<String,Application__c> idApplicationMap = new Map<String,Application__c>();
    //     for(Application__c app:appList){
    //         appIdList.add(app.Id);
    //         // idApplicationMap.put(app.Id,app);
    //         if(app.FirstApprover__c == null && !currentUser.UserRole.DeveloperName.contains('Indonesia_Retail_Manager')){
    //             app.Comments__c = System.label.Application_Limits;//Submitter should assign a manager
    //         }
    //     }
    // }
    public static List<User> getStaticApprover(String approver){
		List<String> trainerList = approver.split(',');//用，隔开
		if(trainerList.size()>0 && trainerList[0] != ''){
			String sql = 'SELECT Id,Name,UserName FROM User WHERE ( ';
			for(String trainer:trainerList){
				if(sql.contains('=')){
					sql += ' OR ';
				}
				sql += ' UserName = \'';
				sql += trainer + '\' ';
			}
			sql += ') AND IsActive = true ';
			return Database.query(sql);
		}else{
			return null;
		}
	}
}