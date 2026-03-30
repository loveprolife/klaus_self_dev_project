import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { CurrentPageReference } from 'lightning/navigation';
import getData from '@salesforce/apex/CreateNewMonthPlanController.getData';
import haveRepeatingData from '@salesforce/apex/CreateNewMonthPlanController.haveRepeatingData';
import saveData from '@salesforce/apex/CreateNewMonthPlanController.saveData';
import getReport from '@salesforce/apex/CreateNewMonthPlanController.getReport';
//跟据输入的值查询巡店员
import filterFloorwalker from '@salesforce/apex/CreateNewMonthPlanController.filterFloorwalker';
import Error from '@salesforce/label/c.Error';
import SaveSucessful from '@salesforce/label/c.SaveSucessful';
import ReportTitle from '@salesforce/label/c.ReportTitle';
import Return from '@salesforce/label/c.Return';
import Save from '@salesforce/label/c.Save';
import PlanNumber from '@salesforce/label/c.PlanNumber';
import PickPlanYear from '@salesforce/label/c.PickPlanYear';
import PlanYear from '@salesforce/label/c.PlanYear';
import Floorwalker from '@salesforce/label/c.Floorwalker';
import PlanMonth from '@salesforce/label/c.PlanMonth';
import PickPlanMonth from '@salesforce/label/c.PickPlanMonth';
import PlanDetail from '@salesforce/label/c.PlanDetail';
import PlannedQuantitySum from '@salesforce/label/c.PlannedQuantitySum';
import ActualQuantitySum from '@salesforce/label/c.ActualQuantitySum';
import Order from '@salesforce/label/c.Order';
import AccountName from '@salesforce/label/c.AccountName';
import ShopName from '@salesforce/label/c.ShopName';
import ShopLevel from '@salesforce/label/c.ShopLevel';
import PlannedQuantity from '@salesforce/label/c.PlannedQuantity';
import ActualQuantity from '@salesforce/label/c.ActualQuantity';
import TaskTitile from '@salesforce/label/c.TaskTitile';
import ReportDetail from '@salesforce/label/c.ReportDetail';
import Result from '@salesforce/label/c.Result';
import Remark from '@salesforce/label/c.Remark';
import PlacementStatus from '@salesforce/label/c.PlacementStatus';
import Product from '@salesforce/label/c.Product';
import ReRe from '@salesforce/label/c.ReRe';
import SampleImages from '@salesforce/label/c.SampleImages';
import ShopCompetitiveProduct from '@salesforce/label/c.ShopCompetitiveProduct';
import Brand from '@salesforce/label/c.Brand';
import Size from '@salesforce/label/c.Size';
import TagPrice from '@salesforce/label/c.TagPrice';
import ActualPrice from '@salesforce/label/c.ActualPrice';
import WeekendFavorable from '@salesforce/label/c.WeekendFavorable';
import TradeInOffers from '@salesforce/label/c.TradeInOffers';
import Confirm from '@salesforce/label/c.Confirm';
import Delete from '@salesforce/label/c.Delete';
import ViewImage from '@salesforce/label/c.ViewImage';
import Preview from '@salesforce/label/c.Preview';
import SaveTheChanges from '@salesforce/label/c.SaveTheChanges';
import IsSaveTheChanges from '@salesforce/label/c.IsSaveTheChanges';
import AbortSavingJump from '@salesforce/label/c.AbortSavingJump';
import SavingJump from '@salesforce/label/c.SavingJump';
import SamplingInspection from '@salesforce/label/c.SamplingInspection';
import ProductCatalogConfirm from '@salesforce/label/c.ProductCatalogConfirm';
import RegularVisit from '@salesforce/label/c.RegularVisit';
import Pick from '@salesforce/label/c.Pick';
import StoreMaintain from '@salesforce/label/c.StoreMaintain';
import IntelligenceGathering from '@salesforce/label/c.IntelligenceGathering';
import StoreInformation from '@salesforce/label/c.StoreInformation';
import corporateInformation from '@salesforce/label/c.CorporateInformation';
import CompetitiveInformation from '@salesforce/label/c.CompetitiveInformation';
import ProductSeries from '@salesforce/label/c.ProductSeries';
import GraphicalCounter from '@salesforce/label/c.GraphicalCounter';
import Description from '@salesforce/label/c.Description';
import Picture from '@salesforce/label/c.Picture';
import Mobiletip from '@salesforce/label/c.MOBILE_PHONE_FUNCTION_NOTONLINE';

