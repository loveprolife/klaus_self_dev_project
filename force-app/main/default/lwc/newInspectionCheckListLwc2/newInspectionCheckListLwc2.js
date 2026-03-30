/*
 * @Author: TJP
 * @Date: 2024-10-29 11:49:50
 * @LastEditTime: 2024-11-26 10:06:23
 * @Description: 
 * @FilePath: \HisenseAll20240426\force-app\main\default\lwc\NewInspectionCheckListLwc2\NewInspectionCheckListLwc2.js
 */
import { wire , track, api} from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import INSPECTION_REPORT_SAVE from '@salesforce/label/c.INSPECTION_REPORT_SAVE';
import INSPECTION_REPORT_EDIT from '@salesforce/label/c.INSPECTION_REPORT_EDIT';
import INSPECTION_REPORT_BACK from '@salesforce/label/c.INSPECTION_REPORT_BACK';
// import getCheckItemInfo from '@salesforce/apex/newCheckItemController.getCheckItemInfo';
// import getRelateCheckItem from '@salesforce/apex/newCheckItemController.getRelateCheckItem';
// import getRelateCheckItemHistory from '@salesforce/apex/newCheckItemController.getRelateCheckItemHistory';
import saveCheckResult from '@salesforce/apex/newCheckItemController.saveCheckResult';
import addCheckResult from '@salesforce/apex/newCheckItemController.addCheckResult';
import checkInitStatus from '@salesforce/apex/newCheckItemController.checkInitStatus';
import getcheckResultInitInfo from '@salesforce/apex/newCheckItemController.getcheckResultInitInfo';
import upsertProductLineStatus from '@salesforce/apex/NewInspectionDailyReportPageController.upsertProductLineStatus';
// import getCheckItemInfoHistory from '@salesforce/apex/newCheckItemController.getCheckItemInfoHistory';
// import getHasCheckResult from '@salesforce/apex/newCheckItemController.getHasCheckResult';
import saveAttachment from '@salesforce/apex/InspectorDailyReportController.saveAttachment';
import samplingInspectionAdd from '@salesforce/apex/NewSamplingAndTicketController.samplingInspectionAdd';
import getRewriteInitData from '@salesforce/apex/NewSamplingAndTicketController.getRewriteInitData';
import getUniteInitData from '@salesforce/apex/NewSamplingAndTicketController.getUniteInitData';
import INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE from '@salesforce/label/c.INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE';
import INSPECTION_REPORT_MSG_PRODUCT_EXISTS from '@salesforce/label/c.INSPECTION_REPORT_MSG_PRODUCT_EXISTS';
import LightningConfirm from 'lightning/confirm';
import samplingInspectionDelete from '@salesforce/apex/NewSamplingAndTicketController.samplingInspectionDelete';
import INSPECTION_REPORT_ATTACHMENT from '@salesforce/label/c.INSPECTION_REPORT_ATTACHMENT';
import Sample_Inspection from '@salesforce/label/c.Sample_Inspection';
import upsertRecord from '@salesforce/apex/NewSamplingAndTicketController.upsertRecord';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PromoterDailyReport_AddNewItemSuccess from '@salesforce/label/c.PromoterDailyReport_AddNewItemSuccess';
import Inspection_No from '@salesforce/label/c.Inspection_No';
import Inspection_Yes from '@salesforce/label/c.Inspection_Yes';
import Inspection_Dishwasher from '@salesforce/label/c.Inspection_Dishwasher';
import Inspection_WM from '@salesforce/label/c.Inspection_WM';
import Inspection_TV from '@salesforce/label/c.Inspection_TV';
import Inspection_Laser_TV from '@salesforce/label/c.Inspection_Laser_TV';
import Inspection_Cooking from '@salesforce/label/c.Inspection_Cooking';
import Inspection_Refrigerator from '@salesforce/label/c.Inspection_Refrigerator';
import Inspection_Freezer from '@salesforce/label/c.Inspection_Freezer';
import Inspection_Sound_Bar  from '@salesforce/label/c.Inspection_Sound_Bar';
import Inspection_Ticket from '@salesforce/label/c.Inspection_Ticket';
import Inspection_Booth from '@salesforce/label/c.Inspection_Booth';
import Inspection_Competing_Goods from '@salesforce/label/c.Inspection_Competing_Goods';
import Inspection_Material from '@salesforce/label/c.Inspection_Material';
import Inspection_Prototype from '@salesforce/label/c.Inspection_Prototype';
import Inspection_Prototype_Booth from '@salesforce/label/c.Inspection_Prototype_Booth';
import Inspection_Description from '@salesforce/label/c.Inspection_Description';
import Inspection_Retail_Price from '@salesforce/label/c.Inspection_Retail_Price';
import Inspection_Unit_Recent_Description from '@salesforce/label/c.Inspection_Unit_Recent_Description';
import Inspection_Unit_Distant_view_Description from '@salesforce/label/c.Inspection_Unit_Distant_view_Description';
import Inspection_Sound_Bar_Distant_view_Description from '@salesforce/label/c.Inspection_Sound_Bar_Distant_view_Description';
import Inspection_LaserTV_Distant_view_Description from '@salesforce/label/c.Inspection_LaserTV_Distant_view_Description';
import Inspection_Routine  from '@salesforce/label/c.Inspection_Routine';
import Inspection_Success  from '@salesforce/label/c.Inspection_Success';
import Inspection_Demand_I  from '@salesforce/label/c.Inspection_Demand_I';
import Inspection_Demand_II  from '@salesforce/label/c.Inspection_Demand_II';
import Inspection_Demand_III  from '@salesforce/label/c.Inspection_Demand_III';
import Inspection_Standard  from '@salesforce/label/c.Inspection_Standard';
import Inspection_Compliance  from '@salesforce/label/c.Inspection_Compliance';
import getPictureList from '@salesforce/apex/NewSamplingAndTicketController.getPictureList';
import getOfficePhoto from '@salesforce/apex/NewSamplingAndTicketController.getOfficePhoto';


export default class NewInspectionCheckListLwc2 extends LightningNavigationElement {

    label = {
        INSPECTION_REPORT_SAVE,             // 保存
        INSPECTION_REPORT_EDIT,             // 修改
        INSPECTION_REPORT_BACK,             // Back
        INSPECTION_REPORT_MSG_PRODUCT_EXISTS,           // 产品已存在
        INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE,     // {0}将被删除
        INSPECTION_REPORT_ATTACHMENT,       // 附件
        PromoterDailyReport_AddNewItemSuccess, //添加成功
        Sample_Inspection,
        Inspection_Dishwasher,
        Inspection_WM,
        Inspection_TV,
        Inspection_Laser_TV,
        Inspection_Cooking,
        Inspection_Refrigerator,
        Inspection_Freezer, 
        Inspection_Sound_Bar,
        Inspection_Booth,
        Inspection_Competing_Goods,
        Inspection_Material, 
        Inspection_Prototype,
        Inspection_Prototype_Booth,
        Inspection_Description,
        Inspection_Retail_Price,
        Inspection_Unit_Recent_Description,
        Inspection_Unit_Distant_view_Description,
        Inspection_Sound_Bar_Distant_view_Description,
        Inspection_LaserTV_Distant_view_Description,
        Inspection_Routine,
        Inspection_Success,
        Inspection_Demand_I,
        Inspection_Demand_II,
        Inspection_Demand_III,
        Inspection_Compliance,
        Inspection_Standard,

    }
    
