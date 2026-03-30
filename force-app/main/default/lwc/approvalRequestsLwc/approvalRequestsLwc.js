/*
 * @Author: WFC
 * @Date: 2024-02-20 10:59:10
 * @LastEditors: WFC
 * @LastEditTime: 2024-03-08 16:37:00
 * @Description: 
 * @FilePath: \hisenseall-231026\force-app\main\default\lwc\approvalRequestsLwc\approvalRequestsLwc.js
 */
import { track, api, wire} from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import timeZone from '@salesforce/i18n/timeZone';

import getApprovalData from '@salesforce/apex/ApprovalRequestsController.getApprovalData';
import submitApprovalRequests from '@salesforce/apex/ApprovalRequestsController.submitApprovalRequests';
import submitVerifyApprovalRequests from '@salesforce/apex/ApprovalRequestsController.submitVerifyApprovalRequests';
// import handleTest from '@salesforce/apex/ApprovalRequestsController.handleTest';

import Approval_Details_Info from '@salesforce/label/c.Approval_Details_Info';
import Approval_Updated_Info from '@salesforce/label/c.Approval_Updated_Info';
import Approval_Details_Info_Filter from '@salesforce/label/c.Approval_Details_Info_Filter';

var timeIntervalInstance;

const actions = [
    { label: 'Approve', name: 'approve' },
    { label: 'Reject', name: 'reject' },
    { label: 'Reassign', name: 'reassign' },
    { label: 'View Approval Request', name: 'viewApprovalRequest' },
    { label: 'View Customer', name: 'viewObject' },
];

