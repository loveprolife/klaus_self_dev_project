import { track, api, wire } from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import common3 from '@salesforce/resourceUrl/common3';
import Id from '@salesforce/user/Id';
import checkSI from '@salesforce/apex/Rest_ImageAI.checkSI';
import getPickList from '@salesforce/apex/NewSamplingAndTicketController.getPickList';
import LightningConfirm from 'lightning/confirm';
import getRewriteInitData from '@salesforce/apex/NewSamplingAndTicketController.getRewriteInitData';
import createRecord from '@salesforce/apex/NewSamplingAndTicketController.createSamplingInspectionRecord';
import refreshData from '@salesforce/apex/NewSamplingAndTicketController.refreshData';
import upsertRecord from '@salesforce/apex/NewSamplingAndTicketController.upsertRecord';
import addPlanOutProduct from '@salesforce/apex/NewSamplingAndTicketController.addPlanOutProduct';
import delProductLine from '@salesforce/apex/NewSamplingAndTicketController.delProductLine';
import judgeCountry from '@salesforce/apex/NewPromoterDailyReportActionController.judgeCountry';//Lay add 区分国家
import getShopInfo from '@salesforce/apex/NewSamplingAndTicketController.getShopInfo';
import checkListGetInitData from '@salesforce/apex/NewSamplingAndTicketController.checkListGetInitData';
import checkListSave from '@salesforce/apex/NewSamplingAndTicketController.checkListSave';
import saveAttachment from '@salesforce/apex/InspectorDailyReportController.saveAttachment';
import getExistingFilesList from '@salesforce/apex/NewSamplingAndTicketController.getExistingFilesList';
import samplingInspectionAdd from '@salesforce/apex/NewSamplingAndTicketController.samplingInspectionAdd';
import samplingInspectionDelete from '@salesforce/apex/NewSamplingAndTicketController.samplingInspectionDelete';
import deleteCheckResultForSamplingInspection from '@salesforce/apex/NewSamplingAndTicketProController.deleteCheckResultForSamplingInspection';// wfc
import INSPECTION_REPORT_TITLE from '@salesforce/label/c.INSPECTION_REPORT_TITLE';
import INSPECTION_REPORT_NEW from '@salesforce/label/c.INSPECTION_REPORT_NEW';
import INSPECTION_REPORT_SAVE from '@salesforce/label/c.INSPECTION_REPORT_SAVE';
import INSPECTION_REPORT_SUBMIT from '@salesforce/label/c.INSPECTION_REPORT_SUBMIT';
import INSPECTION_REPORT_BACK from '@salesforce/label/c.INSPECTION_REPORT_BACK';
import INSPECTION_REPORT_EDIT from '@salesforce/label/c.INSPECTION_REPORT_EDIT';
import INSPECTION_REPORT_ATTACHMENT from '@salesforce/label/c.INSPECTION_REPORT_ATTACHMENT';
import INSPECTION_REPORT_UNSCHEDULED from '@salesforce/label/c.INSPECTION_REPORT_UNSCHEDULED';
import INSPECTION_REPORT_GENERAL from '@salesforce/label/c.INSPECTION_REPORT_GENERAL';

import INSPECTION_REPORT_MSG_CANNOT_BLANK from '@salesforce/label/c.INSPECTION_REPORT_MSG_CANNOT_BLANK';
import INSPECTION_REPORT_MSG_UNPLANNED_STORE from '@salesforce/label/c.INSPECTION_REPORT_MSG_UNPLANNED_STORE';
import INSPECTION_REPORT_MSG_NO_PRODUCT_SELECTED from '@salesforce/label/c.INSPECTION_REPORT_MSG_NO_PRODUCT_SELECTED';
import INSPECTION_REPORT_MSG_PRODUCT_EXISTS from '@salesforce/label/c.INSPECTION_REPORT_MSG_PRODUCT_EXISTS';
import INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE from '@salesforce/label/c.INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE';
import INSPECTION_REPORT_MSG_CHECKITEM_LOST from '@salesforce/label/c.INSPECTION_REPORT_MSG_CHECKITEM_LOST';
import CheckInCheckOut_PHOTO from '@salesforce/label/c.CheckInCheckOut_PHOTO';
import CheckInCheckOut_REMARK from '@salesforce/label/c.CheckInCheckOut_REMARK';
import CheckInCheckOut_REMARK_INFO from '@salesforce/label/c.CheckInCheckOut_REMARK_INFO';
import CheckInCheckOut_LOCATION from '@salesforce/label/c.CheckInCheckOut_LOCATION';
import CheckInCheckOut_STORE from '@salesforce/label/c.CheckInCheckOut_STORE';
import CheckInCheckOut_RECORDED from '@salesforce/label/c.CheckInCheckOut_RECORDED';
import CheckInCheckOut_OUT_OF_CHECK_IN_RANGE from '@salesforce/label/c.CheckInCheckOut_OUT_OF_CHECK_IN_RANGE';
import PromoterDailyReport_TICKET from '@salesforce/label/c.PromoterDailyReport_TICKET';
import PromoterDailyReport_NOT_HAVE_REPORT from '@salesforce/label/c.PromoterDailyReport_NOT_HAVE_REPORT';
import INSPECTION_TYPE_IS_REQUIRED from '@salesforce/label/c.Inspect_Type_Is_Required';
import PromoterDailyReport_AddNewItemSuccess from '@salesforce/label/c.PromoterDailyReport_AddNewItemSuccess';
import Ticket_Fields_Check from '@salesforce/label/c.Ticket_Fields_Check';
import INSPECTION_REPORT_MSG_DEPARTMENT_USER from '@salesforce/label/c.INSPECTION_REPORT_MSG_DEPARTMENT_USER';
import Store_Pic_Title from '@salesforce/label/c.Store_Pic_Title';
import INSPECTION_REPORT_MSG_Please_Save_First from '@salesforce/label/c.INSPECTION_REPORT_MSG_Please_Save_First';
import INSPECTION_REPORT_From_Photo from '@salesforce/label/c.INSPECTION_REPORT_From_Photo';
import INSPECTION_REPORT_From_Fold from '@salesforce/label/c.INSPECTION_REPORT_From_Fold';
import add_Inspection_product from '@salesforce/label/c.add_Inspection_product';
import Ticket_Select_Progress from '@salesforce/label/c.Ticket_Select_Progress';
import INSPECTION_REPORT_SUBMITED from '@salesforce/label/c.INSPECTION_REPORT_SUBMITED';
import Sample_picture from '@salesforce/label/c.Sample_picture';
import INSPECTION_REPORT_Display_Status from '@salesforce/label/c.INSPECTION_REPORT_Display_Status';
import INSPECTION_REPORT_PRODUCT_PRICE from '@salesforce/label/c.INSPECTION_REPORT_PRODUCT_PRICE';
import INSPECTION_REPORT_PRODUCT_PRICE_HELPTEXT from '@salesforce/label/c.INSPECTION_REPORT_PRODUCT_PRICE_HELPTEXT';
import Inspection_Delete_Picture from '@salesforce/label/c.Inspection_Delete_Picture';

import saveObject from '@salesforce/apex/uploadStorePicturesController.saveObject';
import delObject from '@salesforce/apex/uploadStorePicturesController.delObject';
import getPicMsg from '@salesforce/apex/uploadStorePicturesController.getPicMsg';
import Store_Pic_Tip from '@salesforce/label/c.Store_Pic_Tip';
import Store_Pic_Head from '@salesforce/label/c.Store_Pic_Head';
import Before_Cleaning from '@salesforce/label/c.Before_Cleaning';
import After_Cleaning from '@salesforce/label/c.After_Cleaning';
import Image_Is_Tv from '@salesforce/label/c.Image_Is_Tv';
import { NavigationMixin } from 'lightning/navigation';

// import saveTrainingPicture from '@salesforce/apex/TrainingController.saveTrainingPicture';
import getPictureList from '@salesforce/apex/NewSamplingAndTicketController.getPictureList';
import deletePicture from '@salesforce/apex/NewSamplingAndTicketController.deletePicture';
import upsertProductLineStatus from '@salesforce/apex/NewInspectionDailyReportPageController.upsertProductLineStatus';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import uploadFiles from '@salesforce/resourceUrl/uploadFiles';
import { refreshApex } from '@salesforce/apex';

export default class NewSamplingInspectionLwc2 extends LightningNavigationElement {
    lwcName = 'NewSamplingInspectionLwc2';
    label = {
        INSPECTION_REPORT_SAVE,             // 保存
        INSPECTION_REPORT_EDIT,             // 修改

        INSPECTION_REPORT_ATTACHMENT,       // 附件
        INSPECTION_REPORT_UNSCHEDULED,      // 计划外
        INSPECTION_REPORT_GENERAL,          // 通用清单

        INSPECTION_REPORT_MSG_NO_PRODUCT_SELECTED,      // 没有选择产品
        INSPECTION_REPORT_MSG_PRODUCT_EXISTS,           // 产品已存在
        INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE,     // {0}将被删除
        INSPECTION_REPORT_MSG_CHECKITEM_LOST,           // checkItem未匹配
        CheckInCheckOut_PHOTO,          // 拍照
        CheckInCheckOut_REMARK,         // 备注
        CheckInCheckOut_REMARK_INFO,    // 备注信息
        CheckInCheckOut_STORE,          // 门店
        CheckInCheckOut_RECORDED,       // 记录
        CheckInCheckOut_LOCATION,               // 重新/校准定位
        CheckInCheckOut_OUT_OF_CHECK_IN_RANGE,  // 超出打卡范围
        PromoterDailyReport_TICKET,             // TICKET
        PromoterDailyReport_NOT_HAVE_REPORT,    // 当前日期门店没有日报
        PromoterDailyReport_AddNewItemSuccess,
        INSPECTION_REPORT_MSG_DEPARTMENT_USER,    // added by Sunny about chile department start-[20231026]
        INSPECTION_TYPE_IS_REQUIRED,//巡店类型必填 20231101
        INSPECTION_REPORT_From_Photo,
        INSPECTION_REPORT_From_Fold,
        Store_Pic_Title,
        add_Inspection_product,
        Ticket_Select_Progress,
        INSPECTION_REPORT_SUBMITED,
        Sample_picture,
        INSPECTION_REPORT_Display_Status,
        INSPECTION_REPORT_BACK,
        INSPECTION_REPORT_PRODUCT_PRICE,
        INSPECTION_REPORT_PRODUCT_PRICE_HELPTEXT,
        Before_Cleaning,
        After_Cleaning,
        Inspection_Delete_Picture,
        INSPECTION_REPORT_TITLE,
        Image_Is_Tv
    };
lwcName = this.label.INSPECTION_REPORT_TITLE;

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
    Placement_Status__c:'',
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
        Placement_Status__c: data.fields.Placement_Status__c.label,
        Img_Status__c: data.fields.Img_Status__c.label
    }
} else if (error) {
    console.log(error);
    this.showError('Sampling_Inspection__c getInformation error');
}
}
/**初始化 Product__c 标签*/
@track productInfo = {
    Product_Line__c: '',
    Series__c: '',
    Category__c: '',
};
@wire(getObjectInfo, { objectApiName: 'Product__c' })
wiredProductInfo({ error, data }) {
if (data) {
    this.productInfo = {Product_Line__c: data.fields.Product_Line__c.label,Series__c: data.fields.Series__c.label,Category__c: data.fields.Category__c.label,
    }
} else if (error) {
    console.log(error);this.showError('Product__c getInformation error');
}
}
/**初始化 CheckResult__c 标签*/
@track checkResultInfo = {
    Comments__c: '',
};
@wire(getObjectInfo, { objectApiName: 'CheckResult__c' })
wiredCheckResultInfo({ error, data }) {
if (data) {
    this.checkResultInfo = {
        Comments__c: data.fields.Comments__c.label,
    }
} else if (error) {
    console.log(error);
    this.showError('CheckResult__c getInformation error');
}
}

/**初始化 Product Product line Value List*/
@wire(getPickList, {objectName : 'Product__c', fieldName : 'Product_Line__c'})
productLineOptions;
@wire(getPickList, {objectName : 'Sampling_Detail__c', fieldName : 'Display_Type__c'})
displayTypeOptions;
@track showAllPage = true;

// 打卡地图相关
@track mapMarkers = [];
@track showMapMarkers = [];
// Data相关
@api recordId; //子类id
@api inspectionId; //父类id
@api productLine;
@api storeId;
@api shopId;
@api reportDate;
@api recordItemId;
@api status;
@api submit;
@api produceLinePhotoId;
@track isSelectedYes = false;
@track isSelectedNo = false;

@track DisplayHelpTextShow;
@track POPHelpTextShow;

@track CheckPriceHelpTextShow;
@track priceMexicoHelpTextShow;
@track OptimalHelpTextShow;

@track SetUpHelpTextShow;
@track PriceHelpTextShow;

@track DisplayDescription;
@track DisplayMultipleChoice;
@track POPDescription;

@track CheckPriceDescription;
@track priceMexicoDescription;
@track OptimalDescription;

@track SetUpDescription;
@track PriceDescription;
@track showCheckItemIssues = false; // Added By Sunny 
get isShowItemIssues() {
    return this.isIndonesia || this.isSouthAfrica || this.isChile;
}  
@track ownerName;                           // 所有人名
@track userId = Id;

