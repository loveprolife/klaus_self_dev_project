import { track, api, wire } from 'lwc';

import { LightningNavigationElement } from 'c/lwcUtils';
import LightningModal from 'lightning/modal';

import PromoterDailyReport_ATTACHMENT from '@salesforce/label/c.PromoterDailyReport_ATTACHMENT';
import PromoterDailyReport_RequiredCheck from '@salesforce/label/c.PromoterDailyReport_RequiredCheck';
import Ticket_Fields_Check from '@salesforce/label/c.Ticket_Fields_Check';
import Ticket_Error_Assigned from '@salesforce/label/c.Ticket_Error_Assigned';
import INSPECTION_REPORT_MSG_DEPARTMENT_USER from '@salesforce/label/c.INSPECTION_REPORT_MSG_DEPARTMENT_USER';
import userId from '@salesforce/user/Id'; // 导入当前用户 ID
import newTicketGetInitData from '@salesforce/apex/NewTicketsController2.newTicketGetInitData';
import newTicketSaveData from '@salesforce/apex/NewTicketsController2.newTicketSaveData';
import handlerRemove from '@salesforce/apex/NewTicketsController2.handlerRemove';
import getDepartmentUsers from '@salesforce/apex/NewTicketsController2.getDepartmentUsers';
import getNearestStore from '@salesforce/apex/Utility.getNearestStore';
import Ticket_ReSelect_Department from '@salesforce/label/c.Ticket_ReSelect_Department';
export default class NewTicketButtonLwc extends LightningNavigationElement {
    currentUserId = userId; // 将用户 ID 保存到属性中
    // @track ticket = {
    //     Subject__c: null,
    //     Description__c: null,
    //     DueDate__c: null,
    //     Department__c: null,
    //     AssignedTo__c: null,
    //     index: 0
    // };

    @track ticket = {
        index: 0
    };

    @track isShowDepartment = true;
    @track isShowSpinner = false;
    @track isShowProduct = false;
    @track isShowProductSearch = false;
    @track isSouthAfrica = false;
    @track isArgentina = false;
    @track departmentUres = [];
    @track currentLat = 0; // 当前坐标 Lat
    @track currentLong = 0; // 当前坐标 Long
    @track fields = {};
    regisValue = 'Department';

