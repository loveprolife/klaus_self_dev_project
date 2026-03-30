public without sharing class CheckItemTriggerHandlerHelper {
    public static void duplicateCheck(List<CheckItem__c> oldList, List<CheckItem__c> newList){
        Map<Id, CheckItem__c> oldMap = new Map<Id, CheckItem__c>();
        Boolean isUpdate = false;
        if(oldList != null) {
            isUpdate = true;
            oldMap = new Map<Id, CheckItem__c>(oldList);
        }
        for(CheckItem__c item : newList) {
            if(isUpdate) {
                if(oldMap.get(item.Id).Description__c != item.Description__c) {
                    item.DescriptionT__c = item.Description__c;
                }
                 //ADD BY TIGER 
                if (oldMap.get(item.Id).Project__c != item.Project__c) {
                    item.ProjectT__c = item.Project__c;
                }
            } else {
                item.DescriptionT__c = item.Description__c;
                item.ProjectT__c = item.Project__c;//ADD BY TIGER 
            }

            if(item.IsYesOrNo__c && item.HasFile__c && item.RequireFileOptions__c != null) {
                if(item.RequireFileOptions__c.contains('No')) {
                    if(item.Scores_require_file__c == null) {
                       item.Scores_require_file__c = '0'; 
                    } else {
                        item.Scores_require_file__c += ';0'; 
                    }
                } 
                if(item.RequireFileOptions__c.contains('Yes')) {
                    if(item.Scores_require_file__c == null) {
                        item.Scores_require_file__c = item.MaximumScore__c;
                    } else {
                        item.Scores_require_file__c += ';' + item.MaximumScore__c;
                    }
                    
                }
                
            }

            if(item.IsYesOrNo__c && item.HasComment__c && item.RequireCommentOptions__c != null) {
                if(item.RequireCommentOptions__c.contains('No')) {
                    if(item.Require_Comment_Scores__c == null) {
                        item.Require_Comment_Scores__c = '0';
                    } else {
                        item.Require_Comment_Scores__c += ';0';
                    }
                    
                } 
                if(item.RequireCommentOptions__c.contains('Yes')) {
                    if(item.Require_Comment_Scores__c == null) {
                        item.Require_Comment_Scores__c = item.MaximumScore__c;
                    } else {
                        item.Require_Comment_Scores__c += ';' + item.MaximumScore__c;
                    }
                }
            }
        }
    }
}