import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import initData from '@salesforce/apex/InspectorDailyReportController.initData';
import getNewCreateData from '@salesforce/apex/InspectorDailyReportController.getNewCreateData';
import addShopData from '@salesforce/apex/InspectorDailyReportController.addShopData';
import saveData from '@salesforce/apex/InspectorDailyReportController.saveData';
import saveEvaluation from '@salesforce/apex/InspectorDailyReportController.saveEvaluation';
import deleteEvaluation from '@salesforce/apex/InspectorDailyReportController.deleteEvaluation';
import saveResponse from '@salesforce/apex/InspectorDailyReportController.saveResponse';
import deleteResponde from '@salesforce/apex/InspectorDailyReportController.deleteResponde';
import validationData from '@salesforce/apex/InspectorDailyReportController.validationData';
import saveAttachment from '@salesforce/apex/InspectorDailyReportController.saveAttachment';
import getProductSeries from '@salesforce/apex/InspectorDailyReportController.getProductSeries';
import Return from '@salesforce/label/c.Return';
import Save from '@salesforce/label/c.Save';
import DailyInspectionReport from '@salesforce/label/c.DailyInspectionReport';
import ReportDate from '@salesforce/label/c.ReportDate';
import Floorwalker from '@salesforce/label/c.Floorwalker';
import ReportSummary from '@salesforce/label/c.ReportSummary';
import PromoterAttendance from '@salesforce/label/c.PromoterAttendance';
import SignOutRemind from '@salesforce/label/c.SignOutRemind';
import ReportDetail from '@salesforce/label/c.ReportDetail';
import AddRow from '@salesforce/label/c.AddRow';
import DeleteShop from '@salesforce/label/c.DeleteShop';
import HasVisited from '@salesforce/label/c.HasVisited';
import NotVisit from '@salesforce/label/c.NotVisit';
import Mileage from '@salesforce/label/c.Mileage';
import Start from '@salesforce/label/c.Start';
import End from '@salesforce/label/c.End';
import GasMileage from '@salesforce/label/c.GasMileage';
import AddEvaluate from '@salesforce/label/c.AddEvaluate';
import Evaluate from '@salesforce/label/c.Evaluate';
import Responde from '@salesforce/label/c.Responde';
import DeleteEvaluate from '@salesforce/label/c.DeleteEvaluate';
import Action from '@salesforce/label/c.Action';
import AddShop from '@salesforce/label/c.AddShop';
import NameOfCom from '@salesforce/label/c.NameOfCom';
import PickNameOfCom from '@salesforce/label/c.PickNameOfCom';
import ReportShopName from '@salesforce/label/c.ReportShopName';
import PickReportShopName from '@salesforce/label/c.PickReportShopName';
import Confirm from '@salesforce/label/c.Confirm';
import SaveTheChanges from '@salesforce/label/c.SaveTheChanges';
import SaveChange from '@salesforce/label/c.SaveChange';
import AbortSavingJump from '@salesforce/label/c.AbortSavingJump';
import SavingJump from '@salesforce/label/c.SavingJump';
import DeleteVisit from '@salesforce/label/c.DeleteVisit';
import ComfirmDelete from '@salesforce/label/c.ComfirmDelete';
import Cancle from '@salesforce/label/c.Cancle';
import ConfirmChangeStaus from '@salesforce/label/c.ConfirmChangeStaus';
import ConfirmChangeStausContent from '@salesforce/label/c.ConfirmChangeStausContent';
import Publish from '@salesforce/label/c.Publish';
import SupplementaryInformation from '@salesforce/label/c.SupplementaryInformation';
import SignInRetroactive from '@salesforce/label/c.SignInRetroactive';
import RegularVisit from '@salesforce/label/c.RegularVisit';
import ProductCatalogConfirm from '@salesforce/label/c.ProductCatalogConfirm';
import Pick from '@salesforce/label/c.Pick';
import StoreMaintain from '@salesforce/label/c.StoreMaintain';
import IntelligenceGathering from '@salesforce/label/c.IntelligenceGathering';
import CorporateInformation from '@salesforce/label/c.CorporateInformation';
import StoreInformation from '@salesforce/label/c.StoreInformation';
import CompetitiveInformation from '@salesforce/label/c.CompetitiveInformation';
import SamplingInspection from '@salesforce/label/c.SamplingInspection';
import AddSamplingInspection from '@salesforce/label/c.AddSamplingInspection';
import Order from '@salesforce/label/c.Order';
import PlacementStatus from '@salesforce/label/c.PlacementStatus';
import Product from '@salesforce/label/c.Product';
import ProductSeries from '@salesforce/label/c.ProductSeries';
import ReRe from '@salesforce/label/c.ReRe';
import SampleImages from '@salesforce/label/c.SampleImages';
import GraphicalCounter from '@salesforce/label/c.GraphicalCounter';
import PickStatus from '@salesforce/label/c.PickStatus';
import ViewEditImage from '@salesforce/label/c.ViewEditImage';
import Delete from '@salesforce/label/c.Delete';
import Preview from '@salesforce/label/c.Preview';
import AddImage from '@salesforce/label/c.AddImage';
import UpdateImage from '@salesforce/label/c.UpdateImage';
import Description from '@salesforce/label/c.Description';
import Picture from '@salesforce/label/c.Picture';
import Exhibit from '@salesforce/label/c.Exhibit';
import NotExhibit from '@salesforce/label/c.NotExhibit';
import PromotePunishment from '@salesforce/label/c.PromotePunishment';
import Error from '@salesforce/label/c.Error';
import PromoterAttendanceTab from '@salesforce/label/c.PromoterAttendanceTab';
import Required from '@salesforce/label/c.Required';
import NoShop from '@salesforce/label/c.NoShop';
import SaveSucessful from '@salesforce/label/c.SaveSucessful';
import HaveSignIn from '@salesforce/label/c.HaveSignIn';
import FlexibleTicket from '@salesforce/label/c.FlexibleTicket';
import MileageNotification from '@salesforce/label/c.MileageNotification';
import MileageErrorAlertStart from '@salesforce/label/c.MileageErrorAlertStart';
import MileageErrorAlertEndOne from '@salesforce/label/c.MileageErrorAlertEndOne';
import MileageErrorAlertEnd from '@salesforce/label/c.MileageErrorAlertEnd';
import Selection from '@salesforce/label/c.Selection';
import DeletingCommentSucceeded from '@salesforce/label/c.DeletingCommentSucceeded';
import CommentPostedSuccessfully from '@salesforce/label/c.CommentPostedSuccessfully';
import PublishingReplySucceeded from '@salesforce/label/c.PublishingReplySucceeded';
import SerialNumber from '@salesforce/label/c.SerialNumber';
import NoImageAdded from '@salesforce/label/c.NoImageAdded';
import ImageRequiredField from '@salesforce/label/c.ImageRequiredField';
import Reply from '@salesforce/label/c.Reply';
import Mobiletip from '@salesforce/label/c.MOBILE_PHONE_FUNCTION_NOTONLINE'
//wfc
import CheckInCheckOut_QUERY_STORE from '@salesforce/label/c.CheckInCheckOut_QUERY_STORE';
import CheckInCheckOut_QUERY from '@salesforce/label/c.CheckInCheckOut_QUERY';
import CheckInCheckOut_CHANNEL from '@salesforce/label/c.CheckInCheckOut_CHANNEL';
import CheckInCheckOut_STORE_NAME from '@salesforce/label/c.CheckInCheckOut_STORE_NAME';
import Add_Shop_For_Responsible from '@salesforce/label/c.Add_Shop_For_Responsible';
import Search_Other_Shop from '@salesforce/label/c.Search_Other_Shop';
import getStoreInfo from '@salesforce/apex/InspectorDailyReportController.getStoreInfo';
import Last_Completed_Mileage from '@salesforce/label/c.Last_Completed_Mileage';
import MileageErrorAlertLastStart from '@salesforce/label/c.MileageErrorAlertLastStart';
import MileageErrorAlertNextEnd from '@salesforce/label/c.MileageErrorAlertNextEnd';
import MileageErrorAlertNextStart from '@salesforce/label/c.MileageErrorAlertNextStart';
import Mileage_End_Required from '@salesforce/label/c.Mileage_End_Required';
import CheckInCheckOut_LEAST_CHAR from '@salesforce/label/c.CheckInCheckOut_LEAST_CHAR';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
export default class InspectorDailyReport extends NavigationMixin(LightningElement)  {
    label = {
        PromoterAttendanceTab,
        Required,
        NoShop,
        SaveSucessful,
        HaveSignIn,
        FlexibleTicket,
        MileageNotification,
        MileageErrorAlertStart,
        MileageErrorAlertEndOne,
        MileageErrorAlertEnd,
        MileageErrorAlertLastStart,
        MileageErrorAlertNextStart,
        MileageErrorAlertNextEnd,
        Selection,
        DeletingCommentSucceeded,
        CommentPostedSuccessfully,
        PublishingReplySucceeded,
        SerialNumber,
        NoImageAdded,
        ImageRequiredField,
        Error,
        NotExhibit,
        PromotePunishment,
        Exhibit,
        Picture,
        Description,
        UpdateImage,
        AddImage,
        Preview,
        PickStatus,
        Delete,
        ViewEditImage,
        ReRe,
        GraphicalCounter,
        SampleImages,
        Order,
        Product,
        ProductSeries,
        PlacementStatus,
        AddSamplingInspection,
        SamplingInspection,
        StoreInformation,
        CompetitiveInformation,
        IntelligenceGathering,
        CorporateInformation,
        Pick,
        StoreMaintain,
        RegularVisit,
        ProductCatalogConfirm,
        SupplementaryInformation,
        SignInRetroactive,
        Return,
        Save,
        DailyInspectionReport,
        ReportDate,
        Floorwalker,
        ReportSummary,
        PromoterAttendance,
        SignOutRemind,
        ReportDetail,
        AddRow,
        DeleteShop,
        HasVisited,
        NotVisit,
        Mileage,
        Start,
        End,
        GasMileage,
        AddEvaluate,
        Evaluate,
        Responde,
        DeleteEvaluate,
        Action,
        AddShop,
        NameOfCom,
        PickNameOfCom,
        ReportShopName,
        PickReportShopName,
        Confirm,
        SaveTheChanges,
        SaveChange,
        AbortSavingJump,
        SavingJump,
        DeleteVisit,
        ComfirmDelete,
        Cancle,
        Confirm,
        ConfirmChangeStaus,
        ConfirmChangeStausContent,
        Publish,
        Reply,
        Mobiletip,
        CheckInCheckOut_QUERY_STORE,//查询门店
        CheckInCheckOut_QUERY,//查询
        CheckInCheckOut_STORE_NAME,//门店
        CheckInCheckOut_CHANNEL,//经销商渠道
        Add_Shop_For_Responsible,//添加由我负责的门店
        Search_Other_Shop,//搜索其他门店
        Last_Completed_Mileage,//上一次巡店的结束里程
        Mileage_End_Required,//结束里程必填
        CheckInCheckOut_LEAST_CHAR,//输入的查询门店信息不少于两个字符
    };
    @api recordId;
    @track isExist;
    @track channelOptions;
    @track shopOptions;
    @track isModalOpen;
    @track stores;
    @track maxDate;
    @track dateTodayStart;
    @track dailyInspectionReport;
    @track owner;
    @track duplicationData;
    @track isShowSpinner;
    @track showDuplecation;
    @track showPage;
    @track status;
    @track photo;
    @track showPhotoPage;
    @track index;
    @track indexSampling;
    @track mileage;
    @track isCanEdit;
    @track isCanEditAmountTo;
    @track isCanEditSpecialUser;//wfc
    @track shopMap;
    @track shopOptionsSelect;
    @track showSearchPage;
    @track productList;
    @track shopIndex;
    @track heightTable;
    @track showCreateCompetitiveProducts;
    @track competitiveProducts;
    @track addProductName = {};
    @track mileageEnd;
    @track mileageFirst;//wfc
    @track lastMileageId;//wfc
    @track lastMileageStart;//wfc
    @track nextMileageStart;//wfc
    @track mileageAmountFlag;//wfc
    @track isChange;
    @track showCheckSave;
    @track oldSelectDate;
    @track confirmPhotoDataButton;
    @track deleteTask = [];
    // @track deleteCompetitiveProduct = [];
    @track evaluation;
    @track showShopReport;
    @track evaluationDatas;
    @track reportText;
    @track reportShowText;
    @track evaluationIndex;
    @track isShowAddEvaluation;
    @track isShowDeletePage;
    @track shopDeleteIndex;
    @track showChangeStatusPage;
    @track changeStatusIndex;
    @track showError;
    @track errorMsg;
    @track showSaveError;
    @track saveErrorMsg = [];
    @track isCanNotCreate;
    @track createMsg;
    // @track isCanEvaluate;
    @track supplementary;
    @track isCanAdd;
    @track notification;
    @track sampleImages = [];
    @track deletePhoto = [];
    @track photoIndex;
    @track showAddPhotoPage;
    @track imageError;
    @track isPc = true;
    //wfc
    @track searchInfo = ''; 
    @track datas = [];
    @track isRefresh = false;
    @track storeId;
    @track otherShopCanSave = false;
    @track columns = [
        {
            label: this.label.CheckInCheckOut_STORE_NAME,
            fieldName: 'Name',
            type: 'text',
            hideDefaultActions : true,
            wrapText: true
        },
        {
            label: this.label.CheckInCheckOut_CHANNEL,
            fieldName: 'Channel',
            type: 'text',
            hideDefaultActions : true,
            wrapText: true
        }
    ];
    

