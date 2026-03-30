import { LightningElement, api, track } from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'

import getSIImageCheckResultAll from '@salesforce/apex/NewSamplingAndTicketController.getSIImageCheckResultAll';
import createTicket from '@salesforce/apex/NewSamplingAndTicketController.createTicket';
import Ai_Title from '@salesforce/label/c.Ai_Title';
import Check_Logo from '@salesforce/label/c.Check_Logo';
import Check_Samples from '@salesforce/label/c.Check_Samples';
import Check_TV_Screen from '@salesforce/label/c.Check_TV_Screen';
import Inspection_Continue from '@salesforce/label/c.Inspection_Continue';
import Create_Ticket from '@salesforce/label/c.Create_Ticket';

export default class CheckFileModalLwc extends LightningNavigationElement  {
    @api recordId;
    @api recordItemId;
    @api storeId;

    @track resultData = [];
    @track fileErrorList = [];
    @track isPass = true;
    @track productLine = '';
    @track productLineError = '';

    label = {
        Ai_Title,   
        Check_Samples,   
        Check_Logo,   
        Check_TV_Screen,   
        Inspection_Continue,   
        Create_Ticket,   
    }

    connectedCallback(){
        getSIImageCheckResultAll({
            recordId: this.recordItemId,
        }).then(data => {
            if (data.isSuccess) {
               console.log('wwww---'  + JSON.stringify(data.data.checkResult));
               this.resultData = data.data.checkResult;
               this.fileErrorList = data.data.fileErrorList;
               this.isPass = data.data.isPass;
               this.productLine = data.data.productLine;
               this.productLineError = data.data.productLineError;
            }
        })
    }

    // 关闭模态框的方法
    handleClose() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }

    // 继续保存
    handleContinue() {
        const closeEvent = new CustomEvent('continue');
        this.dispatchEvent(closeEvent);
    }

    handleCreateTicket(){
        // 创建工单
        createTicket({
            recordId: this.recordId,
            storeId: this.storeId,
            productLine: this.productLine,
            productLineError: this.productLineError,
            fileErrorList: this.fileErrorList,
        }).then(data => {
            if(data){
                this.showSuccess('Create Ticket Successfully!');
                const closeEvent = new CustomEvent('createticket');
                this.dispatchEvent(closeEvent);
            }else {
                this.showError('Create Ticket Failure!');
            }
        }).catch(error => {
            this.showError('Create Ticket Failure!');
        })
    }
}