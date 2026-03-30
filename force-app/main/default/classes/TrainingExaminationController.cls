/*
 * @Author: WFC
 * @Date: 2023-05-26 14:43:58
 * @LastEditors: TJP
 * @LastEditTime: 2025-07-09 11:50:01
 * @Description: 
 * @FilePath: \Hitest_2022\force-app\main\default\classes\TrainingExaminationController.cls
 */
public without sharing class TrainingExaminationController {

    /**
     * @description: 页面TrainingExaminationLWC，初始考试试题
     * @return {*}
     */    
    @AuraEnabled
	public static OutPut initData(Id recordId) {
        try{
            system.debug('recordId: ' + recordId);
            String recordObejectName = recordId.getSobjectType().getDescribe().getName();
            // 通过id获取
            if(recordObejectName == 'Training_Personnel__c'){
                List<Training_Personnel__c> tpList = [SELECT Training_Task__c FROM Training_Personnel__c WHERE id = :recordId];
                for(Training_Personnel__c tp : tpList){
                    recordId = tp.Training_Task__c;
                }
            }
            OutPut out = new OutPut();
            out.isSuccess = false;
            out.isCanAnswer = false;
            out.isPassExamination = false;
            List<Training_Task__c> ttList = [SELECT Id, Name, Training_Content__c, Task_Status__c FROM Training_Task__c WHERE id = :recordId];
            if(ttList != null && ttList.size() > 0){
                if(ttList[0].Task_Status__c != '发布' && recordObejectName == 'Training_Personnel__c'){
                    out.isSuccess = false;
                    out.msg = Label.Training_Task_Unpublish; // '培训任务未发布！'
                    return out;
                }
                out.trainingTask = ttList[0];
            }
            // 是否可以答题
            List<Training_Task_User__c> ttuList = [SELECT id, Examinations_Number__c, Score__c, Pass_The_Examination__c, Additional_Examination__c FROM Training_Task_User__c WHERE Training_Task__c = :recordId AND User__c = :System.UserInfo.getUserId()];
            Decimal num;
            if(ttuList != null && ttuList.size() > 0 && recordObejectName == 'Training_Personnel__c'){
                out.isCanAnswer = true;
                num = ttuList[0].Examinations_Number__c == null ? 0:ttuList[0].Examinations_Number__c;
                if(ttuList[0].Pass_The_Examination__c == '通过'){
                    out.isSuccess = true;
                    out.isPassExamination = true;
                    out.msg = Label.Pass_The_Examination; // '考试已通过!';
                    return out;
                }
                if(num >= 2 && !ttuList[0].Additional_Examination__c){
                    out.exceedance = true;
                    out.msg = Label.Exceed_The_Number_of_Examinations; // '答题次数已经2次，不可以再次答题!';
                    return out;
                }
                if(ttuList[0].Score__c == null && num > 0){
                    out.msg = Label.Unmarked_Answer; // '上一次答题还未评分！请联系培训师';
                    return out;
                }
            }
            List<Questionnaire_Question_Bank__c> qqbList = [SELECT id, Question_Bank__r.RecordType.DeveloperName, Question_Bank__c, Question_Bank__r.Title__c,
                                                            Question_Bank__r.Choice_A__c, Question_Bank__r.Choice_B__c, Question_Bank__r.Choice_C__c, Question_Bank__r.Choice_D__c,
                                                            Question_Bank__r.Sort__c, Question_Bank__r.Score__c, Score__c
                                                            FROM Questionnaire_Question_Bank__c
                                                            // YYL
                                                            // FROM Questionnaire_Question_Bank__c WHERE Training_Task__c = :recordId
                                                            ORDER BY Question_Bank__r.RecordType.name desc];

            if(qqbList == null || qqbList.size() == 0){
                out.msg = Label.The_Examination_Empty; // '考试试题为空！';
                return out;
            }
            List<Question_Bank__c> singleChoiceList = new List<Question_Bank__c>();    
            List<Question_Bank__c> multipleChoiceList = new List<Question_Bank__c>();
            List<Question_Bank__c> judgmentQuestionList = new List<Question_Bank__c>();
            List<Question_Bank__c> subjectiveQuestionList = new List<Question_Bank__c>();
            Map<Id, String> questionAnswerMap = new Map<Id, String>();
            Integer singleChoiceNum = 1;
            Integer multipleChoiceNum = 1;
            Integer judgmentQuestionNum = 1;
            Integer subjectiveQuestionNum = 1;
            for(Questionnaire_Question_Bank__c qqb : qqbList){
                Question_Bank__c qb = new Question_Bank__c();
                qb.id = qqb.Question_Bank__c;
                qb.Title__c = qqb.Question_Bank__r.Title__c;
                qb.Choice_A__c = qqb.Question_Bank__r.Choice_A__c;
                qb.Choice_B__c = qqb.Question_Bank__r.Choice_B__c;
                qb.Choice_C__c = qqb.Question_Bank__r.Choice_C__c;
                qb.Choice_D__c = qqb.Question_Bank__r.Choice_D__c;
                qb.Score__c = qqb.Score__c;
                if(qqb.Question_Bank__r.RecordType.DeveloperName == 'Single_Choice'){
                    qb.Sort__c = singleChoiceNum;
                    singleChoiceList.add(qb);
                    singleChoiceNum += 1;
                }else if(qqb.Question_Bank__r.RecordType.DeveloperName == 'Multiple_Choice'){
                    qb.Sort__c = multipleChoiceNum;
                    multipleChoiceList.add(qb);
                    multipleChoiceNum += 1;
                }else if(qqb.Question_Bank__r.RecordType.DeveloperName == 'Judgment_Question'){
                    qb.Sort__c = judgmentQuestionNum;
                    judgmentQuestionList.add(qb);
                    judgmentQuestionNum += 1;
                }else if(qqb.Question_Bank__r.RecordType.DeveloperName == 'Subjective_Questions'){
                    qb.Sort__c = subjectiveQuestionNum;
                    subjectiveQuestionList.add(qb);
                    subjectiveQuestionNum += 1;
                }
                questionAnswerMap.put(qqb.Question_Bank__c, '');
            }
            out.singleChoiceList = singleChoiceList;
            out.multipleChoiceList = multipleChoiceList;
            out.judgmentQuestionList = judgmentQuestionList;
            out.subjectiveQuestionList = subjectiveQuestionList;
            out.questionAnswerMap = questionAnswerMap;
            out.isSuccess = true;

            return out;
        }catch (Exception e) {
            OutPut out = new OutPut();
            out.isSuccess = false;
            out.msg = Label.Failed_To_Initialize; // '初始化页面失败';
            return out;    
        }  
	}

    /**
     * @description: 页面ExaminationLwc，初始考试试题
     * @return {*}
     */    
    @AuraEnabled
	public static OutPut initDataExamination(Id recordId) {
        try{
            system.debug('recordId: ' + recordId);
            OutPut out = new OutPut();
            out.isSuccess = false;
            out.isCanAnswer = true;
            out.isPassExamination = false;

            // 是否可以答题
            // List<Training_Task_User__c> ttuList = [SELECT id, Examinations_Number__c, Score__c, Pass_The_Examination__c, Additional_Examination__c FROM Training_Task_User__c WHERE Examination__c = :recordId AND User__c = :System.UserInfo.getUserId()];
            // Decimal num;
            // if(ttuList != null && ttuList.size() > 0){
            //     out.isCanAnswer = true;
            //     num = ttuList[0].Examinations_Number__c == null ? 0:ttuList[0].Examinations_Number__c;
            //     if(ttuList[0].Pass_The_Examination__c == '通过'){
            //         out.isSuccess = true;
            //         out.isPassExamination = true;
            //         out.msg = Label.Pass_The_Examination; // '考试已通过!';
            //         return out;
            //     }
            //     if(num >= 2 && !ttuList[0].Additional_Examination__c){
            //         out.exceedance = true;
            //         out.msg = Label.Exceed_The_Number_of_Examinations; // '答题次数已经2次，不可以再次答题!';
            //         return out;
            //     }
            //     if(ttuList[0].Score__c == null && num > 0){
            //         out.msg = Label.Unmarked_Answer; // '上一次答题还未评分！请联系培训师';
            //         return out;
            //     }
            // }

            List<Examination__c> eeList = [SELECT Id, Name FROM Examination__c WHERE id = :recordId];
            out.examination = eeList.get(0);

            List<Questionnaire_Question_Bank__c> qqbList = [SELECT id, Question_Bank__r.RecordType.DeveloperName, Question_Bank__c, Question_Bank__r.Title__c,
                                                            Question_Bank__r.Choice_A__c, Question_Bank__r.Choice_B__c, Question_Bank__r.Choice_C__c, Question_Bank__r.Choice_D__c,
                                                            Question_Bank__r.Sort__c, Question_Bank__r.Score__c, Score__c
                                                            // YYL
                                                            FROM Questionnaire_Question_Bank__c WHERE Examination__c = :recordId
                                                            ORDER BY Question_Bank__r.RecordType.name desc];

            if(qqbList == null || qqbList.size() == 0){
                out.msg = Label.The_Examination_Empty; // '考试试题为空！';
                return out;
            }
            List<Question_Bank__c> singleChoiceList = new List<Question_Bank__c>();    
            List<Question_Bank__c> multipleChoiceList = new List<Question_Bank__c>();
            List<Question_Bank__c> judgmentQuestionList = new List<Question_Bank__c>();
            List<Question_Bank__c> subjectiveQuestionList = new List<Question_Bank__c>();
            Map<Id, String> questionAnswerMap = new Map<Id, String>();
            Integer singleChoiceNum = 1;
            Integer multipleChoiceNum = 1;
            Integer judgmentQuestionNum = 1;
            Integer subjectiveQuestionNum = 1;
            for(Questionnaire_Question_Bank__c qqb : qqbList){
                Question_Bank__c qb = new Question_Bank__c();
                qb.id = qqb.Question_Bank__c;
                qb.Title__c = qqb.Question_Bank__r.Title__c;
                qb.Choice_A__c = qqb.Question_Bank__r.Choice_A__c;
                qb.Choice_B__c = qqb.Question_Bank__r.Choice_B__c;
                qb.Choice_C__c = qqb.Question_Bank__r.Choice_C__c;
                qb.Choice_D__c = qqb.Question_Bank__r.Choice_D__c;
                qb.Score__c = qqb.Score__c;
                if(qqb.Question_Bank__r.RecordType.DeveloperName == 'Single_Choice'){
                    qb.Sort__c = singleChoiceNum;
                    singleChoiceList.add(qb);
                    singleChoiceNum += 1;
                }else if(qqb.Question_Bank__r.RecordType.DeveloperName == 'Multiple_Choice'){
                    qb.Sort__c = multipleChoiceNum;
                    multipleChoiceList.add(qb);
                    multipleChoiceNum += 1;
                }else if(qqb.Question_Bank__r.RecordType.DeveloperName == 'Judgment_Question'){
                    qb.Sort__c = judgmentQuestionNum;
                    judgmentQuestionList.add(qb);
                    judgmentQuestionNum += 1;
                }else if(qqb.Question_Bank__r.RecordType.DeveloperName == 'Subjective_Questions'){
                    qb.Sort__c = subjectiveQuestionNum;
                    subjectiveQuestionList.add(qb);
                    subjectiveQuestionNum += 1;
                }
                questionAnswerMap.put(qqb.Question_Bank__c, '');
            }
            out.singleChoiceList = singleChoiceList;
            out.multipleChoiceList = multipleChoiceList;
            out.judgmentQuestionList = judgmentQuestionList;
            out.subjectiveQuestionList = subjectiveQuestionList;
            out.questionAnswerMap = questionAnswerMap;
            out.isSuccess = true;

            return out;
        }catch (Exception e) {
            OutPut out = new OutPut();
            out.isSuccess = false;
            out.msg = Label.Failed_To_Initialize; // '初始化页面失败';
            return out;    
        }  
	}

    /**
     * @description: 页面TrainingExaminationLWC，保存考试试题
     * @return {*}
     */      
    @AuraEnabled
	public static OutPut saveData(Map<Id, String> questionAnswerMap, Training_Task__c trainingTask) {
        try {
            OutPut out = new OutPut();
            // 分数
            Decimal score = 0;
            Decimal num;
            // 是否有主观题，有则不计算分数
            Boolean isHaveSubjectiveQuestions = false;
            
            // 答题历史表
            List<Training_Answer_History__c> insertTrainingAnswerHistoryList = new List<Training_Answer_History__c>();
            // 获取题库信息
            // List<Question_Bank__c> qbList = [SELECT id, RecordType.DeveloperName, Title__c,
            //                                 Choice_A__c, Choice_B__c, Choice_C__c, Choice_D__c,
            //                                 Single_Answer__c, Multiple_Choice_Answer__c, True_answer__c, Score__c
            //                                 FROM Question_Bank__c WHERE Id in :questionAnswerMap.keySet()];
            List<Questionnaire_Question_Bank__c> qbList = [SELECT id, Question_Bank__r.RecordType.DeveloperName, Question_Bank__c, Question_Bank__r.Title__c,
                                                            Question_Bank__r.Choice_A__c, Question_Bank__r.Choice_B__c, Question_Bank__r.Choice_C__c, Question_Bank__r.Choice_D__c,
                                                            Question_Bank__r.Single_Answer__c, Question_Bank__r.Multiple_Choice_Answer__c, Question_Bank__r.True_answer__c, 
                                                            Question_Bank__r.Sort__c, Question_Bank__r.Score__c, Score__c
                                                            FROM Questionnaire_Question_Bank__c WHERE Question_Bank__c IN :questionAnswerMap.keySet()
                                                            // YYL
                                                            // FROM Questionnaire_Question_Bank__c WHERE Training_Task__c = :trainingTask.id AND Question_Bank__c IN :questionAnswerMap.keySet()
                                                            ];
            // 题库集合
            Map<Id, Questionnaire_Question_Bank__c> qbMap = new Map<Id, Questionnaire_Question_Bank__c>();
            for(Questionnaire_Question_Bank__c qb : qbList){
                qbMap.put(qb.Question_Bank__c, qb);
            }

            // 获取Training_Task_User__c 信息
            List<Training_Task_User__c> ttuList = [SELECT id,Examinations_Number__c,Score__c FROM Training_Task_User__c WHERE Training_Task__c = :trainingTask.Id AND User__c = :System.UserInfo.getUserId() LIMIT 1];
            Training_Task_User__c ttu = new Training_Task_User__c();

            if(ttuList != null){
                ttu = ttuList[0];

                num = ttu.Examinations_Number__c==null? 0:ttu.Examinations_Number__c;
                ttu.Examinations_Number__c = num + 1;
                
                // 匹配题库信息
                for(String questionId : questionAnswerMap.keySet()){
                    // 答案是否正确
                    Boolean isTrue = false;
                    Boolean isSubjectiveQuestions = false;
                    Questionnaire_Question_Bank__c qb = qbMap.get(questionId);

                    Training_Answer_History__c tah = new Training_Answer_History__c();
                    tah.Question_Bank__c = qb.Question_Bank__c;
                    tah.Questionnaire_Question_Bank__c = qb.id;
                    tah.Training_Task_User__c = ttu.id;
                    tah.Title__c = qb.Question_Bank__r.Title__c;
                    tah.Choice_A__c = qb.Question_Bank__r.Choice_A__c;
                    tah.Choice_B__c = qb.Question_Bank__r.Choice_B__c;
                    tah.Choice_C__c = qb.Question_Bank__r.Choice_C__c;
                    tah.Choice_D__c = qb.Question_Bank__r.Choice_D__c;
                    tah.User_Answer__c = questionAnswerMap.get(questionId);
                    tah.Training_Task__c = trainingTask.Id;
                    tah.User__c = System.UserInfo.getUserId();
                    tah.Question_Score__c = qb.Score__c;
                    tah.Record_Type__c = qb.Question_Bank__r.RecordType.DeveloperName;
                    if(qb.Question_Bank__r.RecordType.DeveloperName == 'Single_Choice'){
                        if(qb.Question_Bank__r.Single_Answer__c == questionAnswerMap.get(questionId)){
                            isTrue = true;
                        }
                        tah.Answer__c = qb.Question_Bank__r.Single_Answer__c;
                    }else if(qb.Question_Bank__r.RecordType.DeveloperName == 'Multiple_Choice'){
                        if(qb.Question_Bank__r.Multiple_Choice_Answer__c == questionAnswerMap.get(questionId)){
                            isTrue = true;
                        }
                        tah.Answer__c = qb.Question_Bank__r.Multiple_Choice_Answer__c;
                    }else if(qb.Question_Bank__r.RecordType.DeveloperName == 'Judgment_Question' ){
                        if(qb.Question_Bank__r.True_answer__c == questionAnswerMap.get(questionId)){
                            isTrue = true;
                        }
                        tah.Answer__c = qb.Question_Bank__r.True_answer__c;
                    }else if(qb.Question_Bank__r.RecordType.DeveloperName == 'Subjective_Questions' ){
                        isHaveSubjectiveQuestions = true;
                        isSubjectiveQuestions = true;
                        tah.Subjective_Questions_Answer__c = questionAnswerMap.get(questionId);
                    }

                    if(isTrue){
                        score += Integer.valueOf(qb.Score__c);
                        tah.Answer_Score__c = qb.Score__c;
                    }else if(!isSubjectiveQuestions){
                        tah.Answer_Score__c = 0;
                    }
                    tah.Examinations_Number__c = ttu.Examinations_Number__c;
                    insertTrainingAnswerHistoryList.add(tah); 
                }

                ttu.The_Highest_Score__c = ttu.Examinations_Number__c;

                if((ttu.Score__c == null || ttu.Score__c <= score) && !isHaveSubjectiveQuestions){
                    ttu.Score__c = score;
                    out.msg = Label.The_Resulting_Score + score; // '所得分数为'
                }else if(isHaveSubjectiveQuestions){
                    out.msg = Label.Wait_Trainer_Score; // '等待培训师评分！';
                }
                if(ttu.Examinations_Number__c > 2){
                    ttu.Additional_Examination__c = false;
                }
                Database.update(ttu);
                // 保存用户答题到库存表中
                Database.insert(insertTrainingAnswerHistoryList);

                out.isSuccess = true;
                
            }else{
                out.isSuccess = false;
                out.msg =  Label.Commit_Failure; //'提交失败';
            }
            return out;
        }catch (Exception e) {
            OutPut out = new OutPut();
            out.isSuccess = false;
            out.msg =  Label.Commit_Failure; //'提交失败';
            return out;    
        }  
    }

    /**
     * @description: 页面ExaminationLWC，保存考试试题
     * @return {*}
     */      
    @AuraEnabled
	public static OutPut saveDataExamination(Map<Id, String> questionAnswerMap, Examination__c examination) {
        try {
            OutPut out = new OutPut();
            // 分数
            Decimal score = 0;
            Decimal num;
            // 是否有主观题，有则不计算分数
            Boolean isHaveSubjectiveQuestions = false;
            
            // 答题历史表
            List<Training_Answer_History__c> insertTrainingAnswerHistoryList = new List<Training_Answer_History__c>();
            // 获取题库信息
            List<Questionnaire_Question_Bank__c> qbList = [SELECT id, Question_Bank__r.RecordType.DeveloperName, Question_Bank__c, Question_Bank__r.Title__c,
                                                            Question_Bank__r.Choice_A__c, Question_Bank__r.Choice_B__c, Question_Bank__r.Choice_C__c, Question_Bank__r.Choice_D__c,
                                                            Question_Bank__r.Single_Answer__c, Question_Bank__r.Multiple_Choice_Answer__c, Question_Bank__r.True_answer__c, 
                                                            Question_Bank__r.Sort__c, Question_Bank__r.Score__c, Score__c
                                                            // YYL
                                                            FROM Questionnaire_Question_Bank__c WHERE Examination__c = :examination.id AND Question_Bank__c IN :questionAnswerMap.keySet()
                                                            ];
            // 题库集合
            Map<Id, Questionnaire_Question_Bank__c> qbMap = new Map<Id, Questionnaire_Question_Bank__c>();
            for(Questionnaire_Question_Bank__c qb : qbList){
                qbMap.put(qb.Question_Bank__c, qb);
            }

            // 匹配题库信息
            for(String questionId : questionAnswerMap.keySet()){
                // 答案是否正确
                Boolean isTrue = false;
                Boolean isSubjectiveQuestions = false;
                Questionnaire_Question_Bank__c qb = qbMap.get(questionId);

                Training_Answer_History__c tah = new Training_Answer_History__c();
                tah.Question_Bank__c = qb.Question_Bank__c;
                tah.Questionnaire_Question_Bank__c = qb.id;
                // tah.Training_Task_User__c = ttu.id;
                tah.Title__c = qb.Question_Bank__r.Title__c;
                tah.Choice_A__c = qb.Question_Bank__r.Choice_A__c;
                tah.Choice_B__c = qb.Question_Bank__r.Choice_B__c;
                tah.Choice_C__c = qb.Question_Bank__r.Choice_C__c;
                tah.Choice_D__c = qb.Question_Bank__r.Choice_D__c;
                tah.User_Answer__c = questionAnswerMap.get(questionId);
                tah.Examination__c = examination.Id;
                tah.User__c = System.UserInfo.getUserId();
                tah.Question_Score__c = qb.Score__c;
                tah.Record_Type__c = qb.Question_Bank__r.RecordType.DeveloperName;
                if(qb.Question_Bank__r.RecordType.DeveloperName == 'Single_Choice'){
                    if(qb.Question_Bank__r.Single_Answer__c == questionAnswerMap.get(questionId)){
                        isTrue = true;
                    }
                    tah.Answer__c = qb.Question_Bank__r.Single_Answer__c;
                }else if(qb.Question_Bank__r.RecordType.DeveloperName == 'Multiple_Choice'){
                    if(qb.Question_Bank__r.Multiple_Choice_Answer__c == questionAnswerMap.get(questionId)){
                        isTrue = true;
                    }
                    tah.Answer__c = qb.Question_Bank__r.Multiple_Choice_Answer__c;
                }else if(qb.Question_Bank__r.RecordType.DeveloperName == 'Judgment_Question' ){
                    if(qb.Question_Bank__r.True_answer__c == questionAnswerMap.get(questionId)){
                        isTrue = true;
                    }
                    tah.Answer__c = qb.Question_Bank__r.True_answer__c;
                }else if(qb.Question_Bank__r.RecordType.DeveloperName == 'Subjective_Questions' ){
                    isHaveSubjectiveQuestions = true;
                    isSubjectiveQuestions = true;
                    tah.Subjective_Questions_Answer__c = questionAnswerMap.get(questionId);
                }

                if(isTrue){
                    score += Integer.valueOf(qb.Score__c);
                    tah.Answer_Score__c = qb.Score__c;
                }else if(!isSubjectiveQuestions){
                    tah.Answer_Score__c = 0;
                }
                // tah.Examinations_Number__c = ttu.Examinations_Number__c;
                insertTrainingAnswerHistoryList.add(tah); 
            }

            // 保存用户答题到库存表中
            Database.insert(insertTrainingAnswerHistoryList);

            out.isSuccess = true;
            return out;
        }catch (Exception e) {
            OutPut out = new OutPut();
            out.isSuccess = false;
            out.msg =  Label.Commit_Failure; //'提交失败';
            return out;    
        }  
    }

    /**
     * @description: 页面TrainingTaskSignInLWC
     * @return {}
     */
    @AuraEnabled
	public static SignInOutPut checkTrainingTaskTime(Id recordId) {
        SignInOutPut out = new SignInOutPut();
        out.isCanSignIn = false;
        out.isHaveSignIn = false;
        Training_Personnel__c tp = [SELECT id, Training_Time__c, Check_in_Time__c, Training_Task__r.Task_Status__c FROM Training_Personnel__c WHERE Id =:recordId LIMIT 1];
        if(tp.Training_Task__r.Task_Status__c != '发布'){
			out.isSuccess = false;
			out.msg = Label.Training_Task_Unpublish; // '培训任务未发布！';
            return out;
		}
        if(tp.Training_Time__c == null){
			out.isSuccess = false;
			out.msg = Label.No_Sign_In; // '培训任务未发布！';
            return out;
		}
        Datetime trainingTime = tp.Training_Time__c;
        if(Datetime.now() >= trainingTime.addHours(-1) && trainingTime.date() == Date.today() && tp.Check_in_Time__c == null){
            out.isCanSignIn = true;
        }else if(tp.Check_in_Time__c != null){
            out.isHaveSignIn = true;
        }
        out.trainingTaskTimeDate = trainingTime.date();
        out.trainingTaskTime = trainingTime.format('yyyy-MM-dd HH:mm:ss');
        out.trainingTaskTimeCheck = trainingTime.addHours(-1).format('yyyy-MM-dd HH:mm:ss');
        out.isSuccess = true;
        return out;
    }

    /**
     * @description: 页面TrainingTaskSignInLWC，培训任务签到日期
     * @return {*}
     */    
    @AuraEnabled
	public static OutPut setSignInTime(Id recordId) {
        OutPut out = new OutPut();
        Training_Personnel__c tp = [SELECT id,Training_Task_User__c FROM Training_Personnel__c WHERE Id =:recordId LIMIT 1];
        Training_Task_User__c ttu = new Training_Task_User__c(Id = tp.Training_Task_User__c);
        ttu.Check_in_Time__c = Datetime.now();
        Database.update(ttu);
        out.isSuccess = true;
        return out;
    }

    /**
     * @description: 页面TrainingTaskEvaluationLWC，获取培训任务评价
     * @return {*}
     */    
    @AuraEnabled
	public static EvaluationOutPut getTrainingTaskEvaluation(Id recordId) {
        EvaluationOutPut out = new EvaluationOutPut();
        Training_Personnel__c tp = [SELECT Id, Training_Task__c, Training_Task__r.Task_Status__c FROM Training_Personnel__c WHERE Id =:recordId LIMIT 1];
        if(tp.Training_Task__r.Task_Status__c != '发布'){
			out.isSuccess = false;
			out.msg = Label.Training_Task_Unpublish; // '培训任务未发布！';
            return out;
		}

        List<Training_Task_Evaluation__c> tteList = [SELECT Id,Training_Task__c, Evaluation__c FROM Training_Task_Evaluation__c WHERE Training_Task__c =:tp.Training_Task__c LIMIT 1];
        if(tteList != null && tteList.size() > 0){
            Training_Task_Evaluation__c tte = tteList[0];
            out.isHaveEvaluation = true;
            out.trainingTaskEvaluation = tte;
            List<Training_Task_Evaluation_Reply__c> tterList = [SELECT 
                                                                Id, Training_Task_Evaluation__c, Reply__c 
                                                                FROM Training_Task_Evaluation_Reply__c    
                                                                WHERE Training_Task_Evaluation__c =: tte.Id 
                                                                AND CreatedById = :System.UserInfo.getUserId()
                                                                ];
            if(tterList != null && tterList.size() > 0){
                out.isHaveEvaluationReply = true;
                out.trainingTaskEvaluationReply = tterList[0];
            }
        }else {
            out.isHaveEvaluation = false;
            out.isHaveEvaluationReply = false;
        }
        out.isSuccess = true;
        return out;
    }

    /**
     * @description: 页面TrainingTaskEvaluationLWC，保存培训任务评价回复
     * @return {*}
     */    
    @AuraEnabled
	public static EvaluationOutPut saveEvaluationReply(Id trainingTaskEvaluationId, Id trainingTaskEvaluationReplyId, String comments) {
        EvaluationOutPut out = new EvaluationOutPut();
        Training_Task_Evaluation_Reply__c tter = new Training_Task_Evaluation_Reply__c();
        if(trainingTaskEvaluationReplyId == null){
            tter.Training_Task_Evaluation__c = trainingTaskEvaluationId;
        }else {
            tter.id = trainingTaskEvaluationReplyId;
        }
        tter.Reply__c = comments;
        Database.upsert(tter);
        return out;
    }

    /**
     * @description: 页面TrainingTaskEvaluationLWC，删除评价回复
     * @return {*}
     */    
    @AuraEnabled
	public static EvaluationOutPut deleteEvaluationReply(Id trainingTaskEvaluationReplyId) {
        EvaluationOutPut out = new EvaluationOutPut();
        Database.delete(trainingTaskEvaluationReplyId);
        return out;
    }

    /**
    * @description: 页面TrainingTaskPublishNoticeLWC，验证是否可以发布通知
    * @return {*}
    */    
    @AuraEnabled
	public static OutPut verifyPublishNotice(Id recordId) {
        OutPut out = new OutPut();
        // 审批通过才能发布培训任务
        Training_Task__c tt = [SELECT Id, Approval_Status__c, Task_Status__c FROM Training_Task__c WHERE Id =:recordId LIMIT 1];
        if(tt.Approval_Status__c != 'Approved'){
            out.isSuccess = false;
            out.msg = Label.Training_Task_Publish_After_Approval; // '培训任务审批通过才能发布！';
            return out;
        }
        // 查询培训人员
        List<Training_Personnel__c> tpList = [SELECT Id,Owner.Email FROM Training_Personnel__c WHERE Training_Task__c  =:recordId];
        if(tpList == null || tpList.size() == 0){
            out.isSuccess = false;
            out.msg = Label.No_Training_User_Added; // '未添加培训人员！';
            return out;
        }
        out.isSuccess = true;
        return out;
    }

    /**
    * @description: 页面trainingTaskUserAddAllLWC，验证
    * @return {*}
    */    
    @AuraEnabled
	public static OutPut verifyAddAllUser(Id recordId) {
        OutPut out = new OutPut();
        out.isSuccess = true;
        return out;
    }

    /**
     * @description: 页面TrainingTaskPublishNoticeLWC，发布通知
     * @return {*}
     */    
    @AuraEnabled
	public static OutPut publishNotice(Id recordId) {
        try {
            OutPut out = new OutPut();
            // 审批通过才能发布培训任务
            Training_Task__c tt = [SELECT Id, Approval_Status__c, Task_Status__c FROM Training_Task__c WHERE Id =:recordId LIMIT 1];
            if(tt.Approval_Status__c != 'Approved'){
                out.isSuccess = false;
                out.msg = Label.Training_Task_Publish_After_Approval; // '培训任务审批通过才能发布！';
                return out;
            }
            // 查询培训人员
            List<Training_Personnel__c> tpList = [SELECT Id,Owner.Email FROM Training_Personnel__c WHERE Training_Task__c  =:recordId];
            if(tpList == null || tpList.size() == 0){
                out.isSuccess = false;
                out.msg = Label.No_Training_User_Added; // '未添加培训人员！';
                return out;
            }
            for(Training_Personnel__c tp : tpList){
                List<String> toAddresses = new List<String>();
                toAddresses.add(tp.Owner.Email);
                Utility.sendEmailWithTextTemplate(tp.Id, toAddresses, 'TrainingTaskPublishNotice');
            }
            // 更改任务发布状态
            tt.Task_Status__c = '发布';
            Database.update(tt);
            out.isSuccess = true;
            out.msg = Label.Publishing_Succeeded; // '发布通知成功！';
            return out;
        } catch (Exception e) {
            OutPut out = new OutPut();
            out.isSuccess = false;
            out.msg = Label.Publishing_Failure; //'发布通知失败！';
            return out;
        }
    }

    /**
     * @description: 页面TrainingTaskUnpublishNoticeLWC，发布通知
     * @return {*}
     */    
    @AuraEnabled
	public static OutPut unpublishNotice(Id recordId) {
        
        OutPut out = new OutPut();
        Training_Task__c tt = new Training_Task__c(Id = recordId);
        // 更改任务发布状态
        tt.Task_Status__c = '未发布';
        Database.update(tt);
        out.isSuccess = true;
        out.msg = Label.Unpublish_Notification_Successful; // '取消发布通知成功！';
        return out;
    }

    /**
     * @description: 页面trainingUserExaminationLWC，初始化培训人员考试试题
     * @return {*}
     */    
    @AuraEnabled
	public static QuestionBankOut initTrainingUserExamination(Id recordId) {
        try{
            QuestionBankOut out = new QuestionBankOut();
            Training_Task_User__c ttu = [SELECT Training_Task__c, The_Highest_Score__c, Score__c, Examinations_Number__c FROM Training_Task_User__c WHERE id = :recordId LIMIT 1];
            recordId = ttu.Training_Task__c;
            if(ttu.Score__c == null && (ttu.Examinations_Number__c == null || ttu.Examinations_Number__c == 0)){
                out.isSuccess = false;
                return out;
            }
            List<Training_Task__c> ttList = [SELECT Id, Name, Training_Content__c FROM Training_Task__c WHERE id = :recordId LIMIT 1];
            if(ttList != null && ttList.size() > 0){
                out.trainingTask = ttList[0];
            }
            // 获取答题历史
            List<Training_Answer_History__c> tahList = [SELECT Id, Examinations_Number__c, Training_Task_User__c, User_Answer__c, Answer__c, 
                                                            Question_Bank__r.RecordType.DeveloperName, Question_Bank__c, Question_Bank__r.Title__c, 
                                                            Question_Bank__r.Choice_A__c, Question_Bank__r.Choice_B__c, Question_Bank__r.Choice_C__c, Question_Bank__r.Choice_D__c, 
                                                            Question_Bank__r.Sort__c, Question_Bank__r.Score__c, Question_Score__c, 
                                                            Question_Bank__r.Single_Answer__c, Question_Bank__r.Multiple_Choice_Answer__c, 
                                                            Question_Bank__r.True_answer__c, Subjective_Questions_Answer__c, Answer_Score__c
                                                        FROM Training_Answer_History__c 
                                                        WHERE Training_Task_User__c  = :ttu.Id 
                                                        ORDER BY Examinations_Number__c, Question_Bank__r.RecordType.name desc] ;
            List<QuestionBankList> questionBankList = new List<QuestionBankList>();

            for(Integer i = 1; i <= Integer.valueOf(ttu.Examinations_Number__c); i++) {
                QuestionBankList qbl = new QuestionBankList();
                List<QuestionBank> singleChoiceList = new List<QuestionBank>();    
                List<QuestionBank> multipleChoiceList = new List<QuestionBank>();
                List<QuestionBank> judgmentQuestionList = new List<QuestionBank>();
                List<QuestionBank> subjectiveQuestionList = new List<QuestionBank>();
                Map<Id, String> questionAnswerScoreMap = new Map<Id, String>();
                qbl.haveSingleChoiceList = false;
                qbl.haveMultipleChoiceList = false;
                qbl.haveJudgmentQuestionList = false;
                qbl.haveSubjectiveQuestionList = false;
                qbl.answerLabel = Label.Answer_Tab + '(' + i + ')'; // 答题
                if(i == Integer.valueOf(ttu.Examinations_Number__c)){
                    qbl.activeSectionName = 'A';
                }
                Integer singleChoiceNum = 1;
                Integer multipleChoiceNum = 1;
                Integer judgmentQuestionNum = 1;
                Integer subjectiveQuestionNum = 1;
                for(Training_Answer_History__c tah : tahList){
                    if(Integer.valueOf(tah.Examinations_Number__c) == i){
                        QuestionBank qb = new QuestionBank();
                        qb.id = tah.Id;
                        qb.title = tah.Question_Bank__r.Title__c;
                        qb.answer = tah.Answer__c;
                        qb.userAnswer = tah.User_Answer__c;
                        qb.choiceA = tah.Question_Bank__r.Choice_A__c;
                        qb.choiceB = tah.Question_Bank__r.Choice_B__c;
                        qb.choiceC = tah.Question_Bank__r.Choice_C__c;
                        qb.choiceD = tah.Question_Bank__r.Choice_D__c;
                        qb.score = tah.Question_Score__c;
                        qb.answerScore = tah.Answer_Score__c;
                        qb.isChoiceA = false;
                        qb.isChoiceB = false;
                        qb.isChoiceC = false;
                        qb.isChoiceD = false;
                        qb.correctAnswer = false;
                        questionAnswerScoreMap.put(tah.Id, tah.Answer_Score__c != null ? String.valueOf(tah.Answer_Score__c) : '');
                        if(tah.Answer__c == tah.User_Answer__c){
                            qb.correctAnswer = true;
                        }
                        if(tah.Question_Bank__r.RecordType.DeveloperName == 'Single_Choice'){
                            qb.questionNumber = singleChoiceNum;
                            if(tah.User_Answer__c == 'A'){
                                qb.isChoiceA = true;
                            }else if(tah.User_Answer__c == 'B'){
                                qb.isChoiceB = true;
                            }else if(tah.User_Answer__c == 'C'){
                                qb.isChoiceC = true;
                            }else if(tah.User_Answer__c == 'D'){
                                qb.isChoiceD = true;
                            }
                            singleChoiceList.add(qb);
                            singleChoiceNum += 1;
                            qbl.haveSingleChoiceList = true;
                        }else if(tah.Question_Bank__r.RecordType.DeveloperName == 'Multiple_Choice'){
                            qb.questionNumber = multipleChoiceNum;
                            if(tah.User_Answer__c.contains('A')){
                                qb.isChoiceA = true;
                            }
                            if(tah.User_Answer__c.contains('B')){
                                qb.isChoiceB = true;
                            }
                            if(tah.User_Answer__c.contains('C')){
                                qb.isChoiceC = true;
                            }
                            if(tah.User_Answer__c.contains('D')){
                                qb.isChoiceD = true;
                            }
                            multipleChoiceList.add(qb);
                            multipleChoiceNum += 1;
                            qbl.haveMultipleChoiceList = true;
                        }else if(tah.Question_Bank__r.RecordType.DeveloperName == 'Judgment_Question'){
                            qb.questionNumber = judgmentQuestionNum;
                            qb.judgmentUserAnswer = Boolean.valueOf(tah.User_Answer__c);
                            judgmentQuestionList.add(qb);
                            judgmentQuestionNum += 1;
                            qbl.haveJudgmentQuestionList = true;
                        }else if(tah.Question_Bank__r.RecordType.DeveloperName == 'Subjective_Questions'){
                            qb.questionNumber = subjectiveQuestionNum;
                            qb.subjectiveUserAnswer = tah.Subjective_Questions_Answer__c;
                            subjectiveQuestionList.add(qb);
                            subjectiveQuestionNum += 1;
                            qbl.haveSubjectiveQuestionList = true;
                        }
                    }
                }
                qbl.singleChoiceList = singleChoiceList;
                qbl.multipleChoiceList = multipleChoiceList;
                qbl.judgmentQuestionList = judgmentQuestionList;
                qbl.subjectiveQuestionList = subjectiveQuestionList;
                qbl.questionAnswerScoreMap = questionAnswerScoreMap;
                questionBankList.add(qbl);
            }
            out.questionBankList = questionBankList;
            out.trainingTaskUser = ttu;
            out.isSuccess = true;

            return out;
        }catch (Exception e) {
            QuestionBankOut out = new QuestionBankOut();
            out.isSuccess = false;
            return out;    
        }  
	}

    /**
     * @description: 页面trainingUserExaminationLWC，保存培训师评分
     * @return {*}
     */    
    @AuraEnabled
	public static QuestionBankOut markSubjectiveQuestions(Map<Id, String> questionAnswerScoreMap, Training_Task_User__c trainingTaskUser) {
        try {
            QuestionBankOut out = new QuestionBankOut();
            Integer score = 0;
            List<Training_Answer_History__c> updateTrainingAnswerHistoryList = new List<Training_Answer_History__c>();
            for(String trainingAnswerHistoryId : questionAnswerScoreMap.keySet()){
                // 答题历史赋值
                Training_Answer_History__c tah = new Training_Answer_History__c(Id = trainingAnswerHistoryId);
                tah.Answer_Score__c = Integer.valueOf(questionAnswerScoreMap.get(trainingAnswerHistoryId));
                updateTrainingAnswerHistoryList.add(tah);
                // 计算总分
                score += Integer.valueOf(questionAnswerScoreMap.get(trainingAnswerHistoryId));
            }

            trainingTaskUser.Score__c = score;
            trainingTaskUser.Mark_Status__c = '已评';
            
            Database.update(updateTrainingAnswerHistoryList);
            Database.update(trainingTaskUser);

            out.isSuccess = true;
            out.msg = Label.Rating_Success_Total_Score + score; // '评分成功！总得分为'
            return out;
        } catch (Exception e) {
            QuestionBankOut out = new QuestionBankOut();
            out.isSuccess = false;
            return out;
        }
    }

    /**
     * @description: 页面trainingTaskCreateExaminationLWC，获取已选择考题
     * @return {*}
     */    
    @AuraEnabled(cacheable=true)
	public static QuestionBankList getSelectedQuestions(Id recordId) { 
        QuestionBankList out = new QuestionBankList();
        List<QuestionBank> singleChoiceList = new List<QuestionBank>();
        List<QuestionBank> multipleChoiceList = new List<QuestionBank>();
        List<QuestionBank> judgmentQuestionList = new List<QuestionBank>();
        List<QuestionBank> subjectiveQuestionList = new List<QuestionBank>();

        // List<Questionnaire_Question_Bank__c> qqbList = [SELECT Id, Title__c, Score__c, Question_Bank_Type__c , Question_Bank_Type_API__c 
        //                                                 FROM Questionnaire_Question_Bank__c WHERE Training_Task__c = :recordId
        //                                                 ORDER BY Question_Bank_Type__c,CreatedDate ];

        // YYL 移除与Training_Task__c绑定关系 20250508
        List<Questionnaire_Question_Bank__c> qqbList = [SELECT Id, Title__c, Score__c, Question_Bank_Type__c , Question_Bank_Type_API__c 
                                                        FROM Questionnaire_Question_Bank__c WHERE Examination__c = :recordId
                                                        ORDER BY Question_Bank_Type__c,CreatedDate ];
                    
        if(qqbList != null && qqbList.size() > 0){
            Integer singleChoiceNum = 1;
            Integer multipleChoiceNum = 1;
            Integer judgmentQuestionNum = 1;
            Integer subjectiveQuestionNum = 1;
            for (Questionnaire_Question_Bank__c qqb : qqbList) {
                QuestionBank qb = new QuestionBank();
                qb.Id = qqb.Id;
                qb.title = qqb.Title__c;
                qb.score = qqb.Score__c;
                if(qqb.Question_Bank_Type_API__c == 'Single_Choice'){
                    qb.questionNumber = singleChoiceNum;
                    singleChoiceList.add(qb);
                    singleChoiceNum += 1;
                }else if(qqb.Question_Bank_Type_API__c == 'Multiple_Choice'){
                    qb.questionNumber = multipleChoiceNum;
                    multipleChoiceList.add(qb);
                    multipleChoiceNum += 1;
                }else if(qqb.Question_Bank_Type_API__c == 'Judgment_Question'){
                    qb.questionNumber = judgmentQuestionNum;
                    judgmentQuestionList.add(qb);
                    judgmentQuestionNum += 1;
                }else if(qqb.Question_Bank_Type_API__c == 'Subjective_Questions'){
                    qb.questionNumber = subjectiveQuestionNum;
                    subjectiveQuestionList.add(qb);
                    subjectiveQuestionNum += 1;
                }  
            } 
        }
        out.singleChoiceList = singleChoiceList;
        out.multipleChoiceList = multipleChoiceList;
        out.judgmentQuestionList = judgmentQuestionList;
        out.subjectiveQuestionList = subjectiveQuestionList;
        
        return out;
    }

    /**
     * @description: 页面trainingTaskCreateExaminationLWC，获取Question_Bank__c的类型
     * @return {*}
     */    
    @AuraEnabled(cacheable=true)
	public static Map<String, String> getQuestionBankRecordType() { 
        Schema.DescribeSObjectResult R = Question_Bank__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        Map<String, String> devNameAndRtIdMap = new Map<String, String>();
        for(Schema.RecordTypeInfo rType : RT) {
            devNameAndRtIdMap.put(rType.getDeveloperName(), rType.getRecordTypeId());
        }
        return devNameAndRtIdMap;
    }

    /**
     * @description: 页面trainingTaskCreateExaminationLWC，选择的试题详情
     * @return {*}
     */    
    @AuraEnabled
	public static Questionnaire_Question_Bank__c checkQuestionInfo(Id recordId) { 
        Questionnaire_Question_Bank__c qqb = [SELECT id, Question_Bank_Type__c, Question_Bank_Type_API__c, Score__c, 
                                                Question_Bank__c, Question_Bank__r.Title__c, 
                                                Question_Bank__r.Choice_A__c, 
                                                Question_Bank__r.Choice_B__c, 
                                                Question_Bank__r.Choice_C__c, 
                                                Question_Bank__r.Choice_D__c, 
                                                Question_Bank__r.Multiple_Choice_Answer__c, 
                                                Question_Bank__r.Single_Answer__c, 
                                                Question_Bank__r.True_answer__c,
                                                Question_Bank__r.Score__c
                                                FROM Questionnaire_Question_Bank__c
                                                WHERE Id =:recordId];
        return qqb;
    }

    /**
     * @description: 页面trainingTaskCreateExaminationLWC，查询题库
     * @return {*}
     */    
    @AuraEnabled
	public static List<Question_Bank__c> searchQuestionBankDatas(Id recordId, String questionType, String titleType, String questionTitle) { 
        List<Question_Bank__c> qbList = new List<Question_Bank__c>();
        // 查询题库，过滤掉已经选择的试题
        String sql = 'SELECT Id, Title_Type__c, Record_Type_Name__c, Title__c FROM Question_Bank__c '+
                        // 'WHERE Id NOT IN (SELECT Question_Bank__c FROM Questionnaire_Question_Bank__c WHERE Training_Task__c = :recordId) ';
                        // YYL 修改试卷绑定逻辑 20250509
                        'WHERE Id NOT IN (SELECT Question_Bank__c FROM Questionnaire_Question_Bank__c WHERE Examination__c = :recordId)';
        if(String.isNotBlank(questionType)){
            sql += ' AND RecordType.DeveloperName = :questionType';
        }
        if(String.isNotBlank(titleType)){
            sql += ' AND Title_Type__c = :titleType';
        }
        if(String.isNotBlank(questionTitle)){
            questionTitle = '%' + questionTitle + '%';
            sql += ' AND Title__c LIKE :questionTitle';
        }
        sql += ' ORDER BY Record_Type_Name__c, Title_Type__c DESC, CreatedDate ';
        qbList = Database.query(sql);
        return qbList;
    }

    /**
     * @description: 页面trainingTaskCreateExaminationLWC，保存试题到培训任务中
     * @return {*}
     */    
    @AuraEnabled
	public static OutPut saveSelectedQuesions(Id recordId, String selectedIds) { 
        OutPut out = new OutPut();
        List<Questionnaire_Question_Bank__c> addList = new List<Questionnaire_Question_Bank__c>();
        Map<Id,Integer> questionMapData = (Map<Id,Integer>)JSON.deserialize(selectedIds, Map<Id,Integer>.class);
        for (Id key : questionMapData.keySet()) {
            Questionnaire_Question_Bank__c qqb = new Questionnaire_Question_Bank__c();

            // YYL 移除与Training_Task__c绑定关系 20250508
            // qqb.Training_Task__c = recordId;
            qqb.Examination__c = recordId;
            qqb.Question_Bank__c = key;
            qqb.Score__c = questionMapData.get(key);
            addList.add(qqb);
        }
        Database.insert(addList);
        out.isSuccess = true;
        return out;
    }

     /**
     * @description: 页面trainingTaskCreateExaminationLWC，删除培训任务中的试题
     * @return {*}
     */    
    @AuraEnabled
	public static OutPut deleteQuestion(Id questionId) { 
        OutPut out = new OutPut();
        Database.Delete(questionId);
        out.isSuccess = true;
        return out;
    }

    /**
     * @description: 页面trainingTaskUserUploadFileLWC，上传培训人员文件
     * @return {*}
     */    
    @AuraEnabled
    public static String saveFile(Id recordId, String fileName, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = bitToString(contentBlob, 'UTF-8');
        content = content.replaceAll('\r\n', '\n');
        content = content.replaceAll('\r', '\n');
        String[] fileLines = content.split('\n');
        System.debug('*** ' + JSON.serialize(fileLines));
        List<Training_Task_User__c> addTrainingTaskUserList = new List<Training_Task_User__c>();
        List<User> userList = [SELECT Id, Username FROM User WHERE Username IN :fileLines AND IsActive = TRUE];
        for (User u : userList) {
            Training_Task_User__c ttu = new Training_Task_User__c();
            ttu.Training_Task__c = recordId;
            ttu.User__c = u.id;
            addTrainingTaskUserList.add(ttu);
        }
        Database.insert(addTrainingTaskUserList, false);
        // inserting file
        // ContentVersion cv = new ContentVersion();
        // cv.Title = fileName;
        // cv.PathOnClient = '/' + fileName;
        // cv.FirstPublishLocationId = recordId;
        // cv.VersionData = EncodingUtil.base64Decode(base64Data);
        // cv.IsMajorVersion = true;
        // Insert cv;
        return 'successfully';
    }

    /**
     * @description: 页面ExaminationUserUploadFileLwc，上传考试人员文件
     * @return {*}
     */    
    @AuraEnabled
    public static OutPut saveFileExamination(Id recordId, List<String[]> fileLines) {

        System.debug('wwwwfileLines' + JSON.serialize(fileLines));
        OutPut output = new OutPut();
        output.isSuccess = true;
        // 循环获取导入邮箱
        if(fileLines != null && fileLines.size() > 0){

            List<String> emailList = new List<String>();
            for(String[] email : fileLines){
                if(isValidLine(email)) {
                    System.debug('XX' + email);
                    emailList.add(email[0].trim());
                }
                // emailList.add(email[0].trim());
            }

            System.debug('wwwwemailList' + JSON.serialize(emailList));
            List<Examination_User__c> addUserList = new List<Examination_User__c>();
            List<User> userList = [SELECT Id, Username, Email FROM User WHERE Email IN :emailList AND IsActive = TRUE];

            System.debug('wwwwuserList' + JSON.serialize(userList));

            // 判断是否查询到用户信息
            if(userList != null && (userList.size() == fileLines.size())){
                for (User u : userList) {
                    Examination_User__c ttu = new Examination_User__c();
                    ttu.Examination__c = recordId;
                    ttu.User__c = u.id;
                    ttu.ExternalId_Key__c = recordId + '_' + u.id;
                    addUserList.add(ttu);
                }
                Database.upsert(addUserList, Examination_User__c.Fields.ExternalId_Key__c , false);
            }else{

                // 根据邮箱分组用户信息
                LisqContainer lcUser = new LisqContainer(userList);
                Map<String,SObject> userMap = lcUser.ToMapS('Email');

                // 拼接未匹配对应的用户信息的邮箱
                String msgError = '';
                String error = 'No user information corresponding to the email was found';
                for(String email : emailList){
                    if(userMap.get(email) == null){
                        msgError += email + '\r';
                    }
                }

                msgError += error;

                String errorFileName = 'error.txt';
                ContentVersion cvError = new ContentVersion();
                cvError.Title = errorFileName + '-ERROR-' + Datetime.now();
                cvError.PathOnClient = '/' + errorFileName;
                cvError.FirstPublishLocationId = UserInfo.getUserId();
                cvError.VersionData = Blob.valueOf(msgError);
                cvError.IsMajorVersion = true;
                Insert cvError;
        
                ContentVersion qrcv = [SELECT Id,VersionDataUrl FROM ContentVersion WHERE Id =:cvError.id];
                output.errorUrl = qrcv.VersionDataUrl;

                output.isSuccess = false;
                output.msg = error;
            }
        }
        
        return output;
    }

    public static Boolean isValidLine(String[] line) {
        if (line == null || line.isEmpty()) {
            return false;
        }
        for (String item : line) {
            if (item != null && !String.isBlank(item)) {
                return true;
            }
        }
        return false;
    }

    /**
     * @description: 页面trainingTaskUserUploadFileLWC，上传培训人员文件
     * @return {*}
     */    
    @AuraEnabled
    public static String saveQuestionBanksFile(String fileName, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'gb2312');
        Blob contentBlob = EncodingUtil.base64Decode(base64Data);
        String content = bitToString(contentBlob, 'gb2312');
        content = content.replaceAll('\r\n', '\n');
        content = content.replaceAll('\r', '\n');
        List<String> fileLines = content.trim().split('\n');
        String singleType = Schema.SObjectType.Question_Bank__c.getRecordTypeInfosByDeveloperName().get('Single_Choice').getRecordTypeId();
        String multipleType = Schema.SObjectType.Question_Bank__c.getRecordTypeInfosByDeveloperName().get('Multiple_Choice').getRecordTypeId();
        String judgmentType = Schema.SObjectType.Question_Bank__c.getRecordTypeInfosByDeveloperName().get('Judgment_Question').getRecordTypeId();
        String subjectiveType = Schema.SObjectType.Question_Bank__c.getRecordTypeInfosByDeveloperName().get('Subjective_Questions').getRecordTypeId();
        List<Question_Bank__c> addQBList = new List<Question_Bank__c>();
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
            Question_Bank__c qb = new Question_Bank__c();
            qb.Title_Type__c = cellList[1];
            qb.Title__c = cellList[2];
            if(cellList[0] == '1'){
                qb.RecordTypeId = singleType;
                qb.Single_Answer__c = cellList[3];
                qb.Choice_A__c = cellList[4];
                qb.Choice_B__c = cellList[5];
                qb.Choice_C__c = cellList[6];
                qb.Choice_D__c = cellList[7];
            }else if(cellList[0] == '2'){
                qb.RecordTypeId = multipleType;
                qb.Multiple_Choice_Answer__c = cellList[3];
                qb.Choice_A__c = cellList[4];
                qb.Choice_B__c = cellList[5];
                qb.Choice_C__c = cellList[6];
                qb.Choice_D__c = cellList[7];
            }else if(cellList[0] == '3'){
                qb.RecordTypeId = judgmentType;
                qb.True_answer__c = cellList[3];
            }else if(cellList[0] == '4'){
                qb.RecordTypeId = subjectiveType;
            }
            addQBList.add(qb);
        }
        Database.insert(addQBList);
        return 'successfully';
    }

    /**
     * @description: 页面trainingTaskUserAppLWC，指派培训人员考试
     * @return {*}
     */    
    @AuraEnabled
    public static String additionalExamination(List<String> trainingTaskUserIds) {
        List<Training_Task_User__c> ttuList = new List<Training_Task_User__c >();
        for(String trainingTaskUserId : trainingTaskUserIds){
            Training_Task_User__c ttu = new Training_Task_User__c(Id = trainingTaskUserId);
            ttu.Additional_Examination__c = true;
            ttuList.add(ttu);
        }
        Database.update(ttuList);
        return 'successfully';
    }

    /**
     * @description: 页面trainingTaskUserAddAllLWC，添加所有培训人员
     * @return {*}
     */    
    @AuraEnabled
    public static String addAllTrainingTaskUser(Id recordId) {
        List<Training_Task_User__c> addTrainingTaskUserList = new List<Training_Task_User__c>();
        // 获取label配置的role
        String trainingTaskProfiles = Label.Training_Task_User_Profiles;
        List<User> userList = [SELECT Id FROM User WHERE Profile.name =:trainingTaskProfiles.split(',') AND IsActive = true];
        for (User u : userList) {
            Training_Task_User__c ttu = new Training_Task_User__c();
            ttu.Training_Task__c = recordId;
            ttu.User__c = u.id;
            addTrainingTaskUserList.add(ttu);
        }
        Database.insert(addTrainingTaskUserList, false);
        return 'successfully';
    }

    /**
     * @description: 页面TrainingTaskCreateExaminationLWC，下载已经添加的人员名单
     */
    @AuraEnabled
    public static List<List<Object>> downLoadViewPersonnel(Id id) {
        // 查询当前问卷添加的人员信息
        List<Examination_User__c> examinationUser = [SELECT Id,User__r.Email FROM Examination_User__c WHERE Examination__c =: id];
        List<List<Object>> returnList = new List<List<Object>>();
        // TODO 标题头 暂无
        List<Object> title = new List<Object>();

        if(examinationUser != null && examinationUser.size() > 0){
            for(Examination_User__c item : examinationUser){
                // 内容
                List<Object> body = new List<Object>();
                body.add(item.User__r.Email);
                returnList.add(body);
            }
        }

        return returnList;
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

    public class OutPut {
        @AuraEnabled
        public Training_Task__c trainingTask {get; set;}

        @AuraEnabled
        public Examination__c examination {get; set;}

        // 导入异常信息下载文件 YYL 20250605
        @AuraEnabled
        public String errorUrl {get; set;}

        @AuraEnabled
        public List<Question_Bank__c> singleChoiceList {get; set;}

        @AuraEnabled
        public List<Question_Bank__c> multipleChoiceList {get; set;}

        @AuraEnabled
        public List<Question_Bank__c> judgmentQuestionList {get; set;}

        @AuraEnabled
        public List<Question_Bank__c> subjectiveQuestionList {get; set;}

        @AuraEnabled
        public Map<Id, String> questionAnswerMap {get; set;}

        @AuraEnabled
        public Boolean isCanAnswer {get; set;}

        @AuraEnabled
        public Boolean exceedance {get; set;}

        @AuraEnabled
		public Boolean isSuccess {get; set;}

		@AuraEnabled
		public String msg {get; set;}

        @AuraEnabled
		public Boolean isPassExamination {get; set;}
    }

    public class SignInOutPut {
        @AuraEnabled
		public Boolean isSuccess {get; set;}

        @AuraEnabled
		public String msg {get; set;}

        @AuraEnabled
        public Boolean isCanSignIn {get; set;}

        @AuraEnabled
        public Boolean isHaveSignIn {get; set;}

        @AuraEnabled
        public String trainingTaskTime {get; set;}

        @AuraEnabled
        public String trainingTaskTimeCheck {get; set;}

        @AuraEnabled
        public Date trainingTaskTimeDate {get; set;}

    }

    public class EvaluationOutPut {
        @AuraEnabled
		public Boolean isSuccess {get; set;}

        @AuraEnabled
		public String msg {get; set;}

        @AuraEnabled
		public Boolean isHaveEvaluation {get; set;}

        @AuraEnabled
		public Boolean isHaveEvaluationReply {get; set;}

        @AuraEnabled
        public Training_Task_Evaluation__c trainingTaskEvaluation {get; set;}

        @AuraEnabled
        public Training_Task_Evaluation_Reply__c trainingTaskEvaluationReply {get; set;}

    }

    public class QuestionBankOut {

        @AuraEnabled
        public Training_Task__c trainingTask {get; set;}

        @AuraEnabled
        public Training_Task_User__c trainingTaskUser {get; set;}

        @AuraEnabled
        public List<QuestionBankList> questionBankList {get; set;}

        @AuraEnabled
		public Boolean isSuccess {get; set;}

		@AuraEnabled
		public String msg {get; set;}
    }

    public class QuestionBankList {
        @AuraEnabled
        public List<QuestionBank> singleChoiceList {get; set;}

        @AuraEnabled
        public List<QuestionBank> multipleChoiceList {get; set;}

        @AuraEnabled
        public List<QuestionBank> judgmentQuestionList {get; set;}

        @AuraEnabled
        public List<QuestionBank> subjectiveQuestionList {get; set;}

        @AuraEnabled
        public Map<Id, String> questionAnswerScoreMap {get; set;}

        @AuraEnabled
		public Boolean haveSingleChoiceList {get; set;}

        @AuraEnabled
		public Boolean haveMultipleChoiceList {get; set;}

        @AuraEnabled
		public Boolean haveJudgmentQuestionList {get; set;}

        @AuraEnabled
		public Boolean haveSubjectiveQuestionList {get; set;}

        @AuraEnabled
		public String answerLabel {get; set;}

        @AuraEnabled
        public String activeSectionName {get; set;}
        
    }

    public class QuestionBank {

        @AuraEnabled
		public String Id {get; set;}

        @AuraEnabled
		public String title {get; set;}

        @AuraEnabled
		public String choiceA {get; set;}

        @AuraEnabled
		public String choiceB {get; set;}

        @AuraEnabled
		public String choiceC {get; set;}

        @AuraEnabled
		public String choiceD {get; set;}

        @AuraEnabled
		public Integer questionNumber {get; set;}

        @AuraEnabled
		public Decimal score {get; set;}

        @AuraEnabled
		public Decimal answerScore {get; set;}

        @AuraEnabled
		public String answer {get; set;}

        @AuraEnabled
		public String userAnswer {get; set;}

        @AuraEnabled
		public String subjectiveUserAnswer {get; set;}

        @AuraEnabled
		public Boolean isChoiceA {get; set;}

        @AuraEnabled
		public Boolean isChoiceB {get; set;}

        @AuraEnabled
		public Boolean isChoiceC {get; set;}

        @AuraEnabled
		public Boolean isChoiceD {get; set;}

        @AuraEnabled
		public Boolean judgmentUserAnswer {get; set;}

        @AuraEnabled
		public Boolean correctAnswer {get; set;}
    }
   
}