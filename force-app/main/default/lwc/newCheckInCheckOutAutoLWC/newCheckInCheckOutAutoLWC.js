import { LightningElement,track,wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import getVisualforceOrigin from '@salesforce/apex/CommonGoogleMapController.getVisualforceOrigin';
import {GoogleMapApi, LightningNavigationElement} from 'c/lwcUtils'
import FORM_FACTOR from '@salesforce/client/formFactor';
import initStoreInfo from '@salesforce/apex/NewCheckInCheckOutAutoController.initStoreInfo';
import checkIn from '@salesforce/apex/NewCheckInCheckOutAutoController.checkIn';
import checkOut from '@salesforce/apex/NewCheckInCheckOutAutoController.checkOut';
import CheckInCheckOut_NOT_MOBILE from '@salesforce/label/c.CheckInCheckOut_NOT_MOBILE';
import CheckInCheckOut_WITHIN_RANGE from '@salesforce/label/c.CheckInCheckOut_WITHIN_RANGE';


export default class newCheckInCheckOutAutoLWC extends LightningNavigationElement {
	label = {
		CheckInCheckOut_NOT_MOBILE,//非移动端
        CheckInCheckOut_WITHIN_RANGE
	}
	@track navigatorInfo = ''; //设备信息
	@track device;//设备操作系统类型
	@track positionLati;
	@track positionLong;
	@track position;
    endLoop;
	_timer;
	@track totalTime = 0;
    debugMode = false;

	// 初始化
    connectedCallback() {
        this.navigatorInfo += 'userAgent:'+navigator.userAgent+'\n';
        this.navigatorInfo += 'vendor:'+navigator.vendor+'\n';
        this.navigatorInfo += 'platform:'+navigator.platform+'\n';
        this.navigatorInfo += 'oscpu:'+navigator.oscpu+'\n';
        this.navigatorInfo += 'appVersion:'+navigator.appVersion+'\n';


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
        debugger;
        this.getCurrentPosition(false);
    }

    // 获取当前经纬度
    getCurrentPosition(highAccuracy){
    	this.totalTime +=1;
        if (navigator.geolocation) {
            if (this.debugMode) {
                this.handleSuccess({
                    coords : {	
                        latitude : -6.1739348,
                        longitude : 106.7869936
                    }
                });
            } else {
                navigator.geolocation.getCurrentPosition(position => {
                    this.handleSuccess(position);
                }, error =>{
                    // this.handleError(error);
                    console.log('error==='+error);
                    this.nextLoop();
                }, {
                    enableHighAccuracy:highAccuracy,
                    timeout: 10000
                });
            }
            
        }else {
            // this.showNotification('error', this.label.CheckInCheckOut_NOT_SUPPORT_GEOLOCATION, 'error');
            // this.showVfError(this.label.CheckInCheckOut_NOT_SUPPORT_GEOLOCATION);
        }
    }

    // 成功获取当前坐标
    handleSuccess(position) {
        this.positionLati = position.coords.latitude;
        this.positionLong = position.coords.longitude;
        this.position = this.positionLati + '，' + this.positionLong;
        //console.log("经纬度==============="+this.positionLong+'  '+this.positionLati);
        this.initStoreInformation();
    }

    // 获取初始化数据
    initStoreInformation() {
        this.isShowSpinner = true;
        this.isCheckOut = true;
        this.isCheckIn = true;
        // String device, String navigatorInfo
        initStoreInfo({lati: this.positionLati, lng: this.positionLong, device: this.device, navigatorInfo : this.navigatorInfo}).then(
            result=>{
                console.log(result);
                if (result == null) {

                    return;
                }
                if(result.isSuccess) {
                    this.datas = result.dataList;
                    this.thisDay = result.thisDay.replace('-', '/');
                    this.thisTime = result.thisTime;
                    this.userType = result.userType;
                    this.addressStr = result.addressStr;
                    this.checkInStatusLabel = result.checkInStatusLabel;
                    this.checkInStatusAPIValue = result.checkInStatus;
                    let nowTime = new Date(result.thisDay + ' ' + result.thisTime + ':00');
                    let startTime = null;
                    let endTime = null;
                    if (result.dataList && result.dataList.length > 0) {
                        this.storeId = result.dataList[0].Id;
                        if (result.checkInStatus == '未签到') {
                            startTime = new Date(result.thisDay + ' ' + result.dataList[0].roleStartTime + ':00');
                            startTime.setMinutes(startTime.getMinutes() - result.dataList[0].roleTimeBuffer);
                            // 最迟签到打卡时间
                            endTime = new Date(result.thisDay + ' ' + result.dataList[0].roleStartTime + ':00');
                            endTime.setMinutes(endTime.getMinutes() + result.dataList[0].roleTimeBuffer);
                            if (nowTime < startTime) {
                                this.nextLoopInterval = startTime - nowTime;
                            } else if (
                                result.dataList[0].roleDistanceText === CheckInCheckOut_WITHIN_RANGE 
                                && nowTime < endTime    // 考勤时间内自动签到 
                            ) {
                                this.navigatorInfo += ';thisDay=' + this.thisDay;
                                this.navigatorInfo += ';thisTime=' + this.thisTime;
                                this.navigatorInfo += ';result.dataList[0].roleEndTime=' + result.dataList[0].roleEndTime;
                                this.navigatorInfo += ';d=' + d;
                                this.navigatorInfo += ';d.getTime=' + d.getTime();
                                this.navigatorInfo += ';startTime=' + startTime;
                                this.navigatorInfo += ';startTime.getTime=' + startTime.getTime();
                                this.navigatorInfo += ';endTime=' + endTime;
                                this.navigatorInfo += ';endTime.getTime=' + endTime.getTime();
                                this.callCheckIn();
                            }                      
                        } else {
                            this.endLoop = true;
                        }
                    }
                }
                
                this.nextLoop();
        }).catch(error => {
            this.isShowSpinner = false;
            // this.showNotification("", error.message ,"error");
            console.log('ERROR+++++++++++++'+JSON.stringify(error)+'      '+error.message);
            // this.showVfError(error.message);
            this.nextLoop();
        });
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
                    this.showSuccess('system auto check in success');
                }else{
                    this.nextLoop();
                }
                this.isCheckOut = false;
                this.isCheckIn = false;
        }).catch(error => {
            this.isShowSpinner = false;
            console.log(error);
            // this.showNotification("", error.body.message ,"error");
            // this.showVfError(error.body.message);
            this.isCheckOut = false;
            this.isCheckIn = false;
            this.nextLoop();
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
                    this.showSuccess('system auto check out success');
                }else{
                    this.nextLoop();
                }
                this.isCheckOut = false;
                this.isCheckIn = false;
        }).catch(error => {
            this.isShowSpinner = false;
            console.log(error);
            // this.showNotification("", error.body.message ,"error");
            // this.showVfError(error.body.message);
            this.isCheckOut = false;
            this.isCheckIn = false;
            this.nextLoop();
        });
    }
    nextLoopInterval = 60000;
    nextLoop() {
        if (this.endLoop) {
            return;
        }
        setTimeout(() => {
            if (this.endLoop) {
                return;
            }
            this.getCurrentPosition(false);
        }, this.nextLoopInterval);
    }
}