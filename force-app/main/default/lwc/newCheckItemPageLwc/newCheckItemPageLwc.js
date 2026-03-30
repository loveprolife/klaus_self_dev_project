/*
 * @Author: YYL
 * @LastEditors: TJP
 */
import {LightningElement, wire , track, api} from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import INSPECTION_REPORT_SAVE from '@salesforce/label/c.INSPECTION_REPORT_SAVE';
import INSPECTION_REPORT_EDIT from '@salesforce/label/c.INSPECTION_REPORT_EDIT';
import Inspection_Type from '@salesforce/label/c.Inspection_Type';
import Item_Type from '@salesforce/label/c.Item_Type';
import Question_Type from '@salesforce/label/c.Question_Type';
import Question_Description from '@salesforce/label/c.Question_Description';
import Help_Text from '@salesforce/label/c.Help_Text';
import Active from '@salesforce/label/c.Active';
import Relate_to_Other_Questions from '@salesforce/label/c.Relate_to_Other_Questions';
import Upload_Photo_or_File from '@salesforce/label/c.Upload_Photo_or_File';
import Has_Comment from '@salesforce/label/c.Has_Comment';
import Automatically_Generate_Ticket from '@salesforce/label/c.Automatically_Generate_Ticket';
import Order_Number from '@salesforce/label/c.Order_Number';
import Enter_Choice from '@salesforce/label/c.Enter_Choice';
import MaximumScore from '@salesforce/label/c.MaximumScore';
import INSPECTION_REPORT_NEW from '@salesforce/label/c.INSPECTION_REPORT_NEW';
import INSPECTION_REPORT_BACK from '@salesforce/label/c.INSPECTION_REPORT_BACK';
import Cancel from '@salesforce/label/c.Cancel'
import getInitData from '@salesforce/apex/newCheckItemController.getInitData';
import getProductLines from '@salesforce/apex/newCheckItemController.getProductLines';
import getChannels from '@salesforce/apex/newCheckItemController.getChannels';
import saveDateWithFiles from '@salesforce/apex/newCheckItemController.saveDateWithFiles';
import getOrderExist from '@salesforce/apex/newCheckItemController.getOrderExist';
import Product_Line from '@salesforce/label/c.Product_Line';
import Channel from '@salesforce/label/c.Channel';
import Optional_Help_Text from '@salesforce/label/c.Optional_Help_Text';
import Mandatory_Help_Text from '@salesforce/label/c.Mandatory_Help_Text';
import Conditional_Help_Text from '@salesforce/label/c.Conditional_Help_Text';
import Optional_Help_Comment_Text from '@salesforce/label/c.Optional_Help_Comment_Text';
import Mandatory_Help_Comment_Text from '@salesforce/label/c.Mandatory_Help_Comment_Text';
import Conditional_Help_Comment_Text from '@salesforce/label/c.Conditional_Help_Comment_Text';
import Relate_Help_Text from '@salesforce/label/c.Relate_Help_Text';
import Local from '@salesforce/label/c.Local';
import En from '@salesforce/label/c.En';
import Cn from '@salesforce/label/c.Cn';
import Standard_Result from '@salesforce/label/c.Standard_Result'; 
import New_Store_Profile_Name from '@salesforce/label/c.New_Store_Profile_Name'; 

import getPickList from '@salesforce/apex/NewSamplingAndTicketController.getPickList';
import getExistingFiles from '@salesforce/apex/newCheckItemController.getExistingFiles';
import getUserInfo from '@salesforce/apex/newCheckItemController.getUserInfo';


export default class NewCheckItemPageLwc extends LightningNavigationElement {
    
    label = {
        Inspection_Type,
        Item_Type,
        Question_Type,
        Question_Description,
        Help_Text,
        Active,
        Relate_to_Other_Questions,
        Upload_Photo_or_File,
        Has_Comment,
        Automatically_Generate_Ticket,
        Enter_Choice,
        MaximumScore,
        INSPECTION_REPORT_NEW,
        INSPECTION_REPORT_SAVE,
        INSPECTION_REPORT_EDIT,
        Cancel,
        Order_Number,
        INSPECTION_REPORT_BACK,
        Product_Line,
        Channel,
        Optional_Help_Text,
        Mandatory_Help_Text,
        Conditional_Help_Text,
        Optional_Help_Comment_Text,
        Mandatory_Help_Comment_Text,
        Conditional_Help_Comment_Text,
        Relate_Help_Text,Local,En,Cn,
        Standard_Result,
        New_Store_Profile_Name,
    }

    // @api recordId = 'a2RHz000001M3MYMA0';
    @api recordId;
    @api recordTypeId;
    @api status;

    @track record = {};
    @track spinnerFlag = false;
    @track isEditPage = false;

    @track showAllPage = true;
    // 是否显示问题描述多语言页面
    @track showQuestionDescriptionPage = false;
    // 是否显示多选答案描述多语言页面
    @track showEnterChoiceDescriptionPage = false;
    // 是否显示帮助文本多语言页面
    @track showHelpTextPage = false;
    // 是否显示设置关联问题
    @track showRelateList = false;
    // 是否显示上传文件的条件判断
    @track showFileConditionalType = false;
    @track showFileConditionalOptional = false;
    @track showFileConditionalMandatory = false;
    @track showFileConditionalType = false;

    // ordernumber 字段提示文本 当前问题类型已存在序号
    @track orderExist;


    // 是否显示Comment的条件判断
    @track showCommentConditionalType = false;
    // 是否显示创建Ticket的条件判断
    @track showTicketConditionalType = false;

    // 是否显示关联问题选项
    @track showRelateQuestions = false;
    @track isPicklistType = false;
    @track isMultipleType = false;
    @track isYesNoType = false;
    @track isObjectType = false;
    @track isScoreType = false;
    // 是否显示上传选项
    @track showUploadFile = true;
    // 是否显示评论选项
    @track showComment = true;
    // 是否显示Ticket选项
    @track showTicket = false;

    // 是否显示Enter Choice
    @track showEnterChoice = false;
    // 是否显示设置最大分数
    @track showMaximumScore = false;
    // 是否限制 Int类型的最大限制的值
    @track isIntegerType = false;

    // 当前用户salesRegion信息
    @track salesRegion;

    @track checkItemAll;
    @track productLineOptions = [];
    @track channelOptions = [];
    @track showStatu = false;
    @track salesRegionChange;
    @track channel = '';
    @track productLine = '';
    
    // 选择Question_Type__c
    @track questionType;
    @track conditionalDataHasFile;
    @track showConditionalYesNoInfoHasFile = false;
    @track showConditionalScoreInfoHasFile = false;
    @track conditionalYesNoInfoRadioHasFile;
    @track conditionalScoreInfoHasFile;

    @track conditionalDataHasComment;
    @track showConditionalYesNoInfoHasComment = false;
    @track showConditionalScoreInfoHasComment = false;
    @track conditionalYesNoInfoRadioHasComment;
    @track conditionalScoreInfoHasComment;

    @track conditionalDataHasTicket;
    @track showConditionalYesNoInfoHasTicket = false;
    @track showConditionalScoreInfoHasTicket = false;
    @track conditionalYesNoInfoRadioHasTicket;
    @track conditionalScoreInfoHasTicket;

    @track standardOption = [];
    @track tmeporary;

