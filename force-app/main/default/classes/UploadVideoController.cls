/*
 * @Author: WFC
 * @Date: 2023-06-12 10:22:36
 * @LastEditors: WFC
 * @LastEditTime: 2024-05-16 17:59:37
 * @Description:
 * @FilePath: \HisenseAll20240426\force-app\main\default\classes\UploadVideoController.cls
 */
public without sharing class UploadVideoController{
	/**
	 * @description: 培训人员页面自己上传的file
	 * @return {*}
	 */
	@AuraEnabled(cacheable = true)
	public static OutPut getAttachedDocuments(Id recordId){
		try{
			OutPut out = new OutPut();

			List<FileInfo> fileInfoList = new List<FileInfo>();
			fileInfoList = getFileInfoList(recordId);

			out.fileInfoList = fileInfoList;
			out.isSuccess = true;
			return out;
		} catch (Exception e){
			OutPut out = new OutPut();
			out.isSuccess = false;
			return out;
		}
	}

	/**
	 * @description: 培训人员页面展示培训师上传的file
	 * @return {*}
	 */
	@AuraEnabled(cacheable = true)
	public static OutPut getTrainingTaskAttachedDocuments(Id recordId){
		try{
			OutPut out = new OutPut();
			String recordObejectName = recordId.getSobjectType().getDescribe().getName();
			if (recordObejectName == 'Training_Personnel__c'){
				Training_Personnel__c tp = [SELECT Training_Task__c
				                            FROM Training_Personnel__c
				                            WHERE id = :recordId
				                            LIMIT 1];
				recordId = tp.Training_Task__c;
			}

			List<FileInfo> fileInfoList = new List<FileInfo>();
			fileInfoList = getFileInfoList(recordId);

			out.fileInfoList = fileInfoList;
			out.isSuccess = true;
			return out;
		} catch (Exception e){
			OutPut out = new OutPut();
			out.isSuccess = false;
			return out;
		}
	}

	/**
	 * @description: 验证培训任务是否发布，上传过堂视频
	 * @return {*}
	 */
	@AuraEnabled
	public static OutPut verifyPublication(Id recordId){

		OutPut out = new OutPut();
		Training_Personnel__c tp = [SELECT Training_Task__r.Task_Status__c
		                            FROM Training_Personnel__c
		                            WHERE id = :recordId
		                            LIMIT 1];
		out.isSuccess = true;
		if (tp.Training_Task__r.Task_Status__c != '发布'){
			out.isSuccess = false;
			out.msg = '培训任务未发布！';
		}
		return out;
	}

	/**
	 * @description: 删除培训人员上传的file
	 * @return {*}
	 */
	@AuraEnabled
	public static OutPut deleteFile(String deleteFileId){
		try{
			OutPut out = new OutPut();
			List<ContentDocument> delList = [SELECT Id
			                                 FROM ContentDocument
			                                 WHERE Id = :deleteFileId];
			Database.delete (delList);
			out.isSuccess = true;
			return out;
		} catch (Exception e){
			OutPut out = new OutPut();
			out.isSuccess = false;
			return out;
		}
	}

	/**
	 * @description: 培训人员上传file后同步到培训任务user中
	 * @return {*}
	 */
	@AuraEnabled
	public static OutPut saveData(Id recordId){
		try{
			OutPut out = new OutPut();
			List<ContentDocumentLink> addList = new List<ContentDocumentLink>();
			List<ContentDocumentLink> delList = new List<ContentDocumentLink>();
			// 获取上传的video
			List<ContentDocumentLink> attachedDocuments = [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.Description
			                                               FROM ContentDocumentLink
			                                               WHERE LinkedEntityId = :recordId
			                                               WITH SECURITY_ENFORCED
			                                               ORDER BY SystemModstamp];

			// 添加到Training Task User中
			List<Training_Personnel__c> tpList = [SELECT id, Training_Task_User__c
			                                      FROM Training_Personnel__c
			                                      WHERE Id = :recordId
			                                      LIMIT 1];
			if (tpList != null){
				Training_Personnel__c tp = tpList[0];
				for (ContentDocumentLink cdl : attachedDocuments){
					ContentDocumentLink link = new ContentDocumentLink();
					link.ContentDocumentId = cdl.contentdocumentid;
					link.LinkedEntityId = tp.Training_Task_User__c;
					link.ShareType = 'V';
					addList.add(link);
				}
				// 删除Training Task User之前关联的文件
				List<ContentDocumentLink> delAttachedDocuments = [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.Description
				                                                  FROM ContentDocumentLink
				                                                  WHERE LinkedEntityId = :tp.Training_Task_User__c
				                                                  WITH SECURITY_ENFORCED
				                                                  ORDER BY SystemModstamp];
				Database.delete (delAttachedDocuments);
			}
			Database.insert (addList);

			out.isSuccess = true;
			return out;
		} catch (Exception e){
			OutPut out = new OutPut();
			out.isSuccess = false;
			return out;
		}
	}

	/**
	 * @description: 培训人员查看资料，保存详情
	 * @return {*}
	 */
	@AuraEnabled
	public static OutPut saveCheckFileDetail(Id recordId, String contentDocumentId, String contentDocumentTitle, String contentDocumentUrl){
		try{
			OutPut out = new OutPut();
			String recordObejectName = recordId.getSobjectType().getDescribe().getName();
			if (recordObejectName == 'Training_Personnel__c'){
				Training_Personnel__c tp = [SELECT Id, Training_Task__c
				                            FROM Training_Personnel__c
				                            WHERE Id = :recordId
				                            LIMIT 1];

				// 保存查看详情
				Training_Task_File_Detail__c ttfd = new Training_Task_File_Detail__c();
				ttfd.Training_Task__c = tp.Training_Task__c;
				ttfd.Training_Personnel__c = recordId;
				ttfd.User__c = System.UserInfo.getUserId();
				ttfd.See_Time__c = Datetime.now();
				ttfd.File_Title__c = contentDocumentTitle;
				ttfd.Content_Document_Id__c = contentDocumentId;
				ttfd.Content_Document_Url__c = contentDocumentUrl;
				Database.insert (ttfd);
			}
			out.isSuccess = true;
			return out;
		} catch (Exception e){
			OutPut out = new OutPut();
			out.isSuccess = false;
			return out;
		}
	}

	/**
	 * @description: 保存查看文件信息
	 * @return {*}
	 */
	@AuraEnabled
	public static OutPut saveFileViewDetail(String saveObjectName, String saveObjectNameTotal, Id recordId, String contentDocumentId, String contentDocumentTitle){
		System.Savepoint sp = Database.setSavepoint();
		try{
			OutPut out = new OutPut();
			// 保存每个文件访问数据
			if (String.isNotBlank(saveObjectName)){
				// 获取对象的API名称
				SObject sObj = (SObject) Type.forName(saveObjectName).newInstance();
				sObj.put('Record_Id__c', recordId);
				sObj.put('File_Id__c', contentDocumentId);
				sObj.put('File_Title__c', contentDocumentTitle);
				sObj.put('User__c', System.UserInfo.getUserId());
				insert sobj;
			}
			// 保存总体学习库数据
			if (String.isNotBlank(saveObjectNameTotal)){
				String key = recordId + '-' + System.UserInfo.getUserId();
				String sql = 'SELECT Id, Number__c FROM ' + saveObjectNameTotal + ' WHERE Key__c = :key ';
				List<SObject> objectList = Database.query(sql);
				// 获取对象的API名称
				SObject sObj = (SObject) Type.forName(saveObjectNameTotal).newInstance();
				sObj.put('Record_Id__c', recordId);
				sObj.put('Key__c', key);
				sObj.put('User__c', System.UserInfo.getUserId());
				if (objectList != null && objectList.size() > 0){
					sObj.put('Number__c', Integer.valueOf(objectList[0].get('Number__c')) + 1);
				} else{
					sObj.put('Number__c', 1);
				}
				// 使用Schema类的getGlobalDescribe()方法获取全局对象描述信息
				Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
				// 根据对象名获取对象描述信息
				Schema.SObjectType objectType = gd.get(saveObjectNameTotal);
				// 使用getDescribe()方法获取对象描述信息
				Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
				// 使用getFieldMap()方法获取对象的所有字段描述信息
				Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
				
				Database.upsert (sObj, fieldMap.get('Key__c'), true);
			}

			out.isSuccess = true;
			return out;
		} catch (Exception e){
			Database.rollback(sp);
			OutPut out = new OutPut();
			out.isSuccess = false;
			return out;
		}
	}

	/**
	 * @description: 查询文件详情，预览图
	 * @return {*}
	 */
	@AuraEnabled
	public static Map<String, Object> getFileDetail(Id contentDocumentId){

		Map<String, Object> resultMap = new Map<String, Object>();
		// 检索文件详细信息
		List<ContentVersion> cvList = [SELECT Id, ContentBodyId, ContentDocumentId, FileType, Title, VersionDataUrl
		                               FROM ContentVersion
		                               WHERE ContentDocumentId = :contentDocumentId AND IsLatest = true
		                               ORDER BY VersionNumber DESC];
		resultMap.put('contentVersion', cvList[0]);
		resultMap.put('flag', true);
		return resultMap;
	}

	public static List<FileInfo> getFileInfoList(Id recordId){
		List<FileInfo> fileInfoList = new List<FileInfo>();
		// 获取上传的video
		List<ContentDocumentLink> attachedDocuments = [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.ContentSize, ContentDocument.FileType, ContentDocument.FileExtension
		                                               FROM ContentDocumentLink
		                                               WHERE LinkedEntityId = :recordId
		                                               WITH SECURITY_ENFORCED
		                                               ORDER BY ContentDocument.LastModifiedDate DESC];
		for (ContentDocumentLink cdl : attachedDocuments){
			List<ContentVersion> cvList = [SELECT Id, ContentBodyId, ContentDocumentId, FileType, Title, VersionDataUrl
			                               FROM ContentVersion
			                               WHERE ContentDocumentId = :cdl.ContentDocumentId AND IsLatest = true
			                               ORDER BY VersionNumber DESC];
			FileInfo fi = new FileInfo();
			fi.ContentDocumentId = cdl.ContentDocumentId;
			fi.ContentDocumentUrl = '/lightning/r/ContentDocument/' + cdl.ContentDocumentId + '/view';
			fi.Title = cdl.ContentDocument.Title;
			fi.LastModifiedDate = Datetime.valueOf(cdl.ContentDocument.LastModifiedDate).format('yyyy-MM-dd');
			fi.ContentSize = getPrintSize(Decimal.valueOf(cdl.ContentDocument.ContentSize));
			fi.fileType = cdl.ContentDocument.FileExtension;
			fi.isMP4 = false;
			fi.isCSV = false;
			fi.isEXCEL = false;
			fi.isJPG = false;
			fi.isTEXT = false;
			fi.isPDF = false;
			fi.isPPT = false;
			fi.isDOC = false;
			fi.isPNG = false;
			fi.versionId = cvList[0].Id;
			fi.viewSrc = '/sfc/servlet.shepherd/version/renditionDownload?rendition=thumb120by90&versionId=' + cvList[0].Id + '&operationContext=CHATTER&contentId=' + cvList[0].ContentBodyId + '&page=0';
			if (cdl.ContentDocument.FileExtension.contains('mp4')){
				fi.isMP4 = true;
			}
			if (cdl.ContentDocument.FileExtension.contains('doc')){
				fi.isDOC = true;
			}
			if (cdl.ContentDocument.FileExtension.contains('xls')){
				fi.isEXCEL = true;
			}
			if (cdl.ContentDocument.FileExtension.contains('jpg')){
				fi.isJPG = true;
			}
			if (cdl.ContentDocument.FileExtension.contains('txt')){
				fi.isTEXT = true;
			}
			if (cdl.ContentDocument.FileExtension.contains('pdf')){
				fi.isPDF = true;
			}
			if (cdl.ContentDocument.FileExtension.contains('csv')){
				fi.isCSV = true;
			}
			if (cdl.ContentDocument.FileExtension.contains('ppt')){
				fi.isPPT = true;
			}
			if (cdl.ContentDocument.FileExtension.contains('png')){
				fi.isPNG = true;
			}
			fileInfoList.add(fi);
		}
		return fileInfoList;
	}

	public class OutPut{
		@AuraEnabled
		public Boolean isSuccess{ get; set; }

		@AuraEnabled
		public String msg{ get; set; }

		@AuraEnabled
		public List<FileInfo> fileInfoList{ get; set; }

	}

	public class FileInfo{
		@AuraEnabled
		public String ContentDocumentId{ get; set; }

		@AuraEnabled
		public String ContentDocumentUrl{ get; set; }

		@AuraEnabled
		public String Title{ get; set; }

		@AuraEnabled
		public String LastModifiedDate{ get; set; }

		@AuraEnabled
		public String ContentSize{ get; set; }

		@AuraEnabled
		public String fileType{ get; set; }

		@AuraEnabled
		public Boolean isMP4{ get; set; }

		@AuraEnabled
		public Boolean isJPG{ get; set; }

		@AuraEnabled
		public Boolean isTEXT{ get; set; }

		@AuraEnabled
		public Boolean isPDF{ get; set; }

		@AuraEnabled
		public Boolean isEXCEL{ get; set; }

		@AuraEnabled
		public Boolean isCSV{ get; set; }

		@AuraEnabled
		public Boolean isPPT{ get; set; }

		@AuraEnabled
		public Boolean isDOC{ get; set; }

		@AuraEnabled
		public Boolean isPNG{ get; set; }

		@AuraEnabled
		public String viewSrc{ get; set; }

		@AuraEnabled
		public String versionId{ get; set; }

	}

	public static String getPrintSize(Decimal size){
		Decimal gbSize = 1024 * 1024 * 1024;
		Decimal mbSize = 1024 * 1024;
		Decimal kbSize = 1024;
		String result;
		if (size / gbSize > 1){
			result = Decimal.valueOf(Math.round(size / gbSize * 100)) / 100 + 'GB';
		} else if (size / mbSize > 1){
			result = Decimal.valueOf(Math.round(size / mbSize * 10)) / 10 + 'MB';
		} else if (size / kbSize > 1){
			result = Math.round(size / kbSize) + 'KB';
		} else{
			result = size + 'B';
		}

		return result;
	}

}