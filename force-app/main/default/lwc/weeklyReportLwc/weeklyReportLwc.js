import { LightningElement, track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';

import Weekly_Report_Title from '@salesforce/label/c.Weekly_Report_Title';
import INSPECTION_REPORT_EDIT from '@salesforce/label/c.INSPECTION_REPORT_EDIT';
import PromoterDailyReport_SAVE from '@salesforce/label/c.PromoterDailyReport_SAVE';
import PromoterDailyReport_NEW from '@salesforce/label/c.PromoterDailyReport_NEW';
import PromoterDailyReport_OWNER from '@salesforce/label/c.PromoterDailyReport_OWNER';
import PromoterDailyReport_RequiredCheck from '@salesforce/label/c.PromoterDailyReport_RequiredCheck';
import ReSelectTheWeekOrMonthly from '@salesforce/label/c.ReSelectTheWeekOrMonthly';

import getInitData from '@salesforce/apex/WeeklyReportController.getInitData';
import createReport from '@salesforce/apex/WeeklyReportController.createReport';
// import refreshData from '@salesforce/apex/WeeklyReportController.refreshData';
import saveData from '@salesforce/apex/WeeklyReportController.saveData';

export default class WeeklyReportLwc extends LightningNavigationElement {

    @api lwcName = Weekly_Report_Title;

    @api recordId;
    @api weekInfo;
    @api shopId;

    @track isShowSpinner;

    @track weeklyReport = {};
    @track reportFields = {};
    @track reprotInfoAndWeekItemIdMap = {};

    @track activeSections = [];
    @track weeklsOptionList = [];
    @track storeOptionList = [];
    @track displayUnitList = [];

    @track commonConfigId = '';

    @track viewMode = true;
    @track isEditPage = false;
    @track isTitleReadOnly = false;
    @track fieldReadOnly = true;

    itemRespIsSuccess = false;
    itemRespErrorMsg = '';


    label = { Weekly_Report_Title, INSPECTION_REPORT_EDIT, PromoterDailyReport_SAVE, PromoterDailyReport_NEW, PromoterDailyReport_OWNER };

    get loaderPara() {
        let reportId = null;
        if (this.isFilledOut(this.isFilledOut(this.weeklyReport.Id))) {
            reportId = this.weeklyReport.Id;
        }
        return {
            recordId: reportId,
            viewMode: this.viewMode
        };
    }

    get haveRecordId() {
        return (this.isFilledOut(this.recordId) || (this.isFilledOut(this.weeklyReport.Id)));
    }

    get recordDisabled() {
        return this.weeklyReport.Status__c != 'New' || this.weeklyReport.Id == null;
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

    handleInitData(recordId, weekInfo, shopId) {
        console.log('handleInitData ------- : ');
        this.isShowSpinner = true;
        getInitData({
            recordId: recordId,
            weekInfo: weekInfo,
            storeId: shopId
        }).then(data => {
            console.log('getInitData : ');
            for (let key in data.data) {
                this[key] = data.data[key];
            }

            if (this.recordId && !data.data.weeklyReport.Weeks__c) {
                this.goToLwc('marketReportLwc', {
                    recordId : this.recordId
                });
                return;
            }
            for (let index = 0; index < this.displayUnitList.length; index++) {
                if (this.displayUnitList[index].name == 'footCountInquiry') {
                    this.displayUnitList[index].isCanAdd = false;
                } else {
                    this.displayUnitList[index].isCanAdd = true;
                }
            }
            if (!data.isSuccess) {
                this.showError(data.message);
            }
            console.log('weeklyReport : ' + JSON.stringify(this.weeklyReport));
            this.start();
            this.isShowSpinner = false;
        }).catch(error => {
            this.catchError(error);
            this.isShowSpinner = false;
        });
        this.isShowSpinner = false;
    }

    connectedCallback() {
        console.log('connectedCallback!! ——> recordId：' + this.recordId);
        this.handleInitData(this.recordId, this.weekInfo, this.shopId);
    }

    handleNew() {
        this.isShowSpinner = true;
        console.log('handleNew ------ : ');
        console.log('weeklyReport : ' + JSON.stringify(this.weeklyReport));

        if (!this.isFilledOut(this.weeklyReport.Weeks__c)) {
            this.showWarning(PromoterDailyReport_RequiredCheck + reportFields.Weeks__c);
        } else if (!this.isFilledOut(this.weeklyReport.Shop__c)) {
            this.showWarning(PromoterDailyReport_RequiredCheck + reportFields.Shop__c);
        } else {
            createReport({
                recordJson: JSON.stringify(this.weeklyReport)
            }).then(data => {
                console.log('createReport ------ : ');
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
            }).catch(error => {
                this.catchError(error);
                this.isShowSpinner = false;
            });
        }
        this.isShowSpinner = false;
    }

    inputChangeHandler(event) {
        let targetName = event.target.dataset.fieldName;
        console.log('weeklyReport ——> inputChangeHandler ——> targetName : ' + targetName);
        this.weeklyReport[targetName] = event.target.value;

        if (targetName == 'Weeks__c') {
            console.log('handleRefreshData ------- Weeks__c : ');
            if (this.weeklyReport.Weeks__c in this.reprotInfoAndWeekItemIdMap) {
                this.weeklyReport.ReportConfigurationItem__c = this.reprotInfoAndWeekItemIdMap[this.weeklyReport.Weeks__c];
            } else {
                this.showError(ReSelectTheWeekOrMonthly.format(this.reportFields.Weeks__c));
            }
        }
        this.goToComponent('c__LWCWrapper', {
            'lwcName': 'WeeklyReportLwc',
            'shopId': this.weeklyReport.Shop__c,
            'weekInfo': this.weeklyReport.Weeks__c
        });

    }

    // 更改日期或门店刷新页面信息
    // handleRefreshData() {
    //     this.isShowSpinner = true;
    //     console.log('handleRefreshData ------ : ');
    //     console.log('weeklyReport : ' + JSON.stringify(this.weeklyReport));

    //     refreshData({
    //         weekInfo: this.weeklyReport.Weeks__c,
    //         storeId: this.weeklyReport.Shop__c,
    //         ReportConfigurationId: this.weeklyReport.ReportConfiguration__c
    //     }).then(data => {
    //         if (data.isSuccess) {
    //             this.displayUnitList = data.data.displayUnitList;
    //             if (data.data.haveCreated) {
    //                 this.weeklyReport = data.data.weeklyReport;
    //                 this.recordId = this.weeklyReport.Id;
    //                 // this.goToComponent('c__LWCWrapper', {
    //                 //     'lwcName': 'WeeklyReportLwc',
    //                 //     'recordId': this.weeklyReport.Id
    //                 // });
    //             } else {
    //                 this.recordId = null;
    //                 this.weeklyReport.Id = null;
    //                 this.weeklyReport.Status__c = 'New';
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
            if (thisUnitName == 'Store View') {
                this.allRef[thisUnitName].addStoreViewItem();
            } else {
                this.allRef[thisUnitName].itemAddHandler();
            }
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
                // 模块信息保存完毕, 更新周报状态
                this.weeklyReport.Saved__c = true;
                console.log('this.weeklyReport :' + JSON.stringify(this.weeklyReport));
                saveData({
                    recordJson: JSON.stringify(this.weeklyReport)
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