    // // 问题描述英文
    // @track questionDescriptionEn;
    // // 问题描述中文
    // @track questionDescriptionCn;
    // // 帮助文本英文
    // @track helpTextEn;
    // // 帮助文本中文
    // @track helpTextCn;

    // // 存放文件条件判断值
    // @track fileConditionalType
    // // 存放评论条件判断值
    // @track commentConditionalType
    // // 存放ticket条件判断值
    // @track ticketConditionalType

    // 存放多选条件
    @track enterChoice = [{
        'T':'',
        'EN':'',
        'CN':''
    }];

    // 存放关联问题
    @track relateList = [];

    @track relateDelList = [];

    // 条件判断类型
    @track ConditionalType = [
                                {label: "Optional", helptext: this.label.Optional_Help_Text, helpCommenttext: this.label.Optional_Help_Comment_Text},
                                {label: "Mandatory", helptext: this.label.Mandatory_Help_Text, helpCommenttext: this.label.Mandatory_Help_Comment_Text},
                                {label: "Conditional", helptext: this.label.Conditional_Help_Text, helpCommenttext: this.label.Conditional_Help_Comment_Text}
                            ];

    // @track hasRelateQuestions = false;
    // TJP 20241110
    @track OfficeProductLineOption = [];

    // wfc 2025-02-27
    @track initFlag = true;
    // question type选择picklist时，存放choice集合
    get picklistOptions() {
        console.log('wwww-fffff---' + this.enterChoice.join(";"));
        // YYL 处理多语言逻辑 20250409
        let enterChoice = [];
        if(this.enterChoice){
            this.enterChoice.forEach(data => {
                enterChoice.push(data.T);
            })
        }

        const options = [];
        const ops = enterChoice.join(";");
        if(ops != null && ops != '' && ops != undefined){
            if(this.record.Question_Type__c == 'Picklist'){
                options.push({
                    label: 'choose one...', value: ''
                })
            }
            ops.split(';').forEach(op => {
                options.push({
                    ...op,
                    label: op,
                    value: op,
                });
            });;
        }
        return options;
    }

    get ScoreOptions() {
        console.log('wwww-ScoreOptions---' + this.record.MaximumScore__c);
        const options = [];
        options.push({
            label: 'choose one...',
            value: '',
        });
        for(var i = 1; i <= this.record.MaximumScore__c; i++) {
            options.push({
                label: i,
                value: i,
            });
        }
        return options;
    }
    
    // 文件信息
    @track files = []; // 包含所有文件（新上传和已有）
    filesToDelete = []; // 待删除的已有文件

    // 处理文件上传
    handleFileUpload(event) {
        const filesList = event.target.files;
        Array.from(filesList).forEach((file, index) => {
            this.createThumbnail(file, index);
        });
    }

    // 创建缩略图
    createThumbnail(file, index) {
        const reader = new FileReader();
        reader.onloadend = () => {
            // 文件读取完成后，获取数据 URL
            this.files = [
                ...this.files,
                {
                    key: this.generateUniqueId(),
                    name: file.name,
                    src: reader.result, // 使用FileReader返回的base64数据作为图片源
                    fileBody: reader.result.split(',')[1], // 存储File对象用于后续上传
                    isExisting: false
                },
            ];
        };
        reader.readAsDataURL(file); // 读取文件并返回base64编码
    }

    deleteFile(event){
        const key = event.target.dataset.key;
        const index = this.files.findIndex(f => f.key === key);
        const fileTemp = this.files[index];
        if (fileTemp.isExisting) {
            this.filesToDelete.push(fileTemp.contentDocumentId);
        }
        this.files.splice(index, 1);
    }

    // 加载已有图片
    async loadExistingFiles() {
        await getExistingFiles({ recordId: this.recordId })
            .then(result => {
                result.forEach(file => {
                    this.files.push({
                        ...file,
                        key: file.contentDocumentId,
                        name: file.title,
                        src: file.downloadUrl,
                        isExisting: true
                    });
                });
            });
    }

    generateUniqueId() {
        return Math.random().toString(36).substr(2, 9);
    }
    
    conditionalYesNoInfoValue = '';
    get conditionalYesNoInfoOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    handleConditionalScoreInfoHasFile(event){
        this.conditionalScoreInfoHasFile = event.target.value;
        this.record.Conditional_Score_Has_File__c = event.target.value;
        this.inputReset('.conditionalScoreInputFile');
    }

    handleConditionalYesNoInfoRadioHasFile(event){
        this.conditionalYesNoInfoRadioHasFile = event.target.value;
        this.record.Conditional_Yes_No_Has_File__c = event.target.value;
        this.inputReset('.conditionalScoreInputFile');
    }

    handleConditionalScoreInfoHasComment(event){
        this.conditionalScoreInfoHasComment = event.target.value;
        this.record.Conditional_Score_Has_Comment__c = event.target.value;
        this.inputReset('.conditionalScoreInputComment');
    }

    handleConditionalYesNoInfoRadioHasComment(event){
        this.conditionalYesNoInfoRadioHasComment = event.target.value;
        this.record.Conditional_Yes_No_Has_Comment__c = event.target.value;
        this.inputReset('.conditionalScoreInputComment');
    }

    handleConditionalScoreInfoHasTicket(event){
        this.conditionalScoreInfoHasTicket = event.target.value;
        this.record.Conditional_Score_Has_Ticket__c = event.target.value;
        this.inputReset('.conditionalScoreInputTicket');
    }

    handleConditionalYesNoInfoRadioHasTicket(event){
        this.conditionalYesNoInfoRadioHasTicket = event.target.value;
        this.record.Conditional_Yes_No_Has_Ticket__c = event.target.value;
        this.inputReset('.conditionalScoreInputTicket');
    }

    handleShowQuestionDescriptionPage(){
        this.showAllPage = false;
        this.showQuestionDescriptionPage = true;
    }

    handleCloseQuestionDescriptionPage(event){
        this.showAllPage = true;
        this.showQuestionDescriptionPage = false;
        this.record.Description_CN__c = event.detail.questionDescriptionCn;
        this.record.Description_EN__c = event.detail.questionDescriptionEn;
        console.log(JSON.stringify(event.detail));
    }

    handleShowHelpTextPage(){
        this.showAllPage = false;
        this.showHelpTextPage = true;
    }

    handleCloseHelpTextPage(event){
        this.showAllPage = true;
        this.showHelpTextPage = false;
        this.record.HelpTextCN__c = event.detail.helpTextCn;
        this.record.HelpTextEN__c = event.detail.helpTextEn;
        console.log(JSON.stringify(event.detail));
    }

    handleShowEnterChoiceDescriptionPage(){
        this.showAllPage = false;
        this.showEnterChoiceDescriptionPage = true;
    }

    handleCloseEnterChoiceDescriptionPage(event){
        this.showAllPage = true;
        this.showEnterChoiceDescriptionPage = false;
        // this.record.Description_CN__c = event.detail.questionDescriptionCn;
        // this.record.Description_EN__c = event.detail.questionDescriptionEn;
        console.log(JSON.stringify(event.detail));
    }

    handleShowRelateList(event){
        this.showRelateList = event.target.value;
        this.record.HasRelateQuestions__c = event.target.value;
        if(!event.target.value){
            this.relateList = [];
        }
    }

