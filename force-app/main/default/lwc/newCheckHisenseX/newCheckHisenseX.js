/*
 * @Author: YYL
 * @LastEditors: YYL
 */
import { wire , track, api} from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import INSPECTION_REPORT_SAVE from '@salesforce/label/c.INSPECTION_REPORT_SAVE';
import INSPECTION_REPORT_EDIT from '@salesforce/label/c.INSPECTION_REPORT_EDIT';
import INSPECTION_REPORT_BACK from '@salesforce/label/c.INSPECTION_REPORT_BACK';
import PromoterDailyReport_TICKET from '@salesforce/label/c.PromoterDailyReport_TICKET';
import getInit from '@salesforce/apex/NewCheckHisenseXController.getInit';
import addXPlan from '@salesforce/apex/NewCheckHisenseXController.addXPlan';
import delXPlan from '@salesforce/apex/NewCheckHisenseXController.delXPlan';

export default class NewCheckHisenseX extends LightningNavigationElement {

    label = {
        INSPECTION_REPORT_SAVE,             // 保存
        INSPECTION_REPORT_EDIT,             // 修改
        INSPECTION_REPORT_BACK,
        PromoterDailyReport_TICKET
    }


    @api recordId; //获取记录id
    @api status; //获取记录id
    @track showSave = false;
    @track isCheckItem = false;
    @track showStoreInfo = false;
    @track isShowSpinner = false;

    @track xPlan = {};
    @track xPlanProduct = [];
    @track xPlanProductCompetitive = [];
    @track salesRegion;

    @track viewMode = true;
    @track itemRespIsSuccess = true;
    @track itemRespErrorMsg = '';
    @track noSalesFileUpload = true;

    get recordDatereadonly() {
        if (this.showSave) {
            return false;
        }else {
            return true;
        }
    }

    connectedCallback() {
        console.log('wwwwwRecordId' + this.recordId);
        console.log('wwwwwStatus' + this.status);
        this.getInit();
        if(this.recordId == null || this.recordId == ''){
            this.showSave = true;
            this.viewMode = false;
        }
    }

    // 初始化数据
    getInit(){
        this.isShowSpinner = true;
        getInit({
            recordId:this.recordId
        }).then(data => {
            console.log('wwwwdata' + JSON.stringify(data));
            let item = data.data;
            console.log('wwwwdata' + JSON.stringify(item.xPlan));
            this.xPlan = item.xPlan;
            this.salesRegion = item.xPlan.Sales_Region__c;
            if(item.xPlanProduct){
                this.xPlanProduct = item.xPlanProduct;
            }
            if(item.xPlanProductCompetitive){
                this.xPlanProductCompetitive = item.xPlanProductCompetitive;
            }
            this.isCheckItem = true;
            this.showStoreInfo = true;
            this.isShowSpinner = false;
        }).catch(error => {
            this.isShowSpinner = false;
        })
    }

    handleSave(){
        this.isShowSpinner = true;
        this.showSave = false;
        console.log('wwwwxPlan' + JSON.stringify(this.xPlan));
        console.log('wwwwxPlan' + JSON.stringify(this.xPlanProduct));
        console.log('wwwwxPlan' + JSON.stringify(this.xPlanProductCompetitive));

        var errorMsg = '';
        if(this.ticketCheckDate()!=''){
            // this.lwcName = PromoterDailyReport_TICKET;
            errorMsg = this.ticketCheckDate();
        }
        if (errorMsg != '') {
            this.showWarning(errorMsg);
            // this.lwcName = PromoterDailyReportLabel;
            return;
        }else{
            addXPlan({
                xPlan: JSON.stringify(this.xPlan),
                xPlanProduct : JSON.stringify(this.xPlanProduct),
                xPlanProductCompetitive : JSON.stringify(this.xPlanProductCompetitive),
            }).then(data => {
                console.log('wwwwhandleSave');
                this.isShowSpinner = false;
                this.template.querySelector('c-new-x-plan-inspection-item-page-lwc').handleSave();
                this.saveTickets();
            }).catch(error => {
                this.catchError(JSON.stringify(error));
            })
        }
    }
    

    handleEdit(){
        this.showSave = true;
        this.viewMode = false;
        this.noSalesFileUpload = false;
    }

    handleChangeSalesRegion(event){
        let value = event.target.value;
        console.log('wwwwValue' + value);
        this.salesRegion = value;
        this.xPlan.Sales_Region__c = value;
    }

    changeStoreName(event){
        let value = event.target.value;
        console.log('wwwwValue' + value);
        this.xPlan.Store_Name__c = value;
    }

    changeChannel(event){
        let value = event.target.value;
        console.log('wwwwValue' + value);
        this.xPlan.Channel_item__c = value;
    }

    changeLevel(event){
        let value = event.target.value;
        console.log('wwwwValue' + value);
        this.xPlan.level__c = value;
    }

