import { LightningElement,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import initStoreInfo from '@salesforce/apex/CheckInCheckOutController.initStoreInfo';
import getStoreInfo from '@salesforce/apex/CheckInCheckOutController.getStoreInfo';
import checkIn from '@salesforce/apex/CheckInCheckOutController.checkIn';
import checkOut from '@salesforce/apex/CheckInCheckOutController.checkOut';
import getPromoterAttendance from '@salesforce/apex/CheckInCheckOutController.getPromoterAttendance';

import CheckInCheckOut_STORE_NAME from '@salesforce/label/c.CheckInCheckOut_STORE_NAME';
import CheckInCheckOut_CHANNEL from '@salesforce/label/c.CheckInCheckOut_CHANNEL';
import CheckInCheckOut_DISTANCE_KM from '@salesforce/label/c.CheckInCheckOut_DISTANCE_KM';
import CheckInCheckOut_CHECK_IN_STATUS from '@salesforce/label/c.CheckInCheckOut_CHECK_IN_STATUS';
import CheckInCheckOut_REMARK from '@salesforce/label/c.CheckInCheckOut_REMARK';

import CheckInCheckOut_MOBILE_NOT_ALLOW from '@salesforce/label/c.CheckInCheckOut_MOBILE_NOT_ALLOW';
import CheckInCheckOut_WITHOUT_POSITION from '@salesforce/label/c.CheckInCheckOut_WITHOUT_POSITION';
import CheckInCheckOut_LEAST_CHAR from '@salesforce/label/c.CheckInCheckOut_LEAST_CHAR';
import CheckInCheckOut_NOT_MOBILE from '@salesforce/label/c.CheckInCheckOut_NOT_MOBILE';
import CheckInCheckOut_NOT_SUPPORT_GEOLOCATION from '@salesforce/label/c.CheckInCheckOut_NOT_SUPPORT_GEOLOCATION';

import CheckInCheckOut_CHECK_IN_SUCCESS from '@salesforce/label/c.CheckInCheckOut_CHECK_IN_SUCCESS';
import CheckInCheckOut_CHECK_OUT_SUCCESS from '@salesforce/label/c.CheckInCheckOut_CHECK_OUT_SUCCESS';
import CheckInCheckOut_OPEN_GEOLOCATION from '@salesforce/label/c.CheckInCheckOut_OPEN_GEOLOCATION';

import CheckInCheckOut_Title from '@salesforce/label/c.CheckInCheckOut_Title';
import CheckInCheckOut_DEVICE from '@salesforce/label/c.CheckInCheckOut_DEVICE';
import CheckInCheckOut_GEOLOCATION from '@salesforce/label/c.CheckInCheckOut_GEOLOCATION';
import CheckInCheckOut_LOCATION from '@salesforce/label/c.CheckInCheckOut_LOCATION';
import CheckInCheckOut_QUERY_STORE from '@salesforce/label/c.CheckInCheckOut_QUERY_STORE';
import CheckInCheckOut_QUERY from '@salesforce/label/c.CheckInCheckOut_QUERY';

import CheckInCheckOut_CHECK_DATE from '@salesforce/label/c.CheckInCheckOut_CHECK_DATE';
import CheckInCheckOut_RETURN from '@salesforce/label/c.CheckInCheckOut_RETURN';
import CheckInCheckOut_CHECK_IN from '@salesforce/label/c.CheckInCheckOut_CHECK_IN';
import CheckInCheckOut_CHECK_OUT from '@salesforce/label/c.CheckInCheckOut_CHECK_OUT';

import CheckInCheckOut_CURRENT_ADDR from '@salesforce/label/c.CheckInCheckOut_CURRENT_ADDR';

export default class CheckInCheckOut extends NavigationMixin(LightningElement) {

    label = {
        CheckInCheckOut_STORE_NAME,//门店
        CheckInCheckOut_CHANNEL,//经销商渠道
        CheckInCheckOut_DISTANCE_KM,//距离(KM)
        CheckInCheckOut_CHECK_IN_STATUS,//考勤状态
        CheckInCheckOut_REMARK,//备注


        CheckInCheckOut_MOBILE_NOT_ALLOW,//非移动端不可签到
        CheckInCheckOut_WITHOUT_POSITION,//未获取当前定位信息，不可签到
        CheckInCheckOut_LEAST_CHAR,//输入的查询门店信息不少于两个字符
        CheckInCheckOut_NOT_MOBILE,//非移动端
        CheckInCheckOut_NOT_SUPPORT_GEOLOCATION,//当前设备不支持定位功能
        CheckInCheckOut_CHECK_IN_SUCCESS,//签到成功
        CheckInCheckOut_CHECK_OUT_SUCCESS,//签退成功
        CheckInCheckOut_OPEN_GEOLOCATION,//请开启定位服务,并刷新页面

        CheckInCheckOut_Title, //签到签退
        CheckInCheckOut_DEVICE,//当前设备
        CheckInCheckOut_GEOLOCATION,//当前经纬度
        CheckInCheckOut_LOCATION,//重新/校准定位
        CheckInCheckOut_QUERY_STORE,//查询门店
        CheckInCheckOut_QUERY,//查询
        CheckInCheckOut_CHECK_DATE,//签到/签退日期
        CheckInCheckOut_RETURN,//返回
        CheckInCheckOut_CHECK_IN,//签到
        CheckInCheckOut_CHECK_OUT,//签退
        CheckInCheckOut_CURRENT_ADDR//当前地址
    }

    PROMOTE_PROFILE = '促销员'; //判断值，不需要翻译
    INSPECTION_PROFILE = '巡店员';//判断值，不需要翻译

    @track device = '';
    @track positionLong;
    @track positionLati;
    @track position;
    @track addressStr;
    @track checkInStatusLabel;
    @track checkInStatus;

    @track thisDay;
    @track searchInfo = '';
    @track userType;

    @track isPC = false;
    @track isShowSpinner = false;

    @track isCheckIn = true;
    @track isCheckOut = true;

    @track isRefresh = false;

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
        },{
            label: this.label.CheckInCheckOut_CHECK_IN_STATUS,
            fieldName: 'CheckInStatusLabel',
            type: 'text' 
        },{
            label: this.label.CheckInCheckOut_REMARK,
            fieldName: 'Remark',
            type: 'text' 
        }
    ];

    @track storeId;
    @track attendanceId;
    @track planId;
    @track distance;
   // @track checkStatus;
    @track datas = [];
    /* =[
        {Id:'1234567890',Name:'１００満ボルトイオン松任店', Channel:'BIC', Shop_External_Key__c:'4016675153', Distance :'2', CheckInStatus:'已签退', PlanStatus:'计划内'},
        {Id:'1234567891',Name:'AirBIC羽田空港国際線', Channel:'BIC', Shop_External_Key__c:'401666403', Distance :'0.1', CheckInStatus:'已签到', PlanStatus:'计划内'},
        {Id:'1234567892',Name:'BIC楽天市場店', Channel:'BIC', Shop_External_Key__c:'401666089', Distance :'0.01', CheckInStatus:'未签到', PlanStatus:'计划内'}
    ];*/
    get isPromoter(){
        return this.userType == this.PROMOTE_PROFILE;
    }

    get canUserCheckFunction(){
        return this.userType == this.PROMOTE_PROFILE ||  this.userType == this.INSPECTION_PROFILE;
    }

    connectedCallback() {
        this.isShowSpinner = true;
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

    handleCheckIn() {
        if(this.isPC){
            this.showNotification('error',this.label.CheckInCheckOut_MOBILE_NOT_ALLOW,'error');
        }else if(this.position != '' && this.position != undefined && this.position != null){
            this.callCheckIn();
        }else{
            this.showNotification("", this.label.CheckInCheckOut_WITHOUT_POSITION ,"error");
        }
    }

    handleCheckOut() {
        if(this.isPC){
            this.showNotification('error',this.label.CheckInCheckOut_MOBILE_NOT_ALLOW,'error');
        }else if(this.position != '' && this.position != undefined && this.position != null){
            this.callCheckOut();
        }else{
            this.showNotification("", this.label.CheckInCheckOut_WITHOUT_POSITION ,"error");
        }   
    }

    handleReturn() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Shop__c',
                actionName: 'home'
            }
        });
    }

    handleChange(event) {
        //console.log(event.detail.selectedRows[0]);
        this.storeId = event.detail.selectedRows[0].Id;
        this.attendanceId = event.detail.selectedRows[0].AttendanceId;
        this.planId = event.detail.selectedRows[0].PlanId;
        this.distance = event.detail.selectedRows[0].Distance;
        if(this.checkInStatus == '已签退' ) {
            this.isCheckOut = true;
            this.isCheckIn = false;
        }else if(this.checkInStatus == '已签到') {
            this.isCheckOut = false;
            this.isCheckIn = true;
        }else if(this.checkInStatus == '已签到签退') {
            this.isCheckOut = true;
            this.isCheckIn = true;
        }else{
            this.isCheckOut = false;
            this.isCheckIn = false;
        }
        /*this.checkStatus = event.detail.selectedRows[0].CheckInStatus;
        if (event.detail.selectedRows[0].CheckInStatus == '已签退') {
            this.isCheckOut = true;
            this.isCheckIn = false;
        }else if(event.detail.selectedRows[0].CheckInStatus == '已签到') {
            this.isCheckOut = false;
            this.isCheckIn = true;
        }else if(event.detail.selectedRows[0].CheckInStatus == '已签到签退'){
            this.isCheckOut = true;
            this.isCheckIn = true;
        }else{
            this.isCheckOut = false;
            this.isCheckIn = false;
        }*/
        /*
        console.log('this.isCheckOut:' + this.isCheckOut);
        console.log('this.isCheckIn:' + this.isCheckIn);
        */
    }

    handleSearchInput(event) {
        this.searchInfo = event.target.value;
    }

    handleSearch() {
        if(!this.searchInfo || this.searchInfo.length < 2) {
            this.showNotification('error', this.label.CheckInCheckOut_LEAST_CHAR, 'error');
        }else{
            this.getStoreInformation();
        }
    }
    /**
    Name : isPCJudgement
    Purpose : 
    Params :  error
    Author : Chiara
    Date : 2021/12/27
    **/
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

    /**
    Name : getHighAccuracyPosition
    Purpose : 重新/校准定位
    Params :  
    Author : Chiara
    Date : 2021/12/29
    **/
    getHighAccuracyPosition() {
        this.isShowSpinner = true;
        this.getCurrentPosition(true);
    }

    /**
    Name : getCurrentPosition
    Purpose : 获取当前经纬度
    Params :  highAccuracy
    Author : Chiara
    Date : 2021/12/29
    **/
    getCurrentPosition(highAccuracy){
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                this.handleSuccess(position);
            }, error =>{
                this.handleError(error);
            },{ enableHighAccuracy:highAccuracy,timeout: 10000}
            );
        }else {
            this.showNotification('error', this.label.CheckInCheckOut_NOT_SUPPORT_GEOLOCATION, 'error');
        }
    }
  
    callCheckIn() {
        this.isShowSpinner = true;
        checkIn({
            attendanceId: this.attendanceId,
            curStatus: this.checkInStatus, 
            storeId: this.storeId,
            planId: this.planId, 
            lati: this.positionLati,
            lng: this.positionLong,
            device: this.device,
            addressStr : this.addressStr}).then(
            result=>{
                this.isShowSpinner = false;
                //console.log(result);
                if(result.isSuccess) {
                    this.initStoreInformation();
                    this.showNotification("", this.label.CheckInCheckOut_CHECK_IN_SUCCESS,"success");
                }else{
                    this.showNotification("", result.failMessage ,"error");
            }
        }).catch(error => {
            this.isShowSpinner = false;
            console.log(error);
            this.showNotification("", error.body.message ,"error");
        });
    }

    callCheckOut() {
        this.isShowSpinner = true;
        checkOut({attendanceId : this.attendanceId, curStatus: this.checkInStatus, 
                    storeId : this.storeId, planId : this.planId, 
                    lati : this.positionLati, lng : this.positionLong, device : this.device,
                    addressStr : this.addressStr}).then(
            result=>{
                this.isShowSpinner = false;
                //console.log(result);
                if(result.isSuccess) {
                    this.initStoreInformation();
                    this.showNotification("", this.label.CheckInCheckOut_CHECK_OUT_SUCCESS,"success");
                }else{
                    this.showNotification("", result.failMessage ,"error");
            }
        }).catch(error => {
            this.isShowSpinner = false;
            console.log(error);
            this.showNotification("", error.body.message ,"error");
        });
    }

    getStoreInformation() {
        this.isShowSpinner = true;
        getStoreInfo({lati: this.positionLati, lng: this.positionLong, searchInfo: this.searchInfo}).then(
            result=>{
                this.isShowSpinner = false;
                console.log(result);
                if(result.isSuccess) {
                    this.handleRefresh();
                    this.datas = result.dataList;
                    this.thisDay = result.thisDay;
                }else{
                    this.showNotification("", result.failMessage ,"error");
                }
        }).catch(error => {
            this.isShowSpinner = false;
            this.showNotification("", error.message ,"error");
        });
    }

    initStoreInformation() {
        this.isShowSpinner = true;
        this.searchInfo = '';//查询重置
        this.isCheckOut = true;
        this.isCheckIn = true;
        initStoreInfo({lati: this.positionLati, lng: this.positionLong}).then(
            result=>{
                this.isShowSpinner = false;
                console.log(result);
                if(result.isSuccess) {
                    this.handleRefresh();
                    this.datas = result.dataList;
                    this.thisDay = result.thisDay;
                    this.userType = result.userType;
                    this.addressStr = result.addressStr;
                    this.checkInStatusLabel = result.checkInStatusLabel;
                    this.checkInStatus = result.checkInStatus;
                }else{
                    this.showNotification("", result.failMessage ,"error");
                }
        }).catch(error => {
            this.isShowSpinner = false;
            this.showNotification("", error.message ,"error");
        });
    }

    handleRefresh() {
        if(this.isRefresh){
            this.isRefresh= false;
        }else{
            this.isRefresh = true;
        }
    }

    /**
    Name : handleSuccess
    Purpose : 处理getCurrentPosition的成功的情况
    Params :  position
    variant : 
    Author : Chiara
    Date : 2021/12/28
    **/
    handleSuccess(position) {
        this.positionLati = position.coords.latitude;
        this.positionLong = position.coords.longitude;
        this.position = this.positionLati + '，' + this.positionLong;
        this.isShowSpinner = false;
        this.initStoreInformation();
    }
    /**
    Name : handleError
    Purpose : 处理getCurrentPosition的失败的情况
    Params :  error
    variant : 
    Author : Chiara
    Date : 2021/12/28
    **/
    handleError (error) {
        try{
            this.showNotification('error',this.label.CheckInCheckOut_OPEN_GEOLOCATION + "：[" + this.getErrorInfomation(error) + "]", 'error');
        }catch(e) {
            alert(e);
        }
        this.isShowSpinner = false;
        this.initStoreInformation();
    }
    /**
    Name : getErrorInfomation
    Purpose : 
    Params :  error
    Author : Chiara
    Date : 2021/12/27
    **/
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
    /**
    Name : showNotification
    Purpose : 
    Params :  title, message,
    variant : error,warning,success,info
    Author : Chiara
    Date : 2021/07/26
    **/
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            //title: title,
            message: message,
            variant: variant,
            mode : 'sticky'
        });
        this.dispatchEvent(evt);
    }

    toPromoterAttendanceDetail() {
        getPromoterAttendance().then(result => {
            console.log("result：" + result);
            if(result !=  "") {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordRelationshipPage',
                    attributes: {
                        recordId: result,
                        objectApiName: 'Promoter_Attendance__c',
                        relationshipApiName: 'AttendanceMBRS__r',
                        actionName: 'view'
                    },
                });
            } else {
                //若没有考勤记录
                this.showNotification("", "暂无当日考勤记录" ,"error");
            }
        }).catch(error => {
            console.log("error: "+JSON.stringify(error));
            this.showNotification("", JSON.stringify(error) ,"error");
        })
        
    }
}