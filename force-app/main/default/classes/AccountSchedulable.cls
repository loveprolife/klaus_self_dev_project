global class AccountSchedulable implements Schedulable {

   public String accId;
   public String claId;
   public String schedulable_name;
   
   global AccountSchedulable (String accId, String schedulable_name){
      this.accId = accId;
      this.schedulable_name = schedulable_name;
   }
   global AccountSchedulable (String accId, String claId, String schedulable_name){
      this.accId = accId;
      this.claId = claId;
      this.schedulable_name = schedulable_name;
   }

   global void execute(SchedulableContext SC) {

      // 删除定时任务
      deleteSchedulable(schedulable_name);

      // 给无法审批赋权限
      try {

         // 获取流程
         List<ProcessInstance> instanceList = [ SELECT Id, (SELECT Id, ActorId,ProcessInstanceId FROM Workitems) FROM ProcessInstance where TargetObjectId  =: accId];

         // 获取审批人id
         for(ProcessInstance instance : instanceList){
               List<ProcessInstanceWorkitem> instanceWorkitemList = instance.Workitems;
               for(ProcessInstanceWorkitem instanceWorkitem: instanceWorkitemList){
                  if(instanceWorkitem.ActorId == null){
                  }else {
                     // 查询审批人是否有权限
                     List<UserRecordAccess> accessList = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess FROM UserRecordAccess WHERE UserId=: instanceWorkitem.ActorId AND RecordId =: accId];
                     for(UserRecordAccess access : accessList){
                        if(!access.HasEditAccess){
                           // AccountShare
                           AccountShare accountShare = new AccountShare();
                           accountShare.RowCause = 'Manual';
                           accountShare.AccountId = claId == null ? accId : claId;
                           accountShare.UserOrGroupId  = instanceWorkitem.ActorId;
                           accountShare.AccountAccessLevel = 'Edit';
                           accountShare.OpportunityAccessLevel = 'Edit';
                           // 删除之前的添加的权限
                           // List<AccountShare> accountShareList = [SELECT id FROM Accountshare where AccountId =: accId and RowCause = 'Manual'];
                           // delete accountShareList;

                           insert accountShare;
                        }
                     }
                    
                  }
               }
         }     
      } catch (Exception e) {
         system.debug('error message'+e.getMessage());
         system.debug('line number'+e.getLineNumber());
      }


   }

   

   public static void deleteSchedulable(String name) {
      // 删除定时任务
      List<CronTrigger> cronTriggers = [select Id from CronTrigger where CronJobDetail.Name = :name and CronJobDetail.JobType = '7'];
      if(cronTriggers.size() > 0){
         for(cronTrigger cronTrigger : cronTriggers){
            System.abortJob(cronTrigger.id);
         }
      }
   }

}