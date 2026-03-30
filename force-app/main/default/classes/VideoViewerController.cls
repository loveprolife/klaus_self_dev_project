/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/* Controller for the VideoViewer Component */
public without sharing class VideoViewerController {
  private static final List<String> ALLOWED_MEDIA_TYPES = new List<String>{
    'webm',
    'mp4',
    'mov',
    'm4v'
  };
  @AuraEnabled(cacheable=true)
  public static List<ContentDocumentLink> getAttachedDocuments(Id recordId) {
    // 通过id获取
    if(recordId.getSobjectType().getDescribe().getName() == 'Training_Personnel__c'){
      List<Training_Personnel__c> tpList = [SELECT Training_Task__c FROM Training_Personnel__c WHERE id = :recordId LIMIT 1];
      for(Training_Personnel__c tp : tpList){
        recordId = tp.Training_Task__c;
      }
    }
    List<String> allowedFileTypes = ALLOWED_MEDIA_TYPES;
    List<ContentDocumentLink> attachedDocuments = [
      SELECT
        ContentDocumentId,
        ContentDocument.Title,
        ContentDocument.Description
      FROM ContentDocumentLink
      WHERE
        LinkedEntityId = :recordId
        AND ContentDocument.FileExtension IN :allowedFileTypes
      WITH SECURITY_ENFORCED
      ORDER BY SystemModstamp
    ];
    return attachedDocuments;
  }

  @AuraEnabled(cacheable=true)
  public static List<ContentDocumentLink> getAttachedDocumentsTrainingPersonnel(Id recordId) {
    List<String> allowedFileTypes = ALLOWED_MEDIA_TYPES;
    List<ContentDocumentLink> attachedDocuments = [
      SELECT
        ContentDocumentId,
        ContentDocument.Title,
        ContentDocument.Description
      FROM ContentDocumentLink
      WHERE
        LinkedEntityId = :recordId
        AND ContentDocument.FileExtension IN :allowedFileTypes
      WITH SECURITY_ENFORCED
      ORDER BY SystemModstamp
    ];
    return attachedDocuments;
  }

  @AuraEnabled(cacheable=true)
  public static String getBaseUrl() {
    // return System.URL.getOrgDomainUrl().toExternalForm();
    return System.DomainCreator.getContentHostname();
  }

  @AuraEnabled(cacheable=true)
  public static String getLightningBaseUrl() {
    return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';
  }
}