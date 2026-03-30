import { LightningElement, track } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'

import PromoterHomePage_MonthTarget from '@salesforce/label/c.PromoterHomePage_MonthTarget';
import PromoterHomePage_MTDSales from '@salesforce/label/c.PromoterHomePage_MTDSales';
import PromoterHomePage_MTDCompleteRatio from '@salesforce/label/c.PromoterHomePage_MTDCompleteRatio';

import getInitData from '@salesforce/apex/SalesVSTargetController.getInitData';

export default class SalesVSTargetLwc extends LightningNavigationElement {

    @track target;
    @track allSales;
    @track completedSales;
    @track completionRate;
    @track userCurrency;
    @track salesRegion;
    @track isTargetShowString = false;
    @track targetShowString = '';
    @track isSalesShowString = false;
    @track salesShowString = '';
    @track label = {
        PromoterHomePage_MonthTarget,
        PromoterHomePage_MTDSales,
        PromoterHomePage_MTDCompleteRatio,
    };

    connectedCallback() {
        this.isShowSpinner = true;
        getInitData({

        }).then(data => {
            if (data.isSuccess) {
                this.target = data.data.target;
                this.allSales = data.data.allSales;
                this.completedSales = data.data.completedSales;
                this.userCurrency = data.data.userCurrency;
                this.salesRegion = data.data.salesRegion;
                // if(this.salesRegion == 'Hisense Indonesia') {
                //     this.target /= 1000;
                //     this.allSales /= 1000;
                //     this.showK = true;
                // }
                if (this.target == 0.0) {
                    this.completionRate = '100%';
                } else {
                    // this.completionRate = Math.round((this.completedSales / this.target) * 10000) / 100 + '%';
                    this.completionRate = Math.round((this.allSales / this.target) * 10000) / 100 + '%';
                }

                if(this.target >= 1000000) {
                    this.target = this.toMoney(this.target / 1000);
                    this.isTargetShowString = true;
                    this.targetShowString = 'K';
                } else if(this.target >= 1000000000) {
                    this.target = this.toMoney(this.target / 1000000);
                    this.isTargetShowString = true;
                    this.targetShowString = 'M';
                } else {
                    this.target = this.toMoney(this.target);
                }
                if(this.allSales >= 1000000) {
                    this.allSales = this.toMoney(this.allSales / 1000);
                    this.isSalesShowString = true;
                    this.salesShowString = 'K';
                } else if(this.allSales >= 1000000000) {
                    this.allSales = this.toMoney(this.allSales / 1000000);
                    this.isSalesShowString = true;
                    this.salesShowString = 'M';
                } else {
                    his.allSales = this.toMoney(this.allSales);
                }
                console.log('completionRate：' + this.completionRate);
            }
            this.isShowSpinner = false;
        }).catch(error => {
            console.log('getInitData error：', error);
            this.isShowSpinner = false;
        });

    }


    toMoney(num){
        num = num.toFixed(2);
        num = parseFloat(num);
        num = num.toLocaleString();
        console.log('toMoney：' + num);
        return num;
    }

    gotoDailySalesRecordList() {
        this.goToVf('/lightning/n/Daily_Sales_Pro');
    }
}