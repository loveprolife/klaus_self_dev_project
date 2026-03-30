public class newInventory {

    @AuraEnabled
    public static ConResponse getInventory(String recordId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // 查询库存信息
        List<Inventory__c> inventoryInfo = getInventoryInfo(recordId);
        Inventory__c inventory;

        // 查询当前库存对应的Sncode码信息
        List<Inventory_Barcode__c> floorbox;
        List<Inventory_Barcode__c> addbox;

        if(inventoryInfo != null && inventoryInfo.size() > 0){
            inventory = inventoryInfo.get(0);
        }else{
            Inventory__c inventoryInit = new Inventory__c();
            inventoryInit.Inspection_Product_Item__c = recordId;

            // 必填字段 设置默认数据
            inventoryInit.Product__c = 'a0z0o00000E1zNoAAJ';
            // inventoryInit.Product__c = 'a0z9D000002Lbz0QAC';
            Database.insert(inventoryInit);

            inventory = inventoryInit;
        }

        List<Inventory_Barcode__c> floorboxList = getInventoryBarcode(inventory.Id,'FloorBox');
        List<Inventory_Barcode__c> addboxList = getInventoryBarcode(inventory.Id,'AddBoxed');

        if(floorboxList != null && floorboxList.size() > 0){
            floorbox = floorboxList;
        }

        if(addboxList != null && addboxList.size() > 0){
            addbox = addboxList;
        }

        // 查询当前Inventory是否已上传照片
        List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId =: inventory.Id];
        if(cdlList != null && cdlList.size() > 0){
            mso.put('imgBof', true);
        }else{
            mso.put('imgBof', false);
        }

        // 查询当前Inventory是否已上传照片
        List<ContentDocumentLink> cdProductList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId =: inventory.Inspection_Product_Item__c];
        if(cdProductList != null && cdProductList.size() > 0){
            mso.put('imgBoxed', true);
        }else{
            mso.put('imgBoxed', false);
        }


        mso.put('inventoryInfo', inventory);
        mso.put('barcodeFloorBox', floorbox);
        mso.put('barcodeAddBoxed', addbox);
        return resp;
    }

    @AuraEnabled
    public static ConResponse saveInventory(String inventoryInfoJson,String barcodeFloorBoxJson,String barcodeAddBoxedJson,
                                                String barcodeFloorBoxDelJson,String barcodeAddBoxedDelJson){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        Inventory__c inventory = (Inventory__c)JSON.deserialize(inventoryInfoJson, Inventory__c.class);
        Database.upsert(inventory);
        System.debug('wwwwinventory' + JSON.serialize(inventory));

        // 处理库存地板上箱子相关数据
        if(!String.isEmpty(barcodeFloorBoxJson)){
            List<Inventory_Barcode__c> floorbox = (List<Inventory_Barcode__c>)JSON.deserialize(barcodeFloorBoxJson, List<Inventory_Barcode__c>.class);
            if(floorbox != null && floorbox.size() > 0){
                for(Inventory_Barcode__c floorItem : floorbox){
                    if(String.isEmpty(floorItem.Id)){
                        floorItem.Inventory__c = inventory.Id;
                        floorItem.Status__c = 'FloorBox';
                    }
                }
                Database.upsert(floorbox);
                System.debug('wwwwfloorbox' + JSON.serialize(floorbox));
            }
        }

        // 处理可新增箱子相关数据
        if(!String.isEmpty(barcodeAddBoxedJson)){
            List<Inventory_Barcode__c> addbox = (List<Inventory_Barcode__c>)JSON.deserialize(barcodeAddBoxedJson, List<Inventory_Barcode__c>.class);
            if(addbox != null && addbox.size() > 0){
                for(Inventory_Barcode__c addItem : addbox){
                    if(String.isEmpty(addItem.Id)){
                        addItem.Inventory__c = inventory.Id;
                        addItem.Status__c = 'AddBoxed';
                    }
                }
                Database.upsert(addbox);
                System.debug('wwwwaddbox' + JSON.serialize(addbox));
            }
        }

        // 删除掉需要删除的暂存数据
        List<Inventory_Barcode__c> floorboxDel = (List<Inventory_Barcode__c>)JSON.deserialize(barcodeFloorBoxDelJson, List<Inventory_Barcode__c>.class);
        List<Inventory_Barcode__c> floorboxDelList = new List<Inventory_Barcode__c>();
        if(floorboxDel != null && floorboxDel.size() > 0){
            for(Inventory_Barcode__c item : floorboxDel){
                if(item.Id != null){
                    floorboxDelList.add(item);
                }
            }
            Database.delete(floorboxDelList);
            System.debug('wwwwfloorbox' + JSON.serialize(floorboxDel));
        }

        List<Inventory_Barcode__c> addboxDel = (List<Inventory_Barcode__c>)JSON.deserialize(barcodeAddBoxedDelJson, List<Inventory_Barcode__c>.class);
        List<Inventory_Barcode__c> addboxDelList = new List<Inventory_Barcode__c>();
        if(addboxDel != null && addboxDel.size() > 0){
            for(Inventory_Barcode__c item : addboxDel){
                if(item.Id != null){
                    addboxDelList.add(item);
                }
            }
            Database.delete(addboxDelList);
            System.debug('wwwwfloorbox' + JSON.serialize(addboxDel));
        }

        // Boxed Photo 上级问题为NO则删除掉已上传的图片
        List<ContentDocumentLink> cdProductList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId =: inventory.Inspection_Product_Item__c];
        if(cdProductList != null && cdProductList.size() > 0){
            Database.delete(cdProductList);
        }

        return resp;
    }

    // 查询当前库存信息已检查数和检查总数
    public static Map<String,Integer> getInventoryCheckNumber(String recordId){
        Map<String,Integer> check = new Map<String,Integer>();
        // 根据日报产品线id查询竞品信息
        List<Inventory__c> inventory = getInventoryInfo(recordId);
        Integer checkNumber = 0;
        Integer checkTotal = 0;
        if(inventory != null && inventory.size() > 0){
            Inventory__c inventoryItem = inventory.get(0);

            // 判断问题答案是否空，计算已检查项
            ++checkTotal;
            if(!String.isEmpty(inventoryItem.BoxesFloor__c)){
                ++checkNumber;

                // 根据上级问题值判断是否为必填数据
                if(inventoryItem.BoxesFloor__c.equals('Yes')){
                    ++checkTotal;
                    if(!String.isEmpty(inventoryItem.AddBoxedTotal__c)){
                        ++checkNumber;
                    }
                }
            }

            ++checkTotal;
            if(!String.isEmpty(inventoryItem.InventoryTodayVisit__c)){
                ++checkNumber;
                if(inventoryItem.InventoryTodayVisit__c.equals('Yes')){
                    ++checkTotal;
                    // 根据当前id查询是否已上传附件
                    List<ContentDocumentLink> cdProductList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId =: inventoryItem.Inspection_Product_Item__c];
                    if(cdProductList != null && cdProductList.size() > 0){
                        ++checkNumber;
                    }
                }
            }


            ++checkTotal;
            // 根据当前id查询是否已上传附件
            List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId =: inventoryItem.Id];
            if(cdlList != null && cdlList.size() > 0){
                ++checkNumber;
            }

            ++checkTotal;
            if(!String.isEmpty(inventoryItem.FloorBoxTotal__c)){
                ++checkNumber;
            }
            


            // List<Inventory_Barcode__c> floorBoxBarcode = getInventoryBarcode(inventoryItem.Id,'FloorBox');
            // if(floorBoxBarcode != null && floorBoxBarcode.size() > 0){
            //     ++checkNumber;
            // }

            // List<Inventory_Barcode__c> addBoxedBarcode = getInventoryBarcode(inventoryItem.Id,'AddBoxed');
            // if(addBoxedBarcode != null && addBoxedBarcode.size() > 0){
            //     ++checkNumber;
            // }
        }else{
            checkTotal = 4;
        }

        check.put('checkTotal', checkTotal);
        check.put('checkNumber', checkNumber);

        return check;
    }

    public static List<Inventory__c> getInventoryInfo(String recordId){
        return [SELECT Id,
                       Inspection_Product_Item__c,
                       BoxesFloor__c,
                       InventoryTodayVisit__c,
                       Img_Bof__c,
                       Img_Boxed__c,
                       FloorBoxTotal__c,
                       AddBoxedTotal__c
                       FROM Inventory__c
                       WHERE Inspection_Product_Item__c =: recordId];
    }

    public static List<Inventory_Barcode__c> getInventoryBarcode(String inventoryId,String status){
        return [SELECT Id,
                       Inventory__c,
                       Status__c,
                       Type__c,
                       Value__c
                       FROM Inventory_Barcode__c
                       WHERE Inventory__c =: inventoryId
                       AND Status__c =: status];
    }

}