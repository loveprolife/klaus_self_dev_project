public without sharing class StoreSelloutInventoryCMPController {

    public Class DataInfo{
        public String productLine;
        public Integer quantity;
        public Integer tStock;
        public Integer aStock;
        public Integer transit;
    }

    public Class DetailInfo{
        public String create_dt;
        public String productLine;
        public String cust_model;
        public Integer act_qty;
        public Integer Tot_SOH;
        public Integer Avl_SOH;
        public Integer st_intr;
        public Double Supportable_Days;
        public String Stock_Status;
    }

    public Class InitDataWarp{
        public List<DataInfo> dataList;
        public List<DetailInfo> detailList;
    }

    @AuraEnabled 
    public static String initDetail(String accId){
        InitDataWarp initData = new InitDataWarp();
        initData.detailList = new List<DetailInfo>();

        Map<String, String> prdln = Utility.getPicklistValueMap('Sell_out_Inventory__c','prdln__c');

        list<Sell_out_Inventory__c> soiList = [select cust_model__c,create_dt__c,prdln__c,act_qty__c,Tot_SOH__c,Avl_SOH__c,st_intr__c,Days_of_Inventory_w4__c from Sell_out_Inventory__c where Store__c =: accId order by create_dt__c desc];
        
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
            DetailInfo di = new DetailInfo();
            di.create_dt = soi.create_dt__c;
            di.productLine = prdln.get(soi.prdln__c);
            di.cust_model = soi.cust_model__c;
            if(soi.act_qty__c != null){
                di.act_qty = soi.act_qty__c.intValue();
            }else{
                di.act_qty = 0;
            }
            if(soi.Tot_SOH__c != null){
                di.Tot_SOH = soi.Tot_SOH__c.intValue();
            }else{
                di.Tot_SOH = 0;
            }
            if(soi.Avl_SOH__c != null){
                di.Avl_SOH = soi.Avl_SOH__c.intValue();
            }else{
                di.Avl_SOH = 0;
            }
            if(soi.st_intr__c != null){
                di.st_intr = soi.st_intr__c.intValue();
            }else{
                di.st_intr = 0;
            }
            
            di.Supportable_Days = Decimal.valueOf('0');
            if(soi.Days_of_Inventory_w4__c != null && soi.Days_of_Inventory_w4__c != 0){
                di.Supportable_Days = (Integer.valueOf(soi.Avl_SOH__c) / soi.Days_of_Inventory_w4__c).setScale(2);
            }
            
            if(soi.Days_of_Inventory_w4__c != null && soi.Days_of_Inventory_w4__c != 0){
                if(Integer.valueOf(soi.Avl_SOH__c) <= soi.Days_of_Inventory_w4__c){
                    di.Stock_Status = 'Out of Stock';
                }else if(Integer.valueOf(soi.Avl_SOH__c) > (soi.Days_of_Inventory_w4__c * 3)){
                    di.Stock_Status = 'Normal';
                }else{
                    di.Stock_Status = 'Replenishment';
                }
            }else{
                di.Stock_Status = 'Replenishment';
            }

            initData.detailList.add(di);
        }

        System.debug('initData==>>>' +initData);
        return JSON.serialize(initData);

        // component.set('v.productLineColumns', [
        //     { label: $A.get("$Label.c.create_dt"), fieldName: 'create_dt', type: 'text'},
        //     { label: $A.get("$Label.c.Product_Line"), fieldName: 'prdln', type: 'text'},
        //     { label: $A.get("$Label.c.cust_model"), fieldName: 'cust_model', type: 'text'},
        //     { label: $A.get("$Label.c.act_qty"), fieldName: 'act_qty', type: 'text'},
        //     { label: $A.get("$Label.c.Tot_SOH"), fieldName: 'Tot_SOH', type: 'text'},
        //     { label: $A.get("$Label.c.Avl_SOH"), fieldName: 'Avl_SOH', type: 'text'},
        //     { label: $A.get("$Label.c.st_intr"), fieldName: 'st_intr', type: 'text'},
        //     { label: $A.get("$Label.c.Supportable_Days"), fieldName: 'Supportable_Days', type: 'text'},
        //     { label: $A.get("$Label.c.Stock_Status"), fieldName: 'Stock_Status', type: 'text'}
        // ]);
    
    }
    @AuraEnabled 
    public static String initData(String accId){
        InitDataWarp initData = new InitDataWarp();
        initData.dataList = new List<DataInfo>();

        
        list<Sell_out_Inventory__c> soiList = [select cust_model__c,create_dt__c,prdln__c,act_qty__c,Tot_SOH__c,Avl_SOH__c,st_intr__c from Sell_out_Inventory__c where Store__c =: accId and prdln__c != null];

        String nowM = String.valueOf(System.today()).substring(0, 8) + '01';
        
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

        Set<String> plSet = new Set<String>();
        //Map<String, String> plMaxCD = new Map<String, String>();
        for(Sell_out_Inventory__c soi : soiList){

            if(plSet.add(soi.prdln__c)){

                //plMaxCD.put(soi.prdln__c, getMaxCD(accId, soi.prdln__c));

                DataInfo di = new DataInfo();
                di.productLine = soi.prdln__c;
                di.quantity = 0;
                di.tStock = 0;
                di.aStock = 0;
                di.transit = 0;
               
                if(soi.create_dt__c >= nowM){
                    di.quantity += Integer.valueOf(soi.act_qty__c);
                }

                if(soi.create_dt__c < maxMap.get(soi.cust_model__c)){
                }else{
                    di.tStock += Integer.valueOf(soi.Tot_SOH__c);
                    di.aStock += Integer.valueOf(soi.Avl_SOH__c);
                    di.transit += Integer.valueOf(soi.st_intr__c);
                }

                initData.dataList.add(di);
            }else{
                for(DataInfo di : initData.dataList){
                    if(di.productLine.equals(soi.prdln__c)){
                        if(soi.create_dt__c >= nowM){
                            di.quantity += Integer.valueOf(soi.act_qty__c);
                        }

                        if(soi.create_dt__c < maxMap.get(soi.cust_model__c)){
                            continue;
                        }
                        di.tStock += Integer.valueOf(soi.Tot_SOH__c);
                        di.aStock += Integer.valueOf(soi.Avl_SOH__c);
                        di.transit += Integer.valueOf(soi.st_intr__c);
                    }
                }
            }

            

            
        }

        Map<String, String> prdln = Utility.getPicklistValueMap('Sell_out_Inventory__c','prdln__c');
        List<DataInfo> resultDataList = new List<DataInfo>();
        
        for(DataInfo di : initData.dataList){
            if(String.isNotBlank(prdln.get(di.productLine))){
                di.productLine = prdln.get(di.productLine);
                resultDataList.add(di);
            }
        }

        initData.dataList = resultDataList;

        
        System.debug('initData==>>>' +initData);
        return JSON.serialize(initData);
    }

    // public static String getMaxCD(String accId, String prdln){
    //     AggregateResult[] maxCD = [select max(create_dt__c)create_dt__c from Sell_out_Inventory__c where Store__c =: accId and prdln__c =: prdln];

    //     if(maxCD.size() > 0){
    //         return (String)maxCD[0].get('create_dt__c');
    //     }

    //     return 'xxx';
    // }

}