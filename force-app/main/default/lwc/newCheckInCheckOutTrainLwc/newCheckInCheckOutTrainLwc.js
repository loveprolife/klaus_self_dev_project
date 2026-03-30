/*
 * @Author: WFC
 * @Date: 2023-12-01 09:19:35
 * @LastEditors: error: error: git config user.name & please set dead value or install git && error: git config user.email & please set dead value or install git & please set dead value or install git
 * @LastEditTime: 2024-03-20 14:16:04
 * @Description: 
 * @FilePath: \hisenseall-231026\force-app\main\default\lwc\newCheckInCheckOutTrainLwc\newCheckInCheckOutTrainLwc.js
 */
import { LightningElement,track,wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import getVisualforceOrigin from '@salesforce/apex/CommonGoogleMapController.getVisualforceOrigin';
import {GoogleMapApi, LightningNavigationElement} from 'c/lwcUtils'
import FORM_FACTOR from '@salesforce/client/formFactor';


import initStoreInfo from '@salesforce/apex/NewCheckInCheckOutTrainController.initStoreInfo';
import checkStoreAttendance from '@salesforce/apex/NewCheckInCheckOutTrainController.checkStoreAttendance';
import getBase64Stream from '@salesforce/apex/NewCheckInCheckOutTrainController.getBase64Stream';
// import getStoreInfo from '@salesforce/apex/NewCheckInCheckOutTrainController.getStoreInfo';
import checkIn from '@salesforce/apex/NewCheckInCheckOutTrainController.checkIn';
import checkOut from '@salesforce/apex/NewCheckInCheckOutTrainController.checkOut';
// import getPromoterAttendance from '@salesforce/apex/NewCheckInCheckOutTrainController.getPromoterAttendance';

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
import CheckInCheckOut_CheckTrainInfo from '@salesforce/label/c.CheckInCheckOut_CheckTrainInfo';
// import CheckInCheckOut_ADDRESS from '@salesforce/label/c.CheckInCheckOut_ADDRESS';

// import CheckInCheckOut_CURRENT_LOCATION from '@salesforce/label/c.CheckInCheckOut_CURRENT_LOCATION';
// import CheckInCheckOut_REFRESH_POSITIONING from '@salesforce/label/c.CheckInCheckOut_REFRESH_POSITIONING';
import importImg from '@salesforce/apex/NewCheckInCheckOutTrainController.importImg';
var timeIntervalInstance;
export default class NewCheckInCheckOutTrainLWC extends LightningNavigationElement {
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
        CheckInCheckOut_CheckTrainInfo,//请填写培训信息
    }

    // PROMOTE_PROFILE = '促销员'; //判断值，不需要翻译
    // INSPECTION_PROFILE = '巡店员';//判断值，不需要翻译

    @track device = ''; //当前设备信息
    @track positionLong; //当前lng坐标
    @track positionLati; //当前lat坐标
    @track position; //当前坐标
    @track addressStr; //当前地址
    @track needCheckStore = false; //需要再查询门店数据
    @track checkInStatusLabel;
    @track checkInStatusAPIValue; //当前用户签到状态

    @track storeNameStr; //当前所选门店名
    @track storeId; //当前所选门店Id
    @track storeDistance; //当前所选门店距离
    @track storeDistanceFlag; //当前所选门店距离
    @track storeRoleDistance; //当前所选门店距离
    @track channelId; //渠道ID
    @track channelName; //渠道名称

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

    @track nowDate; //当前日期时间
    @track nowWeekDate; //当前月第几周
    @track thisDay; //当前日期
    @track thisTime; //当前时间
    @track userType; //当前用户简档
    @track userName; //当前用户

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

    // 培训信息
    @track trainingTheme = '';// 培训主题
    @track trainingObject = '';// 培训对象
    @track trainingContent = '';// 培训内容总结

    // 是否展示激光产品线定制表单信息
    @track isShowProductLine = false;

    @wire(getObjectInfo,{ objectApiName: 'Promoter_Attendance__c'})
    wiredPromoterAttendanceInfo({ error, data }){
        if(data){
            this.promoterAttendanceInfo.Display_Pictures__c = data.fields.Display_Pictures__c.label
            this.promoterAttendanceInfo.Second_Show__c = data.fields.Second_Show__c.label
        }
    }

    // 南非激光产品线线定制培训表单
    @track promoterAttendanceInfo = {
        Display_Pictures__c:'',
        Second_Show__c:''
    };

    @track trainer = '';
    @track customer = '';
    @track nameOfStoreManager = '';
    @track nameOfBA = '';
    @track nameOfFSPs = '';
    @track productFeaturesSalesSkill = '';
    @track promotionFocus = '';
    @track marketingDisplayCondition = '';
    @track secondShow = '';
    @track displayPictures = '';
    imgUrl = '';
    fileImgName = '';
    fileVideoName = '';


    @track fileName = '';
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;

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
    @track datasHistory = [];

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

        var todayTime = new Date().toLocaleTimeString();
        this.nowDate = this.getNowFormatDate + ' ' + todayTime;
        this.nowWeekDate = this.getWeekDate;
        var parentThis = this;
        timeIntervalInstance = setInterval(function() {
            var todayTime = new Date().toLocaleTimeString();
            parentThis.nowDate = parentThis.getNowFormatDate + ' ' + todayTime;
            if(parentThis.nowDate >= parentThis.trainingTaskTimeCheck && parentThis.getNowFormatDate == parentThis.trainingTaskTimeDate){
                parentThis.isCanSignIn = true;
            }
        }, 1000);
    }

    disconnectedCallback(){
        clearInterval(timeIntervalInstance);
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
    initStoreInformation(flag) {
        this.isShowSpinner = true;
        this.isCheckOut = true;
        this.isCheckIn = true;
        // this.positionLati = '36.0662299';
        // this.positionLong = '120.38299';
        initStoreInfo({lati: this.positionLati, lng: this.positionLong, searchInfo: this.shiftSearchInfo}).then(
            result=>{
                this.isShowSpinner = false;
                console.log(result);
                if(result.isSuccess) {
                    this.isShowProductLine = result.isShowProductLine;
                    this.datas = result.dataList;
                    this.thisDay = result.thisDay;
                    this.thisTime = result.thisTime;
                    var todayTime = new Date().toLocaleTimeString();
                    this.nowDate = this.getNowFormatDate + ' ' + todayTime;
                    this.userType = result.userType;
                    this.userName = result.userName;
                    this.addressStr = result.addressStr;
                    console.log('www--addressStr:' + this.addressStr);
                    this.checkInStatusLabel = result.checkInStatusLabel;
                    this.checkInStatusAPIValue = result.checkInStatus;
                    this.trainingTheme = result.trainingTheme;
                    this.trainingObject = result.trainingObject;
                    this.trainingContent = result.trainingContent;
                    if(flag){
                        this.datasHistory = result.dataList;
                        this.needCheckStore = result.needCheckStore;
                        console.log('www--needCheckStore:' + this.needCheckStore);
                    }
                    if(this.shiftSearchInfo != ''){
                        console.log('wwwffff--' + this.shiftSearchInfo);
                        var filteredList = this.datas.filter(obj => obj.Name.toUpperCase().includes(this.shiftSearchInfo.toUpperCase()));
                        this.shiftSearchStorInfo = filteredList;
                    }else {
                        console.log('wwwdddd--' + this.shiftSearchInfo);
                        // 显示主页面
                        if (this.shopId && this.datas.filter(obj => this.shopId == obj.Id).length>0) {
                            console.log('www--选择shopId--' + this.shopId);
                            var selectedShop = this.datas.filter(obj => this.shopId == obj.Id);
                            this.checkStoreRoleInfo(selectedShop[0]);
                        } else if (this.datas.length > 0) {
                            console.log('www--首次--' + JSON.stringify(this.datas[0]));
                            this.checkStoreRoleInfo(this.datas[0])
                        }
                        this.changeShowPage('DetailsPage');
                    }

                    // 判断签到签退按钮状态
                    this.handleChange();
                    // 判断签到签退信息
                    this.checkInOutInfo(result);
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
        console.log('渠道信息' + '-' + data.Channel + '-' + data.ChannelId);
        this.storeId = data.Id;
        this.storeNameStr = data.Name;
        this.storeDistance = data.roleDistanceText;
        this.storeDistanceFlag = data.roleDistanceFlag;
        this.storeRoleDistance = data.roleDistance;
        this.channelId = data.ChannelId;
        this.channelName = data.Channel;
        this.startTime = data.roleStartTime ? data.roleStartTime : '--:--';
        this.endTime = data.roleEndTime ? data.roleEndTime : '--:--';

        // 南非激光产品线培训表单
        this.nameOfStoreManager = '';
        this.nameOfBA = '';
        this.nameOfFSPs = '';
        this.productFeaturesSalesSkill = '';
        this.promotionFocus = '';
        this.marketingDisplayCondition = '';
        this.secondShow = '';
        this.displayPictures = '';
        this.fileImgName = '';
        this.fileVideoName = '';

        this.trainingTheme = '';
        this.trainingObject = '';
        this.trainingContent = '';

        // 查询门店考勤信息
        this.isShowSpinner = true;
        checkStoreAttendance({storeId: this.storeId}).then(
            result=>{
                this.isShowSpinner = false;
                console.log('www-checkStoreAttendance-' + result);
                if(result.isSuccess) {
                    this.checkInStatusLabel = result.checkInStatusLabel;
                    this.checkInStatusAPIValue = result.checkInStatus;
                    console.log('www--选择门店后培训信息trainingTheme--' + result.trainingTheme);
                    console.log('www--选择门店后培训信息trainingObject--' + result.trainingObject);
                    console.log('www--选择门店后培训信息trainingContent--' + result.trainingContent);
                    this.trainingTheme = result.trainingTheme;
                    this.trainingObject = result.trainingObject;
                    this.trainingContent = result.trainingContent;

                    // 判断签到签退按钮状态
                    this.handleChange();
                    // 判断签到签退信息
                    this.checkInOutInfo(result);
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
        console.log('www--thisDay--'+ this.thisDay);
        console.log('www--thisTime--'+ this.thisTime);
        console.log('www--positionLong--'+ this.positionLong);
        console.log('www--positionLati--'+ this.positionLati);
        console.log('www--storeId--'+ this.storeId);
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

    // 培训主题 培训对象 培训内容总结
    handleThemeChange(event) {
        this.trainingTheme = event.target.value;
        console.log('wwww--handleThemeChange--' + this.trainingTheme);
    }
    handleObjectChange(event) {
        this.trainingObject = event.target.value
        console.log('wwww--handleObjectChange--' + this.trainingObject);
    }
    handleContentChange(event) {
        this.trainingContent = event.target.value;
        console.log('wwww--handleContentChange--' + this.trainingContent);
    }

    // 南非激光产品线定制培训表单
    handleTrainerChange(event) {
        this.trainer = event.target.value;
        console.log('wwww--handleTrainerChange--' + this.trainer);
    }
    handleCustomerChange(event) {
        this.customer = event.target.value
        console.log('wwww--handleCustomerChange--' + this.customer);
    }
    handleStoreManagerChange(event) {
        this.nameOfStoreManager = event.target.value;
        console.log('wwww--handleStoreManagerChange--' + this.nameOfStoreManager);
    }
    handleBAChange(event) {
        this.nameOfBA = event.target.value;
        console.log('wwww--handleBAChange--' + this.nameOfBA);
    }
    handleFSPsChange(event) {
        this.nameOfFSPs = event.target.value
        console.log('wwww--handleFSPsChange--' + this.nameOfFSPs);
    }
    handleProductChange(event) {
        this.productFeaturesSalesSkill = event.target.value;
        console.log('wwww--handleProductChange--' + this.productFeaturesSalesSkill);
    }
    handleFocusChange(event) {
        this.promotionFocus = event.target.value;
        console.log('wwww--handleFocusChange--' + this.promotionFocus);
    }
    handleMarketingChange(event) {
        this.marketingDisplayCondition = event.target.value;
        console.log('wwww--handleMarketingChange--' + this.marketingDisplayCondition);
    }

    handleImageChange(event){
        let files = event.detail.files;
        this.fileImgName = files[0].name;
        
        importImg({
            name:files[0].name,
            documentId:files[0].documentId,
            contentVersionId:files[0].contentVersionId
        }).then(result => {
            this.displayPictures = result;
            console.log(result)
        })
        console.log('测试导入图片功能' + JSON.stringify(event.detail.files));

        // this.filesUploaded = event.target.files;
        // this.fileName = event.target.files[0].name;
    }

    handleVideoChange(event){
        let files = event.detail.files;
        this.fileVideoName = files[0].name;
        importImg({
            name:files[0].name,
            documentId:files[0].documentId,
            contentVersionId:files[0].contentVersionId
        }).then(result => {
            this.secondShow = result;
            console.log(result)
        })
        console.log('测试导入图片功能' + JSON.stringify(event.detail.files));

        // this.filesUploaded = event.target.files;
        // this.fileName = event.target.files[0].name;
    }

    get acceptedImgType() {
        return ['.png','.jpeg','.jpg','.heif'];
    }
    get acceptedVideoType() {
        return ['.mp4','.MP4','.3gp','.avi','.mov','.flv'];
    }

    // 签到click
    handleCheckIn() {
        console.log('wwww--handleCheckIn--' + this.attendanceIsOnseit);
        var filteredList = this.datas.filter(obj => obj.Id == this.storeId);
        // var needCheckDistance = filteredList[0].roleNeedCheckDistance;
        var needCheckDistance = false;
        if (needCheckDistance && !this.storeDistanceFlag) {
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
        // var needCheckDistance = filteredList[0].roleNeedCheckDistance;
        var needCheckDistance = false;
        // 签退逻辑
        // PC测试注释
        if(this.isPC){
            this.showNotification('error',this.label.CheckInCheckOut_MOBILE_NOT_ALLOW,'error');
        }else 
        if (needCheckDistance && !this.storeDistanceFlag) {
            this.showNotification("", this.label.CheckInCheckOut_OUT_OF_CHECK_IN_RANGE ,"error");
            // this.showVfError(this.label.CheckInCheckOut_OUT_OF_CHECK_IN_RANGE);
        } else if (this.attendanceIsOnseit == false && this.attendancePhotoStream==null) {
            this.showNotification("", this.label.CheckInCheckOut_NO_PHOTO_ERROR ,"error");
            // this.showVfError(this.label.CheckInCheckOut_NO_PHOTO_ERROR);
        } else if(this.position != '' && this.position != undefined && this.position != null){
            if(this.verifyNotNull(this.trainingTheme) && this.verifyNotNull(this.trainingObject) && this.verifyNotNull(this.trainingContent)){
                console.log('www--trainingTheme:' + this.trainingTheme);
                console.log('www--trainingObject:' + this.trainingObject);
                console.log('www--trainingContent:' + this.trainingContent);
                this.callCheckOut(); 
            }else {
                this.showNotification("", this.label.CheckInCheckOut_CheckTrainInfo ,"error");
            }
        }else{
            this.showNotification("", this.label.CheckInCheckOut_WITHOUT_POSITION ,"error");
            // this.showVfError(this.label.CheckInCheckOut_WITHOUT_POSITION);
        }  
    }

    verifyNotNull(str){
        if(str != '' && str != null && str != undefined){
            return true;
        }else {
            return false;
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
            if(this.needCheckStore){
                this.shiftSearchStorInfo = this.datasHistory;
            }else {
                this.shiftSearchStorInfo = this.datas;
            }
        } else {
            // 查询数据展示所有门店
            console.log('www----'+ this.needCheckStore);
            if(this.needCheckStore){
                this.initStoreInformation(false);
            }else {
                console.log('www----过滤');
                var filteredList = this.datas.filter(obj => obj.Name.toUpperCase().includes(this.shiftSearchInfo.toUpperCase()));
                console.log('www----filteredList:' + JSON.stringify(filteredList));
                this.shiftSearchStorInfo = filteredList;
            }
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
        
        if(this.needCheckStore){
            this.datas = this.datasHistory;
        }
    }

    // Confirm Click
    handleConfirm() {
        this.storeId = this.shiftStoreId;

        var filteredList = this.datas.filter(obj => obj.Id == this.storeId);
        this.checkStoreRoleInfo(filteredList[0]);

        if(this.needCheckStore){
            this.datas = this.datasHistory;
        }

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
            navigatorInfo: this.navigatorInfo,
            trainingTheme: this.trainingTheme,
            trainingObject: this.trainingObject,
            trainingContent: this.trainingContent,
        }).then(
            result=>{
                this.isShowSpinner = false;
                //console.log(result);
                if(result.isSuccess) {
                    this.changeShowPage('DetailsPage');
                    this.removeApiValue();
                    this.initStoreInformation(false);
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
            navigatorInfo: this.navigatorInfo,
            trainer:this.userName,
            customer:this.channelId,
            nameOfStoreManager:this.nameOfStoreManager,
            nameOfBA:this.nameOfBA,
            nameOfFSPs:this.nameOfFSPs,
            productFeaturesSalesSkill:this.productFeaturesSalesSkill,
            promotionFocus:this.promotionFocus,
            marketingDisplayCondition:this.marketingDisplayCondition,
            displayPictures:this.displayPictures,
            secondShow:this.secondShow,
            trainingTheme: this.trainingTheme,
            trainingObject: this.trainingObject,
            trainingContent: this.trainingContent,
        }).then(
            result=>{
                this.isShowSpinner = false;
                //console.log(result);
                if(result.isSuccess) {
                    this.changeShowPage('DetailsPage');
                    this.removeApiValue();
                    this.initStoreInformation(false);
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

            if (this.storeDistanceFlag == true) {
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
            // console.log('post marker--->'+JSON.stringify(config));
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
            // console.log('post marker--->'+JSON.stringify(config));
            // this.googleMapApi.sendMessageToChild(config);
            this.checkGoogleMapInit(config);
            
            this.style =  '';
        } 
    }

    // 成功获取当前坐标
    handleSuccess(position) {
        console.log('www--handleSuccess');
        this.positionLati = position.coords.latitude;
        this.positionLong = position.coords.longitude;
        this.position = this.positionLati + '，' + this.positionLong;
        this.isShowSpinner = false;
        this.initStoreInformation(true);
    }
    
    // 获取当前坐标失败
    handleError (error) {
        console.log('www--handleError');
        try{
            this.showNotification('error',this.label.CheckInCheckOut_OPEN_GEOLOCATION + "：[" + this.getErrorInfomation(error) + "]", 'error');
            // this.showVfError(this.label.CheckInCheckOut_OPEN_GEOLOCATION + "：[" + this.getErrorInfomation(error) + "]");
        }catch(e) {
            alert(e);
        }
        this.isShowSpinner = false;
        this.initStoreInformation(true);
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

    

    //获取当前日期函数
    get getNowFormatDate(){
        let date = new Date(),
        year = date.getFullYear(), //获取完整的年份(4位)
        month = date.getMonth() + 1, //获取当前月份(0-11,0代表1月)
        strDate = date.getDate() // 获取当前日(1-31)
        if (month < 10) month = `0${month}` // 如果月份是个位数，在前面补0
        if (strDate < 10) strDate = `0${strDate}` // 如果日是个位数，在前面补0
        return `${year}-${month}-${strDate}`
    }
    //获取当前月第几周
    get getWeekDate(){
        // 获取本月第几周
        let date = new Date(),
        week = date.getDay(),
        day = date.getDate();
        if(week == 0){
            week = 7
        }
        return Math.ceil((day + 6 - week) / 7);
    }
}