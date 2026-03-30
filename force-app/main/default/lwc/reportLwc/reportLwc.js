/*
 * @Author: WFC
 * @Date: 2024-03-19 16:22:58
 * @LastEditors: WFC
 * @LastEditTime: 2024-05-09 10:55:33
 * @Description: 
 * @FilePath: \HisenseAll20240426\force-app\main\default\lwc\reportLwc\reportLwc.js
 */
import { LightningElement, track, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import timeZone from '@salesforce/i18n/timeZone';

import getReportCustomData from '@salesforce/apex/ReportCustomeController.getReportCustomData';
import updateReportCustom from '@salesforce/apex/ReportCustomeController.updateReportCustom';
import { refreshApex } from '@salesforce/apex';

var timeIntervalInstance;

export default class ReportLwc extends LightningNavigationElement {
    @track data = [];
    @track columns;
    @track wiredResult = '';
    @track rowErrorShow;
    @track updateId = [];
    constructor() {
        super();
        this.columns = [
            { label: '报表名称', fieldName: 'Report_Name__c',},
            { label: '报表地址', fieldName: 'Report_Url__c', type: 'url',
                typeAttributes:{
                    target : '_blank'
                } 
            },
            { label: '更新状态', fieldName: 'Report_Status__c',
                cellAttributes: {
                    class: { fieldName: 'Text_Class__c' },
                },
            },
            { label: '最后一次更新时间', fieldName: 'Last_Update_Time__c', type: 'date',
                typeAttributes:{
                    year: "numeric",
                    month: "numeric",
                    day: "numeric",
                    hour: "2-digit",
                    minute: "2-digit",
                    hour12: true,
                    timeZone: timeZone,
                }
            },
            { type: "button", label: "操作", 
                typeAttributes: {  
                    label: 'Execution Report',  
                    name: 'Execution Report',  
                    title: 'Execution Report',  
                    disabled: {fieldName: 'Disabled__c'}, 
                    value: 'Execution Report',  
                    iconPosition: 'left',
                    variant: "brand",
            } },

        ];
    }

    rows = {};
    rowError = {};
    @wire(getReportCustomData)
    getDocuments(result) {
        this.wiredResult = result;
        if (result.data) {
            this.data = result.data;
            
            if(this.updateId.length > 0){
                for(let item of this.data){
                    if(this.updateId.indexOf(item.Id) != -1 && item.Report_Status__c == 'Update complete'){
                        // 报表执行结束
                        this.updateId = this.updateId.filter(itemId => itemId != item.Id)
                        this.showSuccess('报表已生成---' + item.Report_Name__c);
                    //     // 表头提示
                    //     let row = {};
                    //     let messages = [];
                    //     let fieldNames = [];
                    //     fieldNames.push('Report_Name__c');
                    //     row['title'] = '报表生成结束';
                    //     row['messages'] = messages;
                    //     row['fieldNames'] = fieldNames;
                    //     this.rows[item.Id] = row;
                    //     this.rowError['rows'] = this.rows;
                    //     this.rowErrorShow = this.rowError;
                    //     console.log('wwww---' + JSON.stringify(this.rowErrorShow));
                    }
                }
                // 没有要更新的报表 则删除定时器
                if(this.updateId.length == 0){
                    clearInterval(timeIntervalInstance);
                }
            }
        }
    }

    connectedCallback(){

    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        console.log('wwww---row--' + JSON.stringify(row));
        console.log('wwww---action--' + JSON.stringify(action));
        if(row.Report_Status__c == 'Updating'){
            this.showError('报表正在生成中……');
        }else {
            updateReportCustom({
                row : row
            }).then(data => {
                console.log('wwww---' + data);
                if(data){
                    this.showSuccess('报表正在生成中……');
                    
                    timeIntervalInstance = setInterval(() => {
                        refreshApex(this.wiredResult);
                    }, 1000);

                    this.updateId.push(row.Id);
                    
                    // 重新生成报表 删除已经有的提示信息
                    // if(this.rowErrorShow != null && this.rowErrorShow != '' && this.rowErrorShow != undefined){
                    //     delete this.rowError['rows'][row.Id];
                    //     this.rowErrorShow = this.rowError;
                    // }
                }
            }).catch(error => {
                this.showError('生成报表报错！请联系管理员');
            });
        }
    }
}