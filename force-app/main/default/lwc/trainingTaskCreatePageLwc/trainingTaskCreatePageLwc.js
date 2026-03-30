/*
 * @Author: WFC
 * @Date: 2024-04-03 11:13:31
 * @LastEditors: WFC
 * @LastEditTime: 2024-05-10 09:42:32
 * @Description: 
 * @FilePath: \HisenseAll20240426\force-app\main\default\lwc\trainingTaskCreatePageLwc\trainingTaskCreatePageLwc.js
 */
import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import getTrainingData from '@salesforce/apex/TrainingController.getTrainingData';
import getPickList from '@salesforce/apex/TrainingController.getPickList';

export default class TrainingTaskCreatePageLwc extends NavigationMixin(LightningElement) {

    @track trainingData = []
    @track columns = [];
    @track training = {};

    @track valueYear = '';
    @track valueMonth = '';

    @track isShowSpinner = false;
    @track showButton = true;

    @wire(getPickList, {objectName : 'Training__c', fieldName : 'Year__c'})
    optionsYear;

    @wire(getPickList, {objectName : 'Training__c', fieldName : 'Month__c'})
    optionsMonth;

    @wire(getObjectInfo, { objectApiName: 'Training__c' })
    wiredEDICustomerInfo({ error, data }) {
        if (data) {
            var patch = (window.screen.width) / 10;
            this.columns = [
                // { label: data.fields.Name.label, fieldName: data.fields.Name.apiName, sortable: true,     },
                { label: data.fields.Year__c.label, fieldName: data.fields.Year__c.apiName, sortable: true, initialWidth: patch*2},
                { label: data.fields.Month__c.label, fieldName: data.fields.Month__c.apiName, sortable: true, initialWidth: patch*2},
                { label: data.fields.Training_Theme__c.label, fieldName: data.fields.Training_Theme__c.apiName, sortable: true, initialWidth: patch*5, wrapText: true},
                // { label: data.fields.Training_Type__c.label,            fieldName: data.fields.Training_Type__c.apiName,                sortable: true,     },
                // { label: data.fields.Training_Classification__c.label,  fieldName: data.fields.Training_Classification__c.apiName,      sortable: true,     },
                // { label: data.fields.Product_Line__c.label,             fieldName: data.fields.Product_Line__c.apiName,                 sortable: true,     },
                // { label: data.fields.Task_Number__c.label,              fieldName: data.fields.Task_Number__c.apiName,                  sortable: true,     },
                // { label: data.fields.Pre_effective_Number__c.label,     fieldName: data.fields.Pre_effective_Number__c.apiName,         sortable: true,     },
                // { label: data.fields.Effective_Number__c.label,         fieldName: data.fields.Effective_Number__c.apiName,             sortable: true,     },
                // { label: data.fields.Rate_of_Completion__c.label,       fieldName: data.fields.Rate_of_Completion__c.apiName,           sortable: true,     },
            ];

        } else if (error) {
            console.log(error);
            this.showError('Training__c getInformation error');
        }
    }

    get isPc() {
        var userAgent = navigator.userAgent;
        if (/iphone|iPhone|ipad|iPad|ipod|iPod|iOS|ios/.test(userAgent) || /android|Android/.test(userAgent)) {  
            return false;
        } else { 
            return true; 
        }
    }

    connectedCallback(){
        // 初始化数据
        this.initTrainingData();

    }

    initTrainingData(){
        this.isShowSpinner = true;
        getTrainingData({
            valueYear : this.valueYear,
            valueMonth : this.valueMonth,
        }).then(data => {
            this.isShowSpinner = false;
            // 初始化排序
            this.sortDirection = 'asc';
            this.sortedBy = 'name';

            this.trainingData = data;
        }).catch(error => {
            this.isShowSpinner = false;
        });
    }

    // 选择一条培训数据
    handleChangeTraining(event) {
        this.training = event.detail.selectedRows[0];
        this.showButton = false;
    }

    // 选择年
    handleChangeYear(event) {
        this.valueYear = event.detail.value;
    }
    // 选择月
    handleChangeMonth(event) {
        this.valueMonth = event.detail.value;
    }

    // 点击搜索按钮
    handleSearch(event){
        this.initTrainingData();
    }

    // 点击返回按钮
    handleCancel(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName   :   'Training_Tasks__c',
                actionName      :   'home'
            }
        });
    }

    // 点击下一步
    handleNext(){
        let fieldValues = [];
        fieldValues.push('Training__c=' + this.training.Id);

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName   :   'Training_Tasks__c',
                actionName      :   'new'
            },
            state: {
                defaultFieldValues : fieldValues.join(','),
                nooverride: '1',
                // recordTypeId: this.recordTypeId,
            }
        });
    }

    // 排序
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy = 'Name';

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            if(a == undefined){
                a = '';
            }
            if(b == undefined){
                b = '';
            }
            return reverse * ((a > b) - (b > a)); 
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.trainingData];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.trainingData = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    
}