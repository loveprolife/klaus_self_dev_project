import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import { updateRecord } from "lightning/uiRecordApi";
import { createRecord } from "lightning/uiRecordApi";
import { deleteRecord } from "lightning/uiRecordApi";
import { LightningNavigationElement } from 'c/lwcUtils';

import { refreshApex } from "@salesforce/apex";

import selExhibitionArrangementId from '@salesforce/apex/ExhibitionArrangementWithoutController.selExhibitionArrangementId';
import saveExhibitionArrangement from '@salesforce/apex/ExhibitionArrangementWithoutController.saveExhibitionArrangement';
import getExhibionVeBooking from '@salesforce/apex/ExhibitionArrangementWithoutController.getExhibionVeBooking';
import getExhibionVeBookingNotArranged from '@salesforce/apex/ExhibitionArrangementWithoutController.getExhibionVeBookingNotArranged';
import getInitData from '@salesforce/apex/ExhibitionArrangementWithoutController.getInitData';
import createdRecord from '@salesforce/apex/ExhibitionArrangementWithoutController.createdRecord';
import delRecord from '@salesforce/apex/ExhibitionArrangementWithoutController.delRecord';
import upsertRecords from '@salesforce/apex/ExhibitionArrangementWithoutController.upsertRecords';
import delVehicalBookingExpectArranged from '@salesforce/apex/ExhibitionArrangementWithoutController.delVehicalBookingExpectArranged';
import CAR_TYPE from '@salesforce/schema/Exhibition_Vehical_Booking__c.Vehicle_Type__c';
import CAR_DATE from '@salesforce/schema/Exhibition_Vehical_Booking__c.Date__c';
import ARRANGEMENT from '@salesforce/schema/Exhibition_Vehical_Booking__c.Exhibition_Arrangement__c';
import INTERMAL_REGISTRATION from '@salesforce/schema/Exhibition_Vehical_Booking__c.Internal_Registration__c';
import PLATE_NUMBER from '@salesforce/schema/Exhibition_Vehical_Booking__c.Plate_Number__c';
import PICKUP_POINT from '@salesforce/schema/Exhibition_Vehical_Booking__c.Pick_Up_Point__c';
import IS_ARRANGED from '@salesforce/schema/Exhibition_Vehical_Booking__c.Is_Arranged__c';
// import DEPATRURE_TIME from '@salesforce/schema/Exhibition_Vehical_Booking__c.Departure_Time__c';
import DEPATRURE_TIME from '@salesforce/schema/Exhibition_Vehical_Booking__c.Departure_Time_Invsion__c';

import VEHICAL_DRIVER from '@salesforce/schema/Exhibition_Vehical_Booking__c.Vehical_Driver__c';
import OBJECT_API_NAME from '@salesforce/schema/Exhibition_Vehical_Booking__c';

const ACTIONS = [
    { label: '删除', name: 'delete' },
    { label: '编辑', name: 'edit' }
];

const COLS = [
    { label: "操作", type: 'action', typeAttributes: { rowActions: ACTIONS, menuAlignment: 'left' } },
    {
        label: "车辆类型", fieldName: CAR_TYPE.fieldApiName, editable: false,
        type: 'picklist', typeAttributes: {
            options: [
                { label: '大巴', value: '大巴' },
                { label: '布展小巴', value: '布展小巴' },
                { label: '小车(仅限领导使用)', value: '小车(仅限领导使用)' }], placeholder: 'Select an option'
        }
    },
    {
        label: "用车时间", fieldName: CAR_DATE.fieldApiName, editable: false, type: "date-local",
        typeAttributes: {
            month: "2-digit",
            day: "2-digit"
        },
    },
    { label: "司机", fieldName: VEHICAL_DRIVER.fieldApiName, editable: false, type: 'text', typeAttributes: {} },
    { label: "车牌号", fieldName: PLATE_NUMBER.fieldApiName, editable: false, type: 'text', typeAttributes: {} },
    { label: "上车地点", fieldName: PICKUP_POINT.fieldApiName, editable: false, },
    { label: "发车时间", fieldName: DEPATRURE_TIME.fieldApiName, editable: false, type: 'text', typeAttributes: {} },

    // { label: "是否已安排", fieldName: IS_ARRANGED.fieldApiName, editable: false, },
    // { label: "发车时间", fieldName: DEPATRURE_TIME.fieldApiName, editable: false,
    // type: "date",
    //       typeAttributes:{
    //           hour: "2-digit",
    //           minute: "2-digit",
    //           hour12: false,
    //           timeZone:'Asia/Shanghai'
    //       } }


];


