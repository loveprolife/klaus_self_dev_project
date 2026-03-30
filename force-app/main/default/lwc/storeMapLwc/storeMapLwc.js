import { LightningElement,track,wire,api } from 'lwc';
import {GoogleMapApi, LightningNavigationElement} from 'c/lwcUtils'
import { RefreshEvent } from 'lightning/refresh';

import getInitData from '@salesforce/apex/StoreMapController.getInitData';
// import apex method from salesforce module 
import fetchLookupData from '@salesforce/apex/StoreMapController.fetchLookupData';

import INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION from '@salesforce/label/c.INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION';
import STORE_MAP_SEARCH_PLACEHOLDER from '@salesforce/label/c.STORE_MAP_SEARCH_PLACEHOLDER';
import STORE_MAP_SEARCH_NO_RECORD_MSG from '@salesforce/label/c.STORE_MAP_SEARCH_NO_RECORD_MSG';
import STORE_MAP_SEARCH_RESULTS from '@salesforce/label/c.STORE_MAP_SEARCH_RESULTS';
import STORE_MAP_INSPECTION_REPORT_COUNT from '@salesforce/label/c.STORE_MAP_INSPECTION_REPORT_COUNT';
import STORE_MAP_SELL_OUT from '@salesforce/label/c.STORE_MAP_SELL_OUT';
import STORE_MAP_NO_STORE from '@salesforce/label/c.STORE_MAP_NO_STORE';

import STORE_MAP_STORE_LIST from '@salesforce/label/c.STORE_MAP_STORE_LIST';
import STORE_MAP_PROMOTER from '@salesforce/label/c.STORE_MAP_PROMOTER';
import STORE_MAP_MARKET from '@salesforce/label/c.STORE_MAP_MARKET';
import STORE_MAP_MONTH from '@salesforce/label/c.STORE_MAP_MONTH';
import STORE_MAP_FLOORWALKER from '@salesforce/label/c.STORE_MAP_FLOORWALKER';
import STORE_MAP_STORE from '@salesforce/label/c.STORE_MAP_STORE';
const DELAY = 300; // dealy apex callout timing in miliseconds  
const PC_HEIGHT = 600; // is pc height
export default class StoreMapLwc extends LightningNavigationElement {

    label = {
        INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION,   // 当前设备不支持定位功能
        STORE_MAP_SEARCH_PLACEHOLDER,                   // 请输入网格渠道或门店名
        STORE_MAP_SEARCH_NO_RECORD_MSG,                 // 未找到数据
        STORE_MAP_SEARCH_RESULTS,                       // 搜索结果来自于{0}
        STORE_MAP_INSPECTION_REPORT_COUNT,              // 巡店日报总数
        STORE_MAP_SELL_OUT,                             // 销售总额
        STORE_MAP_NO_STORE,                             // 当前位置附近没有门店

        STORE_MAP_STORE_LIST,                           // 门店列表
        STORE_MAP_PROMOTER,                             // 促销员日报
        STORE_MAP_MARKET,                               // 促销员周报
        STORE_MAP_MONTH,                                // 促销员月报
        STORE_MAP_FLOORWALKER,                          // 巡店员报告
        STORE_MAP_STORE,                                // 门店
    }

