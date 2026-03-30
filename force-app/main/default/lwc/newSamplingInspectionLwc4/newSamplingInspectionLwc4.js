import { wire , track, api} from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import INSPECTION_REPORT_SAVE from '@salesforce/label/c.INSPECTION_REPORT_SAVE';
import INSPECTION_REPORT_EDIT from '@salesforce/label/c.INSPECTION_REPORT_EDIT';
import INSPECTION_REPORT_BACK from '@salesforce/label/c.INSPECTION_REPORT_BACK';
import INSPECTION_REPORT_ACTION from '@salesforce/label/c.INSPECTION_REPORT_ACTION';
import Del_Relate from '@salesforce/label/c.Del_Relate';
import Sample_Image from '@salesforce/label/c.Sample_Image';
import saveCheckResult from '@salesforce/apex/newCheckItemController.saveCheckResult';
import saveAndDelCheckResult from '@salesforce/apex/newCheckItemController.saveAndDelCheckResult';
import addCheckResult from '@salesforce/apex/newCheckItemController.addCheckResult';
import addSampleInspectionCheckResult from '@salesforce/apex/NewSamplingAndTicketProController.addSampleInspectionCheckResult';
import checkInitStatus from '@salesforce/apex/NewSamplingAndTicketProController.checkInitStatus';
import getcheckResultInitInfo from '@salesforce/apex/NewSamplingAndTicketProController.getcheckResultInitInfo';
import upsertProductLineStatus from '@salesforce/apex/NewInspectionDailyReportPageController.upsertProductLineStatus';
import getExistingFiles from '@salesforce/apex/newCheckItemController.getExistingFiles';
import saveAttachment from '@salesforce/apex/InspectorDailyReportController.saveAttachment';
import LightningConfirm from 'lightning/confirm';
import Inspection_Delete_Picture from '@salesforce/label/c.Inspection_Delete_Picture';

export default class NewSamplingInspectionLwc4 extends LightningNavigationElement {

    label = {
        INSPECTION_REPORT_SAVE,             // 保存
        INSPECTION_REPORT_EDIT,             // 修改
        INSPECTION_REPORT_BACK,             // Back
        Del_Relate,             // 请勿全部删除
        Sample_Image,             // 示例图片
        INSPECTION_REPORT_ACTION, // action
        Inspection_Delete_Picture,// 删除照片提示
    }
    
    @api productLine;
    @api recordId;
    @api recordItemId;
    @api storeId;
    @api checkLabel;
    @api checkName;
    @api status;
    @api submit;
    @api sampleId;
    @api selectYes;

    // 上传文件id
    @api contentVersionId;

    // 是否存在暂存数据
    @track showCheckResult = false;
    @track showSave = true;
    @track disabled = false;
    @track disabledSave = false;

    @track record;
    @track isEditPage = false;                  // 显示编辑页面
    @track checkItemInfo;
    @track spinnerFlag = false;

    // 是否是返回操作
    @track isBack = false;

    // 是否有改动
    @track hasEdit = false;

    // 是否展示lightning-card模块 YYL 20250318
    @track isCardBtn = true;

    // 表单详情
    @track checkResult = [];
    // 关联问题详情
    @track checkRelateResult = [];
        // 存放关联问题
    @track relateCheckItem;
        // 单选框选项值
    // @track checkBoxValue = '';

    // 存放多图片数据
    @track checkItemPhoto = [];
    @track checkItemRelatePhoto = [];

    @track indexPhoto;

    // @api treeData = [];
    @track treeData = [];
    @track showChildren = true;

    // 初始化
    connectedCallback() {
        this.spinnerFlag = true;
        console.log('wfc---productLine--' + this.productLine);
        console.log('wfc---recordId--' + this.recordId); // Daily_Inspection_Report__c
        console.log('wfc---recordItemId--' + this.recordItemId); // Inspection_Product_Item__c
        console.log('wfc---storeId--' + this.storeId);
        console.log('wfc---status--' + this.status);
        console.log('wfc---submit--' + this.submit);
        console.log('wfc---selectYes--' + this.selectYes);
        console.log('wfc---sampleId--' + this.sampleId); // Sampling_Inspection__c

        // 是否展示lightning-card YYL 20250318
        if(!this.checkName){
            this.isCardBtn = false;
        }
        if(this.selectYes){
            this.getInit(false);
        }
        
        // 根据是否提交判断展示状态
        if(this.status == 'Submitted'){
            this.showSave = false;
            this.disabled = true;
        }

    }