    changeBrnad(event){
        let index = event.target.dataset.index;
        let value = event.target.value;
        console.log('wwwwValue' + value);
        this.xPlanProduct[index].Brand__c = value;
    }

    changeSerise(event){
        let index = event.target.dataset.index;
        let value = event.target.value;
        console.log('wwwwValue' + value);
        this.xPlanProduct[index].Series__c = value;
    }

    changeSize(event){
        let index = event.target.dataset.index;
        let value = event.target.value;
        console.log('wwwwValue' + value);
        this.xPlanProduct[index].Size__c = value;
    }

    changeQty(event){
        let index = event.target.dataset.index;
        let value = event.target.value;
        console.log('wwwwValue' + value);
        this.xPlanProduct[index].Quantity__c = value;
    }

    changeBrnadCompetitive(event){
        let index = event.target.dataset.index;
        let value = event.target.value;
        console.log('wwwwValue' + value);
        this.xPlanProductCompetitive[index].Brand__c = value;
    }

    changeSeriseCompetitive(event){
        let index = event.target.dataset.index;
        let value = event.target.value;
        console.log('wwwwValue' + value);
        this.xPlanProductCompetitive[index].Series_Competitive__c = value;
    }

    changeSizeCompetitive(event){
        let index = event.target.dataset.index;
        let value = event.target.value;
        console.log('wwwwValue' + value);
        this.xPlanProductCompetitive[index].Size__c = value;
    }

    changeQtyCompetitive(event){
        let index = event.target.dataset.index;
        let value = event.target.value;
        console.log('wwwwValue' + value);
        this.xPlanProductCompetitive[index].Quantity__c = value;
    }

    checkProductAdd(){
        // 初始化新增一个产品描述
        let xProduct = {
            Brand__c : 'Hisense',
            Series__c : '',
            Size__c : '',
            Quantity__c : '1',
            Type__c : 'Hisense Display'
        };
        
        this.xPlanProduct.push(xProduct);
    }

    checkProductDel(event){
        this.isShowSpinner = true;
        let index = event.target.dataset.index;
        console.log('wwwwindex' + index);
        // 删除
        this.delPlan(index);
    }

    checkProductCompetitiveAdd(){
        // 初始化新增一个产品描述
        let xProductCompetitive = {
            Brand__c : '',
            Series_Competitive__c : '',
            Size__c : '',
            Quantity__c : '1',
            Type__c : 'Competitive Display'
        };

        this.xPlanProductCompetitive.push(xProductCompetitive);
    }

    checkProductCompetitiveDel(event){
        this.isShowSpinner = true;
        let index = event.target.dataset.index;
        console.log('wwwwindex' + index);
        this.delPlanCompetitive(index);
    }

    handleBack(){
        this.goToObject('Check_X_Plan__c');
    }

    delPlan(index){
        let xPlan = this.xPlanProduct[index];
        console.log('wwwwxPlan' + JSON.stringify(xPlan));
        delXPlan({
            xPlanProduct : JSON.stringify(xPlan)
        }).then(data => {
            console.log('wwwwdata' + JSON.stringify(data));
            this.xPlanProduct.splice(index,1);
            this.isShowSpinner = false;
        }).catch(error => {
            this.catchError(JSON.stringify(error));
        })
    }

    delPlanCompetitive(index){
        let xPlan = this.xPlanProductCompetitive[index];
        delXPlan({
            xPlanProduct : JSON.stringify(xPlan)
        }).then(data => {
            console.log('wwwwdata' + JSON.stringify(data));
            this.xPlanProductCompetitive.splice(index,1);
            this.isShowSpinner = false;
        }).catch(error => {
            this.catchError(JSON.stringify(error));
        })
    }

    addTicket(event) {
        this.template.querySelector('c-new-tickets-x-lwc').addTicket();
        this.activeSections = ['ticket']; 
    }

    // Ticket
    saveTickets(event) {
        if (this.template.querySelector('c-new-tickets-x-lwc')!=null) {
            this.template.querySelector('c-new-tickets-x-lwc').saveData();
        } 
    }

    ticketSaveData(resp) {
        if (!resp.detail.result.isSuccess) {
            this.itemRespIsSuccess = resp.detail.result.isSuccess;
            this.itemRespErrorMsg += ' ' + resp.detail.result.message;
        }
        if (this.itemRespIsSuccess) {
            this.showSuccess('success');
            this.isCheckItem = true;
            this.viewMode = true;
            this.noSalesFileUpload = true;
        } else {
            // this.lwcName = PromoterDailyReport_TICKET;
            this.showError(this.itemRespErrorMsg);
        }
    }

    ticketCheckDate() {
        let ele = this.template.querySelector('c-new-tickets-x-lwc');
        if(ele == null || ele == ''){
            return '';
        }else{
            return ele.checkData();
        }
    }

    handleSetActiveSection(event) {
        const label = event.target.label;
        const accordion = this.template.querySelector('.example-accordion');
        if(label == accordion){
            accordion.activeSectionName = '';
        }
    }
}