    @track isShowSpinner = false;               // 加载中
    get spinnerStyle() {
        if (this.documentHeight && this.isMobile) {
            return 'height:'+this.documentHeight+'px;';
        } else {
            return 'height:100%';
        }
    }
    googleMapApi;                               // GoogleMap对象
    googleMapVFUrl = '';                        // GoogleMapVF请求地址
    googleMapInitState = false;                 // GoogleMap状态
    googleMapInitIndex = 0;                     // GoogleMap请求次数
    @track currentLat = 0;                      // 当前坐标 Lat
    @track currentLong = 0;                     // 当前坐标 Long
    // 是否已获取当前坐标
    get checkCurrentPosition() {
        if (this.currentLat!=0 && this.currentLong!=0) {
            return true;
        } else {
            return false;
        }
    }
    @track documentHeight = 0;                  // 主页面高度
    @track documentWidth = 0;                   // 主页面宽度
    @track titleHeight = 0;                     // title高度
    // 主页面高度
    get documentHeightStyle() {
        return 'height:'+this.documentHeight+'px;';
    }
    // google map iframe 高度
    get googleMapHeightStyle() {
        if (this.showSearchView) {
            return '0px'
        }
            
        if (this.isMobile) {
            if (this.documentHeight>this.titleHeight) {
                return (this.documentHeight-this.titleHeight)+'px';
            } else {
                return '100%';
            }
        } else {
            return PC_HEIGHT+'px';
        }
    }
    // 手机门店详情高度 storeMarketsIsNull -> true
    get storeInfoViewHeightStyle() {
        var style = '';
        style += 'overflow: auto;';
        var tmp = this.template.querySelector("[name='googleMap']");
        if (this.storeInfoStatus=='open' && tmp) {
            var h = tmp.offsetHeight;
            var tmp_btn = this.template.querySelector('.mobileViewBtnDiv');
            if (tmp_btn) {
                h -= tmp_btn.offsetHeight;
                h -= 40;
            }
            style += 'height: '+h+'px;';
        } else {
            style += 'max-height: 8rem;';
        }
        return style;
    }
    // 手机门店详情高度 storeMarketsIsNull -> false
    get storeInfoViewHeightStyleIsNull() {
        var style = '';
        style += 'width: 100%; text-align: center;';
        var tmp = this.template.querySelector("[name='googleMap']");
        if (this.storeInfoStatus=='open' && tmp) {
            var h = tmp.offsetHeight;
            var tmp_btn = this.template.querySelector('.mobileViewBtnDiv');
            if (tmp_btn) {
                h -= tmp_btn.offsetHeight;
                h -= 40;
            }
            style += 'height: '+h+'px;';
        }
        return style;
    }
    @track storeInfoStatus = 'close';           // store info btn 
    // store info is close
    get storeInfoIsClose() {
        if (this.storeInfoStatus == 'close') {
            return true;
        } else {
            return false;
        }
    }    
    // store info is onlyOne
    get storeInfoIsOnlyOne() {
        if (this.storeInfoStatus == 'onlyOne') {
            return true;
        } else {
            return false;
        }
    }       
    // storeInfoBtnDiv  icon
    get storeInfoBtnIcon() {
        if (this.storeInfoStatus == 'close') {
            return 'utility:chevronup';
        } else {
            return 'utility:chevrondown';
        }
    }
    // storeInfoBtnDiv  style
    get storeInfoBtnStyle() {
        var style = '';
        style += 'margin-top: -8px;';
        style += 'margin-bottom: 10px;';
        style += 'text-align: center;';

        return style;
    }
    get storeMarkets() {
        return this.storeInfoDatas;
    }
    // 地图门店坐标为空
    get storeMarketsIsNull() {
        if (this.storeMarkets.length>0) {
            return false;
        } else {
            return true;
        }
    }
    @track storeInfoDatas = [];                 // 门店详细信息list
    get hasStoreInfoData() {
        return this.storeInfoDatas && this.storeInfoDatas.length > 0;
    }
    @track responsiblePersons = [];             // 地图门店负责人信息
    // 所选门店作为促销员
    get onlyOneIsPromoter() {
        if (!this.storeInfoIsOnlyOne) {
            return false;
        }
        if (this.storeInfoDatas.length!=1) {
            return false;
        }
        var storeInfo = this.storeInfoDatas[0];
        var rpList = this.responsiblePersons.filter(obj => obj.Shop_Name__c == storeInfo.Id);
        if (rpList.length==0) {
            return false;
        }
        for (let i = 0; i < rpList.length; i++) {
            var rp = rpList[i];
            if (rp.RecordType__c == '促销员') {
                return true;
            }
        }
        return false;
    }
    // 所选门店作为巡店员
    get onlyOneIsFloorwalker() {
        if (!this.storeInfoIsOnlyOne) {
            return false;
        }
        if (this.storeInfoDatas.length!=1) {
            return false;
        }
        var storeInfo = this.storeInfoDatas[0];
        var rpList = this.responsiblePersons.filter(obj => obj.Shop_Name__c == storeInfo.Id);
        if (rpList.length==0) {
            return false;
        }
        for (let i = 0; i < rpList.length; i++) {
            var rp = rpList[i];
            if (rp.RecordType__c == '巡店员' || 
                rp.RecordType__c == 'Regional Manager' || 
                rp.RecordType__c == 'Backup Floorwalker') {
                return true;
            }
        }
        return false;
    }

