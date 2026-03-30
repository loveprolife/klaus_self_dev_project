/*
 * @Author: YYL
 * @LastEditors: TJP
 */
import { track, api, wire } from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import Sample_Image from '@salesforce/label/c.Sample_Image';
import Upload_Photo from '@salesforce/label/c.Upload_Photo';
import LightningConfirm from 'lightning/confirm';
import getPickList from '@salesforce/apex/NewSamplingAndTicketController.getPickList';
import Inspection_Delete_Picture from '@salesforce/label/c.Inspection_Delete_Picture';
import Inspection_Max_Text from '@salesforce/label/c.Inspection_Max_Text';
import Result_Integer_Max from '@salesforce/label/c.Result_Integer_Max';
import Result_Positive_Integer from '@salesforce/label/c.Result_Positive_Integer';


export default class NewInspectionItemNotePageLwc extends LightningNavigationElement {

    label = {
        Upload_Photo,  //Upload Photo
        Sample_Image,             // 示例图片
        Inspection_Delete_Picture,// 删除照片提示
        Inspection_Max_Text,
        Result_Integer_Max,
        Result_Positive_Integer
    }

    @api node;
    @api submit;
    @api response;
    @api parentIndex;
    @api childIndex;
    @api childIndexItem;
    @api disabled
    @api fieldRed;

    @track showPage = false;
    @track FileRequired = false;
    @track CommentRequired = false;
    @track isAustralia = false;
    @track showProductLine = false;

    connectedCallback(){
        // 校验是否满足响应条件
        this.fieldRed = this.fieldRed == undefined ? false : this.fieldRed;
        this.checkedChirldResponse();
        console.log('wwwwconnectedCallback------' + JSON.stringify(this.node));
        console.log('wwwwconnectedCallback------' + JSON.stringify(this.node.children));
        this.handleHasFileAndCommentRequired(this.node);
    }

    disconnectedCallback(){
        // 消除当前组件时修改数据值为空
        console.log('disconnectedCallback' + JSON.stringify(this.node));
    }

    lookupFilter = {
        'lookup': 'CustomLookupProvider.ProductFilter'
    }

    get needRefresh() {
        return this.refreshFlag;
    }

    handleRemoveLookup(type, index) {
        let alllookup = this.template.querySelectorAll('c-lookup-lwc');
        console.log(JSON.stringify(alllookup));
        for (let i = 0; i < alllookup.length; i++) {
            console.log(JSON.stringify(alllookup[i]));
            var lookup = alllookup[i];
            lookup.handleRemove();
            if (lookup.name==type && (index==null || lookup.getAttribute('data-index')==index)) {
                lookup.handleRemove();
            }
        }
    }

    @track tagStatus = '';
    handleChangeProductOption(event) {
        let index = event.target.dataset.recordid;
        this.tagStatus = index;
        let fieldName = event.target.dataset.fieldName;
        let selectRecord = event.detail.selectedRecord;
        console.log('选中' + index + fieldName + JSON.stringify(selectRecord));
        var parentJson = JSON.stringify(this.node);
        parentJson = JSON.parse(parentJson);
        if (selectRecord == undefined || selectRecord == '' || selectRecord == "") {
            parentJson.parent.Response__c = null;
            this.inputFull = false;
        } else {
            console.log('产品Id' + selectRecord.Id);
            this.inputFull = true;
            parentJson.parent.Response__c = selectRecord.Id;
        }
        this.node = parentJson;

        this.dispatchEvent(new CustomEvent(
            'data',{
                detail: {
                    parentIndex : this.parentIndex,
                    childIndex : this.childIndex,
                    childIndexItem : this.childIndexItem,
                    data : parentJson,
                    showPage : this.showPage
                }
            })
        );

        // 根据响应条件处理展示评论或者上传文件选项
        this.handleHasFileAndCommentRequired(this.node);

    }

    @api set needRefresh(value) {
        console.log('wwwwneedRefresh' + JSON.stringify(value));

        this.checkedChirldResponse();
    }

    @wire(getPickList, {objectName : 'Product__c', fieldName : 'Product_Line__c'})
    productLineOptions;

