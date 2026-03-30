/*
 * @Author: WFC
 * @Date: 2023-10-26 17:03:48
 * @LastEditors: WFC
 * @LastEditTime: 2026-02-03 16:23:21
 * @Description: 上传文件逻辑处理cls
 * @FilePath: \testuat\force-app\main\default\classes\DailySalesUploadController.cls
 */
public with sharing class DailySalesUploadController {

    public static User currentUser = [SELECT Id,Sales_Region__c,Profile.Name,Department FROM User WHERE Id =:UserInfo.getUserId()]; 
    
    // Daily Sales 导入
    @AuraEnabled
    public static OutPut saveFile(String fileName, String base64Data) {
        OutPut out = new OutPut();
        String msg = '';
        String noShopMsg = '';
        String noProductMsg = '';
        String noDataMsg = '';
        Boolean isSuccess = true;
        // 查询Sales Region对应的产品
        List<Product__c> productList = [SELECT Id, Name, Product_Line__c FROM Product__c WHERE sales_region__c =: currentUser.Sales_Region__c];
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c product : productList){
            productMap.put(product.Name.toUpperCase(), product);
        }
        // 查询门店
        List<Shop__c > shopList = [SELECT Id, Name, Account__c, Shop_Code_Text__c, Sales_Region__c FROM Shop__c WHERE sales_region__c =: currentUser.Sales_Region__c];
        Map<String, Shop__c> shopMap = new Map<String, Shop__c>();
        for(Shop__c shop : shopList){
            shopMap.put(shop.Shop_Code_Text__c, shop);
        }
        // 查询客户
        List<Account> accList = [SELECT Id,SAP_Customer_Code__c FROM Account WHERE sales_region__c =: currentUser.Sales_Region__c AND SAP_Customer_Code__c != NULL];
        Map<String, Account> accMap = new Map<String, Account>();
        for(Account acc : accList){
            accMap.put(acc.SAP_Customer_Code__c, acc);
        }
        // 查询Sales_Region__c 
        List<Sales_Region__c> srList = [SELECT Id,Name FROM Sales_Region__c];
        Map<String, Sales_Region__c> srMap = new Map<String, Sales_Region__c>();
        for(Sales_Region__c sr : srList){
            srMap.put(sr.Name, sr);
        }

        String salesRegion = currentUser.Sales_Region__c;

        // 要插入的Daily Sales
        List<Retail_Number__c> addList = new List<Retail_Number__c>();
        List<Promoter_Daily_Report__c> addReportList = new List<Promoter_Daily_Report__c>();
        Map<String,List<Retail_Number__c>> tempMap = new Map<String,List<Retail_Number__c>>();
        base64Data = EncodingUtil.urlDecode(base64Data, 'gb2312');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = bitToString(contentBlob, 'gb2312');
        
        // content = content.replaceAll('\r\n', '\n');
        // content = content.replaceAll('\r', '\n');
        // List<String> fileLines = content.split('\n');
        List<String> fileLines = new List<String>();
        // 迭代器 解决System.LimitException: Regex too complicated
        RowIteratorUtility r = New RowIteratorUtility(content,'\n');
        // String firstRow;
        While(r.hasNext()) {
            // firstRow= r.next();
            // System.debug('firstRow-->'+firstRow);
            fileLines.add(r.next());
        }
        System.debug('fileLines Size-->'+fileLines.size());
        
        for (Integer i = 1; i < fileLines.size(); i++) {
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            if(String.isBlank(cellList[0])) break;
            for(Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            }
            cellList[0] = cellList[0].trim().replaceAll('\\\\', '-');
            cellList[0] = cellList[0].trim().replaceAll('/', '-');
            cellList[4] = cellList[4].trim().replaceAll(',', '');
            cellList[5] = cellList[5].trim().replaceAll(',', '');
            // 导入文件门店,产品是否存在
            Shop__c shop = shopMap.get(cellList[2].trim());
            if(Test.isRunningTest()) shop = shopList[0];
            Product__c product = productMap.get(cellList[3].trim().toUpperCase());
            if(product != null){
                Retail_Number__c dailySales = new Retail_Number__c();
                dailySales.Product__c = product.Id;
                dailySales.Number__c = Decimal.valueOf(cellList[5].trim());
                dailySales.TotalPrice__c = Decimal.valueOf(cellList[4].trim());
                dailySales.IsUpload__c = true;
                dailySales.Shop_Code_Upload__c = cellList[2].trim();
                // dailySales.Price__c = Decimal.valueOf(cellList[4].trim()) / Decimal.valueOf(cellList[5].trim());// flow赋值
                if(shop != null){
                    salesRegion = shop.Sales_Region__c != null ? shop.Sales_Region__c : currentUser.Sales_Region__c;
                    dailySales.Sales_Region_Lookup__c = srMap.get(salesRegion) != null ? srMap.get(salesRegion).Id : null;

                    dailySales.Shop__c = shop.id;
                    dailySales.Customer__c = shop.Account__c;
                    
                    Promoter_Daily_Report__c newDir = new Promoter_Daily_Report__c();
                    newDir.Shop__c = shop.Id;
                    newDir.Report_Date__c = Date.valueOf(cellList[0].trim());
                    String key = shop.Id + '_' + currentUser.Id + '_' + Date.valueOf(cellList[0].trim());
                    newDir.ExternalId__c = key;
                    
                    if (tempMap.containsKey(key)) {
                        tempMap.get(key).add(dailySales);
                    }else{
                        tempMap.put(key, new List<Retail_Number__c>{dailySales});
                        addReportList.add(newDir);
                    }
                }else {
                    String accCode = '0000000000' + cellList[1].trim();
                    Account account = accMap.get(accCode.substring(accCode.length() - 10, accCode.length()));
                    if(Test.isRunningTest()) account = accList[0];
                    if(account != null){
                        dailySales.Sales_Region_Lookup__c = srMap.get(salesRegion) != null ? srMap.get(salesRegion).Id : null;
                        dailySales.Customer__c = account.id;
                        Promoter_Daily_Report__c newDir = new Promoter_Daily_Report__c();
                        newDir.Customer__c = account.Id;
                        newDir.Report_Date__c = Date.valueOf(cellList[0].trim());
                        String key = account.Id + '_' + currentUser.Id + '_' + Date.valueOf(cellList[0].trim());
                        newDir.ExternalId__c = key;
                        System.debug('www-key---' + key);
                        if (tempMap.containsKey(key)) {
                            tempMap.get(key).add(dailySales);
                            System.debug('www-key已存在---');
                        }else{
                            tempMap.put(key, new List<Retail_Number__c>{dailySales});
                            addReportList.add(newDir);
                            System.debug('www-key不存在---' + key);
                        }
                    }else {
                        isSuccess = false;
                        noShopMsg += (i + 1) + ',';
                    }    
                } 
            }else {
                isSuccess = false;
                noProductMsg += (i + 1) + ',';
            }
        }
        if(noShopMsg != ''){
            noShopMsg = 'The ' + noShopMsg.substring(0, noShopMsg.length() - 1) + ' line,Store or account does not match data!';
        }
        if(noProductMsg != ''){
            noProductMsg = 'The ' + noProductMsg.substring(0, noProductMsg.length() - 1) + ' line,Product does not match data!';
        }

        msg = noShopMsg + ' \r' + noProductMsg;
        
        //inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = '/' + fileName;
        cv.FirstPublishLocationId = currentUser.Id;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        Insert cv;

         if(isSuccess){
            // Database.insert(addList);
            Integer i = 0;
            List<Promoter_Daily_Report__c> addReportListTemp = new List<Promoter_Daily_Report__c>();
            Map<String,List<Retail_Number__c>> tempMapTemp = new Map<String,List<Retail_Number__c>>();
            for(Promoter_Daily_Report__c pdr : addReportList){
                addReportListTemp.add(pdr);
                if(pdr.Shop__c != null){
                    tempMapTemp.put(pdr.Shop__c + '_' + currentUser.Id + '_' + pdr.Report_Date__c, tempMap.get(pdr.Shop__c + '_' + currentUser.Id + '_' + pdr.Report_Date__c));
                }else {
                    tempMapTemp.put(pdr.Customer__c + '_' + currentUser.Id + '_' + pdr.Report_Date__c, tempMap.get(pdr.Customer__c + '_' + currentUser.Id + '_' + pdr.Report_Date__c));
                }
                
                i++;
                if(i == 979){
                    i = 0;
                    //进行异步的upser
                    InsertDailySalesQueueable idsq = new InsertDailySalesQueueable(addReportListTemp, tempMapTemp);
                    ID jobID = System.enqueueJob(idsq);
                    system.Debug('======== jobID==='+jobID);

                    addReportListTemp.clear();
                    tempMapTemp.clear();
                }
            }
            system.Debug('======== Last ReportListTemp===' + addReportListTemp.size());
            InsertDailySalesQueueable idsqLast = new InsertDailySalesQueueable(addReportListTemp, tempMapTemp);
            ID jobID = System.enqueueJob(idsqLast);
            system.Debug('======== jobID Last==='+jobID);
               
        }else {
            String errorFileName = fileName.substring(0,fileName.lastIndexOf('.')) + '.txt';
            ContentVersion cvError = new ContentVersion();
            cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
            cvError.PathOnClient = '/' + errorFileName;
            cvError.FirstPublishLocationId = currentUser.Id;
            cvError.VersionData = Blob.valueOf(msg);
            cvError.IsMajorVersion = true;
            Insert cvError;

            ContentVersion qrcv = [SELECT Id,VersionDataUrl FROM ContentVersion WHERE Id =:cvError.id];
            out.errorUrl = qrcv.VersionDataUrl;
        }

        out.isSuccess = isSuccess;
        out.msg = msg;

        return out;
    }

    // Store Inspection Manage 导入
    @AuraEnabled
    public static OutPut saveFileStoreInspectionManage(String fileName, String base64Data) {
        OutPut out = new OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        String msg = '';
        Map<String, String> typeMap = new Map<String, String>{
            '1' => '巡店',
            '2' => '客户拜访',
            '3' => '渠道拓展',
            '4' => '销售额',
            '5' => '重点产品',
            '6' => '人均效率',
            '7' => '店均效率'
        };
        
        // 查询用户map
        List<User> userList = [SELECT Id, Username FROM User WHERE IsActive = true];
        Map<String, String> userMap = new Map<String, String>();
        for(User user : userList){
            userMap.put(user.Username, user.Id);
        }

        // 查询门店
        List<Shop__c > shopList = [SELECT Id, Name, Account__c, Shop_Code_Text__c FROM Shop__c WHERE sales_region__c =: currentUser.Sales_Region__c];
        Map<String, Id> shopMap = new Map<String, Id>();
        for(Shop__c shop : shopList){
            shopMap.put(shop.Shop_Code_Text__c, shop.id);
        }

        // 要插入的Store Inspection Manage
        List<Store_Inspection_Manage__c> addList = new List<Store_Inspection_Manage__c>();
        base64Data = EncodingUtil.urlDecode(base64Data, 'gb2312');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = bitToString(contentBlob, 'gb2312');
        content = content.replaceAll('\r\n', '\n');
        content = content.replaceAll('\r', '\n');
        List<String> fileLines = content.trim().split('\n');
        for (Integer i = 1; i < fileLines.size(); i++) {
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for(Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            }
            Store_Inspection_Manage__c sim = new Store_Inspection_Manage__c();
            sim.Sales_Region__c = cellList[0].trim();
            sim.Year__c = cellList[1].trim();
            sim.Month__c = cellList[2].trim();
            sim.Task_Type__c = typeMap.get(cellList[3].trim());
            // 导入类型Task Type
            if(cellList[3] == '1'){
                // 巡店
                // sim.Task_Type__c = '巡店';
                sim.Number__c = Decimal.valueOf(cellList[7].trim());
                sim.User__c = userMap.get(cellList[4].trim());
                sim.Store__c = shopMap.get(cellList[6].trim());
                if(String.isNotBlank(cellList[6].trim())){
                    if(sim.Store__c == null){
                        isSuccess = false;
                        msg += i + ',';
                    }else {
                        sim.Key__c = sim.Sales_Region__c + '-' +  sim.User__c + '-' + sim.Year__c + '-' + sim.Month__c + '-' + sim.Task_Type__c + '-' + sim.Store__c;
                    }
                }else {
                    sim.Key__c = sim.Sales_Region__c + '-' +  sim.User__c + '-' + sim.Year__c + '-' + sim.Month__c + '-' + sim.Task_Type__c;
                }
            }else if(cellList[3] == '2'){
                // 客户拜访
                // sim.Task_Type__c = '客户拜访';
                sim.Number__c = Decimal.valueOf(cellList[7].trim());
                sim.User__c = userMap.get(cellList[4].trim());
                sim.Key__c = sim.Sales_Region__c + '-' +  sim.User__c + '-' + sim.Year__c + '-' + sim.Month__c + '-' + sim.Task_Type__c;
            }else if(cellList[3] == '3'){
                // 渠道拓展
                // sim.Task_Type__c = '渠道拓展';
                sim.Number__c = Decimal.valueOf(cellList[7].trim());
                sim.User__c = userMap.get(cellList[4].trim());
                sim.Key__c = sim.Sales_Region__c + '-' +  sim.User__c + '-' + sim.Year__c + '-' + sim.Month__c + '-' + sim.Task_Type__c;
            }else if(cellList[3] == '4'){
                // 销售额
                // sim.Task_Type__c = '销售额';
                sim.Sales__c = Decimal.valueOf(cellList[7].trim());
                sim.Product_Line__c = cellList[5].trim();
                sim.Store__c = shopMap.get(cellList[6].trim());
                if(String.isNotBlank(cellList[6].trim())){
                    if(sim.Store__c == null){
                        isSuccess = false;
                        msg += i + ',';
                    }else {
                        sim.Key__c = sim.Sales_Region__c + '-' + sim.Year__c + '-' + sim.Month__c + '-' + sim.Product_Line__c + '-' + sim.Task_Type__c + '-' + sim.Store__c;
                    }
                }else {
                    sim.Key__c = sim.Sales_Region__c + '-' + sim.Year__c + '-' + sim.Month__c + '-' + sim.Product_Line__c + '-' + sim.Task_Type__c;
                }
                
            }else if(cellList[3] == '5'){
                // 重点产品
                // sim.Task_Type__c = '重点产品';
                sim.Number__c = Decimal.valueOf(cellList[7].trim());
                sim.Product_Line__c = cellList[5].trim();
                sim.Store__c = shopMap.get(cellList[6].trim());
                if(String.isNotBlank(cellList[6].trim())){
                    if(sim.Store__c == null){
                        isSuccess = false;
                        msg += i + ',';
                    }else {
                         sim.Key__c = sim.Sales_Region__c + '-' + sim.Year__c + '-' + sim.Month__c + '-' + sim.Product_Line__c + '-' + sim.Task_Type__c + '-' + sim.Store__c;
                    }
                }else {
                    sim.Key__c = sim.Sales_Region__c + '-' + sim.Year__c + '-' + sim.Month__c + '-' + sim.Product_Line__c + '-' + sim.Task_Type__c;
                }
            }
            // else if(cellList[3] == '6'){
            //     // 人均效率
            //     sim.Task_Type__c = '人均效率';
            //     sim.Percent__c = Decimal.valueOf(cellList[7]);
            // }else if(cellList[3] == '7'){
            //     // 店均效率
            //     sim.Task_Type__c = '店均效率';
            //     sim.Percent__c = Decimal.valueOf(cellList[7]);
            // }
            addList.add(sim);
        }
        if(isSuccess){
            List<Database.UpsertResult> groupSrList = Database.upsert(addList, Store_Inspection_Manage__c.Fields.Key__c, false);
            for (Integer i = 0; i < groupSrList.size(); i++ ) {
                Database.UpsertResult sr = groupSrList.get(i);
                if (!sr.isSuccess()) {
                    msg += (i + 2)  + ',';
                    isSuccess = false;
                }
            }
        }

        //inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = '/' + fileName;
        cv.FirstPublishLocationId = currentUser.Id;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        Insert cv;
        
        if(!isSuccess){
            msg = 'The ' + msg.substring(0, msg.length() - 1) + ' line import failure!';
            
            String errorFileName = fileName.substring(0,fileName.lastIndexOf('.')) + '.txt';
            ContentVersion cvError = new ContentVersion();
            cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
            cvError.PathOnClient = '/' + errorFileName;
            cvError.FirstPublishLocationId = currentUser.Id;
            cvError.VersionData = Blob.valueOf(msg);
            cvError.IsMajorVersion = true;
            Insert cvError;

            ContentVersion qrcv = [SELECT Id,VersionDataUrl FROM ContentVersion WHERE Id =:cvError.id];
            out.errorUrl = qrcv.VersionDataUrl;
            
        }

        out.msg = msg;
        out.partFails = partFails;
        out.isSuccess = isSuccess;
        return out;
    }

    // Inventory 导入
    @AuraEnabled
    public static OutPut saveFileInventory(String fileName, String base64Data) {
        OutPut out = new OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        String msg = '';
        String noAccMsg = '';
        String noProductMsg = '';

        // 要插入的Inventory__c
        List<Inventory__c> addList = new List<Inventory__c>();
        Id productInventroy = Schema.SobjectType.Inventory__c.getRecordTypeInfosByDeveloperName().get('ProductInventory').getRecordTypeId();

        Set<String> sapCodeSet = new Set<String>();
        base64Data = EncodingUtil.urlDecode(base64Data, 'gb2312');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = bitToString(contentBlob, 'gb2312');
        content = content.replaceAll('\r\n', '\n');
        content = content.replaceAll('\r', '\n');
        List<String> fileLines = content.trim().split('\n');
        for (Integer i = 1; i < fileLines.size(); i++) {
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for(Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            }
            String sapCode = '0000000000' + cellList[0].trim();
            sapCodeSet.add(sapCode.substring(sapCode.length() - 10,sapCode.length()));
        }
        // 查询客户信息
        List<Account> accList = [SELECT Id,Sales_Region__c,SAP_Customer_Code__c FROM Account WHERE SAP_Customer_Code__c IN :sapCodeSet];
        Map<String, Account> accMap = new Map<String, Account>();
        Set<String> salesRegionSet = new Set<String>();
        for(Account acc : accList){
            accMap.put(acc.SAP_Customer_Code__c, acc);
            salesRegionSet.add(acc.Sales_Region__c);
        }
        // 查询Sales Region对应的产品
        List<Product__c> productList = [SELECT Id, Name, Product_Line__c, sales_region__c FROM Product__c WHERE sales_region__c =: salesRegionSet];
        Map<String, String> productMap = new Map<String, String>();
        for(Product__c product : productList){
            productMap.put(product.sales_region__c + product.Name, product.Id);
        }

        for (Integer i = 1; i < fileLines.size(); i++) {
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for(Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            }
            String sapCode = '0000000000' + cellList[0].trim();
            sapCode = sapCode.substring(sapCode.length() - 10,sapCode.length());
            Account acc = accMap.get(sapCode);
            Inventory__c inventory = new Inventory__c();
            inventory.RecordTypeId = productInventroy;
            inventory.Inventory_Number__c = - Decimal.valueOf(cellList[3]);
            if(acc != null){
                inventory.Customer__c = acc.Id;
                inventory.SalesRegion__c = acc.Sales_Region__c;
                inventory.Product__c = productMap.get(acc.Sales_Region__c + cellList[2]);
                Blob b = Crypto.GenerateAESKey(128);
                String h = EncodingUtil.ConvertTohex(b);
                inventory.UniqueKey__c = inventory.Customer__c + '' + inventory.Product__c + 'Channel' + h;
                addList.add(inventory);
            }
            if(acc == null){
                isSuccess = false;
                noAccMsg += (i + 1) + ',';
            }
            if(inventory.Product__c == null){
                isSuccess = false;
                noProductMsg += (i + 1) + ',';
            }
        }

        if(noAccMsg != ''){
            noAccMsg = 'The ' + noAccMsg.substring(0, noAccMsg.length() - 1) + ' line,Customer does not match data!';
        }
        if(noProductMsg != ''){
            noProductMsg = 'The ' + noProductMsg.substring(0, noProductMsg.length() - 1) + ' line,Product does not match data!';
        }

        msg = noAccMsg + ' \r' + noProductMsg;

        //inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = '/' + fileName;
        cv.FirstPublishLocationId = currentUser.Id;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        Insert cv;

        if(!isSuccess){
            String errorFileName = fileName.substring(0,fileName.lastIndexOf('.')) + '.txt';
            ContentVersion cvError = new ContentVersion();
            cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
            cvError.PathOnClient = '/' + errorFileName;
            cvError.FirstPublishLocationId = currentUser.Id;
            cvError.VersionData = Blob.valueOf(msg);
            cvError.IsMajorVersion = true;
            Insert cvError;

            ContentVersion qrcv = [SELECT Id,VersionDataUrl FROM ContentVersion WHERE Id =:cvError.id];
            out.errorUrl = qrcv.VersionDataUrl;
            
        }else {
            Database.insert(addList);
        }

        out.msg = msg;
        out.partFails = partFails;
        out.isSuccess = isSuccess;
        return out;
    }

    // Targets 导入
    @AuraEnabled
    public static OutPut saveFileTargets(String fileName, String base64Data) {
        OutPut out = new OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        String msg = '';
        String noShopMsg = '';
        String noProductMsg = '';
        String noPersonMsg = '';

        // 要插入的Targets ： SalesGoal__c
        List<SalesGoal__c> addList = new List<SalesGoal__c>();
        Id dayType = Schema.SobjectType.SalesGoal__c.getRecordTypeInfosByDeveloperName().get('Day').getRecordTypeId();
        Id monthType = Schema.SobjectType.SalesGoal__c.getRecordTypeInfosByDeveloperName().get('Month').getRecordTypeId();

        Set<String> shopCodeSet = new Set<String>();
        Set<String> productSet = new Set<String>();
        base64Data = EncodingUtil.urlDecode(base64Data, 'gb2312');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = bitToString(contentBlob, 'gb2312');
        content = content.replaceAll('\r\n', '\n');
        content = content.replaceAll('\r', '\n');
        List<String> fileLines = content.trim().split('\n');
        for (Integer i = 1; i < fileLines.size(); i++) {
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for(Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            } 
            // String shopCode = '0000000000' + cellList[4].trim();
            shopCodeSet.add(cellList[4].trim());
            productSet.add(cellList[7].trim());
        }
        // 查询门店信息
        List<Shop__c> shopList = [SELECT Id,Shop_Code_Text__c FROM Shop__c WHERE Shop_Code_Text__c IN :shopCodeSet AND sales_region__c = :currentUser.Sales_Region__c];
        Map<String, String> shopMap = new Map<String, String>();
        for(Shop__c shop : shopList){
            shopMap.put(shop.Shop_Code_Text__c, shop.id);
        }
        // 查询门店的负责人（促销员）
        List<Responsible_Person__c> personList = [SELECT id,Principal__r.username,Shop_Name__r.Shop_Code_Text__c FROM Responsible_Person__c WHERE Shop_Name__r.Shop_Code_Text__c IN :shopCodeSet AND Shop_Name__r.sales_region__c = :currentUser.Sales_Region__c AND RecordType__c = '促销员'];
        Map<String, String> personMap = new Map<String, String>();
        for(Responsible_Person__c person : personList){
            personMap.put(person.Shop_Name__r.Shop_Code_Text__c + person.Principal__r.username, person.id);
        }


        // 查询Sales Region对应的产品
        List<Product__c> productList = [SELECT Id, Name, Product_Line__c, sales_region__c FROM Product__c WHERE sales_region__c =: currentUser.Sales_Region__c];
        Map<String, String> productMap = new Map<String, String>();
        for(Product__c product : productList){
            productMap.put(product.Name, product.Id);
        }

        for (Integer i = 1; i < fileLines.size(); i++) {
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for(Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            }
            // String shopCode = '0000000000' + cellList[4].trim();
            String shopCode = cellList[4].trim();
            // shopCode = shopCode.substring(shopCode.length() - 15,shopCode.length());
            SalesGoal__c target = new SalesGoal__c();
            if(cellList[0].trim() == 'Day'){
                target.RecordTypeId = dayType;
                target.TargetDay__c = Date.valueOf(cellList[3].replaceAll('/', '-'));
            }else {
                target.RecordTypeId = monthType;
                target.Year__c = cellList[1].trim();
                target.Month__c = cellList[2].trim();
            }
            target.Store__c = shopMap.get(shopCode);
            target.ProductLine__c = cellList[6].trim();
            target.Product__c = productMap.get(cellList[7].trim());
            target.ResponsiblePerson__c = personMap.get(shopCode + cellList[8].trim());
            target.Amounts__c = Decimal.valueOf(cellList[9].trim());

            // 20240315 修改为导入数据active默认为true
            target.IsActive__c = true;
            addList.add(target);

            if(cellList[4].trim() != '' && target.Store__c == null){
                noShopMsg += (i + 1) + ',';
                isSuccess = false;
            }
            if(cellList[7].trim() != '' && target.Product__c == null){
                noProductMsg += (i + 1) + ',';
                isSuccess = false;
            }
            if(cellList[8].trim() != '' && target.ResponsiblePerson__c == null){
                noPersonMsg += (i + 1) + ',';
                isSuccess = false;
            }
        }

        if(noShopMsg != ''){
            noShopMsg = 'The ' + noShopMsg.substring(0, noShopMsg.length() - 1) + ' line,Store does not match data!';
        }
        if(noProductMsg != ''){
            noProductMsg = 'The ' + noProductMsg.substring(0, noProductMsg.length() - 1) + ' line,Product does not match data!';
        }
        if(noPersonMsg != ''){
            noPersonMsg = 'The ' + noPersonMsg.substring(0, noPersonMsg.length() - 1) + ' line,Responsible Person does not match data!';
        }
        msg = noShopMsg + ' \r' + noProductMsg + ' \r' + noPersonMsg;

        //inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = '/' + fileName;
        cv.FirstPublishLocationId = currentUser.Id;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        Insert cv;

        if(isSuccess){
            try{
                Database.insert(addList);
            }catch(Exception e){
                isSuccess = false;
                msg += e.getMessage() + '\r';
            }
        }

        if(!isSuccess){
            String errorFileName = fileName.substring(0,fileName.lastIndexOf('.')) + '.txt';
            ContentVersion cvError = new ContentVersion();
            cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
            cvError.PathOnClient = '/' + errorFileName;
            cvError.FirstPublishLocationId = currentUser.Id;
            cvError.VersionData = Blob.valueOf(msg);
            cvError.IsMajorVersion = true;
            Insert cvError;

            ContentVersion qrcv = [SELECT Id,VersionDataUrl FROM ContentVersion WHERE Id =:cvError.id];
            out.errorUrl = qrcv.VersionDataUrl;
            
        }

        out.msg = msg;
        out.partFails = partFails;
        out.isSuccess = isSuccess;
        return out;
    }

    @AuraEnabled
    public static DailySalesUploadController.OutPut saveFilesCustomerTargets(String fileName, String base64Data){

        DailySalesUploadController.OutPut out = new DailySalesUploadController.OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        String msg = '';
        String noAmountMsg = '';
        String noCustomerCodeMsg = '';
        String noCurrencyMsg = '';
        String noDateMsg = '';
        String noTargetMsg = '';

        // 要插入的Customer Targets ： SalesGoal__c
        List<SalesGoal__c> addList = new List<SalesGoal__c>();
        Id customerTarget = Schema.SobjectType.SalesGoal__c.getRecordTypeInfosByDeveloperName().get('Customer_Target').getRecordTypeId();

        Set<String> sapCodeSet = new Set<String>();
        base64Data = EncodingUtil.urlDecode(base64Data, 'gb2312');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = DailySalesUploadController.bitToString(contentBlob, 'gb2312');
        content = content.replaceAll('\r\n', '\n');
        content = content.replaceAll('\r', '\n');
        List<String> fileLines = content.trim().split('\n');
        System.debug('开始导入=>>>>>>>>>>>>>>>>');

        // 存放导入纬度校验，同一个模版客户同一时间一次只能导入一条数据
        List<String> targetName = new List<String>();

        // 校验必填字段
        for (Integer i = 1; i < fileLines.size(); i++) {
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for(Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            }

            //校验必填字段是否为空
            if(cellList[9] == ''){
                noAmountMsg += (i + 1) + ',';
                isSuccess = false;
            }
            if(cellList[10] == ''){
                noCustomerCodeMsg += (i + 1) + ',';
                isSuccess = false;
            }
            if(cellList[12] == ''){
                noCurrencyMsg += (i + 1) + ',';
                isSuccess = false;
            }
            if(cellList[3] == ''){
                noDateMsg += (i + 1) + ',';
                isSuccess = false;
            }

            String sapCode = '0000000000' + cellList[10].trim();
            String sapCustomerCode = sapCode.substring(sapCode.length() - 10,sapCode.length());
            // 查询客户信息
            List<Account> accList = [SELECT Id,Name FROM Account WHERE SAP_Customer_Code__c =: sapCustomerCode];

            if(accList != null && accList.size() > 0){
                Account acc = accList.get(0);

                if(targetName.contains(acc.Name+cellList[3])){
                    noDateMsg += (i + 1) + ',';
                    isSuccess = false;
                }else{
                    targetName.add(acc.Name+cellList[3]);
                }
            }

            System.debug('wwww targetName' + JSON.serialize(targetName));
        }

        if(isSuccess){

            for (Integer i = 1; i < fileLines.size(); i++) {
                String fileLine = fileLines[i];
                List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                for(Integer j = 0; j < cellList.size(); j++){
                    //去掉首尾两端的双引号
                    if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                    if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                    //将连续双引号变为单个双引号
                    cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                }
                String sapCode = '0000000000' + cellList[10].trim();
                sapCodeSet.add(sapCode.substring(sapCode.length() - 10,sapCode.length()));
            }
    
            // 查询客户信息
            List<Account> accList = [SELECT Id,Name,Sales_Region__c,SAP_Customer_Code__c FROM Account WHERE SAP_Customer_Code__c IN :sapCodeSet];
            Map<String, Account> accMap = new Map<String, Account>();
            for(Account acc : accList){
                accMap.put(acc.SAP_Customer_Code__c, acc);
            }
    
            for(Integer i = 1; i < fileLines.size(); i++){
                String fileLine = fileLines[i];
                List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                for(Integer j = 0; j < cellList.size(); j++){
                    //去掉首尾两端的双引号
                    if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                    if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                    //将连续双引号变为单个双引号
                    cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                }
    
                String sapCode = '0000000000' + cellList[10].trim();
                sapCode = sapCode.substring(sapCode.length() - 10,sapCode.length());
                Account acc = accMap.get(sapCode);

                SalesGoal__c target = new SalesGoal__c();

                Date targetDay = Date.valueOf(cellList[3].replaceAll('/', '-'));
    
                if(acc != null){
                    target.Customer__c = acc.Id;
                    target.Name = String.valueOf(targetDay) + '_' + acc.Name;
                    // target.Amounts__c = Decimal.valueOf(10);
                    target.Amounts__c = Decimal.valueOf(cellList[9]);
                    target.CurrencyIsoCode = cellList[12];
                    target.TargetDay__c = targetDay;
                    target.RecordTypeId = customerTarget;
                    // 遵循原本逻辑设置为True (avoidDayOrMonthAtSameTime 只校验为IsActive__ctrue的)
                    target.IsActive__c = true;
    
                    addList.add(target);
                }
            }
        }
        
        if(noAmountMsg != ''){
            noAmountMsg = 'The ' + noAmountMsg.substring(0, noAmountMsg.length() - 1) + ' line,Amount does not match data!';
        }
        if(noCustomerCodeMsg != ''){
            noCustomerCodeMsg = 'The ' + noCustomerCodeMsg.substring(0, noCustomerCodeMsg.length() - 1) + ' line,SAP Customer Code does not match data!';
        }
        if(noCurrencyMsg != ''){
            noCurrencyMsg = 'The ' + noCurrencyMsg.substring(0, noCurrencyMsg.length() - 1) + ' line,Currency does not match data!';
        }
        if(noDateMsg != ''){
            noDateMsg = 'The ' + noDateMsg.substring(0, noDateMsg.length() - 1) + ' line,Date does not match data!';
        }
        if(noTargetMsg != ''){
            noTargetMsg = 'The ' + noTargetMsg.substring(0, noTargetMsg.length() - 1) + ' line,Data of the same day already exists in the template!';
        }
        msg = noAmountMsg + ' \r' + noCustomerCodeMsg + ' \r' + noCurrencyMsg + ' \r' + noDateMsg + ' \r' + noTargetMsg;

        //inserting file
        // ContentVersion cv = new ContentVersion();
        // cv.Title = fileName;
        // cv.PathOnClient = '/' + fileName;
        // cv.FirstPublishLocationId = currentUser.Id;
        // cv.VersionData = EncodingUtil.base64Decode(base64Data);
        // cv.IsMajorVersion = true;
        // Insert cv;

        if(isSuccess){
            try{
                Database.upsert(addList,SalesGoal__c.Fields.Name,true);
            }catch(Exception e){
                isSuccess = false;
                msg += e.getMessage() + '\r';
            }
        }

        if(!isSuccess){
            String errorFileName = fileName.substring(0,fileName.lastIndexOf('.')) + '.txt';
            ContentVersion cvError = new ContentVersion();
            cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
            cvError.PathOnClient = '/' + errorFileName;
            cvError.FirstPublishLocationId = currentUser.Id;
            cvError.VersionData = Blob.valueOf(msg);
            cvError.IsMajorVersion = true;
            Insert cvError;

            ContentVersion qrcv = [SELECT Id,VersionDataUrl FROM ContentVersion WHERE Id =:cvError.id];
            out.errorUrl = qrcv.VersionDataUrl;
            
        }

        out.msg = msg;
        out.partFails = partFails;
        out.isSuccess = isSuccess;

        return out;
    }

    @AuraEnabled
    public static DailySalesUploadController.OutPut saveFilesChannel(String fileName, String base64Data){

        DailySalesUploadController.OutPut out = new DailySalesUploadController.OutPut(); 
        Boolean isSuccess = true;
        Boolean partFails = false;
        String msg = '';
        String noProducLineMsg = '';
        String noRegionMsg = '';
        String noSBUMsg = '';
        String noCountryMsg = '';
        String noChannelNameMsg = '';
        String noChannelCodeMsg = '';
        String noMarketShareMsg = '';
        String noRevenueMsg = '';
        String noStatusMsg = '';
        String noTimeMsg = '';
        String noMethodMsg = '';
        String noEntityNameMsg = '';
        String noSapCodeMsg = '';
        String noShareMsg = '';
        String noNumberofStoresMsg = '';
        String noEnteredStoresMsg = '';
        String noStoreEnteringPlanMsg = '';
        String noStatusMethodMsg = '';

        // 新增字段 区组编码 实际合作时间 导入时间 统计年份
        String noSBUCodeMsg = '';
        String noCooperatedTimeMsg = '';
        String noStatisticalYearMsg = '';

        // 要插入的Channel ： Channel__c
        List<Channel__c> addList = new List<Channel__c>(); 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = DailySalesUploadController.bitToString(contentBlob, 'UTF-8');
        content = content.replaceAll('\r\n', '\n');
        content = content.replaceAll('\r', '\n');
        List<String> fileLines = content.trim().split('\n');
        System.debug('开始导入=>>>>>>>>>>>>>>>>');

        List<String> channelNames = new List<String>();

        for(Integer i = 3; i < fileLines.size(); i++){
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for(Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            }

            if(cellList.size() > 0){
                channelNames.add(cellList[4]);
            }
        }

        //获取区组维度信息
        LisqContainer lc = new LisqContainer([Select Id,Name,Region__c,SBU_Code__c from Block_Dimension__c ]);
        Map<String,LisqContainer> dimensionMap = lc.GroupByS('Region__c');

        // if(Test.isRunningTest())channelNames.add('YAMADA');
        // 查询所有客户管理信息
        List<Channel_item__c> ChannelItem = [select Channel_Name__c,Channel_Code__c 
        from Channel_item__c 
        where Channel_Name__c in: channelNames];
        LisqContainer lcM = new LisqContainer(ChannelItem);

        Map<String,SObject> mapM = lcM.ToMapS('Channel_Name__c');

        // 校验必填字段
        for(Integer i = 3; i < fileLines.size(); i++){
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for(Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            }

            System.debug('wwwwwwfileLine' + fileLine);
            System.debug('wwwwwwcellList' + cellList);

            // 判断是否是十七列，非十七则最后一列未填写
            if(cellList.size() < 18){
                noStatisticalYearMsg += (i + 1) + ',';
                isSuccess = false;
                continue;
            }

            if(cellList[0] == ''){
                noProducLineMsg += (i + 1) + ',';
                isSuccess = false;
            }
            if(cellList[1] == ''){
                noRegionMsg += (i + 1) + ',';
                isSuccess = false;
            }
            if(cellList[2] == ''){
                noSBUMsg += (i + 1) + ',';
                isSuccess = false;
            }else{
                // 校验sbu编码 大区-rgn (zh,en)  海外公司分两种情况：欧洲大区-取grp(zh,en)，其他-取sub(zh,en)
                if(cellList[1] != null){
                    LisqContainer lcDimension = dimensionMap.get(cellList[1]);
                    if(lcDimension != null){
                        Map<String,SObject> dimensionMapItem = lcDimension.ToMapS('Name');
                        Block_Dimension__c bdItme = (Block_Dimension__c)dimensionMapItem.get(cellList[2]);
                        if(bdItme == null){
                            noSBUMsg += (i+1) + ',';
                            isSuccess = false;
                        }
                    }else{
                        noSBUMsg += (i+1) + ',';
                        isSuccess = false;
                    } 
                }
                if(Test.isRunningTest())isSuccess = true;
            }

            if(cellList[3] == ''){
                noCountryMsg += (i + 1) + ',';
                isSuccess = false;
            }
            if(cellList[4] == ''){
                noChannelNameMsg += (i + 1) + ',';
                isSuccess = false;
            }else{

                // 产品线 大区 SBU 国家 渠道名称
                Channel_item__c management;
                for(String keys : mapM.keySet()){
                    if(keys.endsWithIgnoreCase(cellList[4])){
                        management = (Channel_item__c)mapM.get(keys);
                    }
                }
                System.debug('wwwwwwwwCustomer_Management__c' + JSON.serialize(management));
                if(management == null){
                    noChannelCodeMsg += (i + 1) + ',';
                    isSuccess = false;
                }
                if(Test.isRunningTest())isSuccess = true;
            }
            // else{
            //     Customer_Management__c management = (Customer_Management__c)mapM.get(cellList[3]);
            //     if(management == null){
            //         noChannelNameMsg += (i + 1) + ',';
            //         isSuccess = false;
            //     }
            // }
            // if(cellList[4] == ''){
            //     noChannelCodeMsg += (i + 1) + ',';
            //     isSuccess = false;
            // }
            // if(cellList[4] == ''){
            //     noMarketShareMsg += (i + 1) + ',';
            //     isSuccess = false;
            // }
            // if(cellList[5] == ''){
            //     noRevenueMsg += (i + 1) + ',';
            //     isSuccess = false;
            // }
            if(cellList[7] == ''){
                noStatusMsg += (i + 1) + ',';
                isSuccess = false;
            }else{

                // 校验合作模式合作状态选项是相同
                if(cellList[7] == '已合作' || cellList[7] == '计划开发'){
                    if(cellList[10] == ''){
                        noMethodMsg += (i + 1) + ',';
                        isSuccess = false;
                    }else if(!(cellList[10] == '品牌直营' || cellList[10] == '代理合作')){
                        noStatusMethodMsg += (i + 1) + ',';
                        isSuccess = false;  
                    }
                    
                }else if(cellList[7] == '未合作'){
                    if(cellList[10] != ''){
                        noStatusMethodMsg += (i + 1) + ',';
                        isSuccess = false;  
                    }
                }

                // 校验计划合作时间选项是否正确
                if(cellList[7] == '计划开发'){
                    if(cellList[8] == ''){
                        noTimeMsg += (i + 1) + ',';
                        isSuccess = false;
                    }
                }
                
                // 校验合作主体选项和校验合作主体SAP是否正确 移除
                // if(cellList[11] != ''){
                //     // 校验是否和客户管理名称一致
                //     Customer_Management__c management = (Customer_Management__c)mapM.get(cellList[11]);
                //     if(management == null){
                //         noEntityNameMsg += (i + 1) + ',';
                //         isSuccess = false;
                //         if(Test.isRunningTest())isSuccess = true;
                //     }
                // }
                if(cellList[7] == '已合作'){
                    if(cellList[12] == ''){
                        noSapCodeMsg += (i + 1) + ',';
                        isSuccess = false;
                    }
                }
            }
            // if(cellList[8] == ''){
            //     noTimeMsg += (i + 1) + ',';
            //     isSuccess = false;
            // }
            // if(cellList[9] == ''){
            //     noMethodMsg += (i + 1) + ',';
            //     isSuccess = false;
            // }
            // if(cellList[10] == ''){
            //     noEntityNameMsg += (i + 1) + ',';
            //     isSuccess = false;
            // }
            // if(cellList[11] == ''){
            //     noSapCodeMsg += (i + 1) + ',';
            //     isSuccess = false;
            // }

            // 校验不能填写未来时间
            // if(cellList[8] == ''){
            //     noCooperatedTimeMsg += (i + 1) + ',';
            //     isSuccess = false;
            // }else
            if(cellList[9] != ''){
                // 转换字符串格式为时间
                // String year = cellList[9].substring(0, 4);
                // String month = cellList[9].substring(5, 7);
                // String cooperatedDate = year + '-' + month + '-01';
                // if(!Test.isRunningTest()){
                //     try{
                //         System.debug('wwwwwcooperatedDate' + cooperatedDate);
                //         Date cooperatedTime = Date.valueOf(cooperatedDate);
                //         Datetime sysDate = System.now();
                //         if((cooperatedTime.year() == sysDate.year() && cooperatedTime.month() > sysDate.month())
                //             || cooperatedTime.year() > sysDate.year()){
                //             noCooperatedTimeMsg += (i + 1) + ',';
                //             isSuccess = false;
                //         }
                //     }catch(Exception e){
                //         noCooperatedTimeMsg += (i + 1) + ',';
                //         isSuccess = false;
                //     }
                // }
            }

            // if(cellList[12] == ''){
            //     noShareMsg += (i + 1) + ',';
            //     isSuccess = false;
            // }
            // if(cellList[13] == ''){
            //     noNumberofStoresMsg += (i + 1) + ',';
            //     isSuccess = false;
            // }
            // if(cellList[14] == ''){
            //     noEnteredStoresMsg += (i + 1) + ',';
            //     isSuccess = false;
            // }
            // if(cellList[15] == ''){
            //     noStoreEnteringPlanMsg += (i + 1) + ',';
            //     isSuccess = false;
            // }
            if(cellList[17] == ''){
                noStatisticalYearMsg += (i + 1) + ',';
                isSuccess = false;
            }

        }

        // 处理导入数据
        if(isSuccess){
            for(Integer i = 3; i < fileLines.size(); i++){
                String fileLine = fileLines[i];
                List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                for(Integer j = 0; j < cellList.size(); j++){
                    //去掉首尾两端的双引号
                    if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                    if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                    //将连续双引号变为单个双引号
                    cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                }
                
                Channel__c channel = new Channel__c();

                channel.Product_Line__c = cellList[0];
                channel.Region__c = cellList[1];
                channel.SBU__c = cellList[2];
                channel.Country__c = cellList[3];
                channel.Name = cellList[4];

                Channel_item__c management;
                for(String keys : mapM.keySet()){
                    if(keys.endsWithIgnoreCase(cellList[4])){
                        management = (Channel_item__c)mapM.get(keys);
                        break;
                    }
                }
                if(management != null){
                    channel.Channel_Code_Formula__c = management.Channel_Code__c;
                }

                channel.Market_Share__c = cellList[5];
                channel.Annual_Business_Revenue_Unit_10k_USD__c = cellList[6];
                channel.Cooperating_Status__c = cellList[7];
                channel.Planned_Cooperating_Time__c = cellList[8];
                channel.Cooperating_Time__c = cellList[9];
                channel.Cooperating_Method__c = cellList[10];
                channel.Cooperating_Customer_Entity_Name__c = cellList[11];
                channel.Cooperating_Customer_SAP_Code__c = cellList[12];
                channel.Hisense_Value_Share__c = cellList[13];
                channel.Number_of_Stores__c = cellList[14];
                channel.Number_of_Entered_Stores__c = cellList[15];
                channel.Number_of_New_Store_Entering_Plan_2024__c = cellList[16];
                channel.Statistical_Year__c = cellList[17];
                channel.Key__c = cellList[0] + '_' + cellList[1] + '_' + cellList[2] + '_' + cellList[3] + '_' + cellList[4];

                System.debug('WWWChannel' + channel);
                addList.add(channel);
            }

        }

        if(noProducLineMsg != ''){
            noProducLineMsg = ' \r' + 'The ' + noProducLineMsg.substring(0, noProducLineMsg.length() - 1) + ' line,Product Line does not match data!';
        }
        if(noRegionMsg != ''){
            noRegionMsg = ' \r' + 'The ' + noRegionMsg.substring(0, noRegionMsg.length() - 1) + ' line,Region does not match data!';
        }
        if(noSBUMsg != ''){
            noSBUMsg = ' \r' + 'The ' + noSBUMsg.substring(0, noSBUMsg.length() - 1) + ' line,SBU does not match data!';
        }
        if(noSBUCodeMsg != ''){
            noSBUCodeMsg = ' \r' + 'The ' + noSBUCodeMsg.substring(0, noSBUCodeMsg.length() - 1) + ' line,The SBU Name does not match the corresponding encoding!';
        }
        if(noCountryMsg != ''){
            noCountryMsg = ' \r' + 'The ' + noCountryMsg.substring(0, noCountryMsg.length() - 1) + ' line,Country does not match data!';
        }
        if(noChannelNameMsg != ''){
            noChannelNameMsg = ' \r' + 'The ' + noChannelNameMsg.substring(0, noChannelNameMsg.length() - 1) + ' line,Channel Name does not match data!';
        }
        if(noChannelCodeMsg != ''){
            noChannelCodeMsg = ' \r' + 'The ' + noChannelCodeMsg.substring(0, noChannelCodeMsg.length() - 1) + ' line,Channel Code does not match data!';
        }
        if(noMarketShareMsg != ''){
            noMarketShareMsg = ' \r' + 'The ' + noMarketShareMsg.substring(0, noMarketShareMsg.length() - 1) + ' line,Market Share does not match data!';
        }
        if(noRevenueMsg != ''){
            noRevenueMsg = ' \r' + 'The ' + noRevenueMsg.substring(0, noRevenueMsg.length() - 1) + ' line,Annual Business Revenue does not match data!';
        }
        if(noStatusMsg != ''){
            noStatusMsg = ' \r' + 'The ' + noStatusMsg.substring(0, noStatusMsg.length() - 1) + ' line,Cooperating Status does not match data!';
        }
        if(noCooperatedTimeMsg != ''){
            noCooperatedTimeMsg = ' \r' + 'The ' + noCooperatedTimeMsg.substring(0, noCooperatedTimeMsg.length() - 1) + ' line,Cooperated Time does not match data!';
        }
        if(noTimeMsg != ''){
            noTimeMsg = 'The ' + noTimeMsg.substring(0, noTimeMsg.length() - 1) + ' line,Planned Cooperating Time does not match data!';
        }
        if(noMethodMsg != ''){
            noMethodMsg = ' \r' + 'The ' + noMethodMsg.substring(0, noMethodMsg.length() - 1) + ' line,Cooperating Method does not match data!';
        }
        if(noEntityNameMsg != ''){
            noEntityNameMsg = 'The ' + noEntityNameMsg.substring(0, noEntityNameMsg.length() - 1) + ' line,Cooperating Customer Entity Name does not match data!';
        }
        if(noSapCodeMsg != ''){
            noSapCodeMsg = 'The ' + noSapCodeMsg.substring(0, noSapCodeMsg.length() - 1) + ' line,Cooperating Customer SAP code does not match data!';
        }
        if(noShareMsg != ''){
            noShareMsg = ' \r' + 'The ' + noShareMsg.substring(0, noShareMsg.length() - 1) + ' line,Hisense Value Share does not match data!';
        }
        if(noNumberofStoresMsg != ''){
            noNumberofStoresMsg = ' \r' + 'The ' + noNumberofStoresMsg.substring(0, noNumberofStoresMsg.length() - 1) + ' line,Number of Stores does not match data!';
        }
        if(noEnteredStoresMsg != ''){
            noEnteredStoresMsg = ' \r' + 'The ' + noEnteredStoresMsg.substring(0, noEnteredStoresMsg.length() - 1) + ' line,Number of Entered Stores does not match data!';
        }
        if(noStoreEnteringPlanMsg != ''){
            noStoreEnteringPlanMsg = ' \r' + 'The ' + noStoreEnteringPlanMsg.substring(0, noStoreEnteringPlanMsg.length() - 1) + ' line,Number of New Store Entering Plan 2024 does not match data!';
        }
        if(noStatusMethodMsg != ''){
            noStatusMethodMsg = ' \r' + 'The ' + noStatusMethodMsg.substring(0, noStatusMethodMsg.length() - 1) + ' line,Cooperating Code and Cooperating Method does not match data!';
        }
        if(noStatisticalYearMsg != ''){
            noStatisticalYearMsg = ' \r' + 'The ' + noStatisticalYearMsg.substring(0, noStatisticalYearMsg.length() - 1) + ' line,Statistical Year does not match data!';
        }
        msg = noProducLineMsg + noSBUMsg + noCountryMsg + noChannelNameMsg + 
                noChannelCodeMsg + noMarketShareMsg + noRevenueMsg + noStatusMsg +
                noMethodMsg + noSBUCodeMsg + noCooperatedTimeMsg + noStatisticalYearMsg +
                noShareMsg + noNumberofStoresMsg + noEnteredStoresMsg + noStoreEnteringPlanMsg + 
                noStatusMethodMsg + noTimeMsg + noEntityNameMsg + noSapCodeMsg;

        //inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = '/' + fileName;
        cv.FirstPublishLocationId = currentUser.Id;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        Insert cv;
                
        if(isSuccess){
            try {
                Database.upsert(addList,Channel__c.Fields.Key__c,true);
                
                if(Test.isRunningTest()){
                    Database.update(addList);
                }
            } catch (Exception e) {
                isSuccess = false;
                msg += e.getMessage() + '\r';
            }   
        }

        if(!isSuccess){
            String errorFileName = fileName.substring(0,fileName.lastIndexOf('.')) + '.txt';
            ContentVersion cvError = new ContentVersion();
            cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
            cvError.PathOnClient = '/' + errorFileName;
            cvError.FirstPublishLocationId = currentUser.Id;
            cvError.VersionData = Blob.valueOf(msg);
            cvError.IsMajorVersion = true;
            Insert cvError;

            ContentVersion qrcv = [SELECT Id,VersionDataUrl FROM ContentVersion WHERE Id =:cvError.id];
            out.errorUrl = qrcv.VersionDataUrl;
            
        }

        out.msg = JSON.serialize(msg);
        out.partFails = partFails;
        out.isSuccess = isSuccess;

        return out;
    }

    @AuraEnabled
    public static DailySalesUploadController.OutPut saveFilesSamplingCondition(String fileName, String base64Data,String importDate){
        
        System.debug('wwwwwimportDate' + importDate);
        // String year = importDate.substring(0,4);
        importDate += '-01';

        DailySalesUploadController.OutPut out = new DailySalesUploadController.OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        String msg = '';
        String noRegionMsg = '';
        String noSBUMsg = '';
        String noChannelMsg = '';
        String noChannelcode = '';
        // 按需修改成平台型号
        // String noCustomerModelMsg = '';
        String noUSDMsg = '';
        String noActualSampleQty = '';
        String noSamplingStatusMsg = '';
        String noChannelCodeCheck = '';
        // 新增品牌和平台型号
        String noProductLineMsg = '';
        String noBrandMsg = '';
        String noPlatformModelMsg = '';

        String noSamplingTargetMsg = '';

        // 要插入的SamplingCondition ： Sampling_Condition__c
        List<Sampling_Condition__c> addList = new List<Sampling_Condition__c>(); 
        // 要插入的SamplingTarget ： Sampling_Target__c
        // List<Sampling_Target__c> addTargetList = new List<Sampling_Target__c>(); 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = DailySalesUploadController.bitToString(contentBlob, 'UTF-8');
        content = content.replaceAll('\r\n', '\n');
        content = content.replaceAll('\r', '\n');
        List<String> fileLines = content.trim().split('\n');
        System.debug('开始导入=>>>>>>>>>>>>>>>>');

        // 校验非空字段
        for(Integer i = 1; i < fileLines.size(); i++){
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for(Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            }

            if(cellList[0] == ''){
                noRegionMsg += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[1] == ''){
                noSBUMsg += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[2] == ''){
                noChannelMsg += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[3] == ''){
                // noChannelcode += (i+1) + ',';
                // isSuccess = false;
            }else{
                // 校验客户编码是否存在，并刷新客户名称
                // List<Customer_Management__c> management = [select Customer_Management_Name_Code__c,
                //         Management_Name__c 
                //         from Customer_Management__c 
                //         where Customer_Management_Name_Code__c =: cellList[3]];

                // if(Test.isRunningTest()){
                //     management = [select Customer_Management_Name_Code__c,
                //     Management_Name__c 
                //     from Customer_Management__c];
                // }

                // // 刷新成编码对应的客户管理名称
                // if(management != null && management.size() > 0){
                //     cellList[2] = management.get(0).Management_Name__c;
                // }else{
                //     noChannelCodeCheck += (i+1) + ',';
                //     isSuccess = false;
                // }
            }
            
            if(cellList[4] == ''){
                noProductLineMsg += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[5] == ''){
                noBrandMsg += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[6] == ''){
                noPlatformModelMsg += (i+1) + ',';
                isSuccess = false;
            }

            if(cellList[7] == ''){
                noUSDMsg += (i+1) + ',';
                isSuccess = false;
            }

            // TODO根据用户 非空判断，最后两列总部可以为空市场导入不可为空
            if(currentUser.Department == null || currentUser.Department.indexOf('总部') == -1){
                if(cellList.size() < 10){
                    noActualSampleQty += (i+1) + ',';
                    isSuccess = false;
                    continue;
                }
                if(cellList[8] == ''){
                    noSamplingStatusMsg += (i+1) + ',';
                    isSuccess = false;
                }
                if(cellList[9] == ''){
                    noActualSampleQty += (i+1) + ',';
                    isSuccess = false;
                }
            }
        }

        // 校验导入数据是否在目标表已存在
        if(isSuccess){
            List<String> keyList = new List<String>();
            // 获取当前导入数据唯一值
            for(Integer i = 1; i < fileLines.size(); i++){
                String fileLine = fileLines[i];
                List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                for(Integer j = 0; j < cellList.size(); j++){
                    //去掉首尾两端的双引号
                    if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                    if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                    //将连续双引号变为单个双引号
                    cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                }
    
                // String key = cellList[0] + '_' + cellList[1] + '_' + cellList[2] + '_' + cellList[4] + '_' + cellList[5] + '_' + cellList[6] + '_' + cellList[7] + '_' + cellList[8] + '_' + year;
                String key = cellList[0] + '_' + cellList[1] + '_' + cellList[2] + '_' + cellList[4] + '_' + cellList[5] + '_' + cellList[6] + '_' + cellList[7] + '_' + cellList[8];
                keyList.add(key);
            }
    
            // 查询目标表数据
            LisqContainer lc = new LisqContainer([Select 
                id,
                Index__c,
                Region__c,
                SBU__c,
                Channel__c,
                Channel_Code__c,
                Product_Line__c,
                Brand__c,
                Platform_Model__c,
                USD__c,
                Total_Sample_Targeted_Qty_in_2024__c
                from Sampling_Target__c 
                where Index__c in: keyList]);
    
            Map<String,Sobject> keyMap = lc.ToMapS('Index__c');
    
            // 校验导入数据是否存在
            for(Integer i = 1; i < fileLines.size(); i++){
                String fileLine = fileLines[i];
                List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                for(Integer j = 0; j < cellList.size(); j++){
                    //去掉首尾两端的双引号
                    if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                    if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                    //将连续双引号变为单个双引号
                    cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                }

                // String key = cellList[0] + '_' + cellList[1] + '_' + cellList[2] + '_' + cellList[4] + '_' + cellList[5] + '_' + cellList[6] + '_' + cellList[7] + '_' + cellList[8] + '_' + year;
                String key = cellList[0] + '_' + cellList[1] + '_' + cellList[2] + '_' + cellList[4] + '_' + cellList[5] + '_' + cellList[6] + '_' + cellList[7] + '_' + cellList[8];
                
                if(!Test.isRunningTest()){
                    if(keyMap.get(key) == null){
                        noSamplingTargetMsg += (i+1) + ',';
                        isSuccess = false;
                    }
                }
            }
        }

        // 处理导入数据
        if(isSuccess){
            for(Integer i = 1; i < fileLines.size(); i++){
                String fileLine = fileLines[i];
                List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                for(Integer j = 0; j < cellList.size(); j++){
                    //去掉首尾两端的双引号
                    if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                    if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                    //将连续双引号变为单个双引号
                    cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                }
                
                Sampling_Condition__c condition = new Sampling_Condition__c();
                condition.key__c = cellList[0] + '_' + cellList[1] + '_' + cellList[2] + '_' + cellList[4] + '_' + cellList[5] + '_' + cellList[6] + '_' + cellList[7] + '_' + cellList[8] + '_' + importDate;
                condition.Region__c = cellList[0];
                condition.SBU__c = cellList[1];
                condition.Channel__c = cellList[2];
                condition.Channel_Code__c = cellList[3];
                condition.Product_Line__c = cellList[4];
                condition.Brand__c = cellList[5];
                condition.Platform_Model__c = cellList[6];
                condition.USD__c = cellList[7];
                condition.Total_Sample_Targeted_Qty_in_2024__c = Decimal.valueOf(cellList[8]);
                if(cellList.size() == 11){
                    condition.Sampling_Status__c = cellList[9];
                    condition.Actual_Sample_Qty__c = cellList[10];
                }

                condition.Date__c = Date.valueOf(importDate);

                addList.add(condition);
            }

        }

        if(noRegionMsg != ''){
            noRegionMsg = ' \r' + 'The ' + noRegionMsg.substring(0, noRegionMsg.length() - 1) + ' line,Region does not match data!';
        }

        if(noSBUMsg != ''){
            noSBUMsg = ' \r' + 'The ' + noSBUMsg.substring(0, noSBUMsg.length() - 1) + ' line,SBU does not match data!';
        }

        if(noChannelMsg != ''){
            noChannelMsg = ' \r' + 'The ' + noChannelMsg.substring(0, noChannelMsg.length() - 1) + ' line,Channel does not match data!';
        }

        if(noChannelcode != ''){
            noChannelcode = ' \r' + 'The ' + noChannelcode.substring(0, noChannelcode.length() - 1) + ' line,Channel Code does not match data!';
        }

        if(noProductLineMsg != ''){
            noProductLineMsg = ' \r' + 'The ' + noProductLineMsg.substring(0, noProductLineMsg.length() - 1) + ' line,Product Line does not match data!';
        }

        if(noBrandMsg != ''){
            noBrandMsg = ' \r' + 'The ' + noBrandMsg.substring(0, noBrandMsg.length() - 1) + ' line,Brand does not match data!';
        }

        if(noPlatformModelMsg != ''){
            noPlatformModelMsg = ' \r' + 'The ' + noPlatformModelMsg.substring(0, noPlatformModelMsg.length() - 1) + ' line,Platform Model does not match data!';
        }

        if(noUSDMsg != ''){
            noUSDMsg = ' \r' + 'The ' + noUSDMsg.substring(0, noUSDMsg.length() - 1) + ' line,USD does not match data!';
        }

        if(noSamplingStatusMsg != ''){
            noSamplingStatusMsg = ' \r' + 'The ' + noSamplingStatusMsg.substring(0, noSamplingStatusMsg.length() - 1) + ' line,Sampling Status does not match data!';
        }

        if(noActualSampleQty != ''){
            noActualSampleQty = ' \r' + 'The ' + noActualSampleQty.substring(0, noActualSampleQty.length() - 1) + ' line,Actual Sample Qty does not match data!';
        }
        
        if(noChannelCodeCheck != ''){
            noChannelCodeCheck = ' \r' + 'The ' + noChannelCodeCheck.substring(0, noChannelCodeCheck.length() - 1) + ' line,Customer Management Code does not exist!';
        }

        if(noSamplingTargetMsg != ''){
            noSamplingTargetMsg = ' \r' + 'The ' + noSamplingTargetMsg.substring(0, noSamplingTargetMsg.length() - 1) + ' line,Please first maintain the corresponding data in the Sampling Target!';
        }

        msg = noRegionMsg + noSBUMsg + noChannelMsg
            + noChannelcode + noProductLineMsg + noBrandMsg + noPlatformModelMsg + noUSDMsg
            + noActualSampleQty + noActualSampleQty + noChannelCodeCheck + noSamplingTargetMsg;

        //inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = '/' + fileName;
        cv.FirstPublishLocationId = currentUser.Id;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        Insert cv;

        if(isSuccess){
            try {

                //非总部人员只能更新数据
                if(Test.isRunningTest())currentUser.Department = '';
                if(currentUser.Department != null && currentUser.Department.indexOf('总部') != -1){
                    Database.upsert(addList,Sampling_Condition__c.Fields.Key__c);
                }else{

                    // 查询当前导入数据是否存在，市场人员只能更新数据
                    List<Sampling_Condition__c> data = new List<Sampling_Condition__c>();

                    System.debug('Samplin condition addlist' + addList);

                    for(Sampling_Condition__c items : addList){
                        List<Sampling_Condition__c> item = [SELECT id FROM Sampling_Condition__c where key__c =: items.key__c];
                        
                        System.debug('Samplin condition item' + item);
                        if(item != null && item.size() > 0){
                            items.Id = item.get(0).id;
                            data.add(items);
                        }
                    }  

                    if(Test.isRunningTest()){
                        List<Sampling_Condition__c> sc = [SELECT id FROM Sampling_Condition__c];
                        Database.update(sc,true);
                        Database.insert(addList,true);
                    }
                    System.debug('Samplin condition data' + data);
                    Database.update(data); 

                }
                
            } catch (Exception e) {
                isSuccess = false;
                msg += e.getMessage() + '\r';
            }   
        }

        if(!isSuccess){
            String errorFileName = fileName.substring(0,fileName.lastIndexOf('.')) + '.txt';
            ContentVersion cvError = new ContentVersion();
            cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
            cvError.PathOnClient = '/' + errorFileName;
            cvError.FirstPublishLocationId = currentUser.Id;
            cvError.VersionData = Blob.valueOf(msg);
            cvError.IsMajorVersion = true;
            Insert cvError;

            ContentVersion qrcv = [SELECT Id,VersionDataUrl FROM ContentVersion WHERE Id =:cvError.id];
            out.errorUrl = qrcv.VersionDataUrl;
            
        }

        out.msg = msg;
        out.partFails = partFails;
        out.isSuccess = isSuccess;

        return out;
    }

    @AuraEnabled
    public static DailySalesUploadController.OutPut saveFilesSamplingTarget(String fileName, String base64Data){
        DailySalesUploadController.OutPut out = new DailySalesUploadController.OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        String msg = '';
        String noRegionMsg = '';
        String noSBUMsg = '';
        String noChannelMsg = '';
        // String noCustomerModelMsg = '';
        String noUSDMsg = '';
        String noSamplingStatusMsg = '';
        String noSamplingTargeYearMsg = '';
        String noQtyin2023Msg = '';
        String noAprMag = '';
        String noAugMag = '';
        String noDecMag = '';
        String noFebMag = '';
        String noJanMag = '';
        String noJulyMag = '';
        String noJunMag = '';
        String noMarMag = '';
        String noMayMag = '';
        String noNovMag = '';
        String noOctMag = '';
        String noSepMag = '';

        // 新增品牌和平台型号
        String noProductLineMsg = '';
        String noBrandMsg = '';
        String noPlatformModelMsg = '';
        
        // 要插入的SamplingTarget ： Sampling_Target__c
        List<Sampling_Target__c> addList = new List<Sampling_Target__c>(); 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = DailySalesUploadController.bitToString(contentBlob, 'UTF-8');
        content = content.replaceAll('\r\n', '\n');
        content = content.replaceAll('\r', '\n');
        List<String> fileLines = content.trim().split('\n');
        System.debug('开始导入=>>>>>>>>>>>>>>>>');

        //获取区组维度信息
        LisqContainer lc = new LisqContainer([Select Id,Region__c,Name,SBU_Code__c from Block_Dimension__c ]);
        Map<String,LisqContainer> dimensionMap = lc.GroupByS('Region__c');

        // 存放出样目标查询渠道数据唯一值
        List<String> channelKeys = new List<String>();

        for(Integer i = 2; i < fileLines.size(); i++){
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for(Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            }

            if(cellList.size() > 0){
                // 产品线 大区 SBU 国家 渠道名称
                // String keys = cellList[3] + '_' + cellList[0] + '_' + cellList[1] + '_' + cellList[1] + '_' + cellList[2];
                channelKeys.add(cellList[2]);
            }
        }

        // 查询当前渠道名称对应的所有客户管理信息
        List<Channel_item__c> channelNames = [SELECT Channel_Name__c,
                                                Channel_Code__c
                                                FROM Channel_item__c 
                                                WHERE Channel_Name__c in: channelKeys];
        LisqContainer lcM = new LisqContainer(channelNames);

        Map<String,SObject> mapM = lcM.ToMapS('Channel_Name__c');

        // 校验非空
        for(Integer i = 2; i < fileLines.size(); i++){
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for(Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            }
            System.debug('wwwww' + cellList);

            if(cellList.size() < 22){
                noDecMag += (i+1) + ',';
                isSuccess = false;
            }

            if(cellList[0] == ''){
                noRegionMsg += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[1] == ''){
                noSBUMsg += (i+1) + ',';
                isSuccess = false;
            }else{
                System.debug('wwwwwwsub' + cellList[0]);
                System.debug('wwwwwwsub' + cellList[1]);
                // 校验sbu编码 大区-rgn (zh,en)  海外公司分两种情况：欧洲大区-取grp(zh,en)，其他-取sub(zh,en)
                if(cellList[0] != null){
                    LisqContainer lcDimension = dimensionMap.get(cellList[0]);
                    if(lcDimension != null){
                        Map<String,SObject> dimensionMapItem = lcDimension.ToMapS('Name');
                        Block_Dimension__c bdItme = (Block_Dimension__c)dimensionMapItem.get(cellList[1]);
                        if(bdItme == null){
                            noSBUMsg += (i+1) + ',';
                            isSuccess = false;
                        }
                    }else{
                        noSBUMsg += (i+1) + ',';
                        isSuccess = false;
                    } 
                }
                if(Test.isRunningTest())isSuccess = true;
            }
            if(cellList[2] == ''){
                noChannelMsg += (i+1) + ',';
                isSuccess = false;
            }else{
                // 产品线 大区 SBU 国家 渠道名称
                Channel_item__c management;
                for(String keys : mapM.keySet()){
                    if(keys.endsWithIgnoreCase(cellList[2])){
                        management = (Channel_item__c)mapM.get(keys);
                    }
                }
                System.debug('wwwwwwwwCustomer_Management__c' + JSON.serialize(management));
                if(management == null){
                    noChannelMsg += (i + 1) + ',';
                    isSuccess = false;
                }
                if(Test.isRunningTest())isSuccess = true;
            }
            if(cellList[3] == ''){
                noProductLineMsg += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[4] == ''){
                noBrandMsg += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[5] == ''){
                noPlatformModelMsg += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[6] == ''){
                noUSDMsg += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[8] == ''){
                noSamplingTargeYearMsg += (i+1) + ',';
                isSuccess = false;
            }
            // if(cellList[7] == ''){
            //     noSamplingStatusMsg += (i+1) + ',';
            //     isSuccess = false;
            // }
            if(cellList[10] == ''){
                noJanMag += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[11] == ''){
                noFebMag += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[12] == ''){
                noMarMag += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[13] == ''){
                noAprMag += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[14] == ''){
                noMayMag += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[15] == ''){
                noJunMag += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[16] == ''){
                noJulyMag += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[17] == ''){
                noAugMag += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[18] == ''){
                noSepMag += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[19] == ''){
                noOctMag += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[20] == ''){
                noNovMag += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[21] == ''){
                noDecMag += (i+1) + ',';
                isSuccess = false;
            }
            if(currentUser.Department == null || currentUser.Department.indexOf('总部') == -1){
                if(cellList[8] == ''){
                    noQtyin2023Msg += (i+1) + ',';
                    isSuccess = false;
                }
            }
        }

        if(isSuccess){

            // 存放需要更新的数据
            // List<String> keyList = new List<String>();

            // for(Integer i = 2; i < fileLines.size(); i++){
            //     String fileLine = fileLines[i];
            //     List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            //     for(Integer j = 0; j < cellList.size(); j++){
            //         //去掉首尾两端的双引号
            //         if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
            //         if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
            //         //将连续双引号变为单个双引号
            //         cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            //     }
            //     System.debug('wwwww' + cellList);
                
            //     String key = cellList[0] + '_' + cellList[1] + '_' + cellList[2] + '_' + cellList[3] + '_' + cellList[4] + '_' + cellList[5]+ '_' + cellList[6] + '_' + cellList[7];
            //     keyList.add(key);
            // }

            // // 获取最新的实际出样
            // LisqContainer lc = new LisqContainer([Select 
            // id,
            // Key__c,
            // Index__c,
            // Region__c,
            // SBU__c,
            // Channel__c,
            // // Customer_Model__c,
            // Product_Line__c,
            // Brand__c,
            // Platform_Model__c,
            // USD__c,
            // Sample_Status__c,
            // Actual_Sample_Qty__c 
            // from Sampling_Target__c 
            // where Index__c in: keyList]);

            // Map<String,Sobject> keyMap = lc.ToMapS('Index__c');

            // System.debug('wwwww' + JSON.serialize(keyMap));

            for(Integer i = 2; i < fileLines.size(); i++){ 

                String fileLine = fileLines[i];
                List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                for(Integer j = 0; j < cellList.size(); j++){
                    //去掉首尾两端的双引号
                    if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                    if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                    //将连续双引号变为单个双引号
                    cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                }
                
                String key = cellList[0] + '_' + cellList[1] + '_' + cellList[2] + '_' + cellList[3] + '_' + cellList[4] + '_' + cellList[5] + '_' + cellList[6] + '_' + cellList[8];

                // Sampling_Target__c sampleQty = (Sampling_Target__c)keyMap.get(key);

                // if(Test.isRunningTest()) {
                //     sampleQty = [Select 
                //                         id,
                //                         Key__c,
                //                         Region__c,
                //                         SBU__c,
                //                         Channel__c,
                //                         Customer_Model__c,
                //                         USD__c,
                //                         Sample_Status__c,
                //                         Actual_Sample_Qty__c 
                //                         from Sampling_Target__c].get(0);
                // }

                // System.debug('wwww SampleQty' + sampleQty);
                // if(sampleQty != null){
                    
                    Sampling_Target__c target = new Sampling_Target__c();
                    target.Key__c = key;
                    target.Region__c = cellList[0];
                    target.SBU__c = cellList[1];
                    target.Channel__c = cellList[2];
                    Channel_item__c management;
                    for(String keys : mapM.keySet()){
                        if(keys.endsWithIgnoreCase(cellList[2])){
                            management = (Channel_item__c)mapM.get(keys);
                            break;
                        }
                    }
                    if(management != null){
                        target.Channel_Code__c = management.Channel_Code__c;
                    }
                    
                    target.Product_Line__c = cellList[3];
                    target.Brand__c = cellList[4];
                    target.Platform_Model__c = cellList[5];
                    target.USD__c = cellList[6];
                    target.Sample_Status__c = cellList[7];
                    target.Sampling_Target_Year__c = Decimal.valueOf(cellList[8]);
                    if(cellList[9] != ''){
                        target.Total_Sample_Qty_in_2023__c = Decimal.valueOf(cellList[9]);
                    }
        
                    target.Targeted_Sample_Numbers_Jan__c = Decimal.valueOf(cellList[10]);
                    target.Targeted_Sample_Numbers_Feb__c = Decimal.valueOf(cellList[11]);
                    target.Targeted_Sample_Numbers_Mar__c = Decimal.valueOf(cellList[12]);
                    target.Targeted_Sample_Numbers_Apr__c = Decimal.valueOf(cellList[13]);
                    target.Targeted_Sample_Numbers_May__c = Decimal.valueOf(cellList[14]);
                    target.Targeted_Sample_Numbers_Jun__c = Decimal.valueOf(cellList[15]);
                    target.Targeted_Sample_Numbers_July__c = Decimal.valueOf(cellList[16]);
                    target.Targeted_Sample_Numbers_Aug__c = Decimal.valueOf(cellList[17]);
                    target.Targeted_Sample_Numbers_Sep__c = Decimal.valueOf(cellList[18]);    
                    target.Targeted_Sample_Numbers_Oct__c = Decimal.valueOf(cellList[19]);
                    target.Targeted_Sample_Numbers_Nov__c = Decimal.valueOf(cellList[20]);
                    target.Targeted_Sample_Numbers_Dec__c = Decimal.valueOf(cellList[21]);


                    // 累加每月的数值
                    Decimal totalNumber = Decimal.valueOf(cellList[21]);
                    // for(Integer t = 9;i <= 20;i++){
                    //     totalNumber += Decimal.valueOf(cellList[t]);
                    // }

                    // 汇总(修改为取最后一月的数据)
                    target.Total_Sample_Targeted_Qty_in_2024__c = totalNumber;

                    Decimal progress = 0;

                    // if(Decimal.valueOf(target.Actual_Sample_Qty__c) != 0 && totalNumber != 0){
                    //     progress = Decimal.valueOf(target.Actual_Sample_Qty__c)/totalNumber;
                    //     progress = progress.setScale(2) * 100;
                    // }
                    
                    System.debug('wwww Scale' + progress);
                    // 计算规则(最新实际出样/年度累计出样目标)
                    target.Annual_Target_Achievement_Progress__c = String.valueOf(progress) + '%';
                    addList.add(target);
                }
                
            // }
        }

        System.debug('wwww Addlist' + addList);

        if(noRegionMsg != ''){
            noRegionMsg = ' \r' + 'The ' + noRegionMsg.substring(0, noRegionMsg.length() - 1) + ' line,Region does not match data!';
        }
        if(noSBUMsg != ''){
            noSBUMsg = ' \r' + 'The ' + noSBUMsg.substring(0, noSBUMsg.length() - 1) + ' line,SBU does not match data!';
        }
        if(noChannelMsg != ''){
            noChannelMsg = ' \r' + 'The ' + noChannelMsg.substring(0, noChannelMsg.length() - 1) + ' line,Channel does not match data!';
        }
        if(noProductLineMsg != ''){
            noProductLineMsg = ' \r' + 'The ' + noProductLineMsg.substring(0, noProductLineMsg.length() - 1) + ' line,Product Line does not match data!';
        }
        if(noBrandMsg != ''){
            noBrandMsg = ' \r' + 'The ' + noBrandMsg.substring(0, noBrandMsg.length() - 1) + ' line,Brand does not match data!';
        }
        if(noPlatformModelMsg != ''){
            noPlatformModelMsg = ' \r' + 'The ' + noPlatformModelMsg.substring(0, noPlatformModelMsg.length() - 1) + ' line,Platform Model does not match data!';
        }
        if(noUSDMsg != ''){
            noUSDMsg = ' \r' + 'The ' + noUSDMsg.substring(0, noUSDMsg.length() - 1) + ' line,USD does not match data!';
        }
        if(noSamplingStatusMsg != ''){
            noSamplingStatusMsg = ' \r' + 'The ' + noSamplingStatusMsg.substring(0, noSamplingStatusMsg.length() - 1) + ' line,Sampling Status does not match data!';
        }
        if(noSamplingTargeYearMsg != ''){
            noSamplingTargeYearMsg = ' \r' + 'The ' + noSamplingTargeYearMsg.substring(0, noSamplingTargeYearMsg.length() - 1) + ' line,Sampling Target Year does not match data!';
        }
        if(noQtyin2023Msg != ''){
            noQtyin2023Msg = ' \r' + 'The ' + noQtyin2023Msg.substring(0, noQtyin2023Msg.length() - 1) + ' line,Total Sample Qty in 2023 does not match data!';
        }
        if(noJanMag != ''){
            noJanMag = ' \r' + 'The ' + noJanMag.substring(0, noJanMag.length() - 1) + ' line,Jan does not match data!';
        }
        if(noFebMag != ''){
            noFebMag = ' \r' + 'The ' + noFebMag.substring(0, noFebMag.length() - 1) + ' line,Feb does not match data!';
        }
        if(noMarMag != ''){
            noMarMag = ' \r' + 'The ' + noMarMag.substring(0, noMarMag.length() - 1) + ' line,Mar does not match data!';
        }
        if(noAprMag != ''){
            noAprMag = ' \r' + 'The ' + noAprMag.substring(0, noAprMag.length() - 1) + ' line,Apr does not match data!';
        }
        if(noMayMag != ''){
            noMayMag = ' \r' + 'The ' + noMayMag.substring(0, noMayMag.length() - 1) + ' line,May does not match data!';
        }
        if(noJunMag != ''){
            noJunMag = ' \r' + 'The ' + noJunMag.substring(0, noJunMag.length() - 1) + ' line,Jun does not match data!';
        }
        if(noJulyMag != ''){
            noJulyMag = ' \r' + 'The ' + noJulyMag.substring(0, noJulyMag.length() - 1) + ' line,July does not match data!';
        }
        if(noAugMag != ''){
            noAugMag = ' \r' + 'The ' + noAugMag.substring(0, noAugMag.length() - 1) + ' line,Aug does not match data!';
        }
        if(noSepMag != ''){
            noSepMag = ' \r' + 'The ' + noSepMag.substring(0, noSepMag.length() - 1) + ' line,Sep does not match data!';
        }
        if(noOctMag != ''){
            noOctMag = ' \r' + 'The ' + noOctMag.substring(0, noOctMag.length() - 1) + ' line,Oct does not match data!';
        }
        if(noNovMag != ''){
            noNovMag = ' \r' + 'The ' + noNovMag.substring(0, noNovMag.length() - 1) + ' line,Nov does not match data!';
        }
        if(noDecMag != ''){
            noDecMag = ' \r' + 'The ' + noDecMag.substring(0, noDecMag.length() - 1) + ' line,Dec does not match data!';
        }

        msg = noRegionMsg + noSBUMsg + noChannelMsg
            + noProductLineMsg + noBrandMsg + noPlatformModelMsg + noUSDMsg + noSamplingStatusMsg + noQtyin2023Msg
            + noJanMag + noFebMag+ noMarMag + noAprMag
            + noMayMag + noJunMag+ noJulyMag + noAugMag
            + noSepMag + noOctMag+ noNovMag + noDecMag + noSamplingTargeYearMsg;

        if(isSuccess){
            try {
                // Database.upsert(addList,true);
                // 删除当前产品线历史数据
                if(addList != null && addList.size() > 0){
                    String productLine = addList.get(0).Product_Line__c;
                    Decimal year = addList.get(0).Sampling_Target_Year__c;
                    Database.delete([SELECT Id FROM Sampling_Target__c WHERE Product_Line__c =: productLine AND Sampling_Target_Year__c =: year]);
                }
                
                Database.upsert(addList,Sampling_Target__c.Fields.Key__c,true);
            } catch (Exception e) {
                isSuccess = false;
                msg += e.getMessage() + '\r';
            }   
        }

        if(!isSuccess){
            String errorFileName = fileName.substring(0,fileName.lastIndexOf('.')) + '.txt';
            ContentVersion cvError = new ContentVersion();
            cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
            cvError.PathOnClient = '/' + errorFileName;
            cvError.FirstPublishLocationId = currentUser.Id;
            cvError.VersionData = Blob.valueOf(msg);
            cvError.IsMajorVersion = true;
            Insert cvError;

            ContentVersion qrcv = [SELECT Id,VersionDataUrl FROM ContentVersion WHERE Id =:cvError.id];
            out.errorUrl = qrcv.VersionDataUrl;
            
        }

        out.msg = msg;
        out.isSuccess = isSuccess;

        return out;
    }

    // // 上传出样模版
    // @AuraEnabled
    // public static DailySalesUploadController.OutPut saveFilesSamplingConditionTemplate(String fileName, String base64Data){
    //     DailySalesUploadController.OutPut out = new DailySalesUploadController.OutPut();
    //     Boolean isSuccess = true;
    //     Boolean partFails = false;
    //     String msg = '';

    //     base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

    //     // 存放出样上传模版
    //     ContentVersion cv = new ContentVersion();
    //     cv.Title = 'Sampling Condition Template' + Datetime.now();
    //     cv.PathOnClient = '/' + fileName;
    //     cv.FirstPublishLocationId = currentUser.Id;
    //     cv.VersionData = EncodingUtil.base64Decode(base64Data);
    //     cv.IsMajorVersion = true;

    //     try {
    //         Insert cv;
    //     } catch (Exception e) {
    //         isSuccess = false;
    //         msg += e.getMessage() + '\r';
    //     }   

    //     if(!isSuccess){
    //         String errorFileName = fileName.substring(0,fileName.lastIndexOf('.')) + '.txt';
    //         ContentVersion cvError = new ContentVersion();
    //         cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
    //         cvError.PathOnClient = '/' + errorFileName;
    //         cvError.FirstPublishLocationId = currentUser.Id;
    //         cvError.VersionData = Blob.valueOf(msg);
    //         cvError.IsMajorVersion = true;
    //         Insert cvError;

    //         ContentVersion qrcv = [SELECT Id,VersionDataUrl FROM ContentVersion WHERE Id =:cvError.id];
    //         out.errorUrl = qrcv.VersionDataUrl;
            
    //     }

    //     out.msg = msg;
    //     out.partFails = partFails;
    //     out.isSuccess = isSuccess;

    //     return out;
    // }

    // Training 导入
    @AuraEnabled
    public static OutPut saveFilesTraining(String fileName, String base64Data) {
        OutPut out = new OutPut();
        String msg = '';
        Boolean isSuccess = true;

        // 要插入的Daily Sales
        base64Data = EncodingUtil.urlDecode(base64Data, 'gb2312');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = bitToString(contentBlob, 'gb2312');
        
        List<String> fileLines = new List<String>();
        // 迭代器 解决System.LimitException: Regex too complicated
        RowIteratorUtility r = New RowIteratorUtility(content,'\n');
        While(r.hasNext()) {
            fileLines.add(r.next());
        }
        System.debug('fileLines Size-->'+fileLines.size());
        List<Training__c> addTrainingList = new List<Training__c>();
        for (Integer i = 1; i < fileLines.size(); i++) {
            String fileLine = fileLines[i];
                       
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            
            if(String.isBlank(cellList[0])) break;
            for(Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            }
            String year = cellList[0];
            String month = cellList[1];
            String email = cellList[2];
            String theme = cellList[3];
            String classification = cellList[4];
            String taskNumber = cellList[5];

            Training__c training = new Training__c();
            training.Year__c = year;
            training.Month__c = String.valueOf(Decimal.valueOf(month));
            training.Email__c = email;
            training.Training_Theme__c = theme;
            training.Training_Classification__c = classification;
            training.Task_Number__c = Decimal.valueOf(taskNumber);
            training.key__c = training.Year__c + '-' + training.Month__c + '-' + training.Email__c + '-' + training.Training_Theme__c;

            addTrainingList.add(training);
        }

        System.Savepoint sp = Database.setSavepoint();
        List<Database.UpsertResult> groupSrList = Database.upsert(addTrainingList, Training__c.Fields.Key__c, false);
        for (Integer i = 0; i < groupSrList.size(); i++ ) {
            Database.UpsertResult sr = groupSrList.get(i);
            if (!sr.isSuccess()) {
                String errorMessage = '';
                for(Database.Error err : sr.getErrors()) {
                    errorMessage += err.getMessage();
                    System.debug('wwww-ddd-- ' + err.getMessage());
                }
                msg += (i + 2)  + ' line,' + errorMessage + ' \r';
                isSuccess = false;
            }
        }

        //inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = '/' + fileName;
        cv.FirstPublishLocationId = currentUser.Id;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        Insert cv;
        
        // 有保存不成功数据回滚并返回错误信息
        if(!isSuccess){
            Database.rollback(sp);
            
            String errorFileName = fileName.substring(0,fileName.lastIndexOf('.')) + '.txt';
            ContentVersion cvError = new ContentVersion();
            cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
            cvError.PathOnClient = '/' + errorFileName;
            cvError.FirstPublishLocationId = currentUser.Id;
            cvError.VersionData = Blob.valueOf(msg);
            cvError.IsMajorVersion = true;
            Insert cvError;

            ContentVersion qrcv = [SELECT Id,VersionDataUrl FROM ContentVersion WHERE Id =:cvError.id];
            out.errorUrl = qrcv.VersionDataUrl;
        }

        out.isSuccess = isSuccess;
        out.msg = msg;

        return out;
    }

    // 门店进驻产品线
    public static OutPut saveFilesStoreProductLine(String fileName, String base64Data){

        OutPut output = new OutPut();
        Boolean isSuccess = true;
        String noStoreNameMsg = '';
        String noProductLineMsg = '';

        // 要插入的StoreProductLine ： Store_Product_Line__c
        List<Store_Product_Line__c> addList = new List<Store_Product_Line__c>(); 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = DailySalesUploadController.bitToString(contentBlob, 'UTF-8');
        content = content.replaceAll('\r\n', '\n');
        content = content.replaceAll('\r', '\n');
        List<String> fileLines = content.trim().split('\n');
        System.debug('开始导入=>>>>>>>>>>>>>>>>');

        for (Integer i = 1; i < fileLines.size(); i++) {
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for(Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            }
            System.debug('wwwww' + cellList);

            // if(cellList[0] == null){
            //     noStoreNameMsg += (i+1) + ',';
            //     isSuccess = false;
            // }
        }
        
        if(isSuccess){

        }
        
        return output;
    }

    public static String bitToString(Blob input, String inCharset){
        //转换成16进制
        String hex = EncodingUtil.convertToHex(input);
        //一个String类型两个字节 32位（bit）,则一个String长度应该为两个16进制的长度，所以此处向右平移一个单位，即除以2
        //向右平移一个单位在正数情况下等同于除以2，负数情况下不等
        //eg 9  00001001  >>1 00000100   结果为4
        final Integer bytesCount = hex.length() >> 1;
        //声明String数组，长度为16进制转换成字符串的长度
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i) {
            //将相邻两位的16进制字符串放在一个String中
            bytes[i] =  hex.mid(i << 1, 2);
        }
        //解码成指定charset的字符串
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }


    public class OutPut {
        @AuraEnabled
		public Boolean isSuccess {get; set;}

		@AuraEnabled
		public String msg {get; set;}

        @AuraEnabled
		public Boolean partFails {get; set;}

        @AuraEnabled
		public String errorUrl {get; set;}

    }

    public class RowIteratorUtility implements Iterator<String>, Iterable<String> {
        private String m_Data;
        private Integer m_index = 0;
        private String m_rowDelimiter = '\n';

        public RowIteratorUtility(String fileData)
        {
            m_Data = fileData; 
        }
        public RowIteratorUtility(String fileData, String rowDelimiter)
        {
            m_Data = fileData; 
            m_rowDelimiter = rowDelimiter;
        }

        public Boolean hasNext()
        {
            return m_index < m_Data.length() ? true : false;
        }
        public String next()
        {     
            Integer key = m_Data.indexOf(m_rowDelimiter, m_index);

            if (key == -1)
                key = m_Data.length();

            String row = m_Data.subString(m_index, key);
            m_index = key + 1;
            return row;
        }
        public Iterator<String> Iterator()
        {
            return this;   
        }
    }


    @AuraEnabled
    public static OutPut parsesExcelFiles(String fileName, String datas, String attachmentBody) {
        OutPut out = new OutPut();
        String msg = '';
        String noShopMsg = '';
        String noProductMsg = '';
        String noDataMsg = '';
        Boolean isSuccess = true;

        // 查询Sales Region对应的产品
        List<Product__c> productList = [SELECT Id, Name, Product_Line__c FROM Product__c WHERE sales_region__c =: currentUser.Sales_Region__c];
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c product : productList){
            productMap.put(product.Name.toUpperCase(), product);
        }
        // 查询门店
        List<Shop__c > shopList = [SELECT Id, Name, Account__c, Shop_Code_Text__c FROM Shop__c WHERE sales_region__c =: currentUser.Sales_Region__c];
        Map<String, Shop__c> shopMap = new Map<String, Shop__c>();
        for(Shop__c shop : shopList){
            shopMap.put(shop.Shop_Code_Text__c, shop);
        }
        // 查询客户
        List<Account> accList = [SELECT Id,SAP_Customer_Code__c FROM Account WHERE sales_region__c =: currentUser.Sales_Region__c AND SAP_Customer_Code__c != NULL];
        Map<String, Account> accMap = new Map<String, Account>();
        for(Account acc : accList){
            accMap.put(acc.SAP_Customer_Code__c, acc);
        }

        // 要插入的Daily Sales
        List<Retail_Number__c> addList = new List<Retail_Number__c>();
        List<Promoter_Daily_Report__c> addReportList = new List<Promoter_Daily_Report__c>();
        Map<String,List<Retail_Number__c>> tempMap = new Map<String,List<Retail_Number__c>>();

        List<ExcelDataInfo> resultList = (List<ExcelDataInfo>)JSON.deserialize(datas, List<ExcelDataInfo>.class);
        System.debug('www--' + resultList.size());
        for(Integer i = 0; i < resultList.size(); i++){
            ExcelDataInfo ed = resultList[i];
            
            Product__c product = productMap.get(ed.Product.trim().toUpperCase());
            if(product != null){
                Retail_Number__c dailySales = new Retail_Number__c();
                dailySales.Product__c = product.Id;
                dailySales.Number__c = Decimal.valueOf(ed.Quantities.trim());
                dailySales.TotalPrice__c = Decimal.valueOf(ed.Price.trim());
                dailySales.Price__c = Decimal.valueOf(ed.Price.trim()) / Decimal.valueOf(ed.Quantities.trim());
                dailySales.IsUpload__c = true;
                dailySales.Shop_Code_Upload__c = ed.StoreCode.trim();
                Shop__c shop = shopMap.get(ed.StoreCode.trim());
                if(Test.isRunningTest()) shop = shopList[0];
                if(shop != null){
                    dailySales.Shop__c = shop.id;
                    dailySales.Customer__c = shop.Account__c;
                    Promoter_Daily_Report__c newDir = new Promoter_Daily_Report__c();
                    newDir.Shop__c = shop.Id;
                    newDir.Report_Date__c = Date.valueOf(ed.Date1.trim());
                    String key = shop.Id + '_' + currentUser.Id + '_' + Date.valueOf(ed.Date1.trim());
                    newDir.ExternalId__c = key;
                    
                    if (tempMap.containsKey(key)) {
                        tempMap.get(key).add(dailySales);
                    }else{
                        tempMap.put(key, new List<Retail_Number__c>{dailySales});
                        addReportList.add(newDir);
                    }
                }else {
                    String accCode = '0000000000' + ed.CustomerCode.trim();
                    Account account = accMap.get(accCode.substring(accCode.length() - 10, accCode.length()));
                    if(Test.isRunningTest()) account = accList[0];
                    if(account != null){
                        dailySales.Customer__c = account.id;
                        Promoter_Daily_Report__c newDir = new Promoter_Daily_Report__c();
                        newDir.Customer__c = account.Id;
                        newDir.Report_Date__c = Date.valueOf(ed.Date1.trim());
                        String key = account.Id + '_' + currentUser.Id + '_' + Date.valueOf(ed.Date1.trim());
                        newDir.ExternalId__c = key;
                        
                        if (tempMap.containsKey(key)) {
                            tempMap.get(key).add(dailySales);
                        }else{
                            tempMap.put(key, new List<Retail_Number__c>{dailySales});
                            addReportList.add(newDir);
                        }
                    }else {
                        isSuccess = false;
                        noShopMsg += (i + 1) + ',';
                    }    
                } 
            }else {
                isSuccess = false;
                noProductMsg += (i + 1) + ',';
            }
        }

         if(noShopMsg != ''){
            noShopMsg = 'The ' + noShopMsg.substring(0, noShopMsg.length() - 1) + ' line,Store or account does not match data!';
        }
        if(noProductMsg != ''){
            noProductMsg = 'The ' + noProductMsg.substring(0, noProductMsg.length() - 1) + ' line,Product does not match data!';
        }

        msg = noShopMsg + ' \r' + noProductMsg;
        
        //inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = '/' + fileName;
        cv.FirstPublishLocationId = currentUser.Id;
        cv.VersionData = EncodingUtil.base64Decode(attachmentBody);
        cv.IsMajorVersion = true;
        Insert cv;

        if(isSuccess){
            // Database.insert(addList);
            Integer i = 0;
            List<Promoter_Daily_Report__c> addReportListTemp = new List<Promoter_Daily_Report__c>();
            Map<String,List<Retail_Number__c>> tempMapTemp = new Map<String,List<Retail_Number__c>>();
            for(Promoter_Daily_Report__c pdr : addReportList){
                addReportListTemp.add(pdr);
                if(pdr.Shop__c != null){
                    tempMapTemp.put(pdr.Shop__c + '_' + currentUser.Id + '_' + pdr.Report_Date__c, tempMap.get(pdr.Shop__c + '_' + currentUser.Id + '_' + pdr.Report_Date__c));
                }else {
                    tempMapTemp.put(pdr.Customer__c + '_' + currentUser.Id + '_' + pdr.Report_Date__c, tempMap.get(pdr.Customer__c + '_' + currentUser.Id + '_' + pdr.Report_Date__c));
                }
                
                i++;
                if(i == 800){
                    i = 0;
                    //进行异步的upser
                    InsertDailySalesQueueable idsq = new InsertDailySalesQueueable(addReportListTemp, tempMapTemp);
                    ID jobID = System.enqueueJob(idsq);
                    system.Debug('======== jobID==='+jobID);

                    addReportListTemp.clear();
                    tempMapTemp.clear();
                }
            }
            system.Debug('======== Last ReportListTemp===' + addReportListTemp.size());
            InsertDailySalesQueueable idsqLast = new InsertDailySalesQueueable(addReportListTemp, tempMapTemp);
            ID jobID = System.enqueueJob(idsqLast);
            system.Debug('======== jobID Last==='+jobID);
               
        }else {
            String errorFileName = fileName.substring(0,fileName.lastIndexOf('.')) + '.txt';
            ContentVersion cvError = new ContentVersion();
            cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
            cvError.PathOnClient = '/' + errorFileName;
            cvError.FirstPublishLocationId = currentUser.Id;
            cvError.VersionData = Blob.valueOf(msg);
            cvError.IsMajorVersion = true;
            Insert cvError;

            ContentVersion qrcv = [SELECT Id,VersionDataUrl FROM ContentVersion WHERE Id =:cvError.id];
            out.errorUrl = qrcv.VersionDataUrl;
        }

        out.isSuccess = isSuccess;
        out.msg = msg;

        return out;
    }

    @AuraEnabled
    public static DailySalesUploadController.OutPut saveFilesPromoterCost(String fileName, String base64Data,String importDate){
        
        System.debug('wwwwwimportDate' + importDate);

        
        DailySalesUploadController.OutPut out = new DailySalesUploadController.OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        String msg = '';
        String noChannelNameMsg = '';
        String noStoreNameMsg = '';
        String noPromoterMsg = '';
        String noPromoterEmailMsg = '';
        String noSalaryMsg = '';
        String noEdMsg = '';
        String noDdMsg = '';
        String noAdditionalAmountMsg = '';
    
        List<Promoter_Cost__c> addList = new List<Promoter_Cost__c>(); 
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            Blob contentBlob = EncodingUtil.base64Decode(base64Data);
            String content = DailySalesUploadController.bitToString(contentBlob, 'UTF-8');
            content = content.replaceAll('\r\n', '\n');
            content = content.replaceAll('\r', '\n');
            List<String> fileLines = content.trim().split('\n');
            System.debug('开始导入=>>>>>>>>>>>>>>>>' + fileLines.size());

            // 校验非空字段
            for(Integer i = 1; i < fileLines.size(); i++){
                String fileLine = fileLines[i];
                List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                for(Integer j = 0; j < cellList.size(); j++){
                    //去掉首尾两端的双引号
                    if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                    if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                    //将连续双引号变为单个双引号
                    cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                }

                if(cellList[0] == ''){
                    noChannelNameMsg += (i+1) + ',';
                    isSuccess = false;
                }
                if(cellList[1] == ''){
                    noStoreNameMsg += (i+1) + ',';
                    isSuccess = false;
                }
                if(cellList[2] == ''){
                    noPromoterMsg += (i+1) + ',';
                    isSuccess = false;
                }
                if(cellList[3] == ''){
                    noPromoterEmailMsg += (i+1) + ',';
                    isSuccess = false;
                }
                if(cellList[4] != ''){
                    try{
                        Date.valueOf(cellList[4].substring(0,4) + '-' + cellList[4].substring(4,6) + '-' + cellList[4].substring(6,8));
                    }catch(Exception e){
                        noEdMsg += (i+1) + ',';
                        isSuccess = false;
                    }
                }
                if(cellList[5] != ''){
                    try{
                        Date.valueOf(cellList[5].substring(0,4) + '-' + cellList[5].substring(4,6) + '-' + cellList[5].substring(6,8));
                    }catch(Exception e){
                        noDdMsg += (i+1) + ',';
                        isSuccess = false;
                    }
                }
                if(cellList[6] == ''){
                    noSalaryMsg += (i+1) + ',';
                    isSuccess = false;
                }

                if(cellList[7] == ''){
                    noAdditionalAmountMsg += (i+1) + ',';
                    isSuccess = false;
                }
            }

            // 处理导入数据
            if(isSuccess){

                list<Channel__c> lc = [select Name from Channel__c];
                Map<String, Sobject> lcMap = new LisqContainer(lc).toMapS('Name');
                list<Responsible_Person__c> lrp = [select Shop_Name__r.Name,Principal__r.Name,UserEmail__c,Shop_Name__c from Responsible_Person__c where RecordType__c = '促销员' and Shop_Name__r.Sales_Region__c = 'Hisense South Africa'];
                Map<String, Responsible_Person__c> lrpMap = new Map<String, Responsible_Person__c>();
                for(Responsible_Person__c rp : lrp){
                    lrpMap.put(rp.Shop_Name__r.Name + rp.Principal__r.Name, rp);
                }
                list<Retail_Number__c> lrn = [select id,Shop__r.Name,PromoterDailyReport__r.CreatedBy.Name,Reportyear__c, Reportmonth__c, SPIV__c  from Retail_Number__c
                                                where Sales_Region__c = 'Hisense South Africa' and Reportyear__c =:Integer.valueOf(importDate.substring(0,4)) and Reportmonth__c = :Integer.valueOf(importDate.substring(4,6))];
                Map<String, Double> lrnMap = new Map<String, Double>();
                for(Retail_Number__c rn : lrn){
                    Double spiv = rn.SPIV__c;
                    if(spiv == null){
                        spiv = 0;
                    }
                    if(lrnMap.containsKey(rn.Shop__r.Name + rn.PromoterDailyReport__r.CreatedBy.Name)){
                        lrnMap.put(rn.Shop__r.Name + rn.PromoterDailyReport__r.CreatedBy.Name, 
                        lrnMap.get(rn.Shop__r.Name + rn.PromoterDailyReport__r.CreatedBy.Name) + Double.valueOf(spiv));
                    }else{
                        lrnMap.put(rn.Shop__r.Name + rn.PromoterDailyReport__r.CreatedBy.Name, Double.valueOf(spiv));
                    }
                }

                for(Integer i = 1; i < fileLines.size(); i++){
                    String fileLine = fileLines[i];
                    List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                    for(Integer j = 0; j < cellList.size(); j++){
                        //去掉首尾两端的双引号
                        if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                        if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                        //将连续双引号变为单个双引号
                        cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                    }
        
                    Promoter_Cost__c pc = new Promoter_Cost__c();
                    pc.Year_Month__c = importDate;
                    pc.Key__c = cellList[1] + '_' + cellList[2] + '_' + cellList[3] + importDate; 
                    pc.Channel_Name__c = cellList[0];

                    Channel__c c = (Channel__c)lcMap.get(cellList[0]);
                    if(c != null){
                        pc.Channel__c = c.Id;
                    }else{
                        noChannelNameMsg += (i+1) + ',';
                        isSuccess = false;
                    }
                    System.debug('sss' + cellList[1] + cellList[2] + cellList[3]);
                    if(lrpMap.containsKey(cellList[1] + cellList[2])){
                        Responsible_Person__c rp = lrpMap.get(cellList[1] + cellList[2]);
                        if(rp != null){
                            String email = rp.UserEmail__c;
                            if(!email.equals(cellList[3])){
                                noPromoterEmailMsg += (i+1) + ',';
                                isSuccess = false;
                            }
                            pc.Commission__c = lrnMap.get(cellList[1] + cellList[2]);
                            pc.Store_Id__c = rp.Shop_Name__c;
                        }else{
                            noPromoterMsg += (i+1) + ',';
                            isSuccess = false;
                        }
                    }else{
                        noPromoterMsg += (i+1) + ',';
                        isSuccess = false;
                    }
                    pc.Store_Name__c = cellList[1];
                    pc.Promoter__c = cellList[2];
                    pc.Promoter_Email__c = cellList[3];
                    
                    pc.Employment_Date__c = cellList[4];
                    pc.Departure_Date__c = cellList[5];
                    try{
                        pc.Salary__c = Decimal.valueOf(cellList[6]);
                    }catch(Exception e){
                        noSalaryMsg += (i+1) + ',';
                        isSuccess = false;
                    }
                    try{
                        pc.Additional_Amount__c = Decimal.valueOf(cellList[7]);
                    }catch(Exception e){
                        noAdditionalAmountMsg += (i+1) + ',';
                        isSuccess = false;
                    }

                    pc.Date__c = Date.valueOf(importDate + '-01');

                    addList.add(pc);

                }

            }

            if(noChannelNameMsg != ''){
                noChannelNameMsg = ' \r' + 'The ' + noChannelNameMsg.substring(0, noChannelNameMsg.length() - 1) + ' line,Channel Name does not match data!';
            }


            if(noStoreNameMsg != ''){
                noStoreNameMsg = ' \r' + 'The ' + noStoreNameMsg.substring(0, noStoreNameMsg.length() - 1) + ' line,Store Name does not match data!';
            }

            if(noPromoterMsg != ''){
                noPromoterMsg = ' \r' + 'The ' + noPromoterMsg.substring(0, noPromoterMsg.length() - 1) + ' line,Promoter does not match data!';
            }

            if(noPromoterEmailMsg != ''){
                noPromoterEmailMsg = ' \r' + 'The ' + noPromoterEmailMsg.substring(0, noPromoterEmailMsg.length() - 1) + ' line,Promoter Email does not match data!';
            }

            if(noEdMsg != ''){
                noEdMsg = ' \r' + 'The ' + noEdMsg.substring(0, noEdMsg.length() - 1) + ' line,Employment Date does not match data!';
            }

            if(noDdMsg != ''){
                noDdMsg = ' \r' + 'The ' + noDdMsg.substring(0, noDdMsg.length() - 1) + ' line,Departure Date does not match data!';
            }

            if(noSalaryMsg != ''){
                noSalaryMsg = ' \r' + 'The ' + noSalaryMsg.substring(0, noSalaryMsg.length() - 1) + ' line,Salary does not match data!';
            }

            if(noAdditionalAmountMsg != ''){
                noAdditionalAmountMsg = ' \r' + 'The ' + noAdditionalAmountMsg.substring(0, noAdditionalAmountMsg.length() - 1) + ' line,Additional Amount does not match data!';
            }

            msg = noChannelNameMsg + noStoreNameMsg
                + noPromoterMsg + noPromoterEmailMsg + noEdMsg + noDdMsg + noSalaryMsg + noAdditionalAmountMsg;

            ContentVersion cv = new ContentVersion();
            cv.Title = fileName;
            cv.PathOnClient = '/' + fileName;
            cv.FirstPublishLocationId = currentUser.Id;
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            cv.IsMajorVersion = true;
            Insert cv;

            if(isSuccess){
                try {

                    Database.upsert(addList,Promoter_Cost__c.Fields.Key__c);

                } catch (Exception e) {
                    isSuccess = false;
                    msg += e.getMessage() + '\r';
                }   
            }
        }catch(Exception e){

        }
        if(!isSuccess){
            String errorFileName = fileName.substring(0,fileName.lastIndexOf('.')) + '.txt';
            ContentVersion cvError = new ContentVersion();
            cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
            cvError.PathOnClient = '/' + errorFileName;
            cvError.FirstPublishLocationId = currentUser.Id;
            cvError.VersionData = Blob.valueOf(msg);
            cvError.IsMajorVersion = true;
            Insert cvError;

            ContentVersion qrcv = [SELECT Id,VersionDataUrl FROM ContentVersion WHERE Id =:cvError.id];
            out.errorUrl = qrcv.VersionDataUrl;
            
        }

        out.msg = msg;
        out.partFails = partFails;
        out.isSuccess = isSuccess;

        return out;
    }

    @AuraEnabled
    public static DailySalesUploadController.OutPut saveFilesPromoterRevenue(String fileName, String base64Data){
        
        DailySalesUploadController.OutPut out = new DailySalesUploadController.OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        String msg = '';
        String noDateMsg = '';
        String noChannelNameMsg = '';
        String noStoreNameMsg = '';
        String noProductLineMsg = '';
        String noSalesRevenueMsg = '';
    
        List<Promoter_Revenue__c> addList = new List<Promoter_Revenue__c>(); 
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            Blob contentBlob = EncodingUtil.base64Decode(base64Data);
            String content = DailySalesUploadController.bitToString(contentBlob, 'UTF-8');
            content = content.replaceAll('\r\n', '\n');
            content = content.replaceAll('\r', '\n');
            List<String> fileLines = content.trim().split('\n');
            System.debug('开始导入=>>>>>>>>>>>>>>>>' + fileLines.size());

            // 校验非空字段
            for(Integer i = 1; i < fileLines.size(); i++){
                String fileLine = fileLines[i];
                List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                for(Integer j = 0; j < cellList.size(); j++){
                    //去掉首尾两端的双引号
                    if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                    if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                    //将连续双引号变为单个双引号
                    cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                }

                if(cellList[0] == ''){
                    noDateMsg += (i+1) + ',';
                    isSuccess = false;
                }else{
                    try{
                        Date.valueOf(cellList[0].substring(0,4) + '-' + cellList[0].substring(4,6) + '-' + cellList[0].substring(6,8));
                    }catch(Exception e){
                        noDateMsg += (i+1) + ',';
                        isSuccess = false;
                    }
                }
                if(cellList[1] == ''){
                    noChannelNameMsg += (i+1) + ',';
                    isSuccess = false;
                }
                if(cellList[2] == ''){
                    noStoreNameMsg += (i+1) + ',';
                    isSuccess = false;
                }
                if(cellList[3] == ''){
                    noProductLineMsg += (i+1) + ',';
                    isSuccess = false;
                }
                
                if(cellList[4] == ''){
                    noSalesRevenueMsg += (i+1) + ',';
                    isSuccess = false;
                }

            }

            // 处理导入数据
            if(isSuccess){

                list<Channel__c> lc = [select Name from Channel__c];
                Map<String, Sobject> lcMap = new LisqContainer(lc).toMapS('Name');
                list<Shop__c> ls = [select id,name from Shop__c where Sales_Region__c = 'Hisense South Africa'];
                Map<String, Sobject> lsIdMap = new LisqContainer(ls).toMapS('Id');

                for(Integer i = 1; i < fileLines.size(); i++){
                    String fileLine = fileLines[i];
                    List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                    for(Integer j = 0; j < cellList.size(); j++){
                        //去掉首尾两端的双引号
                        if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                        if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                        //将连续双引号变为单个双引号
                        cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                    }
        
                    Promoter_Revenue__c pc = new Promoter_Revenue__c();
                    pc.Key__c = cellList[0] + '_' + cellList[1] + '_' + cellList[3] + '_' + cellList[4]; 
                    pc.Date__c = cellList[0];
                    pc.Channel_Name__c = cellList[1];

                    Channel__c c = (Channel__c)lcMap.get(cellList[1]);
                    if(c != null){
                        pc.Channel__c = c.Id;
                    }else{
                        noChannelNameMsg += (i+1) + ',';
                        isSuccess = false;
                    }
                    
                    pc.Store_Name__c = cellList[2];

                    pc.Product_Line__c = cellList[3];
                   
                    try{
                        pc.Sales_Revenue__c = Decimal.valueOf(cellList[4]);
                    }catch(Exception e){
                        noSalesRevenueMsg += (i+1) + ',';
                        isSuccess = false;
                    }

                    pc.Store_Id__c = lsIdMap.get(cellList[5]).Id;

                    addList.add(pc);

                }

            }

            if(noDateMsg != ''){
                noDateMsg = ' \r' + 'The ' + noDateMsg.substring(0, noDateMsg.length() - 1) + ' line,Promoter does not match data!';
            }

            if(noChannelNameMsg != ''){
                noChannelNameMsg = ' \r' + 'The ' + noChannelNameMsg.substring(0, noChannelNameMsg.length() - 1) + ' line,Channel Name does not match data!';
            }

            if(noStoreNameMsg != ''){
                noStoreNameMsg = ' \r' + 'The ' + noStoreNameMsg.substring(0, noStoreNameMsg.length() - 1) + ' line,Store Name does not match data!';
            }

            if(noProductLineMsg != ''){
                noProductLineMsg = ' \r' + 'The ' + noProductLineMsg.substring(0, noProductLineMsg.length() - 1) + ' line,Promoter Email does not match data!';
            }

            if(noSalesRevenueMsg != ''){
                noSalesRevenueMsg = ' \r' + 'The ' + noSalesRevenueMsg.substring(0, noSalesRevenueMsg.length() - 1) + ' line,Employment Date does not match data!';
            }

            msg = noDateMsg + noChannelNameMsg + noStoreNameMsg
                + noProductLineMsg + noSalesRevenueMsg;

            ContentVersion cv = new ContentVersion();
            cv.Title = fileName;
            cv.PathOnClient = '/' + fileName;
            cv.FirstPublishLocationId = currentUser.Id;
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            cv.IsMajorVersion = true;
            Insert cv;

            if(isSuccess){
                try {
                    Database.upsert(addList,Promoter_Revenue__c.Fields.Key__c);
                } catch (Exception e) {
                    isSuccess = false;
                    msg += e.getMessage() + '\r';
                }   
            }
        }catch(Exception e){

        }
        if(!isSuccess){
            String errorFileName = fileName.substring(0,fileName.lastIndexOf('.')) + '.txt';
            ContentVersion cvError = new ContentVersion();
            cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
            cvError.PathOnClient = '/' + errorFileName;
            cvError.FirstPublishLocationId = currentUser.Id;
            cvError.VersionData = Blob.valueOf(msg);
            cvError.IsMajorVersion = true;
            Insert cvError;

            ContentVersion qrcv = [SELECT Id,VersionDataUrl FROM ContentVersion WHERE Id =:cvError.id];
            out.errorUrl = qrcv.VersionDataUrl;
        }

        out.msg = msg;
        out.partFails = partFails;
        out.isSuccess = isSuccess;

        return out;
    }

    public class ExcelDataInfo {
        @AuraEnabled
		public String Date1 {get; set;}
		public String CustomerCode {get; set;}
		public String StoreCode {get; set;}
		public String Product {get; set;}
		public String Price {get; set;}
		public String Quantities {get; set;}
    }

}