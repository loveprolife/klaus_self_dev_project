global class SyncReminderToPortalScheduable implements Schedulable{
    global void execute(SchedulableContext ctx) {
        //获取当前时间 -5min
        Datetime dtQuery = Datetime.now().addMinutes(-5);
        //创建待办
        List<ProcessInstance> piList = new list<ProcessInstance>();
        For(ProcessInstance pi : [SELECT Id,(SELECT Id,TargetObjectId,ProcessNode.name,CreatedById,StepStatus,Actor.Name,Actor.Id,CreatedDate,createdBy.name FROM StepsAndWorkitems where CreatedDate>:dtQuery and StepStatus = 'Pending') FROM ProcessInstance where status ='Pending']){
            if(pi.StepsAndWorkitems.size() >0){
                piList.add(pi);
            }
        }
        List<ProcessInstanceHistory> pihs = new List<ProcessInstanceHistory>();
        for(ProcessInstance pi: piList) {
            pihs.addAll(pi.StepsAndWorkitems);
        }
        //调用创建待办
        SyncReminderToPortal.TaskList taskList = SyncReminderToPortal.createReminderList(pihs,'ADD');
        if(taskList.FieldList.size() > 0){
            String jsonPost = json.serialize(taskList);
            System.debug(jsonPost);
            SyncReminderToPortal.sendReminder(jsonPost);
        }

        //删除待办
        List<ProcessInstance> piListDone = new list<ProcessInstance>();
        For(ProcessInstance pi : [SELECT Id,(SELECT Id,TargetObjectId,ProcessNode.name,CreatedById,StepStatus,Actor.Name,Actor.Id,CreatedDate,createdBy.name FROM StepsAndWorkitems where CreatedDate>:dtQuery  and (StepStatus = 'Approved' or StepStatus = 'Rejected'))  FROM ProcessInstance where CompletedDate > :dtQuery OR CompletedDate  = null]){
            if(pi.StepsAndWorkitems.size() >0){
                piListDone.add(pi);
            }
        }
        List<ProcessInstanceHistory> pihsDone = new List<ProcessInstanceHistory>();
        for(ProcessInstance pi: piListDone) {
            pihsDone.addAll(pi.StepsAndWorkitems);
        }
        //调用创建已办，删除待办
        SyncReminderToPortal.TaskList taskListDone = SyncReminderToPortal.createReminderList(pihsDone,'DEL');
        if(taskListDone.FieldList.size() > 0){
            String jsonPost = json.serialize(taskListDone);
            System.debug(jsonPost);
            SyncReminderToPortal.sendReminder(jsonPost);
            SyncReminderToPortal.sendReminderDone(jsonPost);
        }

    }

}