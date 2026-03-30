import { LightningElement, api, track, wire  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sheetJS from '@salesforce/resourceUrl/sheetJS';
import {loadScript} from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import getSelectedQuestions from '@salesforce/apex/TrainingExaminationController.getSelectedQuestions';
import searchQuestionBankDatas from '@salesforce/apex/TrainingExaminationController.searchQuestionBankDatas';
import saveSelectedQuesions from '@salesforce/apex/TrainingExaminationController.saveSelectedQuesions';
import deleteQuestion from '@salesforce/apex/TrainingExaminationController.deleteQuestion';
import checkQuestionInfo from '@salesforce/apex/TrainingExaminationController.checkQuestionInfo';
import getQuestionBankRecordType from '@salesforce/apex/TrainingExaminationController.getQuestionBankRecordType';
import downLoadViewPersonnel from '@salesforce/apex/TrainingExaminationController.downLoadViewPersonnel';
import { refreshApex } from '@salesforce/apex';
import Title_Type from '@salesforce/label/c.Title_Type';
import Single_Choice_Question from '@salesforce/label/c.Single_Choice_Question';
import Multiple_Choice_Question from '@salesforce/label/c.Multiple_Choice_Question';
import Judgment_Question from '@salesforce/label/c.Judgment_Question';
import Subjective_Questions from '@salesforce/label/c.Subjective_Questions';
import Score_Modified_Successfully from '@salesforce/label/c.Score_Modified_Successfully';
import Test_Add_Successfully from '@salesforce/label/c.Test_Add_Successfully';
import Test_Add_Failed from '@salesforce/label/c.Test_Add_Failed';
import Test_Deleted_Successfully from '@salesforce/label/c.Test_Deleted_Successfully';
import Test_Deleted_Failed from '@salesforce/label/c.Test_Deleted_Failed';
import Selected_Questions from '@salesforce/label/c.Selected_Questions';
import Add_From_Question_Banks from '@salesforce/label/c.Add_From_Question_Banks';
import New_Question_Bank from '@salesforce/label/c.New_Question_Bank';
import Share_Question_Bank from '@salesforce/label/c.Share_Question_Bank';
import Training_Task_Update from '@salesforce/label/c.Training_Task_Update';
import Training_Task_Details from '@salesforce/label/c.Training_Task_Details';
import Training_Task_Delete from '@salesforce/label/c.Training_Task_Delete';
import Training_Task_Cancel from '@salesforce/label/c.Training_Task_Cancel';
import Training_Task_Submit from '@salesforce/label/c.Training_Task_Submit';
import View_Personnel from '@salesforce/label/c.View_Personnel';

export default class TrainingTaskCreateExaminationLWC extends NavigationMixin(LightningElement) {
    label ={
        Title_Type, // 试题类型
        Single_Choice_Question, // 单选题
        Multiple_Choice_Question, // 多选题
        Judgment_Question, // 判断题
        Subjective_Questions, // 主观题
        Score_Modified_Successfully, // 分数修改成功！
        Test_Add_Successfully, // 试题添加成功！
        Test_Add_Failed, // 试题添加失败！
        Test_Deleted_Successfully, // 试题添加失败！
        Test_Deleted_Failed, // 试题添加失败！
        Selected_Questions, // 已选试题
        Add_From_Question_Banks, // Add_From_Question_Banks
        New_Question_Bank, // New_Question_Bank
        Training_Task_Update, // 修改
        Training_Task_Details, // 详情
        Training_Task_Delete, // 删除
        Training_Task_Cancel, // 取消
        Training_Task_Submit, // 提交
        Share_Question_Bank, //分享
        View_Personnel, //人员名单
    }
    @api recordId;

    @track questionBankList;// 试卷集合
    @track singleChoiceList;
    @track multipleChoiceList;
    @track judgmentQuestionList;
    @track subjectiveQuestionList;
    @track singleChoiceListLabel = this.label.Single_Choice_Question; // '单选题'
    @track multipleChoiceListLabel = this.label.Multiple_Choice_Question; // '多选题'
    @track judgmentQuestionListLabel = this.label.Judgment_Question; // '判断题'
    @track subjectiveQuestionListLabel = this.label.Subjective_Questions; // '主观题'

    @track isShowEditSelectQuestionScore = false;
    @track isShowSpinnerEditQuestionScore = false;
    @track isShowSpinnerMax = false;
    @track isQuestionInfoOpen = false;
    @track isShowSpinner = false;
    @track isNewQuestionModalOpen = false;
    @track questionBankDatas;// 查询题库
    @track questionType;
    @track titleType;
    @track questionTitle;
    @track selectedQuestionIds = {};
    @track selectedQuestionOK = [];
    @track isCanSave = false;

    @track isShowShareQuestion = false;
    @track isShowSelectQuestionType = false;
    @track isShowSelectQuestionInfo = false;
    @track isChoice = false;
    @track isSingleChoice = false;
    @track isMultipleChoice = false;
    @track isJudgmentQuestion = false;
    @track Question_Bank__c;
    @track Score__c;
    @track questionRecordTypeMap = {};
    @track selectQuestionRecordType = 'Single_Choice';

    // 下一步新建试题
    @track isChoiceNew = false;
    @track isSingleChoiceNew = false;
    @track isMultipleChoiceNew = false;
    @track isJudgmentQuestionNew = false;
    @track newQuestionScore;
    @track isShowSpinnerCreateQuestion = false;

    @track editQuestionnaireQuestionBank;

    @track columns = [
        {
            label: 'Question Type',
            fieldName: 'Record_Type_Name__c',
            type: 'text',
            hideDefaultActions : true,
            initialWidth : 200,
        },
        {
            label: 'Title Type',
            fieldName: 'Title_Type__c',
            type: 'text',
            hideDefaultActions : true,
            initialWidth : 200,
        },
        {
            label: 'Title',
            fieldName: 'Title__c',
            type: 'text',
            hideDefaultActions : true,
            // initialWidth : 700,
        },
        {
            label: 'Score',
            fieldName: 'Score__c',
            type: 'text',
            hideDefaultActions : true,
            initialWidth : 100,
            editable: true,
        },
        {
            label: '',
            fieldName: '',
            type: 'text',
            hideDefaultActions : true,
            initialWidth : 10,
        }
    ];

    questionTypeOptions = [
        {
            value: '',
            label: '--None--',
        },
        {
            value: 'Single_Choice',
            label: this.label.Single_Choice_Question,
        },
        {
            value: 'Multiple_Choice',
            label: this.label.Multiple_Choice_Question,
        },
        {
            value: 'Judgment_Question',
            label: this.label.Judgment_Question,
        },
        {
            value: 'Subjective_Questions',
            label: this.label.Subjective_Questions,
        },
    ];

    get titleTypeOptions(){
        const titleType = this.label.Title_Type.split(',');
        let titleTypeData = [];
        titleTypeData.push({ label: '--None--', value: ''});
        titleType.forEach(element => {
            const option = {
                label: element,
                value: element
            };
            titleTypeData.push(option);
        });
        return titleTypeData;
    }

    questionTypeValue = 'Single_Choice';
    get questionRecordTypeOptions() {
        return [
            {
                value: 'Single_Choice',
                label: this.label.Single_Choice_Question,
            },
            {
                value: 'Multiple_Choice',
                label: this.label.Multiple_Choice_Question,
            },
            {
                value: 'Judgment_Question',
                label: this.label.Judgment_Question,
            },
            {
                value: 'Subjective_Questions',
                label: this.label.Subjective_Questions,
            },
        ];
    }
    
    wiredResult;
    @wire(getSelectedQuestions, { recordId: "$recordId" })
    getDocuments(result) {
        this.wiredResult = result;
        if (result.data) {
            this.questionBankList = result.data;
            this.singleChoiceList = result.data.singleChoiceList;
            this.multipleChoiceList = result.data.multipleChoiceList;
            this.judgmentQuestionList = result.data.judgmentQuestionList;
            this.subjectiveQuestionList = result.data.subjectiveQuestionList;
            this.singleChoiceListLabel = this.label.Single_Choice_Question + ' (' + result.data.singleChoiceList.length + ')';
            this.multipleChoiceListLabel = this.label.Multiple_Choice_Question + ' (' + result.data.multipleChoiceList.length + ')';
            this.judgmentQuestionListLabel = this.label.Judgment_Question + ' (' + result.data.judgmentQuestionList.length + ')';
            this.subjectiveQuestionListLabel = this.label.Subjective_Questions + ' (' + result.data.subjectiveQuestionList.length + ')';
        }
    }

    connectedCallback(){
        console.log('wwwwwconnectedCallback' + this.recordId);
        // 获取试题record type ids
        getQuestionBankRecordType({

        }).then(result => {
           this.questionRecordTypeMap = result;
        //    this.singleChoiceTypeId = result['Single_Choice'];
        //    this.singleChoiceTypeId = result['Multiple_Choice'];
        //    this.singleChoiceTypeId = result['Judgment_Question'];
        //    this.singleChoiceTypeId = result['Subjective_Questions']
        });

        loadScript(this, sheetJS).then(() => {
            console.log('加载 sheetJS 完成');
        });
    }

    handleEditQuestionScoreSubmit(){
        this.isShowSpinnerEditQuestionScore = true;
    }

    // 选中题目分数修改成功后执行
    handleEditQuestionScoreSuccess(){
        this.isShowSpinnerEditQuestionScore = false;
        this.isShowEditSelectQuestionScore = false;
        this.editQuestionnaireQuestionBank = '';

        this.dispatchEvent(new ShowToastEvent({
            title: 'success',
            message: this.label.Score_Modified_Successfully, //'分数修改成功！'
            variant: 'success',
            // mode: "sticky"
        }));

        refreshApex(this.wiredResult);
    }

    // 打开编辑选中题目分数页面
    editQuestionInfo(event){
        const qqbId = event.currentTarget.dataset.record;

        this.isShowEditSelectQuestionScore = true;
        this.editQuestionnaireQuestionBank = qqbId;
    }

    // 关闭编辑分数页面
    closeEditSelectQuestionScore(){
        this.isShowEditSelectQuestionScore = false;
        this.editQuestionnaireQuestionBank = '';
    }

    // 选择试题类型
    changeQuestionType(event){
        const selectedOption = event.detail.value;
        console.log('Option selected with value: ' + selectedOption);
        this.selectQuestionRecordType = selectedOption;
    }
    
    // 关闭新建试题页面
    closeShowCreateQuestion(){
        this.isShowSelectQuestionType = false;
        this.selectQuestionRecordType = 'Single_Choice';
    }

    // 选择类型下一步新建
    showCreateQuestion(){
        this.isShowSelectQuestionType = false;
        if(this.selectQuestionRecordType == 'Single_Choice'){
            this.isChoiceNew = true;
            this.isSingleChoiceNew = true;
        }else if(this.selectQuestionRecordType == 'Multiple_Choice'){
            this.isChoiceNew = true;
            this.isMultipleChoiceNew = true;
        }else if(this.selectQuestionRecordType == 'Judgment_Question'){
            this.isJudgmentQuestionNew = true;
        }
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__objectPage',
        //     attributes: {
        //         objectApiName: 'Question_Bank__c',
        //         actionName: 'new',
        //     },
        //     state: {
        //         recordTypeId: this.questionRecordTypeMap[this.selectQuestionRecordType],
        //     }                  
        // }).then(url => {
        //     window.open(url, "_blank");
        // });
    
        // 下一步，试题新建页面
        this.isShowSelectQuestionInfo = true;

    }

    // 关闭试题新建页面
    handleCloseQuestionInfo(){
        this.isShowSelectQuestionInfo = false;
        this.selectQuestionRecordType = 'Single_Choice';
        this.isChoiceNew = false;
        this.isSingleChoiceNew = false;
        this.isMultipleChoiceNew = false;
        this.isJudgmentQuestionNew = false;
    }

    // 试题新建成功后执行
    handlecreateQuestionInfoSuccess(event){
        this.isShowSelectQuestionInfo = false;
        this.selectQuestionRecordType = 'Single_Choice';
        this.isChoiceNew = false;
        this.isSingleChoiceNew = false;
        this.isMultipleChoiceNew = false;
        this.isJudgmentQuestionNew = false;

        const questionRecord = event.detail.id;
        console.log('onsuccess: ', questionRecord);
        const questionData = {};
        questionData[questionRecord] = this.newQuestionScore;
        // 添加新增试题到当前试卷中
        saveSelectedQuesions({
            recordId : this.recordId,
            selectedIds : JSON.stringify(questionData), 
        }).then(result => {
            this.newQuestionScore = '';
            this.isShowSpinnerCreateQuestion = false;
            if (result.isSuccess) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'success',
                    message: this.label.Test_Add_Successfully, //'试题添加成功！'
                    variant: 'success',
                    // mode: "sticky"
                }));
                this.closeModal();
                refreshApex(this.wiredResult);
            }
        }).catch(error => {
            this.isShowSpinnerCreateQuestion = false;
            this.newQuestionScore = '';
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Test_Add_Failed, //'试题添加失败！'
                variant: 'error',
                // mode: "sticky"
            })); 
        });
    }

    // 保存试卷添加试卷类型
    handleSubmit(event){

        // YYL 修改绑定逻辑 20250508

        event.preventDefault();       // stop the form from submitting
        this.isShowSpinnerCreateQuestion = true;
        const fields = event.detail.fields;
        fields.RecordTypeId = this.questionRecordTypeMap[this.selectQuestionRecordType];
        this.newQuestionScore = fields.Score__c
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    
    // 新建试题页面
    showCreateQuestionType(event){
        this.isShowSelectQuestionType = true;
    }

    // YYL 分享数据页面 20250509
    showShareQuestion(event){
        this.isShowShareQuestion = true;
    }
    closeShareQuestion(event){
        this.isShowShareQuestion = false;
    }

    // YYL 下载已经上传的人员信息
    downLoadViewPersonnel(event){
        downLoadViewPersonnel({
            id : this.recordId
        }).then(result => {
            if(result.length > 0){
                const data = [];
                result.forEach(element => {
                    data.push(element);
                });

                // 使用 SheetJS 创建工作表
                const ws = XLSX.utils.aoa_to_sheet(data);

                // 将工作表转换为工作簿
                const wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, "Sheet1");

                // 导出并下载Excel文件
                XLSX.writeFile(wb, "Examination View Personnel.xlsx");

                // 导出成功
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'File download successful',
                        variant: 'success',
                        mode : 'sticky'
                    }),
                );
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'error',
                        message: 'There is currently no list of imported personnel',
                        variant: 'error',
                    }),
                );
            }
        }).catch(error => {
            console.log('wwwwwerror--' + JSON.stringify(error));
        })
    }

    // 展示试题
    showQuestionInfo(event){
        this.isQuestionInfoOpen = true;
        checkQuestionInfo({
            recordId : event.currentTarget.dataset.record,
        }).then(result => {
            const questionType = result.Question_Bank_Type_API__c;
            if(questionType == 'Single_Choice'){
                this.isChoice = true;
                this.isSingleChoice = true;
            }else if(questionType == 'Multiple_Choice'){
                this.isChoice = true;
                this.isMultipleChoice = true;
            }else if(questionType == 'Judgment_Question'){
                this.isJudgmentQuestion = true;
            }
            this.Question_Bank__c = result.Question_Bank__c;
            this.Score__c = result.Score__c;
        }).catch(error => {
            
        });
    }

    // 关闭试题详情
    closeQuestionInfo(event){
        this.isQuestionInfoOpen = false;
        this.isChoice = false;
        this.isSingleChoice = false;
        this.isMultipleChoice = false;
        this.isJudgmentQuestion = false;
        this.Question_Bank__c = '';
        this.Score__c = '';
    }

    // 删除试题
    deleteQuestion(event){
        this.isShowSpinnerMax = true;
        var questionId = event.currentTarget.dataset.record;
        deleteQuestion({
            questionId : questionId,
        }).then(result => {
            if (result.isSuccess) {
                this.isShowSpinnerMax = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'success',
                    message: this.label.Test_Deleted_Successfully,//'试题删除成功！'
                    variant: 'success',
                    // mode: "sticky"
                }));
                refreshApex(this.wiredResult);
            }
        }).catch(error => {
            this.isShowSpinnerMax = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Test_Deleted_Failed, // '试题删除失败！'
                variant: 'error',
                // mode: "sticky"
            })); 
        });
    }

    // 新增试题页面
    showQuestionBanks(event){
        this.isNewQuestionModalOpen = true;
    }
    // 关闭新增试题页面
    closeModal(){
        this.isNewQuestionModalOpen = false;
        this.isCanSave = false;
        this.questionType = '';
        this.titleType = '';
        this.questionTitle = '';
        this.questionBankDatas = [];
        this.selectedQuestionIds = {};
        this.selectedIdsOk = [];
    }

    handleChangeQuestionType(event){
        this.questionType = event.detail.value;
        console.log('questionType----' + event.detail.value);
    }

    handleChangeTitleType(event){
        this.titleType = event.detail.value;
        console.log('titleType----' + event.detail.value);
    }

    handleChangeQuestionTitle(event){
        this.questionTitle = event.detail.value;
        console.log('questionTitle----' + event.detail.value);
    }
    
    // 查询题库
    searchData(event){
        this.isShowSpinner = true;
        searchQuestionBankDatas({
            recordId : this.recordId,
            questionType : this.questionType,
            titleType : this.titleType,
            questionTitle : this.questionTitle,
        }).then(result => {
            if (result) {
                this.questionBankDatas = result;   
            }
            this.isShowSpinner = false;
        }).catch(error => {
            this.isShowSpinner = false;
        });
    }

    // 修改score
    updateScore(event){
        const updateRows = event.detail.draftValues;
        const updateMaps = {};
        for (let i = 0; i < updateRows.length; i++) {
            updateMaps[updateRows[i].Id] = updateRows[i].Score__c;
            this.selectedQuestionIds[updateRows[i].Id] = updateRows[i].Score__c;
        }
    
        for (let i = 0; i < this.questionBankDatas.length; i++) {
            if(updateMaps.hasOwnProperty(this.questionBankDatas[i].Id)){
                this.questionBankDatas[i].Score__c = updateMaps[this.questionBankDatas[i].Id]
            }
        }
        // 验证选择的题目是否添加了score
        this.isCanSaveQuestion();
    }

    // 验证分数是否全部添加
    isCanSaveQuestion(){
        if(this.selectedQuestionOK.length > 0){
            this.isCanSave = true
        }else {
            this.isCanSave = false;
        }
        for (let i = 0; i < this.selectedQuestionOK.length; i++) {
            console.log(this.selectedQuestionOK[i]);
            if(this.judgeFieldValueEmpty(this.selectedQuestionIds[this.selectedQuestionOK[i]])){
                console.log(this.selectedQuestionIds[this.selectedQuestionOK[i]]);
                this.isCanSave = false;
            }
        }
    }

    // 选择行数据
    getSelectedQuesions(event) {
        const selectedRows = event.detail.selectedRows;
        // 试题id与score
        const selectedIds = {};
        const selectedIdsOk = [];

        for (let i = 0; i < selectedRows.length; i++) {
            console.log('You selected: ' + selectedRows[i].Id);
            console.log('You selected Score__c: ' + selectedRows[i].Score__c);
            selectedIdsOk.push(selectedRows[i].Id);
            selectedIds[selectedRows[i].Id] = selectedRows[i].Score__c;
            if(this.judgeFieldValueEmpty(selectedRows[i].Score__c)){
                this.isCanSave = false;
            }
        }
        this.selectedQuestionIds = selectedIds;
        this.selectedQuestionOK = selectedIdsOk;

        // 验证选择的题目是否添加了score
        this.isCanSaveQuestion();
    }

    judgeFieldValueEmpty(fieldValue){
        if(fieldValue == undefined || fieldValue == null || fieldValue == "") {
            return true;
        }else{
            return false;
        }
    }

    // 选择试题保存
    saveSelectedQuesions(event){
        // 验证选择的试题score都有数据
        this.isShowSpinner = true;
        saveSelectedQuesions({
            recordId : this.recordId,
            selectedIds : JSON.stringify(this.selectedQuestionIds), 
        }).then(result => {
            this.isShowSpinner = false;
            this.selectedQuestionIds = {};
            this.selectedIdsOk = [];
            if (result.isSuccess) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'success',
                    message: this.label.Test_Add_Successfully,// '试题添加成功！',
                    variant: 'success',
                    // mode: "sticky"
                }));
                this.closeModal();
                refreshApex(this.wiredResult);
            }
        }).catch(error => {
            this.isShowSpinner = false;
            this.selectedQuestionIds = {};
            this.selectedIdsOk = [];
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Test_Add_Failed,// '试题添加失败！',
                variant: 'error',
                // mode: "sticky"
            })); 
        });
    }
}