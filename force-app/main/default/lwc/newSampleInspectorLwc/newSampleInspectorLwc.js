import { track, api, wire } from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import { CurrentPageReference } from 'lightning/navigation';
import common3 from '@salesforce/resourceUrl/common3';
import Id from '@salesforce/user/Id';
import getPickList from '@salesforce/apex/NewSampleInspectorController.getPickList';
import LightningConfirm from 'lightning/confirm';
import getInitData from '@salesforce/apex/NewSampleInspectorController.getInitData';
import createRecord from '@salesforce/apex/NewSampleInspectorController.createRecord';
import refreshPositioning from '@salesforce/apex/NewSampleInspectorController.refreshPositioning';
import refreshData from '@salesforce/apex/NewSampleInspectorController.refreshData';
import upsertRecord from '@salesforce/apex/NewSampleInspectorController.upsertRecord';
import addPlanOutProduct from '@salesforce/apex/NewSampleInspectorController.addPlanOutProduct';
import delProductLine from '@salesforce/apex/NewSampleInspectorController.delProductLine';
import judgeCountry from '@salesforce/apex/NewPromoterDailyReportActionController.judgeCountry';//Lay add 区分国家
import samplingInspectionAdd from '@salesforce/apex/NewSampleInspectorController.samplingInspectionAdd';
import samplingInspectionDelete from '@salesforce/apex/NewSampleInspectorController.samplingInspectionDelete';
import handlerRemove from '@salesforce/apex/NewTicketsController2.handlerRemove';

import SAMPLE_REPORT_TITLE from '@salesforce/label/c.SAMPLE_REPORT_TITLE';
import INSPECTION_REPORT_NEW from '@salesforce/label/c.INSPECTION_REPORT_NEW';
import INSPECTION_REPORT_SAVE from '@salesforce/label/c.INSPECTION_REPORT_SAVE';
import INSPECTION_REPORT_SUBMIT from '@salesforce/label/c.INSPECTION_REPORT_SUBMIT';
import INSPECTION_REPORT_EDIT from '@salesforce/label/c.INSPECTION_REPORT_EDIT';
import INSPECTION_REPORT_CHECK_IN from '@salesforce/label/c.INSPECTION_REPORT_CHECK_IN';
import INSPECTION_REPORT_CHECK_OUT from '@salesforce/label/c.INSPECTION_REPORT_CHECK_OUT';
import INSPECTION_REPORT_DISTANCE from '@salesforce/label/c.INSPECTION_REPORT_DISTANCE';
import INSPECTION_CREATED_BY from '@salesforce/label/c.Inspection_Created_By';
import INSPECTION_REPORT_ATTACHMENT from '@salesforce/label/c.INSPECTION_REPORT_ATTACHMENT';
import INSPECTION_REPORT_UNSCHEDULED from '@salesforce/label/c.INSPECTION_REPORT_UNSCHEDULED';
import INSPECTION_REPORT_ACTION from '@salesforce/label/c.INSPECTION_REPORT_ACTION';
import INSPECTION_REPORT_INFORMATION from '@salesforce/label/c.INSPECTION_REPORT_INFORMATION';
import INSPECTION_REPORT_TICKET_NEW from '@salesforce/label/c.INSPECTION_REPORT_TICKET_NEW';
import INSPECTION_REPORT_TICKET_HISTORY from '@salesforce/label/c.INSPECTION_REPORT_TICKET_HISTORY';
import INSPECTION_REPORT_CHECK_ITEM_ISSUES from '@salesforce/label/c.INSPECTION_REPORT_CHECK_ITEM_ISSUES';
import INSPECTION_REPORT_MSG_FUTURE_DATE from '@salesforce/label/c.INSPECTION_REPORT_MSG_FUTURE_DATE';
import INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION from '@salesforce/label/c.INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION';
import INSPECTION_REPORT_PLEASE_PHONE from '@salesforce/label/c.INSPECTION_REPORT_PLEASE_PHONE';
import INSPECTION_REPORT_MSG_REQUIRED from '@salesforce/label/c.INSPECTION_REPORT_MSG_REQUIRED';
import INSPECTION_REPORT_MSG_CANNOT_BLANK from '@salesforce/label/c.INSPECTION_REPORT_MSG_CANNOT_BLANK';
import INSPECTION_REPORT_MSG_UNPLANNED_STORE from '@salesforce/label/c.INSPECTION_REPORT_MSG_UNPLANNED_STORE';
import INSPECTION_REPORT_MSG_NO_PRODUCT_SELECTED from '@salesforce/label/c.INSPECTION_REPORT_MSG_NO_PRODUCT_SELECTED';
import INSPECTION_REPORT_MSG_PRODUCT_EXISTS from '@salesforce/label/c.INSPECTION_REPORT_MSG_PRODUCT_EXISTS';
import INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE from '@salesforce/label/c.INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE';
import INSPECTION_REPORT_MSG_SUBMIT_REPORT from '@salesforce/label/c.INSPECTION_REPORT_MSG_SUBMIT_REPORT';
import INSPECTION_REPORT_MSG_CHECKITEM_LOST from '@salesforce/label/c.INSPECTION_REPORT_MSG_CHECKITEM_LOST';
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
import INSPECTION_REPORT_From_Photo from '@salesforce/label/c.INSPECTION_REPORT_From_Photo';
import INSPECTION_REPORT_From_Fold from '@salesforce/label/c.INSPECTION_REPORT_From_Fold';
import add_Inspection_product from '@salesforce/label/c.add_Inspection_product';
import add_Inspection_productseries from '@salesforce/label/c.add_Inspection_productseries';
import add_Inspection_productline from '@salesforce/label/c.add_Inspection_productline';
import Ticket_Select_Progress from '@salesforce/label/c.Ticket_Select_Progress';
import INSPECTION_REPORT_SUBMITED from '@salesforce/label/c.INSPECTION_REPORT_SUBMITED';
import Sample_picture from '@salesforce/label/c.Sample_picture';
import INSPECTION_REPORT_Competitors_Information from '@salesforce/label/c.INSPECTION_REPORT_Competitors_Information';
import INSPECTION_REPORT_Display_Status from '@salesforce/label/c.INSPECTION_REPORT_Display_Status';
import INSPECTION_REPORT_Display_Stand from '@salesforce/label/c.INSPECTION_REPORT_Display_Stand';
import PromoterDailyReport_DAILY_SALES from '@salesforce/label/c.PromoterDailyReport_DAILY_SALES';
import INSPECTION_REPORT_PRODUCT_PRICE from '@salesforce/label/c.INSPECTION_REPORT_PRODUCT_PRICE';
import INSPECTION_REPORT_PRODUCT_PRICE_HELPTEXT from '@salesforce/label/c.INSPECTION_REPORT_PRODUCT_PRICE_HELPTEXT';
import Start_inspection from '@salesforce/label/c.Start_inspection';
import NO_SAMPLE from '@salesforce/label/c.NO_SAMPLE';
import HAVE_SAMPLE from '@salesforce/label/c.HAVE_SAMPLE';
import upload_file from '@salesforce/label/c.upload_file';
import Inspection_Success from '@salesforce/label/c.Inspection_Success';

