import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { LightningNavigationElement } from 'c/lwcUtils';

import CheckInCheckOut_More from '@salesforce/label/c.CheckInCheckOut_More';
import PromoterHomePage_ToDoList from '@salesforce/label/c.PromoterHomePage_ToDoList';
import PromoterHomePage_DailyReport from '@salesforce/label/c.PromoterHomePage_DailyReport';
import PromoterHomePage_WeeklyIntelligence from '@salesforce/label/c.PromoterHomePage_WeeklyIntelligence';
import PromoterHomePage_WeeklyMarketInsight from '@salesforce/label/c.PromoterHomePage_WeeklyMarketInsight';
import PromoterHomePage_StockShareinThisMonth from '@salesforce/label/c.PromoterHomePage_StockShareinThisMonth';
import PromoterHomePage_ShelfShareinThisMonth from '@salesforce/label/c.PromoterHomePage_ShelfShareinThisMonth';

import getInitData from '@salesforce/apex/PromoterRemindersController.getInitData';

export default class PromoterRemindersLwc extends LightningNavigationElement {

    @track noReport = false;
    @track noMarket = false;
    @track noResearch = false;
    @track salesRegion;
    @track showToDoList = false;
    @track intelligenceList = [];
    @track marketInsightList = [];
    @track inhouseShareList = [];
    @track shelfShareList = [];
    @track reportList = [];
    @track isShowSpinner = false;
    @track label = {
        CheckInCheckOut_More,
        PromoterHomePage_ToDoList,
        PromoterHomePage_DailyReport,
        PromoterHomePage_WeeklyIntelligence,
        PromoterHomePage_WeeklyMarketInsight,
        PromoterHomePage_StockShareinThisMonth,
        PromoterHomePage_ShelfShareinThisMonth,
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

                if ((this.reports.length > 0) && (this.salesRegion != 'Hisense Chile')) {
                    this.noReport = true;
                }
                console.log('this.reports.length：' + this.reports.length);
                console.log('this.salesRegion：' + this.salesRegion);
                console.log('this.noReport：' + this.noReport);

                // daliy report
                this.reports.forEach((item, i) => {
                    item.index = i;
                });
                if (this.reports.length > 0) {
                    let allReport = this.reports.sort((a, b) => {
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

                    // let allReport = viewReport.concat(newReport);
                    if (allReport.length > 3) {
                        this.reportList = allReport.slice(0, 3);
                    } else {
                        this.reportList = allReport;
                    }
                    // this.reportList = allReport;

                }

                // intelligence
                this.markets.forEach((item, i) => {
                    item.index = i;
                });
                if (this.markets.length > 0) {
                    let newIntelligence = this.markets.filter(item => item.status == 'New').sort((a, b) => {
                        if (a.storeDate > b.storeDate) {
                            return -1;
                        }
                        if (a.storeDate < b.storeDate) {
                            return 1;
                        }
                        return 0;
                    });
                    let viewIntelligence = this.markets.filter(item => item.status == 'View').sort((a, b) => {
                        if (a.storeDate > b.storeDate) {
                            return -1;
                        }
                        if (a.storeDate < b.storeDate) {
                            return 1;
                        }
                        return 0;
                    });

                    let allIntelligence = viewIntelligence.concat(newIntelligence);
                    if (allIntelligence.length > 3) {
                        this.intelligenceList = allIntelligence.slice(0, 3);
                    } else {
                        this.intelligenceList = allIntelligence;
                    }

                }

                // market insight
                this.marketInsights.forEach((item, i) => {
                    item.index = i;
                });
                console.log('this.marketInsights：' + this.marketInsights.length);
                if (this.marketInsights.length > 0) {
                    let newMarketInsight = this.marketInsights.filter(item => item.status == 'New').sort((a, b) => {
                        if (a.storeDate > b.storeDate) {
                            return -1;
                        }
                        if (a.storeDate < b.storeDate) {
                            return 1;
                        }
                        return 0;
                    });
                    let viewMarketInsight = this.marketInsights.filter(item => item.status == 'View').sort((a, b) => {
                        if (a.storeDate > b.storeDate) {
                            return -1;
                        }
                        if (a.storeDate < b.storeDate) {
                            return 1;
                        }
                        return 0;
                    });

                    let allMarketInsight = viewMarketInsight.concat(newMarketInsight);
                    if (allMarketInsight.length > 3) {
                        this.marketInsightList = allMarketInsight.slice(0, 3);
                    } else {
                        this.marketInsightList = allMarketInsight;
                    }
                }

                // stock share
                this.marketInHouseShares.forEach((item, i) => {
                    item.index = i;
                });
                if (this.marketInHouseShares.length > 0) {
                    let newInHouseShare = this.marketInHouseShares.filter(item => item.status == 'New').sort((a, b) => {
                        if (a.storeDate > b.storeDate) {
                            return -1;
                        }
                        if (a.storeDate < b.storeDate) {
                            return 1;
                        }
                        return 0;
                    });
                    let viewInHouseShare = this.marketInHouseShares.filter(item => item.status == 'View').sort((a, b) => {
                        if (a.storeDate > b.storeDate) {
                            return -1;
                        }
                        if (a.storeDate < b.storeDate) {
                            return 1;
                        }
                        return 0;
                    });

                    let allInHouseShare = viewInHouseShare.concat(newInHouseShare);
                    if (allInHouseShare.length > 3) {
                        this.inhouseShareList = allInHouseShare.slice(0, 3);
                    } else {
                        this.inhouseShareList = allInHouseShare;
                    }
                }

                // shelf share
                this.marketShelfShares.forEach((item, i) => {
                    item.index = i;
                });
                if (this.marketShelfShares.length > 0) {
                    let newShelfShare = this.marketShelfShares.filter(item => item.status == 'New').sort((a, b) => {
                        if (a.storeDate > b.storeDate) {
                            return -1;
                        }
                        if (a.storeDate < b.storeDate) {
                            return 1;
                        }
                        return 0;
                    });
                    let viewShelfShare = this.marketShelfShares.filter(item => item.status == 'View').sort((a, b) => {
                        if (a.storeDate > b.storeDate) {
                            return -1;
                        }
                        if (a.storeDate < b.storeDate) {
                            return 1;
                        }
                        return 0;
                    });

                    let allShelfShare = viewShelfShare.concat(newShelfShare);
                    if (allShelfShare.length > 3) {
                        this.shelfShareList = allShelfShare.slice(0, 3);
                    } else {
                        this.shelfShareList = allShelfShare;
                    }
                }

            }
            this.isShowSpinner = false;
        }).catch(error => {
            console.log('getInitData error：', error);
            this.isShowSpinner = false;
        });

    }

    handleButtonClick(event) {
        const storeId = event.currentTarget.dataset.id;
        const reportDate = event.currentTarget.dataset.reportDate;
        const tabName = event.currentTarget.dataset.name;
        const type = event.currentTarget.dataset.type;
        console.log('tabName：' + tabName);
        console.log('storeId：' + storeId);
        console.log('reportDate：' + reportDate);
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
            });
        }



        

    }
}