    // 所选门店作为促销员
    isStorePromoter(storeInfo) {
        var rpList = this.responsiblePersons.filter(obj => obj.Shop_Name__c == storeInfo.Id);
        if (rpList.length==0) {
            return false;
        }
        for (let i = 0; i < rpList.length; i++) {
            var rp = rpList[i];
            if (rp.RecordType__c == '促销员') {
                return true;
            }
        }
        return false;
    }
    // 所选门店作为巡店员
    isStoreFloorwalker(storeInfo) {
        // 2024-01-17 wfc 特定用户可不需要配置门店负责人信息，选择所有权限门店
        console.log('wwww--' + this.isLeader);
        if(this.isLeader){
            return true;
        }
        var rpList = this.responsiblePersons.filter(obj => obj.Shop_Name__c == storeInfo.Id);
        if (rpList.length==0) {
            return false;
        }
        for (let i = 0; i < rpList.length; i++) {
            var rp = rpList[i];
            if (rp.RecordType__c == '巡店员' || 
                rp.RecordType__c == 'Regional Manager' || 
                rp.RecordType__c == 'Backup Floorwalker') {
                return true;
            }
        }
        return false;
    }

    objectAccessible = {};

    // get isMobile() {
    //     return true;
    // }

    handleRole(list) {
        for (let index = 0;list && index < list.length; index++) {
            let element = list[index];
            element.isStorePromoter = this.isStorePromoter(element);
            element.isStoreFloorwalker = this.isStoreFloorwalker(element);
        }
    }

    // 取消下拉刷新
    disablePullToRefresh() {
        if (!this.isMobile) {
            return;
        }
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
        console.log('Store Map Start');
        this.disablePullToRefresh();
        // 初始化Google Map
        this.googleMapApi = new GoogleMapApi();
        this.googleMapInit();
        this.googleMapVFUrl = '/apex/CommonGoogleMapPage';
        /**
         * 初始化加载
         * 取消加载需要确保是googleMapCallback type=NeedInitConfig时取消
         * 保证控件之间通信正常
         */
        this.isShowSpinner = true;

        this.checkGoogleMapInit();
    }

    // 页面渲染
    renderedCallback() {
        console.log('renderedCallback');
        var titleDoc = this.template.querySelector('[data-name="titleDiv"]');
        if (titleDoc) {
            this.titleHeight = titleDoc.offsetHeight;
            console.log('title height='+this.titleHeight);
        }
        this.documentHeight = document.documentElement.clientHeight;
        console.log('document height='+this.documentHeight);
        this.documentWidth = document.documentElement.clientWidth;
        console.log('document width='+this.documentWidth);
    }

    // 初始化图钉
    initializationMarket(ele) {

        var config = {
            "ele": ele,
            "iframeId": "googleMap",
            "data": {
                "config": {
                    "position": {
                        "lat": ele.currentLat,
                        "lng": ele.currentLong
                    },
                    "zoom": 18,
                    "closeAllInfoWindow": true
                },
                "markers":[
                    {
                        "action": "new",
                        "id": "me",
                        "position": {
                            "lat": ele.currentLat,
                            "lng": ele.currentLong
                        },
                        "label": "",
                        "isShow": true,
                        "type": "point"
                    }
                ]
            }
        };
        if (ele.storeMarkets.length>0) {
            for (let i = 0; i < ele.storeMarkets.length; i++) {
                var storeData = ele.storeMarkets[i];
                var city = storeData.object.City__c ? storeData.object.City__c : '';
                var address = storeData.object.Address1__c ? storeData.object.Address1__c : '';
                var infoWindow = '<strong>'+storeData.object.Name+'</strong><br/>'+city+'<br/>'+address;
                var storeMarket = {
                    "action": "new",
                    "id": storeData.Id,
                    "position": {
                        "lat": storeData.object.Shop_Center_Location__Latitude__s,
                        "lng": storeData.object.Shop_Center_Location__Longitude__s
                    },
                    "label": storeData.object.Name,
                    "title": storeData.object.Name,
                    "isClick": true,
                    "isShow": true,
                    "type": "thumbtack",
                    "clickType": "getMarkerId",
                    "infoWindow": infoWindow,
                };
                config.data.markers.push(storeMarket);
            }
        }
        ele.googleMapApi.sendMessageToChild(config);
    }