export default class exhibitionArrangementWithoutLWC extends LightningNavigationElement {
    CAR_TYPE = CAR_TYPE; CAR_DATE = CAR_DATE;
    @track columns = [];
    // get columns() {
    //     let arr = [];
    //     if (!this.isOverLastRegistrationDate) {
    //         arr.push({ label: "操作", type: 'action', typeAttributes: { rowActions: ACTIONS, menuAlignment: 'left' } });
    //     }
    //     console.log('isOverLastRegistrationDate: ' + this.isOverLastRegistrationDate);
    //     console.log('get columns: ' + JSON.stringify(arr));

    //     arr = [arr, ...COLS];
    //     console.log('get columns: ' + JSON.stringify(arr));
    //     return arr;
    // }
    objectApiName = 'Exhibition_Vehical_Booking__c';

    // OBJECT_API_NAME = 'Exhibition_Vehical_Booking__c';

    @api recordId;

    @track nameVal = '';
    @track emailVal = '';
    // @track exhibitionNameVal = '';
    @track titleMsg = '行程信息';

    @track isShowSpinner = false;

    @track errorMsgArray = '';
    @track hasError = false;
    @track isEditShow = false;

    @track exhibitionName = '';

    @track Id = '';
    @track Inbound_Flight_No__c = '';
    @track Return_Flight_No__c = '';
    @track Arrival_Date__c = '';
    @track Return_Date__c = '';
    @track Hotel_Name__c = null;
    @track Hotel_Start_Date__c = null;
    @track Hotel_End_Date__c = null;

    @track options;
    @track Designated_Hotel__c;//无需酒店
    @track Is_Not_Flight__c;//无需航班
    @track Is_Not_Need_Vehicle__c;//无需车辆

    @track carDate;
    @track carType;
    @track internalRegistrationId;

    @track datas = [];
    @track datas_not = [];
    @track draftValues = [];
    @track deleteRows = [];
    @track recordsCount = 0;
    @track isDeleteButtonDisabled = true;
    @track isBookError = false;
    @track errorBook = '';
    @track isRowEditable = {};
    @track delRow = [];
    @track isOverLastRegistrationDate = true;
    @track initHotelName = '';

    @track recordInfo = {};
    @track presenceOptions = [];


    connectedCallback() {
        console.log('connectedCallback================');
        this.caroptions = [{ "label": "", "value": "" }, { "label": "大巴", "value": "大巴" }, { "label": "布展小巴", "value": "布展小巴" }, { "label": "小车(仅限领导使用)", "value": "小车(仅限领导使用)" }];
        if (this.recordId == 'null' || this.recordId == undefined || this.recordId == '') {
            this.errorMsgArray = '系统错误: ' + "未分配到行程信息！";
            return;
        }
    }

