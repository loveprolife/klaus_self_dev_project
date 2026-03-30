/*
 * @Author: WFC
 * @Date: 2025-09-18 14:36:20
 * @LastEditors: WFC
 * @LastEditTime: 2025-09-18 16:08:16
 * @Description: 
 * @FilePath: \testuat\force-app\main\default\lwc\eventReceiptDownloadPDFLWC\eventReceiptDownloadPDFLWC.js
 */
import { LightningElement, api } from 'lwc';
import downloadFile from '@salesforce/apex/EventReceiptPrintPDFController.downloadFile';
import { CurrentPageReference, NavigationMixin} from 'lightning/navigation';

export default class EventReceiptDownloadPDFLWC extends  NavigationMixin(LightningElement) {
    @api recordId;

    connectedCallback(){
        console.log('wwww------' + this.recordId);

        downloadFile({recordId: this.recordId}).then(result => {
            console.log('wwwwww-------' + JSON.stringify(result));
            if(result){
                // 跳转到文件页面
               this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result.ContentDocumentId,
                        actionName: 'view'
                    },
                });
            }
           
        });
    }
}