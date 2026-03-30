import { LightningElement,track,api,wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import LightningConfirm from 'lightning/confirm';

import initLabel from '@salesforce/apex/SchedulingPlanController.initLabel';
import init from '@salesforce/apex/SchedulingPlanController.init';
import initData from '@salesforce/apex/SchedulingPlanController.initData';
import upsertTask from '@salesforce/apex/SchedulingPlanController.upsertSchedulingTask';
import deleteTask from '@salesforce/apex/SchedulingPlanController.deleteSchedulingTask';
import uploadCSV from '@salesforce/apex/SchedulingPlanController.uploadCSV';

import SCHEDULING_PLAN_ERROR_MSG_1 from '@salesforce/label/c.SCHEDULING_PLAN_ERROR_MSG_1';
import SCHEDULING_PLAN_ERROR_MSG_2 from '@salesforce/label/c.SCHEDULING_PLAN_ERROR_MSG_2';
import SCHEDULING_PLAN_ERROR_MSG_3 from '@salesforce/label/c.SCHEDULING_PLAN_ERROR_MSG_3';
import SCHEDULING_PLAN_ERROR_MSG_4 from '@salesforce/label/c.SCHEDULING_PLAN_ERROR_MSG_4';
import SCHEDULING_PLAN_ERROR_MSG_5 from '@salesforce/label/c.SCHEDULING_PLAN_ERROR_MSG_5';
import SCHEDULING_PLAN_ERROR_MSG_6 from '@salesforce/label/c.SCHEDULING_PLAN_ERROR_MSG_6';
import SCHEDULING_PLAN_ERROR_MSG_7 from '@salesforce/label/c.SCHEDULING_PLAN_ERROR_MSG_7';
import SCHEDULING_PLAN_ERROR_MSG_8 from '@salesforce/label/c.SCHEDULING_PLAN_ERROR_MSG_8';
import SCHEDULING_PLAN_ERROR_MSG_9 from '@salesforce/label/c.SCHEDULING_PLAN_ERROR_MSG_9';
import SCHEDULING_PLAN_ERROR_MSG_10 from '@salesforce/label/c.SCHEDULING_PLAN_ERROR_MSG_10';
import SCHEDULING_PLAN_ERROR_MSG_11 from '@salesforce/label/c.SCHEDULING_PLAN_ERROR_MSG_11';
import SCHEDULING_PLAN_ERROR_MSG_12 from '@salesforce/label/c.SCHEDULING_PLAN_ERROR_MSG_12';
import Save from '@salesforce/label/c.Save';
import Return from '@salesforce/label/c.Return';
import Delete from '@salesforce/label/c.Delete';
export default class SchedulingPlan extends LightningNavigationElement {
    // get storeFilter() {
    //     var filter = {
    //         criteria: [
    //             {
    //                 fieldPath: 'Sales_Region__c',
    //                 operator: 'eq',
    //                 value: this.selectedSalesRegion,
    //             },
    //         ],
    //     };
    //     return filter;
    // }
    // get userFilter() {
    //     var filter = {
    //         criteria: [
    //             {
    //                 fieldPath: 'Sales_Region__c',
    //                 operator: 'eq',
    //                 value: this.selectedSalesRegion,
    //             },
    //         ],
    //     };
    //     return filter;
    // }

    get storeFilter() {
        return {
            'lookup' : 'CustomLookupProvider.SchedulingPlanStoreFilter',
            'salesRegion' : this.selectedSalesRegion
        }
    }
    get userFilter() {
        return {
            'lookup' : 'CustomLookupProvider.SchedulingPlanUserFilter',
            'salesRegion' : this.selectedSalesRegion
        }
    }

    label = {
        SCHEDULING_PLAN_ERROR_MSG_1,            // 所选门店或用户没有门店负责人
        SCHEDULING_PLAN_ERROR_MSG_2,            // 没有找到门店负责人数据
        SCHEDULING_PLAN_ERROR_MSG_3,            // 没有找到排班任务数据
        SCHEDULING_PLAN_ERROR_MSG_4,            // 考勤规则不能为空
        SCHEDULING_PLAN_ERROR_MSG_5,            // 过去日期和当前日期禁用修改
        SCHEDULING_PLAN_ERROR_MSG_6,            // 请选择CSV类型文件
        SCHEDULING_PLAN_ERROR_MSG_7,            // 文件必须是UTF-8编码格式
        SCHEDULING_PLAN_ERROR_MSG_8,            // 数据行数少于2
        SCHEDULING_PLAN_ERROR_MSG_9,            // 数据关键行数少于 30 或多于 33
        SCHEDULING_PLAN_ERROR_MSG_10,           // {0}列的key必须是{1}
        SCHEDULING_PLAN_ERROR_MSG_11,           // {0}行中的数据数量错误
        SCHEDULING_PLAN_ERROR_MSG_12,           // 行: {0} 列: {1} 数据不能为空
        Save,
        Return,
        Delete,
    };
    @track responsiblePersonlabel = {};
    @track schedulingPlanlabel = {};
    @track userlabel = {};
    @track schedulingTaskStatus = {};
    @track isAdmin = false;

    @track isShowSpinner = false;
    @track year = '';
    @track month = '';
    @track totalDays = 0;
    get yearsOptions() {
        return [
            { label: '2021', value: '2021' },
            { label: '2022', value: '2022' },
            { label: '2023', value: '2023' },
            { label: '2024', value: '2024' },
            { label: '2025', value: '2025' },
            { label: '2026', value: '2026' },
            { label: '2027', value: '2027' },
            { label: '2028', value: '2028' },
            { label: '2029', value: '2029' },
            { label: '2030', value: '2030' },
            { label: '2031', value: '2031' },
            { label: '2032', value: '2032' },
            { label: '2033', value: '2033' },
            { label: '2034', value: '2034' },
            { label: '2035', value: '2035' },
            { label: '2036', value: '2036' },
            { label: '2037', value: '2037' },
            { label: '2038', value: '2038' },
            { label: '2039', value: '2039' },
            { label: '2040', value: '2040' },
            { label: '2041', value: '2041' },
            { label: '2042', value: '2042' },
            { label: '2043', value: '2042' },
            { label: '2044', value: '2044' },
            { label: '2045', value: '2045' },
            { label: '2046', value: '2046' },
            { label: '2047', value: '2047' },
            { label: '2048', value: '2048' },
            { label: '2049', value: '2049' },
            { label: '2050', value: '2050' }
        ];    
    }
    get monthOptions() {
        return [
            { label: '1', value: '1' },
            { label: '2', value: '2' },
            { label: '3', value: '3' },
            { label: '4', value: '4' },
            { label: '5', value: '5' },
            { label: '6', value: '6' },
            { label: '7', value: '7' },
            { label: '8', value: '8' },
            { label: '9', value: '9' },
            { label: '10', value: '10' },
            { label: '11', value: '11' },
            { label: '12', value: '12' }
        ];
    }
    get dateTh() {
        var returnList = [];
        if (this.totalDays<28 || this.totalDays>31 || !(this.year) || !(this.month)) {
            return returnList;
        }
        var weekArr = ['Sun','Mon','Tues','Wed','Thur','Fri','Sat','Sun'];
        for (let i = 0; i < this.totalDays; i++) {
            var d = new Date(this.year+'-'+this.month+'-'+(i+1)).getDay();
            returnList.push({
                date: (i+1),
                week: weekArr[d],
                isWeekend: d==0||d==6?true:false
            });
        }
        return returnList;
    }
    
    @track selectedSalesRegion = ''
    get salesRegionOptios() {
        return [
            { label: 'Chile', value: 'Hisense Chile' },
            { label: 'Indonesia', value: 'Hisense Indonesia' },
            { label: 'South Africa', value: 'Hisense South Africa' },
            { label: 'Vietnam', value: 'Hisense Vietnam' },
        ];
    }

    // @track selectedStore = 'All';
    @track selectedStore = '';
    // picklist情况
    // get storeOptions() {
    //     var returnList = [];
    //     if (this.storeMapList.length>0 && this.selectedUser=='All') {
    //         for (let i = 0; i < this.storeMapList.length; i++) {
    //             var map = this.storeMapList[i];
    //             returnList.push({ label: map.storeName, value: map.storeId});
    //         }
    //     } else {
    //         var find = this.userMapList.find(obj => obj.userId==this.selectedUser);
    //         if (find) {
    //             for (let i = 0; i < find.responsiblePersons.length; i++) {
    //                 var rp = find.responsiblePersons[i];
    //                 returnList.push({ label: rp.Shop_Name__r.Name, value: rp.Shop_Name__c});
    //             }
    //         }
    //     }
    //     // if (returnList.length>0) {
    //     //     returnList.sort((a,b) => {return a.label>b.label});
    //     // }
    //     returnList.unshift({ label: 'All', value: 'All'});
    //     return returnList;
    // }
    // get storeIds() {
    //     var ids = [];
    //     // picklist情况
    //     // for (let i = 0; i < this.storeOptions.length; i++) {
    //     //     if (this.storeOptions[i].value!='All') {
    //     //         ids.push(this.storeOptions[i].value);
    //     //     }
    //     // }
    //     // picker情况
    //     // for (let i = 0; i < this.responsiblePersons.length; i++) {
    //     //     if (ids.indexOf(this.responsiblePersons[i].Shop_Name__c)==-1) {
    //     //         ids.push(this.responsiblePersons[i].Shop_Name__c)
    //     //     }
            
    //     // }
    //     return ids;
    // }
    // @track selectedUser = 'All';
    @track selectedUser = '';
    // picklist情况
    // get userOptions() {
    //     var returnList = [];
    //     if (this.userMapList.length>0 && this.selectedStore=='All') {
    //         for (let i = 0; i < this.userMapList.length; i++) {
    //             var map = this.userMapList[i];
    //             returnList.push({ label: map.userName, value: map.userId});
    //         }
    //     } else {
    //         var find = this.storeMapList.find(obj => obj.storeId==this.selectedStore);
    //         if (find) {
    //             for (let i = 0; i < find.responsiblePersons.length; i++) {
    //                 var rp = find.responsiblePersons[i];
    //                 returnList.push({ label: rp.Principal__r.Name, value: rp.Principal__c});
    //             }
    //         }
    //     }
    //     // if (returnList.length>0) {
    //     //     returnList.sort((a,b) => {return a.label>b.label});
    //     // }
    //     returnList.unshift({ label: 'All', value: 'All'});
    //     return returnList;
    // }
    // get userIds() {
    //     var ids = [];
    //     // picklist情况
    //     // for (let i = 0; i < this.userOptions.length; i++) {
    //     //     if (this.userOptions[i].value!='All') {
    //     //         ids.push(this.userOptions[i].value);
    //     //     }
    //     // }
    //     // picker情况
    //     // for (let i = 0; i < this.responsiblePersons.length; i++) {
    //     //     if (ids.indexOf(this.responsiblePersons[i].Principal__c)==-1) {
    //     //         ids.push(this.responsiblePersons[i].Principal__c)
    //     //     }
            
    //     // }
    //     return ids;
    // }

    // get checkStoreAndUser() {
    //     // return this.selectedStore=='All'&&this.selectedUser=='All'?false:true;
    //     return this.selectedStore==''&&this.selectedUser==''?false:true;
    // }
    @track checkStoreAndUser = false;

    // @track schedulingPlanDate = {};
    @track schedulingTasks = [];
    @track responsiblePersons = [];

    // @track storeMapList = [];
    // @track userMapList = [];

    connectedCallback() {
        this.isShowSpinner = true;
        var d  = new Date();
        this.totalDays = new Date(d.getFullYear(),(d.getMonth()+1),0).getDate();
        if (this.yearsOptions.find(obj => obj.value == d.getFullYear().toString())) {
            this.year = d.getFullYear().toString();
        } else {
            this.year = this.yearsOptions[0].value;
        }
        if (this.monthOptions.find(obj => obj.value == (d.getMonth()+1).toString())) {
            this.month = (d.getMonth()+1).toString();
        } else {
            this.month = this.monthOptions[0].value;
        }

        initLabel().then(resp => {
            if (resp.Responsible_Person__c) {
                this.responsiblePersonlabel = resp.Responsible_Person__c;
            }
            if (resp.SchedulingPlan__c) {
                this.schedulingPlanlabel = resp.SchedulingPlan__c;
            }
            if (resp.User) {
                this.userlabel = resp.User;
            }
            if (resp.SchedulingTask_Status) {
                this.schedulingTaskStatus = resp.SchedulingTask_Status;
            }
            this.getInit();
        }).catch(error => {

        })
    }

    handleSalesRegionChange(event) {
        this.isShowSpinner = true;
        this.selectedSalesRegion = event.detail.value;

        this.updateLookup();
        this.removeLookup();
        this.checkStoreAndUser = false;

        // this.selectedStore = 'All';
        // this.selectedUser = 'All';
        this.selectedStore = '';
        this.selectedUser = '';
        this.getInit();
        // this.isShowSpinner = false;
    }

    handleYearChange(event) {
        this.isShowSpinner = true;
        this.year = event.detail.value;
        this.totalDays = new Date(Number(this.year),Number(this.month),0).getDate();

        this.getInitDate();
        // this.isShowSpinner = false;
    }

    handleMonthChange(event) {
        this.isShowSpinner = true;
        this.month = event.detail.value;
        this.totalDays = new Date(Number(this.year),Number(this.month),0).getDate();

        this.getInitDate();
        // this.isShowSpinner = false;
    }

    handleStoreChange(event) {
        this.isShowSpinner = true;
        // this.selectedStore = event.detail.value;
        var storeId = event.detail.recordId;
        if (storeId && this.responsiblePersons.find(obj => obj.Shop_Name__c == storeId)) {
            this.selectedStore = storeId;
            // this.getInitDate();
        } else {
            this.selectedStore = '';
            this.isShowSpinner = false;
        }
        // this.getInitDate();
        this.isShowSpinner = false;
    }

    handleUserChange(event) {
        this.isShowSpinner = true;
        // this.selectedUser = event.detail.value;
        var userId = event.detail.recordId;
        if (userId && this.responsiblePersons.find(obj => obj.Principal__c == userId)) {
            this.selectedUser = userId;
            // this.getInitDate();
        } else {
            this.selectedUser = '';
            this.isShowSpinner = false;
        }

        // this.getInitDate();
        this.isShowSpinner = false;
    }

    updateLookup() {
        var cmps = this.template.querySelectorAll('c-lookup-lwc');
        if (cmps) {
            for (let i = 0; i < cmps.length; i++) {
                if (cmps[i].name=='storeLookup') {
                    cmps[i].updateOption(this.storeFilter);
                }
                if (cmps[i].name=='userLookup') {
                    cmps[i].updateOption(this.userFilter);
                }
            }
        }
    }
    removeLookup() {
        var cmps = this.template.querySelectorAll('c-lookup-lwc');
        if (cmps) {
            for (let i = 0; i < cmps.length; i++) {
                if (cmps[i].name=='storeLookup') {
                    cmps[i].handleRemove();
                }
                if (cmps[i].name=='userLookup') {
                    cmps[i].handleRemove();
                }
            }
        }
    }

    handleSearchClick() {
        // (this.selectedUser==''&&this.selectedStore=='')
        if (
            (this.selectedUser==''&&this.selectedStore!=''&&!(this.responsiblePersons.find(obj => obj.Shop_Name__c==this.selectedStore)))
            ||
            (this.selectedStore==''&&this.selectedUser!=''&&!(this.responsiblePersons.find(obj => obj.Principal__c==this.selectedUser)))
            ||
            (this.selectedUser!=''&&this.selectedStore!=''&&!(this.responsiblePersons.find(obj => obj.Shop_Name__c==this.selectedStore&&obj.Principal__c==this.selectedUser)))
        ) {
            this.checkStoreAndUser = false;
            // 'No Responsible Person exists for the selected store or user.'
            this.showError(this.label.SCHEDULING_PLAN_ERROR_MSG_1);
            return;
        }
        this.getInitDate();
    }

    storeLookupSelect(resp) {
        if (resp.detail.selectedRecord==undefined) {
            this.selectedStore = '';
            return;
        } else {
            this.selectedStore = resp.detail.selectedRecord.Id;
        }
    }
    
    userLookupSelect(resp) {
        if (resp.detail.selectedRecord==undefined) {
            this.selectedUser = '';
            return;
        } else {
            this.selectedUser = resp.detail.selectedRecord.Id;
        }
    }

    getInitDate() {
        
        this.isShowSpinner = true;
        console.log('initData');
        initData({
            year : this.year,
            month : this.month,
            salesRegion: this.selectedSalesRegion,
            storeId: this.selectedStore,
            userId: this.selectedUser
        }).then(data => {
            if (data.isSuccess) {
                console.log('isSuccess');
                // if (data.data.schedulingPlanDate) {
                //     this.schedulingPlanDate = data.data.schedulingPlanDate;
                // }
                if (data.data.schedulingTasks) {
                    this.schedulingTasks = data.data.schedulingTasks;
                }
                this.handleChangeHelper();

                this.checkStoreAndUser=true;
                this.isShowSpinner = false;
            } else {
                console.log('isError');
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            this.isShowSpinner = false;
            console.log('error----->'+JSON.stringify(error));
            this.catchError(error);
        })
    }

    handleChangeHelper() {
        for (let i = 0; i < this.responsiblePersons.length; i++) {
            var rp = this.responsiblePersons[i];
            // if (this.selectedStore=='All' || this.selectedStore==rp.Shop_Name__c) {
            if (this.selectedStore=='' || this.selectedStore==rp.Shop_Name__c) {
                rp.isSelectedStore = true;
            } else {
                rp.isSelectedStore = false;
            }
            
            // if (this.selectedUser=='All' || this.selectedUser==rp.Principal__c) {
            if (this.selectedUser=='' || this.selectedUser==rp.Principal__c) {
                rp.isSelectedUser = true;
            } else {
                rp.isSelectedUser = false;
            }
            
            this.checkSchedulingTask(rp);
        }
    }
    
    checkSchedulingTask(rp) {
        rp.tasks = [];
        for (let i = 0; i < this.totalDays; i++) {
            var _i = i+1;
            var dateStr = this.year+'-'+(this.month.length==1?'0'+this.month:this.month)+'-'+(_i<10?'0'+_i:''+_i);
            var map = {
                index: _i,
                ymd: dateStr,
                isWeekend: new Date(dateStr).getDay()==0||new Date(dateStr).getDay()==6?true:false,
                // hasTask: false,
                taskId: '',
                status: '',
                isOnLeave: false,
            };

            var find = this.schedulingTasks.find(obj => obj.Responsible_person__c==rp.Id && obj.Scheduling_Date__c==map.ymd);
            if (find) {
                // map.hasTask = true;
                map.taskId = find.Id;
                if (find.Status__c=='Scheduled') {
                    map.status = '〇';
                } else if (find.Status__c=='OnLeave') {
                    map.status = '╳ ';
                    map.isOnLeave = true;
                }
            }

            rp.tasks.push(map);
        }
    }

    getInit() {
        this.isShowSpinner = true;
        console.log('init');
        init({
            salesRegion: this.selectedSalesRegion
        }).then(data => {
            if (data.isSuccess) {
                console.log('isSuccess');
                // if (data.data.schedulingTasks) {
                //     this.schedulingTasks = data.data.schedulingTasks;
                // }
                if (data.data.responsiblePersons) {
                    this.responsiblePersons = data.data.responsiblePersons;
                    this.responsiblePersonsFormat();
                }
                if (data.data.isAdmin) {
                    this.isAdmin = data.data.isAdmin;
                }
                if (data.data.userSalesRegion && this.selectedSalesRegion=='') {
                    this.selectedSalesRegion = data.data.userSalesRegion;
                    this.updateLookup();
                } else if (this.selectedSalesRegion=='') {
                    this.selectedSalesRegion = this.salesRegionOptios[0].value;
                }

                this.isShowSpinner = false;
            } else {
                console.log('isError');
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            this.isShowSpinner = false;
            console.log('error----->'+JSON.stringify(error));
            this.catchError(error);
        })
    }

    responsiblePersonsFormat() {
        // var storeMapList  = [];
        // var userMapList  = [];
        if (this.responsiblePersons.length>0) {
            for (let i = 0; i < this.responsiblePersons.length; i++) {
                var rp = this.responsiblePersons[i];
                rp.isSelectedStore = false;
                rp.isSelectedUser = false;
                // // store map
                // var storeMap = {
                //     storeId: rp.Shop_Name__c,
                //     storeName: rp.Shop_Name__r.Name,
                //     responsiblePersons: []
                // }
                // var findMap1 = storeMapList.find(obj => obj.storeId == storeMap.storeId);
                // if (findMap1) {
                //     storeMap = findMap1;
                // } else {
                //     storeMapList.push(storeMap);
                // }
                // storeMap.responsiblePersons.push(rp);
                // // user map
                // var userMap = {
                //     userId: rp.Principal__c,
                //     userName: rp.Principal__r.Name,
                //     responsiblePersons: []
                // }
                // var findMap2 = userMapList.find(obj => obj.userId == userMap.userId);
                // if (findMap2) {
                //     userMap = findMap2;
                // } else {
                //     userMapList.push(userMap);
                // }
                // userMap.responsiblePersons.push(rp);

                // if (this.selectedStore=='All' || this.selectedStore==rp.Shop_Name__c) {
                // if (this.selectedStore=='' || this.selectedStore==rp.Shop_Name__c) {
                //     rp.isSelectedStore = true;
                // } else {
                //     rp.isSelectedStore = false;
                // }
                
                // // if (this.selectedUser=='All' || this.selectedUser==rp.Principal__c) {
                // if (this.selectedUser=='' || this.selectedUser==rp.Principal__c) {
                //     rp.isSelectedUser = true;
                // } else {
                //     rp.isSelectedUser = false;
                // }
            }
        }

        // this.storeMapList = storeMapList;
        // this.userMapList = userMapList;
    }

    @track isShowModal = false;
    @track selectedStoreName = '';
    @track selectedUserName = '';
    @track taskRecord = {};

    handleDateClick(event) {
        console.log('date click');
        this.isShowSpinner = true;
        
        var selectYMD = event.target.getAttribute('data-ymd');
        var selectedResponsiblePerson = event.target.getAttribute('data-rpid');
        
        var find = this.responsiblePersons.find(obj => obj.Id==selectedResponsiblePerson);
        if (!(find)) {
            // 'No Responsible Person data found'
            this.showError(this.label.SCHEDULING_PLAN_ERROR_MSG_2);
            this.isShowSpinner = false;
            return;
        }

        this.selectedStoreName = find.Shop_Name__r.Name;
        this.selectedUserName = find.Principal__r.Name;
        
        var taskId = event.target.getAttribute('data-taskid');
        if (taskId) {
            var find_task = this.schedulingTasks.find(obj => obj.Id == taskId);
            if (find_task) {
                this.taskRecord = find_task;
            } else {
                // 'No Scheduling Task data found'
                this.showError(this.label.SCHEDULING_PLAN_ERROR_MSG_3);
                this.isShowSpinner = false;
                return;
            }
        } else {
            this.taskRecord = {
                IsImport__c: false,
                Scheduling_Date__c: selectYMD,
                Responsible_person__c: selectedResponsiblePerson,
                Store__c: find.Shop_Name__c,
                User__c: find.Principal__c,
                Status__c: 'unscheduled',
                Promoter_Attendance_Rule__c: find.Promoter_Attendance_Rule__c,
                // SchedulingPlan__c: this.schedulingPlanDate.Id,
            }
        }

        this.isShowModal = true;
        this.isShowSpinner = false;
    }

    handlePromoterAttendanceRuleChange(event) {
        this.taskRecord.Promoter_Attendance_Rule__c = event.target.value;
    }

    handleApplicationClick() {
        if (this.taskRecord.Application__c) {
            this.goToRecord(this.taskRecord.Application__c);
        }
    }

    async handleDeleteClick() {
        this.isShowSpinner = true;

        var d  = new Date();
        var todayStr = '';
        todayStr += d.getFullYear();
        todayStr += '-';
        todayStr += (d.getMonth()+1)<10?'0'+(d.getMonth()+1):(d.getMonth()+1);
        todayStr += '-';
        todayStr += d.getDate()<10?'0'+d.getDate():d.getDate();
        if (new Date(todayStr)>=new Date(this.taskRecord.Scheduling_Date__c)) {
            // 'Past date and current date disable modification.'
            this.showError(this.label.SCHEDULING_PLAN_ERROR_MSG_5);
            this.isShowSpinner = false;
            return;
        }
        if (this.taskRecord.Status__c == 'OnLeave') {
            // 'Past date and current date disable modification.'
            this.showError(this.label.SCHEDULING_PLAN_ERROR_MSG_5);
            this.isShowSpinner = false;
            return;
        }

        const result = await LightningConfirm.open({
            message: 'Confirmation of data deletion Date: '+this.taskRecord.Scheduling_Date__c+' Store: '+this.selectedStoreName+' User:'+this.selectedUserName,
            variant: 'headerless',
            label: 'This is the aria-label value',
        });
       
        if (result) {
            deleteTask({
                taskId : this.taskRecord.Id
            }).then(resp => {
                if (resp) {
                    this.isShowSpinner = true;
                    this.isShowModal = false;
                    this.showSuccess('Delete Success');
                    this.getInitDate();
                } else {
                    this.isShowSpinner = false;
                    this.showError('Delete Fail');
                }
            }).catch(error => {
                this.isShowSpinner = false;
                this.showError('Delete Fail');
            });
        } else {
            this.isShowSpinner = false;
        }
    }

    handleCancelClick() {
        this.isShowModal = false;
    }

    handleSaveClick() {
        this.isShowSpinner = true;
        console.log(JSON.stringify(this.taskRecord));
        // if (this.taskRecord.Status__c=='OnLeave') {
        //     this.showError('OnLeave status disable modification.');
        //     this.isShowSpinner = false;
        //     return;
        // }
        if (!(this.taskRecord.Promoter_Attendance_Rule__c)) {
            // 'Attendance rules cannot be empty.'
            this.showError(this.label.SCHEDULING_PLAN_ERROR_MSG_4);
            this.isShowSpinner = false;
            return;
        }
        var d  = new Date();
        var todayStr = '';
        todayStr += d.getFullYear();
        todayStr += '-';
        todayStr += (d.getMonth()+1)<10?'0'+(d.getMonth()+1):(d.getMonth()+1);
        todayStr += '-';
        todayStr += d.getDate()<10?'0'+d.getDate():d.getDate();
        if (new Date(todayStr)>=new Date(this.taskRecord.Scheduling_Date__c)) {
            // 'Past date and current date disable modification.'
            this.showError(this.label.SCHEDULING_PLAN_ERROR_MSG_5);
            this.isShowSpinner = false;
            return;
        }
        if (this.taskRecord.Status__c != 'OnLeave') {
            this.taskRecord.Status__c = 'Scheduled';
        }
        upsertTask({
            taskJson: JSON.stringify(this.taskRecord)
        }).then(result => {
            this.isShowModal = false;
            this.getInitDate();
            this.isShowSpinner = false;
        }).catch(e => {
            this.showError(e.body.message);
            this.isShowSpinner = false;
        })
    }

    @track filePath = '';
    async handleInputClick(event) {
        this.isShowSpinner = true;
        var file = event.target.files[0];
        // if (file.type!='text/csv'||file.name.slice(-4).toLowerCase()!='.csv') {
        if (file.name.slice(-4).toLowerCase()!='.csv') {
            this.isShowSpinner = false;
            // 'Please select a csv type file'
            this.showError(this.label.SCHEDULING_PLAN_ERROR_MSG_6);
            return;
        }

        await new Promise(() => {
        
            var reader = new FileReader();
            reader.onload = (e) => {
                const content = e.target.result;
                if (content.indexOf('�')!=-1) {
                    this.isShowSpinner = false;
                    // 'Files must be in UTF-8 encoded format'
                    this.showError(this.label.SCHEDULING_PLAN_ERROR_MSG_7);
                } else {
                    console.log(content);
                    this.checkCSVFile(content);
                }
            };
            reader.readAsText(file);
        });
    }

    checkCSVFile(content) {
        var contentSplit = content.split('\r\n');
        if (contentSplit.length!=0) {
            if (contentSplit[contentSplit.length-1]=='') {
                contentSplit.pop();
            }  
        }
        if (contentSplit.length<2) {
            this.isShowSpinner = false;
            // 'Number of data rows less than 2'
            this.showError(this.label.SCHEDULING_PLAN_ERROR_MSG_8);
            return;
        }
        var keys = contentSplit[0].split(',');
        if (keys.length<30||keys.length>33) {
            this.isShowSpinner = false;
            // 'Number of data key rows less than 30 or more than 33'
            this.showError(this.label.SCHEDULING_PLAN_ERROR_MSG_9);
            return;
        }
        for (let i = 0; i < keys.length; i++) {
            var key = keys[i];
            // if (i==0&&key!='StoreName') {
            //     this.isShowSpinner = false;
            //     this.showError('The 1 column of the key must be StoreName');
            //     return;
            // }
            // if (i==1&&key!='UserName') {
            //     this.isShowSpinner = false;
            //     this.showError('The 2 column of the key must be UserName');
            //     return;
            // }
            if (i>1&&key!=((i-1)+'')) {
                this.isShowSpinner = false;
                // 'The '+(i+1)+' column of the key must be '+(i-1)
                this.showError(this.label.SCHEDULING_PLAN_ERROR_MSG_10.format(i+1,i-1));
                return;
            }
            console.log('key--->'+key);
        }

        var dateMapList = [];
        for (let i = 1; i < contentSplit.length; i++) {
            var item = contentSplit[i].split(',');
            if (item.length!=keys.length) {
                this.isShowSpinner = false;
                // 'Wrong number of data in the '+(i+1)+' row'
                this.showError(this.label.SCHEDULING_PLAN_ERROR_MSG_11);
                return;
            }

            var dateMap = {
                storeName : '',
                userName : '',
                task : {},
            };
            for (let j = 0; j < item.length; j++) {
                var value = item[j];
                if (!value && (j==0 || j==1)) {
                    this.isShowSpinner = false;
                    // 'Row: '+(i+1)+' Col: '+(j+1)+' Data cannot be empty'
                    this.showError(this.label.SCHEDULING_PLAN_ERROR_MSG_12.format(i+1,j+1));
                    return;
                }
                if (j==0) {
                    dateMap.storeName = value;
                } else if (j==1) {
                    dateMap.userName = value;
                } else {
                    dateMap.task[(j-1)] = value?value:0;
                }
            }
            dateMapList.push(dateMap);
        }
        
        console.log('dateMapList');
        console.log(JSON.stringify(dateMapList));
        this.uploadCSV(JSON.stringify(dateMapList));
    }

    uploadCSV(contentJSON) {
        uploadCSV({
            contentJSON: contentJSON,
            year : this.year,
            month : this.month,
            salesRegion: this.selectedSalesRegion,
        }).then(resp => {
            if (resp.isSuccess) {
                // this.getInitDate();
                
                if (resp.data.schedulingTasks) {
                    this.schedulingTasks = resp.data.schedulingTasks;
                }
                if (resp.data.csvRpIds) {
                    this.csvRpIdsFormat(resp.data.csvRpIds);
                    this.checkStoreAndUser=true;
                }
                
                this.isShowSpinner = false;
                this.showSuccess('Success');
            } else {
                this.isShowSpinner = false;
                this.showError(resp.message);
            }
        }).catch(error => {
            this.isShowSpinner = false;
            this.showError(error);
        })
    }

    csvRpIdsFormat(rpIds) {
        for (let i = 0; i < this.responsiblePersons.length; i++) {
            var rp = this.responsiblePersons[i];
            if (rpIds.indexOf(rp.Id)>-1) {
                rp.isSelectedStore = true;
                rp.isSelectedUser = true;
            } else {
                rp.isSelectedStore = false;
                rp.isSelectedUser = false;
            }

            this.checkSchedulingTask(rp);
        }
    }

    handleDownloadTemplate(event) {
        let fileName = 'SchedulingPlan' + this.year + this.month + '.csv';
        let filedsArr = ['StoreName', 'UserName'];
        for (let index = 1; index <= new Date(this.year, this.month, 0).getDate(); index++) {
            filedsArr.push(index);
        }
        this.downloadCSV([filedsArr], fileName)
    }

    downloadCSV(data, filename) {
        const csvContent = "data:text/csv;charset=utf-8," + data.map(row => row.join(",")).join("\n");
        const encodedUri = encodeURI(csvContent);
        const link = document.createElement("a");
    
        link.setAttribute("href", encodedUri);
        link.setAttribute("download", filename);
        document.body.appendChild(link);
    
        link.click(); // This will trigger the download
        document.body.removeChild(link);
    }
    
}