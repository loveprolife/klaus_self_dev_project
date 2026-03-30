/*
 * @Author: YYL
 * @LastEditors: YYL
 */
import { LightningElement } from 'lwc';
import { generateDeviceId } from 'c/deviceUtils';
import { LightningNavigationElement } from 'c/lwcUtils'
import { NavigationMixin } from 'lightning/navigation';
import getDailyReportDateInfo from '@salesforce/apex/SearchDataTableListController.getDailyReportDateInfo';

const columns = [{
        label: 'Report No.',
        fieldName: 'nameUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'name' }, target: '_blank' }
    },
    {
        label: 'Store',
        fieldName: 'ShopUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Shop__c' }, target: '_blank' }
    },
    { label: '*Date', fieldName: 'Report_Date__c', type: 'date' },
    // { label: 'Daily Report Status', fieldName: 'Status__c' },
    // { label: 'Owner', fieldName: 'Owner_text__c' },
];

export default class DailyReportListView extends LightningNavigationElement {
    data = [];
    columns = columns;
    rowOffset = 0;

    connectedCallback() {
        const deviceID = generateDeviceId();
        console.log({ deviceID: deviceID });
        getDailyReportDateInfo({ deviceId: deviceID })
            .then(data => {
                if (data.data) {
                    this.data = data.data.pdrList.map(item => ({
                        name: item.Name,
                        nameUrl: '/' + item.Id,
                        Shop__c: item.Shop__r ? item.Shop__r.Name : '',
                        ShopUrl: '/' + item.Shop__c,
                        Report_Date__c: item.Report_Date__c,
                        Status__c: item.Status__c,
                        Owner_text__c: item.Owner_text__c,
                    }));
                }
            })
            .catch(error => {
                console.error('Error fetching data: ', error);
            });
    }

    handleNewRecordClick() {
        //if (confirm('Are you sure you want to create a new report?')) {
        this.createRecord('Promoter_Daily_Report__c','','','','');
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__objectPage',
        //     attributes: {
        //         objectApiName: 'Promoter_Daily_Report__c',
        //         actionName: 'new'
        //     }
        // });
        // }
    }
}