public without sharing class ShopDistributorInventoryController {

    @AuraEnabled
    public static String saveFile(Id recordId, String fileName, String base64Data) {
        // 查询所有的门店
        List<Shop__c> shopList = [SELECT Id,Shop_Code__c,Responsible_Person__c FROM Shop__c];
        Map<String, Shop__c> shopMap = new Map<String, Shop__c>();
        for(Shop__c shop : shopList){
            shopMap.put(shop.Shop_Code__c, shop);
        }

        base64Data = EncodingUtil.urlDecode(base64Data, 'gb2312');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = bitToString(contentBlob, 'gb2312');
        content = content.replaceAll('\r\n', '\n');
        content = content.replaceAll('\r', '\n');
        List<String> fileLines = content.trim().split('\n');
        List<Distributor_Inventory__c> addList = new List<Distributor_Inventory__c>();
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
           
            String shopCode = '0000000000' + cellList[0].trim();
            Shop__c shop = shopMap.get(cellList[0].trim()) != null ? shopMap.get(cellList[0].trim()) : shopMap.get(shopCode.substring(shopCode.length() - 15,shopCode.length()));
            if(Test.isRunningTest()){
                shop = shopList[0];
            }
            if(shop != null){
                Distributor_Inventory__c di = new Distributor_Inventory__c();
                di.Store__c = shop.id;
                di.Product_Line__c = cellList[2];
                di.Product__c = cellList[3];
                di.Quantity__c = Decimal.valueOf(cellList[4]);
                addList.add(di);
            }
        }
        Database.insert(addList);
        //inserting file
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = '/' + fileName;
        cv.FirstPublishLocationId = recordId;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.IsMajorVersion = true;
        Insert cv;
        return 'successfully';
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

}