@track record = {};                         // 日报主数据信息
@track storeDistanceList = [];              // 门店信息
@track attendanceInformation;               // 签到信息
@track attendanceInformationCheckOut = {};       // 签退信息
@track attendanceInformationCheckOutHandHelper = {};
@track checkResults = {}; 
@track displayTypesInfo = [];                 // 试卷信息
@track checkResultsInfo = [];               // 试卷信息（整理后）
@track productLineDisplayInfo = []; 
@track checkResultsIsRelatedToProduct = [];                   // 试卷信息-出样
@track samplingInspections = [];            // 出样检查
@track mileageRecord = {};                  // 巡店里程
@track inspectTypeOptions = {};
@track inspectStatusOptions = {};
@track selectedProductValue;                // 搜索产品Id 
@track selectedProductInfo = {};            // 产品详细信息 
@track selectedProductInfoIsShow = false;   // 显示产品详细信息 
@track storeInfo = [];
@track productLineDetail = [];
@track checkItemList = []; // wfc
// Page相关
@track isShowSpinner = false;               // 加载中
@track oldReportDate;                       // 旧日期
@track oldReportDateShow = true;            // 切换日期显示
@track isFieldReadOnly = true;              // 字段只读
@track isTitleShowButton = false;           // 显示title按钮
@track isEditPage = false;                  // 显示编辑页面
@track language;                            // 语言
@track hasImage = false;
@track uploadedImage = {};                        
get isViewPage() {
    if (this.isEditPage) {
        return false;
    } else {
        return true;
    }
};
//按钮相关
@track buttons = [];
// Tab相关
@track activeSections = [];
@track activeTicketSections = [];
@track activeSamplingInspectionSections = ['open'];
@track activeSampleUpSections = ['closed'];
// 打卡部分
@track todayDate;
@track nowTime;
@track storeName;
@track storeDistance;
@track attendanceShowPhoto = false;
@track attendancePhotoStream;
@track attendanceRemark;
@track attendanceFromType = 'From Photo';
@track isFromPhoto = true;
@track shopInfo;
@track recordedInfo;
@track distanceInfo;
@track noteInfo;
@track phoneInfo;
@track noteInfoCheckOut;
@track phoneInfoCheckOut;
@track isShowDepartment = false;// 智利
// added by Sunny about chile department end-[20231026]
@track saRequired = false;//南非里程必填,印尼选填
@track isIndonesia = false;
@track isSouthAfrica = false;
@track isChile = false;
@track isStorePicTitle = false;
@track isJapan;        
@track isMalaysia = false;  
@track isThailand = false; 
@track isVietnam = false; 
@track isPhilippines = false;                 
@api contentVersionId;
@api SrcO;
@track tranSRC;
// @track uniqueId = new Date().getTime(); // 用当前时间戳作为唯一标识
@track statusLabel = this.label.INSPECTION_REPORT_NEW;
@track noDisplayType = false;
@track isPOPShow = false;
@track isDisplayShow = false;

@track IsCheckPriceShow = false;
@track IsOptimalShow = false;
@track IsPriceMexicoShow = false;

@track isSetUpShow = false;
@track isPriceShow = false;
@track strorePicture = false;
@track detailDisplayInfo = [];
@track pictureId;
@track delDiv = false;

alertTitle;
alertMessage;
iconType;
showAlert = false;

get iOSModel() {
var userAgent = navigator.userAgent;
if (/iphone|iPhone|ipad|iPad|ipod|iPod|iOS|ios/.test(userAgent)) {  return true;
} else { return false; }
}
get AndroidModel() {
var userAgent = navigator.userAgent;
if (/android|Android/.test(userAgent)) {  return true;
} else { return false; }
}

get computedSrcO() {
    return `${this.SrcO}?v=${this.uniqueId}`;
}
get uploadDivStyle() {
if (this.isEditPage) { return '' } 
else { return 'pointer-events: none;'; }
}
// 门店选项
get shopOptions() {
var optins = [];
for (let i = 0; i < this.storeDistanceList.length; i++) {
    var person = this.storeDistanceList[i];
    optins.push({label: person.storeName, value: person.storeId});
}
if (this.attendanceInformation!=null && this.storeId == null && (
    optins.length==0 || 
    this.isReportUser==false || 
    (this.record.Store__c && this.storeDistanceList.filter(obj => obj.storeId == this.record.Store__c).length == 0))) {
    optins = [{label: this.attendanceInformation.Shop__r.Name, value: this.attendanceInformation.Shop__c}];
}
return optins;
}
// 门店只读
get isTitleReadOnly() {
return false;
}
// 日报日期对比当前日期
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
// 添加产品（自定义lookupFilter）
lookupFilter = {
'lookup' : 'CustomLookupProvider.ProductAllFilter'
}

// 添加用户（自定义lookupFilter）
lookupUserFilter = {
'lookup' : 'CustomLookupProvider.UserFilter'
}
get lookupHidden() {
    console.log('MMM lookupHidden:' + this.status);

// if (this.record.Status__c == 'Submitted') {
//     return true;
// } else {
//     return false;
// }
    if (this.status == 'Start' || this.status == 'Continue') {
        return false;
    } else {
        return true;
    }
}
// 计算分数
get countScore() {
var countScore = {
    Total_Score__c: 0,
    Total_Score_Max__c: 0,
    Average_Score_Count__c: 0,
    Average_Score__c: 0,
    Average_Score_Max__c: 0,
};
for (let i = 0; i < Object.keys(this.checkResults).length; i++) {
    var productLine = this.checkResults[Object.keys(this.checkResults)[i]];
    for (let j = 0; j < Object.keys(productLine).length; j++) {
        var results = productLine[Object.keys(productLine)[j]];
        for (let k = 0; k < results.length; k++) {
            var result = results[k];
            if (result.CheckItem__r.IsYesOrNo__c == false && result.CheckItem__r.IsCountInScore__c == true) {
                countScore.Total_Score__c += (Number(result.Scores__c)<0 ? 0 : Number(result.Scores__c));
                countScore.Total_Score_Max__c += Number(result.CheckItem__r.MaximumScore__c);
                countScore.Average_Score_Count__c += 1;
            }
        }
    }
}
for (let i = 0; i < this.checkResultsIsRelatedToProduct.length; i++) {
    var crItem = this.checkResultsIsRelatedToProduct[i];

    // 出样状态切换 ------ Added By Sunny Start 
    if(typeof crItem.ProductNotSampled != "undefined" && crItem.ProductNotSampled) {
        continue;
    }
    // 出样状态切换 ------ Added By Sunny End

    if (crItem.CheckItem__r.IsCountInScore__c == true) {
        countScore.Total_Score__c += (Number(crItem.Scores__c)<0 ? 0 : Number(crItem.Scores__c));
        countScore.Total_Score_Max__c += Number(crItem.CheckItem__r.MaximumScore__c);
        countScore.Average_Score_Count__c += 1;
    }
}
if (countScore.Average_Score_Count__c!=0) {
    countScore.Average_Score__c = Number(countScore.Total_Score__c/countScore.Average_Score_Count__c).toFixed(2);
    countScore.Average_Score_Max__c = Number(countScore.Total_Score_Max__c/countScore.Average_Score_Count__c).toFixed(2);
}
return countScore;
}
// 自定义弹框
@track modalMsg;
@track modalType;
@track modalHelper;
handleShow(msg, type, hepler) {
let ele = this.template.querySelector('c-modal-lwc');
if (ele!=null) {
    this.modalMsg = msg;
    this.modalType = type
    this.modalHelper = hepler
    ele.showModal(this.template);
} else {
    console.log('c-modal-lwc is null');
}
}
handleOk() {
this.template.querySelector('c-modal-lwc').closeModal();
if (this.modalType == 'deleteImg') {
    if (this.deleteChildComponent) {
        this.deleteChildComponent.performAction();
    }
}
}

// 取消下拉刷新
disablePullToRefresh() {
const disable_ptr_event = new CustomEvent("updateScrollSettings", {
    detail: {
    isPullToRefreshEnabled: false,
    },
    bubbles: true,
    composed: true,
});
this.dispatchEvent(disable_ptr_event);
}
get recordDatereadonly() {
if (this.isTitleReadOnly || this.isReportUser == false) {
    return true;
} else if (this.isEditPage) {
    return true;
} else {
    return false;
}
}
get recordDateClass() {
if (this.recordDatereadonly) {
    return 'disabled-input';
} else {
    return '';
}
}

    @api
    handleSave() {

        this.samplingInspections.forEach(obj => {
            // if (obj.Display_Status__c == 'No') {
            //     obj.Is_POP__c = '';
            //     obj.Is_Set_up_Status__c = '';
            //     obj.Price__c = null;
            // }
            if (obj.Placement_Status__c == '未展出') {
                obj.Is_POP__c = '';
                obj.Is_Set_up_Status__c = '';
                obj.Price__c = null;
            }
        });

        // 检查必填信息
        var checkResp = {alltrue: true, msg: ''};
        console.log('wwwwwwffffff-- 打印一下包含的参数--c/createFileItemLwc' + JSON.stringify(this.samplingInspections));

        // 保存 check result
        let eles = this.template.querySelectorAll('c-new-sampling-inspection-lwc4');
        if(eles){
            for (let index = 0; eles && index < eles.length; index++) {
                let ele = eles[index];
                ele.handleSave();
            }   
        }

        // 保存更新
        this.upsertRecord(false);

        // 更新产品线状态为continue
        upsertProductLineStatus({
            recordId:this.recordId,
            status:'Continue',
            productLineChecked:''
        }).catch(error => {
            this.catchError(JSON.stringify(error));
        });
    }

    async handleCreate() {
        this.isShowSpinner = true;
        console.log('SUBMIT' + this.status);
            
        // addData();
        getRewriteInitData({
            recordId: this.recordId,
            productLine: this.productLine,
            shopId: this.storeId
        }).then(data => {
            if (data.isSuccess) {
                console.log('wwwwgetRewriteInitData' + JSON.stringify(data));
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

                // 数据格式化
                this.dataFormat(data);
                this.oldReportDate = data.data.record.Report_Date__c;
                // 浮动效果
                this.start();
                this.isShowSpinner = false;
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }

        })
        // .catch(error => {
        //     this.catchError(JSON.stringify(error));
        //     this.isShowSpinner = false;
        // });
    }
// Android Photo Click
handleAndroidPhotoClick() {
this.hideAllFun();
}
// iOS Photo Click
async handlephotoClick(event) {
var type = event.target.dataset.id;
var file = event.target.files[0];
// 获取上传图片的base64
var uploadBase64 = await readFile(file);
// 转换后图片base64
var convertBase64 = await new Promise(resolve => {
    // 使用base64方式创建一个Image对象
    var img = new Image();
    img.src = uploadBase64;
    // 当图片加载成功后执行
    img.onload = () => {
        // 创建canvas元素
        var canvas = document.createElement('canvas');
        // 设置canvas的宽高为图片的宽高
        canvas.width = img.width;
        canvas.height = img.height;
        // 在canvas上绘制图片
        var ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0);
        // 将canvas转换为目标大小的base64编码
        var quality = 0.7; // 图片压缩质量
        var maxFileSize = 2097152; // 文件大小限制为2MB
        let compressedDataUrl = canvas.toDataURL('image/jpeg', quality);
        while (compressedDataUrl.length > maxFileSize) {
            // 文件超过限制，压缩质量
            quality -= 0.1; // 每次降低压缩质量 0.1
            compressedDataUrl = canvas.toDataURL('image/jpeg', quality);
        }
        // 压缩后的base64
        var convertBase64 = compressedDataUrl;
        resolve(convertBase64);
    };
});
if (type == 'photo') {
    this.attendancePhotoStream = convertBase64;
    this.attendanceShowPhoto = true;
    this.attendanceFromType = 'From Photo';
    this.isFromPhoto = true;
} else if (type == 'folder') {
    this.attendancePhotoStream = convertBase64;
    this.attendanceShowPhoto = true;
    this.attendanceFromType = 'From Folder';
    this.isFromPhoto = false;
} else if (type == 'checkout') {
    this.attendancePhotoStreamCheckOut = convertBase64;
    this.attendanceShowPhotoCheckOut = true;

    this.phoneInfoCheckOut = convertBase64;
}
}
// del Photo Click
handleDelPhotoClick() {
this.attendancePhotoStream = null;
this.attendanceShowPhoto = false;
this.attendanceFromType = 'From Photo';
this.isFromPhoto = true;
}
// del Photo Click
handleDelPhotoCheckOutClick() {
this.attendancePhotoStreamCheckOut = null;
this.attendanceShowPhotoCheckOut = false;
this.phoneInfoCheckOut = null;
}
// checkout图片部分
@track attendanceShowPhotoCheckOut = false;
@track attendancePhotoStreamCheckOut;
@track attendanceRemarkCheckOut;
// view Photo Click
handleViewPhotoClick(ele) {
if (ele.target.style.width == '10%') {
    ele.target.style.width = '100%';
} else {
    ele.target.style.width = '10%';
}
}
// add Product Click
handleAddProductClick() {
// 判断Product是否为空
if (this.selectedProductValue==null || this.selectedProductInfo.Product_Line__c==undefined || this.selectedProductInfo.Product_Line__c==null) {
    // this.showError('No product selected');
    this.showError(this.label.INSPECTION_REPORT_MSG_NO_PRODUCT_SELECTED);return;
}
// 判断是否已存在产品
for (let i = 0; i < this.samplingInspections.length; i++) {
    //备用
    var item = this.samplingInspections[i];
    if (item.Product__c==this.selectedProductValue) {// this.showError('Product already exists');
        this.showError(this.label.INSPECTION_REPORT_MSG_PRODUCT_EXISTS);return;
    }
}
this.isShowSpinner = true;
console.log('WWWTYU22222-'+ JSON.stringify(this.record));
addPlanOutProduct({recordJson: JSON.stringify(this.record),productJson: JSON.stringify(this.selectedProductInfo)
}).then(data => {
    if (data.isSuccess) {
        console.log('WWW新增反馈' + JSON.stringify(data.data));
        if (data.data.record) {this.record = data.data.record;}
        // Deloitte Yin Mingjie 20231114 start
        if (data.data.checkResults) {this.checkResults = this.checkCheckResults(data.data.checkResults);}
        // Deloitte Yin Mingjie 20231114 end
        // 只需要整理刷新check list 信息
        this.addCheckResultsInfoDataFormat(data, this.selectedProductValue);
        // 清空product搜索
        this.selectedProductValue = null;
        this.selectedProductInfo = {};
        this.selectedProductInfoIsShow = false;
        this.isShowSpinner = false;
    } else {
        this.isShowSpinner = false;
        this.showError(data.message);
    }
}).catch(error => {
    console.log('---------->error='+error);
    this.catchError(JSON.stringify(error));
    this.isShowSpinner = false;
});

}

