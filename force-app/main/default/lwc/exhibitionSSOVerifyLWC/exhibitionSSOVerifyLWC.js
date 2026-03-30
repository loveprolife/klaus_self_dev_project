import { LightningElement, track, wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import verifyInternalRegistration from '@salesforce/apex/ExhibitionSSOVerifyController.verifyInternalRegistration';
import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from "lightning/refresh";

export default class exhibitionSSOVerifyLWC extends LightningElement {
	@api recordId;
    @track isShowSpinner = false;

	connectedCallback() {
		console.log('========exhibitionSSOVerifyLWC=====================');
	}

    handleCancel() {
         this.closePage();
         this.dispatchEvent(new CloseActionScreenEvent());  
    }
    handleOk() {
        this.isShowSpinner = true;
        verifyInternalRegistration({recordId: this.recordId}).then(res=>{
            console.log('res:'+JSON.stringify(res));
            if (res.isSuccess) {
                this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: '校验完成！',
                        variant: 'Success',
                    }));
                    // this.dispatchEvent(new CustomEvent('closemodal'));
                    // this.dispatchEvent(new CustomEvent('refreshview')); 
                    // this.dispatchEvent(new CloseActionScreenEvent());
                    // this.dispatchEvent(new RefreshEvent());
                    this.closePage();
                    this.refreshPage();
            }else {
                this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: '验证失败：'+res.msg,
                        variant: 'error',
                    }));
                this.closePage();
                this.refreshPage();
            }
             this.isShowSpinner = false;

        }).catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: '系统异常，请联系管理员！',
                    variant: 'error',
                }));
                this.isShowSpinner = false;
                this.closePage();
                this.refreshPage();
            });
                    // this.isShowSpinner = false;
        
    }

	



    closePage() {
            this.dispatchEvent(new CloseActionScreenEvent());
        }  

    refreshPage(){
        setTimeout(()=>{
            // eval("$A.get('e.force:refreshView').fire();"); 
            this.dispatchEvent(new RefreshEvent());
            this.dispatchEvent(new CloseActionScreenEvent());
            // this.closeQuickAction();

    }
    ,1000);}


}