/**********************************************************************
* 名称: ShopCreateExternalKeyHandler
* 功能: 
* 门店trigger
* Author: wfc hisence
* Create Date: 2022-01-11
*************************************************************************/
public without sharing class ShopCreateExternalKeyHandler implements Triggers.Handler{
    public void handle() {

        if ((Trigger.isBefore && Trigger.isInsert) || (Trigger.isBefore && Trigger.isUpdate)) {
            Map<String, String> accIdMap = new Map<String, String>();
            Map<String, String> shopIdMap = new Map<String, String>();
            for (Shop__c shop : (List<Shop__c>)Trigger.new) {
                accIdMap.put(shop.Account__c, '');
                shopIdMap.put(shop.Grid__c, '');

                if (String.isNotBlank(shop.External_Key_ID__c) && shop.External_Key_ID__c.length() != 10) {
                    Integer numberZero = 0;
                    String addStrCode = '';

                    numberZero = 10 - shop.External_Key_ID__c.length();
                    for (Integer i = 0; i < numberZero; i++) {
                        addStrCode = addStrCode + '0';
                    }

                    shop.External_Key_ID__c = addStrCode + shop.External_Key_ID__c;
                }
            }

            for (Account acc : [SELECT SAP_Customer_Code__c FROM Account WHERE Id IN :accIdMap.keySet()]) {
                accIdMap.put(acc.Id, acc.SAP_Customer_Code__c);
            }

            for (Gridding__c gri : [SELECT Parent_Gridding__c, 
                                           Gridding_Code__c,
                                           Gridding_All__c 
                                    FROM Gridding__c 
                                    WHERE id IN :shopIdMap.keySet()]) {
                shopIdMap.put(gri.Id, gri.Gridding_All__c);
            }

            for (Shop__c shop : (List<Shop__c>)Trigger.new) {

                //若用户输入的数字长度不足5位，则系统应在保存时自动在输入的数字前面补充“0”，直到5位
                // String storeNo = shop.Store_No_from_Account__c; 
                // if(String.isNotBlank(storeNo) && storeNo.length() < 5){
                //     for (Integer i = 1; i <= 5 - storeNo.length(); i++) {
                //         shop.Store_No_from_Account__c = '0' + shop.Store_No_from_Account__c;
                //     }
                // }

                // 门店编码由系统自动生成，组成内容：｛客户编码+网格编码+门店渠道编号｝。
                // 当门店中的“客户”、“网格”、“门店渠道编号”字段都有值时进行首次编码生成，
                // 当“客户”、“网格”、“门店渠道编号”字段的值发生变化时重新生成。
                if(String.isNotBlank(shop.Account__c) && String.isNotBlank(shop.Grid__c) && String.isNotBlank(shop.Store_No_from_Account__c)){
                    // String gridAll = '';
                    // gridAll = getGridAll(shop.Grid__c, gridAll);
                    // Account acc = [Select SAP_Customer_Code__c from Account where id =: shop.Account__C];
                    String SAPCustomerCode = accIdMap.get(shop.Account__c);
                    shop.Shop_External_Key__c = SAPCustomerCode + '_' + shopIdMap.get(shop.Grid__c) + '_' + shop.Store_No_from_Account__c;
                }else {
                    shop.Shop_External_Key__c = '';
                }
                
                // 门店地址位置为空经纬度为空
                String addressNew = (String.isNotBlank(shop.City__c)?shop.City__c:'') + (String.isNotBlank(shop.Address1__c)?shop.Address1__c:'');
                if(String.isBlank(addressNew)){
                    shop.Shop_Center_Location__Latitude__s = null;
                    shop.Shop_Center_Location__Longitude__s = null;
                }
            }
        }

        if (Trigger.isAfter) {
            // Map<String, String> shopMap = new Map<String, String>();
            Map<Id,Shop__c> oldShopMap = (Map<Id,Shop__c>)Trigger.oldMap;
            List<Shop__c> shopList = new List<Shop__c>();
            for (Shop__c shop : (List<Shop__c>)Trigger.new) {
                String addressNew = shop.City__c + shop.Address1__c;
                if (String.isNotBlank(addressNew)) {
                    if (Trigger.isInsert) {
                        shopList.add(shop);
                    }else if (Trigger.isUpdate) {
                        Shop__c shopOld = (Shop__c)Trigger.oldMap.get(shop.Id);
                        String addressOld = shopOld.City__c + shopOld.Address1__c;
                        if(!addressOld.equals(addressNew)){
                            shopList.add(shop);
                        }
                    }
                }
            }

            // 异步调用google map接口
            if(!shopList.isEmpty()){
                Map<Integer, List<Shop__c>> shopJobList = splitMap(shopList, 100);
                Map<String, String> shopMap = new Map<String, String>();

                if (!Test.isRunningTest()) {
                    System.enqueueJob(new AsyncGoogleMap(shopJobList, 0));
                }
            }
        }
    }

    public static Map<Integer, List<Shop__c>> splitMap(List<Shop__c> shopList, Integer groupSize){
        Integer sObjectListLength = shopList.size();
        Integer num = (sObjectListLength + groupSize - 1) / groupSize;
        Map<Integer, List<Shop__c>> shopJobIntegerList = new Map<Integer, List<Shop__c>>();
        for (Integer i = 0; i < num; i++) {
            List<Shop__c> lookUpShopList = new List<Shop__c>();

            // 开始位置
            Integer fromIndex = i * groupSize;

            //结束
            Integer toIndex = (i+1) * groupSize < sObjectListLength ? ( i+1 ) * groupSize : sObjectListLength ;
            for (Integer j = fromIndex; j < toIndex; j++) {
                lookUpShopList.add(shopList[j]);
            }
            shopJobIntegerList.put(i, lookUpShopList);
        }
        return  shopJobIntegerList;
    }
}