import { LightningElement ,api, track} from 'lwc';
import getTrainAttendance from '@salesforce/apex/CheckOutTrainProductAttendance.getTrainAttendance';

export default class CheckOutTrainingProduct extends LightningElement {
    
    @api recordId;
    @track attendance = {};
    @track isShowImage = false;
    @track isShowVideo =false;
    customerName = '';
    isShow = false;

    connectedCallback(){
        console.log('recordId' + this.recordId);
        getTrainAttendance({
            id:this.recordId
        }).then(data => {
            this.isShow = data.isSuccess;

            if(data.data.Display_Pictures__c != null && data.data.Display_Pictures__c != ''){
                this.isShowImage = true;
            }
            
            if(data.data.Second_Show__c != null && data.data.Second_Show__c != ''){
                this.isShowVideo = true;
            }

            this.attendance = data.data;
            this.customerName = data.customerName;
            console.log('wwww getTrainAttendance' + JSON.stringify(data))
        })
    }
}