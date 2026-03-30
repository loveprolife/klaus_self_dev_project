/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 12-29-2021
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public with sharing class PromoterDailyReportController {
    @AuraEnabled
    public static InitDataClass initFunction(){
        InitDataClass idc = new InitDataClass();

        //问题明细
        List<weekQuestionItem> weekQueList = new List<weekQuestionItem>();
        
        //查找当前登录者(促销员)的所属门店根据门店查找周问题
        Id usId = UserInfo.getUserId();
        List<Responsible_Person__c> respList = [SELECT Shop_Name__c 
                                                FROM Responsible_Person__c
                                                WHERE Principal__c = :usId];

        if (respList.isEmpty()) {
            idc.isError = true;
            idc.msg = '当前操作者无分配门店,请分配门店后进行操作';
            return idc;
        }

        //根据门店查找门店调查要求
        List<Week_Research__c> wresList = [SELECT Shop__c, 
                                                (SELECT Question__c 
                                                 FROM Week_Question_Item__r 
                                                 ORDER BY Number__c)
                                            FROM Week_Research__c
                                            WHERE Shop__c = :respList[0].Shop_Name__c];
        
        if (!wresList[0].Week_Question_Item__r.isEmpty()) {
            for (Week_Question_Item__c wqi : wresList[0].Week_Question_Item__r) {
                weekQuestionItem wqic = new weekQuestionItem();
                wqic.question = wqi.Question__c;
                weekQueList.add(wqic);
            }
        }

        System.debug(LoggingLevel.INFO, '*** weekQueList: ' + weekQueList);

        idc.weekQueList = weekQueList;

        //判断当前日期是否本周最后一天
        idc.isWeekLastDay = true;
        // isWeekLastDay
        return idc;
    }

    public class InitDataClass {
        @AuraEnabled public Boolean isError{GET;SET;}
        @AuraEnabled public String msg{GET;SET;}
        @AuraEnabled public List<weekQuestionItem> weekQueList{GET;SET;}
        @AuraEnabled public Boolean isWeekLastDay{GET;SET;}

        public InitDataClass(){
            this.isError = false;
            this.msg = '';
            this.weekQueList = new List<weekQuestionItem>();
            this.isWeekLastDay = false;
        }
    }

    public class weekQuestionItem {
        @AuraEnabled public String question{GET;SET;}
        @AuraEnabled public String answer{GET;SET;}

        public weekQuestionItem(){
            this.question = '';
            this.answer = '';
        }
    }
}