// Sampling Inspection Click
handleSamplingInspectionClick(event) {
var productline = event.target.getAttribute('data-productline');

this.samplingInspectionGetInitData(productline);
}
// Check List Click
handleChecklistClick(event) {
if (this.ticketNeedSave) {
    this.showWarning(INSPECTION_REPORT_MSG_Please_Save_First);
    return;
}
var productline = event.target.getAttribute('data-productline');
var project = event.target.getAttribute('data-project');
this.checkListGetInitData(productline, project);
}
// Section Toggle click
handleSectionToggle(event) {
let openSections = event.detail.openSections;
var sections = [];
if (openSections.length == 0) {
    sections = []; 
} else if (openSections.length==1) {
    sections = [openSections[0]];

} else {
    openSections.forEach(obj => {
        if (obj!=this.activeSections[0]) {
            sections = [obj];
        }
    });
}
this.activeSections = sections;
}

// Ticket Section Toggle click
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
get ticketNeedSave() {
let needSave = false;
for (let i = 0; i < this.ticketOpenInfo.length; i++) {
    if (this.ticketOpenInfo[i].needSave) {
        needSave = needSave || true;
    } else {
        needSave = needSave || false;
    }
    
}

return needSave;
}
// Check Sampling Inspection
checkSamplingInspection(){
    var resp = {alltrue: true, msg: ''};
    let msgerror = '';
    for(let index=0; index < this.samplingInspections.length; index++) {
        let obj = this.samplingInspections[index];
        if(obj.isCheckedInfo == '' || obj.isCheckedInfo == null || obj.isCheckedInfo == undefined){
            msgerror += obj.Product__r.Name + ','
            resp.alltrue = false;
        }
    }
    resp.msg = msgerror;
    return resp;
}
// Check Ticket
checkTicket() {
var resp = {alltrue: true, msg: ''};
// added by Sunny 检查结果为满分或-2（不出样） start -[20240507]
let d = new Date();
let systemGenerationDate = d.getFullYear() + '-' + (d.getMonth() + 1) + '-' + (d.getDate() + 7);
let noTicketCheckResultIdList = [];
let notSampledCheckResultIdList = [];
for(let index=0; index < this.checkResultsIsRelatedToProduct.length; index++) {
    let obj = this.checkResultsIsRelatedToProduct[index];
    console.log('sunny add -> check result: ' + JSON.stringify(obj));
    // 不出样
    if(typeof obj['ProductNotSampled'] != "undefined") { 
        if(obj.ProductNotSampled) {
            noTicketCheckResultIdList.push(obj.Id);
            notSampledCheckResultIdList.push(obj.Id);
        }
    }
    // 满分
    if (obj.Scores__c == obj.CheckItem__r.MaximumScore__c) {
        noTicketCheckResultIdList.push(obj.Id);
    }
}
console.log('sunny add -> noTicketCheckResultIdList: ' + JSON.stringify(noTicketCheckResultIdList));
// added by Sunny 检查结果为满分或-2（不出样） end -[20240507]
for (let i = 0; i < this.ticketOpenInfo.length; i++) {
    var obj = this.ticketOpenInfo[i];
    // added by Sunny 自动生成的ticket，结果改为满分或-2（不出样）跳过，无需校验 start -[20240507]
    if (obj.SystemGeneration__c && noTicketCheckResultIdList.includes(obj.CheckResult__c)) {
        obj.DueDate__c = systemGenerationDate;
        obj.AssignedTo__c = this.userId;
        if (notSampledCheckResultIdList.includes(obj.CheckResult__c)) {
            this.ticketOpenInfo.splice(i, 1);
            i -= 1;
            continue;
        }
    }
    // added by Sunny 自动生成的ticket，结果改为满分或-2（不出样）跳过，无需校验 end -[20240507]
    if (obj.Subject__c=='' || obj.Subject__c==null) {
        resp.alltrue = false;
        resp.msg = this.TicketInfo.Subject__c;
        return resp;
    }
    if(this.isFilledOut(obj.Category__c) && obj.Category__c != 'Service'){
        if (!this.isFilledOut(obj.Product__c)) {
            resp.alltrue = false;
            resp.msg = this.TicketInfo.Product__c;
            return resp;
        }
    }
    // added by Sunny about chile department start-[20231026]
    if(this.isShowDepartment && (obj.Department__c == '' || obj.Department__c == null) && (obj.AssignedTo__c == '' || obj.AssignedTo__c == null)) {
        resp.alltrue = false;
        resp.msg = Ticket_Fields_Check.format(this.TicketInfo.AssignedTo__c, this.TicketInfo.Department__c);
        return resp;
    }
    // added by Sunny about chile department end-[20231026]
    if (!this.isShowDepartment && (obj.AssignedTo__c=='' || obj.AssignedTo__c==null)) {
        resp.alltrue = false;
        resp.msg = this.TicketInfo.AssignedTo__c;
        return resp;
    } 
    if (obj.DueDate__c=='' || obj.DueDate__c==null) {
        resp.alltrue = false;
        resp.msg = this.TicketInfo.DueDate__c;
        return resp;
    }
}
return resp;
}
// ---------------> ↑ Button click ↑ <---------------
// ---------------> ↓ onchange ↓ <---------------
// 日期变更
storeLabel;


    // lookup remove
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

