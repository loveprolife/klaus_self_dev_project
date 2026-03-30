/*
 * @Author: YYL
 * @LastEditors: YYL
 */
import { LightningElement ,track,api} from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import INSPECTION_REPORT_SAVE from '@salesforce/label/c.INSPECTION_REPORT_SAVE';
import INSPECTION_REPORT_BACK from '@salesforce/label/c.INSPECTION_REPORT_BACK';
import Competitors_Models from '@salesforce/label/c.Competitors_Models';
import Performing_Brands from '@salesforce/label/c.Performing_Brands';
import Competitor_Activities from '@salesforce/label/c.Competitor_Activities';
import Image_Upload from '@salesforce/label/c.Image_Upload';
import getCompetitiveIntelligenceCanada from '@salesforce/apex/newCompetitiveIntelligenceController.getCompetitiveIntelligenceCanada';
import saveCompetitiveIntelligenceCanada from '@salesforce/apex/newCompetitiveIntelligenceController.saveCompetitiveIntelligenceCanada';
import upsertProductLineStatus from '@salesforce/apex/NewInspectionDailyReportPageController.upsertProductLineStatus';

export default class NewCompetitiveIntelligenceCanadaPageLwc extends LightningNavigationElement {

    label = {
        INSPECTION_REPORT_SAVE,             // 保存
        INSPECTION_REPORT_BACK,             // BACK
        Competitors_Models,
        Performing_Brands,
        Competitor_Activities,
        Image_Upload,
    }

    @api recordId;
    @api recordItemId;
    @api storeId;
    @api status;
    @api checkLabel;
    @api submit;
    @api productLine;

    @track competitorsModelsInfo;
    @track performingBrandsInfo;
    @track modelFlag = false;
    @track brandFlag = false;
    @track photosCompetitive = false;

    @track spinnerFlag = false;
    @track showPage = false;
    @track showSave = true;
    @track disabled = false;

    @track competitionIntelligenceInfo;

    @track currencyCode = 'USD'; // 可以从属性中动态设置
    @track currency;

    height;
    get styleContent() {
        return true ? 'max-height: ' + this.height + 'px;' : '';
    }
    start() {
        // if (this.isMobile) {
            let _this = this;
            setTimeout(()=>{
                let h = _this.height = document.documentElement.clientHeight;
                setTimeout(()=>{
                    _this.height = h - document.documentElement.scrollHeight + document.documentElement.clientHeight;
                }, 10);
            }, 1000);
        // }
    }