    handleIsLoopRelateQuestions(event){
        this.record.Is_Loop_Relate_Questions__c = event.target.value;
    }
    
    handleShowFileConditionalType(event){
        this.showFileConditionalType = event.target.value;
        this.record.HasFile__c = event.target.value;
    }
    
    handleShowCommentConditionalType(event){
        this.showCommentConditionalType = event.target.value;
        this.record.HasComment__c = event.target.value;
    }

    handleHasImageAIChange(event){
        this.record.Has_Image_AI__c = event.target.value;
    }

    handleHasRatingChange(event){
        this.record.Is_Store_Rating__c = event.target.value;
        if(this.record.Is_Store_Rating__c == true) {
            this.giveStandardOption(this.record.Enter_Choice__c);
        }
    }

    giveStandardOption(result){
        this.standardOption = [];
        if(this.record.Question_Type__c == 'Yes/No') {
            var option = ['Yes','No'];
            for (let i = 0; i < option.length; i++) {
                var person = option[i];
                this.standardOption.push({label: person, value: person});
            }
            // this.standardOption = ['TV','Laser TV','Sound Bar', 'WM', 'Refrigerator'];
        } else if(this.record.Question_Type__c == 'Picklist') {
            // var option = ['1','2','3'];
            console.log('Choice:' + result);
            const ops = result;
            if(ops != null && ops != '' && ops != undefined){
                if(this.record.Question_Type__c == 'Picklist'){
                    // this.standardOption.push({
                    //     label: 'choose one...', value: ''
                    // })
                }
                ops.split(';').forEach(op => {
                    this.standardOption.push({
                        ...op,
                        label: op,
                        value: op,
                    });
                });;
            }
            // for (let i = 0; i < option.length; i++) {
            //     var person = option[i];
            //     this.standardOption.push({label: person, value: person});
            // }
        } else if(this.record.Question_Type__c == 'Multiple Selection') {
            console.log('Choice:' + result);
            const ops = result;
            if(ops != null && ops != '' && ops != undefined){
                if(this.record.Question_Type__c == 'Multiple Selection'){
                    // this.standardOption.push({
                    //     label: 'choose one...', value: ''
                    // })
                }
                ops.split(';').forEach(op => {
                    this.standardOption.push({
                        label: op,
                        value: op,
                    });
                });
                const result = this.record.Standard_Result__c;
                if(result != null && result != '' && result != undefined){
                    if(result.includes(';')) {
                        this.record.Standard_Result__c = result.split(';')
                    } else {
                        this.record.Standard_Result__c = [this.record.Standard_Result__c];
                    }
                } else {
                   this.standardOption = []; 
                }
            }
        }
    }

    handleImageAIChange(event){
        this.record.Image_AI__c = event.target.value;
    }

    handleShowTicketConditionalType(event){
        this.showTicketConditionalType = event.target.value;
        this.record.Automatic_Generation_Ticket__c = event.target.value;
    }

    handleConditional(event){
        console.log(event.target.dataset.id);
        console.log(event.target.dataset.index);
        let dataid = event.target.dataset.id;
        let index = event.target.dataset.index;
        let label = event.target.label;

        // 获取当前选取的checked
        let selectedRows = this.template.querySelectorAll('[data-id="' + dataid + '"]');
        let checked = selectedRows[index].checked;

        // 全部设置非选中
        this.template.querySelectorAll('[data-id="' + dataid + '"]').forEach(item=>{
            item.checked = false;
        });

        // 单独设置选中状态
        if(checked){
            selectedRows[index].checked = checked;

            if(dataid == 'hasFile'){
                this.record.File_Conditional_Type__c = label;
                this.conditionalDataHasFile = label;
            }else if(dataid == 'hasComment'){
                this.record.Comment_Conditional_Type__c = label;
                this.conditionalDataHasComment = label;
            }else if(dataid =='hasTicket'){
                this.record.Ticket_Conditional_Type__c = label;
                this.conditionalDataHasTicket = label;
            }
            
        }else{
            if(dataid == 'hasFile'){
                this.record.File_Conditional_Type__c = '';
            }else if(dataid == 'hasComment'){
                this.record.Comment_Conditional_Type__c = '';
            }else if(dataid == 'hasTicket'){
                this.record.Ticket_Conditional_Type__c = '';
            }
        }
        // 选择Conditional，显示附加信息
        if(dataid == 'hasFile'){
            if(this.conditionalDataHasFile == 'Conditional' && event.target.checked){
                // 展示yes/no附加信息
                if(this.questionType == 'Yes/No'){
                    this.showConditionalYesNoInfoHasFile = true;
                }else if(this.questionType == 'Score'){
                    // 展示score附加信息
                    this.showConditionalScoreInfoHasFile = true;
                }
            }else {
                this.record.Conditional_Score_Has_File__c = '';
                this.record.Conditional_Yes_No_Has_File__c = '';
                this.conditionalScoreInfoHasFile = '';
                this.conditionalYesNoInfoRadioHasFile = '';
                this.showConditionalYesNoInfoHasFile = false;
                this.showConditionalScoreInfoHasFile = false;
            }
        }

        if(dataid == 'hasComment'){
            if(this.conditionalDataHasComment == 'Conditional' && event.target.checked){
                // 展示yes/no附加信息
                if(this.questionType == 'Yes/No'){
                    this.showConditionalYesNoInfoHasComment = true;
                }else if(this.questionType == 'Score'){
                    // 展示score附加信息
                    this.showConditionalScoreInfoHasComment= true;
                }
            }else {
                this.record.Conditional_Score_Has_Comment__c = '';
                this.record.Conditional_Yes_No_Has_Comment__c = '';
                this.conditionalScoreInfoHasComment = '';
                this.conditionalYesNoInfoRadioHasComment = '';
                this.showConditionalYesNoInfoHasComment = false;
                this.showConditionalScoreInfoHasComment = false;
            }
        }

        if(dataid == 'hasTicket'){
            if(this.conditionalDataHasTicket == 'Conditional' && event.target.checked){
                // 展示yes/no附加信息
                if(this.questionType == 'Yes/No'){
                    this.showConditionalYesNoInfoHasTicket = true;
                }else if(this.questionType == 'Score'){
                    // 展示score附加信息
                    this.showConditionalScoreInfoHasTicket= true;
                }
            }else {
                this.record.Conditional_Score_Has_Ticket__c = '';
                this.record.Conditional_Yes_No_Has_Ticket__c = '';
                this.conditionalScoreInfoHasTicket = '';
                this.conditionalYesNoInfoRadioHasTicket = '';
                this.showConditionalYesNoInfoHasTicket = false;
                this.showConditionalScoreInfoHasTicket = false;
            }
        }
    }

    // 清空数据
    clearInfo(){
        // 清空数据
        this.conditionalScoreInfoHasFile = '';
        this.conditionalYesNoInfoRadioHasFile = '';
        this.showConditionalYesNoInfoHasFile = false;
        this.showConditionalScoreInfoHasFile = false;

        // 清空数据
        this.conditionalScoreInfoHasComment = '';
        this.conditionalYesNoInfoRadioHasComment = '';
        this.showConditionalYesNoInfoHasComment = false;
        this.showConditionalScoreInfoHasComment = false;

        // 清空数据
        this.conditionalScoreInfoHasTicket = '';
        this.conditionalYesNoInfoRadioHasTicket = '';
        this.showConditionalYesNoInfoHasTicket = false;
        this.showConditionalScoreInfoHasTicket = false;

        //清空数据 
        this.Standard_Result__c = '';

    }

