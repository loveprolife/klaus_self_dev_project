import { LightningElement, track, wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import verifyInternalRegistrations from '@salesforce/apex/ExhibitionSSOVerifyController.verifyInternalRegistrations';
import IsExistVerify from '@salesforce/apex/ExhibitionSSOVerifyController.IsExistVerify';

import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from "lightning/refresh";


export default class exhibitionAllSSOVerifyLWC extends LightningElement {
    @api recordId;
    @track isShowSpinner = false;
    @track isFinish = false;
    _timer;


    connectedCallback() {
        console.log('========exhibitionSSOVerifyLWC S=====================');
    }
    disconnectedCallback() {
        console.log('========exhibitionSSOVerifyLWC E=====================');

    }

    handleCancel() {
         // this.dispatchEvent(new CustomEvent('closemodal'));
        this.closePage();   
    }
    handleOk() {
        this.isShowSpinner = true;
        verifyInternalRegistrations({recordId: this.recordId}).then(res=>{
            console.log('res:'+JSON.stringify(res));
            if (res.isSuccess) {
                this.HandlerShowToast('Success', 'LDAP校验开始！', 'Success');
                    // this.dispatchEvent(new CloseActionScreenEvent());
                    // this.dispatchEvent(new CustomEvent('refreshview')); 
                    this.dispatchEvent(new RefreshEvent());
                    this.refreshPage();
                    this.isExistVerify();
                    


            }else {
                this.HandlerShowToast('Error', '验证失败：'+res.msg, 'error');
                this.refreshPage();
                this.closePage();
            }
             // this.isShowSpinner = false;
             this.refreshPage();
             // this.closePage();

        }).catch(error => {
            console.log('lwc error-->'+error+JSON.stringify(error));
            this.HandlerShowToast('Error', '系统异常，请联系管理员！'+error, 'error');
            this.isShowSpinner = false;
            this.closePage();
            });
                    // this.isShowSpinner = false;

    }

    //查询是否跑批完成
    isFinishBatch(){
        IsExistVerify({recordId : this.recordId}).then(r=>{
                    console.log('-----------isFinishBatch Start！-----------');

                    if (r.isSuccess) {
                        if (r.code == 0) {
                            this.isShowSpinner = false;
                            this.HandlerShowToast('Success', 'LDAP校验完成！', 'Success');
                            this.refreshPage();
                            this.closePage();
                            console.log('-----------isFinishBatch Finish');
                            this.isFinish = true;
                            clearInterval(this._timer);
                            return ;

                        }
                    }else{
                        this.isShowSpinner = false;
                        this.HandlerShowToast('Error', '验证失败：'+res.msg, 'error');
                        this.refreshPage();
                        this.closePage();
                        return;
                    }
                   })
    }

    //异步查询
    async isExistVerify() {
        console.log('-----------isExistVerify!-----------');
        this._timer = setInterval(()=>{
        this.isFinishBatch();
                    },3000)
        // let _timer = setInterval(this.isFinishBatch(),3000);

        // if (this.isFinish) {
        //     clearInterval(_timer);
        //     return};
    }

    HandlerShowToast(selfTitle, selfMsg, selfVar) {
        this.dispatchEvent(new ShowToastEvent({
                                    title: selfTitle,
                                    message: selfMsg,
                                    variant: selfVar,
                                }));
    }

    async handleAsyncShowToast(selfTitle, selfMsg, selfVar) {
        this.dispatchEvent(new ShowToastEvent({
                                    title: selfTitle,
                                    message: selfMsg,
                                    variant: selfVar,
                                }));
    }

    closePage() {
            this.dispatchEvent(new CloseActionScreenEvent());
        }  

    refreshPage(){
        setTimeout(()=>{
            eval("$A.get('e.force:refreshView').fire();"); 
            
    }
    ,1000);}

    
}