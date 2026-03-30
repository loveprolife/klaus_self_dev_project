/*
 * @Author: WFC
 * @Date: 2024-06-19 17:38:45
 * @LastEditors: WFC
 * @LastEditTime: 2024-12-24 15:09:09
 * @Description:
 * @FilePath: \hisense005\force-app\main\default\classes\SampleDisplayController.cls
 */
public without sharing class SampleDisplayController{
    public static User currentUser = [SELECT Id, Sales_Region__c, Profile.Name, Department
                                      FROM User
                                      WHERE Id = :UserInfo.getUserId()];
    public static String channelType = Schema.SObjectType.Sample_Display__c.getRecordTypeInfosByDeveloperName().get('Channel').getRecordTypeId();
    public static String storeType = Schema.SObjectType.Sample_Display__c.getRecordTypeInfosByDeveloperName().get('Store').getRecordTypeId();
    // 子任务上传图片后状态变为completed
    @AuraEnabled
    public static Map<String, Object> storeDetailUploadFile(String recordId){
        Map<String, Object> result = new Map<String, Object>();
        Id cid = Id.valueOf(recordId);
        String objectName = cid.getSObjectType().getDescribe().getName();
        if (objectName == 'Sample_Display_Confirm__c'){
            Sample_Display_Confirm__c sdc = [SELECT Id, Status__c, Store__c, Product_Model__c
                                             FROM Sample_Display_Confirm__c
                                             WHERE Id = :recordId
                                             LIMIT 1];
            // 是否第一次上传图片
            String flag = sdc.Status__c;
            sdc.Status__c = 'Completed';
            sdc.Upload_File_Flag__c = true;
            Database.update (sdc);

            // 查询对应的Sampling Detail数据，更改出样状态
            String key = sdc.Store__c + '-' + sdc.Product_Model__c;
            List<Sampling_Detail__c> sd = [SELECT Id, Unplanned_Sample__c
                                           FROM Sampling_Detail__c
                                           WHERE ExternalID__c = :key];
            if (sd != null && sd.size() > 0 && flag == 'Uncompleted'){
                sd[0].Display_Status__c = '展出';
                sd[0].Is_Add__c = '是';
                sd[0].Sampling_Time__c = Date.today();
                sd[0].No_Sampling_Time__c = null;
                Database.update (sd[0]);
            }
        } else if (objectName == 'Sample_Removal_Confirm__c'){
            Sample_Removal_Confirm__c sdc = [SELECT Id, Status__c, Store__c, Product_Model__c
                                             FROM Sample_Removal_Confirm__c
                                             WHERE Id = :recordId
                                             LIMIT 1];
            // 是否第一次上传图片
            String flag = sdc.Status__c;
            sdc.Status__c = 'Completed';
            Database.update (sdc);

            // 查询对应的Sampling Detail数据，更改出样状态
            String key = sdc.Store__c + '-' + sdc.Product_Model__c;
            List<Sampling_Detail__c> sd = [SELECT Id, Unplanned_Sample__c
                                           FROM Sampling_Detail__c
                                           WHERE ExternalID__c = :key];
            if (sd != null && sd.size() > 0 && flag == 'Uncompleted'){
                sd[0].Display_Status__c = '未展出';
                sd[0].Is_Add__c = '否';
                sd[0].No_Sampling_Time__c = Date.today();
                Database.update (sd[0]);
            }
        }
        result.put('objectName', objectName);
        result.put('isSuccess', true);
        return result;
    }

    // 三级任务上传图片后保存附加信息
    @AuraEnabled
    public static Boolean saveAdditionalInformation(String recordId, String addOrReplace, String replaceModel){
        Id cid = Id.valueOf(recordId);
        String objectName = cid.getSObjectType().getDescribe().getName();
        if (objectName == 'Sample_Display_Confirm__c'){
            Sample_Display_Confirm__c sdc = [SELECT Id, Status__c, Store__c, Product_Model__c
                                             FROM Sample_Display_Confirm__c
                                             WHERE Id = :recordId
                                             LIMIT 1];
            sdc.Add_or_Replace__c = addOrReplace;
            if (addOrReplace == 'New'){
                sdc.Replace_Model__c = null;
            } else{
                //【1】识别上样型号是否已有sampling detail，没有的话进行新增，display or not=yes，status=exhibited，有的话在原sampling detail更新这两个字段。
                //【2】识别被替换型号是否已有sampling detail，没有的话不做处理，有的话在原sampling detail更新display or not=not，status=unexhibited。
                String replaceKey = sdc.Store__c + '-' + replaceModel;
                List<Sampling_Detail__c> replaceSdList = [SELECT Id
                                                          FROM Sampling_Detail__c
                                                          WHERE ExternalID__c = :replaceKey];
                if (replaceSdList != null && replaceSdList.size() > 0){
                    Sampling_Detail__c replaceSd = replaceSdList[0];
                    replaceSd.Display_Status__c = '未展出';
                    replaceSd.Is_Add__c = '否';
                    replaceSd.No_Sampling_Time__c = Date.today();
                    Database.update (replaceSd);
                }
                sdc.Replace_Model__c = replaceModel;
            }
            sdc.Upload_File_Flag__c = true;
            Database.update (sdc);
        }
        // else if (objectName == 'Sample_Removal_Confirm__c'){
        //     Sample_Removal_Confirm__c sdc = [SELECT Id, Status__c, Store__c, Product_Model__c
        //                                      FROM Sample_Removal_Confirm__c
        //                                      WHERE Id = :recordId
        //                                      LIMIT 1];
        //     sdc.Add_or_Replace__c = addOrReplace;
        //     sdc.Replace_Model__c = replaceModel;
        //     Database.update (sdc);
        // }
        return true;
    }

    // Sample Display 上传功能
    @AuraEnabled
    public static OutPut saveSampleDisplayFile(String fileName, String base64Data){
        OutPut out = new OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        String msg = '';

        // 要插入的Sample_Display__c
        List<Sample_Display__c> addList = new List<Sample_Display__c>();
        base64Data = EncodingUtil.urlDecode(base64Data, 'gb2312');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = bitToString(contentBlob, 'gb2312');
        List<String> fileLines = new List<String>();
        // 迭代器 解决System.LimitException: Regex too complicated
        RowIteratorUtility r = New RowIteratorUtility(content, '\n');
        While (r.hasNext()){
            fileLines.add(r.next());
        }
        // 获取Customer store product集合
        Set<String> customerSet = new Set<String>();
        Set<String> storeSet = new Set<String>();
        Set<String> productSet = new Set<String>();
        Set<String> salesRegionSet = new Set<String>();
        for (Integer i = 1; i < fileLines.size(); i++){
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for (Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if (cellList[j].startsWith('\"'))
                    cellList[j] = cellList[j].substring(1, cellList[j].length());
                if (cellList[j].endsWith('\"'))
                    cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"');
            }
            String taskLevel = cellList[1].trim();
            if (taskLevel == 'Store'){
                storeSet.add(cellList[3].trim());
            } else{
                String accCode = '0000000000' + cellList[3].trim();
                customerSet.add(accCode.substring(accCode.length() - 10, accCode.length()));
            }
            productSet.add(cellList[2].trim());
            salesRegionSet.add(cellList[0].trim());
        }
        // 查询客户
        List<Account> customerList = [SELECT Id, SAP_Customer_Code__c
                                      FROM Account
                                      WHERE SAP_Customer_Code__c IN:customerSet];
        Map<String, SObject> customerMap = new LisqContainer(customerList).toMapS('SAP_Customer_Code__c');
        // 查询门店
        List<Shop__c> storeList = [SELECT Id, Shop_Code_Text__c
                                   FROM Shop__c
                                   WHERE Shop_Code_Text__c IN:storeSet];
        Map<String, SObject> storeMap = new LisqContainer(storeList).toMapS('Shop_Code_Text__c');
        // 查询产品
        List<Product__c> productList = [SELECT Id, Name, sales_region__c
                                        FROM Product__c
                                        WHERE Name IN:productSet AND sales_region__c IN:salesRegionSet];
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c pd : productList){
            productMap.put(pd.Name.toUpperCase() + pd.sales_region__c, pd);
        }

        for (Integer i = 1; i < fileLines.size(); i++){
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for (Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if (cellList[j].startsWith('\"'))
                    cellList[j] = cellList[j].substring(1, cellList[j].length());
                if (cellList[j].endsWith('\"'))
                    cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"');
            }
            // 时间/替换成-
            cellList[5] = cellList[5].trim().replaceAll('/', '-');
            String taskLevel = cellList[1].trim();
            Sample_Display__c sd = new Sample_Display__c();
            if (taskLevel == 'Store'){
                sd.RecordTypeId = storeType;
                Shop__c store = (Shop__c) storeMap.get(cellList[3].trim());
                if (store != null){
                    sd.Store__c = store.Id;
                }
            } else{
                sd.RecordTypeId = channelType;
                String accCode = '0000000000' + cellList[3].trim();
                Account acc = (Account)customerMap.get(accCode.substring(accCode.length() - 10, accCode.length()));
                if (acc != null){
                    sd.Customer__c = acc.Id;
                }
            }
            Product__c product = (Product__c) productMap.get(cellList[2].trim().toUpperCase() + cellList[0].trim());
            if (product != null){
                sd.Product_Model__c = product.Id;
            }
            sd.Sales_Region__c = cellList[0].trim();
            sd.Number__c = Decimal.valueOf(cellList[4].trim());
            sd.Deadline__c = Date.valueOf(cellList[5].trim());
            sd.Key__c = sd.Sales_Region__c + '-' + sd.Customer__c + '-' + sd.Store__c + '-' + sd.Product_Model__c + '-' + sd.Deadline__c + '-' + sd.Number__c;
            addList.add(sd);
        }
        System.Savepoint sp = Database.setSavepoint();
        List<Database.UpsertResult> groupSrList = Database.Upsert (addList, Sample_Display__c.Fields.Key__c, false);
        for (Integer i = 0; i < groupSrList.size(); i++){
            Database.UpsertResult sr = groupSrList.get(i);
            if (!sr.isSuccess()){
                String errorMessage = '';
                for (Database.Error err : sr.getErrors()){
                    errorMessage += err.getMessage();
                }
                msg += (i + 2) + ' line,' + errorMessage + ' \r';
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

        if (!isSuccess){
            Database.rollback(sp);

            String errorFileName = fileName.substring(0, fileName.lastIndexOf('.'));
            ContentVersion cvError = new ContentVersion();
            cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
            cvError.PathOnClient = '/' + errorFileName + '.txt';
            cvError.FirstPublishLocationId = currentUser.Id;
            cvError.VersionData = Blob.valueOf(msg);
            cvError.IsMajorVersion = true;
            Insert cvError;

            ContentVersion qrcv = [SELECT Id, VersionDataUrl
                                   FROM ContentVersion
                                   WHERE Id = :cvError.id];
            out.errorUrl = qrcv.VersionDataUrl;

        }

        out.msg = msg;
        out.partFails = partFails;
        out.isSuccess = isSuccess;
        return out;
    }

    // Sample Removal 上传功能
    @AuraEnabled
    public static OutPut saveSampleRemovalFile(String fileName, String base64Data){
        OutPut out = new OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        String msg = '';

        // 要插入的Sample_Display__c
        List<Sample_Removal__c> addList = new List<Sample_Removal__c>();
        base64Data = EncodingUtil.urlDecode(base64Data, 'gb2312');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = bitToString(contentBlob, 'gb2312');
        List<String> fileLines = new List<String>();
        // 迭代器 解决System.LimitException: Regex too complicated
        RowIteratorUtility r = New RowIteratorUtility(content, '\n');
        While (r.hasNext()){
            fileLines.add(r.next());
        }
        // 获取store product集合
        Set<String> storeSet = new Set<String>();
        Set<String> productSet = new Set<String>();
        for (Integer i = 1; i < fileLines.size(); i++){
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for (Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if (cellList[j].startsWith('\"'))
                    cellList[j] = cellList[j].substring(1, cellList[j].length());
                if (cellList[j].endsWith('\"'))
                    cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"');
            }

            storeSet.add(cellList[2].trim());
            productSet.add(cellList[0].trim());
        }
        // 查询门店
        List<Shop__c> storeList = [SELECT Id, Shop_Code_Text__c
                                   FROM Shop__c
                                   WHERE Shop_Code_Text__c IN:storeSet];
        Map<String, SObject> storeMap = new LisqContainer(storeList).toMapS('Shop_Code_Text__c');
        // 查询产品
        List<Product__c> productList = [SELECT Id, Name
                                        FROM Product__c
                                        WHERE Name IN:productSet AND sales_region__c = :currentUser.Sales_Region__c];
        Map<String, SObject> productMap = new LisqContainer(productList).toMapS('Name');

        for (Integer i = 1; i < fileLines.size(); i++){
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for (Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if (cellList[j].startsWith('\"'))
                    cellList[j] = cellList[j].substring(1, cellList[j].length());
                if (cellList[j].endsWith('\"'))
                    cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"');
            }
            // 时间/替换成-
            cellList[4] = cellList[4].trim().replaceAll('/', '-');
            Sample_Removal__c sd = new Sample_Removal__c();
            Shop__c store = (Shop__c) storeMap.get(cellList[2].trim());
            if (store != null){
                sd.Store__c = store.Id;
            }
            Product__c product = (Product__c) productMap.get(cellList[0].trim());
            if (product != null){
                sd.Product_Model__c = product.Id;
            }
            sd.Number__c = Decimal.valueOf(cellList[3].trim());
            sd.Deadline__c = Date.valueOf(cellList[4].trim());
            addList.add(sd);
        }
        System.Savepoint sp = Database.setSavepoint();
        List<Database.SaveResult> groupSrList = Database.Insert (addList, false);
        for (Integer i = 0; i < groupSrList.size(); i++){
            Database.SaveResult sr = groupSrList.get(i);
            if (!sr.isSuccess()){
                String errorMessage = '';
                for (Database.Error err : sr.getErrors()){
                    errorMessage += err.getMessage();
                }
                msg += (i + 2) + ' line,' + errorMessage + ' \r';
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

        if (!isSuccess){
            Database.rollback(sp);

            String errorFileName = fileName.substring(0, fileName.lastIndexOf('.'));
            ContentVersion cvError = new ContentVersion();
            cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
            cvError.PathOnClient = '/' + errorFileName + '.txt';
            cvError.FirstPublishLocationId = currentUser.Id;
            cvError.VersionData = Blob.valueOf(msg);
            cvError.IsMajorVersion = true;
            Insert cvError;

            ContentVersion qrcv = [SELECT Id, VersionDataUrl
                                   FROM ContentVersion
                                   WHERE Id = :cvError.id];
            out.errorUrl = qrcv.VersionDataUrl;

        }

        out.msg = msg;
        out.partFails = partFails;
        out.isSuccess = isSuccess;
        return out;
    }

    // Store Detail 上传功能
    @AuraEnabled
    public static OutPut saveStoreDetailConfirmFile(String recordId, String productModel, String fileName, String base64Data){
        OutPut out = new OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        String msg = '';

        // 要插入的Sample_Display_Confirm__c
        List<Store_Detail__c> addList = new List<Store_Detail__c>();
        base64Data = EncodingUtil.urlDecode(base64Data, 'gb2312');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = bitToString(contentBlob, 'gb2312');
        List<String> fileLines = new List<String>();
        // 迭代器 解决System.LimitException: Regex too complicated
        RowIteratorUtility r = New RowIteratorUtility(content, '\n');
        While (r.hasNext()){
            fileLines.add(r.next());
        }
        // 获取store集合
        Set<String> storeSet = new Set<String>();
        for (Integer i = 1; i < fileLines.size(); i++){
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for (Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if (cellList[j].startsWith('\"'))
                    cellList[j] = cellList[j].substring(1, cellList[j].length());
                if (cellList[j].endsWith('\"'))
                    cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"');
            }
            storeSet.add(cellList[1].trim());
        }
        // 查询门店
        List<Shop__c> storeList = [SELECT Id, Shop_Code_Text__c, Account__c
                                   FROM Shop__c
                                   WHERE Shop_Code_Text__c IN:storeSet];
        Map<String, SObject> storeMap = new LisqContainer(storeList).toMapS('Shop_Code_Text__c');

        for (Integer i = 1; i < fileLines.size(); i++){
            String fileLine = fileLines[i];
            List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            for (Integer j = 0; j < cellList.size(); j++){
                //去掉首尾两端的双引号
                if (cellList[j].startsWith('\"'))
                    cellList[j] = cellList[j].substring(1, cellList[j].length());
                if (cellList[j].endsWith('\"'))
                    cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //将连续双引号变为单个双引号
                cellList[j] = cellList[j].replaceAll('\"\"', '\"');
            }
            Store_Detail__c sd = new Store_Detail__c();
            Shop__c store = (Shop__c) storeMap.get(cellList[1].trim());
            if (store != null){
                sd.Store__c = store.Id;
            }
            sd.Sample_Display__c = recordId;
            sd.Product_Model__c = productModel;
            sd.Number__c = Decimal.valueOf(cellList[2].trim());
            sd.Priority__c = cellList[3].trim() == 'yes' ? true : false;
            addList.add(sd);
        }
        System.Savepoint sp = Database.setSavepoint();
        List<Database.SaveResult> groupSrList = Database.insert (addList, false);
        for (Integer i = 0; i < groupSrList.size(); i++){
            Database.SaveResult sr = groupSrList.get(i);
            if (!sr.isSuccess()){
                String errorMessage = '';
                for (Database.Error err : sr.getErrors()){
                    errorMessage += err.getMessage();
                }
                msg += (i + 2) + ' line,' + errorMessage + ' \r';
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

        if (!isSuccess){
            Database.rollback(sp);

            String errorFileName = fileName.substring(0, fileName.lastIndexOf('.'));
            ContentVersion cvError = new ContentVersion();
            cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
            cvError.PathOnClient = '/' + errorFileName + '.txt';
            cvError.FirstPublishLocationId = currentUser.Id;
            cvError.VersionData = Blob.valueOf(msg);
            cvError.IsMajorVersion = true;
            Insert cvError;

            ContentVersion qrcv = [SELECT Id, VersionDataUrl
                                   FROM ContentVersion
                                   WHERE Id = :cvError.id];
            out.errorUrl = qrcv.VersionDataUrl;

        }

        out.msg = msg;
        out.partFails = partFails;
        out.isSuccess = isSuccess;
        return out;
    }

    public class OutPut{
        @AuraEnabled
        public Boolean isSuccess{ get; set; }

        @AuraEnabled
        public String msg{ get; set; }

        @AuraEnabled
        public Boolean partFails{ get; set; }

        @AuraEnabled
        public String errorUrl{ get; set; }

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
        for (Integer i = 0; i < bytesCount; ++i){
            //将相邻两位的16进制字符串放在一个String中
            bytes[i] = hex.mid(i << 1, 2);
        }
        //解码成指定charset的字符串
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }

}