    changeData(event) {
        let name = event.target.name;
        let value = event.target.value;
        let parm = event.target;
        // console.log('-----'+parm+JSON.stringify(parm));
        console.log('name' + name);
        console.log('value' + value);
        if (name == 'userName') {
            this.nameVal = value;
        }
        if (name == 'userEmail') {
            this.emailVal = value;
        }
        if (name == 'exhibitionName') {
            this.exhibitionNoVal = value;
        }


        if (name == 'InboundNo') {
            this.Inbound_Flight_No__c = value;
        }
        if (name == 'ReturnNo') {
            this.Return_Flight_No__c = value;
        }
        if (name == 'InboundDate') {
            this.Arrival_Date__c = value;
        }
        if (name == 'ReturnDate') {
            this.Return_Date__c = value;
        }
        if (name == 'HotelName') {
            this.Hotel_Name__c = value;
        }
        if (name == 'HotelStart') {
            this.Hotel_Start_Date__c = value;
        }
        if (name == 'HotelEnd') {
            this.Hotel_End_Date__c = value;
        }
        if (name == 'Designated_Hotel__c') {
            this.Designated_Hotel__c = event.target.checked;
        }
        if (name == 'Is_Not_Flight__c') {
            this.Is_Not_Flight__c = event.target.checked;
        }
        if (name == 'Is_Not_Need_Vehicle__c') {
            this.Is_Not_Need_Vehicle__c = event.target.checked;
            // if (this.Is_Not_Need_Vehicle__c) this.handleIsNotNeedVehicle();
        }



    }

    handleIsNotNeedVehicle() {
        // alert('未安排的车辆信息将会被清空！');
        this.isShowSpinner = true;
        console.log(this.Id + '  ' + this.internalRegistrationId)
        delVehicalBookingExpectArranged({
            exhibitionArrangementId: this.Id,
            internalRegistrationId: this.internalRegistrationId
        }).then(res => {
            if (res.isSuccess) {
                console.log('车辆信息已清理=====');
                this.getVeBooks();
            } else {
                console.log('发生错误：' + res.message);
            }
            this.isShowSpinner = false;
        }).catch(error => {
            this.isShowSpinner = false;
            this.hasError = true;
            this.errorMsgArray = '系统错误：' + JSON.stringify(error);
        })
    }

