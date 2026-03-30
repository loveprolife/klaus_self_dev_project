import { LightningElement, api, wire } from 'lwc';
import getReportUrl from '@salesforce/apex/EndCustomerBigScreenCtrl.getReportUrl';
export default class EndCustomerBigScreen extends LightningElement {
    @api reportId;

    reportUrl;


    //查找权限
    connectedCallback() {
        console.log('reportId:' + this.reportId);
        this.showSpinner = true;
        getReportUrl({
            reporId: this.reportId,
        })
            .then(result => {
                console.log('dshchjasdbvhjvbdhsj:' + result);
                this.reportUrl = result;
                this.showSpinner = false;
            })
            .catch(error => {
                console.log(error);
                this.showSpinner = false; // 停止加载动画
            });
    }


}