    handleChangeProductLine(event) {
        let value = event.target.value;
        var parentJson = JSON.stringify(this.node);
        parentJson = JSON.parse(parentJson);
        parentJson.parent.Product_Line__c = value;
        this.node = parentJson;
        var lookup = this.template.querySelector('c-lookup-lwc');
        if(lookup != null){
            lookup.updateOption({
                'lookup': 'CustomLookupProvider.ProductFilter',
                'Product_Line__c' : value
            });
        }

        this.handleRemoveLookup('onProductLine',this.tagStatus);
    }


    @track inputFull;
    checkedChirldResponse(){
        console.log('wwwwcheckedChirldResponse' + JSON.stringify(this.node));
        // 校验是否满足响应条件
        if(this.response){
            let response = JSON.stringify(this.response);
            //解析SalesRegion 澳洲区别抽样模块特殊处理
            console.log('wwwwscoreSymbolResponse' + JSON.stringify(response));
            this.isAustralia = this.node.parent.CheckItem__r.Sales_Region__c == 'Hisense Australia' ? true : false;
            let apiName = this.node.parent.CheckItem__r.Object_Api_Name__c == 'Product__c' ? true : false;
            this.showProductLine = this.isAustralia && apiName;
            console.log('Object_Api_Name__c : ' + this.node.parent.CheckItem__r.Object_Api_Name__c);
            console.log('this.showProductLine : ' + this.showProductLine);
            
            // 拆分基于分数问题展示子问题的显示条件 YYL 20250305
            let scoreSymbolResponse = this.node.parent.CheckItem__r.Score_Symbol_Response__c;
            let isScoreNode = false;
            if(scoreSymbolResponse){
                let scoreSymbol = JSON.stringify(scoreSymbolResponse).split('&');
                scoreSymbol.forEach(item => {
                    isScoreNode = this.compareNumbers(this.response,this.node.parent.CheckItem__r.Parent_Select__c,item);
                    if(isScoreNode){
                        return;
                    }
                });
                
                this.showPage = isScoreNode;
            }else{
                if(this.response == this.node.parent.CheckItem__r.Parent_Response__c ||
                    response == this.node.parent.CheckItem__r.Parent_Select__c ||
                    response.indexOf(this.node.parent.CheckItem__r.Parent_Select__c) != -1
                ){
                    this.showPage = true;
                }else{
                    this.showPage = false;
                }
            }
            console.log('wwwwcheckedChirldResponse2' + JSON.stringify(this.node));
            var node;
            var parentJson = JSON.stringify(this.node);
            parentJson = JSON.parse(parentJson);
            if(!this.showPage){
                parentJson.parent.Response__c = '';
            }
            node = parentJson;

            // console.log('子组件渲染结果' + JSON.stringify(this.node.parent.Response__c));
            if(this.node.parent != undefined) {
                this.inputFull = this.node.parent.Response__c == undefined ? '' : this.node.parent.Response__c;

            } else {
                this.inputFull = '';
            }
            console.log('结果' + this.inputFull);
            // 根据条件是否满足展示隐藏加减号 YYL 20250307
            if(this.parentIndex !== undefined && this.parentIndex !== '' && this.parentIndex !== null){
                console.log('wwwwcheckedChirldResponse2' + JSON.stringify(node));
                // 传输给父级数据
                this.dispatchEvent(new CustomEvent(
                    'data',{
                        detail: {
                            parentIndex : this.parentIndex,
                            childIndex : this.childIndex,
                            childIndexItem : this.childIndexItem,
                            data : node,
                            showPage : this.showPage
                        }
                    })
                ); 
            }
            console.log('NODE' + JSON.stringify(node));
        }
    }

    // 计算分数是否满足展示子问题 YYL 20250305
    compareNumbers(num1, num2, symbol) {
        if(symbol.indexOf('<') != -1){
            return num1 < num2;
        }else if(symbol.indexOf('<=') != -1){
            return num1 <= num2;
        }else if(symbol.indexOf('>') != -1){
            return num1 > num2;
        }else if(symbol.indexOf('>=') != -1){
            return num1 >= num2;
        }else if(symbol.indexOf('=') != -1){
            return num1 == num2;
        }else if(symbol.indexOf('!=') != -1){
            return num1 != num2;
        }
    }

    @track tips;
    handleChangeResponse(event){
        let value = event.target.value;

        // 修改数据未保存，返回父级页面提示标识符
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );

        // 获取当前问题类型
        let question = this.node.parent.CheckItem__r.Question_Type__c;
        // let apiName = this.node.parent.CheckItem__r.Object_Api_Name__c;
        // console.log('apiNameNote:' + apiName);
        var parentJson = JSON.stringify(this.node);
        parentJson = JSON.parse(parentJson);

