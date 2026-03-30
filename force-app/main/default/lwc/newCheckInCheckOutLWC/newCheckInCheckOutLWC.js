import { LightningElement,track,wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import getVisualforceOrigin from '@salesforce/apex/CommonGoogleMapController.getVisualforceOrigin';
import {GoogleMapApi, LightningNavigationElement} from 'c/lwcUtils'
import FORM_FACTOR from '@salesforce/client/formFactor';


import initStoreInfo from '@salesforce/apex/NewCheckInCheckOutController.initStoreInfo';
import getBase64Stream from '@salesforce/apex/NewCheckInCheckOutController.getBase64Stream';
// import getStoreInfo from '@salesforce/apex/NewCheckInCheckOutController.getStoreInfo';
import checkIn from '@salesforce/apex/NewCheckInCheckOutController.checkIn';
import checkOut from '@salesforce/apex/NewCheckInCheckOutController.checkOut';
// import getPromoterAttendance from '@salesforce/apex/NewCheckInCheckOutController.getPromoterAttendance';

import CheckInCheckOut_STORE_NAME from '@salesforce/label/c.CheckInCheckOut_STORE_NAME';
import CheckInCheckOut_CHANNEL from '@salesforce/label/c.CheckInCheckOut_CHANNEL';
import CheckInCheckOut_DISTANCE_KM from '@salesforce/label/c.CheckInCheckOut_DISTANCE_KM';
// import CheckInCheckOut_CHECK_IN_STATUS from '@salesforce/label/c.CheckInCheckOut_CHECK_IN_STATUS';
import CheckInCheckOut_REMARK from '@salesforce/label/c.CheckInCheckOut_REMARK';
import CheckInCheckOut_REMARK_INFO from '@salesforce/label/c.CheckInCheckOut_REMARK_INFO';
// import CheckInCheckOut_TIME from '@salesforce/label/c.CheckInCheckOut_TIME';
import CheckInCheckOut_PHOTO from '@salesforce/label/c.CheckInCheckOut_PHOTO';

import CheckInCheckOut_MOBILE_NOT_ALLOW from '@salesforce/label/c.CheckInCheckOut_MOBILE_NOT_ALLOW';
import CheckInCheckOut_WITHOUT_POSITION from '@salesforce/label/c.CheckInCheckOut_WITHOUT_POSITION';
import CheckInCheckOut_LEAST_CHAR from '@salesforce/label/c.CheckInCheckOut_LEAST_CHAR';
import CheckInCheckOut_NOT_MOBILE from '@salesforce/label/c.CheckInCheckOut_NOT_MOBILE';
import CheckInCheckOut_NOT_SUPPORT_GEOLOCATION from '@salesforce/label/c.CheckInCheckOut_NOT_SUPPORT_GEOLOCATION';

import CheckInCheckOut_CHECK_IN_SUCCESS from '@salesforce/label/c.CheckInCheckOut_CHECK_IN_SUCCESS';
import CheckInCheckOut_CHECK_OUT_SUCCESS from '@salesforce/label/c.CheckInCheckOut_CHECK_OUT_SUCCESS';
import CheckInCheckOut_OPEN_GEOLOCATION from '@salesforce/label/c.CheckInCheckOut_OPEN_GEOLOCATION';
import CheckInCheckOut_NO_PHOTO_ERROR from '@salesforce/label/c.CheckInCheckOut_NO_PHOTO_ERROR';
import CheckInCheckOut_OUT_OF_CHECK_IN_RANGE from '@salesforce/label/c.CheckInCheckOut_OUT_OF_CHECK_IN_RANGE';


import CheckInCheckOut_Title from '@salesforce/label/c.CheckInCheckOut_Title';
// import CheckInCheckOut_DEVICE from '@salesforce/label/c.CheckInCheckOut_DEVICE';
// import CheckInCheckOut_GEOLOCATION from '@salesforce/label/c.CheckInCheckOut_GEOLOCATION';
import CheckInCheckOut_LOCATION from '@salesforce/label/c.CheckInCheckOut_LOCATION';
import CheckInCheckOut_QUERY_STORE from '@salesforce/label/c.CheckInCheckOut_QUERY_STORE';
import CheckInCheckOut_QUERY from '@salesforce/label/c.CheckInCheckOut_QUERY';

// import CheckInCheckOut_CHECK_DATE from '@salesforce/label/c.CheckInCheckOut_CHECK_DATE';
// import CheckInCheckOut_RETURN from '@salesforce/label/c.CheckInCheckOut_RETURN';
import CheckInCheckOut_CHECK_IN from '@salesforce/label/c.CheckInCheckOut_CHECK_IN';
import CheckInCheckOut_CHECK_IN_INFO from '@salesforce/label/c.CheckInCheckOut_CHECK_IN_INFO';
import CheckInCheckOut_CHECK_OUT from '@salesforce/label/c.CheckInCheckOut_CHECK_OUT';
import CheckInCheckOut_CHECK_OUT_INFO from '@salesforce/label/c.CheckInCheckOut_CHECK_OUT_INFO';
import CheckInCheckOut_CANCEL from '@salesforce/label/c.CheckInCheckOut_CANCEL';
import CheckInCheckOut_CONFIRM from '@salesforce/label/c.CheckInCheckOut_CONFIRM';

import CheckInCheckOut_CURRENT_ADDR from '@salesforce/label/c.CheckInCheckOut_CURRENT_ADDR';

import CheckInCheckOut_WITHIN_RANGE from '@salesforce/label/c.CheckInCheckOut_WITHIN_RANGE';
// import CheckInCheckOut_OUT_OF_RANGE from '@salesforce/label/c.CheckInCheckOut_OUT_OF_RANGE';
import CheckInCheckOut_START_TIME from '@salesforce/label/c.CheckInCheckOut_START_TIME';
import CheckInCheckOut_END_TIME from '@salesforce/label/c.CheckInCheckOut_END_TIME';
import CheckInCheckOut_SHIFT from '@salesforce/label/c.CheckInCheckOut_SHIFT';

import CheckInCheckOut_TYPE from '@salesforce/label/c.CheckInCheckOut_TYPE';
import CheckInCheckOut_STATUS from '@salesforce/label/c.CheckInCheckOut_STATUS';
import CheckInCheckOut_RECORDED from '@salesforce/label/c.CheckInCheckOut_RECORDED';
import CheckInCheckOut_STORE from '@salesforce/label/c.CheckInCheckOut_STORE';
import CheckInCheckOut_More from '@salesforce/label/c.CheckInCheckOut_More';
import CheckInCheckOut_CheckDateTimePosition from '@salesforce/label/c.CheckInCheckOut_CheckDateTimePosition';
// import CheckInCheckOut_ADDRESS from '@salesforce/label/c.CheckInCheckOut_ADDRESS';

// import CheckInCheckOut_CURRENT_LOCATION from '@salesforce/label/c.CheckInCheckOut_CURRENT_LOCATION';
// import CheckInCheckOut_REFRESH_POSITIONING from '@salesforce/label/c.CheckInCheckOut_REFRESH_POSITIONING';

export default class NewCheckInCheckOutLWC extends LightningNavigationElement {
    label = {
        CheckInCheckOut_STORE_NAME,//门店
        CheckInCheckOut_CHANNEL,//经销商渠道
        CheckInCheckOut_DISTANCE_KM,//距离(KM)
        // CheckInCheckOut_CHECK_IN_STATUS,//考勤状态
        CheckInCheckOut_REMARK,//备注
        CheckInCheckOut_REMARK_INFO,//备注信息
        // CheckInCheckOut_TIME,//当前时间
        CheckInCheckOut_PHOTO,//拍照


        CheckInCheckOut_MOBILE_NOT_ALLOW,//非移动端不可签到
        CheckInCheckOut_WITHOUT_POSITION,//未获取当前定位信息，不可签到
        CheckInCheckOut_LEAST_CHAR,//输入的查询门店信息不少于两个字符
        CheckInCheckOut_NOT_MOBILE,//非移动端
        CheckInCheckOut_NOT_SUPPORT_GEOLOCATION,//当前设备不支持定位功能
        CheckInCheckOut_CHECK_IN_SUCCESS,//签到成功
        CheckInCheckOut_CHECK_OUT_SUCCESS,//签退成功
        CheckInCheckOut_OPEN_GEOLOCATION,//请开启定位服务,并刷新页面
        CheckInCheckOut_NO_PHOTO_ERROR,//打卡失败，请上传照片
        CheckInCheckOut_OUT_OF_CHECK_IN_RANGE,//超出打卡范围

        CheckInCheckOut_Title, //签到签退
        // CheckInCheckOut_DEVICE,//当前设备
        // CheckInCheckOut_GEOLOCATION,//当前经纬度
        CheckInCheckOut_LOCATION,//重新/校准定位
        CheckInCheckOut_QUERY_STORE,//查询门店
        CheckInCheckOut_QUERY,//查询
        // CheckInCheckOut_CHECK_DATE,//签到/签退日期
        // CheckInCheckOut_RETURN,//返回
        CheckInCheckOut_CHECK_IN,//签到
        CheckInCheckOut_CHECK_IN_INFO,//签到信息
        CheckInCheckOut_CHECK_OUT,//签退
        CheckInCheckOut_CHECK_OUT_INFO,//签退信息
        CheckInCheckOut_CANCEL,//取消
        CheckInCheckOut_CONFIRM,//确认
        CheckInCheckOut_CURRENT_ADDR,//当前地址

        CheckInCheckOut_WITHIN_RANGE,//在范围内
        // CheckInCheckOut_OUT_OF_RANGE,//超出范围
        CheckInCheckOut_START_TIME,//开始时间
        CheckInCheckOut_END_TIME,//结束时间
        CheckInCheckOut_SHIFT,//转换

        CheckInCheckOut_TYPE,//类型
        CheckInCheckOut_STATUS,//状态
        CheckInCheckOut_RECORDED,//记录
        CheckInCheckOut_STORE,//门店
        // CheckInCheckOut_ADDRESS,//地址

        // CheckInCheckOut_CURRENT_LOCATION,//当前位置
        // CheckInCheckOut_REFRESH_POSITIONING,//刷新定位
        CheckInCheckOut_More,//More
        CheckInCheckOut_CheckDateTimePosition,//检查日期、时间、当前坐标
    }

    // PROMOTE_PROFILE = '促销员'; //判断值，不需要翻译
    // INSPECTION_PROFILE = '巡店员';//判断值，不需要翻译

    @track device = ''; //当前设备信息
    @track positionLong; //当前lng坐标
    @track positionLati; //当前lat坐标
    @track position; //当前坐标
    @track addressStr; //当前地址
    @track checkInStatusLabel;
    @track checkInStatusAPIValue; //当前用户签到状态

    @track storeNameStr; //当前所选门店名
    @track storeId; //当前所选门店Id
    @track storeDistance; //当前所选门店距离
    @track storeRoleDistance; //当前所选门店距离

    // 签到信息
    @track startTime = '--:--';
    @track checkInType = '/';
    @track checkInStatus = 'No record';
    @track checkInRecorded = '/';
    @track checkInShopName = '/';
    @track checkInAddress = '/';

    // 签退信息
    @track endTime = '--:--';
    @track checkOutType = '/';
    @track checkOutStatus = 'No record';
    @track checkOutRecorded = '/';
    @track checkOutShopName = '/';
    @track checkOutAddress = '/';

    @track thisDay; //当前日期
    @track thisTime; //当前时间
    @track userType; //当前用户简档

    @track isPC = false; //是否为PC
    @track isShowSpinner = false; //loading加载动画

    // Title 按钮有效性
    @track isCheckIn = true; //CheckIn按钮
    @track isCheckOut = true; //CheckOut按钮

    // 页面显示
    @track isTitlePage = true; //按钮页面页面
    @track isDetailsPage = true; //主页面
    @track isShiftPage = false; //门店选择页面
    @track isAttendancePage = false; //shift页面

    // 门店显示页面用
    @track shiftStoreId; //所选门店Id
    @track shiftStoreName; //所选门店名
    @track shiftSearchInfo = ''; //查询门店
    @track shiftSearchStorInfo = []; //查询后门店

    // 签到签退页面用
    @track attendanceType; //所选门店打卡类型
    @track attendanceShowPhoto = false; //显示预览
    @track attendancePhotoStream; //拍照图片字节流
    @track attendanceRemark; //打卡备注
    @track attendanceIsCheckIn = true; //用作判断check in/out按钮来源 true：check in  false：check out
    @track attendanceIsOnseit = true; //用作判断Onsite/Offsite true：Onsite  false：Offsite

    @track columns = [
        {
            label: this.label.CheckInCheckOut_STORE_NAME,
            fieldName: 'Name',
            type: 'text',
            wrapText: true
        },
        {
            label: this.label.CheckInCheckOut_CHANNEL,
            fieldName: 'Channel',
            type: 'text',
        },{
            label: this.label.CheckInCheckOut_DISTANCE_KM,
            fieldName: 'Distance',
            type: 'text'
        }
    ];
    @track datas = [];

    googleMapApi;//GoodleMap对象
    visualForceOrigin;//VF url
    
    @track style = FORM_FACTOR == 'Small' ? 'margin-top: ' + (document.documentElement.clientHeight - 130) + 'px;' : '';
    refreshStyle() {
        this.style =  FORM_FACTOR == 'Small' ? 'max-height: ' + (document.documentElement.clientHeight - 130) + 'px;' : '';
    }

    get styletest() {
        return 'padding: 0px;';
    }
    
    // VF进入启动用
    @api clientModel;
    @api openVf;
    @api showVfSuccess;
    @api showVfError;
    @api gotoLwc;
    @track showAllPage = false;
    @api shopId;
    @api contentVersionId;
    get iOSModel() {
        // if (this.clientModel=='iOS') {
        //     return true;
        // }
        // return false;

        var userAgent = navigator.userAgent;
        if (/iphone|iPhone|ipad|iPad|ipod|iPod|iOS|ios/.test(userAgent)) { 
            return true;
        } else {
            return false;
        }
        // return true;
    }
    get AndroidModel() {
        // if (this.clientModel=='Android') {
        //     return true;
        // }
        // return false;

        var userAgent = navigator.userAgent;
        if (/android|Android/.test(userAgent)) { 
            return true;
        } else {
            return false;
        }
        // return true;
    }

    googleMapInitState = false;
    googleMapVFUrl = '';
    navigatorInfo = '';
    // 初始化
    connectedCallback() {
        this.navigatorInfo += 'userAgent:'+navigator.userAgent+'\n';
        this.navigatorInfo += 'vendor:'+navigator.vendor+'\n';
        this.navigatorInfo += 'platform:'+navigator.platform+'\n';
        this.navigatorInfo += 'oscpu:'+navigator.oscpu+'\n';
        this.navigatorInfo += 'appVersion:'+navigator.appVersion+'\n';
        // if (this.clientModel==null && this.openVf==null) {
        //     var url = '/apex/CheckInOutCapturePage';

        //     this[NavigationMixin.Navigate]({
        //         type: 'standard__webPage',
        //         attributes: {
        //             url: url
        //         }
        //     });
        //     return;
        // } else {
        //     this.showAllPage = true;
        // }
        this.showAllPage = true;

        this.isShowSpinner = true;
        // 初始化Google Map
        this.googleMapApi = new GoogleMapApi();
        this.checkVisualforceOrigin();
        this.googleMapVFUrl = '/apex/CommonGoogleMapPage';
        // this.isPCJudgement(); //测试时，可注释掉该判断
        var userAgentInfo = window.navigator.userAgent;
        var Agents = ["Android", "iPhone", "YunOS","Windows Phone","iPad","iPod","SymbianOS","BlackBerry OS"];
        var flag = true;
        for (var i = 0;  i<Agents.length; i++){
            if (userAgentInfo.indexOf(Agents[i]) >= 0){
                this.device = Agents[i];
                flag = false;
                break;
            }
        }
        this.isPC = flag;
        if(this.isPC) {
            this.device = this.label.CheckInCheckOut_NOT_MOBILE;
        }
        this.getCurrentPosition(false);
    }

    // 地图返回信息
    googleMapCallback(info, ele) {
        ele.googleMapInitState = true;
        console.log('api callback '+JSON.stringify(info));
        var config = {
            "ele": ele,
            "iframeId": "googleMap",
            "data": {
                "config": {
                    "position": {
                        "lat": ele.positionLati,
                        "lng": ele.positionLong
                    },
                    "zoom": 18
                },
                "markers":[
                    {
                        "action": "new",
                        "type": "point",
                        "id": "me",
                        "position": {
                            "lat": ele.positionLati,
                            "lng": ele.positionLong
                        },
                        "label": "",
                        "isShow" : true
                    }
                ]
            }
        };
        // 初始化
        if (info.type === 'NeedInitConfig') {
            setTimeout(function() {
                // ele.googleMapApi.sendMessageToChild(config);
                ele.checkGoogleMapInit(config);
            }, 2000);
        }
        
        // marker 点击返回id
        if (info.type === 'MarkerId') {
            ele.shiftStoreId = info.data;
            var filteredList = ele.datas.filter(obj => obj.Id == ele.shiftStoreId);
            ele.shiftStoreName = filteredList[0].Name;
        }
    }

    // 线程监听
    checkGoogleMapInit (config) {
        if (this.googleMapInitState==false) {
            setTimeout(() => {
                this.checkGoogleMapInit(config);
            }, 500);
        } else {
            this.googleMapApi.sendMessageToChild(config);
        }
    }

    // 获取初始化数据
    initStoreInformation() {
        this.isShowSpinner = true;
        this.isCheckOut = true;
        this.isCheckIn = true;
        initStoreInfo({lati: this.positionLati, lng: this.positionLong}).then(
            result=>{
                this.isShowSpinner = false;
                console.log(result);
                if(result.isSuccess) {
                    // this.handleRefresh();
                    this.datas = result.dataList;
                    this.thisDay = result.thisDay;
                    this.thisTime = result.thisTime;
                    this.userType = result.userType;
                    this.addressStr = result.addressStr;
                    this.checkInStatusLabel = result.checkInStatusLabel;
                    this.checkInStatusAPIValue = result.checkInStatus;

                    if (this.shopId && this.datas.filter(obj => this.shopId == obj.Id).length>0) {
                        var selectedShop = this.datas.filter(obj => this.shopId == obj.Id);
                        this.checkStoreRoleInfo(selectedShop[0]);
                    } else if (this.datas.length > 0) {
                        this.checkStoreRoleInfo(this.datas[0])
                    }
                    // 判断签到签退信息
                    this.checkInOutInfo(result);
                    // 判断签到签退按钮状态
                    this.handleChange();
                    // 显示主页面
                    this.changeShowPage('DetailsPage');
                    // 判断是否需要预加载图片
                    this.checkcontentVersionId();
                }else{
                    this.showNotification("", result.failMessage ,"error");
                    // this.showVfError(result.failMessage);
                }
        }).catch(error => {
            this.isShowSpinner = false;
            this.showNotification("", error.message ,"error");
            // this.showVfError(error.message);
        });
    }

    // 所选门店信息
    checkStoreRoleInfo(data) {
        this.storeId = data.Id;
        this.storeNameStr = data.Name;
        this.storeDistance = data.roleDistanceText;
        this.storeRoleDistance = data.roleDistance;
        this.startTime = data.roleStartTime ? data.roleStartTime : '--:--';
        this.endTime = data.roleEndTime ? data.roleEndTime : '--:--';
    }

    // 签到签退信息
    checkInOutInfo(data) {
        this.checkInType = data.checkInType ? data.checkInType : '/';
        this.checkInStatus = data.checkInTimeStatus ? data.checkInTimeStatus : 'No record';
        this.checkInRecorded = data.checkInTime ? data.checkInTime : '/';
        this.checkInShopName = data.checkInShopName ? data.checkInShopName : '/';
        this.checkInAddress = data.checkInAddress ? data.checkInAddress : '/';
    
        this.checkOutType = data.checkOutType ? data.checkOutType : '/';
        this.checkOutStatus = data.checkOutTimeStatus ? data.checkOutTimeStatus : 'No record';
        this.checkOutRecorded = data.checkOutTime ? data.checkOutTime : '/';
        this.checkOutShopName = data.checkOutShopName ? data.checkOutShopName : '/';
        this.checkOutAddress = data.checkOutAddress ? data.checkOutAddress : '/';
    }

    checkcontentVersionId() {
        if (this.contentVersionId) {
            getBase64Stream({
                contentVersionId : this.contentVersionId
            }).then(result=>{
                if(result!='') {
                    this.attendancePhotoStream = 'data:image/jpeg;base64,'+result.slice(1).slice(0,-1);
                    console.log(this.attendancePhotoStream);
                    this.attendanceShowPhoto = true;
                }
            })
        }
    }

    removeApiValue() {
        this.contentVersionId = null;
        this.shopId = null;
        this.handleDelPhotoClick();
    }

    // 判断签到签退状态
    handleChange() {
        if (this.thisDay!=null && this.thisTime!=null && this.positionLong!=null && this.positionLati!=null && this.storeId!=null) {
            this.isCheckOut = false;
            this.isCheckIn = false;
        } else {
            // this.showNotification('error','检查日期、时间、当前坐标','error');
            this.showNotification('error',this.label.CheckInCheckOut_CheckDateTimePosition,'error');
            // this.showVfError(this.label.CheckInCheckOut_CheckDateTimePosition);
        }
    }

    // Remark字符
    handleRemarkInput(event) {
        this.attendanceRemark = event.target.value;
        
        this.refreshStyle();
    }

    // 签到click
    handleCheckIn() {
        var filteredList = this.datas.filter(obj => obj.Id == this.storeId);
        var needCheckDistance = filteredList[0].roleNeedCheckDistance;
        if (needCheckDistance && this.storeDistance != CheckInCheckOut_WITHIN_RANGE) {
            this.showNotification("", this.label.CheckInCheckOut_OUT_OF_CHECK_IN_RANGE ,"error");
            // this.showVfError(this.label.CheckInCheckOut_OUT_OF_CHECK_IN_RANGE);
        } else if (this.attendanceIsOnseit == false && this.attendancePhotoStream==null) {
            this.showNotification("", this.label.CheckInCheckOut_NO_PHOTO_ERROR ,"error");
            // this.showVfError(this.label.CheckInCheckOut_NO_PHOTO_ERROR);
        } else if(this.position != '' && this.position != undefined && this.position != null){
            this.callCheckIn();
        }else{
            this.showNotification("", this.label.CheckInCheckOut_WITHOUT_POSITION ,"error");
            // this.showVfError(this.label.CheckInCheckOut_WITHOUT_POSITION);
        }
    }

    // 签退click
    handleCheckOut() {
        var filteredList = this.datas.filter(obj => obj.Id == this.storeId);
        var needCheckDistance = filteredList[0].roleNeedCheckDistance;
                
        // 签退逻辑
        // PC测试注释
        // if(this.isPC){
        //     this.showNotification('error',this.label.CheckInCheckOut_MOBILE_NOT_ALLOW,'error');
        // }else 
        if (needCheckDistance && this.storeDistance != CheckInCheckOut_WITHIN_RANGE) {
            this.showNotification("", this.label.CheckInCheckOut_OUT_OF_CHECK_IN_RANGE ,"error");
            // this.showVfError(this.label.CheckInCheckOut_OUT_OF_CHECK_IN_RANGE);
        } else if (this.attendanceIsOnseit == false && this.attendancePhotoStream==null) {
            this.showNotification("", this.label.CheckInCheckOut_NO_PHOTO_ERROR ,"error");
            // this.showVfError(this.label.CheckInCheckOut_NO_PHOTO_ERROR);
        } else if(this.position != '' && this.position != undefined && this.position != null){
            this.callCheckOut();
        }else{
            this.showNotification("", this.label.CheckInCheckOut_WITHOUT_POSITION ,"error");
            // this.showVfError(this.label.CheckInCheckOut_WITHOUT_POSITION);
        }  
    }

    // Shift Click
    handleShift() {
        this.shiftStoreId = this.storeId;
        this.shiftStoreName = this.storeNameStr;
        this.changeShowPage('ShiftPage');
    }

    // 查询门店字符
    handleSearchInput(event) {
        this.shiftSearchInfo = event.target.value;
    }

    // 查询事件
    handleSearch() {
        if(this.shiftSearchInfo.length > 0 && this.shiftSearchInfo.length < 2) {
            this.showNotification('error', this.label.CheckInCheckOut_LEAST_CHAR, 'error');
            // this.showVfError(this.label.CheckInCheckOut_LEAST_CHAR);
        } else if (this.shiftSearchInfo.length == 0) {
            this.shiftSearchStorInfo = this.datas;
        } else {
            var filteredList = this.datas.filter(obj => obj.Name.includes(this.shiftSearchInfo));
            this.shiftSearchStorInfo = filteredList;
        }
    }
    
    // store 点击事件
    handleItem(event) {
        this.shiftStoreId = event.detail.selectedRows[0].Id;
        this.shiftStoreName = event.detail.selectedRows[0].Name;
    }

    // 判断是否为PC
    isPCJudgement() {
        var userAgentInfo = window.navigator.userAgent;
        var Agents = ["Android", "iPhone", "YunOS","Windows Phone","iPad","iPod","SymbianOS","BlackBerry OS"];
        var flag = true;
        for (var i = 0;  i<Agents.length; i++){
            if (userAgentInfo.indexOf(Agents[i]) > 0){
                this.device = Agents[i];
                flag = false;
                break;
            }
        }
        this.isPC = flag;
        if(this.isPC) {
            this.device = this.label.CheckInCheckOut_NOT_MOBILE;
        }
    }

    // Cancel Click
    handleCancel() {
        this.changeShowPage('DetailsPage');
    }

    // Confirm Click
    handleConfirm() {
        this.storeId = this.shiftStoreId;

        var filteredList = this.datas.filter(obj => obj.Id == this.storeId);
        this.checkStoreRoleInfo(filteredList[0]);

        this.changeShowPage('DetailsPage');
    }
    
    // Android Photo Click
    handleAndroidPhotoClick() {
        this.hideAllFun();
        // this.showAllPage = false;
        // this.openVf(this);
        
        // var url = '/apex/CommonCapturePage?';
        // url +=('storeId='+encodeURIComponent(this.storeId)+'&');
        // url +=('type='+encodeURIComponent('CheckInOut')+'&');
        // console.log(url);
        
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: url
        //     }
        // });
    }

    // Photo Click
    async handlephotoClick(event) {
        console.log('Photo click');
        
        var file = event.target.files[0];
        // 获取上传图片的base64
        var uploadBase64 = await new Promise(resolve => {
            // 文件读取
            var reader = new FileReader();
            reader.onload = () => {
                // const base64String = reader.result.split(',')[1];
                var uploadBase64 = reader.result;
                resolve(uploadBase64);
                // console.log('Name:', file.name, 'Base64 string:', uploadBase64);
            };
            reader.readAsDataURL(file);
        });
        console.log(uploadBase64);
        console.log(uploadBase64.length);
        
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
        console.log(convertBase64);
        console.log(convertBase64.length);

        this.attendancePhotoStream = convertBase64;
        this.attendanceShowPhoto = true;

        this.refreshStyle();
    }
    // del Photo Click
    handleDelPhotoClick() {
        this.attendancePhotoStream = null;
        this.attendanceShowPhoto = false;
        
        this.refreshStyle();
    }
    
    // view Photo Click
    handleViewPhotoClick(ele) {
        if (ele.target.style.width == '10%') {
            ele.target.style.width = '100%';
        } else {
            ele.target.style.width = '10%';
        }
        
        this.refreshStyle();
    }

    // 跳转到view list
    handleViewList() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Promoter_Attendance__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
        // this.gotoLwc();
    }

    // 刷新定位信息
    getHighAccuracyPosition() {
        this.isShowSpinner = true;
        this.getCurrentPosition(true);
    }

    // 获取当前经纬度
    getCurrentPosition(highAccuracy){
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                // 测试用 设置固定当前坐标
                // var testPosition = {
                //     "coords":{
                //         "latitude": 23.134319370221707,
                //         "longitude": 113.33652718795777
                //     }
                // }
                // this.handleSuccess(testPosition);
                this.handleSuccess(position);
                // 更新地图显示
                if (!highAccuracy) {
                    // this.checkVisualforceOrigin();
                } else {
                    var config = {
                        "ele": this,
                        "iframeId": "googleMap",
                        "data": {
                            "config": {
                                "position": {
                                    "lat": this.positionLati,
                                    "lng": this.positionLong
                                },
                                "zoom": 18
                            },
                            "markers":[
                                {
                                    "action": "new",
                                    "id": "me",
                                    "position": {
                                        "lat": this.positionLati,
                                        "lng": this.positionLong
                                    },
                                    "label": "",
                                    "isShow" : true
                                }
                            ]
                        }
                    };
                    // this.googleMapApi.sendMessageToChild(config);
                    this.checkGoogleMapInit(config);
                }
            }, error =>{
                this.handleError(error);
            },{ enableHighAccuracy:highAccuracy,timeout: 10000}
            );
        }else {
            this.showNotification('error', this.label.CheckInCheckOut_NOT_SUPPORT_GEOLOCATION, 'error');
            // this.showVfError(this.label.CheckInCheckOut_NOT_SUPPORT_GEOLOCATION);
        }
    }

    // 初始化地图
    checkVisualforceOrigin() {
        var config = {
            "ele": this,
            "callback": this.googleMapCallback,
            "visualForceOrigin": this.visualForceOrigin,
            "iframeId": 'googleMap'
        };

        this.googleMapApi.init(config);
        // if (!this.visualforceOrigin) {
        //     getVisualforceOrigin().then(result => {
        //         this.visualforceOrigin = result;
        //         config.visualForceOrigin = result;

        //         this.googleMapApi.init(config);
        //         // this.googleMapApi.sendMessageToChild(configInfo);
        //     });
        // } else {
        //     this.googleMapApi.init(config);
        //     // this.googleMapApi.sendMessageToChild(configInfo);
        // }
    }
    
    // check in 操作
    callCheckIn() {
        this.isShowSpinner = true;
        this.isCheckOut = true;
        this.isCheckIn = true;
        checkIn({
            curStatus: this.checkInStatusAPIValue, 
            storeId: this.storeId,
            lati: this.positionLati,
            lng: this.positionLong,
            device: this.device,
            addressStr: this.addressStr,
            remark: this.attendanceRemark,
            photoStream: this.attendancePhotoStream,
            navigatorInfo: this.navigatorInfo
        }).then(
            result=>{
                this.isShowSpinner = false;
                //console.log(result);
                if(result.isSuccess) {
                    this.changeShowPage('DetailsPage');
                    this.removeApiValue();
                    this.initStoreInformation();
                    this.showNotification("", this.label.CheckInCheckOut_CHECK_IN_SUCCESS,"success");
                    // this.showVfSuccess(this.label.CheckInCheckOut_CHECK_IN_SUCCESS);
                }else{
                    this.showNotification("", result.failMessage ,"error");
                    // this.showVfError(result.failMessage);
                }
                this.isCheckOut = false;
                this.isCheckIn = false;
        }).catch(error => {
            this.isShowSpinner = false;
            console.log(error);
            this.showNotification("", error.body.message ,"error");
            // this.showVfError(error.body.message);
            this.isCheckOut = false;
            this.isCheckIn = false;
        });
    }

    // check out 操作
    callCheckOut() {
        this.isShowSpinner = true;
        this.isCheckOut = true;
        this.isCheckIn = true;
        checkOut({
            curStatus: this.checkInStatusAPIValue, 
            storeId : this.storeId, 
            lati : this.positionLati, 
            lng : this.positionLong, 
            device : this.device,
            addressStr : this.addressStr,
            remark: this.attendanceRemark,
            photoStream: this.attendancePhotoStream,
            navigatorInfo: this.navigatorInfo
        }).then(
            result=>{
                this.isShowSpinner = false;
                //console.log(result);
                if(result.isSuccess) {
                    this.changeShowPage('DetailsPage');
                    this.removeApiValue();
                    this.initStoreInformation();
                    this.showNotification("", this.label.CheckInCheckOut_CHECK_OUT_SUCCESS,"success");
                    // this.showVfSuccess(this.label.CheckInCheckOut_CHECK_OUT_SUCCESS);
                }else{
                    this.showNotification("", result.failMessage ,"error");
                    // this.showVfError(result.failMessage);
                }
                this.isCheckOut = false;
                this.isCheckIn = false;
        }).catch(error => {
            this.isShowSpinner = false;
            console.log(error);
            this.showNotification("", error.body.message ,"error");
            // this.showVfError(error.body.message);
            this.isCheckOut = false;
            this.isCheckIn = false;
        });
    }

    // 更改显示页面
    changeShowPage(pagename) {
        if (pagename == 'DetailsPage') {
            this.isTitlePage = true;
            this.isDetailsPage = true;
            this.isShiftPage = false;

            this.shiftStoreId = '';
            this.shiftStoreName = '';
            this.shiftSearchInfo = '';
            this.shiftSearchStorInfo = [];

            this.attendanceShowPhoto = false;
            this.attendancePhotoStream = null;
            this.attendanceRemark = '';
            
            if (this.storeDistance == CheckInCheckOut_WITHIN_RANGE) {
                this.attendanceIsOnseit = true;
            } else {
                this.attendanceIsOnseit = false;
            }

            var config = {
                "ele": this,
                "iframeId": "googleMap",
                "data": {
                    "config": {
                        "position": {
                            "lat": this.positionLati,
                            "lng": this.positionLong
                        },
                        "zoom": 18
                    },
                    "markers":[]
                }
            };
            var markerList = [];
            for (let index = 0; index < this.datas.length; index++) {
                var data = this.datas[index];
                var marker = new Object();
                // marker['action'] = "new";
                marker['action'] = "del";
                marker['id'] = data.Id;
                // marker['isShow'] = false;
                markerList.push(marker);
            }
            config.data.markers = markerList;
            console.log('post marker--->'+JSON.stringify(config));
            // this.googleMapApi.sendMessageToChild(config);
            this.checkGoogleMapInit(config);
            this.refreshStyle();
        } else if (pagename == 'ShiftPage') {
            this.isTitlePage = false;
            this.isDetailsPage = false;
            this.isShiftPage = true;
            this.isAttendancePage = false;

            this.shiftSearchStorInfo = this.datas;

            var config = {
                "ele": this,
                "iframeId": "googleMap",
                "data": {
                    "config": {
                        "position": {
                            "lat": this.positionLati,
                            "lng": this.positionLong
                        },
                        "zoom": 18
                    },
                    "markers":[]
                }
            };
            var markerList = [];
            for (let index = 0; index < this.datas.length; index++) {
                var data = this.datas[index];
                var marker = new Object();
                marker['action'] = "new";
                marker['type'] = "thumbtack";
                marker['id'] = data.Id;
                marker.position = {"lat": data.Lat, "lng": data.Lng};
                marker['label'] = data.Name;
                marker['title'] = data.Name;
                marker['isShow'] = true;
                marker['isClick'] = true;
                marker['clickType'] = 'getMarkerId';
                markerList.push(marker);
            }
            config.data.markers = markerList;
            console.log('post marker--->'+JSON.stringify(config));
            // this.googleMapApi.sendMessageToChild(config);
            this.checkGoogleMapInit(config);
            
            this.style =  '';
        } 
    }

    // 成功获取当前坐标
    handleSuccess(position) {
        this.positionLati = position.coords.latitude;
        this.positionLong = position.coords.longitude;
        this.position = this.positionLati + '，' + this.positionLong;
        this.isShowSpinner = false;
        this.initStoreInformation();
    }
    
    // 获取当前坐标失败
    handleError (error) {
        try{
            this.showNotification('error',this.label.CheckInCheckOut_OPEN_GEOLOCATION + "：[" + this.getErrorInfomation(error) + "]", 'error');
            // this.showVfError(this.label.CheckInCheckOut_OPEN_GEOLOCATION + "：[" + this.getErrorInfomation(error) + "]");
        }catch(e) {
            alert(e);
        }
        this.isShowSpinner = false;
        this.initStoreInformation();
    }

    // 获取错误信息
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
    
    // 显示信息提示框
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            //title: title,
            message: message,
            variant: variant,
            mode : 'sticky'
        });
        this.dispatchEvent(evt);
    }

    captureCompress = true;
    showCapture = false;
    handleCaptureComplete(event) {
        if (event.detail) {
            this.attendancePhotoStream = event.detail.data.base64;
            this.attendanceShowPhoto = true;
        }
        
        // this.showAllPage = true;
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
}