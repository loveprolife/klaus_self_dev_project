import { LightningElement, api, track } from 'lwc';
import searchSampleDisplaySAP from '@salesforce/apex/SampleDisplayDetailsController.searchSampleDisplaySAP';

export default class SampleDisplaySAPLwc extends LightningElement {
    @api recordId;

    @track isHaveData = false;
    @track sapData;

    connectedCallback(){
        // 查询数据
        searchSampleDisplaySAP({ 
            recordId : this.recordId,
        })
        .then(result => {
            if(result){
                this.isHaveData = result.isHaveData;
                this.sapData = result.sapData;
            }
        })
        .catch(error => {
        });
    }

}