    isLeader = false;
    // 初始化附近门店
    getStoreMapData(ele) {
        getInitData({
            currentLat: JSON.stringify(ele.currentLat),
            currentLong: JSON.stringify(ele.currentLong)
        }).then(data => {
            console.log('getInitData');
            console.log(JSON.stringify(data));
            if (data.isSuccess) {
                console.log('getInitData success');
                if (data.data.stroreMapMarkets) {
                    ele.storeInfoDatas = data.data.stroreMapMarkets;
                }
                if (data.data.responsiblePersons) {
                    ele.responsiblePersons = data.data.responsiblePersons;
                }

                // 2024-01-17 wfc 特定用户可不需要配置门店负责人信息，选择所有权限门店
                ele.isLeader =  data.data.isLeader;

                ele.handleRole(ele.storeInfoDatas);
                // for (let index = 0; index < ele.storeInfoDatas.length; index++) {
                //     let element = ele.storeInfoDatas[index];
                //     element.isStorePromoter = ele.isStorePromoter(element);
                //     element.isStoreFloorwalker = ele.isStoreFloorwalker(element);
                // }
                
                // 初始化图钉
                ele.initializationMarket(ele);
                ele.isShowSpinner = false;
                ele.objectAccessible = data.data.objectAccessible;
            } else {
                console.log('getInitData error');
                // 初始化图钉(当前坐标初始化)
                ele.initializationMarket(ele);
                ele.isShowSpinner = false;
                ele.showError(data.message);
            }
        }).catch(error =>{
            console.log('getInitData catch error');
            console.log(JSON.stringify(error));
            // 初始化图钉(当前坐标初始化)
            ele.initializationMarket(ele);
            ele.isShowSpinner = false;
            ele.catchError(error);
        })
    }
    
