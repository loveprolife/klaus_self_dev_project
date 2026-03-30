public class TicketTriggerHandler extends BaseTriggerHandler {
	
    protected override String getClassName() {
        return super.getClassName();
    }

    // public override void beforeInsert(){
    //     // 校验 Assigned To 部门信息
    //     List<Ticket__c> newTicketList = (List<Ticket__c>) new LisqContainer(this.newList).WhereAnd(new object[]{
    //         'Department__c', 'NOTBLANK', '',
    //         'AssignedTo__c', 'NOTBLANK', ''           
    //     }).ToSobjectList();
    //     if(newTicketList.size() > 0) {
    //        TicketTriggerHandlerHelper.beforeInsertCheck(this.oldList, newTicketList); 
    //     }
    // }

    // public override void beforeUpdate(){
    //     // 校验 Assigned To 部门信息
    //     List<Ticket__c> newTicketList = (List<Ticket__c>) new LisqContainer(this.newList).WhereAnd(new object[]{
    //         'Department__c', 'NOTBLANK', '',
    //         'AssignedTo__c', 'NOTBLANK', ''           
    //     }).ToSobjectList();
    //     if(newTicketList.size() > 0) {
    //        TicketTriggerHandlerHelper.beforeInsertCheck(this.oldList, newTicketList); 
    //     }
    // }

    // public override void beforeUpdate(){
    //     // 校验 Assigned To 部门信息
    //     List<Ticket__c> newTicketList = (List<Ticket__c>) new LisqContainer(this.newList).WhereAnd(new object[]{
    //         'Department__c', 'NOTBLANK', '',
    //         'AssignedTo__c', 'NOTBLANK', ''           
    //     }).ToSobjectList();
    //     if(newTicketList.size() > 0) {
    //        TicketTriggerHandlerHelper.beforeInsertCheck(this.oldList, newTicketList); 
    //     }
    // }


    // lastBy TJP 2025-07-03 d:没有关联日报的仅允许编辑 指派人以及Status
    public override void beforeUpdate(){
        TicketTriggerHandlerHelper.beforeHandle(this.oldList, this.newList);            
    }

    public override void afterInsert(){
        // 发送通知给Assign To的人员.并给其增加查看权限

        // 新增多人员逻辑 根据Assign To 和 Aassigners 区分
        Ticket__c ticket = (Ticket__c)this.newList.get(0);
        if(!String.isEmpty(ticket.Aassigners__c)){
            TicketTriggerHandlerHelper.afterInsertUserManyHandler(this.oldList, this.newList);
        }else{
            TicketTriggerHandlerHelper.afterInsertHandler(this.oldList, this.newList);
        }
        
    }
    
    public override void afterUpdate(){
        // 1. 状态更新为Resolved发通知
        // 2. Assign To发生更改，数据权限更改
        
        // 新增多人员逻辑 根据Assign To 和 Aassigners 区分
        Ticket__c ticket = (Ticket__c)this.newList.get(0);
        if(!String.isEmpty(ticket.Aassigners__c)){
            TicketTriggerHandlerHelper.afterUpdateUserManyHandler(this.oldList, this.newList);
        }else{
            TicketTriggerHandlerHelper.afterUpdateHandler(this.oldList, this.newList);
        }
    }

    public override void afterDelete(){
        // 删掉记录，拿掉共享的权限
        TicketTriggerHandlerHelper.deleteShred(this.oldList, this.newList);
    }

    
    
}