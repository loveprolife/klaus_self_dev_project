/**************************************************************************************************
 * Name: ExhibitionSSOVerifyController
 * Object: Internal_Registration__c
 * Purpose: 通过SSO接口验证员工信息
 * ************************************************************************************************
 * History
 * --------
 * VERSION     AUTHOR              DATE            DETAIL             Description
 * 1.0          Ethan             2023-08-23         Created        
 
***************************************************************************************************/
public with sharing class ExhibitionSSOVerifyController {
    // private final static String  PARAMS_PREFIX = 'uid=';
    //单一验证
    @AuraEnabled
    public static ResData verifyInternalRegistration(String recordId) {
        ResData resData = new ResData();
        try{
            Internal_Registration__c intReg = [SELECT Id,Is_Verify__c,XHNumber__c,Department_Name__c,Department_Code__c,Is_Present__c,Last_Verified_Date__c,
             Name_CN__c, Position__c, Email__c, Phone__c
            FROM Internal_Registration__c WHERE Id=:recordId];
            if (!intReg.Is_Present__c) {
                resData.msg = '该参展员工未确认出席展会！';
                return resData;
            }
            // if (intReg.Is_Verify__c) {
            //  resData.msg = '此记录已通过SSO验证！';
            //  return resData;
            // }
            if (String.isBlank(intReg.XHNumber__c)) {
                resData.msg = '未填写信鸿号！';
                return resData;
            }
            ExhibitionSSOVerifyPanGu.VerifyData verifyData = ExhibitionSSOVerifyPanGu.verifyInternalRegistration(intReg.XHNumber__c);
            if (verifyData.code == 0) {//成功
                if (verifyData.data.size() > 0) {
                    if (verifyData.data[0].ou != NULL) intReg.Department_Name__c = verifyData.data[0].ou;//部门
                    //intReg.Department_Code__c = verifyData.data[0].departmentNumber;//部门号
                    if (verifyData.data[0].cn != NULL) intReg.Name_CN__c = verifyData.data[0].cn;//姓名
                    if (verifyData.data[0].title != NULL) intReg.Position__c = verifyData.data[0].title;//岗位
                    if (verifyData.data[0].mail != NULL) intReg.Email__c = verifyData.data[0].mail;//邮箱
                    if (verifyData.data[0].mobile != NULL) intReg.Phone__c = verifyData.data[0].mobile;//电话
                    if (verifyData.data[0].o != NULL) intReg.Company_Abbr__c = verifyData.data[0].o;//公司
                    intReg.Is_Verify__c = true;
                    intReg.Last_Verified_Date__c = System.now();
                    intReg.Verify_Result__c = '接口调用成功,验证通过,成功获取Ldap账号信息';

                    UPDATE intReg;
                    resData.isSuccess = true;
                    return resData;
                }
                intReg.Is_Verify__c = false;
                intReg.Last_Verified_Date__c = System.now();
                intReg.Verify_Result__c = '接口调用成功,验证失败,未匹配到LDAP校验接口相同的信鸿号所在的Ldap账号信息';
                resData.msg = '此记录信鸿号与LDAP匹配失败，查询为空！';
                UPDATE intReg;
                return resData;

            }
            intReg.Is_Verify__c = false;
            intReg.Last_Verified_Date__c = System.now();
            intReg.Verify_Result__c = 'LDAP校验接口调用失败，错误信息：'+verifyData.message;
            resData.msg = 'SSO：'+verifyData.message;
            UPDATE intReg;
            return resData;


        }
        catch(Exception e) {
            System.debug('error--->'+e.getLineNumber()+e.getMessage());
            resData.msg = 'SF系统异常，请联系管理员：'+e.getLineNumber()+e.getMessage();
            return resData; 

        }
    }

    //批量验证
    @AuraEnabled
    public static ResData verifyInternalRegistrations(String recordId) { 
        ResData resData = new ResData();
        Savepoint sp;
        try {
            String countSoql = 'SELECT COUNT() FROM Internal_Registration__c '+
                'WHERE Exhibition_Id__c=: recordId  AND XHNumber__c <> NULL AND Exhibition_Id__r.LastRegistrationDate__c >= TODAY AND Is_Present__c = TRUE';
            if (Database.countQuery(countSoql) == 0) {
                 resData.msg = '此展会下无需进行LDAP校验！';
                return resData;
            }
            //展会下给出正在批量验证状态
            ExpoInfo__c eInfo = [SELECT Id, Is_Verify_Batch__c FROM ExpoInfo__c WHERE Id=:recordId];
            if (eInfo.Is_Verify_Batch__c) {
                resData.msg = 'LDAP校验批量正在进行中！';
                return resData;
            }
            eInfo.Is_Verify_Batch__c = TRUE;
            UPDATE eInfo;
            //将展会下的所有满足条件的参展员工刷成正在批量验证状态
            List<Internal_Registration__c> updateIntRegList = new List<Internal_Registration__c>();
            for (Internal_Registration__c item: [SELECT Id, Is_Verify_Batch__c FROM Internal_Registration__c
                WHERE Exhibition_Id__c=: recordId  AND XHNumber__c <> NULL AND Exhibition_Id__r.LastRegistrationDate__c >= TODAY AND Is_Present__c = TRUE ]) {
                item.Is_Verify_Batch__c = TRUE;
                updateIntRegList.add(item);
            }
            System.debug('updateIntReg Size--'+updateIntRegList.size());
            if (updateIntRegList.size() > 0) UPDATE updateIntRegList;


            ExhibitionSSOVerifyBatch bt = new ExhibitionSSOVerifyBatch((Id)recordId);
            // bt.execute();
            Database.executeBatch(bt,10);

            resData.isSuccess = true;

        }catch (Exception e) {
            Database.rollback(sp); 
            System.debug('error--->'+e.getLineNumber()+e.getMessage());
            resData.msg = 'SF系统异常，请联系管理员：'+e.getLineNumber()+e.getMessage();
        }
        return resData;
    }

    //查询是否还剩批量验证
    @AuraEnabled
    public static ResData IsExistVerify(String recordId) {
        ResData resData = new ResData();
        try {
            String countSoql = 'SELECT COUNT() FROM Internal_Registration__c '+
                'WHERE Exhibition_Id__c=: recordId  AND XHNumber__c <> NULL AND Exhibition_Id__r.LastRegistrationDate__c >= TODAY AND Is_Present__c = TRUE AND Is_Verify_Batch__c = TRUE';
            Integer countSum = Database.countQuery(countSoql);
            System.debug('countSoql-->'+countSoql);

            resData.isSuccess = TRUE;
            if (countSum == 0) {
                resData.msg = '已完成LDAP批量校验！';
            }else {
                resData.code = countSum;
                resData.msg = '未完成LDAP批量校验！';
            }
        }
        catch (Exception e) {
            System.debug('IsExistVerify Error-->'+e.getLineNumber()+e.getMessage());
            resData.msg = 'SF系统异常，请联系管理员：'+e.getLineNumber()+e.getMessage();
        }
        return resData;
        
        
    }

    // @AuraEnabled
    // public static ResData getCompanyAbbr(String recordId) {
    //     return getInternalRegistrationFieldList(recordId, '', 'Company_Abbr__c');
    // }

    //获取展会下内部员工的所有部门
    @AuraEnabled
    public static ResData getDepartment(String recordId) {
        return getInternalRegistrationFieldList(recordId, null, 'Department_Name__c');
    }

    //20241203 TJP 获取展会下内部员工的所有大区
    @AuraEnabled
    public static ResData getCompany(String recordId) {
        return getInternalRegistrationFieldList(recordId, null, 'Company__c');
    }

    //20241203 TJP 获取 当前大区下的部门 List集合
    @AuraEnabled
    public static ResData getCompanyAbbr(String recordId,String company) {

        return getInternalRegistrationFieldList(recordId, company,'Company_Abbr__c');
    }


    //获取展会下内部员工的某个字段
    public static ResData getInternalRegistrationFieldList(String recordId, String argument, String fieldName) {
        ResData resData = new ResData();
        try {
            List<ApproverData> approverDataList = new List<ApproverData>();

            String querySoql = 'SELECT Id, ' + fieldName + ' FROM Internal_Registration__c WHERE Exhibition_Id__r.LastRegistrationDate__c >= TODAY AND Is_Present__c = TRUE '
                             + 'AND Is_Verify_Batch__c = FALSE AND Exhibition_Id__r.Is_Verify_Batch__c = FALSE AND Department_Name__c<>NULL '
                             + 'AND (Approval_Status__c = \'未审批\' OR Approval_Status__c = \'部门审批驳回\') ';
            if (recordId != NULL) {
                querySoql += ' AND Exhibition_Id__c=: recordId';
            }
            if (String.isNotBlank(argument)) {
                querySoql += ' AND Company__c=: argument';
            }

            // List<Internal_Registration__c> intRegList = [SELECT Id, Department_Name__c FROM Internal_Registration__c 
            //     WHERE Exhibition_Id__c=: recordId AND Exhibition_Id__r.LastRegistrationDate__c >= TODAY AND Is_Present__c = TRUE 
            //     AND Is_Verify_Batch__c = FALSE AND Exhibition_Id__r.Is_Verify_Batch__c = FALSE AND Department_Name__c<>NULL 
            //     AND (Approval_Status__c = '未审批' OR Approval_Status__c = '部门审批驳回')];
            List<Internal_Registration__c> intRegList = Database.query(querySoql);
            approverDataList.add(new ApproverData('',''));
            if (intRegList.size() > 0) {
                Set<String> approverDepartmentSet = new Set<String>(new LisqContainer(intRegList).SelectSField(fieldName));
                for (String item: approverDepartmentSet) {
                    approverDataList.add(new ApproverData(item, item));
                }
            }
            resData.isSuccess = TRUE;
            resData.msg = JSON.serialize(approverDataList);
        }
        catch (Exception e) {
            System.debug('ExhibitionSSOVerifyController.getDepartment'+e.getLineNumber()+e.getMessage());
            resData.msg = 'SF系统异常，请联系管理员： 行-'+e.getLineNumber()+',原因 '+e.getMessage();
        }
        return resData;
        
        

    }

    //获取OA二级审批人
    @AuraEnabled
    public static ResData getSecondApprover(String type) {
        ResData resData = new ResData();
        try {
            List<ApproverData> approverDataList = new List<ApproverData>();
            List<Exhibition_OA_Second_Approver__c> approverList = [SELECT Id, Name,XHNumber__c,Region__c FROM Exhibition_OA_Second_Approver__c WHERE Type__c =:type ];

            
            approverDataList.add(new ApproverData('','',''));

            if (approverList.size() > 0) {
                for (Exhibition_OA_Second_Approver__c item: approverList) {
                    approverDataList.add(new ApproverData(item.Name, item.XHNumber__c,item.Region__c));
                }
            }
            resData.isSuccess = TRUE;
            resData.msg = JSON.serialize(approverDataList);
        }
        catch (Exception e) {
            System.debug('ExhibitionSSOVerifyController.getDepartment'+e.getLineNumber()+e.getMessage());
            resData.msg = 'SF系统异常，请联系管理员： 行-'+e.getLineNumber()+',原因 '+e.getMessage();
        }
        return resData;
    }

    @AuraEnabled
    public static ResData getOAapprover(String type) {
        ResData resData = new ResData();
        try {
            // List<ApproverData> approverDataList = new List<ApproverData>();
            List<Exhibition_OA_Second_Approver__c> approverList = [SELECT Id, Name,XHNumber__c,Region__c FROM Exhibition_OA_Second_Approver__c WHERE Type__c =:type ];

            
            // approverDataList.add(new ApproverData('','',''));

            // if (approverList.size() > 0) {
            //     for (Exhibition_OA_Second_Approver__c item: approverList) {
            //         approverDataList.add(new ApproverData(item.Name, item.XHNumber__c,item.Region__c));
            //     }
            // }
            resData.isSuccess = TRUE;
            resData.msg = JSON.serialize(approverList);
        }
        catch (Exception e) {
            System.debug('ExhibitionSSOVerifyController.getDepartment'+e.getLineNumber()+e.getMessage());
            resData.msg = 'SF系统异常，请联系管理员： 行-'+e.getLineNumber()+',原因 '+e.getMessage();
        }
        return resData;
    }

    //获取全部内部员工的所有展会
    @AuraEnabled
    public static ResData getExhibition(){
        ResData resData = new ResData();
        try {
            Set<Id> expoIdSet = new Set<Id>();
            List<ApproverData> approverDataList = new List<ApproverData>();
            Map<Id, ExpoInfo__c> expoInfoMap = new Map<Id, ExpoInfo__c>([SELECT Id, Name, TitleEN__c FROM ExpoInfo__c]);

            String querySoql = 'SELECT COUNT(Id) countId, Exhibition_Id__c exInfo FROM Internal_Registration__c WHERE Exhibition_Id__r.LastRegistrationDate__c >= TODAY AND Is_Present__c = TRUE '
                             + 'AND Is_Verify_Batch__c = FALSE AND Exhibition_Id__r.Is_Verify_Batch__c = FALSE AND Department_Name__c<>NULL '
                             + 'AND (Approval_Status__c = \'未审批\' OR Approval_Status__c = \'部门审批驳回\' OR (Approval_Status__c = \'部门审批通过\' AND Approval_Cycle__c = 1)) GROUP BY Exhibition_Id__c';
            for (AggregateResult agg: Database.query(querySoql)) {
                expoIdSet.add((Id)agg.get('exInfo'));
            }

            approverDataList.add(new ApproverData('',''));

            for (Id expoId : expoIdSet) {
                approverDataList.add(new ApproverData(expoInfoMap.get(expoId).Name + ' '+ expoInfoMap.get(expoId).TitleEN__c, (String)expoId));
            }
            System.debug('ExpoInfo======'+approverDataList);
            resData.isSuccess = TRUE;
            resData.msg = JSON.serialize(approverDataList);
        }
        catch (Exception e) {
            System.debug('ExhibitionSSOVerifyController.getDepartment'+e.getLineNumber()+e.getMessage());
            resData.msg = 'SF系统异常，请联系管理员： 行-'+e.getLineNumber()+',原因 '+e.getMessage();
        }
        return resData;
    }











    public class ResData{
        @AuraEnabled 
        public Boolean isSuccess;
        @AuraEnabled 
        public Integer code;
        @AuraEnabled 
        public String msg;

        public ResData(){
            isSuccess = false;
            msg = '未匹配到信鸿号！';
            code = 0;
        }
    }

    public class ApproverData{
        @AuraEnabled 
        public String label;
        @AuraEnabled 
        public String value;
        @AuraEnabled 
        public String region;

        public ApproverData() {

        }
        public ApproverData(String label, String value){
            this.label = label;
            this.value = value;
        }
        public ApproverData(String label, String value, String region){
            this.label = label;
            this.value = value;
            this.region = region;
        }
    }

}