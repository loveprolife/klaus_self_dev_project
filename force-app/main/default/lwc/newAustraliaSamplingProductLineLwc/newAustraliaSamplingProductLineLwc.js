/*
 * @Author: YYL
 * @LastEditors: TJP
 */
import { track, api, wire } from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import INSPECTION_REPORT_SAVE from '@salesforce/label/c.INSPECTION_REPORT_SAVE';
import INSPECTION_REPORT_BACK from '@salesforce/label/c.INSPECTION_REPORT_BACK';
import getSIImageCheckResult from '@salesforce/apex/NewSamplingAndTicketController.getSIImageCheckResult';

export default class NewAustraliaSamplingProductLineLwc extends LightningNavigationElement {

    label = {
        INSPECTION_REPORT_SAVE,
        INSPECTION_REPORT_BACK
    }


    // Data相关
    @api recordId; //子类id
    @api inspectionId; //父类id
    @api productLine;
    @api storeId;
    @api shopId;
    @api reportDate;
    @api recordItemId;
    @api checkName;
    @api status;
    @api submit;
    @api produceLinePhotoId;

    @track isShowSpinner = false;
    @track isEditPage = false;

    // 存放拆分后的产品线信息
    @track productLines = [];
    @track activeSections = [];
    connectedCallback(){
        console.log('WWWWrecordId'  + this.recordId);
        console.log('WWWWinspectionId'  + this.inspectionId);
        console.log('WWWWproductLine'  + this.productLine);
        console.log('WWWWstoreId'  + this.storeId);
        console.log('WWWWreportDate'  + this.reportDate);
        console.log('WWWWrecordItemId'  + this.recordItemId);
        console.log('WWWWstatus'  + this.status);
        console.log('WWWWsubmit'  + this.submit);
        console.log('WWWWproduceLinePhotoId'  + this.produceLinePhotoId);

        // 拆分黑白电的产品线进行展示
        this.productLines = this.productLine.split(';');
        this.activeSections = this.productLines.map((item) => item.toString());
        console.log('TJP' + JSON.stringify(this.activeSections));
        console.log('wwww' + JSON.stringify(this.productLines));
    }

    handleBack(){
        this.dispatchEvent(new CustomEvent('refreshdata'));
        this.dispatchEvent(new CustomEvent('goback'));
    }

    
    handleSectionToggle(event) {
        console.log('监听自动' + event.detail.openSections);
        const sectionName = event.detail.openSections;
        const index = this.activeSections.indexOf(sectionName);
        
        if (index !== -1) {
        this.activeSections.splice(index, 1);
        } else {
            this.activeSections.push(sectionName);
        }
    }

    alertTitle;
    alertMessage;
    iconType;
    showAlert = false;

    // 处理模态框关闭事件
    handleAlertClose() {
        this.showAlert = false;
        let eles = this.template.querySelectorAll('c-new-sampling-inspection-lwc2');
        if(eles){
            for (let index = 0; eles && index < eles.length; index++) {
                let ele = eles[index];
                ele.handleSave();
            }   
        }
    }

    @api
    async handleSave(){
        let messageHtml = '';
        // await getSIImageCheckResult({
        //     recordId: this.recordId
        // }).then(data => {
        //     if (data && data != '') {
        //         messageHtml += data;
        //     } 
        // })
        
        if(messageHtml != ''){
            this.showAlert = true;
            this.alertTitle = '';
            this.alertMessage = messageHtml;
            this.iconType = 'info';
        }else{
            this.handleAlertClose();
        }

        
    }

    handleHasEdit(event){
        let hasEdit = event.detail.hasEdit;
        let saveFlag = event.detail.hasEdit;
        console.log('hasEdit1' + this.hasEdit);
        // 返回父级元素页面
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : hasEdit,
                    saveFlag : saveFlag
                }
            })
        );
    }

    handleRefreshData(){
        this.dispatchEvent(new CustomEvent('refreshdata'));
    }

    disconnectedCallback() {
        console.log('wwwww------end');
        if(this.status != 'Submitted'){
            this.handleSave();
        }
    }
}