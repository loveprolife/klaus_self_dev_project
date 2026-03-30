import { LightningElement, track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';

import getStoreList from '@salesforce/apex/StoresUnderGridController.getStoreList';
import Store_List from '@salesforce/label/c.Store_List';

export default class StoresUnderGridLwc extends LightningNavigationElement {

    @api recordId;

    @track recordList = [];
    @track isEmpty = true;

    label = {Store_List};
    
    connectedCallback() {
        this.isShowSpinner = true;
        if (this.recordId) {
            console.log('before ——> getStoreList ——> recordId:' + this.recordId);
            console.log('before ——> getStoreList ——> :');
            getStoreList({
                recordId: this.recordId,
            }).then(data => {
                this.isShowSpinner = false;
                console.log('getStoreList ——> ！:');
                if (data.isSuccess && data.data.storeList.length > 0) {
                    this.isEmpty = false;
                    this.recordList = data.data.storeList;
                    for (let i = 0; i < this.recordList.length; i++) {
                        this.recordList[i].index = i + 1;
                    }
                }
            }).catch(error => {
                this.catchError(error);
                this.isShowSpinner = false;
            });
        } else {
            this.isShowSpinner = false;
        }
    }

    
    handleClick(event) {
        const index = event.target.dataset.index;
        console.log('handleClick ——> index：' + index);
        this.goToRecord(this.recordList[index].Id);
        console.log('handleClick');
    }

    customerHandleClick(event) {
        const index = event.target.dataset.index;
        console.log('customerHandleClick ——> index：' + index);
        this.goToRecord(this.recordList[index].Account__c);
        console.log('customerHandleClick');
    }
    
}