// 选择产品变更
handleChangeProductOption(resp) {
var selectProductId;
if (resp.detail.selectedRecord==undefined) {
    return;
} else {
    selectProductId = resp.detail.selectedRecord.Id;
}
console.log('WWW判断是否已存在产品')
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
console.log('WWWTYU-'+ JSON.stringify(this.record));
addPlanOutProduct({
    recordJson: JSON.stringify(this.record),
    productId: selectProductId,
    displayType: this.record.displayType
}).then(data => {
    if (data.isSuccess) {
        if (data.data.record) {
            this.record = data.data.record;
        }
        // 只需要整理刷新check list 信息
        this.addCheckResultsInfoDataFormat(data, selectProductId);
        // 跳转Sampling Inspection页面
        this.samplingInspectionGetInitData(this.selectedProductInfo.Product_Line__c);
        // 清空product搜索
        this.selectedProductValue = null;
        this.selectedProductInfo = {};
        this.selectedProductInfoIsShow = false;
        // 清空lookup
        this.handleRemoveLookup('onProduct',null);
        this.showSuccess(this.label.PromoterDailyReport_AddNewItemSuccess);
        this.isShowSpinner = false;
    } else {
        this.isShowSpinner = false;
        this.showError(data.message);
    }
}).catch(error => {
    // 清空lookup
    this.handleRemoveLookup('onProduct',null);
    this.catchError(JSON.stringify(error));
    this.isShowSpinner = false;
});
}

    // 选择产品变更（基于产品线）
    handleChangeProductOptionByProductLine(resp) {
        console.log('==========>product change by product line');
        console.log('wwwwselectedRecord' + JSON.stringify(resp.detail.selectedRecord));
        var selectProductId;
        if (!resp.detail.selectedRecord) {
            return;
        } else {
            selectProductId = resp.detail.selectedRecord.Id;
        }
        var index = resp.target.dataset.index;
        var displayType = resp.target.dataset.fieldDisplaytype;
        console.log('WWWWCCCC==' + displayType);
        // console.log('WWWTTTT==' + JSON.stringify(resp.detail.selectedRecord));
        // 判断是否已存在产品
        console.log('WWWYYYY==' + this.samplingInspections.length);
        // console.log('WWWYYYY=CC=' + JSON.stringify(this.samplingInspections));

        for (let i = 0; i < this.samplingInspections.length; i++) {
            var item = this.samplingInspections[i];
            console.log('WWW表述参数值' + item.Display_Type__c);
            // if (item.Product__c==selectProductId && item.Display_Type__c == displayType) {
            if (item.Product__c==selectProductId) {
                // this.showError('Product already exists');
                this.showError(this.label.INSPECTION_REPORT_MSG_PRODUCT_EXISTS);
                return;
            }
        }
        console.log('WWWRRR=' + JSON.stringify(this.record));
        this.isShowSpinner = true;
        samplingInspectionAdd({
            recordId: this.recordId,
            recordJson: JSON.stringify(this.record),
            displayType: displayType,
            productId: selectProductId
        }).then(data => {
            console.log('---------->data='+JSON.stringify(data));
            if (data.isSuccess) {
                if (data.data.record) {
                    this.record = data.data.record;
                }
                // 只需要整理刷新check list 信息
                console.log('WWWWW' + selectProductId);
                this.addCheckResultsInfoDataFormat(data, displayType,selectProductId);
                // this.addCheckResultsInfoDataFormat(data, selectProductId, this.record.value);
                // this.displayTypesInfo.push(data.data.newSamplingInspection);
                // 清空lookup
                
                console.log('WWWWQQEE' + JSON.stringify(this.checkResultsInfo));
                this.handleRemoveLookup('onProductLine',index);
                this.showSuccess(this.label.PromoterDailyReport_AddNewItemSuccess);
                //刷新
                console.log('WWWW新增的刷新');
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

    // Summary字符
    handleSummaryChange(event) {
        this.record.Summary__c = event.target.value;
    }

    // Remark字符
    handleRemarkInput(event) {
        this.attendanceRemark = event.target.value;
    }

    handleRemarkInputCheckOut(event) {
        this.attendanceRemarkCheckOut = event.target.value;
        this.noteInfoCheckOut = event.target.value;
    }

    handleDisplayTypeChange(event) {
        console.log('WWW--'  + event.target.value);
        //留存位置用于创建一个空白Type
    }

    // added by Sunny about chile department start-[20231026]
    updateLookup(index) {
        var cmps = this.template.querySelectorAll('c-lookup-lwc');
        if (cmps) {
            let userIndex = 0;
            for (let i = 0; i < cmps.length; i++) {
                if (cmps[i].name=='onUser') {
                    if(userIndex == index) {
                        cmps[i].updateOption({
                            'lookup': 'CustomLookupProvider.DepartmentUserFilter',
                            'department' : this.ticketOpenInfo[index].Department__c
                        });
                        break;
                    } else {
                        userIndex += 1;
                    }
                }
            }
        }
    }

    removeLookup(index) {
        var cmps = this.template.querySelectorAll('c-lookup-lwc');
        if (cmps) {
            let userIndex = 0;
            for (let i = 0; i < cmps.length; i++) {
                if (cmps[i].name=='onUser') {
                    if(userIndex == index) {
                        cmps[i].handleRemove();
                        break;
                    } else {
                        userIndex += 1;
                    }
                }
            }
        }
    }

    // Open Ticket Department
    handleTicketDepartmentChange(event) {
        var index = event.target.dataset.index;
        this.ticketOpenInfo[index].Department__c = event.target.value;
        this.ticketOpenInfo[index].needSave = true;
        // this.lookupUserFilter['department'] = event.target.value;
        this.updateLookup(index);
        this.removeLookup(index);
    }

    // added by Sunny about chile department end-[20231026]
    // Open Ticket Assigned To
    handleTicketAssignedToChange(event) {
        var index = event.target.dataset.index;
        // this.ticketOpenInfo[index].AssignedTo__c = event.target.value;
        if (event.detail.selectedRecord==undefined) {
            this.ticketOpenInfo[index].AssignedTo__c = null;
        } else {
            this.ticketOpenInfo[index].AssignedTo__c = event.detail.selectedRecord.Id;
        }
        this.ticketOpenInfo[index].needSave = true;
    }
    // Open Ticket ActivityDate

    // Mileage Start
    handleMileageStartChange(event) {
        this.mileageRecord.Start__c = event.target.value;
    }

    // Mileage End
    handleMileageEndChange(event) {
        this.mileageRecord.End__c = event.target.value; 
    }

    dataFormat(data) {
        //check list
        this.checkResultsInfoDataFormat(data);
    }
    @track productFilter;
    // 整理check list 信息
    checkResultsInfoDataFormat(data) {
        var currency;
        this.currencyCode = this.Iso;
        currency = this.currencySymbol;
        this.currency = currency;
        const ids = JSON.stringify(this.pictureIds);
        this.pictureId = JSON.parse(ids);
        this.storeInfo[0] = this.storeInfos;

        // 移除 YYL 20250317
        // var productLineDetailInfo = {};

        // if(this.produceLineDetails) {
        //     productLineDetailInfo = this.produceLineDetails;
        //     if(productLineDetailInfo.ImgRequired__c && productLineDetailInfo.ImgRequired__c == 'Yes'){
        //         this.pictureNeed = true;
        //     } else {
        //         this.pictureNeed = false;
        //     }
        //     this.productLineDetail[0] = productLineDetailInfo;
        //     this.produceLinePhotoId = productLineDetailInfo.Id;
        // }

        // this.getPictureList();
        this.isPOPShow = this.isPOP;
        this.isDisplayShow = this.isDisplay;

        // TODO 新增针对墨西哥问题后续废弃 YYL 20250319
        this.IsCheckPriceShow = this.IsCheckPrice;
        this.CheckPriceDescription = this.CheckPrice;
        this.CheckPriceHelpTextShow = this.CheckPriceHelpText;
        this.IsPriceMexicoShow = this.IsPriceMexicoShow;
        this.priceMexicoDescription = this.PriceDesc;
        this.priceMexicoHelpTextShow = this.PriceHelpText;
        this.IsOptimalShow = this.IsOptimalShow;
        this.OptimalDescription = this.OptimalDesc;
        this.OptimalHelpTextShow = this.OptimalHelpText;

        this.isSetUpShow = this.isSetUp;
        this.isPriceShow = this.isPrice;
        this.DisplayHelpTextShow = this.DisplayHelpText;
        this.POPHelpTextShow = this.POPHelpText;
        this.SetUpHelpTextShow = this.SetUpHelpText;
        this.PriceHelpTextShow = this.PriceHelpText;
        
        this.DisplayDescription = this.DisplayDesc;
        this.DisplayMultipleChoice = this.DisplayEnterChoice;
        
        this.POPDescription = this.POPDesc;
        this.SetUpDescription = this.SetUpDesc;
        this.PriceDescription = this.PriceDesc;

        this.productLineDisplayInfo = this.productLineDisplay;

        var checkResultsInfo = [];
        console.log('分界线' + this.SetUpDescription + this.POPDescription + this.PriceDescription);
        console.log('WWWDETAIL' + this.isDetail);
        console.log('WWWisDetailDisplay' + this.isDetailDisplay);

        this.detailDisplayInfo = this.isDetailDisplay;
        this.productFilter = {
            productLookup: {
                'lookup' : 'CustomLookupProvider.ProductFilter',
                'Product_Line__c' : this.productLine
            }
        }
       
        if(this.isDetail == 'No') {
            // if(this.productLineDisplayInfo.length > 0){
                if (this.samplingInspections.length>0) {
                    // this.dispatchEvent(new CustomEvent('refreshdata'));
                    // 循环所有sampling
                        for (let i = 0; i < this.samplingInspections.length; i++) {
                            var checkResultsInfoItem = this.samplingInspections[i];
                            //备份
                            if(checkResultsInfoItem.Product__r.Product_Line__c) {
                                // var filteredList = checkResultsInfo.filter(obj => obj.displayType == this.productLineDisplayInfo[i].value);checkResultsInfoItem.Display_Type__c
                                var filteredList = checkResultsInfo.filter(obj => obj.productLine == this.productLine);

                                var item;
                                if (filteredList.length ==0) {
                                    item = {
                                        //巡店员日报日语翻译  BY lizunxing 20231020
                                        //YYL 移除展出类型纬度 20250324
                                        // displayType: checkResultsInfoItem.Display_Type__c,
                                        productLine: this.productLine,
                                        productLineName: this.productLine,
                                        productLookup: {
                                            'lookup' : 'CustomLookupProvider.ProductFilter',
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
                                    // if (this.checkResults[checkResultsInfoItem.Product__r.Product_Line__c]!=undefined) {
                                    //     var checkResultitem = this.checkResults[checkResultsInfoItem.Product__r.Product_Line__c];
                                    //     Object.keys(checkResultitem).forEach(pjObj => {
                                    //         var project = checkResultitem[pjObj];
                                    //         var pj = {
                                    //             project: pjObj, 
                                    //             projectItems: project,
                                    //             projectItems_done: project.filter(pr => pr.Scores__c!= -1).length, 
                                    //             projectItems_total: project.length
                                    //         };
                                    //         item.productLineItem.push(pj);
                                    //     });
                                    // }
                                    checkResultsInfo.push(item);
                                // 存在该产品线
                                } else {
                                    item = filteredList[0];
                                }

                                // YYL 处理展出类型问题 20250324
                                // 判断是否有默认数据
                                if(this.isDisplayShow){
                                    let choiceValue = [];
                                    if(checkResultsInfoItem.Display_Type__c != null && checkResultsInfoItem.Display_Type__c != ''){
                                        choiceValue = checkResultsInfoItem.Display_Type__c.split(";");
                                    }

                                    let choice = this.DisplayMultipleChoice.split(";");
                                    let enterChoice = [];
                                    for(var ice in choice){
                                        let flag = false;

                                        // 根据暂存值设置默认选项
                                        if(choiceValue.indexOf(choice[ice]) != -1){
                                            flag = true;
                                        }

                                        enterChoice.push({
                                            label:choice[ice],
                                            value:choice[ice],
                                            flag:flag
                                        });
                                    }

                                    console.log('wwwwenterChoice' + JSON.stringify(enterChoice));
                                    checkResultsInfoItem.option = enterChoice;
                                }

                                // YYL 处理展示照片 20250324
                                if(checkResultsInfoItem.Before_Img__c){
                                    var beforeImg = checkResultsInfoItem.Before_Img__c;
                                    getExistingFilesList({
                                        ContentDocumentId : beforeImg
                                    }).then(data =>{
                                        console.log('wwwwBefore_Img__c' + JSON.stringify(data));
                                        checkResultsInfoItem.beforeFiles = data;
                                    })
                                }
                                if(checkResultsInfoItem.After_Img__c){
                                    var afterImg = checkResultsInfoItem.After_Img__c;
                                    getExistingFilesList({
                                        ContentDocumentId : afterImg
                                    }).then(data =>{
                                        console.log('wwwwAfter_Img__c' + JSON.stringify(data));
                                        checkResultsInfoItem.afterFiles = data;
                                    })
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
                                // if(checkResultsInfoItem.Display_Status__c && checkResultsInfoItem.Display_Status__c == 'Yes'){
                                //     checkResultsInfoItem['SelectYes'] = true;
                                // }else {
                                //     checkResultsInfoItem['SelectYes'] = false;
                                // }
                                if(checkResultsInfoItem.Placement_Status__c && checkResultsInfoItem.Placement_Status__c == '展出'){
                                    checkResultsInfoItem['SelectYes'] = true;
                                }else {
                                    checkResultsInfoItem['SelectYes'] = false;
                                }

                                // TODO 根据确认价格问题是否相同判断是否展示 YYL 20250119 后续废除
                                if(checkResultsInfoItem.Is_Check_Price__c && checkResultsInfoItem.Is_Check_Price__c == 'No'){
                                    checkResultsInfoItem['IsPriceYes'] = true;
                                }else {
                                    checkResultsInfoItem['IsPriceYes'] = false;
                                }

                                // TODO 根据确认价格问题是否需要清洗 YYL 20250324 后续废除
                                if(checkResultsInfoItem.Is_Optimal__c && checkResultsInfoItem.Is_Optimal__c == 'No'){
                                    checkResultsInfoItem['isOptimalYes'] = true;
                                }else {
                                    checkResultsInfoItem['isOptimalYes'] = false;
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
                                if(checkResultsInfoItem.Placement_Status__c && checkResultsInfoItem.Placement_Status__c == '展出'){
                                    checkResultsInfoItem['SelectYes'] = true;
                                }else {
                                    checkResultsInfoItem['SelectYes'] = false;
                                }

                                // TODO 根据确认价格问题是否相同判断是否展示 YYL 20250119 后续废除
                                if(checkResultsInfoItem.Is_Check_Price__c && checkResultsInfoItem.Is_Check_Price__c == 'No'){
                                    checkResultsInfoItem['IsPriceYes'] = true;
                                }else {
                                    checkResultsInfoItem['IsPriceYes'] = false;
                                }

                                // TODO 根据确认价格问题是否需要清洗 YYL 20250324 后续废除
                                if(checkResultsInfoItem.Is_Optimal__c && checkResultsInfoItem.Is_Optimal__c == 'No'){
                                    checkResultsInfoItem['isOptimalYes'] = true;
                                }else {
                                    checkResultsInfoItem['isOptimalYes'] = false;
                                }

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
                        console.log('获取Detail 数据集合标记');
                        console.log('WWW数据传递' + JSON.stringify(this.productLineDisplayInfo));
                        console.log('WWWWWWWWWW梳理数据' + JSON.stringify(checkResultsInfo));
                        console.log('WWWWWWWWWW梳理数据' + checkResultsInfo.length);
                        console.log('WWW参数' + checkResultsInfo[0].displayType);

                        var param = [];
                        for (let i = 0; i < checkResultsInfo.length; i++){
                            param.push(checkResultsInfo[i].displayType);
                        }
                        console.log('WWW打印测试' + JSON.stringify(param));
                        // 获取集合 B 中的所有 value
                        const BValues = this.productLineDisplayInfo.map(item => item.value);

                        // 过滤出集合 B 中不在集合 A 中的值
                        const unmatched = BValues.filter(value => !param.includes(value));

                        // 输出未匹配到的值
                        console.log('wwwwwww强请' + unmatched);
            
                        console.log('wwwwwww强请' + unmatched.length);
                        // for(let i = 0; i < unmatched.length; i++){
                        //     var item = {
                        //         //巡店员日报日语翻译  BY lizunxing 20231020
                        //         displayType: unmatched[i],
                        //         productLine: this.productLine,
                        //         productLineName: this.productLine,
                        //         productLookup: {
                        //             'lookup' : 'CustomLookupProvider.ProductFilter',
                        //             // 'Product_Line__c' : checkResultsInfo[0].displayType
                        //             'Product_Line__c' : this.productLine

                        //         },
                        //         samplingInspection: true,
                        //         samplingInspectionPlanIn: [],
                        //         samplingInspectionPlanOut: [],
                        //         productLineItem: [],
                        //     };
                        //     // console.log('WWWWWITEM' + JSON.stringify(item));
                        //     checkResultsInfo.push(item);
                        //     // console.log('WWWWWWwoioio'+ i );
                        // }


                } else {
                    console.log('WWWWWWWW' + JSON.stringify(this.productLineDisplayInfo));
                    var item;
                    var checkResultsInfo = [];
                    console.log('WWWWW插眼');
                    console.log('WWWWW插眼' +this.productLineDisplayInfo.length);
                    console.log('WWWWWPRODUCTLINE' + this.productLine)
                    if (this.productLineDisplayInfo.length > 0) {
                        console.log('WWWW开始循环' );
                        for(let i = 0; i < this.productLineDisplayInfo.length; i++){
                            console.log('WWWW进入循环体');
                            console.log('WWWW进入循环体displayType:' +  this.productLineDisplayInfo[i].value);

                            item = {
                                //巡店员日报日语翻译  BY lizunxing 20231020
                                // displayType: this.productLineDisplayInfo[i].value,
                                productLine: this.productLine,
                                productLineName: this.productLine,
                                productLookup: {
                                    'lookup' : 'CustomLookupProvider.ProductFilter',
                                    'Product_Line__c' : this.productLine,
                                },
                                samplingInspection: true,
                                samplingInspectionPlanIn: [],
                                samplingInspectionPlanOut: [],
                                productLineItem: [],
                            };
                            console.log('WWWWWITEM' + JSON.stringify(item));
                            checkResultsInfo.push(item);
                        }
                        
                    }
                }
        } else {
            console.log('WWW打印一下参数' + JSON.stringify(this.samplingInspections));
            console.log('WWW打印一下参数' + JSON.stringify(this.samplingInspections.length));

            if (this.samplingInspections.length>0) {
                // this.dispatchEvent(new CustomEvent('refreshdata'));
                // 循环所有sampling
                    for (let i = 0; i < this.samplingInspections.length; i++) {
                        var checkResultsInfoItem = this.samplingInspections[i];
                        //备份
                        if(checkResultsInfoItem.Product__r.Product_Line__c) {
                            // var filteredList = checkResultsInfo.filter(obj => obj.displayType == this.productLineDisplayInfo[i].value);checkResultsInfoItem.Display_Type__c
                            var filteredList = checkResultsInfo.filter(obj => obj.productLine == this.productLine);

                            var item;
                            if (filteredList.length ==0) {

                                item = {
                                    //巡店员日报日语翻译  BY lizunxing 20231020
                                    //YYL 移除展出类型纬度 20250324
                                    // displayType: this.detailDisplayInfo[i].value,
                                    productLine: this.productLine,
                                    productLineName: this.productLine,
                                    productLookup: {
                                        'lookup' : 'CustomLookupProvider.ProductFilter',
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
                                // if (this.checkResults[checkResultsInfoItem.Product__r.Product_Line__c]!=undefined) {
                                //     var checkResultitem = this.checkResults[checkResultsInfoItem.Product__r.Product_Line__c];
                                //     Object.keys(checkResultitem).forEach(pjObj => {
                                //         var project = checkResultitem[pjObj];
                                //         var pj = {
                                //             project: pjObj, 
                                //             projectItems: project,
                                //             projectItems_done: project.filter(pr => pr.Scores__c!= -1).length, 
                                //             projectItems_total: project.length
                                //         };
                                //         item.productLineItem.push(pj);
                                //     });
                                // }
                                checkResultsInfo.push(item);
                            // 存在该产品线
                            } else {
                                item = filteredList[0];
                            }
                            // 判断产品线内产品是否全是出样外
                            if (checkResultsInfoItem.Unplanned_Sample__c == 'No' && item.AllSamplePlanOut) {
                                item.AllSamplePlanOut = false;
                            }

                            // YYL 处理展出类型问题 20250324
                            // 判断是否有默认数据
                            if(this.isDisplayShow){
                                let choiceValue = [];
                                if(checkResultsInfoItem.Display_Type__c != null && checkResultsInfoItem.Display_Type__c != ''){
                                    choiceValue = checkResultsInfoItem.Display_Type__c.split(";");
                                }

                                let choice = this.DisplayMultipleChoice.split(";");
                                let enterChoice = [];
                                for(var ice in choice){
                                    let flag = false;

                                    // 根据暂存值设置默认选项
                                    if(choiceValue.indexOf(choice[ice]) != -1){
                                        flag = true;
                                    }

                                    enterChoice.push({
                                        label:choice[ice],
                                        value:choice[ice],
                                        flag:flag
                                    });
                                }

                                console.log('wwwwenterChoice' + JSON.stringify(enterChoice));
                                checkResultsInfoItem.option = enterChoice;
                            }

                            // YYL 处理展示照片 20250324
                            if(checkResultsInfoItem.Before_Img__c){
                                var beforeImg = checkResultsInfoItem.Before_Img__c;
                                getExistingFilesList({
                                    ContentDocumentId : beforeImg
                                }).then(data =>{
                                    console.log('wwwwBefore_Img__c' + JSON.stringify(data));
                                    checkResultsInfoItem.beforeFiles = data;
                                })
                            }
                            if(checkResultsInfoItem.After_Img__c){
                                var beforeImg = checkResultsInfoItem.After_Img__c;
                                getExistingFilesList({
                                    ContentDocumentId : beforeImg
                                }).then(data =>{
                                    console.log('wwwwBefore_Img__c' + JSON.stringify(data));
                                    checkResultsInfoItem.afterFiles = data;
                                })
                            }
                            
                            
                        // 计划内出样
                            console.log('@WWWDetail为True' + JSON.stringify(checkResultsInfoItem));
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
                            console.log('WWW校对数据'+ JSON.stringify(checkResultsInfoItem));
                            if (this.checkResultsIsRelatedToProduct && this.checkResultsIsRelatedToProduct.filter(obj => obj.Sampling_Inspection__c == checkResultsInfoItem.Id).length>0) {
                            var samplingInspections = this.checkResultsIsRelatedToProduct.filter(obj => obj.Sampling_Inspection__c == checkResultsInfoItem.Id);
                            checkResultsInfoItem['checkItems'] = [];
                            }

                            // if(checkResultsInfoItem.Display_Status__c && checkResultsInfoItem.Display_Status__c == 'Yes'){
                            //     checkResultsInfoItem['SelectYes'] = true;
                            // }else {
                            //     checkResultsInfoItem['SelectYes'] = false;
                            // }

                            if(checkResultsInfoItem.Placement_Status__c && checkResultsInfoItem.Placement_Status__c == '展出'){
                                checkResultsInfoItem['SelectYes'] = true;
                            }else {
                                checkResultsInfoItem['SelectYes'] = false;
                            }

                            // TODO 根据确认价格问题是否相同判断是否展示 YYL 20250119 后续废除
                            if(checkResultsInfoItem.Is_Check_Price__c && checkResultsInfoItem.Is_Check_Price__c == 'No'){
                                checkResultsInfoItem['IsPriceYes'] = true;
                            }else {
                                checkResultsInfoItem['IsPriceYes'] = false;
                            }

                            // TODO 根据确认价格问题是否需要清洗 YYL 20250324 后续废除
                            if(checkResultsInfoItem.Is_Optimal__c && checkResultsInfoItem.Is_Optimal__c == 'No'){
                                checkResultsInfoItem['isOptimalYes'] = true;
                            }else {
                                checkResultsInfoItem['isOptimalYes'] = false;
                            }

                            console.log('WWWID参数' + checkResultsInfoItem.Id);
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
                            if(checkResultsInfoItem.Placement_Status__c && checkResultsInfoItem.Placement_Status__c == '展出'){
                                checkResultsInfoItem['SelectYes'] = true;
                            }else {
                                checkResultsInfoItem['SelectYes'] = false;
                            }

                            // TODO 根据确认价格问题是否相同判断是否展示 YYL 20250319 后续废除
                            if(checkResultsInfoItem.Is_Check_Price__c && checkResultsInfoItem.Is_Check_Price__c == 'No'){
                                checkResultsInfoItem['IsPriceYes'] = true;
                            }else {
                                checkResultsInfoItem['IsPriceYes'] = false;
                            }

                            // TODO 根据确认价格问题是否需要清洗 YYL 20250324 后续废除
                            if(checkResultsInfoItem.Is_Optimal__c && checkResultsInfoItem.Is_Optimal__c == 'No'){
                                checkResultsInfoItem['isOptimalYes'] = true;
                            }else {
                                checkResultsInfoItem['isOptimalYes'] = false;
                            }

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
                    }

                    console.log('WWW数据传递' + JSON.stringify(this.detailDisplayInfo));
                    var param = [];
                    for (let i = 0; i < checkResultsInfo.length; i++){
                        param.push(checkResultsInfo[i].displayType);
                    }
                    var detailDisplays = [];
                    console.log('WWW打印测试' + JSON.stringify(this.detailDisplayInfo));
                    console.log('WWW打印测试2' + JSON.stringify(param));

                    // 获取集合 B 中的所有 value
                    const BValues = this.detailDisplayInfo.map(item => item.value);

                    // 过滤出集合 B 中不在集合 A 中的值
                    const unmatched = BValues.filter(value => !param.includes(value));

                    // 输出未匹配到的值
                    // for(let i = 0; i < unmatched.length; i++){
                    //     var item = {
                    //         //巡店员日报日语翻译  BY lizunxing 20231020
                    //         displayType: unmatched[i],
                    //         productLine: this.productLine,
                    //         productLineName: this.productLine,
                    //         productLookup: {
                    //             'lookup' : 'CustomLookupProvider.ProductFilter',
                    //             // 'Product_Line__c' : checkResultsInfo[0].displayType
                    //             'Product_Line__c' : this.productLine

                    //         },
                    //         samplingInspection: true,
                    //         samplingInspectionPlanIn: [],
                    //         samplingInspectionPlanOut: [],
                    //         productLineItem: [],
                    //     };
                    //     // console.log('WWWWWITEM' + JSON.stringify(item));
                    //     checkResultsInfo.push(item);
                    //     // console.log('WWWWWWwoioio'+ i );
                    // }
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
                    console.log('获取Detail 数据集合标记');
                    console.log('WWW数据传递' + JSON.stringify(this.detailDisplayInfo));
                    console.log('WWWWWWWWWW梳理数据' + JSON.stringify(checkResultsInfo));
                    console.log('WWWWWWWWWW梳理数据' + checkResultsInfo.length);
                    console.log('WWW参数' + checkResultsInfo[0].displayType);



            } else {
                var item;
                var checkResultsInfo = [];
                if (this.detailDisplayInfo.length > 0) {
                    for(let i = 0; i < this.detailDisplayInfo.length; i++){
                    item = {
                        //巡店员日报日语翻译  BY lizunxing 20231020
                        // displayType: this.detailDisplayInfo[i].value,
                        productLine: this.productLine,
                        productLineName: this.productLine,
                        productLookup: {
                            'lookup' : 'CustomLookupProvider.ProductFilter',
                            'Product_Line__c' : this.productLine,
                        },
                        samplingInspection: true,
                        samplingInspectionPlanIn: [],
                        samplingInspectionPlanOut: [],
                        productLineItem: [],
                    };
                    checkResultsInfo.push(item);
                    }
                    
                }
            }
        }
        this.checkResultsInfo = checkResultsInfo;
        console.log('WWW-edit参数' + this.isEditPage);
        console.log('WWW-productLine参数' + this.productLine);

    }

    // Group Button Click - 出样
    siGroupButtonClick(event) {
    var productline = event.target.dataset.productline;
    var inorout = event.target.dataset.inorout;
    var samplinginspectionid = event.target.dataset.samplinginspectionid;
    var checkitemid = event.target.dataset.checkitemid;
    var number = event.target.dataset.number;
    // 定位
    var checkItem_filterItem = this.checkResultsInfoFilter(productline,inorout,samplinginspectionid,checkitemid);
    var buttonwidth = Math.floor(100/Number(checkItem_filterItem.CheckItem__r.MaximumScore__c));
    checkItem_filterItem.styles.forEach(obj => {
        if (obj.buttonNumber == Number(number)) {
            obj.style = 'width: '+buttonwidth+'%;';
        } else {
            obj.style = 'background: white; color: black;'+'width: '+buttonwidth+'%;';
        }
        if (checkItem_filterItem.Scores__c < checkItem_filterItem.CheckItem__r.MaximumScore__c) {
            checkItem_filterItem.isMust = true;
        } else {
            checkItem_filterItem.isMust = false;
        }
    });
    checkItem_filterItem.fileMust = checkItem_filterItem.fileRequireScores.includes(checkItem_filterItem.Scores__c);
    checkItem_filterItem.commentMust = checkItem_filterItem.commentRequireScores.includes(checkItem_filterItem.Scores__c);
    var updateCr = this.checkResultsIsRelatedToProduct.filter(obj => obj.Id == checkitemid);
    if (updateCr.length>0) {
        updateCr[0].Scores__c = Number(number);
    }
    }
    // Checkbox Change - 出样
    siCheckboxChangeClick(event){
    var productline = event.target.dataset.productline;
    var inorout = event.target.dataset.inorout;
    var samplinginspectionid = event.target.dataset.samplinginspectionid;
    var checkitemid = event.target.dataset.checkitemid;
    var type = event.target.dataset.type;
    // 定位
    var checkItem_filterItem = this.checkResultsInfoFilter(productline,inorout,samplinginspectionid,checkitemid);
    if (type == '展出') {
        checkItem_filterItem.unChecked = false;
        checkItem_filterItem.isChecked = true;
        checkItem_filterItem.styleYes = 'width: 50%;';
        checkItem_filterItem.styleNo = 'background: white; color: black; width: 50%;';
        checkItem_filterItem.Scores__c = Number(checkItem_filterItem.CheckItem__r.MaximumScore__c);
    } else {
        checkItem_filterItem.unChecked = false;
        checkItem_filterItem.isChecked = false;
        checkItem_filterItem.styleYes = 'background: white; color: black; width: 50%;';
        checkItem_filterItem.styleNo = 'width: 50%;';
        checkItem_filterItem.Scores__c = 0;
    }
    checkItem_filterItem.fileMust = checkItem_filterItem.fileRequireScores.includes(checkItem_filterItem.Scores__c);
    checkItem_filterItem.commentMust = checkItem_filterItem.commentRequireScores.includes(checkItem_filterItem.Scores__c);
    var updateCr = this.checkResultsIsRelatedToProduct.filter(obj => obj.Id == checkitemid);
    if (updateCr.length>0) {
        updateCr[0].Scores__c = checkItem_filterItem.Scores__c;
    }

    console.log('siCheckboxChangeClick ---> checkItem_filterItem: ' + JSON.stringify(checkItem_filterItem));
    }
    // Comment Change - 出样
    siCheckItemCommentChange(event) {
    var productline = event.target.dataset.productline;
    var inorout = event.target.dataset.inorout;
    var samplinginspectionid = event.target.dataset.samplinginspectionid;
    var checkitemid = event.target.dataset.checkitemid;
    var value = event.target.value;
    // 定位
    var checkItem_filterItem = this.checkResultsInfoFilter(productline,inorout,samplinginspectionid,checkitemid);
    checkItem_filterItem.Comments__c = value;
    }

    checkResultsInfoFilter(productline,inorout,samplinginspectionid,checkitemid) {
    var checkResultsInfo_filter = this.checkResultsInfo.filter(obj => obj.productLine==productline);
    if (checkResultsInfo_filter.length==0) {
        return;
    }
    var checkResultsInfo_filterItem = checkResultsInfo_filter[0];
    var samplingInspection_items;
    if (inorout == 'in') {
        samplingInspection_items = checkResultsInfo_filterItem.samplingInspectionPlanIn;
    } else {
        samplingInspection_items = checkResultsInfo_filterItem.samplingInspectionPlanOut;
    }
    var samplingInspection_filter = samplingInspection_items.filter(obj => obj.Id == samplinginspectionid);
    if (samplingInspection_filter.length==0) {
        return;
    }
    var samplingInspection_filterItem = samplingInspection_filter[0];
    var checkItem_filter = samplingInspection_filterItem.checkItems.filter(obj => obj.Id == checkitemid);
    if (checkItem_filter.length==0) {
        return;
    }
    var checkItem_filterItem = checkItem_filter[0];
    return checkItem_filterItem;
    }
    // 新增check list 信息（新增产品必须为计划外，不能影响已修改未保存数据）
    addCheckResultsInfoDataFormat(data,displayType, productId) {
        // var filterNewSi = data.data.samplingInspections.filter(obj => obj.Product__c == productId && obj.Display_Type__c == displayType);
        var filterNewSi = data.data.samplingInspections.filter(obj => obj.Product__c == productId);
        console.log('WWWJSON' + JSON.stringify(filterNewSi));
        if (filterNewSi.length>0) {
            var newProduct = filterNewSi[0];
            this.samplingInspections.push(newProduct)
            var filterNewInfo = this.checkResultsInfo.filter(obj => obj.Product_Line__c == newProduct.Product__r.Product_Line__c);
            var item;
            console.log('WWWWASAS'+JSON.stringify(filterNewInfo));
            if (filterNewInfo.length == 0) {
                item = {
                    //巡店员日报日语翻译  BY lizunxing 20231020
                    // displayType: displayType,
                    productLine: newProduct.Product__r.Product_Line__c,
                    productLineName: newProduct.Product__r.Product_Line__c,
                    // isTv : newProduct.Product__r.Product_Line__c == 'TV' ? true : false,
                    // isTv : true,
                    productLookup: {
                        'lookup' : 'CustomLookupProvider.ProductFilter',
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
                console.log('WWWWfffff------------' + JSON.stringify(this.checkResultsInfo));
                console.log('WWWWfffff------------' + JSON.stringify(item));
            } else {
                item = filterNewInfo[0];
            }
            // 判断产品线内产品是否全是出样外
            if (newProduct.Unplanned_Sample__c == 'No' && item.AllSamplePlanOut) {
                item.AllSamplePlanOut = false;
            }

            // YYL 处理展示照片 20250324
            if(newProduct.Before_Img__c){
                var beforeImg = newProduct.Before_Img__c;
                getExistingFilesList({
                    ContentDocumentId : beforeImg
                }).then(data =>{
                    console.log('wwwwBefore_Img__c' + JSON.stringify(data));
                    newProduct.beforeFiles = data;
                })
            }
            if(newProduct.After_Img__c){
                var beforeImg = newProduct.After_Img__c;
                getExistingFilesList({
                    ContentDocumentId : beforeImg
                }).then(data =>{
                    console.log('wwwwBefore_Img__c' + JSON.stringify(data));
                    newProduct.afterFiles = data;
                })
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

                if(newProduct.Placement_Status__c && newProduct.Placement_Status__c == '展出'){
                    newProduct['SelectYes'] = true;
                }else {
                    newProduct['SelectYes'] = false;
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

    // 刷新数据
    refreshData(ele) {
    ele.isShowSpinner = true;
    refreshData({
        recordJson: JSON.stringify(ele.record), currentLat: ele.currentLat, currentLong: ele.currentLong, contentVersionId: ele.contentVersionId,
        shopId: ele.storeId  
    }).then(data => {
        if (data.isSuccess) {
            for (let key in data.data) {
                ele[key] = data.data[key];
            }
            console.log('data',JSON.stringify(data));
            // Deloitte Yin Mingjie 20231114 start
            // check list格式化
            if (data.data.checkResults) {
                ele.checkResults = ele.checkCheckResults(data.data.checkResults);
            }
            // Deloitte Yin Mingjie 20231114 end
            // 有历史数据，设置签到地图，无历史数据，设置打卡地图
            if (ele.record.Id) {
                if (ele.record.Status__c == 'Submitted') {
                    ele.isFieldReadOnly = true;
                    ele.isTitleShowButton = false;
                } else {
                    ele.isTitleShowButton = true;
                }
                ele.isEditPage = false;
                //如果是远程巡店 则不需要显示地图 不需要初始化地图信息 20231101
                console.log('执行到这==========='+ele.record.Inspect_Type__c);
                if (ele.record.Inspect_Type__c != 'Remote Inspection') {
                    ele.setShowMapInformation();
                }
            } else {
                if (ele.attendancePhotoStreamInfo) {
                    ele.attendancePhotoStream = 'data:image/jpeg;base64,'+ele.attendancePhotoStreamInfo.slice(1).slice(0,-1);
                }
                ele.checkResults = {};
                ele.isTitleShowButton = false;
                ele.isFieldReadOnly = true;
                if (ele.record.Inspect_Type__c != 'Remote Inspection') {
                    ele.setMapInformation();
                }
                ele.attendanceShowPhotoCheckOut = false;
                ele.attendancePhotoStreamCheckOut = null;
                ele.attendanceRemarkCheckOut = null;
            }

            // 数据格式化
            ele.dataFormat(data);
            ele.isShowSpinner = false;
        } else {
            ele.isShowSpinner = false;
            ele.showError(data.message);
        }
    }).catch(error => {
        ele.catchError(JSON.stringify(error));
        ele.isShowSpinner = false;
    });
    }

    // 新建数据
    createRecord(ele) {
    ele.isShowSpinner = true;
    createRecord({
        recordJson: JSON.stringify(ele.record),
        attendanceFromType: ele.attendanceFromType,
        attendancePhotoStreamJson: ele.attendancePhotoStream,
        attendanceRemark: ele.attendanceRemark,
    }).then(data => {
        
        if (data.isSuccess) {
            for (let key in data.data) {
                ele[key] = data.data[key];
            }
            // Deloitte Yin Mingjie 20231114 start
            // check list格式化
            if (data.data.checkResults) {
                ele.checkResults = ele.checkCheckResults(data.data.checkResults);
            }
            // Deloitte Yin Mingjie 20231114 end
            ele.isTitleShowButton = true;
            ele.isEditPage = false;
            // 数据格式化
            ele.dataFormat(data);
            ele.handleEdit();
            ele.isShowSpinner = false;
        } else {
            ele.isShowSpinner = false;
            ele.showError(data.message);
        }
    }).catch(error => {
        ele.catchError(error);
        ele.isShowSpinner = false;
    });
    }
    
    // 更新数据
    upsertRecord(isSubmit) {
    this.record.Total_Score__c = this.countScore.Total_Score__c;
    this.record.Total_Score_Max__c = this.countScore.Total_Score_Max__c;
    this.record.Average_Score_Count__c = this.countScore.Average_Score_Count__c;
    this.record.Average_Score__c = this.countScore.Average_Score__c;
    this.record.Average_Score_Max__c = this.countScore.Average_Score_Max__c;
    this.isShowSpinner = true;
    var copyCheckResultsIsRelatedToProduct = JSON.parse(JSON.stringify(this.checkResultsIsRelatedToProduct));
    console.log('wwwwcopyCheckResultsIsRelatedToProduct' + JSON.stringify(copyCheckResultsIsRelatedToProduct));
    copyCheckResultsIsRelatedToProduct.forEach(obj => {
        delete obj['index'];
        delete obj['isButtonOption'];
        delete obj['styles'];
        delete obj['fileRequireScores'];
        delete obj['fileMust'];
        delete obj['commentRequireScores'];
        delete obj['commentMust'];
        delete obj['isMust'];
        delete obj['isCheckbox'];
        delete obj['isChecked'];
        delete obj['unChecked'];
        delete obj['styleYes'];
        delete obj['styleNo'];
    });

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
        delete obj['option'];
        delete obj['afterFiles'];
        delete obj['beforeFiles'];
        if(this.isArgentina && obj.Product__r.Product_Line__c == 'TV'){
            if(obj.Display_Stand__c == true || obj.On_Wall_Display__c == true){
                obj.Placement_Status__c = '展出';
            }else{
                obj.Placement_Status__c = '未展出';
            }
        }
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
        if (data.isSuccess) {
            for (let key in data.data) {
                this[key] = data.data[key];
            }
            if (isSubmit) {
                if (data.data.submitCheckError) {
                    this.showError(data.data.submitCheckError);
                    this.isShowSpinner = false;
                    return;
                }
                //20241015数据暂时剥离 <> 还原
                // this.isFieldReadOnly = true;
                this.isTitleShowButton = false;
                // this.isEditPage = false;
                this.isEditPage = true;
                this.isFieldReadOnly = false;
            } 
            //20241015数据暂时剥离 <> 还原
            else {
                // this.isEditPage = false;
                // this.isFieldReadOnly = true;
                this.isEditPage = true;
                this.isFieldReadOnly = false;
            }

            // 数据格式化
            // this.dataFormat(data);
            this.showSuccess('success');
            this.isShowSpinner = false;
        } else {
            this.isShowSpinner = false;
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
        this.isShowSpinner = false;
    });
    }

    handleCheckChange(event){
        var index = event.target.dataset.index;
        var type = event.target.dataset.type;
        var checkItem = this.selectedProject[Number(index)];
        if (type == 'yes') {
            checkItem.unChecked = false;
            checkItem.isChecked = true;
            checkItem.styleYes = 'width: 50%;';
            checkItem.styleNo = 'background: white; color: black; width: 50%;';
            checkItem.Scores__c = Number(checkItem.CheckItem__r.MaximumScore__c);
        } else {
            checkItem.unChecked = false;
            checkItem.isChecked = false;
            checkItem.styleYes = 'background: white; color: black; width: 50%;';
            checkItem.styleNo = 'width: 50%;';
            checkItem.Scores__c = 0;
        }
        checkItem.fileMust = checkItem.fileRequireScores.includes(checkItem.Scores__c);
        checkItem.commentMust = checkItem.commentRequireScores.includes(checkItem.Scores__c);
    }

    // Comment Change
    commentChange(event) {
        var index = event.target.dataset.index;
        var value = event.target.value;
        this.selectedProject[Number(index)].Comments__c = value;
    }

    // Check List Saave
    handleCheckListSave() {
        this.isShowSpinner = true;
        var copySelectedProject = JSON.parse(JSON.stringify(this.selectedProject));
        copySelectedProject.forEach(obj => {
            delete obj['styles'];
            delete obj['commentRequireScores'];
            delete obj['fileRequireScores'];
        });
        checkListSave({
            recordId: this.record.Id,
            checkListJson: JSON.stringify(copySelectedProject)
        }).then(data => {
            if (data.isSuccess) {
                var summary  = this.record.Summary__c;
                for (let key in data.data) {
                    this[key] = data.data[key];
                }
                this.record.Summary__c = summary;
                // Deloitte Yin Mingjie 20231114 start
                if (data.data.checkResults) {
                    this.checkResults = this.checkCheckResults(data.data.checkResults);
                }
                // Deloitte Yin Mingjie 20231114 end
                this.itemFormat();
                this.checkResultsInfoDataFormat(data);
                this.showSuccess('success');
                this.isShowSpinner = false;
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            console.log('---------->error='+error);
            this.catchError(JSON.stringify(error));
            this.isShowSpinner = false;
        });
    }

    // Check List Back
    handleCheckListBack() {
        this.checklistPage = false;
        this.selectedProject = [];
        this.checklistProductline = '';
        this.checklistProject = '';
    }
    /* Sampling Inspection Page - 废弃*/
    @track siSelectedProductline = [];
    @track siSelectedProductlinePlanOut = [];
    @track samplingInspectionPage = false;
    @track samplingInspectionProductline;
    @track diaplayTypeSelect = true;
    get sioptions() {
        return [  { label: 'Yes', value: '展出' }, { label: 'No', value: '未展出' } ];
    }

    siCheckboxChange(event) {
        var check = event.detail.value;
        console.log('-----------WWWW监听一下YESORNO参数变化event type' + event.detail.value);
        // this.samplingInspectionChange(event, 'Display_Status__c', false);
        var resultindex = Number(event.target.dataset.resultindex);
        var index = Number(event.target.dataset.index);
        console.log('WWWINDEX'+ index);
        var type = event.target.dataset.t;
        console.log('WWWtype------------' + type);

        var check = event.detail.value;
        var checkItem;
        var checkResult = [];

        var siId;
        var paramType = (check == '展出');
        if (type == 'PlanIn') {
            this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].SelectYes = paramType;
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
            console.log('SIID' + siId);
            console.log('WWW测试数据PlanIn--' + JSON.stringify(this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index]));
        } else {
            this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].SelectYes = paramType;
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;
            console.log('SIID' + siId);
            console.log('WWW测试数据--' + JSON.stringify(this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index]));
        }
        this.samplingInspections.forEach(obj => {
            if (obj.Id == siId) {
                // obj.Display_Status__c = check;
                obj.Placement_Status__c = check;
            }
        });

        // wfc Display or not 选择yes的时候，保存 CheckResult__c ,选择no的时候，删除 CheckResult__c
        var sampleId = event.target.dataset.sampleId;
        console.log('wwwwww-----sampleId---' + sampleId);
        console.log('wwwwww-----Sales_Region__c---' + this.record.Store__r.Sales_Region__c);
        console.log('wwwwww-----checkItemList---' + JSON.stringify(this.checkItemList));
        if(paramType){
            this.isShowSpinner = true;
            // saveCheckResultForSamplingInspection({
            //     inspectorDailyReportId: this.inspectionId,
            //     inspectionProductItemId: this.recordId,
            //     samplingInspectionId: sampleId,
            //     salesRegion: this.record.Store__r.Sales_Region__c,
            //     checkItemList: JSON.stringify(this.checkItemList),
            // }).then(data => {}).catch(error => {});
        } else {
            this.isShowSpinner = true;
            deleteCheckResultForSamplingInspection({
                samplingInspectionId: sampleId,
            }).then(data => {
                this.isShowSpinner = false;
            }).catch(error => {
                this.isShowSpinner = false;
            });
        }


        this.dispatchEvent(
            new CustomEvent("select", {
                detail: {
                    hasEdit: true,
                },
            })
        );
    }

    closeSpinner(){
        this.isShowSpinner = false;
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

    deleteChildComponent;
    siHandleSelectFiles(event) {
        var isTv = false;
        console.log('监听方法');
        var resultindex = Number(event.target.dataset.resultindex);
        var index = Number(event.target.dataset.index);
        var type = event.target.dataset.type;
        //var type = event.currentTarget.dataset.type;
        var siId;
        if (type == 'PlanIn') {
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
        } else {
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;
        }

        //暂时不用 2025-04-18开启
        // if(this.checkResultsInfo[resultindex].productLine == 'TV'){
        //     isTv = true;
        // }

        // 获取新上传的图片记录
        this.samplingInspections.forEach(obj => {
            if (obj.Id == siId) {
                obj.Img_Status__c = true;

                if(isTv){
                    const childComponents = this.template.querySelectorAll('c-upload-files3-lwc');
                    childComponents.forEach(childComponent => {
                        if(childComponent.getAttribute('data-index') == index && childComponent.getAttribute('data-type') == type){
                            this.deleteChildComponent = childComponent;
                            let image = childComponent.files1()[childComponent.files1().length - 1];
                    
                            checkSI({
                                interfaceName: '品类检核',
                                fielBase64: image.base64.substring(image.base64.indexOf('base64,') + 7),
                            }).then(data => {
                                console.log('images.pop().base64 data' + JSON.stringify(data));
                                if(data){
                                    
                                }else{
                                    this.checkMsg = this.label.Image_Is_Tv;
                                    //this.showError(obj.Product__r.Name + this.label.Image_Is_Tv);
                                    childComponent.handleDeleteFile1(childComponent.files1().length - 1);
                                }
                            }).catch(error => {
                                console.log('---------->error='+error);
                                this.catchError(JSON.stringify(error));
                                this.isShowSpinner = false;
                            });
                        }
                    });
                }
            }
        });
        console.log('上传图片');
        this.dispatchEvent(new CustomEvent('refreshdata'));
    }

    // 处理模态框关闭事件
    handleAlertClose() {
        this.showAlert = false;
        if (this.deleteChildComponent) {
            this.deleteChildComponent.performAction();
        }
    }

    checkMsg;
    async handleCheckEvent(event) {
        console.log('触发弹窗方法');

        if(this.checkMsg != ''){
            this.showAlert = true;
            this.alertTitle = '';
            this.alertMessage = this.checkMsg;
            this.iconType = 'info';
        }else{
            this.handleAlertClose();
        }

        // this.modalType
        // this.handleShow(this.checkMsg, 'deleteImg', '');
    }

    handleChangePLOption(event) {
        var cmps = this.template.querySelectorAll('c-lookup-lwc');
        if (cmps) {
            for (let i = 0; i < cmps.length; i++) {
                if (cmps[i].name=='onProduct') {
                    cmps[i].updateOption({
                        'lookup': 'CustomLookupProvider.ProductFilter',
                        'Product_Line__c' : event.detail.value
                    });
                    cmps[i].handleRemove();
                    break;
                } 
            }
        }
    }
handleChangeBrandOption(event) {
if(!this.isFilledOut(event.detail.value)){
    return;
}
this.record.Brand__c = event.detail.value;
this.samplingInspectionsArgentinaShow = [];
if(this.record.Brand__c == 'Hisense'){
    this.argentinaNotHisense = false;
}else{
    this.argentinaNotHisense = true;
    this.samplingInspectionsArgentina.forEach(obj => {
        obj.title = obj.Brand__c + '-' + obj.Product_Line__c;
        if(obj.Brand__c == this.record.Brand__c){
            this.samplingInspectionsArgentinaShow.push(obj);
        }
    });
    if(this.samplingInspectionsArgentinaShow.length == 0){
        this.brandAndProductline[this.record.Brand__c].forEach(obj =>{
            let item = {
                title: this.record.Brand__c + '-' + obj,
                Brand__c: this.record.Brand__c,
                Daily_Inspection_Report__c : this.recordId,
                Product_Line__c : obj,
                Quantity_Of_Exhibits_Total__c: null,
                Placement_Status__c: false,
                POP__c:false,
                ReRe__c: '',
                External_Id__c: this.recordId + '-' + this.record.Brand__c + '-' + obj
            };
            this.samplingInspectionsArgentinaShow.push(item);
            this.samplingInspectionsArgentina.push(item);
        });
    }
}
}
argPlacementStatusChange(event) {
var value = event.target.checked;
var type = event.target.dataset.type;
this.argChange('Placement_Status__c', type, value);
}
argQuantityOfExhibitsTotalChange(event) {
var type = event.target.dataset.type;
var value = event.target.value;  
this.argChange('Quantity_Of_Exhibits_Total__c', type, value);
}
argCommentChange(event) {
var type = event.target.dataset.type;
var value = event.target.value;  
this.argChange('ReRe__c', type, value);
}
argPOPChange(event) {
var type = event.target.dataset.type;
var value = event.target.value;  
this.argChange('Is_POP__c', type, value);
}
argChange(fieldName, type, value){
this.samplingInspectionsArgentina.forEach(obj => {
    if (this.record.Brand__c == obj.Brand__c && type == obj.Product_Line__c) {
        obj[fieldName] = value;
    }
});
this.samplingInspectionsArgentinaShow.forEach(obj => {
    if (this.record.Brand__c == obj.Brand__c && type == obj.Product_Line__c) {
        obj[fieldName] = value;
    }
});
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
                hasEdit : this.hasEdit
            }
        })
    );
    }

    siDisplayChange(event) {
        var resultindex = Number(event.target.dataset.resultindex);
        var index = Number(event.target.dataset.index);
        var id = event.target.dataset.id;

        // var type = event.target.dataset.type;
        var check = event.detail.value;
        var type = event.target.dataset.t;
        console.log('WWWINDEX'+ index + ',' + resultindex + ',' + check + ',' + type + 'id:' + JSON.stringify(id)) ;

        let multipleSelection = [];

        // 获取当前是否为选中状态
        this.template.querySelectorAll('[data-id="'+ id +'"]').forEach(item => {
            if(item.checked){
                // 设置多选值
                multipleSelection.push(item.value);
            }
        });
        // this.treeData[index].parent.Response__c = multipleSelection.join(',');

        console.log('wwwwmultipleSelection' + JSON.stringify(multipleSelection.join(';')));

        var siId;
        if (type == 'PlanIn') {
            console.log('PlanIn'+this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index]);
            this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Display_Type__c = multipleSelection.join(';');
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
        } else {
            this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Display_Type__c = multipleSelection.join(';');    
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;   
        }

        this.samplingInspections.forEach(obj => {
            if (obj.Id == siId) {
                obj.Display_Type__c = multipleSelection.join(';');
            }
        });

        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : this.hasEdit
                }
            })
        );
    }
    siCheckPriceChange(event) {
        var resultindex = Number(event.target.dataset.resultindex);
        var index = Number(event.target.dataset.index);

        // var type = event.target.dataset.type;
        var check = event.detail.value;
        var type = event.target.dataset.t;
        console.log('WWWINDEX'+ index + ',' + resultindex + ',' + check + ',' + type) ;

        // TODO 根据确认价格问题是否相同判断是否展示 YYL 20250119 后续废除
        let isPriceYes = false;
        if(check == 'No'){
            isPriceYes = true;
        }

        var siId;
        if (type == 'PlanIn') {
            console.log('PlanIn'+this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index]);
            this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Is_Check_Price__c = check;
            this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].IsPriceYes = isPriceYes;
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
        } else {
            this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Is_Check_Price__c = check;   
            this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].IsPriceYes = isPriceYes;   
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;   
        }

        this.samplingInspections.forEach(obj => {
            if (obj.Id == siId) {
                obj.Is_Check_Price__c = check;
            }
        });

        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : this.hasEdit
                }
            })
        );
    }

    siOptimalChange(event) {
        var resultindex = Number(event.target.dataset.resultindex);
        var index = Number(event.target.dataset.index);

        // var type = event.target.dataset.type;
        var check = event.detail.value;
        var type = event.target.dataset.t;
        console.log('WWWINDEX'+ index + ',' + resultindex + ',' + check + ',' + type) ;

        let isOptimalYes = false;
        if(check == 'No'){
            isOptimalYes = true;
        }

        var siId;
        if (type == 'PlanIn') {
            console.log('PlanIn'+this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index]);
            this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Is_Optimal__c = check;
            this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].isOptimalYes = isOptimalYes;
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
        } else {
            this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Is_Optimal__c = check;   
            this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].isOptimalYes = isOptimalYes;   
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;   
        }

        this.samplingInspections.forEach(obj => {
            if (obj.Id == siId) {
                obj.Is_Optimal__c = check;
            }
        });

        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : this.hasEdit
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
                    hasEdit : this.hasEdit
                }
            })
        ); 
    }