    // 根据问题类型展示不同的配置选项
    handleChanngeQuestionTypeInit(event){
        this.clearInfo();
        this.record.Question_Type__c = event.target.value;
        this.record.Is_Store_Rating__c  = false;
        console.log('wwwww-----initFlag=------' + JSON.stringify(this.initFlag));
        if(!this.initFlag){
            // 初始化上个问题选项值
            this.record.Enter_Choice__c  = '';
            if(this.record.HasRelateQuestions__c){
                this.record.HasRelateQuestions__c = false;
                if(this.relateList){
                    this.relateDelList = [];
                    this.relateDelList = this.relateDelList.concat(this.relateList);
                }
            }
            if(this.record.HasFile__c){
                this.record.HasFile__c = false;
                this.record.File_Conditional_Type__c = '';
            }
            if(this.record.HasComment__c){
                this.record.HasComment__c = false;
                this.record.Comment_Conditional_Type__c = '';
            }
            if(this.record.Automatic_Generation_Ticket__c){
                this.record.Automatic_Generation_Ticket__c = false;
            }
            // 初始化 wfc
            this.enterChoice = [{
                'T':'',
                'EN':'',
                'CN':''
            }];
            this.showRelateList = false;
            this.relateList = [];
        }
        this.handleChanngeQuestionType();
        this.initFlag = false;
    }
    handleChanngeQuestionType(){
        console.log('wwwww-----record=------' + JSON.stringify(this.record));
        // 获取当前设置的类型
        const itemType = this.record.Item_Type__c;
        this.questionType = this.record.Question_Type__c;
        const name = this.questionType;
        // 选择Conditional，显示附加信息
        if(this.conditionalDataHasFile == 'Conditional'){
            // 展示yes/no附加信息
            if(this.questionType == 'Yes/No'){
                this.showConditionalYesNoInfoHasFile = true;
                this.conditionalYesNoInfoRadioHasFile = this.record.Conditional_Yes_No_Has_File__c;
            }else if(this.questionType == 'Score'){
                // 展示score附加信息
                this.showConditionalScoreInfoHasFile = true;
                this.conditionalScoreInfoHasFile = this.record.Conditional_Score_Has_File__c;
            }
        }

        if(this.conditionalDataHasComment == 'Conditional'){
            // 展示yes/no附加信息
            if(this.questionTypeHasComment == 'Yes/No'){
                this.showConditionalYesNoInfoHasComment = true;
                this.conditionalYesNoInfoRadioHasComment = this.record.Conditional_Yes_No_Has_Comment__c;
            }else if(this.questionTypeHasComment == 'Score'){
                // 展示score附加信息
                this.showConditionalScoreInfoHasComment = true;
                this.conditionalScoreInfoHasComment = this.record.Conditional_Score_Has_Comment__c;
            }
        }

        if(this.conditionalDataHasTicket == 'Conditional'){
            // 展示yes/no附加信息
            if(this.questionTypeHasTicket == 'Yes/No'){
                this.showConditionalYesNoInfoHasTicket = true;
                this.conditionalYesNoInfoRadioHasTicket = this.record.Conditional_Yes_No_Has_Ticket__c;
            }else if(this.questionTypeHasTicket == 'Score'){
                // 展示score附加信息
                this.showConditionalScoreInfoHasTicket = true;
                this.conditionalScoreInfoHasTicket = this.record.Conditional_Score_Has_Ticket__c;
            }
        }
        
        // let itemType = this.template.querySelector('[data-field-name="Item_Type__c"]');
        // console.log(itemType.value);
        console.log(name);
        this.ConditionalType = [
            {label: "Optional", helptext: this.label.Optional_Help_Text, helpCommenttext: this.label.Optional_Help_Comment_Text},
            {label: "Mandatory", helptext: this.label.Mandatory_Help_Text, helpCommenttext: this.label.Mandatory_Help_Comment_Text},
                                
        ];
        this.isPicklistType = false;// wfc
        this.isMultipleType = false;// wfc
        this.isYesNoType = false;// wfc
        this.isObjectType = false;// wfc
        this.isScoreType = false;// wfc
        this.isIntegerType = false;//tjp
        if(name == 'Yes/No'){
            this.showRelateQuestions = true;
            this.isYesNoType = true;
            this.showUploadFile = true;
            this.showComment = true;
            // this.showTicket = true;
            this.showEnterChoice = false;
            this.showMaximumScore = false;
            this.ConditionalType = [
                {label: "Optional", helptext: this.label.Optional_Help_Text, helpCommenttext: this.label.Optional_Help_Comment_Text},
                {label: "Mandatory", helptext: this.label.Mandatory_Help_Text, helpCommenttext: this.label.Mandatory_Help_Comment_Text},   
                {label: "Conditional", helptext: this.label.Conditional_Help_Text, helpCommenttext: this.label.Conditional_Help_Comment_Text}
            ];
        }else if(name == 'Text' || name == 'Integer' || name == 'Object'){
            this.showRelateQuestions = false;
            this.showUploadFile = true;
            this.showComment = true;
            // this.showTicket = false;
            this.showEnterChoice = false;
            this.showMaximumScore = false;
            if(name == 'Object'){
                this.isObjectType = true; // wfc
            }
            if(name == 'Integer') {
                this.isIntegerType = true;
            }
        }else if(name == 'Multiple Selection'){
            this.showRelateQuestions = true;
            this.isMultipleType = true; // wfc
            this.showUploadFile = true;
            this.showComment = true;
            // this.showTicket = false;
            this.showEnterChoice = true;
            this.showMaximumScore = false;
        }else if(name == 'Picklist'){
            this.showRelateQuestions = true;
            this.isPicklistType = true; // wfc
            this.showUploadFile = true;
            this.showComment = true;
            this.showTicket = false;
            this.showEnterChoice = true;
            this.showMaximumScore = false;
        }else if(name == 'Score'){
            this.showRelateQuestions = true;
            this.isScoreType = true;// wfc
            this.showUploadFile = true;
            this.showComment = true;
            // this.showTicket = true;
            this.showEnterChoice = false;
            this.showMaximumScore = true;
            this.ConditionalType = [
                {label: "Optional", helptext: this.label.Optional_Help_Text, helpCommenttext: this.label.Optional_Help_Comment_Text},
                {label: "Mandatory", helptext: this.label.Mandatory_Help_Text, helpCommenttext: this.label.Mandatory_Help_Comment_Text},   
                {label: "Conditional", helptext: this.label.Conditional_Help_Text, helpCommenttext: this.label.Conditional_Help_Comment_Text}
            ];
        }else{
            this.showRelateQuestions = false;
            this.showUploadFile = true;
            this.showComment = true;
            // this.showTicket = false;
            this.showEnterChoice = false;
            this.showMaximumScore = false;
        }

        // 根据问题类型判断是否展示自动生成工单选项
        if(itemType){
            if(itemType == 'Sampling Product Check' && (name == 'Yes/No' || name == 'Score')){
                this.showTicket = true;
            }else{
                this.showTicket = false;
            }
        }
    }