    get acceptedFormats() {
        return ['.png','.jpg','.jfif','.jpeg','.pjp','.pjpeg','.gif'];
    }
    get posttypeOptions() {
        return [
            {label:'Traditional Sales',value:'Traditional Sales'}
        ];
    }
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
    get showOptions() {
        return [
            {label:this.label.Exhibit,value:'展出'},
            {label:this.label.NotExhibit,value:'未展出'},
        ];
    }
    get showOptionsYellow() {
        return [
            {label:this.label.PromotePunishment,value:'処分推進'},
        ];
    }

    createCompetitiveProducts() {
        this.showCreateCompetitiveProducts = true;
        this.showSearchPage = false;    
    }

    // closeCompetitiveProducts() {
    //     this.showCreateCompetitiveProducts = false;
    //     this.showSearchPage = true;
    //     this.productList = [];
    //     this.competitiveproductsName = '';       
    // }
    viewImag(event) {
        this.showPhotoPage = false;
        this.showAddPhotoPage = true;
        this.photo = event.target.name;
        this.photoIndex = event.currentTarget.dataset.record;
    }
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        saveAttachment({
            contentDocumentId : uploadedFiles[0].documentId,
            contentVersionId : uploadedFiles[0].contentVersionId 
        }).then(result => {
            if (result.isSucess) {       
                this.sampleImages[this.photoIndex].sampleImages.Sample_Images__c = result.imageUrl;
                this.sampleImages[this.photoIndex].sampleImages.ImageUrl__c = result.viewImageUrl;
                this.photoIndex = ''; 
                this.photo = null;
                this.isChange = true;              
            }else{
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

    changeUploadFinished(event){
        const uploadedFiles = event.detail.files;
        saveAttachment({
            contentDocumentId : uploadedFiles[0].documentId,
            contentVersionId : uploadedFiles[0].contentVersionId 
        }).then(result => {
            if (result.isSucess) {       
                this.sampleImages[this.photoIndex].sampleImages.Sample_Images__c = result.imageUrl; 
                this.sampleImages[this.photoIndex].sampleImages.ImageUrl__c = result.viewImageUrl;
                this.showAddPhotoPage = false;
                this.showPhotoPage = true;
                this.photoIndex = '';
                this.photo = null;
                this.isChange = true;              
            }else{
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

    //页面初始化方法
    connectedCallback() {

        //判断是否是Pc端
        var userAgentInfo = window.navigator.userAgent;
        var Agents = ["Android", "iPhone", "YunOS","Windows Phone","iPad","iPod","SymbianOS","BlackBerry OS"];
        for (var v = 0; v < Agents.length; v++) {
            if (userAgentInfo.indexOf(Agents[v]) > 0) {
                this.isPc = false;
                break;
            }
        }

        //PC端初始化
        let screenHeight = window.screen.height;
        if (screenHeight >1000) {
            this.heightTable = "width: 100%;height: "+screenHeight/2+"px;overflow-y: scroll;"
        }else{
            this.heightTable = "width: 100%;height: "+screenHeight/4+"px;overflow-y: scroll;"
        }
        initData({
            reportId : this.recordId
        }).then(result => {
            if (result.isSucess) {
                if (!this.recordId) {
                    this.maxDate = result.dateToday;
                    this.dateTodayStart = result.dateTodayStart;
                    this.owner = result.owner;
                    this.stores = result.stores;
                    this.showPage = true; 
                    if (result.mileage) {
                        this.mileage = result.mileage;
                    }else{
                        this.mileage = {};
                    }
                    
                    let pickListValue = [];
                    for (var i=0;i<result.accountShopList.length;i++) {
                        pickListValue.push({label:result.accountShopList[i],value:result.accountShopList[i]});      
                    }
                    this.channelOptions = pickListValue;
                    this.shopMap = result.shopMap;
                    this.isCanEdit = result.isCanEdit = true;
                    this.isCanEditAmountTo = result.isCanEditAmountTo;
                    this.isCanEditSpecialUser = result.isCanEditSpecialUser;
                    this.mileageEnd = result.mileageEnd;
                    this.mileageFirst = result.mileageFirst;
                    this.lastMileageStart = result.lastMileageStart;
                    if(this.mileageFirst){ // 不是第一次巡店里程数据 wfc
                        this.lastMileageId = result.lastMileageId;
                    }
                    this.nextMileageStart = result.nextMileageStart;
                    this.dailyInspectionReport = result.dailyInspectionReport;
                    this.isChange = false;
                    if (result.dailyInspectionReport.Id) {
                        this.isExist = true;
                    }else{
                        this.isExist = false;    
                    }
                    this.supplementary = result.supplementary;
                    this.supplementary.SignInTime__c = result.signInTime;
                    this.supplementary.SignOutTime__c = result.signOutTime;
                    // this.supplementary.AddCheckSignInTime__c = result.addCheckSignInTime;
                    // if (this.supplementary.ApprovalStatus__c==='未提交补签申请' || this.supplementary.ApprovalStatus__c==='补签申请审批拒绝') {
                    //     this.notification = this.label.PromoterAttendanceTab;
                    // }else{
                    //     this.notification = null;
                    // }
                    this.isCanAdd = result.isCanAdd;
                    this.isShowAddEvaluation = result.isShowAddEvaluation;
                    this.oldSelectDate = this.dailyInspectionReport.Report_Date__c;
                    setTimeout(function(){
                        if (!result.isCanEdit) {
                            this.disableMethon();
                        }
                        else{
                            this.canEditMethon();
                        }
                        this.isShowSpinner = false; 
                    }.bind(this), 500);
                }else{
                    this.stores = result.stores;
                    this.owner = result.owner;
                    // this.isShowSpinner = false; 
                    this.showPage = true;  
                    this.mileage = result.mileage;
                    let pickListValue = [];
                    for (var i=0;i<result.accountShopList.length;i++) {
                        pickListValue.push({label:result.accountShopList[i],value:result.accountShopList[i]});      
                    }
                    this.channelOptions = pickListValue;
                    this.shopMap = result.shopMap;
                    this.isCanEdit = result.isCanEdit = true;
                    this.isCanEditAmountTo = result.isCanEditAmountTo;
                    this.isCanEditSpecialUser = result.isCanEditSpecialUser;
                    this.mileageEnd = result.mileageEnd;
                    this.mileageFirst = result.mileageFirst;
                    this.lastMileageStart = result.lastMileageStart;
                    if(this.mileageFirst){ // 不是第一次巡店里程数据 wfc
                        this.lastMileageId = result.lastMileageId;
                    }
                    this.nextMileageStart = result.nextMileageStart;
                    if (result.dailyInspectionReport.Id) {
                        this.isExist = true;
                    }else{
                        this.isExist = false;   
                    }
                    this.supplementary = result.supplementary;
                    this.supplementary.SignInTime__c = result.signInTime;
                    this.supplementary.SignOutTime__c = result.signOutTime;
                    // this.supplementary.AddCheckSignInTime__c = result.addCheckSignInTime;
                    // if (this.supplementary.ApprovalStatus__c==='未提交补签申请' || this.supplementary.ApprovalStatus__c==='补签申请审批拒绝') {
                    //     this.notification = this.label.PromoterAttendanceTab;
                    // }else{
                    //     this.notification = null;
                    // }
                    this.isCanAdd = result.isCanAdd;
                    this.isShowAddEvaluation = result.isShowAddEvaluation;
                    this.isChange = false;
                    this.showCheckSave = false;
                    this.dailyInspectionReport = result.dailyInspectionReport;
                    this.evaluationDatas = result.evaluationDatas;
                    setTimeout(function(){
                        if (!result.isCanEdit) {
                            this.disableMethon();
                            this.template.querySelectorAll('[data-id="dateInput"]').forEach(item=>{
                            item.disabled=true;    
                        });
                        }else{
                            this.canEditMethon();
                        }
                        this.isShowSpinner = false;
                    }.bind(this), 500);
                }
                  
            }else{
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

    dateChange(event) {
        this.oldSelectDate = this.dailyInspectionReport.Report_Date__c;
        this.dailyInspectionReport.Report_Date__c = event.target.value;
        const allValid = [
            ...this.template.querySelectorAll("[data-id='dateInput']"),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (!allValid) {
            if (this.isChange) {
                this.showCheckSave = true;
            }else{
                this.showPage = false; 
                this.isCanNotCreate = false;
                this.showSaveError = false;
                this.isCanEdit = false;
                this.isCanEdit = true;
                this.saveErrorMsg = [];
                return;   
            }
        }
        if (this.isChange) {
            this.showCheckSave = true;
        }else{
            this.showCheckSave = false;
            this.notSave(); 
        }
        this.showError = false;
    }

    evaluationChange(event) {
        this.evaluation = event.target.value;
    }

    notSave() {
        this.isShowSpinner = true;
        this.showPage = false;
        this.showError = false;
        getNewCreateData({
            dateSelect : this.dailyInspectionReport.Report_Date__c
        }).then(result => {
            if (result.isSucess) {
                if (!result.isCanNotCreate) {
                    this.stores = result.stores;
                    this.showPage = true;  
                    if (result.mileage) {
                        this.mileage = result.mileage;
                    }else{
                        this.mileage = {};    
                    }
                    this.isCanNotCreate = result.isCanNotCreate;   
                    
                    let pickListValue = [];
                    for (var i=0;i<result.accountShopList.length;i++) {
                        pickListValue.push({label:result.accountShopList[i],value:result.accountShopList[i]});      
                    }
                    this.channelOptions = pickListValue;
                    this.shopMap = result.shopMap;
                    this.isCanEdit = result.isCanEdit = true;
                    this.isCanEditAmountTo = result.isCanEditAmountTo;
                    this.mileageEnd = result.mileageEnd;
                    this.mileageFirst = result.mileageFirst;
                    this.lastMileageStart = result.lastMileageStart;
                    if(this.mileageFirst){ // 不是第一次巡店里程数据 wfc
                        this.lastMileageId = result.lastMileageId;     
                    }
                    this.nextMileageStart = result.nextMileageStart;
                    if (result.dailyInspectionReport.Id) {
                        this.isExist = true;
                        this.evaluationDatas = result.evaluationDatas;
                    }else{
                        this.isExist = false;   
                    }
                    this.supplementary = result.supplementary;
                    this.supplementary.SignInTime__c = result.signInTime;
                    this.supplementary.SignOutTime__c = result.signOutTime;
                    // this.supplementary.AddCheckSignInTime__c = result.addCheckSignInTime;
                    // if (this.supplementary.ApprovalStatus__c==='未提交补签申请' || this.supplementary.ApprovalStatus__c==='补签申请审批拒绝') {
                    //     this.notification = this.label.PromoterAttendanceTab;
                    // }else{
                    //     this.notification = null;
                    // }
                    this.isCanAdd = result.isCanAdd;
                    this.isShowAddEvaluation = result.isShowAddEvaluation;
                    this.isChange = false;
                    this.showCheckSave = false;
                    this.dailyInspectionReport = result.dailyInspectionReport;
                    this.deleteTask = [];  
                    this.deletePhoto = [];
                    // this.deleteCompetitiveProduct = [];
                    this.saveErrorMsg = [];
                    this.showSaveError = false;
                    setTimeout(function(){
                        // this.isShowSpinner = true;
                        if (!result.isCanEdit) {
                            this.disableMethon();
                        }else{
                            this.canEditMethon();
                        }
                        this.isShowSpinner = false;
                    }.bind(this), 500);    
                }else{
                    this.isCanNotCreate = result.isCanNotCreate;
                    this.createMsg = result.errorMsg;
                    this.isShowSpinner = false;
                    this.isChange = false;
                    this.showCheckSave = false;
                    this.deleteTask = [];  
                    this.deletePhoto = [];
                    this.saveErrorMsg = [];
                    this.showSaveError = false;
                    this.showCheckSave = false;
                }
            }else{
                console.log('www112321344444555');
                this.isShowSpinner = false; 
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));    
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

    saveAndJump() {
        if (this.validation()) {
            this.isShowSpinner = true; 
            this.showError = false;
            saveData({
                dailyInspectionReport : this.dailyInspectionReport,
                stores : this.stores,
                mileage : this.mileage,
                isJump : true,
                oldSelectDate : this.oldSelectDate,
                deleteTaskId : this.deleteTask,
                supplementary : this.supplementary,
                deletePhoto : this.deletePhoto,
                lastMileageId : this.lastMileageId, //wfc
                mileageFirst : this.mileageFirst //wfc
            }).then(result => {
                if (result.isSucess) {
                    if (!result.isCanNotCreate) {
                        this.mileageFirst = false;
                        this.stores = result.stores;
                        this.isShowSpinner = false; 
                        this.showPage = true;  
                        this.mileage = result.mileage;
                        let pickListValue = [];
                        for (var i=0;i<result.accountShopList.length;i++) {
                            pickListValue.push({label:result.accountShopList[i],value:result.accountShopList[i]});      
                        }
                        this.supplementary = result.supplementary;
                        this.supplementary.SignInTime__c = result.signInTime;
                        this.supplementary.SignOutTime__c = result.signOutTime;
                        // this.supplementary.AddCheckSignInTime__c = result.addCheckSignInTime;
                        // if (this.supplementary.ApprovalStatus__c==='未提交补签申请' || this.supplementary.ApprovalStatus__c==='补签申请审批拒绝') {
                        //     this.notification = this.label.PromoterAttendanceTab;
                        // }else{
                        //     this.notification = null;
                        // }
                        this.isCanAdd = result.isCanAdd;
                        this.channelOptions = pickListValue;
                        this.shopMap = result.shopMap;
                        this.isCanEdit = result.isCanEdit = true;
                        this.isCanEditAmountTo = result.isCanEditAmountTo;
                        this.mileageEnd = result.mileageEnd;
                        if (result.dailyInspectionReport.Id) {
                            this.isExist = true;
                        }else{
                            this.isExist = false;    
                        }
                        this.isCanNotCreate = result.isCanNotCreate;
                        this.isShowAddEvaluation = result.isShowAddEvaluation;
                        this.isChange = false; 
                        this.deleteTask = []; 
                        this.deletePhoto = []; 
                        this.showCheckSave = false;
                        this.dailyInspectionReport = result.dailyInspectionReport;
                        setTimeout(function(){
                            if (!result.isCanEdit) {
                                this.disableMethon();
                            }else{
                                this.canEditMethon();
                            }
                            this.isShowSpinner = false;
                        }.bind(this), 500);
                    }else{
                        this.isCanNotCreate = result.isCanNotCreate;
                        this.createMsg = result.errorMsg;
                        this.isShowSpinner = false;
                        this.isChange = false;
                        this.showCheckSave = false;
                        this.deleteTask = [];  
                        this.deletePhoto = [];
                        this.saveErrorMsg = [];
                        this.showSaveError = false;
                        this.showCheckSave = false;
                    }
                }else{
                    this.isShowSpinner = false; 
                    this.showCheckSave = false;
                    this.dailyInspectionReport.Report_Date__c = this.oldSelectDate;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: result.errorMsg,
                        variant: 'error',
                    }));
                }

            }).catch(error => {
                this.isShowSpinner = false;
                this.showCheckSave = false;
                this.dailyInspectionReport.Report_Date__c = this.oldSelectDate;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: this.label.Error,
                    variant: 'error',
                }));
            });    
        }else{
            this.showCheckSave = false;
            this.dailyInspectionReport.Report_Date__c = this.oldSelectDate;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Required,
                variant: 'error',
            }));    
        }
    }

    saveReport() {
        if (this.stores.length===0) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.NoShop,
                variant: 'error',
            }));
            return;    
        }
        let flag = this.validation();
        if (flag) {
            this.isShowSpinner = true;
            this.showError = false;
            saveData({
                dailyInspectionReport : this.dailyInspectionReport,
                stores : this.stores,
                mileage : this.mileage,
                isJump : false,
                deleteTaskId : this.deleteTask,
                // deleteCompetitiveProduct : this.deleteCompetitiveProduct,
                supplementary : this.supplementary,
                deletePhoto : this.deletePhoto,
                lastMileageId : this.lastMileageId, //wfc
                mileageFirst : this.mileageFirst //wfc
            }).then(result => {
                if (result.isSucess) {
                    this.mileageFirst = false;
                    this.showPage = true;
                    this.stores = result.stores;
                    this.isShowSpinner = false;  
                    this.mileage = result.mileage;
                    // this.supplementary = {signInTime:'2022-01-01T18:13:41Z',status:'无'};
                    this.dailyInspectionReport = result.dailyInspectionReport;
                    this.owner = result.owner;
                    this.isCanEdit = result.isCanEdit = true;
                    this.isCanEditAmountTo = result.isCanEditAmountTo;
                    // this.isCanEvaluate = result.isCanEvaluate;
                    let pickListValue = [];
                    for (var i=0;i<result.accountShopList.length;i++) {
                        pickListValue.push({label:result.accountShopList[i],value:result.accountShopList[i]});      
                    }
                    this.channelOptions = pickListValue;
                    this.shopMap = result.shopMap;
                    if (result.dailyInspectionReport.Id) {
                        this.isExist = true;
                    }else{
                        this.isExist = false;   
                    }
                    this.supplementary = result.supplementary;
                    this.supplementary.SignInTime__c = result.signInTime;
                    this.supplementary.SignOutTime__c = result.signOutTime;
                    // this.supplementary.AddCheckSignInTime__c = result.addCheckSignInTime;
                    // if (this.supplementary.ApprovalStatus__c==='未提交补签申请' || this.supplementary.ApprovalStatus__c==='补签申请审批拒绝') {
                    //     this.notification = this.label.PromoterAttendanceTab;
                    // }else{
                    //     this.notification = null;
                    // }
                    this.isCanAdd = result.isCanAdd;
                    this.isShowAddEvaluation = result.isShowAddEvaluation;
                    this.isChange = false;
                    this.isShowSpinner = false; 
                    this.deleteTask = [];  
                    this.deletePhoto = [];
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: this.label.SaveSucessful,
                        variant: 'Success',
                    }));
                }else{
                    this.isShowSpinner = false; 
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: result.errorMsg,
                        variant: 'error',
                    }));
                }
            }).catch(error => {
                this.isShowSpinner = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: this.label.Error,
                    variant: 'error',
                }));
            });    
        }else{
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Required,
                variant: 'error',
            }));    
        }
    }

    taskChange(event) {
        this.stores[event.currentTarget.dataset.record][event.currentTarget.name] = event.target.value;    
        this.isChange = true;
    }

    validation() {
        this.saveErrorMsg = [];
        
        // 验证填写加油量，则必填结束里程 wfc
        this.mileageAmountFlag = false;
        if((this.mileage.Amount_To__c != null && this.mileage.Amount_To__c != undefined && this.mileage.Amount_To__c != '')
             && (this.mileage.End__c == null || this.mileage.End__c == undefined || this.mileage.End__c == '')) {
            this.mileageAmountFlag = true; 
        }

        const allValid1 = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);

        let allValid2 = true; 
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if(!element.reportValidity()){
                allValid2 = false;    
            }
        });

        const allValid3 = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);

        const allValid4 = [...this.template.querySelectorAll('lightning-textarea')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid1 && allValid2 && allValid3 && allValid4 && !this.showError) {
            // if (!this.supplementary.Id) {
            //     if (!this.supplementary.AddCheckSignInTime__c || !this.supplementary.AddCheckInReason__c || !this.supplementary.Add_Check_Shop__c) {
            //         this.showSaveError = true;  
            //         this.saveErrorMsg.push(this.label.HaveSignIn);        
            //         return false;
            //     } 
            // }else{
            //     if (this.supplementary.CheckInStatus__c === '已签退' || this.supplementary.CheckInStatus__c==='未签到') {
            //         if (!this.supplementary.AddCheckSignInTime__c || !this.supplementary.AddCheckInReason__c || !this.supplementary.Add_Check_Shop__c) {
            //             this.showSaveError = true;  
            //             this.saveErrorMsg.push(this.label.HaveSignIn);   
            //             return false;
            //         } 
            //     }else{
            //         if (
            //             !((!this.supplementary.AddCheckSignInTime__c && !this.supplementary.AddCheckInReason__c && !this.supplementary.Add_Check_Shop__c)
            //             || (this.supplementary.AddCheckSignInTime__c&& this.supplementary.AddCheckInReason__c && this.supplementary.Add_Check_Shop__c))
            //         ) {
            //             this.showSaveError = true; 
            //             this.saveErrorMsg.push(this.label.FlexibleTicket);    
            //             return false;
            //         }    
            //     }
            // }
            if(this.mileageAmountFlag){
                this.showSaveError = true;
                this.saveErrorMsg.push(this.label.Mileage_End_Required);    
                return false;
            }else {
                this.showSaveError = false;
                return true;
            }
            
        }else{
            this.showSaveError = true;
            validationData({
                dailyInspectionReport : this.dailyInspectionReport,
                stores : this.stores,
                mileage : this.mileage,
                supplementary : this.supplementary
            }).then(result => {
                if (result.isSucess) {
                    if (!result.isShowAddEvaluation) {
                        this.saveErrorMsg = result.saveErrorMsgList;
                    }

                    if (this.showError) {
                        this.saveErrorMsg.push(this.label.MileageNotification);    
                    }
                    if(this.mileageAmountFlag){
                        this.saveErrorMsg.push(this.label.Mileage_End_Required);    
                    }
                    return false;    
                }else{
                    this.isShowSpinner = false; 
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: result.errorMsg,
                        variant: 'error',
                    }));
                    if(this.mileageAmountFlag){
                        this.saveErrorMsg.push(this.label.Mileage_End_Required);    
                    }
                    return false; 
                }
            }).catch(error => {
                this.isShowSpinner = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: this.label.Error,
                    variant: 'error',
                }));
                return false; 
            }); 
        }

    }

    disableMethon() {
        this.template.querySelectorAll('lightning-input').forEach(item=>{
            if (item.type!='date') {
                item.disabled=true;    
            }
            if(this.isCanEditAmountTo && item.name == 'inputAmountTo'){
                item.disabled=false; 
            }
        });

        this.template.querySelectorAll('lightning-textarea').forEach(item=>{
            item.disabled=true;

            if(this.isCanEditSpecialUser && item.dataset.id == 'Special_Update'){
                item.disabled=false;
            }
        });

        this.template.querySelectorAll('lightning-combobox').forEach(item=>{
            item.disabled=true;

            if(this.isCanEditSpecialUser && item.dataset.id == 'Special_Update'){
                item.disabled=false;
            }
        });

        this.template.querySelectorAll('lightning-input-field').forEach(item=>{
            item.disabled=true;
        });

    }

    canEditMethon() {
        this.template.querySelectorAll('lightning-input').forEach(item=>{
            if (item.name!="inputDate" && item.name!="supplementary") {
                item.disabled=false;
            } 
        });

        this.template.querySelectorAll('lightning-textarea').forEach(item=>{
            if (item.name!="Responde") {
                item.disabled=false;
            }
        });

        this.template.querySelectorAll('lightning-combobox').forEach(item=>{
           item.disabled=false;
        });

        this.template.querySelectorAll('lightning-input-field').forEach(item=>{
            if (item.name!="Product__c" && item.dataset.id!="CheckInStatus__c"
                && item.dataset.id!="ApprovalStatus__c"
                && item.dataset.id!="SignIn_Time__c"
                && item.dataset.id!="Shop__c"
                && item.dataset.id!="disableData"
                && item.dataset.id!="AddCheckSignInTime__c"
                && item.dataset.id!="AddCheckInReason__c"
                && item.dataset.id!="Add_Check_Shop__c"
            ) {
                item.disabled=false;    
            }
        });
    }

    closeDuplecationModal() {
        this.showDuplecation = false;
        this.dailyInspectionReport.Report_Date__c = '';
        this.dailyInspectionReport.Shop_Report__c = '';
    }

    channelChange(event){
        let channelValue = event.detail.value;
        this.shopOptions = this.shopMap[channelValue];
        this.template.querySelectorAll('lightning-combobox').forEach(item=>{
            if( item.name == 'progress'){
                item.value = '';
            }
        });
    }

    addShop(){
        this.isModalOpen = true;
    }

    closeModal(){
        this.isModalOpen = false;
        this.otherShopCanSave = false;
    }

    shopOptionsChange(event) {
        this.shopOptionsSelect = event.detail.value;
    }

    confirmData(){
        this.isShowSpinner = true;
        const allValid = [...this.template.querySelectorAll('[data-id="addShop"]')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        if (!allValid) {
            this.isShowSpinner = false;
            return;
        }
        this.isModalOpen = false; 
        this.otherShopCanSave = false;
        addShopData({
            shopId : this.shopOptionsSelect,
            shoreSize : this.stores.length,
            shopMap : this.shopMap
        }).then(result => {
            if (result.isSucess) {
                this.stores.push(result.stores[0]); 
                this.shopMap = result.shopMap; 
                this.isModalOpen = false; 
                this.isShowSpinner = false; 
                this.isChange = true;
            }else{
                this.isShowSpinner = false; 
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));
                //this.isModalOpen = false; 
                this.isShowSpinner = false;     
            }
        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Error,
                variant: 'error',
            }));
            //this.isModalOpen = false;
        });

    }

    competitiveProductsChange(event) {
        this.competitiveProducts[event.currentTarget.dataset.record] = event.target.value;
    }

    reportDataChange(event) {
        this.dailyInspectionReport[event.currentTarget.dataset.record] = event.target.value;
        this.isChange = true;
    }

    mileageChange(event) {
        this.mileage[event.currentTarget.dataset.record] = event.target.value;   
        this.isChange = true; 
    }
    mileageStartChange(event) {
        this.mileage[event.currentTarget.dataset.record] = event.target.value; 
        //let saf = this.template.querySelectorAll('[data-id="mileageStart"]');
        // let saf1 = this.template.querySelectorAll('[data-id="mileageEnd"]');
        if (parseFloat(this.mileage[event.currentTarget.dataset.record]) >= parseFloat(this.mileage.End__c)) {
            //saf[0].setCustomValidity('出发时的里程必须小于结束时的里程');
            this.errorMsg = this.label.MileageErrorAlertStart;
            this.showError = true;
            return;
        }else{
            this.showError = false;   
        }
        // 判断出发时的里程是否大于上一次的出发里程
        if (parseFloat(this.mileage[event.currentTarget.dataset.record]) < parseFloat(this.lastMileageStart)) {
            this.errorMsg = this.label.MileageErrorAlertLastStart;
            this.showError = true;
            return;
        }else{
            this.showError = false;   
        }
        // 判断出发时的里程是否小于下一次的出发里程
        if (this.nextMileageStart != '-1' && parseFloat(this.mileage[event.currentTarget.dataset.record]) > parseFloat(this.nextMileageStart)) {
            this.errorMsg = this.label.MileageErrorAlertNextStart;
            this.showError = true;
            return;
        }else{
            this.showError = false; 
        }
        this.isChange = true;
    }
    mileageEndChange(event) {
        let saf1 = this.template.querySelectorAll('[data-id="mileageStart"]');
        this.mileage[event.currentTarget.dataset.record] = event.target.value; 
        // let saf = this.template.querySelectorAll('[data-id="mileageEnd"]');
        if (parseFloat(this.mileage[event.currentTarget.dataset.record])<=parseFloat(this.mileage.Start__c)) {
            this.errorMsg = this.label.MileageErrorAlertEndOne;
            this.showError = true;
            return;
        }else if (parseFloat(this.mileage.Start__c)<parseFloat(this.mileageEnd)) {
            this.errorMsg = this.label.MileageErrorAlertEnd;
            this.showError = true;
            return;
        }else{
            this.showError = false;  
        } 
        // 判断时的里程是否小于下一次的出发里程
        if (this.nextMileageStart != '-1' && parseFloat(this.mileage[event.currentTarget.dataset.record]) > parseFloat(this.nextMileageStart)) {
            this.errorMsg = this.label.MileageErrorAlertNextEnd;
            this.showError = true;
            return;
        }else{
            this.showError = false; 
        }
        this.isChange = true;   
    }

    storeChange(event) {
        this.stores[event.currentTarget.dataset.record][event.currentTarget.name] = event.target.value;    
        this.isChange = true;
    }

    supplementaryChange(event) {
        this.supplementary[event.currentTarget.name] = event.target.value;  
        this.isChange = true;
    }

    inspectionChange(event) {
        let keyStr = event.currentTarget.name;
        let indexArr = keyStr.split('-');
        let shop = this.stores[indexArr[0]-1];
        let samplingInspectionDataList = this.stores[indexArr[0]-1].samplingInspectionDataList;
        samplingInspectionDataList[indexArr[1]-1].samplingInspection[event.currentTarget.dataset.record] = event.target.value;
        // this.testc = event.target.value;
        // samplingInspectionDataList[indexArr[1]-1].samplingInspection.Product__c = event.target.value;
        // shop.samplingInspectionDataList = samplingInspectionDataList;    
        this.isChange = true;
    }

    productChange(event) {
        if (!event.target.value) {
            let keyStr = event.currentTarget.name;
            let indexArr = keyStr.split('-');
            this.stores[indexArr[0]-1].samplingInspectionDataList[indexArr[1]-1].samplingInspection.Product__c = '';
            this.stores[indexArr[0]-1].samplingInspectionDataList[indexArr[1]-1].series = '';
            return;
        }
        let product = event.target.value;
        this.isShowSpinner = true;
        let keyStr = event.currentTarget.name;
        let indexArr = keyStr.split('-');
        let shop = this.stores[indexArr[0]-1];
        let samplingInspectionDataList = this.stores[indexArr[0]-1].samplingInspectionDataList;
        for (var i = 0; i < samplingInspectionDataList.length; i++) {
            if (samplingInspectionDataList[i].samplingInspection.Product__c===event.target.value) {
                let newData = [];
                let indexNum = 1;
                for(var j=1; j<=samplingInspectionDataList.length; j++){
                    if (j!=indexArr[1]) {
                       samplingInspectionDataList[j-1].key = indexArr[0]+'-'+indexNum;
                       samplingInspectionDataList[j-1].index = indexNum;
                       newData.push(samplingInspectionDataList[j-1]);
                       indexNum++;
                    }
                }
                shop.samplingInspectionDataList = newData;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: shop.storeLabel+this.label.Selection,
                    variant: 'error',
                }));
                this.isShowSpinner = false;
                return;  
            }
        }   
        getProductSeries({
            productId : event.target.value
        }).then(result => {
            if (result.isSucess) {
                this.stores[indexArr[0]-1].samplingInspectionDataList[indexArr[1]-1].samplingInspection.Product__c = product;
                this.stores[indexArr[0]-1].samplingInspectionDataList[indexArr[1]-1].series = result.series;
                this.isChange = true;
                this.isShowSpinner = false;  
            }else{
                this.isShowSpinner = false; 
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));
                //this.isModalOpen = false; 
                this.isShowSpinner = false;     
            }
        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Error,
                variant: 'error',
            }));
            //this.isModalOpen = false;
        });

        this.isChange = true;
    }
    notDelete() {
        this.isShowDeletePage = false;    
    }

    confirmDelete() {
        let store = this.stores[this.shopDeleteIndex];
        this.deleteTask.push(store.taskId);
        let shop = {label:store.storeLabel, value:store.shop};
        
        if (!this.shopMap[store.accountName]) {
            this.shopMap[store.accountName] = [];    
        }
        this.shopMap[store.accountName].push(shop);
        this.stores.splice(this.shopDeleteIndex, 1);
        this.recoverSamplingData();
        this.isChange = true;  
        this.isShowDeletePage = false; 
    }

    deleteShop(event) {
        var selectedItem = event.currentTarget;

        var index = selectedItem.dataset.record;
        let store = this.stores[index];
        if (store.taskId) {
            this.isShowDeletePage = true;
            this.shopDeleteIndex = index;
        }else{
            let shop = {label:store.storeLabel, value:store.shop};
            if (!this.shopMap[store.accountName]) {
                this.shopMap[store.accountName] = [];    
            }
            this.shopMap[store.accountName].push(shop);
            this.stores.splice(index, 1);
            this.recoverSamplingData();
            this.isChange = true;    
        }
    }

    recoverSamplingData() {
        for (var i = 1; i <= this.stores.length; i++) {
            for (var j = 1; j <= this.stores[i-1].samplingInspectionDataList.length; j++) {
                this.stores[i-1].samplingInspectionDataList[j-1].key = i+'-'+j;
                this.stores[i-1].storeId = i;
            }
        }
        this.isChange = true;    
    }

    statusChange(event) {
        var selectedItem = event.currentTarget;

        var index = selectedItem.dataset.record;
        console.log('index'+index);
        if (this.stores[index].taskStatus) {
            this.stores[index].taskStatus = false;    
        }else{
            if(!this.isExist){
                this.stores[index].taskStatus = true;   
            }else{
                if (this.stores[index].taskStatusString === '已完成') {
                    this.showChangeStatusPage = true;   
                    this.changeStatusIndex = index;    
                }else{
                    this.stores[index].taskStatus = true;   
                }
            }
               
        }
        this.isChange = true;
        console.log('运行完成',this.stores[index].taskStatus);
    }

    cancelChangeStatus() {
        this.showChangeStatusPage = false;    
    }

    confirmChangeStatus() {
        this.stores[this.changeStatusIndex].taskStatus = true;
        this.showChangeStatusPage = false;      
    }

    cancel(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Daily_Inspection_Report__c',
                actionName: 'list'
            }
        });
    }
    addEvaluation() {
        this.reportText = '评价';
        this.reportShowText = this.label.Evaluate;
        this.showShopReport = true;
        this.evaluation = null;    
    }

    addResponse(event) {
        this.reportText = '回复';
        this.reportShowText = this.label.Reply;
        this.showShopReport = true;
        this.evaluation = null;  
        this.evaluationIndex = event.currentTarget.dataset.record;  
    }
    closeShopReport() {
        this.reportText = null;
        this.reportShowText = null;
        this.showShopReport = false;
        this.evaluation = null;    
    }

    deleteEvaluationMethod(event) {
        let data = this.evaluationDatas[event.currentTarget.dataset.record];
        this.isShowSpinner = true;
        deleteEvaluation({
            evaluationId : data.evaluation.Id,
            reportId : this.dailyInspectionReport.Id 
        }).then(result => {
            if (result.isSucess) {
                this.evaluationDatas = result.evaluationDatas;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: this.label.DeletingCommentSucceeded,
                    variant: 'Success',
                }));
                //this.isModalOpen = false; 
                this.isShowSpinner = false; 
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));
                //this.isModalOpen = false; 
                this.isShowSpinner = false;     
            }

        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Error,
                variant: 'error',
            }));
            //this.isModalOpen = false;
        });
    }

    deleteResponde(event) {
        let index = event.currentTarget.dataset.record;
        let indexArr = index.split('-');
        this.isShowSpinner = true;
        deleteResponde({
            respondeId : this.evaluationDatas[indexArr[0]-1].responde[indexArr[1]-1].responde.Id,
            reportId : this.dailyInspectionReport.Id,
            evaluationId : this.evaluationDatas[indexArr[0]-1].evaluation.Id 
        }).then(result => {
            if (result.isSucess) {
                this.evaluationDatas = result.evaluationDatas;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: this.label.DeletingReplySucceeded,
                    variant: 'Success',
                }));
                //this.isModalOpen = false; 
                this.isShowSpinner = false; 
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));
                //this.isModalOpen = false; 
                this.isShowSpinner = false;     
            }

        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Error,
                variant: 'error',
            }));
            //this.isModalOpen = false;
        });
    }

    submitShopReport() {
        const allValid = [...this.template.querySelectorAll('[data-id="evaluation"]')]
        .reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            this.showShopReport = false;
            this.isShowSpinner = true;
            console.log('this.reportText',this.reportText==='评价');
            if (this.reportText==='评价') {
                console.log('正确1');
                saveEvaluation({
                    evaluation : this.evaluation,
                    reportId : this.dailyInspectionReport.Id 
                }).then(result => {
                    if (result.isSucess) {
                        console.log('正确');
                        this.evaluationDatas = result.evaluationDatas;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success',
                            message: this.label.CommentPostedSuccessfully,
                            variant: 'Success',
                        }));
                        //this.isModalOpen = false; 
                        this.isShowSpinner = false; 
                        
                    }else{
                        console.log('错误');
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'error',
                            message: result.errorMsg,
                            variant: 'error',
                        }));
                        //this.isModalOpen = false; 
                        this.isShowSpinner = false;     
                    }

                }).catch(error => {
                    this.isShowSpinner = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: this.label.Error,
                        variant: 'error',
                    }));
                    //this.isModalOpen = false;
                });
            }
            if (this.reportText==='回复') {
                saveResponse({
                    comment : this.evaluation,
                    reportId : this.dailyInspectionReport.Id,
                    evaluationId : this.evaluationDatas[this.evaluationIndex].evaluation.Id 
                }).then(result => {
                    if (result.isSucess) {
                        this.evaluationDatas = result.evaluationDatas;
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success',
                            message: this.label.PublishingReplySucceeded,
                            variant: 'Success',
                        }));
                        //this.isModalOpen = false; 
                        this.isShowSpinner = false; 
                    }else{
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'error',
                            message: result.errorMsg,
                            variant: 'error',
                        }));
                        //this.isModalOpen = false; 
                        this.isShowSpinner = false;     
                    }

                }).catch(error => {
                    this.isShowSpinner = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: this.label.Error,
                        variant: 'error',
                    }));
                    //this.isModalOpen = false;
                });    
            }
        }   
    }
    addHisenseData(event){
        let index = event.target.value-1;
        //const resetItem = [...this.stores];
        let shop = this.stores[index].shop;
        let size = this.stores[index].samplingInspectionDataList.length;
        let samplingInspectionDataList = this.stores[index].samplingInspectionDataList;
        let indexNum = size+1;
        let cxjlsDate = {key:event.target.value+'-'+indexNum,index:size+1,samplingStandardName:'SMD-0000000002',productName:'4K超高清超薄悬浮全面屏平板液晶电视机 75英寸',samplingInspection:{Placement_Status__c:'',Product__c:'',Tag_Price__c:'',Point__c:'',ReRe__c:'',Sample_Images_Url__c:'',Shop__c: shop},isShowDelete:true,imageNum:0};
        samplingInspectionDataList.push(cxjlsDate);
        this.stores[index].samplingInspectionDataList = samplingInspectionDataList;
        this.isChange = true;
    }

    

    deleteData(event){
        let keyStr = event.target.value;
        let indexArr = keyStr.split('-');
        let shop = this.stores[indexArr[0]-1];
        let samplingInspectionDataList = this.stores[indexArr[0]-1].samplingInspectionDataList;
        let newData = [];
        let indexNum = 1;
        for(var i=1; i<=samplingInspectionDataList.length; i++){
            if (i!=indexArr[1]) {
               samplingInspectionDataList[i-1].key = indexArr[0]+'-'+indexNum;
               samplingInspectionDataList[i-1].index = indexNum;
               newData.push(samplingInspectionDataList[i-1]);
               indexNum++;
            }
        }
        shop.samplingInspectionDataList = newData;
        this.isChange = true;
    }

    productNameChange(event) {
        this.competitiveproductsName = event.target.value;    
    }

    closeSearchPage() {
        this.showSearchPage = false;    
    }

    showPhoto(event) {
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        this.photoIndex = index;
    }

    closePhotoPage() {
        this.showPhotoPage = true;  
        this.showAddPhotoPage = false; 
        this.photo = null; 
        this.confirmPhotoDataButton = false;
    }

    viewImgMethod(event) {
        this.showPhotoPage = true;
        // this.photo = event.target.name;
        var selectedItem = event.currentTarget;

        // this.confirmPhotoDataButton = true;
        var index = selectedItem.dataset.record;
        this.indexSampling = index.split('-')[1];
        this.index = index[0];
        if (!this.stores[this.index-1].samplingInspectionDataList[this.indexSampling-1].sampleImageList) {
            this.sampleImages = [];    
        }else{
            this.sampleImages = this.stores[this.index-1].samplingInspectionDataList[this.indexSampling-1].sampleImageList;
        }
    }

    imageDataChange(event){
        this.sampleImages[event.currentTarget.dataset.record].sampleImages[event.currentTarget.name] = event.target.value;  
        this.isChange = true;
    }

    closeviewImgMethod() {
        const allValid = [...this.template.querySelectorAll('[data-id="ReRe"]')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            let flag = false;
            let errorMsg;
            for (var i =0; i < this.sampleImages.length; i++) {
                if (!this.sampleImages[i].sampleImages.Sample_Images__c) {
                    flag = true;
                    if (errorMsg) {
                        errorMsg = errorMsg +','+this.label.SerialNumber+(i+1);
                    }else{
                        errorMsg = this.label.SerialNumber+(i+1);
                    }
                }    
            }
            if (flag) {
                this.imageError = errorMsg+this.label.NoImageAdded;
            }else{
                this.showPhotoPage = false; 
                this.stores[this.index-1].samplingInspectionDataList[this.indexSampling-1].sampleImageList = this.sampleImages;
                this.stores[this.index-1].samplingInspectionDataList[this.indexSampling-1].imageNum = this.sampleImages.length;
                this.sampleImages = [];  
                this.imageError = '';  
            }
        }else{
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.ImageRequiredField,
                variant: 'error',
            }));    
        }
        
    }

    addPhoto(){
        let index = this.sampleImages.length+1
        let images = {'index':index+'',sampleImages:{'Sample_Images__c':'','ReRe__c':''}};
        this.sampleImages.push(images);
        this.isChange = true;
    }

    deletePhotoData(event) {
        var selectedItem = event.currentTarget;
        // this.confirmPhotoDataButton = true;
        var index = selectedItem.dataset.record;
        if (this.sampleImages[index].sampleImages.Id) {
            this.deletePhoto.push(this.sampleImages[index].sampleImages.Id);
        }
        this.sampleImages.splice(index, 1);
        let indexNum;
        for (var i = 0; i < this.sampleImages.length; i++) {
            indexNum = i+1;
            this.sampleImages[i].index = indexNum+'';
        }
        this.isChange = true;
    }

    photoChange(event) {
        this.photo = event.target.value;
    }

    // wfc
    handleSearchInput(event) {
        this.searchInfo = event.target.value;
    }

    handleSearch() {
        if(!this.searchInfo || this.searchInfo.length < 2) {
            this.showNotification('error', this.label.CheckInCheckOut_LEAST_CHAR, 'error');
        }else{
            this.getStoreInformation();
        }
        this.otherShopCanSave = false;
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            //title: title,
            message: message,
            variant: variant,
            mode : 'sticky'
        });
        this.dispatchEvent(evt);
    }

    getStoreInformation() {
        this.isShowSpinner = true;
        getStoreInfo({searchInfo: this.searchInfo}).then(
            result=>{
                this.isShowSpinner = false;
                console.log(result);
                if(result.isSucess) {
                    this.handleRefresh();
                    this.datas = result.otherShopList;
                }else{
                    this.showNotification("", result.failMessage ,"error");
                }
        }).catch(error => {
            this.isShowSpinner = false;
            this.showNotification("", error.message ,"error");
        });
    }

    handleRefresh() {
        if(this.isRefresh){
            this.isRefresh= false;
        }else{
            this.isRefresh = true;
        }
    }

    handleChange(event) {
        this.storeId = event.detail.selectedRows[0].Id;
        this.otherShopCanSave = true;

        console.log('this.storeId:' + this.storeId);
    }

    confirmOtherShopData(){
        this.otherShopCanSave = false;
        this.isModalOpen = false; 
        addShopData({
            shopId : this.storeId,
            shoreSize : this.stores.length,
            shopMap : this.shopMap
        }).then(result => {
            if (result.isSucess) {
                this.stores.push(result.stores[0]); 
                this.shopMap = result.shopMap; 
                this.isModalOpen = false; 
                this.isShowSpinner = false; 
                this.isChange = true;
                this.datas = [];
                this.searchInfo  = '';
            }else{
                this.isShowSpinner = false; 
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: result.errorMsg,
                    variant: 'error',
                }));
                //this.isModalOpen = false; 
                this.isShowSpinner = false;     
            }
        }).catch(error => {
            this.isShowSpinner = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: this.label.Error,
                variant: 'error',
            }));
            //this.isModalOpen = false;
        });

    }
}