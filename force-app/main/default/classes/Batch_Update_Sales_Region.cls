//String sql = 'select Id,Sales_Region_Text__c from Login_History__c where Sales_Region_Text__c != null';
//Id batchInstanceId = Database.executeBatch(new Batch_Update_Sales_Region(sql), 200);
global class Batch_Update_Sales_Region implements Database.Batchable<sObject> {
    public String query;

    global Batch_Update_Sales_Region(string query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        set<String> set_name = new set<String>();
        for(Sobject obj : scope)
        {
            IF(obj.getSObjectType() == Login_History__c.SobjectType)
            {
                if(obj.get('Sales_Region_Text__c') != null)
                {
                    set_name.add(String.valueOf(obj.get('Sales_Region_Text__c')));
                }
            }
            IF(obj.getSObjectType() == Retail_Number__c.SobjectType)
            {
                if(obj.get('Store_Sales_Region__c') != null)
                {
                    set_name.add(String.valueOf(obj.get('Store_Sales_Region__c')));
                }
            }
        }
        list<Sales_Region__c> list_sales = [select Id,Name from Sales_Region__c where Name in:set_name];
        map<String,Sales_Region__c> map_sales = new map<String,Sales_Region__c>();
        for(Sales_Region__c sale : list_sales)
        {
            map_sales.put(sale.Name,sale);
        }
        for(Sobject obj : scope)
        {
            IF(obj.getSObjectType() == Login_History__c.SobjectType)
            {
                if(obj.get('Sales_Region_Text__c') != null)
                {
                    if(map_sales.containsKey(String.valueOf(obj.get('Sales_Region_Text__c'))))
                    {
                        obj.put('Sales_Region__c',map_sales.get(String.valueOf(obj.get('Sales_Region_Text__c'))).Id);
                    }
                }
            }
            IF(obj.getSObjectType() == Retail_Number__c.SobjectType)
            {
                if(obj.get('Store_Sales_Region__c') != null)
                {
                    if(map_sales.containsKey(String.valueOf(obj.get('Store_Sales_Region__c'))))
                    {
                        obj.put('Sales_Region_Lookup__c',map_sales.get(String.valueOf(obj.get('Store_Sales_Region__c'))).Id);
                    }
                }
            }
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC) {
    }
}