/*
 * @Author: Su,Tiger Shanhu
 * @Date: 2023-06-27 16:10:01
 * @LastEditors: WFC
 * @LastEditTime: 2023-10-18 13:47:52
 * @Description: 获取checklist
 */
public without sharing  class CheckListController {
    public CheckListController() {

    }

    public static ConResponse getCheckList(String shopId,String inspectorId) {
        return getCheckList(shopId, inspectorId, false);
    }

    @AuraEnabled
    public static ConResponse getCheckList(String shopId,String inspectorId, Boolean isRemotedInspect) {
        if (isRemotedInspect == null) {
            isRemotedInspect = false;
        }

        //根据获取门店的信息
        System.debug('shopId--' + shopId +' inspectorId--'+inspectorId);
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        try {
            Map<String, List<CheckItem__c>> resultMap = new Map<String, List<CheckItem__c>>();
            Shop__c shopDb = [select Id,Name,Shop_Level__c,Account__r.Sales_Region__c, Sales_Region__c, City__c, Account__c, Account_Name__c from Shop__c  WHERE id =:shopId];
           // 匹配角色
            List<Responsible_Person__c> personRoleList = [SELECT Id, Name, Shop_Name__c, Principal__c, RecordType__c 
            FROM Responsible_Person__c 
            WHERE Principal__c = :inspectorId AND Shop_Name__c = :shopId AND RecordType__c !='促销员'];
            String role ;
            if(personRoleList.size() != 0) {
                role = personRoleList[0].RecordType__c;
                if(role == '巡店员' || role == 'Backup Floorwalker') {
                    role = 'Floorwalker';
                } 
            }
            //get all CheckListScope information
            List<CheckItem__c> checlistVo = new List<CheckItem__c>();
            Set<String> productLinSet = new Set<String>();
            Set<String> checkItemSet = new Set<String>();
           /*for (CheckListScope__c checkListScope : [select Id,CheckItem__c,Role__c, Country__c, Store__c,CheckItem__r.Product_Line__c, CheckItem__r.Description__c,CheckItem__r.Project__c,CheckItem__r.ShowYesNo__c,CheckItem__r.MaximumScore__c,CheckItem__r.HasFile__c,OrderNumber__c from CheckListScope__c WHERE Country__c=:shopDb.Account__r.Guarantor_Country_Code__c]) {
                if (String.isNotEmpty(checkListScope.Role__c) && checkListScope.Role__c != inspector.UserRole.DeveloperName) {
                    continue;
                }
                if (String.isNotEmpty(checkListScope.Store__c) && checkListScope.Store__c != shopDb.Id) {
                    continue;
                }
                productLinSet.add(checkListScope.CheckItem__r.Product_Line__c);
                checlistVo.add(checkListScope);
            }
            */
            for (CheckListScope__c checkListScope : [select Id, CheckItem__c, Role__c, Sales_Region__c, Store__c, Customer__c, CheckItem__r.Product_Line__c from CheckListScope__c WHERE Sales_Region__c =:shopDb.Sales_Region__c and Active__c = true and CheckItem__r.Check_Item_Type__c = '巡店']) {
                if (String.isNotEmpty(checkListScope.Role__c) && checkListScope.Role__c != role) {
                    continue;
                }
                if (String.isNotEmpty(checkListScope.Store__c) && checkListScope.Store__c != shopDb.Id) {
                    continue;
                }
                if (String.isNotEmpty(checkListScope.Customer__c) && checkListScope.Customer__c != shopDb.Account__c) {
                    continue;
                }
                productLinSet.add(checkListScope.CheckItem__r.Product_Line__c);
                checkItemSet.add(checkListScope.CheckItem__c);
            }
            if (checkItemSet.size()>0) {
                checlistVo = [select Id, Name, Product_Line__c, Project__c, MaximumScore__c, HasFile__c, Description__c, HelpText__c, IsYesOrNo__c,IsCountInScore__c,Sales_Region__c,Is_Related_To_Product__c from CheckItem__c  WHERE Id =:checkItemSet AND Is_Remote_Inspection__c = :isRemotedInspect];
            }
            if (checlistVo.size()>0) {
                for (String productLin : productLinSet) {
                    List<CheckItem__c> checklist = new LisqContainer(checlistVo).WhereOne('Product_Line__c','=',productLin).ToSobjectList();
                    if (String.isNotEmpty(productLin)) {
                        resultMap.put(productLin,checklist);
                    }else {
                        resultMap.put('General',checklist);
                    }
                }
                resp.data = resultMap;
                for(String key : resultMap.keyset()) {
                    System.debug('key：' + key);
                    System.debug('resultMap' + resultMap.get(key));
                }
            }else {
                System.debug('getCheckList failed,there is no data');
            }
        } catch (Exception e) {
            System.debug('getCheckList has a error:'+ e.getMessage() +'line:' +e.getLineNumber());
        }
        System.debug('resp======>'+resp);
        return resp;
    }


    @AuraEnabled
    public static ConResponse getStoreCheckList(String storeId) {
        System.debug('storeId---' + storeId);
        ConResponse resp = new ConResponse();
        Map<string, object> mso = new Map<string, object>();
        Shop__c shopDb = [select Id, Name, Shop_Level__c, Account__r.Sales_Region__c, Sales_Region__c, City__c, Account__c, Account_Name__c from Shop__c  WHERE id =:storeId];
        List<CheckListScope__c> checkListScopeList = [select Id, CheckItem__c, Role__c, Sales_Region__c,  Store__c, Customer__c, CheckItem__r.Product_Line__c from CheckListScope__c WHERE Sales_Region__c=:shopDb.Sales_Region__c and Active__c = true and CheckItem__r.Check_Item_Type__c = '巡店'];
        LisqContainer lc = new LisqContainer(checkListScopeList).WhereOr(new object[]{
            'Store__c','IsBlank','',
            'Store__c','=',shopDb.Id            
        });
        lc = lc.WhereOr(new object[]{
            'Customer__c','IsBlank','',
            'Customer__c','=',shopDb.Account__c            
        });
        System.debug('lc---' + JSON.serialize(lc));
        List<String> checkItemIdList = lc.selectsField('CheckItem__c');
        System.debug('getStoreCheckList ——> checkItemIdList：' + checkItemIdList);
        List<CheckItem__c> checkItemList = [SELECT Description__c, Id, Name, Product_Line__c, Project__c, MaximumScore__c, HasFile__c, Active__c, Sales_Region__c, HelpText__c,IsCountInScore__c
                                                FROM CheckItem__c
                                                WHERE Id IN :checkItemIdList];
        mso.put('checkItemList', checkItemList);
        
        resp.data = mso;
        return resp;
    }

    // @AuraEnabled
    // public static ConResponse getReportCheckList(String storeId, String userId) {
    //     ConResponse resp = new ConResponse();
    //     Map<string, object> mso = new Map<string, object>();

    //     // 匹配国家

    //     // 匹配门店
    //     List<CheckItem__c> storeCheckList = (List<CheckItem__c>)((Map<string, Object>)getStoreCheckList(storeId).data).get('checkItemList');
    //     Map<Id, CheckItem__c> storeCheckIdList = new Map<Id, CheckItem__c>(storeCheckList);

    //     // 匹配角色
    //     List<Responsible_Person__c> personRoleList = [SELECT Id, Name, Shop_Name__c, Principal__c, RecordType__c 
    //                                                     FROM Responsible_Person__c 
    //                                                     WHERE Principal__c = :userId AND Shop_Name__c = :storeId];
    //     List<CheckItem__c> roleCheckList = new List<CheckItem__c>();
    //     if(personRoleList.size() != 0) {
    //         String role = personRoleList[0].RecordType__c;
    //         if(role == '巡店员') {
    //             role = 'Floorwalker';
    //         } 
    //         List<CheckListScope__c> checkListScopeList = [SELECT CheckItem__c, Id, Name, Role__c, Country__c, Store__c, Customer__c 
    //                                                         FROM CheckListScope__c
    //                                                         WHERE Store__c = :storeId AND (Role__c = :role OR Role__c = '')];
    //         LisqContainer checkScopelc = new LisqContainer(checkListScopeList);
    //         List<String> checkIdList = checkScopelc.selectsField('CheckItem__c');
    //         System.debug('getReportCheckList ——> personRoleList ——> checkIdList：' + checkIdList);
    //         roleCheckList = [SELECT Description__c, Id, Name, Product_Line__c, Project__c, MaximumScore__c, HasFile__c, Active__c, Country__c, HelpText__c
    //                             FROM CheckItem__c
    //                             WHERE Id IN :checkIdList AND Id NOT IN:storeCheckIdList.keyset()];
    //     }
        
    //     List<CheckItem__c> checkList = new List<CheckItem__c>();
    //     Map<String, LisqContainer> checkListGroupByProductLine = new Map<String, LisqContainer>();
    //     if(storeCheckList.size()!=0 || roleCheckList.size()!=0) {
    //         checkList.addAll(storeCheckList);
    //         checkList.addAll(roleCheckList);
    //         System.debug('getReportCheckList ——> checkList.size()：' + checkList.size());
    //         LisqContainer lc = new LisqContainer(checkList);
    //         checkListGroupByProductLine = lc.GroupByS('Product_Line__c');
    //     }

    //     mso.put('checkListGroupByProductLine', checkListGroupByProductLine);
    //     resp.data = mso;
    //     return resp;
    // }

    
    // public static void testClassMethod() {
    //     Integer i = 0;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    //     i++;
    // }
}