export default class NewSampleInspectorLwc extends LightningNavigationElement {
    lwcName = 'NewSampleInspectorLwc';
    label = {
        PromoterDailyReport_DAILY_SALES,
        SAMPLE_REPORT_TITLE,            // Title 检查报告
        INSPECTION_REPORT_NEW,              // 新建
        INSPECTION_REPORT_SAVE,             // 保存
        INSPECTION_REPORT_SUBMIT,           // 提交
        INSPECTION_REPORT_EDIT,             // 修改
        INSPECTION_REPORT_CHECK_IN,         // 签到
        INSPECTION_REPORT_CHECK_OUT,        // 签退
        INSPECTION_REPORT_DISTANCE,         // 距离
        INSPECTION_CREATED_BY,              // 创建者
        INSPECTION_REPORT_ATTACHMENT,       // 附件
        INSPECTION_REPORT_UNSCHEDULED,      // 计划外
        INSPECTION_REPORT_ACTION,           // 操作
        INSPECTION_REPORT_INFORMATION,      // 信息
        INSPECTION_REPORT_TICKET_NEW,       // 新增（当前日期）
        INSPECTION_REPORT_TICKET_HISTORY,   // 历史记录
        INSPECTION_REPORT_CHECK_ITEM_ISSUES,// 历史检查项问题
        INSPECTION_REPORT_MSG_FUTURE_DATE,              // 无法为此记录选择未来日期
        INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION,   // 当前设备不支持定位功能
        INSPECTION_REPORT_PLEASE_PHONE,                 // 打卡失败，请上传照片
        INSPECTION_REPORT_MSG_REQUIRED,                 // 未维护所需信息。请先填写所需信息
        INSPECTION_REPORT_MSG_CANNOT_BLANK,             // 摘要不能为空
        INSPECTION_REPORT_MSG_UNPLANNED_STORE,          // 门店为计划外门店，确定要新建此日报
        INSPECTION_REPORT_MSG_NO_PRODUCT_SELECTED,      // 没有选择产品
        INSPECTION_REPORT_MSG_PRODUCT_EXISTS,           // 产品已存在
        INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE,     // {0}将被删除
        INSPECTION_REPORT_MSG_SUBMIT_REPORT,            // 是否提交当前日报
        INSPECTION_REPORT_MSG_CHECKITEM_LOST,           // checkItem未匹配
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
        add_Inspection_productseries,
        add_Inspection_productline,
        Ticket_Select_Progress,
        INSPECTION_REPORT_SUBMITED,
        Sample_picture,
        INSPECTION_REPORT_Competitors_Information,
        INSPECTION_REPORT_Display_Status,
        INSPECTION_REPORT_Display_Stand,
        INSPECTION_REPORT_PRODUCT_PRICE,
        INSPECTION_REPORT_PRODUCT_PRICE_HELPTEXT,
        Start_inspection, //开始检查
        NO_SAMPLE, 
        HAVE_SAMPLE, 
        upload_file,
        Inspection_Success
    };
    lwcName = this.label.SAMPLE_REPORT_TITLE;
    /**
     * 初始化 Sample_Inspector__c 标签
     */
    @track dailyInspectionReportInfo = {
        Store__c: '',
        Status__c: '',
    };
    @wire(getObjectInfo, { objectApiName: 'Sample_Inspector__c' })
    wiredDailyInspectionReportInfo({ error, data }) {
        if (data) {
            this.dailyInspectionReportInfo = {
                Store__c: data.fields.Store__c.label,
                Status__c: data.fields.Status__c.label,
            }
        } else if (error) {
            console.log(error);
            this.showError('Sample_Inspector__c getInformation error');
        }
    }
    /**初始化 Sampling_Inspection__c 标签*/
    @track samplingInspectionInfo = {
        ReRe__c: '',
        Price__c: '',
        Quantity__c: '',
        Rent__c: '',
        Exhibition_Format__c: ''
    };
    @wire(getObjectInfo, { objectApiName: 'Sampling_Inspection__c' })
    wiredSamplingInspectionInfo({ error, data }) {
        if (data) {
            this.samplingInspectionInfo = {
                ReRe__c: data.fields.ReRe__c.label,
                Exhibition_Format__c: data.fields.Exhibition_Format__c.label,
                Quantity__c: data.fields.Quantity__c.label,
                Rent__c: data.fields.Rent__c.label,
                Price__c: data.fields.Price__c.label
            }
        } else if (error) {
            console.log(error);
            this.showError('Sampling_Inspection__c getInformation error');
        }
    }
    /**初始化 Product__c 标签*/
    @track productInfo = {
        Product_Line__c: '',
        Name: ''
    };
    @wire(getObjectInfo, { objectApiName: 'Product__c' })
    wiredProductInfo({ error, data }) {
        if (data) {
            this.productInfo = {
                Product_Line__c: data.fields.Product_Line__c.label, 
                Name: data.fields.Name.label,
            }
        } else if (error) {
            console.log(error); this.showError('Product__c getInformation error');
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
        Product__c: '',
        Product_Line__c:''
    };
    @wire(getObjectInfo, { objectApiName: 'Ticket__c' })
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
                Product__c: data.fields.Product__c.label,
                Product_Line__c: data.fields.Product_Line__c.label
            };
        } else if (error) {
            this.showError('Ticket__c getInformation error');
        }
    }
    /**初始化 Ticket Confirm Task Value List*/
    @wire(getPickList, { objectName: 'Ticket__c', fieldName: 'Status__c' })
    confirmTaskOptions;
    @wire(getPickList, { objectName: 'Ticket__c', fieldName: 'Priority__c' })
    priorityTaskOptions;
    @wire(getPickList, { objectName: 'Ticket__c', fieldName: 'Category__c' })
    CategoryTaskOptions;
    /**初始化 Product Product line Value List*/

    @wire(getPickList, { objectName: 'Sampling_Inspection__c', fieldName: 'Exhibition_Format__c' })
    ExhibitionFormatOptions;
    @wire(getPickList, { objectName: 'Sampling_Inspection__c', fieldName: 'Rent__c' })
    RentOptions;
    @track showAllPage = true;
    // 打卡地图相关
    @track mapMarkers = [];
    @track showMapMarkers = [];
    // Data相关
    @api recordId;
    @api storeId;
    @api reportDate;
    @track showCheckItemIssues = false; // Added By Sunny 
  
    get isShowCategory() {
        return this.isArgentina || this.isSouthAfrica;
    }
    @track isReportUser = true;                 // 是否为日报所有人
    @track ownerName;                           // 所有人名
    @track userId = Id;
    // @track currentLat = 23.134319370221707;     // 当前坐标 Lat(测试)
    // @track currentLong = 113.33652718795777;    // 当前坐标 Long(测试)
    @track currentLat = 0;                      // 当前坐标 Lat
    @track currentLong = 0;                     // 当前坐标 Long
    @track record = {};                         // 日报主数据信息
    @track storeDistanceList = [];              // 门店信息
    @track attendanceInformation;               // 签到信息
    @track attendanceInformationCheckOut = {};       // 签退信息
    @track attendanceInformationCheckOutHandHelper = {};
    @track checkResults = {};                   // 试卷信息
    @track checkResultsInfo = [];               // 试卷信息（整理后）
    @track checkResultsIsRelatedToProduct = [];                   // 试卷信息-出样
    @track ticketClosedInfo = [];               // 历史ticket
    @track ticketOpenInfo = [];                 // 新建ticket
    @track ticketOpenFilesMap = {};             // ticket附件Map
    @track samplingInspections = [];            // 出样检查
    @track inspectTypeOptions = {};
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
    @track language;                            // 语言
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

    retailNumberHaveFileIdMap = [];
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
    @track isShowTotalScore = true;
    @track isShowAverageScore = true;
    @track isShowREMARK = true;
    @track isShowPHOTO = true;
    @track isShowTicket = false;
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
    @track ticketAssignedTo = '';

    @wire(CurrentPageReference)
    pageEvent;

    get pageState() {
        return this.pageEvent.state;
    }

    get havaSampling(){
        return this.samplingInspections != null && this.samplingInspections.length > 0
    }

    get iOSModel() {
        var userAgent = navigator.userAgent;
        if (/iphone|iPhone|ipad|iPad|ipod|iPod|iOS|ios/.test(userAgent)) {
            return true;
        } else { return false; }
    }
    get AndroidModel() {
        var userAgent = navigator.userAgent;
        if (/android|Android/.test(userAgent)) {
            return true;
        } else { return false; }
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
            optins.push({ label: person.storeName, value: person.storeId });
        }
       
        return optins;
    }
    // 门店只读
    get isTitleReadOnly() {
        return false;
    }
    // 日报日期对比当前日期
    get reportDateIsToday() {
        var recordDate = new Date(this.record.Report_Date__c);
        var today = new Date(this.todayDate);
        if (today > recordDate) {
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
            setTimeout(() => {
                let h = _this.height = document.documentElement.clientHeight;
                setTimeout(() => {
                    _this.height = h - document.documentElement.scrollHeight + document.documentElement.clientHeight;
                }, 10);
            }, 1000);
        }
    }
    // 添加产品（自定义lookupFilter）
    lookupFilter = {
        'lookup': 'CustomLookupProvider.ProductAllFilter'
    }
    // 添加用户（自定义lookupFilter）
    lookupUserFilter = {
        'lookup': 'CustomLookupProvider.UserFilter'
    }

    shopLookupFilter = {
        'lookup' : 'CustomLookupProvider.ShopFilter'
    }

    handleUpdateLookup(type, index) {
        console.log('11111' + JSON.stringify(this.shopOptions));
        let lookup;
        setTimeout(() => {
            lookup = this.template.querySelector('c-store-lookup-lwc');

            if(lookup != null && lookup.name == type){
                lookup.updateOption({
                    'lookup' : 'CustomLookupProvider.ShopFilter',
                    'shopOptions' : JSON.stringify(this.shopOptions)
                });
            }
        }, 0);
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
        if (ele != null) {
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

    get isEditPageJudgment() {
        if(this.pageState && this.pageState.c__skip || this.isEditPage) {
            console.log('WWW');
            return true;
        } else {
            console.log('MMM');
            return false;
        }
    }

    // 初始化
    connectedCallback() {
        if (this.pageState && this.pageState.c__skip) {
            // 执行相关操作
            this.activeSections = ['ticket'];
            this.activeTicketSections = ['open'];
        }
        
        loadStyle(this, common3).then(() => { }).catch((error) => { });
        judgeCountry().then(data => {
            if (data.isSuccess) {
                // added by Sunny about chile department start-[20231026]
                this.isShowDepartment = (data.data.Chile || data.data.SouthAfrica);
                // added by Sunny about chile department end-[20231026]
                if (data.data.SouthAfrica) {
                    this.saRequired = true;
                    this.isShowSpinner = false;
                    this.isSouthAfrica = true;
                } else if (data.data.Chile) {
                    this.isShowTotalScore = false;
                    this.isShowAverageScore = false;
                    this.isShowSpinner = false;
                    this.isChile = true;
                    this.isStorePicTitle = true;
                } else if (data.data.Indonesia) {
                    this.saRequired = false;
                    this.isShowSpinner = false;
                    this.isIndonesia = true;
                    //判断国家  BY lizunxing 20231128
                } else if (data.data.Japan) {
                    this.isShowTotalScore = false;
                    this.isShowAverageScore = false;
                    this.isShowREMARK = false;
                    this.isShowPHOTO = false;
                    this.isShowTicket = false;
                    this.isJapan = true;
                } else if (data.data.Argentina) {
                    this.isArgentina = true;

                    this.isShowTotalScore = false;
                    this.isShowAverageScore = false;
                } else if (data.data.Malaysia) {
                    this.isMalaysia = true;
                } else if (data.data.Thailand) {
                    this.isThailand = true;
                } else if (data.data.Vietnam) {
                    this.isVietnam = true;
                } else if (data.data.Philippines) {
                    this.isPhilippines = true;
                }
                if (data.data.HQOperation) {
                    this.isStorePicTitle = false;
                }
                this.isShowSpinner = true;
                // 取消下拉刷新
                this.disablePullToRefresh();
                // 有门店Id
                if (this.storeId != null && this.storeId != '') {
                    var d = new Date();
                    this.record = {
                        Report_Date__c: this.reportDate == null ? d.getFullYear() + '-' + (d.getMonth() + 1) + '-' + d.getDate() : this.reportDate,
                        Store__c: this.storeId,
                        Status__c: 'New',
                    };
                    this.getCurrentPosition(this.refreshData);
                } else {
                    this.getCurrentPosition(this.getInitDataBaseRecordId);
                }
                
                this.start();
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            this.isShowSpinner = false; this.catchError(error);
        })
    }

    // ---------------> ↓ Button click ↓ <---------------
    // Edit click
    handleEdit() {
        this.isEditPage = true;
        this.isFieldReadOnly = false;
        //this.storeLabel = this.shopOptions.find(opt => opt.value === this.record.Store__c).label;
        if (this.ticketOpenInfo.length > 0) {
            for (let i = 0; i < this.ticketOpenInfo.length; i++) {
                this.ticketOpenInfo[i]['key'] = i + 1;
                if (this.ticketOpenInfo[i].DueDate__c == undefined) {
                    this.ticketOpenInfo[i].DueDate__c = '';
                }
                this.ticketOpenInfo[i]['oldActivityDate'] = this.ticketOpenInfo.DueDate__c;
                this.ticketOpenInfo[i]['oldActivityDateShow'] = false;

                if (!this.isFilledOut(this.ticketOpenInfo[i].Category__c) || this.ticketOpenInfo[i].Category__c == 'Service') {
                    this.ticketOpenInfo[i].isShowProduct = false;
                } else {
                    this.ticketOpenInfo[i].isShowProduct = true;
                }
                this.ticketOpenInfo[i].disabled = this.isEditPage;
                this.ticketOpenInfo[i].isFieldReadOnly = this.isFieldReadOnly;
                console.log(this.ticketOpenInfo[i]);
            }
        }
    }
    // Save click
    handleSave() {
        // 检查必填信息
        var checkResp = { alltrue: true, msg: '' };

        for (let index = 0; index < this.samplingInspections.length; index++) {
            let obj = this.samplingInspections[index];

            if (!this.isFilledOut(obj.Rent__c)) {
                this.lwcName = this.label.SAMPLE_REPORT_TITLE;
                this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.Rent__c));
                return;
            }

            if (!this.isFilledOut(obj.Price__c)) {
                this.lwcName = this.label.SAMPLE_REPORT_TITLE;
                this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.Price__c));
                return;
            }

            if (!this.isFilledOut(obj.Quantity__c)) {
                this.lwcName = this.label.SAMPLE_REPORT_TITLE;
                this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.Quantity__c));
                return;
            }

            if (!this.isFilledOut(obj.Exhibition_Format__c)) {
                this.lwcName = this.label.SAMPLE_REPORT_TITLE;
                this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.Exhibition_Format__c));
                return;
            }

            // if (!this.isFilledOut(obj.ReRe__c)) {
            //     this.lwcName = this.label.SAMPLE_REPORT_TITLE;
            //     this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.ReRe__c));
            //     return;
            // }

            let fileListRetail = this.retailNumberHaveFileIdMap[obj.Id];
            if((fileListRetail == null || fileListRetail == '' || fileListRetail == undefined || fileListRetail.length == 0) && !obj.isUpdatedFile){
                this.lwcName = this.label.SAMPLE_REPORT_TITLE;
                this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.label.upload_file));
                return;
            }
        };

        if (this.checkTicket().alltrue == false) {
            checkResp = this.checkTicket();
            this.lwcName = this.label.PromoterDailyReport_TICKET;
        }

        if (checkResp.alltrue == false) {
            this.showWarning(this.label.INSPECTION_REPORT_MSG_REQUIRED + checkResp.msg);
            this.lwcName = this.label.SAMPLE_REPORT_TITLE;
            return;
        }

        // 保存更新
        this.upsertRecord(false);
    }
    // Submit click
    async handleSubmit() {
        const result = await LightningConfirm.open({
            message: this.label.INSPECTION_REPORT_MSG_SUBMIT_REPORT,
            variant: 'headerless',
            label: 'This is the aria-label value',
        });
        if (result) {
            this.handleSubmitModal();
        }
    }
    handleSubmitModal() {
        // 检查必填信息
        var checkResp = { alltrue: true, msg: '' };

        for (let index = 0; index < this.samplingInspections.length; index++) {
            let obj = this.samplingInspections[index];

            if (!this.isFilledOut(obj.Rent__c)) {
                this.lwcName = this.label.SAMPLE_REPORT_TITLE;
                this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.Rent__c));
                return;
            }

            if (!this.isFilledOut(obj.Price__c)) {
                this.lwcName = this.label.SAMPLE_REPORT_TITLE;
                this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.Price__c));
                return;
            }

            if (!this.isFilledOut(obj.Quantity__c)) {
                this.lwcName = this.label.SAMPLE_REPORT_TITLE;
                this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.Quantity__c));
                return;
            }

            if (!this.isFilledOut(obj.Exhibition_Format__c)) {
                this.lwcName = this.label.SAMPLE_REPORT_TITLE;
                this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.Exhibition_Format__c));
                return;
            }

            // if (!this.isFilledOut(obj.ReRe__c)) {
            //     this.lwcName = this.label.SAMPLE_REPORT_TITLE;
            //     this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.ReRe__c));
            //     return;
            // }

            let fileListRetail = this.retailNumberHaveFileIdMap[obj.Id];
            if((fileListRetail == null || fileListRetail == '' || fileListRetail == undefined || fileListRetail.length == 0) && !obj.isUpdatedFile){
                this.lwcName = this.label.SAMPLE_REPORT_TITLE;
                this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.label.upload_file));
                return;
            }
        };

        if (this.checkTicket().alltrue == false) {
            checkResp = this.checkTicket();
            this.lwcName = this.label.PromoterDailyReport_TICKET;
        }

        if (checkResp.alltrue == false) {
            this.showWarning(this.label.INSPECTION_REPORT_MSG_REQUIRED + checkResp.msg);
            this.lwcName = this.label.SAMPLE_REPORT_TITLE;
            return;
        }

        this.isShowNewButton = true;
        this.upsertRecord(true);
        // if (navigator.geolocation) {
        //     navigator.geolocation.getCurrentPosition(position => {
        //         // 测试用，固定坐标
        //         this.currentLat = position.coords.latitude;
        //         this.currentLong = position.coords.longitude;
        //         this.handleSubmitCheckOut();
        //     }, error => {
        //         this.isShowSpinner = false;
        //         this.showError(this.getErrorInfomation(error));
        //     }, { enableHighAccuracy: true, timeout: 10000 });
        // } else {
        //     this.isShowSpinner = false; this.showError(this.label.INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION);
        // }
    }

    // Create click
    async handleCreate() {
        this.isShowSpinner = true;
        this.getCurrentPosition(this.createRecord);
    }

    // Delete Product Line
    deleteProductLine(event) {
        var productline = event.target.dataset.productline;
        this.handleShow(
            // 'Product Line '+productline+' will be deleted if you click "Yes"; click "No" to cancel.',
            this.label.INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE.format(this.productInfo.Product_Line__c + ' ' + productline),
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

                // 只需要整理刷新check list 信息
                this.checkResultsInfoDataFormat(data);
                this.isShowSpinner = false;
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            console.log('---------->error=' + error);
            this.catchError(JSON.stringify(error));
            this.isShowSpinner = false;
        });
    }
    
    // Section Toggle click
    handleSectionToggle(event) {
        let openSections = event.detail.openSections;
        var sections = [];
        if (openSections.length == 0) {
            sections = [];
        } else if (openSections.length == 1) {
            sections = [openSections[0]];

        } else {
            openSections.forEach(obj => {
                if (obj != this.activeSections[0]) {
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
        } else if (openSections.length == 1) {
            sections = [openSections[0]];
        } else {
            openSections.forEach(obj => {
                if (obj != this.activeTicketSections[0]) {
                    sections = [obj];
                }
            });
        }
        this.activeTicketSections = sections;
    }

    // Add Ticket click
    addTicket() {
        // 检查必填信息
        var checkResp = { alltrue: true, msg: '' };
        if (this.checkTicket().alltrue == false) {
            checkResp = this.checkTicket();
            this.lwcName = this.label.PromoterDailyReport_TICKET;
        }
        if (checkResp.alltrue == false) {
            // this.showError('Required information haven’t been maintained. Please fulfil required information first. - ' + checkResp.msg);
            this.showWarning(this.label.INSPECTION_REPORT_MSG_REQUIRED + checkResp.msg);
            this.lwcName = this.label.SAMPLE_REPORT_TITLE;
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
            Product__c: '',
            Product_Line__c: '',
            isShowProduct: false,
            disabled: true,
            isFieldReadOnly: false,

            index: new Date().getTime(),
            needSave: true
        };
        if (this.isArgentina) {
            if (this.ticketAssignedTo != '') {
                ticket.AssignedTo__c = '';
            }
           
            ticket.Priority__c = 'Normal';
           
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
        var resp = { alltrue: true, msg: '' };
        // added by Sunny 检查结果为满分或-2（不出样） start -[20240507]
        let d = new Date();
        // let systemGenerationDate = d.getFullYear() + '-' + (d.getMonth() + 1) + '-' + (d.getDate() + 7);
        let noTicketCheckResultIdList = [];
        let notSampledCheckResultIdList = [];
        for (let index = 0; index < this.checkResultsIsRelatedToProduct.length; index++) {
            let obj = this.checkResultsIsRelatedToProduct[index];
            console.log('sunny add -> check result: ' + JSON.stringify(obj));
            // 不出样
            if (typeof obj['ProductNotSampled'] != "undefined") {
                if (obj.ProductNotSampled) {
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
                // obj.DueDate__c = systemGenerationDate;
                obj.DueDate__c = d.getFullYear() + '-' + (d.getMonth() + 1) + '-' + d.getDate();
                obj.AssignedTo__c = this.userId;
                if (notSampledCheckResultIdList.includes(obj.CheckResult__c)) {
                    this.ticketOpenInfo.splice(i, 1);
                    i -= 1;
                    continue;
                }
            }
            // added by Sunny 自动生成的ticket，结果改为满分或-2（不出样）跳过，无需校验 end -[20240507]
            if (obj.Subject__c == '' || obj.Subject__c == null) {
                resp.alltrue = false;
                resp.msg = this.TicketInfo.Subject__c;
                return resp;
            }
            //增加判断条件 阿根廷不做校验 TJP
            if(!this.isArgentina) {
                if (this.isFilledOut(obj.Category__c) && obj.Category__c != 'Service') {
                    if (!this.isFilledOut(obj.Product__c)) {
                        resp.alltrue = false;
                        resp.msg = this.TicketInfo.Product__c;
                        return resp;
                    }
                }
            }
           
            if ((this.isShowDepartment) && (obj.Department__c == '' || obj.Department__c == null) && (obj.AssignedTo__c == '' || obj.AssignedTo__c == null)) {
                resp.alltrue = false;
                resp.msg = Ticket_Fields_Check.format(this.TicketInfo.AssignedTo__c, this.TicketInfo.Department__c);
                return resp;
            }
            
            // added by Sunny about chile department end-[20231026]
            if (!this.isShowDepartment && (!this.isArgentina) && (obj.AssignedTo__c == '' || obj.AssignedTo__c == null)) {
                resp.alltrue = false;
                resp.msg = this.TicketInfo.AssignedTo__c;
                return resp;
            }
            if (obj.DueDate__c == '' || obj.DueDate__c == null) {
                resp.alltrue = false;
                resp.msg = this.TicketInfo.DueDate__c;
                return resp;
            }
        }
        return resp;
    }
    // Del Ticket click
    deleteTicket(event) {
        var index = event.target.dataset.index;
        this.handleShow(
            // 'Information will be deleted if you click "Yes"; click "No" to cancel.',
            this.label.INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE.format(this.label.INSPECTION_REPORT_INFORMATION),
            'deleteTicketHelper',
            index);
    }
    async deleteTicketHelper(event) {
        var new_list = [];
        for (let i = 0; i < this.ticketOpenInfo.length; i++) {
            if (i != event) {
                new_list.push(this.ticketOpenInfo[i]);
            }
        }
        for (let i = 0; i < new_list.length; i++) {
            new_list[i].key = i + 1;
        }
        this.ticketOpenInfo = new_list;
    }
    // ---------------> ↑ Button click ↑ <---------------
    // ---------------> ↓ onchange ↓ <---------------
  
    storeLabel;
    // 门店变更
    handleChangeShopOption(event) {
        this.isShowSpinner = true;
        this.record.Store__c = event.target.value + '';
        //this.storeLabel = this.shopOptions.find(opt => opt.value === event.target.value).label;
        this.getCurrentPosition(this.refreshData);
    }

    // handleChangeShopOption(event) {
    //     if (event.detail.selectedRecord==undefined || event.detail.selectedRecord.Id == '') {
    //         return;
    //     }
    //     this.record.Store__c = event.detail.selectedRecord.Id;
    //     this.storeLabel = event.detail.selectedRecord.Name;
    //     this.getCurrentPosition(this.refreshData);
    // }

    // lookup remove
    handleRemoveLookup(type, index) {
        let alllookup = this.template.querySelectorAll('c-lookup-lwc');
        for (let i = 0; i < alllookup.length; i++) {
            var lookup = alllookup[i];
            if (lookup.name == type && (index == null || lookup.getAttribute('data-index') == index)) {
                lookup.handleRemove();
            }
        }
    }
    // 选择产品变更
    handleChangeProductOption(resp) {
        var selectProductId;
        if (resp.detail.selectedRecord == undefined || resp.detail.selectedRecord == '') {
            return;
        } else {
            selectProductId = resp.detail.selectedRecord.Id;
        }
        // 判断是否已存在产品
        for (let i = 0; i < this.samplingInspections.length; i++) {
            var item = this.samplingInspections[i];
            if (item.Product__c == selectProductId) {
                this.showError(this.label.INSPECTION_REPORT_MSG_PRODUCT_EXISTS);
                return;
            }
        }
        this.isShowSpinner = true;
        addPlanOutProduct({
            recordJson: JSON.stringify(this.record),
            productId: selectProductId
        }).then(data => {
            if (data.isSuccess) {
                if (data.data.record) {
                    this.record = data.data.record;
                }

                // 只需要整理刷新check list 信息
                this.addCheckResultsInfoDataFormat(data, selectProductId);
           
                this.selectedProductValue = null;
                this.selectedProductInfo = {};
                this.selectedProductInfoIsShow = false;
                // 清空lookup
                this.handleRemoveLookup('onProduct', null);
                this.showSuccess(this.label.PromoterDailyReport_AddNewItemSuccess);

                this.isShowSpinner = false;
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            // 清空lookup
            this.handleRemoveLookup('onProduct', null);
            this.catchError(JSON.stringify(error));
            this.isShowSpinner = false;
        });
    }
    // 选择产品变更（基于产品线）
    handleChangeProductOptionByProductLine(resp) {
        console.log('==========>product change by product line');
        var selectProductId;
        if (resp.detail.selectedRecord == undefined || resp.detail.selectedRecord == '') {
            return;
        } else {
            selectProductId = resp.detail.selectedRecord.Id;
        }
        var index = resp.target.dataset.index;
        // 判断是否已存在产品
        for (let i = 0; i < this.samplingInspections.length; i++) {
            var item = this.samplingInspections[i];
            if (item.Product__c == selectProductId) {
                // this.showError('Product already exists');
                this.showError(this.label.INSPECTION_REPORT_MSG_PRODUCT_EXISTS);
                return;
            }
        }
        this.isShowSpinner = true;
        samplingInspectionAdd({
            recordJson: JSON.stringify(this.record),
            productId: selectProductId
        }).then(data => {
            console.log('---------->data=' + data);
            if (data.isSuccess) {
                if (data.data.record) {
                    this.record = data.data.record;
                }
                // 只需要整理刷新check list 信息
                this.addCheckResultsInfoDataFormat(data, selectProductId);
                // 清空lookup
                this.handleRemoveLookup('onProductLine', index);
                this.showSuccess(this.label.PromoterDailyReport_AddNewItemSuccess);
                this.isShowSpinner = false;
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            // 清空lookup
            this.handleRemoveLookup('onProductLine', index);
            this.catchError(JSON.stringify(error));
            this.isShowSpinner = false;
        });
    }
  
    // Open/Closed Ticket Subject
    handleTicketConfirmChange(event) {
        var index = event.target.dataset.index;
        var type = event.target.dataset.type;
        if (type == 'closed') {
            this.ticketClosedInfo[index].Status__c = event.target.value;
            this.ticketClosedInfo[index].needSave = true;
        } else {
            this.ticketOpenInfo[index].Status__c = event.target.value;
            this.ticketOpenInfo[index].needSave = true;
        }
    }
    // Open Ticket Priority
    handleTicketPriorityChange(event) {
        var index = event.target.dataset.index;
        this.ticketOpenInfo[index].Priority__c = event.target.value;
        this.ticketOpenInfo[index].needSave = true;
    }
    // Open Ticket Subject
    handleTicketSubjectChange(event) {
        var index = event.target.dataset.index;
        this.ticketOpenInfo[index].Subject__c = event.target.value;
        this.ticketOpenInfo[index].needSave = true;
    }
    // Open Ticket Description
    handleTicketDescriptionChange(event) {
        var index = event.target.dataset.index;
        this.ticketOpenInfo[index].Description__c = event.target.value;
        this.ticketOpenInfo[index].needSave = true;
    }
    // added by Sunny about chile department start-[20231026]
    updateLookup(index) {
        var cmps = this.template.querySelectorAll('c-lookup-lwc');
        if (cmps) {
            let userIndex = 0;
            for (let i = 0; i < cmps.length; i++) {
                if (cmps[i].name == 'onUser') {
                    if (userIndex == index) {
                        cmps[i].updateOption({
                            'lookup': 'CustomLookupProvider.DepartmentUserFilter',
                            'department': this.ticketOpenInfo[index].Department__c
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
                if (cmps[i].name == 'onUser') {
                    if (userIndex == index) {
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

    handleTicketDepartmentOnChange(event) {
        console.log('WWW' + JSON.stringify(event));
        var index = event.target.dataset.index;
        console.log('WWWVVV' + event.target.value);
        this.ticketOpenInfo[index].Department__c = event.target.value;
        this.ticketOpenInfo[index].needSave = true;
        // this.updateLookup(index);
        // this.removeLookup(index);
    }

    // added by Sunny about chile department end-[20231026]
    // Open Ticket Assigned To
    handleTicketAssignedToChange(event) {
        var index = event.target.dataset.index;
        // this.ticketOpenInfo[index].AssignedTo__c = event.target.value;
        if (event.detail.selectedRecord == undefined) {
            this.ticketOpenInfo[index].AssignedTo__c = null;
        } else {
            this.ticketOpenInfo[index].AssignedTo__c = event.detail.selectedRecord.Id;
        }
        this.ticketOpenInfo[index].needSave = true;
    }
    // Open Ticket ActivityDate
    handleTicketActivityDateChange(event) {
        var index = event.target.dataset.index;
        var newDate = new Date(event.target.value);
        var today = new Date(this.todayDate);
        if (newDate < today) {
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
    }
   
    // ---------------> ↑ onchange ↑ <---------------
    // ---------------> ↓ function ↓ <---------------
    // 初始化获取数据
    getInitDataBaseRecordId(ele) {
        ele.isShowSpinner = true;
        getInitData({
            recordId: ele.recordId, currentLat: ele.currentLat, currentLong: ele.currentLong, shopId: ele.storeId // wfc 门店没有配置巡店员可显示
        }).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    ele[key] = data.data[key];
                }
              
                // check list格式化
                if (data.data.checkResults) {
                    ele.checkResults = ele.checkCheckResults(data.data.checkResults);
                }
 
                if (ele.recordId || ele.record.Id) {
                    if (ele.record.Status__c == 'Submitted') {
                        ele.isFieldReadOnly = true;
                        ele.isTitleShowButton = false;
                        ele.statusLabel = ele.label.INSPECTION_REPORT_SUBMITED;
                    } else {
                        ele.isTitleShowButton = true;
                    }
                    ele.isEditPage = false;
                } else {
                    ele.isTitleShowButton = false;
                    ele.isFieldReadOnly = true;
                }

                // 是否为巡店员查看
                if (data.data.isReportUser == false) {
                    ele.isTitleShowButton = false;
                }
                // 数据格式化
                ele.dataFormat(data);
                ele.oldReportDate = data.data.record.Report_Date__c;
                // 浮动效果
                ele.start();

                ele.handleUpdateLookup('onShop', null);
                // if(ele.isFilledOut(ele.record.Store__c)){
                //     ele.storeLabel = ele.shopOptions.find(opt => opt.value === ele.record.Store__c).label;
                // }
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
    // 数据整理
    dataFormat(data) {
        // ticket
        if (data.data.ticketClosedInfo == undefined) {
            this.ticketClosedInfo = [];
        }
        if (data.data.ticketOpenInfo == undefined) {
            this.ticketOpenInfo = [];
        }
        if (this.ticketClosedInfo.length > 0) {
            for (let i = 0; i < this.ticketClosedInfo.length; i++) {
                this.ticketClosedInfo[i]['key'] = i + 1;
                this.ticketClosedInfo[i].className = 'slds-table slds-table_bordered slds-table_fixed-layout slds-resizable marketInsightTable ticketTable ' + (i % 2 ? 'table-even' : 'table-odd');
                if (!this.isFilledOut(this.ticketClosedInfo[i].Category__c) || this.ticketClosedInfo[i].Category__c == 'Service') {
                    this.ticketClosedInfo[i].isShowProduct = false;
                } else {
                    this.ticketClosedInfo[i].isShowProduct = true;
                }
            }
        }
        if (this.ticketOpenInfo.length > 0) {
            for (let i = 0; i < this.ticketOpenInfo.length; i++) {
                this.ticketOpenInfo[i]['key'] = i + 1;
                if (this.ticketOpenInfo[i].DueDate__c == undefined) {
                    this.ticketOpenInfo[i].DueDate__c = '';
                }
                this.ticketOpenInfo[i]['oldActivityDate'] = this.ticketOpenInfo.DueDate__c;
                this.ticketOpenInfo[i]['oldActivityDateShow'] = false;

                if (!this.isFilledOut(this.ticketOpenInfo[i].Category__c) || this.ticketOpenInfo[i].Category__c == 'Service') {
                    this.ticketOpenInfo[i].isShowProduct = false;
                } else {
                    this.ticketOpenInfo[i].isShowProduct = true;
                }
                this.ticketOpenInfo[i].disabled = this.isEditPage;
                this.ticketOpenInfo[i].isFieldReadOnly = this.isFieldReadOnly;
                console.log(this.ticketOpenInfo[i]);
            }
        }
        
        //check list
        this.checkResultsInfoDataFormat(data);
    }
    // 整理check list 信息
    checkResultsInfoDataFormat(data) {
        var checkResultsInfo = [];
      
        if (this.samplingInspections.length > 0) {
            // 循环所有sampling
            for (let i = 0; i < this.samplingInspections.length; i++) {
                var checkResultsInfoItem = this.samplingInspections[i];
                //日本删除计划内产品  废番隐藏
                if (this.isJapan && checkResultsInfoItem.Sample_Item__r && checkResultsInfoItem.Sample_Item__r.Sampling_Standard__r &&
                    checkResultsInfoItem.Sample_Item__r.Sampling_Standard__r.Flag__c == true) {
                    continue;
                }
                // 是否已存在对应产品线
                var filteredList = checkResultsInfo.filter(obj => obj.productLine == checkResultsInfoItem.Product__r.Product_Line__c);
                var item;
                // 不存在该产品线，新增产品线
                if (filteredList.length == 0) {
                    item = {
                        //巡店员日报日语翻译  BY lizunxing 20231020
                        productLine: checkResultsInfoItem.Product__r.Product_Line__c,
                        productLineName: this.getProductLineJa(checkResultsInfoItem.Product__r.Product_Line__c),
                        productLookup: {
                            'lookup': 'CustomLookupProvider.ProductFilter',
                            'Product_Line__c': checkResultsInfoItem.Product__r.Product_Line__c
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
                    if (this.checkResults[checkResultsInfoItem.Product__r.Product_Line__c] != undefined) {
                        var checkResultitem = this.checkResults[checkResultsInfoItem.Product__r.Product_Line__c];
                        Object.keys(checkResultitem).forEach(pjObj => {
                            var project = checkResultitem[pjObj];
                            var pj = {
                                project: pjObj,
                                projectItems: project,
                                projectItems_done: project.filter(pr => pr.Scores__c != -1).length,
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
                // 新增出样检查项
                // 计划内出样
                if (checkResultsInfoItem.Unplanned_Sample__c == 'No') {
                    checkResultsInfoItem['index'] = item.samplingInspectionPlanIn.length + 1;
                    if (checkResultsInfoItem.Placement_Status__c == '展出') {
                        checkResultsInfoItem['isChecked'] = true;
                        checkResultsInfoItem['showDetail'] = true;
                    } else {
                        checkResultsInfoItem['isChecked'] = false;
                        checkResultsInfoItem['showDetail'] = false;
                    }

                    item.samplingInspectionPlanOut.push(checkResultsInfoItem);
                }
                // 计划外出样
                if (checkResultsInfoItem.Unplanned_Sample__c == 'Yes') {
                    checkResultsInfoItem['index'] = item.samplingInspectionPlanOut.length + 1;
                    if (checkResultsInfoItem.Placement_Status__c == '展出') {
                        checkResultsInfoItem['isChecked'] = true;
                        checkResultsInfoItem['showDetail'] = true;
                    } else {
                        checkResultsInfoItem['isChecked'] = false;
                        checkResultsInfoItem['showDetail'] = false;
                    }
               
                    item.samplingInspectionPlanOut.push(checkResultsInfoItem);
                }
                // 判断是否存在计划外出样
                if (item.samplingInspectionPlanOut.length > 0) {
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
        this.checkResultsInfo = checkResultsInfo;
    }

    // 新增check list 信息（新增产品必须为计划外，不能影响已修改未保存数据）
    addCheckResultsInfoDataFormat(data, productId) {
        var filterNewSi = data.data.samplingInspections.filter(obj => obj.Product__c == productId);
        
        if (filterNewSi.length > 0) {
            var newProduct = filterNewSi[0];
            this.samplingInspections.push(newProduct);
            var filterNewInfo = this.checkResultsInfo.filter(obj => obj.productLine == newProduct.Product__r.Product_Line__c);
            var item;
            if (filterNewInfo.length == 0) {
                item = {
                    //巡店员日报日语翻译  BY lizunxing 20231020
                    productLine: newProduct.Product__r.Product_Line__c,
                    productLineName: this.getProductLineJa(newProduct.Product__r.Product_Line__c),
                    productLookup: {
                        'lookup': 'CustomLookupProvider.ProductFilter',
                        'Product_Line__c': newProduct.Product__r.Product_Line__c
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
                newProduct['index'] = item.samplingInspectionPlanOut.length + 1;
                if (newProduct.Placement_Status__c == '展出') {
                    newProduct['isChecked'] = true;
                    newProduct['showDetail'] = true;
                } else {
                    newProduct['isChecked'] = false;
                    newProduct['showDetail'] = false;
                }
               
                item.samplingInspectionPlanOut.push(newProduct);
            }
            // 判断是否存在计划外出样
            if (item.samplingInspectionPlanOut.length > 0) {
                item.hasPlanOut = true;
            } else {
                item.hasPlanOut = false;
            }
            // 排序
            var productLineSort = [];
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
            recordJson: JSON.stringify(ele.record), currentLat: ele.currentLat, currentLong: ele.currentLong, shopId: ele.storeId
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
                // 有历史数据，设置签到地图，无历史数据，设置打卡地图
                if (ele.record.Id) {
                    if (ele.record.Status__c == 'Submitted') {
                        ele.isFieldReadOnly = true;
                        ele.isTitleShowButton = false;
                    } else {
                        ele.isTitleShowButton = true;
                    }
                    ele.isEditPage = false;
                } else {
                    if (ele.attendancePhotoStreamInfo) {
                        ele.attendancePhotoStream = 'data:image/jpeg;base64,' + ele.attendancePhotoStreamInfo.slice(1).slice(0, -1);
                    }
                    ele.checkResults = {};
                    ele.isTitleShowButton = false;
                    ele.isFieldReadOnly = true;
                }

                // 数据格式化
                ele.dataFormat(data);
                ele.oldReportDate = data.data.record.Report_Date__c;
                // 浮动效果
                ele.start();

                ele.handleUpdateLookup('onShop', null);
                ele.isShowSpinner = false;

                // if(ele.isFilledOut(ele.record.Store__c)){
                //     ele.storeLabel = ele.shopOptions.find(opt => opt.value === ele.record.Store__c).label;
                // }
            } else {
                ele.isShowSpinner = false;
                ele.showError(data.message);
            }
        }).catch(error => {
            ele.catchError(JSON.stringify(error));
            ele.isShowSpinner = false;
        });
    }
    // 刷新定位
    refreshPositioning(ele) {
        ele.isShowSpinner = true;
        refreshPositioning({
            currentLat: ele.currentLat, currentLong: ele.currentLong, recordDate: ele.record.Report_Date__c,
            shopId: ele.storeId
        }).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    ele[key] = data.data[key];
                }
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
            currentLat: ele.currentLat,
            currentLong: ele.currentLong
        }).then(data => {

            if (data.isSuccess) {
                for (let key in data.data) {
                    ele[key] = data.data[key];
                }
  
                if (data.data.checkResults) {
                    ele.checkResults = ele.checkCheckResults(data.data.checkResults);
                }
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
        this.isShowSpinner = true;

        var copySamplingInspections = JSON.parse(JSON.stringify(this.samplingInspections));
        copySamplingInspections.forEach(obj => {
            delete obj['checkItems'];
        });

        upsertRecord({
            recordJson: JSON.stringify(this.record),
            samplingInspectionJson: JSON.stringify(copySamplingInspections),
            ticketOpenJson: JSON.stringify(this.ticketOpenInfo),
            ticketClosedJson: JSON.stringify(this.ticketClosedInfo),
            ticketOpenFilesMapJson: JSON.stringify(this.ticketOpenFilesMap),
            isSubmit: isSubmit
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
                    this.isFieldReadOnly = true;
                    this.isTitleShowButton = false;
                    this.isEditPage = false;
                } else {
                    this.isEditPage = false;
                    this.isFieldReadOnly = true;
                }

                // 数据格式化
                this.dataFormat(data);
                this.showSuccess(this.label.Inspection_Success);
                // Added By Sunny Start
                // if(data.data.ticketMessage != '') {
                //     this.showWarning(data.data.ticketMessage);
                // }
                // Added By Sunny End

                this.handleUpdateLookup('onShop', null);
                this.isShowSpinner = false;
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            console.log('---------->error=' + JSON.stringify(error));
            this.catchError(error);
            this.isShowSpinner = false;
        });
    }
    // 附件部分
    handleSelectFiles(event) {
        console.log('handleSelectFiles ---> type: ' + event.currentTarget.dataset.type);
        console.log('handleSelectFiles ---> recordid: ' + event.currentTarget.dataset.recordid);
        var type = event.currentTarget.dataset.type;
        var index = event.currentTarget.dataset.recordid;
        if (type == 'ticketOpen') {
            var filesIndex = this.ticketOpenInfo[index].index;
            this.ticketOpenFilesMap[filesIndex] = event.detail.records;
        }
    }
    // 获取当前坐标
    getCurrentPosition(callback) {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                // 测试用，固定坐标
                this.currentLat = position.coords.latitude;
                this.currentLong = position.coords.longitude;
                // this.isShowNewButton = true;
                callback(this);
            }, error => {
                this.isShowSpinner = false;
                this.showError(this.getErrorInfomation(error));
                callback(this);
            }, {
                enableHighAccuracy: true, timeout: 10000
            }
            );
        } else {
            this.isShowSpinner = false;
            this.showError(this.label.INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION);
        }
    }
    // 获取错误信息（坐标用）
    getErrorInfomation(error) {
        switch (error.code) {
            case error.PERMISSION_DENIED:
                return 'PERMISSION_DENIED';
            case error.POSITION_UNAVAILABLE:
                return 'POSITION_UNAVAILABLE';
            case error.TIMEOUT:
                return 'TIMEOUT';
            case error.UNKNOWN_ERROR:
                return 'UNKNOWN_ERROR';
        }
    }
    // ---------------> ↑ function ↑ <---------------
    /*
    * Check List Page
    */
    @track selectedProject = [];
    @track checklistPage = false;
    @track checklistProductline;
    @track checklistProject;
    @track checklistTotalScore = 0;
    @track checklistTotalScoreMax = 0;
    @track checklistAverageScore = 0;
    @track checklistAverageScoreMax = 0;

    get options() {
        return [
            { label: 'Yes', value: 'Y' },
            { label: 'No', value: 'N' },
        ];
    }

    // Check List数据格式化
    itemFormat() {
        if (this.selectedProject.length > 0) {
            for (let i = 0; i < this.selectedProject.length; i++) {
                var item = this.selectedProject[i];
                this.itemFormatCore(item, i);
            }
        }
    }
    itemFormatCore(item, i) {
        item['index'] = i + 1;
        let disPStyle = 'background: white; color: black; width: 50%;'
        if (item.CheckItem__r.IsCountInScore__c == true) {
            item['isButtonOption'] = true;
            var styles = [];
            var buttonwidth = Math.floor(100 / Number(item.CheckItem__r.MaximumScore__c));
            for (let s = 0; s <= Number(item.CheckItem__r.MaximumScore__c); s++) {
                if (item.Scores__c == s) {
                    styles.push({
                        'buttonNumber': s,
                        'style': 'width: ' + buttonwidth + '%;',
                    });
                } else {
                    styles.push({
                        'buttonNumber': s,
                        'style': 'background: white; color: black;' + 'width: ' + buttonwidth + '%;',
                    });
                }
            }
            item['styles'] = styles;
        } else if( item.CheckItem__r.IsYesOrNo__c == true){
            item['isCheckbox'] = true;
            if (item.Scores__c == -1) {
                item['unChecked'] = true;
                item['styleYes'] = disPStyle;
                item['styleNo'] = disPStyle;
            } else if (item.Scores__c == 0) {
                item['isChecked'] = false;
                item['styleYes'] = disPStyle;
                item['styleNo'] = 'width: 50%;';
            } else {
                item['isChecked'] = true;
                item['styleYes'] = 'width: 50%;';
                item['styleNo'] = disPStyle;
            }
        }else if(item.CheckItem__r.Is_Text__c == true){
            // todo wfc
            item['isText'] = true;
        }
        item['fileRequireScores'] = [];
        if (item.CheckItem__r.Scores_require_file__c) {
            var requireScores = item.CheckItem__r.Scores_require_file__c.split(';');
            requireScores.forEach(obj => {
                item['fileRequireScores'].push(Number(obj));
            });

        }
        item['fileMust'] = item['fileRequireScores'].includes(item.Scores__c);
        item['commentRequireScores'] = [];
        if (item.CheckItem__r.Require_Comment_Scores__c) {
            var requireScores = item.CheckItem__r.Require_Comment_Scores__c.split(';');
            requireScores.forEach(obj => {
                item['commentRequireScores'].push(Number(obj));
            });

        }
        item['commentMust'] = item['commentRequireScores'].includes(item.Scores__c);
    }
    // Group Button Click
    groupButtonClick(event) {
        var index = event.target.dataset.index;
        var number = event.target.dataset.number;
        this.selectedProject[Number(index)].Scores__c = Number(number);
        var checkItem = this.selectedProject[Number(index)];
        var buttonwidth = Math.floor(100 / Number(checkItem.CheckItem__r.MaximumScore__c));
        checkItem.styles.forEach(obj => {
            if (obj.buttonNumber == Number(number)) {
                obj.style = 'width: ' + buttonwidth + '%;';
            } else {
                obj.style = 'background: white; color: black;' + 'width: ' + buttonwidth + '%;';
            }
            if (checkItem.Scores__c < checkItem.CheckItem__r.MaximumScore__c) {
                checkItem.isMust = true;
            } else {
                checkItem.isMust = false;
            }
        });
        checkItem.fileMust = checkItem.fileRequireScores.includes(checkItem.Scores__c);
        checkItem.commentMust = checkItem.commentRequireScores.includes(checkItem.Scores__c);
    }
    handleCheckChange(event) {
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
    
    /* Sampling Inspection Page - 废弃*/
    @track siSelectedProductline = [];
    @track siSelectedProductlinePlanOut = [];
    @track samplingInspectionPage = false;
    @track samplingInspectionProductline;
    // Sampling Inspection Checkbox Change
    siCheckboxChange(event) {
        var resultindex = Number(event.target.dataset.resultindex);
        var index = Number(event.target.dataset.index);
        var type = event.target.dataset.type;
        var check = event.target.checked;
        var checkItem;
        var checkResult = [];
        if (type == 'PlanIn') {
            checkItem = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index];
            if (typeof this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].checkItems != 'undefined') {
                checkResult = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].checkItems;
            }
        } else {
            checkItem = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index];
        }
        if (check) {
            checkItem.showDetail = true;
            checkItem.Placement_Status__c = '展出';
            // 出样状态切换 ------ Added By Sunny Start 
            checkItem.isChecked = true;
            for (let index = 0; index < checkResult.length; index++) {
                checkResult[index].ProductNotSampled = false;
            }
            // 出样状态切换 ------ Added By Sunny End
        } else {
            checkItem.showDetail = false;
            checkItem.Placement_Status__c = '未展出';
            // 出样状态切换 ------ Added By Sunny Start 
            checkItem.isChecked = false;
            for (let index = 0; index < checkResult.length; index++) {
                checkResult[index].ProductNotSampled = true;
            }
            // 出样状态切换 ------ Added By Sunny End 
        }
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
    }
    
    siHandleSelectFiles(event) {
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
                obj.isUpdatedFile = true;
            }
        });
    }

    siHandleDeleteFiles(event){
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
                obj.isUpdatedFile = false;
            }
        });
    }

    samplingInspectionChange(event) {
        var resultindex = Number(event.target.dataset.resultindex);
        var fieldName = event.target.dataset.fieldName;
        var index = Number(event.target.dataset.index);
        var type = event.target.dataset.type;
        var value = event.target.value;

        var siId;
        if (type == 'PlanIn') {
            this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index][fieldName] = value;
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanIn[index].Id;
        } else {
            this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index][fieldName] = value;
            siId = this.checkResultsInfo[resultindex].samplingInspectionPlanOut[index].Id;
        }
        this.samplingInspections.forEach(obj => { if (obj.Id == siId) { obj[fieldName] = value; } });
    }

    handleSamplingInspectionDelete(event) {
        var resultindex = Number(event.target.dataset.resultindex);
        var index = Number(event.target.dataset.index);
        var samplingId = event.target.dataset.id;
        var productName = event.target.dataset.name;
        this.handleShow(
            this.label.INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE.format(this.productInfo.Product_Line__c + ' ' + productName),
            'handleSamplingInspectionDeleteHelper',
            { resultindex: resultindex, index: index, samplingId: samplingId, productName: productName });
    }
    async handleSamplingInspectionDeleteHelper(event) {
        var resultindex = event.resultindex;
        var index = event.index;
        var samplingId = event.samplingId;
        var productName = event.productName;
        this.isShowSpinner = true;
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
                        obj.index = newSamplingInspectionPlanOut.length + 1
                        newSamplingInspectionPlanOut.push(obj);
                    }
                });
                this.checkResultsInfo[resultindex].samplingInspectionPlanOut = newSamplingInspectionPlanOut;

                // 重新格式化 CheckResultsInfo.samplingInspectionPlanIn  日本删除计划内产品
                var samplingInspectionPlanIn = this.checkResultsInfo[resultindex].samplingInspectionPlanIn;
                var newSamplingInspectionPlanIn = [];
                samplingInspectionPlanIn.forEach(obj => {
                    if (obj.Id != samplingId) {
                        obj.index = newSamplingInspectionPlanIn.length + 1
                        newSamplingInspectionPlanIn.push(obj);
                    }
                });
                this.checkResultsInfo[resultindex].samplingInspectionPlanIn = newSamplingInspectionPlanIn;
                // 重新格式化 CheckResultsInfo
                var newcheckResultsInfo = [];
                for (let i = 0; i < this.checkResultsInfo.length; i++) {
                    if (this.checkResultsInfo[i].samplingInspection != undefined &&
                        (this.checkResultsInfo[i].samplingInspectionPlanIn.length != 0 || this.checkResultsInfo[i].samplingInspectionPlanOut.length != 0)) {
                        newcheckResultsInfo.push(this.checkResultsInfo[i])
                    } else if (this.checkResultsInfo[i].samplingInspection == undefined) {
                        newcheckResultsInfo.push(this.checkResultsInfo[i])
                    }
                }
                this.checkResultsInfo = newcheckResultsInfo;

                this.isShowSpinner = false;
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            console.log('---------->error=' + error);
            this.catchError(JSON.stringify(error));
            this.isShowSpinner = false;
        });
    }
    // 选择的ProductId
    selectedProductId;
    getSelectedProductId(resp) {
        if (resp.detail.selectedRecord == undefined) {
            this.selectedProductId = null;
        } else {
            this.selectedProductId = resp.detail.selectedRecord.Id;
        }
    }
    // 添加计划外出样
    addProductByLine() {
        // 判断Product是否为空
        if (this.selectedProductId == null) {
            // this.showError('No product selected');
            this.showError(this.label.INSPECTION_REPORT_MSG_NO_PRODUCT_SELECTED);
            return;
        }
        // 判断是否已存在产品
        for (let i = 0; i < this.samplingInspections.length; i++) {
            var item = this.samplingInspections[i];
            if (item.Product__c == this.selectedProductId) {
                // this.showError('Product already exists');
                this.showError(this.label.INSPECTION_REPORT_MSG_PRODUCT_EXISTS);
                return;
            }
        }
        this.isShowSpinner = true;
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
                newitem['index'] = this.siSelectedProductlinePlanOut.length + 1;
                if (newitem.Placement_Status__c == '展出') {
                    newitem['isChecked'] = true;
                    newitem['showDetail'] = true;
                } else {
                    newitem['isChecked'] = false;
                    newitem['showDetail'] = false;
                }
                this.siSelectedProductlinePlanOut.push(newitem);
                this.isShowSpinner = false;
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            console.log('---------->error=' + error);
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
    /*自定义相机页面*/
    @track capturePage = false;
    capturePageInitialization() {
        this.capturePage = true;
    }
    //巡店员日报日语翻译  BY lizunxing 20231020
    getProductLineJa(ele) {
        if ('ja' == this.language) {
            switch (ele) {
                case 'TV':
                    return 'テレビ展示確認';
                case 'Refrigerator':
                    return '冷蔵庫展示確認';
                case 'Freezer':
                    return '冷凍庫';
                case 'WM':
                    return '洗濯機展示確認';
                case 'AC':
                    return 'エアコン';
                case 'Sound Bar':
                    return 'サウンドバー展示確認';
            }
        }
        if (ele == 'Refrigerator') { return 'REF'; }
        return ele;
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
    // Deloitte Yin Mingjie 20231114 end
    //Add By Ethan 20231031
    @track isRemoteInspection = false;//是否远程巡店
    get isShwoRemoteInspectPage() {
        let remoteInspection = 'Remote Inspection';
        let localInspection = 'Locale Inspection';
        if (this.record.Inspect_Type__c == remoteInspection) {
            return true;
        } else {
            return false;
        }
    }
    @track isShowLocalInspection = false;//是否展示现场巡店的页面
    handleInspectType(event) {
        let inspectTypeVal = event.detail.value
        let remoteInspection = 'Remote Inspection';
        let localInspection = 'Locale Inspection';
        this.record.Contact_Person__c = '';
        this.record.Start_Time__c = null;
        if (inspectTypeVal == remoteInspection) {//如果是远程巡店
            this.isShowLocalInspection = false;
            this.record.Inspect_Type__c = inspectTypeVal;
            var d = new Date();
            this.record.Start_Time__c = (d.getHours() < 10 ? '0' + d.getHours() : d.getHours()) + ':' + (d.getMinutes() < 10 ? '0' + d.getMinutes() : d.getMinutes());
        } else if (localInspection == inspectTypeVal) {//如果是现场巡店
            this.isShowLocalInspection = true;
            this.record.Inspect_Type__c = inspectTypeVal;
        } else {
            this.isShowLocalInspection = false;
            this.record.Inspect_Type__c = '';
        }
    }
   
    handleComments(event) {
        let inspectComments = event.detail.value;
        this.record.Comments__c = inspectComments;
    }
    handleContactType(event) {
        let contactType = event.detail.value;
        this.record.Contact_Type__c = contactType;
    }
    handleContactPerson(event) {
        let contactPerson = event.detail.value;
        this.record.Contact_Person__c = contactPerson;
    }
    handleContactStatus(event) {
        let ContactStatus = event.detail.value;
        this.record.Contact_Status__c = ContactStatus;
    }
    
    // By lizunxing 2024-01-02
    handleTicketCategoryChange(event) {
        this.ticketOpenInfo[event.target.dataset.index].Category__c = event.target.value;
        if (event.target.dataset.fieldName == 'Category__c') {
            if (!this.isFilledOut(event.target.value) || event.target.value == 'Service') {
                this.ticketOpenInfo[event.target.dataset.index].isShowProduct = false;
                this.ticketOpenInfo[event.target.dataset.index].Product__c = '';
            } else {
                this.ticketOpenInfo[event.target.dataset.index].isShowProduct = true;
            }
        }
    }

    // By TJP 2024-12-13
    handleTicketCategoryOnChange(event) {
        this.ticketOpenInfo[event.target.dataset.index].Category__c = event.target.value;
        this.ticketOpenInfo[event.target.dataset.index].isShowProduct = false;
        this.ticketOpenInfo[event.target.dataset.index].Product__c = '';  
    }
    isFilledOut(content) {
        if (typeof content == "undefined") {
            return false;
        } else if (content == '' || content == null) {
            return false;
        } else if (typeof content == "number") { return !isNaN(content); }
        return true;
    }
    deleteProductValue(event) {
        let index = event.target.dataset.index;
        if (this.isFilledOut(this.ticketOpenInfo[index].Product__c)) {
            if (this.ticketOpenInfo[index].Product__c.lastIndexOf(',') != -1) {
                this.ticketOpenInfo[index].Product__c = this.ticketOpenInfo[index].Product__c.substr(0, this.ticketOpenInfo[index].Product__c.lastIndexOf(','));
            } else { this.ticketOpenInfo[index].Product__c = ''; }
        }
    }
    // 选择产品变更
    handleChangeProductOptionTicket(event) {
        let index = event.target.dataset.index;
        console.log('handleChangeProductOptionTicket ——> index: ' + index);
        if (event.detail.selectedRecord == undefined) { return; }
        handlerRemove({}).then(data => {
            if (data.isSuccess) { this.handleRemoveLookup('onProduct', index); } else { }
        }).catch(error => { this.catchError(error); });
        if (this.ticketOpenInfo[index].Product__c && this.ticketOpenInfo[index].Product__c != '') {
            if (this.ticketOpenInfo[index].Product__c.indexOf(event.detail.selectedRecord.Name) == -1) {
                this.ticketOpenInfo[index].Product__c = this.ticketOpenInfo[index].Product__c + ',' + event.detail.selectedRecord.Name;
            }
        } else { this.ticketOpenInfo[index].Product__c = event.detail.selectedRecord.Name; }
    }
 

}