    getInit(flag){
        this.spinnerFlag = true;
        // 查询当前检查项是否已初始化
        checkInitStatus({
            checkItemType: this.checkLabel,
            inspectionProductItemId: this.recordItemId,
            sampleId: this.sampleId,
        }).then(data => {
            if(data.isSuccess){
                if(data.data.initStatus){
                    // 查询初始化数据
                    getcheckResultInitInfo({
                        checkItemType : this.checkLabel,
                        inspectionProductItemId : this.recordItemId,
                        sampleId: this.sampleId,
                    }).then(data => {
                        if(data.isSuccess){
                            this.treeData = data.data.checkResultData;
                            console.log('wwwwtreeData------' + JSON.stringify(data.data.checkResultData));
                            this.dataFormat(this.treeData, flag);
                        }
                        this.dispatchEvent(new CustomEvent(
                            "closespinner", {})
                        );
                    }).catch(error => {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'error',
                            message: 'error',
                            variant: 'error',
                        }));
                        this.dispatchEvent(new CustomEvent(
                            "closespinner", {})
                        );
                    })
                }else{
                    // 初始化检查项
                    this.initCheckResult();
                }
            }
            this.spinnerFlag = false;
            this.dispatchEvent(new CustomEvent(
                "closespinner", {})
            );
        })
    }

    // 初始化CheckResult
    initCheckResult(){
        this.spinnerFlag = true;
        addSampleInspectionCheckResult({
            checkItemType : this.checkLabel,
            inspectorDailyReportId : this.recordId,
            inspectionProductItemId : this.recordItemId,
            productLine : this.productLine,
            sampleId : this.sampleId,
        }).then(data => {
            console.log('wwwwdata.data' + JSON.stringify(data.data.checkResultAdd));
            if(data.isSuccess){
                this.getInit(false);
            }
            this.spinnerFlag = false;
            this.dispatchEvent(new CustomEvent(
                "closespinner", {})
            );
        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Error,
                variant: 'error',
            }));
            this.dispatchEvent(new CustomEvent(
                "closespinner", {})
            );
        })
    }

    // value;
    // handleChange(event) {
    //     this.value = event.detail.value;
    //     console.log(this.value);
    // }

    get yesNo() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    get score() {
        return [
            { label: '1', value: '1' },
            { label: '2', value: '2' },
            { label: '3', value: '3' },
            { label: '4', value: '4' },
            { label: '5', value: '5' },
        ];
    }

    @track needRefresh = false;
    handleChangeYesAndNo(event){
        this.spinnerFlag = true;
        let index = event.target.dataset.index;
        let value = event.target.value;

        // wfc 保存数据


        console.log('wwwwwggghhyesno---' + index);
        console.log('wwwwwggghhyesno---' + value);

        // 如果为多选问题校验是否包含子问题响应值 YYL 20250304
        let parent = this.treeData[index].parent;
        if(parent.CheckItem__r.Question_Type__c == 'Multiple Selection'){
            let multipleSelection = [];

            // 获取当前是否为选中状态
            this.template.querySelectorAll('[data-id="checkbox"]').forEach(item => {
                if(item.checked){
                    // 设置多选值
                    multipleSelection.push(item.value);
                }
            });
            this.treeData[index].parent.Response__c = multipleSelection.join(',');
        }else{
            this.treeData[index].parent.Response__c = value;
        }

        let children = this.treeData[index].children;
        // 没有子数据则不刷新
        if(children){
            // 通过更改needRefresh 刷新子组件
            if(this.needRefresh){
                this.needRefresh = false;
            }else{
                this.needRefresh = true;
            }
        }
        
        // 修改数据未保存，返回父级页面提示标识符
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );

        // 根据响应条件处理展示评论或者上传文件选项
        this.handleHasFileAndCommentRequired(this.treeData[index]);
        // this.handleHasFileAndComment(this.treeData[index]);

        this.spinnerFlag = false;
    }

    handleHasFileAndCommentRequired(data){
        var response = data.parent.Response__c;

        // 是否展示文件触发条件
        let questionType = data.parent.CheckItem__r.Question_Type__c;
        let fileConditionalType = data.parent.CheckItem__r.File_Conditional_Type__c;
        let conditionalScoreHasFile = data.parent.CheckItem__r.Conditional_Score_Has_File__c;
        let conditionalYesNoHasFile = data.parent.CheckItem__r.Conditional_Yes_No_Has_File__c;
        // 是否展示评论触发条件
        let commentConditionalType = data.parent.CheckItem__r.Comment_Conditional_Type__c;
        let conditionalScoreHasComment = data.parent.CheckItem__r.Conditional_Score_Has_Comment__c;
        let conditionalYesNoHasComment = data.parent.CheckItem__r.Conditional_Yes_No_Has_Comment__c;

        // Mandatory为必填
        if(fileConditionalType == 'Mandatory'){
            data.parent.FileRequired= true;
        }else {
            data.parent.FileRequired= false;
        }
        if(commentConditionalType == 'Mandatory'){
            data.parent.CommentRequired= true;
        }else {
            data.parent.CommentRequired= false;
        }
        // Conditional条件必填
        if(fileConditionalType == 'Conditional'){
            if(questionType == 'Yes/No' && response == conditionalYesNoHasFile){
                data.parent.FileRequired= true;
            }
        }
        if(commentConditionalType == 'Conditional'){
            if(questionType == 'Yes/No' && response == conditionalYesNoHasComment){
                data.parent.CommentRequired= true;
            }
        }
        if(fileConditionalType == 'Conditional'){
            if(questionType == 'Score' && response < conditionalScoreHasFile){
                data.parent.FileRequired= true;
            }
        }
        if(commentConditionalType == 'Conditional'){
            if(questionType == 'Score' && response < conditionalScoreHasComment){
                data.parent.CommentRequired= true;
            }
        }
    }

    // handleHasFileAndComment(data){
    //     var response = data.parent.Response__c;

    //     console.log('handleHasFileAndCommentStart' + JSON.stringify(data));
    //     console.log('handleHasFileAndComment' + response);

    //     // 是否展示文件触发条件
    //     let fileConditionalType = data.parent.CheckItem__r.File_Conditional_Type__c;
    //     let conditionalScoreHasFile = data.parent.CheckItem__r.Conditional_Score_Has_File__c;
    //     let conditionalYesNoHasFile = data.parent.CheckItem__r.Conditional_Yes_No_Has_File__c;
    //     // 是否展示评论触发条件
    //     let commentConditionalType = data.parent.CheckItem__r.Comment_Conditional_Type__c;
    //     let conditionalScoreHasComment = data.parent.CheckItem__r.Conditional_Score_Has_Comment__c;
    //     let conditionalYesNoHasComment = data.parent.CheckItem__r.Conditional_Yes_No_Has_Comment__c;

    //     if((fileConditionalType == 'Optional' && response == 'No') || (fileConditionalType == 'Mandatory' && response == 'Yes') || 
    //         (fileConditionalType == 'Conditional' && response == conditionalYesNoHasFile)){
    //         data.parent.CheckItem__r.HasFile__c = true;
    //     }else{
    //         data.parent.CheckItem__r.HasFile__c = false;
    //     }

    //     if((commentConditionalType == 'Optional' && response == 'No') || (commentConditionalType == 'Mandatory' && response == 'Yes') || 
    //         (commentConditionalType == 'Conditional' && response == conditionalYesNoHasComment)){
    //         data.parent.CheckItem__r.HasComment__c = true;
    //     }else{
    //         data.parent.CheckItem__r.HasComment__c = false;
    //     }

    //     console.log('handleHasFileAndCommentEnd' + JSON.stringify(data));
    // }

    handleChangeResponse(event){
        let index = event.target.dataset.index;
        let value = event.target.value; 
        
        if(this.needRefresh){
            this.needRefresh = false;
        }else{
            this.needRefresh = true;
        }

        // 修改数据未保存，返回父级页面提示标识符
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );

        // 获取当前问题类型
        let question = this.treeData[index].parent.CheckItem__r.Question_Type__c;

        if(question == 'Multiple Selection'){
            let multipleSelection = [];

            // 获取当前是否为选中状态
            this.template.querySelectorAll('[data-id="checkbox"]').forEach(item => {
                if(item.checked){
                    // 设置多选值
                    multipleSelection.push(item.value);
                }
            });
            this.treeData[index].parent.Response__c = multipleSelection.join(',');

            console.log('multipleSelection',JSON.stringify(multipleSelection));
        }else if(question == 'Picklist'){
            // 设置单选框数据
            let checkBoxValue = event.detail.value;
            console.log(checkBoxValue);
            this.treeData[index].parent.Response__c = checkBoxValue;
        }else if(question == 'Integer'){
            
            // 根据正则表达式判断输入数据
            let pattern = /^[0-9]*[1-9][0-9]*$/;
            let flag = pattern.test(value);

            if(flag || value == 0){
                this.treeData[index].parent.Response__c = parseInt(value);
            }else if(value == ''){
                this.treeData[index].parent.Response__c = value;
            }

        }else if(question == 'Number'){
            
            // 根据正则表达式判断输入数据
            let pattern = /^[0-9]+(.[0-9]{1,2})?$/;
            let flag = pattern.test(value);

            if(flag || value == 0){
                this.treeData[index].parent.Response__c = parseFloat(value);
                console.log('wwwwNumber1---' + value);
            }else if(value == ''){
                this.treeData[index].parent.Response__c = value;
                console.log('wwwwNumber2---' + value);
            }

        }else if(question == 'Email'){
            let pattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            let flag = pattern.test(value);

            if(flag){
                this.treeData[index].parent.Response__c = value;
                console.log('wwwwemail---' + value);
            }
        }else if(question == 'Object'){
            this.treeData[index].parent.Response__c = value;
        }else{
            this.treeData[index].parent.Response__c = value;
        }

        // 根据响应条件处理展示评论或者上传文件选项
        this.handleHasFileAndCommentRequired(this.treeData[index]);
        // this.handleHasFileAndComment(this.treeData[index]);
    }

    handleChangeComments(event){
        let index = event.target.dataset.index;
        let value = event.target.value;

        this.treeData[index].parent.Comments__c = value
        // 修改数据未保存，返回父级页面提示标识符
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    // Edit click
    handleEdit() {
        this.isEditPage = true;
    }

    deleteTree(obj){
        delete obj.parent.option;
        delete obj.parent.yesNo;
        delete obj.parent.text;
        delete obj.parent.selection;
        delete obj.parent.picklist;
        delete obj.parent.score;
        delete obj.parent.object;
        delete obj.parent.number;
        delete obj.parent.email;
        delete obj.parent.isImgList;
        delete obj.parent.FileRequired;
        delete obj.parent.CommentRequired;
        if(obj.children){
            obj.children.forEach(child => {
                child.forEach(childItem => {
                    this.deleteTree(childItem);
                }); 
            }); 
        }   
    }

    // Save click
    @api
    handleSave() {
        console.log('wfcwfc---handleSave---444');
        // 保存更新
        this.spinnerFlag = true;

        // 设置保存按钮为不能响应，防止多次提交保存
        this.disabledSave = true;
        console.log('Data =' + JSON.stringify(this.treeData));

        // 删除掉处理的页面展示数据
        this.treeData.forEach(obj => {
            this.deleteTree(obj);
        })

        console.log('DataFilter =' + JSON.stringify(this.treeData));

        // 整合关联问题
        // if(this.checkRelateResult.length > 0){
        //     this.checkResult = this.checkResult.concat(this.checkRelateResult);
        // }

        saveAndDelCheckResult({
            checkResultJson:JSON.stringify(this.treeData),
            delCheckResult:JSON.stringify(this.delChildren)
        }).then(data => {
            console.log('data' + JSON.stringify(data));
            // this.showSuccess('Success');
            // 刷新
            this.dispatchEvent(new CustomEvent('refreshdata'));
            // 修改数据未保存，返回父级页面提示标识符
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        hasEdit : false,
                        saveFlag : 'inspectionItem'
                    }
                })
            );
            this.disabledSave = false;

            // 修改产品线状态为continue
            upsertProductLineStatus({
                recordId:this.recordItemId,
                status:'Continue',
                productLineChecked:''
            }).catch(error => {
                this.catchError(JSON.stringify(error));
            });

            if(!this.isBack){
                // 刷新当前页面
                this.getInit(true);
            }

            this.spinnerFlag = false;
            
        }).catch(error => {
            this.showError(error);

        })
    }

    @api
    handleSaveBackstage() {
        // 删除掉处理的页面展示数据
        let treeDateTemp = this.treeData;
        treeDateTemp.forEach(obj => {
            this.deleteTree(obj);
        })
        saveAndDelCheckResult({
            checkResultJson:JSON.stringify(treeDateTemp),
            delCheckResult:JSON.stringify(this.delChildren)
        }).then(data => {
        }).catch(error => {
        })
    }

    get acceptedFormats() {
        return ['.png','.jpg','.jfif','.jpeg','.pjp','.pjpeg','.gif'];
    }

    // 处理展示数据
    dataFormat(data, flag){
        data.forEach(item => {
            let parent = item.parent;
            this.dataFormatItem(parent);

            // 新增判断是否展示缩略图 YYL 20250304
            if(item.imgList){
                parent.isImgList = true;
            }else{
                parent.isImgList = false;
            }
            // wfc
            if(flag){
                item.parent.isShowPageItem = this.isShow;
            }

            // this.handleHasFileAndComment(item);
            this.handleHasFileAndCommentRequired(item);
            let child = item.children;
            if(child){
                // 获取子问题的排序号 YYL 20250309
                // parent.index = child[0][0].parent.Index__c;
                console.log('wwwwdataFormat' + child[0][0].parent.Index__c);
                child.forEach(itemChild => {
                    this.dataFormat(itemChild);
                })
            }
        })
    }

    dataFormatItem(data){
        let questionType = data.CheckItem__r.Question_Type__c;
        if(questionType == 'Yes/No'){
            data.option = this.yesNo;
            data.yesNo = true;
        }else if(questionType == 'Text'){
            data.text = true;
        }else if(questionType == 'Integer'){
            data.integer = true;
        }else if(questionType == 'Multiple Selection' || questionType == 'Picklist'){

            if(questionType == 'Multiple Selection'){
                data.selection = true;
            }else if(questionType == 'Picklist'){
                data.picklist = true;
            }

            // 判断是否有默认数据
            let choiceValue = [];
            if(data.Response__c != null && data.Response__c != ''){
                choiceValue = data.Response__c.split(";");
            }

            let choice = data.CheckItem__r.Enter_Choice__c.split(";");
            let enterChoice = [];
            for(var i in choice){
                let flag = false;

                // 根据暂存值设置默认选项
                if(choiceValue.indexOf(choice[i]) != -1){
                    flag = true;
                }

                enterChoice.push({
                    label:choice[i],
                    value:choice[i],
                    flag:flag
                });
            }

            console.log('wwwwenterChoice' + JSON.stringify(enterChoice));
            data.option = enterChoice;
        }else if(questionType == 'Score'){
            data.score = true;
            // YYL 根据设置的最大分数展示数据列 20250407
            let maxScore = data.CheckItem__r.MaximumScore__c;
            if(maxScore){
                let scoreOption = [];
                for(let i = 1;i <= maxScore;i++){
                    scoreOption.push({
                        label:i,
                        value:i
                    });
                }
                data.option = scoreOption;
            }else{
                data.option = this.score;
            }
        }else if(questionType == 'Object'){
            data.object = true;
        }else if(questionType == 'Number'){
            data.number = true;
        }else if(questionType == 'Email'){
            data.email = true;
        }
    }

    handleBack(){
        this.isBack = true;
        this.dispatchEvent(new CustomEvent('goback'));

        this.dispatchEvent(new CustomEvent('refreshdata'));
    }

    @track isShow = false;
    handleProcessingdata(event){
        console.log('parentIndex---' + event.detail.parentIndex);
        console.log('childIndex---' + event.detail.childIndex);
        console.log('childIndexItem---' + event.detail.childIndexItem);
        console.log('data---' + JSON.stringify(event.detail.data));
        console.log('index---' + JSON.stringify(event.detail.index));
        var parentIndex = event.detail.parentIndex;
        var showPage = event.detail.showPage;
        if(parentIndex !== undefined && parentIndex !== '' && parentIndex !== null){
            var childIndex = event.detail.childIndex;
            var childIndexItem = event.detail.childIndexItem;
            var data = event.detail.data;
            var index = event.detail.index;

            if(data){
                this.treeData[parentIndex].children[childIndex][childIndexItem] = data;
            }
            this.treeData[parentIndex].parent.isShowPageItem = showPage;
            
        }
        this.isShow = showPage;
        console.log('wwwwwww--------fffff-----' + showPage);
    }

    handleChangeHasEdit(){
        // 修改数据未保存，返回父级页面提示标识符
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    // 新增新的子问题 YYL 20250305
    handleAddRelate(event){
        let index = event.target.dataset.index;
        let children = this.treeData[index].children;
        let childrenItemJson = JSON.stringify(children[0]);
        let childrenItem = JSON.parse(childrenItemJson);
        this.initRelate(childrenItem,children);    
        children.push(childrenItem);

        // 通过更改needRefresh 刷新子组件
        if(this.needRefresh){
            this.needRefresh = false;
        }else{
            this.needRefresh = true;
        }
        
        // 修改数据未保存，返回父级页面提示标识符
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    // 初始化循环的子问题数据 YYL 20250307
    initRelate(childrenItem,children){
        for (var i = 0; i < childrenItem.length; i++){
            delete childrenItem[i].parent.Id;
            delete childrenItem[i].parent.Name;
            childrenItem[i].parent.Response__c = '';
            // 根据数据长度设置新的index
            childrenItem[i].parent.Index__c = children.length + 1;
            console.log('wwwwinitRelate' + JSON.stringify(childrenItem[i]));
            if(childrenItem[i].children){
                childrenItem[i].children.forEach(child => {
                    this.initRelate(child,childrenItem[i].children);
                }); 
            }   
        } 
    }

    // 存放删除的checkResult的Id
    @track delChildren = [];
    // 删除子问题 YYL 20250305
    handleDelRelate(event){
        let index = event.target.dataset.index;
        if(this.treeData[index].children.length > 1){
            let indexItem = event.target.dataset.index1;
            let childrenList = this.treeData[index].children[indexItem];

            // 判断是否已初始化 
            for(var i = 0; i < childrenList.length; i++){
                let parentId = childrenList[i].parent.Id;
                if(parentId){
                    this.delChildren.push(parentId);
                }
            }

            this.treeData[index].children.splice(indexItem, 1);

            console.log('wwwwdelChildren' + JSON.stringify(this.delChildren));
            if(this.needRefresh){
                this.needRefresh = false;
            }else{
                this.needRefresh = true;
            }

            // 修改数据未保存，返回父级页面提示标识符
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        hasEdit : true
                    }
                })
            );
        }else{
            this.catchError(this.label.Del_Relate);
        }
    }

    preview(event) {
        // Naviagation Service to the show preview
        this.filePreview(event.currentTarget.dataset.id);
    }

    handleDeletePicture(event){
        var Id = event.detail.sampleId;
        this.samplingInspections.forEach(obj => {
            if (obj.Id == Id) {
                obj.Img_Status__c = false;

            }
        });
        console.log('samplingId' + Id);
        this.dispatchEvent(new CustomEvent('refreshdata'));
    }

    async handleActionThree(event) {
        console.log('触发弹窗方法');
        const result = await LightningConfirm.open({
            message: Inspection_Delete_Picture,
            variant: 'headerless',
            label: 'this is the aria-label value',
        });

        if (result) {
            // 如果用户点击了确认，派发一个事件给子组件
            const childComponent = this.template.querySelector('c-upload-files3-lwc');
            if (childComponent) {
                childComponent.performAction();
            }
        }
    }
}