siDisplayStatusChange(event) {
this.samplingInspectionChange(event, 'Display_Stand__c', true);
this.dispatchEvent(new CustomEvent(
    "select", {
        detail: {
            hasEdit : this.hasEdit
        }
    })
);
}
siPriceChange(event) {
var check = event.detail.value;
this.samplingInspectionChange(event, 'Price__c', false);
this.dispatchEvent(new CustomEvent(
    "select", {
        detail: {
            hasEdit : this.hasEdit
        }
    })
); 
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

async handleSamplingInspectionDelete(event) {
var resultindex = Number(event.target.dataset.resultindex);
var index = Number(event.target.dataset.index);
var samplingId = event.target.dataset.id;
var productName = event.target.dataset.name;
var displayType = event.target.dataset.fieldDisplaytype;

console.log('WWWeven参数' + JSON.stringify(event.target.dataset));

    // 保存 check result
    let eles = this.template.querySelectorAll('c-new-sampling-inspection-lwc4');
    if(eles){
        for (let index = 0; eles && index < eles.length; index++) {
            let ele = eles[index];
            ele.handleSaveBackstage();
        }   
    }

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
                if (data.data.checkResults) {
                    this.checkResults = this.checkCheckResults(data.data.checkResults);
                }
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

                var param = [];
                for (let i = 0; i < newcheckResultsInfo.length; i++){
                    param.push(newcheckResultsInfo[i].displayType);
                }
                console.log('WWW打印测试' + JSON.stringify(param));
                console.log('WWW打印测试' + JSON.stringify(this.detailDisplayInfo));
                console.log('WWW打印测试' + JSON.stringify(this.productLineDisplayInfo));
                console.log('WWW打印测试' + JSON.stringify(this.detailDisplayInfo.length));
                console.log('WWW打印测试' + JSON.stringify(this.productLineDisplayInfo.length));

                // 获取集合 B 中的所有 value
                let BValues;
                if(this.detailDisplayInfo.length > 0) {
                    BValues = this.detailDisplayInfo.map(item => item.value);
                } else {
                    BValues = this.productLineDisplayInfo.map(item => item.value);
                }
                // BValues = this.productLineDisplayInfo.map(item => item.value);

                // 过滤出集合 B 中不在集合 A 中的值
                const unmatched = BValues.filter(value => !param.includes(value));

                // 输出未匹配到的值
                console.log('wwwwwww强请' + unmatched);
    
                console.log('wwwwwww强请' + unmatched.length);
                // for(let i = 0; i < unmatched.length; i++){
                //     var item = {
                //         //巡店员日报日语翻译  BY lizunxing 20231020
                //         displayType: unmatched[i],
                //         productLine: this.productLine,
                //         productLineName: this.productLine,
                //         productLookup: {
                //             'lookup' : 'CustomLookupProvider.ProductFilter',
                //             // 'Product_Line__c' : checkResultsInfo[0].displayType
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
                if(this.checkResultsInfo.length == 0){
                    var item = {
                        //巡店员日报日语翻译  BY lizunxing 20231020
                        productLine: this.productLine,
                        productLineName: this.productLine,
                        productLookup: {
                            'lookup' : 'CustomLookupProvider.ProductFilter',
                            // 'Product_Line__c' : checkResultsInfo[0].displayType
                            'Product_Line__c' : this.productLine

                        },
                        samplingInspection: true,
                        samplingInspectionPlanIn: [],
                        samplingInspectionPlanOut: [],
                        productLineItem: [],
                    };
                    // console.log('WWWWWITEM' + JSON.stringify(item));
                    this.checkResultsInfo.push(item);
                }
                console.log('删除后参数' + JSON.stringify(this.checkResultsInfo));
                this.isShowSpinner = false;
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
            this.dispatchEvent(new CustomEvent('refreshdata'));
        }).catch(error => {
            console.log('-----www----->error='+error);
            this.catchError(JSON.stringify(error));
            this.isShowSpinner = false;
        });
    }else {
        // todo 选cancel逻辑
        console.log('wwww---选cancel逻辑----' + index);
    }
}

