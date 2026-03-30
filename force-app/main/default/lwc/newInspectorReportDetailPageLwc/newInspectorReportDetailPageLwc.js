/*
 * @Author: YYL
 * @LastEditors: TJP
 */
import { wire , track, api} from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import LightningConfirm from 'lightning/confirm';
import INSPECTION_REPORT_TITLE from '@salesforce/label/c.INSPECTION_REPORT_TITLE';
import INSPECTION_REPORT_SAVE from '@salesforce/label/c.INSPECTION_REPORT_SAVE';
import INSPECTION_REPORT_SUBMIT from '@salesforce/label/c.INSPECTION_REPORT_SUBMIT';
import INSPECTION_REPORT_EDIT from '@salesforce/label/c.INSPECTION_REPORT_EDIT';
import INSPECTION_REPORT_NEW from '@salesforce/label/c.INSPECTION_REPORT_NEW';
import CheckInCheckOut_REMARK from '@salesforce/label/c.CheckInCheckOut_REMARK'
import Product_Line_Checked from '@salesforce/label/c.Product_Line_Checked'
import INSPECTION_REPORT_FLOORWALKER from '@salesforce/label/c.INSPECTION_REPORT_FLOORWALKER';
import INSPECTION_REPORT_MSG_FUTURE_DATE from '@salesforce/label/c.INSPECTION_REPORT_MSG_FUTURE_DATE';
import CheckInCheckOut_RECORDED from '@salesforce/label/c.CheckInCheckOut_RECORDED';
import INSPECTION_REPORT_DISTANCE from '@salesforce/label/c.INSPECTION_REPORT_DISTANCE';
import INSPECTION_REPORT_MSG_SUBMIT_REPORT from '@salesforce/label/c.INSPECTION_REPORT_MSG_SUBMIT_REPORT';
import CheckInCheckOut_PHOTO from '@salesforce/label/c.CheckInCheckOut_PHOTO';
import getInitData from '@salesforce/apex/NewInspectorDailyReportController.getInitData';
import refreshData from '@salesforce/apex/NewInspectorDailyReportController.refreshData';
import upsertProductLineStatus from '@salesforce/apex/NewInspectionDailyReportPageController.upsertProductLineStatus';
import upsertPatrolMode from '@salesforce/apex/NewInspectionDailyReportPageController.upsertPatrolMode';
import submitRecord from '@salesforce/apex/NewInspectionDailyReportPageController.submitRecord';
import Inspection_Date from '@salesforce/label/c.Inspection_Date';
import Inspection_Store from '@salesforce/label/c.Inspection_Store';
import Inspection_Created_By from '@salesforce/label/c.Inspection_Created_By';
import Inspection_Dishwasher from '@salesforce/label/c.Inspection_Dishwasher';
import Inspection_WM from '@salesforce/label/c.Inspection_WM';
import Inspection_TV from '@salesforce/label/c.Inspection_TV';
import Inspection_Laser_TV from '@salesforce/label/c.Inspection_Laser_TV';
import Inspection_Cooking from '@salesforce/label/c.Inspection_Cooking';
import Inspection_Refrigerator from '@salesforce/label/c.Inspection_Refrigerator';
import Inspection_Freezer from '@salesforce/label/c.Inspection_Freezer';
import Inspection_Sound_Bar  from '@salesforce/label/c.Inspection_Sound_Bar';
import Inspection_Start from '@salesforce/label/c.Inspection_Start';
import Inspection_Continue from '@salesforce/label/c.Inspection_Continue';
import Inspection_Submitted  from '@salesforce/label/c.Inspection_Submitted';
import Inspection_Patrol_Mode_Tips from '@salesforce/label/c.Inspection_Patrol_Mode_Tips';
import Inspection_Unite from '@salesforce/label/c.Inspection_Unite';
import Inspection_Routine  from '@salesforce/label/c.Inspection_Routine';
import Inspection_Completed  from '@salesforce/label/c.Inspection_Completed';
import CHECK_MSG_SUBMIT from '@salesforce/label/c.CHECK_MSG_SUBMIT';
import Inspection_Type_AC from '@salesforce/label/c.Inspection_Type_AC';
import Inspection_Type_HA from '@salesforce/label/c.Inspection_Type_HA';
import Inspection_Type_CE from '@salesforce/label/c.Inspection_Type_CE';
import All_Product_Lines from '@salesforce/label/c.All_Product_Lines';
import CHECK_MSG_SUBMIT_SINGLE from '@salesforce/label/c.CHECK_MSG_SUBMIT_SINGLE';
import PromoterDailyReport_TICKET from '@salesforce/label/c.PromoterDailyReport_TICKET';
import INSPECTION_REPORT_TICKET_HISTORY from '@salesforce/label/c.INSPECTION_REPORT_TICKET_HISTORY';
import INSPECTION_REPORT_ATTACHMENT from '@salesforce/label/c.INSPECTION_REPORT_ATTACHMENT';
import INSPECTION_REPORT_MSG_DEPARTMENT_USER from '@salesforce/label/c.INSPECTION_REPORT_MSG_DEPARTMENT_USER';
import INSPECTION_REPORT_ACTION from '@salesforce/label/c.INSPECTION_REPORT_ACTION';
import INSPECTION_REPORT_TICKET_NEW from '@salesforce/label/c.INSPECTION_REPORT_TICKET_NEW';
import INSPECTION_REPORT_MSG_REQUIRED from '@salesforce/label/c.INSPECTION_REPORT_MSG_REQUIRED';
import PromoterDailyReport_AddNewItemSuccess from '@salesforce/label/c.PromoterDailyReport_AddNewItemSuccess';
import INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE from '@salesforce/label/c.INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE';
import INSPECTION_REPORT_INFORMATION from '@salesforce/label/c.INSPECTION_REPORT_INFORMATION';
import Ticket_Fields_Check from '@salesforce/label/c.Ticket_Fields_Check';
import Inspection_Add from '@salesforce/label/c.Inspection_Add';
import Inspection_Delete from '@salesforce/label/c.Inspection_Delete';
import saveTicket from '@salesforce/apex/NewSamplingAndTicketController.saveTicket';
import getPickList from '@salesforce/apex/NewInspectorDailyReportController.getPickList';
import deleteRecord from '@salesforce/apex/NewAccountPageController.deleteRecord';
import handlerRemove from '@salesforce/apex/NewTicketsController2.handlerRemove';
import Position_Correction from '@salesforce/label/c.Position_Correction';
import Coordinate_Description from '@salesforce/label/c.Coordinate_Description';
import Distance from '@salesforce/label/c.Distance';
import Inspection_Type from '@salesforce/label/c.Inspection_Type';
import Product_Model_Tips from '@salesforce/label/c.Product_Model_Tips';


