/*
 * @Author: WFC
 * @Date: 2023-11-22 16:00:37
 * @LastEditors: WFC
 * @LastEditTime: 2024-12-06 13:39:28
 * @Description: 
 * @FilePath: \hisense005\force-app\main\default\lwc\newCustomerPageLwc\newCustomerPageLwc.js
 */
import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { LightningNavigationElement } from 'c/lwcUtils'
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEDIData from '@salesforce/apex/NewCustomerForEDIController.getEDIData';
import getCountryCodeOptions from '@salesforce/apex/NewCustomerForEDIController.getCountryCodeOptions';
// import getCustomerDataFromEDI from '@salesforce/apex/NewCustomerForEDIController.getCustomerDataFromEDI';

import saveEDICustomerDate from '@salesforce/apex/NewCustomerForEDIController.saveEDICustomerDate';

import New_Customer_Buyer_Name from '@salesforce/label/c.New_Customer_Buyer_Name';
import New_Customer_Buyer_Name_Verify from '@salesforce/label/c.New_Customer_Buyer_Name_Verify';
import New_Customer_Country_Region_Code from '@salesforce/label/c.New_Customer_Country_Region_Code';
import New_Customer_EDI_Data from '@salesforce/label/c.New_Customer_EDI_Data';
import New_Customer_Buyer_Name_Not_Null from '@salesforce/label/c.New_Customer_Buyer_Name_Not_Null';
import New_Customer_Country_Region_Code_Select from '@salesforce/label/c.New_Customer_Country_Region_Code_Select';
import New_Customer_EDI_Data_Null from '@salesforce/label/c.New_Customer_EDI_Data_Null';
import New_Customer_EDI_Data_Select from '@salesforce/label/c.New_Customer_EDI_Data_Select';
import New_Customer_Registration_Number_Have from '@salesforce/label/c.New_Customer_Registration_Number_Have';

export default class NewCustomerPageLwc extends LightningNavigationElement {
    label = {
        New_Customer_Buyer_Name, // 买方名称
        New_Customer_Buyer_Name_Verify, // 买方名称5个字节以上
        New_Customer_Country_Region_Code, // 国别/地区代码
        New_Customer_EDI_Data, // EDI客户数据
        New_Customer_Buyer_Name_Not_Null, // 请填写买方名称！
        New_Customer_Country_Region_Code_Select, // 请选择国别代码！
        New_Customer_EDI_Data_Null, // 未查询到EDI客户数据！
        New_Customer_EDI_Data_Select, // 请选择一条EDI客户数据！
        New_Customer_Registration_Number_Have, // 注册号已存在
    }

    @api recordTypeId;
    // 买方模糊查询参数
    @track buyerName
    @track countryCode
    @track ediData = []
    @track isHaveEDI = false;
    @track isChecked = false;
    @track isShowSpinner = false;
    @track customerid;
    // 买方画像参数
    @track buyerParam = {}
    @track columns = [];

    @track isShowDisplay = false;
    showConnectingCustomers = false;

    /**
     * 初始化 EDI_Customer__c 标签
     */
    @track EDICustomerInfo = {
        createTime__c: '',
        updateTime__c: '',
        id__c: '',
        chnname__c: '',
        buyerno__c: '',
        countryname__c: '',
        address__c: '',
        buyerlevel__c: ''
    };

