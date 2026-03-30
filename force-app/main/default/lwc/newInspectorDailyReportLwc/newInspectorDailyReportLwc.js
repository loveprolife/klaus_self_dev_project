import { track, api, wire } from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import { CurrentPageReference } from 'lightning/navigation';
import common3 from '@salesforce/resourceUrl/common3';
import Id from '@salesforce/user/Id';
import getPickList from '@salesforce/apex/NewInspectorDailyReportController.getPickList';
import LightningConfirm from 'lightning/confirm';
import getInitData from '@salesforce/apex/NewInspectorDailyReportController.getInitData';
import createRecord from '@salesforce/apex/NewInspectorDailyReportController.createRecord';
import refreshPositioning from '@salesforce/apex/NewInspectorDailyReportController.refreshPositioning';
import refreshData from '@salesforce/apex/NewInspectorDailyReportController.refreshData';
import upsertRecord from '@salesforce/apex/NewInspectorDailyReportController.upsertRecord';
import addPlanOutProduct from '@salesforce/apex/NewInspectorDailyReportController.addPlanOutProduct';
import delProductLine from '@salesforce/apex/NewInspectorDailyReportController.delProductLine';
import judgeCountry from '@salesforce/apex/NewPromoterDailyReportActionController.judgeCountry';//Lay add 区分国家
import getStoreDistance from '@salesforce/apex/NewInspectorDailyReportController.getStoreDistance';
import checkListGetInitData from '@salesforce/apex/NewInspectorDailyReportController.checkListGetInitData';
import checkListSave from '@salesforce/apex/NewInspectorDailyReportController.checkListSave';
import samplingInspectionAdd from '@salesforce/apex/NewInspectorDailyReportController.samplingInspectionAdd';
import samplingInspectionDelete from '@salesforce/apex/NewInspectorDailyReportController.samplingInspectionDelete';
import handlerRemove from '@salesforce/apex/NewTicketsController2.handlerRemove';
import deleteTicket from '@salesforce/apex/NewInspectorDailyReportController.deleteTicket';
import getProductSeriesOption from '@salesforce/apex/NewInspectorDailyReportController.getProductSeriesOption';
import refreshUpShop from '@salesforce/apex/NewInspectorDailyReportController.refreshUpShop';
import geolocationGetAddress from '@salesforce/apex/CheckInCheckOutController.geolocationGetAddress';

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
import Position_Correction from '@salesforce/label/c.Position_Correction';
import Coordinate_Description from '@salesforce/label/c.Coordinate_Description';
import Distance from '@salesforce/label/c.Distance';
import Product_Model_Tips from '@salesforce/label/c.Product_Model_Tips';
export default class NewInspectorDailyReportLwc extends LightningNavigationElement {
    lwcName = 'NewInspectorDailyReportLwc';
    label = {
        PromoterDailyReport_DAILY_SALES,
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
        Position_Correction,
        Coordinate_Description,
        Distance,
        Product_Model_Tips
    };
    lwcName = this.label.INSPECTION_REPORT_TITLE;
    /**
     * 初始化 Daily_Inspection_Report__c 标签
     */
    @track dailyInspectionReportInfo = {
        Store__c: '',
        Status__c: '',
        Total_Score__c: '',
        Average_Score__c: '',
        Summary__c: '',
        Inspect_Type__c: '',//Add By Ethan增加巡店类型
        Contact_Person__c: '',
        Contact_Status__c: '',
        Contact_Type__c: '',
        Start_Time__c: '',
        Comments__c: '',
        Brand__c: ''
    };
    @wire(getObjectInfo, { objectApiName: 'Daily_Inspection_Report__c' })
    wiredDailyInspectionReportInfo({ error, data }) {
        if (data) {
            this.dailyInspectionReportInfo = {
                Store__c: data.fields.Store__c.label,
                Status__c: data.fields.Status__c.label,
                Total_Score__c: data.fields.Total_Score__c.label,
                Average_Score__c: data.fields.Average_Score__c.label,
                Summary__c: data.fields.Summary__c.label,
                Inspect_Type__c: data.fields.Inspect_Type__c.label,//Add By Ethan增加巡店类型
                Contact_Person__c: data.fields.Contact_Person__c.label,
                Contact_Status__c: data.fields.Contact_Status__c.label,
                Contact_Type__c: data.fields.Contact_Type__c.label,
                Start_Time__c: data.fields.Start_Time__c.label,
                Comments__c: data.fields.Comments__c.label,
                Brand__c: data.fields.Brand__c.label
            }
        } else if (error) {
            console.log(error);
            this.showError('Daily_Inspection_Report__c getInformation error');
        }
    }
    /**初始化 Sampling_Inspection__c 标签*/
    @track samplingInspectionInfo = {
        ReRe__c: '',
        Quantity_Of_Exhibits_DS__c: '',
        Quantity_Of_Exhibits_OWD__c: '',
        Stock__c: '',
        On_Wall_Display__c: '',
        POP__c: '',
        Is_Prototype_Complete__c: '',
        Is_Built_in_Video__c: '',
        Is_Epos__c: '',
        Price__c: '',
        Display_Stand__c: '',
        Hisense_Rack__c: '',
        Quantity_Hisense__c: '',
        Quantity_POP__c: '',
    };
    @wire(getObjectInfo, { objectApiName: 'Sampling_Inspection__c' })
    wiredSamplingInspectionInfo({ error, data }) {
        if (data) {
            this.samplingInspectionInfo = {
                ReRe__c: data.fields.ReRe__c.label,
                On_Wall_Display__c: data.fields.On_Wall_Display__c.label,
                POP__c: data.fields.POP__c.label,
                Quantity_Of_Exhibits_DS__c: data.fields.Quantity_Of_Exhibits_DS__c.label,
                Quantity_Of_Exhibits_OWD__c: data.fields.Quantity_Of_Exhibits_OWD__c.label,
                Stock__c: data.fields.Stock__c.label,
                Is_Prototype_Complete__c: data.fields.Is_Prototype_Complete__c.label,
                Is_Built_in_Video__c: data.fields.Is_Built_in_Video__c.label,
                Is_Epos__c: data.fields.Is_Epos__c.label,
                Price__c: data.fields.Price__c.label,
                Display_Stand__c: data.fields.Display_Stand__c.label,
                Hisense_Rack__c: data.fields.Hisense_Rack__c.label,
                Quantity_Hisense__c: data.fields.Quantity_Hisense__c.label,
                Quantity_POP__c: data.fields.Quantity_POP__c.label,
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
        Name: ''
    };
    @wire(getObjectInfo, { objectApiName: 'Product__c' })
    wiredProductInfo({ error, data }) {
        if (data) {
            this.productInfo = {
                Product_Line__c: data.fields.Product_Line__c.label, 
                Series__c: data.fields.Series__c.label, 
                Category__c: data.fields.Category__c.label,
                Name: data.fields.Name.label,
            }
        } else if (error) {
            console.log(error); this.showError('Product__c getInformation error');
        }
    }
    /**初始化 Mileage__c 标签*/
    @track mileageInfo = {
        Label: '',
        Start__c: '',
        End__c: '',
        Mileage_Of_Today__c: '',
    };
    @wire(getObjectInfo, { objectApiName: 'Mileage__c' })
    wiredMileageInfo({ error, data }) {
        if (data) {
            this.mileageInfo = {
                Label: data.label,
                Start__c: data.fields.Start__c.label,
                End__c: data.fields.End__c.label,
                Mileage_Of_Today__c: data.fields.Mileage_Of_Today__c.label,
            }
        } else if (error) {
            console.log(error);
            this.showError('Mileage__c getInformation error');
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
        Product__c: '',
        Product_Line__c:'',
        Product_Category__c: ''
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
                Product_Line__c: data.fields.Product_Line__c.label,
                Product_Category__c: data.fields.Product_Category__c.label
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
    @wire(getPickList, { objectName: 'Ticket__c', fieldName: 'Product_Category__c' })
    productCategoryOptions;
    /**初始化 Product Product line Value List*/
    @wire(getPickList, { objectName: 'Product__c', fieldName: 'Product_Line__c' })
    productLineOptions;
    @track showAllPage = true;
    // 打卡地图相关
    @track mapMarkers = [];
    @track showMapMarkers = [];
    // Data相关
    @api recordId;
    @api storeId;
    @api reportDate;

    // 存放门店地址详情信息
    @track storeDistanceInfo;
    // 定位地址详情信息
    @track positionAddress;

    @track showCheckItemIssues = false; // Added By Sunny 
    get isShowItemIssues() {
        return this.isIndonesia || this.isSouthAfrica || this.isChile;
    }
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
    @track storeAddress1;
    @track noteInfo;
    @track phoneInfo;
    @track noteInfoCheckOut;
    @track phoneInfoCheckOut;
    //根据国家隐藏-Lay add
    @track isShowMileage = true;
    @track isShowTotalScore = true;
    @track isShowAverageScore = true;
    @track isShowREMARK = true;
    @track isShowPHOTO = true;
    @track isShowTicket = true;
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
    @track isShowIPC = false;
    @track brandAndProductline = {};
    @track samplingInspectionsArgentina = [];
    @track samplingInspectionsArgentinaShow = [];
    @track brandOptions = [];
    @track ticketAssignedTo = '';
    @track searchProductByProductLineOption = [];
    @track storeMapSkip = false;
    @track productSerierOption = [];
    @track argentinaPL = ''; //产品线
    @track argentinaPS = ''; //产品序列

    @track showAdress = true;

    @track CategoryOption = [
        { label: 'Price', value: 'Price' },
        { label: 'Stock', value: 'Stock' },
        { label: 'Display', value: 'Display' },
        { label: 'Product', value: 'Product' }
    ];

    @track departmentOption = [
        { label: 'Supervisor', value: 'Supervisor' },
        { label: 'Manager', value: 'Manager' },
        { label: 'Marketing', value: 'Marketing' },
        { label: 'Agency', value: 'Agency' },
        { label: 'Product Line Manager', value: 'Product Line Manager' }
    ];

    @wire(CurrentPageReference)
    pageEvent;

    get pageState() {
        return this.pageEvent.state;
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
        if (this.attendanceInformation != null && this.storeId == null && (
            optins.length == 0 ||
            this.isReportUser == false ||
            (this.record.Store__c && this.storeDistanceList.filter(obj => obj.storeId == this.record.Store__c).length == 0))) {
            optins = [{ label: this.attendanceInformation.Shop__r.Name, value: this.attendanceInformation.Shop__c }];
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
    
    get lookupHidden() {
        if (this.record.Status__c == 'Submitted') {
            return true;
        } else {
            return false;
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
                    //东盟YesOrNo计算分数  2024-08-07  lizunxing
                    //if((this.isIndonesia || this.isMalaysia || this.isThailand || this.isVietnam || this.isPhilippines)){
                    if ((this.record.Sales_Region__c == 'Hisense Indonesia' || this.record.Sales_Region__c == 'Hisense Malaysia' || this.record.Sales_Region__c == 'Hisense Thailand' || this.record.Sales_Region__c == 'Hisense Vietnam' || this.record.Sales_Region__c == 'Hisense Philippines')) {
                        if (result.CheckItem__r.IsCountInScore__c == true) {
                            countScore.Total_Score__c += (Number(result.Scores__c) < 0 ? 0 : Number(result.Scores__c));
                            countScore.Total_Score_Max__c += Number(result.CheckItem__r.MaximumScore__c);
                            countScore.Average_Score_Count__c += 1;
                        }
                    } else {
                        if (result.CheckItem__r.IsYesOrNo__c == false && result.CheckItem__r.IsCountInScore__c == true) {
                            countScore.Total_Score__c += (Number(result.Scores__c) < 0 ? 0 : Number(result.Scores__c));
                            countScore.Total_Score_Max__c += Number(result.CheckItem__r.MaximumScore__c);
                            countScore.Average_Score_Count__c += 1;
                        }
                    }
                }
            }
        }
        for (let i = 0; i < this.checkResultsIsRelatedToProduct.length; i++) {
            var crItem = this.checkResultsIsRelatedToProduct[i];

            // 出样状态切换 ------ Added By Sunny Start 
            if (typeof crItem.ProductNotSampled != "undefined" && crItem.ProductNotSampled) {
                continue;
            }
            // 出样状态切换 ------ Added By Sunny End

            if (crItem.CheckItem__r.IsCountInScore__c == true) {
                countScore.Total_Score__c += (Number(crItem.Scores__c) < 0 ? 0 : Number(crItem.Scores__c));
                countScore.Total_Score_Max__c += Number(crItem.CheckItem__r.MaximumScore__c);
                countScore.Average_Score_Count__c += 1;
            }
        }
        if (countScore.Average_Score_Count__c != 0) {
            countScore.Average_Score__c = Number(countScore.Total_Score__c / countScore.Average_Score_Count__c).toFixed(2);
            countScore.Average_Score_Max__c = Number(countScore.Total_Score_Max__c / countScore.Average_Score_Count__c).toFixed(2);
        }
        return countScore;
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

    get isArgentinaEdit() {
        console.log('装填' + (this.pageState && this.pageState.c__skip));
        if(this.pageState && this.pageState.c__skip) {
            this.storeMapSkip = true;
            return true;
        } else {
            this.storeMapSkip = false;
            return this.recordDatereadonly;
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
        this.giveTime();
        if (this.pageState && this.pageState.c__skip) {
            // 执行相关操作
            this.activeSections = ['ticket'];
            this.activeTicketSections = ['open'];
        }
        
        loadStyle(this, common3).then(() => { }).catch((error) => { });
        judgeCountry().then(data => {
            if (data.isSuccess) {

                this.isShowMileage = false;
                
                //巡店员日报当前用户语言  BY lizunxing 20231020
                this.language = data.data.currentUserLanguage;
                // added by Sunny about chile department start-[20231026]
                this.isShowDepartment = (data.data.Chile || data.data.SouthAfrica);
                // added by Sunny about chile department end-[20231026]
                if (!data.data.SouthAfrica) { this.handleInspectType({ detail: { value: 'Locale Inspection' } }) }
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
    @track storeSalesRegion;
    handleEdit() {
        this.isEditPage = true;
        this.isFieldReadOnly = false;
        var storeDetail = this.storeDistanceList.filter(obj => obj.storeId == this.record.Store__c);
        this.storeSalesRegion = storeDetail.length > 0 ? storeDetail[0].salesRegion : '';
        console.log('后台数据' + JSON.stringify(storeDetail));
        console.log('后台数据' + this.storeSalesRegion);
        this.storeLabel = this.shopOptions.find(opt => opt.value === this.record.Store__c).label;
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
                //区分动态产品列表 暂时只对马来做特殊处理
                // if(this.isMalaysia) {
                    this.ticketOpenInfo[i].lookupProductLineFilter = {
                        // 'lookup': 'CustomLookupProvider.productLineTicketFilter',
                        // 'Product_Line__c': this.ticketOpenInfo[i].Product_Line__c
                        'lookup': 'CustomLookupProvider.productTicketFilter',
                        'salesRegion': this.storeSalesRegion,
                        'productCategory': this.ticketOpenInfo[i].Product_Category__c,
                        'productLine': this.ticketOpenInfo[i].Product_Line__c
                    };
                    this.updateProductLineLookup(i);
                    this.ticketOpenInfo[i].isFullLine = false;
                    this.ticketOpenInfo[i].isFullCategory = false;
                // }

                
                console.log(this.ticketOpenInfo[i]);
            }
        }
    }
    // Save click
    handleSave() {
        // 检查必填信息
        var checkResp = { alltrue: true, msg: '' };
        if (this.checkTicket().alltrue == false) {
            checkResp = this.checkTicket();
            this.lwcName = this.label.PromoterDailyReport_TICKET;
        }

        if (checkResp.alltrue == false) {
            this.showWarning(this.label.INSPECTION_REPORT_MSG_REQUIRED + checkResp.msg);
            this.lwcName = this.label.INSPECTION_REPORT_TITLE;
            return;
        }

        if (this.competitorsInformationCheck().alltrue == false) {
            checkResp = this.competitorsInformationCheck();
            this.lwcName = this.label.INSPECTION_REPORT_Competitors_Information;
            this.showWarning(this.label.INSPECTION_REPORT_MSG_REQUIRED + checkResp.msg);
            return;
        }
        if (this.isVietnam) {
            if (this.dssiCheck().alltrue == false) {
                checkResp = this.dssiCheck();
                this.lwcName = this.label.PromoterDailyReport_DAILY_SALES;
                this.showWarning(this.label.INSPECTION_REPORT_MSG_REQUIRED + checkResp.msg);
                return;
            }
        }

        if (this.isArgentina) {
            if (!this.argentinaNotHisense) {
                for (let index = 0; index < this.samplingInspections.length; index++) {
                    let obj = this.samplingInspections[index];
                    if (obj.Display_Stand__c == true && !this.isFilledOut(obj.Quantity_Of_Exhibits_DS__c)) {
                        this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                        this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format('Hisense team - ' + obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.Quantity_Of_Exhibits_DS__c));
                        return;
                    }

                    if (obj.Hisense_Rack__c == true && !this.isFilledOut(obj.Quantity_Hisense__c)) {
                        this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                        this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format('Hisense team - ' + obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.Quantity_Hisense__c));
                        return;
                    }

                    if (obj.Product__r.Product_Line__c == 'TV') {
                        if (obj.On_Wall_Display__c == true && !this.isFilledOut(obj.Quantity_Of_Exhibits_OWD__c)) {
                            this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format('Hisense team - ' + obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.Quantity_Of_Exhibits_OWD__c));
                            this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                            return;
                        }
                    }

                    if (obj.POP__c == true && !this.isFilledOut(obj.Quantity_POP__c)) {
                        this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                        this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format('Hisense team - ' + obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.Quantity_POP__c));
                        return;
                    }
                    // if(this.isFilledOut(obj.Id)){
                    //     if(obj.isChecked == true || obj.On_Wall_Display__c == true){
                    //         if(!this.checkAttachment(Id)){
                    //             this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format('Hisense team - ' + obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.label.INSPECTION_REPORT_ATTACHMENT));
                    //             this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                    //             return;
                    //         }
                    //     }
                    // }else{
                    //     if((obj.isChecked == true || obj.On_Wall_Display__c == true) && obj.isUpdatedFile != true){
                    //         this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format('Hisense team - ' + obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.label.INSPECTION_REPORT_ATTACHMENT));
                    //         this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                    //         return;
                    //     }
                    // }
                };
            } else {
                for (let index = 0; index < this.samplingInspectionsArgentina.length; index++) {
                    let obj = this.samplingInspectionsArgentina[index];
                    if (obj.Placement_Status__c == true && !this.isFilledOut(obj.Quantity_Of_Exhibits_Total__c)) {
                        this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Brand__c + ' - ' + obj.Product_Line__c + ' - ' + this.samplingInspectionInfo.Quantity_Of_Exhibits_DS__c));
                        this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                        return;
                    }

                    // if(this.isFilledOut(obj.Id)){
                    //     if(obj.Placement_Status__c == true){
                    //         if(!this.checkAttachment(Id)){
                    //             this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Brand__c + '-' + obj.Product_Line__c + '-' + this.label.INSPECTION_REPORT_ATTACHMENT));
                    //             this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                    //             return;
                    //         }
                    //     }
                    // }else{
                    //     if(obj.Placement_Status__c == true && obj.isUpdatedFile != true){
                    //         this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Brand__c + '-' + obj.Product_Line__c + '-' + this.label.INSPECTION_REPORT_ATTACHMENT));
                    //         this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                    //         return;
                    //     }
                    // }
                };
            }
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
        if (this.checkTicket().alltrue == false) {
            checkResp = this.checkTicket();
            this.lwcName = this.label.PromoterDailyReport_TICKET;
        }
        if (this.competitorsInformationCheck().alltrue == false) {
            checkResp = this.competitorsInformationCheck();
            this.lwcName = this.label.INSPECTION_REPORT_Competitors_Information;
            this.showWarning(this.label.INSPECTION_REPORT_MSG_REQUIRED + checkResp.msg);
            return;
        }
        if (this.isVietnam) {
            if (this.dssiCheck().alltrue == false) {
                checkResp = this.dssiCheck();
                this.lwcName = this.label.PromoterDailyReport_DAILY_SALES;
                this.showWarning(this.label.INSPECTION_REPORT_MSG_REQUIRED + checkResp.msg);
                return;
            }
        }
        if (this.isArgentina) {
            if (!this.argentinaNotHisense) {
                for (let index = 0; index < this.samplingInspections.length; index++) {
                    let obj = this.samplingInspections[index];
                    if (obj.Display_Stand__c == true && !this.isFilledOut(obj.Quantity_Of_Exhibits_DS__c)) {
                        this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                        this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format('Hisense team - ' + obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.Quantity_Of_Exhibits_DS__c));
                        return;
                    }

                    if (obj.Hisense_Rack__c == true && !this.isFilledOut(obj.Quantity_Hisense__c)) {
                        this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                        this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format('Hisense team - ' + obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.Quantity_Hisense__c));
                        return;
                    }

                    if (obj.Product__r.Product_Line__c == 'TV') {
                        if (obj.On_Wall_Display__c == true && !this.isFilledOut(obj.Quantity_Of_Exhibits_OWD__c)) {
                            this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format('Hisense team -' + obj.Product__r.Product_Line__c + '-' + obj.Product__r.Name + '-' + this.samplingInspectionInfo.Quantity_Of_Exhibits_OWD__c));
                            this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                            return;
                        }
                    }

                    if (obj.POP__c == true && !this.isFilledOut(obj.Quantity_POP__c)) {
                        this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                        this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format('Hisense team - ' + obj.Product__r.Product_Line__c + ' - ' + obj.Product__r.Name + ' - ' + this.samplingInspectionInfo.Quantity_POP__c));
                        return;
                    }
                    
                };
            } else {
                for (let index = 0; index < this.samplingInspectionsArgentina.length; index++) {
                    let obj = this.samplingInspectionsArgentina[index];
                    if (obj.Placement_Status__c == true && !this.isFilledOut(obj.Quantity_Of_Exhibits_Total__c)) {
                        this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Brand__c + '-' + obj.Product_Line__c + '-' + this.samplingInspectionInfo.Quantity_Of_Exhibits_DS__c));
                        this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                        return;
                    }
                    // if(obj.Placement_Status__c == true && obj.isUpdatedFile != true){
                    //     this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(obj.Brand__c + '-' + obj.Product_Line__c + '-' + this.label.INSPECTION_REPORT_ATTACHMENT));
                    //     this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                    //     return;
                    // }
                };
            }
        }
        if (checkResp.alltrue == false) {
            // this.showError('Required information haven’t been maintained. Please fulfil required information first. - ' + checkResp.msg);
            this.showWarning(this.label.INSPECTION_REPORT_MSG_REQUIRED + checkResp.msg);
            this.lwcName = this.label.INSPECTION_REPORT_TITLE;
            return;
        }
        if(!this.isJapan){
            if (this.record.Summary__c == undefined || this.record.Summary__c == null || this.record.Summary__c == '') {
                // this.showError('Summary cannot be blank');
                this.lwcName = this.dailyInspectionReportInfo.Summary__c;
                this.showWarning(this.label.INSPECTION_REPORT_MSG_CANNOT_BLANK.format(this.dailyInspectionReportInfo.Summary__c));
                this.lwcName = this.label.INSPECTION_REPORT_TITLE;
                return;
            }
        }
        this.isShowNewButton = true;
        this.handleSubmitCheckOut();
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
    handleSubmitCheckOut() {
        var find = this.storeDistanceList.find(obj => obj.storeId == this.record.Store__c);
        if (find && this.record.Inspect_Type__c != 'Remote Inspection') {
            getStoreDistance({
                currentLat: this.currentLat,
                currentLong: this.currentLong,
                storeId: find.storeId
            }).then(resp => {
                var distance = resp;
                if (Number(distance) > Number(find.checkInDistance) &&
                    (!this.attendanceRemarkCheckOut || !this.attendancePhotoStreamCheckOut) &&
                    this.isSouthAfrica
                ) {
                    this.showError('Checkout photo and checkout notes cannot be blank.');
                    this.isShowSpinner = false;
                    return;
                } else {
                    this.upsertRecord(true);
                }
            }).catch(error => {
                this.isShowSpinner = true;
                this.showError(error);
            })
        } else { this.upsertRecord(true); }
    }
    // Create click
    async handleCreate() {
        this.isShowSpinner = true;
        var distance = parseInt(this.storeDistance.slice(0, this.storeDistance.length - 1));
        //Add By Ethan 巡店类型必填 20231101
        if (this.record.Inspect_Type__c == '' || this.record.Inspect_Type__c == null || this.record.Inspect_Type__c == undefined) {
            this.showError(this.label.INSPECTION_TYPE_IS_REQUIRED);
            this.isShowSpinner = false;
            return;
        }
        // BFR Yin Mingjie 20231124 start
        if (this.record.Inspect_Type__c != 'Remote Inspection' && this.reportDateIsToday) {
            if ((this.isIndonesia || this.isMalaysia || this.isThailand || this.isVietnam || this.isPhilippines) && this.attendancePhotoStream == null) {
                this.showError(this.label.INSPECTION_REPORT_PLEASE_PHONE); this.isShowSpinner = false;
                return;
                //判断国家  BY lizunxing 20231128
            } else if (this.isJapan && this.attendancePhotoStream == null) {
            } else {
                var find = this.storeDistanceList.find(obj => obj.storeId == this.record.Store__c);
                if (find && find.storeDistance && find.checkInDistance && (Number(find.storeDistance) * 1000) > Number(find.checkInDistance) && this.attendancePhotoStream == null) {
                    this.showError(this.label.INSPECTION_REPORT_PLEASE_PHONE); this.isShowSpinner = false;
                    // todo wfc
                    return;
                }
            }
        }
        // BFR Yin Mingjie 20231124 end
        // 检查是否为计划外门店
        var filteredList = this.storeDistanceList.filter(obj => obj.storeId == this.record.Store__c);
        if (filteredList[0].storeName.charAt(0) == '*') {
            this.getCurrentPosition(this.createRecord);
        } else {
            this.handleShow(// filteredList[0].storeName + ' is an unplanned store, are you sure to create a new inspection report for this date?',
                this.label.INSPECTION_REPORT_MSG_UNPLANNED_STORE.format(filteredList[0].storeName),
                'getCurrentPosition', this.createRecord); this.isShowSpinner = false;
        }
    }
    // Refresh Positioning click
    handleRefreshPositioning() {
        this.getCurrentPosition(this.refreshPositioning);
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
        if (this.selectedProductValue == null || this.selectedProductInfo.Product_Line__c == undefined || this.selectedProductInfo.Product_Line__c == null) {
            // this.showError('No product selected');
            this.showError(this.label.INSPECTION_REPORT_MSG_NO_PRODUCT_SELECTED); return;
        }
        // 判断是否已存在产品
        for (let i = 0; i < this.samplingInspections.length; i++) {
            var item = this.samplingInspections[i];
            if (item.Product__c == this.selectedProductValue) {// this.showError('Product already exists');
                this.showError(this.label.INSPECTION_REPORT_MSG_PRODUCT_EXISTS); return;
            }
        }
        this.isShowSpinner = true;
        addPlanOutProduct({
            recordJson: JSON.stringify(this.record), productJson: JSON.stringify(this.selectedProductInfo)
        }).then(data => {
            if (data.isSuccess) {
                if (data.data.record) { this.record = data.data.record; }
                // Deloitte Yin Mingjie 20231114 start
                if (data.data.checkResults) { this.checkResults = this.checkCheckResults(data.data.checkResults); }
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
            console.log('---------->error=' + error);
            this.catchError(JSON.stringify(error));
            this.isShowSpinner = false;
        });

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
                // 删除非满分自动生成的ticket start 20241024
                if (data.data.delTickets) {
                    var newOpentickets = [];
                    this.ticketOpenInfo.forEach(obj => {
                        if (!data.data.delTickets.includes(obj.Id)) {
                            newOpentickets.push(obj);
                        }
                    });
                    this.ticketOpenInfo = newOpentickets;
                }
                // 删除非满分自动生成的ticket end 20241024
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
            console.log('---------->error=' + error);
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
            this.lwcName = this.label.INSPECTION_REPORT_TITLE;
            return;
        }
        // 新增Ticket
        var key = this.ticketOpenInfo.length + 1;
        var op = {
            // 'lookup': 'CustomLookupProvider.productLineTicketFilter',
            // 'Product_Line__c': ''
            'lookup': 'CustomLookupProvider.productTicketFilter',
            'salesRegion': this.storeSalesRegion,
            'productCategory': '',
            'productLine': ''
        };
        console.log('新增伊始' + this.storeSalesRegion);
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
            Product_Category__c: '',
            SBU__c: this.storeSalesRegion,
            Store__c: this.record.Store__c,
            index: new Date().getTime(),
            needSave: true,
            lookupProductLineFilter : op,
            isFullLine: false,
            isFullCategory: false
            
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
            // if(!this.isArgentina) {
            //     if (this.isFilledOut(obj.Category__c) && obj.Category__c != 'Service') {
            //         if (!this.isFilledOut(obj.Product__c)) {
            //             resp.alltrue = false;
            //             resp.msg = this.TicketInfo.Product__c;
            //             return resp;
            //         }
            //     }
            // }
            //保留南非 产品必填
            if(this.isSouthAfrica) {
                if (!this.isFilledOut(obj.Product__c)) {
                    resp.alltrue = false;
                    resp.msg = this.TicketInfo.Product__c;
                    return resp;
                }
            }
            // console.log('获取校验参数' + this.isArgentina + 'Department' +this.isShowDepartment+ 'obj.Department__c' +obj.Department__c+ ( (obj.AssignedTo__c == '' || obj.AssignedTo__c == null)));
            // added by Sunny about chile department start-[20231026]
            // console.log('获取校验' + ((obj.Department__c == '' || obj.Department__c == null) && (obj.AssignedTo__c == '' || obj.AssignedTo__c == null)));
            // if (this.isArgentina) {
            //     if((obj.Department__c == '' || obj.Department__c == null) && (obj.AssignedTo__c == '' || obj.AssignedTo__c == null)) {
            //         resp.alltrue = false;
            //         resp.msg = Ticket_Fields_Check.format(this.TicketInfo.AssignedTo__c, this.TicketInfo.Department__c);
            //         return resp;
            //     }
            // } else {
                if ((this.isShowDepartment) && (obj.Department__c == '' || obj.Department__c == null) && (obj.AssignedTo__c == '' || obj.AssignedTo__c == null)) {
                    resp.alltrue = false;
                    resp.msg = Ticket_Fields_Check.format(this.TicketInfo.AssignedTo__c, this.TicketInfo.Department__c);
                    return resp;
                }
            // }
            
           

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
            }else{
                if(this.isFilledOut(this.ticketOpenInfo[i].Id)){
                    deleteTicket({
                        id: this.ticketOpenInfo[i].Id
                    }).then(data => {
                    
                    }).catch(error => { 
                        this.catchError(error); 
                    });
                }
                
            }
        }
        for (let i = 0; i < new_list.length; i++) {
            new_list[i].key = i + 1;
        }
        this.ticketOpenInfo = new_list;
    }
    // ---------------> ↑ Button click ↑ <---------------
    // ---------------> ↓ onchange ↓ <---------------
    // 日期变更
    handleChangeReportDate(event) {
        var reportDate = new Date(event.target.value);
        var today = new Date(this.todayDate);
        if (reportDate > today) {
            this.record.Report_Date__c = this.oldReportDate;
            if (this.oldReportDateShow) {
                this.oldReportDateShow = false;
            } else {
                this.oldReportDateShow = true;
            }
            // this.showError('Future date couldn’t be selected for this record.');
            this.showError(this.label.INSPECTION_REPORT_MSG_FUTURE_DATE);
            return;
        } else {
            this.oldReportDate = event.target.value;
            this.record.Report_Date__c = event.target.value;
            this.getCurrentPosition(this.refreshData);
        }
    }
    storeLabel;
    // 门店变更
    handleChangeShopOption(event) {
        this.isShowSpinner = true;
        this.record.Store__c = event.detail.value;
        this.storeLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.getCurrentPosition(this.refreshData);
    }

    // 门店变更
    handleChangeShopOptionArgentina(event) {
        if (event.target.value != '') {
            this.isShowSpinner = true;
            this.record.Store__c = event.detail.value + '';
            // this.storeLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
            this.storeId = event.detail.value + '';
            this.getCurrentPosition(this.refreshData);
        }
    }
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
                // this.showError('Product already exists');
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

                console.log('sssss1' + data.data.productLine);


                // 只需要整理刷新check list 信息
                this.addCheckResultsInfoDataFormat(data, selectProductId);
                // 跳转Sampling Inspection页面
                // this.samplingInspectionGetInitData(this.selectedProductInfo.Product_Line__c);
                // 清空product搜索
                this.selectedProductValue = null;
                this.selectedProductInfo = {};
                this.selectedProductInfoIsShow = false;
                // 清空lookup
                this.handleRemoveLookup('onProduct', null);
                this.showSuccess(this.label.PromoterDailyReport_AddNewItemSuccess);

                //lzx 2024-11-12 阿根廷添加计划外产品时自动展开产品线
                setTimeout(() => {
                    if (this.isArgentina && data.data.productLine) {
                        this.activeSections = [data.data.productLine];
                    }
                }, 50);

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
    // Mileage Start
    handleMileageStartChange(event) {
        this.mileageRecord.Start__c = event.target.value;
    }
    // Mileage End
    handleMileageEndChange(event) {
        this.mileageRecord.End__c = event.target.value;
    }
    // Mileage Blur
    handleMileageBlur(event) {
        if (this.mileageRecord.Start__c == undefined || this.mileageRecord.Start__c == null || this.mileageRecord.Start__c == '') {
            this.mileageRecord.Start__c = 0.00;
        }
        if (this.mileageRecord.End__c == undefined || this.mileageRecord.End__c == null || this.mileageRecord.End__c == '') {
            this.mileageRecord.End__c = 0.00;
        }
        if (Number(this.mileageRecord.End__c) >= Number(this.mileageRecord.Start__c)) {
            this.mileageRecord.Mileage_Of_Today__c = this.mileageRecord.End__c - this.mileageRecord.Start__c;
        } else {
            this.mileageRecord.Mileage_Of_Today__c = this.mileageRecord.End__c - this.mileageRecord.Start__c;
            // this.showError('Mileage End cannot be less than Mileage Start');
            this.showError(this.label.INSPECTION_REPORT_MSG_MILEAGE.format(this.mileageInfo.End__c, this.mileageInfo.Start__c));
        }
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

                // Deloitte Yin Mingjie 20231114 start
                // check list格式化
                if (data.data.checkResults) {
                    ele.checkResults = ele.checkCheckResults(data.data.checkResults);
                }
                // ele.showAdress = (ele.recordId) ? false : true;
      
                // Deloitte Yin Mingjie 20231114 end
                // 有历史数据，设置签到地图，无历史数据，设置打卡地图
                if (ele.recordId || ele.record.Id) {
                    if (ele.record.Status__c == 'Submitted') {
                        ele.isFieldReadOnly = true;
                        ele.isTitleShowButton = false;
                        ele.statusLabel = ele.label.INSPECTION_REPORT_SUBMITED;
                    } else {
                        ele.isTitleShowButton = true;
                    }
                    ele.isEditPage = false;
                    if (ele.record.Inspect_Type__c != 'Remote Inspection') {
                        ele.setShowMapInformation();
                    }

                } else {
                    ele.isTitleShowButton = false;
                    ele.isFieldReadOnly = true;
                    if (ele.record.Inspect_Type__c != 'Remote Inspection') {
                        ele.setMapInformation();
                    }
                }

                if (ele.isArgentina && ele.record.Brand__c && ele.record.Brand__c != 'Hisense') {
                    ele.samplingInspectionsArgentinaShow = [];
                    ele.samplingInspectionsArgentina.forEach(obj => {
                        obj.title = obj.Brand__c + '-' + obj.Product_Line__c;
                        if (obj.Brand__c == ele.record.Brand__c) {
                            ele.samplingInspectionsArgentinaShow.push(obj);
                        }
                    });
                    ele.argentinaNotHisense = true;
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
        if (this.checkResults.General) {
            var checkResultitem = this.checkResults.General;
            var item = {
                productLine: this.label.INSPECTION_REPORT_GENERAL,
                //巡店员日报日语翻译  BY lizunxing 20231020
                productLineName: this.label.INSPECTION_REPORT_GENERAL,
                productLineItem: [],
            };
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
            checkResultsInfo.push(item);
        }
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
                        isTv: checkResultsInfoItem.Product__r.Product_Line__c == 'TV' ? true : false,
                        isShowIPC: (checkResultsInfoItem.Product__r.Product_Line__c == 'Laser TV' || checkResultsInfoItem.Product__r.Product_Line__c == 'Sound Bar' || checkResultsInfoItem.Product__r.Product_Line__c == 'TV') ? true : false,
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
                    if (this.checkResultsIsRelatedToProduct && this.checkResultsIsRelatedToProduct.filter(obj => obj.Sampling_Inspection__c == checkResultsInfoItem.Id).length > 0) {
                        var samplingInspections = this.checkResultsIsRelatedToProduct.filter(obj => obj.Sampling_Inspection__c == checkResultsInfoItem.Id);
                        checkResultsInfoItem['checkItems'] = [];
                        for (let i = 0; i < samplingInspections.length; i++) {
                            var siCheckItem = samplingInspections[i];
                            // 出样状态切换 ------ Added By Sunny Start 
                            if (checkResultsInfoItem.Placement_Status__c != '展出') {
                                siCheckItem['ProductNotSampled'] = true;
                            }
                            // 出样状态切换 ------ Added By Sunny End 
                            siCheckItem['index'] = (i + 1);
                            if (siCheckItem.CheckItem__r.IsYesOrNo__c == false) {
                                siCheckItem['isButtonOption'] = true;
                                var styles = [];
                                var buttonwidth = Math.floor(100 / Number(siCheckItem.CheckItem__r.MaximumScore__c));
                                for (let s = 0; s <= Number(siCheckItem.CheckItem__r.MaximumScore__c); s++) {
                                    if (siCheckItem.Scores__c == s) {
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
                                siCheckItem['styles'] = styles;
                            } else {
                                siCheckItem['isCheckbox'] = true;
                                if (siCheckItem.Scores__c == -1) {
                                    siCheckItem['unChecked'] = true;
                                    siCheckItem['styleYes'] = 'background: white; color: black; width: 50%;';
                                    siCheckItem['styleNo'] = 'background: white; color: black; width: 50%;';
                                } else if (siCheckItem.Scores__c == 0) {
                                    siCheckItem['isChecked'] = false;
                                    siCheckItem['styleYes'] = 'background: white; color: black; width: 50%;';
                                    siCheckItem['styleNo'] = 'width: 50%;';
                                } else {
                                    siCheckItem['isChecked'] = true;
                                    siCheckItem['styleYes'] = 'width: 50%;';
                                    siCheckItem['styleNo'] = 'background: white; color: black; width: 50%;';
                                }
                            }
                            siCheckItem['fileRequireScores'] = [];
                            if (siCheckItem.CheckItem__r.Scores_require_file__c) {
                                var requireScores = siCheckItem.CheckItem__r.Scores_require_file__c.split(';');
                                requireScores.forEach(obj => {
                                    siCheckItem['fileRequireScores'].push(Number(obj));
                                });
                            }
                            siCheckItem['fileMust'] = siCheckItem['fileRequireScores'].includes(siCheckItem.Scores__c);
                            siCheckItem['commentRequireScores'] = [];
                            if (siCheckItem.CheckItem__r.Require_Comment_Scores__c) {
                                var requireScores = siCheckItem.CheckItem__r.Require_Comment_Scores__c.split(';');
                                requireScores.forEach(obj => {
                                    siCheckItem['commentRequireScores'].push(Number(obj));
                                });
                            }
                            siCheckItem['commentMust'] = siCheckItem['commentRequireScores'].includes(siCheckItem.Scores__c);
                            checkResultsInfoItem.checkItems.push(siCheckItem);
                        }
                    }
                    item.samplingInspectionPlanIn.push(checkResultsInfoItem);
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
                    if (this.checkResultsIsRelatedToProduct && this.checkResultsIsRelatedToProduct.filter(obj => obj.Sampling_Inspection__c == checkResultsInfoItem.Id).length > 0) {
                        var samplingInspections = this.checkResultsIsRelatedToProduct.filter(obj => obj.Sampling_Inspection__c == checkResultsInfoItem.Id);
                        checkResultsInfoItem['checkItems'] = [];
                        for (let i = 0; i < samplingInspections.length; i++) {
                            var siCheckItem = samplingInspections[i];
                            siCheckItem['index'] = (i + 1);
                            if (siCheckItem.CheckItem__r.IsYesOrNo__c == false) {
                                siCheckItem['isButtonOption'] = true;
                                var styles = [];
                                var buttonwidth = Math.floor(100 / Number(siCheckItem.CheckItem__r.MaximumScore__c));
                                for (let s = 0; s <= Number(siCheckItem.CheckItem__r.MaximumScore__c); s++) {
                                    if (siCheckItem.Scores__c == s) {
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
                                siCheckItem['styles'] = styles;
                            } else {
                                siCheckItem['isCheckbox'] = true;
                                if (siCheckItem.Scores__c == -1) {
                                    siCheckItem['unChecked'] = true;
                                    siCheckItem['styleYes'] = 'background: white; color: black; width: 50%;';
                                    siCheckItem['styleNo'] = 'background: white; color: black; width: 50%;';
                                } else if (siCheckItem.Scores__c == 0) {
                                    siCheckItem['isChecked'] = false;
                                    siCheckItem['styleYes'] = 'background: white; color: black; width: 50%;';
                                    siCheckItem['styleNo'] = 'width: 50%;';
                                } else {
                                    siCheckItem['isChecked'] = true;
                                    siCheckItem['styleYes'] = 'width: 50%;';
                                    siCheckItem['styleNo'] = 'background: white; color: black; width: 50%;';
                                }
                            }
                            siCheckItem['fileRequireScores'] = [];
                            if (siCheckItem.CheckItem__r.Scores_require_file__c) {
                                var requireScores = siCheckItem.CheckItem__r.Scores_require_file__c.split(';');
                                requireScores.forEach(obj => {
                                    siCheckItem['fileRequireScores'].push(Number(obj));
                                });
                            }
                            siCheckItem['fileMust'] = siCheckItem['fileRequireScores'].includes(siCheckItem.Scores__c);
                            siCheckItem['commentRequireScores'] = [];
                            if (siCheckItem.CheckItem__r.Require_Comment_Scores__c) {
                                var requireScores = siCheckItem.CheckItem__r.Require_Comment_Scores__c.split(';');
                                requireScores.forEach(obj => {
                                    siCheckItem['commentRequireScores'].push(Number(obj));
                                });
                            }
                            siCheckItem['commentMust'] = siCheckItem['commentRequireScores'].includes(siCheckItem.Scores__c);
                            checkResultsInfoItem.checkItems.push(siCheckItem);
                        }
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
    // Group Button Click - 出样
    siGroupButtonClick(event) {
        var productline = event.target.dataset.productline;
        var inorout = event.target.dataset.inorout;
        var samplinginspectionid = event.target.dataset.samplinginspectionid;
        var checkitemid = event.target.dataset.checkitemid;
        var number = event.target.dataset.number;
        // 定位
        var checkItem_filterItem = this.checkResultsInfoFilter(productline, inorout, samplinginspectionid, checkitemid);
        var buttonwidth = Math.floor(100 / Number(checkItem_filterItem.CheckItem__r.MaximumScore__c));
        checkItem_filterItem.styles.forEach(obj => {
            if (obj.buttonNumber == Number(number)) {
                obj.style = 'width: ' + buttonwidth + '%;';
            } else {
                obj.style = 'background: white; color: black;' + 'width: ' + buttonwidth + '%;';
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
        if (updateCr.length > 0) {
            updateCr[0].Scores__c = Number(number);
        }
    }
    // Checkbox Change - 出样
    siCheckboxChangeClick(event) {
        var productline = event.target.dataset.productline;
        var inorout = event.target.dataset.inorout;
        var samplinginspectionid = event.target.dataset.samplinginspectionid;
        var checkitemid = event.target.dataset.checkitemid;
        var type = event.target.dataset.type;
        // 定位
        var checkItem_filterItem = this.checkResultsInfoFilter(productline, inorout, samplinginspectionid, checkitemid);
        if (type == 'yes') {
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
        if (updateCr.length > 0) {
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
        var checkItem_filterItem = this.checkResultsInfoFilter(productline, inorout, samplinginspectionid, checkitemid);
        checkItem_filterItem.Comments__c = value;
    }
    checkResultsInfoFilter(productline, inorout, samplinginspectionid, checkitemid) {
        var checkResultsInfo_filter = this.checkResultsInfo.filter(obj => obj.productLine == productline);
        if (checkResultsInfo_filter.length == 0) {
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
        if (samplingInspection_filter.length == 0) {
            return;
        }
        var samplingInspection_filterItem = samplingInspection_filter[0];
        var checkItem_filter = samplingInspection_filterItem.checkItems.filter(obj => obj.Id == checkitemid);
        if (checkItem_filter.length == 0) {
            return;
        }
        var checkItem_filterItem = checkItem_filter[0];
        return checkItem_filterItem;
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
                    isTv: newProduct.Product__r.Product_Line__c == 'TV' ? true : false,
                    isShowIPC: (newProduct.Product__r.Product_Line__c == 'Laser TV' || newProduct.Product__r.Product_Line__c == 'Sound Bar' || newProduct.Product__r.Product_Line__c == 'TV') ? true : false,
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
                if (data.data.checkResults[newProduct.Product__r.Product_Line__c] != undefined) {
                    var checkResultitem = data.data.checkResults[newProduct.Product__r.Product_Line__c];
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
                // 
                //为计划外出样添加checkitem
                let checkItems = [];
                for (let prodLine in data.data.checkResults) {
                    for (let project in data.data.checkResults[prodLine]) {
                        for (let index = 0; index < data.data.checkResults[prodLine][project].length; index++) {
                            let element = data.data.checkResults[prodLine][project][index];
                            if (newProduct.Id === element.Sampling_Inspection__c) {
                                checkItems.push(element);
                            }
                        }
                    }
                }
                for (let index = 0; index < data.data.checkResultsIsRelatedToProduct.length; index++) {
                    let element = data.data.checkResultsIsRelatedToProduct[index];
                    if (newProduct.Id === element.Sampling_Inspection__c) {
                        checkItems.push(element);
                        this.checkResultsIsRelatedToProduct.push(element);
                    }
                }
                for (let index = 0; index < checkItems.length; index++) {
                    let element = checkItems[index];
                    this.itemFormatCore(element, index);
                }
                newProduct.checkItems = checkItems;
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
        ele.giveTime();
        ele.isShowSpinner = true;
        refreshData({
            recordJson: JSON.stringify(ele.record), currentLat: ele.currentLat, currentLong: ele.currentLong, contentVersionId: ele.contentVersionId,
            shopId: ele.storeId
        }).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    ele[key] = data.data[key];
                }
                console.log('wwwwpositionAddress' + JSON.stringify(ele.positionAddress));
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
                    console.log('执行到这===========' + ele.record.Inspect_Type__c);
                    if (ele.record.Inspect_Type__c != 'Remote Inspection') {
                        ele.setShowMapInformation();
                    }
                } else {
                    if (ele.attendancePhotoStreamInfo) {
                        ele.attendancePhotoStream = 'data:image/jpeg;base64,' + ele.attendancePhotoStreamInfo.slice(1).slice(0, -1);
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

                if (ele.isArgentina && ele.record.Brand__c && ele.record.Brand__c != 'Hisense') {
                    ele.samplingInspectionsArgentinaShow = [];
                    ele.samplingInspectionsArgentina.forEach(obj => {
                        obj.title = obj.Brand__c + '-' + obj.Product_Line__c;
                        if (obj.Brand__c == ele.record.Brand__c) {
                            ele.samplingInspectionsArgentinaShow.push(obj);
                        }
                    });
                    ele.argentinaNotHisense = true;
                }

                // 是否为巡店员查看
                if (data.data.isReportUser == false) {
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

                // YYL 设置最近的一个门店信息
                ele.record.Store__c = data.data.storeId;
                ele.setMapInformation();
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
            currentLat: ele.currentLat,
            currentLong: ele.currentLong
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
                ele.funIsRemoteInspection();
                //如果是远程巡店 则不需要显示地图 不需要初始化地图信息 20231101
                if (ele.record.Inspect_Type__c != 'Remote Inspection') {
                    ele.setShowMapInformation();
                }
                // 清空打卡信息
                ele.attendanceShowPhoto = false;
                ele.attendancePhotoStream = null;
                ele.attendanceRemark = null;
                // 是否为巡店员查看
                if (data.data.isReportUser == false) {
                    ele.ownerName = data.data.attendanceInformation.CreatedBy.Name;
                    ele.isTitleShowButton = false;
                }

                if (ele.isArgentina && ele.record.Brand__c && ele.record.Brand__c != 'Hisense') {
                    ele.samplingInspectionsArgentinaShow = [];
                    ele.samplingInspectionsArgentina.forEach(obj => {
                        obj.title = obj.Brand__c + '-' + obj.Product_Line__c;
                        if (obj.Brand__c == ele.record.Brand__c) {
                            ele.samplingInspectionsArgentinaShow.push(obj);
                        }
                    });
                    ele.argentinaNotHisense = true;
                }

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
        for (let index = 0; index < copyCheckResultsIsRelatedToProduct.length; index++) {
            let obj = copyCheckResultsIsRelatedToProduct[index];
            if (typeof obj['ProductNotSampled'] != "undefined") {
                if (obj.ProductNotSampled) {
                    if (isSubmit) {
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
            if (this.isArgentina && obj.Product__r.Product_Line__c == 'TV') {
                if (obj.Display_Stand__c == true || obj.On_Wall_Display__c == true) {
                    obj.Placement_Status__c = '展出';
                } else {
                    obj.Placement_Status__c = '未展出';
                }
            }
        });
        const cleanedArray = this.ticketOpenInfo.map(item => {
          const { lookupProductLineFilter, ...rest } = item;
          return rest;
        });

        // console.log('获知参数传递' + JSON.stringify(this.ticketOpenInfo));
        // console.log('获知修改后的参数传递' + JSON.stringify(cleanedArray));
        upsertRecord({
            recordJson: JSON.stringify(this.record),
            samplingInspectionJson: JSON.stringify(copySamplingInspections),
            samplingInspectionsArgentinaJson: JSON.stringify(this.samplingInspectionsArgentina),
            ticketOpenJson: JSON.stringify(cleanedArray),
            ticketClosedJson: JSON.stringify(this.ticketClosedInfo),
            ticketOpenFilesMapJson: JSON.stringify(this.ticketOpenFilesMap),
            mileageRecordJson: JSON.stringify(this.mileageRecord),
            checkResultsIsRelatedToProductJson: JSON.stringify(copyCheckResultsIsRelatedToProduct),
            isSubmit: isSubmit,
            attendancePhotoStreamJson: this.attendancePhotoStreamCheckOut,
            attendanceRemark: this.attendanceRemarkCheckOut
        }).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    this[key] = data.data[key];
                }
                this.funIsRemoteInspection();
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

                //阿根廷竞品信息
                if (this.isArgentina && !this.argentinaNotHisense) {
                    this.saveCompetitorsInformationts();
                }

                if (this.isVietnam) {
                    this.saveDssi();
                }

                // 数据格式化
                this.dataFormat(data);
                this.showSuccess('success');
                // Added By Sunny Start
                // if(data.data.ticketMessage != '') {
                //     this.showWarning(data.data.ticketMessage);
                // }
                // Added By Sunny End
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
    // 设置地图相关信息（打卡Map用）
    setMapInformation() {
        for (let i = 0; i < this.storeDistanceList.length; i++) {
            var storeDistanceItem = this.storeDistanceList[i];
            if (this.record.Store__c != null && this.record.Store__c != '' && this.record.Store__c == storeDistanceItem.storeId) {
                this.storeName = storeDistanceItem.storeName;
                this.storeDistance = storeDistanceItem.storeDistanceStr;
                this.mapMarkers = [
                    {
                        location: {
                            Latitude: storeDistanceItem.storeLat,
                            Longitude: storeDistanceItem.storeLong,
                        },
                        value: storeDistanceItem.storeId,
                    },
                    {
                        location: {
                            Latitude: this.currentLat,
                            Longitude: this.currentLong,
                        },
                        value: 'user',
                        mapIcon: {
                            path: 'M50,10 A40,40 0 1,1 50,90 A40,40 0 1,1 50,10 Z',
                            fillColor: '#007FFF',
                            fillOpacity: .8,
                            strokeWeight: 0,
                            strokeColor: '#007FFF',
                            strokeOpacity: 1,
                            scale: .2,
                            anchor: { x: 45, y: 45 }
                        },
                    },
                    {
                        location: {
                            Latitude: this.currentLat,
                            Longitude: this.currentLong,
                        },
                        value: 'circle',
                        type: 'Circle',
                        radius: storeDistanceItem.checkInDistance,
                        strokeColor: '#00FF00',
                        strokeOpacity: 0.8,
                        strokeWeight: 2,
                        fillColor: '#00FF00',
                        fillOpacity: 0.2,
                    },
                ];
            }
        }
    }
    // 设置地图相关信息（显示Map用）
    setShowMapInformation() {
        if (this.record.NeedCheckIn__c) {
            this.shopInfo = this.attendanceInformation.Shop__r.Name;
            this.recordedInfo = this.attendanceInformationHandHelper.checkInTime;
            this.distanceInfo = Math.round(this.attendanceInformation.Distance__c);
            this.storeAddress1 = this.attendanceInformation.Shop__r.Address1__c; 
            this.noteInfo = this.attendanceInformation.Remark__c;
            //this.phoneInfo = 'data:image/jpeg;base64,'+this.attendanceInformationHandHelper.phoneBase64.slice(1).slice(0,-1);
            if (this.attendanceInformationHandHelper != null && this.attendanceInformationHandHelper.phoneBase64) {
                this.phoneInfo = 'data:image/jpeg;base64,' + this.attendanceInformationHandHelper.phoneBase64.slice(1).slice(0, -1);
            }
            this.noteInfoCheckOut = this.attendanceInformationCheckOut.Remark__c;
            //this.phoneInfo = 'data:image/jpeg;base64,'+this.attendanceInformationHandHelper.phoneBase64.slice(1).slice(0,-1);
            if (this.attendanceInformationCheckOutHandHelper != null && this.attendanceInformationCheckOutHandHelper.phoneBase64) {
                this.phoneInfoCheckOut = 'data:image/jpeg;base64,' + this.attendanceInformationCheckOutHandHelper.phoneBase64.slice(1).slice(0, -1);
            }
            var radius = 0;
            var filteredList = this.storeDistanceList.filter(obj => obj.storeId == this.attendanceInformation.Shop__c);
            if (filteredList.length > 0) {
                this.storeSalesRegion = filteredList[0].salesRegion;
                radius = filteredList[0].checkInDistance;
            }
            this.showMapMarkers = [
                {
                    location: {
                        Latitude: this.attendanceInformation.Shop__r.Shop_Center_Location__Latitude__s,
                        Longitude: this.attendanceInformation.Shop__r.Shop_Center_Location__Longitude__s,
                    },
                    value: this.attendanceInformation.Shop__c,
                },
                {
                    location: {
                        Latitude: this.attendanceInformation.Location__Latitude__s,
                        Longitude: this.attendanceInformation.Location__Longitude__s,
                    },
                    value: 'user',
                    mapIcon: {
                        path: 'M50,10 A40,40 0 1,1 50,90 A40,40 0 1,1 50,10 Z',
                        fillColor: '#007FFF',
                        fillOpacity: .8,
                        strokeWeight: 0,
                        strokeColor: '#007FFF',
                        strokeOpacity: 1,
                        scale: .2,
                        anchor: { x: 45, y: 45 }
                    },
                },
                {
                    location: {
                        Latitude: this.attendanceInformation.Location__Latitude__s,
                        Longitude: this.attendanceInformation.Location__Longitude__s,
                    },
                    value: 'circle',
                    type: 'Circle',
                    radius: radius,
                    strokeColor: '#00FF00',
                    strokeOpacity: 0.8,
                    strokeWeight: 2,
                    fillColor: '#00FF00',
                    fillOpacity: 0.2,
                },
            ];
        } else {
            this.noteInfo = this.record.Note__c;
            //this.phoneInfo = 'data:image/jpeg;base64,'+this.attendanceInformationHandHelper.phoneBase64.slice(1).slice(0,-1);
            if (this.attendanceInformationHandHelper != null && this.attendanceInformationHandHelper.phoneBase64) {
                this.phoneInfo = 'data:image/jpeg;base64,' + this.attendanceInformationHandHelper.phoneBase64.slice(1).slice(0, -1);
            }
            var radius = 0;
            var filteredList = this.storeDistanceList.filter(obj => obj.storeId == this.record.Store__c);
            if (filteredList.length > 0) {

                this.storeSalesRegion = filteredList[0].salesRegion;
                this.showMapMarkers = [
                    {
                        location: {
                            Latitude: Number(filteredList[0].storeLat),
                            Longitude: Number(filteredList[0].storeLong),
                        },
                        value: filteredList[0].storeId,
                    }
                ];
            }
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
    get checkListCountScore() {
        var checkListCountScore = {
            checklistTotalScore: 0,
            checklistTotalScoreMax: 0,
            checklistAverageScore: 0,
            checklistAverageScoreMax: 0,
        };
        var checklistScoreCount = 0;
        for (let i = 0; i < this.selectedProject.length; i++) {
            var item = this.selectedProject[i];
            if ((this.record.Sales_Region__c == 'Hisense Indonesia' || this.record.Sales_Region__c == 'Hisense Malaysia' || this.record.Sales_Region__c == 'Hisense Thailand' || this.record.Sales_Region__c == 'Hisense Vietnam' || this.record.Sales_Region__c == 'Hisense Philippines')) {
                if (item.CheckItem__r.IsCountInScore__c == true) {
                    checkListCountScore.checklistTotalScore += (Number(item.Scores__c) < 0 ? 0 : Number(item.Scores__c));
                    checkListCountScore.checklistTotalScoreMax += Number(item.CheckItem__r.MaximumScore__c);
                    checklistScoreCount += 1;
                }
            } else {
                if (item.CheckItem__r.IsYesOrNo__c == false && item.CheckItem__r.IsCountInScore__c == true) {
                    checkListCountScore.checklistTotalScore += (Number(item.Scores__c) < 0 ? 0 : Number(item.Scores__c));
                    checkListCountScore.checklistTotalScoreMax += Number(item.CheckItem__r.MaximumScore__c);
                    checklistScoreCount += 1;
                }
            }
        }
        if (checklistScoreCount != 0) {
            checkListCountScore.checklistAverageScore = Number(checkListCountScore.checklistTotalScore / checklistScoreCount).toFixed(2);
            checkListCountScore.checklistAverageScoreMax = Number(checkListCountScore.checklistTotalScoreMax / checklistScoreCount).toFixed(2);
        }
        return checkListCountScore;
    }
    get options() {
        return [
            { label: 'Yes', value: 'Y' },
            { label: 'No', value: 'N' },
        ];
    }
    // CheckList页面初始化
    checkListGetInitData(productline, project) {
        this.checklistProductline = productline;
        this.checklistProject = project;
        this.isShowSpinner = true;
        checkListGetInitData({
            recordId: this.record.Id,
            productline: productline == this.label.INSPECTION_REPORT_GENERAL ? null : productline,
            project: project
        }).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    this[key] = data.data[key];
                }
                this.itemFormat();
                this.checklistPage = true;
                // 浮动效果
                this.start();
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
                var summary = this.record.Summary__c;
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

                this.showSuccess('success');
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
 
    handleChangeProductLineOption(event) {
        this.ticketOpenInfo[event.target.dataset.index].Product_Line__c = event.target.value;
    }

    handleChangePLOption(event) {

        this.argentinaPL = event.detail.value;
        this.argentinaPS = '';

        getProductSeriesOption({
            productLine: this.argentinaPL
        }).then(data => {
            this.productSerierOption = data.data;
        }).catch(error => {
            console.log('---------->error=' + error);
        });

        
        var cmps = this.template.querySelectorAll('c-lookup-lwc');
        if (cmps) {
            for (let i = 0; i < cmps.length; i++) {
                if (cmps[i].name == 'onProduct') {
                    cmps[i].updateOption({
                        'lookup': 'CustomLookupProvider.ArgentinaProductFilter',
                        'argentinaPL': this.argentinaPL,
                        'argentinaPS': this.argentinaPS
                    });
                    cmps[i].handleRemove();
                    break;
                }
            }
        }
    }

    handleChangePSOption(event) {
        this.argentinaPS = event.detail.value;
        var cmps = this.template.querySelectorAll('c-lookup-lwc');
        if (cmps) {
            for (let i = 0; i < cmps.length; i++) {
                if (cmps[i].name == 'onProduct') {
                    cmps[i].updateOption({
                        'lookup': 'CustomLookupProvider.ArgentinaProductFilter',
                        'argentinaPL': this.argentinaPL,
                        'argentinaPS': this.argentinaPS
                    });
                    cmps[i].handleRemove();
                    break;
                }
            }
        }
    }
 
    handleChangeBrandOption(event) {
        if (!this.isFilledOut(event.detail.value)) {
            return;
        }
        this.record.Brand__c = event.detail.value;
        this.samplingInspectionsArgentinaShow = [];
        if (this.record.Brand__c == 'Hisense') {
            this.argentinaNotHisense = false;
        } else {
            this.argentinaNotHisense = true;
            this.samplingInspectionsArgentina.forEach(obj => {
                obj.title = obj.Brand__c + '-' + obj.Product_Line__c;
                if (obj.Brand__c == this.record.Brand__c) {
                    this.samplingInspectionsArgentinaShow.push(obj);
                }
            });
            if (this.samplingInspectionsArgentinaShow.length == 0) {
                this.brandAndProductline[this.record.Brand__c].forEach(obj => {
                    let item = {
                        title: this.record.Brand__c + '-' + obj,
                        Brand__c: this.record.Brand__c,
                        Daily_Inspection_Report__c: this.recordId,
                        Product_Line__c: obj,
                        Quantity_Of_Exhibits_Total__c: null,
                        Placement_Status__c: false,
                        POP__c: false,
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
        this.argChange('POP__c', type, value);
    }
    argChange(fieldName, type, value) {
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
    argHandleSelectFiles(event) {
        var type = event.target.dataset.type;
        this.argChange('isUpdatedFile', type, true);
    }
    siPOPChange(event) {
        this.samplingInspectionChange(event, 'POP__c', true);
    }
    siIsPrototypeCompleteChange(event) {
        this.samplingInspectionChange(event, 'Is_Prototype_Complete__c', true);
    }
    siIsBuiltinVideoChange(event) {
        this.samplingInspectionChange(event, 'Is_Built_in_Video__c', true);
    }
    siIsEposChange(event) {
        this.samplingInspectionChange(event, 'Is_Epos__c', true);
    }
    siHisenseRackChange(event) {
        this.samplingInspectionChange(event, 'Hisense_Rack__c', true);
    }
    siOnWallDisplayChange(event) {
        this.samplingInspectionChange(event, 'On_Wall_Display__c', true);
    }
    siDisplayStatusChange(event) {
        this.samplingInspectionChange(event, 'Display_Stand__c', true);
    }
    siQuantityOfExhibitsDSChange(event) {
        this.samplingInspectionChange(event, 'Quantity_Of_Exhibits_DS__c', false);
    }
    siQuantityHisenseChange(event) {
        this.samplingInspectionChange(event, 'Quantity_Hisense__c', false);
    }
    siQuantityOfExhibitsOWDChange(event) {
        this.samplingInspectionChange(event, 'Quantity_Of_Exhibits_OWD__c', false);
    }
    siStockChange(event) {
        this.samplingInspectionChange(event, 'Stock__c', false);
    }
    siQuantityPOPChange(event) {
        this.samplingInspectionChange(event, 'Quantity_POP__c', false);
    }
    siPriceChange(event) {
        this.samplingInspectionChange(event, 'Price__c', false);
    }

    samplingInspectionChange(event, fieldName, isCheckbox) {
        var resultindex = Number(event.target.dataset.resultindex);
        var index = Number(event.target.dataset.index);
        var type = event.target.dataset.type;
        var value;
        if (isCheckbox) {
            value = event.target.checked;
        } else {
            value = event.target.value;
        }
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
                // 删除非满分自动生成的ticket start 20241024
                if (data.data.delTickets) {
                    var newOpentickets = [];
                    this.ticketOpenInfo.forEach(obj => {
                        if (!data.data.delTickets.includes(obj.Id)) {
                            newOpentickets.push(obj);
                        }
                    });
                    this.ticketOpenInfo = newOpentickets;
                }
                // 删除非满分自动生成的ticket end 20241024

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
    get isRecordRemoteInspectPage() {
        if (this.record.Inspect_Type__c == 'Remote Inspection') {
            return true;
        } else {
            return false;
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
    //是否远程巡店，是否不显示Map
    funIsRemoteInspection() {
        if (this.record.Inspect_Type__c == 'Remote Inspection') {
            this.isRemoteInspection = true;
        }
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
    showAllFun() {
        this.showCapture = false;
        var tmp = this.template.querySelector('.slds-is-relative');
        if (tmp) {
            tmp.classList.remove('slds-hide');
            tmp.classList.add('slds-show');
        }
    }
    hideAllFun() {
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
        this.showAllPage = true;
        this.activeSections = [];
    }
    // Added By Sunny End
    handleTicketPriorityChange(event) {
        var index = event.target.dataset.index;
        this.ticketOpenInfo[index].Priority__c = event.target.value;
    }
    // By lizunxing 2024-01-02
    handleTicketCategoryChange(event) {
        this.ticketOpenInfo[event.target.dataset.index].Category__c = event.target.value;
        //20250806 TJP废弃
        // if (event.target.dataset.fieldName == 'Category__c') {
        //     if (!this.isFilledOut(event.target.value) || event.target.value == 'Service') {
        //         this.ticketOpenInfo[event.target.dataset.index].isShowProduct = false;
        //         this.ticketOpenInfo[event.target.dataset.index].Product__c = '';
        //     } else {
        //         this.ticketOpenInfo[event.target.dataset.index].isShowProduct = true;
        //     }
        // }
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
            } else { this.ticketOpenInfo[index].Product__c = '';this.ticketOpenInfo[index].Product_Line__c = '';this.ticketOpenInfo[index].Product_Category__c = ''; }
        }
    }

    handleTicketProductLineOnChange(event) {
        console.log('ProductLine标记');
        console.log('选中产品吸纳参数' + JSON.stringify(event.target.value));
        console.log('触发更新操作' + this.ticketOpenInfo[event.target.dataset.index].isFullLine +':'+ this.ticketOpenInfo[event.target.dataset.index].Product_Line__c);
        this.ticketOpenInfo[event.target.dataset.index].Product_Line__c = event.target.value;
        if(this.ticketOpenInfo[event.target.dataset.index].isFullLine) {
            this.ticketOpenInfo[event.target.dataset.index].isFullLine = false;
        } else {
            this.ticketOpenInfo[event.target.dataset.index].Product__c = '';
        }
        this.updateProductLineLookup(event.target.dataset.index);
        
    }

    updateProductLineLookup(index) {
        var cmps = this.template.querySelectorAll('c-lookup-lwc');
        if (cmps) {
            let productLineIndex = 0;
            for (let i = 0; i < cmps.length; i++) {
                if (cmps[i].name == 'onLine') {
                    if (productLineIndex == index) {
                        cmps[i].updateOption({
                            
                            // 'lookup': 'CustomLookupProvider.productLineTicketFilter',
                            // 'Product_Line__c': this.ticketOpenInfo[index].Product_Line__c
                            'lookup': 'CustomLookupProvider.productTicketFilter',
                            'salesRegion': this.storeSalesRegion,
                            'productCategory': this.ticketOpenInfo[index].Product_Category__c,
                            'productLine': this.ticketOpenInfo[index].Product_Line__c
                        });
                        break;
                    } else {
                        productLineIndex += 1;
                    }
                }
            }
        }
    }
    removeProductLineLookup(index) {
        var cmps = this.template.querySelectorAll('c-lookup-lwc');
        if (cmps) {
            let productLineIndex = 0;
            for (let i = 0; i < cmps.length; i++) {
                if (cmps[i].name == 'onLine') {
                    if (productLineIndex == index) {
                        cmps[i].handleRemove();
                        break;
                    } else {
                        productLineIndex += 1;
                    }
                }
            }
        }
    }

    handleTicketSeriesOnChange(event) {
        this.ticketOpenInfo[event.target.dataset.index].SeriesNum__c = event.target.value;
    }

    handleTicketProductCategoryOnChange(event) {
        console.log('ProductCategory' + event.target.value);
        console.log('ProductCategory' + this.ticketOpenInfo[event.target.dataset.index].isFullCategory);
        console.log('ProductCategory标记');
        this.ticketOpenInfo[event.target.dataset.index].Product_Category__c = event.target.value;
        if(this.ticketOpenInfo[event.target.dataset.index].isFullCategory) {
            this.ticketOpenInfo[event.target.dataset.index].isFullCategory = false;
        } else {
            this.ticketOpenInfo[event.target.dataset.index].Product_Line__c = '';
            this.ticketOpenInfo[event.target.dataset.index].Product__c = '';
        }
        console.log('ProductCategory' + this.ticketOpenInfo[event.target.dataset.index].isFullCategory);
        this.updateProductLineLookup(event.target.dataset.index);
    }

    // 选择产品变更
    handleChangeProductOptionTicket(event) {
        let index = event.target.dataset.index;
        console.log('handleChangeProductOptionTicket ——> index: ' + index);
        if (event.detail.selectedRecord == undefined || event.detail.selectedRecord == '') { return; }
        handlerRemove({}).then(data => {
            if (data.isSuccess) { this.handleRemoveLookup('onProduct', index); } else { }
        }).catch(error => { this.catchError(error); });
        if (this.ticketOpenInfo[index].Product__c && this.ticketOpenInfo[index].Product__c != '' && this.ticketOpenInfo[index].Product__c != undefined) {
            if (this.ticketOpenInfo[index].Product__c.indexOf(event.detail.selectedRecord.Name) == -1) {
                this.ticketOpenInfo[index].Product__c = this.ticketOpenInfo[index].Product__c + ',' + event.detail.selectedRecord.Name;
            }
        } else { this.ticketOpenInfo[index].Product__c = event.detail.selectedRecord.Name; }
    }
    handleChangeProductLSOptionTicket(event) {
        let idx = event.target.dataset.index;
        console.log('handleChangeProductOptionTicket ——> index: ' + idx);
        console.log('event.detail' + JSON.stringify(event.detail));
        if (event.detail.selectedRecord == undefined || event.detail.selectedRecord == '') { return; }

        console.log('event.detail' + event.detail.selectedRecord.Product_Line__c);
        console.log('event.detail' + event.detail.selectedRecord.Product__c);

        console.log('产品标记');
        
        this.ticketOpenInfo[idx].isFullCategory = true;
        if(this.ticketOpenInfo[idx].Product_Category__c == event.detail.selectedRecord.Product__c) {
            this.handleTicketProductCategoryOnChange({
                target: {
                    value: event.detail.selectedRecord.Product__c,
                    dataset: { index: idx }
                }
            });
        } else {
            this.ticketOpenInfo[idx].Product_Category__c = event.detail.selectedRecord.Product__c;
        }
        // 4. 如需强制触发 onchange 逻辑，再手动调用
        
        this.ticketOpenInfo[idx].isFullLine = true;
        if(this.ticketOpenInfo[idx].Product_Line__c == event.detail.selectedRecord.Product_Line__c) {
            this.handleTicketProductLineOnChange({
                target: {
                    value: event.detail.selectedRecord.Product_Line__c,
                    dataset: { index: idx }
                }
            });
        } else {
            this.ticketOpenInfo[idx].Product_Line__c = event.detail.selectedRecord.Product_Line__c;
        }
        
        console.log('数据==>' + JSON.stringify(this.ticketOpenInfo[idx]));
        this.updateProductLineLookup(idx);
        
        handlerRemove({}).then(data => {
            if (data.isSuccess) { this.handleRemoveLookup('onLine', idx); } else { }
        }).catch(error => { this.catchError(error); });
        if (this.ticketOpenInfo[idx].Product__c && this.ticketOpenInfo[idx].Product__c != '' && this.ticketOpenInfo[idx].Product__c != undefined) {
            if (this.ticketOpenInfo[idx].Product__c.indexOf(event.detail.selectedRecord.Name) == -1) {
                this.ticketOpenInfo[idx].Product__c = this.ticketOpenInfo[idx].Product__c + ',' + event.detail.selectedRecord.Name;
            }
        } else { this.ticketOpenInfo[idx].Product__c = event.detail.selectedRecord.Name; }
    }
    get totalScoreText() { return this.countScore.Total_Score__c + '/' + this.countScore.Total_Score_Max__c; }
    get avgScoreText() { return this.countScore.Average_Score__c + '/' + this.countScore.Average_Score_Max__c; }
    addDssi(event) {
        this.template.querySelector('c-new-daily-sales-sell-in-lwc').addDssi();
    }
    addCompetitorsInformation(event) {
        this.template.querySelector('c-new-competitors-information-lwc').addCompetitorsInformation();
        //lzx 2024-11-12 添加时展开
        this.activeSections = ['competitorsInformation'];
    }
    dssiCheck() {
        let ele = this.template.querySelector('c-new-daily-sales-sell-in-lwc');
        if (ele == null || ele == '') {
            return '';
        } else {
            return ele.checkData();
        }
    }
    competitorsInformationCheck() {
        let ele = this.template.querySelector('c-new-competitors-information-lwc');
        if (ele == null || ele == '') {
            return '';
        } else {
            return ele.checkData();
        }
    }
    dssiSaveData(resp) {
        var itemRespIsSuccess = true;
        var itemRespErrorMsg = '';
        if (!resp.detail.result.isSuccess) {
            itemRespIsSuccess = resp.detail.result.isSuccess;
            itemRespErrorMsg += ' ' + resp.detail.result.message;
        }
        if (itemRespIsSuccess) {
            this.showSuccess('success');
            this.viewMode = true;
        } else {
            this.lwcName = this.label.PromoterDailyReport_DAILY_SALES;
            this.showError(itemRespErrorMsg);
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
        if (this.template.querySelector('c-new-competitors-information-lwc') != null) {
            this.template.querySelector('c-new-competitors-information-lwc').saveData();
        }
    }
    saveDssi(event) {
        if (this.template.querySelector('c-new-daily-sales-sell-in-lwc') != null) {
            this.template.querySelector('c-new-daily-sales-sell-in-lwc').saveData();
        }
    }

    goToStoreQuery(event) {
        event.stopPropagation();

        this.goToComponent('c__LWCWrapper',{
            'lwcName' : 'storeQueryLookUp'
        });
    }

    async handleDownLoadPDF() {
        this.goToVf("/apex/inspectionPDF?ID="+this.recordId);
        // window.open("/apex/inspectionPDF?ID="+this.recordId);
    }

    @track locationRecord;
    @track storeRecordInfo;

    @track storeCurrentLat;
    @track storeCurrentLong;
    @track storeAddress;
    handleHasEdit(event){
        // 获取子级页面信息
        this.locationRecord = event.detail.location;
        console.log('locationRecord' + JSON.stringify(this.locationRecord)); 
        console.log('locationRecord' + JSON.stringify(this.locationRecord.Shop_Center_Location__c.latitude)); 
        console.log('locationRecord' + JSON.stringify(this.locationRecord.Shop_Center_Location__c.longitude)); 

        this.storeAddress = this.locationRecord.Address1__c;
        this.storeCurrentLat = this.locationRecord.Shop_Center_Location__c.latitude;
        this.storeCurrentLong = this.locationRecord.Shop_Center_Location__c.longitude;

        console.log('wwwwrefreshUpShop' + this.storeCurrentLat); 
        console.log('wwwwrefreshUpShop' + this.storeCurrentLong); 

        // 更新门店数据并刷新信息
        this.getCurrentPosition(this.refreshUpShop);
    }

    // 刷新定位
    refreshUpShop(ele) {
        ele.isShowSpinner = true;
        refreshUpShop({
            currentLat: ele.storeCurrentLat, currentLong: ele.storeCurrentLong,address: ele.storeAddress,
            shopId: ele.record.Store__c
        }).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    ele[key] = data.data[key];
                }

                if(ele.record.Id != null){
                    ele.showReportDetail = true;
                    ele.showAllPage  = false;
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

    @track openLocationPage;
    handleCloseLocation() {
        this.openLocationPage = false;
    }

    openLocation(){
        this.openLocationPage = true;
    }

    @track formattedTime;
    geolocationGetAddress() {
        this.giveTime();
        this.isShowSpinner = true;
        geolocationGetAddress({
            lat: this.currentLat, lng: this.currentLong
        }).then(data => {
            console.log('AddressRefresh' + data);
            this.positionAddress = data;
            this.isShowSpinner = false;
        }).catch(error => {
            this.catchError(JSON.stringify(error));
            this.isShowSpinner = false;
        });
    }

    giveTime() {
        const now = new Date();
        // 使用 Intl.DateTimeFormat 格式化日期和时间
        const dateFormatter = new Intl.DateTimeFormat('en-CA', {
          year: 'numeric',
          month: '2-digit',
          day: '2-digit',
        });
        const timeFormatter = new Intl.DateTimeFormat('en-US', {
          hour: '2-digit',
          minute: '2-digit',
          hour12: false, // 使用 24 小时制
        });
        const formattedDate = dateFormatter.format(now);
        const formattedTime = timeFormatter.format(now);
        // 组合日期和时间
        this.formattedTime = `${formattedDate} ${formattedTime}`;
    }
}