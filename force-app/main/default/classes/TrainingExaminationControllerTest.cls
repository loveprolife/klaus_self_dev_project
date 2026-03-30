@isTest
private class TrainingExaminationControllerTest {

    static testMethod void testMethod1() {

        User currentUser = [select id, title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country
                                FROM User WHERE id =: UserInfo.getUserId()];

        Profile p = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];
        User user1 = new User(
            Alias = 'admin', Email='trainingExaminationControllerTest@hisensetest.com',
            EmailEncodingKey='UTF-8', LastName='sales representative', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Kuala_Lumpur',
            UserName='trainingExaminationControllerTest@hisensetest.com'
        );
        Database.insert(user1);
        Contact con = new Contact();
        con.lastname = '111';
        con.Email = 'qinyanhao@hisense.com';
        insert con;
        system.runAs(currentUser){
            // 试题库 Question_Bank__c
            String recorType1 = Schema.getGlobalDescribe().get('Question_Bank__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Single_Choice').getRecordTypeId();
            String recorType2 = Schema.getGlobalDescribe().get('Question_Bank__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Multiple_Choice').getRecordTypeId();
            String recorType3 = Schema.getGlobalDescribe().get('Question_Bank__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Judgment_Question').getRecordTypeId();
            String recorType4 = Schema.getGlobalDescribe().get('Question_Bank__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Subjective_Questions').getRecordTypeId();
            Question_Bank__c qb1 = new Question_Bank__c();
            qb1.Title__c = 'Test-01';
            qb1.Title_Type__c = '客户试题';
            qb1.Choice_A__c = 'AAA';
            qb1.Choice_B__c = 'BBB';
            qb1.Choice_C__c = 'CCC';
            qb1.Choice_D__c = 'DDD';
            qb1.Single_Answer__c = 'A';
            qb1.RecordTypeId = recorType1;
            Question_Bank__c qb2 = new Question_Bank__c();
            qb2.Title__c = 'Test-02';
            qb2.Title_Type__c = '客户试题';
            qb2.Choice_A__c = 'AAA';
            qb2.Choice_B__c = 'BBB';
            qb2.Choice_C__c = 'CCC';
            qb2.Choice_D__c = 'DDD';
            qb2.Multiple_Choice_Answer__c = 'A;B;C;D';
            qb2.RecordTypeId = recorType2;
            Question_Bank__c qb3 = new Question_Bank__c();
            qb3.Title__c = 'Test-02';
            qb3.Title_Type__c = '客户试题';
            qb3.True_answer__c = 'true';
            qb3.RecordTypeId = recorType3;
            Question_Bank__c qb4 = new Question_Bank__c();
            qb4.Title__c = 'Test-02';
            qb4.Title_Type__c = '巡店试题';
            qb4.RecordTypeId = recorType4;
            insert qb1;
            insert qb2;
            insert qb3;
            insert qb4;
            // 培训任务
            Training_Task__c tt = new Training_Task__c();
            tt.Training_Content__c = '培训任务-001';
            tt.Pass_Score__c = 1;
            tt.Training_Time__c = Datetime.now();
            tt.Approval_Status__c = 'Approved';
            insert tt;

            // 试卷任务
            Examination__c et = new Examination__c();
            et.Name = '试卷任务-001';
            insert et;

            // 添加培训人员
            Training_Task_User__c ttu = new Training_Task_User__c();
            ttu.Training_Task__c = tt.id;
            ttu.User__c = currentUser.id;
            insert ttu;
            // 培训人员
            Training_Personnel__c tp = new Training_Personnel__c();
            tp.Training_Task__c = tt.id;
            tp.Training_Task_User__c = ttu.id;
            tp.User__c = currentUser.id;
            insert tp;
            // 考试试题
            Questionnaire_Question_Bank__c qqb1 = new Questionnaire_Question_Bank__c();
            qqb1.Training_Task__c = tt.id;
            qqb1.Examination__c = et.id;
            qqb1.Question_Bank__c = qb1.id;
            qqb1.Score__c = 1;
            Questionnaire_Question_Bank__c qqb2 = new Questionnaire_Question_Bank__c();
            qqb2.Training_Task__c = tt.id;
            qqb2.Examination__c = et.id;
            qqb2.Question_Bank__c = qb2.id;
            qqb2.Score__c = 2;
            Questionnaire_Question_Bank__c qqb3 = new Questionnaire_Question_Bank__c();
            qqb3.Training_Task__c = tt.id;
            qqb3.Examination__c = et.id;
            qqb3.Question_Bank__c = qb3.id;
            qqb3.Score__c = 3;
            Questionnaire_Question_Bank__c qqb4 = new Questionnaire_Question_Bank__c();
            qqb4.Training_Task__c = tt.id;
            qqb4.Examination__c = et.id;
            qqb4.Question_Bank__c = qb4.id;
            qqb4.Score__c = 4;
            insert qqb1;
            insert qqb2;
            insert qqb3;
            insert qqb4;
            // 考试历史
            Training_Answer_History__c tah = new Training_Answer_History__c();
            tah.Question_Bank__c = qb4.id;
            tah.Questionnaire_Question_Bank__c = qqb4.id;
            tah.Training_Task_User__c = ttu.id;
            tah.Training_Task__c = tt.Id;
            tah.Examination__c = et.id;
            insert tah;
            // 评价
            Training_Task_Evaluation__c tte = new Training_Task_Evaluation__c();
            tte.Training_Task__c = tt.id;
            tte.Evaluation__c = '请评价';
            insert tte;
            // 评价回复
            Training_Task_Evaluation_Reply__c tter = new Training_Task_Evaluation_Reply__c();
            tter.Training_Task_Evaluation__c = tte.id;
            tter.Reply__c = 'GOOD';
            insert tter;
            // 文件链接
            Training_Task_Video_Connection__c ttvc = new Training_Task_Video_Connection__c();
            ttvc.Training_Task__c = tt.id;
            ttvc.Name = '百度';
            ttvc.Video_Connection_URL__c = 'www.baidu.com';
            insert ttvc;

            Test.startTest();

            // initData 方法
            TrainingExaminationController.initData(tt.id);
            TrainingExaminationController.initData(tp.id);
            TrainingExaminationController.initDataExamination(et.id);

            tt.Task_Status__c = '发布';
            upsert tt;
            ttu.Score__c = 2;
            ttu.Pass_The_Examination__c = '通过';
            upsert ttu;
            TrainingExaminationController.initData(tp.id);
            ttu.Score__c = null;
            ttu.Pass_The_Examination__c = '未通过';
            ttu.Examinations_Number__c = 2;
            upsert ttu;
            TrainingExaminationController.initData(tp.id);
            ttu.Examinations_Number__c = 1;
            upsert ttu;
            TrainingExaminationController.initData(tp.id);
            TrainingExaminationController.initData(ttvc.id);
            // saveData 方法
            Map<Id, String> questionAnswerMap = new Map<Id, String>();
            questionAnswerMap.put(qb1.id, 'A');
            questionAnswerMap.put(qb2.id, 'A;B;C;D');
            questionAnswerMap.put(qb3.id, 'true');
            questionAnswerMap.put(qb4.id, 'qqqqqq');
            TrainingExaminationController.saveData(questionAnswerMap, tt);
            TrainingExaminationController.saveDataExamination(questionAnswerMap, et);
            // checkTrainingTaskTime 方法
            TrainingExaminationController.checkTrainingTaskTime(tp.id);
            // setSignInTime 方法
            TrainingExaminationController.setSignInTime(tp.id);
            // checkTrainingTaskTime 方法
            TrainingExaminationController.checkTrainingTaskTime(tp.id);
            // saveEvaluationReply 方法
            TrainingExaminationController.saveEvaluationReply(tte.id, tter.id, 'Good');
            // deleteEvaluationReply 方法
            TrainingExaminationController.deleteEvaluationReply(tter.id);
            TrainingExaminationController.saveEvaluationReply(tte.id, null, 'Good');
            // getTrainingTaskEvaluation 方法
            TrainingExaminationController.getTrainingTaskEvaluation(tp.id);
            delete tte;
            TrainingExaminationController.getTrainingTaskEvaluation(tp.id);
            // verifyPublishNotice 方法
            TrainingExaminationController.verifyPublishNotice(tt.id);
            // publishNotice 方法
            TrainingExaminationController.publishNotice(tt.id);
            // unpublishNotice 方法
            TrainingExaminationController.unpublishNotice(tt.id);
            // saveSelectedQuesions 方法
            Question_Bank__c qb5 = new Question_Bank__c();
            qb5.Title__c = 'Test-05';
            qb5.Title_Type__c = '客户试题';
            qb5.Choice_A__c = 'AAA';
            qb5.Choice_B__c = 'BBB';
            qb5.Choice_C__c = 'CCC';
            qb5.Choice_D__c = 'DDD';
            qb5.Single_Answer__c = 'B';
            qb5.RecordTypeId = recorType1;
            insert qb5;
            Map<Id,Integer> ssqMap = new Map<Id,Integer>();
            ssqMap.put(qb5.id, 5);
            // TrainingExaminationController.saveSelectedQuesions(tt.id, JSON.serialize(ssqMap));
            TrainingExaminationController.saveSelectedQuesions(et.id, JSON.serialize(ssqMap));
            // initTrainingUserExamination 方法
            TrainingExaminationController.initTrainingUserExamination(ttu.id);
            // markSubjectiveQuestions 方法
            Map<Id, String> questionAnswerHistoryMap = new Map<Id, String>();
            questionAnswerHistoryMap.put(tah.id, '4');
            TrainingExaminationController.markSubjectiveQuestions(questionAnswerHistoryMap, ttu);
            TrainingExaminationController.markSubjectiveQuestions(questionAnswerMap, ttu);
            // getSelectedQuestions 方法
            // TrainingExaminationController.getSelectedQuestions(tt.id);
            TrainingExaminationController.getSelectedQuestions(et.id);
            // getQuestionBankRecordType 方法
            TrainingExaminationController.getQuestionBankRecordType();
            // checkQuestionInfo 方法
            TrainingExaminationController.checkQuestionInfo(qqb1.id);
            // searchQuestionBankDatas 方法
            // TrainingExaminationController.searchQuestionBankDatas(tt.id, '客户试题', 'Single_Choice', 'Test');
            TrainingExaminationController.searchQuestionBankDatas(et.id, '客户试题', 'Single_Choice', 'Test');
            // deleteQuestion 方法
            TrainingExaminationController.deleteQuestion(qqb1.id);
            // saveFile 方法
            Blob b = Blob.valueOf('trainingExaminationControllerTest@hisensetest.com');
            String b1 = EncodingUtil.base64Encode(b);
            TrainingExaminationController.saveFile(ttu.id, 'Test',  b1);

            List<String[]> fileLines = new List<String[]>();
            String[] userLine = new String[]{'inyanhao@hisense.com'};
            fileLines.add(userLine);
            TrainingExaminationController.saveFileExamination(et.id, fileLines);

            TrainingExaminationController.downLoadViewPersonnel(et.id);
            // saveQuestionBanksFile 方法
            Blob b2 = Blob.valueOf('Record Types,Title Type,Title,Answer,Choice A,Choice B,Choice C,Choice D\r\n'
                                + '1,Type1,QuestionSingle1,A,A,B,C,D\r\n'
                                + '2,Type1,QuestionMultiple1,B;C,A,B,C,D\r\n'
                                + '3,Type1,QuestionJudgment1,TRUE,,,,\r\n' 
                                + '4,,QuestionSubjective1,,,,,\r\n'
            );
            String b3 = EncodingUtil.base64Encode(b2);
            TrainingExaminationController.saveQuestionBanksFile('Test2',  b3);
            // additionalExamination 方法
            List<String> trainingTaskUserIds = new List<String>();
            trainingTaskUserIds.add(ttu.id);
            TrainingExaminationController.additionalExamination(trainingTaskUserIds);
            // addAllTrainingTaskUser 方法
            TrainingExaminationController.addAllTrainingTaskUser(tt.id);
            // verifyAddAllUser 方法
            TrainingExaminationController.verifyAddAllUser(tt.id);

            StarRatingController.initData(ttu.id);
            StarRatingController.updateRating(ttu.id, '5','6');
            StarRatingController.updateRating(ttu.id, '6','6');
            
            // 未发布
            tt.Task_Status__c = '未发布';
            upsert tt;
            TrainingExaminationController.checkTrainingTaskTime(tp.id);
            TrainingExaminationController.getTrainingTaskEvaluation(tp.id);
            // 删除
            delete con;
            TrainingExaminationController.publishNotice(tt.id);
            delete ttu;
            TrainingExaminationController.verifyPublishNotice(tt.id);
            TrainingExaminationController.publishNotice(tt.id);
            tt.Approval_Status__c = 'Draft';
            upsert tt;
            TrainingExaminationController.verifyPublishNotice(tt.id);
            TrainingExaminationController.publishNotice(tt.id);
            
            Test.stopTest();
        }
    }
}