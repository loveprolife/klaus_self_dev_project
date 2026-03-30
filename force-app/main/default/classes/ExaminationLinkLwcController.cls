public class ExaminationLinkLwcController {

    /**
     * 根据当前用户信息查询是否有代办考试
     */
    @AuraEnabled
    public static ConResponse getInitData(String recordId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        String userId = UserInfo.getUserId();
        List<String> examinationId = new List<String>();
        // YYL 校验当前用户是否已经参与此次考试 20250529
        List<Training_Answer_History__c> history = [SELECT Id,Examination__c FROM Training_Answer_History__c WHERE User__c = :userId];
        if(history != null && history.size() > 0){
            LisqContainer lq = new LisqContainer(history);
            // 获取考试问卷id
            List<String> examination = lq.SelectSField('Examination__c');
            examinationId.addAll(examination);
        }
        List<Examination_User__c> examinationUser = [SELECT Id,Examination__r.Name FROM Examination_User__c WHERE User__c = :userId AND Examination__c NOT IN :examinationId];
        mso.put('examinationUser', examinationUser);

        return resp;
    }
}