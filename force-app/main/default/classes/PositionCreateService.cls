/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-08-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public withOut sharing class PositionCreateService {
    // public static List<Map<String, Object>> createColumnHeader() {
    //     List<Map<String, Object>> columnHeader = new List<Map<String, Object>>();
    //     columnHeader.add(new Map<String, Object>{'type' => 'text', 'label' => '网格名称', 'fieldName' => 'name'});
    //     return columnHeader;
    // }

    // public static List<Map<String, Object>> createGridData(String recordId) {
    //     List<Map<String, Object>> gridData = new List<Map<String, Object>>();
    //     Map<String, Map<String, Object>> gridMap = new Map<String, Map<String, Object>>();

    //     Map<String, List<Gridding__c>> griddingListMap = new Map<String, List<Gridding__c>>();
    //     for (Gridding__c grid : PositionCreateService.getGridList2()) {
    //         String parentGraddingCode;
    //         if (grid.Parent_Gridding__c == null) {
    //             parentGraddingCode = 'N';
    //         }else {
    //             parentGraddingCode = grid.Parent_Gridding__c;
    //         }
    //         if (griddingListMap.containsKey(parentGraddingCode)) {
    //             griddingListMap.get(parentGraddingCode).add(grid);
    //         }else {
    //             griddingListMap.put(parentGraddingCode, new List<Gridding__c>{grid});
    //         }
    //     }

    //     // Map<String, Object> griddingIterationListMap = new Map<String, Object>();

    //     if (!griddingListMap.isEmpty()) {
    //         for (Gridding__c gri : griddingListMap.get('N')) {
    
    //             //第一层网格结构
    //             Map<String, Object> root = new Map<String, Object>();
    //             root.put('key', gri.Id);
    //             root.put('name', String.valueOf(gri.get('Name')));
    //             root.put('parentId', String.valueOf(gri.get('Parent_Gridding__c')));
    //             root.put('netpr', String.valueOf(gri.get('GriddingLevel')));
    //             root.put('expanded','N');
    //             root.put('_children', new List<Map<String, Object>>());
    //             gridData.add(root);
    //         }
    //     }

    //     for (Integer i = 0; i < gridData.size(); i++) {
    //         Map<String, Object> root = gridData[i];
    //         String objkey = String.valueOf(root.get('key'));

    //         System.debug(LoggingLevel.INFO, '*** objkey: ' + objkey);

    //         if (griddingListMap.containsKey(objkey)) {
    //             List<Map<String, Object>> nodes = new List<Map<String, Object>>();
    //             for (Gridding__c gri : griddingListMap.get(objkey)) {
    //                 Map<String, Object> row = new Map<String, Object>();
    //                 row.put('key', gri.Id);
    //                 row.put('name', String.valueOf(gri.get('Name')));
    //                 row.put('netpr', String.valueOf(gri.get('GriddingLevel')));
    //                 row.put('expanded','N');

    //                 List<Map<String, Object>> nodes2 = new List<Map<String, Object>>();
    //                 if (griddingListMap.containsKey(gri.Id)) {
    //                     for (Gridding__c gri2 : griddingListMap.get(gri.Id)) {
    //                         Map<String, Object> row2 = new Map<String, Object>();
    //                         row2.put('key', gri2.Id);
    //                         row2.put('name', String.valueOf(gri2.get('Name')));
    //                         row2.put('netpr', String.valueOf(gri2.get('GriddingLevel')));
    //                         row2.put('expanded','N');
                            
    //                         List<Map<String, Object>> nodes3 = new List<Map<String, Object>>();
    //                         if (griddingListMap.containsKey(gri2.Id)) {
    //                             for (Gridding__c gri3 : griddingListMap.get(gri2.Id)) {
    //                                 Map<String, Object> row3 = new Map<String, Object>();
    //                                 row3.put('key', gri3.Id);
    //                                 row3.put('name', gri3.Name);
    //                                 System.debug(LoggingLevel.INFO, '*** String.valueOf ' + gri3.Name);
    //                                 row3.put('netpr', String.valueOf(gri3.get('GriddingLevel')));
    //                                 row3.put('expanded','N');

    //                                 List<Map<String, Object>> nodes4 = new List<Map<String, Object>>();
    //                                 if (griddingListMap.containsKey(gri3.Id)) {
    //                                     for (Gridding__c gri4 : griddingListMap.get(gri3.Id)) {
    //                                         Map<String, Object> row4 = new Map<String, Object>();
    //                                         row4.put('key', gri4.Id);
    //                                         row4.put('name', gri4.Name);
    //                                         System.debug(LoggingLevel.INFO, '*** String.valueOf ' + gri4.Name);
    //                                         row4.put('netpr', String.valueOf(gri4.get('GriddingLevel')));
    //                                         row4.put('expanded','N');

    //                                         List<Map<String, Object>> nodes5 = new List<Map<String, Object>>();
    //                                         if (griddingListMap.containsKey(gri4.Id)) {
    //                                             for (Gridding__c gri5 : griddingListMap.get(gri4.Id)) {
    //                                                 Map<String, Object> row5 = new Map<String, Object>();
    //                                                 row5.put('key', gri5.Id);
    //                                                 row5.put('name', gri5.Name);
    //                                                 System.debug(LoggingLevel.INFO, '*** String.valueOf ' + gri5.Name);
    //                                                 row5.put('netpr', String.valueOf(gri5.get('GriddingLevel')));
    //                                                 row5.put('expanded','N');
                                                    
    //                                                 List<Map<String, Object>> nodes6 = new List<Map<String, Object>>();
    //                                                 if (griddingListMap.containsKey(gri5.Id)) {
    //                                                     for (Gridding__c gri6 : griddingListMap.get(gri5.Id)) {
    //                                                         Map<String, Object> row6 = new Map<String, Object>();
    //                                                         row6.put('key', gri6.Id);
    //                                                         row6.put('name', gri6.Name);
    //                                                         System.debug(LoggingLevel.INFO, '*** String.valueOf ' + gri6.Name);
    //                                                         row6.put('netpr', String.valueOf(gri6.get('GriddingLevel')));
    //                                                         row6.put('expanded','N');
    //                                                         nodes6.add(row6);
    //                                                     }
    //                                                     row5.put('_children', nodes6);
    //                                                 }
    //                                                 nodes5.add(row5);
    //                                             }
    //                                             row4.put('_children', nodes5);
    //                                         }
    //                                         nodes4.add(row4);
    //                                     }
    //                                     row3.put('_children', nodes4);
    //                                 }
    //                                 nodes3.add(row3);
    //                             }
    //                             row2.put('_children', nodes3);
    //                         }
    //                         nodes2.add(row2);
    //                     }
    //                     row.put('_children', nodes2);
    //                 }
    //                 nodes.add(row);
    //             }
    //             root.put('_children', nodes);
    //         }
    //     }

    //     System.debug(LoggingLevel.INFO, '*** gridData: ' + gridData);
    //     return gridData;
    // }

    public static List<PositionCreateController.shopGriddingWrapper> getNewGridding(String recordId){
        List<Map<String, Object>> gridData = new List<Map<String, Object>>();
        Map<String, Map<String, Object>> gridMap = new Map<String, Map<String, Object>>();

        Map<String, List<Gridding__c>> griddingListMap = new Map<String, List<Gridding__c>>();

        //获取当前岗位网格
        List<String> griddingChooseList = new List<String>();
        List<Position_Permissions__c> posList = getPositionItemList(recordId);
        for (Position_Permissions__c pos : getPositionItemList(recordId)) {
            if (String.isNotBlank(pos.Gridding__c)) {
                griddingChooseList.add(pos.Gridding__c);
            }
        }
        for (Gridding__c grid : PositionCreateService.getGridList2()) {
            String parentGraddingCode;
            if (grid.Parent_Gridding__c == null) {
                parentGraddingCode = 'N';
            }else {
                parentGraddingCode = grid.Parent_Gridding__c;
            }
            if (griddingListMap.containsKey(parentGraddingCode)) {
                griddingListMap.get(parentGraddingCode).add(grid);
            }else {
                griddingListMap.put(parentGraddingCode, new List<Gridding__c>{grid});
            }
        }

        //构建网格
        List<PositionCreateController.shopGriddingWrapper> posGriddingList = new List<PositionCreateController.shopGriddingWrapper>();
        
        if (!griddingListMap.isEmpty()) {
            for (Gridding__c gri : griddingListMap.get('N')) {
    
                //第一层网格结构
                PositionCreateController.shopGriddingWrapper ps = newSGW(
                    String.valueOf(gri.get('Name')), 
                    gri.Id,
                    'utility:chevrondown',
                    String.valueOf(gri.get('Parent_Gridding__c')),
                    '',
                    true,
                    griddingChooseList,
                    String.valueOf(gri.get('Gridding_Recursion_ID__c'))
                );
                posGriddingList.add(ps);

                //第二层网格
                String objkey2 = gri.Id;
                if (griddingListMap.containsKey(objkey2)) {
                    for (Gridding__c gri2 : griddingListMap.get(objkey2)) {
                        PositionCreateController.shopGriddingWrapper ps2 = newSGW(
                            String.valueOf(gri2.get('Name')), 
                            gri2.Id,
                            'utility:chevronright',
                            String.valueOf(gri2.get('Parent_Gridding__c')),
                            'margin-left:15px;',
                            true,
                            griddingChooseList,
                            String.valueOf(gri2.get('Gridding_Recursion_ID__c'))
                        );
                        posGriddingList.add(ps2);

                        //第三层网格
                        String objkey3 = gri2.Id;
                        if (griddingListMap.containsKey(objkey3)) {
                            for (Gridding__c gri3 : griddingListMap.get(objkey3)) {
                                PositionCreateController.shopGriddingWrapper ps3 = newSGW(
                                    String.valueOf(gri3.get('Name')), 
                                    gri3.Id,
                                    'utility:chevronright',
                                    String.valueOf(gri3.get('Parent_Gridding__c')),
                                    'margin-left:30px;',
                                    false,
                                    griddingChooseList,
                                    String.valueOf(gri3.get('Gridding_Recursion_ID__c'))
                                );
                                posGriddingList.add(ps3);

                                //第四层网格
                                String objkey4 = gri3.Id;
                                if (griddingListMap.containsKey(objkey4)) {
                                    for (Gridding__c gri4 : griddingListMap.get(objkey4)) {
                                        PositionCreateController.shopGriddingWrapper ps4 = newSGW(
                                            String.valueOf(gri4.get('Name')), 
                                            gri4.Id,
                                            'utility:chevronright',
                                            String.valueOf(gri4.get('Parent_Gridding__c')),
                                            'margin-left:45px;',
                                            false,
                                            griddingChooseList,
                                            String.valueOf(gri4.get('Gridding_Recursion_ID__c'))
                                        );
                                        posGriddingList.add(ps4);

                                        //第五层网格
                                        String objkey5 = gri4.Id;
                                        if (griddingListMap.containsKey(objkey5)) {
                                            for (Gridding__c gri5 : griddingListMap.get(objkey5)) {
                                                PositionCreateController.shopGriddingWrapper ps5 = newSGW(
                                                    String.valueOf(gri5.get('Name')), 
                                                    gri5.Id,
                                                    'utility:chevronright',
                                                    String.valueOf(gri5.get('Parent_Gridding__c')),
                                                    'margin-left:60px;',
                                                    false,
                                                    griddingChooseList,
                                                    String.valueOf(gri5.get('Gridding_Recursion_ID__c'))
                                                );
                                                posGriddingList.add(ps5);

                                                //第六层网格
                                                String objkey6 = gri5.Id;
                                                if (griddingListMap.containsKey(objkey6)) {
                                                    for (Gridding__c gri6 : griddingListMap.get(objkey6)) {
                                                        PositionCreateController.shopGriddingWrapper ps6 = newSGW(
                                                            String.valueOf(gri6.get('Name')), 
                                                            gri6.Id,
                                                            'utility:chevronright',
                                                            String.valueOf(gri6.get('Parent_Gridding__c')),
                                                            'margin-left:75px;',
                                                            false,
                                                            griddingChooseList,
                                                            String.valueOf(gri6.get('Gridding_Recursion_ID__c'))
                                                        );
                                                        posGriddingList.add(ps6);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        System.debug(LoggingLevel.INFO, '*** posGriddingList: ' + posGriddingList.size());
        System.debug(LoggingLevel.INFO, '*** posGriddingList: ' + JSON.serializePretty(posGriddingList));

        return posGriddingList;
    }

    public static List<Map<String, Object>> asyncLoadBomNode(String key) {
        List<Map<String, Object>> nodes = new List<Map<String, Object>>();
        System.debug(LoggingLevel.INFO, '*** key: ' + key);
        System.debug(LoggingLevel.INFO, '*** getGridList(key): ' + getGridList(key));
        for (Gridding__c grid : getGridList(key)) {
            Map<String, Object> row = new Map<String, Object>();
            row.put('key', grid.Id);
            row.put('name', String.valueOf(grid.get('Name')));
            row.put('netpr', String.valueOf(grid.get('GriddingLevel')));
            Decimal emcSum = 0;
            row.put('expanded','N');
            row.put('_children', new List<Map<String, Object>>());
            nodes.add(row);
        }
        return nodes;
    }

    public static PositionCreateController.PositionTreeResult initCurrentDataItems(
        String recordId, 
        List<PositionCreateController.ProductLine> productLineList,
        Map<String, String> productLineMap
    ) {
        PositionCreateController.PositionTreeResult initCurrentDataItemsObj = new PositionCreateController.PositionTreeResult();

        //客户产品线
        List<PositionCreateController.AccProductLine> accProductLineList = new List<PositionCreateController.AccProductLine>();

        //网格
        List<String> graddingList = new List<String>();

        //门店
        List<PositionCreateController.ShopWrapper> shopItemList = new List<PositionCreateController.ShopWrapper>();

        List<Position_Permissions__c> positionItemList = PositionCreateService.getPositionItemList(recordId);

        //当前权限客户
        Set<String> accIdSet = new Set<String>();

        //当前用户 wfc
        List<PositionCreateController.UserWrapper> userList = new List<PositionCreateController.UserWrapper>();

        for (Position_Permissions__c per : positionItemList) {
            if (String.isNotBlank(per.Account__c) && String.isNotBlank(per.Product_Line__c)) {
                accIdSet.add(per.Account__c);
            }

            if (String.isNotBlank(per.Gridding__c)) {
                graddingList.add(per.Gridding__c);
            }

            if (String.isNotBlank(per.Shop__c)) {
                PositionCreateController.ShopWrapper pccsw = new PositionCreateController.ShopWrapper();
                pccsw.icon = 'utility:dash';
                pccsw.value = true;
                pccsw.shopName = per.Shop__r.Name;
                pccsw.accountName = per.Shop__r.Account__r.Name;
                pccsw.griddingName = per.Shop__r.Grid__r.Name;
                pccsw.shopExternalKeyID = per.Shop__c;
                pccsw.positionPermissionId = per.Id;
                shopItemList.add(pccsw);
            }
            // wfc
            if(String.isNotBlank(per.User__c)){
                PositionCreateController.UserWrapper userw = new PositionCreateController.UserWrapper(); 
                userw.userName = per.User__r.Name;
                userw.roleName = per.User__r.UserRole.name ;
                userList.add(userw);
            }
        }

        for (String str : accIdSet) {
            PositionCreateController.AccProductLine accProLine = new PositionCreateController.AccProductLine();
            accProLine.accId = str;
            accProductLineList.add(accProLine);
        }

        //获取客户产品线
        Map<String, Map<String, String>> currentAccProductLineMap = PositionCreateService.getAccountProductLineList(accIdSet);
        for (Position_Permissions__c per : positionItemList) {
            if (String.isNotBlank(per.Account__c) && String.isNotBlank(per.Product_Line__c)) {
                Map<String, String> unDisableProLineMap = currentAccProductLineMap.get(per.Account__c);
                for (PositionCreateController.AccProductLine accProLine : accProductLineList) {
                    if (per.Account__c == accProLine.accId) {
                        for (PositionCreateController.ProductLine pl : accProLine.productLineList) {
                            if (pl.value == per.Product_Line__c) {
                                pl.isTrue = true;
                            }
    
                            if (unDisableProLineMap.containsKey(pl.value)) {
                                pl.isDisable = false;
                            }
                            pl.accProductLineKey = accProLine.accId + '_' + pl.value;
                        }
                    }
                }
            }
        }

        Map<String, String> gridMap = new Map<String, String>();
        for (Gridding__c grid : getGridList2()) {
            gridMap.put(grid.Id, grid.Gridding_Code__c);
        }

        initCurrentDataItemsObj.accProductLineList = accProductLineList;
        initCurrentDataItemsObj.currentPermissionsGridDataList = graddingList;
        initCurrentDataItemsObj.shopItemList = shopItemList;
        initCurrentDataItemsObj.gridMap = gridMap;
        // wfc
        initCurrentDataItemsObj.userList = userList;

        return initCurrentDataItemsObj;
    }

    public static productLineMapWrapper getProductLinePiskListMap() {
        productLineMapWrapper pdlm = new productLineMapWrapper();
        List<PositionCreateController.ProductLine> productLineList = new List<PositionCreateController.ProductLine>();
        Map<String, String> productLineMap = new Map<String, String>();
        for (Schema.PicklistEntry t : Position_Permissions__c.Product_Line__c.getDescribe().getPicklistValues()) {
            productLineMap.put(t.getValue(), t.getLabel());
            PositionCreateController.ProductLine pl = new PositionCreateController.ProductLine();
            pl.label = t.getLabel();
            pl.value = t.getValue();
            productLineList.add(pl);
        }
        pdlm.productLineList = productLineList;
        pdlm.productLineMap = productLineMap;
        return pdlm;
    }

    // public static Map<String, Object> ParsingChooseGridding(List<Map<String, Object>> gridData, String griddingId) {
    //     Map<String, Object> currentChooseMap = new Map<String, Object>();
    //     for (Integer i = 0; i < gridData.size(); i++) {
    //         Map<String, Object> root = gridData[i];
    //         if (root.get('key') == griddingId) {
    //             currentChooseMap = root;
    //         }else if (root.containsKey('_children')) {
    //             System.debug(LoggingLevel.INFO, '*** root_children' + JSON.serialize(root.get('_children')));
    //             List<Object> root1List = (List<Object>)root.get('_children');
    //             for (Integer i1 = 0; i1 < root1List.size(); i1++) {
    //                 String instanceObjJson1 = JSON.serialize(root1List[i1]);
    //                 Map<String, Object> root1 = (Map<String, Object>)JSON.deserializeUntyped(instanceObjJson1);
    //                 if (root1.get('key') == griddingId) {
    //                     currentChooseMap = root1;
    //                 }else if (root1.containsKey('_children')) {
    //                     List<Object> root2List = (List<Object>)root1.get('_children');
    //                     for (Integer i2 = 0; i2 < root2List.size(); i2++) {
    //                         String instanceObjJson2 = JSON.serialize(root2List[i2]);
    //                         Map<String, Object> root2 = (Map<String, Object>)JSON.deserializeUntyped(instanceObjJson2);
    //                         if (root2.get('key') == griddingId) {
    //                             currentChooseMap = root2;
    //                         }else if (root2.containsKey('_children')) {
    //                             List<Object> root3List = (List<Object>)root2.get('_children');
    //                             for (Integer i3 = 0; i3 < root3List.size(); i3++) {
    //                                 String instanceObjJson3 = JSON.serialize(root3List[i3]);
    //                                 Map<String, Object> root3 = (Map<String, Object>)JSON.deserializeUntyped(instanceObjJson3);
    //                                 if (root3.get('key') == griddingId) {
    //                                     currentChooseMap = root3;
    //                                 }else if (root3.containsKey('_children')) {
    //                                     List<Object> root4List = (List<Object>)root3.get('_children');
    //                                     for (Integer i4 = 0; i4 < root4List.size(); i4++) {
    //                                         String instanceObjJson4 = JSON.serialize(root4List[i4]);
    //                                         Map<String, Object> root4 = (Map<String, Object>)JSON.deserializeUntyped(instanceObjJson4);
    //                                         if (root4.get('key') == griddingId) {
    //                                             currentChooseMap = root4;
    //                                         }else if (root4.containsKey('_children')) {
    //                                             List<Object> root5List = (List<Object>)root4.get('_children');
    //                                             for (Integer i5 = 0; i5 < root5List.size(); i5++) {
    //                                                 String instanceObjJson5 = JSON.serialize(root5List[i5]);
    //                                                 Map<String, Object> root5 = (Map<String, Object>)JSON.deserializeUntyped(instanceObjJson5);
    //                                                 if (root5.get('key') == griddingId) {
    //                                                     currentChooseMap = root5;
    //                                                 }else if (root5.containsKey('_children')) {
    //                                                     List<Object> root6List = (List<Object>)root5.get('_children');
    //                                                     for (Integer i6 = 0; i6 < root6List.size(); i6++) {
    //                                                         String instanceObjJson6 = JSON.serialize(root6List[i6]);
    //                                                         Map<String, Object> root6 = (Map<String, Object>)JSON.deserializeUntyped(instanceObjJson6);
    //                                                         if (root6.get('key') == griddingId) {
    //                                                             currentChooseMap = root6;
    //                                                         }else if (root6.containsKey('_children')) {
    //                                                             List<Object> root7List = (List<Object>)root6.get('_children');
    //                                                             for (Integer i7 = 0; i7 < root7List.size(); i7++) {
    //                                                                 String instanceObjJson7 = JSON.serialize(root7List[i7]);
    //                                                                 Map<String, Object> root7 = (Map<String, Object>)JSON.deserializeUntyped(instanceObjJson7);
    //                                                                 if (root7.get('key') == griddingId) {
    //                                                                     currentChooseMap = root7;
    //                                                                 }else {
    //                                                                     currentChooseMap = new Map<String, Object>();
    //                                                                 }
    //                                                             }
    //                                                         }
    //                                                     }
    //                                                 }
    //                                             }
    //                                         }
    //                                     }
    //                                 }
    //                             }
    //                         }
    //                     }
    //                 }
    //             }
    //         }
    //     }

    //     return currentChooseMap;
    // }
    
    public static PositionCreateController.shopGriddingWrapper newSGW(
        String gridName,
        String gridId,
        String iconName,
        String gridParentGridding,
        String nameStyle,
        Boolean rowStyle,
        List<String> griddingChooseList,
        String griExternalId
        ){
        PositionCreateController.shopGriddingWrapper sgw = new PositionCreateController.shopGriddingWrapper();
        sgw.name = gridName;
        sgw.recordId = gridId == null ? '':gridId;
        sgw.iconName = iconName;
        sgw.parentId = gridParentGridding;
        sgw.nameStyle = nameStyle;
        if (griddingChooseList.contains(gridId)) {
            sgw.isChoose = true;
        }else {
            sgw.isChoose = false;
        }
        sgw.rowStyle = rowStyle;
        sgw.griExternalId = griExternalId;

        return sgw;
    }
    public static List<Gridding__c> getGridList2() {
        String sql = 'SELECT Name, ' + 
                            'tolabel(Gridding_Level__c) GriddingLevel, ' +
                            'Gridding_Code__c, ' +
                            'DivisionUnit__c, ' +
                            'Parent_Gridding__c,Gridding_All__c,Gridding_Recursion_ID__c ' +
                     'FROM Gridding__c ';

        return Database.query(sql);
    }

    public static List<Gridding__c> getGridList(String parentRecordId) {
        String sql = 'SELECT Name, ' + 
                            'tolabel(Gridding_Level__c) GriddingLevel, ' +
                            'Gridding_Code__c, ' +
                            'DivisionUnit__c ' +
                     'FROM Gridding__c WHERE ';
        if (String.isNotBlank(parentRecordId)) {
            sql += ' Parent_Gridding__c = :parentRecordId';
        }else {
            sql += ' Parent_Gridding__c = null';
        }

        return Database.query(sql);
    }


    public static List<Shop__c> getSearchShopList(String shopName, String accountName, String griddingName, List<String> noIncludingGridIdList){
        List<Shop__c> shopList = new List<Shop__c>();
        String sql = ' SELECT Name, Account__r.Name, Grid__r.Name, Shop_External_Key__c FROM Shop__c WHERE Name != null ';
        if(String.isNotBlank(shopName)){
            sql += ' AND Name LIKE :shopName ';
        }
        if(String.isNotBlank(accountName)){
            sql += ' AND Account__r.Name LIKE :accountName ';
        }
        if(String.isNotBlank(griddingName)){
            sql += ' AND Grid__r.Name LIKE :griddingName ';
        }
        if(noIncludingGridIdList != null && noIncludingGridIdList.size() > 0){
            sql += ' AND Id NOT IN :noIncludingGridIdList ';
        }
        sql += ' LIMIT 100 ';

        return Database.query(sql);
        // shopList = [SELECT Name,
        //                     Account__r.Name,
        //                     Grid__r.Name,
        //                     Shop_External_Key__c
        //             FROM Shop__c
        //             WHERE Name LIKE :shopName
        //             AND Account__r.Name LIKE :accountName
        //             AND Grid__r.Name LIKE :griddingName
        //             AND Id NOT IN :noIncludingGridIdList
        //             LIMIT 100];
        // return shopList;
    }

    public static List<Position_Permissions__c> getPositionItemList(String recordId) {
        return [SELECT Name,
                       Gridding__c,
                       Gridding__r.Name,
                       Gridding_External_Key__c,
                       Shop__c,
                       Shop__r.Name,
                       Shop_External_Key__c,
                       Account__c,
                       Account__r.Name,
                       Account_External_Key__c,
                       Product_Line__c,
                       Account_Product_Line_Key__c,
                       Shop__r.Account__r.Name,
                       Shop__r.Grid__r.Name,
                       User__c,
                       User__r.Name, 
                       User__r.UserRole.name  
                FROM Position_Permissions__c 
                WHERE Position__c = :recordId
                ORDER BY CreatedDate DESC];
    }

    public static Map<String, Map<String, String>> getAccountProductLineList(Set<String> accIdSet){
        Map<String, Map<String, String>> accountProductLineList = new Map<String, Map<String, String>>();
        for (Account acc : [SELECT Id,
                                   (SELECT Customer__c,
                                           Product_Line_Name__c
                                    FROM Account_Product_Lines__r)
                            FROM Account 
                            WHERE Id IN :accIdSet]) {
            Map<String, String> accProductMap = new Map<String, String>();
            if (!acc.Account_Product_Lines__r.isEmpty()) {
                for(Customer_Product_Line__c cpl : acc.Account_Product_Lines__r){
                    accProductMap.put(cpl.Product_Line_Name__c, '');
                }
            }

            accountProductLineList.put(acc.Id, accProductMap);
        }
        
        return accountProductLineList;
    }

    public static Map<String, Position_Permissions__c> getCurrentGriddingMap(List<String> griddingIdList, String recordId) {
        Map<String, Position_Permissions__c> posPerMap = new Map<String, Position_Permissions__c>();
        for (Position_Permissions__c posPer : [SELECT Id,
                                                      Name,
                                                      Gridding__c
                                               FROM Position_Permissions__c 
                                               WHERE Gridding__c IN :griddingIdList
                                               AND Position__c = :recordId]) {
            posPerMap.put(posPer.Gridding__c, posPer);
        }
        return posPerMap;
    }

    public static List<Position_Permissions__c> getPositionPermissionFromAccount(String accId, String recordId){
        List<Position_Permissions__c> posPerList = new List<Position_Permissions__c>();
        posPerList = [SELECT Id 
                      FROM Position_Permissions__c 
                      WHERE Account__c = :accId
                      AND Position__c = :recordId];
        return posPerList;
    }
     
    public class productLineMapWrapper {
        public List<PositionCreateController.ProductLine> productLineList;
        public Map<String, String> productLineMap;

        public productLineMapWrapper() {
            this.productLineList = new List<PositionCreateController.ProductLine>();
            this.productLineMap = new Map<String, String>();
        }
    }
}