        console.log('当前参数' + value + '类型' +question);

        if(question == 'Multiple Selection'){
            let multipleSelection = [];

            // 获取当前是否为选中状态
            this.template.querySelectorAll('[data-id="checkbox"]').forEach(item => {
                if(item.checked){
                    // 设置多选值
                    multipleSelection.push(item.value);
                }
            });
            value = multipleSelection.join(';');

            parentJson.parent.Response__c = value;
        }else if(question == 'Integer'){
            let maxInt = this.node.parent.CheckItem__r.Integer_Type_Max__c;  
            if (maxInt == null || maxInt == undefined || maxInt == '') {this.tips = Result_Positive_Integer;} else {this.tips = Result_Integer_Max + ' ' + maxInt;}        
            console.log('value' + value);
                let pattern = /^[1-9][0-9]*$/;
                let flag = pattern.test(value);
                console.log(flag);  
                if (flag) {
                    // 输入值是正整数
                    if (maxInt == null || maxInt == undefined || maxInt == '') {
                        // 没有最大值限制
                        parentJson.IntegerMaxTips = this.tips;
                        parentJson.parent.Response__c = parseInt(value);
                        parentJson._rowError = false;
                        parentJson._inputClass = '';
                    } else {
                        // 有最大值限制
                        parentJson.IntegerMaxTips = this.tips;
                        if (parseInt(value) > 0 && parseInt(value) <= maxInt) {
                            // 输入值在允许范围内
                            parentJson.parent.Response__c = parseInt(value);
                            parentJson._rowError = false;
                            parentJson._inputClass = '';
                        } else {
                            // 输入值超出允许范围
                            console.log('最大值定义清空');
                            parentJson.parent.Response__c = '';
                            parentJson._rowError = true;
                            parentJson._inputClass = 'slds-has-error';
                        }
                    }
                } else if (value == '') {
                    // 输入值为空
                    parentJson._rowError = false;
                    parentJson.parent.Response__c = null;
                    parentJson._inputClass = '';
                } else {
                    // 输入值不符合正则表达式（不是正整数）
                    console.log('输入值不符合要求，清空');
                    parentJson.parent.Response__c = null;
                    parentJson.parent.Response__c = '';
                    parentJson._rowError = true;
                    parentJson.IntegerMaxTips = this.tips;
                    parentJson._inputClass = 'slds-has-error';
                }
            // }
            parentJson.parent.Integer_Response__c = parentJson.parent.Response__c;

        }else if(question == 'Number'){
            
            // 根据正则表达式判断输入数据
            let pattern = /^-?[0-9]+(.[0-9]{1,2})?$/;
            let flag = pattern.test(value);

            if(flag || value == 0){
                parentJson.parent.Response__c = parseFloat(value);
            }else if(value == ''){
                parentJson.parent.Response__c = value;
            }

        }else if(question == 'Email'){
            let pattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            let flag = pattern.test(value);

            if(flag){
                parentJson.parent.Response__c = value;
                console.log('wwwwemail---' + value);
            }
        }else if(question == 'Text'){
            const tooLong = String(value.length) > 131072;
            if(tooLong) {
                parentJson.parent.Response__c = String(value).substring(0,131072);
    
            } else {
                parentJson.parent.Response__c = String(value);
            }
            // const row = this.node
            parentJson._rowError = tooLong;                // 直接写属性即可
            parentJson._inputClass = tooLong ? 'slds-has-error' : '';
            // 手动触发一次浅拷贝，保证模板刷新
            // this.node = [...this.node];
            console.log('wwwwText---' + String(value));
        }else{
            parentJson.parent.Response__c = value;
        }

        this.node = parentJson;
        
        this.dispatchEvent(new CustomEvent(
            'data',{
                detail: {
                    parentIndex : this.parentIndex,
                    childIndex : this.childIndex,
                    childIndexItem : this.childIndexItem,
                    data : parentJson,
                    showPage : this.showPage
                }
            })
        );