export default class NewInspectorReportDetailPageLwc extends LightningNavigationElement {
    label = {
        INSPECTION_REPORT_TITLE,            // Title 检查报告
        INSPECTION_REPORT_SAVE,             // 保存
        INSPECTION_REPORT_SUBMIT,           // 提交
        INSPECTION_REPORT_EDIT,             // 修改
        INSPECTION_REPORT_NEW,              // 新建
        INSPECTION_REPORT_FLOORWALKER,      // 巡店员
        INSPECTION_REPORT_MSG_FUTURE_DATE,              // 无法为此记录选择未来日期
        INSPECTION_REPORT_MSG_SUBMIT_REPORT,            // 是否提交当前日报
        CheckInCheckOut_REMARK,         // 备注
        CheckInCheckOut_RECORDED,
        INSPECTION_REPORT_DISTANCE,
        CheckInCheckOut_REMARK,
        CheckInCheckOut_PHOTO,
        Product_Line_Checked,   
        Inspection_Date,// TJP20241108 新增
        Inspection_Store,            // 检查项复选框描述
        Inspection_Created_By,
        Inspection_Dishwasher,
        Inspection_WM,
        Inspection_TV,
        Inspection_Laser_TV,
        Inspection_Cooking,
        Inspection_Refrigerator,
        Inspection_Freezer, 
        Inspection_Sound_Bar, 
        Inspection_Start,
        Inspection_Continue,
        Inspection_Submitted,
        Inspection_Patrol_Mode_Tips,
        Inspection_Unite,
        Inspection_Routine,
        Inspection_Completed,
        CHECK_MSG_SUBMIT,
        Inspection_Type_CE,
        Inspection_Type_HA,
        Inspection_Type_AC,
        All_Product_Lines,
        CHECK_MSG_SUBMIT_SINGLE,
        PromoterDailyReport_TICKET,
        INSPECTION_REPORT_TICKET_HISTORY,
        INSPECTION_REPORT_ATTACHMENT,
        INSPECTION_REPORT_MSG_DEPARTMENT_USER,
        INSPECTION_REPORT_ACTION,
        INSPECTION_REPORT_TICKET_NEW,
        INSPECTION_REPORT_MSG_REQUIRED,
        PromoterDailyReport_AddNewItemSuccess,
        INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE,
        INSPECTION_REPORT_INFORMATION,
        Ticket_Fields_Check,
        Inspection_Add,
        Inspection_Delete,
        Position_Correction,
        Coordinate_Description,
        Distance,
        Inspection_Type,
        Product_Model_Tips
    }
    
    // 巡店员总表id
    // @track recordId = 'a1aHz000003cKm0IAE';

    // 巡店员子表id
    @track recordItemId;
    @api recordId;
    @api storeId;
    @api reportDate;
    @track isEditPage = false;                  // 显示编辑页面
    @track isShowSubmit = true;                  // 是否展示提交按钮
    @track storeLabel;                  // 门店名称
    @track currentLat = 0;                      // 当前坐标 Lat
    @track currentLong = 0;                     // 当前坐标 Long‘
    @track ownerName;                           // 所有人名
    @track inspectType;
    @track statusLabel = this.label.INSPECTION_REPORT_NEW;
    @track noteInfoCheckOut;
    @track phoneInfoCheckOut;

    // Page相关
    @track isShowSpinner = false;               // 加载中
    @track isReportUser = true;                 // 是否为日报所有人
    @track oldReportDate;                       // 旧日期
    @track oldReportDateShow = true;            // 切换日期显示
    @track record = {};                         // 日报主数据信息
    @track storeDistanceList = [];              // 门店信息
    @track attendanceInformation;               // 签到信息
    @track attendanceInformationCheckOut = {};       // 签退信息
    @track recordedInfo;
    @track distanceInfo;
    @track storeAddress1;
    @track noteInfo;
    @track phoneInfo;
    @track storeProductLines;                   // 门店进驻产品线信息
    @track showAllPage = true;
    @track showProductLineIssues = false;
    @track showDetailBtn = true;
    @track uniteLaserTV //联合巡店;常规巡店
    @track salesRegion;

    @track LineLabel; //TJP 20241108
    @track StatusLabel; //TJP 20241108
    @track producrLineAndPatrolmode;

    // 打卡地图相关
    @track mapMarkers = [];
    @track showMapMarkers = [];

    @track selectedOption;
    @track options = [
        { label: Inspection_Routine, value: 'Routine' },
        { label: Inspection_Unite, value: 'Unite' }
    ]; //这里后期设定字段PickList值