// 选择的ProductId
selectedProductId;
getSelectedProductId(resp) {
if (resp.detail.selectedRecord==undefined) {
    this.selectedProductId = null;
} else {
    this.selectedProductId = resp.detail.selectedRecord.Id;
}
}
// 添加计划外出样
addProductByLine() {
// 判断Product是否为空
if (this.selectedProductId==null) {
    // this.showError('No product selected');
    this.showError(this.label.INSPECTION_REPORT_MSG_NO_PRODUCT_SELECTED);
    return;
}
// 判断是否已存在产品
for (let i = 0; i < this.samplingInspections.length; i++) {
    var item = this.samplingInspections[i];
    if (item.Product__c==this.selectedProductId) {
        // this.showError('Product already exists');
        this.showError(this.label.INSPECTION_REPORT_MSG_PRODUCT_EXISTS);
        return;
    }
}
this.isShowSpinner = true;
console.log('WWWVVBBB===>');
samplingInspectionAdd({
    recordJson: JSON.stringify(this.record),
    productId: this.selectedProductId
}).then(data => {
    if (data.isSuccess) {
        for (let key in data.data) {
            this[key] = data.data[key];
        }
        // Deloitte Yin Mingjie 20231114 start
        if (data.data.checkResults) {
            this.checkResults = this.checkCheckResults(data.data.checkResults);
        }
        // Deloitte Yin Mingjie 20231114 end
        // 只需要整理刷新check list 信息
        this.checkResultsInfoDataFormat(data);
        // 添加新增数据
        var newitem = data.data.newSamplingInspection;
        newitem['index'] = this.siSelectedProductlinePlanOut.length+1;
            newitem['showDetail'] = false;
            newitem['isCheckedInfo'] = '';
        // }
        this.siSelectedProductlinePlanOut.push(newitem);
        
        this.isShowSpinner = false;
    } else {
        this.isShowSpinner = false;
        this.showError(data.message);
    }
}).catch(error => {
    console.log('---------->error='+error);
    this.catchError(JSON.stringify(error));
    this.isShowSpinner = false;
});
}
handleSamplingInspectionBack() {
this.samplingInspectionPage = false;
this.siSelectedProductline = [];
this.siSelectedProductlinePlanOut = [];
this.samplingInspectionProductline = '';

this.selectedProductId = null;
}
/**
 * 自定义相机页面
 */
