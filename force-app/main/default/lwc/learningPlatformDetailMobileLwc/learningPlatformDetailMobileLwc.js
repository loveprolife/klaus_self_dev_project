import { api, track, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import { createRecord, deleteRecord, getRecord, getFieldValue  } from 'lightning/uiRecordApi';

import NAME_FIELD from "@salesforce/schema/Learning_Platform_Management__c.Name";
import TYPE from "@salesforce/schema/Learning_Platform_Management__c.Type__c";
import AUTHOR from "@salesforce/schema/Learning_Platform_Management__c.Author__c";
import UPLOAD_DATE from "@salesforce/schema/Learning_Platform_Management__c.Upload_Date__c";
import ALLOW_DOWNLOAD from "@salesforce/schema/Learning_Platform_Management__c.Allow_Download__c";

export default class LearningPlatformDetailMobileLwc extends LightningNavigationElement {

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD, TYPE, AUTHOR, UPLOAD_DATE, ALLOW_DOWNLOAD], })
    trainingDocument;

    get recordName() {
        return getFieldValue(this.trainingDocument.data, NAME_FIELD);
    }

    get recordType() {
        return getFieldValue(this.trainingDocument.data, TYPE);
    }

    get recordAuthor() {
        return getFieldValue(this.trainingDocument.data, AUTHOR);
    }

    get recordUploadDate() {
        return getFieldValue(this.trainingDocument.data, UPLOAD_DATE);
    }

    get recordAllowDownload() {
        return getFieldValue(this.trainingDocument.data, ALLOW_DOWNLOAD);
    }

    connectedCallback(){
        
    }


}