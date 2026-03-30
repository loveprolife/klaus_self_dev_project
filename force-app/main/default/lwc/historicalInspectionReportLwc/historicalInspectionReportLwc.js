import { LightningElement,track,api,wire} from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import init from '@salesforce/apex/HistoricalInspectionReportController.init';

import INSPECTION_REPORT_GENERAL from '@salesforce/label/c.INSPECTION_REPORT_GENERAL';
import INSPECTION_REPORT_ATTACHMENT from '@salesforce/label/c.INSPECTION_REPORT_ATTACHMENT';
import HISTORICAL_INSPECTION_REPORT_REPORT_NUll from '@salesforce/label/c.HISTORICAL_INSPECTION_REPORT_REPORT_NUll';
import HISTORICAL_INSPECTION_REPORT_CHECKITEM_NUll from '@salesforce/label/c.HISTORICAL_INSPECTION_REPORT_CHECKITEM_NUll';

import HISTORICAL_INSPECTION_REPORT_Ticket_NUll from '@salesforce/label/c.HISTORICAL_INSPECTION_REPORT_Ticket_NUll';
import INSPECTION_REPORT_CHECK_ITEM_ISSUES from '@salesforce/label/c.INSPECTION_REPORT_CHECK_ITEM_ISSUES';
import PromoterDailyReport_TICKET from '@salesforce/label/c.PromoterDailyReport_TICKET';


export default class HistoricalInspectionReportLwc extends LightningElement {
    label = {
        INSPECTION_REPORT_GENERAL,          // 通用清单
        INSPECTION_REPORT_ATTACHMENT,       // 附件
        HISTORICAL_INSPECTION_REPORT_REPORT_NUll,       // 日报为空
        HISTORICAL_INSPECTION_REPORT_CHECKITEM_NUll,    // Check Item 为空

        HISTORICAL_INSPECTION_REPORT_Ticket_NUll,   // Ticket 为空
        INSPECTION_REPORT_CHECK_ITEM_ISSUES,
        PromoterDailyReport_TICKET
    }
    @api ownerId = '';
    @api reportDate = '';
    @api storeId = '';

    @track isShowSpinner = true;
    @track isShowModal = false;
    @track checkItemId = '';
    @track inspectionReport = {};
    get inspectionReportIsNull() {
        if (this.inspectionReport.Id) {
            return false;
        } else {
            return true;
        }
    }
    @track CheckResultInfoList = [];
    get CheckResultInfoListIsNull() {
        if (this.CheckResultInfoList.length==0) {
            return true;
        } else {
            return false;
        }
    }

    @track productLineValueSort = [];

    @track HistoricalTicketListIsNull = true;
    @track ticketFieldLabel = {};
    @track historicalTicketList = [];
    @track isShowDepartment = false;
    @track activeSections = ['checkItem', 'ticket'];
    
    /**
     * 初始化 CheckResult__c 标签
     */
    @track checkResultInfo = {
        Comments__c: '',
        Result__c: '',
    };
    @wire(getObjectInfo, { objectApiName: 'CheckResult__c' })
    wiredCheckResultInfo({ error, data }) {
        if (data) {
            this.checkResultInfo = {
                Comments__c: data.fields.Comments__c.label,
                Result__c: data.fields.Result__c.label
            }
        } else if (error) {
            console.log(error);
            this.showError('CheckResult__c getInformation error');
        }
    }

    @track checkItemInfo = {
        Description__c: ''
    };
    @wire(getObjectInfo, { objectApiName: 'CheckItem__c' })
    wiredCheckItemInfo({ error, data }) {
        if (data) {
            this.checkItemInfo = {
                Description__c: data.fields.Description__c.label
            }
        } else if (error) {
            console.log(error);
            this.showError('CheckResult__c getInformation error');
        }
    }
    /**
     * 初始化 Sampling_Inspection__c 标签
     */
    @track samplingInspectionInfo = {
        ReRe__c: '',
    };
    @wire(getObjectInfo, { objectApiName: 'Sampling_Inspection__c' })
    wiredSamplingInspectionInfo({ error, data }) {
        if (data) {
            this.samplingInspectionInfo = {
                ReRe__c: data.fields.ReRe__c.label,
            }
        } else if (error) {
            console.log(error);
            this.showError('Sampling_Inspection__c getInformation error');
        }
    }
    /**
     * 初始化 Product__c 标签
     */
    @track productInfo = {
        Product_Line__c: '',
        Series__c: '',
        Category__c: '',
    };
    @wire(getObjectInfo, { objectApiName: 'Product__c' })
    wiredProductInfo({ error, data }) {
        if (data) {
            this.productInfo = {
                Product_Line__c: data.fields.Product_Line__c.label,
                Series__c: data.fields.Series__c.label,
                Category__c: data.fields.Category__c.label,
            }
        } else if (error) {
            console.log(error);
            this.showError('Product__c getInformation error');
        }
    }