@track capturePage = false;
capturePageInitialization() {
this.capturePage = true;
}
// Deloitte Yin Mingjie 20231113 start
height;
get styleContent() {
    return true ? 'max-height: ' + this.height + 'px;' : '';
}
start() {
    var titleDoc = this.template.querySelector('.slds-modal__header');
    if (titleDoc) {
        var titleHeight = titleDoc.offsetHeight;
        this.height = document.documentElement.clientHeight - titleHeight;
    }
}
// Deloitte Yin Mingjie 20231113 end
// Deloitte Yin Mingjie 20231114 start
@track isShowBody = true;
checkCheckResults(checkResults) {
var returnCrs = {};
for (let i = 0; i < Object.keys(checkResults).length; i++) {
    var productLine = checkResults[Object.keys(checkResults)[i]];
    var map_1 = {};
    for (let j = 0; j < Object.keys(productLine).length; j++) {
        var results = productLine[Object.keys(productLine)[j]];
        var list_1 = [];
        for (let k = 0; k < results.length; k++) {
            var result = results[k];
            if (result.CheckItem__c) {
                list_1.push(result);
            } else {
                this.showError(this.label.INSPECTION_REPORT_MSG_CHECKITEM_LOST.format(results.Id));
                this.isTitleShowButton = false;
                this.isShowBody = false;
            }
        }
        if (list_1) {
            map_1[Object.keys(productLine)[j]] = list_1;
        }
    }
    if (map_1) {
        returnCrs[Object.keys(checkResults)[i]] = map_1;
    }
}
return returnCrs;
}

handleComments(event){
let inspectComments = event.detail.value;
this.record.Comments__c = inspectComments;
}
handleContactType(event){
let contactType = event.detail.value;
this.record.Contact_Type__c = contactType;
}
handleContactPerson(event){
let contactPerson = event.detail.value;
this.record.Contact_Person__c = contactPerson;
}
handleContactStatus(event){
let ContactStatus = event.detail.value;
this.record.Contact_Status__c = ContactStatus;
}
captureCompress = true;
showCapture = false;
handleCaptureComplete(event) {
if (event.detail.isSuccess) {
    this.attendancePhotoStream = event.detail.data.base64;
    this.attendanceShowPhoto = true;
    this.attendanceFromType = 'From Photo';
    this.isFromPhoto = true;
}
this.showAllFun();
}
showAllFun(){
this.showCapture = false;
var tmp = this.template.querySelector('.slds-is-relative');
if (tmp) {
    tmp.classList.remove('slds-hide');
    tmp.classList.add('slds-show');
}
}
hideAllFun(){
this.showCapture = true;
var tmp = this.template.querySelector('.slds-is-relative');
if (tmp) {
    tmp.classList.remove('slds-show');
    tmp.classList.add('slds-hide');
}
}

handleCloseItemIssues() {
this.showCheckItemIssues = false;
this.showAllPage  = true;
this.activeSections = [];
}

