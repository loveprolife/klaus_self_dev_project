import { LightningElement, track, wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveOAAppExecutive from '@salesforce/apex/oAApprovalSubmissionController.saveOAAppExecutive';
import getSecondApprover from '@salesforce/apex/ExhibitionSSOVerifyController.getSecondApprover';
import getInternalRegistList from '@salesforce/apex/oAApprovalSubmissionController.getInternalRegistList';
const COL = [
    { label: "姓名", fieldName: 'Name_CN__c', editable: false,  },
    { label: "部门", fieldName: 'Department_Name__c', editable: false, },
    { label: "电话", fieldName: 'Phone__c', editable: false, },
    { label: "邮箱", fieldName: 'Email__c', editable: false, },
    ];
export default class oAApprovalSubmissionExecutiveLwc extends LightningElement {
	@api recordId;
    @track isShowSpinner = false;
	@track approverList = [];
    @track oneAppVal = '';
    @track twoAppVal = '';
    columns = COL;
    datas = [];

	connectedCallback(){
        this.isShowSpinner = true;
		let opMap = [{label:'',value:''},{label:'cuijie3',value:'cuijie3'}];
        // for(let key in result.salesUnitMap){
        //     opMap.push({label: result.salesUnitMap[key],value: result.salesUnitMap[key]});
        // }
        // Modified By Ethan 20230824 二级审批人动态获取
        getSecondApprover({type:'总办'}).then(res=>{
            if (res.isSuccess) {
                this.approverList = JSON.parse(res.msg);
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: res.msg,
                        variant: 'error',
                    }));
                    this.dispatchEvent(new CustomEvent('closemodal'));
                    this.dispatchEvent(new CustomEvent('refreshview')); 
            }
        })

        getInternalRegistList({id: this.recordId}).then(res=>{this.datas = res});

        // this.approverList = opMap;
        console.log('Id:'+this.recordId);
        this.isShowSpinner = false;
	}

    cancel(event) {
        this.dispatchEvent(new CustomEvent('closemodal')); 
    }

    changeData(event){
        let name = event.target.name;
        let value = event.target.value;
        console.log('name'+name);
        console.log('value'+value);
        if (name == 'oneApp') {
            this.oneAppVal = value;
        }
        if (name == 'twoApp') {
            this.twoAppVal = value;
        }
    }

    saveData(){
        this.isShowSpinner = true;
        if(this.recordId==''||this.oneAppVal==''||this.twoAppVal==''){
            this.dispatchEvent(new ShowToastEvent({
                title: 'error',
                message: '参数不能为空!',
                variant: 'error',
            }));
        }else{
            saveOAAppExecutive({
                id : this.recordId,
                oneApp : this.oneAppVal,
                twoApp : this.twoAppVal,
            }).then(result => {
                console.log('result:'+JSON.stringify(result));
                if (result.isSuccess) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: '提交审批成功！',
                        variant: 'Success',
                    }));
                    this.dispatchEvent(new CustomEvent('closemodal'));
                    this.dispatchEvent(new CustomEvent('refreshview')); 
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: '系统错误!'+result.message,
                        variant: 'error',
                    }));
                    this.isShowSpinner = false;
                }
            }).catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: '系统错误!'+JSON.stringify(error),
                    variant: 'error',
                }));
                this.isShowSpinner = false;
            });
        }
        
    }
}