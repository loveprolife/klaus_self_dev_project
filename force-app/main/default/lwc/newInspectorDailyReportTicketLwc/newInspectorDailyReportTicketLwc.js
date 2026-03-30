import { track, api, wire } from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import common3 from '@salesforce/resourceUrl/common3';
import Id from '@salesforce/user/Id';
import getPickList from '@salesforce/apex/NewSamplingAndTicketController.getPickList';
import LightningConfirm from 'lightning/confirm';
import getRewriteInitData from '@salesforce/apex/NewSamplingAndTicketController.getRewriteInitData';
import refreshData from '@salesforce/apex/NewSamplingAndTicketController.refreshData';
import upsertRecord from '@salesforce/apex/NewSamplingAndTicketController.upsertRecord';
import delProductLine from '@salesforce/apex/NewSamplingAndTicketController.delProductLine';
import upsertProductLineStatus from '@salesforce/apex/NewInspectionDailyReportPageController.upsertProductLineStatus';
import INSPECTION_REPORT_TITLE from '@salesforce/label/c.INSPECTION_REPORT_TITLE';
import INSPECTION_REPORT_NEW from '@salesforce/label/c.INSPECTION_REPORT_NEW';
import INSPECTION_REPORT_SAVE from '@salesforce/label/c.INSPECTION_REPORT_SAVE';
import INSPECTION_REPORT_SUBMIT from '@salesforce/label/c.INSPECTION_REPORT_SUBMIT';
import INSPECTION_REPORT_EDIT from '@salesforce/label/c.INSPECTION_REPORT_EDIT';
import INSPECTION_REPORT_CHECK_IN from '@salesforce/label/c.INSPECTION_REPORT_CHECK_IN';
import INSPECTION_REPORT_CHECK_OUT from '@salesforce/label/c.INSPECTION_REPORT_CHECK_OUT';
import INSPECTION_REPORT_DISTANCE from '@salesforce/label/c.INSPECTION_REPORT_DISTANCE';
import INSPECTION_REPORT_FLOORWALKER from '@salesforce/label/c.INSPECTION_REPORT_FLOORWALKER';
import INSPECTION_REPORT_ATTACHMENT from '@salesforce/label/c.INSPECTION_REPORT_ATTACHMENT';
import INSPECTION_REPORT_UNSCHEDULED from '@salesforce/label/c.INSPECTION_REPORT_UNSCHEDULED';
import INSPECTION_REPORT_ACTION from '@salesforce/label/c.INSPECTION_REPORT_ACTION';
import INSPECTION_REPORT_INFORMATION from '@salesforce/label/c.INSPECTION_REPORT_INFORMATION';
import INSPECTION_REPORT_GENERAL from '@salesforce/label/c.INSPECTION_REPORT_GENERAL';
import INSPECTION_REPORT_TICKET_NEW from '@salesforce/label/c.INSPECTION_REPORT_TICKET_NEW';
import INSPECTION_REPORT_TICKET_HISTORY from '@salesforce/label/c.INSPECTION_REPORT_TICKET_HISTORY';
import INSPECTION_REPORT_CHECK_ITEM_ISSUES from '@salesforce/label/c.INSPECTION_REPORT_CHECK_ITEM_ISSUES';
import INSPECTION_REPORT_PLACEMENT_STATUS from '@salesforce/label/c.INSPECTION_REPORT_PLACEMENT_STATUS';
import INSPECTION_REPORT_MSG_FUTURE_DATE from '@salesforce/label/c.INSPECTION_REPORT_MSG_FUTURE_DATE';
import INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION from '@salesforce/label/c.INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION';
import INSPECTION_REPORT_PLEASE_PHONE from '@salesforce/label/c.INSPECTION_REPORT_PLEASE_PHONE';
import INSPECTION_REPORT_MSG_REQUIRED from '@salesforce/label/c.INSPECTION_REPORT_MSG_REQUIRED';
import INSPECTION_REPORT_MSG_MILEAGE from '@salesforce/label/c.INSPECTION_REPORT_MSG_MILEAGE';
import INSPECTION_REPORT_MSG_CANNOT_BLANK from '@salesforce/label/c.INSPECTION_REPORT_MSG_CANNOT_BLANK';
import INSPECTION_REPORT_MSG_UNPLANNED_STORE from '@salesforce/label/c.INSPECTION_REPORT_MSG_UNPLANNED_STORE';
import INSPECTION_REPORT_MSG_NO_PRODUCT_SELECTED from '@salesforce/label/c.INSPECTION_REPORT_MSG_NO_PRODUCT_SELECTED';
import INSPECTION_REPORT_MSG_PRODUCT_EXISTS from '@salesforce/label/c.INSPECTION_REPORT_MSG_PRODUCT_EXISTS';
import INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE from '@salesforce/label/c.INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE';
import INSPECTION_REPORT_MSG_SUBMIT_REPORT from '@salesforce/label/c.INSPECTION_REPORT_MSG_SUBMIT_REPORT';
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
import INSPECTION_REPORT_Competitors_Information from '@salesforce/label/c.INSPECTION_REPORT_Competitors_Information';
import INSPECTION_REPORT_Display_Status from '@salesforce/label/c.INSPECTION_REPORT_Display_Status';
import INSPECTION_REPORT_Display_Stand from '@salesforce/label/c.INSPECTION_REPORT_Display_Stand';
import INSPECTION_REPORT_BACK from '@salesforce/label/c.INSPECTION_REPORT_BACK';
export default class NewInspectorDailyReportLwc extends LightningNavigationElement {
lwcName = 'newInspectorDailyReportTicketLwc';
label = {
INSPECTION_REPORT_TITLE,            // Title 检查报告
INSPECTION_REPORT_NEW,              // 新建
INSPECTION_REPORT_SAVE,             // 保存
INSPECTION_REPORT_SUBMIT,           // 提交
INSPECTION_REPORT_EDIT,             // 修改
INSPECTION_REPORT_CHECK_IN,         // 签到
INSPECTION_REPORT_CHECK_OUT,        // 签退
INSPECTION_REPORT_DISTANCE,         // 距离
INSPECTION_REPORT_FLOORWALKER,      // 巡店员
INSPECTION_REPORT_ATTACHMENT,       // 附件
INSPECTION_REPORT_UNSCHEDULED,      // 计划外
INSPECTION_REPORT_ACTION,           // 操作
INSPECTION_REPORT_INFORMATION,      // 信息
INSPECTION_REPORT_GENERAL,          // 通用清单
INSPECTION_REPORT_TICKET_NEW,       // 新增（当前日期）
INSPECTION_REPORT_TICKET_HISTORY,   // 历史记录
INSPECTION_REPORT_CHECK_ITEM_ISSUES,// 历史检查项问题
INSPECTION_REPORT_PLACEMENT_STATUS, // 是否出样
INSPECTION_REPORT_MSG_FUTURE_DATE,              // 无法为此记录选择未来日期
INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION,   // 当前设备不支持定位功能
INSPECTION_REPORT_PLEASE_PHONE,                 // 打卡失败，请上传照片
INSPECTION_REPORT_MSG_REQUIRED,                 // 未维护所需信息。请先填写所需信息
INSPECTION_REPORT_MSG_MILEAGE,                  // 结束里程不能小于开始里程
INSPECTION_REPORT_MSG_CANNOT_BLANK,             // 摘要不能为空
INSPECTION_REPORT_MSG_UNPLANNED_STORE,          // 门店为计划外门店，确定要新建此日报
INSPECTION_REPORT_MSG_NO_PRODUCT_SELECTED,      // 没有选择产品
INSPECTION_REPORT_MSG_PRODUCT_EXISTS,           // 产品已存在
INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE,     // {0}将被删除
INSPECTION_REPORT_MSG_SUBMIT_REPORT,            // 是否提交当前日报
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
INSPECTION_REPORT_Competitors_Information,
INSPECTION_REPORT_Display_Status,
INSPECTION_REPORT_Display_Stand,
INSPECTION_REPORT_BACK,
};
lwcName = this.label.INSPECTION_REPORT_TITLE;

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
/**初始化 Ticket 标签*/
@track TicketInfo = {
    Name: '',
    InspectionReport__c: '',
    ClosedDailyInspectionReport__c: '',
    Subject__c: '',
    Status__c: '',
    Priority__c: '',
    DueDate__c: '',
    Description__c: '',
    AssignedTo__c: '',
    Department__c: '', // added by Sunny about chile department -[20231026]
    Category__c: '', 
    SeriesNum__c: '',     
    Product__c: ''
};
@wire(getObjectInfo, {objectApiName : 'Ticket__c'})
wiredTicketInfo({ error, data }) {
if (data) {
    this.TicketInfo = {
        Name: data.fields.Name.label,
        InspectionReport__c: data.fields.InspectionReport__c.label,
        ClosedDailyInspectionReport__c: data.fields.ClosedDailyInspectionReport__c.label,
        Subject__c: data.fields.Subject__c.label,
        Status__c: data.fields.Status__c.label,
        Priority__c: data.fields.Priority__c.label,
        DueDate__c: data.fields.DueDate__c.label,
        Description__c: data.fields.Description__c.label,
        AssignedTo__c: data.fields.AssignedTo__c.label,
        Department__c: data.fields.Department__c.label,     // added by Sunny about chile department -[20231026]
        Category__c: data.fields.Category__c.label, 
        SeriesNum__c: data.fields.SeriesNum__c.label, 
        Product__c: data.fields.Product__c.label
    };
} else if (error) {
    this.showError('Ticket__c getInformation error');
}
}
/**初始化 Ticket Confirm Task Value List*/
@wire(getPickList, {objectName : 'Ticket__c', fieldName : 'Status__c'})
confirmTaskOptions;
@wire(getPickList, {objectName : 'Ticket__c', fieldName : 'Priority__c'})
priorityTaskOptions;
@wire(getPickList, {objectName : 'Ticket__c', fieldName : 'Category__c'})
CategoryTaskOptions;
/**初始化 Product Product line Value List*/
@wire(getPickList, {objectName : 'Product__c', fieldName : 'Product_Line__c'})
productLineOptions;
@track showAllPage = true;
// 打卡地图相关
// Data相关
@api recordId;
@api storeId;
@api productLine;
@api reportDate;
@track isReportUser = true;                 // 是否为日报所有人
@track ownerName;                           // 所有人名
@track userId = Id;
@track record = {};                         // 日报主数据信息
@track storeDistanceList = [];              // 门店信息
@track attendanceInformationCheckOutHandHelper = {};
@track checkResults = {};                   // 试卷信息
@track checkResultsInfo = [];               // 试卷信息（整理后）
@track checkResultsIsRelatedToProduct = [];                   // 试卷信息-出样
@track ticketClosedInfo = [];               // 历史ticket
@track ticketOpenInfo = [];                 // 新建ticket
@track ticketOpenFilesMap = {};             // ticket附件Map
@track samplingInspections = [];            // 出样检查
@track mileageRecord = {};                  // 巡店里程
@track inspectTypeOptions = {};
@track inspectStatusOptions = {};
@track selectedProductValue;                // 搜索产品Id 
@track selectedProductInfo = {};            // 产品详细信息 
@track selectedProductInfoIsShow = false;   // 显示产品详细信息 
// Page相关
@track isShowSpinner = false;               // 加载中
@track oldReportDate;                       // 旧日期
@track oldReportDateShow = true;            // 切换日期显示
@track isFieldReadOnly = true;              // 字段只读
@track isTitleShowButton = false;           // 显示title按钮
@track isEditPage = false;                  // 显示编辑页面
@track language;    
@api submit;
@api status;                        
get isViewPage() {
    if (this.isEditPage) {
        return false;
    } else {
        return true;
    }
};
// Tab相关
@track activeSections = [];
@track activeTicketSections = [];
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
//根据国家隐藏-Lay add
@track isShowMileage = true;
@track isShowTotalScore = true;
@track isShowAverageScore = true;
// added by Sunny about chile department start-[20231026]
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
@track statusLabel = this.label.INSPECTION_REPORT_NEW;
//阿根廷使用
@track isArgentina = false;
@track argentinaNotHisense = false;
@track isTv = false;
@track brandAndProductline = {};
@track samplingInspectionsArgentina = [];
@track samplingInspectionsArgentinaShow = [];
@track brandOptions = [];
@track ticketAssignedTo = '';
@track searchProductByProductLineOption = [];
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
get uploadDivStyle() {
if (this.isEditPage) { return '' } 
else { return 'pointer-events: none;'; }
}

// 门店只读
get isTitleReadOnly() {
return false;
}
// 日报日期对比当前日期
get reportDateIsToday() {
var recordDate = new Date(this.record.Report_Date__c);
var today = new Date(this.todayDate);
if (today>recordDate) {
    return false;
} else {
    return true;
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
if (this.record.Status__c == 'Submitted') {
    return true;
} else {
    return false;
}
}

// 自定义弹框
@track modalMsg;
@track modalType;
@track modalHelper;
handleShow(msg, type, hepler) {
let ele = this.template.querySelector('c-modal-lwc');
console.log('ELE' + JSON.stringify(ele));
console.log('MESSAGE' + msg + ',' + type + ',' + hepler);
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
this[this.modalType](this.modalHelper);
}
// 测试用
handletestbutton() {
let ele = this.template.querySelector('c-modal-lwc');
ele.showModal(this);
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

renderedCallback(){
    this.start();
}
// 初始化
connectedCallback() {
    this.start();
    loadStyle(this, common3).then(()=>{}).catch((error) => {});
    // judgeCountry().then(data => {
    //     if (data.isSuccess) {
    //         if(data.data.SouthAfrica){
    //             this.isSouthAfrica = true;
    //         }
    //     }
    // }).catch(error => {
    //     this.isShowSpinner = false;this.catchError(error);
    // })
    console.log('WWW打印传递参数' + this.submit);
    this.handleCreate();   
}

// ---------------> ↓ Button click ↓ <---------------
// Edit click
handleEdit() {
this.isEditPage = true;
this.isFieldReadOnly = false;
// this.storeLabel = this.shopOptions.find(opt => opt.value === this.record.Store__c).label;
}
    // Save click
    @api
    handleSave() {
        // 检查必填信息
        var checkResp = {alltrue: true, msg: ''};
        // if (this.checkTicket().alltrue == false) {
        //     checkResp = this.checkTicket();
        //     this.lwcName = this.label.PromoterDailyReport_TICKET;
        // }

        // if (checkResp.alltrue == false) {
        //     this.showWarning(this.label.INSPECTION_REPORT_MSG_REQUIRED + checkResp.msg);
        //     this.lwcName = this.label.INSPECTION_REPORT_TITLE;
        //     return;
        // }

        // if(this.competitorsInformationCheck().alltrue == false){
        //     checkResp = this.competitorsInformationCheck();
        //     this.lwcName = this.label.INSPECTION_REPORT_Competitors_Information;
        //     this.showWarning(this.label.INSPECTION_REPORT_MSG_REQUIRED + checkResp.msg);
        //     return;
        // }
        console.log('WWWSAVE之前的传递数据1' + JSON.stringify(this.ticketOpenInfo));
        this.ticketOpenInfo.forEach(obj => {
            if (obj.DueDate__c == '') {
                obj.DueDate__c = null;
                console.log('WWWDueDate' + obj.DueDate__c);
            }
        });
        console.log('WWWSAVE之前的传递数据2' + JSON.stringify(this.ticketOpenInfo));
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
getRewriteInitData({
    // recordId: 'a1aHz000003cKhPIAU',	
        recordId: this.recordId,
        // recordId: this.recordItemId,
        productLine: this.productLine,
        shopId: this.storeId
    //recordId: this.recordId,	
//     recordId: 'a1aHz000003cKm0IAE',
//     productLine: this.productLine,
//     shopId: this.storeId
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

        // 数据格式化
        this.dataFormat(data);
        this.oldReportDate = data.data.record.Report_Date__c;
        
        this.isShowSpinner = false;
    } else {
        this.isShowSpinner = false;
        this.showError(data.message);
    }

}).catch(error => {
    this.catchError(JSON.stringify(error));
    this.isShowSpinner = false;
});
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
// Delete Product Line
deleteProductLine(event) {
var productline = event.target.dataset.productline;
this.handleShow(
    'Product Line '+productline+' will be deleted if you click "Yes"; click "No" to cancel.',
    this.label.INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE.format(this.productInfo.Product_Line__c+' '+productline),
    'deleteProductLineHelper',
    productline);
}
async deleteProductLineHelper(event) {
var productline = event;
this.isShowSpinner = true;
delProductLine({
    recordJson: JSON.stringify(this.record),
    productLine: productline
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

// Add Ticket click
addTicket() {
// 检查必填信息
var checkResp = {alltrue: true, msg: ''};
if (this.checkTicket().alltrue == false) {
    checkResp = this.checkTicket();
    this.lwcName = this.label.PromoterDailyReport_TICKET;
}
if (checkResp.alltrue == false) {
    // this.showError('Required information haven’t been maintained. Please fulfil required information first. - ' + checkResp.msg);
    this.showWarning(this.label.INSPECTION_REPORT_MSG_REQUIRED + checkResp.msg);
    this.lwcName = this.label.INSPECTION_REPORT_TITLE;
    return;
}
// 新增Ticket
var key = this.ticketOpenInfo.length + 1;
var ticket = {
    key: key,
    Subject__c: '',
    Description__c: '',
    Status__c: 'Open',
    DueDate__c: '',
    oldActivityDate: '',
    oldActivityDateShow: false,
    Category__c: '',
    SeriesNum__c: '',
    Product__c: '',
    isShowProduct: false,
    isShowProductSearch: false,
    index: new Date().getTime(),
    needSave: true
};
if(this.isArgentina){
    if(this.ticketAssignedTo != ''){
        ticket.AssignedTo__c = this.ticketAssignedTo;
    }
}
this.ticketOpenInfo.push(ticket)
this.activeTicketSections = ['open'];
this.showSuccess(this.label.PromoterDailyReport_AddNewItemSuccess);

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

// Check Ticket
checkTicket() {
var resp = {alltrue: true, msg: ''};
// added by Sunny 检查结果为满分或-2（不出样） start -[20240507]
let d = new Date();
let systemGenerationDate = d.getFullYear() + '-' + (d.getMonth() + 1) + '-' + (d.getDate() + 7);
let noTicketCheckResultIdList = [];
for(let index=0; index < this.checkResultsIsRelatedToProduct.length; index++) {
    let obj = this.checkResultsIsRelatedToProduct[index];
    console.log('sunny add -> check result: ' + JSON.stringify(obj));
    // 不出样
    if(typeof obj['ProductNotSampled'] != "undefined") { 
        if(obj.ProductNotSampled) {
            noTicketCheckResultIdList.push(obj.Id);

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
    }
    // added by Sunny 自动生成的ticket，结果改为满分或-2（不出样）跳过，无需校验 end -[20240507]
    if (obj.Subject__c=='' || obj.Subject__c==null) {
        resp.alltrue = false;
        resp.msg = this.TicketInfo.Subject__c;
        return resp;
    }
    // 
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

async deleteTicket(event) {
    var index = event.target.dataset.index;
    const result = await LightningConfirm.open({
        message: 'Do you want to delete this ticket?',
        variant: 'headerless',
        label: 'this is the aria-label value',
        // setting theme would have no effect
    });
    if (result) {
        // todo 选ok逻辑
        console.log('wwww---选ok逻辑---' + index);
        var new_list = [];
        for (let i = 0; i < this.ticketOpenInfo.length; i++) {
            if (i!=index) {
                new_list.push(this.ticketOpenInfo[i]);
            }
        }
        for (let i = 0; i < new_list.length; i++) {
            new_list[i].key = i+1;
        }
        this.ticketOpenInfo = new_list;
        console.log('WWW删除Ticket' + JSON.stringify(this.ticketOpenInfo));
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }else {
        // todo 选cancel逻辑
        console.log('wwww---选cancel逻辑----' + index);
    }
}

// Del Ticket click
// deleteTicket(event) {
// console.log('进入删除');
// var index = event.target.dataset.index;
// this.handleShow(
//     // 'Information will be deleted if you click "Yes"; click "No" to cancel.',
//     this.label.INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE.format(this.label.INSPECTION_REPORT_INFORMATION),
//     'deleteTicketHelper',
//     index);
// }
// async deleteTicketHelper(event) {
//     console.log('deleteTicketHelper');
//     var new_list = [];
//     for (let i = 0; i < this.ticketOpenInfo.length; i++) {
//         if (i!=event) {
//             new_list.push(this.ticketOpenInfo[i]);
//         }
//     }
//     for (let i = 0; i < new_list.length; i++) {
//         new_list[i].key = i+1;
//     }
//     this.ticketOpenInfo = new_list;
// }
storeLabel;
// lookup remove
handleRemoveLookup(type, index) {
let alllookup = this.template.querySelectorAll('c-lookup-lwc');
for (let i = 0; i < alllookup.length; i++) {
    var lookup = alllookup[i];
    if (lookup.name==type && (index==null || lookup.getAttribute('data-index')==index)) {
        lookup.handleRemove();
    }
}
}

// Summary字符
handleSummaryChange(event) {
this.record.Summary__c = event.target.value;
this.dispatchEvent(new CustomEvent(
    "select", {
        detail: {
            hasEdit : true
        }
    })
);
}
// Remark字符
handleRemarkInput(event) {
this.attendanceRemark = event.target.value;
}
handleRemarkInputCheckOut(event) {
this.attendanceRemarkCheckOut = event.target.value;
this.noteInfoCheckOut = event.target.value;
}
// Open Ticket SeriesNum
handleTicketSeriesNumChange(event) {
    var index = event.target.dataset.index;
    this.ticketOpenInfo[index].SeriesNum__c = event.target.value;
    this.ticketOpenInfo[index].needSave = true;
    this.dispatchEvent(new CustomEvent(
        "select", {
            detail: {
                hasEdit : true
            }
        })
    );
}
// Open/Closed Ticket Subject
handleTicketConfirmChange(event) {
var index = event.target.dataset.index;
var type = event.target.dataset.type;
if (type=='closed') {
    this.ticketClosedInfo[index].Status__c = event.target.value;
    this.ticketClosedInfo[index].needSave = true;
} else {
    this.ticketOpenInfo[index].Status__c = event.target.value;
    this.ticketOpenInfo[index].needSave = true;
}
this.dispatchEvent(new CustomEvent(
    "select", {
        detail: {
            hasEdit : true
        }
    })
);
}
// Open Ticket Priority
handleTicketPriorityChange(event) {
var index = event.target.dataset.index;
this.ticketOpenInfo[index].Priority__c = event.target.value;
this.ticketOpenInfo[index].needSave = true;
this.dispatchEvent(new CustomEvent(
    "select", {
        detail: {
            hasEdit : true
        }
    })
);
}
// Open Ticket Subject
handleTicketSubjectChange(event) {
var index = event.target.dataset.index;
this.ticketOpenInfo[index].Subject__c = event.target.value;
this.ticketOpenInfo[index].needSave = true;
this.dispatchEvent(new CustomEvent(
    "select", {
        detail: {
            hasEdit : true
        }
    })
);
}
// Open Ticket Description
handleTicketDescriptionChange(event) {
var index = event.target.dataset.index;
this.ticketOpenInfo[index].Description__c = event.target.value;
this.ticketOpenInfo[index].needSave = true;
this.dispatchEvent(new CustomEvent(
    "select", {
        detail: {
            hasEdit : true
        }
    })
);
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
this.dispatchEvent(new CustomEvent(
    "select", {
        detail: {
            hasEdit : true
        }
    })
);
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
this.dispatchEvent(new CustomEvent(
    "select", {
        detail: {
            hasEdit : true
        }
    })
);
}
// Open Ticket ActivityDate
handleTicketActivityDateChange(event) {
var index = event.target.dataset.index;
var newDate = new Date(event.target.value);
var today = new Date(this.todayDate);
if (newDate<today) {
    this.ticketOpenInfo[index].DueDate__c = this.ticketOpenInfo[index].oldActivityDate;
    if (this.ticketOpenInfo[index].oldActivityDateShow) {
        this.ticketOpenInfo[index].oldActivityDateShow = false;
    } else {
        this.ticketOpenInfo[index].oldActivityDateShow = true;
    }
    // this.showError('Past date couldn’t be selected for this record.');
    this.showError(this.label.INSPECTION_REPORT_MSG_FUTURE_DATE);
    return;
} else {
    this.ticketOpenInfo[index].oldActivityDate = event.target.value;
    this.ticketOpenInfo[index].DueDate__c = event.target.value;
}
this.ticketOpenInfo[index].needSave = true;
this.dispatchEvent(new CustomEvent(
    "select", {
        detail: {
            hasEdit : true
        }
    })
);
}



// 数据整理
dataFormat(data) {
// ticket
if (data.data.ticketClosedInfo == undefined) {
    this.ticketClosedInfo = [];
}
if (data.data.ticketOpenInfo == undefined) {
    this.ticketOpenInfo = [];
}
if (this.ticketClosedInfo.length>0) {
    for (let i = 0; i < this.ticketClosedInfo.length; i++) {
        this.ticketClosedInfo[i]['key'] = i+1;
        this.ticketClosedInfo[i].className = 'slds-table slds-table_bordered slds-table_fixed-layout slds-resizable marketInsightTable ticketTable ' + (i % 2 ? 'table-even' : 'table-odd');
        if(!this.isFilledOut(this.ticketClosedInfo[i].Category__c) || this.ticketClosedInfo[i].Category__c == 'Service'){
            this.ticketClosedInfo[i].isShowProduct = true;
            this.ticketClosedInfo[i].isShowProductSearch = true; 
        }else{
            this.ticketClosedInfo[i].isShowProduct = false; 
            this.ticketClosedInfo[i].isShowProductSearch = false; 
        }
    }
}
if (this.ticketOpenInfo.length>0) {
    for (let i = 0; i < this.ticketOpenInfo.length; i++) {
        this.ticketOpenInfo[i]['key'] = i+1;
        if (this.ticketOpenInfo[i].DueDate__c == undefined) {
            this.ticketOpenInfo[i].DueDate__c = '';
        }
        this.ticketOpenInfo[i]['oldActivityDate'] = this.ticketOpenInfo.DueDate__c;
        this.ticketOpenInfo[i]['oldActivityDateShow'] = false;

        if(!this.isFilledOut(this.ticketOpenInfo[i].Category__c) || this.ticketOpenInfo[i].Category__c == 'Service'){
            this.ticketOpenInfo[i].isShowProduct = true;
            this.ticketOpenInfo[i].isShowProductSearch = true;
        }else{
            this.ticketOpenInfo[i].isShowProduct = false;
            this.ticketOpenInfo[i].isShowProductSearch = false;
        }
    }
    this.activeTicketSections = ['open'];
} 
//不用自动创建
// else {
//     this.addTicket();
// }
//check list
// this.checkResultsInfoDataFormat(data);
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

        if(ele.isArgentina && ele.record.Brand__c && ele.record.Brand__c != 'Hisense'){
            ele.samplingInspectionsArgentinaShow = [];
            ele.samplingInspectionsArgentina.forEach(obj => {
                obj.title = obj.Brand__c + '-' + obj.Product_Line__c;
                if(obj.Brand__c == ele.record.Brand__c){
                    ele.samplingInspectionsArgentinaShow.push(obj);
                }
            });
            ele.argentinaNotHisense = true;
        }

        // 是否为巡店员查看
        if (data.data.isReportUser==false) {
            ele.ownerName = data.data.attendanceInformation.CreatedBy.Name;
            ele.isTitleShowButton = false;
        }
        // 数据格式化
        ele.dataFormat(data);
        ele.oldReportDate = data.data.record.Report_Date__c;
        // 浮动效果
        ele.start();
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

// 更新数据
upsertRecord(isSubmit) {
this.isShowSpinner = true;
// var copyCheckResultsIsRelatedToProduct = JSON.parse(JSON.stringify(this.checkResultsIsRelatedToProduct));
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
// for(let index=0; index < copyCheckResultsIsRelatedToProduct.length; index++) {
//     let obj = copyCheckResultsIsRelatedToProduct[index];
//     if(typeof obj['ProductNotSampled'] != "undefined") { 
//         if(obj.ProductNotSampled) {
//             if(isSubmit) {
//                 obj.Scores__c = -2;
//             } else {
//                 copyCheckResultsIsRelatedToProduct.splice(index, 1);
//                 index -= 1;
//             }
//         }
//         delete obj['ProductNotSampled']; 
//     }
// }
// 出样状态切换 ------ Added By Sunny End


upsertRecord({
    recordJson: JSON.stringify(this.record),
    samplingInspectionJson: '',
    samplingInspectionsArgentinaJson: JSON.stringify(this.samplingInspectionsArgentina),
    ticketOpenJson: JSON.stringify(this.ticketOpenInfo),
    ticketClosedJson: JSON.stringify(this.ticketClosedInfo),
    ticketOpenFilesMapJson: JSON.stringify(this.ticketOpenFilesMap),
    mileageRecordJson: JSON.stringify(this.mileageRecord),
    checkResultsIsRelatedToProductJson: '',
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
            // this.isFieldReadOnly = true;
            // this.isTitleShowButton = false;
            // this.isEditPage = false;
            this.isFieldReadOnly = false;
            this.isTitleShowButton = true;
            this.isEditPage = true;
        } else {
            this.isEditPage = true;
            this.isFieldReadOnly = false;
        }
        // 数据格式化
        this.dataFormat(data);
        this.showSuccess('success');
        this.isShowSpinner = false;
    } else {
        this.isShowSpinner = false;
        this.showError(data.message);
    }
    // 刷新
    this.dispatchEvent(new CustomEvent('refreshdata'));
    // 返回父级元素页面
    this.dispatchEvent(new CustomEvent(
        "select", {
            detail: {
                hasEdit : false,
                // saveFlag : 'ticket'
            }
        })
    );
}).catch(error => {
    console.log('---------->error='+JSON.stringify(error));
    this.catchError(error);
    this.isShowSpinner = false;
});
}
// 附件部分
handleSelectFiles(event) {
console.log('handleSelectFiles ---> type: '+event.currentTarget.dataset.type);
console.log('handleSelectFiles ---> recordid: '+event.currentTarget.dataset.recordid);
var type = event.currentTarget.dataset.type;
var index = event.currentTarget.dataset.recordid;
if (type=='ticketOpen') {
    var filesIndex = this.ticketOpenInfo[index].index;
    this.ticketOpenFilesMap[filesIndex] = event.detail.records;
}
}

get options() {
return [
    { label: 'Yes', value: 'Y' },
    { label: 'No', value: 'N' },
];
}

// Comment Change
commentChange(event) {
var index = event.target.dataset.index;
var value = event.target.value;
this.selectedProject[Number(index)].Comments__c = value;
this.dispatchEvent(new CustomEvent(
    "select", {
        detail: {
            hasEdit : true
        }
    })
);
}
get sioptions() {
    return [  { label: 'Yes', value: 'Yes' }, { label: 'No', value: 'No' }, ];
}
siHandleSelectFiles(event) {
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

this.samplingInspections.forEach(obj => {
    if (obj.Id == siId) {
        obj.isUpdatedFile = true;
    }
});
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
this.argChange('POP__c', type, value);
}
argChange(fieldName, type, value){
this.samplingInspectionsArgentina.forEach(obj => {
    if (this.record.Brand__c == obj.Brand__c && type == obj.Product_Line__c) {
        obj[fieldName] = value;
    }
});
}

argHandleSelectFiles(event) {
var type = event.target.dataset.type;
this.argChange('isUpdatedFile', type, true);
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

/**
 * 自定义相机页面
 */
@track capturePage = false;
capturePageInitialization() {
this.capturePage = true;
}

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
// Added By Sunny Start
handleShowItemIssues() {
this.showAllPage = false;
this.showCheckItemIssues = true;
}
handleCloseItemIssues() {
this.showCheckItemIssues = false;
this.showAllPage  = true;
this.activeSections = [];
}
// Added By Sunny End
handleTicketPriorityChange(event) {
var index = event.target.dataset.index;
this.ticketOpenInfo[index].Priority__c = event.target.value;
this.dispatchEvent(new CustomEvent(
    "select", {
        detail: {
            hasEdit : true
        }
    })
);
}
// By lizunxing 2024-01-02
handleTicketCategoryChange(event) {
this.ticketOpenInfo[event.target.dataset.index].Category__c = event.target.value;

if(event.target.dataset.fieldName == 'Category__c') {
    if(!this.isFilledOut(event.target.value) || event.target.value == 'Service'){
        this.ticketOpenInfo[event.target.dataset.index].isShowProduct = true;
        this.ticketOpenInfo[event.target.dataset.index].isShowProductSearch = true;
        this.ticketOpenInfo[event.target.dataset.index].Product__c = '';
    }else{
        this.ticketOpenInfo[event.target.dataset.index].isShowProduct = false;
        this.ticketOpenInfo[event.target.dataset.index].isShowProductSearch = false;
    }
}
this.dispatchEvent(new CustomEvent(
    "select", {
        detail: {
            hasEdit : true
        }
    })
);
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
        this.ticketOpenInfo[index].Product__c = this.ticketOpenInfo[index].Product__c.substr(0, this.ticketOpenInfo[index].Product__c.lastIndexOf(','));this.ticketOpenInfo[index].isShowProductSearch = false;
    }else{this.ticketOpenInfo[index].Product__c = '';this.ticketOpenInfo[index].isShowProductSearch = true;}
}
}
// 选择产品变更
handleChangeProductOptionTicket(event) {
let index = event.target.dataset.index;
console.log('handleChangeProductOptionTicket ——> index: ' + index);
console.log('handleChangeProductOptionTicket event.detail.selectedRecord ——> : ' + event.detail.selectedRecord);
if (event.detail.selectedRecord==undefined) {return;} 
// handlerRemove({}).then(data => {
//     if (data.isSuccess) {this.handleRemoveLookup('onProduct',index);} else {}
// }).catch(error => {this.catchError(error);});
// if(this.ticketOpenInfo[index].Product__c && this.ticketOpenInfo[index].Product__c != ''){
//     if(this.ticketOpenInfo[index].Product__c.indexOf(event.detail.selectedRecord.Name) == -1){
//         this.ticketOpenInfo[index].Product__c = this.ticketOpenInfo[index].Product__c + ',' + event.detail.selectedRecord.Name;
//         this.ticketOpenInfo[index].isShowProductSearch = true;
//     }
// }else{
    this.ticketOpenInfo[index].Product__c = event.detail.selectedRecord.Name;
    console.log('打印一下传入参数' +event.detail.selectedRecord.Name);
    console.log('实际参数' + JSON.stringify(this.ticketOpenInfo[index]));
    this.dispatchEvent(new CustomEvent(
        "select", {
            detail: {
                hasEdit : true
            }
        })
    );
    // this.ticketOpenInfo[index].isShowProductSearch = false;
// }
}

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

competitorsInformationtSaveData(resp) {
var itemRespIsSuccess = true;
var itemRespErrorMsg = '';
if (!resp.detail.result.isSuccess) {
    itemRespIsSuccess = resp.detail.result.isSuccess;
    itemRespErrorMsg += ' ' + resp.detail.result.message;
}
if (itemRespIsSuccess) {
    this.showSuccess('success');
    //this.isEditPage = false;
    this.viewMode = true;
} else {
    this.lwcName = this.label.INSPECTION_REPORT_Competitors_Information;
    this.showError(itemRespErrorMsg);
}
}

saveCompetitorsInformationts(event) {
if (this.template.querySelector('c-new-competitors-information-lwc')!=null) {
    this.template.querySelector('c-new-competitors-information-lwc').saveData();
} 
}
//Copy 
cancelHandleClick(event) {
    this.goToObject('Ticket__c');
}

handleBack(){
    this.dispatchEvent(new CustomEvent('goback'));
}
}