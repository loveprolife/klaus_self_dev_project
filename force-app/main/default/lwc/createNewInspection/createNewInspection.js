import { LightningElement, track, wire, api } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
//apex methods
import getData from '@salesforce/apex/CreateNewInspectionController.getData';
import haveRepeatingData from '@salesforce/apex/CreateNewInspectionController.haveRepeatingData';
import saveData from '@salesforce/apex/CreateNewInspectionController.saveData';
import getReport from '@salesforce/apex/CreateNewInspectionController.getReport';
import approvalSubmit from '@salesforce/apex/CreateNewInspectionController.approvalSubmit';
import approvalProcess from '@salesforce/apex/CreateNewInspectionController.approvalProcess';
import judgeCountry from '@salesforce/apex/NewPromoterDailyReportActionController.judgeCountry';//Lay add 区分国家
//跟据输入的值查询巡店员
// import filterFloorwalker from '@salesforce/apex/CreateNewInspectionController.filterFloorwalker';
// custom label
import Error from '@salesforce/label/c.Error';
import Reset from '@salesforce/label/c.Reset';
import Channel_Name from '@salesforce/label/c.Channel_Name';
import City from '@salesforce/label/c.City';
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
import Common_Button_Submit_For_Approval from '@salesforce/label/c.Common_Button_Submit_For_Approval';
import Unscheduled from '@salesforce/label/c.Unscheduled';
import Submit from '@salesforce/label/c.Submit';
import Approve from '@salesforce/label/c.Approve';
import Reject from '@salesforce/label/c.Reject';
import Recall from '@salesforce/label/c.Recall';
import GridName from '@salesforce/label/c.GridName';
import Inspection_Task_Create_Limits from '@salesforce/label/c.Inspection_Task_Create_Limits';
import Inspection_Task_Create_Limits2 from '@salesforce/label/c.Inspection_Task_Create_Limits2';
import Inspection_Task_Create_Limits3 from '@salesforce/label/c.Inspection_Task_Create_Limits3';
import Inspection_Task_Create_Limits4 from '@salesforce/label/c.Inspection_Task_Create_Limits4';
import Inspection_Task_Create_Limits5 from '@salesforce/label/c.Inspection_Task_Create_Limits5';
import Comments from '@salesforce/label/c.Comments';
import CommentsMissing from '@salesforce/label/c.CommentsMissing';
import Submit_Success from '@salesforce/label/c.Submit_Success';
import Submit_Limit from '@salesforce/label/c.Submit_Limit';
import Approve_Success from '@salesforce/label/c.Approve_Success';
import Reject_Success from '@salesforce/label/c.Reject_Success';
import Recall_Success from '@salesforce/label/c.Recall_Success';
import Inspection_Task_Create_Backup_Limits from '@salesforce/label/c.Inspection_Task_Create_Backup_Limits';
import Inspection_Task_Backup from '@salesforce/label/c.Inspection_Task_Backup';
import getPickList from '@salesforce/apex/TrainingController.getPickList';
import IconGreen from '@salesforce/resourceUrl/IconGreen';
import IconBlue from '@salesforce/resourceUrl/IconBlue';
import IconOrange from '@salesforce/resourceUrl/IconOrange';
import Inspection_Task_Planned_Store from '@salesforce/label/c.Inspection_Task_Planned_Store';
import Inspection_Task_Number from '@salesforce/label/c.Inspection_Task_Number';
import Inspection_Task_Plan_Visit from '@salesforce/label/c.Inspection_Task_Plan_Visit';
import Inspection_Task_Actual_Visit from '@salesforce/label/c.Inspection_Task_Actual_Visit';
import Inspection_Task_Unscheduled_Visit from '@salesforce/label/c.Inspection_Task_Unscheduled_Visit';
import Exceed_Timelimit from '@salesforce/label/c.Exceed_Timelimit';
import Add_Note from '@salesforce/label/c.Add_Note';
import Inspection_Task_Total_Plan from '@salesforce/label/c.Inspection_Task_Total_Plan';
import Inspection_Task_Planned_Unscheduled from '@salesforce/label/c.Inspection_Task_Planned_Unscheduled';
import deleteRecord from '@salesforce/apex/CreateNewInspectionController.deleteRecord';
import addPlanTask from '@salesforce/apex/CreateNewInspectionController.addPlanTask';
import saveNote from '@salesforce/apex/CreateNewInspectionController.saveNote';

export default class createNewInspection  extends LightningNavigationElement {
    @api recordId;
    @api yearTemp;
    @api monthTemp;
    @api ownerIdTemp;
    @api customerValueTemp;
    @api gridNameTemp;
    @api cityTemp;
    @api storeLevelTemp;
    @api storeNameTemp;
    
    @track isShowSpinner;
    @track isShowNoteSpinner;
    @track day =1 ;
    @track isModalOpen = false;
    @track isShowProductLine = false;
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
    @track visitedQuantitySum;
    @track unscheduledQuantitySum;
    @track taskTotal;
    @track taskCompletedTotal;
    @track totalStoreNum;
    @track planStoreNum;
    @track unscheduledQuantity;
    @track report;
    @track cxjls;
    @track jpjls;
    @track showDetail;
    @track isViewImgOpen;
    @track viewImg;
    @track isCurrentApprover;
    
    @track heightTable;
    @track ownerName;
    @track isChange;
    @track approvalConfirm;
    @track comments;
    @track isApprove;
    @track showCheckSave;
    @track oldYear;
    @track oldMonth;
    @track sampleImages=[];
    @track showPhotoPage;
    @track isPc = true;
    @track approve1Label;
    @track approve2Label;
    @track statusLabel;
    @track historyDatasNum = [];
    //是否可选巡店员
    @track canSelectFloorwalker = false;
    //巡店员
    @track currentUserRole;
    @track customerOptionValue = '';
    @track gridOptionValue = '';
    @track channelOptionValue = '';
    @track cityOptionValue = '';
    @track storeLevelOptionValue = '';
    @track storeNameOptionValue = '';
    @track floorwalkers=[];
    @track approvers=[];
    @track customerName=[];
    @track griddingName=[];
    @track channelName=[];
    @track cityName=[];

    // 根据salesRegion 展示对应的搜索框 20241101 YYL
    @track isShowFilter = true;
    // 根据salesRegion 展示客户信息还是渠道信息
    @track isShowArgentina = false;
    // 四期国家隐藏Inspection_Task_Backup 20241115 YYL
    @track isShowBackup = false;
    @track salesRegionFilter = ['Hisense USA','Hisense Canada','Hisense Peru'];

    // 存放所选门店的Customer 20241029 YYL
    @track customerFilter=[];
    // 存放所选门店的Grid 20241029 YYL
    @track griddingFilter=[];
    // 存放所选门店的Channel 20241104 YYL
    @track channelFilter=[];
    // 存放所选门店的City 20241104 YYL
    @track cityFilter=[];
    // 存放所选门店
    @track storeNameFilter=[];