    // 获取当前坐标
    getCurrentPosition(callback) {
        // this.isShowSpinner = true;
        console.log('==========>getCurrentPosition');
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                // 测试用，固定坐标
                // this.currentLat = 23.13070;
                // this.currentLong = 113.33301;
                this.currentLat = position.coords.latitude;
                this.currentLong = position.coords.longitude;
                // this.isShowSpinner = false;
                callback(this);
            }, error =>{
                // this.isShowSpinner = false;
                this.showError(this.getErrorInfomation(error));
                callback(this);
            },{ 
                enableHighAccuracy: true,timeout: 10000}
            );
        }else {
            // this.isShowSpinner = false;
            callback(this);
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

    // 新建lwc监听
    googleMapInit() {
        var config = {
            "ele": this,
            "callback": this.googleMapCallback,
            "visualForceOrigin": '',
            "iframeId": 'googleMap'
        };

        this.googleMapApi.init(config);
    }
    
    // Google Map线程监听
    checkGoogleMapInit () {
        if (this.googleMapInitState==true) {
            // 获取当前坐标
            this.isShowSpinner = true;
            this.getCurrentPosition(this.getStoreMapData);
        } else if (this.googleMapInitIndex>=40) {
            this.isShowSpinner = false;
            this.showError('Google Map Api Timeout');
        } else {
            setTimeout(() => {
                this.googleMapInitIndex += 1;
                console.log('call google map api sleep '+(this.googleMapInitIndex*500)+'ms');
                this.checkGoogleMapInit();
            }, 500);
        }
    }

    // Google Map Call Back
    googleMapCallback(info, ele) {
        console.log('api callback '+JSON.stringify(info));
        if (info.type=='NeedInitConfig') {
            console.log('google map api link success');
            ele.googleMapInitState = true;
            ele.isShowSpinner = false;
        }

        if (info.type=='MarkerId') {
            ele.isShowSpinner = true;
            ele.showSearchView = false;
            var storeOption = [];
            ele.storeMarkets.forEach(obj => {
                if (obj.Id == info.data) {
                    storeOption.push(obj);
                }
            });
            let foo = null;
            foo = () => {
                let ce = ele.template.querySelector('.storeListContainer');
                let item = ele.template.querySelector('.storeListContainer .' + info.data);
                if (ce && item) {
                    let ot = item.offsetTop -20;
                    ce.scrollTop = ot < 80 ? 0 : ot;
                } else {
                    setTimeout(foo, 500);
                }
            };
            foo();
            // ele.storeInfoDatas = storeOption;
            // ele.storeInfoStatus = 'onlyOne';
            ele.isShowSpinner = false;
        }

        if (info.type=='closeInfoWindow') {
            ele.storeInfoStatus = 'close';
            if (!ele.isMobile) {
                ele.storeInfoDatas = ele.storeMarkets;
                ele.handleRole(ele.storeInfoDatas);
            }
        }
        
        // if (info.type=='MarkerIsClick') {
        //     ele.showError(info.data);
        // }

        // if (info.type=='test') {
        //     ele.showError(info.data);
        // }

    }

    // store info btn click
    storeInfoBtnClick() {
        if (this.storeInfoStatus == 'close') {
            this.storeInfoStatus = 'open';
        } else {
            this.storeInfoStatus = 'close';
        }

        // if (this.storeInfoStatus == 'open') {
        //     this.storeInfoDatas = this.storeMarkets;
        // }
    }

    storeClick(event) {
        if (!this.showSearchView && ((this.isMobile && this.storeInfoIsClose) || this.storeInfoIsOnlyOne)) {
            return;
        }
        this.storeClick2(event);
    }

    // store info click
    storeClick2(event) {
        this.storeInfoStatus = 'close';
        var storeId = event.currentTarget.dataset.id;
        if (!(storeId)) {
            return;
        }
        var storeData = this.storeInfoDatas.find(obj => obj.Id == storeId);
        if (!(storeData)) {
            return;
        }
        var config = {
            "ele": this,
            "iframeId": "googleMap",
            "data": {
                "config": {
                    "marketClick": storeId,
                    "position": {
                        "lat": storeData.object.Shop_Center_Location__Latitude__s,
                        "lng": storeData.object.Shop_Center_Location__Longitude__s
                    }
                }
            }
        };
        
        this.googleMapApi.sendMessageToChild(config);
    }

    // 刷新定位
    refreshPositioning() {
        this.isShowSpinner = true;
        this.storeInfoStatus = 'close';
        this.checkGoogleMapInit();
    }
    
    // 跳转门店列表
    gotoStoreList() {
        this.goToObject('Shop__c');
    }

    // 跳转门店详情
    gotoStoreViewPage() {
        if ((!this.storeInfoIsOnlyOne) && this.storeInfoDatas.length==1) {
            return;
        }

        var storeDate = this.storeInfoDatas[0];
        this.goToRecord(storeDate.Id);
    }

    // 跳转Promoter 门店页面
    gotoPromoterViewPage() {
        if ((!this.storeInfoIsOnlyOne) && this.storeInfoDatas.length==1) {
            return;
        }

        var storeDate = this.storeInfoDatas[0];
        this.goToComponent('c__LWCWrapper',{
            'lwcName' : 'newPromoterDailyReportLwc',
            'shopId' : storeDate.Id
        });
    }

    // 跳转Market 门店页面
    gotoMarketViewPage() {
        if ((!this.storeInfoIsOnlyOne) && this.storeInfoDatas.length==1) {
            return;
        }

        var storeDate = this.storeInfoDatas[0];
        this.goToComponent('c__LWCWrapper',{
            'lwcName' : 'weeklyReportLwc',
            'shopId' : storeDate.Id
        });
    }
    
    // 跳转Month 门店页面
    gotoMonthViewPage() {
        if ((!this.storeInfoIsOnlyOne) && this.storeInfoDatas.length==1) {
            return;
        }

        var storeDate = this.storeInfoDatas[0];
        this.goToComponent('c__LWCWrapper',{
            'lwcName' : 'monthlyReportLwc',
            'shopId' : storeDate.Id
        });
    }

    // 跳转Floorwalker 门店页面
    gotoFloorwalkerViewPage() {
        if ((!this.storeInfoIsOnlyOne) && this.storeInfoDatas.length==1) {
            return;
        }

        var storeDate = this.storeInfoDatas[0];
        this.goToComponent('c__LWCWrapper',{
            'lwcName' : 'newInspectorDailyReportLwc',
            'shopId' : storeDate.Id
        });
    }
    
    // 自定义lookup部分=============================================
    // public properties with initial default values 
    // @track placeholder = 'Please enter Grid/Customer/Store Name...'; 
    @track iconName = 'custom:custom15';
    @track sObjectApiName = 'Shop__c';
    @track showSearchView = false;
    // private properties 
    lstResult = []; // to store list of returned records   
    hasRecords = true; 
    searchKey=''; // to store input field value    
    isSearchLoading = false; // to control loading spinner  
    delayTimeout;
    selectedRecord = {}; // to store selected lookup record in object formate 

    @track queryList = [];

    get searchResultsLabel() {
        return this.label.STORE_MAP_SEARCH_RESULTS.format(this.searchKey);
    }
    get searchKeyIsNull() {
        if (this.searchKey==''||this.searchKey==null) {
            return true;
        } else {
            return false;
        }
    }  
    get searchViewHeight() {
        var style = '';
        var height = '';
        if (this.isMobile) {
            if (this.documentHeight>this.titleHeight) {
                height += (this.documentHeight-this.titleHeight-20)+'px;';
            } else {
                height += '95%';
            }
        } else {
            height += PC_HEIGHT+'px';
        }

        style += 'height:'+height + ';';
        style += 'max-height:'+height + ';';
        style += 'width:100%;';
        style += 'background:white;';
        style += 'padding-left: 10px;';
        style += 'padding-right: 10px;';

        return style;
    }  
    get searchListHeight() {
        var style = '';
        var height = '';
        if (this.isMobile) {
            if (this.documentHeight>this.titleHeight) {
                var tmp = this.template.querySelector('.slds-text-align_left');
                var tmph = 0;
                if (tmp) {
                    tmph = tmp.offsetHeight;
                }
                height += (this.documentHeight-this.titleHeight-20-tmph)+'px;';
            } else {
                height += '95%';
            }
        } else {
            var tmp = this.template.querySelector('.slds-text-align_left');
            var tmph = 0;
            if (tmp) {
                tmph = tmp.offsetHeight;
            }
            height += (PC_HEIGHT-20-tmph)+'px;';
        }

        style += 'height:'+height + ';';
        style += 'max-height:'+height + ';';
        style += 'overflow: auto;';

        return style;
    }
    // wire function property to fetch search record based on user input
    @wire(fetchLookupData, { 
            searchKey: '$searchKey', 
            sObjectApiName : '$sObjectApiName', 
            lat: '$currentLat', 
            lng: '$currentLong',
            lmt: 5,
            oft: 0
        })
        searchResult(value) {
        const { data, error } = value; // destructure the provisioned value
        this.isSearchLoading = false;
        if (data) {
                this.hasRecords = data.length == 0 ? false : true; 
                this.lstResult = JSON.parse(JSON.stringify(data)); 
                console.log('query list='+JSON.stringify(this.lstResult));
            }
        else if (error) {
            console.log('(error---> ' + JSON.stringify(error));
            }
    };
           
    // update searchKey property on input field change  
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            
        this.searchKey = searchKey;
        this.showSearchView = false;
        }, DELAY);
    }
    // method to toggle lookup result section on UI 
    toggleResult(event){
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch(whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
                break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');    
            break;                    
            }
    }
    // method to clear selected lookup record  
    handleRemove(){
        this.searchKey = '';    
        this.selectedRecord = {};
        // remove selected pill and display input field again 
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-hide');
        searchBoxWrapper.classList.add('slds-show');
        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-show');
        pillDiv.classList.add('slds-hide');
        this.showSearchView = false;
    }
    // method to update selected record from search result 
    handelSelectedRecord(event){   
        var objId = event.target.getAttribute('data-recid'); // get selected record Id 
        if(!objId) {
            objId = event.currentTarget.dataset.recid;
        }
        this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list 
        this.showSearchView = false;
        this.searchKey = this.selectedRecord.Name;
        this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
        this.queryList = [this.selectedRecord];
        this.handelStoreView(this.selectedRecord);
    }
    /*COMMON HELPER METHOD STARTED*/
    handelSelectRecordHelper(){
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        // const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        // searchBoxWrapper.classList.remove('slds-show');
        // searchBoxWrapper.classList.add('slds-hide');
        // const pillDiv = this.template.querySelector('.pillDiv');
        // pillDiv.classList.remove('slds-hide');
        // pillDiv.classList.add('slds-show');     
    }
    // 点击store info类型信息 联动google map
    handelStoreView(dataObj){
        if (!(dataObj)) {
            return;
        }
        this.isShowSpinner = true;
        var clon = JSON.parse(JSON.stringify(dataObj));
        var checkStoreInfo = this.storeMarkets.filter(obj => obj.Id == clon.Id);
        var needNewMarker = false;
        if (this.storeMarkets.length==0) {
            needNewMarker = true;
            this.storeMarkets.push(clon);
        } else if (checkStoreInfo.length==0) {
            needNewMarker = true;
            // for (let i = 0; i < this.storeMarkets.length; i++) {
            //     var smItem = this.storeMarkets[i];
            //     if (Number(clon.distance) < Number(smItem.distance)) {
            //         this.storeMarkets.splice(i,0,clon);
            //         break;
            //     }
            //     if (i==(this.storeMarkets.length-1)) {
            //         this.storeMarkets.push(clon);
            //         break;
            //     }
            // }
            this.storeMarkets.sort((a,b) => {
                return Number(a.distance) - Number(b.distance);
            });
            this.storeMarkets.splice(0,0,clon);
        } else if (this.storeMarkets.length>1 && checkStoreInfo.length>0) {
            var newStoreMarkets = [];
            newStoreMarkets.push(clon);
            this.storeMarkets.sort((a,b) => {
                return Number(a.distance) - Number(b.distance);
            });
            for (let i = 0; i < this.storeMarkets.length; i++) {
                var smItem = this.storeMarkets[i];
                if (smItem.Id!=clon.Id) {
                    newStoreMarkets.push(smItem);
                }
            }
            this.storeInfoDatas = newStoreMarkets;
            this.handleRole(this.storeInfoDatas);
        }

        var config = {
            "ele": this,
            "iframeId": "googleMap",
            "data": {
                "config": {},
                "markers":[]
            }
        };

        if (this.storeMarkets.length>0) {
            for (let i = 0; i < this.storeMarkets.length; i++) {
                var item = this.storeMarkets[i];
                config.data.markers.push({"action":"del","type":"thumbtack","id":item.Id});
            }
        }
        this.storeInfoDatas = this.queryList;
        this.handleRole(this.storeInfoDatas);
        for (let i = 0; i < this.queryList.length; i++) {
            var storeData = this.queryList[i];
            var city = storeData.object.City__c ? storeData.object.City__c : '';
            var address = storeData.object.Address1__c ? storeData.object.Address1__c : '';
            var infoWindow = '<strong>'+storeData.object.Name+'</strong><br/>'+city+'<br/>'+address;
            var storeMarket = {
                "action": "new",
                "id": storeData.Id,
                "position": {
                    "lat": storeData.object.Shop_Center_Location__Latitude__s,
                    "lng": storeData.object.Shop_Center_Location__Longitude__s
                },
                "label": storeData.object.Name,
                "title": storeData.object.Name,
                "isClick": true,
                "isShow": true,
                "type": "thumbtack",
                "clickType": "getMarkerId",
                "infoWindow": infoWindow,
            };
            config.data.markers.push(storeMarket);
        }
        // if (needNewMarker) {
        //     var city = clon.object.City__c ? clon.object.City__c : '';
        //     var address = clon.object.Address1__c ? clon.object.Address1__c : '';
        //     var infoWindow = '<strong>'+clon.object.Name+'</strong><br/>'+city+'<br/>'+address;
        //     var storeMarket = {
        //         "action": "new",
        //         "id": clon.Id,
        //         "position": {
        //             "lat": clon.object.Shop_Center_Location__Latitude__s,
        //             "lng": clon.object.Shop_Center_Location__Longitude__s
        //         },
        //         "label": clon.object.Name,
        //         "title": clon.object.Name,
        //         "isClick": true,
        //         "isShow": true,
        //         "type": "thumbtack",
        //         "clickType": "getMarkerId",
        //         "infoWindow": infoWindow,
        //     };
        //     config.data.markers.push(storeMarket);
        // }
        config.data.config['marketClick'] = clon.Id;
        config.data.config['position'] = {
            "lat": clon.object.Shop_Center_Location__Latitude__s,
            "lng": clon.object.Shop_Center_Location__Longitude__s
        };
        this.googleMapApi.sendMessageToChild(config);
    }
    // 点击搜索
    handelSearchValue() {
        if (!this.searchKey) {
            return;
        }
        this.isShowSpinner = true;

        this.showSearchView = true;
        this.handelSearchValueHelper();
        fetchLookupData({
            searchKey: this.searchKey, 
            sObjectApiName : this.sObjectApiName, 
            lat: this.currentLat, 
            lng: this.currentLong,
            lmt: 20,
            oft: 0
        }).then(resp => {
            if (resp) {
                this.queryList = JSON.parse(JSON.stringify(resp));
            }
            this.isShowSpinner = false;
            if (this.queryList.length > 1) {
                this.handelQueryListClick({
                    currentTarget : {
                        dataset : {
                            id : this.queryList[0].Id
                        }
                    }
                })
            }
        }).catch(error => {
            console.log(JSON.stringify(error));
            this.isShowSpinner = false;
        })

    }
    // 点击搜索之后页面显示调整
    handelSearchValueHelper(){
        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-show');
        pillDiv.classList.add('slds-hide');
    }
    // query list click
    handelQueryListClick(event) {
        var objId = event.currentTarget.dataset.id;
        var queryData = this.queryList.find(data => data.Id === objId);
        if (queryData) {
            this.handelStoreView(queryData);
        }
    }
    
    // 添加query list
    handelQueryListAddItem() {
        this.isShowSpinner = true;
        fetchLookupData({
            searchKey: this.searchKey, 
            sObjectApiName : this.sObjectApiName, 
            lat: this.currentLat, 
            lng: this.currentLong,
            lmt: 20,
            oft: this.queryList.length
        }).then(resp => {
            if (resp && resp.length>0) {
                var data = JSON.parse(JSON.stringify(resp));
                data.forEach(obj => {
                    this.queryList.push(obj);
                });
                this.onRefresh();
            } else {
                this.showError('All data loaded.');
            }
            this.isShowSpinner = false;
        }).catch(error => {
            console.log(JSON.stringify(error));
            this.isShowSpinner = false;
        })
    }
    onRefresh() {
        this.dispatchEvent(new RefreshEvent());
    }

    goToSore(event) {
        event.stopPropagation();
        let store = this.storeInfoDatas[event.currentTarget.dataset.index];
        if (store) {
            this.goToRecord(store.Id);
        }
    }

    goToPromoterReport(event) {
        event.stopPropagation();
        let store = this.storeInfoDatas[event.currentTarget.dataset.index];
        if (store) {
            this.goToComponent('c__LWCWrapper',{
                'lwcName' : 'newPromoterDailyReportLwc',
                'shopId' : store.Id
            });
        }
    }

    goToFloorwalkerReport(event) {
        event.stopPropagation();
        let store = this.storeInfoDatas[event.currentTarget.dataset.index];
        if (store) {
            this.goToComponent('c__LWCWrapper',{
                'lwcName' : 'newInspectorDailyReportLwc',
                'shopId' : store.Id
            });
        }

    }

    goToDailySales(event) {
        event.stopPropagation();
        let store = this.storeInfoDatas[event.currentTarget.dataset.index];
        if (store) {
            this.goToRelatedList('Shop__c', store.Id, 'Shop_Retail_Number__r');
        }
    }

    goToInspectionReport(event) {
        event.stopPropagation();
        let store = this.storeInfoDatas[event.currentTarget.dataset.index];
        if (store) {
            this.goToRelatedList('Shop__c', store.Id, 'DailyInspectionReports__r');
        }
    }
}