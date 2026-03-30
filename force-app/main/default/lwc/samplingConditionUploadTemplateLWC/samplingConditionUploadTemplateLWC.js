import { LightningElement, track, api  } from 'lwc';
import sheetJS from '@salesforce/resourceUrl/sheetJS';
import {loadScript} from 'lightning/platformResourceLoader';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import getSamplingTargetData from '@salesforce/apex/ExportController.getSamplingTargetData';
import getSAWeeklySalesTargetTemplateData from '@salesforce/apex/ExportController.getSAWeeklySalesTargetTemplateData';

export default class SamplingConditionUploadTemplateLWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectLoad;

    connectedCallback(){
        console.log('objectLoad----' + this.objectLoad);

        loadScript(this, sheetJS).then(() => {
            console.log('加载 sheetJS 完成');
        });
    }

    
    /**
     * @Param: 
     * @Return: 
     * @Author: WFC
     * @Date: 2024-12-10 15:07:13
     * @Description: 下载excel文件
     */    
    handleFilesDownLoad(){

        if(this.objectLoad == 'Sampling Condition Template'){
            // 获取数据
            getSamplingTargetData({
                
            }).then(result => {
                const data = [];
                result.forEach(element => {
                    data.push(element);
                });
                this.generateExcel(data, 'SamplingConditionList.xlsx');
            }).catch(error => {
                console.log('wwwwwerror--' + JSON.stringify(error));
            })
        }else if(this.objectLoad == 'SA Weekly Sales Target Template'){
            // 获取数据
            getSAWeeklySalesTargetTemplateData({
                
            }).then(result => {
                const data = [];
                result.forEach(element => {
                    data.push(element);
                });
                this.generateExcel(data, 'Weekly Sales Target Template.xlsx');
            }).catch(error => {
                console.log('wwwwwerror--' + JSON.stringify(error));
            })
        }
        
        
    }

    generateExcel(data, filename){  
        // 示例数据
        // const data = [
        //     ["Name", "Age", "City"],
        //     ["John", 28, "New York"],
        //     ["Jane", 22, "Los Angeles"],
        //     ["Jack", 35, "Chicago"]
        // ];

        // 使用 SheetJS 创建工作表
        const ws = XLSX.utils.aoa_to_sheet(data);

        // 将工作表转换为工作簿
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Sheet1");

        // 导出并下载Excel文件
        XLSX.writeFile(wb, filename);

        // 导出成功
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'File download successful',
                variant: 'success',
                mode : 'sticky'
            }),
        );
    }

}