    /**
     * 初始化 Daily_Inspection_Report__c 标签
     */
    @track dailyInspectionReportInfo = {
        Store__c: '',
        Status__c: '',
        Total_Score__c: '',
        Average_Score__c: '',
        Summary__c: '',
        // Inspect_Type__c:'',//Add By Ethan增加巡店类型
        Contact_Person__c:'',
        Contact_Status__c:'',
        Contact_Type__c:'',
        Start_Time__c:'',
        Comments__c: '',
        Brand__c:''
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
                // Inspect_Type__c: data.fields.Inspect_Type__c.label,//Add By Ethan增加巡店类型
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

    get recordDatereadonly() {
        if (this.isTitleReadOnly || this.isReportUser == false) {
            return true;
        }else {
            return false;
        }
    }

    get recordDateClass() {
        if (this.recordDatereadonly) {
            return 'disabled-input date-format-hide';
        } else {
            return 'date-format-hide';
        }
    }

    loaded = false
    renderedCallback() {
        if(!this.loaded) {
            let style = document.createElement('style');
            style.innerText = 'div[class=slds-form-element__help]{display:none;}';
            this.template.querySelector('.date-format-hide').appendChild(style);
            this.loaded = true;
        }
    }

    handleShowDetailBtn(event){
        this.isShowSpinner = true;
        // let ele = this.template.querySelector('c-new-tickets-lwc2');
        this.showDetailBtn = event.detail.flag;

        if(event.detail.submitFlag){
            this.showProductLineIssues = false;
            this.showAllPage  = true;
            
            // 有门店Id
            if (this.storeId!=null && this.storeId!='' && this.recordId == null) {
                var d = new Date();
                this.record = {
                    Report_Date__c: this.reportDate == null ? d.getFullYear()+'-'+(d.getMonth()+1)+'-'+d.getDate() : this.reportDate,
                    Store__c: this.storeId,
                    Status__c: 'New',
                };
                this.getCurrentPosition(this.refreshData);
            } else {
                this.getCurrentPosition(this.getInitDataBaseRecordId);
            }
            
            // this.getCurrentPosition(this.refreshData);
        }
        // 展开ticket
        if(event.detail.createTicket){
            this.activeSections = ['ticket'];
            this.activeTicketSections = ['open'];
        }
    }

    // 初始化
    connectedCallback() {
        this.isShowSpinner = true;
        // var d = new Date();
        // this.record = {
        //     Report_Date__c: this.reportDate == null ? d.getFullYear()+'-'+(d.getMonth()+1)+'-'+d.getDate() : this.reportDate,
        //     // Store__c: this.storeId,
        //     // Status__c: 'New',
        // };
        console.log('API参数'+ this.storeId + ':' + this.recordId);
        // 取消下拉刷新
        this.disablePullToRefresh();
        this.start();
        // 有门店Id
        if (this.storeId!=null && this.storeId!='' && this.recordId == null) {
            var d = new Date();
            this.record = {
                Report_Date__c: this.reportDate == null ? d.getFullYear()+'-'+(d.getMonth()+1)+'-'+d.getDate() : this.reportDate,
                Store__c: this.storeId,
                Status__c: 'New',
            };
            this.getCurrentPosition(this.refreshData);
        } else {
            this.getCurrentPosition(this.getInitDataBaseRecordId);
        }
    }

    // 获取当前坐标
    getCurrentPosition(callback) {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                // 测试用，固定坐标
                this.currentLat = position.coords.latitude;
                this.currentLong = position.coords.longitude;
                console.log('数据坐标测试' + this.currentLat + ':' + this.currentLong);

                // this.isShowNewButton = true;
                callback(this);
            }, error =>{
                this.isShowSpinner = false;
                this.showError(this.getErrorInfomation(error));
                callback(this);
            },{ 
                enableHighAccuracy: true,timeout: 10000}
            );
        }else {
            this.isShowSpinner = false;
            this.showError(this.label.INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION);
        }
        // callback(this);
    }

    // 获取错误信息（坐标用）
    getErrorInfomation(error){
        switch(error.code) {
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
            if (this.record.Store__c!=null && this.record.Store__c!='' && this.record.Store__c==storeDistanceItem.storeId) {
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
                            anchor: {x: 45, y: 45}
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
            this.storeAddress1 = this.attendanceInformation.Shop__r.Address1__c; 
            this.distanceInfo = Math.round(this.attendanceInformation.Distance__c);
            this.noteInfo = this.attendanceInformation.Remark__c;
            //this.phoneInfo = 'data:image/jpeg;base64,'+this.attendanceInformationHandHelper.phoneBase64.slice(1).slice(0,-1);
            if(this.attendanceInformationHandHelper != null && this.attendanceInformationHandHelper.phoneBase64){
                this.phoneInfo = 'data:image/jpeg;base64,'+this.attendanceInformationHandHelper.phoneBase64.slice(1).slice(0,-1);
            }
            this.noteInfoCheckOut = this.attendanceInformationCheckOut.Remark__c;
            //this.phoneInfo = 'data:image/jpeg;base64,'+this.attendanceInformationHandHelper.phoneBase64.slice(1).slice(0,-1);
            if(this.attendanceInformationCheckOutHandHelper != null && this.attendanceInformationCheckOutHandHelper.phoneBase64){
                this.phoneInfoCheckOut = 'data:image/jpeg;base64,'+this.attendanceInformationCheckOutHandHelper.phoneBase64.slice(1).slice(0,-1);
            }
            var radius = 0;
            var filteredList = this.storeDistanceList.filter(obj => obj.storeId == this.attendanceInformation.Shop__c);
            if (filteredList.length>0) {
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
                        anchor: {x: 45, y: 45}
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
            if(this.attendanceInformationHandHelper != null && this.attendanceInformationHandHelper.phoneBase64){
                this.phoneInfo = 'data:image/jpeg;base64,'+this.attendanceInformationHandHelper.phoneBase64.slice(1).slice(0,-1);
            }
            var radius = 0;
            var filteredList = this.storeDistanceList.filter(obj => obj.storeId == this.record.Store__c);
            if (filteredList.length>0) {
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

    // ---------------> ↑ Button click ↑ <---------------
    // ---------------> ↓ onchange ↓ <---------------
    // 日期变更
    handleChangeReportDate(event) {
        var reportDate = new Date(event.target.value);
        var today = new Date(this.todayDate);
        if (reportDate>today) {
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
            // this.oldReportDate = event.target.value;
            this.record.Report_Date__c = event.target.value;
            this.getCurrentPosition(this.refreshData);
        }
    }

    // 门店变更
    handleChangeShopOption(event) {
        if(event.target.value != ''){
            this.isShowSpinner = true;
            this.record.Store__c = event.detail.value + '';
            // this.storeLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
            this.storeId = event.detail.value + '';
            this.getCurrentPosition(this.refreshData);
        }
        // this.isShowSpinner = true;
        // this.record.Store__c = event.detail.value;
        // this.storeId = event.detail.value;
        // this.storeLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
        // this.getCurrentPosition(this.refreshData);
    }

    // 复选框状态变更
    handleChangeCheckbox(event) {
        this.isShowSpinner = true;
        let index = event.target.dataset.index;
        let id = event.target.dataset.id;
        let status = this.storeProductLines[index].Status__c;
        let check = event.target.checked;

        console.log('check' + check);
        console.log('wwwwstoreProductLines' + JSON.stringify(this.storeProductLines));

        if(!status){
            status = 'Start';
            this.storeProductLines[index].StatusShow = 'Start';
            this.storeProductLines[index].isStart = true;
        }
        
        this.handleSetStatusOption(status);
        // 更新产品线状态
        upsertProductLineStatus({
            recordId:id,
            status:status,
            productLineChecked:check
        }).then(data => {
            this.storeProductLines[index].Status__c = data.data.productLine.Status__c;
            this.storeProductLines[index].checked = data.data.productLine.Product_Line_Checked__c;

            this.isShowSpinner = false;
        }).catch(error => {
            this.catchError(JSON.stringify(error));
            this.isShowSpinner = false;
        });

        // 有门店Id
        if (this.storeId!=null && this.storeId!='' && this.recordId == null) {
            var d = new Date();
            this.record = {
                Report_Date__c: this.reportDate == null ? d.getFullYear()+'-'+(d.getMonth()+1)+'-'+d.getDate() : this.reportDate,
                Store__c: this.storeId,
                Status__c: 'New',
            };
            this.getCurrentPosition(this.refreshData);
        } else {
            this.getCurrentPosition(this.getInitDataBaseRecordId);
        }

        console.log('wwwthis.storeProductLines' + JSON.stringify(this.storeProductLines[index]));
    }

    // Edit click
    handleEdit() {
        this.isEditPage = true;
        // this.isFieldReadOnly = false;
        this.storeLabel = this.shopOptions.find(opt => opt.value === this.record.Store__c).label;
        var storeDetail = this.storeDistanceList.filter(obj => obj.storeId == this.record.Store__c);
        this.storeSalesRegion = storeDetail.length > 0 ? storeDetail[0].salesRegion : '';
    }

    // Save click
    handleSave() {
        // 保存更新
        // this.upsertRecord(false);
        this.isTitleShowButton = false;
        this.isEditPage = false;
    }

    // Submit click
    async handleSubmit() {
        if(this.storeProductLines){
            const result = await LightningConfirm.open({
                message: this.label.INSPECTION_REPORT_MSG_SUBMIT_REPORT,
                variant: 'headerless',
                label: 'This is the aria-label value',
            });
            if (result) {
                this.handleSubmitModal();
            } 
        }
    }

    async handleDownLoadPDF() {
        // window.open('/lightning/cmp/c__InspectionPDFCmp');
        // this.goToVf("/apex/inspectionPDF?ID="+this.recordId);
        window.open("/apex/inspectionPDF?ID="+this.recordId);
    }

    handleSubmitModal() {
        this.isShowSpinner = true;
        var isSubmit = true;
        var isCheck = false;
        var isTicketCheck = true;
        var message = [];
        // 检查需要检查的产品线是否都已完成 YYL 20250317

        // 检验check状态是否已检查完毕
        this.storeProductLines.forEach(item => {
            console.log('wwwwItem' + JSON.stringify(item));
            if(item.Product_Line_Checked__c && item.Status__c != 'Submitted'){
                message.push(item.Type__c);
                isSubmit = false;
            }

            // 判断是否有一个为check状态的检查
            if(item.Product_Line_Checked__c){
                isCheck = true;
            }
        })

        // 校验ticket是否填写完全
        var checkResp = { alltrue: true, msg: '' };
        if (this.checkTicket().alltrue == false) {
            checkResp = this.checkTicket();
            this.lwcName = this.label.PromoterDailyReport_TICKET;
        }
        if (checkResp.alltrue == false) {
            // this.showError('Required information haven’t been maintained. Please fulfil required information first. - ' + checkResp.msg);
            // this.showWarning(this.label.INSPECTION_REPORT_MSG_REQUIRED + checkResp.msg);
            this.lwcName = this.label.INSPECTION_REPORT_TITLE;
            isTicketCheck = false;
        }
        
        if(isSubmit && isCheck && isTicketCheck){
            this.submitRecord();
        }else{
            this.isShowSpinner = false;
            if(message.length > 0){
                this.catchError(message.join(',')+ ' ' + this.label.CHECK_MSG_SUBMIT);
            }
            if(!isCheck){
                this.catchError(this.label.CHECK_MSG_SUBMIT_SINGLE);
            }
            if(!isTicketCheck){
                this.catchError(this.label.INSPECTION_REPORT_MSG_REQUIRED + checkResp.msg);
            }
        }
        
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
        if(this.isTicket){
            this.isTicket = false;
            this[this.modalType](this.modalHelper);

        }else {
            this.showAllPage = false;
            this.showProductLineIssues = true;
        }
    }

    handleClose(){
        this.isTicket = false;
    }

    @track productLine;
    @track status;
    @track patrolmode;
    // Added By Sunny Start
    handleShowItemIssues(event) {
        // this.productLine = event.target.value.Product_Line__c;
        // this.status = event.target.value.Status__c;
        this.productLine = event.target.dataset.productline;
        this.status = event.target.dataset.status;
        this.patrolmode = event.target.dataset.patrolmode;

        console.log('进入触发弹窗巡检条件。。。。。。。。。。。。。。。' + this.status);
        console.log('进入触发弹窗巡检条件。。。。。。。。。。。。。。。' + this.uniteLaserTV +':'+ this.productLine + ':' + this.salesRegion);
        this.recordItemId = event.target.dataset.id;
        // if(this.patrolmode == undefined) {
        //     this.patrolmode = this.uniteLaserTV; 
        // }
        if(this.salesRegion == 'Hisense International') {
            console.log('thisX.XsalesRegion' + this.salesRegion + ':' + this.patrolmode);
            // 需要声明产品线加模式的唯一值
            if(this.productLine && this.patrolmode) {
                this.uniteLaserTV = this.patrolmode;
                this.showAllPage = false;
                this.showProductLineIssues = true;
                this.handleUpsertPatrolMode();
            } else if(this.productLine && (this.patrolmode == '' || this.patrolmode == undefined)){
                console.log('触发弹窗条件。。。。。。。。。。。。。。。');
                this.handleShow(Inspection_Patrol_Mode_Tips,'','');
            } 
        } else if (this.productLine){
            this.showAllPage = false;
            this.showProductLineIssues = true;
            // 设置当前产品线巡店日报子表id
            this.recordItemId = event.target.dataset.id;
        }
    }

    async handleChangStatus(event) {

        console.log('WWW' + event);
    }

    

    // //备份
    // @track productLine;
    // @track status;
    // // Added By Sunny Start
    // handleShowItemIssues(event) {
    //     // this.productLine = event.target.value.Product_Line__c;
    //     // this.status = event.target.value.Status__c;
    //     this.productLine = event.target.dataset.productline;
    //     this.status = event.target.dataset.status;
    //     if(this.productLine){
    //         this.showAllPage = false;
    //         this.showProductLineIssues = true;
    //         // 设置当前产品线巡店日报子表id
    //         this.recordItemId = event.target.dataset.id;
    //     }
    // }

    handleCloseItemIssues() {
        this.showProductLineIssues = false;
        this.showAllPage  = true;
        // this.activeSections = [];
    }

    getTypeLanguage(ele) {
        switch (ele) {
            case 'CE':
                return Inspection_Type_CE;
            case 'HA':
                return Inspection_Type_HA;
            case 'AC':
                return Inspection_Type_AC;
            case 'All':
                return All_Product_Lines;
        }
        return ele;
    }
    // 初始化获取数据
    getInitDataBaseRecordId(ele) {
        ele.isShowSpinner = true;
        getInitData({
            recordId: ele.recordId, currentLat: ele.currentLat, currentLong: ele.currentLong, shopId: ele.storeId // 门店没有配置巡店员可显示
        }).then(data => {
            if (data.isSuccess) {
                console.log(JSON.stringify(data.data));
                for (let key in data.data) {
                    ele[key] = data.data[key];
                    // 处理storeProductLines数据
                    if(key == 'storeProductLines'){
                        let storeProductLinesData = data.data[key];
                        storeProductLinesData.forEach(element => {
                            console.log('storeProductLinesData1' + JSON.stringify(storeProductLinesData));
                            // if(element['Status__c'] != 'Submitted'){
                            //     element['StatusShow'] = 'Unsubmitted';
                            //     element['isSubmitted'] = false;
                            // }else{
                            //     element['StatusShow'] = 'Submitted';
                            //     element['isSubmitted'] = true;
                            // }

                            // 新增复选框展示逻辑
                            element['checked'] = element['Product_Line_Checked__c'];
                            if(element['Status__c'] == 'Submitted'){
                                // element['StatusShow'] = 'Submitted';
                                element['StatusShow'] = Inspection_Completed;
                                element['isStart'] = false;
                                element['isContinue'] = false;
                                element['isSubmitted'] = true;
                                element['disable'] = true;
                            }else if(element['Status__c'] == 'Start'){
                                element['StatusShow'] = Inspection_Start;
                                element['isStart'] = true;
                                element['isContinue'] = false;
                                element['isSubmitted'] = false;
                                element['disable'] = false;
                            }else if(element['Status__c'] == 'Continue'){
                                element['StatusShow'] = Inspection_Continue;
                                element['isStart'] = false;
                                element['isContinue'] = true;
                                element['isSubmitted'] = false;
                                element['disable'] = false;
                            }else{
                                element['isStart'] = false;
                                element['isContinue'] = false;
                                element['isSubmitted'] = false;
                                element['disable'] = false;
                            }
                            var line = element['Product_Line__c'];
                            ele.handleSetLinesOption(line);
                            
                            element['LineLabel'] = ele.LineLabel;
                            // element['LineLabel'] = 'DDDD';
                            ele.patrolMode = element['Patrol_Mode__c'];
                            console.log('获取产品线数据Status__cLabel' + element['Status__c']);
                            console.log('获取产品线数据StatusShowLabel' + element['StatusShow']);
                            ele.handleSetStatusOption(element['Status__c']);
                            element['StatusLabel'] = ele.StatusLabel;
                            if(element['Type__c'] == 'All') {
                                element['disable'] = true;
                            }
                        });
                        ele[key] = storeProductLinesData;
                    }
                    if(key == 'salesRegion'){
                        let salesRegion = data.data[key];
                        ele.salesRegion = salesRegion;
                        console.log('this.salesRegion' + ele.salesRegion);
                        console.log('salesRegion' + salesRegion);
                    }

                    if(ele.record){
                        var status = ele.record.Status__c;
                        ele.inspectType = ele.record.Inspect_Type__c;
                    }
               
                }

                if(ele.storeProductLines){
                    console.log('ssss' + JSON.stringify(ele.storeProductLines));
                    ele.storeProductLines.forEach(element => {
                        console.log('ssss' + element['Type__c']);
                        element['Type__c'] = ele.getTypeLanguage(element['Type__c']);
                        // if(){
                        //     element['typeLabel'] = 
                        // }else{
                        //     element['typeLabel'] = '';
                        // }
                    });
                }

                // ele.salesRegion = data.data['salesRegion'];
                // console.log('this.salesRegion' + data.data['salesRegion']);
                console.log('wwwwstoreProductLines' + JSON.stringify(data.data['storeProductLines']));
                console.log('wwwwRecord' + JSON.stringify(data.data['record']));
                ele.storeId = ele.record.Store__c;

                // 根据日报状态是否展示提交按钮 YYL 20250317
                if(ele.record){
                    var status = ele.record.Status__c;
                    console.log('wwwwrecord' + JSON.stringify(status));
                    if(status == 'Submitted'){
                        ele.isShowSubmit = false;
                        ele.isEditTicket = false;
                        ele.isFieldReadOnly = true;
                    }
                }

                // 无历史数据，设置打卡地图
                // ele.isTitleShowButton = false;
                // isEditTicket
                
                if (ele.recordId || ele.record.Id) {
                    ele.setShowMapInformation();
                }else{
                    // ele.setMapInformation();
                }

                // 判断国家
                ele.checkCountry(data.data.salesRegion);
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

    // 刷新数据
    refreshData(ele) {
        console.log('refreshData storeId' + JSON.stringify(ele.storeId));
        console.log('refreshData record' + JSON.stringify(ele.record));
        ele.isShowSpinner = true;
        refreshData({
            recordJson: JSON.stringify(ele.record), currentLat: ele.currentLat, currentLong: ele.currentLong, contentVersionId: ele.contentVersionId,
            shopId: ele.storeId  
        }).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    ele[key] = data.data[key];
                    // 处理storeProductLines数据
                    if(key == 'storeProductLines'){
                        let storeProductLinesData = data.data[key];
                        console.log('storeProductLinesData' + JSON.stringify(storeProductLinesData));
                        // storeProductLinesData.forEach(element => {
                        //     if(element['Status__c'] != 'Submitted'){
                        //         element['StatusShow'] = 'Unsubmitted';
                        //         element['isSubmitted'] = false;
                        //     }else{
                        //         element['StatusShow'] = 'Submitted';
                        //         element['isSubmitted'] = true;
                        //     }
                        // });
                        // 新增复选框展示逻辑
                        storeProductLinesData.forEach(element => {
                            element['checked'] = element['Product_Line_Checked__c'];
                            if(element['Status__c'] == 'Submitted'){
                                // element['StatusShow'] = 'Submitted';
                                element['StatusShow'] = Inspection_Completed;
                                element['isStart'] = false;
                                element['isContinue'] = false;
                                element['isSubmitted'] = true;
                                element['disable'] = true;
                            }else if(element['Status__c'] == 'Start'){
                                element['StatusShow'] = Inspection_Start;
                                element['isStart'] = true;
                                element['isContinue'] = false;
                                element['isSubmitted'] = false;
                                element['disable'] = false;
                            }else if(element['Status__c'] == 'Continue'){
                                element['StatusShow'] = Inspection_Continue;
                                element['isStart'] = false;
                                element['isContinue'] = true;
                                element['isSubmitted'] = false;
                                element['disable'] = false;
                            }else{
                                element['isStart'] = false;
                                element['isContinue'] = false;
                                element['isSubmitted'] = false;
                                element['disable'] = false;
                            }
                            //增加逻辑
                            var line = element['Product_Line__c'];
                            ele.handleSetLinesOption(line);
                            
                            element['LineLabel'] = ele.LineLabel;
                            // element['LineLabel'] = 'DDDD';
                            ele.patrolMode = element['Patrol_Mode__c'];
                            // console.log('获取模式数据' + element['Patrol_Mode__c']);
                            // console.log('获取产品线数据' + element['Product_Line__c']);
                            // console.log('获取产品线数据Label' + element['LineLabel']);
                            console.log('获取产品线数据Status__cLabel' + element['Status__c']);
                            console.log('获取产品线数据StatusShowLabel' + element['StatusShow']);
                            ele.handleSetStatusOption(element['Status__c']);
                            element['StatusLabel'] = ele.StatusLabel;
                            if(element['Type__c'] == 'All') {
                                element['disable'] = true;
                            }
                        });

                        // 根据日报状态是否展示提交按钮 YYL 20250317
                        if(ele.record){
                            var status = ele.record.Status__c;
                            console.log('wwwwrecord' + JSON.stringify(status));
                            if(status == 'Submitted'){
                                ele.isShowSubmit = false;
                            }
                        }
                        
                        ele[key] = storeProductLinesData;
                    }

                    if(ele.storeProductLines){
                        console.log('ssss' + JSON.stringify(ele.storeProductLines));
                        ele.storeProductLines.forEach(element => {
                            console.log('ssss' + element['Type__c']);
                            element['Type__c'] = ele.getTypeLanguage(element['Type__c']);
                            // if(){
                            //     element['typeLabel'] = 
                            // }else{
                            //     element['typeLabel'] = '';
                            // }
                        });
                    }
                }

                ele.storeId = ele.record.Store__c;

                // 根据是否有日报Id判断展示首页还是详情页
                if(ele.record.Id == null){
                    ele.dispatchEvent(new CustomEvent(
                        "select", {
                            detail: {
                                flag : true,
                                storeId : ele.record.Store__c,
                                reportDate : ele.record.Report_Date__c
                            }
                        })
                    );
                }

                if (ele.record.Id) {
                    ele.setShowMapInformation();
                }else{
                    // ele.setMapInformation();
                }

                // 无历史数据，设置打卡地图
                // ele.isTitleShowButton = false;
                // ele.isFieldReadOnly = true;
                // ele.setMapInformation();
                // ele.attendanceShowPhotoCheckOut = false;
                // ele.attendancePhotoStreamCheckOut = null;
                // ele.attendanceRemarkCheckOut = null;

                // 判断国家
                ele.checkCountry(data.data.salesRegion);
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

    // 更新数据
    submitRecord() {
        submitRecord({
            recordJson: JSON.stringify(this.record),
            ticketClosedInfo : JSON.stringify(this.ticketClosedInfo),
            ticketOpenInfo : JSON.stringify(this.ticketOpenInfo),
        }).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    this[key] = data.data[key];
                }
                
                this.setShowMapInformation();
        
                // 数据格式化
                this.showSuccess('success');

                // 根据日报状态是否展示提交按钮 YYL 20250317
                if(this.record){
                    var status = this.record.Status__c;
                    console.log('wwwwrecord' + JSON.stringify(status));
                    if(status == 'Submitted'){
                        this.isShowSubmit = false;
                        // ticket 权限
                        this.isEditTicket = false;
                        this.isFieldReadOnly = true;
                        if (this.ticketOpenInfo.length > 0) {
                            for (let i = 0; i < this.ticketOpenInfo.length; i++) {
                                this.ticketOpenInfo[i].disabled = this.isEditTicket;
                                this.ticketOpenInfo[i].isFieldReadOnly = this.isFieldReadOnly;
                            }
                        }
                    }
                }

                this.isShowSpinner = false;
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
            this.isShowSpinner = false;
        }).catch(error => {
            console.log('---------->error='+JSON.stringify(error));
            this.catchError(error);
            this.isShowSpinner = false;
        });  
    }

    handleGoBack(){
        this.showProductLineIssues = false;
        this.showAllPage  = true;

        // // 刷新页面
        // this.getCurrentPosition(this.refreshData);
        
        // 有门店Id
        if (this.storeId!=null && this.storeId!='' && this.recordId == null) {
            var d = new Date();
            this.record = {
                Report_Date__c: this.reportDate == null ? d.getFullYear()+'-'+(d.getMonth()+1)+'-'+d.getDate() : this.reportDate,
                Store__c: this.storeId,
                Status__c: 'New',
            };
            this.getCurrentPosition(this.refreshData);
        } else {
            this.getCurrentPosition(this.getInitDataBaseRecordId);
        }
    }

    handleOptionChange(event) {
        console.log('XXXthis.recordId' + this.recordId);
        console.log('XXXthis.recordItemId' + this.recordItemId);

        console.log('XXX' + event);
        this.selectedOption = event.detail.value;
        this.uniteLaserTV = this.selectedOption;
        console.log('XXX' + this.selectedOption);
        this.handleOk();
        upsertPatrolMode({
            recordId: this.recordItemId,
            patrolMode: this.selectedOption
        }).then(data => {
            console.log('data' + JSON.stringify(data));
        });

    }

    handleUpsertPatrolMode() {
        console.log('XXXthis.recordId' + this.recordId);
        console.log('XXXthis.recordItemId' + this.recordItemId);

        upsertPatrolMode({
            recordId: this.recordItemId,
            patrolMode: this.patrolmode
        }).then(data => {
            console.log('data' + JSON.stringify(data));
        });

    }

    //TJP 20241108 新增产品线多语言Option方法 TV Laser TV Cooking WM Refrigerator Freezer Sound Bar Dishwasher
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
    
    handleSetStatusOption(data) {
        if(data == 'Start') {
            this.StatusLabel = Inspection_Start;
        } else if(data == 'Continue') {
            this.StatusLabel = Inspection_Continue;
        }  else if(data == 'Submitted') {
            // this.StatusLabel = Inspection_Submitted;
            this.StatusLabel = Inspection_Completed;
        } 
        console.log('传递的Label参数' +  this.StatusLabel + ':' + data);

    }

    // ----------------------------------ticket----------------------------------------
    @track activeTicketSections = [];
    @track activeSections = [];
    @track ticketClosedInfo = [];               // 历史ticket
    @track ticketOpenInfo = [];                 // 新建ticket
    @track ticketOpenFilesMap = {};             // ticket附件Map
    @track isEditTicket = true;                  // 显示编辑页面
    @track isSouthAfrica = false;
    @track isArgentina = false;
    @track isShowDepartment = false; // 智利
    @track isFieldReadOnly = false;              // 字段只读
    @track isTicket = false; // 智利
    @track isAustralia = false; //澳洲
    @track checkResultsIsRelatedToProduct = [];                   // 试卷信息-出样
    @track isNotAustralia = true;
    @track storeSalesRegion;
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

    checkCountry(salesRegion){
        if(salesRegion == 'Hisense South Africa'){
            this.isSouthAfrica = true;
            this.isShowDepartment = true;
        }else if(salesRegion == 'Hisense Argentina'){
            this.isArgentina = true;
            this.isShowDepartment = true;
        } else if(salesRegion == 'Hisense Australia') { //暂时注释 Australia
            this.isAustralia = true;
            this.isNotAustralia = false;
        }
    }

    /**初始化 Ticket Confirm Task Value List*/
    @wire(getPickList, { objectName: 'Ticket__c', fieldName: 'Status__c' })
    confirmTaskOptions;
    @wire(getPickList, { objectName: 'Ticket__c', fieldName: 'Priority__c' })
    priorityTaskOptions;
    @wire(getPickList, { objectName: 'Ticket__c', fieldName: 'Category__c' })
    CategoryTaskOptions;
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

    // 数据整理
    dataFormat(data) {
        console.log('wwwwwbbbb-----' + JSON.stringify(data.data.ticketOpenInfo));
        console.log('wwwwwaaaa-----' + JSON.stringify(data.data.ticketClosedInfo));
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
                this.ticketClosedInfo[i].className = 'slds-table slds-table_bordered slds-table_fixed-layout slds-resizable marketInsightTable ticketTable slds-var-m-top_small slds-border_left slds-border_right ' + (i % 2 ? 'table-even' : 'table-odd');
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
                this.ticketOpenInfo[i].disabled = this.isEditTicket;
                this.ticketOpenInfo[i].isFieldReadOnly = this.isFieldReadOnly;
                console.log(this.ticketOpenInfo[i]);
            }
        }
    }

    isFilledOut(content) {
        if (typeof content == "undefined") {
            return false;
        } else if (content == '' || content == null) {
            return false;
        } else if (typeof content == "number") { return !isNaN(content); }
        return true;
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
        var op = {
            'lookup': 'CustomLookupProvider.productTicketFilter',
            'salesRegion': this.storeSalesRegion,
            'productCategory': '',
            'productLine': ''
        };
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
            InspectionReport__c: this.recordId,
            Product_Category__c: '',
            SBU__c: this.storeSalesRegion,
            Store__c: this.record.Store__c,
            index: new Date().getTime(),
            SBU__c: this.storeSalesRegion,
            Store__c: this.record.Store__c,
            needSave: true,
            lookupProductLineFilter : op,
            isFullLine: false,
            isFullCategory: false
        };
        // if (this.isArgentina) {
        //     if (this.ticketAssignedTo != '') {
        //         ticket.AssignedTo__c = '';
        //     }
           
        //     ticket.Priority__c = 'Normal';
           
        // }
        this.ticketOpenInfo.push(ticket)
        console.log('SAVE Ticket' + JSON.stringify(this.ticketOpenInfo));
        this.activeTicketSections = ['open'];
        this.showSuccess(this.label.PromoterDailyReport_AddNewItemSuccess);

    }

    handleTicketCategoryChange(event) {
        this.ticketOpenInfo[event.target.dataset.index].Category__c = event.target.value;
    }

    handleTicketCategoryOnChange(event) {
        this.ticketOpenInfo[event.target.dataset.index].Category__c = event.target.value;
        this.ticketOpenInfo[event.target.dataset.index].isShowProduct = false;
        this.ticketOpenInfo[event.target.dataset.index].Product__c = '';  
    }

    handleTicketProductLineOnChange(event) {
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
        this.ticketOpenInfo[event.target.dataset.index].Product_Category__c = event.target.value;
        if(this.ticketOpenInfo[event.target.dataset.index].isFullCategory) {
            this.ticketOpenInfo[event.target.dataset.index].isFullCategory = false;
        } else {
            this.ticketOpenInfo[event.target.dataset.index].Product_Line__c = '';
            this.ticketOpenInfo[event.target.dataset.index].Product__c = '';
        }
        this.updateProductLineLookup(event.target.dataset.index);
    }

    deleteProductValue(event) {
        let index = event.target.dataset.index;
        if (this.isFilledOut(this.ticketOpenInfo[index].Product__c)) {
            if (this.ticketOpenInfo[index].Product__c.lastIndexOf(',') != -1) {
                this.ticketOpenInfo[index].Product__c = this.ticketOpenInfo[index].Product__c.substr(0, this.ticketOpenInfo[index].Product__c.lastIndexOf(','));
            } else { this.ticketOpenInfo[index].Product__c = '';this.ticketOpenInfo[index].Product_Line__c = '';this.ticketOpenInfo[index].Product_Category__c = ''; }
        }
    }

    // 选择产品变更
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
        this.updateProductLineLookup(idx);
        handlerRemove({}).then(data => {
            if (data.isSuccess) { this.handleRemoveLookup('onLine', idx); } else { }
        }).catch(error => { console.error(error); this.catchError(error); });
        if (this.ticketOpenInfo[idx].Product__c && this.ticketOpenInfo[idx].Product__c != '' && this.ticketOpenInfo[idx].Product__c != undefined) {
            if (this.ticketOpenInfo[idx].Product__c.indexOf(event.detail.selectedRecord.Name) == -1) {
                this.ticketOpenInfo[idx].Product__c = this.ticketOpenInfo[idx].Product__c + ',' + event.detail.selectedRecord.Name;
            }
        } else { this.ticketOpenInfo[idx].Product__c = event.detail.selectedRecord.Name; }
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

    // Check Ticket
    checkTicket() {
        var resp = { alltrue: true, msg: '' };
        for (let i = 0; i < this.ticketOpenInfo.length; i++) {
            var obj = this.ticketOpenInfo[i];
            if (obj.Subject__c == '' || obj.Subject__c == null) {
                resp.alltrue = false;
                resp.msg = this.TicketInfo.Subject__c;
                return resp;
            }
            // TJP Product 非必填
            // if(!this.isArgentina) {
            //     if (this.isFilledOut(obj.Category__c) && obj.Category__c != 'Service') {
            //         if (!this.isFilledOut(obj.Product__c)) {
            //             resp.alltrue = false;
            //             resp.msg = this.TicketInfo.Product__c;
            //             return resp;
            //         }
            //     }
            // }
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
        this.isTicket = true;
        this.handleShow(
            // 'Information will be deleted if you click "Yes"; click "No" to cancel.',
            this.label.INSPECTION_REPORT_MSG_DELETED_PRODUCT_LINE.format(this.label.INSPECTION_REPORT_INFORMATION),
            'deleteTicketHelper',
            index);
    }
    async deleteTicketHelper(event) {
        let deleteId = this.ticketOpenInfo[event].Id;
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
        // 删除ticket
        this.isShowSpinner = true;
        deleteRecord({ 
            recordId: deleteId 
        }).then(data => {
            if(data){
                this.showSuccess('Success');
            }
            this.isShowSpinner = false;
        }).catch(error => {
            this.isShowSpinner = false;
        });
        
    }
    saveNewTicket(event){
        let index = event.target.dataset.index;
        let tempTicket = this.ticketOpenInfo[index];
        // 校验
        var resp = { alltrue: true, msg: '' };
        if (tempTicket.Subject__c == '' || tempTicket.Subject__c == null) {
            resp.alltrue = false;
            resp.msg = this.TicketInfo.Subject__c;
        }
        if (tempTicket.Description__c == '' || tempTicket.Description__c == null) {
            resp.alltrue = false;
            resp.msg = this.TicketInfo.Description__c;
        }
        //增加判断条件 阿根廷不做校验 TJP
        // if(!this.isArgentina) {
        //     if (this.isFilledOut(tempTicket.Category__c) && tempTicket.Category__c != 'Service') {
        //         if (!this.isFilledOut(tempTicket.Product__c)) {
        //             resp.alltrue = false;
        //             resp.msg = this.TicketInfo.Product__c;
        //         }
        //     }
        // }
        if ((this.isShowDepartment) && (tempTicket.Department__c == '' || tempTicket.Department__c == null) && (tempTicket.AssignedTo__c == '' || tempTicket.AssignedTo__c == null)) {
            resp.alltrue = false;
            resp.msg = Ticket_Fields_Check.format(this.TicketInfo.AssignedTo__c, this.TicketInfo.Department__c);
        }
        
        // added by Sunny about chile department end-[20231026]
        if (!this.isShowDepartment && (!this.isArgentina) && (tempTicket.AssignedTo__c == '' || tempTicket.AssignedTo__c == null)) {
            resp.alltrue = false;
            resp.msg = this.TicketInfo.AssignedTo__c;
        }
        if (tempTicket.DueDate__c == '' || tempTicket.DueDate__c == null) {
            resp.alltrue = false;
            resp.msg = this.TicketInfo.DueDate__c;
        }
        if (resp.alltrue == false) {
            this.showWarning(this.label.INSPECTION_REPORT_MSG_REQUIRED + resp.msg);
            this.lwcName = this.label.INSPECTION_REPORT_TITLE;
            return;
        }
        this.saveTicket(JSON.stringify(tempTicket), index);
    }
    saveHistoryTicket(event){
        let index = event.target.dataset.index;
        let tempTicket = this.ticketClosedInfo[index];
        // const cleanedArray = tempTicket.map(item => {
        //   const { lookupProductLineFilter, ...rest } = item;
        //   return rest;
        // });
        this.saveTicket(JSON.stringify(tempTicket));
    }
    saveTicket(saveTicketJson, index){
        console.log('Save----');
        this.isShowSpinner = true;
        saveTicket({
            saveTicketJson: saveTicketJson,
        }).then(data => {
            if(data.isSuccess){
                this.showSuccess('Save successfully!');
                if(index != null && index != undefined &&  index != ''){
                    this.ticketOpenInfo[index].Id = data.data.ticket.Id;
                }
            }else {
                this.showError('Save failure!' + data.message);
            }
            this.isShowSpinner = false;
        }).catch(error => {
            this.isShowSpinner = false;
            this.showError('Save failure!' + JSON.stringify(error));
        });
    }

    // 添加用户（自定义lookupFilter）
    lookupUserFilter = {
        'lookup': 'CustomLookupProvider.UserFilter'
    }
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

    // captureCompress = true;
    // showCapture = false;
    // handleCaptureComplete(event) {
    //     if (event.detail.isSuccess) {
    //         this.attendancePhotoStream = event.detail.data.base64;
    //         this.attendanceShowPhoto = true;
    //         this.attendanceFromType = 'From Photo';
    //         this.isFromPhoto = true;
    //     }   
    //     this.showAllFun();
    // }   

    // showAllFun(){
    //     this.showCapture = false;
    //     var tmp = this.template.querySelector('.slds-is-relative');
    //     if (tmp) {
    //         tmp.classList.remove('slds-hide');
    //         tmp.classList.add('slds-show');
    //     }
    // }

    // hideAllFun(){
    //     this.showCapture = true;
    //     var tmp = this.template.querySelector('.slds-is-relative');
    //     if (tmp) {
    //         tmp.classList.remove('slds-show');
    //         tmp.classList.add('slds-hide');
    //     }
    // }

    // view Photo Click
    handleViewPhotoClick(ele) {
        if (ele.target.style.width == '10%') {
            ele.target.style.width = '100%';
        } else {
            ele.target.style.width = '10%';
        }
    }
}