    selExhibitionArr(event) {
        this.isShowSpinner = true;
        if (this.nameVal != '' & this.emailVal != '' & this.exhibitionNoVal != '') {
            selExhibitionArrangementId({
                name: this.nameVal,
                email: this.emailVal,
                exhibitionArrId: this.recordId,
            }).then(result => {
                console.log('result:' + JSON.stringify(result));
                if (result.isSuccess) {
                    for (let key in result.data) {
                        this[key] = result.data[key];
                    }

                    this.isShowSpinner = false;
                    this.Id = result.data.exhibitionArrangementId;
                    this.exhibitionName = result.data.exhibitionName;
                    this.internalRegistrationId = result.data.internalRegistrationId;
                    console.log("internalRegistrationId-->" + this.internalRegistrationId);
                    this.isEditShow = true;
                    this.hasError = false;

                    // getInitData 参数赋值
                    this.getPresenceOptions();
                    console.log('getInitData ---> recordInfo : ' + JSON.stringify(this.recordInfo));

                    this.options = result.data.options;

                    if (this.options.length > 0 && !this.isFilledOut(this.recordInfo.Exhibition_Hotel__c)) {
                        this.recordInfo.Exhibition_Hotel__c = this.options[0].value;
                    }
                    this.isOverLastRegistrationDate = result.data.isOverLastRegistrationDate;
                    if (this.isOverLastRegistrationDate) {
                        alert('已过展会报名截止日期，无法再次进行填写！');
                        COLS.splice(0, 1);
                    }

                    this.columns = COLS;
                    // this.isOverLastRegistrationDate = true;
                    console.log('columns : ' + JSON.stringify(this.columns));
                    console.log('isOverLastRegistrationDate : ' + this.isOverLastRegistrationDate);

                    // 车辆信息
                    for (let i = 0; i < this.datas.length; i++) {
                        if (this.datas[i].Is_Arranged__c) {
                            this.isRowEditable[this.datas[i].Id] = false;
                        } else {
                            this.isRowEditable[this.datas[i].Id] = true;
                        }
                    }
                } else {
                    this.isShowSpinner = false;
                    this.hasError = true;
                    this.errorMsgArray = result.message;
                }
            }).catch(error => {
                this.isShowSpinner = false;
                this.hasError = true;
                this.errorMsgArray = '系统错误：' + JSON.stringify(error);
            });

            //参数赋值
            // getInitData({ recordId: this.recordId }).then(resp => {
            //     if (resp.isSuccess) {

            //         for (let key in resp.data) {
            //             this[key] = resp.data[key];
            //         }
            //         this.getPresenceOptions();
            //         console.log('getInitData ---> recordInfo : ' + JSON.stringify(this.recordInfo));

            //         this.options = resp.data.options;

            //         if (this.options.length > 0 && !this.isFilledOut(this.recordInfo.Exhibition_Hotel__c)) {
            //             this.recordInfo.Exhibition_Hotel__c = this.options[0].value;
            //         }

            //         // this.Designated_Hotel__c = resp.data.isDesignated;
            //         // console.log('是否自定酒店' + this.Designated_Hotel__c);
            //         // this.Is_Not_Flight__c = resp.data.isNotFlight;
            //         // this.Is_Not_Need_Vehicle__c = resp.data.isNotNeedVehicle;
            //         // this.Inbound_Flight_No__c = resp.data.Inbound_Flight_No__c;
            //         // this.Return_Flight_No__c = resp.data.Return_Flight_No__c;
            //         // this.Arrival_Date__c = resp.data.Arrival_Date__c;
            //         // this.Return_Date__c = resp.data.Return_Date__c;
            //         // this.Hotel_Start_Date__c = resp.data.Hotel_Start_Date__c;
            //         // this.Hotel_End_Date__c = resp.data.Hotel_End_Date__c;
            //         // this.initHotelName = resp.data.Hotel_Name__c;
            //         // this.Hotel_Name__c = resp.data.Exhibition_Hotel__c;
            //         // console.log('酒店初始值==》' + this.initHotelName + this.Hotel_Name__c);
            //         // console.log('是否航班，是否车辆====' + this.Is_Not_Flight__c + this.Is_Not_Need_Vehicle__c);
            //         this.isOverLastRegistrationDate = resp.data.isOverLastRegistrationDate;
            //         if (this.isOverLastRegistrationDate) {
            //             alert('已过展会报名截止日期，无法再次进行填写！');
            //             COLS.splice(0, 1);
            //         }

            //         this.columns = COLS;
            //         // this.isOverLastRegistrationDate = true;
            //         console.log('columns : ' + JSON.stringify(this.columns));
            //         console.log('isOverLastRegistrationDate : ' + this.isOverLastRegistrationDate);

            //         // 车辆信息
            //         for (let i = 0; i < this.datas.length; i++) {
            //             if (this.datas[i].Is_Arranged__c) {
            //                 this.isRowEditable[this.datas[i].Id] = false;
            //             } else {
            //                 this.isRowEditable[this.datas[i].Id] = true;
            //             }
            //         }
            //     } else {
            //         // this.HandlerShowToast('Error', '系统错误！'+resp.message, 'error');
            //         this.showError('系统错误！' + resp.message);
            //     }
            // }).catch(error => {
            //     this.showError('Error', '系统错误！' + JSON.stringify(error), 'error');
            //     // this.catchError('系统错误！'+resp.message);
            // })

            //车辆信息查询
            // setTimeout(() => {
            //     this.getVeBooks();
            // }, 3000);

        } else {
            this.isShowSpinner = false;
            this.hasError = true;
            this.showError('登录参数必须填写！');
            this.errorMsgArray = '登录参数必须填写！';

        }

    }