    @wire(
        init,{
            ownerId : '$ownerId',
            reportDate: '$reportDate',
            storeId: '$storeId'
        })
        getInit(value){
            let data = value.data;
            let error = value.error;
            if (data) {
                console.log(JSON.stringify(data));
                if (data.isSuccess) {
                    if (data.data.inspectionReport) {
                        this.inspectionReport = data.data.inspectionReport;
                    }
                    console.log('this.inspectionReport.Id: ' + this.inspectionReport.Id);
                    if (data.data.productLineValueSort) {
                        this.productLineValueSort = data.data.productLineValueSort;
                    }
                    if (data.data.CheckResultList) {
                        this.dataFormat(JSON.parse(JSON.stringify(data.data.CheckResultList)));
                    }

                    if(data.data.historicalTicketList && data.data.historicalTicketList.length > 0) {
                        // this.historicalTicketList = data.data.historicalTicketList;
                        for (let index = 0; index < data.data.historicalTicketList.length; index++) {
                            this.historicalTicketList.push(JSON.parse(JSON.stringify(data.data.historicalTicketList[index])));
                            this.historicalTicketList[index].className = "slds-table slds-table_bordered slds-table_fixed-layout slds-resizable "  + (index % 2 ? 'table-even' : 'table-odd');
                        }
                        
                        this.ticketFieldLabel = data.data.ticketFieldLabel;
                        this.HistoricalTicketListIsNull = false;
                        this.isShowDepartment = (data.data.userRegion == 'Hisense Chile') || (data.data.userRegion == 'Hisense South Africa');
                    }
                } else {
                    console.log('(data.message---> ' + JSON.stringify(data.message));
                }
            } else if (error) {
                console.log('(error---> ' + JSON.stringify(error));
            }
            this.isShowSpinner = false;
        };