    @track selectedItemsToDisplay = ''; //to display items in comma-delimited way
    @track userIds = []; //stores the labels in this array
    @track isItemExists = false; //flag to check if message can be displayed
    get regis() {
        return [
            { label: 'Department', value: 'Department' },
            { label: 'User', value: 'User' },
        ];
    }
    fileMap = {};
    label = { PromoterDailyReport_ATTACHMENT, INSPECTION_REPORT_MSG_DEPARTMENT_USER };
    handleRegisChange(event) {
            this.regisValue = event.target.value;
            this.isShowDepartment = this.regisValue == 'Department' ? true : false;
            this.userIds = [];

            this.departmentUres = [];
            this.ticket.Department__c = '';
        }
        // 获取当前位置并调用 Apex 方法
    initNearestStore() {
        // 使用浏览器 Geolocation API 获取当前位置
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    const { latitude, longitude } = position.coords;
                    console.log('Clatitude', latitude);
                    console.log('longitude', longitude);
                    // 调用 Apex 方法
                    getNearestStore({ currentLat: latitude.toString(), currentLong: longitude.toString() })
                        .then((result) => {
                            console.log('result:', result); // 门店 ID
                            this.ticket.Store__c = result;
                            this.error = null;
                        })
                        .catch((error) => {
                            console.log(error);
                            console.log(error.body.message);
                            this.error = error.body.message;
                            this.ticket.Store__c = null;
                        });
                },
                (error) => {
                    console.log(error.message);
                    this.error = '无法获取地理位置：' + error.message;
                }
            );
        } else {
            this.error = '浏览器不支持地理位置功能。';
        }
    }

    connectedCallback() {
        console.log('Current User ID:', this.currentUserId); // 输出用户 ID
        this.isShowSpinner = true;
        this.initNearestStore();
        newTicketGetInitData(

        ).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    this[key] = data.data[key];
                }
                // this.isShowDepartment = (data.data.userRegion == 'Hisense Chile') || (data.data.userRegion == 'Hisense South Africa');
                this.isSouthAfrica = data.data.userRegion == 'Hisense South Africa';
                this.isArgentina = data.data.userRegion == 'Hisense Argentina';
                console.log('isShowDepartment：' + this.isShowDepartment);
            } else {
                this.showError(data.message);
            }
        }).catch(error => {
            this.catchError(error);
        })
        this.isShowSpinner = false;
    }

    //captures the retrieve event propagated from lookup component
    selectItemEventHandler(event) {
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayItem(args);
    }

    //captures the remove event propagated from lookup component
    deleteItemEventHandler(event) {
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayItem(args);
    }

    //displays the items in comma-delimited way
    displayItem(args) {
        console.log('args', JSON.stringify(args));
        this.userIds = []; //initialize first
        args.map(element => {
            this.userIds.push(element.value);
        });

        this.isItemExists = (args.length > 0);
        this.selectedItemsToDisplay = this.userIds.join(',');
        console.log("this.userIds", JSON.stringify(this.userIds));
    }

    cancelHandleClick(event) {
        this.goToObject('Ticket__c');
    }
    removeRecord(event) {
        let index = event.target.name;
        this.departmentUres.splice(index, 1);
        this.userIds = []; //initialize first
        this.departmentUres.forEach(element => {
            this.userIds.push(element.Id);
        });

    }
    saveHandleClick(event) {
        this.isShowSpinner = true;
        let result = this.saveCheck();
        if (result.flag) {

            // 设置is_Update__c默认为true 20241203 YYL
            this.ticket.is_Update__c = true;


            let recordList = [];
            recordList.push(this.ticket);
            newTicketSaveData({
                recordListJson: JSON.stringify(recordList),
                fileMapJson: JSON.stringify(this.fileMap),
            }).then(resp => {
                if (resp.isSuccess) {
                    this.goToRecord(resp.data.ticketId);
                } else {
                    this.showError(resp.message);
                }
            }).catch(error => {
                this.catchError(error);
            })
        } else {
            this.showError(result.message);
            this.isShowSpinner = false;
        }

        this.isShowSpinner = false;
    }
    handleFieldChange(event) {
        console.log('handleFieldChange ——> target value: ' + event.target.value);
        this.ticket[event.target.dataset.fieldName] = event.target.value;
        if ((this.ticket[event.target.dataset.fieldName]).length == 0) {
            return;
        }
        //传入后台查询部门下的人
        getDepartmentUsers({ 'department': this.ticket[event.target.dataset.fieldName] })
            .then(result => {
                console.log(result);
                this.departmentUres = JSON.parse(JSON.stringify(result));
                this.userIds = []; //initialize first
                this.departmentUres.map(element => {
                    this.userIds.push(element.Id);
                });
            })
            .catch((error) => {
                console.error("Error in setPSIImportTemplate:", error);
            });
    }
    handleFieldChange1111(event) {
        console.log('handleFieldChange ——> target value: ' + event.target.value);
        this.ticket[event.target.dataset.fieldName] = event.target.value;

        // 新增判断是否可以修改store__c字段 20241129 YYL
        // this.ticket["is_Update__c"] = true;
        console.log('wwwwhandleFieldChange' + JSON.stringify(this.ticket));

        this.ticket.isUpdated = true;

        if (event.target.dataset.fieldName == 'Department__c') {
            this.updateLookup('userLookup');
            this.removeLookup('userLookup');
        }

        if (event.target.dataset.fieldName == 'Category__c') {
            console.log(this.ticket[event.target.dataset.fieldName]);
            if (this.isSouthAfrica) {
                if (!this.isFilledOut(this.ticket[event.target.dataset.fieldName]) || this.ticket[event.target.dataset.fieldName] == 'Service') {
                    this.isShowProduct = false;
                    this.isShowProductSearch = false;
                    this.ticket.Product__c = '';
                } else {
                    this.isShowProduct = true;
                    this.isShowProductSearch = true;
                }
            } else {
                if (!this.isFilledOut(this.ticket[event.target.dataset.fieldName]) || this.ticket[event.target.dataset.fieldName] == 'Service') {
                    this.isShowProduct = true;
                    this.isShowProductSearch = true;
                    this.ticket.Product__c = '';
                } else {
                    this.isShowProduct = false;
                    this.isShowProductSearch = false;
                }
            }
        }
    }

    lookUpChangeHandler(event) {
        let targetName = event.target.dataset.fieldName;
        console.log('lookUpChangeHandler ——> targetName: ' + targetName);

        if (event.detail.selectedRecord == undefined) {
            this.ticket[targetName] = null;
        } else {
            this.ticket[targetName] = event.detail.selectedRecord.Id;
        }
        this.ticket.isUpdated = true;
    }

    updateLookup(name) {
        var cmps = this.template.querySelectorAll('c-lookup-lwc');
        for (let i = 0; i < cmps.length; i++) {
            var lookup = cmps[i];
            if (lookup.name == name) {
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.DepartmentUserFilter',
                    'department': this.ticket.Department__c
                });
                return;
            }
        }
    }

    removeLookup(name) {
        var cmps = this.template.querySelectorAll('c-lookup-lwc');
        for (let i = 0; i < cmps.length; i++) {
            var lookup = cmps[i];
            if (lookup.name == name) {
                lookup.handleRemove();
                return;
            }
        }
    }

    lookupUserFilter = {
        'lookup': 'CustomLookupProvider.UserFilter'
    }

    handleKeyDown(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
        }
    }


    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        alert('No. of files uploaded : ' + uploadedFiles.length);
    }

    handleSelectFiles(event) {
        this.fileMap[event.target.dataset.index] = event.detail.records;
    }

    openUpload(event) {
        this.template.querySelector('c-upload-files3-lwc').openUpload();
    }

    saveCheck() {
        let result = {
            flag: true,
            message: '',
        }

        if (!this.isFilledOut(this.ticket.Subject__c)) {
            result.flag = false;
            result.message = PromoterDailyReport_RequiredCheck + ' ' + this.fields.Subject__c;
            return result;
        }
        if (!this.isFilledOut(this.ticket.Description__c)) {
            result.flag = false;
            result.message = PromoterDailyReport_RequiredCheck + ' ' + this.fields.Description__c;
            return result;
        }
        if (!this.isFilledOut(this.ticket.Status__c)) {
            result.flag = false;
            result.message = PromoterDailyReport_RequiredCheck + ' ' + this.fields.Status__c;
            return result;
        }
        if (!this.isFilledOut(this.ticket.Priority__c)) {
            result.flag = false;
            result.message = PromoterDailyReport_RequiredCheck + ' ' + this.fields.Priority__c;
            return result;
        }
        if (!this.isFilledOut(this.ticket.Category__c)) {
            result.flag = false;
            result.message = PromoterDailyReport_RequiredCheck + ' ' + this.fields.Category__c;
            return result;
        }
        // if (this.isFilledOut(this.ticket.Category__c) && this.isSouthAfrica && this.ticket.Category__c != 'Service') {
        //     if (!this.isFilledOut(this.ticket.Product__c)) {
        //         result.flag = false;
        //         result.message = PromoterDailyReport_RequiredCheck + ' ' + this.fields.Product__c;
        //         return result;
        //     }
        // }
        if (!this.isFilledOut(this.ticket.DueDate__c)) {
            result.flag = false;
            result.message = PromoterDailyReport_RequiredCheck + ' ' + this.fields.DueDate__c;
            return result;
        }

        console.log('userIds=>' + this.userIds);
        if (this.userIds.length > 0) {
            this.ticket.Aassigners__c = this.userIds.join(','); // 将数组元素用逗号分隔
            console.log('hbdhc=>' + this.ticket.Aassigners__c);
        } else {
            result.flag = false;
            result.message = Ticket_ReSelect_Department;

            return result;
        }

        // if (this.isFilledOut(this.ticket.Department__c) && this.isFilledOut(this.ticket.AssignedTo__c)) {
        //     let userMatch = false;
        //     console.log('Department User List: ' + this[this.ticket.Department__c]);
        //     for (let index = 0; index < this[this.ticket.Department__c].length; index++ ) {
        //         console.log('this[this.ticket.Department__c][index]: ' + this[this.ticket.Department__c][index]);
        //         if (this[this.ticket.Department__c][index] == this.ticket.AssignedTo__c) {
        //             userMatch = true;
        //         }
        //     }
        //     if (!userMatch) {
        //         result.flag = false;
        //         result.message = Ticket_Error_Assigned;
        //         return result;
        //     }
        // }

        return result;
    }

    isFilledOut(content) {
        if (typeof content == "undefined") {
            return false;
        } else if (content == '' || content == null) {
            return false;
        } else if (typeof content == "number") {
            return !isNaN(content);
        }
        return true;
    }

    // 添加产品（自定义lookupFilter）
    lookupFilter = {
        'lookup': 'CustomLookupProvider.ProductAllFilter'
    }
    deleteProductValue(event) {
            if (this.isFilledOut(this.ticket.Product__c)) {
                if (this.ticket.Product__c.lastIndexOf(',') != -1) {
                    this.ticket.Product__c = this.ticket.Product__c.substr(0, this.ticket.Product__c.lastIndexOf(','));
                    if (!this.isSouthAfrica) {
                        this.isShowProductSearch = false;
                    } else {
                        this.isShowProductSearch = true;
                    }
                } else {
                    this.ticket.Product__c = '';
                    this.isShowProductSearch = true;
                }
            }
        }
        // 选择产品变更
    handleChangeProductOption(resp) {
        if (resp.detail.selectedRecord == undefined) {
            return;
        }

        handlerRemove({

        }).then(data => {
            if (data.isSuccess) {
                this.removeLookup('onProduct');
            } else {}
        }).catch(error => {
            this.catchError(error);
        })

        if (this.ticket.Product__c && this.ticket.Product__c != '') {
            if (this.ticket.Product__c.indexOf(resp.detail.selectedRecord.Name) == -1) {
                this.ticket.Product__c = this.ticket.Product__c + ',' + resp.detail.selectedRecord.Name;
                if (!this.isSouthAfrica) {
                    this.isShowProductSearch = false;
                } else {
                    this.isShowProductSearch = true;
                }
            }
        } else {
            this.ticket.Product__c = resp.detail.selectedRecord.Name;
            if (!this.isSouthAfrica) {
                this.isShowProductSearch = false;
            } else {
                this.isShowProductSearch = true;
            }
        }
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