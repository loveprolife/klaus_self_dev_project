/*
 * @Author: YYL
 * @LastEditors: YYL
 */
import { wire, track, api } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInit from '@salesforce/apex/NewStoreMapSubmitController.getInit';
import actionRecord from '@salesforce/apex/NewStoreMapSubmitController.actionRecord';
import getStoreId from '@salesforce/apex/Lookup.getStoreId';
import { generateDeviceId } from 'c/deviceUtils';

export default class NewStoreMapSubmitLwc extends LightningNavigationElement {




    @track isShowSpinner = false; // 加载中
    get spinnerStyle() {
        if (this.documentHeight && this.isMobile) {
            return 'height:' + this.documentHeight + 'px;';
        } else {
            return 'height:100%';
        }
    }


    @track currentLat = 0; // 当前坐标 Lat
    @track currentLong = 0; // 当前坐标 Long

    @track shopId = '';
    @track userId = '';
    @track Email = '';
    @track shopName = '';
    @track userName = '';
    readly = false;
    // 初始化
    connectedCallback() {
        this.isShowSpinner = true;
        //this.getCurrentPosition(this.getInitInfo);
        this.getInitInfo();
    }
    renderedCallback() {
        //code
        this.isShowSpinner = false;

    }
    async subUserChange(event) {

        console.log(JSON.stringify(event.detail.selectedRecord));
        if (!this.stringIsEmpty(event.detail.selectedRecord)) {
            this.isShowSpinner = true;
            this.userId = event.detail.selectedRecord.Id;
            this.Email = event.detail.selectedRecord.Email__c;
            if (!this.stringIsEmpty(this.userId)) {
                let obj = await getStoreId({ subUserId: this.userId });
                if (!this.stringIsEmpty(obj.storeId)) {
                    this.shopId = obj.storeId;
                    this.shopName = obj.storeName;

                }

            }
            this.isShowSpinner = false;
        } else {
            this.userId = '';
            this.Email = '';
            this.shopId = '';
            this.shopName = '';
        }
    }

    getInitInfo() {
        this.isShowSpinner = true;
        getInit({
            userId: this.userId,
            deviceId: generateDeviceId()
        }).then(data => {
            let storeInfo = data.data.shopInfo;
            let userInfo = data.data.userInfo;
            console.log('storeInfo: ' + JSON.stringify(storeInfo));
            console.log('userInfo: ' + JSON.stringify(userInfo));

            // Check if storeInfo exists (not an array)
            if (storeInfo) {
                // Check if userInfo exists and is an array with data
                if (userInfo && userInfo.length > 0) {
                    let firstUser = userInfo[0]; // 获取第一个 user
                    console.log('firstUser:', JSON.stringify(firstUser)); // Debug: Output firstUser content

                    this.userId = firstUser.Id || '';
                    this.userName = firstUser.Name || '';
                    this.Email = firstUser.Email__c || '';

                    // Ensure that the data has been assigned before logging
                    console.log('this.userId:', this.userId); // Debug output for userId
                    console.log('this.Email:', this.Email); // Debug output for Email
                }
                this.shopId = storeInfo.Id || '';
                this.shopName = storeInfo.Name || '';
                this.readly = this.stringIsEmpty(this.userId) ? false : true;
            }

            this.isShowSpinner = false;
        }).catch(error => {
            console.log('Error:', JSON.stringify(error));
            this.isShowSpinner = false;
        });
    }
    edit() {
        this.readly = false;

    }

    handleSubmit() {
            // 确保 shopId 和 userId 不为空
            if (!this.shopId || !this.userId) {
                this.ShowToast('Shop and User must be provided!', 'error');
                return;
            }
            this.isShowSpinner = true;
            // 生成唯一设备 ID
            this.deviceId = generateDeviceId();

            console.log('deviceId:', this.deviceId);

            actionRecord({
                userId: this.userId,
                shopId: this.shopId,
                actionDetails: 'Submit',
                deviceInfo: this.deviceId // 传递设备信息
            }).then(data => {
                if (data.isSuccess) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!',
                            message: 'Submit Successfully! ',
                            variant: 'success'
                        }),
                    );
                    this.getInitInfo();
                } else {
                    this.showError(data.message);
                }
                this.isShowSpinner = false;
            }).catch(error => {
                this.showError(error.body.message);
                this.isShowSpinner = false;
            });
        }
        /*
         * method: Toast 提示
         * author:Collin
         * DateTime : 2022-10-19
         */
    ShowToast(message, variant) {
            const evt = new ShowToastEvent({
                message: message,
                variant: variant,
            });
            this.dispatchEvent(evt);
        }
        /*
         * method: 判断是否为空
         * author:Collin
         * DateTime : 2022-8-19
         */
    stringIsEmpty(str) {
        if (str != '' && str != undefined && str != null) {
            return false;
        } else {
            return true;
        }
    }
}