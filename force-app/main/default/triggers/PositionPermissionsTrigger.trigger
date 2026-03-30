/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-15-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
trigger PositionPermissionsTrigger on Position_Permissions__c (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete
) {
    new Triggers()

    //岗位创建后,生成UserGroup,并写入GroupId至岗位
    .bind(Triggers.Evt.afterinsert, new PositionPermissionsAccShopShareHandler())
    .bind(Triggers.Evt.afterupdate, new PositionPermissionsAccShopShareHandler())
    .bind(Triggers.Evt.afterdelete, new PositionPermissionsAccShopShareHandler())
    .manage();
}