export default class createMonthPlan  extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isShowSpinner;
    @track day =1 ;
    @track isModalOpen = false;
    // @track taskId;
    @track showButton;
    @track showDeleteButton;
    @track dayOptions = [];
    @track monthplans = [];
    @track showDisable;
    @track ShopPlanData;
    @track myDate;
    @track showEditInput = false;
    @track showDuplecation = false;
    @track duplicationData;
    @track dataUrl;
    @track task;
    @track taskMap;
    @track MonthIndex;
    @track plannedQuantitySum;
    @track actualQuantitySum;
    @track report;
    @track cxjls;
    @track jpjls;
    @track showDetail;
    @track isViewImgOpen;
    @track viewImg;
    @track showSaveButton;
    @track heightTable;
    @track ownerName;
    @track isChange;
    @track showCheckSave;
    @track oldYear;
    @track oldMonth;
    @track sampleImages=[];
    @track showPhotoPage;
    @track isPc = true;
    //是否可选巡店员
    @track canSelectFloorwalker = false;
    //巡店员
    //@track floorwalkers=[];

    @track floorwalkerRecords=[];
    @track showSelectList =false;

    @api searchPlaceholder='Search';
    @track selectedFloorwalkerId;
    @track blurTimeout;
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    label = {
        Picture,
        Description,
        GraphicalCounter,
        ProductSeries,
        CompetitiveInformation,
        corporateInformation,
        StoreInformation,
        IntelligenceGathering,
        StoreMaintain,
        Pick,
        ProductCatalogConfirm,
        RegularVisit,
        SaveSucessful,
        ReportTitle,
        Return,
        Save,
        PlanNumber,
        PlanYear,
        PickPlanYear,
        Floorwalker,
        PlanMonth,
        PickPlanMonth,
        PlanDetail,
        PlannedQuantitySum,
        ActualQuantitySum,
        Order,
        AccountName,
        ShopName,
        ShopLevel,
        PlannedQuantity,
        ActualQuantity,
        TaskTitile,
        ReportDetail,
        Result,
        Remark,
        PlacementStatus,
        Product,
        ReRe,
        SampleImages,
        ShopCompetitiveProduct,
        Brand,
        Size,
        TagPrice,
        ActualPrice,
        WeekendFavorable,
        TradeInOffers,
        Confirm,
        Delete,
        ViewImage,
        Preview,
        SaveTheChanges,
        IsSaveTheChanges,
        AbortSavingJump,
        SavingJump,
        Error,
        SamplingInspection,
        Mobiletip
    };
    get catalogOptions() {
        return [
            {label:'○',value:'济'},
            {label:'X',value:'未'},
        ];    
    }
    get storeMaintainOptions() {
        return [
            {label:'○',value:'济'},
            {label:'X',value:'未'},
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

    yearChange(event) {
        this.oldYear = this.ShopPlanData.Inspection_Year__c;
        this.ShopPlanData.Inspection_Year__c = event.detail.value;
        // if (!this.recordId) {
        this.callApexHaveRepeatingDataMethod();
        // }
    }

    monthChange(event) {
        this.oldMonth = this.ShopPlanData.Inspection_Month__c;
        this.ShopPlanData.Inspection_Month__c = event.detail.value; 
        // if (!this.recordId) {
        this.callApexHaveRepeatingDataMethod();   
        // }
    }

    callApexHaveRepeatingDataMethod() {
        if (this.isChange) {
            this.showCheckSave = true;   
        }else{
            this.notSave();

        }
    }

    saveAndJump() {
        this.isShowSpinner = true;
        if (!this.recordId) {
            const allValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
            if (!allValid) {
                this.isShowSpinner = false;
                return;
            }    
        }
        this.monthplans = null;
        this.dayOptions = null;
        this.myDate = null;
        saveData({
            shopPlan : this.ShopPlanData,
            taskMapDataJSON : JSON.stringify(this.taskMap),
            planId : this.ShopPlanData.Id,
            jump : true,
            month : this.oldMonth,
            year : this.oldYear,
            ownerId : this.selectedFloorwalkerId
        }).then(result => {
            if (result.isSucess) {
                if (result.canCreate) {
                    this.ShopPlanData = result.ShopPlanData;
                    this.monthplans = result.MonthPlans;
                    this.dayOptions = result.dayAndWeekDate;
                    this.myDate = result.nowDate;
                    this.isShowSpinner = false;
                    this.taskMap = result.taskMap;
                    // this.showEditInput = false;
                    this.isShowSpinner = false;
                    this.plannedQuantitySum = result.plannedQuantitySum;
                    this.actualQuantitySum = result.actualQuantitySum;
                    // if (!this.recordId) {
                    //     this.recordId = result.ShopPlanData.Id;
                    // }
                    this.ownerName = result.ownerName;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: this.label.SaveSucessful,
                        variant: 'Success',
                    }));
                    this.isChange = false;
                    this.showCheckSave = false;    
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: result.errorMsg,
                        variant: 'error',
                    }));
                    this.showSaveButton = result.showSaveButton;
                    this.isShowSpinner = false;  
                    this.showCheckSave = false; 
                    this.isChange = false;    
                }
                
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));
                this.ShopPlanData.Inspection_Year__c = this.oldYear;
                this.ShopPlanData.Inspection_Month__c = this.oldMonth;
                this.isShowSpinner = false;
                this.showCheckSave = false;
            }
        }).catch(error => {
            this.isShowSpinner = false;
            this.ShopPlanData.Inspection_Year__c = this.oldYear;
            this.ShopPlanData.Inspection_Month__c = this.oldMonth;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Error,
                variant: 'error',
            }));
            this.isShowSpinner = false;
            
        });    
    }

    notSave() {
        this.isShowSpinner = true;
        this.monthplans = null;
        this.dayOptions = null;
        this.myDate = null;
        // if (this.recordId) {
        //     this.showEditInput = false;
        // }else{
        //     this.showEditInput = true;
        // }
        this.showDuplecation = false;
        //调用后台逻辑
        if (this.ShopPlanData.Inspection_Year__c && this.ShopPlanData.Inspection_Month__c) {
            haveRepeatingData({
                year : this.ShopPlanData.Inspection_Year__c,
                month : this.ShopPlanData.Inspection_Month__c,
                ownerId : this.selectedFloorwalkerId
            }).then(result => {
                if (result.isSucess) {
                    if (result.canCreate) {
                        // if (result.recordId) {//如果存在
                        //     this.showDuplecation = true;
                        //     this.duplicationData = result.ShopPlanData;
                        //     this.dataUrl = '/'+result.recordId;
                        //     this.isShowSpinner = false;
                        // }else{
                        this.monthplans = result.MonthPlans;
                        this.dayOptions = result.dayAndWeekDate;
                        this.myDate = result.nowDate;
                        this.isShowSpinner = false;
                        this.taskMap = result.taskMap;
                        this.plannedQuantitySum = result.plannedQuantitySum;
                        this.actualQuantitySum = result.actualQuantitySum;
                        // if (this.recordId) {
                        //     this.showEditInput = false;
                        // }else{
                        //     this.showEditInput = true;
                        // }
                        this.showDuplecation = false;
                        this.showSaveButton = result.showSaveButton;
                        this.ownerName = result.ownerName;
                        this.ShopPlanData = result.ShopPlanData;
                        this.isChange = false;
                        this.showCheckSave = false;
                        // }    
                    }else{
                        this.showSaveButton = result.showSaveButton;
                        this.isShowSpinner = false;
                        this.showCheckSave = false;
                        this.isChange = false;  
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'error',
                            message: result.errorMsg,
                            variant: 'error',
                        }));  
                    }
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: result.errorMsg,
                        variant: 'error',
                    }));
                    this.isShowSpinner = false;
                    this.showCheckSave = false;
                }
            });
        }else{
            this.isShowSpinner = false;
        }    
    }

    closeDuplecationModal() {
        this.showDuplecation = false;
        this.ShopPlanData.Inspection_Year__c = '';
        this.ShopPlanData.Inspection_Month__c = '';
    }


     //页面初始化方法
    connectedCallback() {

        //判断是否是Pc端
        var userAgentInfo = window.navigator.userAgent;
        var Agents = ["Android", "iPhone", "SymbianOS", "Windows Phone", "iPad", "iPod"];
        for (var v = 0; v < Agents.length; v++) {
            if (userAgentInfo.indexOf(Agents[v]) > 0) {
                this.isPc = false;
                return;
            }
        }

        // pc端初始化
        this.isShowSpinner = true;

        getData({
            planId : this.recordId
        }).then(result => {
            console.log(" this.recordId :" + this.recordId);
            console.log("result.isSucess : " + result.isSucess);
            if (result.isSucess) {
                let screenHeight = window.screen.height;
                if (screenHeight > 1000) {
                    this.heightTable = "width: 100%;height: "+screenHeight/2+"px;overflow-y: scroll;"
                }else{
                    this.heightTable = "width: 100%;height: "+screenHeight/4+"px;overflow-y: scroll;"
                }

                // this.template.querySelectorAll('slds-context-bar').classList.add('displayElement');
                console.log("result.ShopPlanData: "  + result.ShopPlanData);
                this.ShopPlanData = result.ShopPlanData;
                this.monthplans = result.MonthPlans;
                this.dayOptions = result.dayAndWeekDate;
                console.log("result.dayAndWeekDate: " + result.dayAndWeekDate);
                this.myDate = result.nowDate;
                this.isShowSpinner = false;
                this.taskMap = result.taskMap;
                this.plannedQuantitySum = result.plannedQuantitySum;
                this.actualQuantitySum = result.actualQuantitySum;
                //是否可选择巡店员
                this.canSelectFloorwalker = result.canSelectFloorwalker;
                this.selectedFloorwalkerId = result.ownerId;
                
                //巡店员
                // result.floorwalkers.forEach(walker => {
                //     this.floorwalkers.push({ label: walker.Name, value: walker.Id });
                // });
                if (this.recordId) {
                    //可选择巡店员
                    if(this.canSelectFloorwalker == true) {
                        this.showEditInput = true;
                    } else {
                        this.showEditInput = false;
                    }
                }else{
                    this.showEditInput = true;
                }
                this.showSaveButton = result.showSaveButton;
                this.ownerName = result.ownerName;
                this.searchTerm = result.ownerName;
                this.oldYear = this.ShopPlanData.Inspection_Year__c;
                this.oldMonth = this.ShopPlanData.Inspection_Month__c;
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));
                this.isShowSpinner = false;
            }
            
        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Error,
                variant: 'error',
              }));
            
        });
        
    }

    showPlanItem() {

        this.dispatchEvent(new CloseActionScreenEvent());
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'StoreVisitPlan__c',
                actionName: 'New'
            },
            state: {
                nooverride : 1
            }
        });

    }

    cancel(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Inspection_Shop_Plan__c',
                actionName: 'list'
            }
        });
    }

    createInspectionShopTask(event){
        this.isShowSpinner = true;
        let nameValue = event.target.getAttribute("name")+'';
        let pickValue = nameValue.split(':');
        let onclickDay = new Date(pickValue[0].replaceAll('-','/'));
        let nowDate = new Date(this.myDate.replaceAll('-','/'));
        this.showDisable = false;
        this.isModalOpen = false;
        this.showButton = false;
        this.showDeleteButton = false;
        this.showDetail = false;
        this.report = [];
        this.cxjls = [];
        this.jpjls = [];
        if (onclickDay < nowDate) {
            if (pickValue.length === 4) {
                this.isShowSpinner = true;
                getReport({
                    taskId : pickValue[1]
                }).then(result => {
                    if (result.isSucess) {
                        this.showDetail = true;
                        this.task = this.taskMap[pickValue[2]+''+pickValue[0]+'NEW'];
                        this.MonthIndex = pickValue[3];
                        this.isModalOpen = true;
                        this.showButton = false;
                        this.showDisable = true;

                        this.report = result.report;
                        this.cxjls = result.siList;
                        this.jpjls = result.scpList;
                    }else{
                        this.showDetail = false;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'error',
                            message: result.errorMsg,
                            variant: 'error',
                        }));
                    }
                    this.isShowSpinner = false;
                }).catch(error => {
                    this.isShowSpinner = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: this.label.Error,
                        variant: 'error',
                    }));
                });
            }
        }else{
            this.showDetail = false;
            if (pickValue.length === 4) {
                this.task = this.taskMap[pickValue[2]+''+pickValue[0]+'NEW'];
                if (!this.task.Daily_Inspection_Report__c) {
                    this.showDeleteButton = true;
                }
                this.MonthIndex = pickValue[3];
                this.isModalOpen = true;
                this.showButton = true;
            }else{
                if (this.taskMap[pickValue[1]+''+pickValue[0]+'NEW']) {
                    this.task = this.taskMap[pickValue[1]+''+pickValue[0]+'NEW'];
                    this.showDeleteButton = true;
                }else{
                    let taskObject = {};
                    taskObject.Shop__c = pickValue[1];
                    taskObject.Inspection_Date__c = pickValue[0];
                    if (this.ShopPlanData.Id) {
                        taskObject.Inspection_Plan__c = this.ShopPlanData.Id;
                    }else{
                        taskObject.Inspection_Plan__c = '';
                    }
                    taskObject.Status__c = '未到访';
                    this.task = taskObject;
                }
                this.MonthIndex = pickValue[2];
                this.isModalOpen = true;
                this.showButton = true;
            }    
        }
        this.isShowSpinner = false;
    }

    closeModal(){
        this.isModalOpen = false;
    }

    confirmData(){
        let dayNumber = this.task.Inspection_Date__c.split('-');
        this.taskMap[this.task.Shop__c+''+dayNumber[0]+'-'+parseInt(dayNumber[1])+'-'+parseInt(dayNumber[2])+'NEW'] = this.task;
        
        let monthData = this.monthplans[parseInt(this.MonthIndex)-1];
        let taskDate = monthData.dayOptions;
        if(!this.task.Id){
            let data = taskDate[parseInt(dayNumber[2])-1];
            data.status1 = '〇';
        }
        this.isModalOpen = false;
        this.isChange = true;
    }

    handleFiledChange(event){
        this.task[event.currentTarget.fieldName] = event.target.value;
    }

    deleteData() {
        
        if (this.task.Id) {//删除已经保存过的数据
            let dateStr = this.task.Inspection_Date__c.split('-');
            let mothString;
            let dayString;
            if (dateStr[1].indexOf('0')===0) {
                mothString = dateStr[1].replace('0','');
            }else{
                mothString = dateStr[1];
            }
            if (dateStr[2].indexOf('0')===0) {
                dayString = dateStr[2].replace('0','');    
            }else{
                dayString = dateStr[2];    
            }
            this.taskMap[this.task.Shop__c+''+dateStr[0]+'-'+mothString+'-'+dayString+'DELETE'] = this.task;
            delete this.taskMap[this.task.Shop__c+''+dateStr[0]+'-'+mothString+'-'+dayString+'NEW'];
            // this.taskMap[this.task.Shop__c+''+dateStr[0]+'-'+dateStr[1]+'-'+dateStr[2]+'DELETE'] = this.task;
            // delete this.taskMap[this.task.Shop__c+''+dateStr[0]+'-'+dateStr[1]+'-'+dateStr[2]+'NEW'];
            let dayNumber = this.task.Inspection_Date__c.split('-');
            let monthData = this.monthplans[parseInt(this.MonthIndex)-1];
            let taskDate = monthData.dayOptions;
            let dataExist = taskDate[parseInt(dayNumber[2])-1];
            let taskAndDate = dataExist.taskAndDate.split(':');
            dataExist.taskAndDate = taskAndDate[0]+':'+taskAndDate[2]+':'+this.MonthIndex;
            dataExist.status1 = '';
            this.isModalOpen = false;
            this.isChange = true;
        }else{
            let dateStr = this.task.Inspection_Date__c.split('-');
            let mothString;
            let dayString;
            if (dateStr[1].indexOf('0')===0) {
                mothString = dateStr[1].replace('0','');
            }else{
                mothString = dateStr[1];
            }
            if (dateStr[2].indexOf('0')===0) {
                dayString = dateStr[2].replace('0','');    
            }else{
                dayString = dateStr[2];    
            }
            delete this.taskMap[this.task.Shop__c+''+dateStr[0]+'-'+mothString+'-'+dayString+'NEW'];
            // delete this.taskMap[this.task.Shop__c+''+dateStr[0]+'-'+dateStr[1]+'-'+dateStr[2]+'NEW'];
            let dayNumber = this.task.Inspection_Date__c.split('-');
            let monthData = this.monthplans[parseInt(this.MonthIndex)-1];
            let taskDate = monthData.dayOptions;
            let data = taskDate[parseInt(dayNumber[2])-1];
            data.status1 = '';
            this.isModalOpen = false;
            this.isChange = true;
        }    
    }

    savePlan() {
        this.isShowSpinner = true;
        if (!this.recordId) {
            const allValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
            if (!allValid) {
                this.isShowSpinner = false;
                return;
            }    
        }
        
        saveData({
            shopPlan : this.ShopPlanData,
            taskMapDataJSON : JSON.stringify(this.taskMap),
            planId : this.ShopPlanData.Id,
            jump : false,
            ownerId : this.selectedFloorwalkerId
        }).then(result => {
            if (result.isSucess) {
                this.ShopPlanData = result.ShopPlanData;
                this.monthplans = result.MonthPlans;
                this.dayOptions = result.dayAndWeekDate;
                this.myDate = result.nowDate;
                this.isShowSpinner = false;
                this.taskMap = result.taskMap;
                // this.showEditInput = false;
                this.isShowSpinner = false;
                this.plannedQuantitySum = result.plannedQuantitySum;
                this.actualQuantitySum = result.actualQuantitySum;
                // if (!this.recordId) {
                //     this.recordId = result.ShopPlanData.Id;
                // }
                this.ownerName = result.ownerName;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: this.label.SaveSucessful,
                    variant: 'Success',
                }));
                this.isChange = false;
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));
                this.isShowSpinner = false;    
            }
        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Error,
                variant: 'error',
            }));
            this.isShowSpinner = false;
            
        });
    }

    viewImgMethod(event) {
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        this.sampleImages = this.cxjls[index].sampleImageList;
        this.showPhotoPage = true;
        this.isModalOpen = false;
    }

    viewImag(event) {
        this.viewImg = '';
        this.showPhotoPage = false;
        this.isViewImgOpen = true;
        this.viewImg = event.target.name;
    }

    closeViewModal() {
        this.isViewImgOpen = false;  
        this.showPhotoPage = true;  
    }
    closeviewImgMethod() {
        this.showPhotoPage = false;
        this.isModalOpen = true;
    }

    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

    onSelect(event) {
        this.showSelectList = false;
        this.floorwalkerRecords = [];
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        console.log('selectedId: ' + selectedId);
        console.log('selectedName: ' + selectedName);
        this.isShowSpinner = true;
        this.searchTerm = selectedName;
        this.selectedFloorwalkerId = selectedId;
        this.notSave();
        
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    onChange(event) {
        this.searchTerm = event.target.value;
        filterFloorwalker({name : this.searchTerm}).then(result =>{
            console.log('userResult: ' + JSON.stringify(result));
            this.floorwalkerRecords = result;
            if(this.floorwalkerRecords.length > 0) {
                this.showSelectList = true;
            } else {
                this.showSelectList = false;
            }
        }).catch(error =>{
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Error,
                variant: 'error',
            }));
        })
    }

}