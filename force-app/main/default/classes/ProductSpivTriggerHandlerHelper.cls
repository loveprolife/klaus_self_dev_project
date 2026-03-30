/**
 * @description       : 
 * @author            : fausfeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 25-07-2023
 * @last modified by  : fausfeng@deloitte.com.cn
**/
public with sharing class ProductSpivTriggerHandlerHelper {
    //检查插入列表自身的数据是否冲突
    public static void checkNewSpiv(List<ProductSpiv__c> newList){
        //boolean flag = true;
        for(Integer i = 0; i<newList.size();i++){
            for(Integer j = 0; j<newList.size(); j++ ){
                if(i != j){
                    if((newList[i].Product__c == newList[j].Product__c)&&(newList[i].Sales_Region__c == newList[j].Sales_Region__c)){
                        if((newList[i].StartTime__c > newList[j].StartTime__c && newList[i].StartTime__c < newList[j].EndTime__c)||(newList[i].EndTime__c > newList[j].StartTime__c && newList[i].EndTime__c < newList[j].EndTime__c)||(newList[i].StartTime__c == newList[j].StartTime__c && newList[i].EndTime__c == newList[j].EndTime__c)){
                        	if((newList[i].IsActive__c == true)&&(newList[j].IsActive__c == true)){
                                newList[j].addError( System.Label.SpivError);
                            	//flag = false;
                        	}  	
                    	}
                    }
                }
            }
        }
        //return flag;
    }
    //检查插入时提成数据是否与已有数据冲突
    public static void checkSpiv(List<ProductSpiv__c> newList){
        //Boolean flag = true;
        List<String> proList = new List<String>();
        List<String> areaList = new List<String>();
        for(ProductSpiv__c spiv : newList){
			proList.add(spiv.Product__c); 
            areaList.add(spiv.Sales_Region__c);
        }
        List<ProductSpiv__c> getSpivList = [select Name,Product__c,Product__r.Name,StartTime__c,Sales_Region__c,EndTime__c From ProductSpiv__c Where Product__c in :proList AND Sales_Region__c in :areaList AND IsActive__c = true];
    	Map<String,List<ProductSpiv__c>> getMap = new Map<String,List<ProductSpiv__c>>();
        for(ProductSpiv__c spivTest : getSpivList){
            String mapString = String.valueOf(spivTest.Product__c)+String.valueOf(spivTest.Sales_Region__c);
            if(getMap.get(mapString) == null){
                List<ProductSpiv__c> putList = new List<ProductSpiv__c>();
                putList.add(spivTest);
                getMap.put(mapString,putList);
            }else{
                getMap.get(mapString).add(spivTest);
            }
        }
        for(ProductSpiv__c newSpiv : newList){
        	String newString = String.valueOf(newSpiv.Product__c)+String.valueOf(newSpiv.Sales_Region__c);
            if(getMap.get(newString)!=null){
                for(ProductSpiv__c getSpiv : getMap.get(newString)){
                    if((newSpiv.StartTime__c > getSpiv.StartTime__c && newSpiv.StartTime__c < getSpiv.EndTime__c)||(newSpiv.EndTime__c > getSpiv.StartTime__c && newSpiv.EndTime__c < getSpiv.EndTime__c)||(newSpiv.StartTime__c == getSpiv.StartTime__c && newSpiv.EndTime__c == getSpiv.EndTime__c)||(newSpiv.StartTime__c < getSpiv.StartTime__c && newSpiv.EndTime__c > getSpiv.EndTime__c)){
                        if(newSpiv.IsActive__c == true){
                            newSpiv.addError(System.Label.SpivTikOne+getSpiv.Name+System.Label.SpivTikTwo+ getSpiv.Sales_Region__c +System.Label.SpivTikThree+ getSpiv.Product__r.Name+System.Label.SpivError);
                            //flag = false;
                        }  	
                    }
                }
            }
        }
        //return flag;
    }
    //检查更新提成数据是否与其他数据冲突
    public Static void checkUpdateSpiv(List<ProductSpiv__c> newList){
		//Boolean flag = true;
        List<String> proList = new List<String>();
        List<String> areaList = new List<String>();
        List<String> idList = new List<String>();
        for(ProductSpiv__c spiv : newList){
            idList.add(spiv.Id);
			proList.add(spiv.Product__c); 
            areaList.add(spiv.Sales_Region__c);
        }
        List<ProductSpiv__c> getSpivList = [select Name,Product__c,Product__r.Name,StartTime__c,Sales_Region__c,EndTime__c From ProductSpiv__c Where Product__c in :proList AND Sales_Region__c in :areaList AND IsActive__c = true AND id not in :idList];
    	Map<String,List<ProductSpiv__c>> getMap = new Map<String,List<ProductSpiv__c>>();
        for(ProductSpiv__c spivTest : getSpivList){
            String mapString = String.valueOf(spivTest.Product__c)+String.valueOf(spivTest.Sales_Region__c);
            if(getMap.get(mapString) == null){
                List<ProductSpiv__c> putList = new List<ProductSpiv__c>();
                putList.add(spivTest);
                getMap.put(mapString,putList);
            }else{
                getMap.get(mapString).add(spivTest);
            }
        }
        for(ProductSpiv__c newSpiv : newList){
        	String newString = String.valueOf(newSpiv.Product__c)+String.valueOf(newSpiv.Sales_Region__c);
            if(getMap.get(newString)!=null){
                for(ProductSpiv__c getSpiv : getMap.get(newString)){
                    if((newSpiv.StartTime__c > getSpiv.StartTime__c && newSpiv.StartTime__c < getSpiv.EndTime__c)||(newSpiv.EndTime__c > getSpiv.StartTime__c && newSpiv.EndTime__c < getSpiv.EndTime__c)||(newSpiv.StartTime__c == getSpiv.StartTime__c && newSpiv.EndTime__c == getSpiv.EndTime__c)||(newSpiv.StartTime__c < getSpiv.StartTime__c && newSpiv.EndTime__c > getSpiv.EndTime__c)){
                        if(newSpiv.IsActive__c == true){
                            newSpiv.addError(System.Label.SpivTikOne+getSpiv.Name+System.Label.SpivTikTwo+ getSpiv.Sales_Region__c +System.Label.SpivTikThree+ getSpiv.Product__r.Name +System.Label.SpivError);
                            //flag = false;
                        }  	
                    }
                }
            }
        }
        //return flag;
    }
}