    @track IconGreen = IconGreen;
    @track IconBlue = IconBlue;
    @track IconOrange = IconOrange;
    @track modalOpenStyle;
    @track showTooltipFlag = false;
    @track salesRegion = '';

    get isManager(){
        return this.currentUserRole == 0?true:false;
    }
    @track showSave;
    get showSaveButton(){
        if((true||true) && this.ShopPlanData.Name == null){
            return true;
        }
        if(this.ShopPlanData.Status__c == 'Approved'){
            return false;
        }
        if(this.currentUserRole == 4 ){
            return false;
        }
        if((true||(true && this.isSubmiter)) && this.ShopPlanData.Status__c != 'New' && this.ShopPlanData.Status__c != 'Rejected'){
            return false;
        }else if(true && !this.isSubmiter && this.ShopPlanData.Status__c != 'New' && this.ShopPlanData.Status__c != 'Rejected' ){
            return false;
        }else if(!this.showSave){
            return false;
        }else{
            return true;
        }
    }
    @track floorwalkerRecords=[];
    @track showSelectList =false;

    @api searchPlaceholder='Search';
    @track selectedFloorwalkerId;
    @track selectedFloorwalkerName;
    @track selectedApproverId1;
    @track selectedApproverId2;
    @track comments;
    @track blurTimeout;
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    height;
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
        Mobiletip,
        Common_Button_Submit_For_Approval,
        Unscheduled,
        Submit,
        Approve,
        Reject,
        Recall,
        Inspection_Task_Create_Limits,
        Inspection_Task_Create_Limits2,
        Inspection_Task_Create_Limits3,
        Inspection_Task_Create_Limits4,
        Inspection_Task_Create_Limits5,
        Comments,
        CommentsMissing,
        Submit_Success,
        Submit_Limit,
        Approve_Success,
        Reject_Success,
        Recall_Success,
        Inspection_Task_Create_Backup_Limits,//add 20231013
        Inspection_Task_Backup,//add 20231013
        GridName,
        Reset,
        Channel_Name,
        City,
        Inspection_Task_Planned_Store,
        Inspection_Task_Number,
        Inspection_Task_Plan_Visit,
        Inspection_Task_Actual_Visit,
        Inspection_Task_Unscheduled_Visit,
        Add_Note,
        Exceed_Timelimit,
        Inspection_Task_Total_Plan,
        Inspection_Task_Planned_Unscheduled,
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

    @wire(getPickList, {objectName : 'Shop__c', fieldName : 'Shop_Level__c'})
    storeLevelOptions;

    get showSubmit(){
        return this.ShopPlanData.Name && (true|| true)?((this.ShopPlanData.Status__c=='New'||this.ShopPlanData.Status__c=='Rejected')?true:false):false;
    }

    get showRecall(){
        return this.isSubmiter && (this.ShopPlanData.Status__c=='Submitted'||this.ShopPlanData.Status__c=='In Approval') && this.ShopPlanData.Submiter__c == this.ShopPlanData.OwnerId__c?true:false;
    }

    get showApprove(){
        // return ((true && !this.isSubmiter && this.ShopPlanData.Status__c=='Submitted') || ( true && ((this.ShopPlanData.Status__c=='Submitted' && this.ShopPlanData.Approver1__c == null )||this.ShopPlanData.Status__c=='In Approval'))) && this.isCurrentApprover ?true:false;
        return this.showApproveAction;
    }

    get canEditApprover(){
        return true&& (this.ShopPlanData.Status__c=='New'||this.ShopPlanData.Status__c=='Rejected'||this.ShopPlanData.Status__c==null)?false:true
    }
    start() {
        let _this = this;
        setTimeout(()=>{
            let h = _this.height = document.documentElement.clientHeight;
            setTimeout(()=>{
                _this.height = h - document.documentElement.scrollHeight + document.documentElement.clientHeight;
            }, 10);
        }, 1000);
    }
    get style() {
        return true ? 'max-height: ' + this.height + 'px;' : ''
    }
    get style2(){
        var width;
        if(document.documentElement.scrollHeight <= document.documentElement.clientHeight){
            width = 'width: 5%;';
        }else{
            width = 'width: 6.1%;';
        }
        return width;
    }
    floorwalkerChange(event) {
        console.log('wwww-event.detail.value--------'+event.detail.value);
        console.log('wwww-event.detail.id--------'+event.detail.id);
        if(event.detail.id != undefined && event.detail.id != '' && event.detail.id != null){
            // this.oldYear = this.ShopPlanData.Inspection_Year__c;
            this.ownerName = event.detail.id;
            this.selectedFloorwalkerId = event.detail.id;
            this.selectedFloorwalkerName = event.detail.value;
            // this.ShopPlanData.Owner.Name = this.ownerName;
            // this.callApexHaveRepeatingDataMethod();
            this.refresh();
        }
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

    storeLevelChange(event) {
        this.storeLevelOptionValue = event.detail.value; 
        // if (!this.recordId) {
        this.callApexHaveRepeatingDataMethod();   
        // }

    }

    customerChange(event){
        console.log(event.detail.value);
        if(event.detail.value == this.customerOptionValue){
            return false;
        }
        this.customerOptionValue = event.detail.value;
        // this.gridOptionValue = '';
        this.callApexHaveRepeatingDataMethod();
    }

    gridChange(event){
        console.log(event.detail.value);
        if(event.detail.value == this.gridOptionValue){
            return false;
        }
        // 根据新需求修改为选择grid筛选条件，不清空客户筛选条件 20241029 YYL
        this.gridOptionValue = event.detail.value;
        // this.customerOptionValue = '';

        this.callApexHaveRepeatingDataMethod();
    }

    channelChange(event){
        console.log(event.detail.value);
        if(event.detail.value == this.channelOptionValue){
            return false;
        }
        this.channelOptionValue = event.detail.value;

        this.callApexHaveRepeatingDataMethod();
    }

    cityChange(event){
        console.log(event.detail.value);
        if(event.detail.value == this.cityOptionValue){
            return false;
        }
        this.cityOptionValue = event.detail.value;

        this.callApexHaveRepeatingDataMethod();
    }

    storeNameChange(event){
        console.log(event.detail.value);
        if(event.detail.value == this.storeNameOptionValue){
            return false;
        }
        this.storeNameOptionValue = event.detail.value;

        // this.callApexHaveRepeatingDataMethod();
    }
    // 门店名称 点击图标搜索
    handlerSearchStoreName(){
        this.callApexHaveRepeatingDataMethod();
    }
    // 门店名称 回车搜索
    handleKeyUp(evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.callApexHaveRepeatingDataMethod();
        }
    }