    @wire(getObjectInfo, { objectApiName: 'EDI_Customer__c' })
    wiredEDICustomerInfo({ error, data }) {
        if (data) {
            this.EDICustomerInfo = {
                createTime__c: data.fields.createTime__c.label,
                updateTime__c: data.fields.updateTime__c.label,
                id__c: data.fields.id__c.label,
                chnname__c: data.fields.chnname__c.label,
                buyerno__c: data.fields.buyerno__c.label,
                countryname__c: data.fields.countryname__c.label,
                address__c: data.fields.address__c.label,
                buyerlevel__c: data.fields.buyerlevel__c.label,
            };
            this.optionsDisplay = [
                { value: 'createTime__c', label: this.EDICustomerInfo.createTime__c, },
                { value: 'updateTime__c', label: this.EDICustomerInfo.updateTime__c, },
                { value: 'id__c', label: this.EDICustomerInfo.id__c, },
                { value: 'chnname__c', label: this.EDICustomerInfo.chnname__c, },
                { value: 'buyerno__c', label: this.EDICustomerInfo.buyerno__c, },
                { value: 'countryname__c', label: this.EDICustomerInfo.countryname__c, },
                { value: 'address__c', label: this.EDICustomerInfo.address__c, },
                { value: 'buyerlevel__c', label: this.EDICustomerInfo.buyerlevel__c, },
            ];
            this.columns = [
                { label: this.EDICustomerInfo.createTime__c, fieldName: 'createTime', sortable: true, },
                { label: this.EDICustomerInfo.updateTime__c, fieldName: 'updateTime', sortable: true, },
                { label: this.EDICustomerInfo.id__c, fieldName: 'id', sortable: true, },
                { label: this.EDICustomerInfo.chnname__c, fieldName: 'chnname', sortable: true, },
                { label: this.EDICustomerInfo.buyerno__c, fieldName: 'buyerno', sortable: true, },
                { label: this.EDICustomerInfo.countryname__c, fieldName: 'countryname', sortable: true, },
                { label: this.EDICustomerInfo.address__c, fieldName: 'address', sortable: true, },
                { label: this.EDICustomerInfo.buyerlevel__c, fieldName: 'buyerlevel', sortable: true, },
            ];

        } else if (error) {
            console.log(error);
            this.showError('EDI_Customer__c getInformation error');
        }
    }

    get style() {
        var width;
        var userAgent = navigator.userAgent;
        if (/iphone|iPhone|ipad|iPad|ipod|iPod|iOS|ios/.test(userAgent) || /android|Android/.test(userAgent)) {
            width = 'width: 100%;';
        } else {
            width = 'width: 36%;';
        }
        return width;
    }

    // 选择显示字段-----------------------
    handleDisplayClick(event) {
        console.log('wwww---' + this.EDICustomerInfo);
        this.isShowDisplay = true;
    }

    // 多选字段option
    optionsDisplay = [];
    // 字段对应
    columnTemp = {
        createTime__c: 'createTime',
        updateTime__c: 'updateTime',
        id__c: 'id',
        chnname__c: 'chnname',
        buyerno__c: 'buyerno',
        countryname__c: 'countryname',
        address__c: 'address',
        buyerlevel__c: 'buyerlevel'
    };
    // 默认选择字段
    optionsValue = ['createTime__c', 'updateTime__c', 'id__c', 'chnname__c', 'buyerno__c', 'countryname__c', 'address__c', 'buyerlevel__c'];

    // 选择显示字段
    handleSelectChange(e) {
            this.optionsValue = e.detail.value;
        }
        // 取消按钮
    cancelDisplay(e) {
            this.isShowDisplay = false;
        }
        // 保存选择字段按钮
    saveDisplay(e) {
            this.columns = [];
            this.optionsValue.forEach(element => {
                let column = {};
                column['label'] = this.EDICustomerInfo[element];
                column['fieldName'] = this.columnTemp[element];
                column['sortable'] = true;
                this.columns.push(column);
            });
            this.isShowDisplay = false;
        }
        // -------------------------------------

    connectedCallback() {

    }

    handleCustomerName(event) {
        console.log('www--handleCustomerName:' + event.target.value);
        this.buyerName = event.target.value;
    }
    handleCustomerIdChange(event) {
        this.customerid = event.target.value;
    }

    handleSalesRegion(event) {
        // this.countryCode  = event.target.value;
        try {
            this.countryCode = event.target.options.find(opt => opt.label === event.detail.value).value;
            console.log('www--handleSalesRegion:' + this.countryCode);
        } catch (error) {

        }

    }

