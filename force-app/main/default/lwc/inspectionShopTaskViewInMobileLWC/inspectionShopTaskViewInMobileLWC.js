import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningNavigationElement } from 'c/lwcUtils'
//apex methods
import initData from '@salesforce/apex/InspectionShopTaskViewInMobileController.initData';
import newData from '@salesforce/apex/InspectionShopTaskViewInMobileController.newData';
import getData from '@salesforce/apex/InspectionShopTaskViewInMobileController.getData';
import setGridOptions from '@salesforce/apex/InspectionShopTaskViewInMobileController.setGridOptions';
import getShopOptions from '@salesforce/apex/InspectionShopTaskViewInMobileController.getShopOptions';
import getCurrentMonthDays from '@salesforce/apex/InspectionShopTaskViewInMobileController.getCurrentMonthDays';
import judgeCountry from '@salesforce/apex/NewPromoterDailyReportActionController.judgeCountry';//Lay add 区分国家
//custom label
import TaskTitile from '@salesforce/label/c.TaskTitile';
import Return from '@salesforce/label/c.Return';
import Confirm from '@salesforce/label/c.Confirm';
import PickPlanYear from '@salesforce/label/c.PickPlanYear';
import PlanYear from '@salesforce/label/c.PlanYear';
import PlanMonth from '@salesforce/label/c.PlanMonth';
import PickPlanMonth from '@salesforce/label/c.PickPlanMonth';
import PlanDay from '@salesforce/label/c.PlanDay';
import PickPlanDay from '@salesforce/label/c.PickPlanDay';
import TodayTask from '@salesforce/label/c.TodayTask';
import All from '@salesforce/label/c.All';
import Daily_Report_Navigation_Label from '@salesforce/label/c.Daily_Report_Navigation_Label';
import PromoterDailyReport_NEW from '@salesforce/label/c.PromoterDailyReport_NEW';
import Search_Store from '@salesforce/label/c.Search_Store';
import Country from '@salesforce/label/c.Country';
import Region from '@salesforce/label/c.Region';
import Province from '@salesforce/label/c.Province';
import City from '@salesforce/label/c.City';
import District from '@salesforce/label/c.District';
import IIII_Sales_Region from '@salesforce/label/c.IIII_Sales_Region';

export default class InspectionShopTaskViewInMobileLWC extends LightningNavigationElement {
    @track isShowSpinner;

    @api isHomePage;
    //flag
    @track isModalOpen = false;
    @track isDateOpen = false;
    @track isShopOpen = false;
    @track isStatusOpen = false;
    @track isOwnerOpen = false;
    @track isToday = true;
    // @track notHomePage = true;

    @track allDate = true;
    @track allDay = true;
    get isManager(){
        return this.relatedUserIdList.length>1?true:false;
    }
    //data
    @track temp;
    @track temp2;

    @track taskList = [];
    @track relatedUserIdList = [];

    @track selectedDay = null;
    @track selectedYear = null;
    @track selectedMonth = null;
    @track selectedShopId = null;
    @track selectedStatus = null;
    @track selectedOwner = null;

    @track selectedNewTaskShopId = null;
    @track selectedNewTaskShopLabel = null;
    //new task
    @track task = {};
    @track shopId;
    @track inspectionDate;
    @track status;
    @track inspectionTarget;
    @track inspectionPlanCommnets;
    @track ownerId;
    //label
    @track inspectionDateLabel;
    @track shopLabel;
    @track noteLabel;
    @track channelLabel;
    @track statusLabel;
    @track ownerLabel;

    @track isShowProductLine = false;
    label = {
        TaskTitile,
        Return,
        Confirm,
        PlanYear,
        PlanMonth,
        PlanDay,
        PickPlanYear,
        PickPlanMonth,
        PickPlanDay,
        TodayTask,
        Daily_Report_Navigation_Label,
        PromoterDailyReport_NEW,
        Search_Store,
        Country,
        Province,
        Region,
        City,
        District,
        IIII_Sales_Region,

        All
    }
    //options
    @track channelOptions = [];
    @track shopOptions = [];
    @track shopOptions2 = [];//remove 'all'
    @track statusOptions = [];
    @track ownerOptions = [];
    @track dayOptions = [];
    @track statusMapping = [];