    callApexHaveRepeatingDataMethod() {
        if (this.isChange) {
            this.showCheckSave = true;   
        }else{
            this.notSave();
        }

        var cmps = this.template.querySelector('c-searchable-combobox');
        if(cmps != null && cmps != undefined && cmps != ''){
            cmps.refresh(this.selectedFloorwalkerName);
        }
    }

    saveAndJump() {
        this.isShowSpinner = true;
        if (!this.ShopPlanData.Id) {
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
            ownerId : this.selectedFloorwalkerId,
            approver1 : this.selectedApproverId1,
            approver2 : this.selectedApproverId2
        }).then(result => {
            if (result.isSucess) {
                if (result.canCreate) {
                    this.ShopPlanData = result.ShopPlanData;
                    this.monthplans = result.MonthPlans;
                    console.log('result.MonthPlans--------'+JSON.stringify(result.MonthPlans));
                    console.log('result.MonthPlans.dayOptions--------'+JSON.stringify(result.MonthPlans.dayOptions));
                    console.log('result.dayAndWeekDate--------'+JSON.stringify(result.dayAndWeekDate));
                    this.dayOptions = result.dayAndWeekDate;
                    this.myDate = result.nowDate;
                    this.isShowSpinner = false;
                    this.taskMap = result.taskMap;
                    // this.showEditInput = false;
                    this.isShowSpinner = false;
                    this.plannedQuantitySum = result.plannedQuantitySum;
                    this.actualQuantitySum = result.actualQuantitySum;
                    this.unscheduledQuantity = result.unscheduledQuantity;
                    // 数据统计
                    this.taskTotal = result.unscheduledQuantitySum + result.visitedQuantitySum;
                    this.taskCompletedTotal = result.unscheduledQuantitySum + result.unVisitedQuantitySum;
                    this.planStoreNum = result.planStoreNum;
                    this.totalStoreNum = result.totalStoreNum;
                    // if (!this.recordId) {
                    //     this.recordId = result.ShopPlanData.Id;
                    // }
                    this.ownerName = result.ownerName;
                    this.isSubmiter = result.isSubmiter;
                    this.showApproveAction = result.showApproveAction;
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
                    this.showSave = result.showSaveButton;
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
        // this.start();
        console.log('wwwthis.selectedFloorwalkerId-----'+this.selectedFloorwalkerId);
        console.log('wwwthis.custoemrValue-----'+this.customerOptionValue);
        console.log('wwwthis.gridName-----'+this.gridOptionValue);
        console.log('wwwthis.storeLevelOptionValue-----'+this.storeLevelOptionValue);
        console.log('wwwthis.storeNameOptionValue-----'+this.storeNameOptionValue);
        //调用后台逻辑
        if (this.ShopPlanData.Inspection_Year__c && this.ShopPlanData.Inspection_Month__c) {
            haveRepeatingData({
                year : this.ShopPlanData.Inspection_Year__c,
                month : this.ShopPlanData.Inspection_Month__c,
                ownerId : this.selectedFloorwalkerId,
                customerValue : this.customerOptionValue,
                gridName : this.gridOptionValue,
                channelValue : this.channelOptionValue,
                city : this.cityOptionValue,
                storeLevel : this.storeLevelOptionValue,
                storeName : this.storeNameOptionValue,
            }).then(result => {
                if (result.isSucess) {
                    if (result.canCreate) {
                        // if (result.recordId) {//如果存在
                        //     this.showDuplecation = true;
                        //     this.duplicationData = result.ShopPlanData;
                        //     this.dataUrl = '/'+result.recordId;
                        //     this.isShowSpinner = false;
                        // }else{

                        console.log('wwwresult.MonthPlans--------'+JSON.stringify(result.MonthPlans));
                        console.log('wwwwwfffffff--------'+JSON.stringify(result));
                        this.monthplans = result.MonthPlans;
                        console.log('wwwresult.MonthPlans.dayOptions--------'+JSON.stringify(result.MonthPlans.dayOptions));
                        console.log('wwwresult.dayAndWeekDate--------'+result.dayAndWeekDate);
                        this.salesRegion = result.salesRegion;
                        this.dayOptions = result.dayAndWeekDate;
                        this.myDate = result.nowDate;
                        this.isShowSpinner = false;
                        this.taskMap = result.taskMap;
                        this.plannedQuantitySum = result.plannedQuantitySum;
                        this.actualQuantitySum = result.actualQuantitySum;
                        this.visitedQuantitySum = result.visitedQuantitySum;
                        this.unVisitedQuantitySum = result.unVisitedQuantitySum;
                        this.unscheduledQuantitySum = result.unscheduledQuantitySum;
                        // 数据统计
                        this.taskTotal = result.unscheduledQuantitySum + result.visitedQuantitySum;
                        this.taskCompletedTotal = result.unscheduledQuantitySum + result.unVisitedQuantitySum;
                        this.planStoreNum = result.planStoreNum;
                        this.totalStoreNum = result.totalStoreNum;

                        this.currentUserRole = result.currentUserRole;
                        // if(result.unscheduledQuantity != null && result.unscheduledQuantity != undefined){
                        //     this.unscheduledQuantity = result.unscheduledQuantity;
                        // }else{
                        //     this.unscheduledQuantity = 0;
                        // }
                        // if (this.recordId) {
                        //     this.showEditInput = false;
                        // }else{
                        //     this.showEditInput = true;
                        // }
                        this.showDuplecation = false;
                        this.showSave = result.showSaveButton;
                        this.ownerName = result.ownerName;
                        this.ShopPlanData = result.ShopPlanData;
                        this.isChange = false;
                        this.showCheckSave = false;

                        this.selectedApproverId1 = this.ShopPlanData.Approver1__c;
                        this.selectedApproverId2 = this.ShopPlanData.Approver2__c;
                        this.isSubmiter = result.isSubmiter;
                        this.showApproveAction = result.showApproveAction;
                        this.historyDatasNum = result.historyDatasNum;

                        // 刷新Customer和Grid筛选框数据 20241031 YYL
                        this.customerAndGridDistinct(result.MonthPlans,result.salesRegion);

                        // 根据salesRegion 选用对应的筛选框联动逻辑 20241105 YYL
                        // if(this.salesRegionFilter.indexOf(result.salesRegion) !== -1){

                        //     //根据所选Grid显示门店的channel 20241105 YYL
                        //     if(this.gridOptionValue){
                        //         this.channelFilter = this.channelFilter.filter(obj => obj.filterGrid == this.gridOptionValue);
                        //         this.cityFilter = this.cityFilter.filter(obj => obj.filterGrid == this.gridOptionValue);
                        //         this.storeNameFilter = this.storeNameFilter.filter(obj => obj.filterGrid == this.gridOptionValue);
                        //     }

                        //     //根据所选Grid显示门店的channel 20241105 YYL
                        //     if(this.channelOptionValue){
                        //         this.griddingFilter = this.griddingFilter.filter(obj => obj.filterChannel == this.channelOptionValue);
                        //         this.cityFilter = this.cityFilter.filter(obj => obj.filterChannel == this.channelOptionValue);
                        //         this.storeNameFilter = this.storeNameFilter.filter(obj => obj.filterChannel == this.channelOptionValue);
                        //     }

                        //     //根据所选Grid显示门店的channel 20241105 YYL
                        //     if(this.cityOptionValue){
                        //         this.griddingFilter = this.griddingFilter.filter(obj => obj.filterCity == this.cityOptionValue);
                        //         this.channelFilter = this.channelFilter.filter(obj => obj.filterCity == this.cityOptionValue);
                        //         this.storeNameFilter = this.storeNameFilter.filter(obj => obj.filterCity == this.cityOptionValue);
                        //     }

                        // }else{
                        //     //根据所选Grid门店显示门店的Customer 20241029 YYL
                        //     if(this.gridOptionValue){
                        //         this.customerFilter = this.customerFilter.filter(obj => obj.filter == this.gridOptionValue);
                        //     }

                        //     //根据所选Customer门店显示门店的Grid 20241029 YYL
                        //     if(this.customerOptionValue){
                        //         this.griddingFilter = this.griddingFilter.filter(obj => obj.filter == this.customerOptionValue);
                        //     }
                        // }

                        console.log('wwwwgriddingFilter' + JSON.stringify(this.griddingFilter));
                        
                        // }    
                    }else{
                        this.showSave = result.showSaveButton;
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
        // judgeCountry().then(data => {
        //     if (data.isSuccess) {
        //         this.isShowProductLine = !(data.data.Thailand || data.data.Indonesia || data.data.Malaysia || data.data.Philippines || data.data.Vietnam || data.data.Japan);
        //     } else {
        //         this.isShowSpinner = false;
        //         this.showError(data.message);
        //     }
        // }).catch(error => {
        //     this.isShowSpinner = false;
        //     this.catchError(error);
        // })

        this.storeLevelOptionValue = this.storeLevelTemp;
        this.customerOptionValue = this.customerValueTemp;
        this.gridOptionValue = this.gridNameTemp;
        this.cityOptionValue = this.cityTemp;
        this.storeNameOptionValue = this.storeNameTemp;

        window.addEventListener('scroll', this.handleScroll);

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
        this.start();
        getData({
            planId : this.recordId,
            customerValue : this.customerValueTemp,
            gridName : this.gridNameTemp,
            city : this.cityTemp,
            storeLevel : this.storeLevelTemp,
            storeName : this.storeNameTemp,
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
                this.salesRegion = result.salesRegion;
                this.ShopPlanData = result.ShopPlanData;
                this.monthplans = result.MonthPlans;
                this.dayOptions = result.dayAndWeekDate;
                console.log('result.dayAndWeekDate--------'+JSON.stringify(result.dayAndWeekDate));
                this.myDate = result.nowDate;
                this.isCurrentApprover = result.isCurrentApprover;
                this.isShowSpinner = false;
                this.taskMap = result.taskMap;
                this.plannedQuantitySum = result.plannedQuantitySum;
                this.actualQuantitySum = result.actualQuantitySum;
                this.visitedQuantitySum = result.visitedQuantitySum;
                this.unVisitedQuantitySum = result.unVisitedQuantitySum;
                this.unscheduledQuantitySum = result.unscheduledQuantitySum;
                // 数据统计
                this.taskTotal = result.unscheduledQuantitySum + result.visitedQuantitySum;
                this.taskCompletedTotal = result.unscheduledQuantitySum + result.unVisitedQuantitySum;
                this.planStoreNum = result.planStoreNum;
                this.totalStoreNum = result.totalStoreNum;

                this.approve1Label = result.approve1Label;
                this.approve2Label = result.approve2Label;
                this.statusLabel = result.statusLabel;
                this.currentUserRole = result.currentUserRole;
                //是否可选择巡店员
                this.canSelectFloorwalker = result.canSelectFloorwalker;
                this.selectedFloorwalkerId = result.ownerId;
                this.selectedFloorwalkerName = result.ownerName;
                //巡店员
                result.floorwalkers.forEach(walker => {
                    this.floorwalkers.push({ label: walker.Name, value: walker.Id });
                });
                
                requestAnimationFrame(() => {
                    this.customerAndGridDistinct(this.monthplans,result.salesRegion);
                });

                //过滤掉空数据集
                console.log('this.floorwalkers.length-------'+this.floorwalkers.length);
                //approver
                // if(result.ShopPlanData.Approver1__c){
                    this.selectedApproverId1 = result.ShopPlanData.Approver1__c;
                // }
                // if(result.ShopPlanData.Approver2__c){
                    this.selectedApproverId2 = result.ShopPlanData.Approver2__c;
                // }
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
                this.showSave = result.showSaveButton;
                this.isSubmiter = result.isSubmiter;
                this.showApproveAction = result.showApproveAction;
                this.ownerName = result.ownerName;
                this.searchTerm = result.ownerName;
                this.oldYear = this.ShopPlanData.Inspection_Year__c;
                this.oldMonth = this.ShopPlanData.Inspection_Month__c;

                this.historyDatasNum = result.historyDatasNum;
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

    disconnectedCallback() {
        window.removeEventListener('scroll', this.handleScroll); // 避免内存泄漏:ml-citation{ref="4" data="citationList"}
    }

    // 处理Customer和Grid筛选框数据信息 20241031 YYL
    customerAndGridDistinct(monthplans,salesRegion){
        console.log('wwwwsalesRegion' + salesRegion);
        // 根据salesRegion 展示对应的筛选框
        if(this.salesRegionFilter.indexOf(salesRegion) !== -1){
            this.isShowFilter = false;
            this.isShowBackup = false;
        }else{
            this.isShowFilter = true;
            this.isShowBackup = true;
        }

        // 阿根廷展示渠道信息
        if(salesRegion == 'Hisense Argentina'){
            this.isShowArgentina = true;
        }else{
            this.isShowArgentina = false;
        }

        var customerArray = [];
        var griddingArray = [];
        var channelArray = [];
        var cityArray = [];
        var storeNameArray = [];

        if(monthplans.length > 0){
            //客户和区域筛选框数据 
            //新增渠道和城市筛选框数据 20241104 YYL
            monthplans.forEach(plans => {
                //过滤掉客户名称非空和重复数据
                if(plans.shopOwner != null){
                    if(customerArray.length > 0){
                        if(this.distinctOption(customerArray,plans.shopOwner)){
                            // 新增过滤条件字段filter 20241029 YYL
                            customerArray.push({ label : plans.shopOwner, value : plans.shopOwner, filter : plans.shopGridding});
                            // this.customerName.push({ label : plans.shopOwner, value : plans.shopOwner, filter : plans.shopGridding});
                        }
                    }else{
                        // 新增过滤条件字段filter 20241029 YYL
                        customerArray.push({ label : plans.shopOwner, value : plans.shopOwner, filter : plans.shopGridding});
                        // this.customerName = this.customerFilter;
                    }
                }

                //过滤掉区域非空和重复数据
                if(plans.shopGridding != null){
                    if(griddingArray.length > 0){
                        if(this.distinctOption(griddingArray,plans.shopGridding)){
                            // 新增过滤条件字段filter 20241029 YYL
                            griddingArray.push({ label : plans.shopGridding, value : plans.shopGridding, filter : plans.shopOwner, filterChannel : plans.shopChannel, filterCity : plans.shopCity});
                            // this.griddingName.push({ label : plans.shopGridding, value : plans.shopGridding, filter : plans.shopOwner, filterChannel : plans.shopChannel, filterCity : plans.shopCity});
                        }
                    }else{
                        // 新增过滤条件字段filter 20241029 YYL
                        griddingArray.push({ label : plans.shopGridding, value : plans.shopGridding, filter : plans.shopOwner, filterChannel : plans.shopChannel, filterCity : plans.shopCity});
                        // this.griddingName = this.griddingFilter;
                    }
                }

                //过滤掉渠道非空和重复数据 20241104 YYL
                if(plans.shopChannel != null){
                    if(channelArray.length > 0){
                        if(this.distinctOption(channelArray,plans.shopChannel)){
                            channelArray.push({ label : plans.shopChannel, value : plans.shopChannel, filterGrid : plans.shopGridding, filterCity : plans.shopCity});
                            // this.channelName.push({ label : plans.shopChannel, value : plans.shopChannel, filterGrid : plans.shopGridding, filterCity : plans.shopCity});
                        }
                    }else{
                        channelArray.push({ label : plans.shopChannel, value : plans.shopChannel, filterGrid : plans.shopGridding, filterCity : plans.shopCity});
                        // this.channelName = this.channelFilter;
                    }
                }

                //过滤掉城市非空和重复数据 20241104 YYL
                if(plans.shopCity != null){
                    if(cityArray.length > 0){
                        if(this.distinctOption(cityArray,plans.shopCity)){
                            // 新增过滤条件字段filter 20241029 YYL
                            cityArray.push({ label : plans.shopCity, value : plans.shopCity, filterGrid : plans.shopGridding, filterChannel : plans.shopChannel});
                            // this.cityName.push({ label : plans.shopCity, value : plans.shopCity, filterGrid : plans.shopGridding, filterChannel : plans.shopChannel});
                        }
                    }else{
                        // 新增过滤条件字段filter 20241029 YYL
                        cityArray.push({ label : plans.shopCity, value : plans.shopCity, filterGrid : plans.shopGridding, filterChannel : plans.shopChannel});
                        // this.cityName = this.cityFilter;
                    }
                }

                //过滤掉门店名称非空和重复数据 
                if(plans.shopName != null){
                    if(storeNameArray.length > 0){
                        if(this.distinctOption(storeNameArray,plans.shopName)){
                            // 新增过滤条件字段filter
                            storeNameArray.push({ 
                                label : plans.shopName, 
                                value : plans.shopName, 
                                filterGrid : plans.shopGridding, 
                                filterChannel : plans.shopChannel,
                                filterCity : plans.shopCity,
                            });
                        }
                    }else{
                        // 新增过滤条件字段filter
                        storeNameArray.push({ 
                            label : plans.shopName, 
                            value : plans.shopName, 
                            filterGrid : plans.shopGridding, 
                            filterChannel : plans.shopChannel,
                            filterCity : plans.shopCity,
                        });
                    }
                }

            });
            customerArray.unshift({ label : '--None--', value : ''});
            griddingArray.unshift({ label : '--None--', value : ''});
            cityArray.unshift({ label : '--None--', value : ''});
            this.customerFilter = customerArray;
            this.griddingFilter = griddingArray;
            this.channelFilter = channelArray;
            this.cityFilter = cityArray;
            this.storeNameFilter = storeNameArray;
        }else{
            // 清空历史的筛选框数据
            this.customerFilter = [];
            // this.customerName = [];
            this.griddingFilter = [];
            // this.griddingName = [];
            this.channelFilter = [];
            // this.channelName = [];
            this.cityFilter = [];
            // this.cityName = [];
            this.storeNameFilter = [];
        }
        
    }

    distinctOption(arrs,value){

        //判断value值是否已存在
        var flag = true;

        for(var index in arrs){
            if(arrs[index].value == value){
                flag = false;
                break;
            }
        }
        
        return flag;
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

    clear(){
        this.gridOptionValue = '';
        this.customerOptionValue = '';

        // 新增刷新渠道 和 城市 筛选框按钮 20241104 YYL
        this.channelOptionValue = '';
        this.cityOptionValue = '';

        this.storeLevelOptionValue = '';
        this.storeNameOptionValue = '';
    }

    // 新增刷新Customer Name 和 Grid Name 筛选框按钮 20241029 YYL
    refresh(){
        this.gridOptionValue = '';
        this.customerOptionValue = '';

        // 新增刷新渠道 和 城市 筛选框按钮 20241104 YYL
        this.channelOptionValue = '';
        this.cityOptionValue = '';

        this.storeLevelOptionValue = '';
        this.storeNameOptionValue = '';

        this.callApexHaveRepeatingDataMethod();
    }

    //go to daily report
    goToDailyReport(event){
        
        console.log('storeId--------'+event.target.dataset.id);
        // debugger;
        this.goToComponent('c__LWCWrapper',{
            'lwcName' : 'newInspectorDailyReportLwc',
            'recordId' : '',
            'storeId' : event.target.dataset.id
           });
    }

    clickTimer = null;
    tempIdList = [];
    async createInspectionShopTask(event){
        event.stopPropagation();
        clearTimeout(this.clickTimer); // 清除已有计时器
        
        let tempId = event.target.getAttribute("data-tempid");
        // 防止上次点击事件未完成 重复点击
        let tempIdIndex = this.tempIdList.indexOf(tempId);
        if (tempIdIndex !== -1) {
            this.tempIdList.splice(tempIdIndex, 1);
            return false;
        }else {
            this.tempIdList.push(tempId);
        }

        // const colIndex = event.target.dataset.col;
        // let parentElement = event.target.parentElement
        // let parentElementParentElement = event.target.parentElement.parentElement;
        // // 交叉定位
        // this.template.querySelectorAll('.highlight-row, .highlight-col').forEach(el => {
        //     el.classList.remove('highlight-row', 'highlight-col');
        // });
        // // 高亮整列
        // this.template.querySelectorAll(`[data-col="${colIndex}"]`).forEach(cell => {
        //     cell.classList.add('highlight-col');
        // });
        // // 高亮表头所在行
        // parentElement.classList.add('highlight-row');
        // if(parentElement.tagName == 'TD'){
        //     parentElementParentElement.classList.add('highlight-row');
        // }

        let nameValue = event.target.getAttribute("name")+'';
        let taskId = event.target.getAttribute("data-task");
        let isPlan = event.target.getAttribute("data-isPlan");

        this.clickTimer = setTimeout(() => {
            console.log('wwww----日历点击事件');
            let pickValue = nameValue.split(':');
            let onclickDay = new Date(pickValue[0].replaceAll('-','/'));
            let nowDate = new Date(this.myDate.replaceAll('-','/'));
            // let backupStatus =  event.target.getAttribute("abbr");//Add By Ethan 20231013 Modified 20231119
            this.showDisable = false;
            this.isModalOpen = false;
            this.showButton = false;
            this.showDeleteButton = false;
            this.showDetail = false;
            var flag = false;
            var errorMsg;

            if(onclickDay < nowDate){
                flag = true;
                errorMsg = this.label.Inspection_Task_Create_Limits;//You cannot create tasks for dates before today.
            }
            // else if( this.ShopPlanData.Status__c != 'New' && this.ShopPlanData.Status__c != 'Rejected' && this.ShopPlanData.Status__c != 'Approved' && this.ShopPlanData.Status__c != null){
            //     flag = true;
            //     errorMsg = this.label.Inspection_Task_Create_Limits2;//The Inspection Plan is in Approval，cannot be modified/created.
            // }else if(this.ShopPlanData.Status__c == 'Approved'){
            //     flag = true;
            //     errorMsg = this.label.Inspection_Task_Create_Limits3;//The Inspection Plan has been approved，cannot be modified/created.
            // }
            else if(this.historyDatasNum != undefined  ){
                this.historyDatasNum.forEach(item =>{
                    if(pickValue[pickValue.length-1]==item){
                        flag = true;
                        errorMsg = this.label.Inspection_Task_Create_Limits4;//The floor walker is not responsible for this store anymore.
                    }
                })
            }

            if(flag){
                if(errorMsg != undefined){
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: errorMsg,
                        variant: 'error',
                    }));
                }
            }else {
                if(taskId != null &&  taskId != undefined && taskId != ''){
                    console.log('wwww----日历点击删除');
                    if(isPlan == 'false'){
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'error',
                            message: this.label.Inspection_Task_Create_Limits5,
                            variant: 'error',
                        }));
                        return false;
                    }
                    deleteRecord({
                        recordId : taskId, 
                    })
                    .then(result => {
                        if(result){
                            this.monthplans.forEach(item => {
                                // console.log('wwwww--' + JSON.stringify(item));
                                // 门店id 
                                let shopId = pickValue[2];
                                if(item.shopId == shopId){
                                    let flag = false;
                                    let flagStore = true; // 门店中是否存在其他task任务
                                    item.dayOptions.forEach(day => {
                                        // 定位到当前taskId
                                        if(day.taskId == taskId){
                                            day.taskId = '';
                                            day.status1 = '';
                                            day.isPlan = false;
                                            day.taskAndDate = pickValue[0] + ':' + pickValue[2] + ':' + pickValue[3];
                                            day.isExceedTimelimit = false;
                                            
                                            flag = true;
                                        }

                                        if(flag && day.taskId == result.nextTaskId){
                                            day.isExceedTimelimit = result.isExceedTimelimitNext;
                                            flag = false;
                                        }

                                        if(day.taskId != null && day.taskId != '' && day.taskId != undefined && day.taskId != taskId){
                                            flagStore = false;
                                        }
                                    });
                                    item.plannedQuantity = item.plannedQuantity - 1;
                                    if(flagStore){
                                        this.planStoreNum = this.planStoreNum - 1;
                                    }
                                }
                            });
                            // 刷新计数
                            this.taskTotal = this.taskTotal - 1;
                            this.visitedQuantitySum = this.visitedQuantitySum - 1;
                        }
                        this.tempIdList = this.tempIdList.filter(item => item !== tempId);
                    }).catch(error => {
                        this.tempIdList = this.tempIdList.filter(item => item !== tempId);
                        // this.dispatchEvent(new ShowToastEvent({
                        //     title: 'Error',
                        //     message: 'Delete failure!' + JSON.stringify(error),
                        //     variant: 'Error',
                        // }));
                    })
                }else {
                    console.log('wwww----日历点击新增');
                    addPlanTask({
                        shopId : pickValue[1], 
                        inspectionDate : pickValue[0], 
                        inspectionPlanId : this.ShopPlanData.Id, 
                        ownerId : this.selectedFloorwalkerId,
                    })
                    .then(result => {
                        if(result){
                            let dayNumber = pickValue[0].split('-');
                            this.taskMap[pickValue[1] + '' + dayNumber[0] + '-'+ parseInt(dayNumber[1]) + '-' + parseInt(dayNumber[2]) + 'NEW'] = result.task;
                            this.monthplans.forEach(item => {
                                // console.log('wwwww--' + JSON.stringify(item));
                                // 门店id 
                                let shopId = pickValue[1];
                                if(item.shopId == shopId){
                                    // 定位到当前日期，下一个有task的日期
                                    let flag = false;
                                    let flagStore = true; // 门店中是否存在其他task任务
                                    item.dayOptions.forEach(day => {
                                        if(day.taskId != null && day.taskId != '' && day.taskId != undefined){
                                            flagStore = false;
                                        }

                                        // 定位到当前taskId
                                        if(day.taskAndDate == nameValue){
                                            day.taskId = result.task.Id;
                                            day.status1 = '〇';
                                            day.isPlan = true;
                                            day.taskAndDate = pickValue[0] + ':' + result.task.Id + ':' + pickValue[1] + ':' + pickValue[2];
                                            day.isExceedTimelimit = result.isExceedTimelimit;

                                            flag = true;
                                        }

                                        if(flag && day.taskId == result.nextTaskId){
                                            day.isExceedTimelimit = result.isExceedTimelimitNext;
                                            flag = false;
                                        }
                                    });
                                    item.plannedQuantity = item.plannedQuantity + 1;
                                    if(flagStore){
                                        this.planStoreNum = this.planStoreNum + 1;
                                    }
                                }
                            });
                            // 刷新计数
                            this.taskTotal = this.taskTotal + 1;
                            this.visitedQuantitySum = this.visitedQuantitySum + 1;
                        }
                        this.tempIdList = this.itempIdListems.filter(item => item !== tempId);
                    }).catch(error => {
                        this.tempIdList = this.tempIdList.filter(item => item !== tempId);
                        // this.dispatchEvent(new ShowToastEvent({
                        //     title: 'Error',
                        //     message: 'Insert failure!' + JSON.stringify(error),
                        //     variant: 'Error',
                        // }));
                    })
                }
            }
        }, 300);
    }

    closeModal(){
        // this.isModalOpen = false;
        this.showTooltipFlag = false;
    }

    // 保存Note
    async saveNote(){
        console.log('wwwww-----' + JSON.stringify(this.task));
        this.isShowNoteSpinner = true;
        saveNote({
            shopTask : this.task
        })
        .then(result => {
            if(result){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: this.label.SaveSucessful,
                    variant: 'Success',
                }));
                this.showTooltipFlag = false;
            }
            this.isShowNoteSpinner = false;
        }).catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Save failure!' + JSON.stringify(error),
                variant: 'Error',
            }));
            this.isShowNoteSpinner = false;
        })

    }

    handleFiledChange(event){
        this.task[event.currentTarget.fieldName] = event.target.value;
    }

    savePlan(callback) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: this.label.SaveSucessful,
            variant: 'Success',
        }));
        // System.debug('---save---');
        // this.isShowSpinner = true;
        // if (!this.recordId) {
        //     const allValid = [...this.template.querySelectorAll('lightning-combobox')]
        //     .reduce((validSoFar, inputCmp) => {
        //                 inputCmp.reportValidity();
        //                 return validSoFar && inputCmp.checkValidity();
        //     }, true);
        //     if (!allValid) {
        //         this.isShowSpinner = false;
        //         return;
        //     }    
        // }
        // saveData({
        //     shopPlan : this.ShopPlanData,
        //     taskMapDataJSON : JSON.stringify(this.taskMap),
        //     planId : this.ShopPlanData.Id,
        //     jump : false,
        //     ownerId : this.selectedFloorwalkerId,
        //     approver1 : this.selectedApproverId1,
        //     approver2 : this.selectedApproverId2
        // }).then(result => {
        //     if (result.isSucess) {
        //         this.ShopPlanData = result.ShopPlanData;
        //         this.monthplans = result.MonthPlans;
        //         this.dayOptions = result.dayAndWeekDate;
        //         this.myDate = result.nowDate;
        //         this.isShowSpinner = false;
        //         this.taskMap = result.taskMap;
        //         this.isShowSpinner = false;
        //         this.plannedQuantitySum = result.plannedQuantitySum;
        //         this.actualQuantitySum = result.actualQuantitySum;
        //         this.unscheduledQuantity = result.unscheduledQuantity;
        //         this.visitedQuantitySum = result.visitedQuantitySum;
        //         this.unVisitedQuantitySum = result.unVisitedQuantitySum;
        //         this.unscheduledQuantitySum = result.unscheduledQuantitySum;
        //         // 数据统计
        //         this.taskTotal = result.unscheduledQuantitySum + result.visitedQuantitySum;
        //         this.taskCompletedTotal = result.unscheduledQuantitySum + result.unVisitedQuantitySum;
        //         this.planStoreNum = result.planStoreNum;
        //         this.totalStoreNum = result.totalStoreNum;
        //         this.ownerName = result.ownerName;
        //         if (typeof callback === 'function') {
        //             callback();
        //         }
        //         this.dispatchEvent(new ShowToastEvent({
        //             title: 'Success',
        //             message: this.label.SaveSucessful,
        //             variant: 'Success',
        //         }));
        //         this.isChange = false;

        //         this.clear();
                
        //     }else{
        //         this.dispatchEvent(new ShowToastEvent({
        //             title: 'error',
        //             message: result.errorMsg,
        //             variant: 'error',
        //         }));
        //         this.isShowSpinner = false;    
        //     }
        // }).catch(error => {
        //     console.log('error--------'+error);
        //     this.isShowSpinner = false;
        //     this.dispatchEvent(new ShowToastEvent({
        //         title: 'error',
        //         message: this.label.Error,
        //         variant: 'error',
        //     }));
        //     this.isShowSpinner = false;
            
        // });
    }
    //----------------Approval methods---------------------
    submitPlan(){
        // if(this.selectedApproverId1 != null){
            this.isShowSpinner = true;

            if(this.ShopPlanData.Id != null || this.ShopPlanData.Id != ''){
                approvalSubmit({
                    recordId : this.ShopPlanData.Id
                }).then(result => {
                    if(result.isSucess){
                        this.ShopPlanData = result.ShopPlanData;
                        this.isSubmiter = result.isSubmiter;
                        this.showApproveAction = result.showApproveAction;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success',
                            message: this.label.Submit_Success,
                            variant: 'Success',
                        }));
                        this.isShowSpinner = false;
                        
                    }else{
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'error',
                            message: result.errorMsg,
                            variant: 'error',
                        }));
                        this.isShowSpinner = false;
                    }
                    return;
                })
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: this.label.Submit_Limit,
                    variant: 'error',
                }));
                this.isShowSpinner = false;
            }

            // this.savePlan(()=>{
            //     if(this.ShopPlanData.Id != null || this.ShopPlanData.Id != ''){
            //         approvalSubmit({
            //             recordId : this.ShopPlanData.Id
            //         }).then(result => {
            //             if(result.isSucess){
            //                 this.ShopPlanData = result.ShopPlanData;
            //                 this.isSubmiter = result.isSubmiter;
            //                 this.showApproveAction = result.showApproveAction;
            //                 this.dispatchEvent(new ShowToastEvent({
            //                     title: 'Success',
            //                     message: this.label.Submit_Success,
            //                     variant: 'Success',
            //                 }));
            //                 this.isShowSpinner = false;
                            
            //             }else{
            //                 this.dispatchEvent(new ShowToastEvent({
            //                     title: 'error',
            //                     message: result.errorMsg,
            //                     variant: 'error',
            //                 }));
            //                 this.isShowSpinner = false;
            //             }
            //             return;
            //         })
            //     }else{
            //         this.dispatchEvent(new ShowToastEvent({
            //             title: 'error',
            //             message: this.label.Submit_Limit,
            //             variant: 'error',
            //         }));
            //         this.isShowSpinner = false;
            //     }
            // });
            // Promise.resolve([
            //     this.savePlan()
            // ]).then(() => {
                
            // })
            
        // }else{
        //     this.dispatchEvent(new ShowToastEvent({
        //         title: 'error',
        //         message: 'Please input approver',
        //         variant: 'error',
        //     }));
        //     this.isShowSpinner = false;
        // }
        
        
    }
    commentChange(event){
        this.comments = event.target.value;
    }
    approvePlan(){
        this.approvalConfirm = true;
        this.isApprove = false;
    }
    confirmApprove(){
        this.processApprove('Approve');
        this.approvalConfirm = false;
    }
    rejectPlan(){
        this.isApprove = true;
        this.approvalConfirm = true;
    }
    confirmReject(){
        if(this.isApprove && this.comments != null && this.comments != undefined){
            this.processApprove('Reject');
            this.approvalConfirm = false;
        }else{
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.CommentsMissing,
                variant: 'error',
            }));
        }
        
    }
    recallPlan(){
        this.processApprove('Removed');
    }
    closeModal2(){
        this.comments = null;
        this.approvalConfirm = false;
    }
    processApprove(action){
        this.isShowSpinner = true;
        var msg;
        if(action == 'Approve'){
            msg = this.label.Approve_Success;
        }else if(action == 'Reject'){
            msg = this.label.Reject_Success;
        }else if(action == 'Removed'){
            msg = this.label.Recall_Success;
        }
        var nextApproverId;
        if(this.ShopPlanData.Status__c != 'In Approval'){
            nextApproverId = this.ShopPlanData.Approver2__c;
        }else{
            nextApproverId = null;
        }
        approvalProcess({
            recordId : this.ShopPlanData.Id,
            action : action,
            nextApproverId : nextApproverId,
            comments : this.comments
        }).then(result => {
            if(result.isSucess){
                this.ShopPlanData = result.ShopPlanData;
                this.isCurrentApprover = result.isCurrentApprover;
                this.showApproveAction = result.showApproveAction;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: msg,
                    variant: 'Success',
                }));
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));
            }
            this.comments = null;
            this.isShowSpinner = false;
        })
    }
    //----------------Approval methods---------------------
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

    // onChange(event) {
    //     this.searchTerm = event.target.value;
    //     filterFloorwalker({name : this.searchTerm}).then(result =>{
    //         console.log('userResult: ' + JSON.stringify(result));
    //         this.floorwalkerRecords = result;
    //         if(this.floorwalkerRecords.length > 0) {
    //             this.showSelectList = true;
    //         } else {
    //             this.showSelectList = false;
    //         }
    //     }).catch(error =>{
    //         this.dispatchEvent(new ShowToastEvent({
    //             title: 'error',
    //             message: this.label.Error,
    //             variant: 'error',
    //         }));
    //     })
    // }


    // 双击弹出 note
    showTooltipViw(event){
        console.log('wwww----日历双击点击事件');
        clearTimeout(this.clickTimer);
        event.stopPropagation();

        const element = this.template.querySelector('.my-container');
        const rect = element.getBoundingClientRect();
        const distanceFromTop = rect.top;

        let mouseX = event.clientX; // 水平坐标
        let mouseY = event.clientY; // 垂直坐标
        // this.modalOpenStyle = 'top: ' + (mouseY - distanceFromTop)  + 'px;' + 'left: ' + mouseX + 'px; padding:0;border: 1px solid #b5b5b5';

        let nameValue = event.target.getAttribute("name")+'';
        let pickValue = nameValue.split(':');
        let onclickDay = new Date(pickValue[0].replaceAll('-','/'));
        let nowDate = new Date(this.myDate.replaceAll('-','/'));
        const day = onclickDay.getDate();
        if(day >= 28){
            mouseX = mouseX - 100;
        }
        this.modalOpenStyle = 'top: ' + (mouseY - distanceFromTop)  + 'px;' + 'left: ' + mouseX + 'px; padding:0;border: 1px solid #b5b5b5';

        this.showDisable = false;
        this.showButton = true;
        this.showTooltipFlag = false;

        if(onclickDay < nowDate){
            this.showDisable = true;
            this.showButton = false;
        }else if(this.ShopPlanData.Status__c == 'Approved' || this.ShopPlanData.Status__c == 'Submitted'){
            this.showDisable = true;
            this.showButton = false;
        }
        if (this.taskMap[pickValue[2] + ''+ pickValue[0] + 'NEW']) {
            this.task = this.taskMap[pickValue[2]+''+pickValue[0]+'NEW'];
            this.showTooltipFlag = true;
        }
    }

    hoverTimeout = null;
    handleMouseOver(event){
        const colIndex = event.target.dataset.col;
        let parentElement = event.target.parentElement
        let parentElementParentElement = event.target.parentElement.parentElement;
        // this.hoverTimeout = setTimeout(() => {
             // 交叉定位
            this.template.querySelectorAll('.highlight-row, .highlight-col').forEach(el => {
                el.classList.remove('highlight-row', 'highlight-col');
            });
            // 高亮整列
            this.template.querySelectorAll(`[data-col="${colIndex}"]`).forEach(cell => {
                cell.classList.add('highlight-col');
            });
            // 高亮表头所在行
            parentElement.classList.add('highlight-row');
            if(parentElement.tagName == 'TD'){
                parentElementParentElement.classList.add('highlight-row');
            }
        // }, 1000); // 2秒延迟
    }

    // 鼠标滚轮
    heightTemp = 0;
    handleScroll = () => {
        clearTimeout(this.scrollTimer);
        this.scrollTimer = setTimeout(() => {
            const scrollTop = document.documentElement.scrollTop;
            if (scrollTop === 0) {
                const header = this.template.querySelector('.my-thead');
                const headDive = this.template.querySelector('.headDive');
                header.style.top = '0px';
                headDive.style.top = '0px';
            }else {
                const header = this.template.querySelector('.my-thead');
                const headDive = this.template.querySelector('.headDive');
                header.style.top = (window.scrollY - this.heightTemp) + 'px';
                // header.style.top = (window.scrollY - 12) + 'px';
                // headDive.style.top = (this.heightTemp + 12) + 'px';
            }
        }, 100); // 设置 100ms 延迟
    };

    renderedCallback(){
        const element = this.template.querySelector('.my-container');
        const element1 = this.template.querySelector('.my-thead');
        if(element && element1){
            const rect = element.getBoundingClientRect();
            const distanceFromTop = rect.top;

            const rect1 = element1.getBoundingClientRect();
            const distanceFromTop1 = rect1.top;

            this.heightTemp = distanceFromTop1 - distanceFromTop + 12
        }
    }

    editView(){
        this.goToLwc('createNewInspectionPlanLwc', {
            'recordId' : this.ShopPlanData.Id,
            'yearTemp' : this.ShopPlanData.Inspection_Year__c,
            'monthTemp' : this.ShopPlanData.Inspection_Month__c,
            'ownerIdTemp' : this.selectedFloorwalkerId,
            'customerValueTemp' : this.customerOptionValue,
            'gridNameTemp' : this.gridOptionValue,
            'cityTemp' : this.cityOptionValue,
            'storeLevelTemp' : this.storeLevelOptionValue,
            'storeNameTemp' : this.storeNameOptionValue,
        });
    }

}