    handleCheck(event) {
        let flag = true;
        if (this.buyerName == '' || this.buyerName == null || this.buyerName == undefined) {
            console.log('www--buyerName:' + event.target.value);
            this.showError(this.label.New_Customer_Buyer_Name_Not_Null);
            flag = false;
            return;
        } else if (this.buyerName.length < 5) {
            this.showError(this.label.New_Customer_Buyer_Name_Verify);
            flag = false;
            return;
        }
        if (this.countryCode == '' || this.countryCode == null || this.countryCode == undefined) {
            console.log('www--countryCode:' + event.target.value);
            this.showError(this.label.New_Customer_Country_Region_Code_Select);
            flag = false;
            return;
        }
        // const inputFields = this.template.querySelectorAll(
        //     'lightning-input-field'
        // );
        // if (inputFields) {
        //     inputFields.forEach(field => {
        //         if(field.name == 'Name'){
        //             if(field.value == '' || field.value == null || field.value == undefined){
        //                 this.showError('请填写客户名称！');
        //                 flag = false;
        //             }else {
        //                 this.buyerName = field.value;
        //             }

        //         }
        //         if(field.name == 'Sales_Region__c'){
        //             if(field.value == '' || field.value == null || field.value == undefined){
        //                 this.showError('请选择国家！');
        //                 flag = false;
        //             }else {
        //                 this.countryCode = field.value;
        //             }
        //         }
        //     });
        // }
        if (!flag) return;
        this.isShowSpinner = true;
        this.isChecked = false;
        this.ediData = [];
        this.buyerParam = {};
        // 查询EDI系统
        getEDIData({
            buyerName: this.buyerName,
            countryCode: this.countryCode,
        }).then(data => {
            this.isShowSpinner = false;
            if (data.isSuccess) {
                console.log('www-----' + data.ediData);
                this.ediData = JSON.parse(data.ediData);
                if (this.ediData.length > 0) {
                    this.isHaveEDI = true;
                } else {
                    this.isHaveEDI = false;
                    this.showSuccess(this.label.New_Customer_EDI_Data_Null);
                }
                this.isChecked = true;
            } else {
                this.showError(data.failMessage);
                return;
            }

        }).catch(error => {
            this.isShowSpinner = false;
        });
    }

