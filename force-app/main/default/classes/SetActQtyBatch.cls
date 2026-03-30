global class SetActQtyBatch implements Database.Batchable<sObject>{

    public String create_dt;

    public SetActQtyBatch() {

    }

    public SetActQtyBatch(String create_dt) {
        this.create_dt = create_dt;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        //String create_dt = String.valueOf(System.today().addDays(-7));
        //String queryS = 'SELECT Id,ch_store_no__c,cust_model__c,act_qty__c,create_dt__c,act_qty_w4__c,act_qty_w6__c,Avl_SOH__c,Days_of_Inventory_w4__c,Days_of_Inventory_w6__c FROM Sell_out_Inventory__c where create_dt__c >= :create_dt';
        String queryS = 'select id from shop__c';
        return Database.getQueryLocator(queryS);

    }

    public Integer getSumInt(String cust_model, String startDt, list<Sell_out_Inventory__c> soiList){
        Integer i = 0;
        for(Sell_out_Inventory__c soi : soiList){
            if(soi.cust_model__c.equals(cust_model) && soi.create_dt__c >= startDt){
                i += Integer.valueOf(soi.act_qty__c);
            }
        }
        return i;

    }
    global void execute(Database.BatchableContext BC, list<shop__c> shopList) {//list<Sell_out_Inventory__c> soiList
        
        if(String.isBlank(create_dt)){
            list<Sell_out_Inventory__c> maxAr= [select create_dt__c from Sell_out_Inventory__c order by create_dt__c desc limit 1];
            create_dt = maxAr[0].create_dt__c;
        }

        String create_dt4 = String.valueOf(Date.valueOf(create_dt).addDays(-28));
        String create_dt6 = String.valueOf(Date.valueOf(create_dt).addDays(-42));
        list<Sell_out_Inventory__c> updateList = new list<Sell_out_Inventory__c>();
        for(shop__c shop : shopList){

            list<Sell_out_Inventory__c> soiList = [select cust_model__c,create_dt__c,act_qty__c,Avl_SOH__c,act_qty_w4__c,act_qty_w6__c,Days_of_Inventory_w4__c,Days_of_Inventory_w6__c from Sell_out_Inventory__c where Store__c = :shop.id and create_dt__c >= :create_dt6 and cust_model__c != null];
            
            Map<String, String> maxMap = new Map<String, String>();
            for(Sell_out_Inventory__c soi : soiList){
                if(maxMap.containsKey(soi.cust_model__c)){
                    if(soi.create_dt__c > maxMap.get(soi.cust_model__c)){
                        maxMap.put(soi.cust_model__c, soi.create_dt__c);
                    }
                }else{
                    maxMap.put(soi.cust_model__c, soi.create_dt__c);
                }
            }

            
            for(Sell_out_Inventory__c soi : soiList){
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
        
        
        // if(String.isNotBlank(create_dt)){
        //     list<Sell_out_Inventory__c> maxAr= [select create_dt__c from Sell_out_Inventory__c where create_dt__c >= :create_dt order by create_dt__c desc limit 1];
        //     create_dt = maxAr[0].create_dt__c;
        // }

        

        // list<Sell_out_Inventory__c> updateList = new list<Sell_out_Inventory__c>();
        // for(Sell_out_Inventory__c soi : soiList){

        //     list<Sell_out_Inventory__c> soiSearchList2 = [select id,act_qty__c from Sell_out_Inventory__c where create_dt__c >= :create_dt4 and ch_store_no__c = :soi.ch_store_no__c and cust_model__c = :soi.cust_model__c and act_qty__c != 0];
        //     if(soiSearchList2 != null && soiSearchList2.size() > 0){
        //         soi.act_qty_w4__c = 0;
        //         for(Sell_out_Inventory__c soi2 : soiSearchList2){
        //             if(soi2.act_qty__c != null && soi2.act_qty__c != 0){
        //                 soi.act_qty_w4__c = soi.act_qty_w4__c + soi2.act_qty__c;
        //             }
        //         }
        //         if(soi.act_qty_w4__c == 0){
        //             soi.Days_of_Inventory_w4__c = 0;
        //         }else{
        //             soi.Days_of_Inventory_w4__c = Integer.valueOf(soi.Avl_SOH__c) / (soi.act_qty_w4__c / 28);
        //         }
                
        //     }

        //     list<Sell_out_Inventory__c> soiSearchList4 = [select id,act_qty__c from Sell_out_Inventory__c where create_dt__c >= :create_dt6 and ch_store_no__c = :soi.ch_store_no__c and cust_model__c = :soi.cust_model__c and act_qty__c != 0];
        //     if(soiSearchList4 != null && soiSearchList4.size() > 0){
        //         soi.act_qty_w6__c = 0;
        //         for(Sell_out_Inventory__c soi4 : soiSearchList4){
        //             if(soi4.act_qty__c != null && soi4.act_qty__c != 0){
        //                 soi.act_qty_w6__c = soi.act_qty_w6__c + soi4.act_qty__c;
        //             }
        //         }
        //         if(soi.act_qty_w6__c == 0){
        //             soi.Days_of_Inventory_w6__c = 0;
        //         }else{
        //             soi.Days_of_Inventory_w6__c = Integer.valueOf(soi.Avl_SOH__c) / (soi.act_qty_w6__c / 42);
        //         }
        //     }
            
        //     updateList.add(soi);
        // }

        // update updateList;

    }

    global void finish(Database.BatchableContext BC) {
        
    }

}