    saveExhibitionArr(event) {
        this.isShowSpinner = true;

        if (this.isFilledOut(this.recordInfo.Id)
            & (this.recordInfo.Is_Not_Flight__c || (this.isFilledOut(this.recordInfo.Return_Flight_No__c) & this.isFilledOut(this.recordInfo.Arrival_Date__c) & this.isFilledOut(this.recordInfo.Return_Date__c)))
            & (this.recordInfo.Designated_Hotel__c || (this.isFilledOut(this.recordInfo.Exhibition_Hotel__c) & this.isFilledOut(this.recordInfo.Hotel_Start_Date__c) & this.isFilledOut(this.recordInfo.Hotel_End_Date__c)))
        ) {
            if (this.recordInfo.Designated_Hotel__c) {
                this.recordInfo.Hotel_Name__c = null;
                this.recordInfo.Hotel_Start_Date__c = null;
                this.recordInfo.Hotel_End_Date__c = null;

                this.recordInfo.Exhibition_Hotel__c = null;
            }
            if (this.recordInfo.Is_Not_Flight__c) {
                this.recordInfo.Inbound_Flight_No__c = null;
                this.recordInfo.Return_Flight_No__c = null;
                this.recordInfo.Arrival_Date__c = null;
                this.recordInfo.Return_Date__c = null;
            }

            this.recordInfo.PresenceDate__c = new String(this.recordInfo.PresenceDate__c);
            console.log('recordInfo :' + JSON.stringify(this.recordInfo));

            if (this.recordInfo.Is_Not_Need_Vehicle__c) {
                this.handleIsNotNeedVehicle();
            }

            saveExhibitionArrangement({
                jsonStr: JSON.stringify(this.recordInfo),
            }).then(result => {
                console.log('result:' + JSON.stringify(result));
                if (result.isSuccess) {
                    // this.isShowSpinner = false;
                    // this.isEditShow = false;
                    this.hasError = false;
                    alert('保存成功！');
                    setTimeout(() => {
                        this.isShowSpinner = false;
                    }, 1000);

                    // window.location.reload();
                } else {
                    this.isShowSpinner = false;
                    this.hasError = true;
                    this.errorMsgArray = result.message;
                }
            }).catch(error => {
                this.isShowSpinner = false;
                this.hasError = true;
                this.errorMsgArray = '系统错误：' + JSON.stringify(error);
            });

        } else {
            this.isShowSpinner = false;
            this.hasError = true;
            this.errorMsgArray = '登录参数必须填写！';
            alert('请完成必填信息!')
        }

    }

    //创建
    handleCreatedRecordByOne() {
        this.isBookError = false;
        if (this.carType == '' || this.carDate == '' || this.carType == null || this.carDate == null || this.carType == undefined || this.carDate == undefined) {
            this.isBookError = true;
            this.errorBook = '车辆类型和用车时间必填！';
            return;
        }
        let currentDate = new Date();
        console.log('==========' + currentDate + '========' + this.carDate);
        if (this.carDate < currentDate) {
            this.isBookError = true;
            this.errorBook = '用车时间不小于当前时间！';
            return;
        }
        console.log(this.internalRegistrationId + ' ' + this.recordId + ' ' + this.carType + ' ' + this.carDate);
        createdRecord({ intId: this.internalRegistrationId, arrId: this.recordId, carType: this.carType, carDate: this.carDate }).then(res => {
            if (res.isSuccess) {
                alert('操作成功！\n 实际发车与否将根据最终乘车人数决定，人数必须达到最低人数要求，请留意后续安排信息。');
                console.log('只要创建就会统计delrow==>' + this.delRow);
                if (this.delRow != undefined && this.delRow != []) {
                    delRecord({ bookIdList: this.delRow }).then(res => { console.log("更新===》先删除！"); }).catch(error => { console.log("更新，系统异常！" + JSON.stringify(error)) });
                }
            }
            else {
                alert('操作失败!' + res.message);
            }
        }).catch(message => {
            alert('系统错误：' + JSON.stringify(message));
            console.log('message==>' + message + JSON.stringify(message));
        })



        setTimeout(() => {
            this.getVeBooks();
        }, 1000);

    }
    // modelOK方法
    handleOk() {
        this.handleCreatedRecordByOne();
        setTimeout(() => {
            this.carType = null;
            this.carDate = null;
            this.template.querySelector('c-modal-lwc').closeModal();
        }, 1000);

    }