    dataFormat(data) {
        // data.sort((a,b) => a.CheckItem__r.Is_Related_To_Product__c - b.CheckItem__r.Is_Related_To_Product__c);

        var crInfoList = []
        for (let i = 0; i < data.length; i++) {
            var cr = data[i];
            var item_1 = {
                productLine : '',
                project : []
            };

            if (cr.CheckItem__r.Product_Line__c) {
                // 存在产品线情况
                var find_1 = crInfoList.find(obj => obj.productLine == cr.CheckItem__r.Product_Line__c);
                if (find_1) {
                    item_1 = find_1;
                } else {
                    item_1.productLine = cr.CheckItem__r.Product_Line__c;
                    crInfoList.push(item_1);
                }
                if (cr.CheckItem__r.Is_Related_To_Product__c) {
                    // 产品题目
                    var item_2 = {
                        projectName : 'Product Related',
                        isProject : false,
                        product : []
                    }
                    var find_2 = item_1.project.find(obj => obj.projectName == 'Product Related');
                    if (find_2) {
                        item_2 = find_2;
                    } else {
                        item_2.projectName = 'Product Related';
                        item_1.project.push(item_2);
                    }

                    var item_3 = {
                        productId : '',
                        productName : '',
                        productCategory : '',
                        productSeries : '',
                        isChecked : true,
                        rere : '',
                        checkItem : []
                    }
                    var find_3 = item_2.product.find(obj => obj.productId == cr.Sampling_Inspection__r.Product__c);
                    if (find_3) {
                        item_3 = find_3
                    } else {
                        item_3.productId = cr.Sampling_Inspection__r.Product__c;
                        item_3.productName = cr.Sampling_Inspection__r.Product__r.Name;
                        item_3.productCategory = cr.Sampling_Inspection__r.Product__r.Category__c;
                        item_3.productSeries = cr.Sampling_Inspection__r.Product__r.Series__c;
                        item_3.isChecked = cr.Sampling_Inspection__r.Placement_Status__c;
                        item_3.rere = cr.Sampling_Inspection__r.ReRe__c;
                        item_2.product.push(item_3);
                    }
                    item_3.checkItem.push(this.checkItemFormat(cr));
                } else if (cr.CheckItem__r.Project__c) {
                    // 非产品题目
                    var item_2 = {
                        projectName : '',
                        isProject : true,
                        checkItem : []
                    }
                    var find_2 = item_1.project.find(obj => obj.projectName == cr.CheckItem__r.Project__c);
                    if (find_2) {
                        item_2 = find_2;
                    } else {
                        item_2.projectName = cr.CheckItem__r.Project__c;
                        item_1.project.push(item_2);
                    }
                    item_2.checkItem.push(this.checkItemFormat(cr));
                }
            } else {
                // GENERAL 情况（无产品线）
                var find_1 = crInfoList.find(obj => obj.productLine == this.label.INSPECTION_REPORT_GENERAL);
                if (find_1) {
                    item_1 = find_1;
                } else {
                    item_1.productLine = this.label.INSPECTION_REPORT_GENERAL;
                    crInfoList.push(item_1);
                }

                if ((!cr.CheckItem__r.Is_Related_To_Product__c) && cr.CheckItem__r.Project__c) {
                    var item_2 = {
                        projectName : '',
                        isProject : true,
                        checkItem : []
                    }
                    var find_2 = item_1.project.find(obj => obj.projectName == cr.CheckItem__r.Project__c);
                    if (find_2) {
                        item_2 = find_2;
                    } else {
                        item_2.projectName = cr.CheckItem__r.Project__c;
                        item_1.project.push(item_2);
                    }
                    item_2.checkItem.push(this.checkItemFormat(cr));
                }
            }
        }

        // 排序
        var productLineSort = [];
        productLineSort.push(this.label.INSPECTION_REPORT_GENERAL);
        this.productLineValueSort.forEach(obj => {
            productLineSort.push(obj.label);
        });
        crInfoList.sort((a, b) => {
            const indexA = productLineSort.indexOf(a.productLine);
            const indexB = productLineSort.indexOf(b.productLine);
            return indexA - indexB;
        });

        let itemIndex = 1;
        for(let infoIndex=0; infoIndex < crInfoList.length; infoIndex++) {
            for(let i=0; i < crInfoList[infoIndex].project.length; i++) {
              let currentList = [];
              if(crInfoList[infoIndex].project[i].isProject) {
                  currentList = crInfoList[infoIndex].project[i].checkItem;
              } else {
                for(let productIndex=0; productIndex < crInfoList[infoIndex].project[i].product.length; productIndex++) {
                    currentList = currentList.concat(crInfoList[infoIndex].project[i].product[productIndex].checkItem);
                }
              }
              for(let index=0; index < currentList.length; index++) {
                  currentList[index].index = itemIndex;
                  currentList[index].className = "slds-table slds-table_bordered slds-table_fixed-layout slds-resizable "  + (itemIndex % 2 ? 'table-odd' : 'table-even') 
                  itemIndex += 1;
              }
            }  
        }
        

        this.CheckResultInfoList = crInfoList;
    }
    
    checkItemFormat(cr) {
        if (cr.CheckItem__r.IsYesOrNo__c) {
            
            if (cr.Scores__c == -1) {
                cr['styleYes'] = 'background: white; color: black; width: 50%;';
                cr['styleNo'] = 'background: white; color: black; width: 50%;';
            } else if (cr.Scores__c == 0) {
                cr['styleYes'] = 'background: white; color: black; width: 50%;';
                cr['styleNo'] = 'width: 50%;';
            } else {
                cr['styleYes'] = 'width: 50%;';
                cr['styleNo'] = 'background: white; color: black; width: 50%;';
            }
        } else {
            var styles = [];
            var buttonwidth = Math.floor(100/Number(cr.CheckItem__r.MaximumScore__c));
            for (let s = 0; s <= Number(cr.CheckItem__r.MaximumScore__c); s++) {
                if (cr.Scores__c == s) {
                    styles.push({
                        'buttonNumber' : s,
                        'style' : 'width: '+buttonwidth+'%;',
                    });
                } else {
                    styles.push({
                        'buttonNumber' : s,
                        'style' : 'background: white; color: black;'+'width: '+buttonwidth+'%;',
                    });
                }
            }
            cr['styles'] = styles;
        }

        return cr;
    }

    closeModal() {
        // this.isShowModal = false;
    }

    checkItemClick(event) {
        // this.checkItemId = event.currentTarget.dataset.id;
        // this.isShowModal = true;
    }
}