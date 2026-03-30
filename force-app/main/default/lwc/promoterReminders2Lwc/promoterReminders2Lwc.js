import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { LightningNavigationElement } from 'c/lwcUtils';

import CheckInCheckOut_More from '@salesforce/label/c.CheckInCheckOut_More';
import PromoterHomePage_ToDoList from '@salesforce/label/c.PromoterHomePage_ToDoList';
import PromoterHomePage_DailyReport from '@salesforce/label/c.PromoterHomePage_DailyReport';

import Weekly_Report_Title from '@salesforce/label/c.Weekly_Report_Title';
import Monthly_Report_Title from '@salesforce/label/c.Monthly_Report_Title';


import getInitData from '@salesforce/apex/PromoterRemindersController2.getInitData';

export default class PromoterReminders2Lwc extends LightningNavigationElement {

    @track salesRegion;
    @track showToDoList = false;
    @track needCheckIn = false;
    @track needCheckOut = false;
    @track haveReport = false;
    @track haveWeeklyReport = false;
    @track haveMonthlyReport = false;
    @track isShowSpinner = false;

    @track reportList = [];
    @track weeklyReportList = [];
    @track monthlyReportList = [];

    @track label = {
        CheckInCheckOut_More,
        PromoterHomePage_ToDoList,
        PromoterHomePage_DailyReport,
        Weekly_Report_Title,
        Monthly_Report_Title
    };

    connectedCallback() {
        this.isShowSpinner = true;
        getInitData({

        }).then(data => {
            if (data.isSuccess) {
                // console.log(JSON.stringify(data.data));
                for (let key in data.data) {
                    this[key] = data.data[key];
                }

                this.showToDoList = this.needCheckIn || this.needCheckOut;
                this.haveWeeklyReport = (this.weeklyReports.length != 0);
                this.haveMonthlyReport = (this.monthlyReports.length != 0);

                if ((this.reports.length > 0) && (this.salesRegion != 'Hisense Chile')) {
                    this.haveReport = true;
                }

                // daliy report
                this.reportList = this.sort(this.reports);

                // weekly report
                this.weeklyReportList =  this.sort(this.weeklyReports);

                // monthly report
                this.monthlyReportList =  this.sort(this.monthlyReports);
            }
            this.isShowSpinner = false;
        }).catch(error => {
            console.log('getInitData error : ', error);
            this.isShowSpinner = false;
        });

    }

    sort(sortList) {
        sortList.forEach((item, i) => {
            item.index = i;
        });
        if (sortList.length > 0) {
            let allReport = sortList.sort((a, b) => {
                if (a.storeDate > b.storeDate) {
                    return -1;
                }
                if (a.storeDate < b.storeDate) {
                    return 1;
                }
                return 0;
            }).sort((a, b) => {
                if (a.status > b.status) {
                    return -1;
                }
                if (a.status < b.status) {
                    return 1;
                }
                return 0;
            });

            if (allReport.length > 3) {
                sortList = allReport.slice(0, 3);
            } else {
                sortList = allReport;
            }
        }
        return sortList;
    }

    handleButtonClick(event) {
        const storeId = event.currentTarget.dataset.id;
        const reportDate = event.currentTarget.dataset.reportDate;
        const tabName = event.currentTarget.dataset.name;
        const type = event.currentTarget.dataset.type;
        console.log('tabName : ' + tabName);
        console.log('storeId : ' + storeId);
        console.log('reportDate : ' + reportDate);
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__navItemPage',
        //     attributes: {
        //         apiName: tabName
        //     }
        // });

        if (type == 'object') {
            this.goToObject(tabName);
        } else {
            this.goToComponent('c__LWCWrapper', {
                'lwcName': tabName,
                'recordId': '',
                'shopId': storeId,
                'reportDate': reportDate,
                'weekInfo': reportDate,
                'monthInfo': reportDate
            });
        }
    }

}