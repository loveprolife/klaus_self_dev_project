import { LightningElement, track, wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import setCustomerOwner from '@salesforce/apex/ExhibitionSetCustomerOwner.setCustomerOwner';
import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from "lightning/refresh";

export default class exhibitionSetCustomerOwnerLWC extends LightningElement {
	@api recordId;

	connectedCallback() {
		console.log('========exhibitionSetCustomerOwnerLWC S=====================');
		console.log('recordId-->'+this.recordId);
		setCustomerOwner({recordId : this.recordId}).then(res=>{
			if (res.isSuccess) {
				this.handlerShowToast('Success', res.msg, 'Success');
				this.refreshPage();
			} else {
				console.log('Error----->'+res.msg);
			}
		}).catch(error=>{
			console.log('lwc error-->'+error+JSON.stringify(error));
        	this.HandlerShowToast('Error', '系统异常，请联系管理员！'+error, 'error');
		})




	}
    disconnectedCallback() {
        console.log('========exhibitionSetCustomerOwnerLWC E=====================');
    }




    handlerShowToast(selfTitle, selfMsg, selfVar) {
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