isFilledOut(content) {
if (typeof content == "undefined") {return false;
} else if (content == '' || content == null) {return false;
} else if (typeof content == "number") {return !isNaN(content);}
return true;
}
deleteProductValue(event){
let index = event.target.dataset.index;
if(this.isFilledOut(this.ticketOpenInfo[index].Product__c)){
    if(this.ticketOpenInfo[index].Product__c.lastIndexOf(',') != -1){
        this.ticketOpenInfo[index].Product__c = this.ticketOpenInfo[index].Product__c.substr(0, this.ticketOpenInfo[index].Product__c.lastIndexOf(','));
    }else{this.ticketOpenInfo[index].Product__c = '';}
}
}
// 选择产品变更

addCompetitorsInformation(event) {
this.template.querySelector('c-new-competitors-information-lwc').addCompetitorsInformation();
}

competitorsInformationCheck() {
let ele = this.template.querySelector('c-new-competitors-information-lwc');
if(ele == null || ele == ''){
    return '';
}else{
    return ele.checkData();
}
}

saveCompetitorsInformationts(event) {
if (this.template.querySelector('c-new-competitors-information-lwc')!=null) {
    this.template.querySelector('c-new-competitors-information-lwc').saveData();
} 
}

@api versionIdField;
@api contentBodyIdField;
// @api publicLinkField;
@api fileTypeField;
@api fileType;
@api versionId;
@api contentBodyId;
@api isImgManagement;
@track isDelShow = false;
@track isShowEditViewCus = false;
imageUrl = '';
@track isShowSpinner = false;
@track docment_id = '';
isUpdate = false;
Store_Pic_Tip = Store_Pic_Tip;
Store_Pic_Head = Store_Pic_Head;
get acceptedFormats() {
    return ['.jpg', '.png','.jpge','.bmp'];
}
deleteClick(){
    this.isShowSpinner = true
    if (this.versionId!='' && this.contentBodyId!='' && this.fileType!='') {
        delObject({
            id : this.shopId,
            versionIdField : this.versionIdField,
            contentBodyIdField : this.contentBodyIdField,
            fileTypeField : this.fileTypeField,
            contentVersionId : this.versionId,
        }).then(result => {
            console.log('result:'+JSON.stringify(result));
            if (result.isSuccess) {
                this.showSuccess('success');
                this.refreshRecords(this.shopId);
                this.goToRecord(this.shopId);
            }else{
                this.showError(result.message);
                this.isShowSpinner = false
            }
            
        }).catch(error => {
            this.showError('系统发送错误：'+JSON.stringify(error));
        });
    }
}
handleUploadFinishedS(event) {
    // Get the list of uploaded files
    const uploadedFiles = event.detail.files;
    this.docment_id = uploadedFiles[0].documentId;
    console.log('uploadedFiles:'+JSON.stringify(uploadedFiles));
    console.log('No. of files uploaded : ' + uploadedFiles.length);
    console.log('this.versionId==='+this.versionId);
    this.isUpdate = (this.versionId != '' && this.versionId != null && this.versionId != undefined) ? true : false;
    if (uploadedFiles.length==1) {
        saveObject({
            id : this.shopId,
            // id : 'a269D000000mKjVQAU',
            versionIdField : 'PlanogramsVersionId__c',
            contentBodyIdField : 'PlanogramsContentBodyId__c',
            fileTypeField : 'PlanogramsFileType__c',
            documentId : uploadedFiles[0].documentId,
            contentVersionId : uploadedFiles[0].contentVersionId,
            contentBodyId : uploadedFiles[0].contentBodyId,
            name : uploadedFiles[0].name,
            isUpdate : this.isUpdate
        }).then(result => {
            if (result.isSuccess) {
                this.versionId = uploadedFiles[0].contentVersionId;
                console.log('WWW--图片参数' + JSON.stringify(uploadedFiles[0]));
                this.getShopInfo();
                this.showSuccess('success');
            }else{
                this.showError(result.message);
            }
        }).catch(error => {
            this.showError('系统发送错误：'+JSON.stringify(error));
        });
    }else{
        this.showError('只能上传一张图片！');
    }
    
}
cancelClick(event) {
    this.goToRecord(this.shopId);
}
preview() {
    if (this.versionId == null || this.versionId == '' || this.versionId == undefined) return;
    getPicMsg({contentVersionId : this.versionId }).then(res=>{
        if (res.isSuccess) {
            this.filePreview(res.data.documentId);
        }else{
            this.showError('系统发送错误：'+res.message);
        }
    }).catch(error=>{
        this.showError('系统发送错误：'+JSON.stringify(error));
    })
}
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
    //salesRegion 判断
    @track Candada = false;

    get acceptedFormats() {
        return ['.jpg','.jpeg','.png','.bmp','.pjpeg'];
    }
    connectedCallback() {
        console.log('wfc222---productLine--' + this.productLine);
        console.log('wfc222---recordId--' + this.recordId);// Inspection_Product_Item__c
        console.log('wfc222---inspectionId--' + this.inspectionId);// Daily_Inspection_Report__c
        console.log('wfc222---recordItemId--' + this.recordItemId);
        console.log('wfc222---storeId--' + this.storeId);
        console.log('wfc222---status--' + this.status);
        console.log('wfc222---submit--' + this.submit);
        // loadStyle(this, common3).then(()=>{}).catch((error) => {});

        // loadStyle(this, uploadFiles).then(()=>{
        //     this.start();
        // }).catch((error) => {
            
        // });

        // judgeCountry().then(data => {
        //     if (data.isSuccess) {
        //         if(data.data.Canada) {this.Candada = data.data.Canada;}
        //     } else {this.isShowSpinner = false;this.showError(data.message);}
        // }).catch(error => {
        //     this.isShowSpinner = false;this.catchError(error);
        // })
        // this.getShopInfo();
        // this.getPictureList();
        // this.wiredResult;
        // this.submit = true;
        this.handleCreate();
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

    @track paramId;
    
    getShopInfo(){
        getShopInfo({
            shopId: this.shopId
            // shopId: 'a269D000000mKjVQAU'
        }).then(data => {
                var PlanogramsContentBodyId__c = data[0].PlanogramsContentBodyId__c;
                var PlanogramsVersionId__c = data[0].PlanogramsVersionId__c;                
                var SRCO = '/sfc/servlet.shepherd/version/renditionDownload?rendition=thumb240by180&versionId='+ PlanogramsVersionId__c +'&operationContext=CHATTER&contentId='+ PlanogramsContentBodyId__c;
                // LINKO = '/lightning/cmp/c__lwcWrapper?c__lwcName=uploadStorePicturesLWC&c__versionId='+ PlanogramsVersionId__c +'&c__fileType='+ PlanogramsFileType__c +'&c__contentBodyId='+ PlanogramsContentBodyId__c +'&c__recordId='+ shopId +'&c__versionIdField=PlanogramsVersionId__c&c__contentBodyIdField=PlanogramsContentBodyId__c&c__fileTypeField=PlanogramsFileType__c&c__isImgManagement=true';
                // this.SrcO = SRCO;
                const timestamp = new Date().getTime();
                this.tranSRC = `${SRCO}?t=${timestamp}`;
                console.log('handleUploadFinishedS' + this.tranSRC);
                console.log('WWW访问----');
            // } 
        }).catch(error => {
             
        });
    }

    handleImgLoadError(event) {
        console.log('wwww---图片加载失败');
        this.getShopInfo();
    }

    // 点击小图片，放大
    handleViewPhotoClick(ele) {
        this.showPicture = true;
        this.shopPictureSrc = ele.target.dataset.show;
        this.shopPictureId = ele.target.dataset.id;
        this.filePreview(ele.target.dataset.id);
    }
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

    handleBack(){
        this.dispatchEvent(new CustomEvent('refreshdata'));
        this.dispatchEvent(new CustomEvent('goback'));
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
        const childComponent = event.target;
        const result = await LightningConfirm.open({
            message: Inspection_Delete_Picture,
            variant: 'headerless',
            label: 'this is the aria-label value',
        });

        if (result) {
            // 如果用户点击了确认，派发一个事件给子组件
            // const childComponent = this.template.querySelector('c-upload-files3-lwc');
            // if (childComponent) {
            //     childComponent.performAction();
            // }

            if (childComponent.performAction) {
                childComponent.performAction();
            }
        }
    }

    handleUploadFinished(event){
        const uploadedFiles = event.detail.files;
        var resultindex = Number(event.target.dataset.resultindex);
        var index = Number(event.target.dataset.index);

        // var type = event.target.dataset.type;
        var type = event.target.dataset.t;
        console.log('documentId'+ uploadedFiles[0].documentId) ;
        console.log('contentVersionId'+ uploadedFiles[0].contentVersionId) ;
        var value = '';

        var siId;
        if (type == 'PlanIn') {
            var imgUrl = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Before_Img__c;
            if(imgUrl){
                value = imgUrl + ';' + uploadedFiles[0].documentId;
            }else{
                value = uploadedFiles[0].documentId;
            }
            console.log('PlanIn'+this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index]);
            this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Before_Img__c = value;
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
        } else {
            var imgUrl = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Before_Img__c;
            if(imgUrl){
                value = imgUrl + ';' + uploadedFiles[0].documentId;
            }else{
                value = uploadedFiles[0].documentId;
            }
            this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Before_Img__c = value;     
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;   
        }

        console.log('wwwwhandleUploadFinished' + siId);
        this.samplingInspections.forEach(obj => {
            if (obj.Id == siId) {
                obj.Before_Img__c = value;
            }
        });

        // 刷新
        // this.checkResultsInfoDataFormat('');

        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : this.hasEdit
                }
            })
        );   
    }  
    
    handleUploadFinishedA(event){
        const uploadedFiles = event.detail.files;
        var resultindex = Number(event.target.dataset.resultindex);
        var index = Number(event.target.dataset.index);

        // var type = event.target.dataset.type;
        var type = event.target.dataset.t;
        console.log('documentId'+ uploadedFiles[0].documentId) ;
        console.log('contentVersionId'+ uploadedFiles[0].contentVersionId);
        
        var value = '';

        var siId;
        if (type == 'PlanIn') {
            var imgUrl = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].After_Img__c;
            if(imgUrl){
                value = imgUrl + ';' + uploadedFiles[0].documentId;
            }else{
                value = uploadedFiles[0].documentId;
            }
            console.log('PlanIn'+this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index]);
            this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].After_Img__c = value;
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
        } else {
            var imgUrl = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].After_Img__c;
            if(imgUrl){
                value = imgUrl + ';' + uploadedFiles[0].documentId;
            }else{
                value = uploadedFiles[0].documentId;
            }
            this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].After_Img__c = value;     
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;   
        }

        console.log('wwwwhandleUploadFinished' + siId);
        this.samplingInspections.forEach(obj => {
            if (obj.Id == siId) {
                obj.After_Img__c = value;
            }
        });

        // 刷新
        // this.checkResultsInfoDataFormat('');

        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : this.hasEdit
                }
            })
        );   
    }  

    preview(event) {
        // Naviagation Service to the show preview
        this.filePreview(event.currentTarget.dataset.id);
    }

    deleteFile(event){
        var resultindex = Number(event.target.dataset.resultindex);
        var index = Number(event.target.dataset.index);

        // var type = event.target.dataset.type;
        var type = event.target.dataset.t;
        var indexImg = event.target.dataset.i;

        var value = '';

        var siId;
        if (type == 'PlanIn') {
            var imgUrl = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].beforeFiles;

            imgUrl.splice(imgUrl[indexImg],1);
            if(imgUrl){
                value = imgUrl.join(';');
            }else{
                value = '';
            }
            console.log('PlanIn'+this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index]);
            this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Before_Img__c = value;
            this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Before_Img__c = value;
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
        } else {
            var imgUrl = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].beforeFiles;

            imgUrl.splice(imgUrl[indexImg],1);
            if(imgUrl){
                value = imgUrl.join(';');
            }else{
                value = '';
            }
            this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Before_Img__c = value;     
            this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Before_Img__c = value;     
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;   
        }

        this.samplingInspections.forEach(obj => {
            if (obj.Id == siId) {
                obj.Before_Img__c = value;
            }
        });

        // 刷新
        // this.checkResultsInfoDataFormat('');

        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : this.hasEdit
                }
            })
        ); 
    }
    deleteFileA(event){
        var resultindex = Number(event.target.dataset.resultindex);
        var index = Number(event.target.dataset.index);

        // var type = event.target.dataset.type;
        var type = event.target.dataset.t;
        var indexImg = event.target.dataset.i;

        var value = '';

        var siId;
        if (type == 'PlanIn') {
            var imgUrl = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].afterFiles;
            imgUrl.splice(imgUrl[indexImg],1);

            if(imgUrl){
                value = imgUrl.join(';');
            }else{
                value = '';
            }
            console.log('PlanIn'+this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index]);
            this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].After_Img__c = value;
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
        } else {
            var imgUrl = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].afterFiles;
            imgUrl.splice(imgUrl[indexImg],1);

            if(imgUrl){
                value = imgUrl.join(';');
            }else{
                value = '';
            }
            this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].After_Img__c = value;     
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;   
        }

        this.samplingInspections.forEach(obj => {
            if (obj.Id == siId) {
                obj.After_Img__c = value;
            }
        });

        // 刷新
        // this.checkResultsInfoDataFormat('');

        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : this.hasEdit
                }
            })
        ); 
    }

    dropDownStyle;
    handleHeightChange(event) {
        const showList = event.detail;
        console.log('wwwwwww显示子组件的下拉框:----', showList);
        const container = this.template.querySelector(".searchBoxWrapper");
        // 根据新高度调整布局
        if(showList){
            this.dropDownStyle = "top: 100% !important; bottom: auto !important;margin: 0;";
            container.classList.add('highlight');
            container.classList.remove('lowheight');
        }else {
            this.dropDownStyle = "bottom: 100% !important; top: auto !important;margin: 0;";
            container.classList.add('lowheight');
            container.classList.remove('highlight');
        }
    }

    @track hasEdit;
    handleHasEdit(event){
        let hasEdit = event.detail.hasEdit;
        this.hasEdit = hasEdit;
        console.log('wwwww----hasEdit1---c/approvalRequestsLwc' + this.hasEdit);
        // 返回父级元素页面
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : hasEdit,
                }
            })
        );
        
    }
    
}