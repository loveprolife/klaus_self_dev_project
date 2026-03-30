import { LightningElement, track, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from "lightning/refresh";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import verifyInternalRegistration from '@salesforce/apex/ExhibitionSSOVerify.verifyInternalRegistration';

export default class exhibitionSSoXhCreateRecordLWC extends LightningNavigationElement {
		@track isShowSpinner = false;
		@track xhNumber;
        @track xhNumber_length = 0;
		PARAMS_PREFIX = 'uid=';


	connectedCallback() { 
		console.log('========exhibitionSSOVerifyLWC S=====================');
	}
    disconnectedCallback() {
        console.log('========exhibitionSSOVerifyLWC E=====================');

    }

    handleCreated() {
        console.log('====handleCreated====');
        console.log('length--->'+this.xhNumber_length);

        if (this.xhNumber_length == 0) {
            // this.HandlerShowToast('Success', '未输入信鸿号！', 'Success');
            this[NavigationMixin.Navigate]({
              type: "standard__objectPage",
              attributes: {
                objectApiName: "Internal_Registration__c",
                actionName: "new",
              },
            });

            return;

        }
    	if (this.xhNumber_length < 2 && this.xhNumber_length > 0) {
    		this.showError('输入字符长度过短!');
            // this.refreshPage();
    		return;
    	}
        let senduid = 'uid='+this.xhNumber;
        console.log('senduid--->'+senduid);

    	
        console.log('next-------------');
        verifyInternalRegistration({uid : senduid}).then(res=>{
    	// verifyInternalRegistration({uid : PARAMS_PREFIX+this.xhNumber}).then(res=>{
    		console.log('SSO---->'+res);

    		if (res.code == 500) {
    			this.showError(res.message);
    			// this.refreshPage();
    			return;
    		}
            // let resDat = JSON.parse(res);
            let resData = res.data;
            console.log('resdata--->')
            let para = {
                type: "standard__objectPage",
                attributes: {
                  objectApiName: "Internal_Registration__c",
                  actionName: "new",
                },
              };
    		if (resData.length == 0) {
    			this.showWarning('未匹配到用户信息，请手动输入');
    		} else {
                this.showSuccess('已匹配到用户信息');
                para.state = {
                    defaultFieldValues: encodeDefaultFieldValues({
                        Name_CN__c: resData[0].cn,
                        Department_Name__c: resData[0].ou,
                        Department_Code__c: resData[0].departmentNumber,
                        Position__c: resData[0].title,
                        Email__c: resData[0].mail,
                        Phone__c: resData[0].mobile,
                        Is_Verify__c: true,
                        Verify_Result__c: '接口调用成功,新建成功通过,成功获取Ldap账号信息',
                        XHNumber__c: this.xhNumber
                        // Last_Verified_Date__c: Date.now()
                    }),
                }
            }

    		this[NavigationMixin.Navigate](para);




    	}).catch(error=>{
            console.log('lwc error-->'+error+JSON.stringify(error));
            this.HandlerShowToast('Error', '系统异常，请联系管理员！'+error, 'error');
        })


        console.log('end');

    }
    handleCancel() {
       this.goToObject('Internal_Registration__c');
    }


    handleXhNumber(evt){
    	let xh_str = evt.detail.value;
    	this.xhNumber = xh_str.trim();
    	this.xhNumber_length = this.xhNumber.length
    	}

    HandlerShowToast(selfTitle, selfMsg, selfVar) {
    	this.dispatchEvent(new ShowToastEvent({
			                        title: selfTitle,
			                        message: selfMsg,
			                        variant: selfVar,
			                    }));
    }

    closePage() {
        console.log('closePage============');
            this.dispatchEvent(new CloseActionScreenEvent());
        }  

    refreshPage(){
        console.log('refreshPage=========');
        setTimeout(()=>{
            eval("$A.get('e.force:refreshView').fire();"); 
            
    }
    ,1000);}

}