    // 新增多选选项栏
    handleAddChoice(){
        this.enterChoice.push({
            'T':'',
            'EN':'',
            'CN':''
        });
    }

    // 删除多选选项栏
    handleDelChoice(event){
        let index = event.target.dataset.index;

        // YYL 整理多语言选项数据值 20250409
        if(this.enterChoice.length > 1){
            this.enterChoice.splice(index,1);
            let t = [];
            let en = [];
            let cn = [];
            this.enterChoice.forEach(data => {
                t.push(data.T);
                en.push(data.EN);
                cn.push(data.CN);
            })
            this.record.Enter_Choice__c = t.join(";");
            this.record.Enter_Choice_EN__c = en.join(";");
            this.record.Enter_Choice_CN__c = cn.join(";");
            console.log('this.record' + JSON.stringify(this.record));
        }
    }
    // 新增关联问题
    handleAddRelate(){
        let relate = {
            Id:'',
            Parent_Response__c:'',
        };
        this.relateList.push(relate);
    }
    
    // 删除关联问题
    handleDelChoiceRelate(event){
        let index = event.target.dataset.index;
        this.relateDelList.push(this.relateList[index]);
        this.relateList.splice(index,1);
    }

    // 设置多选选项值
    handleChangeChoice(event){
        let index = event.target.dataset.index;
        let name= event.target.dataset.name;
        let value = event.target.value;
        console.log('index' + index);
        console.log('name' + name);
        console.log('value' + value);

        // YYL 整理多语言选项数据值 20250409
        let choice = [];
        if(name == 'T'){
            this.enterChoice[index].T = value;
            this.enterChoice.forEach(data => {
                choice.push(data.T);
            })
            this.record.Enter_Choice__c = choice.join(";");
        }else if(name == 'EN'){
            this.enterChoice[index].EN = value;
            this.enterChoice.forEach(data => {
                choice.push(data.EN);
            })
            this.record.Enter_Choice_EN__c = choice.join(";");
        }else if(name == 'CN'){
            this.enterChoice[index].CN = value;
            this.enterChoice.forEach(data => {
                choice.push(data.CN);
            })
            this.record.Enter_Choice_CN__c = choice.join(";");
        }
        console.log('this.enterChoice' + JSON.stringify(this.enterChoice));
        console.log('this.record' + JSON.stringify(this.record));

        // this.enterChoice[index] = value;
        // this.record.Enter_Choice__c = this.enterChoice.join(";");
        //对标准结果下拉列表赋值 TJP
        console.log('Choice 标准打印:' + this.record.Enter_Choice__c);
        this.tmeporary = this.record.Enter_Choice__c;
        this.giveStandardOption(this.tmeporary);
    }

    handleChangeInspectionType(event){
        let value = event.target.value;
        this.record.Inspection_Type__c = value;
    }

    handleChangeSalesRegion(event){
        let value = event.target.value;
        console.log('value' + value);
        this.record.Sales_Region__c = value;
        this.salesRegionChange = value;

        getOrderExist({
            itemType:this.record.Item_Type__c,
            recordId:this.recordId,
            salesRegion:value
        }).then(data => {
            if(data.isSuccess){
                console.log('wwwworderExist' + JSON.stringify(data.data.orderExist));
                this.orderExist = data.data.orderExist;
            }
        })
        //20241105 TJP 总部检查项产品线赋值 
        if(this.salesRegion == 'Hisense International') {
            this.getOfficeProductLineOption();
            this.productLineOptions = this.OfficeProductLineOption;
            var channelResult = [];
            channelResult.push({label: 'All', value: 'All'});
            this.channelOptions = channelResult;
        } else { 
            this.getProductLines(this.salesRegionChange,this.channel);
            this.getChannels(this.salesRegionChange,this.productLine);
        }

        var lookup = this.template.querySelector('c-lookup-lwc');
        if(lookup != null){
            lookup.updateOption({
                'lookup' : 'CustomLookupProvider.ChannelAllFilter',
                'salesRegion' : value
            });
        }
    }

    handleChangeOrderNumber(event){
        let value = event.target.value;
        // 根据正则表达式判断输入数据
        let pattern = /^[0-9]*[1-9][0-9]*$/;
        let flag = pattern.test(value);

        console.log('flag' + flag);

        if(flag || value == 0){
            this.record.OrderNumber__c = value;
        }

        console.log('OrderNumber__c' + this.record.OrderNumber__c);
    }

    handleChangeItemType(event){
        let name = this.record.Question_Type__c;
        let value = event.target.value;
        this.record.Item_Type__c = value;

        if(name){
            if(value == 'Sampling Product Check' && (name == 'Yes/No' || name == 'Score')){
                this.showTicket = true;
            }else{
                this.showTicket = false;
            }
        }

        getOrderExist({
            itemType:value,
            recordId:this.recordId,
            salesRegion:this.record.Sales_Region__c
        }).then(data => {
            if(data.isSuccess){
                console.log('wwwworderExist' + JSON.stringify(data.data.orderExist));
                this.orderExist = data.data.orderExist;
            }
        })
    }

    handleChanngeIntegerTypeInit(event){
        let value = event.target.value;
        if(value == '') {
            this.record.Integer_Type_Max__c = null;
        } else {
            this.record.Integer_Type_Max__c = value;
        }
    }

    handleObjectApiName(event){
        let value = event.target.value;
        this.record.Object_Api_Name__c = value;
    }

    handleChangeDescription(event){
        let value = event.target.value;
        this.record.Description__c = value;
    }

    handleChangeHelpText(event){
        let value = event.target.value;
        this.record.HelpText__c = value;
    }
    
    handleChangeMaximumScore(event){
        let value = event.target.value;
        this.record.MaximumScore__c = value;
    }
    handleChangeActive(event){
        let value = event.target.value;
        this.record.Active__c = value;
    }

    // 设置关联问题值
    handleRelate(event){
        let name = event.target.name;
        let index = event.target.dataset.index;
        if(name == 'response'){
            this.relateList[index].Parent_Response__c = event.target.value;
        }else if(name == 'checkItemRelate'){
            this.relateList[index].Id = event.target.value;
        }else if(name == 'ParentSelect'){
            this.relateList[index].Parent_Select__c = event.target.value;
        }else if(name == 'ParentSelectMultiple'){
            // 如果是多选，则把选择值数组合并成string
            // const mul = event.target.value;
            const mul = event.detail.value;
            console.log('www--mul---' + mul);
            this.relateList[index].Parent_Select__c = mul.join(',');
        }else if(name == 'Score'){
            this.relateList[index].Score_Symbol__c = event.target.value;
        }
        console.log(JSON.stringify(this.relateList));

    }

