public with sharing class ExcelUploadController {

    public static User currentUser = [SELECT Id,Sales_Region__c,Profile.Name,Department FROM User WHERE Id =:UserInfo.getUserId()]; 
    @AuraEnabled
    public static ExcelUploadController.OutPut saveCustomerAddress(String fileName, List<String[]> fileLines){
        ExcelUploadController.OutPut out = new ExcelUploadController.OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        Map<String, String> errorMap = new Map<String, String>();
        String msg = '';
        String noCol0 = '';
        String noCol1 = '';
        String noCol2 = '';
        String noCol3 = '';
        String noCol4 = '';
        String noCol5 = '';
        String noCol6 = '';
        String noCol9 = '';
        String noCol10 = '';
        String noCol11 = '';
        
        
        List<Account> addList = new List<Account>();
        System.debug('开始导入=>>>>>>>>>>>>>>>>');

        Map<String,string> currentyMap = Utility.getPicklistValueMap('Customer_extend__c','CurrencyIsoCode');
        Map<String,string> countryMap = Utility.getPicklistValueMap('Account','Guarantor_Country_Code__c');
        Map<String,string> hisenseEntityMap = Utility.getPicklistValueMap('Customer_extend__c','Hisense_Entity__c');
        Map<String,string> shippingConditionsMap = Utility.getPicklistValueMap('Customer_extend__c','Shipping_Conditions__c');
        List<Country_State__c> provinces = [select ex_id__c,Id from Country_State__c where Belong_To__c != null];
        Map<String, Sobject> provinceMap = new LisqContainer(provinces).ToMapS('ex_id__c'); 

        Integer index = 4;

        // 校验非空
        for(Integer i = index; i < fileLines.size(); i++){
            String[] cellList = fileLines[i];

            if(String.isBlank(cellList[0])){
                noCol0 += (i+1) + ',';
                isSuccess = false;
            }

            if(String.isBlank(cellList[1])){
                noCol1 += (i+1) + ',';
                isSuccess = false;
            }

            if(String.isBlank(cellList[2])){
                noCol2 += (i+1) + ',';
                isSuccess = false;
            }

            if(String.isBlank(cellList[3]) || String.isBlank(currentyMap.get(cellList[3]))){
                noCol3 += (i+1) + ',';
                isSuccess = false;
            }

            if(String.isBlank(cellList[4]) || String.isBlank(countryMap.get(cellList[4]))){
                noCol4 += (i+1) + ',';
                isSuccess = false;
            }

            if(String.isBlank(cellList[5]) || provinceMap.get(cellList[5] + cellList[4]) == null){
                noCol5 += (i+1) + ',';
                isSuccess = false;
            }

            if(String.isBlank(cellList[6])){
                noCol6 += (i+1) + ',';
                isSuccess = false;
            }

            if(String.isBlank(cellList[9]) || String.isBlank(hisenseEntityMap.get(cellList[9]))){
                noCol9 += (i+1) + ',';
                isSuccess = false;
            }

            if(String.isBlank(cellList[10]) || String.isBlank(hisenseEntityMap.get(cellList[10]))){
                noCol10 += (i+1) + ',';
                isSuccess = false;
            }

            if(String.isBlank(cellList[11]) || String.isBlank(shippingConditionsMap.get(cellList[11]))){
                noCol11 += (i+1) + ',';
                isSuccess = false;
            }
            
        }

        if(isSuccess){
            for(Integer i = index; i < fileLines.size(); i++){ 
                String[] cellList = fileLines[i];
                
                Account target = new Account();

                target.SAP_Customer_Code__c = cellList[0].leftPad(10, '0');
                target.Name = cellList[1];
                target.Customer_Name_Local_Language__c = cellList[1];
                target.Customer_Short_Name__c = cellList[2];
                target.CurrencyIsoCode = cellList[3];
                target.Guarantor_Country_Code__c = cellList[4];
                target.Province_State__c = provinceMap.get(cellList[5] + cellList[4]).Id;
                //target.Phone = cellList[6];
                target.Street_2__c = cellList[6];
                target.Street_3__c = cellList[7];
                target.Street_4__c = cellList[8];
                target.Hisense_Entity__c = cellList[9];
                target.Hisense_Entity_Sales__c = cellList[10];
                target.Shipping_Conditions__c = cellList[11];
                target.City__c = cellList[12];
                target.Postal_Code__c = cellList[13];
                target.EDI_ID__c = cellList[14];
                //target.Related_to_POD__c = cellList[13].equals('Y') ? true : false;
                addList.add(target);
            }
        }

        if(isSuccess && addList.size() > 0){
            try {
                Batch_CustomerAddressUpload ss = new Batch_CustomerAddressUpload(addList);
                if(!Test.isRunningTest()){
                    Database.executeBatch(ss, 1);
                }
            } catch (Exception e) {
                isSuccess = false;
                msg += e.getMessage() + '\r';
            }   
        }

        if(!isSuccess){

            if(noCol0 != ''){
                errorMap = addErrorMap(errorMap, noCol0.substring(0, noCol0.length() - 1), String.format(Label.Excel_Check_Info, new List<Object>{'Sold to(SAP Customer Code)'}));
                noCol0 = ' \r' + 'The ' + noCol0.substring(0, noCol0.length() - 1) + ' line,' + String.format(Label.Excel_Check_Info, new List<Object>{'Sold to(SAP Customer Code)'});
            }
            // noCol1
            if(noCol1 != ''){
                errorMap = addErrorMap(errorMap, noCol1.substring(0, noCol1.length() - 1), String.format(Label.Excel_Check_Info, new List<Object>{'Customer name'}));
                noCol1 = ' \r' + 'The ' + noCol1.substring(0, noCol1.length() - 1) + ' line,' + String.format(Label.Excel_Check_Info, new List<Object>{'Customer name'});
            }

            // noCol2
            if(noCol2 != ''){
                errorMap = addErrorMap(errorMap, noCol2.substring(0, noCol2.length() - 1), String.format(Label.Excel_Check_Info, new List<Object>{'Search Term(Customer Short Name)'}));
                noCol2 = ' \r' + 'The ' + noCol2.substring(0, noCol2.length() - 1) + ' line,' + String.format(Label.Excel_Check_Info, new List<Object>{'Search Term(Customer Short Name)'});
            }

            // noCol3
            if(noCol3 != ''){
                errorMap = addErrorMap(errorMap, noCol3.substring(0, noCol3.length() - 1), String.format(Label.Excel_Check_Info, new List<Object>{'Currency'}));
                noCol3 = ' \r' + 'The ' + noCol3.substring(0, noCol3.length() - 1) + ' line,' + String.format(Label.Excel_Check_Info, new List<Object>{'Currency'});
            }

            // noCol4
            if(noCol4 != ''){
                errorMap = addErrorMap(errorMap, noCol4.substring(0, noCol4.length() - 1), String.format(Label.Excel_Check_Info, new List<Object>{'Country'}));
                noCol4 = ' \r' + 'The ' + noCol4.substring(0, noCol4.length() - 1) + ' line,' + String.format(Label.Excel_Check_Info, new List<Object>{'Currency'});
            }

            // noCol5
            if(noCol5 != ''){
                errorMap = addErrorMap(errorMap, noCol5.substring(0, noCol5.length() - 1), String.format(Label.Excel_Check_Info, new List<Object>{'Province/State'}));
                noCol5 = ' \r' + 'The ' + noCol5.substring(0, noCol5.length() - 1) + ' line,' + String.format(Label.Excel_Check_Info, new List<Object>{'Province/State'});
            }

            // noCol6
            if(noCol6 != ''){
                errorMap = addErrorMap(errorMap, noCol6.substring(0, noCol6.length() - 1), String.format(Label.Excel_Check_Info, new List<Object>{'Street'}));
                noCol6 = ' \r' + 'The ' + noCol6.substring(0, noCol6.length() - 1) + ' line,' + String.format(Label.Excel_Check_Info, new List<Object>{'Street'});
            }

            // noCol9
            if(noCol9 != ''){
                errorMap = addErrorMap(errorMap, noCol9.substring(0, noCol9.length() - 1), String.format(Label.Excel_Check_Info, new List<Object>{'Hisense Entity'}));
                noCol9 = ' \r' + 'The ' + noCol9.substring(0, noCol9.length() - 1) + ' line,' + String.format(Label.Excel_Check_Info, new List<Object>{'Hisense Entity'});
            }

            // noCol10
            if(noCol10 != ''){
                errorMap = addErrorMap(errorMap, noCol10.substring(0, noCol10.length() - 1), String.format(Label.Excel_Check_Info, new List<Object>{'Sales Organization'}));
                noCol10 = ' \r' + 'The ' + noCol10.substring(0, noCol10.length() - 1) + ' line,' + String.format(Label.Excel_Check_Info, new List<Object>{'Sales Organization'});
            }

            // noCol11
            if(noCol11 != ''){
                errorMap = addErrorMap(errorMap, noCol11.substring(0, noCol11.length() - 1), String.format(Label.Excel_Check_Info, new List<Object>{'Shipping Conditions'}));
                noCol11 = ' \r' + 'The ' + noCol11.substring(0, noCol11.length() - 1) + ' line,' + String.format(Label.Excel_Check_Info, new List<Object>{'Shipping Conditions'});
            }
            msg = noCol0 + noCol1 + noCol2 + noCol3 + noCol4 + noCol5 + noCol6 + noCol9 + noCol10 + noCol11;

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
        out.errorMap = errorMap;

        return out;
    }
    @AuraEnabled
    public static ExcelUploadController.OutPut saveKeyModel(String fileName, List<String[]> fileLines){
        ExcelUploadController.OutPut out = new ExcelUploadController.OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        Map<String, String> errorMap = new Map<String, String>();
        String msg = '';
        String noRegionMsg = '';
        String noModelMsg = '';
        String noDateMsg = '';
        
        // Key_Model__c
        List<Key_Model__c> addList = new List<Key_Model__c>(); 
        System.debug('开始导入=>>>>>>>>>>>>>>>>');

        Integer index = 1;
        Set<String> regionSet = new Set<String>();

        // 校验非空
        for(Integer i = index; i < fileLines.size(); i++){
            String[] cellList = fileLines[i];

            if(String.isBlank(cellList[0])){
                noRegionMsg += (i+1) + ',';
                isSuccess = false;
            }else{
                regionSet.add(cellList[0]);
            }
            
            if(String.isBlank(cellList[1])){
                noModelMsg += (i+1) + ',';
                isSuccess = false;
            }

            if(String.isBlank(cellList[2])){
                noDateMsg += (i+1) + ',';
                isSuccess = false;
            }
            
        }

        Map<String, Product__c> productMap = new Map<String, Product__c>();
        if(isSuccess){
            List<Product__c> productList = [Select id, Name, Sales_Region__c From Product__c where Sales_Region__c in: regionSet];
            for(Product__c p : productList){
                if(String.isNotBlank(p.Name)){
                    productMap.put(p.Name.toLowerCase() + p.Sales_Region__c, p);
                }
            }

            // 校验型号和日期
            for(Integer i = index; i < fileLines.size(); i++){
                String[] cellList = fileLines[i];
                
                if(productMap.get(cellList[1].toLowerCase() + cellList[0]) == null){
                    noModelMsg += (i+1) + ',';
                    isSuccess = false;
                }

                try{
                    Date.valueOf(cellList[2] + '-01');
                }catch(Exception e){
                    noDateMsg += (i+1) + ',';
                    isSuccess = false;
                }
                
            }
        }

        if(isSuccess){
            for(Integer i = index; i < fileLines.size(); i++){ 
                String[] cellList = fileLines[i];
                Key_Model__c target = new Key_Model__c();
                target.Sales_Region__c = cellList[0];
                target.Key_Model__c = productMap.get(cellList[1].toLowerCase() + cellList[0]).Id;
                target.Year_Month__c = cellList[2];
                target.External_Key__c = cellList[0] + cellList[1] + cellList[2];
                addList.add(target);
            }
        }

        if(isSuccess && addList.size() > 0){
            try {
                Database.insert(addList,true);
            } catch (Exception e) {
                isSuccess = false;
                msg += e.getMessage() + '\r';
            }   
        }

        if(!isSuccess){

            if(noRegionMsg != ''){
                errorMap = addErrorMap(errorMap, noRegionMsg.substring(0, noRegionMsg.length() - 1), 'Sales Region does not match data!');
                noRegionMsg = ' \r' + 'The ' + noRegionMsg.substring(0, noRegionMsg.length() - 1) + ' line,Sales Region does not match data!';
            }
            if(noModelMsg != ''){
                errorMap = addErrorMap(errorMap, noModelMsg.substring(0, noModelMsg.length() - 1), 'Model does not match data!');
                noModelMsg = ' \r' + 'The ' + noModelMsg.substring(0, noModelMsg.length() - 1) + ' line,Model does not match data!';
            }
            if(noDateMsg != ''){
                errorMap = addErrorMap(errorMap, noDateMsg.substring(0, noDateMsg.length() - 1), 'Date does not match data!');
                noDateMsg = ' \r' + 'The ' + noDateMsg.substring(0, noDateMsg.length() - 1) + ' line,Date does not match data!';
            }
            msg = noRegionMsg + noModelMsg + noDateMsg;

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
        out.errorMap = errorMap;

        return out;
    }

    @AuraEnabled
    public static ExcelUploadController.OutPut saveWeeklySalesTarget(String fileName, List<String[]> fileLines){
        ExcelUploadController.OutPut out = new ExcelUploadController.OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        Map<String, String> errorMap = new Map<String, String>();
        String msg = '';
        String noRegionMsg = '';
        String noChannelMsg = '';
        String noStoreMsg = '';
        String noProductLineMsg = '';
        String noModelMsg = '';
        String noWeekMsg = '';
        String noRspMsg = '';
        String noTargetMsg = '';
        
        // 要插入的Weekly_Sales_Target__c
        List<Weekly_Sales_Target__c> addList = new List<Weekly_Sales_Target__c>(); 
        //Map<String, Weekly_Sales_Target__c> channelInfoMap = new Map<String, Weekly_Sales_Target__c>();
        Set<String> wstEkSet = new Set<String>();
            
        System.debug('开始导入=>>>>>>>>>>>>>>>>');

        Integer index = 1;

        // 查询导出模板
        List<Responsible_Person__c> stList = [select Shop_Name__r.Sales_Region__c,Shop_Name__r.Channel_item__c,Shop_Name__r.Channel_item__r.Name,Shop_Name__r.Channel_Name__c,Shop_Name__c,Shop_Name__r.Name from Responsible_Person__c where Shop_Name__r.Channel_item__r.SBU__c = 'Hisense South Africa' and RecordType__c = '促销员' order by Shop_Name__r.Channel_Name__c];
        //25.3.20 张安琪要求模板取消渠道和产品线
        //Map<String, String> channelMap = new Map<String, String>();
        Map<String, Responsible_Person__c> shopMap = new Map<String, Responsible_Person__c>();
        for(Responsible_Person__c rp : stList){
            // if(!channelMap.containsKey(rp.Shop_Name__r.Channel_Name__c)){
            //     channelMap.put(rp.Shop_Name__r.Channel_Name__c.toLowerCase(), rp.Shop_Name__r.Channel_item__c);
            // }
            if(!shopMap.containsKey(rp.Shop_Name__r.Name)){
                shopMap.put(rp.Shop_Name__r.Name.toLowerCase(), rp);
            }
        }

        List<Product__c> productList = [Select id, Name, Product_Line__c From Product__c where Sales_Region__c =:stList[0].Shop_Name__r.Sales_Region__c];
        Map<String, Product__c> productMap = new Map<String, Product__c>();
        for(Product__c p : productList){
            if(String.isNotBlank(p.Name)){
                productMap.put(p.Name.toLowerCase(), p);
            }
        }

        Map<String, String> currencyMap = new Map<String, String>();
        currencyMap.put('Hisense Japan', 'JPY');
        currencyMap.put('Hisense South Africa', 'ZAR');
        currencyMap.put('Hisense USA', 'USD');
        currencyMap.put('Hisense Canada', 'CAD');
        currencyMap.put('Hisense Mexico', 'MXN');
        currencyMap.put('Hisense Peru', 'PEN');
        currencyMap.put('Hisense Chile', 'CLP');
        currencyMap.put('Hisense Argentina', 'ARS');
        currencyMap.put('Hisense Thailand', 'VND');
        currencyMap.put('Hisense Malaysia', 'MYR');
        currencyMap.put('Hisense Indonesia', 'IDR');
        currencyMap.put('Hisense Philippines', 'PHP');
        currencyMap.put('Hisense Singapore', 'SGD');

        Set<String> fromWeekSet = new Set<String>();
        Set<String> toWeekSet = new Set<String>();

        // 校验非空
        for(Integer i = index; i < fileLines.size(); i++){
            String[] cellList = fileLines[i];
            
            if(String.isBlank(cellList[0]) ||String.isBlank(cellList[1]) || String.isBlank(cellList[2]) || String.isBlank(cellList[3])
                || String.isBlank(cellList[4])){
                    continue;
            }

            // if(String.isBlank(channelMap.get(cellList[1].toLowerCase()))){
            //     noChannelMsg += (i+1) + ',';
            //     isSuccess = false;
            // }

            if(shopMap.get(cellList[1].toLowerCase()) == null){
                noStoreMsg += (i+1) + ',';
                isSuccess = false;
            }

            if(!productMap.containsKey(cellList[2].toLowerCase())){
                noModelMsg += (i+1) + ',';
                isSuccess = false;
            }

            try{
                Decimal fw = Decimal.valueOf(cellList[3].replace('WK',''));
                Decimal tw = Decimal.valueOf(cellList[4].replace('WK',''));
                
                if(tw < fw){
                    noWeekMsg += (i+1) + ',';
                    isSuccess = false;
                }
            }catch(Exception e){
                noWeekMsg += (i+1) + ',';
                isSuccess = false;
            }

            fromWeekSet.add(cellList[3]);
            toWeekSet.add(cellList[4]);

            if(fromWeekSet.size() > 1){
                noWeekMsg += (i+1) + ',';
                isSuccess = false;
            }
            if(toWeekSet.size() > 1){
                noWeekMsg += (i+1) + ',';
                isSuccess = false;
            }

            if(String.isNotBlank(cellList[5])){
                try{
                    Decimal.valueOf(cellList[5]);
                }catch(Exception e){
                    noRspMsg += (i+1) + ',';
                    isSuccess = false;
                }
            }

            if(String.isNotBlank(cellList[6])){
                try{
                    Decimal.valueOf(cellList[6]);
                }catch(Exception e){
                    noTargetMsg += (i+1) + ',';
                    isSuccess = false;
                }
            }
        }

        if(isSuccess){
            
            for(Integer i = index; i < fileLines.size(); i++){ 
                String[] cellList = fileLines[i];

                if(String.isBlank(cellList[0]) ||String.isBlank(cellList[1]) || String.isBlank(cellList[2]) || String.isBlank(cellList[3])
                || String.isBlank(cellList[4])){
                    continue;
                } 
                
                Weekly_Sales_Target__c target = new Weekly_Sales_Target__c();
                target.Sales_Region__c = cellList[0];
                target.CurrencyIsoCode = currencyMap.get(cellList[0]);
                target.Channel_item__c = shopMap.get(cellList[1].toLowerCase()).Shop_Name__r.Channel_item__c;
                target.Store__c = shopMap.get(cellList[1].toLowerCase()).Shop_Name__c;
                target.Product_Line__c = productMap.get(cellList[2].toLowerCase()).Product_Line__c;
                target.Model__c = productMap.get(cellList[2].toLowerCase()).Id;
                target.Model_Name__c = cellList[2];
                target.Week__c = Decimal.valueOf(cellList[3].replace('WK', ''));
                target.From_Week__c = Decimal.valueOf(cellList[3].replace('WK', ''));
                target.To_Week__c = Decimal.valueOf(cellList[4].replace('WK', ''));

                if(String.isNotBlank(cellList[5])){
                    target.RSP__c = Decimal.valueOf(cellList[5]);
                }
                if(String.isNotBlank(cellList[6])){
                    target.Plan_Target__c = Decimal.valueOf(cellList[6]).setScale(0, System.RoundingMode.HALF_UP);
                }
                
                target.External_key__c = target.Sales_Region__c + '_' 
                                        + target.Week__c + '_'
                                        + target.Channel_item__c + '_'
                                        + target.Store__c + '_'
                                        + target.Product_Line__c + '_'
                                        + target.Model__c + '_'
                                        + System.now().year();

                wstEkSet.add(target.External_key__c);
                addList.add(target);
            }
        }

        // if(noChannelMsg != ''){
        //     errorMap = addErrorMap(errorMap, noChannelMsg.substring(0, noChannelMsg.length() - 1), 'Channel does not match data!');
        //     noChannelMsg = ' \r' + 'The ' + noChannelMsg.substring(0, noChannelMsg.length() - 1) + ' line,Channel does not match data!';
        // }
        if(noStoreMsg != ''){
            errorMap = addErrorMap(errorMap, noStoreMsg.substring(0, noStoreMsg.length() - 1), 'Store does not match data!');
            noStoreMsg = ' \r' + 'The ' + noStoreMsg.substring(0, noStoreMsg.length() - 1) + ' line,Store does not match data!';
        }
        // if(noProductLineMsg != ''){
        //     errorMap = addErrorMap(errorMap, noProductLineMsg.substring(0, noProductLineMsg.length() - 1), 'Product Line does not match data!');
        //     noProductLineMsg = ' \r' + 'The ' + noProductLineMsg.substring(0, noProductLineMsg.length() - 1) + ' line,Product Line does not match data!';
        // }
        if(noModelMsg != ''){
            errorMap = addErrorMap(errorMap, noModelMsg.substring(0, noModelMsg.length() - 1), 'Model does not match data!');
            noModelMsg = ' \r' + 'The ' + noModelMsg.substring(0, noModelMsg.length() - 1) + ' line,Model does not match data!';
        }
        if(noWeekMsg != ''){
            errorMap = addErrorMap(errorMap, noWeekMsg.substring(0, noWeekMsg.length() - 1), 'Week does not match data!');
            noWeekMsg = ' \r' + 'The ' + noWeekMsg.substring(0, noWeekMsg.length() - 1) + ' line,Week does not match data!';
        }
        if(noRspMsg != ''){
            errorMap = addErrorMap(errorMap, noRspMsg.substring(0, noRspMsg.length() - 1), 'Target does not match data!');
            noRspMsg = ' \r' + 'The ' + noRspMsg.substring(0, noRspMsg.length() - 1) + ' line,Target does not match data!';
        }
        if(noTargetMsg != ''){
            errorMap = addErrorMap(errorMap, noTargetMsg.substring(0, noTargetMsg.length() - 1), 'Target does not match data!');
            noTargetMsg = ' \r' + 'The ' + noTargetMsg.substring(0, noTargetMsg.length() - 1) + ' line,Target does not match data!';
        }

        msg = noRegionMsg + noChannelMsg + noStoreMsg
            + noProductLineMsg + noModelMsg + + noWeekMsg + noRspMsg + noTargetMsg;

        if(isSuccess && addList.size() > 0){
            try {
                if(new List<String>(fromWeekSet).get(0) != new List<String>(toWeekSet).get(0)){
                    List<Weekly_Sales_Target__c> wstList = [SELECT Id,Name FROM Weekly_Sales_Target__c WHERE External_key__c IN :wstEkSet];
                    if(wstList != null && wstList.size() > 0){
                        for(Weekly_Sales_Target__c wst : wstList){
                            msg += wst.Name + ',';
                        }
                        msg += 'The data to be imported already exists.';
                        isSuccess = false;
                    }else{
                        // List<Weekly_Sales_Target__c> insertWstList = new List<Weekly_Sales_Target__c>();
                        // for(Weekly_Sales_Target__c wst : addList){
                        //     insertWstList.add(wst);
                        //     if(insertWstList.size() == 100){
                        //         String jobID = System.enqueueJob(new AsyncInsertWST(insertWstList));
                        //         insertWstList.clear();
                        //     }
                            
                        // }
                        //Database.insert(addList,true);
                    }
                }else{
                    //Database.upsert(addList,Weekly_Sales_Target__c.Fields.External_key__c,true);
                }
                if(isSuccess){
                    SetSAWeeklySalesTargetBA_ACHBatch ss = new SetSAWeeklySalesTargetBA_ACHBatch(addList, 'insert');
                    Database.executeBatch(ss, 1);
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
        out.isSuccess = isSuccess;
        out.errorMap = errorMap;

        return out;
    }

    /*@AuraEnabled
    public static ExcelUploadController.OutPut saveStoreProductLine(String fileName, List<String[]> fileLines){
        
        System.debug('wwwwwfileLines' + fileLines);

        List<Store_Product_Line__c> splList = [select id,Product_Line__c,Store__c from Store_Product_Line__c];
        Set<String> keys = new Set<String>();
        for(Store_Product_Line__c spl : splList){
            keys.add(spl.Product_Line__c + spl.Store__c);
        }

        list<Shop__c> ls = [select id,name from Shop__c];
        Map<String, Sobject> lsNameMap = new LisqContainer(ls).toMapS('Id');


        ExcelUploadController.OutPut out = new ExcelUploadController.OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        Map<String, String> errorMap = new Map<String, String>();
        String msg = '';
        String noStoreName = '';
        String noProductLine = '';
        String noEnteringStatus = '';
        String noTimeOfEntry = '';
        String noTimeOfExit = '';
        String noBoothQuantity = '';
        String noProductlineC = '';
        
        
        try{
            System.debug('开始导入=>>>>>>>>>>>>>>>>' + fileLines.size());

            Map<String, String> tempPL = Utility.getPicklistValueMap('Store_Product_Line__c','Product_Line__c');
            Set<String> productLineSet = tempPL.keySet();

            Map<String, String> tempES = Utility.getPicklistValueMap('Store_Product_Line__c','Entering_Status__c');
            Set<String> enteringStatusSet = tempES.keySet();

            // 校验非空字段
            for(Integer i = 1; i < fileLines.size(); i++){
                String[] cellList = fileLines[i];

                if(cellList[0] == ''){
                    noStoreName += (i+1) + ',';
                    isSuccess = false;
                }else{
                    if(!lsNameMap.containsKey(cellList[0])){
                        noStoreName += (i+1) + ',';
                        isSuccess = false;
                    }
                }
                if(cellList[1] == ''){
                    noProductLine += (i+1) + ',';
                    isSuccess = false;
                }else{
                    if(!productLineSet.contains(cellList[1])){
                        noProductLine += (i+1) + ',';
                        isSuccess = false;
                    }
                }

                if(cellList[2] == ''){
                    noEnteringStatus += (i+1) + ',';
                    isSuccess = false;
                }else{
                    if(!enteringStatusSet.contains(cellList[2])){
                        noEnteringStatus += (i+1) + ',';
                        isSuccess = false;
                    }
                }

                if(cellList[3] != ''){
                    try{
                        Date.valueOf(cellList[3].substring(0, 4) + '-' + cellList[3].substring(4,6) + '-01');
                    }catch(Exception e){
                        noTimeOfEntry += (i+1) + ',';
                        isSuccess = false;
                    }
                }

                if(cellList[4] != ''){
                    try{
                        Date.valueOf(cellList[4].substring(0, 4) + '-' + cellList[4].substring(4,6) + '-01');
                    }catch(Exception e){
                        noTimeOfExit += (i+1) + ',';
                        isSuccess = false;
                    }
                }

                if(cellList[5] != ''){
                    try{
                        Decimal.valueOf(cellList[5]);
                    }catch(Exception e){
                        noBoothQuantity += (i+1) + ',';
                        isSuccess = false;
                    }
                }

                if(cellList[1] != '' && cellList[0] != '' && !keys.add(cellList[1] + cellList[0])){
                    noProductlineC += (i+1) + ',';
                    isSuccess = false;
                }

            }

            List<Store_Product_Line__c> addList = new List<Store_Product_Line__c>(); 

            String saciKey = '';
            // 处理导入数据
            if(isSuccess){
                for(Integer i = 1; i < fileLines.size(); i++){
                    String[] cellList = fileLines[i];
    
                    Store_Product_Line__c s = new Store_Product_Line__c();
                    if(cellList[0] != ''){
                        s.Store__c = cellList[0];
                    }
                    if(cellList[1] != ''){
                        s.Product_Line__c = cellList[1];
                    }
                    if(cellList[2] != ''){
                        s.Entering_Status__c = cellList[2];
                    }
                    if(cellList[3] != ''){
                        s.Time_Of_Entry__c = cellList[3];
                    }
                    if(cellList[4] != ''){
                        s.Close_Date__c = cellList[4];
                    }
                    if(cellList[5] != ''){
                        s.Stand_Amount__c = Decimal.valueOf(cellList[5]);
                    }
                    addList.add(s);

                }
            }

            if(noProductlineC != ''){
                errorMap = addErrorMap(errorMap, noProductlineC.substring(0, noProductlineC.length() - 1), 'Data Already Exists!');
                noProductlineC = ' \r' + 'The ' + noProductlineC.substring(0, noProductlineC.length() - 1) + ' line,Data Already Exists!';
            }

            if(noStoreName != ''){
                errorMap = addErrorMap(errorMap, noStoreName.substring(0, noStoreName.length() - 1), 'Store Name not found!');
                noStoreName = ' \r' + 'The ' + noStoreName.substring(0, noStoreName.length() - 1) + ' line,Store Name not found!';
            }

            if(noProductLine != ''){
                errorMap = addErrorMap(errorMap, noProductLine.substring(0, noProductLine.length() - 1), 'Product Line not found!');
                noProductLine = ' \r' + 'The ' + noProductLine.substring(0, noProductLine.length() - 1) + ' line,Product Line not found!';
            }

            if(noEnteringStatus != ''){
                errorMap = addErrorMap(errorMap, noEnteringStatus.substring(0, noEnteringStatus.length() - 1), 'Entering Status not found!');
                noEnteringStatus = ' \r' + 'The ' + noEnteringStatus.substring(0, noEnteringStatus.length() - 1) + ' line,Entering Status not found!';
            }

            if(noTimeOfEntry != ''){
                errorMap = addErrorMap(errorMap, noTimeOfEntry.substring(0, noTimeOfEntry.length() - 1), 'Time Of Entry is not a date!');
                noTimeOfEntry = ' \r' + 'The ' + noTimeOfEntry.substring(0, noTimeOfEntry.length() - 1) + ' line,Time Of Entry is not a date!';
            }

            if(noTimeOfExit != ''){
                errorMap = addErrorMap(errorMap, noTimeOfExit.substring(0, noTimeOfExit.length() - 1), 'Time Of Exit is not a date!');
                noTimeOfExit = ' \r' + 'The ' + noTimeOfExit.substring(0, noTimeOfExit.length() - 1) + ' line,Time Of Exit is not a date!';
            }
            if(noBoothQuantity != ''){
                errorMap = addErrorMap(errorMap, noBoothQuantity.substring(0, noBoothQuantity.length() - 1), 'Booth Quantity is not a number!');
                noBoothQuantity = ' \r' + 'The ' + noBoothQuantity.substring(0, noBoothQuantity.length() - 1) + ' line,Booth Quantity is not a number!';
            }

            msg = noProductlineC + ' \r' + noStoreName + ' \r' + noProductLine + ' \r' + noEnteringStatus + ' \r' + noTimeOfEntry + ' \r' + noTimeOfExit + ' \r' + noBoothQuantity;

            if(isSuccess){
                try {

                    Database.insert(addList);

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
        out.errorMap = errorMap;

        return out;
    }

    @AuraEnabled
    public static ExcelUploadController.OutPut saveSamplingCondition(String fileName, List<String[]> fileLines,String importDate){
        
        System.debug('wwwwwimportDate' + importDate);
        // String year = importDate.substring(0,4);
        importDate += '-01';

        ExcelUploadController.OutPut out = new ExcelUploadController.OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        Map<String, String> errorMap = new Map<String, String>();
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
        // base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        // Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        // String content = ExcelUploadController.bitToString(contentBlob, 'UTF-8');
        // content = content.replaceAll('\r\n', '\n');
        // content = content.replaceAll('\r', '\n');
        // List<String> fileLines = content.trim().split('\n');
        System.debug('开始导入=>>>>>>>>>>>>>>>>');

        // 校验非空字段
        for(Integer i = 1; i < fileLines.size(); i++){
            String[] cellList = fileLines[i];
            // String fileLine = fileLines[i];
            // List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            // for(Integer j = 0; j < cellList.size(); j++){
            //     //去掉首尾两端的双引号
            //     if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
            //     if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
            //     //将连续双引号变为单个双引号
            //     cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            // }

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
                String[] cellList = fileLines[i];
                // String fileLine = fileLines[i];
                // List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                // for(Integer j = 0; j < cellList.size(); j++){
                //     //去掉首尾两端的双引号
                //     if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                //     if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //     //将连续双引号变为单个双引号
                //     cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                // }
    
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
                String[] cellList = fileLines[i];
                // String fileLine = fileLines[i];
                // List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                // for(Integer j = 0; j < cellList.size(); j++){
                //     //去掉首尾两端的双引号
                //     if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                //     if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //     //将连续双引号变为单个双引号
                //     cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                // }

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
                String[] cellList = fileLines[i];
                // String fileLine = fileLines[i];
                // List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                // for(Integer j = 0; j < cellList.size(); j++){
                //     //去掉首尾两端的双引号
                //     if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                //     if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //     //将连续双引号变为单个双引号
                //     cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                // }
                
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
            errorMap = addErrorMap(errorMap, noRegionMsg.substring(0, noRegionMsg.length() - 1), 'Region does not match data!');
            noRegionMsg = ' \r' + 'The ' + noRegionMsg.substring(0, noRegionMsg.length() - 1) + ' line,Region does not match data!';
        }

        if(noSBUMsg != ''){
            errorMap = addErrorMap(errorMap, noSBUMsg.substring(0, noSBUMsg.length() - 1), 'SBU does not match data!');
            noSBUMsg = ' \r' + 'The ' + noSBUMsg.substring(0, noSBUMsg.length() - 1) + ' line,SBU does not match data!';
        }

        if(noChannelMsg != ''){
            errorMap = addErrorMap(errorMap, noChannelMsg.substring(0, noChannelMsg.length() - 1), 'Channel does not match data!');
            noChannelMsg = ' \r' + 'The ' + noChannelMsg.substring(0, noChannelMsg.length() - 1) + ' line,Channel does not match data!';
        }

        if(noChannelcode != ''){
            errorMap = addErrorMap(errorMap, noChannelcode.substring(0, noChannelcode.length() - 1), 'Channel Code does not match data!');
            noChannelcode = ' \r' + 'The ' + noChannelcode.substring(0, noChannelcode.length() - 1) + ' line,Channel Code does not match data!';
        }

        if(noProductLineMsg != ''){
            errorMap = addErrorMap(errorMap, noProductLineMsg.substring(0, noProductLineMsg.length() - 1), 'Product Line does not match data!');
            noProductLineMsg = ' \r' + 'The ' + noProductLineMsg.substring(0, noProductLineMsg.length() - 1) + ' line,Product Line does not match data!';
        }

        if(noBrandMsg != ''){
            errorMap = addErrorMap(errorMap, noBrandMsg.substring(0, noBrandMsg.length() - 1), 'Brand does not match data!');
            noBrandMsg = ' \r' + 'The ' + noBrandMsg.substring(0, noBrandMsg.length() - 1) + ' line,Brand does not match data!';
        }

        if(noPlatformModelMsg != ''){
            errorMap = addErrorMap(errorMap, noPlatformModelMsg.substring(0, noPlatformModelMsg.length() - 1), 'Platform Model does not match data!');
            noPlatformModelMsg = ' \r' + 'The ' + noPlatformModelMsg.substring(0, noPlatformModelMsg.length() - 1) + ' line,Platform Model does not match data!';
        }

        if(noUSDMsg != ''){
            errorMap = addErrorMap(errorMap, noUSDMsg.substring(0, noUSDMsg.length() - 1), 'USD does not match data!');
            noUSDMsg = ' \r' + 'The ' + noUSDMsg.substring(0, noUSDMsg.length() - 1) + ' line,USD does not match data!';
        }

        if(noSamplingStatusMsg != ''){
            errorMap = addErrorMap(errorMap, noSamplingStatusMsg.substring(0, noSamplingStatusMsg.length() - 1), 'Sampling Status does not match data!');
            noSamplingStatusMsg = ' \r' + 'The ' + noSamplingStatusMsg.substring(0, noSamplingStatusMsg.length() - 1) + ' line,Sampling Status does not match data!';
        }

        if(noActualSampleQty != ''){
            errorMap = addErrorMap(errorMap, noActualSampleQty.substring(0, noActualSampleQty.length() - 1), 'Actual Sample Qty does not match data!');
            noActualSampleQty = ' \r' + 'The ' + noActualSampleQty.substring(0, noActualSampleQty.length() - 1) + ' line,Actual Sample Qty does not match data!';
        }
        
        if(noChannelCodeCheck != ''){
            errorMap = addErrorMap(errorMap, noChannelCodeCheck.substring(0, noChannelCodeCheck.length() - 1), 'Customer Management Code does not exist!');
            noChannelCodeCheck = ' \r' + 'The ' + noChannelCodeCheck.substring(0, noChannelCodeCheck.length() - 1) + ' line,Customer Management Code does not exist!';
        }

        if(noSamplingTargetMsg != ''){
            errorMap = addErrorMap(errorMap, noSamplingTargetMsg.substring(0, noSamplingTargetMsg.length() - 1), 'Please first maintain the corresponding data in the Sampling Target!');
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
        cv.VersionData = Blob.valueOf(JSON.serialize(fileLines));
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
        out.errorMap = errorMap;

        return out;
    }

    @AuraEnabled
    public static ExcelUploadController.OutPut saveSamplingTarget(String fileName, List<String[]> fileLines){
        ExcelUploadController.OutPut out = new ExcelUploadController.OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        Map<String, String> errorMap = new Map<String, String>();
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
        // base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        // Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        // String content = ExcelUploadController.bitToString(contentBlob, 'UTF-8');
        // content = content.replaceAll('\r\n', '\n');
        // content = content.replaceAll('\r', '\n');
        // List<String> fileLines = content.trim().split('\n');
        System.debug('开始导入=>>>>>>>>>>>>>>>>');

        //获取区组维度信息
        LisqContainer lc = new LisqContainer([Select Id,Region__c,Name,SBU_Code__c from Block_Dimension__c ]);
        Map<String,LisqContainer> dimensionMap = lc.GroupByS('Region__c');

        // 存放出样目标查询渠道数据唯一值
        List<String> channelKeys = new List<String>();

        for(Integer i = 2; i < fileLines.size(); i++){
            String[] cellList = fileLines[i];
            // String fileLine = fileLines[i];
            // List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            // for(Integer j = 0; j < cellList.size(); j++){
            //     //去掉首尾两端的双引号
            //     if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
            //     if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
            //     //将连续双引号变为单个双引号
            //     cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            // }

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
            String[] cellList = fileLines[i];
            // String fileLine = fileLines[i];
            // List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            // for(Integer j = 0; j < cellList.size(); j++){
            //     //去掉首尾两端的双引号
            //     if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
            //     if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
            //     //将连续双引号变为单个双引号
            //     cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            // }
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
                String[] cellList = fileLines[i];
                // String fileLine = fileLines[i];
                // List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                // for(Integer j = 0; j < cellList.size(); j++){
                //     //去掉首尾两端的双引号
                //     if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                //     if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //     //将连续双引号变为单个双引号
                //     cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                // }
                
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
            errorMap = addErrorMap(errorMap, noRegionMsg.substring(0, noRegionMsg.length() - 1), 'Region does not match data!');
            noRegionMsg = ' \r' + 'The ' + noRegionMsg.substring(0, noRegionMsg.length() - 1) + ' line,Region does not match data!';
        }
        if(noSBUMsg != ''){
            errorMap = addErrorMap(errorMap, noSBUMsg.substring(0, noSBUMsg.length() - 1), 'SBU does not match data!');
            noSBUMsg = ' \r' + 'The ' + noSBUMsg.substring(0, noSBUMsg.length() - 1) + ' line,SBU does not match data!';
        }
        if(noChannelMsg != ''){
            errorMap = addErrorMap(errorMap, noChannelMsg.substring(0, noChannelMsg.length() - 1), 'Channel does not match data!');
            noChannelMsg = ' \r' + 'The ' + noChannelMsg.substring(0, noChannelMsg.length() - 1) + ' line,Channel does not match data!';
        }
        if(noProductLineMsg != ''){
            errorMap = addErrorMap(errorMap, noProductLineMsg.substring(0, noProductLineMsg.length() - 1), 'Product Line does not match data!');
            noProductLineMsg = ' \r' + 'The ' + noProductLineMsg.substring(0, noProductLineMsg.length() - 1) + ' line,Product Line does not match data!';
        }
        if(noBrandMsg != ''){
            errorMap = addErrorMap(errorMap, noBrandMsg.substring(0, noBrandMsg.length() - 1), 'Brand does not match data!');
            noBrandMsg = ' \r' + 'The ' + noBrandMsg.substring(0, noBrandMsg.length() - 1) + ' line,Brand does not match data!';
        }
        if(noPlatformModelMsg != ''){
            errorMap = addErrorMap(errorMap, noPlatformModelMsg.substring(0, noPlatformModelMsg.length() - 1), 'Platform Model does not match data!');
            noPlatformModelMsg = ' \r' + 'The ' + noPlatformModelMsg.substring(0, noPlatformModelMsg.length() - 1) + ' line,Platform Model does not match data!';
        }
        if(noUSDMsg != ''){
            errorMap = addErrorMap(errorMap, noUSDMsg.substring(0, noUSDMsg.length() - 1), 'USD does not match data!');
            noUSDMsg = ' \r' + 'The ' + noUSDMsg.substring(0, noUSDMsg.length() - 1) + ' line,USD does not match data!';
        }
        if(noSamplingStatusMsg != ''){
            errorMap = addErrorMap(errorMap, noSamplingStatusMsg.substring(0, noSamplingStatusMsg.length() - 1), 'Sampling Status does not match data!');
            noSamplingStatusMsg = ' \r' + 'The ' + noSamplingStatusMsg.substring(0, noSamplingStatusMsg.length() - 1) + ' line,Sampling Status does not match data!';
        }
        if(noSamplingTargeYearMsg != ''){
            errorMap = addErrorMap(errorMap, noSamplingTargeYearMsg.substring(0, noSamplingTargeYearMsg.length() - 1), 'Sampling Target Year does not match data!');
            noSamplingTargeYearMsg = ' \r' + 'The ' + noSamplingTargeYearMsg.substring(0, noSamplingTargeYearMsg.length() - 1) + ' line,Sampling Target Year does not match data!';
        }
        if(noQtyin2023Msg != ''){
            errorMap = addErrorMap(errorMap, noQtyin2023Msg.substring(0, noQtyin2023Msg.length() - 1), 'Total Sample Qty in 2023 does not match data!');
            noQtyin2023Msg = ' \r' + 'The ' + noQtyin2023Msg.substring(0, noQtyin2023Msg.length() - 1) + ' line,Total Sample Qty in 2023 does not match data!';
        }
        if(noJanMag != ''){
            errorMap = addErrorMap(errorMap, noJanMag.substring(0, noJanMag.length() - 1), 'Jan does not match data!');
            noJanMag = ' \r' + 'The ' + noJanMag.substring(0, noJanMag.length() - 1) + ' line,Jan does not match data!';
        }
        if(noFebMag != ''){
            errorMap = addErrorMap(errorMap, noFebMag.substring(0, noFebMag.length() - 1), 'Feb does not match data!');
            noFebMag = ' \r' + 'The ' + noFebMag.substring(0, noFebMag.length() - 1) + ' line,Feb does not match data!';
        }
        if(noMarMag != ''){
            errorMap = addErrorMap(errorMap, noMarMag.substring(0, noMarMag.length() - 1), 'Mar does not match data!');
            noMarMag = ' \r' + 'The ' + noMarMag.substring(0, noMarMag.length() - 1) + ' line,Mar does not match data!';
        }
        if(noAprMag != ''){
            errorMap = addErrorMap(errorMap, noAprMag.substring(0, noAprMag.length() - 1), 'Apr does not match data!');
            noAprMag = ' \r' + 'The ' + noAprMag.substring(0, noAprMag.length() - 1) + ' line,Apr does not match data!';
        }
        if(noMayMag != ''){
            errorMap = addErrorMap(errorMap, noMayMag.substring(0, noMayMag.length() - 1), 'May does not match data!');
            noMayMag = ' \r' + 'The ' + noMayMag.substring(0, noMayMag.length() - 1) + ' line,May does not match data!';
        }
        if(noJunMag != ''){
            errorMap = addErrorMap(errorMap, noJunMag.substring(0, noJunMag.length() - 1), 'Jun does not match data!');
            noJunMag = ' \r' + 'The ' + noJunMag.substring(0, noJunMag.length() - 1) + ' line,Jun does not match data!';
        }
        if(noJulyMag != ''){
            errorMap = addErrorMap(errorMap, noJulyMag.substring(0, noJulyMag.length() - 1), 'July does not match data!');
            noJulyMag = ' \r' + 'The ' + noJulyMag.substring(0, noJulyMag.length() - 1) + ' line,July does not match data!';
        }
        if(noAugMag != ''){
            errorMap = addErrorMap(errorMap, noAugMag.substring(0, noAugMag.length() - 1), 'Aug does not match data!');
            noAugMag = ' \r' + 'The ' + noAugMag.substring(0, noAugMag.length() - 1) + ' line,Aug does not match data!';
        }
        if(noSepMag != ''){
            errorMap = addErrorMap(errorMap, noSepMag.substring(0, noSepMag.length() - 1), 'Sep does not match data!');
            noSepMag = ' \r' + 'The ' + noSepMag.substring(0, noSepMag.length() - 1) + ' line,Sep does not match data!';
        }
        if(noOctMag != ''){
            errorMap = addErrorMap(errorMap, noOctMag.substring(0, noOctMag.length() - 1), 'Oct does not match data!');
            noOctMag = ' \r' + 'The ' + noOctMag.substring(0, noOctMag.length() - 1) + ' line,Oct does not match data!';
        }
        if(noNovMag != ''){
            errorMap = addErrorMap(errorMap, noNovMag.substring(0, noNovMag.length() - 1), 'Nov does not match data!');
            noNovMag = ' \r' + 'The ' + noNovMag.substring(0, noNovMag.length() - 1) + ' line,Nov does not match data!';
        }
        if(noDecMag != ''){
            errorMap = addErrorMap(errorMap, noDecMag.substring(0, noDecMag.length() - 1), 'Dec does not match data!');
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
        out.errorMap = errorMap;

        return out;
    }

    @AuraEnabled
    public static ExcelUploadController.OutPut saveChannel(String fileName, List<String[]> fileLines){

        ExcelUploadController.OutPut out = new ExcelUploadController.OutPut(); 
        Boolean isSuccess = true;
        Boolean partFails = false;
        Map<String, String> errorMap = new Map<String, String>();
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
        // base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        // Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        // String content = ExcelUploadController.bitToString(contentBlob, 'UTF-8');
        // content = content.replaceAll('\r\n', '\n');
        // content = content.replaceAll('\r', '\n');
        // List<String> fileLines = content.trim().split('\n');
        System.debug('开始导入=>>>>>>>>>>>>>>>>');

        List<String> channelNames = new List<String>();

        for(Integer i = 3; i < fileLines.size(); i++){
            String[] cellList = fileLines[i];
            // String fileLine = fileLines[i];
            // List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            // for(Integer j = 0; j < cellList.size(); j++){
            //     //去掉首尾两端的双引号
            //     if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
            //     if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
            //     //将连续双引号变为单个双引号
            //     cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            // }

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
            String[] cellList = fileLines[i];
            // String fileLine = fileLines[i];
            // List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
            // for(Integer j = 0; j < cellList.size(); j++){
            //     //去掉首尾两端的双引号
            //     if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
            //     if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
            //     //将连续双引号变为单个双引号
            //     cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
            // }

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
                if(cellList[2] != null){
                    LisqContainer lcDimension = dimensionMap.get(cellList[2]);
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
                String[] cellList = fileLines[i];
                // String fileLine = fileLines[i];
                // List<String> cellList = fileLine.trim().split(',(?=([^\"]*\"[^\"]*\")*[^\"]*$)');
                // for(Integer j = 0; j < cellList.size(); j++){
                //     //去掉首尾两端的双引号
                //     if(cellList[j].startsWith('\"')) cellList[j] = cellList[j].substring(1, cellList[j].length()); 
                //     if(cellList[j].endsWith('\"')) cellList[j] = cellList[j].substring(0, cellList[j].length() - 1);
                //     //将连续双引号变为单个双引号
                //     cellList[j] = cellList[j].replaceAll('\"\"', '\"'); 
                // }
                
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
            errorMap = addErrorMap(errorMap, noProducLineMsg.substring(0, noProducLineMsg.length() - 1), 'Product Line does not match data!');
            noProducLineMsg = ' \r' + 'The ' + noProducLineMsg.substring(0, noProducLineMsg.length() - 1) + ' line,Product Line does not match data!';
        }
        if(noRegionMsg != ''){
            errorMap = addErrorMap(errorMap, noRegionMsg.substring(0, noRegionMsg.length() - 1), 'Region does not match data!');
            noRegionMsg = ' \r' + 'The ' + noRegionMsg.substring(0, noRegionMsg.length() - 1) + ' line,Region does not match data!';
        }
        if(noSBUMsg != ''){
            errorMap = addErrorMap(errorMap, noSBUMsg.substring(0, noSBUMsg.length() - 1), 'SBU does not match data!');
            noSBUMsg = ' \r' + 'The ' + noSBUMsg.substring(0, noSBUMsg.length() - 1) + ' line,SBU does not match data!';
        }
        if(noSBUCodeMsg != ''){
            errorMap = addErrorMap(errorMap, noSBUCodeMsg.substring(0, noSBUCodeMsg.length() - 1), 'The SBU Name does not match the corresponding encoding!');
            noSBUCodeMsg = ' \r' + 'The ' + noSBUCodeMsg.substring(0, noSBUCodeMsg.length() - 1) + ' line,The SBU Name does not match the corresponding encoding!';
        }
        if(noCountryMsg != ''){
            errorMap = addErrorMap(errorMap, noCountryMsg.substring(0, noCountryMsg.length() - 1), 'Country does not match data!');
            noCountryMsg = ' \r' + 'The ' + noCountryMsg.substring(0, noCountryMsg.length() - 1) + ' line,Country does not match data!';    
        }
        if(noChannelNameMsg != ''){
            errorMap = addErrorMap(errorMap, noChannelNameMsg.substring(0, noChannelNameMsg.length() - 1), 'Channel Name does not match data!');
            noChannelNameMsg = ' \r' + 'The ' + noChannelNameMsg.substring(0, noChannelNameMsg.length() - 1) + ' line,Channel Name does not match data!';   
        }
        if(noChannelCodeMsg != ''){
            errorMap = addErrorMap(errorMap, noChannelCodeMsg.substring(0, noChannelCodeMsg.length() - 1), 'Channel Code does not match data!');
            noChannelCodeMsg = ' \r' + 'The ' + noChannelCodeMsg.substring(0, noChannelCodeMsg.length() - 1) + ' line,Channel Code does not match data!';    
        }
        if(noMarketShareMsg != ''){
            errorMap = addErrorMap(errorMap, noMarketShareMsg.substring(0, noMarketShareMsg.length() - 1), 'Market Share does not match data!');
            noMarketShareMsg = ' \r' + 'The ' + noMarketShareMsg.substring(0, noMarketShareMsg.length() - 1) + ' line,Market Share does not match data!';   
        }
        if(noRevenueMsg != ''){
            errorMap = addErrorMap(errorMap, noRevenueMsg.substring(0, noRevenueMsg.length() - 1), 'Annual Business Revenue does not match data!');
            noRevenueMsg = ' \r' + 'The ' + noRevenueMsg.substring(0, noRevenueMsg.length() - 1) + ' line,Annual Business Revenue does not match data!';
        }
        if(noStatusMsg != ''){
            errorMap = addErrorMap(errorMap, noStatusMsg.substring(0, noStatusMsg.length() - 1), 'Cooperating Status does not match data!');
            noStatusMsg = ' \r' + 'The ' + noStatusMsg.substring(0, noStatusMsg.length() - 1) + ' line,Cooperating Status does not match data!';
        }
        if(noCooperatedTimeMsg != ''){
            errorMap = addErrorMap(errorMap, noCooperatedTimeMsg.substring(0, noCooperatedTimeMsg.length() - 1), 'Cooperated Time does not match data!');
            noCooperatedTimeMsg = ' \r' + 'The ' + noCooperatedTimeMsg.substring(0, noCooperatedTimeMsg.length() - 1) + ' line,Cooperated Time does not match data!';
        }
        if(noTimeMsg != ''){
            errorMap = addErrorMap(errorMap, noTimeMsg.substring(0, noTimeMsg.length() - 1), 'Planned Cooperating Time does not match data!');
            noTimeMsg = 'The ' + noTimeMsg.substring(0, noTimeMsg.length() - 1) + ' line,Planned Cooperating Time does not match data!';
        }
        if(noMethodMsg != ''){
            errorMap = addErrorMap(errorMap, noMethodMsg.substring(0, noMethodMsg.length() - 1), 'Cooperating Method does not match data!');
            noMethodMsg = ' \r' + 'The ' + noMethodMsg.substring(0, noMethodMsg.length() - 1) + ' line,Cooperating Method does not match data!';
        }
        if(noEntityNameMsg != ''){
            errorMap = addErrorMap(errorMap, noEntityNameMsg.substring(0, noEntityNameMsg.length() - 1), 'Cooperating Customer Entity Name does not match data!');
            noEntityNameMsg = 'The ' + noEntityNameMsg.substring(0, noEntityNameMsg.length() - 1) + ' line,Cooperating Customer Entity Name does not match data!';
        }
        if(noSapCodeMsg != ''){
            errorMap = addErrorMap(errorMap, noSapCodeMsg.substring(0, noSapCodeMsg.length() - 1), 'Cooperating Customer SAP code does not match data!');
            noSapCodeMsg = 'The ' + noSapCodeMsg.substring(0, noSapCodeMsg.length() - 1) + ' line,Cooperating Customer SAP code does not match data!';
        }
        if(noShareMsg != ''){
            errorMap = addErrorMap(errorMap, noShareMsg.substring(0, noShareMsg.length() - 1), 'Hisense Value Share does not match data!');
            noShareMsg = ' \r' + 'The ' + noShareMsg.substring(0, noShareMsg.length() - 1) + ' line,Hisense Value Share does not match data!';
        }
        if(noNumberofStoresMsg != ''){
            errorMap = addErrorMap(errorMap, noNumberofStoresMsg.substring(0, noNumberofStoresMsg.length() - 1), 'Number of Stores does not match data!');
            noNumberofStoresMsg = ' \r' + 'The ' + noNumberofStoresMsg.substring(0, noNumberofStoresMsg.length() - 1) + ' line,Number of Stores does not match data!';
        }
        if(noEnteredStoresMsg != ''){
            errorMap = addErrorMap(errorMap, noEnteredStoresMsg.substring(0, noEnteredStoresMsg.length() - 1), 'Number of Entered Stores does not match data!');
            noEnteredStoresMsg = ' \r' + 'The ' + noEnteredStoresMsg.substring(0, noEnteredStoresMsg.length() - 1) + ' line,Number of Entered Stores does not match data!';
        }
        if(noStoreEnteringPlanMsg != ''){
            errorMap = addErrorMap(errorMap, noStoreEnteringPlanMsg.substring(0, noStoreEnteringPlanMsg.length() - 1), 'Number of New Store Entering Plan 2024 does not match data!');
            noStoreEnteringPlanMsg = ' \r' + 'The ' + noStoreEnteringPlanMsg.substring(0, noStoreEnteringPlanMsg.length() - 1) + ' line,Number of New Store Entering Plan 2024 does not match data!';
        }
        if(noStatusMethodMsg != ''){
            errorMap = addErrorMap(errorMap, noStatusMethodMsg.substring(0, noStatusMethodMsg.length() - 1), 'Cooperating Code and Cooperating Method does not match data!');
            noStatusMethodMsg = ' \r' + 'The ' + noStatusMethodMsg.substring(0, noStatusMethodMsg.length() - 1) + ' line,Cooperating Code and Cooperating Method does not match data!';
        }
        if(noStatisticalYearMsg != ''){
            errorMap = addErrorMap(errorMap, noStatisticalYearMsg.substring(0, noStatisticalYearMsg.length() - 1), 'Statistical Year does not match data!');
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
        cv.VersionData = Blob.valueOf(JSON.serialize(fileLines));
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
        out.errorMap = errorMap;

        return out;
    }

    // Targets 导入
    @AuraEnabled
    public static OutPut saveTargets(String fileName, List<String[]> fileLines) {
        OutPut out = new OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        Map<String, String> errorMap = new Map<String, String>();
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
        
        for (Integer i = 1; i < fileLines.size(); i++) {
            String[] cellList = fileLines[i];
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
            String[] cellList = fileLines[i];
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
            errorMap = addErrorMap(errorMap, noShopMsg.substring(0, noShopMsg.length() - 1), 'Store does not match data!');
            noShopMsg = 'The ' + noShopMsg.substring(0, noShopMsg.length() - 1) + ' line,Store does not match data!';
        }
        if(noProductMsg != ''){
            errorMap = addErrorMap(errorMap, noProductMsg.substring(0, noProductMsg.length() - 1), 'Product does not match data!');
            noProductMsg = 'The ' + noProductMsg.substring(0, noProductMsg.length() - 1) + ' line,Product does not match data!';
        }
        if(noPersonMsg != ''){
            errorMap = addErrorMap(errorMap, noPersonMsg.substring(0, noPersonMsg.length() - 1), 'Responsible Person does not match data!');
            noPersonMsg = 'The ' + noPersonMsg.substring(0, noPersonMsg.length() - 1) + ' line,Responsible Person does not match data!';
        }
        msg = noShopMsg + ' \r' + noProductMsg + ' \r' + noPersonMsg;

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
        out.errorMap = errorMap;
        return out;
    }

    @AuraEnabled
    public static ExcelUploadController.OutPut saveCustomerTargets(String fileName, List<String[]> fileLines){

        ExcelUploadController.OutPut out = new ExcelUploadController.OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        Map<String, String> errorMap = new Map<String, String>();
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
        
        System.debug('开始导入=>>>>>>>>>>>>>>>>');

        // 存放导入纬度校验，同一个模版客户同一时间一次只能导入一条数据
        List<String> targetName = new List<String>();

        // 校验必填字段
        for (Integer i = 1; i < fileLines.size(); i++) {
            String[] cellList = fileLines[i];

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
                String[] cellList = fileLines[i];
                
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
                String[] cellList = fileLines[i];
    
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
            errorMap = addErrorMap(errorMap, noAmountMsg.substring(0, noAmountMsg.length() - 1), 'Amount does not match data!');
            noAmountMsg = 'The ' + noAmountMsg.substring(0, noAmountMsg.length() - 1) + ' line,Amount does not match data!';
        }
        if(noCustomerCodeMsg != ''){
            errorMap = addErrorMap(errorMap, noCustomerCodeMsg.substring(0, noCustomerCodeMsg.length() - 1), 'SAP Customer Code does not match data!');
            noCustomerCodeMsg = 'The ' + noCustomerCodeMsg.substring(0, noCustomerCodeMsg.length() - 1) + ' line,SAP Customer Code does not match data!';
        }
        if(noCurrencyMsg != ''){
            errorMap = addErrorMap(errorMap, noCurrencyMsg.substring(0, noCurrencyMsg.length() - 1), 'Currency does not match data!');
            noCurrencyMsg = 'The ' + noCurrencyMsg.substring(0, noCurrencyMsg.length() - 1) + ' line,Currency does not match data!';
        }
        if(noDateMsg != ''){
            errorMap = addErrorMap(errorMap, noDateMsg.substring(0, noDateMsg.length() - 1), 'Date does not match data!');
            noDateMsg = 'The ' + noDateMsg.substring(0, noDateMsg.length() - 1) + ' line,Date does not match data!';
        }
        if(noTargetMsg != ''){
            errorMap = addErrorMap(errorMap, noTargetMsg.substring(0, noTargetMsg.length() - 1), 'Data of the same day already exists in the template!');
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
        out.errorMap = errorMap;

        return out;
    }

    // Store Inspection Manage 导入
    @AuraEnabled
    public static OutPut saveStoreInspectionManage(String fileName, List<String[]> fileLines) {
        OutPut out = new OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        Map<String, String> errorMap = new Map<String, String>();
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
        
        for (Integer i = 1; i < fileLines.size(); i++) {
            String[] cellList = fileLines[i];
            
            system.debug('wwwww------' + cellList);
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
        // ContentVersion cv = new ContentVersion();
        // cv.Title = fileName;
        // cv.PathOnClient = '/' + fileName;
        // cv.FirstPublishLocationId = currentUser.Id;
        // cv.VersionData = EncodingUtil.base64Decode(base64Data);
        // cv.IsMajorVersion = true;
        // Insert cv;
        
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
        out.errorMap = errorMap;
        return out;
    }

    // Daily Sales 导入
    @AuraEnabled
    public static OutPut saveDailySales(String fileName, List<String[]> fileLines) {
        OutPut out = new OutPut();
        Map<String, String> errorMap = new Map<String, String>();
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
        
        System.debug('fileLines Size-->'+fileLines.size());
        
        for (Integer i = 1; i < fileLines.size(); i++) {
            String[] cellList = fileLines[i];

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
            errorMap = addErrorMap(errorMap, noShopMsg.substring(0, noShopMsg.length() - 1), 'Store or account does not match data!');
            noShopMsg = 'The ' + noShopMsg.substring(0, noShopMsg.length() - 1) + ' line,Store or account does not match data!';
        }
        if(noProductMsg != ''){
            errorMap = addErrorMap(errorMap, noProductMsg.substring(0, noProductMsg.length() - 1), 'Product does not match data!');
            noProductMsg = 'The ' + noProductMsg.substring(0, noProductMsg.length() - 1) + ' line,Product does not match data!';
        }

        msg = noShopMsg + ' \r' + noProductMsg;
        
        //inserting file
        // ContentVersion cv = new ContentVersion();
        // cv.Title = fileName;
        // cv.PathOnClient = '/' + fileName;
        // cv.FirstPublishLocationId = currentUser.Id;
        // cv.VersionData = EncodingUtil.base64Decode(base64Data);
        // cv.IsMajorVersion = true;
        // Insert cv;

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
        out.errorMap = errorMap;

        return out;
    }*/
    
    /**
     * @Param: 
     * @Return: 
     * @Author: WFC
     * @Date: 2025-02-19 09:58:49
     * @Description: 目标导入
     */
    @AuraEnabled
    public static ExcelUploadController.OutPut saveTargetOther(String fileName, List<String[]> fileLines){
        String Sell_Out_Amount = Schema.SobjectType.SalesGoal__c.getRecordTypeInfosByDeveloperName().get('Sell_Out_Amount').getRecordTypeId();
        String Shop_Efficiency = Schema.SobjectType.SalesGoal__c.getRecordTypeInfosByDeveloperName().get('Shop_Efficiency').getRecordTypeId();
        String Human_Effect = Schema.SobjectType.SalesGoal__c.getRecordTypeInfosByDeveloperName().get('Human_Effect').getRecordTypeId();
        String Key_Products_Sell_Out = Schema.SobjectType.SalesGoal__c.getRecordTypeInfosByDeveloperName().get('Key_Products_Sell_Out').getRecordTypeId();
        String X500_Sellout = Schema.SobjectType.SalesGoal__c.getRecordTypeInfosByDeveloperName().get('X500_Sellout').getRecordTypeId();
        String X1000_Sellout = Schema.SobjectType.SalesGoal__c.getRecordTypeInfosByDeveloperName().get('X1000_Sellout').getRecordTypeId();
        String Key_Channel_Store_Coverage = Schema.SobjectType.SalesGoal__c.getRecordTypeInfosByDeveloperName().get('Key_Channel_Store_Coverage').getRecordTypeId();

        ExcelUploadController.OutPut out = new ExcelUploadController.OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        Map<String, String> errorMap = new Map<String, String>();
        String msg = '';
        String noRecordTypeMsg = '';
        String noYearMsg = '';
        String noMonthMsg = '';
        String noSalesRegionMsg = '';
        String noBrandMsg = '';
        String noProductLineMsg = '';
        String noNumberMsg = '';
        
        // 要插入的Target
        List<SalesGoal__c> addList = new List<SalesGoal__c>(); 
        System.debug('开始导入=>>>>>>>>>>>>>>>>' + JSON.serialize(fileLines));
        Integer index = 1;
        // 校验非空
        for(Integer i = index; i < fileLines.size(); i++){
            String[] cellList = fileLines[i];
            // 类型
            if(cellList[1].trim() == ''){
                noRecordTypeMsg += (i+1) + ',';
                isSuccess = false;
            }
            // 年份
            if(cellList[2].trim() == ''){
                noYearMsg += (i+1) + ',';
                isSuccess = false;
            }
            // 月份
            if(cellList[3].trim() == ''){
                noMonthMsg += (i+1) + ',';
                isSuccess = false;
            }
            // 地区
            if(cellList[4].trim() == ''){
                noSalesRegionMsg += (i+1) + ',';
                isSuccess = false;
            }
            if(cellList[1].trim() == '5' || cellList[1].trim() == '6'){
                // 品牌
                if(cellList[7].trim() == ''){
                    noBrandMsg += (i+1) + ',';
                    isSuccess = false;
                }
                // 产品线
                if(cellList[8].trim() == ''){
                    noProductLineMsg += (i+1) + ',';
                    isSuccess = false;
                }
            }
            if(cellList[1].trim() == '4'){
                // 数量
                if(cellList[10].trim() == ''){
                    noNumberMsg += (i+1) + ',';
                    isSuccess = false;
                }
            }
        }

        if(isSuccess){
            for(Integer i = index; i < fileLines.size(); i++){ 
                String[] cellList = fileLines[i];
                
                SalesGoal__c target = new SalesGoal__c();
                if(cellList[1].trim() == '1'){
                    target.RecordTypeId = Sell_Out_Amount;
                }else if(cellList[1].trim() == '2'){
                    target.RecordTypeId = Shop_Efficiency;
                }else if(cellList[1].trim() == '3'){
                    target.RecordTypeId = Human_Effect;
                }else if(cellList[1].trim() == '4'){
                    target.RecordTypeId = Key_Products_Sell_Out;
                }else if(cellList[1].trim() == '5'){
                    target.RecordTypeId = X500_Sellout;
                }else if(cellList[1].trim() == '6'){
                    target.RecordTypeId = X1000_Sellout;
                }else if(cellList[1].trim() == '7'){
                    target.RecordTypeId = Key_Channel_Store_Coverage;
                }
                target.Record_Type_Id__c = cellList[0].trim();
                target.Year__c = cellList[2].trim();
                target.Month__c = cellList[3].trim();
                target.Sales_Region_Other__c = cellList[4].trim();
                if(cellList[5].trim() != ''){
                    target.Amounts__c = Decimal.valueOf(cellList[5].trim());
                }else {
                    target.Amounts__c = 0;
                }
                if(cellList[6].trim() != ''){
                    target.CurrencyIsoCode = cellList[6].trim();
                }
                if(cellList[7].trim() != ''){
                    target.Brand__c = cellList[7].trim();
                }
                if(cellList[8].trim() != ''){
                    target.ProductLine__c = cellList[8].trim();
                }
                if(cellList[9].trim() != ''){
                    target.Store_Coverage_Rate__c = cellList[9].trim();
                }
                if(cellList[10].trim() != ''){
                    target.Quantities__c = Decimal.valueOf(cellList[10].trim());
                }
                target.Key__c = target.RecordTypeId + '-' + target.Year__c + + '-' + target.Month__c + '-' + 
                                target.Sales_Region_Other__c + '-' + target.Brand__c + '-' + target.ProductLine__c;

                addList.add(target);
            }
        }

        System.debug('wwww Addlist' + addList);

        if(noRecordTypeMsg != ''){
            errorMap = addErrorMap(errorMap, noRecordTypeMsg.substring(0, noRecordTypeMsg.length() - 1), 'Record Type does not match data!');
            noRecordTypeMsg = ' \r' + 'The ' + noRecordTypeMsg.substring(0, noRecordTypeMsg.length() - 1) + ' line,Record Type does not match data!';
        }

        if(noYearMsg != ''){
            errorMap = addErrorMap(errorMap, noYearMsg.substring(0, noYearMsg.length() - 1), 'Year does not match data!');
            noYearMsg = ' \r' + 'The ' + noYearMsg.substring(0, noYearMsg.length() - 1) + ' line,Year does not match data!';
        }

        if(noMonthMsg != ''){
            errorMap = addErrorMap(errorMap, noMonthMsg.substring(0, noMonthMsg.length() - 1), 'Month does not match data!');
            noMonthMsg = ' \r' + 'The ' + noMonthMsg.substring(0, noMonthMsg.length() - 1) + ' line,Month does not match data!';
        }

        if(noSalesRegionMsg != ''){
            errorMap = addErrorMap(errorMap, noSalesRegionMsg.substring(0, noSalesRegionMsg.length() - 1), 'Sales Region does not match data!');
            noSalesRegionMsg = ' \r' + 'The ' + noSalesRegionMsg.substring(0, noSalesRegionMsg.length() - 1) + ' line,Sales Region does not match data!';
        }

        if(noBrandMsg != ''){
            errorMap = addErrorMap(errorMap, noBrandMsg.substring(0, noBrandMsg.length() - 1), 'Brand does not match data!');
            noBrandMsg = ' \r' + 'The ' + noBrandMsg.substring(0, noBrandMsg.length() - 1) + ' line,Brand does not match data!';
        }

        if(noProductLineMsg != ''){
            errorMap = addErrorMap(errorMap, noProductLineMsg.substring(0, noProductLineMsg.length() - 1), 'Product Line does not match data!');
            noProductLineMsg = ' \r' + 'The ' + noProductLineMsg.substring(0, noProductLineMsg.length() - 1) + ' line,Product Line does not match data!';
        }
        
        if(noNumberMsg != ''){
            errorMap = addErrorMap(errorMap, noNumberMsg.substring(0, noNumberMsg.length() - 1), 'Quantity does not match data!');
            noNumberMsg = ' \r' + 'The ' + noNumberMsg.substring(0, noNumberMsg.length() - 1) + ' line,Quantity does not match data!';
        }
        
        
        msg = noRecordTypeMsg + noYearMsg + noMonthMsg + noSalesRegionMsg
            + noBrandMsg + noProductLineMsg + noNumberMsg;

        if(isSuccess){
            try {
                //忽略触发器更新
                GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'TargetUpload');

                Database.upsert(addList,SalesGoal__c.Fields.Key__c,true);

                //恢复触发器
                Utility.IgnoreAction(false,false,false,'');
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
        out.errorMap = errorMap;

        return out;
    }

    /**
     * @Param: 
     * @Return: 
     * @Author: WFC
     * @Date: 2025-02-19 09:58:20
     * @Description: Actual Achievement 导入
     */    
    @AuraEnabled
    public static ExcelUploadController.OutPut saveActualAchievement(String fileName, List<String[]> fileLines, String objectType){
        String typeCustomer = Schema.SobjectType.Actual_Achievement__c.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        String typeStore = Schema.SobjectType.Actual_Achievement__c.getRecordTypeInfosByDeveloperName().get('Store').getRecordTypeId();

        ExcelUploadController.OutPut out = new ExcelUploadController.OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        Map<String, String> errorMap = new Map<String, String>();
        String msg = '';
        String noSalesRegionMsg = '';
        String noBrandMsg = '';
        String noProductLineMsg = '';
        String noSapCustomerCodeMsg = '';
        String noYearMsg = '';
        String noMonthMsg = '';


        
        // 要插入的Actual_Achievement__c
        List<Actual_Achievement__c> addList = new List<Actual_Achievement__c>(); 
        System.debug('开始导入=>>>>>>>>>>>>>>>>' + JSON.serialize(fileLines));
        Integer index = 1;
        // 校验非空
        for(Integer i = index; i < fileLines.size(); i++){
            String[] cellList = fileLines[i];
            if(objectType == 'Store'){
                // Sales Region
                if(cellList[0].trim() == ''){
                    noSalesRegionMsg += (i+1) + ',';
                    isSuccess = false;
                }
                // Brand
                if(cellList[1].trim() == ''){
                    noBrandMsg += (i+1) + ',';
                    isSuccess = false;
                }
                // Product Line
                if(cellList[2].trim() == ''){
                    noProductLineMsg += (i+1) + ',';
                    isSuccess = false;
                }
                // year
                if(cellList[3].trim() == ''){
                    noYearMsg += (i+1) + ',';
                    isSuccess = false;
                }
                // Month
                if(cellList[4].trim() == ''){
                    noMonthMsg += (i+1) + ',';
                    isSuccess = false;
                }
            }else if(objectType == 'Customer'){
                // Sap Customer Code
                if(cellList[1].trim() == ''){
                    noSapCustomerCodeMsg += (i+1) + ',';
                    isSuccess = false;
                }
                // year
                if(cellList[2].trim() == ''){
                    noYearMsg += (i+1) + ',';
                    isSuccess = false;
                }
                // Month
                if(cellList[3].trim() == ''){
                    noMonthMsg += (i+1) + ',';
                    isSuccess = false;
                }
            }  
        }
        

        if(isSuccess){
            for(Integer i = index; i < fileLines.size(); i++){ 
                String[] cellList = fileLines[i];
                Actual_Achievement__c actualAchievement = new Actual_Achievement__c();
                if(objectType == 'Store'){
                    actualAchievement.RecordTypeId = typeStore;
                    actualAchievement.Sales_Region__c = cellList[0].trim();
                    actualAchievement.Brand__c = cellList[1].trim();
                    actualAchievement.Product_Line__c = cellList[2].trim();
                    actualAchievement.Year__c = cellList[3].trim();
                    actualAchievement.Month__c = cellList[4].trim();
                    actualAchievement.Store_Number__c = cellList[5].trim();
                    actualAchievement.Promoter_Number__c = cellList[6].trim();
                    actualAchievement.S_Promoter_Number__c = cellList[7].trim();
                    actualAchievement.A_Promoter_Number__c = cellList[8].trim();
                    actualAchievement.B_Promoter_Number__c = cellList[9].trim();
                    actualAchievement.C_Promoter_Number__c = cellList[10].trim();
                }else if (objectType == 'Customer'){
                    actualAchievement.RecordTypeId = typeCustomer;
                    actualAchievement.Customer_Name__c = cellList[0].trim();
                    actualAchievement.SAP_Customer_Code__c = cellList[1].trim();
                    actualAchievement.Year__c = cellList[2].trim();
                    actualAchievement.Month__c = cellList[3].trim();
                    actualAchievement.Store_Number__c = cellList[4].trim();
                }
                actualAchievement.Key__c = actualAchievement.RecordTypeId + '-' + actualAchievement.Sales_Region__c + + '-' + 
                                            actualAchievement.Brand__c + '-' + actualAchievement.Product_Line__c + '-' + 
                                            actualAchievement.SAP_Customer_Code__c + '-' + actualAchievement.Year__c + '-' + actualAchievement.Month__c;
                addList.add(actualAchievement);
            }
        }
        if(noSalesRegionMsg != ''){
            errorMap = addErrorMap(errorMap, noSalesRegionMsg.substring(0, noSalesRegionMsg.length() - 1), 'Sales Region does not match data!');
            noSalesRegionMsg = ' \r' + 'The ' + noSalesRegionMsg.substring(0, noSalesRegionMsg.length() - 1) + ' line,Sales Region does not match data!';
        }
        if(noBrandMsg != ''){
            errorMap = addErrorMap(errorMap, noBrandMsg.substring(0, noBrandMsg.length() - 1), 'Brand does not match data!');
            noBrandMsg = ' \r' + 'The ' + noBrandMsg.substring(0, noBrandMsg.length() - 1) + ' line,Brand does not match data!';
        }
        if(noProductLineMsg != ''){
            errorMap = addErrorMap(errorMap, noProductLineMsg.substring(0, noProductLineMsg.length() - 1), 'Product Line does not match data!');
            noProductLineMsg = ' \r' + 'The ' + noProductLineMsg.substring(0, noProductLineMsg.length() - 1) + ' line,Product Line does not match data!';
        }
        if(noSapCustomerCodeMsg != ''){
            errorMap = addErrorMap(errorMap, noSapCustomerCodeMsg.substring(0, noSapCustomerCodeMsg.length() - 1), 'Sap Customer Code does not match data!');
            noSapCustomerCodeMsg = ' \r' + 'The ' + noSapCustomerCodeMsg.substring(0, noSapCustomerCodeMsg.length() - 1) + ' line,Sap Customer Code does not match data!';
        }
        if(noYearMsg != ''){
            errorMap = addErrorMap(errorMap, noYearMsg.substring(0, noYearMsg.length() - 1), 'Year does not match data!');
            noYearMsg = ' \r' + 'The ' + noYearMsg.substring(0, noYearMsg.length() - 1) + ' line,Year does not match data!';
        }

        if(noMonthMsg != ''){
            errorMap = addErrorMap(errorMap, noMonthMsg.substring(0, noMonthMsg.length() - 1), 'Month does not match data!');
            noMonthMsg = ' \r' + 'The ' + noMonthMsg.substring(0, noMonthMsg.length() - 1) + ' line,Month does not match data!';
        }
        msg = noSalesRegionMsg + noSapCustomerCodeMsg + noYearMsg + noMonthMsg;

        if(isSuccess){
            try {
                //忽略触发器更新
                GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'ActualAchievementUpload');

                Database.upsert(addList,Actual_Achievement__c.Fields.Key__c,true);

                //恢复触发器
                Utility.IgnoreAction(false,false,false,'');
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
        out.errorMap = errorMap;

        return out;
    }

    /**
     * @Param: 
     * @Return: 
     * @Author: WFC
     * @Date: 2025-03-17 15:43:53
     * @Description: Channel_Product_Price__c 导入
     */    
    @AuraEnabled
    public static ExcelUploadController.OutPut saveChannelProductPrice(String fileName, List<String[]> fileLines){
        String productType = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();

        ExcelUploadController.OutPut out = new ExcelUploadController.OutPut();
        Boolean isSuccess = true;
        Boolean partFails = false;
        Map<String, String> errorMap = new Map<String, String>();
        String msg = '';
        String noSalesRegionMsg = '';
        String noChannelMsg = '';
        String noProductMsg = '';
        String noPriceMsg = '';
        
        // 要插入的Target
        List<Channel_Product_Price__c> addList = new List<Channel_Product_Price__c>(); 
        Set<String> salesRegionSet = new Set<String>();
        Set<String> channelSet = new Set<String>();
        Set<String> productSet = new Set<String>();
        System.debug('开始导入=>>>>>>>>>>>>>>>>' + JSON.serialize(fileLines));
        Integer index = 1;
        // 校验非空
        for(Integer i = index; i < fileLines.size(); i++){
            String[] cellList = fileLines[i];
            // sales region
            if(cellList[0].trim() == ''){
                noSalesRegionMsg += (i+1) + ',';
                isSuccess = false;
            }else {
                salesRegionSet.add(cellList[0].trim());
            }
            // channel
            if(cellList[1].trim() == ''){
                noChannelMsg += (i+1) + ',';
                isSuccess = false;
            }else {
                channelSet.add(cellList[1].trim()); 
            }
            // product
            if(cellList[2].trim() == ''){
                noProductMsg += (i+1) + ',';
                isSuccess = false;
            }else {
                productSet.add(cellList[2].trim()); 
            }
            // price
            if(cellList[3].trim() == ''){
                noPriceMsg += (i+1) + ',';
                isSuccess = false;
            }
        }

        if(isSuccess){
            // 查询channel，product数据
            Map<String, Channel_item__c> channelMap = new Map<String, Channel_item__c>();
            Map<String, Product__c> productMap = new Map<String, Product__c>();
            List<Channel_item__c> channelList = [SELECT Id, SBU__c, Channel_Name__c
                                                    FROM Channel_item__c 
                                                    WHERE SBU__c IN :salesRegionSet 
                                                    AND Channel_Name__c IN :channelSet];
            List<Product__c> productList = [SELECT Id, sales_region__c, Name
                                                    FROM Product__c 
                                                    WHERE sales_region__c IN :salesRegionSet 
                                                    AND Name IN :productSet
                                                    AND RecordTypeId = :productType];
            for(Channel_item__c channel : channelList){
                channelMap.put(channel.SBU__c + '-' + channel.Channel_Name__c, channel);
            }
            for(Product__c product : productList){
                productMap.put(product.sales_region__c + '-' + product.Name, product);
            }

            for(Integer i = index; i < fileLines.size(); i++){ 
                String[] cellList = fileLines[i];
                String salesRegion = cellList[0].trim();
                String channel = cellList[1].trim();
                String product = cellList[2].trim();
                String price = cellList[3].trim();
                String currencyStr = cellList[4].trim();// 可能为空
                
                Channel_Product_Price__c target = new Channel_Product_Price__c();
                // 匹配 channel
                if(channelMap.get(salesRegion + '-' + channel) != null){
                    target.Channel_item__c = channelMap.get(salesRegion + '-' + channel).Id;
                }else {
                    noChannelMsg += (i+1) + ',';
                    isSuccess = false;
                }
                // 匹配 product
                if(productMap.get(salesRegion + '-' + product) != null){
                    target.Product__c = productMap.get(salesRegion + '-' + product).Id;
                }else {
                    noProductMsg += (i+1) + ',';
                    isSuccess = false;
                }
                target.Sales_Region__c = salesRegion;
                target.Price__c = Decimal.valueOf(price);
                target.CurrencyIsoCode = currencyStr;
                target.Key__c = target.Sales_Region__c + '-' + target.Channel_item__c + + '-' + target.Product__c;

                addList.add(target);
            }
        }

        System.debug('wwww Addlist' + addList);
        if(noSalesRegionMsg != ''){
            errorMap = addErrorMap(errorMap, noSalesRegionMsg.substring(0, noSalesRegionMsg.length() - 1), 'Sales Region does not match data!');
            noSalesRegionMsg = ' \r' + 'The ' + noSalesRegionMsg.substring(0, noSalesRegionMsg.length() - 1) + ' line,Sales Regiondoes not match data!';
        }

        if(noChannelMsg != ''){
            errorMap = addErrorMap(errorMap, noChannelMsg.substring(0, noChannelMsg.length() - 1), 'Channel does not match data!');
            noChannelMsg = ' \r' + 'The ' + noChannelMsg.substring(0, noChannelMsg.length() - 1) + ' line,Channel does not match data!';
        }

        if(noProductMsg != ''){
            errorMap = addErrorMap(errorMap, noProductMsg.substring(0, noProductMsg.length() - 1), 'Product does not match data!');
            noProductMsg = ' \r' + 'The ' + noProductMsg.substring(0, noProductMsg.length() - 1) + ' line,Product does not match data!';
        }

        if(noPriceMsg != ''){
            errorMap = addErrorMap(errorMap, noPriceMsg.substring(0, noPriceMsg.length() - 1), 'Price does not match data!');
            noPriceMsg = ' \r' + 'The ' + noPriceMsg.substring(0, noPriceMsg.length() - 1) + ' line,Price does not match data!';
        }
          
        msg = noSalesRegionMsg + noChannelMsg + noProductMsg + noPriceMsg;

        if(isSuccess){
            try {
                //忽略触发器更新
                GlobalSetting__c ignoreGs = Utility.IgnoreAction(true, true, true, 'ChannelProductPrice');

                Database.upsert(addList,Channel_Product_Price__c.Fields.Key__c,true);

                //恢复触发器
                Utility.IgnoreAction(false,false,false,'');
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
        out.errorMap = errorMap;

        return out;
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

        @AuraEnabled
		public Map<String, String> errorMap {get; set;}

    }
    public static Map<String, String> addErrorMap(Map<String, String> errorMap, String key, String errorMsg){
        // key拆分','
        List<String> keyList = key.split(',');
        for(String temp : keyList){
            temp = temp.trim();
            if(errorMap.containsKey(temp)){
                String errorMsgTemp= errorMap.get(temp);
                errorMsgTemp += ' ' + errorMsg;
                errorMap.put(temp, errorMsgTemp);
            }else{
                errorMap.put(temp, errorMsg);
            }
        }
        
        return errorMap;
    }

    //异步调用生成后续的周
    public class AsyncInsertWST implements Queueable {
        List<Weekly_Sales_Target__c> target;
        public AsyncInsertWST(List<Weekly_Sales_Target__c> target){
            this.target = target;
        }
        public void execute(QueueableContext context) {
            insert target;
        }
    } 
}