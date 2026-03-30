public without sharing class HistoricalInspectionReportController {
    
    @AuraEnabled(cacheable=true)
    public static ConResponse init(String ownerId, String reportDate, String storeId) {
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        
        if (ownerId=='' || ownerId==null || 
            reportDate=='' || reportDate==null ||
            storeId=='' || storeId==null) {

            return resp;
        }

        Date d;
        try {
            d = Date.valueOf(reportDate);
        } catch (Exception e) {
            return resp;
        } 

        mso = (Map<String, Object>)getHistoricalTicket(ownerId, d, storeId).data;
        resp.data = mso;

        List<Daily_Inspection_Report__c> dirList = [SELECT 
                                            Id,Name,Report_Date__c 
                                        FROM Daily_Inspection_Report__c 
                                        WHERE OwnerId = :ownerId
                                        AND Store__c = :storeId
                                        AND Report_Date__c < :d 
                                        AND Status__c = 'Submitted' 
                                        ORDER BY Report_Date__c DESC
                                        LIMIT 1];
        if (dirList.size()==0) {
            return resp;
        } else {
            mso.put('inspectionReport', dirList[0]);
        }

        Daily_Inspection_Report__c dir = dirList[0];

        List<CheckResult__c> crList = [SELECT 
                                            Id,
                                            Name,
                                            Scores__c,
                                            Max_Scores__c,
                                            Comments__c,
                                            Status__c,
                                            CheckItem__c,
                                            CheckItem__r.Name,
                                            CheckItem__r.Is_Related_To_Product__c,
                                            CheckItem__r.Product_Line__c,
                                            toLabel(CheckItem__r.Project__c),
                                            CheckItem__r.MaximumScore__c,
                                            CheckItem__r.HasFile__c,
                                            CheckItem__r.Description__c,
                                            CheckItem__r.Description_CN__c,
                                            CheckItem__r.Description_EN__c,
                                            CheckItem__r.Description_Filling_Language__c,
                                            CheckItem__r.IsYesOrNo__c,
                                            CheckItem__r.HelpText__c,
                                            CheckItem__r.OrderNumber__c,
                                            CheckItem__r.IsCountInScore__c,
                                            CheckItem__r.Require_Comment_Scores__c,
                                            CheckItem__r.Scores_require_file__c,
                                            CheckItem__r.HasComment__c,
                                            Sampling_Inspection__c,
                                            Sampling_Inspection__r.Placement_Status__c,
                                            Sampling_Inspection__r.ReRe__c,
                                            Sampling_Inspection__r.Product__c,
                                            Sampling_Inspection__r.Product__r.Name,
                                            Sampling_Inspection__r.Product__r.Category__c,
                                            Sampling_Inspection__r.Product__r.Series__c,
                                            Result__c
                                        FROM CheckResult__c
                                        WHERE 
                                            InspectorDailyReport__c = : dir.Id
                                        ORDER BY CheckItem__r.OrderNumber__c
                                        ];
        if (crList.size()==0) {
            return resp;
        } else {
            List<CheckResult__c> returnCrList = new List<CheckResult__c>();
            for (CheckResult__c cr : crList) {
                if (Integer.valueOf(cr.Max_Scores__c)>Integer.valueOf(cr.Scores__c)) {
                    returnCrList.add(cr);
                }
            }
            if (returnCrList.size()>0) {
                mso.put('CheckResultList', getCheckResultBycurrentUserLanguage(returnCrList));
            }
        }
        // 获取Product Line Picklist Value顺序
        mso.put('productLineValueSort', getPickList('Product__c','Product_Line__c')); 
        System.debug('resp======>'+resp);
        return resp;
    }

    public static ConResponse getHistoricalTicket(String ownerId, Date reportDate, String storeId) {
        System.debug('getHistoricalTicket ---> ownerId: ' + ownerId);
        System.debug('getHistoricalTicket ---> reportDate: ' + reportDate);
        System.debug('getHistoricalTicket ---> storeId: ' + storeId);

        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        List<Ticket__c> historicalTicketList = new List<Ticket__c>();
        List<Daily_Inspection_Report__c> historicalReportList = [SELECT Id FROM Daily_Inspection_Report__c 
                                                                    WHERE CreatedById = :ownerId AND  Store__c = :storeId AND Report_Date__c < :reportDate];
        if(historicalReportList.size() > 0) {
            List<String> historicalReportIdList = new LisqContainer(historicalReportList).SelectSField('Id');
            historicalTicketList = [SELECT Id, Name, Status__c, AssignedTo__c, DueDate__c, Description__c, Subject__c, Priority__c, InspectionReport__c, Department__c
                                    FROM Ticket__c 
                                    WHERE Status__c != 'Closed' AND CreatedById = :ownerId AND InspectionReport__c IN :historicalReportIdList
                                    ORDER BY InspectionReport__c];
        }
        mso.put('historicalTicketList', historicalTicketList);
        mso.put('ticketFieldLabel', SObjectHelper.getFieldLabelMap('Ticket__c'));
        mso.put('userRegion', [SELECT Id, Sales_Region__c FROM User WHERE Id = :ownerId LIMIT 1].Sales_Region__c);
        return resp;
    }
    
    public static  List<CheckResult__c> getCheckResultBycurrentUserLanguage(List<CheckResult__c> checkList) {
        String currentUserLanguage = UserInfo.getLanguage();
        String languageIsCN = 'zh_CN';
        String languageIsEN = 'en_US';
        List<CheckResult__c> resCheckList = new List<CheckResult__c>();
        for (CheckResult__c item: checkList) {
            if (item.CheckItem__r.Description_Filling_Language__c != currentUserLanguage ) {
                if (String.isNotBlank(item.CheckItem__r.Description_EN__c) && currentUserLanguage == languageIsEN) {
                    item.CheckItem__r.Description__c = item.CheckItem__r.Description_EN__c;
                }
                if (currentUserLanguage == languageIsCN) {
                    if (String.isNotBlank(item.CheckItem__r.Description_CN__c)) item.CheckItem__r.Description__c = item.CheckItem__r.Description_CN__c;
                    else item.CheckItem__r.Description__c = String.isNotBlank(item.CheckItem__r.Description_EN__c) ? item.CheckItem__r.Description_EN__c : item.CheckItem__r.Description__c;
                }
            }
            resCheckList.add(item);
        }
        return resCheckList;
    }

    
    // 获取Picklist values
    @AuraEnabled(Cacheable=true)
    public static List<Map<String, String>> getPickList(String objectName, String fieldName) {
        if (String.isBlank(fieldName)) {
            return null;
        }

        try {
            Map<String, String> temp = Utility.getPicklistValueMap(objectName, fieldName);
            List<Map<String, String>> result = new List<Map<String, String>>();
            for (String key : temp.keySet()) {
                result.add(new Map<String, String> {
                    'label' => temp.get(key),
                    'value' => key
                });
            }

            return result;
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
        }

        return null;
    }
}