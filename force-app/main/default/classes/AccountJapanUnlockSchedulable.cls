global class AccountJapanUnlockSchedulable implements Schedulable {

   public List<Id> accIdList;
   public String schedulable_name;
   // true：锁定 false：解锁
   public Boolean flag;

   global AccountJapanUnlockSchedulable (List<Id> accIdList, String schedulable_name, Boolean flag){
      this.accIdList = accIdList;
      this.schedulable_name = schedulable_name;
      this.flag = flag;
   }

   global void execute(SchedulableContext SC) {

      // 删除定时任务
      AccountSchedulable.deleteSchedulable(schedulable_name);
      if(flag){
         for(Id accId : accIdList){
            Approval.LockResult ur = Approval.lock(accId);
         }
      }else {
         for(Id accId : accIdList){
            Approval.UnlockResult ur = Approval.unlock(accId);
         }
      }
      Utility.insertLog('AccountJapanUnlockSchedulable', '1', accIdList.toString(), flag + '-----' + schedulable_name);
   }

}