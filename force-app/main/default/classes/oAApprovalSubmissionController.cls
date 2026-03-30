public without sharing class oAApprovalSubmissionController {
    @AuraEnabled
    public static ConResponse saveOAApp(String id,String oneApp,String twoApp,String opinion,List<Object> ids) {
        System.debug('Id--=='+id);
        System.debug('oneApp--=='+oneApp);
        System.debug('twoApp--=='+twoApp);
        System.debug('opinion--=='+opinion);
        ConResponse resp = new ConResponse();
        try {
            String res = SyncExhibitionPersonnelToOA.postCustomerInfomationToOA(id,oneApp,twoApp,opinion,ids);
            if (res!='SUCCESS') {
                resp.code = -1;
                resp.message = res;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        
        return resp;
    }

    @AuraEnabled
    public static ConResponse saveOAAppExecutive(String id,String oneApp,String twoApp) {
        System.debug('Id--=='+id);
        System.debug('oneApp--=='+oneApp);
        System.debug('twoApp--=='+twoApp);
        ConResponse resp = new ConResponse();
        try {
            String res = SyncExhibitionPersonnelToOA.postCustomerInfomationToOAExecutive(id,oneApp,twoApp);
            if (res!='SUCCESS') {
                resp.code = -1;
                resp.message = res;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        
        return resp;
    }

    @TestVisible
    private static ConResponse selIntList(String deap,String exhId) {
        return selIntList(deap, exhId, null);
    }

    @AuraEnabled
    public static ConResponse selIntList(String deap,String exhId, String companyAbbr) {
        ConResponse resp = new ConResponse();
        try {
            System.debug('XXX3' + deap + ':' + exhId);
            // String querySoql = 'SELECT Id, Name_CN__c, Email__c,Exhibition_Id__c,Department_Name__c,Phone__c FROM Internal_Registration__c WHERE '
            //                  + '(Approval_Status__c = \'未审批\' OR Approval_Status__c = \'部门审批驳回\') AND Department_Name__c =: deap ';
            // if (exhId != NULL) {
            //     querySoql += 'AND Exhibition_Id__c =: exhId';
            // }
            // List<Internal_Registration__c> intList = Database.query(querySoql);
            // List<Internal_Registration__c> intList = [SELECT Id, Name_CN__c, Email__c,
            //                                 Exhibition_Id__c,Department_Name__c,Phone__c    
            //                                 FROM Internal_Registration__c
            //                                 WHERE Exhibition_Id__c =: exhId 
            //                                 AND (Approval_Status__c = '未审批' OR Approval_Status__c = '部门审批驳回')
            //                                 AND Department_Name__c =: deap];
            // #展会优化 增加companyAbbr条件 add by DTT-Bright 20240803 START
            List<Internal_Registration__c> intList = Database.query(String.join(new String[] {
                'SELECT',
                '   Name_CN__c,',
                '   Email__c,',
                '   Exhibition_Id__c,',
                '   Certificate_Type__c,',
                
                '   Department_Name__c,',
                '   Company_Abbr__c,',
                '   Phone__c,',
                '   Approval_Status__c,',
                '   Id',
                'FROM Internal_Registration__c',
                'WHERE ',
                '   Exhibition_Id__c =: exhId',
                '   AND (Approval_Status__c = \'未审批\' OR Approval_Status__c = \'部门审批驳回\' OR Approval_Status__c = \'分管领导/大区总驳回\')',
                deap == null ? '' : '   AND Department_Name__c =: deap',
                companyAbbr == null ? '' : '   AND Company_Abbr__c =: companyAbbr',
                ''
            }, ' '));
            // #展会优化 增加companyAbbr条件 add by DTT-Bright 20240803 END
        
            if (intList.size()>0) {
                Map<String, List<Internal_Registration__c>> mso = new Map<String, List<Internal_Registration__c>>();
                resp.data = mso;
                mso.put('intList',getSortedInternalRecords(intList));
            }else{
                resp.code = -1;
                resp.message = '该部门没有要审批的员工！';
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        
        return resp;
    }

    @AuraEnabled
    public static ConResponse selIntList(String deap,String exhId, String companyAbbr, String region, String approval,String approvalStatus) {
        ConResponse resp = new ConResponse();
        try {
            System.debug('XXX5' + region + ':' + exhId + ':' + approval + ':' + deap + ':' + companyAbbr + ':' + approvalStatus);
            // System.debug('XXX5' + approvalState););
            // String querySoql = 'SELECT Id, Name_CN__c, Email__c,Exhibition_Id__c,Department_Name__c,Phone__c FROM Internal_Registration__c WHERE '
            //                  + '(Approval_Status__c = \'未审批\' OR Approval_Status__c = \'部门审批驳回\') AND Department_Name__c =: deap ';
            // if (exhId != NULL) {
            //     querySoql += 'AND Exhibition_Id__c =: exhId';
            // }
            // List<Internal_Registration__c> intList = Database.query(querySoql);
            // List<Internal_Registration__c> intList = [SELECT Id, Name_CN__c, Email__c,
            //                                 Exhibition_Id__c,Department_Name__c,Phone__c    
            //                                 FROM Internal_Registration__c
            //                                 WHERE Exhibition_Id__c =: exhId 
            //                                 AND (Approval_Status__c = '未审批' OR Approval_Status__c = '部门审批驳回')
            //                                 AND Department_Name__c =: deap];
            // #展会优化 增加companyAbbr条件 add by DTT-Bright 20240803 START
            String statusString = '';
            System.debug('XXX' +approvalStatus );
            if(String.isEmpty(approvalStatus)){
                statusString = '  AND (Approval_Status__c = \'未审批\' OR Approval_Status__c = \'部门审批驳回\' OR Approval_Status__c = \'分管领导/大区总驳回\')';
            } else if(approvalStatus.equals('未审批')) {
                statusString = ' AND Approval_Status__c = \'未审批\'';
            } else if(approvalStatus.equals('审批驳回')) {
                statusString = ' AND (Approval_Status__c = \'部门审批驳回\' OR Approval_Status__c = \'分管领导/大区总驳回\')';
            } else {
                statusString = '  AND (Approval_Status__c = \'未审批\' OR Approval_Status__c = \'部门审批驳回\' OR Approval_Status__c = \'分管领导/大区总驳回\')';
            }

            List<Internal_Registration__c> intList = Database.query(String.join(new String[] {
                'SELECT',
                '   Name_CN__c,',
                '   Email__c,',
                '   Exhibition_Id__c,',
                '   Certificate_Type__c,',
                '   Department_Name__c,',
                '   Company_Abbr__c,',
                '   Phone__c,',
                '   Approval_Status__c,',
                '   Id',
                'FROM Internal_Registration__c',
                'WHERE ',
                '   Exhibition_Id__c =: exhId',
                // '   AND (Approval_Status__c = \'未审批\' OR Approval_Status__c = \'部门审批驳回\' OR Approval_Status__c = \'复审\')',
                statusString,
                region == null ? '' : '   AND Company__c =: region',
                approval == null ? '' : '   AND Approver__c LIKE \'%' + approval + '%\'',
                // approval == null ? '' : '   AND Approver__c =: approval',
                deap == null ? '' : '   AND Department_Name__c =: deap',
                companyAbbr == null ? '' : '   AND Company_Abbr__c =: companyAbbr',
                ''
            }, ' '));
            // #展会优化 增加companyAbbr条件 add by DTT-Bright 20240803 END
        
            if (intList.size()>0) {
                Map<String, List<Internal_Registration__c>> mso = new Map<String, List<Internal_Registration__c>>();
                resp.data = mso;
                mso.put('intList',getSortedInternalRecords(intList));
            }else{
                resp.code = -1;
                resp.message = '该部门没有要审批的员工！';
            }
            
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            resp.code = -1;
            resp.message = e.getMessage() + '\n' + e.getStackTraceString();
        }
        
        return resp;
    }

    @AuraEnabled
    public static List<Internal_Registration__c> getInternalRegistList(String id){
        return [SELECT Id, Name_CN__c,Certificate_Type__c, Department_Name__c, Phone__c, Email__c,Approval_Status__c FROM Internal_Registration__c WHERE Exhibition_Id__c =:id 
                                                 AND (Approval_Status__c = '部门审批通过' OR Approval_Status__c = '审批驳回')];
    }

    public static List<Internal_Registration__c> getSortedInternalRecords(List<Internal_Registration__c> records) {
        // 查询所有 Internal_Registration__c 记录
        // List<Internal_Registration__c> records = [SELECT Id,Name, Certificate_Type__c FROM Internal_Registration__c Where Exhibition_Id__c = 'a3KA200000049mHMAQ'];
        
        // 创建包装类列表
        System.debug('进入排序----');
        List<SortableRecord> wrappers = new List<SortableRecord>();
        for (Internal_Registration__c record : records) {
            wrappers.add(new SortableRecord(record));
        }

        // 对包装类列表进行排序
        wrappers.sort();

        // 提取排序后的原始记录列表
        List<Internal_Registration__c> sortedRecords = new List<Internal_Registration__c>();
        for (SortableRecord wrapper : wrappers) {
            sortedRecords.add(wrapper.record);
        }

        return sortedRecords;
    }

    // 包装类实现 Comparable 接口
    private class SortableRecord implements Comparable {
        public Internal_Registration__c record;

        public SortableRecord(Internal_Registration__c record) {
            this.record = record;
        }

        public Integer compareTo(Object other) {
            SortableRecord otherWrapper = (SortableRecord) other;
            Map<String, Integer> priorityMap = new Map<String, Integer>{
                '参展商证|Exhibition Badge' => 1, '临时证|Day Voucher' => 2, '筹展证|Day Voucher for booth construction' => 3, '撤展证|Day Voucher for booth dismantle' => 4,
                '境内采购商证|Domestic Buyer' => 5, '境外采购商证|Overseas Buyers' => 6, '采购代表证|Purchasing Agent' => 7, '翻译证|Translation Certificate' => 8,
                '临时证(自购)|Day Voucher(Self-buying)' => 9
            };

            List<String> types1 = (record.Certificate_Type__c != null) ? record.Certificate_Type__c.split(';') : new List<String>();
            List<String> types2 = (otherWrapper.record.Certificate_Type__c != null) ? otherWrapper.record.Certificate_Type__c.split(';') : new List<String>();

            Integer priority1 = getRecordPriority(types1, priorityMap);
            Integer priority2 = getRecordPriority(types2, priorityMap);

            return priority1 - priority2;
        }
    }

    // 辅助方法：计算记录的优先级
    private static Integer getRecordPriority(List<String> types, Map<String, Integer> priorityMap) {
        Integer priority = 10; // 默认优先级
        for (String type : types) {
            Integer currentPriority = priorityMap.get(type.trim());
            if (currentPriority != null && currentPriority < priority) {
                priority = currentPriority;
            }
        }
        return priority;
    }
    
    
}