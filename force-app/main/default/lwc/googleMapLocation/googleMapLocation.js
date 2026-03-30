/*
 * @Author: tom
 * @Date: 2025-06-11 10:37:14
 * @LastEditors: Do not edit
 * @LastEditTime: 2025-06-12 11:24:34
 */
import { LightningElement, track } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'

export default class GoogleMapLocation extends LightningNavigationElement {

    @track isShowSpinner = false;
    @track isModalOpen = false;
    @track isJapan = false;
    @track isLocationOpen = false;
    @track currentLat;
    @track currentLong;
    @track storeAddress;
    @track addressDetails = {};
    @track googleMapUrl;
    @track record = {};
    // 是否是返回操作
    @track isBack = false;

    vfIframe;

    // iframe 加载完成后获取引用
    handleIframeLoad(event) {
        this.vfIframe = event.target;
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.handleMessage.bind(this));
    }

    connectedCallback(){
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                // 测试用，固定坐标
                this.currentLat = position.coords.latitude;
                this.currentLong = position.coords.longitude;
                console.log('wwwwww---currentLat--' + this.currentLat);
                console.log('wwwwww---currentLong--' + this.currentLong);

                // 构造带参数的 VF 页面 URL
                this.googleMapUrl = `/apex/GoogleMapLocation?param1=${encodeURIComponent(this.currentLat)}&param2=${encodeURIComponent(this.currentLong)}`;
            }, error =>{
                this.googleMapUrl = `/apex/GoogleMapLocation`;
                switch(error.code) {
                    case error.PERMISSION_DENIED:
                        alert('用户拒绝定位授权LWC');
                        break;
                    case error.POSITION_UNAVAILABLE:
                        alert('无法获取位置信息LWC');
                        break;
                    case error.TIMEOUT:
                        alert('定位请求超时LWC');
                        break;
                    default:
                        console.log('获取定位信息失败');
                        alert(error);
                }
            },{enableHighAccuracy: true, timeout: 10000});  
        }else {
            console.log('wwwwww---2222--');
            alert('当前浏览器不支持定位功能LWC');
        }

        window.addEventListener('message', this.handleMessage.bind(this));
    }

    // 与ifream 通信
    handleMessage(event) {
        // 确保消息来源是可信的，例如来自同一个Salesforce域
        console.log('wwww--origin:' + event.origin);

        if (!(event.origin.includes('vf.force.com'))) {
            return;
        }
        
        if (event.data.action === 'location') {
            this.isModalOpen = true;
            this.currentLat = event.data.lat;
            this.currentLong = event.data.lng;
            this.addressDetails = event.data.addressDetails;
            console.log('wwwww---地址详细信息--' + JSON.stringify(this.addressDetails));
            // Address1__c 去掉前面国家+省+市
            const address = event.data.storeAddress;
            const nation = this.addressDetails.country + this.addressDetails.province + this.addressDetails.city;
            this.storeAddress = this.removePrefix(address, nation);
            this.record['Shop_Center_Location__c'] = {
                latitude: this.currentLat,
                longitude: this.currentLong
            };
            this.record['Country__c'] = this.addressDetails.country;
            this.record['Address1__c'] = this.storeAddress;
            this.record['City__c'] = this.addressDetails.city;
            this.record['State_Province__c'] = this.addressDetails.province;
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        location : this.record
                    }
                })
            );
            this.handleBack();

        }
        
    }

    removePrefix(s1, s2) {
        s1 = s1 || '';
        s2 = s2 || '';
        if (s1.indexOf(s2) !== -1) {
          return s1.slice(s1.indexOf(s2) + s2.length);
        }
        return s1;
    }
      
    // 关闭弹出框
    closeModal(event){
        this.clearRecord();
        // this.isModalOpen = false;
        this.handleBack();
    }

    clearRecord(){
        this.record = {};
        this.record['Address1__c'] = this.storeAddress;
    }

    // new shop
    handleChange(event){
        const fieldName = event.target.dataset.fieldName;
        const fieldValue = event.target.value;
        this.record[fieldName] = fieldValue;
        if(fieldName === 'Sales_Region__c'){
            if(fieldValue.includes('Japan')){
                this.isJapan = true;
            }else {
                this.isJapan = false;
                this.record.Shop_Level__c = '';
            }
        }
    }

    // 保存
    handleSave(){
        this.saveShop(false);
    }
    // save & new
    handleSaveAndNew(){
        this.saveShop(true);
    }
    //
    saveShop(flag){
        this.isShowSpinner = true;
        if (this.validation()) {
            saveShop({
                recordJson : JSON.stringify(this.record),
            }).then(result => {
                if (result.isSuccess) {
                    this.showSuccess('Save Success!');
                    this.clearRecord();
                    if(flag){
                        this.isModalOpen = false;
                        setTimeout(() => {
                            this.isModalOpen = true;
                        }, 500);
                    }else {
                        this.isModalOpen = false;
                    }
                    // 给vfpage map传递信息
                    if (!this.vfIframe) return;
                    const message = {
                        action: 'triggerVFMethod',
                        data: { address: this.record['Address1__c'] }
                    };
                    // 发送消息到 VF 页面（替换为你的 Salesforce 域名）
                    this.vfIframe.contentWindow.postMessage(
                        message,
                        '*'
                    );
                }else{
                    this.showError('Save Failure!');
                }
                this.isShowSpinner = false;
            }).catch(error => {
                this.showError('Save Failure!' + JSON.stringify(error));
                this.isShowSpinner = false;
            });
        }else {
            this.isShowSpinner = false;
        }
    }

    validation() {
        let allValid = true; 
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if(!element.reportValidity()){
                allValid = false;
            }
        });
        return allValid;
    } 
    
    handleBack(){
        this.isBack = true;
        this.dispatchEvent(new CustomEvent('goback'));
        this.dispatchEvent(new CustomEvent('refreshdata'));
    }
}