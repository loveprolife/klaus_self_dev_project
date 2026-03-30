public class CombineFileItems implements Queueable {
	
    List<FileItem__c> items;
    private static String itemRecordTypeId = Schema.SObjectType.FileItem__c.getRecordTypeInfosByName().get('Item').getRecordTypeId();
    private static String itemHeadRecordTypeId = Schema.SObjectType.FileItem__c.getRecordTypeInfosByName().get('ItemHead').getRecordTypeId();
    private static Datetime now  = System.now();
    
    public CombineFileItems(List<FileItem__c> items) {
        this.items = items;
    }
    
    public void execute(QueueableContext context) {
        afterInsertHandler(items);
    }
    
    public static void afterInsertHandler(List<FileItem__c> newList) {
        if (newList == null || newList.size() == 0) {
            return;
        }
        System.debug('index=' + newList[0].Index__c);
        LisqContainer allContainer = new LisqContainer(newList);
        // 查询有所有未完成File item
                         
        List<FileItem__c> allList = [SELECT 
                                        Id,
                                        Name,
                                        RecordTypeId,
                                        PackageId__c,
                                        ItemId__c,
                                        RecordId__c,
                                        FileName__c,
                                        Base64__c,
                                        Index__c,
                                        IndexMax__c,
                                        CompleteDateTime__c,
                                        ContentBodyId__c,
                                        ContentVersionId__c,
                                        ContentDocumentId__c
                                    FROM FileItem__c 
                                    WHERE CompleteDateTime__c = null
                                    AND PackageId__c IN : (allContainer.selectSField('PackageId__c'))
                                    AND PackageId__c != null
                                    AND Id NOT IN : allContainer.toIds()];
        System.debug('allList size='+ allList.size());                      
        allList.addAll(newList);
        System.debug('allList size2='+ allList.size());                      
        System.debug('allList->'+JSON.serialize(allList));
        allContainer = new LisqContainer(allList);
        Map<String, Sobject> itemHeadMap = allContainer.where1('RecordTypeId', '=', itemHeadRecordTypeId).toMapS('PackageId__c');
        Map<String, LisqContainer> itemListMap = allContainer.where1('RecordTypeId', '=', itemRecordTypeId).GroupByS('PackageId__c');

        Map<String, ContentVersion> packageIdCVMap = new Map<String, ContentVersion>();
        Map<String, FileItem__c> packageIditemHeadMap = new Map<String, FileItem__c>();
        
        Map<String, ContentVersion> packageIdHeadCVMap = new Map<String, ContentVersion>();
        for (String packageId : itemListMap.keySet()) {
            System.debug('packageId->'+packageId);
            LisqContainer lc = itemListMap.get(packageId);
            List<FileItem__c> items = lc.orderBY('Index__c').ToSobjectList();
            if (items.size() > 0) {
                Boolean b_index = true;
                String recordId = null;
                String base64 = '';
                for (Integer i = 0; i < items.size(); i++) {
                    System.debug('items i->'+JSON.serialize(items[i]));
                    if ((i + 1) != Integer.valueOf(items[i].Index__c)) {
                        b_index = false;
                        System.debug('break1->');
                        break;
                    }

                    if (recordId == null && !String.isBlank(items[i].RecordId__c)) {
                        recordId = items[i].RecordId__c;
                    }

                    if (i == 0) {
                        base64 += items[i].Base64__c.subString(items[i].Base64__c.indexOf('base64,') + 7);
                    } else {
                        base64 += items[i].Base64__c;
                    }
                }
                
                if (!b_index || items.size()!=Integer.valueOf(items[0].IndexMax__c)) {
                    System.debug('!b_index->'+!b_index);
                    System.debug('items.size()->'+items.size());
                    System.debug('Integer.valueOf(items[0].IndexMax__c)->'+Integer.valueOf(items[0].IndexMax__c));
                    System.debug('items All->'+JSON.serialize(items));
                    
                    System.debug('break2->');
                    break;
                }

                if (!String.isBlank(recordId)) {
                    
                    System.debug('recordId check->');
                    // 创建contentversion对象 FirstPublishLocationId
                    // 创建Head
                    String filename = items[0].FileName__c;
                    ContentVersion cv = new ContentVersion();
                    cv.VersionData = EncodingUtil.base64Decode(base64);
                    cv.Title = filename.substring(0,filename.lastIndexOf('.'));
                    cv.PathOnClient = items[0].FileName__c;
                    cv.FirstPublishLocationId = items[0].RecordId__c;
                    packageIdCVMap.put(packageId, cv);

                    FileItem__c newitemHead = new FileItem__c();
                    newitemHead.RecordTypeId = itemHeadRecordTypeId;
                    newitemHead.PackageId__c = packageId;
                    newitemHead.ItemId__c = packageId;
                    newitemHead.RecordId__c = items[0].RecordId__c;
                    newitemHead.FileName__c = items[0].FileName__c;
                    newitemHead.IndexMax__c = items[0].IndexMax__c;
                    newitemHead.CompleteDateTime__c = now;
                    packageIditemHeadMap.put(packageId, newitemHead);
                } else if (itemHeadMap.containsKey(packageId)) {
                    // 创建contentversion对象 FirstPublishLocationId
                    System.debug('itemHeadMap check->');
                    String filename = items[0].FileName__c;
                    ContentVersion cv = new ContentVersion();
                    cv.VersionData = EncodingUtil.base64Decode(base64);
                    cv.Title = filename.substring(0,filename.lastIndexOf('.'));
                    cv.PathOnClient = items[0].FileName__c;

                    FileItem__c fiHead = (FileItem__c)itemHeadMap.get(packageId);
                    cv.FirstPublishLocationId = fiHead.RecordId__c;
                    packageIdHeadCVMap.put(packageId, cv);
                } else {
                    
                    System.debug('错误数据->');
                }
            }
        }

        System.debug('packageIdCVMap->'+JSON.serialize(packageIdCVMap));
        System.debug('packageIditemHeadMap->'+JSON.serialize(packageIditemHeadMap));

        Savepoint sp = Database.setSavepoint();
        if (packageIdCVMap.size()>0 && packageIditemHeadMap.size()>0 && packageIdCVMap.size()==packageIditemHeadMap.size()) {
            
            System.debug('合并->');
            insert packageIdCVMap.values();
            Set<String> cvIds = new Set<String>();
            for (ContentVersion cv : packageIdCVMap.values()) {
                cvIds.add(cv.id);
            }
            Map<String, ContentVersion> recordIdCvMap = new Map<String, ContentVersion>();
            for (ContentVersion cv : [SELECT Id,ContentDocumentId,ContentBodyId,FirstPublishLocationId FROM ContentVersion WHERE Id IN : cvIds]) {
                recordIdCvMap.put(cv.FirstPublishLocationId, cv);
            }
            List<FileItem__c> needUpdate = new List<FileItem__c>();
            for (String packageId : packageIditemHeadMap.keyset()) {
                FileItem__c headFi = packageIditemHeadMap.get(packageId);
                headFi.ContentBodyId__c = recordIdCvMap.get(headFi.RecordId__c).ContentBodyId;
                headFi.ContentVersionId__c = recordIdCvMap.get(headFi.RecordId__c).Id;
                headFi.ContentDocumentId__c = recordIdCvMap.get(headFi.RecordId__c).ContentDocumentId;

                // LisqContainer lc = itemListMap.get(packageId);
                // for (SObject fiSobj : lc.ToSobjectList()) {
                //     FileItem__c fi = (FileItem__c)fiSobj;
                //     fi.CompleteDateTime__c = now;
                //     fi.ContentBodyId__c = recordIdCvMap.get(headFi.RecordId__c).ContentBodyId;
                //     fi.ContentVersionId__c = recordIdCvMap.get(headFi.RecordId__c).Id;
                //     fi.ContentDocumentId__c = recordIdCvMap.get(headFi.RecordId__c).ContentDocumentId;
                //     if (String.isNotBlank(fi.Id)) {
                //         needUpdate.add(fi);
                //     }
                // }
            }
            // if (needUpdate.size()>0) {
            //     update needUpdate;
            // }
            try {
                upsert packageIditemHeadMap.values();
            } catch (Exception e) {
                System.debug('error--->'+e.getMessage());
                Database.rollback(sp);
            }
        }

        System.debug('packageIdHeadCVMap->'+JSON.serialize(packageIdHeadCVMap));
        if (packageIdHeadCVMap.size()>0) {
            
            System.debug('合并2->');
            insert packageIdHeadCVMap.values();
            Set<String> cvIds = new Set<String>();
            for (ContentVersion cv : packageIdHeadCVMap.values()) {
                System.debug('cv id->'+cv.id);
                cvIds.add(cv.id);
            }
            System.debug('cv ids->'+JSON.serialize(cvIds));
            Map<String, ContentVersion> recordIdCvMap = new Map<String, ContentVersion>();
            for (ContentVersion cv : [SELECT Id,ContentDocumentId,ContentBodyId,FirstPublishLocationId FROM ContentVersion WHERE Id IN : cvIds]) {
                recordIdCvMap.put(cv.FirstPublishLocationId, cv);
            }
            List<FileItem__c> needUpdate = new List<FileItem__c>();
            for (String packageId : packageIdHeadCVMap.keyset()) {
                FileItem__c headFi = new FileItem__c();
                // headFi = (FileItem__c)itemHeadMap.get(packageId);
                // FileItem__c headFi = (FileItem__c)itemHeadMap.get(packageId);
                FileItem__c oldHeadFi = (FileItem__c)itemHeadMap.get(packageId);
                headFi.Id = oldHeadFi.Id;
                headFi.CompleteDateTime__c = now;
                headFi.ContentBodyId__c = recordIdCvMap.get(oldHeadFi.RecordId__c).ContentBodyId;
                headFi.ContentVersionId__c = recordIdCvMap.get(oldHeadFi.RecordId__c).Id;
                headFi.ContentDocumentId__c = recordIdCvMap.get(oldHeadFi.RecordId__c).ContentDocumentId;
                // if (String.isNotBlank(headFi.Id)) {
                    needUpdate.add(headFi);
                // }

                // LisqContainer lc = itemListMap.get(packageId);
                // for (SObject fiSobj : lc.ToSobjectList()) {
                //     FileItem__c fi = (FileItem__c)fiSobj;
                //     fi.CompleteDateTime__c = now;
                //     fi.ContentBodyId__c = recordIdCvMap.get(headFi.RecordId__c).ContentBodyId;
                //     fi.ContentVersionId__c = recordIdCvMap.get(headFi.RecordId__c).Id;
                //     fi.ContentDocumentId__c = recordIdCvMap.get(headFi.RecordId__c).ContentDocumentId;
                //     if (String.isNotBlank(fi.Id)) {
                //         needUpdate.add(fi);
                //     }
                // }
            }
            if (needUpdate.size()>0) {
                update needUpdate;
            }
        }
    }
}