    @api productLine;
    @api recordId;
    @api recordItemId;
    @api storeId;
    @api checkLabel;
    @api status;
    @api submit;
    @track region;
    @track titleDescription;

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
    @track activeSamplingComplianceSections = ['open'];
    @track activeSamplingInspectionSections = ['open'];
    @track activeSampleUpSections = ['closed'];
    @track productSearchInfo = [];  //20241025搜索产品初始化
    @track isShowBody = false;
    @track isShowUnite = false;
    @track samplingInspections = [];            // 出样检查
    @track checkResultsInfo = []; 
    @track checkUniteResultsInfoOne = []; 
    @track checkUniteResultsInfoTwo = []; 

    // @track record = {};
    @track checkResults = {}; 
    @track checkResultsIsRelatedToProduct = []; 
    @track POPDescription;
    @track SetUpDescription;
    @track DisPlayDescription;
    @track officeCheckItem = [];
    @track pictureNeed = true;
    @track activeTicketSections = [];
    @track isDisplayShow = false;
    @track LineLabel;
    @track inspectionTitlelabel;
    @track isShowPhoto;
    @track productLineDetail = [];
    @track produceLinePhotoId;
    @track pictureList = [];

    // 上传照片流信息
    @track attendancePhotoStream;
    // 主数据关联图片集合
    @track pictureList = [];
    // 点击小图片，放大标记
    @track showPicture = false;
    // 点击删除图片提示框标记
    @track showDeletePicture = false;
    // 大图片src地址
    @track shopPictureSrc = '';
    // 大图片ContentDocumentId
    @track shopPictureId = '';
    // 删除图片加载……标记
    @track isShowSpinner = false;
    // 是否可以上传更改图片 true：可以 false：不可以
    @track status = false;
    // 抽样图片
    @track pictureNeed = false;

/**初始化 Sampling_Inspection__c 标签*/
@track samplingInspectionInfo = {
    ReRe__c: '',
    Quantity_Of_Exhibits_DS__c: '',
    Quantity_Of_Exhibits_OWD__c: '',
    Stock__c: '',
    On_Wall_Display__c: '',
    POP__c: '',
    Is_POP__c:'',
    Is_Set_up_Status__c:'',
    Is_Prototype_Complete__c: '',
    Is_Built_in_Video__c: '',
    Is_Epos__c: '',
    Price__c: '',
    Set_up_Status__c: '',
    Display_Stand__c: '',
    Display_Type__c: '',
    Status__c:'',
    Display_Status__c:'',
    Img_Status__c:''
};
@wire(getObjectInfo, { objectApiName: 'Sampling_Inspection__c' })
wiredSamplingInspectionInfo({ error, data }) {
if (data) {
    this.samplingInspectionInfo = {
        ReRe__c: data.fields.ReRe__c.label,
        On_Wall_Display__c: data.fields.On_Wall_Display__c.label,
        POP__c: data.fields.POP__c.label,
        Is_POP__c: data.fields.Is_POP__c.label,
        Quantity_Of_Exhibits_DS__c: data.fields.Quantity_Of_Exhibits_DS__c.label,
        Quantity_Of_Exhibits_OWD__c: data.fields.Quantity_Of_Exhibits_OWD__c.label,
        Stock__c : data.fields.Stock__c.label,
        Is_Prototype_Complete__c : data.fields.Is_Prototype_Complete__c.label,
        Is_Built_in_Video__c : data.fields.Is_Built_in_Video__c.label,
        Is_Epos__c : data.fields.Is_Epos__c.label,
        Price__c : data.fields.Price__c.label,
        Set_up_Status__c : data.fields.Set_up_Status__c.label,
        Is_Set_up_Status__c : data.fields.Is_Set_up_Status__c.label,
        Display_Stand__c : data.fields.Display_Stand__c.label,
        Display_Type__c : data.fields.Display_Type__c.label,
        Display_Status__c: data.fields.Display_Status__c.label,
        Img_Status__c: data.fields.Img_Status__c.label
    }
} else if (error) {
    console.log(error);
    this.showError('Sampling_Inspection__c getInformation error');
}
}

    // 初始化
    connectedCallback() {
        this.spinnerFlag = true;
        console.log('productLine--' + this.productLine);
        console.log('recordId' + this.recordId);
        console.log('recordItemId' + this.recordItemId);
        console.log('storeId' + this.storeId);
        console.log('status' + this.status);
        console.log('submit' + this.submit);
        console.log('Lable' + this.checkLabel);
        var param = this.checkLabel;
        this.handleSwitchTitleLanguage(param);

        if(this.productLine == 'Laser TV') {
            console.log('入参-----');
            this.isShowPhoto = true;
            this.handleGetOfficePhoto();
        } else {
            this.isShowPhoto = false;
        }

        if(this.checkLabel != 'PrototypeAndBooth') {
            this.getInit();
            this.isShowUnite = false;
        } else {
            this.isShowUnite = true;
            this.handleCreateUniteSampling()
        }
        
        //暂时注释
        if(this.checkLabel == 'Prototype') {
            this.isShowUnite = false;
            this.isShowBody = true;
            this.handleCreate();
        } else {
            this.isShowBody = false;
        }
        

        // 根据是否提交判断展示状态
        if(this.status == 'Submitted'){
            this.showSave = false;
            this.disabled = true;
        }

    }

