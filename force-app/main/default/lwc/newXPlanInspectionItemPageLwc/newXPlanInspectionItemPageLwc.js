/*
 * @Author: YYL
 * @LastEditors: YYL
 */
import { wire , track, api} from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import INSPECTION_REPORT_SAVE from '@salesforce/label/c.INSPECTION_REPORT_SAVE';
import INSPECTION_REPORT_EDIT from '@salesforce/label/c.INSPECTION_REPORT_EDIT';
import INSPECTION_REPORT_BACK from '@salesforce/label/c.INSPECTION_REPORT_BACK';
import saveCheckResult from '@salesforce/apex/newXPlanCheckItemController.saveCheckResult';
import addCheckResult from '@salesforce/apex/newXPlanCheckItemController.addCheckResult';
import checkInitStatus from '@salesforce/apex/newXPlanCheckItemController.checkInitStatus';
import getcheckResultInitInfo from '@salesforce/apex/newXPlanCheckItemController.getcheckResultInitInfo';
import saveAttachment from '@salesforce/apex/InspectorDailyReportController.saveAttachment';

import Upload_Photo from '@salesforce/label/c.Upload_Photo';

export default class NewXPlanInspectionItemPageLwc extends LightningNavigationElement {
    label = {
        INSPECTION_REPORT_SAVE,             // 保存
        INSPECTION_REPORT_EDIT,             // 修改
        INSPECTION_REPORT_BACK,             // Back
        Upload_Photo
    }
        
    @api checkXPlanId;
    @api storeId;
    @api checkLabel;
    @api status;
    @api submit;

    // 上传文件id
    @api contentVersionId;

    // 是否存在暂存数据
    @track showCheckResult = false;
    @track showSave = true;
    @api disabled = false;
    @track disabledSave = false;

    @track record;
    @track isEditPage = false;                  // 显示编辑页面
    @track checkItemInfo;
    @track spinnerFlag = false;

    // 是否是返回操作
    @track isBack = false;

    // 是否有改动
    @track hasEdit = false;

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

    @api treeData = [];
    @track showChildren = true;

    // 初始化
    connectedCallback() {
        this.spinnerFlag = true;
        console.log('productLine' + this.productLine);
        console.log('checkXPlanId' + this.checkXPlanId);
        console.log('storeId' + this.storeId);
        console.log('status' + this.status);
        console.log('submit' + this.submit);
        console.log('checkLabel' + this.checkLabel);

        this.getInit();

        // 根据是否提交判断展示状态
        // if(this.status == 'Submitted'){
        //     this.showSave = false;
        //     this.disabled = true;
        // }

    }

    getInit(){
        this.spinnerFlag = true;
        // 查询当前检查项是否已初始化
        checkInitStatus({
            checkItemType:this.checkLabel,
            checkXPlanId:this.checkXPlanId,
        }).then(data => {
            if(data.isSuccess){
                console.log('wwww' + JSON.stringify(data.data));
                if(data.data.initStatus){
                    //查询初始化数据
                    getcheckResultInitInfo({
                        checkItemType : this.checkLabel,
                        checkXPlanId : this.checkXPlanId,
                    }).then(data => {
                        if(data.isSuccess){
                            this.treeData = data.data.checkResultData;
                            this.dataFormat(this.treeData);
                        }
                    }).catch(error => {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'error',
                            message: 'error',
                            variant: 'error',
                        }));
                    })
                }else{
                    // 初始化检查项
                    this.initCheckResult();
                }
            }
            this.spinnerFlag = false;
        })
    }

    // 初始化CheckResult
    initCheckResult(){
        this.spinnerFlag = true;
        addCheckResult({
            checkItemType : this.checkLabel,
            checkXPlanId : this.checkXPlanId
        }).then(data => {
            console.log('wwwwdata.data' + JSON.stringify(data.checkResultAdd));
            if(data.isSuccess){
                this.getInit();
            }
            this.spinnerFlag = false;
        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Error,
                variant: 'error',
            }));
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

        console.log('wwwwwggghhyesno---' + index);
        console.log('wwwwwggghhyesno---' + value);


        // this.needRefresh = true;
        this.treeData[index].parent.Response__c = value;
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
        console.log('wwwww---handleHasFileAndCommentStart---' + JSON.stringify(data));

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
        console.log('wwwww---handleHasFileAndCommentEnd---' + JSON.stringify(data));
    }

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
        if(obj.children){
            obj.children.forEach(childItem => {
                this.deleteTree(childItem);
            }); 
        }   
    }

    // Save click
    @api
    handleSave() {
        // 保存更新
        // this.spinnerFlag = true;

        // 设置保存按钮为不能响应，防止多次提交保存
        console.log('Data =' + JSON.stringify(this.treeData));

        // // 删除掉处理的页面展示数据
        this.treeData.forEach(obj => {
            this.deleteTree(obj);
        })

        console.log('DataFilter =' + JSON.stringify(this.treeData));

        saveCheckResult({
            checkResultJson:JSON.stringify(this.treeData)
        }).then(data => {
            console.log('data' + JSON.stringify(data));
        }).catch(error => {
            this.showError(error);
        })
    }

    get acceptedFormats() {
        return ['.png','.jpg','.jfif','.jpeg','.pjp','.pjpeg','.gif'];
    }

    // 处理展示数据
    dataFormat(data){
        data.forEach(item => {
            let parent = item.parent;
            this.dataFormatItem(parent);
            // this.handleHasFileAndComment(item);
            this.handleHasFileAndCommentRequired(item);
            let child = item.children;
            if(child){
                this.dataFormat(child);
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
                choiceValue = data.Response__c.split(",");
            }

            let choice = data.CheckItem__r.Enter_Choice__c.split(",");
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
            data.option = this.score;
        }   
    }

    handleBack(){
        this.isBack = true;
        this.dispatchEvent(new CustomEvent('goback'));

        this.dispatchEvent(new CustomEvent('refreshdata'));
    }

    handleProcessingdata(event){
        console.log('parentIndex' + event.detail.parentIndex);
        console.log('childIndex' + event.detail.childIndex);
        console.log('data' + JSON.stringify(event.detail.data));
        var parentIndex = event.detail.parentIndex;
        var childIndex = event.detail.childIndex;
        var data = event.detail.data;

        this.treeData[parentIndex].children[childIndex] = data;
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
}