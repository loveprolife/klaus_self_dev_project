/**
 * @description Apex controller for FileUpload LWC: fetch thumbnails of files linked to a record and allow deleting links/files created in this session.
 * Runs operations in USER_MODE and enforces sharing and FLS where applicable.
 */
public with sharing class FileUploadController {

    public class FileInfo {
        @AuraEnabled public Id contentDocumentId;
        @AuraEnabled public Id contentVersionId;
        @AuraEnabled public Id contentDocumentLinkId;
        @AuraEnabled public Id contentBodyId;
        @AuraEnabled public String title;
        @AuraEnabled public String fileType;
        @AuraEnabled public String fileExtension;
        @AuraEnabled public String smallThumbnailUrl;
        @AuraEnabled public String largeThumbnailUrl;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public String createdByName;
        @AuraEnabled public Boolean deletable;
    }

    /**
     * @description Get files (ContentDocuments) linked to a record with thumbnails.
     * Only returns image/* by default to fit use case.
     */
    @AuraEnabled
    public static List<FileInfo> getRecordFiles(Id recordId) {
        if (recordId == null) {
            return new List<FileInfo>();
        }

        // Query latest content version per document linked to the record
        // Enforce security with WITH SHARING on class and WITH SECURITY_ENFORCED on fields
        List<ContentDocumentLink> links = [
            SELECT Id, ContentDocumentId, LinkedEntityId,
                ContentDocument.LatestPublishedVersionId,
                ContentDocument.Title,
                ContentDocument.FileType,
                ContentDocument.FileExtension,
                ContentDocument.CreatedDate,
                ContentDocument.CreatedBy.Name
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
            WITH SECURITY_ENFORCED
            ORDER BY ContentDocument.CreatedDate DESC
            LIMIT 200
        ];

        Set<Id> versionIds = new Set<Id>();
        Map<Id, ContentDocumentLink> cdlByDoc = new Map<Id, ContentDocumentLink>();
        for (ContentDocumentLink l : links) {
            cdlByDoc.put(l.ContentDocumentId, l);
            if (l.ContentDocument.LatestPublishedVersionId != null) {
                versionIds.add(l.ContentDocument.LatestPublishedVersionId);
            }
        }
        if (versionIds.isEmpty()) {
            return new List<FileInfo>();
        }

        // Fetch versions with thumbnails; filter to images
        Map<Id, ContentVersion> versionsById = new Map<Id, ContentVersion>([
            SELECT Id, ContentDocumentId, Title, FileType, ContentBodyId,
                   CreatedDate, CreatedBy.Name,
                   FileExtension,
                   VersionNumber,
                   ContentSize,
                   IsLatest
            FROM ContentVersion
            WHERE Id IN :versionIds AND FileType IN ('PNG','JPG','JPEG','GIF','BMP','TIFF','HEIC','WEBP')
            WITH SECURITY_ENFORCED
        ]);

        List<FileInfo> result = new List<FileInfo>();
        for (ContentDocumentLink l : links) {
            Id vId = l.ContentDocument.LatestPublishedVersionId;
            if (versionsById.containsKey(vId)) {
                ContentVersion v = versionsById.get(vId);
                FileInfo fi = new FileInfo();
                fi.contentDocumentId = l.ContentDocumentId;
                fi.contentVersionId = v.Id;
                fi.contentDocumentLinkId = l.Id;
                fi.contentBodyId = v.ContentBodyId;
                fi.title = v.Title;
                fi.fileType = v.FileType;
                fi.fileExtension = v.FileExtension;
                fi.createdDate = v.CreatedDate;
                fi.createdByName = v.CreatedBy != null ? v.CreatedBy.Name : null;
                // Indicate deletable; server enforces again on delete
                fi.deletable = true;
                // Thumbnail URLs will be composed on client using contentVersionId
                fi.smallThumbnailUrl = null;
                fi.largeThumbnailUrl = null;
                result.add(fi);
            }
        }
        return result;
    }

    public class DeleteRequest {
        @AuraEnabled public String contentDocumentId;
        @AuraEnabled public String contentDocumentLinkId;
        @AuraEnabled public String recordId;
    }
    public class DeleteResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
    }

    /**
     * @description Delete the ContentDocumentLink to the record; if the document has no more links, delete the document as well.
     * Runs in USER_MODE to respect user permissions.
     */
    @AuraEnabled
    public static DeleteResponse deleteFileLink(String contentDocumentId, String contentDocumentLinkId, String recordId) {
        DeleteResponse resp = new DeleteResponse();
        if (String.valueOf(contentDocumentLinkId).trim() == '') {
            resp.success = false;
            resp.message = 'Missing ContentDocumentLink Id';
            return resp;
        }
        try {
            // Validate the link belongs to the provided record (if provided)
            // 兼容社区/移动端可能传入字符串 Id 的情况
            Id linkIdToUse = (Id) contentDocumentLinkId;
            ContentDocumentLink cdl = [
                SELECT Id, ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE Id = :linkIdToUse
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            if (cdl.LinkedEntityId != recordId) {
                resp.success = false;
                resp.message = 'Link does not belong to the specified record';
                return resp;
            }

            // Delete link in USER_MODE
            Database.DeleteResult dr = Database.delete(cdl, AccessLevel.USER_MODE);
            if (!dr.isSuccess()) {
                resp.success = false;
                resp.message = dr.getErrors().isEmpty() ? 'Delete failed' : dr.getErrors()[0].getMessage();
                return resp;
            }

            // If no other links exist, try delete the document (user must have permission)
            Integer remaining = [SELECT COUNT() FROM ContentDocumentLink WHERE ContentDocumentId = :cdl.ContentDocumentId];
            if (remaining == 0) {
                Database.DeleteResult dDoc = Database.delete(new ContentDocument(Id = cdl.ContentDocumentId), AccessLevel.USER_MODE);
                // If fails, ignore; link removal already done
            }

            resp.success = true;
            resp.message = 'Deleted';
            return resp;
        } catch (Exception e) {
            resp.success = false;
            resp.message = e.getMessage();
            return resp;
        }
    }
}