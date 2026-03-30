/******************************************************************************
 ************************
 * Name: StoreNameCheckBatch
 * Description:  门店名称模糊查重，区分Sales_Region__c
 * TestClassName:  StoreNameCheckBatchTest
 * Version History: 0.01
 * Date: 2024-11-13
 * Author: lizunxing
 * Comments: 
 *******************************************************************************
 **************************/
public class StoreNameCheckBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{

    
    public Integer flg = 1;
    public Set<String> setRegion;
    public StoreNameCheckBatch() {}


    public Database.QueryLocator start(Database.BatchableContext BC) {
        setRegion = new Set<String>();
        String queryS = 'select Id, Name, Sales_Region__c, Address1__c from Shop__c order by Sales_Region__c';
        return Database.getQueryLocator(queryS);
    }

    public void execute(Database.BatchableContext BC, list<Shop__c> shopList) {

        for(Shop__c shop : shopList){

            if(!setRegion.add(shop.Name + shop.Sales_Region__c)){
                continue;
            }

            List<Duplicate_Store__c> line = new List<Duplicate_Store__c>();
            Duplicate_Store__c ds = new Duplicate_Store__c();
            ds.Store__c = shop.Id;
            ds.Store_Name__c = shop.Name;
            ds.Sales_Region__c = shop.Sales_Region__c;
            ds.Address1__c = shop.Address1__c;
            ds.Sort__c = flg + '';
            line.add(ds);
            String name = '%'+shop.Name+'%';
            List<Shop__c> sl = [select Id, Name, Sales_Region__c, Address1__c from Shop__c where Name like :name and Sales_Region__c = :shop.Sales_Region__c];
            if(sl.size() > 1){
                Set<String> srSet = new Set<String>();
                srSet.add(shop.Sales_Region__c);
                for(Shop__c s : sl){
                    if(!srSet.add(s.Sales_Region__c) && !shop.Id.equals(s.Id)){
                        Duplicate_Store__c dse = new Duplicate_Store__c();
                        dse.Store__c = s.Id;
                        dse.Store_Name__c = s.Name;
                        dse.Sales_Region__c = s.Sales_Region__c;
                        dse.Address1__c = s.Address1__c;
                        dse.Sort__c = flg + '';
                        line.add(dse);
                    }
                }
            }
            if(line.size() > 1){
                Database.insert(line);
                flg++;
            }
        }
    }

    public void finish(Database.BatchableContext BC) {}

    /**
    @description create a CSV file from a list of Strings each string should be a row
    */
    // public static void createCSV(List<String> csvHeaders, List<String> csvRowList, String title){
    //     String headerRow = String.join(csvHeaders,',') + '\n';
    //     String concantenatedStr = headerRow;
    //     Integer i = 0;
    //     Integer rowListSize = csvRowList.size();
    //     //assuming the rowList is in the correct format and each object in the list is a new record
    //     for(String row :csvRowList){
           
    //         i++;
    //         concantenatedStr += (String)row + ((i != rowListSize) ? '\n' : '');//add new line
    //     }
    //     title += '.xls';
    //     createFile(concantenatedStr, title);
    // }

    /**
    @description create a file - generic
    */
    // public static void createFile(String versionData, String title) {
    //     ContentVersion cv = new ContentVersion();
    //     cv.ContentLocation = 'S'; //denotes it resides on Salesforce
    //     cv.Title = title; //title of the file
    //     cv.PathOnClient = title; // full path within Salesforce this can just be the name of file to be in the library
    //     cv.VersionData = Blob.valueOf(versionData); //file data
    //     insert cv;
    // }

}