    @track lookupChannelItemFilter;
    connectedCallback(){
        console.log('connectedCallback' + this.recordId);
        this.getUserInfo();

        if(this.recordId == null || this.recordId == '' || this.status == 'edit'){
            this.isEditPage = true;
        }

        if (this.recordId) {
            this.loadExistingFiles();
        }
        getInitData({
            recordId:this.recordId,
            recordTypeId:this.recordTypeId,
        }).then(
            data => {
                console.log('wwwDataUser' + JSON.stringify(data.data));
                if(data.data.record.Sales_Region__c){
                    this.salesRegion = data.data.record.Sales_Region__c;
                }

                // 设置recordTypeId
                if(!this.recordTypeId){
                    this.recordTypeId = data.data.record.RecordTypeId;
                }

                this.lookupChannelItemFilter = {
                    'lookup': 'CustomLookupProvider.ChannelAllFilter',
                    'salesRegion' : data.data.record.Sales_Region__c
                }

                // 如果记录Sales_Region 为空则获取当前record type默认Sales_Region
                // if(!data.data.record.Sales_Region__c){
                    
                // }
                // let salseRegionDiv = this.template.querySelectorAll('[data-id="salesRegion"]');
                // console.log('wwwsalseRegionDiv' + JSON.stringify(salseRegionDiv));
                // console.log('wwwsalseRegionDiv' + JSON.stringify(salseRegionDiv[0]));

                var recordData = data.data.record;

                // 处理排序字段，初始化时数据展示为空不展示0
                if(!recordData.Id){
                    recordData.OrderNumber__c = '';
                }

                this.record = recordData;
                this.checkItemAll = data.data.checkItemAll;
                this.orderExist = data.data.orderExist;

                this.showStatu = (this.salesRegion == 'Hisense USA' || this.salesRegion == 'Hisense Canada' || this.salesRegion == 'Hisense Peru' || this.salesRegion == 'Hisense International' || this.salesRegion == 'Hisense Mexico' || this.salesRegion == 'Hisense Argentina');
                
                this.formatEnterChoice(data.data.record);
                console.log('标准结果' + JSON.stringify(data.data.record));
                console.log('标准结果2' + JSON.stringify(data.data.record.Enter_Choice__c));
                console.log('标准结果3' + JSON.stringify(data.data.record.Standard_Result__c));
                
                this.tmeporary = data.data.record.Enter_Choice__c;
                this.giveStandardOption(this.tmeporary);
                this.record.Standard_Result__c = data.data.record.Standard_Result__c;
                console.log('标准列' + JSON.stringify(this.standardOption));
                
                // if(choice != null && choice != ''){
                //     this.enterChoice = choice.split(';');
                //     console.log(JSON.stringify(this.enterChoice));
                // }

                let relateList = data.data.relateList;
                console.log('wwwwfffff-----' + JSON.stringify(relateList) );
                if(relateList != null && relateList != ''){
                    // 如果是多选，处理返回数据 wfc
                    if(this.record.Question_Type__c == 'Multiple Selection'){
                        relateList.forEach(relate => {
                            console.log('wwwwfffff1111-----' + JSON.stringify(relate) );
                            console.log('wwwwfffff3333-----' + typeof relate.Parent_Select__c);
                            if(typeof relate.Parent_Select__c === 'string'){
                                console.log('wwwwfffff-22222----' + JSON.stringify(relate.Parent_Select__) );
                                relate.Parent_Select__c = relate.Parent_Select__c.split(',');
                            }
                        });
                    }
                    this.relateList = relateList; 
                }

                if(this.record.HasRelateQuestions__c){
                    this.showRelateList = true;
                }

                console.log('wwwwHasFile__c' + this.record.HasFile__c);
                if(this.record.HasFile__c){
                    let index;
                    this.showFileConditionalType = true;
                    let conditional = this.record.File_Conditional_Type__c;
                    if(conditional == 'Optional'){
                        index = 0;
                    }else if(conditional == 'Mandatory'){
                        index = 1;
                    }else{
                        index = 2;
                    }

                    // 获取当前选取的checked
                    let selectedRows = this.template.querySelectorAll('[data-id="hasFile"]');
                    // selectedRows[index].checked = checked;
                }

                if(this.record.HasComment__c){
                    let index;
                    this.showCommentConditionalType = true;

                    let conditional = this.record.Comment_Conditional_Type__c;
                    if(conditional == 'Optional'){
                        index = 0;
                    }else if(conditional == 'Mandatory'){
                        index = 1;
                    }else{
                        index = 2;
                    }
                    // 获取当前选取的checked
                    let selectedRows = this.template.querySelectorAll('[data-id="hasComment"]');
                    // selectedRows[index].checked = checked;
                }

                if(this.record.Automatic_Generation_Ticket__c){
                    let index;
                    this.showTicketConditionalType = true;

                    let conditional = this.record.Ticket_Conditional_Type__c;
                    if(conditional == 'Optional'){
                        index = 0;
                    }else if(conditional == 'Mandatory'){
                        index = 1;
                    }else{
                        index = 2;
                    }
                    // 获取当前选取的checked
                    let selectedRows = this.template.querySelectorAll('[data-id="hasTicket"]');
                    // selectedRows[index].checked = checked;
                }

                // 处理条件问题是否展示
                if(this.recordId){
                    this.handleChanngeQuestionType();
                }

                //获取产品线
                if(this.salesRegion) {
                    if(this.salesRegion == 'Hisense International') {
                        this.getOfficeProductLineOption();
                        this.productLineOptions = this.OfficeProductLineOption;    
                        var channelResult = [];
                        channelResult.push({label: 'All', value: 'All'});
                        this.channelOptions = channelResult;

                    } else {
                        this.salesRegionChange = this.salesRegion;
                        this.getProductLines(this.salesRegion,this.channel);
                        this.getChannels(this.salesRegion,this.productLine);
                    }
                }
                
                this.spinnerFlag = false;
            }
        )
    }

    formatEnterChoice(data){
        // YYL 整理多语言选项数据值 20250409
        var choiceT = data.Enter_Choice__c;
        var choiceEn = data.Enter_Choice_EN__c;
        var choiceCn = data.Enter_Choice_CN__c;
        
        if(choiceT){
            let t = choiceT.split(';');
            let en = [];
            let cn = [];
            if(choiceEn){
                en = choiceEn.split(';');
            }

            if(choiceCn){
                cn = choiceCn.split(';');
            }

            let enterChoice = [];
            for(let i = 0;i < t.length;i++){

                let choice = {
                    T:t[i]
                };

                if(en[i]){
                    choice.EN = en[i];
                }

                if(cn[i]){
                    choice.CN = cn[i];
                }

                enterChoice.push(choice);
            }

            this.enterChoice = enterChoice;
        }
    }