    //增加按钮触发model
    addOne() {
        this.template.querySelector('c-modal-lwc').showModal();
    }
    // Action 响应
    handleRowAction(event) {
        if (this.isOverLastRegistrationDate) {
            alert('已过展会报名截止日期，无法再次进行填写！');
            return;
        }
        this.delRow = [];
        const action = event.detail.action;
        const row = event.detail.row;
        console.log("action===>" + action + row);
        if (row.Is_Arranged__c) {
            alert('已分配车辆无法进行操作！');
            return;
        }
        let conIds = [];
        conIds.push(row.Id);
        this.delRow = conIds;
        if ("edit" == action.name) {
            this.carType = row.Vehicle_Type__c;
            this.carDate = row.Date__c;
            this.template.querySelector('c-modal-lwc').showModal();

        } if ('delete' == action.name) {
            console.log("delete================");
            delRecord({ bookIdList: conIds }).then(res => {
                if (res.isSuccess) {
                    alert("删除成功！");
                    console.log("删除成功！");
                    setTimeout(() => {
                        this.getVeBooks();
                    }, 500);
                } else {
                    alert("系统异常：" + res.message);
                }

            }).catch(error => {
                alert("系统错误：" + JSON.stringify(error));
            })
        }
    }


    // 获取车辆信息
    getVeBooks() {
        console.log("getVeBooks");
        console.log("this.internalRegistrationId:" + this.internalRegistrationId + "this.recordId:" + this.recordId);

        getExhibionVeBooking({ intId: this.internalRegistrationId, arrId: this.recordId }).then(res => {
            this.datas = res;

            for (let i = 0; i < this.datas.length; i++) {
                if (this.datas[i].Is_Arranged__c) {
                    this.isRowEditable[this.datas[i].Id] = false;
                } else {
                    this.isRowEditable[this.datas[i].Id] = true;
                }
            }
        }).catch(res => {
            console.log("error===>" + res);
            this.errorMsgArray = "系统错误：" + res;
        });

    }

    handleCarType(event) {
        console.log('cartype==>' + event.detail.value);
        this.carType = event.detail.value;
    }
    handleCarDate(event) {
        let inputDate = event.detail.value;
        console.log('date===>' + inputDate);
        this.carDate = inputDate;
    }

    handlerShowToast(selfTitle, selfMsg, selfVar) {
        this.dispatchEvent(new ShowToastEvent({
            title: selfTitle,
            message: selfMsg,
            variant: selfVar,
        }));
    }



    //批量 废除
    handleRowSelection(event) {
        this.delRow = [];
        const selectedRows = event.detail.selectedRows
        this.recordsCount = event.detail.selectedRows.length;
        // this.deleteRows = selectedRows;
        console.log('批量' + JSON.stringify(selectedRows));
        // let conIds = new Set();
        let conIds = [];
        for (let i = 0; i < selectedRows.length; i++) {
            // conIds.add(selectedRows[i].Id);
            if (selectedRows[i].Is_Arranged__c) {
                alert("已分配车辆无法删除！");
            }
            else if (selectedRows[i].Id.length == 18 && selectedRows[i].Plate_Number__c == undefined) {
                conIds.push(selectedRows[i].Id);
            } else {
                const row = selectedRows[i];
                // 查找要删除的行的索引
                const rowIndex = this.datas.findIndex((dataRow) => dataRow.Id === row.Id);
                if (rowIndex !== -1) {
                    // 从 data 数组中删除行
                    this.datas.splice(rowIndex, 1);
                    // 重新分配数组以刷新视图
                    this.datas = [...this.datas];
                }
            }
        }
        // this.deleteRows = Array.from(conIds);
        this.deleteRows = conIds;
        console.log(this.deleteRows + JSON.stringify(this.deleteRows));
        if (this.recordsCount > 0) {
            this.isDeleteButtonDisabled = false;
        }
        else {
            this.isDeleteButtonDisabled = true;
        }
    }
    //更新记录 废除
    async handleRowsSave(event) {
        const updatedData = event.detail.draftValues;
        console.log('updateRowsSave==>' + JSON.stringify(updatedData));
        const row = event.detail.row;
        console.log("handleRowsSave.row====>" + row + JSON.stringify(row));
        const updatedFields = event.detail.draftValues;

        // Prepare the record IDs for notifyRecordUpdateAvailable()
        const notifyChangeIds = updatedFields.map(row => { return { "recordId": row.Id } });

        // Clear all datatable draft values
        this.draftValues = [];
        console.log("updatedFields==>" + JSON.stringify(updatedFields));
        console.log(this.internalRegistrationId + ' ' + this.recordId + ' ');
        await upsertRecords({ jsonStr: JSON.stringify(updatedFields), intId: this.internalRegistrationId, arrId: this.recordId }).then(res => {
            if (res.isSuccess) {
                alert("保存成功！");
            } else {
                alert("系统错误!：" + res.message);
                console.log('更新失败' + res.message);
            }
        }).catch(error => {
            alert("系统错误! " + JSON.stringify(error));
            console.log("===>" + JSON.stringify(error) + error);
        })

        setTimeout(() => {
            this.getVeBooks();
        }, 1000);


    }

