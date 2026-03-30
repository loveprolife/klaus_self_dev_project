import { LightningElement, track, wire, api} from 'lwc';
import searchShopData from '@salesforce/apex/Gridding_Shop_MapController.searchShopData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getVisualforceOrigin from '@salesforce/apex/Gridding_Shop_MapController.getVisualforceOrigin';


export default class GriddingShopMapLWC extends LightningElement {
    @api recordId;
    @track isShowSpinner;
    @track isShowMap = true;

    @wire(getVisualforceOrigin) visualForceOrigin;

    //初始化
    connectedCallback() {
        this.isShowSpinner = true;

        //初始化搜索网格下存在的门店数据->VF
        this.searchDataHelper();
    }

    searchDataHelper() {
        searchShopData({
            recordId : this.recordId
        }).then(result => {
            if(!result.isError){

                //门店列表是否为空,是否显示地图
                console.log('********* result.markersList.length  *********' + result.markersList.length);
                if(result.markersList.length == 0){
                    this.isShowMap = false;
                    this.isShowSpinner = false;
                }else{

                    //result.markersList -> VisualForce Page
                    setTimeout(function(){
                        console.log('********* -> VisualForce Page  *********' + this.visualForceOrigin.data);
                        var markersList = result.markersList;
                        let sendVfMessage = Object();
                        sendVfMessage.key = 'markersList';
                        sendVfMessage.value = markersList;
                        this.template.querySelector('iframe').contentWindow.postMessage(
                            JSON.stringify(sendVfMessage), 
                            this.visualForceOrigin.data
                        );
                        this.isShowSpinner = false;
                    }.bind(this), 2000);
                }
                // this.isShowSpinner = false;
            }else{
                this.isShowSpinner = false;
                return;
            }   
        }).catch(error => {
            this.error = error.body.message;
            console.log("catch.Msg" + error.body.message);
        });
    }

    sendMessgaeToVisualForce() {
        var markersList = JSON.stringify(this.markersList); 
        this.template.querySelector('iframe').contentWindow.postMessage(options, this.visualForceOrigin.data);
    }
}