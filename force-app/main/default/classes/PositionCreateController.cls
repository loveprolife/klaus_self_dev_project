/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-15-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public with sharing class PositionCreateController {
    @AuraEnabled
    public static PositionTreeResult initGridding(String recordId) {
        PositionTreeResult result = new PositionTreeResult();
        // try {
            // result.columHeader = PositionCreateService.createColumnHeader();
            // result.gridData = PositionCreateService.createGridData(recordId);
            result.gridNewColumns = PositionCreateService.getNewGridding(recordId);
            System.debug(LoggingLevel.INFO, '*** result.gridNewColumn: ' + JSON.serializePretty(result.gridNewColumns));
            
            //获取产品线
            PositionCreateService.productLineMapWrapper plmw = PositionCreateService.getProductLinePiskListMap();
            result.productLineList = plmw.productLineList;
            
            //获取当前权限
            PositionTreeResult ptr = PositionCreateService.initCurrentDataItems(recordId, plmw.productLineList, plmw.productLineMap);
            
            // //查找当前岗位权限-客户产品线
            result.currentPermissionsGridDataList = ptr.currentPermissionsGridDataList;
            result.accProductLineList = ptr.accProductLineList;
            result.shopItemList = ptr.shopItemList;
            // wfc
            result.userList = ptr.userList;
            
            System.debug(LoggingLevel.INFO, '*** : result.currentPermissionsGridDataList' + result.currentPermissionsGridDataList);
            System.debug(LoggingLevel.INFO, '*** : result.accProductLineList' + result.accProductLineList);
            System.debug(LoggingLevel.INFO, '*** : result.shopItemList' + result.shopItemList);
        // } catch (Exception ex) {
        //     result.success = false;
        //     result.message = ex.getMessage();
        //     System.debug(LoggingLevel.INFO, '*** : getMessage' + ex.getMessage());
        //     System.debug(LoggingLevel.INFO, '*** : getLineNumber' + ex.getLineNumber());
        // }

        return result;
    }

    @AuraEnabled
    public static List<AccProductLine> addNewRow(String objStr) {
        List<AccProductLine> aplList = (List<AccProductLine>)JSON.deserialize(objStr, List<AccProductLine>.class);
        System.debug(LoggingLevel.INFO, '*** aplList: ' + aplList);
        if (!aplList.isEmpty()) {
            aplList.add(0, new AccProductLine());
        }else {
            aplList.add(new AccProductLine());
        }
        return aplList;
    }

    // @AuraEnabled
    // public static PositionTreeResult createGridding(
    //     String recordId, 
    //     String griddingId, 
    //     String actionType,
    //     List<String> gridSelectedRowsTemp,
    //     List<Map<String, Object>> gridData
    // ) {
    //     PositionTreeResult ptr = new PositionTreeResult();
    //     ptr.success = true;
    //     ptr.message = '';
    //     Map<String, Object> currentChooseMap = PositionCreateService.ParsingChooseGridding(gridData, griddingId);

    //     Boolean isLastLevel = false;

    //     List<String> chooseIdList = new List<String>();
    //     //正则匹配当前选择数据中的Id
    //     String currentChooseMapJSON = JSON.serialize(currentChooseMap);
    //     Matcher matcher = Pattern.compile('"key":"[\u4e00-\u9fa5_a-zA-Z0-9_]{18}').matcher(currentChooseMapJSON);
    //     while (matcher.find()) {
    //         chooseIdList.add(matcher.group().substring(7));

    //         // System.debug(LoggingLevel.INFO, '*** matcher.group().substring(2): ' + matcher.group().substring(7));
    //     }

    //     //是否当前已存在chooseIdList中的岗位网格权限, 存在的不进行Insert/进行删除
    //     Map<String, Position_Permissions__c> currentGriddingpermissionMap = PositionCreateService.getCurrentGriddingMap(chooseIdList, recordId);
    //     List<Position_Permissions__c> dmlPerList = new List<Position_Permissions__c>();
    //     try {
    //         if (actionType == 'insert') {
    //             for (Integer i = 0; i < chooseIdList.size(); i++) {
    //                 if (currentGriddingpermissionMap.containsKey(chooseIdList[i])) {
    //                     chooseIdList.remove(i);
    //                     continue;
    //                 }
    //                 gridSelectedRowsTemp.add(chooseIdList[i]);
    //                 Position_Permissions__c insertPer = new Position_Permissions__c();
    //                 insertPer.Position__c = recordId;
    //                 insertPer.Gridding__c = chooseIdList[i];
    //                 dmlPerList.add(insertPer);
    //             }
    //             if (!dmlPerList.isEmpty()) {
    //                 INSERT dmlPerList;
    //             }
    //         }else {
    //             for (Id currentGriddingId : currentGriddingpermissionMap.keySet()) {
    //                 dmlPerList.add(currentGriddingpermissionMap.get(currentGriddingId));
    //             }
    //             if (!dmlPerList.isEmpty()) {
    //                 DELETE dmlPerList;
    //             }
    //             Set<String> chooseIdSet = Utility.conversionStringList(chooseIdList);
    //             Set<String> gridSelectedRowsTempSet = Utility.conversionStringList(gridSelectedRowsTemp);
    //             for (Integer i = 0; i < chooseIdList.size(); i++) {
    //                 for (Integer j = 0; j < gridSelectedRowsTemp.size(); j++) {
    //                     if (chooseIdList[i] == gridSelectedRowsTemp[j]) {
    //                         gridSelectedRowsTemp.remove(j);
    //                         j--;
    //                     }
    //                 }
    //             }
                
    //         }

    //         System.debug(LoggingLevel.INFO, '*** gridSelectedRowsTemp: ' + gridSelectedRowsTemp);

    //         ptr.currentPermissionsGridDataList = Utility.conversionStringSet(Utility.conversionStringList(gridSelectedRowsTemp));
    //     } catch (Exception ex) {
    //         ptr.success = false;
    //         ptr.message = ex.getMessage();
    //     }

    //     return ptr;
    // }

    @AuraEnabled
    public static List<AccProductLine> changeAccoutFunction(String accId, String accProductLineListJSON, String recordId) {
        List<AccProductLine> accProductLineList = (List<AccProductLine>)JSON.deserialize(accProductLineListJSON, List<AccProductLine>.class);
        String deleteAccId = '';

        //获取客户产品线
        Set<String> accIdSet = new Set<String>{accId};
        Map<String, Map<String, String>> currentAccProductLineMap = PositionCreateService.getAccountProductLineList(accIdSet);
        Map<String, String> unDisableProLineMap = currentAccProductLineMap.get(accId);
        for (PositionCreateController.AccProductLine accProLine : accProductLineList) {
            if (String.isNotBlank(accId)) {
                if (accProLine.accId == accId) {
                    for (PositionCreateController.ProductLine pl : accProLine.productLineList) {
                        if (unDisableProLineMap.containsKey(pl.value)) {
                            pl.isDisable = false;
                        }
                        pl.accProductLineKey = accId + '_' + pl.value;
                    }
                }
            }else {
                
                //accId为空, 查找数据中accProductLineList 为空的行, 将其后台数据删除, 
                // isDisable = true,
                // istrue = false, 
                // accProductLineKey = '';
                if (String.isBlank(accProLine.accId)) {
                    for (PositionCreateController.ProductLine pl : accProLine.productLineList) {
                        if (String.isNotBlank(pl.accProductLineKey)) {
                            deleteAccId = pl.accProductLineKey.split('_')[0];
                        }
                        pl.isDisable = true;
                        pl.isTrue = false;
                        pl.accProductLineKey = '';
                    }
                }
                if (String.isNotBlank(deleteAccId)) {
                    break;
                }
            }
        }
        if (String.isNotBlank(deleteAccId)) {
            List<Position_Permissions__c> deletePosPerList = PositionCreateService.getPositionPermissionFromAccount(deleteAccId, recordId);
            if (!deletePosPerList.isEmpty()) {
                DELETE deletePosPerList;
            }
        }

        return accProductLineList;
    }

    @AuraEnabled
    public static PositionTreeResult checkProductLine(
        Boolean checkOutValue,  // checkOutValue 是否勾选,勾选/true, 取消勾选/false
        String accProductLineKey, //客户id_产品线Value Key值, spilt获取当前勾选的数据,后台实时进行增删
        List<AccProductLine> accProductLineList, //当前在编辑的所有客户产品线信息,若发生错误,将checkOutValue更新为相反数
        String positionId
    ){
        PositionTreeResult ptr = new PositionTreeResult();
        List<String> accProductLine = accProductLineKey.split('_');
        try {
            if (checkOutValue) {
                Position_Permissions__c upsertPosPer = new Position_Permissions__c();
                upsertPosPer.Account__c = accProductLine[0];
                upsertPosPer.Product_Line__c = accProductLine[1];
                upsertPosPer.External_Key_ID__c = accProductLine[0] + '-' + accProductLine[1] + '-' + positionId;
                upsertPosPer.Position__c = positionId;
                Database.upsert(upsertPosPer, Position_Permissions__c.External_Key_ID__c);
            }else {
                String accProductExternalKey = accProductLine[0] + '-' + accProductLine[1] + '-' + positionId;
                Position_Permissions__c deletePosPer = [SELECT Id 
                                                        FROM Position_Permissions__c 
                                                        WHERE External_Key_ID__c = :accProductExternalKey
                                                        AND Position__c = :positionId];
                DELETE deletePosPer;
            }
        } catch (Exception ex) {
            ptr.success = false;
            ptr.message = ex.getMessage();

            for (PositionCreateController.AccProductLine accProLine : accProductLineList) {
                if (accProLine.accId == accProductLine[0]) {
                    for (PositionCreateController.ProductLine pl : accProLine.productLineList) {
                        if (pl.value == accProductLine[1]) {
                            pl.isTrue = !checkOutValue;
                        }
                    }
                }
            }
        }
        ptr.accProductLineList = accProductLineList;

        return ptr;
    }

    @AuraEnabled
    public static PositionTreeResult deleteRowLine(String accRecordId, String recordId){
        System.debug(LoggingLevel.INFO, '*** accRecordId: ' + accRecordId);
        PositionTreeResult ptr = new PositionTreeResult();
        List<Position_Permissions__c> deletePosPerList = PositionCreateService.getPositionPermissionFromAccount(accRecordId, recordId);
        try {
            if (!deletePosPerList.isEmpty()) {
                DELETE deletePosPerList;
            }
        } catch (Exception ex) {
            ptr.success = false;
            ptr.message = ex.getMessage();
            System.debug(LoggingLevel.INFO, '*** ptr.success: ' + ptr.success);
            System.debug(LoggingLevel.INFO, '*** ptr.message: ' + ptr.message);
        }

        return ptr;
    }

    @AuraEnabled
    public static PositionTreeResult searchActionFunction(Map<String, String> shopSearchMap, List<String> noIncludingGridIdList){
        PositionTreeResult ptr = new PositionTreeResult();
        List<ShopWrapper> shopSearchItemList = new List<ShopWrapper>();
        // String shopName = '%' + shopSearchMap.get('shopName') + '%';
        // String accountName = '%' + shopSearchMap.get('accountName') + '%';
        // String griddingName = '%' + shopSearchMap.get('griddingName') + '%';

        String shopName = shopSearchMap.get('shopName');
        String accountName = shopSearchMap.get('accountName');
        String griddingName = shopSearchMap.get('griddingName');

        try {
            for (Shop__c shop : PositionCreateService.getSearchShopList(shopName, accountName, griddingName, noIncludingGridIdList)) {
                ShopWrapper sw = new ShopWrapper();
                sw.icon = 'utility:add';
                sw.value = false;
                sw.shopName = shop.Name;
                sw.accountName = shop.Account__r.Name;
                sw.griddingName = shop.Grid__r.Name;
                sw.shopExternalKeyID = shop.Id;
                sw.positionPermissionId = '';
                shopSearchItemList.add(sw);
            }
        } catch (Exception ex) {
            ptr.success = false;
            ptr.message = ex.getMessage();
        }
        ptr.shopSearchItemList = shopSearchItemList;

        return ptr;
    }

    @AuraEnabled
    public static PositionTreeResult chooseShopFunction(String currentShopId, String recordId, String shopSearchListJSON, String shopListJSON){
        PositionTreeResult ptr = new PositionTreeResult();
        List<ShopWrapper> shopSearchList = (List<ShopWrapper>)JSON.deserialize(shopSearchListJSON, List<ShopWrapper>.class);
        List<ShopWrapper> shopList = (List<ShopWrapper>)JSON.deserialize(shopListJSON, List<ShopWrapper>.class);
        try {
            for (Integer i = 0; i < shopSearchList.size(); i++) {
                if (shopSearchList[i].shopExternalKeyID == currentShopId) {
                    if (shopList.isEmpty()) {
                        shopList.add(shopSearchList[i]);
                    }else {
                        shopList.add(0, shopSearchList[i]);
                    }
                    shopSearchList[i].icon = 'utility:dash';
                    shopSearchList.remove(i);
                    i--;
                }
            }
            Position_Permissions__c posPer = new Position_Permissions__c();
            posPer.Position__c = recordId;
            posPer.Shop__c = currentShopId;
            INSERT posPer;
        } catch (Exception ex) {
            ptr.success = false;
            ptr.message = ex.getMessage();
            System.debug(LoggingLevel.INFO, '*** ptr.success: ' + ptr.success);
            System.debug(LoggingLevel.INFO, '*** ptr.message: ' + ptr.message);
        }
        ptr.shopItemList = shopList;
        ptr.shopSearchItemList = shopSearchList;

        return ptr;
    }

    @AuraEnabled
    public static PositionTreeResult unChooseShopFunction(
        String currentShopId, 
        String recordId, 
        String shopSearchListJSON, 
        String shopListJSON,
        Map<String, String> shopSearchMap
    ){
        PositionTreeResult ptr = new PositionTreeResult();
        List<ShopWrapper> shopSearchList = (List<ShopWrapper>)JSON.deserialize(shopSearchListJSON, List<ShopWrapper>.class);
        List<ShopWrapper> shopList = (List<ShopWrapper>)JSON.deserialize(shopListJSON, List<ShopWrapper>.class);
        List<ShopWrapper> shopReusltList =  new List<ShopWrapper>();
        System.debug(LoggingLevel.INFO, '*** shopList: ' + shopList);
        List<String> noIncludingGridIdList = new List<String>();
        try {
            for (Integer i = 0; i < shopList.size(); i++) {
                if (shopList[i].shopExternalKeyID == currentShopId) {
                    shopList[i].icon = 'utility:add';
                    if (shopSearchList.isEmpty()) {
                        shopSearchList.add(shopList[i]);
                    }else {
                        shopSearchList.add(0, shopList[i]);
                    }
                    // shopList.remove(i);
                    // i--;
                }else {
                    shopReusltList.add(shopList[i]);
                    noIncludingGridIdList.add(shopList[i].shopExternalKeyID);
                }
            }
            Position_Permissions__c posPer = [SELECT Id FROM Position_Permissions__c WHERE Shop__c = :currentShopId AND Position__c = :recordId];

            DELETE posPer;

        } catch (Exception ex) {
            ptr.success = false;
            ptr.message = ex.getMessage();
        }
        ptr.shopItemList = shopReusltList;
        ptr.shopSearchItemList = shopSearchList;

        return ptr;
    }

    @AuraEnabled
    public static List<shopGriddingWrapper> openOrCloseGridding(
        String currentgridNewColumnsJson, 
        String currentId,
        String currentIconName,
        String currentName
    ){

        List<shopGriddingWrapper> aplList = (List<shopGriddingWrapper>)JSON.deserialize(currentgridNewColumnsJson, List<shopGriddingWrapper>.class);

        List<String> griddingIdList = new List<String>();
        if (currentIconName == 'utility:chevrondown') {
            for (Gridding__c gri : [SELECT Id,Gridding_Recursion_ID__c FROM Gridding__c WHERE Id != :currentId]) {
                if (gri.Gridding_Recursion_ID__c.contains(currentId.left(15))) {
                    griddingIdList.add(gri.Id);
                }
            }

            for (shopGriddingWrapper apl : aplList) {
                if (!griddingIdList.isEmpty() && griddingIdList.contains(apl.recordId)) {
                    apl.rowStyle = false;
                    apl.iconName = 'utility:chevronright';
                }
                if (apl.recordId == currentId) {
                    apl.iconName = 'utility:chevronright';
                }
            }
        }

        if (currentIconName == 'utility:chevronright') {
            for (shopGriddingWrapper apl : aplList) {
                if (apl.recordId == currentId) {
                    apl.iconName = 'utility:chevrondown';
                }

                if (apl.parentId == currentId) {
                    apl.rowStyle = true;
                }
            }
        }

        System.debug(LoggingLevel.INFO, '*** aplList: ' +  JSON.serializePretty(aplList));
        return aplList;
    }

    public static void hiddenNextGridding(String recordId, List<shopGriddingWrapper> aplList){
        List<String> aplIdList = new List<String>();
        for (shopGriddingWrapper apl : aplList) {
            if (apl.recordId == recordId) {
                apl.rowStyle = false;
                apl.iconName = 'utility:chevronright';
                aplIdList.add(apl.recordId);
            }
        }

        if (!aplIdList.isEmpty()) {
            for (String strRecordId : aplIdList) {
                hiddenNextGridding(strRecordId, aplList);
            }
        }
    }

    @AuraEnabled
    public static PositionTreeResult checkGriddingFunction(
        String currentgridNewColumnsJSON, 
        Boolean currentValue, 
        String currentGridding, 
        String recordId
    ){
        System.debug(LoggingLevel.INFO, '*** : currentgridNewColumnsJSON' + currentgridNewColumnsJSON);
        System.debug(LoggingLevel.INFO, '*** currentValue: ' + currentValue);
        System.debug(LoggingLevel.INFO, '*** currentGridding: ' + currentGridding);
        PositionTreeResult ptr = new PositionTreeResult();
        List<shopGriddingWrapper> aplList = (List<shopGriddingWrapper>)JSON.deserialize(currentgridNewColumnsJson, List<shopGriddingWrapper>.class);

        List<Position_Permissions__c> posPerList = new List<Position_Permissions__c>();

        try {

            //选中操作
            if (currentValue) {
                for (shopGriddingWrapper sgw : aplList) {
                    if (sgw.griExternalId.contains(currentGridding.left(15))) {
                        Position_Permissions__c posPer = new Position_Permissions__c();
                        posPer.External_Key_ID__c = sgw.recordId + '-' + recordId;
                        posPer.Gridding__c = sgw.recordId;
                        posPer.Position__c = recordId;
                        posPerList.add(posPer);
    
                        sgw.isChoose = true;
                    }
                }
    
                System.debug(LoggingLevel.INFO, '*** posPerList: ' + posPerList);
                if (!posPerList.isEmpty()) {
                    Database.upsert(posPerList, Position_Permissions__c.External_Key_ID__c);
                }
            }else {
                List<String> griddingIdList = new List<String>();
                for (shopGriddingWrapper sgw : aplList) {
                    if (sgw.griExternalId.contains(currentGridding.left(15))) {
                        griddingIdList.add(sgw.recordId);
                        sgw.isChoose = false;
                    }
                }
    
                List<Position_Permissions__c> deletePosList = [SELECT Id FROM Position_Permissions__c WHERE Gridding__c IN :griddingIdList];
                if (!deletePosList.isEmpty()) {
                    DELETE deletePosList;
                }
            }
            ptr.gridNewColumns = aplList;
        } catch (Exception ex) {
            ptr.success = false;
            ptr.message = ex.getMessage();
        }

        return ptr;
    }

    public class PositionTreeResult {
        @AuraEnabled public Boolean success {GET; SET;}
        @AuraEnabled public String message {GET; SET;}
        @AuraEnabled public List<Map<String, Object>> columHeader {GET; SET;}

        //网格
        @AuraEnabled public List<Map<String, Object>> gridData {GET; SET;}
        @AuraEnabled public List<String> currentPermissionsGridDataList {GET; SET;} //当前权限中的网格数据
        @AuraEnabled public Map<String, String> gridMap {GET;SET;} //所有网格键对值

        //新网格
        @AuraEnabled public List<shopGriddingWrapper> gridNewColumns {GET; SET;}

        //客户产品线
        @AuraEnabled public List<AccProductLine> accProductLineList {GET; SET;}
        @AuraEnabled public List<ProductLine> productLineList {GET; SET;}

        //搜索的门店
        @AuraEnabled public List<ShopWrapper> shopSearchItemList {GET; SET;}

        //权限中的门店
        @AuraEnabled public List<ShopWrapper> shopItemList {GET; SET;}

        //权限中的人员 wfc
         @AuraEnabled public List<UserWrapper> userList {GET; SET;}

        public PositionTreeResult() {
            this.success = true;
            this.message = '';
            this.columHeader = new List<Map<String, Object>>();
            this.gridData = new List<Map<String, Object>>();
            this.currentPermissionsGridDataList = new List<String>();
            this.gridMap = new Map<String, String>();
            this.accProductLineList = new List<AccProductLine>();
            this.productLineList = new List<ProductLine>();
            this.shopSearchItemList = new List<ShopWrapper>();
            this.shopItemList = new List<ShopWrapper>();
            this.gridNewColumns = new List<shopGriddingWrapper>();
            this.userList = new List<UserWrapper>();
        }
    }

    public class AccProductLine {
        @AuraEnabled public String accId;
        @AuraEnabled public List<ProductLine> productLineList;

        public AccProductLine() {
            this.accId = '';
            this.productLineList = PositionCreateService.getProductLinePiskListMap().productLineList;
        }
    }

    public class ProductLine {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean isTrue;
        @AuraEnabled public Boolean isDisable;
        @AuraEnabled public String accProductLineKey;

        public ProductLine() {
            this.label = '';
            this.value = '';
            this.isTrue = false;
            this.isDisable = true;
            this.accProductLineKey = '';
        }
    }

    public class shopWrapper {
        @AuraEnabled public String icon;
        @AuraEnabled public Boolean value;
        @AuraEnabled public String shopName;
        @AuraEnabled public String shopExternalKeyID;
        @AuraEnabled public String accountName;
        @AuraEnabled public String griddingName;
        @AuraEnabled public String positionPermissionId;

        public shopWrapper(){
            this.icon = '';
            this.value = true;
            this.shopName = '';
            this.shopExternalKeyID = '';
            this.accountName = '';
            this.griddingName = '';
            this.positionPermissionId = '';
        }
    }

    public class shopGriddingWrapper {
        @AuraEnabled public String recordId;
        @AuraEnabled public String name;
        @AuraEnabled public String iconName;
        @AuraEnabled public String parentId;
        @AuraEnabled public Boolean rowStyle;
        @AuraEnabled public String nameStyle;
        @AuraEnabled public Boolean isChoose;
        @AuraEnabled public String griExternalId;

        public shopGriddingWrapper(){
            this.recordId = '';
            this.name = '';
            this.iconName = '';
            this.parentId = '';
            this.rowStyle = false;
            this.nameStyle = '';
            this.isChoose = false;
            this.griExternalId = '';
        }
    }

    public class UserWrapper {
        @AuraEnabled public String userName;
        @AuraEnabled public String roleName;


        public UserWrapper(){
            this.userName = '';
            this.roleName = '';
        }
    }
}