    checkFieldList = ['Is_Not_Flight__c', 'Designated_Hotel__c', 'Is_Not_Need_Vehicle__c'];
    dateFieldList = ['Arrival_Date__c', 'Hotel_Start_Date__c', 'Return_Date__c', 'Hotel_End_Date__c'];
    handleChange(event) {
        let fieldName = event.target.dataset.fieldName;
        if (fieldName == 'PresenceDate__c') {
            this.recordInfo[fieldName] = new String(event.detail.value).replaceAll(',', ';');
        } else if (this.checkFieldList.includes(fieldName)) {
            this.recordInfo[fieldName] = event.target.checked;
        } else {
            this.recordInfo[fieldName] = event.target.value;

            if (this.dateFieldList.includes(fieldName)) {
                let result = this.dateCheck();
                if (result.flag) {
                    this.dateChange();
                } else {
                    alert(result.message);
                    this.recordInfo[fieldName] = null;
                    // this.showError(result.message);
                }
            }
        }

        console.log('fieldName : ' + fieldName);
        console.log('handleChange : ' + this.recordInfo[fieldName]);
    }

    dateChange() {
        let presenceStartDate = new Date(this.startDate);
        let presenceEndDate = new Date(this.endDate);
        console.log('dateChange ---> startDate : ' + this.startDate);
        console.log('dateChange ---> endDate : ' + this.endDate);

        if (this.isFilledOut(this.recordInfo.Arrival_Date__c) && (presenceStartDate < new Date(this.recordInfo.Arrival_Date__c))) {
            presenceStartDate = new Date(this.recordInfo.Arrival_Date__c);
        }
        if (this.isFilledOut(this.recordInfo.Hotel_Start_Date__c) && (presenceStartDate < new Date(this.recordInfo.Hotel_Start_Date__c))) {
            presenceStartDate = new Date(this.recordInfo.Hotel_Start_Date__c);
        }

        if (this.isFilledOut(this.recordInfo.Return_Date__c) && (presenceEndDate > new Date(this.recordInfo.Return_Date__c))) {
            presenceEndDate = new Date(this.recordInfo.Return_Date__c);
        }
        if (this.isFilledOut(this.recordInfo.Hotel_End_Date__c) && (presenceEndDate > new Date(this.recordInfo.Hotel_End_Date__c))) {
            presenceEndDate = new Date(this.recordInfo.Hotel_End_Date__c);
        }
        console.log('dateChange ---> presenceStartDate : ' + presenceStartDate);
        console.log('dateChange ---> presenceEndDate : ' + presenceEndDate);

        this.recordInfo.PresenceDate__c = '';


        for (let indexDate = presenceStartDate; indexDate <= presenceEndDate;) {
            let indexDateString = indexDate.getFullYear() + '-' + (indexDate.getMonth() + 1) + '-' + indexDate.getDate();
            indexDateString = indexDate.format('yyyy-MM-dd');
            console.log('dateChange ---> indexDateString : ' + indexDateString);

            this.recordInfo.PresenceDate__c += indexDate.format('MM-dd') + ';';

            indexDate = new Date(indexDate.setDate(indexDate.getDate() + 1));
            console.log('dateChange ---> indexDate : ' + indexDate);
        }
    }

