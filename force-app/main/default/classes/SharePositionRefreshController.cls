/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-23-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public withOut sharing class SharePositionRefreshController {

    @AuraEnabled
    public static WrapperInnerClass checkPosition(String recordId) {
        WrapperInnerClass wic = new WrapperInnerClass ();

        Position__c pos = Share_Common_IntegrationFunction.getPositionObject(recordId);
        if (pos.Position_Permissions__r.isEmpty()) {
            wic.msg = '请先维护岗位权限,再进行此操作';
            wic.isError = true;
            return wic;
        }

        if (pos.Is_Job__c) {
            wic.msg = '该岗位正在计算共享中, 请等待邮件通知/联系系统管理员协助处理';
            wic.isError = true;
            return wic;
        }

        return wic;
    }

    @AuraEnabled
    public static WrapperInnerClass runRefreshJob(String recordId) {
        WrapperInnerClass wic = new WrapperInnerClass ();

        //邮件通知当前操作人
        // String currentUserId = UserInfo.getUserId();

        try {

            // 获取共享对象_ShareAPI
            List<String> shareObjectList = new List<String>();
            for (Share_Object__c sobj : [SELECT Object_Share__c FROM Share_Object__c WHERE IsActive__c = true AND Object_Share__c  != 'Customer_Visit__Share']) {
                shareObjectList.add(sobj.Object_Share__c);
            }

            //获取岗位后台用户小组Id;
            Position__c posObj = [SELECT GroupId__c FROM Position__c WHERE Id = :recordId][0];

            //调用 ShareInsertShareHistoryBatch将之前的共享数据更新为false
            ShareInsertShareHistoryBatch theBatch = new ShareInsertShareHistoryBatch(
                recordId,
                posObj.GroupId__c, 
                shareObjectList,
                false
            );
            Id jobId =Database.executeBatch(theBatch, 8000);
            if (String.isNotBlank(jobId)) {

                //更新Is_Job
                Position__c pos = new Position__c(Id = recordId, Is_Job__c = true);
                UPDATE pos;
                wic.msg = '岗位数据正在处理中,请耐心等待并注意查收结果邮件';
            }
        } catch (Exception e) {
            wic.isError = true;
            wic.msg = e.getMessage();
        }

        return wic;
    }

    public class WrapperInnerClass {
        @AuraEnabled public Boolean isError;
        @AuraEnabled public String msg;
        public WrapperInnerClass(){
            this.isError = false;
            this.msg = '';
        }
    }
}