    getInit(){
        this.spinnerFlag = true;
        // 查询当前检查项是否已初始化
        checkInitStatus({
            checkItemType:this.checkLabel,
            inspectionProductItemId:this.recordItemId
        }).then(data => {
            if(data.isSuccess){
                if(data.data.initStatus){
                    // 查询初始化数据
                    getcheckResultInitInfo({
                        checkItemType : this.checkLabel,
                        inspectionProductItemId : this.recordItemId,
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
        console.log('初始化产品线' + this.productLine);

        //初始化抽样检查
        var lookupProduct;
        lookupProduct = {
            productLookup: {
                'lookup' : 'CustomLookupProvider.InternationalProductFilter',
                'salesRegion' : this.region,
                'Product_Line__c' : this.productLine
            }
        }        
        this.productSearchInfo = lookupProduct;
    }

    // 初始化CheckResult
    initCheckResult(){
        this.spinnerFlag = true;
        addCheckResult({
            checkItemType : this.checkLabel,
            inspectorDailyReportId : this.recordId,
            inspectionProductItemId : this.recordItemId,
            productLine : this.productLine
        }).then(data => {
            console.log('wwwwdata.data' + JSON.stringify(data));

            // console.log('wwwwdata.data' + JSON.stringify(data.checkResultAdd));
            if(data.isSuccess){
                //20241029暂时注释循环
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
            { label: Inspection_Yes, value: 'Yes'},
            { label: Inspection_No, value: 'No'},
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
        if(this.isShowBody) {
            this.upsertRecord(false);
        }
        //检查项暂时注释
        saveCheckResult({
            checkResultJson:JSON.stringify(this.treeData)
        }).then(data => {
            console.log('data' + JSON.stringify(data));
            this.showSuccess(Inspection_Success);
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
                recordId: this.recordItemId,
                status:'Continue',
                productLineChecked:''
            }).catch(error => {
                this.catchError(JSON.stringify(error));
            });

            if(!this.isBack){
                // 刷新当前页面
                this.getInit();
            }

            this.spinnerFlag = false;
            
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
    handleSampleUpToggle(event) {
        let openSections = event.detail.openSections;
        var sections = [];
        if (openSections.length == 0) {
            sections = []; 
        } else if (openSections.length==1) {
            sections = [openSections[0]];
        } else {
            openSections.forEach(obj => {
                if (obj!=this.activeSampleUpSections[0]) {
                    sections = [obj];
                }
            });
        }
        this.activeSampleUpSections = sections;
    }
    // 选择产品变更（基于产品线）
    // 选择产品变更（基于产品线）
    handleChangeProductOptionByProductLine(resp) {
    console.log('==========>product change by product line');
    var selectProductId;
    if (resp.detail.selectedRecord==undefined) {
    return;
    } else {
    selectProductId = resp.detail.selectedRecord.Id;
    }
    var index = resp.target.dataset.index;
    // 判断是否已存在产品
    for (let i = 0; i < this.samplingInspections.length; i++) {
    var item = this.samplingInspections[i];
    if (item.Product__c==selectProductId) {
        // this.showError('Product already exists');
        this.showError(this.label.INSPECTION_REPORT_MSG_PRODUCT_EXISTS);
        return;
    }
    }
    this.isShowSpinner = true;
    samplingInspectionAdd({
    recordId: this.recordItemId,
    recordJson: JSON.stringify(this.record),
    displayType:'',
    productId: selectProductId
    }).then(data => {
    console.log('---------->data='+data);
    if (data.isSuccess) {
        if (data.data.record) {
            this.record = data.data.record;
        }
        // 只需要整理刷新check list 信息
        this.addCheckResultsInfoDataFormat(data, selectProductId);
        // 清空lookup
        this.handleRemoveLookup('onProductLine',index);
        this.showSuccess(this.label.PromoterDailyReport_AddNewItemSuccess);
        this.dispatchEvent(new CustomEvent('refreshdata'));
        this.isShowSpinner = false;
    } else {
        this.isShowSpinner = false;
        this.showError(data.message);
    }
    }).catch(error => {
    // 清空lookup
    this.handleRemoveLookup('onProductLine',index);
    this.catchError(JSON.stringify(error));
    this.isShowSpinner = false;
    });
    }
    // 新增check list 信息（新增产品必须为计划外，不能影响已修改未保存数据）
    addCheckResultsInfoDataFormat(data, productId) {
        var filterNewSi = data.data.samplingInspections.filter(obj => obj.Product__c == productId);
        if (filterNewSi.length>0) {
        var newProduct = filterNewSi[0];
        this.samplingInspections.push(newProduct);
        var filterNewInfo = this.checkResultsInfo.filter(obj => obj.productLine == newProduct.Product__r.Product_Line__c);
        var item;
        if (filterNewInfo.length == 0) {
            this.handleSetLinesOption(this.productLine);
            console.log('产品线' + this.productLine);
            item = {
                //巡店员日报日语翻译  BY lizunxing 20231020
                productLine: this.productLine,
                productLineName: this.LineLabel,
                // isTv : newProduct.Product__r.Product_Line__c == 'TV' ? true : false,
                // isTv : true,
                productLookup: {
                    'lookup' : 'CustomLookupProvider.InternationalProductFilter',
                    'salesRegion' : this.region,
                    'Product_Line__c' : this.productLine
                },
                samplingInspection: true,
                samplingInspectionPlanIn: [],
                samplingInspectionPlanOut: [],
                productLineItem: [],
            };
            // 判断产品线内容是否是出样外
            if (newProduct.Unplanned_Sample__c == 'No') {
                item.AllSamplePlanOut = false;
            } else {
                item.AllSamplePlanOut = true;
            }
            if (data.data.checkResults[newProduct.Product__r.Product_Line__c]!=undefined) {
                var checkResultitem = data.data.checkResults[newProduct.Product__r.Product_Line__c];
                Object.keys(checkResultitem).forEach(pjObj => {
                    var project = checkResultitem[pjObj];
                    var pj = {
                        project: pjObj, 
                        projectItems: project,
                        projectItems_done: project.filter(pr => pr.Scores__c!= -1).length, 
                        projectItems_total: project.length
                    };
                    item.productLineItem.push(pj);
                });
            }
            this.checkResultsInfo.push(item);
        } else {
            item = filterNewInfo[0];
        }
        // 判断产品线内产品是否全是出样外
        if (newProduct.Unplanned_Sample__c == 'No' && item.AllSamplePlanOut) {
            item.AllSamplePlanOut = false;
        }
        // 计划外出样
        if (newProduct.Unplanned_Sample__c == 'Yes') {
            newProduct['index'] = item.samplingInspectionPlanOut.length+1;
            if (newProduct.Placement_Status__c == '展出') {
                newProduct['isChecked'] = true;
                newProduct['showDetail'] = true;
                newProduct['isCheckedInfo'] = 'Yes';
            } else if (newProduct.Placement_Status__c == '未展出'){
                newProduct['isChecked'] = false;
                newProduct['showDetail'] = false;
                newProduct['isCheckedInfo'] = 'No';
            }else {
                newProduct['showDetail'] = false;
                newProduct['isCheckedInfo'] = '';
            }
            item.samplingInspectionPlanOut.push(newProduct);
        }
        // 判断是否存在计划外出样
        if (item.samplingInspectionPlanOut.length>0) {
            item.hasPlanOut = true;
        } else {
            item.hasPlanOut = false;
        }
        // 排序
        var productLineSort = [];
        productLineSort.push(this.label.INSPECTION_REPORT_GENERAL);
        this.productLineValueSort.forEach(obj => {
            productLineSort.push(obj.label);
        });
        this.checkResultsInfo.sort((a, b) => {
            const indexA = productLineSort.indexOf(a.productLine);
            const indexB = productLineSort.indexOf(b.productLine);
            return indexA - indexB;
        });
    }
    }
    // lookup remove
    handleRemoveLookup(type, index) {
    let alllookup = this.template.querySelectorAll('c-office-lookup-lwc');
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
    async handleSamplingInspectionDelete(event) {
        var resultindex = Number(event.target.dataset.resultindex);
        var index = Number(event.target.dataset.index);
        var samplingId = event.target.dataset.id;
        var productName = event.target.dataset.name;
        
        console.log('WWWeven参数' + JSON.stringify(event.target.dataset));
        
            var index = event.target.dataset.index;
            const result = await LightningConfirm.open({
                message: this.label.INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE.format(productName),
                variant: 'headerless',
                label: 'this is the aria-label value',
                // setting theme would have no effect
            });
            if (result) {
                
                // todo 选ok逻辑
                console.log('wwww---选ok逻辑---' + index);
                samplingInspectionDelete({
                    recordJson: JSON.stringify(this.record),
                    samplingId: samplingId
                }).then(data => {
                    if (data.isSuccess) {
                        if (data.data.record) {
                            this.record = data.data.record;
                        }
                        // Deloitte Yin Mingjie 20231114 start
                        
                        // Deloitte Yin Mingjie 20231114 end
                        // 重新格式化 SamplingInspections
                        var newSamplingInspections = [];
                        this.samplingInspections.forEach(obj => {
                            if (obj.Id != samplingId) {
                                newSamplingInspections.push(obj);
                            }
                        });
                        this.samplingInspections = newSamplingInspections;
                        // 重新格式化 CheckResultsInfo.samplingInspectionPlanOut
                        var samplingInspectionPlanOut = this.checkResultsInfo[resultindex].samplingInspectionPlanOut;
                        var newSamplingInspectionPlanOut = [];
                        samplingInspectionPlanOut.forEach(obj => {
                            if (obj.Id != samplingId) {
                                obj.index = newSamplingInspectionPlanOut.length+1
                                newSamplingInspectionPlanOut.push(obj);
                            }
                        });
                        this.checkResultsInfo[resultindex].samplingInspectionPlanOut = newSamplingInspectionPlanOut;
                        // 重新格式化 CheckResultsInfo.samplingInspectionPlanIn  日本删除计划内产品
                        var samplingInspectionPlanIn = this.checkResultsInfo[resultindex].samplingInspectionPlanIn;
                        var newSamplingInspectionPlanIn = [];
                        samplingInspectionPlanIn.forEach(obj => {
                            if (obj.Id != samplingId) {
                                obj.index = newSamplingInspectionPlanIn.length+1
                                newSamplingInspectionPlanIn.push(obj);
                            }
                        });
                        this.checkResultsInfo[resultindex].samplingInspectionPlanIn = newSamplingInspectionPlanIn;
                        // 重新格式化 CheckResultsInfo
                        var newcheckResultsInfo = [];
                        for (let i = 0; i < this.checkResultsInfo.length; i++) {
                            if (this.checkResultsInfo[i].samplingInspection!=undefined && 
                                (this.checkResultsInfo[i].samplingInspectionPlanIn.length!=0 || this.checkResultsInfo[i].samplingInspectionPlanOut.length!=0)) {
                                newcheckResultsInfo.push(this.checkResultsInfo[i])
                            } else if (this.checkResultsInfo[i].samplingInspection==undefined) {
                                newcheckResultsInfo.push(this.checkResultsInfo[i])
                            }
                        }
                        // this.checkResultsInfo = newcheckResultsInfo;
                        // console.log('删除参数' + JSON.stringify(this.checkResultsInfo));
        
                        // var param = [];
                        // for (let i = 0; i < newcheckResultsInfo.length; i++){
                        //     param.push(newcheckResultsInfo[i].displayType);
                        // }
                        // console.log('WWW打印测试' + JSON.stringify(param));
                        // console.log('WWW打印测试' + JSON.stringify(this.detailDisplayInfo));
                        // console.log('WWW打印测试' + JSON.stringify(this.productLineDisplayInfo));
                        // console.log('WWW打印测试' + JSON.stringify(this.detailDisplayInfo.length));
                        // console.log('WWW打印测试' + JSON.stringify(this.productLineDisplayInfo.length));
        
                        // 获取集合 B 中的所有 value
                        // let BValues;
                        // if(this.detailDisplayInfo.length > 0) {
                        //     BValues = this.detailDisplayInfo.map(item => item.value);
                        // } else {
                        //     BValues = this.productLineDisplayInfo.map(item => item.value);
                        // }
                        // BValues = this.productLineDisplayInfo.map(item => item.value);
        
                        // 过滤出集合 B 中不在集合 A 中的值
                        // const unmatched = BValues.filter(value => !param.includes(value));
        
                        // 输出未匹配到的值
                        // console.log('wwwwwww强请' + unmatched);
            
                        // console.log('wwwwwww强请' + unmatched.length);
                        // for(let i = 0; i < unmatched.length; i++){
                        //     var item = {
                        //         //巡店员日报日语翻译  BY lizunxing 20231020
                        //         displayType: unmatched[i],
                        //         productLine: this.productLine,
                        //         productLineName: this.productLine,
                        //         productLookup: {
                        //             'lookup' : 'CustomLookupProvider.InternationalProductFilter',
                        //             'salesRegion' : 'Hisnese USA',
                        //             'Product_Line__c' : this.productLine
                        //         },
                        //         samplingInspection: true,
                        //         samplingInspectionPlanIn: [],
                        //         samplingInspectionPlanOut: [],
                        //         productLineItem: [],
                        //     };
                        //     // console.log('WWWWWITEM' + JSON.stringify(item));
                        //     newcheckResultsInfo.push(item);
                        // }
                        this.checkResultsInfo = newcheckResultsInfo;
                        console.log('删除后参数' + JSON.stringify(this.checkResultsInfo));
                        this.isShowSpinner = false;
                    } else {
                        this.isShowSpinner = false;
                        this.showError(data.message);
                    }
                    this.dispatchEvent(new CustomEvent('refreshdata'));
                }).catch(error => {
                    console.log('---------->error='+error);
                    this.catchError(JSON.stringify(error));
                    this.isShowSpinner = false;
                });
            }else {
                // todo 选cancel逻辑
                console.log('wwww---选cancel逻辑----' + index);
            }
        }

        async handleCreate() {
            // this.isShowSpinner = true;
            console.log('WWWWW需要知道WWWWW'  + this.recordItemId + ',' + this.productLine + ',' + this.storeId);
            getRewriteInitData({
                recordId: this.recordItemId,
                productLine: this.productLine,
                shopId: this.storeId
            }).then(data => {
                if (data.isSuccess) {
                    for (let key in data.data) {
                        this[key] = data.data[key];
                    }
                    console.log('WWW-editOne'+ this.status +':'+ this.isEditPage);
        
                    if (this.status == 'Submitted') {
                       this.isFieldReadOnly = true;
                       this.isTitleShowButton = true;
                       this.statusLabel = this.label.INSPECTION_REPORT_SUBMITED;
                       this.isEditPage = false;
                    } else {
                        this.isTitleShowButton = true;
                        this.isEditPage = true;
                        this.isFieldReadOnly = false;
                    }
        
                    // this.isEditPage = true;
                    // this.isFieldReadOnly = false;
                    // 数据格式化
                    this.checkResultsInfoDataFormat(data);
                    // 浮动效果
                    this.start();
                    // this.isShowSpinner = false;
                } else {
                    // this.isShowSpinner = false;
                    this.showError(data.message);
                }
        
            }).catch(error => {
                this.catchError(JSON.stringify(error));
                // this.isShowSpinner = false;
            });
        }
        checkResultsInfoDataFormat(data) {
            var currency;
            this.currencyCode = this.Iso;
            console.log('WWWCODE' + this.currencyCode);
            currency = this.currencySymbol;
            console.log('WWWW结果' + currency);
            this.currency = currency;
            console.log('WWW动态货币' + this.currency);
            console.log('getOfficeCheck' + JSON.stringify(this.getOfficeCheck));
            this.officeCheckItem = JSON.parse(JSON.stringify(this.getOfficeCheck));
            // var ss = JSON.parse(JSON.stringify(this.getOfficeCheck));
            // var firstObject = ss[0];
            // console.log('SS' + ss.length);
            // console.log('SS' + this.getOfficeCheck.length);
            // console.log('SS' + firstObject);
            var recordData = this.record;
            this.record = recordData;
            console.log('XXXXXXXXrecord' + JSON.stringify(this.record));
            const ids = JSON.stringify(this.pictureIds);
            this.pictureId = JSON.parse(ids);
            this.region = this.salesRegionArgument;
            // this.storeInfo[0] = this.storeInfos;
            
            var lookupProduct;
            lookupProduct = {
                productLookup: {
                    'lookup' : 'CustomLookupProvider.InternationalProductFilter',
                    'salesRegion' : this.region,
                    'Product_Line__c' : this.productLine
                },
            }
            
            this.productSearchInfo = lookupProduct;
            
            console.log('分界线');
            // this.isPOPShow = this.isPOP;
            // this.isSetUpShow = this.isSetUp;
            // this.isPriceShow = this.isPrice;
            // this.POPHelpTextShow = this.POPHelpText;
            // this.SetUpHelpTextShow = this.SetUpHelpText;
            // this.PriceHelpTextShow = this.PriceHelpText;
            // this.POPDescription = this.POPDesc;
            // this.SetUpDescription = this.SetUpDesc;
            // this.PriceDescription = this.PriceDesc;
            // this.productLineDisplayInfo = this.productLineDisplay;

            //开始解析文本
            if(this.officeCheckItem.length > 0 && this.officeCheckItem.length == 3) {
                this.isDisplayShow = true;
                this.POPDescription = this.officeCheckItem[0].Description__c;
                this.SetUpDescription = this.officeCheckItem[1].Description__c;
                this.DisPlayDescription = this.officeCheckItem[2].Description__c;
            } else if(this.officeCheckItem.length > 0 && this.officeCheckItem.length == 2) {
                this.POPDescription = this.officeCheckItem[0].Description__c;
                this.SetUpDescription = this.officeCheckItem[1].Description__c;
            }
            
            var checkResultsInfo = [];
            // console.log('分界线' + this.SetUpDescription + this.POPDescription + this.PriceDescription);
            console.log('WWWDETAIL' + this.isDetail);
            // console.log('WWWisDetailDisplay' + this.isDetailDisplay);
            
            // this.detailDisplayInfo = this.isDetailDisplay;
            
            
            //剥离display Type
            console.log('this.samplingInspections.length :: =>' + this.samplingInspections.length);
            
            if (this.samplingInspections.length>0) {
                // this.dispatchEvent(new CustomEvent('refreshdata'));
                // 循环所有sampling
                    for (let i = 0; i < this.samplingInspections.length; i++) {
                        var checkResultsInfoItem = this.samplingInspections[i];
                        //备份
                        
                        // var filteredList = checkResultsInfo.filter(obj => obj.displayType == this.productLineDisplayInfo[i].value);checkResultsInfoItem.Display_Type__c
                        var filteredList = checkResultsInfo.filter(obj => obj.productLine == checkResultsInfoItem.Product__r.Product_Line__c);
            
                        var item;
                        if (filteredList.length ==0) {
                            this.handleSetLinesOption(this.productLine);
                            item = {
                                productLine: this.productLine,
                                productLineName: this.LineLabel,
                                productLookup: {
                                    'lookup' : 'CustomLookupProvider.InternationalProductFilter',
                                    'salesRegion' : this.region,
                                    'Product_Line__c' : this.productLine
                                },
                                samplingInspection: true,
                                samplingInspectionPlanIn: [],
                                samplingInspectionPlanOut: [],
                                productLineItem: [],
                            };
                            // 判断产品线内容是否是出样外
                            if (checkResultsInfoItem.Unplanned_Sample__c == 'No') {
                                item.AllSamplePlanOut = false;
                            } else {
                                item.AllSamplePlanOut = true;
                            }
                            console.log('WWW执行到这里');
                            if (this.checkResults[checkResultsInfoItem.Product__r.Product_Line__c]!=undefined) {
                                var checkResultitem = this.checkResults[checkResultsInfoItem.Product__r.Product_Line__c];
                                Object.keys(checkResultitem).forEach(pjObj => {
                                    var project = checkResultitem[pjObj];
                                    var pj = {
                                        project: pjObj, 
                                        projectItems: project,
                                        projectItems_done: project.filter(pr => pr.Scores__c!= -1).length, 
                                        projectItems_total: project.length
                                    };
                                    item.productLineItem.push(pj);
                                });
                            }
                            checkResultsInfo.push(item);
                        // 存在该产品线
                        } else {
                            item = filteredList[0];
                        }
                               // 判断产品线内产品是否全是出样外
                            if (checkResultsInfoItem.Unplanned_Sample__c == 'No' && item.AllSamplePlanOut) {
                                item.AllSamplePlanOut = false;
                            }
            
            
                        // 计划内出样
                        if (checkResultsInfoItem.Unplanned_Sample__c == 'No') {
                            checkResultsInfoItem['index'] = item.samplingInspectionPlanIn.length+1;
                            if (checkResultsInfoItem.Placement_Status__c == '展出') {
                            checkResultsInfoItem['isChecked'] = true; 
                            checkResultsInfoItem['showDetail'] = true;
                            checkResultsInfoItem['isCheckedInfo'] = 'Yes';
                            } else if(checkResultsInfoItem.Placement_Status__c == '未展出'){
                            checkResultsInfoItem['isChecked'] = false; 
                            checkResultsInfoItem['showDetail'] = false;
                            checkResultsInfoItem['isCheckedInfo'] = 'No';
                            } else { 
                            checkResultsInfoItem['showDetail'] = false; 
                            checkResultsInfoItem['isCheckedInfo'] = '';
                            }
                            if (this.checkResultsIsRelatedToProduct && this.checkResultsIsRelatedToProduct.filter(obj => obj.Sampling_Inspection__c == checkResultsInfoItem.Id).length>0) {
                            var samplingInspections = this.checkResultsIsRelatedToProduct.filter(obj => obj.Sampling_Inspection__c == checkResultsInfoItem.Id);
                            checkResultsInfoItem['checkItems'] = [];
                            }
                            if(checkResultsInfoItem.Display_Status__c && checkResultsInfoItem.Display_Status__c == 'Yes'){
                                checkResultsInfoItem['SelectYes'] = true;
                            }else {
                                checkResultsInfoItem['SelectYes'] = false;
                            }
                            const isIdInArray = (this.pictureId).includes(checkResultsInfoItem.Id);
                            console.log('WWWID参数判断' + isIdInArray);
                            if(isIdInArray){
                                checkResultsInfoItem['Img_Status__c'] = true;
                            } else {
                                checkResultsInfoItem['Img_Status__c'] = false;
                            }
                            item.samplingInspectionPlanIn.push(checkResultsInfoItem);
                            }
                            // 计划外出样
                            if (checkResultsInfoItem.Unplanned_Sample__c == 'Yes') {
                            checkResultsInfoItem['index'] = item.samplingInspectionPlanOut.length+1;
                            if (checkResultsInfoItem.Placement_Status__c == '展出') {
                            checkResultsInfoItem['isChecked'] = true; 
                            checkResultsInfoItem['showDetail'] = true;
                            checkResultsInfoItem['isCheckedInfo'] = 'Yes';
                            } else if(checkResultsInfoItem.Placement_Status__c == '未展出'){
                            checkResultsInfoItem['isChecked'] = false; 
                            checkResultsInfoItem['showDetail'] = false;
                            checkResultsInfoItem['isCheckedInfo'] = 'No';
                            }else { 
                            checkResultsInfoItem['showDetail'] = false;
                            checkResultsInfoItem['isCheckedInfo'] = '';
                            }
                            if (this.checkResultsIsRelatedToProduct && this.checkResultsIsRelatedToProduct.filter(obj => obj.Sampling_Inspection__c == checkResultsInfoItem.Id).length>0) {
                            var samplingInspections = this.checkResultsIsRelatedToProduct.filter(obj => obj.Sampling_Inspection__c == checkResultsInfoItem.Id);
                            checkResultsInfoItem['checkItems'] = [];
                            }
                            // if(checkResultsInfoItem.Display_Status__c && checkResultsInfoItem.Display_Status__c == 'Yes'){
                            //     checkResultsInfoItem['SelectYes'] = true;
                            // }else {
                            //     checkResultsInfoItem['SelectYes'] = false;
                            // }
                            const isIdInArray = (this.pictureId).includes(checkResultsInfoItem.Id);
                            console.log('WWWID参数判断' + isIdInArray);
                            if(isIdInArray){
                                checkResultsInfoItem['Img_Status__c'] = true;
                            } else {
                                checkResultsInfoItem['Img_Status__c'] = false;
                            }
                            item.samplingInspectionPlanOut.push(checkResultsInfoItem);
                            }
                        
                    
                    // 判断是否存在计划外出样
                    if (item.samplingInspectionPlanOut.length>0) {
                    item.hasPlanOut = true;
                    } else {
                    item.hasPlanOut = false;
                    }
                    
                        // 排序
                        var productLineSort = [];
                        this.productLineValueSort.forEach(obj => {
                            productLineSort.push(obj.label);
                        });
                        checkResultsInfo.sort((a, b) => {
                            const indexA = productLineSort.indexOf(a.productLine);
                            const indexB = productLineSort.indexOf(b.productLine);
                            return indexA - indexB;
                        });
                    }       
            } 
            
            this.checkResultsInfo = checkResultsInfo;
           
        }

    @track currencyCode = 'USD'; // 可以从属性中动态设置
    @track currency;
    get currencySymbol() {
        const formatter = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: this.currencyCode
        });
        const parts = formatter.formatToParts(0);
        return parts.find(part => part.type === 'currency').value;
    }
    get lookupHidden() {
        console.log('MMM lookupHidden:' + this.status);
    if (this.status == 'Start' || this.status == 'Continue') {
        return false;
    } else {
        return true;
    }
    }
    start() {
        if (this.isMobile) {
            let _this = this;
            setTimeout(()=>{
                let h = _this.height = document.documentElement.clientHeight;
                setTimeout(()=>{
                    _this.height = h - document.documentElement.scrollHeight + document.documentElement.clientHeight;
                }, 10);
            }, 1000);
        }
    }
    // 浮动效果
height;
get style() {
return this.isMobile ? 'max-height: ' + this.height + 'px;' : '';
}
get topStyle() {
return this.isMobile === 'PHONE' ? 'max-height: ' + this.height + 'px;' : '';
}
get IssueStyle() {
return 'padding: 0; ' + this.topStyle;
}

upsertRecord(isSubmit) {
    // this.record.Total_Score__c = this.countScore.Total_Score__c;
    // this.record.Total_Score_Max__c = this.countScore.Total_Score_Max__c;
    // this.record.Average_Score_Count__c = this.countScore.Average_Score_Count__c;
    // this.record.Average_Score__c = this.countScore.Average_Score__c;
    // this.record.Average_Score_Max__c = this.countScore.Average_Score_Max__c;
    // this.isShowSpinner = true;
    console.log('参数' + JSON.stringify(this.checkResultsIsRelatedToProduct));
    var copyCheckResultsIsRelatedToProduct = JSON.parse(JSON.stringify(this.checkResultsIsRelatedToProduct));
    // copyCheckResultsIsRelatedToProduct.forEach(obj => {
    //     delete obj['index'];
    //     delete obj['isButtonOption'];
    //     delete obj['styles'];
    //     delete obj['fileRequireScores'];
    //     delete obj['fileMust'];
    //     delete obj['commentRequireScores'];
    //     delete obj['commentMust'];
    //     delete obj['isMust'];
    //     delete obj['isCheckbox'];
    //     delete obj['isChecked'];
    //     delete obj['unChecked'];
    //     delete obj['styleYes'];
    //     delete obj['styleNo'];
    // });
    
    // 出样状态切换 ------ Added By Sunny Start
    for(let index=0; index < copyCheckResultsIsRelatedToProduct.length; index++) {
        let obj = copyCheckResultsIsRelatedToProduct[index];
        if(typeof obj['ProductNotSampled'] != "undefined") { 
            if(obj.ProductNotSampled) {
                if(isSubmit) {
                    obj.Scores__c = -2;
                } else {
                    copyCheckResultsIsRelatedToProduct.splice(index, 1);
                    index -= 1;
                }
            }
            delete obj['ProductNotSampled']; 
        }
    }
    // 出样状态切换 ------ Added By Sunny End
    
    var copySamplingInspections = JSON.parse(JSON.stringify(this.samplingInspections));
    copySamplingInspections.forEach(obj => {
        delete obj['checkItems'];       
    });
    
    console.log('SAVE数据' + copySamplingInspections.length);
    console.log('SAVE数据' + copySamplingInspections);
    console.log('发起SAVE数据测试' + isSubmit);
    
    
    upsertRecord({
        recordJson: JSON.stringify(this.record),
        samplingInspectionJson: JSON.stringify(copySamplingInspections),
        isSubmit: isSubmit,
        attendancePhotoStreamJson: this.attendancePhotoStreamCheckOut,
        attendanceRemark: this.attendanceRemarkCheckOut
    }).then(data => {
        console.log('XXXXX' + data.isSuccess);
        if (data.isSuccess) {
            for (let key in data.data) {
                this[key] = data.data[key];
            }
            // if (isSubmit) {
            //     if (data.data.submitCheckError) {
            //         this.showError(data.data.submitCheckError);
            //         this.isShowSpinner = false;
            //         return;
            //     }
            //     //20241015数据暂时剥离 <> 还原
            //     // this.isFieldReadOnly = true;
            //     this.isTitleShowButton = false;
            //     // this.isEditPage = false;
            //     this.isEditPage = true;
            //     this.isFieldReadOnly = false;
            // } 
            // //20241015数据暂时剥离 <> 还原
            // else {
            //     // this.isEditPage = false;
            //     // this.isFieldReadOnly = true;
            //     this.isEditPage = true;
            //     this.isFieldReadOnly = false;
            // }
    
            // 数据格式化
            // this.dataFormat(data);
            // this.showSuccess('success');
            // this.isShowSpinner = false;
        } else {
            // this.isShowSpinner = false;
            this.showError(data.message);
        }
        // 刷新
        console.log('WWW刷新');
        this.dispatchEvent(new CustomEvent('refreshdata'));
    
        // 返回父级元素页面
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : false,
                    saveFlag : 'samplingInspection'
                }
            })
        );
    
    }).catch(error => {
        console.log('---------->error='+JSON.stringify(error));
        this.catchError(error);
        // this.isShowSpinner = false;
    });
    }

    samplingInspectionChange(event, fieldName, isCheckbox) {
        var resultindex = Number(event.target.dataset.resultindex);
        var index = Number(event.target.dataset.index);
        var type = event.target.dataset.type;
        var value;  
        if(fieldName == 'Price__c') {
            console.log('value'+ value + '判断' + value=== '' + value === 'undefined' + value === null);
            if(value === '' || value === 'undefined' || value === null){
                value = null;
            } else {
                value = event.target.value;
            }
        } else{ 
            if(isCheckbox){
                value = event.target.checked;
            }else{
                value = event.target.value;
            }
        }
        var siId;
        if (type == 'PlanIn') {
            this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index][fieldName] = value;
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
            console.log('打印planIN数据修改状态' + fieldName + ':' + value);
            
        } else {
            this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index][fieldName] = value;
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;
        }
        this.samplingInspections.forEach(obj => {if (obj.Id == siId) {obj[fieldName] = value;}});
    }

    siPriceChange(event) {
        var check = event.detail.value;
        this.samplingInspectionChange(event, 'Price__c', false);
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        ); 
    }
    siPOPChange(event) {
        // this.samplingInspectionChange(event, 'Is_POP__c', false);
        var resultindex = Number(event.target.dataset.resultindex);
        var index = Number(event.target.dataset.index);
        
        // var type = event.target.dataset.type;
        var check = event.detail.value;
        var type = event.target.dataset.t;
        console.log('WWWINDEX'+ index + ',' + resultindex + ',' + check + ',' + type) ;
        var siId;
        if (type == 'PlanIn') {
            console.log('PlanIn'+this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index]);
            this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Is_POP__c = check;
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
        } else {
            this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Is_POP__c = check;   
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;   
        }
        
        this.samplingInspections.forEach(obj => {
            if (obj.Id == siId) {
                obj.Is_POP__c = check;
            }
        });
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
        }
        siSetupStatusChange(event) {
            var resultindex = Number(event.target.dataset.resultindex);
            var index = Number(event.target.dataset.index);
            // var type = event.target.dataset.type;
            var check = event.detail.value;
            var type = event.target.dataset.t;
            console.log('WWWINDEX'+ index + ',' + resultindex + ',' + check + ',' + type) ;
            var siId;
            if (type == 'PlanIn') {
                console.log('PlanIn'+this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index]);
                this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Is_Set_up_Status__c = check;
                siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
            } else {
                this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Is_Set_up_Status__c = check;   
                siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;   
            }
            
            this.samplingInspections.forEach(obj => {
                if (obj.Id == siId) {
                    obj.Is_Set_up_Status__c = check;
                }
            });
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        hasEdit : true
                    }
                })
            ); 
        }
        siDisplayChange(event) {
            var resultindex = Number(event.target.dataset.resultindex);
            var index = Number(event.target.dataset.index);
            // var type = event.target.dataset.type;
            var check = event.detail.value;
            var type = event.target.dataset.t;
            console.log('WWWINDEX'+ index + ',' + resultindex + ',' + check + ',' + type) ;
            var siId;
            if (type == 'PlanIn') {
                console.log('PlanIn'+this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index]);
                this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Display_Status__c = check;
                siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
            } else {
                this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Display_Status__c = check;   
                siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;   
            }
            
            this.samplingInspections.forEach(obj => {
                if (obj.Id == siId) {
                    obj.Display_Status__c = check;
                }
            });
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        hasEdit : true
                    }
                })
            ); 
        }
        siCommentChange(event) {
            var resultindex = Number(event.target.dataset.resultindex);
            var index = Number(event.target.dataset.index);
            var type = event.target.dataset.type;
            var value = event.target.value;
            var siId;
            if (type == 'PlanIn') {
                this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].ReRe__c = value;
                siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
            } else {
                this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].ReRe__c = value;
                siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;
            }
            this.samplingInspections.forEach(obj => {
                if (obj.Id == siId) {
                    obj.ReRe__c = value;
                }
            });
            this.dispatchEvent(
              new CustomEvent("select", {
                detail: {
                  hasEdit: true,
                },
              })
            );
        }

        siHandleSelectFiles(event) {
            console.log('监听方法');
            var resultindex = Number(event.target.dataset.resultindex);
            var index = Number(event.target.dataset.index);
            var type = event.target.dataset.type;
            var siId;
            if (type == 'PlanIn') {
                siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
            } else {
                siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;   
            }
            
            this.samplingInspections.forEach(obj => {
                if (obj.Id == siId) {
                    obj.Img_Status__c = true;
                }
            });
            console.log('上传图片');
            this.dispatchEvent(new CustomEvent('refreshdata'));
        }

        handleDeletePicture(even){
            var Id = event.detail.sampleId;
            this.samplingInspections.forEach(obj => {
                if (obj.Id == Id) {
                    obj.Img_Status__c = false;
    
                }
            });
            console.log('samplingId' + Id);
            this.dispatchEvent(new CustomEvent('refreshdata'));
        }

        handleTicketSectionToggle(event) {
            let openSections = event.detail.openSections;
            var sections = [];
            if (openSections.length == 0) {
                sections = []; 
            } else if (openSections.length==1) {
                sections = [openSections[0]];
            } else {
                openSections.forEach(obj => {
                    if (obj!=this.activeTicketSections[0]) {
                        sections = [obj];
                    }
                });
            }
            this.activeTicketSections = sections;
        }

        // 初始化一个SamplingInspection
        handleCreateUniteSampling() {
            getUniteInitData({
                recordId: this.recordItemId,
                productLine: this.productLine,
                shopId: this.storeId
            }).then(data => {
                if (data.isSuccess) {
                    for (let key in data.data) {
                        this[key] = data.data[key];
                    }
                    if (this.status == 'Submitted') {
                        this.isFieldReadOnly = true;
                        this.isTitleShowButton = true;
                        this.statusLabel = this.label.INSPECTION_REPORT_SUBMITED;
                        this.isEditPage = false;
                     } else {
                         this.isTitleShowButton = true;
                         this.isEditPage = true;
                         this.isFieldReadOnly = false;
                     }
         
                     // this.isEditPage = true;
                     // this.isFieldReadOnly = false;
                     // 数据格式化
                     this.checkSamplingInspectionDataFormat(data);
                     // 浮动效果
                     this.start();
                     this.spinnerFlag = false;
                 } else {
                     this.spinnerFlag = false;
                     this.showError(data.message);
                 }
         
             }).catch(error => {
                 this.catchError(JSON.stringify(error));
             }); 
  
        }

        checkSamplingInspectionDataFormat(data) {
           
            const ids = JSON.stringify(this.pictureIds);
            this.pictureId = JSON.parse(ids);
            
            console.log('分界线 hahahaahha');

            var checkResultsInfo = [];
            console.log('分界线 hahahaahha length' + JSON.stringify(this.uniteInspections));

            if (this.uniteInspections.length>0) {
                // this.dispatchEvent(new CustomEvent('refreshdata'));
                // 循环所有sampling
                    for (let i = 0; i < this.uniteInspections.length; i++) {
                        var checkResultsInfoItem = this.uniteInspections[i];                    
                        const isIdInArray = (this.pictureId).includes(checkResultsInfoItem.Id);
                        console.log('WWWID参数判断' + isIdInArray);
                        if(isIdInArray){
                            checkResultsInfoItem['Img_Status__c'] = true;
                        } else {
                            checkResultsInfoItem['Img_Status__c'] = false;
                        }
                        checkResultsInfo.push(checkResultsInfoItem);
                    }
                            
                        

                    
                    //     // 排序
                    //     var productLineSort = [];
                    //     this.productLineValueSort.forEach(obj => {
                    //         productLineSort.push(obj.label);
                    //     });
                    //     checkResultsInfo.sort((a, b) => {
                    //         const indexA = productLineSort.indexOf(a.productLine);
                    //         const indexB = productLineSort.indexOf(b.productLine);
                    //         return indexA - indexB;
                    //     });
                this.checkUniteResultsInfoOne.push(checkResultsInfo[0]);
                this.checkUniteResultsInfoTwo.push(checkResultsInfo[1]);
                this.checkResultsInfo = checkResultsInfo;
                this.handleSetLinesTitleOption(this.productLine);
            }                   
            
            console.log('cececeece' + JSON.stringify(this.checkUniteResultsInfoOne));
        }

        siHandleUniteSelectFiles(event) {
            console.log('监听方法');
            var resultindex = Number(event.target.dataset.resultindex);
            var index = Number(event.target.dataset.index);
            var type = event.target.dataset.type;
            console.log('XXXUUU'+resultindex + index + type);
            var siId;
            if (type == 'PlanIn') {
                siId = this.checkUniteResultsInfoOne[resultindex].Id;
            } else {
                siId = this.checkUniteResultsInfoOne[resultindex].Id;   
            }
            
            this.checkUniteResultsInfoOne.forEach(obj => {
                if (obj.Id == siId) {
                    obj.Img_Status__c = true;
                }
            });
            console.log('上传图片');
            this.dispatchEvent(new CustomEvent('refreshdata'));
        }

        handleUniteDeletePicture(even){
            var Id = event.detail.sampleId;
            this.checkUniteResultsInfoOne.forEach(obj => {
                if (obj.Id == Id) {
                    obj.Img_Status__c = false;
    
                }
            });
            console.log('samplingId' + Id);
            this.dispatchEvent(new CustomEvent('refreshdata'));
        }

        siHandleUniteTwoSelectFiles(event) {
            console.log('监听方法');
            var resultindex = Number(event.target.dataset.resultindex);
            var index = Number(event.target.dataset.index);
            var type = event.target.dataset.type;
            console.log('XXXUUU'+resultindex + index + type);
            var siId;
            if (type == 'PlanIn') {
                siId = this.checkUniteResultsInfoTwo[resultindex].Id;
            } else {
                siId = this.checkUniteResultsInfoTwo[resultindex].Id;   
            }
            
            this.checkUniteResultsInfoTwo.forEach(obj => {
                if (obj.Id == siId) {
                    obj.Img_Status__c = true;
                }
            });
            console.log('上传图片');
            this.dispatchEvent(new CustomEvent('refreshdata'));
        }

        handleUniteTwoDeletePicture(even){
            var Id = event.detail.sampleId;
            this.checkUniteResultsInfoTwo.forEach(obj => {
                if (obj.Id == Id) {
                    obj.Img_Status__c = false;
    
                }
            });
            console.log('samplingId' + Id);
            this.dispatchEvent(new CustomEvent('refreshdata'));
        }
        handleSetLinesOption(data) {
            if(data == 'TV') {
                this.LineLabel = Inspection_TV;
            } else if(data == 'Laser TV') {
                this.LineLabel = Inspection_Laser_TV;
            }  else if(data == 'Cooking') {
                this.LineLabel = Inspection_Cooking;
            }  else if(data == 'WM') {
                this.LineLabel = Inspection_WM;
            }  else if(data == 'Refrigerator') {
                this.LineLabel = Inspection_Refrigerator;
            }  else if(data == 'Freezer') {
                this.LineLabel = Inspection_Freezer;
            }  else if(data == 'Sound Bar') {
                this.LineLabel = Inspection_Sound_Bar;
            }  else if(data == 'Dishwasher') {
                this.LineLabel = Inspection_Dishwasher;
            } else {
                this.LineLabel = data;
            }
            console.log('Label' + this.LineLabel);
    
        }

        handleSetLinesTitleOption(data) {
            if(data == 'Laser TV') {
                this.titleDescription = Inspection_LaserTV_Distant_view_Description;
            }  else if(data == 'Sound Bar') {
                this.titleDescription = Inspection_Sound_Bar_Distant_view_Description;
            }  else {
                this.titleDescription = Inspection_Unit_Distant_view_Description;
            }
            console.log('titleDescription' + this.titleDescription);
    
        }

        //新增一个用于给与页面Title 的多语言
    handleSwitchTitleLanguage(data) {
        console.log('参数' + data);
        if(data == 'Prototype') {
            this.inspectionTitlelabel = Inspection_Prototype;
        } else if(data == 'Material') {
            this.inspectionTitlelabel = Inspection_Material;
        } else if(data == 'PrototypeAndBooth') {
            this.inspectionTitlelabel = Inspection_Prototype_Booth;
        } else if(data == 'Booth') {
            this.inspectionTitlelabel = Inspection_Booth;
        } else if(data == 'Competing Goods') {
            this.inspectionTitlelabel = Inspection_Competing_Goods;
        } else {
            this.inspectionTitlelabel = data;
        }
        console.log('XXXinspectionTitlelabel' + this.inspectionTitlelabel);

    }

    handleSamplingSectionToggle(event) {
        let openSections = event.detail.openSections;
        console.log('AAAX' + JSON.stringify(openSections));
        var sections = [];
        console.log('AAA--' + openSections.length);
        if (openSections.length == 0) {
            sections = []; 
        } else if (openSections.length==1) {
            sections = [openSections[0]];
        } else {
            openSections.forEach(obj => {
                if (obj!=this.activeSamplingInspectionSections[0]) {
                    sections = [obj];
                }
            });
        }
        this.activeSamplingInspectionSections = sections;
    }
     // } else if(titlt == 'Training') {
        //     this.inspectionTitlelabel = Inspection_Training;
        // } else if(titlt == 'Sales') {
        //     this.inspectionTitlelabel = Inspection_Material;
        // } else if(titlt == 'Weekly Asks') {
        //     this.inspectionTitlelabel = Inspection_Material;
        // } else if(titlt == 'Brand Feedback') {
        //     this.inspectionTitlelabel = Inspection_Material;
        // } else if(titlt == 'Sample Condition') {
        //     this.inspectionTitlelabel = Inspection_Material;
        // } else if(titlt == 'Material Display') {
        //     this.inspectionTitlelabel = Inspection_Material;
        // } else if(titlt == 'Speak With the Store Leader') {
        //     this.inspectionTitlelabel = '';
        // } 

    handleSamplingComplianceSectionToggle(event) {
        let openSections = event.detail.openSections;
        console.log('AAAX' + JSON.stringify(openSections));
        var sections = [];
        console.log('AAA--' + openSections.length);
        if (openSections.length == 0) {
            sections = []; 
        } else if (openSections.length==1) {
            sections = [openSections[0]];
        } else {
            openSections.forEach(obj => {
                if (obj!=this.activeSamplingComplianceSections[0]) {
                    sections = [obj];
                }
            });
        }
        this.activeSamplingComplianceSections = sections;
    }

    handleViewPhotoClick(ele) {
        this.showPicture = true;
        this.shopPictureSrc = ele.target.dataset.show;
        this.shopPictureId = ele.target.dataset.id;
        this.filePreview(ele.target.dataset.id);
    }

    //产品线为Laser TV时触发获取图片
    getPictureList(){
        this.pictureList = [];
        getPictureList({
            //赋值假数据 根据国家/产品线 获取对应 展出样例图片
            recordId: this.produceLinePhotoId
            // recordId: 'a6YHz0000019QUuMAM',
        }).then(data => {
            if(data){
                // 处理数据
                data.forEach((d) => {
                    let picture = {};
                    picture['src'] = "/sfc/servlet.shepherd/version/renditionDownload?rendition=thumb240by180&versionId=" + d.Id + "&operationContext=CHATTER&contentId=" + d.ContentBodyId;
                    picture['show'] = "/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_" + d.FileType + "&versionId=" + d.Id + "&operationContext=CHATTER&contentId=" + d.ContentBodyId;
                    picture['id'] = d.ContentDocumentId;
                    this.pictureList.push(picture);
                });
            }
        }).catch(error => {
             
        });
    }

    // 关闭放大的图片
    handleClosePicture(event){
        this.showPicture = false;
        this.shopPictureSrc = '';
        this.shopPictureId = '';
    }
    // 点击放大图片里的详情页面
    handleViewPicture(event){
        // 新页面GenerateUrl
        this[NavigationMixin.GenerateUrl]({
          type: "standard__recordPage",
          attributes: {
            recordId: this.shopPictureId,
            actionName: "view",
          },
        }).then((url) => {
          window.open(url, "_blank");
        });
    }

    handleGetOfficePhoto() {
        
        getOfficePhoto({
            //赋值假数据 根据国家/产品线 获取对应 展出样例图片
            salesRegion: 'Hisense International',
            productLine: this.productLine
        }).then(data => {
            if(data){
                // 处理数据
                this.productLineDetail = data;
                console.log('详情描述' + JSON.stringify(this.productLineDetail));
                this.produceLinePhotoId= this.productLineDetail[0].Id;
                this.getPictureList();

            }
        }).catch(error => {
             
        });
    }


}