    @track isSearchStore = false;
    @track searchStoreType = '';
    @track searchStoreId = '';
    @track gridsMap = [];
    @track countryGridOption = null;
    @track regionGridOption = null;
    @track provinceGridOption = null;
    @track cityGridOption = null;
    @track districtGridOption = null;

    @track selectedChannelId = this.label.All;
    @track countryId = this.label.All;
    @track regionId = this.label.All;
    @track provinceId = this.label.All;
    @track cityId = this.label.All;
    @track districtId = this.label.All;

    get monthOptions() {
        return [
            { label: this.label.All, value: this.label.All },
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
            { label: this.label.All, value: this.label.All },
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

    shopLookupFilter = {
        'lookup' : 'CustomLookupProvider.ShopFilter'
    }
    
    connectedCallback(){
        this.isShowSpinner = true;

        judgeCountry().then(data => {
            if (data.isSuccess) {
                this.isShowProductLine = !(data.data.Thailand || data.data.Indonesia || data.data.Malaysia || data.data.Philippines || data.data.Vietnam || data.data.Japan);
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            this.isShowSpinner = false;
            this.catchError(error);
        })
        
        console.log('isHomePage------------'+this.isHomePage);
        // if(this.isNotHomePage == undefined){
        //     this.notHomePage = true;
        //     console.log('notHomePage undefined------------'+this.notHomePage);
        // }else{
        //     this.notHomePage = Boolean(this.isNotHomePage);
        //     console.log('notHomePage------------'+this.notHomePage);
        // }
        initData().then(result =>{
            if(result.isSuccess){
                this.selectedYear = result.year;
                this.selectedMonth = result.month;
                this.selectedDay = this.label.All;
                this.selectedShopId = this.label.All;
                this.selectedStatus = this.label.All;

                this.dayOptions = JSON.parse(JSON.stringify(result.dayList));
                this.channelOptions = JSON.parse(JSON.stringify(result.channelList));
                this.shopOptions = JSON.parse(JSON.stringify(result.shopList));
                this.shopOptions2 = JSON.parse(JSON.stringify(result.shopList));
                this.shopOptions2.splice(0,1);
                //this.shopOptionsSearch = this.shopOptions2;
                
                this.ownerOptions = JSON.parse(JSON.stringify(result.ownerList));
                this.statusOptions = JSON.parse(JSON.stringify(result.statusList));
                this.statusOptions.forEach(option=>{
                    this.statusMapping[option['value']] = option['label'];
                })
                this.ownerId = result.ownerId;
                this.taskList = result.istList;
                console.log('wwwwwtaskList = ' + JSON.stringify(this.taskList));
                //field label
                this.inspectionDateLabel = result.inspectionDateLabel;
                this.channelLabel = result.channelLabel;
                this.shopLabel = result.shopLabel;
                this.noteLabel = result.noteLabel;
                this.statusLabel = result.statusLabel;
                this.ownerLabel = result.ownerLabel;
                this.relatedUserIdList = result.relatedUserIdList;
                this.taskListformat();
                
                this.task['OwnerId'] = result.ownerId;
            }
            this.isShowSpinner = false;
        })
    }
    showRecordDetailpage(event){
        
        if(event.currentTarget.parentElement.dataset.id != '' && event.currentTarget.parentElement.dataset.id != null && event.currentTarget.parentElement.dataset.id != undefined && event.currentTarget.parentElement.dataset.id.length != 1){
            // window.location.href = '/lightning/r/Inspection_Shop_Task__c/'+ event.currentTarget.parentElement.dataset.id +'/view';
            this.goToRecord(event.currentTarget.parentElement.dataset.id);
        }
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         "recordId": event.currentTarget.dataset.id,
        //         "objectApiName": "Inspection_Shop_Task__c",
        //         "actionName": "view"
        //     },
        // });
    }
    newRecord(event){
        this.isModalOpen = true;
        this.handleUpdateLookup('onShop', null);
    }
    
    closeSelectShop(){
        //this.isModalOpen = false;
        this.isSearchStore = false;
        if(this.searchStoreType == 'new'){
            this.isModalOpen = true;
        }
        this.searchStoreSetNull();
        this.handleUpdateLookup('onShop', null);
        
    }
    
    searchStoreSetNull(){
        this.selectedChannelId = '';
        this.countryId = '';
        this.regionId = '';
        this.provinceId = '';
        this.cityId = '';
        this.districtId = '';
    }
    shopSearchChange(event){
        this.searchStoreId = event.target.value;
    }
    confirmSelectShop(){
        this.isShowSpinner = true;

        if(this.searchStoreId && this.searchStoreId != ''){
            this.temp = this.searchStoreId;
            this.temp2 = this.shopOptions.find(option => option.value === this.searchStoreId).label;
            //this.confirmShop();
    
            if(this.temp != null){
                if(this.temp == this.label.All){
                    this.selectedNewTaskShopId = null;
                    this.selectedNewTaskShopLabel = null;
                    this.task['Shop__c'] = '';
                }else{
                    this.selectedNewTaskShopId = this.temp;
                    this.selectedNewTaskShopLabel = this.temp2;
                    this.task['Shop__c'] = this.selectedNewTaskShopId;
                }
            }
        }

        this.isSearchStore = false;
        this.searchStoreSetNull();

        if(this.searchStoreType == 'new'){
            this.isModalOpen = true;
            this.handleUpdateLookup('onShop', null);
        }else{
            this.selectedShopId = this.temp;
            this.confirmfilter();
        }
        
        this.isShowSpinner = false;
    }

    confirmData(){
        this.isShowSpinner = true;
        this.task['Status__c'] = '未到访';
        // this.task['OwnerId'] = this.selectedOwner;
        newData({
            newData : this.task,
            isToday : this.isToday
        }).then(result =>{
            if(result.isSuccess){
                this.taskList = result.istList;
                this.taskListformat();
                this.selectedDay = this.label.All;
                this.selectedShopId = this.label.All;
                this.showSuccess('Save Success');
            }else{
                this.showError(result.errorMsg);
            }
            this.selectedNewTaskShopId = null;
            this.selectedNewTaskShopLabel = null;
        })
        this.isModalOpen = false;
        this.isShowSpinner = false;
    }
    handleFiledChange(event){
        this.task[event.currentTarget.fieldName] = event.target.value;
    }
    //go to daily report
    goToDailyReport(event){
        var salesRegion = event.target.dataset.name;
        // 根据当前记录的用户salesRegion跳转新页面还是旧页面
        console.log('wwwwwsalesRegion' + salesRegion);
        var lwcName;
        let salesRegionList = this.label.IIII_Sales_Region.split(',');
        if(salesRegionList.includes(salesRegion)){
            lwcName = 'newInspectorReportHomePageLwc';
        }else {
            lwcName = 'newInspectorDailyReportLwc';
        }
        // if(salesRegion == 'Hisense USA' || salesRegion == 'Hisense Canada' || salesRegion == 'Hisense Peru' || salesRegion == 'Hisense Mexico' || salesRegion == 'Hisense Argentina'){
        //     lwcName = 'newInspectorReportHomePageLwc';
        // }else{
        //     lwcName = 'newInspectorDailyReportLwc';
        // }

        this.goToComponent('c__LWCWrapper',{
            'lwcName' : lwcName,
            'recordId' : '',
            'storeId' : event.currentTarget.parentElement.parentElement.dataset.shopId
        });
    }
    //filter today task
    todayTask(){
        if(this.isToday){
            this.isToday = false;
            this.setGridOption();
        }else{
            this.isToday = true;
        }
        this.confirmfilter();
    }
    //filter date
    chooseDate(){
        this.isDateOpen = true;
    }
    getDayOptions(){
        getCurrentMonthDays({
            year : JSON.stringify(this.selectedYear),
            month : JSON.stringify(this.selectedMonth)
        }).then(result =>{
            if(result){
                this.dayOptions = result;
                this.selectedDay = this.label.All;
            }
        })
    }
    yearChange(event){
        if(this.selectedYear == this.label.All && event.target.value != this.label.All){
            this.allDate = true;
        }
        // this.selectedYear = event.target.value;
        this.selectedYear = event.target.value;
        this.selectedDay = this.label.All;
        if(event.target.value == this.label.All){
            this.allDate = false;
        }
        this.getDayOptions();
        this.confirmfilter();
    }
    monthChange(event){
        if(this.selectedMonth == this.label.All  && event.target.value != this.label.All){
            this.allDay = true;
        }
        this.selectedMonth = event.target.value;
        this.selectedDay = this.label.All;
        if(event.target.value == this.label.All){
            this.allDay = false;
        }
        this.getDayOptions();
        this.confirmfilter();
    }
    dayChange(event){
        this.selectedDay = event.target.value;
        this.confirmfilter();
    }
    // confirmDate(){
    //     this.confirmfilter();
    // }
    //filter shop
    chooseShop(){
        this.isShopOpen = true;
    }
    channelChange(event){
        this.selectedChannelId = event.target.value;
        if('searchChannel' == event.target.name){
            this.selectedShopId = this.label.All;
            this.confirmfilter();
        }

        this.setShopOptions();
    }
    optionChange(event){
        let type = event.target.dataset.type;
        
        switch(event.target.name){
            case 'countryId':
                this.countryId = event.target.value;
                this.regionId = this.label.All;
                this.provinceId = this.label.All;
                this.cityId = this.label.All;
                this.districtId = this.label.All;
                break;
            case 'regionId':
                this.regionId = event.target.value;
                this.provinceId = this.label.All;
                this.cityId = this.label.All;
                this.districtId = this.label.All;
                break;
            case 'provinceId':
                this.provinceId = event.target.value;
                this.cityId = this.label.All;
                this.districtId = this.label.All;
                break;
            case 'cityId':
                this.cityId = event.target.value;
                this.districtId = this.label.All;
                break;
            case 'districtId':
                this.districtId = event.target.value;
            break;
        }

        if(type == 'search'){
            this.confirmfilter();
        }
        this.setGridOption();
        this.setShopOptions();
    }

    setShopOptions(){
        getShopOptions({
            channelId : this.selectedChannelId,
            countryId : this.countryId,
            regionId : this.regionId,
            provinceId : this.provinceId,
            cityId : this.cityId,
            districtId : this.districtId
        }).then( result =>{
            if(result && result.length > 0){
                this.shopOptions = result;
                if(this.shopOptions && this.shopOptions.length == 1){
                    this.shopOptions[0].label = '--None--';
                }
            }
        })
    }

    setGridOption(){
        setGridOptions({
            countryId : this.countryId,
            regionId : this.regionId,
            provinceId : this.provinceId,
            cityId : this.cityId,
            districtId : this.districtId
        }).then( result =>{
            this.gridsMap = JSON.parse(JSON.stringify(result));

            if(this.gridsMap.Country && this.gridsMap.Country.length > 0){
                this.countryGridOption = this.gridsMap.Country;

                if(this.countryGridOption.length == 2){
                    //this.countryGridOption.splice(0, 1);
                    this.countryId = this.gridsMap.Country[1].value;
                }
            }
            if(this.gridsMap.Region && this.gridsMap.Region.length > 0){
                this.regionGridOption = this.gridsMap.Region;
            }
            if(this.gridsMap.Province && this.gridsMap.Province.length > 0){
                this.provinceGridOption = this.gridsMap.Province;
            }
            if(this.gridsMap.City && this.gridsMap.City.length > 0){
                this.cityGridOption = this.gridsMap.City;
            }
            if(this.gridsMap.District && this.gridsMap.District.length > 0){
                this.districtGridOption = this.gridsMap.District;
            }
        })
    }

    shopChange(event){
        this.temp = event.target.value;
        this.temp2 = this.shopOptions.find(option => option.value === event.target.value).label;
        this.confirmShop();
    }

    handleUpdateLookup(type, index) {
        let lookup;
        setTimeout(() => {
            lookup = this.template.querySelector('c-store-lookup-lwc');

            if(lookup != null && lookup.name == type){
                lookup.updateOption({
                    'lookup' : 'CustomLookupProvider.ShopFilter',
                    'shopOptions' : JSON.stringify(this.shopOptions2)
                });
            }
        }, 0);
    }

    newTaskShopChange(event) {
        if (event.detail.selectedRecord==undefined || event.detail.selectedRecord.Id == '') {
            return;
        }
        this.selectedNewTaskShopId = event.detail.selectedRecord.Id;
        this.selectedNewTaskShopLabel = event.detail.selectedRecord.Name;
        this.task['Shop__c'] = event.detail.selectedRecord.Id;
    }

    newTaskDateChange(event){
        this.task['Inspection_Date__c'] = event.target.value;
    }
    confirmShop(){
        if(this.temp != null){
            this.selectedShopId = this.temp;
            if(this.temp == this.label.All){
                this.selectedNewTaskShopId = null;
                this.selectedNewTaskShopLabel = null;
                this.task['Shop__c'] = '';
            }else{
                this.selectedNewTaskShopId = this.temp;
                this.selectedNewTaskShopLabel = this.temp2;
                this.task['Shop__c'] = this.selectedNewTaskShopId;
            }
        }
        this.confirmfilter();
    }
    //filter status
    chooseStatus(){
        this.isStatusOpen = true;
    }
    confirmStatus(){
        if(this.temp != null){
           this.selectedStatus = this.temp; 
        }
        this.confirmfilter();
    }
    //filter owner
    chooseOwner(){
        this.isOwnerOpen = true;
    }

    handleSearchClick(event){
        console.log('event.target.name' + JSON.stringify(this.gridsMap));
        this.searchStoreSetNull();
        this.setGridOption();
        this.setShopOptions();
        if(event.target.name == 'search'){
            this.searchStoreType = 'search';
        }else{
            this.searchStoreType = 'new';
            this.isModalOpen = false;
        }

        this.isSearchStore = true;
        
    }
    confirmOwner(){
        if(this.temp != null){
            this.selectedOwner = this.temp;
        }
        this.confirmfilter();
    }
    //submit filter
    dataChange(event){
        this.selectedStatus = event.target.value;
        this.confirmfilter();
    }
    confirmfilter(){
        this.isShowSpinner = true;
        var selectedOwner ;
        if(this.selectedOwner){
            selectedOwner = this.selectedOwner;
        }else{
            selectedOwner = JSON.stringify(this.relatedUserIdList);
        }
        // console.log('selectedOwner-------'+this.selectedOwner);
        // console.log('selectedYear-------'+this.selectedYear);
        // console.log('selectedMonth-------'+this.selectedMonth);
        // console.log('selectedShopId-------'+this.selectedShopId);
        // console.log('selectedStatus-------'+this.selectedStatus);
        
        getData({
            ownerIdListJson : selectedOwner,
            year : this.selectedYear,
            month : this.selectedMonth,
            day : this.selectedDay,
            channelId : this.selectedChannelId,
            shopId : this.selectedShopId,
            status : this.selectedStatus,
            isToday : this.isToday,
            countryId : this.countryId,
            regionId : this.regionId,
            provinceId : this.provinceId,
            cityId : this.cityId,
            districtId : this.districtId
        }).then( result =>{
            // console.log('result-------'+JSON.stringify(result));
            if(result != null && result != undefined){
                this.taskList = result;
                this.taskListformat();
            }
            this.temp = null;
            this.temp2 = null;

            this.isDateOpen = false;
            this.isShopOpen = false;
            this.isStatusOpen = false;
            this.isOwnerOpen = false;
            
            this.isShowSpinner = false;
        })
    }
    closeModal(){
        this.temp = null;
        this.temp2 = null;

        this.isModalOpen = false;
        this.isDateOpen = false;
        this.isShopOpen = false;
        this.isStatusOpen = false;
        this.isOwnerOpen = false;
    }
    taskListformat(){
        this.taskList.forEach(task =>{
            task.Status__c = this.statusMapping[task.Status__c];
            if(task.Inspection_Plan__c == null){
                this.taskList.splice(this.taskList.indexOf(task),1);
            }
        })

        if(this.taskList.length<5){
            var limit = 0;
            limit = 5 - this.taskList.length;
            for(var i = 0; i < limit; i++){
                let o = {};
                o['Id'] = i;
                o['Name'] = '';
                o['Inspection_Date__c'] = '';
                o['Shop__r'] = {};
                o['Shop__r']['Name'] = ' ';
                o['Status__c'] = ' ';
                o['Inspection_Plan__r'] = {};
                o['Inspection_Plan__r']['Owner'] = {};
                o['Inspection_Plan__r']['Owner']['Name'] = ' ';
                o['flag'] = true;
                this.taskList.push(o);
            }
        }
    }
}