    handleCancel(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'home'
            }
        });
    }

    handleChange(event) {
            console.log(JSON.stringify(event.detail.selectedRows[0]));
            this.buyerParam = event.detail.selectedRows[0];
            console.log(JSON.stringify(this.buyerParam));
        }
        /*
         * method: 判断是否为空
         * author: yanglin
         * DateTime : 2024-12-05
         */
    stringIsEmpty(str) {
            if (str != '' && str != undefined && str != null) {
                return false;
            } else {
                return true;
            }
        }
        /*
         * method: Toast 提示
         * author: yang lin
         * DateTime : 2024-12-05
         */
    ShowToast(message, variant) {
            const evt = new ShowToastEvent({
                message: message,
                variant: variant,
                mode: 'dismissable' // 自动消失模式
            });
            this.dispatchEvent(evt);
        }
        /*
         * method:保存数据
         * author: yang lin
         * DateTime : 2024-12-05
         */
    async ConnectingCustomers() {
        if (this.stringIsEmpty(this.customerid)) {
            this.showError('请选择需要关联的客户');
            return;
        }
        console.log({ tcustomerid: this.customerid });
        let customer_EDI_id = await saveEDICustomerDate({ customerId: this.customerid, buyerParam: JSON.stringify(this.buyerParam) });
        console.log({ customer_EDI_id: customer_EDI_id });
        if (!this.stringIsEmpty(customer_EDI_id)) {
            this.ShowToast('save success!', 'success');

            window.location.href = '/lightning/n/EDI_Customer';
        } else {
            this.ShowToast('save error', 'error');
        }



    }
    handleSelect() {
        if (JSON.stringify(this.buyerParam) === '{}') {
            this.showError('请先选择一条EDI客户数据！');
            return;
        }
        this.showConnectingCustomers = true;

        console.log(JSON.stringify(this.buyerParam));


    }
    cancelConnectingCustomers() {
            this.customerid = null;
            this.showConnectingCustomers = false;
        }
        //废弃
        // handleSelect111(event) {


    //     if (this.buyerParam.buyerno == null || this.buyerParam.buyerno == '' || this.buyerParam.buyerno == undefined) {
    //         this.showError(this.label.New_Customer_EDI_Data_Select);
    //         return;
    //     } else {
    //         this.isShowSpinner = true;
    //         // 查询EDI系统
    //         getCustomerDataFromEDI({
    //             recordTypeId: this.recordTypeId,
    //             buyerName: this.buyerName,
    //             countryCode: this.countryCode,
    //             buyerParam: JSON.stringify(this.buyerParam)
    //         }).then(data => {
    //             this.isShowSpinner = false;
    //             if (data.isSuccess) {
    //                 console.log('wwww--' + JSON.stringify(data.account));
    //                 if (data.failMessage == 'view') {
    //                     // this.showWarning('注册号：' + data.account.VAT_Registration_Number__c + '已存在！');
    //                     this.showWarning(this.label.New_Customer_Registration_Number_Have.format(data.account.VAT_Registration_Number__c));
    //                 }
    //                 let fieldValues = [];
    //                 fieldValues.push('Name=' + data.account.Name);
    //                 fieldValues.push('Email__c=' + data.account.Email__c);
    //                 fieldValues.push('Fax=' + data.account.Fax);
    //                 fieldValues.push('Website=' + data.account.Website);
    //                 fieldValues.push('Phone=' + data.account.Phone);
    //                 fieldValues.push('VAT_Registration_Number__c=' + data.account.VAT_Registration_Number__c);
    //                 fieldValues.push('Address__c=' + data.account.Address__c);
    //                 if (data.account.Sales_Region__c != null && data.account.Sales_Region__c != '' && data.account.Sales_Region__c != undefined) {
    //                     fieldValues.push('Sales_Region__c=' + data.account.Sales_Region__c);
    //                 }
    //                 this[NavigationMixin.Navigate]({
    //                     type: 'standard__objectPage',
    //                     attributes: {
    //                         objectApiName: 'Account',
    //                         actionName: 'new'
    //                     },
    //                     state: {
    //                         defaultFieldValues: fieldValues.join(','),
    //                         nooverride: '1',
    //                         recordTypeId: this.recordTypeId,
    //                     }
    //                 });
    //                 // if(data.failMessage == 'new'){
    //                 //     this[NavigationMixin.Navigate]({
    //                 //         type: 'standard__objectPage',
    //                 //         attributes: {
    //                 //             objectApiName   :   'Account',
    //                 //             actionName      :   'new'
    //                 //         },
    //                 //         state: {
    //                 //             defaultFieldValues : 'Name=' + data.account.Name + 
    //                 //                                 ',Sales_Region__c=' + data.account.Sales_Region__c + 
    //                 //                                 ',Email__c=' + data.account.Email__c + 
    //                 //                                 ',Fax=' + data.account.Fax + 
    //                 //                                 ',Address__c=' + data.account.Address__c + 
    //                 //                                 ',EDICode__c=' + data.account.EDICode__c + 
    //                 //                                 ',VAT_Registration_Number__c=' + data.account.VAT_Registration_Number__c 
    //                 //                                 ,
    //                 //             nooverride: '1',
    //                 //             recordTypeId: this.recordTypeId,
    //                 //         }
    //                 //     });
    //                 // }else{
    //                 //     this.showSuccess('客户已存在！');
    //                 //     this[NavigationMixin.Navigate]({
    //                 //         type: 'standard__recordPage',
    //                 //         attributes: {
    //                 //             recordId: data.account.Id,
    //                 //             objectApiName: 'Account',
    //                 //             actionName: 'view'
    //                 //         },
    //                 //     });
    //                 // }

    //             } else {
    //                 this.showError(data.failMessage);
    //                 return;
    //             }

    //         }).catch(error => {
    //             this.isShowSpinner = false;
    //         });
    //     }
    // }

    handleSkip(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: 'Name=' + this.buyerName,
                nooverride: '1',
                recordTypeId: this.recordTypeId,
            }
        });
    }

    // 排序
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    sortBy(field, reverse, primer) {
        const key = primer ?

            function(x) {
                return primer(x[field]);
            } :
            function(x) {
                return x[field];
            };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.ediData];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.ediData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    // variant : info / success / warning / error
    // mode : dismissable/pester/sticky。
    // dismissable是默认的值，功能为用户点击关闭按钮或者经过3秒以后toast消失；
    // pester用于只显示3秒，3秒以后自动消失(此种没有关闭按钮)；
    // sticky用于只有用户点击关闭按钮才会消失
    showToast(title, message, variant, mode) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        }));
    }


    // get options() {
    //     return [
    //         { label: 'Yes', value: 'Y' },
    //         { label: 'No', value: 'N' },
    //     ];
    // }

    @wire(getCountryCodeOptions)
    options;

}