const columns = [
    { label: 'Related To', fieldName: 'relatedToUrl', sortable: true, type: 'url',
        typeAttributes:{
            label: { fieldName: 'relatedTo' }
        },
    },
    { label: 'Type', fieldName: 'type', sortable: true,},
    { label: 'Most Recent Approver', fieldName: 'mostRecentApproverUrl', sortable: true, type: 'url',
        typeAttributes:{
            label: { fieldName: 'mostRecentApprover' }
        }
    },
    { label: 'Date Submitted', fieldName: 'dateSubmitted', sortable: true, type: "date",
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
    { label: 'Submitter Comments', fieldName: 'comments', sortable: true,},
    { type: 'action',fixedWidth	 : 60, typeAttributes: { rowActions: actions, menuAlignment: 'auto' } }
];

const optionsType = [
    { label: 'ALL', value: 'ALL' },
    { label: 'Customer', value: 'Customer' },
];
export default class ApprovalRequestsLwc extends LightningNavigationElement {

    label = {
        Approval_Details_Info, // '{0} items • {1} selected • Sorted by {2} • Filtered by {3} •'
        Approval_Details_Info_Filter, // 'Type equals {0} •'
        Approval_Updated_Info, // 'Updated {0} minutes ago'
    }

    @track isShowSpinner = false; // 加载标记 
    @track isShowSpinnerDialog = false; // 加载显示标记 
    @track isShowDisplay = false; // 审批弹出框显示标记 
    @track isShowComments = false; // 审批Comments显示标记
    @track isShowUser = false; // 审批选择用户显示标记 
    @track isShowFilters = false; // 显示过滤条件页面
    @track buttonLabel; // 审批按钮label
    @track buttonLabelUsable = false; // 审批按钮label是否可用
    @track reassignUser; // 选择重新分配的用户
    @track approvalDataAll = []; // 列表信息总数据
    @track approvalData = []; // 列表信息
    @track totalNumberOfRows; // 列表总行数
    @track rowErrorShow;
    @track columns = columns;

    @track isBatch = true; // 点击顶部批量审批按钮还是每一行中审批按钮
    @track selectRows = []; // 批量选择列表行数据
    @track selectRow = []; // 行按钮选择数据
    @track title; // 弹出框标题
    @track comments; // 弹出框评论
    @track submitVerify = true;; // 批量提交验证

    @track valueOldType;
    @track valueNewType;
    @track optionsType = optionsType;
    @track typeList = [];

    @track enabelInfiniteLoading;// 是否启动无限加载

    // 数据信息
    refreshApprovalDataTime = 0; // 刷新列表时间
    itemsNumber = 0;
    selectedNumber = 0;
    filteredBy = 'requests assigned to me and my queues';
    detailsInfo;
    updatedInfo;

    // 手机端
    get isMobile() {
        var userAgent = navigator.userAgent;
        if (/iphone|iPhone|ipad|iPad|ipod|iPod|iOS|ios/.test(userAgent) || /android|Android/.test(userAgent)) {  
            return true;
        } else { 
            return false;
        }
    }

    constructor() {
        super();
        this.columns = [
            { label: 'Related To', fieldName: 'relatedToUrl', sortable: true, type: 'url',
                typeAttributes:{
                    label: { fieldName: 'relatedTo'},
                    tooltip: {fieldName: 'relatedTo'}   
                },
            },
            { label: 'Type', fieldName: 'type', sortable: true,

            },
            { label: 'Most Recent Approver', fieldName: 'mostRecentApproverUrl', sortable: true, type: 'url',
                typeAttributes:{
                    label: { fieldName: 'mostRecentApprover' },
                    tooltip: {fieldName: 'mostRecentApprover'}  
                }
            },
            { label: 'Date Submitted', fieldName: 'dateSubmitted', sortable: true, type: "date",
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
            // { label: 'Submitter Comments', fieldName: 'comments', sortable: true,

            // },
            {
                label: 'Submitter Comments',
                type: 'customTextType',
                typeAttributes: {
                    comments: { fieldName: 'comments' }
                },
            },             
            { type: 'action', fixedWidth : 80, 
                typeAttributes: { 
                    rowActions: this.getRowActions, 
                    menuAlignment: 'auto'
                },
            },
        ]
    }

    getRowActions(row, doneCallback) {
        const rowActions = [
            { label: 'Approve', name: 'approve' },
            { label: 'Reject', name: 'reject' },
            { label: 'Reassign', name: 'reassign' },
            { label: 'View Approval Request', name: 'viewApprovalRequest' },
            { label: 'View ' + row['type'], name: 'viewObject' },
        ];
        doneCallback(rowActions);   
        // simulate a trip to the server
        // setTimeout(() => {
        //     doneCallback(actions);
        // }, 200);
    }

    // 初始化数据
    connectedCallback(){
        // 获取审批数据
        this.initApprovalData();
    }

    // 清除赋值信息
    clearData(){
        this.approvalData = [];
        this.selectRows = [];
        this.refreshApprovalDataTime = 0;
        this.selectedNumber = 0;
        this.itemsNumber = 0;
        this.rowErrorShow = {};
        this.submitVerify = true;

        this.comments = '';
        this.reassignUser = '';
        this.buttonLabel = '';

        this.enabelInfiniteLoading = true;
    }

     // 初始化审批数据
    initApprovalData(){
        console.log('wwww--initApprovalData--' + this.valueOldType);
        clearInterval(timeIntervalInstance);
        // 清理数据
        this.clearData();
        this.isShowSpinner = true;
        // 后台查询审批数据
        getApprovalData({
            typeFilter : this.valueOldType
        }).then(data => {
            // 初始化排序
            this.sortDirection = 'desc';
            this.sortedBy = 'dateSubmitted';
            
            this.isShowSpinner = false;
            this.approvalData = JSON.parse(data.data.ApprovalData);
            this.approvalDataAll = JSON.parse(data.data.ApprovalData);
            // datatable无限滚动加载是否开启
            if(this.enabelInfiniteLoading){
                // 显示只取前50条数据
                this.approvalData = this.approvalData.slice(0, 50);
            }
            
            this.totalNumberOfRows = this.approvalDataAll.length;
            console.log('wwww--approvalData---' + JSON.stringify(data.data.ApprovalData));
            this.itemsNumber = this.approvalData.length;

            this.typeList = data.data.typeList;
            // 初始化过滤条件中type选择框
            this.initType();
            // 刷新detailsInfo
            this.refreshDetailsInfo();
            // 刷新updatedInfo
            this.refreshUpdatedInfo();
            
            console.log('wwww--initApprovalData---success');
            this.refreshApprovalDataTime = 0;
            var parentThis = this;
            timeIntervalInstance = setInterval(function() {
                parentThis.refreshApprovalDataTime =  parentThis.refreshApprovalDataTime + 1;
                parentThis.refreshUpdatedInfo();
            }, 60000);
        }).catch(error => {
            this.isShowSpinner = false;
            this.refreshApprovalDataTime = 0;
        });
    }

    // 初始化过滤条件中type选择框
    initType(){
        console.log('wwww--typeList---' + this.typeList);
        let optionTypeTemp = [];
        // let firstMap = {};
        // firstMap['label'] = 'ALL';
        // firstMap['value'] = 'ALL';
        // optionTypeTemp.push(firstMap);
        for(let item of this.typeList){
            console.log('wwww--typeList--item-' + item);
            let itemMap = {};
            itemMap['label'] = item;
            itemMap['value'] = item;
            optionTypeTemp.push(itemMap);
        }
        this.optionsType = optionTypeTemp;
    }

    // 下方鼠标滚动时加载更多数据
    loadMoreData(event) {
        console.log('wwww--loadMoreData---');
        // Display a spinner to signal that data is being loaded
        event.target.isLoading = true;
        // Display "Loading" when more data is being loaded
        // 总数据行数和现有数据行数
        if(this.approvalDataAll.length - this.approvalData.length > 50){
            // 大于50
            this.approvalData = this.approvalDataAll.slice(0, this.approvalData.length + 50);
        }else {
            // 小于等于50
            this.approvalData = this.approvalDataAll.slice(0, this.approvalDataAll.length);
            this.enabelInfiniteLoading = false;
            // event.target.enableInfiniteLoading = false;
        }
        event.target.isLoading = false;

        // 刷新updatedInfo
        clearInterval(timeIntervalInstance);
        this.refreshApprovalDataTime = 0;
        var parentThis = this;
        timeIntervalInstance = setInterval(function() {
            parentThis.refreshApprovalDataTime =  parentThis.refreshApprovalDataTime + 1;
            parentThis.refreshUpdatedInfo();
        }, 60000);
        // 刷新detailsInfo
        this.refreshDetailsInfo();
    }

    // 刷新detailsInfo
    refreshDetailsInfo() {
        console.log('wwww--refreshDetailsInfo---' + this.selectedNumber);
        let assigned = 'requests assigned to me and my queues';
        if(this.approvalDataAll.length == this.approvalData.length){
            this.itemsNumber = this.approvalDataAll.length ;
        }else {
            this.itemsNumber = this.approvalData.length + '+';
        }
        this.detailsInfo = this.label.Approval_Details_Info.format(this.itemsNumber, this.selectedNumber, this.columnsInfo[this.sortedBy], assigned);
        if(this.valueOldType != '' && this.valueOldType != null && this.valueOldType != undefined){
            this.detailsInfo = this.detailsInfo + ' ' + this.label.Approval_Details_Info_Filter.format(this.valueOldType);
        }
        console.log('wwww--refreshDetailsInfo---success' + this.detailsInfo);
    }

    // 刷新updatedInfo
    refreshUpdatedInfo() {
        console.log('wwww--refreshUpdatedInfo---' + this.refreshApprovalDataTime);
        if(this.refreshApprovalDataTime == 0){
            this.updatedInfo = 'Updated a few seconds ago';
        }else {
            this.updatedInfo = this.label.Approval_Updated_Info.format(this.refreshApprovalDataTime);
        }
        console.log('wwww--refreshUpdatedInfo---success' + this.updatedInfo);
    }

    // 点击刷新按钮
    handleRefreshClick(event){
        console.log('wwww---点击刷新按钮--');
        this.initApprovalData();
    }

    // 点击显示过滤条件页面
    handleShowFiltersClick(event){
        console.log('wwww---显示过滤条件--');
        this.isShowFilters = !this.isShowFilters;
        console.log('wwww---显示过滤条件--' + this.isShowFilters);
    }
    // 点击关闭过滤条件页面
    handleCloseFilters(event){
        console.log('wwww---关闭过滤条件--');
        this.isShowFilters = false;
    }

    // 选择过滤条件type
    handleChangeType(event){
        console.log('wwww---选择过滤条件type--');
        console.log('wwww---选择过滤条件type--' + event.target.value);
        this.valueNewType = event.target.value;
    }

    // 保存选择过滤条件type
    handleSaveType(){
        console.log('wwww---保存选择过滤条件type--');
        this.isShowFilters = false;
        if(this.valueOldType == this.valueNewType){
            return;
        }
        this.valueOldType = this.valueNewType;
        this.initApprovalData();
    }

    // 列表行选择
    handleChange(event) {
        this.selectRows = event.detail.selectedRows;
        console.log('wwww---selectRows--' + this.selectRows);
        this.selectRows.forEach(element => {
            console.log('wwww---element--' + JSON.stringify(element));
        });
        this.selectedNumber = this.selectRows.length;
        // 刷新detailsInfo
        this.refreshDetailsInfo();
    }

    // 排序 ---------------------------------------------------------------------
    @track columnsInfo = {
        relatedToUrl:           'Related To',
        type:                   'Type',
        mostRecentApproverUrl:  'Most Recent Approver',
        dateSubmitted:          'Date Submitted',
        comments:               'Submitter Comments',
    };
    defaultSortDirection = 'asc';
    sortDirection = 'desc';
    sortedBy = 'dateSubmitted';
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
            return reverse * ((a > b) - (b > a));
        };
    }
    onHandleSort(event) {
        try{
            const { fieldName: sortedBy, sortDirection } = event.detail;
            const cloneData = [...this.approvalData];
            cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));

            this.approvalData = cloneData;
            this.sortDirection = sortDirection;
            this.sortedBy = sortedBy;
            console.log('wwww--sortedBy--' + this.sortedBy);
            console.log('wwww--sortedByInfo--' + this.columnsInfo[sortedBy]);
            this.refreshDetailsInfo();
        } catch (error) {
            
        }
    }
    // --------------------------------------------------------------------------

    // Approve按钮
    handleApprove(event){
        console.log('wwww-----handleApprove-----' + this.verifySelectRows());
        // 验证选择列表行数据是否为空
        if(this.verifySelectRows()){
            this.isBatch = true;
            this.isShowDisplay = true;
            this.isShowComments = true;
            this.isShowUser = false;
            this.buttonLabelUsable = true;
            this.buttonLabel = 'Approve';
            if(this.selectRows.length > 1){
                this.title = 'Approve ' + this.selectRows.length + ' Approval Requests';
            }else {
                this.title = 'Approve ' + this.selectRows[0].type + ' - ' + this.selectRows[0].relatedTo;
            }
            
        }else {
            this.showError('Select at least one approval request and try again.');
        }
    }

    // Reject按钮
    handleReject(event){
        console.log('wwww-----handleReject-----' + this.verifySelectRows());
        // 验证选择列表行数据是否为空
        if(this.verifySelectRows()){
            this.isBatch = true;
            this.isShowDisplay = true;
            this.isShowComments = true;
            this.isShowUser = false;
            this.buttonLabelUsable = true;
            this.buttonLabel = 'Reject';
            if(this.selectRows.length > 1){
                this.title = 'Reject ' + this.selectRows.length + ' Approval Requests';
            }else {
                this.title = 'Reject ' + this.selectRows[0].type + ' - ' + this.selectRows[0].relatedTo;
            }
        }else {
            this.showError('Select at least one approval request and try again.');
        }
    }

    // Reassign按钮
    handleReassign(event){
        console.log('wwww-----handleReassign-----' + this.verifySelectRows());
        // 验证选择列表行数据是否为空
        if(this.verifySelectRows()){
            this.isBatch = true;
            this.isShowDisplay = true;
            this.isShowComments = false;
            this.isShowUser = true;
            this.buttonLabelUsable = false;
            this.buttonLabel = 'Reassign';
            if(this.selectRows.length > 1){
                this.title = 'Reassign Approval Request';
            }else {
                this.title = 'Reassign ' + this.selectRows[0].type + ' - ' + this.selectRows[0].relatedTo;
            }
        }else {
            this.showError('Select at least one approval request and try again.');
        }
    }

    // 验验证选择列表行数据是否为空
    verifySelectRows(){
        if(this.selectRows == null || this.selectRows == '' || this.selectRows == undefined){
            return false;
        }else {
            return true;
        }
    }

    // 审批comments
    commentsDataChange(event) {
        this.comments = event.target.value;
    }

    // 审批弹出框 取消按钮
    cancel(){
        console.log('wwww-----cancel-----');
        this.isShowDisplay = false;
        this.comments = '';
        this.reassignUser = '';
        this.buttonLabel = '';
    }

    rows = {};
    rowError = {};
    // 审批弹出框 提交按钮
    submit(){
        console.log('wwww-----submit-----' + this.buttonLabel);
        this.isShowSpinnerDialog = true;
        this.submitVerify = true;
        this.rows = {};
        this.rowError = {};
        let selectRowsData = [];
        if(this.isBatch){
            selectRowsData = this.selectRows;
        }else {
            selectRowsData = this.selectRow;
        }

        // 验证流程是否全部成功
        let allSelectRowsDataTemp = [];
        let selectRowsDataTemp = [];
        let i = 1;
        // 拆分每次最多147条数据(Too many DML statements: 151)
        selectRowsData.forEach(element => {
            selectRowsDataTemp.push(element);
            i = i + 1;
            if(i > 148){
                allSelectRowsDataTemp.push(selectRowsDataTemp);
                selectRowsDataTemp = [];
                i = 1;
            }
        });
        if(i > 1){
            allSelectRowsDataTemp.push(selectRowsDataTemp);
        }
        this.verifyApprovalRequests(0, allSelectRowsDataTemp, selectRowsData);
        
        
    }

    // 提交审批
    handlerSubmitApprovalRequests(selectRowsData){
        console.log('wwww-----handlerSubmitApprovalRequests-----' + selectRowsData.length);
        submitApprovalRequests({
            buttonLabel : this.buttonLabel,
            comments : this.comments,
            reassignUser : this.reassignUser,
            selectRows : JSON.stringify(selectRowsData),
        }).then(data => {
            this.isShowSpinnerDialog = false;
            this.isShowDisplay = false;
            this.comments = '';
            this.reassignUser = '';
            this.buttonLabel = '';
            this.rows = {};
            this.rowError = {};
            if(data.isSuccess){
                this.showSuccess('The selected items are approval successful.');
                this.initApprovalData();
            }else {
                this.showError('Process failure.');
                // this.rowErrorShow = {
                //     rows: {
                //             '04iHz000001QKviIAG': {
                //                 title: 'An error has occurred.',
                //                 messages: [
                //                     '错误信息',
                //                 ],
                //                 fieldNames: ['type']
                //             },
                //             '04iHz000001QKvYIAW': {
                //                 title: 'An error has occurred.',
                //                 messages: [
                //                     '错误信息',
                //                 ],
                //                 fieldNames: ['type']
                //             },
                //         }
                // };
            }
            
        }).catch(error => {
            console.log('wwwww--submitApprovalRequests--error---' + this.getErrorMessage(error));
            this.isShowSpinnerDialog = false;
            this.isShowDisplay = false;
            this.showError('Process failure. ' + this.getErrorMessage(error));
        });
    }

    // 验证审批是否全部可以通过
    verifyApprovalRequests(i, allSelectRowsDataTemp, selectRowsData){
        console.log('wwwww--verifyApprovalRequests--' + i);
        console.log('wwwww--verifyApprovalRequests--' + allSelectRowsDataTemp.length);
        console.log('wwwww--verifyApprovalRequests--' + allSelectRowsDataTemp[i].length);
        submitVerifyApprovalRequests({
            buttonLabel : this.buttonLabel,
            comments : this.comments,
            reassignUser : this.reassignUser,
            selectRows : JSON.stringify(allSelectRowsDataTemp[i]),
        }).then(data => {
            if(!data.isSuccess){
                this.submitVerify = false;
                let errorList =  JSON.parse(data.data);
                errorList.forEach(element => {
                    let row = {};
                    let messages = [];
                    let fieldNames = [];
                    messages.push(element.errorInfo);
                    fieldNames.push('type');
                    row['title'] = 'An error has occurred.';
                    row['messages'] = messages;
                    row['fieldNames'] = fieldNames;
                    this.rows[element.id] = row;
                });
            }
            if(i + 1 <  allSelectRowsDataTemp.length){
                this.verifyApprovalRequests(i + 1, allSelectRowsDataTemp, selectRowsData);
            }else {
                if(!this.submitVerify){
                    this.showError('Process failure. Please check the items marked with an error icon.');

                    this.rowError['rows'] = this.rows;
                    this.rowErrorShow = this.rowError;

                    this.isShowSpinnerDialog = false;
                    this.isShowDisplay = false;
                    this.comments = '';
                    this.reassignUser = '';
                    this.buttonLabel = '';
                    return;
                }
                this.handlerSubmitApprovalRequests(selectRowsData);
            }
        }).catch(error => {
            console.log('wwwww--verifyApprovalRequests--error--' + this.getErrorMessage(error));
            this.isShowSpinnerDialog = false;
            this.isShowDisplay = false;
            this.showError('Process failure. ' + this.getErrorMessage(error));
        });
    }

    // 审批弹出框重新分配选择用户
    handleUserChange(event){
        console.log('wwww-----handleUserChange-----' + event.target.value);
        this.reassignUser = event.target.value;
        // 选择重新分配用户后 按钮可用
        if(this.reassignUser != '' && this.reassignUser != null && this.reassignUser != undefined){
            this.buttonLabelUsable = true;
        }else {
            this.buttonLabelUsable = false;
        }
    }

    // 每行aciton按钮
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        this.selectRow = [];
        this.selectRow.push(row);
        this.isBatch = false;
        console.log('wwww---row--' + JSON.stringify(row));
        console.log('wwww---selectRow--' + JSON.stringify(this.selectRow));
        switch (action.name) {
            case 'approve':
                console.log('wwwww---action---approve');
                this.isShowDisplay = true;
                this.isShowComments = true;
                this.isShowUser = false;
                this.buttonLabelUsable = true;
                this.buttonLabel = 'Approve';
                this.title = 'Approve ' + row.type + ' - ' + row.relatedTo;
                break;
            case 'reject':
                console.log('wwwww---action---reject');
                this.isShowDisplay = true;
                this.isShowComments = true;
                this.isShowUser = false;
                this.buttonLabelUsable = true;
                this.buttonLabel = 'Reject';
                this.title = 'Reject ' + row.type + ' - ' + row.relatedTo;
                break;
            case 'reassign':
                console.log('wwwww---action---reassign');
                this.isShowDisplay = true;
                this.isShowComments = false;
                this.isShowUser = true;
                this.buttonLabelUsable = false;
                this.buttonLabel = 'Reassign';
                this.title = 'Reassign ' + row.type + ' - ' + row.relatedTo;
                break;
            case 'viewApprovalRequest':
                console.log('wwwww---action---viewApprovalRequest');
                this.goToRecord(row.id);
                break;
            case 'viewObject':
                console.log('wwwww---action---viewObject');
                this.goToRecord(row.objectId);
                break;
        }   
    }

    // handleTest(){
    //     handleTest({
           
    //     }).then(data => {
           
    //     }).catch(error => {
           
    //     });
    // }
}