    get currencySymbol() {
        const formatter = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: this.currencyCode
        });
        const parts = formatter.formatToParts(0);
        return parts.find(part => part.type === 'currency').value;
    }

    connectedCallback() {

        console.log('recordId' + this.recordId);
        console.log('submit' + this.submit);
        console.log('productLine' + this.productLine);

        this.spinnerFlag = true;
        
        this.getCompetitiveIntelligenceInfo();

        this.start();
    }

    getCompetitiveIntelligenceInfo(){
        getCompetitiveIntelligenceCanada({
            recordId:this.recordId
        }).then(data => {
            console.log('wwww' + JSON.stringify(data.data.competitorsModelsInfo));
            console.log('wwww' + JSON.stringify(data.data.performingBrandsInfo));

            this.competitionIntelligenceInfo = data.data.competitionIntelligenceInfo;
            // 设置货币类型
            this.currencyCode = this.competitionIntelligenceInfo.CurrencyIsoCode;
            if(this.currencyCode == 'Canada'){
                this.currencyCode = 'USD';
            }
            this.currency = this.currencySymbol;
            this.competitorsModelsInfo = data.data.competitorsModelsInfo;
            this.performingBrandsInfo = data.data.performingBrandsInfo;

            // 判断brandNameTotal是否完成所有必填项
            if(this.competitorsModelsInfo){
                let flag = true;
                this.competitorsModelsInfo.forEach((item,index) => {
                    // 处理序号问题
                    item.order = index + 1;
                    if(!item.Brand__c || !item.Model__c || !item.Price__c){
                        flag = false;
                        return 
                    }
                });

                this.modelFlag = flag;
            }else{
                this.modelFlag = false;
            }

            // 判断brandNamePrice是否完成所有必填项
            if(this.performingBrandsInfo){
                let flag = true;
                this.performingBrandsInfo.forEach((item,index) => {
                    // 处理序号问题
                    item.order = index + 1;
                    if(!item.Brand__c){
                        flag = false;
                        return 
                    }
                });

                this.brandFlag = flag;
            }else{
                this.brandFlag = false;
            }

            // 设置照片
            this.photosCompetitive = data.data.photosCompetitive;

            this.spinnerFlag = false;
            this.showPage = true;

            // 根据是否提交判断展示状态
            if(this.status == 'Submitted'){
                this.showSave = false;
                this.disabled = true;
            }
            
        })
    }

    // 更改竞品箱子数量
    handleChangeModelAndBrand(event){
        let index = event.target.dataset.index;
        let name = event.target.name;
        let value = event.target.value;
        if(name == 'model'){
            this.competitorsModelsInfo[index].Brand__c = value;
        }else if(name == 'brand'){
            this.performingBrandsInfo[index].Brand__c = value;
        }

        console.log('competitorsModelsInfo' + JSON.stringify(this.competitorsModelsInfo));
        console.log('performingBrandsInfo' + JSON.stringify(this.performingBrandsInfo));

        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    handleChangePrice(event){
        let index = event.target.dataset.index;
        let value = event.target.value;
        // 根据正则表达式判断输入数据
        let pattern = /^[0-9]*[1-9][0-9]*$/;
        let flag = pattern.test(value);

        if(flag){
            this.competitorsModelsInfo[index].Price__c = parseInt(value);
        }else if(value == ''){
            this.competitorsModelsInfo[index].Price__c = value;
        }

        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    handleChangeModel(event){
        let index = event.target.dataset.index;
        let value = event.target.value;
        this.competitorsModelsInfo[index].Model__c = value;

        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    handleChangeCompetitor(event){
        let value = event.target.value;
        this.competitionIntelligenceInfo.Competitor_Activities__c = value;

        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    hasEdit : true
                }
            })
        );
    }

    // Save click
    @api
    handleSave() {
        this.spinnerFlag = true;
        console.log('Data =' + JSON.stringify(this.competitionIntelligenceInfo));
        console.log('competitorsModelsInfo =' + JSON.stringify(this.competitorsModelsInfo));
        console.log('performingBrandsInfo =' + JSON.stringify(this.performingBrandsInfo));

        // 删除掉序号
        this.competitorsModelsInfo.forEach(item => {
            delete item.order;
        })
        this.performingBrandsInfo.forEach(item => {
            delete item.order;
        })

        saveCompetitiveIntelligenceCanada({
            competitionIntelligenceInfoJson:JSON.stringify(this.competitionIntelligenceInfo),
            competitorsModelsInfoJson:JSON.stringify(this.competitorsModelsInfo),
            performingBrandsInfoJson:JSON.stringify(this.performingBrandsInfo)
        }).then(data => {
            this.spinnerFlag = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    variant: 'success'
                })
            );

            // 更新产品线状态为continue
            upsertProductLineStatus({
                recordId:this.recordId,
                status:'Continue',
                productLineChecked:''
            }).catch(error => {
                this.catchError(JSON.stringify(error));
            });
            
            // 刷新
            this.dispatchEvent(new CustomEvent('refreshdata'));
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        hasEdit : false,
                        saveFlag : 'competitionIntelligenceCanada'
                    }
                })
            );
            // 刷新当前页面
            this.getCompetitiveIntelligenceInfo();
        })

    }

    handleBack(){
        this.dispatchEvent(new CustomEvent('goback'));

        this.dispatchEvent(new CustomEvent('refreshdata'));
    }
}