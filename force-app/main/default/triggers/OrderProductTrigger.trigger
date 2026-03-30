trigger OrderProductTrigger on Order_Product__c (
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete) {
    new Triggers()

    //岗位共享IsChanges设置
    .bind(Triggers.Evt.afterupdate, new PositionShareHandler())
    .manage();
}