    getPresenceOptions() {
        this.presenceOptions = [];
        let presenceStartDate = new Date(this.startDate);
        let presenceEndDate = new Date(this.endDate);
        for (let indexDate = presenceStartDate; indexDate <= presenceEndDate;) {
            let indexDateString = indexDate.getFullYear() + '-' + (indexDate.getMonth() + 1) + '-' + indexDate.getDate();
            indexDateString = indexDate.format('yyyy-MM-dd');
            console.log('getPresenceOptions ---> indexDateString : ' + indexDateString);

            this.presenceOptions.push({
                'label': indexDateString,
                'value': indexDate.format('MM-dd')
            });

            indexDate = new Date(indexDate.setDate(indexDate.getDate() + 1));
            console.log('getPresenceOptions ---> indexDate : ' + indexDate);
        }
    }

    get presenceValue() {
        if (this.isFilledOut(this.recordInfo.PresenceDate__c)) {
            console.log('recordInfo.PresenceDate__c : ' + this.recordInfo.PresenceDate__c);
            return new String(this.recordInfo.PresenceDate__c).split(';');
        } else {
            return [];
        }

    }

    // get noFlightInfo() {
    //     if (this.isFilledOut(this.recordInfo.Is_Not_Flight__c)) {
    //         return this.recordInfo.Is_Not_Flight__c;
    //     } else {
    //         return true;
    //     }
    // }

    // get noHotelInfo() {
    //     if (this.isFilledOut(this.recordInfo.Designated_Hotel__c)) {
    //         return this.recordInfo.Designated_Hotel__c;
    //     } else {
    //         return true;
    //     }
    // }

    // get noVehicleInfo() {
    //     if (this.isFilledOut(this.recordInfo.Is_Not_Need_Vehicle__c)) {
    //         return this.recordInfo.Is_Not_Need_Vehicle__c;
    //     } else {
    //         return true;
    //     }
    // }

    dateCheck() {
        let result = {
            flag: true,
            message: '',
        }

        let noFlightInfo = this.isFilledOut(this.recordInfo.Is_Not_Flight__c) ? this.recordInfo.Is_Not_Flight__c : true;
        let noHotelInfo = this.isFilledOut(this.recordInfo.Designated_Hotel__c) ? this.recordInfo.Designated_Hotel__c : true;

        if (!noFlightInfo) {
            if (this.isFilledOut(this.recordInfo.Arrival_Date__c) && this.isFilledOut(this.recordInfo.Return_Date__c) && (this.recordInfo.Arrival_Date__c > this.recordInfo.Return_Date__c)) {
                result.flag = false;
                result.message = '返回航班时间不应晚于出发航班时间';
                return result;
            }
        }

        if (!noHotelInfo) {
            if (this.isFilledOut(this.recordInfo.Hotel_Start_Date__c) && this.isFilledOut(this.recordInfo.Hotel_End_Date__c) && (this.recordInfo.Hotel_Start_Date__c > this.recordInfo.Hotel_End_Date__c)) {
                result.flag = false;
                result.message = '酒店入住时间不应晚于酒店离开时间';
                return result;
            }
        }

        if (!(noFlightInfo || noHotelInfo)) {
            if (this.isFilledOut(this.recordInfo.Arrival_Date__c) && this.isFilledOut(this.recordInfo.Hotel_Start_Date__c) && (this.recordInfo.Arrival_Date__c > this.recordInfo.Hotel_Start_Date__c)) {
                result.flag = false;
                result.message = '出发航班时间不应晚于酒店入住时间';
                return result;
            }
        }
        return result;
    }

    isFilledOut(content) {
        if (typeof content == "undefined") {
            return false;
        } else if (typeof content == "boolean") {
            return true;
        } else if (content == '' || content == null) {
            return false;
        } else if (typeof content == "number") {
            return !isNaN(content);
        }
        return true;
    }

}