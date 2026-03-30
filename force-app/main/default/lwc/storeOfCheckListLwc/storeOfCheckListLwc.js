import { LightningElement, track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';

import getStoreCheckList from '@salesforce/apex/CheckListController.getStoreCheckList';
import Check_List_Preview from '@salesforce/label/c.Check_List_Preview';

export default class StoreOfCheckListLwc extends LightningNavigationElement {

    @api recordId;

    @track recordList = [];
    @track isEmpty = true;

    label = { Check_List_Preview };

    connectedCallback() {
        this.isShowSpinner = true;
        if (this.recordId) {
            console.log('before ——> getStoreCheckList ——> recordId:' + this.recordId);
            console.log('before ——> getStoreCheckList ——> :');
            getStoreCheckList({
                storeId: this.recordId,
            }).then(data => {
                this.isShowSpinner = false;
                console.log('getStoreCheckList ——> :');
                if (data.isSuccess && data.data.checkItemList.length > 0) {
                    this.isEmpty = false;
                    this.recordList = data.data.checkItemList;
                    for (let i = 0; i < this.recordList.length; i++) {
                        let id = this.recordList[i].Id;
                        this.recordList[i].index = i + 1;
                        this.recordList[i].href = `/lightning/r/CheckItem__c/${id}/view`;
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
        // const index = event.target.dataset.index;
        // console.log('handleClick ——> index：' + index);
        // this.goToRecord(this.recordList[index].Id);
        // console.log('handleClick');

        // event.preventDefault();
        // const recordId = event.target.dataset.recordId;
        // console.log('recordId：' + recordId);
        // this.goToRecord(recordId);

        // event.preventDefault();
        // const recordId = event.currentTarget.dataset.recordId;
        // const objectApiName = 'CheckItem__c';
        // console.log('currentTarget —> recordId：' + recordId);
        // const recordUrl = `/lightning/r/${objectApiName}/${recordId}/view`;


        // window.open(recordUrl, '_blank');
    }

}