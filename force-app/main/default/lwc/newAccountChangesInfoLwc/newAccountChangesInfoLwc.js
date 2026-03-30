/*
 * @Author: WFC
 * @Date: 2025-05-21 13:51:09
 * @LastEditors: WFC
 * @LastEditTime: 2025-05-26 11:35:23
 * @Description: 
 * @FilePath: \HiTest20250422\force-app\main\default\lwc\newAccountChangesInfoLwc\newAccountChangesInfoLwc.js
 */
import { LightningElement, api, track } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'

import initAccountChangesInfo from '@salesforce/apex/NewAccountPageController.initAccountChangesInfo';

export default class NewAccountChangesInfoLwc extends LightningNavigationElement {

    @api recordId;
    @api isSub = false;

    @track isShowDifferencesSpinner = false;
    @track haveHistory = true;
    @track customerDifferencesList = [];
    @track companyUpdateDifferencesList = [];
    @track companyNewDifferencesList = [];
    @track salesUpdateDifferencesList = [];
    @track salesNewDifferencesList = [];
    @track banksUpdateDifferencesList = [];
    @track banksNewDifferencesList = [];

    connectedCallback(){
        console.log('wwwww-idSub--' + this.isSub);
        console.log('wwwww-recordId--' + this.recordId);
        this.isShowDifferencesSpinner = true;
        initAccountChangesInfo({ 
            recordId : this.recordId
        })
        .then(result => {
            if(result.isSuccess){
                console.log('wwwww--customerDifferencesList-' + JSON.stringify(result.data.customerDifferencesList));
                console.log('wwwww--haveHistory-' + JSON.stringify(result.data.haveHistory));
                this.haveHistory = result.data.haveHistory;
                if(result.data.haveHistory){
                    this.customerDifferencesList = result.data.customerDifferencesList;
                    this.companyUpdateDifferencesList = result.data.companyUpdateDifferencesList;
                    this.companyNewDifferencesList = result.data.companyNewDifferencesList;
                    this.salesUpdateDifferencesList = result.data.salesUpdateDifferencesList;
                    this.salesNewDifferencesList = result.data.salesNewDifferencesList;
                    this.banksUpdateDifferencesList = result.data.banksUpdateDifferencesList;
                    this.banksNewDifferencesList = result.data.banksNewDifferencesList;
                }
                const closeModal = new CustomEvent('checkhistory', { detail: result.data.haveHistory});
                this.dispatchEvent(closeModal);
            }
            this.isShowDifferencesSpinner = false;
        })
        .catch(error => {
            this.isShowDifferencesSpinner = false;
            this.showError('Init Account Changes Info failure!' + JSON.stringify(error));
        });
    }
    
    cancel(){
        const closeModal = new CustomEvent('closemodal');
        this.dispatchEvent(closeModal);
    }
    
}