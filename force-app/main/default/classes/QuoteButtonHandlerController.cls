/**************************************************************************************************
 * QuoteButtonHandlerController
 * Purpose:报价按钮处理逻辑
 * Author: Deloitte Johnson
 * Create Date: 2019-3-12
***************************************************************************************************/
global  without sharing class QuoteButtonHandlerController{
    public static User currentUser = [SELECT Id,Profile.Name,ManagerId FROM User WHERE Id = :UserInfo.getUserId()];
    public static Map<String,Schema.SObjectField> quoteLoopMap = Schema.SObjectType.Quote__c.fields.getMap();
    public static Map<String,Schema.SObjectField> quoteItemLoopMap = Schema.SObjectType.Quote_Product__c.fields.getMap();
    public class ReturnResult{
        public String code; //code "0" means success, and other codes means failure
        public String msg;  //result message
    }
    @AuraEnabled 
    //提交报价到成本组询价
    public static String submitToCost(String quoteId){
    	ReturnResult result = new ReturnResult();
    	result.code = '0';
        result.msg = 'Submitted to Cost!';
        Quote__c thisQuote = [SELECT Id,Name,Approval_Status__c,Cost_Staff__c,Inquiry_Status__c,
                             (SELECT Id,Need_to_Provide_EXW__c FROM Quote_Products__r) 
                              FROM Quote__c WHERE Id =:quoteId];
        if(!Label.Quote_Editable_Status_Set.contains(thisQuote.Approval_Status__c)){
            result.code = '1';
            //result.msg = 'Only a Draft/Rejected quote can be submitted to the cost team!';
            result.msg = Label.Quote_Submit_To_Cost_With_Error_Status;
            return JSON.serialize(result);
        }
        if(thisQuote.Inquiry_Status__c.equals('Submitted')){
            result.code = '1';
            //result.msg = 'You have submitted to the cost team and cannot repeat operation';
            result.msg = Label.Quote_Submit_To_Cost_Repeat_Operation;
            return JSON.serialize(result);
        }
        if(String.isBlank(thisQuote.Cost_Staff__c)){
            result.code = '1';
            //result.msg = 'Please fill in the \'Cost Staff\' before submitting!';
            result.msg = Label.Quote_Submit_To_Cost_Need_Staff;
            return JSON.serialize(result);
        }
        Integer count = 0;//需要询价的产品行
        for(Quote_Product__c quoteItem : thisQuote.Quote_Products__r){
            if(quoteItem.Need_to_Provide_EXW__c.equals('YES')){
            	count++;
            }
        }
        if(count == 0){
            result.code = '1';
            //result.msg = 'There\'s no products need to ask for cost price.';
            result.msg = Label.Quote_Submit_To_Cost_No_Inquiry_Products;
            return JSON.serialize(result);
        }
        //需要权限共享给对应成本组人员
        Map<String,Set<String>> quoteApproverMap = new Map<String,Set<String>>();
        quoteApproverMap.put(quoteId,new Set<String>{thisQuote.Cost_Staff__c});
        shareQuoteToApprover(quoteApproverMap);

        thisQuote.Inquiry_Status__c = 'Submitted';
        update thisQuote;

        Task task = new Task();
        task.Subject = Label.Quote_Submit_To_Cost_Task_Subject;//'Ask for Cost Price';
        task.Description = Label.Quote_Submit_To_Cost_Task_Description;//'Please fill in the cost price of quote products.';
        task.WhatId = quoteId;
        task.Status = 'Not Started';
        task.Priority = 'High';
        task.OwnerId = thisQuote.Cost_Staff__c;
        task.IsReminderSet = true;
        task.ReminderDateTime = Datetime.now();
        insert task;
        return JSON.serialize(result);
    }
    @AuraEnabled 
    //成本组确认成本价并通知销售
    public static String confirmCostPrice(String quoteId){
        ReturnResult result = new ReturnResult();
        result.code = '0';
        result.msg = 'Confirmed!';
        Quote__c thisQuote = [SELECT Id,Name,Approval_Status__c,Cost_Staff__c,OwnerId,Inquiry_Status__c,
                              (SELECT Id,Need_to_Provide_EXW__c,Cost__c,Cost_Type__c FROM Quote_Products__r) 
                              FROM Quote__c WHERE Id =:quoteId];
        if(thisQuote.Inquiry_Status__c.equals('Confirmed')){
            result.code = '1';
            //result.msg = 'You have confirmed the cost price and cannot repeat operation';
            result.msg = Label.Quote_Confirm_Cost_Price_Repeat_Operation;
            return JSON.serialize(result);
        }
        Integer count = 0;//需要询价的产品行
        for(Quote_Product__c quoteItem : thisQuote.Quote_Products__r){
            if(quoteItem.Need_to_Provide_EXW__c.equals('YES')
            && (String.isBlank(quoteItem.Cost_Type__c) || quoteItem.Cost__c == null || quoteItem.Cost__c <= 0)
            ){
                count ++;
            }
        }
        if(count > 0){
            result.code = '1';
            //result.msg = 'Please fill in the cost price for the quote products that need to provide the cost price';
            result.msg = Label.Quote_Confirm_Cost_Price_Must_Input_Cost_Info;
            return JSON.serialize(result);
        }
        thisQuote.Inquiry_Status__c = 'Confirmed';
        update thisQuote;

        Task task = new Task();
        task.Subject = Label.Quote_Confirm_Cost_Price_Task_Subject;//'Cost Price confirmed';
        task.Description = Label.Quote_Confirm_Cost_Price_Task_Description;//'The cost price of quote products has been confirmed by cost team, please complete the other information!';
        task.WhatId = quoteId;
        task.Status = 'Not Started';
        task.Priority = 'High';
        task.OwnerId = thisQuote.OwnerId;
        task.IsReminderSet = true;
        task.ReminderDateTime = Datetime.now();
        insert task;
        return JSON.serialize(result);
    }
    @AuraEnabled 
    //报价提交审批
    public static String submitForApproval(String quoteId){
        System.debug('提交审批！');
        ReturnResult result = new ReturnResult();
        result.code = '0';
        result.msg = 'Submitted!';
        Quote__c thisQuote = [SELECT Id,Name,Approval_Status__c,Cost_Staff__c,RecordType.DeveloperName,Product_Line__c,Customer_Name__c,
                             Minimum_Gross_Profit_Margin_Level__c,Expiry_Date__c,IsAutoApproval__c,
                             (SELECT Id,Need_to_Provide_EXW__c,Product_Name_Formula__c,Quantity__c,Unit_Sell_In_Price__c,
                             Delivery_Form__c,Estimatied_Delivery_Date__c FROM Quote_Products__r) 
                              FROM Quote__c WHERE Id =:quoteId];
        if(!Label.Quote_Editable_Status_Set.contains(thisQuote.Approval_Status__c)){
            result.code = '1';
            //result.msg = 'Only a Draft/Rejected quote can be submitted for approval!';
            result.msg = Label.Quote_Submit_For_Approval_With_Error_Status;
            return JSON.serialize(result);
        }
        if(thisQuote.Expiry_Date__c <= System.today()){
            result.code = '1';
            //result.msg = 'The expiry date must be after today';
            result.msg = Label.Quote_Submit_For_Approval_Expiry_Date_Check;
            return JSON.serialize(result);
        }
        if(thisQuote.RecordType.DeveloperName.contains('Sales_Department')){
            List<Customer_Product_Line__c> customerLines = [SELECT Id,Minimum_Gross_Profit_Margin_Level__c FROM Customer_Product_Line__c
                                           WHERE Customer__c =:thisQuote.Customer_Name__c AND Product_Line_Name__c =:thisQuote.Product_Line__c LIMIT 1]; 
            if(customerLines.isEmpty() || customerLines[0].Minimum_Gross_Profit_Margin_Level__c == null){
                result.code = '1';
                //result.msg = 'Please fill in \'Minimum Gross Profit Margin- Level\' under the corresponding product line before submitting';
                result.msg = Label.Quote_Submit_For_Approval_Cannot_Get_Gross_Margin;
                return JSON.serialize(result);
            } 
            thisQuote.Minimum_Gross_Profit_Margin_Level__c = customerLines[0].Minimum_Gross_Profit_Margin_Level__c;
            update thisQuote;                              
        }
        if(thisQuote.Quote_Products__r.isEmpty()){
            result.code = '1';
            //result.msg = 'Please add quote products before submitting.';
            result.msg = Label.Quote_Submit_For_Approval_Need_Products;
            return JSON.serialize(result);
        }
        String errMessage = '';
        for(Quote_Product__c quoteItem : thisQuote.Quote_Products__r){
            Integer lineErrCount = 0;
            String proName = '[' + quoteItem.Product_Name_Formula__c + ']';
            errMessage += proName;
            if(quoteItem.Quantity__c == null){
                errMessage += ' ' + Label.Quote_Product_Field_Quantity + ',';
                lineErrCount++;
            }
            if(quoteItem.Unit_Sell_In_Price__c == null){
                errMessage += ' ' + Label.Quote_Product_Field_Unit_Price +  ',';
                lineErrCount++;
            }
            if(thisQuote.RecordType.DeveloperName.contains('Sales_Department_TV')
            && quoteItem.Delivery_Form__c == null){
                errMessage += ' ' + Label.Quote_Product_Field_Delivery_Form +  ',';
                lineErrCount++;
            }
            // if(thisQuote.RecordType.DeveloperName.contains('Sales_Department_Mobile')
            // && quoteItem.Estimatied_Delivery_Date__c == null){
            //     errMessage += ' Estimatied Delivery Date' +  ',';
            //     lineErrCount++;
            // }
            if(lineErrCount > 0){
                errMessage = errMessage.substring(0,errMessage.length()-1);
                errMessage += ' ' + Label.Quote_Product_Field_Require_Alert + '\n';
            }else{
                errMessage = errMessage.replace(proName,'');
            }

        }
        if(errMessage.contains(Label.Quote_Product_Field_Require_Alert)){
            result.code = '1';
            result.msg = errMessage;
            return JSON.serialize(result);
        }
        try{
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            //req.setComments('提交报价审批！');
            req.setObjectId(quoteId);
            req.setSubmitterId(currentUser.Id);
            if(thisQuote.RecordType.DeveloperName.contains('Sales_Department')){
                //req.setNextApproverIds(new Id[] {currentUser.ManagerId});
                req.setProcessDefinitionNameOrId('QuoteApprovalProcessForSD');
            }else if(thisQuote.RecordType.DeveloperName.contains('USA')){
                req.setProcessDefinitionNameOrId('QuoteApprovalProcessForUSA');
            }else if(thisQuote.RecordType.DeveloperName.contains('Malaysia')){
                if(thisQuote.IsAutoApproval__c){
                    req.setProcessDefinitionNameOrId('QuoteApprovalProcessForMalaysia_Auto');
                }else{
                    req.setProcessDefinitionNameOrId('QuoteApprovalProcessForMalaysia');
                }
                
            }
            req.setSkipEntryCriteria(true);
            Approval.process(req);
        }catch(Exception e){
            result.code = '1';
            result.msg = 'Submit failed, failed reason: ' + e.getMessage();
        }
        
        return JSON.serialize(result);
    }
    @AuraEnabled 
    //成本组确认成本价并通知销售
    public static String submitForAbandon(String quoteId){
        ReturnResult result = new ReturnResult();
        result.code = '0';
        result.msg = 'Abandoned!';
        Quote__c thisQuote = [SELECT Id,Approval_Status__c FROM Quote__c WHERE Id =:quoteId];
        if(!Label.Quote_Editable_Status_Set.contains(thisQuote.Approval_Status__c)){
            result.code = '1';
            //result.msg = 'Only a Draft/Rejected quote can be abandoned!';
            result.msg = Label.Quote_Submit_For_Abandon_With_Error_Status;
            return JSON.serialize(result);
        }
        thisQuote.Approval_Status__c = 'Abandoned';
        update thisQuote;
        Approval.lock(quoteId, false);
        return JSON.serialize(result);
    }
    @AuraEnabled
    //复制报价以及报价产品
    public static String copyQuoteInfo(String quoteId){
        ReturnResult result = new ReturnResult();
        result.code = '0';
        result.msg = 'Copied!';
        Quote__c newQuote = new Quote__c();
        Savepoint sp = Database.setSavepoint();
        try{
            String querySql1 = 'SELECT ' + Utility.getQueryStringByFieldMap(quoteLoopMap) + ' FROM Quote__c WHERE Id =:quoteId';
            Quote__c thisQuote = Database.query(querySql1);
            newQuote = thisQuote.clone(false);
            newQuote.Name += '_Copy';
            newQuote.Approval_Status__c = 'Draft';
            newQuote.External_ID__c = null;
            insert newQuote;
            String querySql2 = 'SELECT ' + Utility.getQueryStringByFieldMap(quoteItemLoopMap) + ' FROM Quote_Product__c WHERE Quote_Name__c =:quoteId';
            List<Quote_Product__c> quoteItemList = Database.query(querySql2);
            List<Quote_Product__c> newQuoteItemList = new List<Quote_Product__c>();
            for(Quote_Product__c qItem : quoteItemList){
                Quote_Product__c newQuoteItem = qItem.clone(false);
                newQuoteItem.Quote_Name__c = newQuote.Id;
                newQuoteItem.External_ID__c = null;
                newQuoteItemList.add(newQuoteItem);
            }
            insert newQuoteItemList;
        }catch(Exception e){
            Database.rollback(sp);
            system.debug('error message: '+e.getMessage());
            system.debug('line number: '+e.getLineNumber());
            result.code = '1';
            result.msg = Utility.getProperErrorMessage(e.getMessage());
            return JSON.serialize(result);
        }
        result.msg = newQuote.Id;
        return JSON.serialize(result);
    }
    
    /**
     方法名: shareQuoteToApprover
     功能说明: 共享报价权限给审批人
     参数说明: Map<String,Set<String>> quoteApproverMap
     返回值: 
     作者: Johnson
     日期: 2019-03-27
    */
    public static void shareQuoteToApprover(Map<String,Set<String>> quoteApproverMap){
        Map<String,Set<String>> accessUserMap = new Map<String,Set<String>>(); //quoteId => Set<String>;
        List<Quote__Share> insertQuoteShareList = new List<Quote__Share>();
        List<Quote__Share> quoteShareList = [SELECT ParentId,UserOrGroupId FROM Quote__Share WHERE ParentId IN :quoteApproverMap.keySet()];
        for(Quote__Share quoteShare : quoteShareList){
            if(accessUserMap.containsKey(quoteShare.ParentId)){
                accessUserMap.get(quoteShare.ParentId).add(quoteShare.UserOrGroupId);
            }else{
                accessUserMap.put(quoteShare.ParentId, new Set<String>{quoteShare.UserOrGroupId});
            }
        }
        for(String quoteId : quoteApproverMap.keySet()){
            Set<String> approverIdSet = quoteApproverMap.get(quoteId);
            for(String approverId : approverIdSet){
                if(accessUserMap.containsKey(quoteId) && accessUserMap.get(quoteId).contains(approverId)){
                    continue ;
                }
                Quote__Share quoteShare = new Quote__Share();
                quoteShare.RowCause = 'Manual';
                quoteShare.ParentId = quoteId;
                quoteShare.UserOrGroupId = approverId;
                quoteShare.AccessLevel = 'Edit';
                insertQuoteShareList.add(quoteShare);
            }
        }
        if(insertQuoteShareList.size() > 0){
            try{
                insert insertQuoteShareList;
            }catch(Exception e){
                system.debug('error message'+e.getMessage());
                system.debug('line number'+e.getLineNumber());
            }
        }
    }

}