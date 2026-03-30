/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

/* Tests for VideoViewerController */
@isTest
public class TestVideoViewerController {
  @TestSetup
  static void setupTestData() {
    // Setup different test cases
    Case caseWithoutAttachments = TestUtils.createTestCase(
      'caseWithoutAttachments'
    );
    Case caseWithNoVideoAttachments = TestUtils.createTestCase(
      'caseWithNoVideoAttachments'
    );
    Case caseWithOneVideoAttachment = TestUtils.createTestCase(
      'caseWithOneVideoAttachment'
    );
    Case caseWithMultipleVideoAttachments = TestUtils.createTestCase(
      'caseWithMultipleVideoAttachments'
    );
    Case caseWithMixedAttachments = TestUtils.createTestCase(
      'caseWithMixedAttachments'
    );
    Case caseWithUnsupportedVideoAttachment = TestUtils.createTestCase(
      'caseWithUnsupportedVideoAttachment'
    );
    ContentVersion videoFile1 = TestUtils.createContentVersion(
      'videoFile1',
      'testvideo1.mp4'
    );
    ContentVersion videoFile2 = TestUtils.createContentVersion(
      'videoFile2',
      'testvideo2.mov'
    );
    ContentVersion videoFile3 = TestUtils.createContentVersion(
      'videoFile3',
      'testvideo2.flv'
    );
    ContentVersion textFile = TestUtils.createContentVersion(
      'textFile',
      'exampletext.txt'
    );
    // Attach files to cases
    TestUtils.attachDocumentToCase('caseWithNoVideoAttachments', 'textFile');
    TestUtils.attachDocumentToCase('caseWithOneVideoAttachment', 'videoFile1');
    TestUtils.attachDocumentToCase(
      'caseWithMultipleVideoAttachments',
      'videoFile1'
    );
    TestUtils.attachDocumentToCase(
      'caseWithMultipleVideoAttachments',
      'videoFile2'
    );
    TestUtils.attachDocumentToCase('caseWithMixedAttachments', 'textFile');
    TestUtils.attachDocumentToCase('caseWithMixedAttachments', 'videoFile1');
    TestUtils.attachDocumentToCase(
      'caseWithUnsupportedVideoAttachment',
      'videoFile3'
    );
  }
  @isTest
  static void testAttachedDocumentWhenNoDocumentsAreAttached() {
    Case caseWithoutAttachments = TestUtils.getCaseBySubject(
      'caseWithoutAttachments'
    );
    List<ContentDocumentLink> attachedDocuments = VideoViewerController.getAttachedDocuments(
      caseWithoutAttachments.Id
    );
    System.assertEquals(
      0,
      attachedDocuments.size(),
      'There should be no documents attached to the case'
    );
  }

  @isTest
  static void testAttachedDocumentsWhenNoVideoDocumentsAreAttached() {
    Case caseWithNoVideoAttachments = TestUtils.getCaseBySubject(
      'caseWithNoVideoAttachments'
    );
    List<ContentDocumentLink> attachedDocuments = VideoViewerController.getAttachedDocuments(
      caseWithNoVideoAttachments.Id
    );
    System.assertEquals(
      0,
      attachedDocuments.size(),
      'There should be no video documents attached to the case'
    );
  }

  @isTest
  static void testAttachedDocumentsWhenOneVideoDocumentIsAttached() {
    Case caseWithOneVideoAttachment = TestUtils.getCaseBySubject(
      'caseWithOneVideoAttachment'
    );
    List<ContentDocumentLink> attachedDocuments = VideoViewerController.getAttachedDocuments(
      caseWithOneVideoAttachment.Id
    );
    System.assertEquals(
      1,
      attachedDocuments.size(),
      'There should be exactly one video attached to the case'
    );
  }

  @isTest
  static void testAttachedDocumentsWhenMultipleVideoDocumentsAreAttached() {
    Case caseWithMultipleVideoAttachments = TestUtils.getCaseBySubject(
      'caseWithMultipleVideoAttachments'
    );
    List<ContentDocumentLink> attachedDocuments = VideoViewerController.getAttachedDocuments(
      caseWithMultipleVideoAttachments.Id
    );
    System.assertEquals(
      2,
      attachedDocuments.size(),
      'There should be exactly two video files attached to the case'
    );
  }

  @isTest
  static void testAttachedDocumentsWhenMixedDocumentsAreAttached() {
    Case caseWithMixedAttachments = TestUtils.getCaseBySubject(
      'caseWithMixedAttachments'
    );
    List<ContentDocumentLink> attachedDocuments = VideoViewerController.getAttachedDocuments(
      caseWithMixedAttachments.Id
    );
    System.assertEquals(
      1,
      attachedDocuments.size(),
      'There should be exactly one video file attached to the case'
    );
  }

  @isTest
  static void testAttachedDocumentsWhenUnSupportedVideoIsAttached() {
    Case caseWithUnsupportedVideoAttachment = TestUtils.getCaseBySubject(
      'caseWithUnsupportedVideoAttachment'
    );
    List<ContentDocumentLink> attachedDocuments = VideoViewerController.getAttachedDocuments(
      caseWithUnsupportedVideoAttachment.Id
    );
    System.assertEquals(
      0,
      attachedDocuments.size(),
      'There should be no documents attached to the case, as the video file is unsupported'
    );
  }

  @isTest
  static void test1() {
    Case caseWithUnsupportedVideoAttachment = TestUtils.getCaseBySubject(
      'caseWithUnsupportedVideoAttachment'
    );
    List<ContentDocumentLink> attachedDocuments = VideoViewerController.getAttachedDocumentsTrainingPersonnel(
      caseWithUnsupportedVideoAttachment.Id
    );
    System.assertEquals(
      0,
      attachedDocuments.size(),
      'There should be no documents attached to the case, as the video file is unsupported'
    );
  }

  @isTest
  static void test2() {
    Training_Task__c tt = new Training_Task__c();
    tt.Training_Content__c = '培训任务-001';
    tt.Pass_Score__c = 1;
    tt.Training_Time__c = Datetime.now();
    tt.Approval_Status__c = 'Approved';
    insert tt;
    // 添加培训人员
    Training_Task_User__c ttu = new Training_Task_User__c();
    ttu.Training_Task__c = tt.id;
    ttu.User__c = UserInfo.getUserId();
    insert ttu;
    // 培训人员
    Training_Personnel__c tp = new Training_Personnel__c();
    tp.Training_Task__c = tt.id;
    tp.Training_Task_User__c = ttu.id;
    tp.User__c = UserInfo.getUserId();
    insert tp;
    VideoViewerController.getAttachedDocuments(tp.id);
  }

  @isTest
  static void testGetBaseUrl() {
    String url = VideoViewerController.getBaseUrl();
    System.assertNotEquals(
      null,
      url,
      'The base url for the org cannot be null'
    );
  }
}