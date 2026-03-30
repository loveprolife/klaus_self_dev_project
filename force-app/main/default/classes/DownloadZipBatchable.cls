/*
 * @Author: WFC
 * @Date: 2024-09-19 16:31:13
 * @LastEditors: WFC
 * @LastEditTime: 2024-10-08 15:46:23
 * @Description: DownloadZipBatchable dz  = new DownloadZipBatchable();
 Database.executeBatch(dz);
 * @Controller: HexUtil, Puff, Zippex
 * @FilePath: \HisenseAll20240426\force-app\main\default\classes\DownloadZipBatchable.cls
 */
public class DownloadZipBatchable implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
    // public String zipName = 'DownloadZip.zip';
    public Integer zipNameNo = 1;
    public Zippex zip = new Zippex();
    public List<String> checkResultIdList;
    public String query;
    public String key;
    integer m = 0;
    public DownloadZipBatchable(List<String> checkResultIdList, String key){
        this.checkResultIdList = checkResultIdList;
        this.key = key;
        this.query = ' SELECT Id, ContentDocument.LatestPublishedVersion.VersionData, LinkedEntityId, ' + 
                 ' ContentDocument.LatestPublishedVersion.PathOnClient,ContentDocument.ContentSize ' + 
                 ' FROM ContentDocumentLink ' + 
                 ' WHERE LinkedEntityId IN :checkResultIdList';
    }

    public Iterable<SObject> start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<ContentDocumentLink> docList){
        integer n = Integer.valueOf(System.Label.DownloadZipNumber);
        // 文件夹
        String prefixFolder = '';
        // 查询相关数据信息
        List<CheckResult__c> crList = [SELECT Id, InspectorDailyReport__r.Report_Date__c, InspectorDailyReport__r.Store__r.name
                                       FROM CheckResult__c
                                       WHERE Id IN:checkResultIdList];
        LisqContainer checkResultListLc = new LisqContainer(crList);
        Map<String, SObject> checkResultMap = checkResultListLc.ToMapS('Id');

        for (ContentDocumentLink cv : docList){
            if (cv.ContentDocument.ContentSize > 1500000){
                continue;
            }
            CheckResult__c cr = (CheckResult__c) checkResultMap.get(cv.LinkedEntityId);
            prefixFolder = cr.InspectorDailyReport__r.Store__r.name + '/' + cr.InspectorDailyReport__r.Report_Date__c + '/';

            String fileName = cv.ContentDocument.LatestPublishedVersion.PathOnClient;

            Integer b = 0;
            Integer crc = -1;
            String hexStr = EncodingUtil.convertToHex(cv.ContentDocument.LatestPublishedVersion.VersionData);
            Integer size = hexStr.length();


            for (Integer i = 0; i < size; i += 2){
                b = ((hexStr.charAt(i) & 15) + (hexStr.charAt(i) >>> 6) * 9) * 16 | (hexStr.charAt(i + 1) & 15) + (hexStr.charAt(i + 1) >>> 6) * 9;
                crc = (crc >>> 8) ^ HexUtil.table[(crc ^ b) & 255];
            }
            crc = crc ^ -1;
            zip.addFile(prefixFolder + fileName, cv.ContentDocument.LatestPublishedVersion.VersionData, HexUtil.intToHexLE(crc, 4));

            m++;
            if (m >= n || Test.isRunningTest()){
                try{
                    // Document d = new Document();
                    // d.folderid = UserInfo.getUserId();
                    // d.Name = 'DownloadZip-' + zipNameNo + '.zip';
                    // d.body = zip.getZipArchive();
                    // d.Keywords = key;
                    // insert d;
                    ContentVersion contentVersion = new ContentVersion(
                        Title = 'DownloadZip-' + zipNameNo, 
                        PathOnClient = 'DownloadZip-' + zipNameNo + '.zip', 
                        VersionData = zip.getZipArchive(), 
                        IsMajorVersion = true, 
                        Download_Key__c = key
                    );
                    insert contentVersion;
                    zip = new Zippex();
                    m = 0;
                    zipNameNo++;
                } catch (Exception ex){

                }
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        try{
            if (m > 0 || Test.isRunningTest()){
                // Document d = new Document();
                // d.folderid = UserInfo.getUserId();
                // d.Name = 'DownloadZip-' + zipNameNo + '.zip';
                // d.body = zip.getZipArchive();
                // d.Keywords = key;
                // insert d;
                ContentVersion contentVersion = new ContentVersion(
                    Title = 'DownloadZip-' + zipNameNo, 
                    PathOnClient = 'DownloadZip-' + zipNameNo + '.zip', 
                    VersionData = zip.getZipArchive(), 
                    IsMajorVersion = true, 
                    Download_Key__c = key
                );
                insert contentVersion;
            }

        } catch (Exception ex){

        }
    }

}