    renderedCallback() {
        // 回显Conditional
        if(!this.judgeFieldValueEmpty(this.record)){
            this.questionType = this.record.Question_Type__c;
            this.conditionalYesNoInfoRadioHasFile = this.record.Conditional_Yes_No_Has_File__c;
            this.conditionalScoreInfoHasFile = this.record.Conditional_Score_Has_File__c;
            this.conditionalYesNoInfoRadioHasComment = this.record.Conditional_Yes_No_Has_Comment__c;
            this.conditionalScoreInfoHasComment = this.record.Conditional_Score_Has_Comment__c;
            this.conditionalYesNoInfoRadioHasTicket = this.record.Conditional_Yes_No_Has_Ticket__c;
            this.conditionalScoreInfoHasTicket = this.record.Conditional_Score_Has_Ticket__c;

            this.template.querySelectorAll('.conditionalTypeInput').forEach(item => {
                if(item.label == this.record.File_Conditional_Type__c){
                    item.checked = true;
                    
                }
            });
            this.template.querySelectorAll('[name="conditionalYesNoRadioHasFile"]').forEach(item => {
                if(item.value == this.record.Conditional_Yes_No_Has_File__c){
                    item.checked = true;
                }
            });
            this.conditionalDataHasFile = this.record.File_Conditional_Type__c;
            if(this.conditionalDataHasFile == 'Conditional'){
                // 展示yes/no附加信息
                if(this.questionType == 'Yes/No'){
                    this.showConditionalYesNoInfoHasFile = true;
                }else if(this.questionType == 'Score'){
                    // 展示score附加信息
                    this.showConditionalScoreInfoHasFile = true;
                }
            }
            this.template.querySelectorAll('.conditionalTypeInputHasComment').forEach(item => {
                if(item.label == this.record.Comment_Conditional_Type__c){
                    item.checked = true;
                    
                }
            });
            this.template.querySelectorAll('[name="conditionalYesNoRadioHasComment"]').forEach(item => {
                if(item.value == this.record.Conditional_Yes_No_Has_Comment__c){
                    item.checked = true;
                }
            });
            this.conditionalDataHasComment = this.record.Comment_Conditional_Type__c;
            if(this.conditionalDataHasComment == 'Conditional'){
                // 展示yes/no附加信息
                if(this.questionType == 'Yes/No'){
                    this.showConditionalYesNoInfoHasComment = true;
                }else if(this.questionType == 'Score'){
                    // 展示score附加信息
                    this.showConditionalScoreInfoHasComment = true;
                }
            }
            this.template.querySelectorAll('.conditionalTypeInputHasTicket').forEach(item => {
                if(item.label == this.record.Ticket_Conditional_Type__c){
                    item.checked = true;
                    
                }
            });
            this.template.querySelectorAll('[name="conditionalYesNoRadioHasTicket"]').forEach(item => {
                if(item.value == this.record.Conditional_Yes_No_Has_Ticket__c){
                    item.checked = true;
                }
            });
            this.conditionalDataHasTicket = this.record.Ticket_Conditional_Type__c;
            if(this.conditionalDataHasTicket == 'Conditional'){
                // 展示yes/no附加信息
                if(this.questionType == 'Yes/No'){
                    this.showConditionalYesNoInfoHasTicket = true;
                }else if(this.questionType == 'Score'){
                    // 展示score附加信息
                    this.showConditionalScoreInfoHasTicket = true;
                }
            } 
        }
    }

    // 是否不为空
	judgeFieldValueEmpty(fieldValue){
        if(fieldValue == undefined || fieldValue == null || fieldValue == "") {
            return true;
        }else{
            return false;
        }
    }

    // input框标红
    inputSetRed(event){
        this.template.querySelectorAll(event).forEach(item => {
            item.classList.add('inputred');
            item.focus();
        });
    }
    // input框
    inputReset(event){
        this.template.querySelectorAll(event).forEach(item => {
            item.classList.remove('inputred');
        });
    }
    
