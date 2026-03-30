/*
 * @Author: WFC
 * @Date: 2024-04-29 13:37:59
 * @LastEditors: WFC
 * @LastEditTime: 2024-05-10 14:26:04
 * @Description: 
 * @FilePath: \HisenseAll20240426\force-app\main\default\lwc\learningPlatformLwc\learningPlatformLwc.js
 */
import { track, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getLearningData from '@salesforce/apex/TrainingDocumentController.getLearningData';

export default class LearningPlatformLwc extends LightningNavigationElement {

    @track isShowSpinner = false;
    @track isShowStartError = false;
    @track isShowEndError = false;
    @track title = '';
    @track type = '';
    @track author = '';
    @track startDate = '';
    @track endDate = '';
    @track allowDownload = '';
    @track patch = window.screen.width;

    @track data = [];
    @track isHaveData = false;
    @track isHaveTips = false;

    @track flag = true;

    get optionsAllowDownload() {
        return [
            { label: '--None--', value: '' },
            { label: '是', value: 'true' },
            { label: '否', value: 'false' },
        ];
    }

    connectedCallback(){
        this.getLearningData();
    }

    handleName(event){
        this.title = event.target.value;
    }
    
    handleType(event){
        this.type = event.target.value;
    } 

    handleAuthor(event){
        this.author = event.target.value;
    }

    handleStartDate(event){
        this.isShowStartError = false;
        this.isShowEndError = false;
        this.startDate = event.target.value;
        // 验证开始时间必须小于结束时间
        if(this.dataNotNull(this.endDate) && this.dataNotNull(this.startDate) && this.endDate < this.startDate){
            this.isShowStartError = true;
        }
    } 

    handleEndDate(event){
        this.isShowStartError = false;
        this.isShowEndError = false;
        this.endDate = event.target.value;
        // 验证结束时间必须大于开始时间
        if(this.dataNotNull(this.startDate) && this.dataNotNull(this.endDate) && this.endDate < this.startDate){
            this.isShowEndError = true;
        }
    } 

    handleAllowDownload(event){
        this.allowDownload = event.target.value;
    }

    handleClear(){
        this.title = '';
        this.type = '';
        this.author = '';
        this.startDate = '';
        this.endDate = '';
        this.allowDownload = '';
        this.isShowEndError = false;
        this.isShowEndError = false;
    }

    handleSearch(){
        // 验证开始时间必须小于结束时间
        if(this.dataNotNull(this.startDate) && this.dataNotNull(this.endDate) && this.endDate < this.startDate){
            this.isShowEndError = true;
            this.isShowStartError = true;
            this.showError("The end time must be greater than the start time");
            return;
        }
        this.isHaveData = false;
        this.isHaveTips = false;
        this.isShowSpinner = true;
        
        this.getLearningData();
        
    }

     // 后台查询审批数据
    getLearningData(){
        this.flag = true;
        getLearningData({
            title : this.title,
            type : this.type,
            author : this.author,
            startDate : this.startDate,
            endDate : this.endDate,
            allowDownload : this.allowDownload,
        }).then(data => {
            this.isShowSpinner = false;
            if(data.flag){
                this.data = data.data;
                this.isHaveData = true;
            }else {
                this.isHaveTips = true;
            }
        }).catch(error => {
            this.isShowSpinner = false;
        });
    }

    dataNotNull(info){
        if(info !== null && info !== '' && info !== undefined){
            return true;
        }else {
            return false;
        }
    }

    learningPlatformView(event){
        let recordId = event.currentTarget.dataset.id;
        if(this.flag){
            this.flag = false;
            this.goToLwc('learningPlatformDetailLwc', {
                'recordId' : recordId,
            });
            this.flag = true;
        }
    }
    
}