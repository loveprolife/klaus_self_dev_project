/**********************************************************************
* Name: CustomerProductLineYearRankUpdateBatch
* Object: customer Product Line 
* Purpose: 客户产品线年度排行更新
* Author: Johnson
* Create Date: 2019-04-22
*************************************************************************/
public class CustomerProductLineYearRankUpdateBatch implements Database.Batchable<sObject> {
    public String query;

    public CustomerProductLineYearRankUpdateBatch() {
        this.query = 'SELECT Id,Name,Rank__c,Rank_Of_Last_Year__c,Rank_Of_The_Year_Before_Last__c FROM Customer_Product_Line__c';
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Customer_Product_Line__c> proLineList) {
    	List<Customer_Product_Line__c> updateProLineList = new List<Customer_Product_Line__c>();
    	for(Customer_Product_Line__c proLine : proLineList){
    		Integer updateCount = 0;
    		//在年初更新客户产品线年度排行，将当前排行赋值到上一年度后置空
    		/* 如果Rank Of The Year Before Last, Rank Of Last Year, Rank不为空，分别对应以下赋值逻辑
    		*  1. Rank Of The Year Before Last = null
    		*  2. Rank Of Last Year => Rank Of The Year Before Last & Rank Of Last Year = null
    		*  3. Rank => Rank Of Last Year & Rank = null
    		*/
    		if(String.isNotBlank(proLine.Rank_Of_The_Year_Before_Last__c)){
    			proLine.Rank_Of_The_Year_Before_Last__c = null;
    			updateCount++ ;
    		}
            if(String.isNotBlank(proLine.Rank_Of_Last_Year__c)){
                proLine.Rank_Of_The_Year_Before_Last__c = proLine.Rank_Of_Last_Year__c;
                proLine.Rank_Of_Last_Year__c = null;
                updateCount++ ;
            }
            if(String.isNotBlank(proLine.Rank__c)){
            	proLine.Rank_Of_Last_Year__c = proLine.Rank__c;
            	proLine.Rank__c = null;
            	updateCount++ ;
            }
            if(updateCount > 0){
                updateProLineList.add(proLine);
            }

    	}
    	if(updateProLineList.size() > 0){
            update updateProLineList;
    	}
    }
    public void finish(Database.BatchableContext BC) {

    }

}