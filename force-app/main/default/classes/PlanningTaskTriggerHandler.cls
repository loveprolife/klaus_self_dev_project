public without sharing class PlanningTaskTriggerHandler extends TriggerHandler{

    public override void AfterInsert(){
        List<Task> taskList = new List<Task>();
        for (Planning_Task__c pt : ((list<Planning_Task__c>)Trigger.new)) {
            if(pt.Revenue_Targets_User__c != null && pt.Revenue_Targets_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Revenue_Targets_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Revenue_Targets_Due_Date__c;
                task.CallObject = pt.id + '1';
                taskList.add(task);
            }
            if(pt.Category_Share_Goals_Targets_User__c != null && pt.Category_Share_Goals_Targets_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Category_Share_Goals_Targets_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Category_Share_Goals_Targets_Due_Date__c;
                task.CallObject = pt.id + '2';
                taskList.add(task);
            }
            if(pt.Pricing_User__c != null && pt.Pricing_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Pricing_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Pricing_Due_Date__c;
                task.CallObject  = pt.id + '3';
                taskList.add(task);
            }
            if(pt.Assortment_recommendation_selection_User__c != null && pt.Assortment_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Assortment_recommendation_selection_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Assortment_Due_Date__c;
                task.CallObject = pt.id + '4';
                taskList.add(task);
            }
            if(pt.Training_Plans_User__c != null && pt.Training_Plans_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Training_Plans_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Training_Plans_Due_Date__c;
                task.CallObject = pt.id + '5';
                taskList.add(task);
            }
            if(pt.Competitor_benchmarking_User__c != null && pt.Competitor_benchmarking_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Competitor_benchmarking_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Competitor_benchmarking_Due_Date__c;
                task.CallObject = pt.id + '6';
                taskList.add(task);
            }
            if(pt.Map_UPP_Policy_review_User__c != null && pt.Map_UPP_Policy_review_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Map_UPP_Policy_review_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Map_UPP_Policy_review_Due_Date__c;
                task.CallObject = pt.id + '7';
                taskList.add(task);
            }
            if(pt.MDF_Budgets_User__c != null && pt.MDF_Budgets_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.MDF_Budgets_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.MDF_Budgets_Due_Date__c;
                task.CallObject = pt.id + '8';
                taskList.add(task);
            }
            if(pt.EOL_plans_User__c != null && pt.EOL_plans_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.EOL_plans_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.EOL_plans_Due_Date__c;
                task.CallObject = pt.id + '9';
                taskList.add(task);
            }
            if(pt.Program_Letters_VPA_s_User__c != null && pt.Program_Letters_VPA_s_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Program_Letters_VPA_s_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Program_Letters_VPA_s_Due_Date__c;
                task.CallObject = pt.id + '10';
                taskList.add(task);
            }
            if(pt.NPI_360_plans_User__c != null && pt.NPI_360_plans_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.NPI_360_plans_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.NPI_360_plans_Due_Date__c;
                task.CallObject = pt.id + '11';
                taskList.add(task);
            }
            if(pt.Sales_Information_User__c != null && pt.Sales_Information_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Sales_Information_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Sales_Information_Due_Date__c;
                task.CallObject = pt.id + '12';
                taskList.add(task);
            }
            if(pt.X6_Month_Customer_Forecasts_User__c != null && pt.X6_Month_Customer_Forecasts_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.X6_Month_Customer_Forecasts_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.X6_Month_Customer_Forecasts_Due_Date__c;
                task.CallObject = pt.id + '13';
                taskList.add(task);
            }
            if(pt.Customer_KPI_s_User__c != null && pt.Customer_KPI_s_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Customer_KPI_s_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Customer_KPI_s_Due_Date__c;
                task.CallObject = pt.id + '14';
                taskList.add(task);
            }
            if(pt.JBP_3_Year_Plans_User__c != null && pt.JBP_3_Year_Plans_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.JBP_3_Year_Plans_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.JBP_3_Year_Plans_Due_Date__c;
                task.CallObject = pt.id + '15';
                taskList.add(task);
            }
            if(pt.Online_Agreements_Auth_Reseller_User__c != null && pt.Online_Agreements_Auth_Reseller_Due__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Online_Agreements_Auth_Reseller_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Online_Agreements_Auth_Reseller_Due__c;
                task.CallObject = pt.id + '16';
                taskList.add(task);
            }
            if(pt.Master_Product_SetUp_Sheet_User__c != null && pt.Master_Product_SetUp_Sheet_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Master_Product_SetUp_Sheet_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Master_Product_SetUp_Sheet_Due_Date__c;
                task.CallObject = pt.id + '17';
                taskList.add(task);
            }
            if(pt.PDP_s_with_enhanced_content_User__c != null && pt.PDP_s_with_enhanced_content_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.PDP_s_with_enhanced_content_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.PDP_s_with_enhanced_content_Due_Date__c;
                task.CallObject = pt.id + '18';
                taskList.add(task);
            }
            if(pt.Product_photos_User__c != null && pt.Product_photos_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Product_photos_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Product_photos_Due_Date__c;
                task.CallObject = pt.id + '19';
                taskList.add(task);
            }
            if(pt.Tech_Specs_User__c != null && pt.Tech_Specs_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Tech_Specs_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Tech_Specs_Due_Date__c;
                task.CallObject = pt.id + '20';
                taskList.add(task);
            }
            if(pt.Digital_Ads_User__c != null && pt.Digital_Ads_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Digital_Ads_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Digital_Ads_Due_Date__c;
                task.CallObject = pt.id + '21';
                taskList.add(task);
            }
            if(pt.Online_Checklist_User__c != null && pt.Online_Checklist_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Online_Checklist_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Online_Checklist_Due_Date__c;
                task.CallObject = pt.id + '22';
                taskList.add(task);
            }
            if(pt.Training_Plans_User__c != null && pt.Training_Plans_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Training_Plans_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Training_Plans_Due_Date__c;
                task.CallObject = pt.id + '23';
                taskList.add(task);
            }
            if(pt.Expert_reviews_User__c != null && pt.Expert_reviews_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Expert_reviews_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Expert_reviews_Due_Date__c;
                task.CallObject = pt.id + '24';
                taskList.add(task);
            }
            if(pt.Consumer_reviews_User__c != null && pt.Consumer_reviews_Due_Date__c != null){
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Consumer_reviews_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Consumer_reviews_Due_Date__c;
                task.CallObject = pt.id + '25';
                taskList.add(task);
            }
            
        }
        Database.insert(taskList);
        
    }
    

    public override void beforeUpdate(){
        List<Task> taskList = new List<Task>();
        for (Planning_Task__c pt : ((list<Planning_Task__c>)Trigger.new)) {
            Planning_Task__c oldPt = (Planning_Task__c)Trigger.oldMap.get(pt.Id);
            if(oldPt.Revenue_Targets_User__c != pt.Revenue_Targets_User__c || oldPt.Revenue_Targets_Due_Date__c != pt.Revenue_Targets_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '1'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Revenue_Targets_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Revenue_Targets_Due_Date__c;
                task.CallObject = pt.id + '1';
                taskList.add(task);
            }
            if(oldPt.Category_Share_Goals_Targets_User__c != pt.Category_Share_Goals_Targets_User__c || oldPt.Category_Share_Goals_Targets_Due_Date__c != pt.Category_Share_Goals_Targets_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '2'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Category_Share_Goals_Targets_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Category_Share_Goals_Targets_Due_Date__c;
                task.CallObject = pt.id + '2';
                taskList.add(task);
            }
            if(oldPt.Pricing_User__c != pt.Pricing_User__c || oldPt.Pricing_Due_Date__c != pt.Pricing_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '3'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Pricing_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Pricing_Due_Date__c;
                task.CallObject = pt.id + '3';
                taskList.add(task);
            }
            if(oldPt.Assortment_recommendation_selection_User__c != pt.Assortment_recommendation_selection_User__c || oldPt.Assortment_Due_Date__c != pt.Assortment_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '4'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Assortment_recommendation_selection_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Assortment_Due_Date__c;
                task.CallObject = pt.id + '4';
                taskList.add(task);
            }
            if(oldPt.Training_Plans_User__c != pt.Training_Plans_User__c || oldPt.Training_Plans_Due_Date__c != pt.Training_Plans_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '5'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Training_Plans_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Training_Plans_Due_Date__c;
                task.CallObject = pt.id + '5';
                taskList.add(task);
            }
            if(oldPt.Competitor_benchmarking_User__c != pt.Competitor_benchmarking_User__c || oldPt.Competitor_benchmarking_Due_Date__c != pt.Competitor_benchmarking_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '6'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Competitor_benchmarking_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Competitor_benchmarking_Due_Date__c;
                task.CallObject = pt.id + '6';
                taskList.add(task);
            }
            if(oldPt.Map_UPP_Policy_review_User__c != pt.Map_UPP_Policy_review_User__c || oldPt.Map_UPP_Policy_review_Due_Date__c != pt.Map_UPP_Policy_review_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '7'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Map_UPP_Policy_review_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Map_UPP_Policy_review_Due_Date__c;
                task.CallObject = pt.id + '7';
                taskList.add(task);
            }
            if(oldPt.MDF_Budgets_User__c != pt.MDF_Budgets_User__c || oldPt.MDF_Budgets_Due_Date__c != pt.MDF_Budgets_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '8'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.MDF_Budgets_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.MDF_Budgets_Due_Date__c;
                task.CallObject = pt.id + '8';
                taskList.add(task);
            }
            if(oldPt.EOL_plans_User__c != pt.EOL_plans_User__c || oldPt.EOL_plans_Due_Date__c != pt.EOL_plans_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '9'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.EOL_plans_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.EOL_plans_Due_Date__c;
                task.CallObject = pt.id + '9';
                taskList.add(task);
            }
            if(oldPt.Program_Letters_VPA_s_User__c != pt.Program_Letters_VPA_s_User__c || oldPt.Program_Letters_VPA_s_Due_Date__c != pt.Program_Letters_VPA_s_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '10'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Program_Letters_VPA_s_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Program_Letters_VPA_s_Due_Date__c;
                task.CallObject = pt.id + '10';
                taskList.add(task);
            }
            if(oldPt.NPI_360_plans_User__c != pt.NPI_360_plans_User__c || oldPt.NPI_360_plans_Due_Date__c != pt.NPI_360_plans_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '11'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.NPI_360_plans_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.NPI_360_plans_Due_Date__c;
                task.CallObject = pt.id + '11';
                taskList.add(task);
            }
            if(oldPt.Sales_Information_User__c != pt.Sales_Information_User__c || oldPt.Sales_Information_Due_Date__c != pt.Sales_Information_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '12'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Sales_Information_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Sales_Information_Due_Date__c;
                task.CallObject = pt.id + '12';
                taskList.add(task);
            }
            if(oldPt.X6_Month_Customer_Forecasts_User__c != pt.X6_Month_Customer_Forecasts_User__c || oldPt.X6_Month_Customer_Forecasts_Due_Date__c != pt.X6_Month_Customer_Forecasts_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '13'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.X6_Month_Customer_Forecasts_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.X6_Month_Customer_Forecasts_Due_Date__c;
                task.CallObject = pt.id + '13';
                taskList.add(task);
            }
            if(oldPt.Customer_KPI_s_User__c != pt.Customer_KPI_s_User__c || oldPt.Customer_KPI_s_Due_Date__c != pt.Customer_KPI_s_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '14'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Customer_KPI_s_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Customer_KPI_s_Due_Date__c;
                task.CallObject = pt.id + '14';
                taskList.add(task);
            }
            if(oldPt.JBP_3_Year_Plans_User__c != pt.JBP_3_Year_Plans_User__c || oldPt.JBP_3_Year_Plans_Due_Date__c != pt.JBP_3_Year_Plans_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '15'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.JBP_3_Year_Plans_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.JBP_3_Year_Plans_Due_Date__c;
                task.CallObject = pt.id + '15';
                taskList.add(task);
            }
            if(oldPt.Online_Agreements_Auth_Reseller_User__c != pt.Online_Agreements_Auth_Reseller_User__c || oldPt.Online_Agreements_Auth_Reseller_Due__c != pt.Online_Agreements_Auth_Reseller_Due__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '16'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Online_Agreements_Auth_Reseller_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Online_Agreements_Auth_Reseller_Due__c;
                task.CallObject = pt.id + '16';
                taskList.add(task);
            }
            if(oldPt.Master_Product_SetUp_Sheet_User__c != pt.Master_Product_SetUp_Sheet_User__c || oldPt.Master_Product_SetUp_Sheet_Due_Date__c != pt.Master_Product_SetUp_Sheet_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '17'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Master_Product_SetUp_Sheet_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Master_Product_SetUp_Sheet_Due_Date__c;
                task.CallObject = pt.id + '17';
                taskList.add(task);
            }
            if(oldPt.PDP_s_with_enhanced_content_User__c != pt.PDP_s_with_enhanced_content_User__c || oldPt.PDP_s_with_enhanced_content_Due_Date__c != pt.PDP_s_with_enhanced_content_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '18'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.PDP_s_with_enhanced_content_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.PDP_s_with_enhanced_content_Due_Date__c;
                task.CallObject = pt.id + '18';
                taskList.add(task);
            }
            if(oldPt.Product_photos_User__c != pt.Product_photos_User__c || oldPt.Product_photos_Due_Date__c != pt.Product_photos_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '19'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Product_photos_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Product_photos_Due_Date__c;
                task.CallObject = pt.id + '19';
                taskList.add(task);
            }
            if(oldPt.Tech_Specs_User__c != pt.Tech_Specs_User__c || oldPt.Tech_Specs_Due_Date__c != pt.Tech_Specs_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '20'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Tech_Specs_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Tech_Specs_Due_Date__c;
                task.CallObject = pt.id + '20';
                taskList.add(task);
            }
            if(oldPt.Digital_Ads_User__c != pt.Digital_Ads_User__c || oldPt.Digital_Ads_Due_Date__c != pt.Digital_Ads_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '21'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Digital_Ads_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Digital_Ads_Due_Date__c;
                task.CallObject = pt.id + '21';
                taskList.add(task);
            }
            if(oldPt.Online_Checklist_User__c != pt.Online_Checklist_User__c || oldPt.Online_Checklist_Due_Date__c != pt.Online_Checklist_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '22'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Online_Checklist_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Online_Checklist_Due_Date__c;
                task.CallObject = pt.id + '22';
                taskList.add(task);
            }
            if(oldPt.Training_Plans_User__c != pt.Training_Plans_User__c || oldPt.Training_Plans_Due_Date__c != pt.Training_Plans_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '23'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Training_Plans_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Training_Plans_Due_Date__c;
                task.CallObject = pt.id + '23';
                taskList.add(task);
            }
            if(oldPt.Expert_reviews_User__c != pt.Expert_reviews_User__c || oldPt.Expert_reviews_Due_Date__c != pt.Expert_reviews_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '24'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Expert_reviews_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Expert_reviews_Due_Date__c;
                task.CallObject = pt.id + '24';
                taskList.add(task);
            }
            if(oldPt.Consumer_reviews_User__c != pt.Consumer_reviews_User__c || oldPt.Consumer_reviews_Due_Date__c != pt.Consumer_reviews_Due_Date__c){
                List<Task> delTask = [Select id From Task where CallObject = :pt.id + '25'];
                Database.delete(delTask);
                Task task = new Task();
                task.Subject = pt.name;
                task.OwnerId = pt.Consumer_reviews_User__c;
                task.WhatId = pt.id;
                task.ActivityDate = pt.Consumer_reviews_Due_Date__c;
                task.CallObject = pt.id + '25';
                taskList.add(task);
            }
            
        }
        Database.insert(taskList);
    }

}