public without sharing class StoreSamplingAnalysisController {

    public Class DataInfo{
        public String productLine;
        public Decimal realQuantity;
        public Decimal quantity;
        public String sampleRate;
    }

    public Class InitDataWarp{
        public List<DataInfo> dataList;
    }

    @AuraEnabled 
    public static String initData(String accId){
        InitDataWarp initData = new InitDataWarp();
        initData.dataList = new List<DataInfo>();

        list<Sampling_Detail__c> sdList = [select id,Product__c, Product__r.Product_Line__c, Unplanned_Sample__c, Is_Add__c, Display_Status__c from Sampling_Detail__c where Shop__c =: accId];
        
        Set<String> plSet = new Set<String>();
        for(Sampling_Detail__c sd : sdList){
            if(String.isBlank(sd.Product__c) || String.isBlank(sd.Product__r.Product_Line__c)){
                continue;
            }
            if(plSet.add(sd.Product__r.Product_Line__c)){
                DataInfo di = new DataInfo();
                di.productLine = sd.Product__r.Product_Line__c;

                if('是'.equals(sd.Is_Add__c)){
                    di.quantity = 1;
                }else{
                    di.quantity = 0;
                }

                if('是'.equals(sd.Is_Add__c) && '展出'.equals(sd.Display_Status__c)){
                    di.realQuantity = 1;
                }else{
                    di.realQuantity = 0;
                }
                
                initData.dataList.add(di);
            }else{
                for(DataInfo di : initData.dataList){
                    if(di.productLine.equals(sd.Product__r.Product_Line__c)){
                        if('是'.equals(sd.Is_Add__c)){
                            di.quantity += 1;
                        }
                        
                        if('是'.equals(sd.Is_Add__c) && '展出'.equals(sd.Display_Status__c)){
                            di.realQuantity += 1;
                        }
                    }
                    
                }
            }
        }

        for(DataInfo di : initData.dataList){
            if(di.quantity <= 0){
                di.sampleRate = '0.00%';
            }else{
                di.sampleRate = (di.realQuantity * 100).divide(di.quantity,2)  + '%';
            }
        }
        System.debug('initData==>>>' +initData);
        return JSON.serialize(initData);
    }

}