/*
 * @Author: YYL
 * @LastEditors: TJP
 * @LastEditTime: 2025-07-31 16:49:14
 * @FilePath: \hisense005\force-app\main\default\lwc\newInspectorReportHomePageLwc\newInspectorReportHomePageLwc.js
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
import { wire , track, api} from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import Id from '@salesforce/user/Id';
import INSPECTION_REPORT_TITLE from '@salesforce/label/c.INSPECTION_REPORT_TITLE';
import INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION from '@salesforce/label/c.INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION';
import INSPECTION_REPORT_NEW from '@salesforce/label/c.INSPECTION_REPORT_NEW';
import INSPECTION_REPORT_FLOORWALKER from '@salesforce/label/c.INSPECTION_REPORT_FLOORWALKER';
import CheckInCheckOut_LOCATION from '@salesforce/label/c.CheckInCheckOut_LOCATION';
import CheckInCheckOut_PHOTO from '@salesforce/label/c.CheckInCheckOut_PHOTO';
import CheckInCheckOut_REMARK from '@salesforce/label/c.CheckInCheckOut_REMARK';
import CheckInCheckOut_REMARK_INFO from '@salesforce/label/c.CheckInCheckOut_REMARK_INFO';
import INSPECTION_REPORT_From_Photo from '@salesforce/label/c.INSPECTION_REPORT_From_Photo';
import INSPECTION_REPORT_From_Fold from '@salesforce/label/c.INSPECTION_REPORT_From_Fold';
import INSPECTION_REPORT_CHECK_ITEM_ISSUES from '@salesforce/label/c.INSPECTION_REPORT_CHECK_ITEM_ISSUES';
import INSPECTION_REPORT_MSG_UNPLANNED_STORE from '@salesforce/label/c.INSPECTION_REPORT_MSG_UNPLANNED_STORE';
import INSPECTION_REPORT_MSG_FUTURE_DATE from '@salesforce/label/c.INSPECTION_REPORT_MSG_FUTURE_DATE';
import { loadStyle } from 'lightning/platformResourceLoader';
import getInitData from '@salesforce/apex/NewInspectorDailyReportController.getInitData';
import refreshPositioning from '@salesforce/apex/NewInspectorDailyReportController.refreshPositioning';
import createRecord from '@salesforce/apex/NewInspectionDailyReportPageController.createRecord';
import refreshData from '@salesforce/apex/NewInspectorDailyReportController.refreshData';
import refreshUpShop from '@salesforce/apex/NewInspectorDailyReportController.refreshUpShop';
import Inspection_Date from '@salesforce/label/c.Inspection_Date';
import Inspection_Store from '@salesforce/label/c.Inspection_Store';
import Inspection_Created_By from '@salesforce/label/c.Inspection_Created_By';
import Inspection_Prior_Visit_Date from '@salesforce/label/c.Inspection_Prior_Visit_Date';
import Position_Correction from '@salesforce/label/c.Position_Correction';
import Coordinate_Description from '@salesforce/label/c.Coordinate_Description';
import Distance from '@salesforce/label/c.Distance';
import Inspection_Type from '@salesforce/label/c.Inspection_Type';
import geolocationGetAddress from '@salesforce/apex/CheckInCheckOutController.geolocationGetAddress';
import Inspection_Type_Tips from '@salesforce/label/c.Inspection_Type_Tips';
	
// import NOT_STORE from '@salesforce/label/c.NOT_STORE';	

export default class NewInspectorReportHomePageLwc extends LightningNavigationElement {

    label = {
        INSPECTION_REPORT_TITLE,            // Title 检查报告
        INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION,   // 当前设备不支持定位功能
        INSPECTION_REPORT_NEW,              // 新建
        INSPECTION_REPORT_FLOORWALKER,      // 巡店员
        INSPECTION_REPORT_CHECK_ITEM_ISSUES,// 历史检查项问题
        INSPECTION_REPORT_MSG_UNPLANNED_STORE,          // 门店为计划外门店，确定要新建此日报
        CheckInCheckOut_PHOTO,          // 拍照
        CheckInCheckOut_REMARK,         // 备注
        CheckInCheckOut_REMARK_INFO,    // 备注信息
        CheckInCheckOut_LOCATION,               // 重新/校准定位
        INSPECTION_REPORT_From_Photo,
        INSPECTION_REPORT_From_Fold,
        INSPECTION_REPORT_MSG_FUTURE_DATE,              // 无法为此记录选择未来日期
        Inspection_Date,// TJP20241108 新增
        Inspection_Store,
        Inspection_Created_By,
        Inspection_Prior_Visit_Date,
        Position_Correction,
        Coordinate_Description,
        Distance,
        Inspection_Type,
        Inspection_Type_Tips,
    }
    
    @track recordId;
    @api storeId;
    @api reportDate;
    @api contentVersionId;
    @track todayDate;
    // 存放门店地址详情信息
    @track storeDistanceInfo;
    // 定位地址详情信息
    @track positionAddress = '';
    @track showAllPage = true;
    @track showCheckItemIssues = false; 
    @track showReportDetail = false; 

    @track currentLat = 0;                      // 当前坐标 Lat
    @track currentLong = 0;                     // 当前坐标 Long‘
    @track ownerName;                           // 所有人名
    @track statusLabel = this.label.INSPECTION_REPORT_NEW;
    
    // Page相关
    @track isShowSpinner = false;               // 加载中
    @track isReportUser = true;                 // 是否为日报所有人
    @track oldReportDate;                       // 旧日期
    @track oldReportDateShow = true;            // 切换日期显示
    @track record = {};                         // 日报主数据信息
    @track storeDistanceList = [];              // 门店信息
    // 打卡部分
    @track todayDate;
    @track nowTime;
    @track storeName;
    @track storeDistance;
    @track attendanceShowPhoto = false;
    @track attendancePhotoStream;
    @track attendanceRemark;
    @track attendanceFromType = 'From Photo';

    @track userId = Id;
    // 自定义弹框
    @track modalMsg;
    @track modalType;
    @track modalHelper;

    @track salesRegion; //TJP 2024 1114 用于隐藏 计划外巡店弹窗
    @track isAustralia = false;
    
    get iOSModel() {
        var userAgent = navigator.userAgent;
        if (/iphone|iPhone|ipad|iPad|ipod|iPod|iOS|ios/.test(userAgent)) {  
            return true;
        } else { 
            return false;
        }
    }
    get AndroidModel() {
        var userAgent = navigator.userAgent;
        if (/android|Android/.test(userAgent)) {  
            return true;
        } else { 
            return false; 
        }
    }

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

    // 浮动效果
    height;
    get topStyle() {
        return this.isMobile === 'PHONE' ? 'max-height: ' + this.height + 'px;' : '';
    }

    get IssueStyle() {
        return 'padding: 0; ' + this.topStyle;
    }

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

    get totalScoreText() {return this.countScore.Total_Score__c + '/' + this.countScore.Total_Score_Max__c;}
    
    get avgScoreText() {return this.countScore.Average_Score__c + '/' + this.countScore.Average_Score_Max__c;}

    // 计算分数
    get countScore() {
        var countScore = {
            Total_Score__c: 0,
            Total_Score_Max__c: 0,
            Average_Score_Count__c: 0,
            Average_Score__c: 0,
            Average_Score_Max__c: 0,
        };
        return countScore;
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


    // 初始化
    connectedCallback() {
        this.giveTime();
        this.isShowSpinner = true;
        // var d = new Date();
        // this.record = {
        //     Report_Date__c: this.reportDate == null ? d.getFullYear()+'-'+(d.getMonth()+1)+'-'+d.getDate() : this.reportDate,
        //     // Store__c: this.storeId,
        //     // Status__c: 'New',
        // };

        // 取消下拉刷新
        this.disablePullToRefresh();
        // 有门店Id
        if (this.storeId!=null && this.storeId!='') {
                        var d = new Date();
            this.record = {
                Report_Date__c: this.reportDate == null ? d.getFullYear()+'-'+(d.getMonth()+1)+'-'+d.getDate() : this.reportDate,
                Store__c: this.storeId,
                Status__c: 'New',
            };
            this.getCurrentPosition(this.refreshData);
        } else {
            console.log('storeId==null');
            this.getCurrentPosition(this.getInitDataBaseRecordId);
        }
        this.start();
    }

    // 获取当前坐标
    getCurrentPosition(callback) {
        this.isShowSpinner = true;
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
        // for (let i = 0; i < this.storeDistanceList.length; i++) {
        //     var storeDistanceItem = this.storeDistanceList[i];
        //     if (this.record.Store__c!=null && this.record.Store__c!='' && this.record.Store__c==storeDistanceItem.storeId) {
        //         this.storeName = storeDistanceItem.storeName;
        //         this.storeDistance = storeDistanceItem.storeDistanceStr;
        //         this.mapMarkers = [
        //             {
        //                 location: {
        //                     Latitude: storeDistanceItem.storeLat,
        //                     Longitude: storeDistanceItem.storeLong,
        //                 },
        //                 value: storeDistanceItem.storeId,
        //             },
        //             {
        //                 location: {
        //                     Latitude: this.currentLat,
        //                     Longitude: this.currentLong,
        //                 },
        //                 value: 'user',
        //                 mapIcon: {
        //                     path: 'M50,10 A40,40 0 1,1 50,90 A40,40 0 1,1 50,10 Z',
        //                     fillColor: '#007FFF',
        //                     fillOpacity: .8,
        //                     strokeWeight: 0,
        //                     strokeColor: '#007FFF',
        //                     strokeOpacity: 1,
        //                     scale: .2,
        //                     anchor: {x: 45, y: 45}
        //                 },
        //             },
        //             {
        //                 location: {
        //                     Latitude: this.currentLat,
        //                     Longitude: this.currentLong,
        //                 },
        //                 value: 'circle',
        //                 type: 'Circle',
        //                 radius: storeDistanceItem.checkInDistance,
        //                 strokeColor: '#00FF00',
        //                 strokeOpacity: 0.8,
        //                 strokeWeight: 2,
        //                 fillColor: '#00FF00',
        //                 fillOpacity: 0.2,
        //             },
        //         ];
        //     }
        // }
    }


    // ---------------> ↑ Button click ↑ <---------------
    // ---------------> ↓ onchange ↓ <---------------
    // 日期变更
    handleChangeReportDate(event) {
        this.isShowSpinner = true;
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

    @track typeInvalid = false;
    @track errorClass = '';
    handleInspectType(event) {
        const val = event.target.value;
        this.typeInvalid = false;
        this.errorClass = '';
        this.record.Inspect_Type__c = val;
    }
    
    storeLabel;
    // 门店变更
    handleChangeShopOption(event) {
        if(event.target.value != ''){
            this.isShowSpinner = true;
            this.record.Store__c = event.detail.value + '';
            // this.storeLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
            this.storeId = event.detail.value + '';
            // 修改门店时清除掉上次上传的照片 20241122 YYL
            this.handleDelPhotoClick();
            this.getCurrentPosition(this.refreshData);
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

    // view Photo Click
    handleViewPhotoClick(ele) {
        if (ele.target.style.width == '10%') {
            ele.target.style.width = '100%';
        } else {
            ele.target.style.width = '10%';
        }
    }

    // del Photo Click
    handleDelPhotoClick() {
        this.attendancePhotoStream = null;
        this.attendanceShowPhoto = false;
        this.attendanceFromType = 'From Photo';
        this.isFromPhoto = true;
    }

    // iOS Photo Click
    async handlephotoClick(event) {
        var type = event.target.dataset.id;
        alert(type);
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
        } 
        // else if (type == 'checkout') {
        //     this.attendancePhotoStreamCheckOut = convertBase64;
        //     this.attendanceShowPhotoCheckOut = true;
    
        //     this.phoneInfoCheckOut = convertBase64;
        // }
    }

    // Added By Sunny Start
    handleShowItemIssues() {
        this.showAllPage = false;
        this.showCheckItemIssues = true;
    }

    handleCloseItemIssues() {
        this.showCheckItemIssues = false;
        this.showAllPage  = true;
        // this.activeSections = [];
    }

    // Added By Sunny Start
    handleShowReportDetail() {
        this.showAllPage = false;
        this.showReportDetail = true;
    }

    handleCloseReportDetail() {
        this.showReportDetail = false;
        this.showAllPage  = true;
        // this.activeSections = [];
    }

    // 根据返回数据判断展示首页还是详情页
    handleShowNewHistory(event) {
        let flag = event.detail.flag;
        this.record.Report_Date__c = event.detail.reportDate
        this.record.Store__c = event.detail.storeId
        this.storeId = event.detail.storeId

        if(flag){
            this.showReportDetail = false;
            this.showAllPage = true;
        }

        // this.record.Store__c = event.detail.value + '';
        // this.storeId = event.detail.value + '';
        this.getCurrentPosition(this.refreshData);
    }

    // Remark字符
    handleRemarkInput(event) {
        this.attendanceRemark = event.target.value;
    }

    // 自定义弹窗
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
        this[this.modalType](this.modalHelper);
    }

    // Create click
    async handleCreate() {
        //增加澳洲巡店类型必填校验
        if(this.isAustralia && !this.record.Inspect_Type__c || this.isAustralia &&this.record.Inspect_Type__c == '--None--'){
            this.typeInvalid = true;
            this.errorClass = 'slds-has-error';
        } else {
            // this.isShowSpinner = true;
            // 检查是否为计划外门店
            var filteredList = this.storeDistanceList.filter(obj => obj.storeId == this.record.Store__c);
            if(this.salesRegion == 'Hisense International') {
                this.getCurrentPosition(this.createRecords);
            } else {
                if (filteredList[0].storeName.charAt(0)=='*') {
                    this.getCurrentPosition(this.createRecords);
                } else {
                    this.handleShow(
                    this.label.INSPECTION_REPORT_MSG_UNPLANNED_STORE.format(filteredList[0].storeName),
                    'getCurrentPosition', this.createRecords); 
                    this.isShowSpinner = false;
                }
            }
        }
        
        
    }

    // 初始化获取数据
    getInitDataBaseRecordId(ele) {
        ele.isShowSpinner = true;
        getInitData({
            recordId: ele.recordId, currentLat: ele.currentLat, currentLong: ele.currentLong, shopId: ele.storeId // 门店没有配置巡店员可显示
        }).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    ele[key] = data.data[key];
                    if(key == 'salesRegion'){
                        let salesRegion = data.data[key];
                        ele.salesRegion = salesRegion;
                        ele.isAustralia = salesRegion == 'Hisense Australia' ? true : false;
                        console.log('this.salesRegion' + ele.salesRegion);
                        console.log('salesRegion' + salesRegion);
                    }
                }

                console.log('wwwwele.record' + JSON.stringify(ele.record));

                if(ele.record.Id != null){
                    ele.showReportDetail = true;
                    ele.showAllPage  = false;
                }

                // 无历史数据，设置打卡地图
                // ele.isTitleShowButton = false;
                // ele.isFieldReadOnly = true;
                // ele.setMapInformation();
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

                if(ele.record.Id != null){
                    ele.showReportDetail = true;
                    ele.showAllPage  = false;
                }

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

    // 刷新数据
    refreshData(ele) {
        // ele.giveTime();
        ele.isShowSpinner = true;
        refreshData({
            recordJson: JSON.stringify(ele.record), currentLat: ele.currentLat, currentLong: ele.currentLong, contentVersionId: ele.contentVersionId,
            shopId: ele.storeId  
        }).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    ele[key] = data.data[key];
                    if(key == 'salesRegion'){
                        let salesRegion = data.data[key];
                        ele.salesRegion = salesRegion;
                        console.log('this.salesRegion' + ele.salesRegion);
                        console.log('salesRegion' + salesRegion);
                    }
                }

                console.log('wwwwstoreDistanceInfo' + JSON.stringify(ele.storeDistanceInfo));
                console.log('wwwwpositionAddress' + JSON.stringify(ele.positionAddress));

                if(ele.record.Id != null){
                    ele.showReportDetail = true;
                    ele.showAllPage  = false;
                    ele.recordId = ele.record.Id;
                }
                
                // 无历史数据，设置打卡地图
                ele.isTitleShowButton = false;
                ele.isFieldReadOnly = true;
                // ele.setMapInformation();
                ele.attendanceShowPhotoCheckOut = false;
                ele.attendancePhotoStreamCheckOut = null;
                // ele.attendanceRemarkCheckOut = null;

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
    createRecords(ele) {
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

                if(ele.record.Id != null){
                    ele.showReportDetail = true;
                    ele.showAllPage  = false;
                }

                ele.isShowSpinner = false;
                // 创建成功跳转到详情页面
                console.log(JSON.stringify(data));
                ele.recordId = ele.record.Id;
                ele.showReportDetail = true;
                ele.showAllPage = false;
            }else{
                ele.isShowSpinner = false;
                ele.showError(data.message);
            }
        }).catch(error => {
            ele.catchError(error);
            ele.isShowSpinner = false;
        });
    }

    goToStoreQuery(event) {
        event.stopPropagation();
        // console.log('goToStoreQuery');
        this.createRecord('Shop__c','','','','');
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
            this.isShowSpinner = false;
            this.positionAddress = data;
        }).catch(error => {
            this.catchError(JSON.stringify(error));
            this.isShowSpinner = false;
        });
    }

    giveTime() {
        this.formattedDate = '';
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