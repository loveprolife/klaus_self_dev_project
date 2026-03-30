global class SetThaiActQtyBatch implements Database.Batchable<sObject>{

    public String create_dt;

    public SetThaiActQtyBatch() {

    }

    public SetThaiActQtyBatch(String create_dt) {
        this.create_dt = create_dt;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryS = 'select id from shop__c';
        return Database.getQueryLocator(queryS);
    }

    public Integer getSumInt(String cust_model, String startDt, list<Thai_Sell_out_Inventory__c> soiList){
        Integer i = 0;
        for(Thai_Sell_out_Inventory__c soi : soiList){
            if(soi.cust_model__c.equals(cust_model) && soi.create_dt__c >= startDt){
                i += Integer.valueOf(soi.act_qty__c);
            }
        }
        return i;

    }
    global void execute(Database.BatchableContext BC, list<shop__c> shopList) {//list<Thai_Sell_out_Inventory__c> soiList
        
        if(String.isBlank(create_dt)){
            list<Thai_Sell_out_Inventory__c> maxAr= [select create_dt__c from Thai_Sell_out_Inventory__c order by create_dt__c desc limit 1];
            create_dt = maxAr[0].create_dt__c;
        }

        String create_dt4 = String.valueOf(Date.valueOf(create_dt).addDays(-28));
        String create_dt6 = String.valueOf(Date.valueOf(create_dt).addDays(-42));
        list<Thai_Sell_out_Inventory__c> updateList = new list<Thai_Sell_out_Inventory__c>();
        for(shop__c shop : shopList){

            list<Thai_Sell_out_Inventory__c> soiList = [select cust_model__c,create_dt__c,act_qty__c,Avl_SOH__c,act_qty_w4__c,act_qty_w6__c,Days_of_Inventory_w4__c,Days_of_Inventory_w6__c from Thai_Sell_out_Inventory__c where Store__c = :shop.id and create_dt__c >= :create_dt6 and cust_model__c != null];
            
            Map<String, String> maxMap = new Map<String, String>();
            for(Thai_Sell_out_Inventory__c soi : soiList){
                if(maxMap.containsKey(soi.cust_model__c)){
                    if(soi.create_dt__c > maxMap.get(soi.cust_model__c)){
                        maxMap.put(soi.cust_model__c, soi.create_dt__c);
                    }
                }else{
                    maxMap.put(soi.cust_model__c, soi.create_dt__c);
                }
            }

            
            for(Thai_Sell_out_Inventory__c soi : soiList){
                if(soi.create_dt__c < maxMap.get(soi.cust_model__c)){
                    continue;
                }
                soi.act_qty_w4__c = getSumInt(soi.cust_model__c, create_dt4, soiList);

                if(soi.act_qty_w4__c == 0){
                    soi.Days_of_Inventory_w4__c = 0;
                }else{
                    soi.Days_of_Inventory_w4__c = Integer.valueOf(soi.Avl_SOH__c) / (soi.act_qty_w4__c / 28);
                }

                soi.act_qty_w6__c = getSumInt(soi.cust_model__c, create_dt6, soiList);

                if(soi.act_qty_w6__c == 0){
                    soi.Days_of_Inventory_w6__c = 0;
                }else{
                    soi.Days_of_Inventory_w6__c = Integer.valueOf(soi.Avl_SOH__c) / (soi.act_qty_w6__c / 28);
                }

                updateList.add(soi);
                
            }
        
        
        }

        if(updateList.size() > 0){
            update updateList;
        }

    }

    global void finish(Database.BatchableContext BC) {
        
    }

}