        this.inputFull = true;
        // 根据响应条件处理展示评论或者上传文件选项
        this.handleHasFileAndCommentRequired(this.node);
    }

    handleHasFileAndCommentRequired(data){  
        console.log('wwwwhandleHasFileAndCommentRequired' + JSON.stringify(data));
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
                this.FileRequired= true;
            }else {
                this.FileRequired= false;
            }
            if(commentConditionalType == 'Mandatory'){
                this.CommentRequired= true;
            }else {
                this.CommentRequired= false;
            }
            // Conditional条件必填
            if(fileConditionalType == 'Conditional'){
                if(questionType == 'Yes/No' && response == conditionalYesNoHasFile){
                    this.FileRequired= true;
                }
            }
            if(commentConditionalType == 'Conditional'){
                if(questionType == 'Yes/No' && response == conditionalYesNoHasComment){
                    this.CommentRequired= true;
                }
            }
            if(fileConditionalType == 'Conditional'){
                if(questionType == 'Score' && response < conditionalScoreHasFile){
                    this.FileRequired= true;
                }
            }
            if(commentConditionalType == 'Conditional'){
                if(questionType == 'Score' && response < conditionalScoreHasComment){
                    this.CommentRequired= true;
                }
            }
    }

    handleChangeRelateHistory(event){
        this.spinnerFlag = true;
        let value = event.target.value;
        this.inputFull = true;
        console.log('wwwwhandleChangeRelateHistory' + JSON.stringify(this.node));

        // 修改数据未保存，返回父级页面提示标识符
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );

        // 如果为多选问题校验是否包含子问题响应值 YYL 20250304
        var node;
        var parentJson = JSON.stringify(this.node);
        parentJson = JSON.parse(parentJson);
        if(parentJson.parent.CheckItem__r.Question_Type__c == 'Multiple Selection'){
            let multipleSelection = [];

            // 获取当前是否为选中状态
            this.template.querySelectorAll('[data-id="checkbox"]').forEach(item => {
                if(item.checked){
                    // 设置多选值
                    multipleSelection.push(item.value);
                }
            });
            parentJson.parent.Response__c = multipleSelection.join(';');
            value = multipleSelection.join(';');
        }else{
            parentJson.parent.Response__c = value;
        }

        this.node = parentJson;
        node = parentJson;

        // 传输给父级数据
        this.dispatchEvent(new CustomEvent(
            'data',{
                detail: {
                    parentIndex : this.parentIndex,
                    childIndex : this.childIndex,
                    childIndexItem : this.childIndexItem,
                    data : node,
                    showPage : this.showPage
                }
            })
        );

        let children = this.node.children;
        // 没有子数据则不刷新
        if(children){
            // 刷新子组件
            let eles = this.template.querySelectorAll('c-new-inspection-item-note-page-lwc');
            for (let index = 0; eles && index < eles.length; index++) {
                let ele = eles[index];
                ele.response = value;
                ele.handleInit();
            }
        }
    }

    @api
    handleInit(){
        this.checkedChirldResponse();
    }

    handleProcessingChilddata(event){
        var childIndex = event.detail.childIndex;
        var childIndexItem = event.detail.childIndexItem;
        var data = event.detail.data;

        console.log('this.node.children[childIndex]' + JSON.stringify(childIndex));

        // 修改数据异常问题，创建新的数据接收子组件数据，在修改原本数据做修改
        var parentJson = JSON.stringify(this.node);
        parentJson = JSON.parse(parentJson);
        parentJson.children[childIndex][childIndexItem] = data;
        this.node = parentJson;

        // 传输给父级数据
        this.dispatchEvent(new CustomEvent(
            'data',{
                detail: {
                    parentIndex : this.parentIndex,
                    childIndex : this.childIndex,
                    childIndexItem : this.childIndexItem,
                    data : this.node,
                    showPage : this.showPage
                }
            })
        );
    }

    handleChangeComments(event){
        let value = event.target.value;

        var parentJson = JSON.stringify(this.node);
        parentJson = JSON.parse(parentJson);
        parentJson.parent.Comments__c = value;
        console.log('wwww' + JSON.stringify(parentJson));
        this.node = parentJson;

        // 传输给父级数据
        this.dispatchEvent(new CustomEvent(
            'data',{
                detail: {
                    parentIndex : this.parentIndex,
                    childIndex : this.childIndex,
                    childIndexItem : this.childIndexItem,
                    data : this.node,
                    showPage : this.showPage
                }
            })
        );

        // this.node.parent.Comments__c = value
        // 修改数据未保存，返回父级页面提示标识符
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
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