import { track, api, wire} from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getSampleRemovalConfirmData from '@salesforce/apex/SampleDisplayConfirmController.getSampleRemovalConfirmData';
import Approval_Updated_Info from '@salesforce/label/c.Approval_Updated_Info';
import { generateDeviceId } from 'c/deviceUtils';

var timeIntervalInstance;
export default class SampleRemovalConfirmLwc extends LightningNavigationElement {
    @track confirmData = [];
    @track columns = [];
    @track rowOffset = 0;
    @track isShowSpinner = false;

    @track detailsInfo = '';
    @track updatedInfo = '';
    refreshApprovalDataTime = 0; // 刷新列表时间

    label = {
        Approval_Updated_Info, // 'Updated {0} minutes ago'
    }

    /**
     * 初始化 sample display confirm
     */
    @track SampleRemovalConfirmLabel = {
        Sample_Removal_Code__c: '',
        Name: '',
        Product_Model__c: '',
        Store__c: '',
        Number__c: '',
        Status__c: '',
        Deadline__c: '',
    };
    @wire(getObjectInfo, { objectApiName: 'Sample_Removal_Confirm__c' })
    wiredSampleRemovalConfirmLabel({ error, data }) {
        if (data) {
            this.SampleRemovalConfirmLabel = {
                Sample_Removal_Code__c: data.fields.Sample_Removal_Code__c.label,
                Name: data.fields.Name.label,
                Product_Model__c: data.fields.Product_Model__c.label,
                Store__c: data.fields.Store__c.label,
                Number__c: data.fields.Number__c.label,
                Status__c: data.fields.Status__c.label,
                Deadline__c: data.fields.Deadline__c.label,
            };
            this.columns = [
                { label: this.SampleRemovalConfirmLabel.Sample_Removal_Code__c, fieldName: 'Sample_Removal_Code__c', },
                { label: this.SampleRemovalConfirmLabel.Name, fieldName: 'NameToUrl', type: 'url',
                    typeAttributes:{
                        label: { fieldName: 'Name' }
                    }, },
                { label: this.SampleRemovalConfirmLabel.Product_Model__c, fieldName: 'Product_Model__c', },
                { label: this.SampleRemovalConfirmLabel.Store__c, fieldName: 'Store__c', },
                { label: this.SampleRemovalConfirmLabel.Number__c, fieldName: 'Number__c', },
                { label: this.SampleRemovalConfirmLabel.Status__c, fieldName: 'Status__c', },
                { label: this.SampleRemovalConfirmLabel.Deadline__c, fieldName: 'Deadline__c', },
            ];

        } else if (error) {
            console.log(error);
            this.showError('Sample Display Confirm getInformation error.');
        }
    }

    // 手机端
    get isMobile() {
        var userAgent = navigator.userAgent;
        if (/iphone|iPhone|ipad|iPad|ipod|iPod|iOS|ios/.test(userAgent) || /android|Android/.test(userAgent)) {  
            return true;
        } else { 
            return false;
        }
    }

    connectedCallback(){
        this.initData();
    }

    // 获取列表信息 
    initData(){
        // 生成唯一设备 ID
        this.deviceId = generateDeviceId();
        this.isShowSpinner = true;
        // 查询系统
        getSampleRemovalConfirmData({
            deviceId : this.deviceId
        }).then(data => {
            this.isShowSpinner = false;
            this.refreshApprovalDataTime = 0;
            this.confirmData = data;
            this.detailsInfo = this.confirmData.length  + ' items • '
            // 刷新updatedInfo
            this.refreshUpdatedInfo();

            var parentThis = this;
            timeIntervalInstance = setInterval(function() {
                parentThis.refreshApprovalDataTime =  parentThis.refreshApprovalDataTime + 1;
                parentThis.refreshUpdatedInfo();
            }, 60000);
        }).catch(error => {
            this.isShowSpinner = false;
            this.refreshApprovalDataTime = 0;
        });
    }

    // 点击刷新按钮 刷新数据
    handleRefreshClick(){
        this.initData();
    }

    // 刷新updatedInfo
    refreshUpdatedInfo() {
        if(this.refreshApprovalDataTime == 0){
            this.updatedInfo = 'Updated a few seconds ago';
        }else {
            this.updatedInfo = this.label.Approval_Updated_Info.format(this.refreshApprovalDataTime);
        }
    }

}