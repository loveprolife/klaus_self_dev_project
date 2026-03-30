/*
 * @Author: WFC
 * @Date: 2024-04-23 14:01:44
 * @LastEditors: WFC
 * @LastEditTime: 2024-05-28 17:09:43
 * @Description:
 * @FilePath: \HisenseAll20240426\force-app\main\default\classes\TrainingDocumentController.cls
 */
public without sharing class TrainingDocumentController{
    // 查询Author Email
    @AuraEnabled
    public static Map<String, Object> checkAuthorEmail(String authorEmail){
        Map<String, Object> resultMap = new Map<String, Object>();
        List<User> userList = [SELECT Id, Name, FullPhotoUrl
                               FROM User
                               WHERE Username = :authorEmail AND IsActive = true];
        if (userList != null && userList.size() > 0){
            resultMap.put('isSuccess', true);
            resultMap.put('author', userList[0].Name);
            resultMap.put('photoUrl', userList[0].FullPhotoUrl);
        } else{
            resultMap.put('isSuccess', false);
        }
        return resultMap;
    }

    // 点击修改，查询Extra Person
    @AuraEnabled
    public static List<User> editExtrPerson(Id recordId){
        Learning_Platform_Management__c lpm = [SELECT Id, Extra_Person__c
                                               FROM Learning_Platform_Management__c
                                               WHERE Id = :recordId
                                               LIMIT 1];
        if (String.isNotBlank(lpm.Extra_Person__c)){
            List<String> usernameList = lpm.Extra_Person__c.split(',');
            List<User> userList = [SELECT Id, Username, FullPhotoUrl
                                   FROM User
                                   WHERE Username IN:usernameList];
            return userList;
        } else{
            return null;
        }
    }

    // 获取资料库数据
    @AuraEnabled
    public static Map<String, Object> getLearningData(String title, String type, String author, String startDate, String endDate, String allowDownload){
        System.debug('wwww-----' + title);
        System.debug('wwww-----' + type);
        System.debug('wwww-----' + author);
        System.debug('wwww-----' + startDate);
        System.debug('wwww-----' + endDate);
        System.debug('wwww-----' + allowDownload);
        Map<String, Object> result = new Map<String, Object>();
        String sql = 'SELECT Id, Name, Type__c, Author__c, Upload_Date__c, Allow_Download__c, Sales_Region__c, Person_Type__c, Extra_Person__c FROM Learning_Platform_Management__c WHERE Id != null ';
        if (String.isNotBlank(title)){
            sql += ' AND Name LIKE \'%' + title + '%\'';
        }
        if (String.isNotBlank(type) ){
            sql += ' AND Type__c = \'' + type + '\'';
        }
        if (String.isNotBlank(author)){
            sql += ' AND Author__c LIKE \'%' + author + '%\'';
        }
        if (String.isNotBlank(startDate)){
            sql += ' AND Upload_Date__c >=' + startDate;
        }
        if (String.isNotBlank(endDate)){
            sql += ' AND Upload_Date__c <=' + endDate;
        }
        if (String.isNotBlank(allowDownload)){
            sql += ' AND Allow_Download__c = ' + allowDownload;
        }
        List<Learning_Platform_Management__c> lpmList = Database.query(sql + ' ORDER BY Upload_Date__c DESC');
        List<Learning_Platform_Management__c> lpm = new List<Learning_Platform_Management__c>();
        if (lpmList != null && lpmList.size() > 0){
            result.put('flag', true);
            // 当前用户数据
            User u = UserUtility.currentUser;
            // 过滤数据
            for (Learning_Platform_Management__c learning : lpmList){
                String salesRegion = learning.Sales_Region__c + '';
                String personType = learning.Person_Type__c + '';
                String extraPerson = learning.Extra_Person__c + '';
                // 是否是特殊用户
                if (extraPerson.contains(u.Username + '')){
                    lpm.add(learning);
                    continue;
                }
                // sales region是否满足条件，不满足直接跳过
                if (!salesRegion.contains(u.Sales_Region__c + '')){
                    continue;
                }
                // person type是否包含
                String[] dataTypeList = personType.split(';');
                String[] uTypeList = (u.Role_Type__c + '').split(';');
                for (String str : dataTypeList){
                    if (uTypeList.contains(str)){
                        lpm.add(learning);
                        break;
                    }
                }
            }
        } else{
            result.put('flag', false);
        }
        result.put('data', lpm);
        return result;
    }

    // // 查询文件信息
    // @AuraEnabled
    // public static ContentDocumentLink getRecordFile(Id recordId){
    //     List<ContentDocumentLink> attachedDocuments = [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.ContentSize, ContentDocument.FileType, ContentDocument.FileExtension
    //                                                    FROM ContentDocumentLink
    //                                                    WHERE LinkedEntityId = :recordId
    //                                                    WITH SECURITY_ENFORCED
    //                                                    ORDER BY ContentDocument.LastModifiedDate DESC];
    //     if (attachedDocuments != null && attachedDocuments.size() > 0){
    //         return attachedDocuments[0];
    //     } else{
    //         return null;
    //     }
    // }
    @AuraEnabled
    public static Map<String, Object> checkUploadExtraPerson(String fileName, String base64Data){
        Map<String, Object> resultMap = new Map<String, Object>();
        List<User> rightUser = new List<User>();
        List<String> wrongUser = new List<String>();

        // 解析csv
        base64Data = EncodingUtil.urlDecode(base64Data, 'gb2312');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = bitToString(contentBlob, 'gb2312');
        content = content.replaceAll('\r\n', '\n');
        content = content.replaceAll('\r', '\n');
        List<String> fileLines = content.trim().split('\n');

        Map<String, String> usernameMap = new Map<String, String>();
        Map<String, User> usernameHaveMap = new Map<String, User>();
        for (Integer i = 0; i < fileLines.size(); i++){
            String fileLine = fileLines[i].trim();
            if (String.isNotBlank(fileLine)){
                usernameMap.put(fileLine, fileLine);
            }
        }
        //check username
        List<User> checkUserList = [SELECT Id, Username, FullPhotoUrl
                                    FROM User
                                    WHERE IsActive = TRUE AND Username IN:usernameMap.keySet()];
        for (User u : checkUserList){
            usernameHaveMap.put(u.Username, u);
        }

        for (String username : usernameMap.keySet()){
            if (usernameHaveMap.get(username) != null){
                rightUser.add(usernameHaveMap.get(username));
            } else{
                wrongUser.add(username);
            }
        }

        resultMap.put('rightUser', rightUser);
        resultMap.put('wrongUser', wrongUser);
        return resultMap;
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