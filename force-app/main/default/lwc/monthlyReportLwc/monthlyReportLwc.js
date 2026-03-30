import { LightningElement, track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';

import Monthly_Report_Title from '@salesforce/label/c.Monthly_Report_Title';
import INSPECTION_REPORT_EDIT from '@salesforce/label/c.INSPECTION_REPORT_EDIT';
import PromoterDailyReport_SAVE from '@salesforce/label/c.PromoterDailyReport_SAVE';
import PromoterDailyReport_NEW from '@salesforce/label/c.PromoterDailyReport_NEW';
import PromoterDailyReport_OWNER from '@salesforce/label/c.PromoterDailyReport_OWNER';
import PromoterDailyReport_RequiredCheck from '@salesforce/label/c.PromoterDailyReport_RequiredCheck';
import ReSelectTheWeekOrMonthly from '@salesforce/label/c.ReSelectTheWeekOrMonthly';

import getInitData from '@salesforce/apex/MonthlyReportController.getInitData';
import createReport from '@salesforce/apex/MonthlyReportController.createReport';
// import refreshData from '@salesforce/apex/MonthlyReportController.refreshData';
import saveData from '@salesforce/apex/MonthlyReportController.saveData';


export default class MonthlyReportLwc extends LightningNavigationElement {

    @api lwcName = Monthly_Report_Title;

    @api recordId;
    @api monthInfo;
    @api shopId;

    @track isShowSpinner;

    @track monthlyReport = {};
    @track reportFields = {};
    @track reprotInfoAndMonthItemIdMap = {};

    @track activeSections = [];
    @track monthlsOptionList = [];
    @track storeOptionList = [];
    @track displayUnitList = [];

    @track commonConfigId = '';

    @track viewMode = true;
    @track isEditPage = false;
    @track isTitleReadOnly = false;
    @track fieldReadOnly = true;

    itemRespIsSuccess = false;
    itemRespErrorMsg = '';

    label = { Monthly_Report_Title, INSPECTION_REPORT_EDIT, PromoterDailyReport_SAVE, PromoterDailyReport_NEW, PromoterDailyReport_OWNER };

    get loaderPara() {
        let reportId = null;
        if (this.isFilledOut(this.isFilledOut(this.monthlyReport.Id))) {
            reportId = this.monthlyReport.Id;
        }
        return {
            recordId: reportId,
            viewMode: this.viewMode
        };
    }

    get haveRecordId() {
        return (this.isFilledOut(this.recordId) || (this.isFilledOut(this.monthlyReport.Id)));
    }

    get recordDisabled() {
        return this.monthlyReport.Status__c != 'New' || this.monthlyReport.Id == null;
    }

    get viewStyle() {
        var style = '';
        if (this.viewMode || this.isTitleReadOnly || this.recordDisabled || this.fieldReadOnly) {
            return 'background: unset;cursor: no-drop;border: 0;box-shadow: none;';
        }
        return style;
    }

    get recordDatereadonly() {
        if (this.isTitleReadOnly) {
            return true;
        } else if (this.isEditPage) {
            return true;
        } else {
            return false;
        }
    }

    get recordDateClass() {
        if (this.recordDatereadonly) {
            return 'disabled-input';
        } else {
            return '';
        }
    }

    height;
    get styleContent() {
        return true ? 'max-height: ' + this.height + 'px;' : '';
    }
    start() {
        var titleDoc = this.template.querySelector('.slds-modal__header');
        if (titleDoc) {
            var titleHeight = titleDoc.offsetHeight;
            this.height = document.documentElement.clientHeight - titleHeight;

        }
    }

    handleInitData(recordId, monthInfo, shopId) {
        console.log('handleInitData ------- : ');
        this.isShowSpinner = true;
        getInitData({
            recordId: recordId,
            monthInfo: monthInfo,
            storeId: shopId
        }).then(data => {
            console.log('getInitData : ');
            for (let key in data.data) {
                this[key] = data.data[key];
            }
            
            if (this.recordId && !data.data.monthlyReport.Months__c) {
                this.goToLwc('researchReportLwc', {
                    recordId : this.recordId
                });
                return;
            }
            for(let index=0; index < this.displayUnitList.length; index++) {
                if(this.displayUnitList[index].name == 'footCountInquiry') {
                    this.displayUnitList[index].isCanAdd = false;
                } else {
                    this.displayUnitList[index].isCanAdd = true;
                }
            }
            if (!data.isSuccess) {
                this.showError(data.message);
            }
            console.log('monthlyReport : ' + JSON.stringify(this.monthlyReport));
            console.log('displayUnitList : ' + JSON.stringify(this.displayUnitList));
            this.start();
            this.isShowSpinner = false;
        }).catch(error => {
            this.catchError(error);
            this.isShowSpinner = false;
        });
        this.isShowSpinner = false;
    }

    connectedCallback() {
        console.log('connectedCallback!! ——> recordId : ' + this.recordId);
        this.handleInitData(this.recordId, this.monthInfo, this.shopId);
    }

    handleNew() {
        this.isShowSpinner = true;
        console.log('handleNew ------ start : ');
        console.log('monthlyReport : ' + JSON.stringify(this.monthlyReport));

        if (!this.isFilledOut(this.monthlyReport.Months__c)) {
            this.showWarning(PromoterDailyReport_RequiredCheck + reportFields.Months__c);
        } else if (!this.isFilledOut(this.monthlyReport.Shop__c)) {
            this.showWarning(PromoterDailyReport_RequiredCheck + reportFields.Shop__c);
        } else {
            createReport({
                recordJson: JSON.stringify(this.monthlyReport)
            }).then(data => {
                console.log('createReport ------ start : ');
                if (data.isSuccess) {
                    for (let key in data.data) {
                        this[key] = data.data[key];
                    }
                    for (let index = 0; index < this.displayUnitList.length; index++) {
                        if (this.displayUnitList[index].name == 'footCountInquiry') {
                            this.displayUnitList[index].isCanAdd = false;
                        } else {
                            this.displayUnitList[index].isCanAdd = true;
                        }
                    }
                    this.recordId = data.data.reportId;
                } else {
                    this.showError(data.message);
                }
                this.isShowSpinner = false;
                console.log('createReport ------ end : ');
            }).catch(error => {
                this.catchError(error);
                this.isShowSpinner = false;
            });
        }
        this.isShowSpinner = false;
        console.log('handleNew ------ end : ');
    }

    inputChangeHandler(event) {
        let targetName = event.target.dataset.fieldName;
        console.log('monthlyReport ——> inputChangeHandler ——> targetName : ' + targetName);
        this.monthlyReport[targetName] = event.target.value;

        if (targetName == 'Months__c') {
            console.log('handleRefreshData ------- Months__c : ');
            if (this.monthlyReport.Months__c in this.reprotInfoAndMonthItemIdMap) {
                this.monthlyReport.ReportConfigurationItem__c = this.reprotInfoAndMonthItemIdMap[this.monthlyReport.Months__c];
            } else {
                this.showError(ReSelectTheWeekOrMonthly.format(this.reportFields.Months__c));
            }
        }
        this.goToComponent('c__LWCWrapper', {
            'lwcName': 'MonthlyReportLwc',
            'shopId': this.monthlyReport.Shop__c,
            'monthInfo': this.monthlyReport.Months__c
        });
    }

    // 更改日期或门店刷新页面信息
    // handleRefreshData() {
    //     this.isShowSpinner = true;
    //     console.log('handleRefreshData ------ : ');
    //     console.log('monthlyReport : ' + JSON.stringify(this.monthlyReport));

    //     refreshData({
    //         monthInfo: this.monthlyReport.Months__c,
    //         storeId: this.monthlyReport.Shop__c,
    //     }).then(data => {
    //         if (data.isSuccess) {
    //             if (data.data.haveCreated) {
    //                 this.monthlyReport = data.data.monthlyReport;
    //                 this.goToComponent('c__LWCWrapper', {
    //                     'lwcName': 'MonthlyReportLwc',
    //                     'recordId': this.monthlyReport.Id
    //                 });
    //             } else {
    //                 this.recordId = null;
    //                 this.monthlyReport.Id = null;
    //                 this.monthlyReport.Status__c = 'New';
    //             }
    //         } else {
    //             this.showError(data.message);
    //         }
    //         this.isShowSpinner = false;
    //     }).catch(error => {
    //         this.catchError(error);
    //         this.isShowSpinner = false;
    //     });
    // }

    handleEdit() {
        console.log('==========>Edit click');
        this.isEditPage = true;
        this.isTitleReadOnly = false;
        this.viewMode = false;
    }


    handleOk() {
        this.template.querySelector('c-modal-lwc').closeModal();
        this[this.modalType](this.modalHelper, this.modelHelper);
    }

    handleSectionToggle(event) {
        console.log(event.detail.openSections);
        let openSections = event.detail.openSections;
        let sections = this.template.querySelectorAll(
            "lightning-accordion-section"
        );
        console.log('openSections>>>>>>>' + openSections);
        console.log('sections>>>>>>>' + sections);
        this.activeSections = [];
        sections.forEach((section) => {
            if (openSections.indexOf(section.name) > -1) {
                this.activeSections.push(section.name);
            }
        });
    }


    allRef = new Map();
    handleLoad(event) {
        console.log('handleLoad ------- : ');
        let unitName = event.target.dataset.unitName;
        let ref = event.detail.ref;
        console.log('unitName : ' + unitName);
        console.log('ref : ' + ref);
        this.allRef[unitName] = ref;
    }

    handleAddItem(event) {
        console.log('handleAddItem ------- : ');
        let thisUnitName = event.currentTarget.dataset.unitName;
        console.log('thisUnitName : ' + thisUnitName);
        if (thisUnitName in this.allRef) {
            this.allRef[thisUnitName].itemAddHandler();
        }
        this.activeSections = [thisUnitName];
    }

    handleSaveData(resp) {
        console.log('handleSaveData ------- : ');
        if (!resp.detail.result.isSuccess) {
            this.itemRespIsSuccess = resp.detail.result.isSuccess;
            this.itemRespErrorMsg += ' ' + resp.detail.result.message;
        }
    }

    handleSave() {
        this.isShowSpinner = true;
        let allMessages = '';
        for (let unit in this.allRef) {
            let unitMessages = this.allRef[unit].checkData();
            if (this.isFilledOut(unitMessages)) {
                allMessages += unitMessages;
                console.log('unitMessages : ' + unitMessages);
            }
        }
        if (allMessages == '') {
            this.itemRespIsSuccess = true;
            this.itemRespErrorMsg = '';
            for (let unit in this.allRef) {
                this.allRef[unit].saveData();
            }
            if (this.itemRespIsSuccess) {
                // 模块信息保存完毕, 更新月报状态
                this.monthlyReport.Saved__c = true;
                console.log('this.monthlyReport :' + JSON.stringify(this.monthlyReport));
                saveData({
                    recordJson: JSON.stringify(this.monthlyReport)
                }).then(data => {
                    console.log('saveData ------ : ');
                    if (data.isSuccess) {
                        this.showSuccess('success');
                    } else {
                        this.showError(data.message);
                    }
                }).catch(error => {
                    this.catchError(error);
                    this.isShowSpinner = false;
                });
            } else {
                this.itemRespErrorMsg = this.itemRespErrorMsg == '' ? this.itemRespErrorMsg : 'error';
                this.showError(this.itemRespErrorMsg);
            }
        } else {
            this.showWarning(allMessages);
        }
        this.isShowSpinner = false;
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
}