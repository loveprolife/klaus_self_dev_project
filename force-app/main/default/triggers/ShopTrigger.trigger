/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-02-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
trigger ShopTrigger on Shop__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	new Triggers()
    // .bind(Triggers.Evt.beforeinsert, new ShopTriggerHandler())
	// .bind(Triggers.Evt.beforeupdate, new ShopTriggerHandler())
	// .bind(Triggers.Evt.afterinsert, new ShopTriggerHandler())
	// .bind(Triggers.Evt.afterupdate, new ShopTriggerHandler())

    //创建门店Key
    .bind(Triggers.Evt.beforeinsert, new ShopCreateExternalKeyHandler())
    .bind(Triggers.Evt.beforeupdate, new ShopCreateExternalKeyHandler())

    //生成地址经纬度
    .bind(Triggers.Evt.afterinsert, new ShopCreateExternalKeyHandler())
    .bind(Triggers.Evt.afterupdate, new ShopCreateExternalKeyHandler())

    //岗位共享IsChanges设置 chenpeng@deloitte.com.cn 20220221 add
    .bind(Triggers.Evt.afterupdate, new PositionShareHandler())
	.manage();
}