    save(event){
        let flag = true;

        // 获取当前按钮label
        let label = event.target.label;
        this.spinnerFlag = true;
        console.log('record' + JSON.stringify(this.record));
        console.log('relateList' + JSON.stringify(this.relateList));
        console.log('this.record.Inspection_Type__c' + JSON.stringify(this.record.Inspection_Type__c));
        if(this.questionType != 'Score'){
            this.record.MaximumScore__c = '5'; 
        }
        // 验证附加条件必填
        // if(!this.record.Sales_Region__c){
        //     this.spinnerFlag = false;
        //     this.showError('Sales Region required!');
        //     return false;
        // }
        if(!this.record.Item_Type__c){
            this.spinnerFlag = false;
            this.showError('Check Item Type required!');
            return false;
        }
        if(!this.record.Question_Type__c){
            this.spinnerFlag = false;
            this.showError('Question Type required!');
            return false;
        }
        if(!this.record.Description__c){
            this.spinnerFlag = false;
            this.showError('Question Description required!');
            return false;
        }
        if(this.showEnterChoice){
            if(this.enterChoice.length == 0){
                flag = false;
            }else{
                this.enterChoice.forEach(item => {
                    if(!item.T){
                        flag = false;
                        return 
                    }
                })
            }
            
            if(!flag){
                this.spinnerFlag = false;
                this.showError('Enter Choice required!');
                return false;
            }
        }
        if(this.showMaximumScore && !this.record.MaximumScore__c){
            this.spinnerFlag = false;
            this.showError('Maximum Score required!');
            return false;
        }
        if(!this.record.OrderNumber__c){
            if(this.record.OrderNumber__c != 0){
                this.spinnerFlag = false;
                this.showError('Order Number required!');
                return false;
            }
        }
        if(this.record.HasRelateQuestions__c){
            console.log('HasRelateQuestions__c' + JSON.stringify(this.relateList));
            let flag = true;

            if(this.relateList.length == 0){
                flag = false;
            }else{
                this.relateList.forEach(item => {
                    if(!item.Id || (!item.Parent_Response__c && !item.Parent_Select__c )){
                        flag = false;
                        return 
                    }
                    if(this.questionType == 'Score' && (!item.Parent_Select__c || !item.Score_Symbol__c)){
                        flag = false;
                        return 
                    }
                })
            }
            
            if(!flag){
                this.spinnerFlag = false;
                this.showError('Relate to Other Questions required!');
                return false;
            }
        }
        if(this.record.HasFile__c && !this.record.File_Conditional_Type__c){
            this.spinnerFlag = false;
            this.showError('Upload Photo or File required!');
            return false;
        }
        if(this.record.HasComment__c && !this.record.Comment_Conditional_Type__c){
            this.spinnerFlag = false;
            this.showError('Has Comment required!');
            return false;
        }

        if((this.questionType == 'Score' && this.conditionalDataHasFile == 'Conditional' && this.judgeFieldValueEmpty(this.record.Conditional_Score_Has_File__c)) || 
            (this.questionType == 'Yes/No' && this.conditionalDataHasFile == 'Conditional' && this.judgeFieldValueEmpty(this.record.Conditional_Yes_No_Has_File__c))){
            this.inputSetRed('.conditionalScoreInputFile');
            flag = false;
        }
        if((this.questionType == 'Score' && this.conditionalDataHasComment == 'Conditional' && this.judgeFieldValueEmpty(this.record.Conditional_Score_Has_Comment__c)) || 
            (this.questionType == 'Yes/No' && this.conditionalDataHasComment == 'Conditional' && this.judgeFieldValueEmpty(this.record.Conditional_Yes_No_Has_Comment__c))){
            this.inputSetRed('.conditionalScoreInputComment');
            flag = false;
        }
        if((this.questionType == 'Score' && this.conditionalDataHasTicket == 'Conditional' && this.judgeFieldValueEmpty(this.record.Conditional_Score_Has_Ticket__c)) || 
            (this.questionType == 'Yes/No' && this.conditionalDataHasTicket == 'Conditional' && this.judgeFieldValueEmpty(this.record.Conditional_Yes_No_Has_Ticket__c))){
            this.inputSetRed('.conditionalScoreInputTicket');
            flag = false;
            
        }
        // 判断赋值
        if(this.record.Question_Type__c != 'Yes/No'){
            this.record.Conditional_Yes_No_Has_File__c = '';
            this.record.Conditional_Yes_No_Has_Comment__c = '';
            this.record.Conditional_Yes_No_Has_Ticket__c = '';
        }
        if(this.record.Question_Type__c != 'Score'){
            this.record.Conditional_Score_Has_File__c = '';
            this.record.Conditional_Score_Has_Comment__c = '';
            this.record.Conditional_Score_Has_Ticket__c = '';
        }

        if(!flag){
            this.spinnerFlag = false;
            this.showError('Conditional required!');
            return false;
        } 

        // wfc Question_Type__c是Informational-photo则必上传文件
        if(this.record.Question_Type__c == 'Informational-photo' && this.files.size == 0){
            this.showError('File Uploader required!');
            this.spinnerFlag = false;
            return false;
        }

        if(this.record.Question_Type__c == 'Multiple Selection'){
            if(this.relateList.length > 0){
                this.relateList.forEach(relate => {
                    if(relate.Parent_Select__c instanceof Array){
                        relate.Parent_Select__c = relate.Parent_Select__c.join(';');
                    }
                });
            }
            if(this.relateDelList.length > 0){
                this.relateDelList.forEach(relate => {
                    if(relate.Parent_Select__c instanceof Array){
                        relate.Parent_Select__c = relate.Parent_Select__c.join(';');
                    }
                });
            }
        }

        // 设置record Type Id
        this.record.RecordTypeId = this.recordTypeId;
        saveDateWithFiles({
            checkItemJson:JSON.stringify(this.record),
            relateList:JSON.stringify(this.relateList),
            relateDelList:JSON.stringify(this.relateDelList),
            filesToDelete:this.filesToDelete,
            newFiles:this.files.filter(f => !f.isExisting),

        }).then(data => {
            console.log('save' + JSON.stringify(data));
            if(data.isSuccess){
                this.isEditPage = false;
                this.spinnerFlag = false;
                this.files = [];
                this.filesToDelete = [];
                // 创建成功跳转到数据列
                // this[NavigationMixin.Navigate]({
                //     type: 'standard__recordPage',
                //     attributes: {
                //         recordId: data.data.Id,
                //         objectApiName: 'CheckItem__c',
                //         actionName: 'view'
                //     }
                // });
                
                this.uploadResult(data);

                if(label == this.label.INSPECTION_REPORT_SAVE){
                    this.goToRecord(data.data.id);
                }else if(label == 'Save&New'){
                    this.createRecord('CheckItem__c','',this.recordTypeId,'','');
                }
                this.loadExistingFiles();
            }else{
                this.uploadResult(data);
            }
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'error',
                    message: 'The same check item already exists',
                    variant: 'error'
                    // mode : 'sticky'
                }),
            );
            this.spinnerFlag = false;
        });
    }

    uploadResult(result){
        this.spinnerFlag = false;

        if(result.isSuccess){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!',
                    // message: ' - Upload successfully! ',
                    variant: 'success'
                    // mode : 'sticky'
                }),
            );
        }else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'error',
                    message: result.message,
                    variant: 'error'
                    // mode : 'sticky'
                }),
            );
        }
    }

    handleEdit(){
        this.isEditPage = true;
        console.log('wwwww----' + this.isEditPage);
    }

    handleCancel(){
        
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'CheckItem__c',
                actionName: 'list'
            },
            "state": {
                "filterName": "All"
            }
        });
        // this.goToObject('CheckItem__c','Chile');
    }

    get disabled(){
        var disabled = false;
        if(!this.isEditPage){
            disabled = true;
        }
        return disabled;
    }

    get yesNo() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    get checkItemOptions() {
        var optins = [];
        for (let i = 0; i < this.checkItemAll.length; i++) {
            var person = this.checkItemAll[i];
            optins.push({label: person.Description__c, value: person.Id});
        }
        return optins;
    }

    // TJP20241110
    getOfficeProductLineOption() {
        var option = ['TV','Laser TV','Sound Bar', 'WM', 'Refrigerator'];
        for (let i = 0; i < option.length; i++) {
            var person = option[i];
            this.OfficeProductLineOption.push({label: person, value: person});
        }
        console.log('OfficeProductLineOption' + this.OfficeProductLineOption);

    }

    /**初始化 Product Product line Value List*/
    getProductLines(salesRegion, channel) {
        getProductLines({
            salesRegion: salesRegion,
            channel: channel
        }).then(data => {
            this.productLineOptions = data;
            console.log('WWW打印参数' + JSON.stringify(data));
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'error',
                    message: error.message,
                    variant: 'error'
                })
            )
        });
        
    }
    getChannels(salesRegion,productLine) {
        getChannels({
            salesRegion: salesRegion,
            productLine: productLine
        }).then(data => {
            this.channelOptions = data;
            console.log('WWW打印参数' + JSON.stringify(data));
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'error',
                    message: error.message,
                    variant: 'error'
                })
            )
        });
        
    }

    handleChangeProductLinePro(event){
        let value = event.target.value;
        this.record.Product_Line_Pro__c = value;
    }

    handleChangeStandardResult(event){
        let value = event.target.value;
        console.log('监听对应的结果' + value);
        if(this.isMultipleType) {
            value = this.processInput(value);
        }
        console.log('计算后的结果' + value);
        this.record.Standard_Result__c = value;
    }


    processInput(param) {
        const process = '';
        if (param && param.includes(',')) {           
            process = param.replace(/,/g, ';');
        } else {
            process = param;
        }
        return process;
    }

    handleChangeProductLine(event) {
        let value = event.target.value;
        this.record.Product_Line__c = value;
        this.productLine = value;
        if(this.salesRegion == 'Hisense International') {
            console.log('校验参数-----' +  this.channelOptions);
            this.channelOptions.push({label: 'All', value: 'All'});
        } else{
            // if(value == 'All'){this.productLine = '';} else {this.productLine = value;}
            this.getProductLines(this.salesRegionChange,this.channel);
            this.getChannels(this.salesRegionChange,this.productLine);
            console.log(JSON.stringify(this.channelOptions));
            if(value == 'All'){
                // 处理数据
                const result = this.channelOptions
                .filter(item => item.value !== "All") 
                .map(item => item.value)  
                .join(';');
                // 输出结果
                console.log(result);
            } else {
                //记录实际参数值
                console.log(value);
            }

        }

        
    }
    handleChangeChannel(event) {
        let value = event.detail.selectedRecord.Id;
        this.record.Channel_item__c = value;
        // if(value == 'All'){this.channel = '';} else {this.channel = value;}
        this.channel = value;
        if(this.salesRegion == 'Hisense International') {
            console.log('触发');
        } else {
            // this.getProductLines(this.salesRegionChange,this.channel);
            // this.getChannels(this.salesRegionChange,this.productLine);
            console.log(JSON.stringify(this.productLineOptions));
            if(value == 'All'){
                // 处理数据
                const result = this.productLineOptions
                .filter(item => item.value !== "All") 
                .map(item => item.value)  
                .join(';');
                // 输出结果
                console.log(result);
            } else {
                //记录实际参数值
                console.log(value);
            }
        }
        
    }
    @track isProfileName = false;
    getUserInfo() {
        getUserInfo({
        }).then(data => {
            const param = New_Store_Profile_Name;
            let profileNameList = param.split(',');
            profileNameList.forEach(item => {
                if(data.Profile.Name.indexOf(item) != -1){
                    this.isProfileName = true;
                }
            });
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'error',
                    message: error.message,
                    variant: 'error'
                })
            )
        });
    }

}