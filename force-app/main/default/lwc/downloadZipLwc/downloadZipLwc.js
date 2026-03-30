/*
 * @Author: WFC
 * @Date: 2024-09-20 10:02:51
 * @LastEditors: TJP
 * @LastEditTime: 2025-09-09 14:45:36
 * @Description: 
 * @FilePath: \hisense005\force-app\main\default\lwc\downloadZipLwc\downloadZipLwc.js
 */
import { LightningElement, track, wire } from "lwc";
import { LightningNavigationElement } from 'c/lwcUtils';
// import downloadZip from '@salesforce/apex/DownloadZipController.downloadZip';
import searchSample from '@salesforce/apex/DownloadZipController.searchSample';
import searchDownloadPhoto from '@salesforce/apex/DownloadZipController.searchDownloadPhoto';
// import checkBatchProgress from '@salesforce/apex/DownloadZipController.checkBatchProgress';
// import getDownloadFileList from '@salesforce/apex/DownloadZipController.getDownloadFileList';
import getResultByStore from '@salesforce/apex/DownloadZipController.getResultByStore';
// import changePhotoName from '@salesforce/apex/DownloadZipController.changePhotoName';
// import getInitData from '@salesforce/apex/DownloadZipController.getInitData';
import getDataResult from '@salesforce/apex/DownloadZipController.getDataResult';
import shopVerification from '@salesforce/apex/DownloadZipController.shopVerification';
import getParamResult from '@salesforce/apex/DownloadZipController.getParamResult';
import PhotoDownloadZip from '@salesforce/label/c.PhotoDownloadZip';	
import Channel from '@salesforce/label/c.Channel';
import Store from '@salesforce/label/c.Store';
import Star_Date from '@salesforce/label/c.Star_Date';
import End_Date from '@salesforce/label/c.End_Date';
import Floorwalker from '@salesforce/label/c.Floorwalker';
import Date_Interval from '@salesforce/label/c.Date_Interval'; //日期区间提示（tips:可选区间最大31天）
import Data_Missing from '@salesforce/label/c.Data_Missing'; //数据缺失
import Date_Max from '@salesforce/label/c.Date_Max'; //最大日期可选
import NO_DATA from '@salesforce/label/c.NO_DATA';
import DOWN_SEARCH from '@salesforce/label/c.DOWN_SEARCH';
import STORE_HELP_TEXT from '@salesforce/label/c.STORE_HELP_TEXT';
import CHANNEL_HELP_TEXT from '@salesforce/label/c.CHANNEL_HELP_TEXT';
import OWNER_HELP_TEXT from '@salesforce/label/c.OWNER_HELP_TEXT';
import PHOTO_OWNER from '@salesforce/label/c.PHOTO_OWNER';
import Photo_Refresh from '@salesforce/label/c.Photo_Refresh';
import Photo_Updating from '@salesforce/label/c.Photo_Updating';
import Photo_Updated from '@salesforce/label/c.Photo_Updated';
import getUpdateStatus from '@salesforce/apex/DownloadZipController.getUpdateStatus';
import processCheckResults from '@salesforce/apex/DownloadZipController.processCheckResults';
import { refreshApex } from '@salesforce/apex';



var timeIntervalInstance;

export default class DownloadZipLwc extends LightningNavigationElement {

    @track isShowSpinner = false;
    @track shopId;
    @track dateStart;
    @track dateEnd;
    @track startEndDate = '';
    @track channel;
    @track walker;
    @track isCanSearch = true;
    @track isLoading = false;// 生成文件标记
    @track isLoadingProgess = '0';// 文件生成进度
    @track isCanDownload = false;// 文件生成后才能下载
    @track batchId;
    @track isLoadingCompleted = false;// 文件是否生成完成
    @track key;// 文件秘钥

    @track result;
    @track recordAllowDownload = true;
    @track recordSaveLog = false;
    @track walkerId; // 用于存储选中的 Floorwalker 的 Id
    @track channelId;
    @track walkerOptions = []; // 用于存储下拉列表的选项
    @track ownerDataOptions = [];
    @track channelOptions = [];
    @track urlList;
    @track channelEdit = false;
    @track maxDate;
    @track minDate;
    @track forceRender = false; 
    @track totalRecords = 0;

     label = {
        DOWN_SEARCH,
        PhotoDownloadZip,
        Channel,
        Store,
        Star_Date,
        End_Date,
        Floorwalker,
        Date_Interval,
        Data_Missing, 
        Date_Max,
        NO_DATA,
        STORE_HELP_TEXT,
        CHANNEL_HELP_TEXT,
        OWNER_HELP_TEXT,
        PHOTO_OWNER,
        Photo_Refresh, 
        Photo_Updating,
        Photo_Updated 
    }

    // 筛选门店（自定义lookupFilter）
    // lookupStoreFilter = {
    // 'lookup' : 'CustomLookupProvider.HavePhotoStoreFilter'

    // }


    @track lookupStoreFilter;
    connectedCallback() {
        // this.handleCreate();
        this.getDateParam();
        this.getParamResult();
        this.lookupStoreFilter = {
            'lookup': 'CustomLookupProvider.HavePhotoStoreFilter',
            'startDate' : this.dateStart,
            'endDate' : this.dateEnd,
            'channelId' : this.channelId,
            'ownerId' : this.walkerId
        }

        this.initResultUpdate();
    }

    @track isUpdate = true;
    initResultUpdate() {
        getUpdateStatus({ batchClass: 'PhotoDownloadProcessBatch'})
            .then(result => {
                if (result) {
                    // this.isDisabled = result.Disabled__c;
                    if (result.Update_Status__c == 'Updating') {
                        this.isUpdate = false;
                    }
                } else {
                    this.isUpdate = true;
                }
            }).catch(error => {

            });
    }

    handleShopChange(event) {
        if(this.isLoadingCompleted){
            this.isCanSearch = true;
        }
        this.isCanDownload = false;
        //event.target.value;
        if (event.detail.selectedRecord==undefined) {
            this.shopId = null;
            this.walkerOptions = this.ownerDataOptions;
        } else {
            this.shopId = event.detail.selectedRecord.Id;
        }
        this.channelEdit = this.shopId == null ? false : true;
        this.getResultByStore();
    }

    // 隐藏日期下方提示
    loaded = false
    renderedCallback() {
        if(!this.loaded) {
            let style = document.createElement('style');
            style.innerText = 'div[class=slds-form-element__help]{display:none;}';
            this.template.querySelector('.date-format-hide').appendChild(style);
            this.loaded = true;
        }
    }

    getDateParam() {
        const today = new Date();
        const yesterday = new Date(today);
        yesterday.setDate(today.getDate() - 1);
        const thirtyOneDaysBeforeYesterday = new Date(yesterday);
        thirtyOneDaysBeforeYesterday.setDate(yesterday.getDate() - 31);
        const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1); // 获取当月的第一天
        const formatter = new Intl.DateTimeFormat('en-CA', {
          year: 'numeric',
          month: '2-digit',
          day: '2-digit',
        });
        const formattedYesterday = formatter.format(yesterday);
        const formattedThirtyOneDaysBeforeYesterday = formatter.format(thirtyOneDaysBeforeYesterday);
        const formattedfirstDayOfMonth = formatter.format(firstDayOfMonth);
        this.dateStart = formattedThirtyOneDaysBeforeYesterday;
        this.dateEnd = formattedYesterday;
        this.minDate = formattedThirtyOneDaysBeforeYesterday;
        this.maxDate = formattedYesterday;
        console.log('min' + this.minDate);
        console.log('max' + this.maxDate);
    }

    getMinDate() {
        const yesterday = new Date(this.dateEnd);
        const thirtyOneDaysBeforeYesterday = new Date(yesterday);
        thirtyOneDaysBeforeYesterday.setDate(yesterday.getDate() - 31);
        const formatter = new Intl.DateTimeFormat('en-CA', {
          year: 'numeric',
          month: '2-digit',
          day: '2-digit',
        });
        const formattedThirtyOneDaysBeforeYesterday = formatter.format(thirtyOneDaysBeforeYesterday);
        this.minDate = formattedThirtyOneDaysBeforeYesterday;
    }


    getResultByStore() {
        getResultByStore({
            id: this.shopId,
            dateStart: this.dateStart,
            dateEnd: this.dateEnd,})
        .then(data => {
            console.log('getResultByStore' + JSON.stringify(data));
            // if(data.channel) {
            //     this.channelOptions = data.channel
            // } else {
            //     this.channelOptions = this.option;
            // }
            if(data.owner) {
                this.walkerOptions = data.owner || [];
            }
            this.channelId = data.channelId;
            
            console.log('walkerOptions' + this.walkerOptions);
        })
        .catch(error => {
        });
    }

    handleChannelChange(event) {
        this.isCanDownload = false;
        // 获取选中的 Floorwalker 的 Id
        this.channelId = event.detail.value;
        console.log('Selected ChannelId Id:', this.channelId);
        // this.shopVerification();
        var lookup = this.template.querySelector('c-lookup-lwc');
        if(lookup != null){
            lookup.updateOption({
                'lookup': 'CustomLookupProvider.HavePhotoStoreFilter',
                'startDate' : this.dateStart,
                'endDate' : this.dateEnd,
                'channelId' : this.channelId,
                'ownerId' : this.walkerId
            });
        }
    }

    handleWalkerChange(event) {
        this.isCanDownload = false;
        // 获取选中的 Floorwalker 的 Id
        this.walkerId = event.detail.value;
        console.log('Selected Floorwalker Id:', this.walkerId);
        var lookup = this.template.querySelector('c-lookup-lwc');
        if(lookup != null){
            lookup.updateOption({
                'lookup': 'CustomLookupProvider.HavePhotoStoreFilter',
                'startDate' : this.dateStart,
                'endDate' : this.dateEnd,
                'channelId' : this.channelId,
                'ownerId' : this.walkerId
            });
        }
    }


    handleDateStartChange(event){
        this.isCanDownload = false;
        if(this.isLoadingCompleted){
            this.isCanSearch = true;
        }
        this.dateStart = event.target.value;
        this.channelId = null;
        this.walkerId = null;
        var lookup = this.template.querySelector('c-lookup-lwc');
        lookup.handleRemove();
        this.shopId = null;
        if(lookup != null){
            lookup.updateOption({
                'lookup': 'CustomLookupProvider.HavePhotoStoreFilter',
                'startDate' : this.dateStart,
                'endDate' : this.dateEnd,
                'channelId' : this.channelId,
                'ownerId' : this.walkerId
            });
        }
        this.getParamResult();
    }

    handleDateEndChange(event){
        console.log(JSON.stringify(event));
        this.isCanDownload = false;
        if(this.isLoadingCompleted){
            this.isCanSearch = true;
        }
        this.channelId = null;
        this.walkerId = null;
        const endDate = event.target.value;
        const maxResult = this.maxDate;
        const tips = Date_Max +" "+ maxResult;
        console.log('endDate' + endDate);
        console.log('maxDate' + this.maxDate);
        if(endDate > this.maxDate) {
            const inputElement = this.template.querySelector('lightning-input[data-id="dateEnd"]');
            if (inputElement) {
                inputElement.value = this.maxDate;
            }
            this.showError(tips);
        }else {
          this.dateEnd = endDate;  
        }
        var lookup = this.template.querySelector('c-lookup-lwc');
        lookup.handleRemove();
        this.shopId = null;
        if(lookup != null){
            lookup.updateOption({
                'lookup': 'CustomLookupProvider.HavePhotoStoreFilter',
                'startDate' : this.dateStart,
                'endDate' : this.dateEnd,
                'channelId' : this.channelId,
                'ownerId' : this.walkerId
            });
        }
        this.getParamResult();
    }

    // shopVerification() {
    //     shopVerification({shopId: this.shopId,channelId: this.channelId}).then(data => {
    //         if(data){
    //             this.shopId = data.shopId;
    //         }
    //         this.isShowSpinner = false;
    //     })
    //     .catch(error => {
    //         this.isShowSpinner = false;
    //     });
    // }

    handleProcessCheckResults() {
        if(this.judgeFieldValueEmpty(this.dateStart) || this.judgeFieldValueEmpty(this.dateEnd) ){
            this.showError(Data_Missing);
            return false;
        }
        this.getMinDate();

        if(this.dateStart < this.minDate){
            this.showError(Date_Interval);
            return false;
        }
        processCheckResults({
            shopId: this.shopId,
            dateStart: this.dateStart,
            dateEnd: this.dateEnd,
            channel: this.channelId,
            walker: this.walkerId,
        })
        .then(data => {
            this.showSuccess(Photo_Updating);
            this.isCanSearch = false;
            this.pollForStatus();
        })
        .catch(error => {
            
        });
    }

    pollForStatus() {
        getUpdateStatus({ batchClass: 'PhotoDownloadProcessBatch'})
            .then(result => {
                if (result) {
                    // this.isDisabled = result.Disabled__c;
                    if (result.Update_Status__c !== 'Update complete') {
                        this.isUpdate = false;
                        // 每隔 5 秒查询一次状态
                        setTimeout(() => this.pollForStatus(), 5000);
                    } else {
                        this.showSuccess(Photo_Updated);
                        this.isUpdate = true;
                        this.isCanSearch = true;
                    }
                }
            })
            .catch(error => {
                console.error('Error fetching update status:', error);
                clearInterval(timeIntervalInstance);
            });
    }


    // 点击查询生成文件按钮
    handleClickSearch(){
        // 验证
        // if(this.judgeFieldValueEmpty(this.shopId) || this.judgeFieldValueEmpty(this.dateStart) || this.judgeFieldValueEmpty(this.dateEnd) ){

        if(this.judgeFieldValueEmpty(this.dateStart) || this.judgeFieldValueEmpty(this.dateEnd) ){
            this.showError(Data_Missing);
            return false;
        }
        this.getMinDate();

        if(this.dateStart < this.minDate){
            this.showError(Date_Interval);
            return false;
        }
        this.isShowSpinner = true;
        // todo
        this.isCanSearch = true;
        this.isCanDownload = false;
        // downloadZip
        
        searchDownloadPhoto({
            shopId: this.shopId,
            dateStart: this.dateStart,
            dateEnd: this.dateEnd,
            channel: this.channelId,
            walker: this.walkerId,
        })
        .then(data => {
            if(data.isSuccess){
                this.isLoadingCompleted = false;
                this.isLoading = true;
                // this.batchId = data.batchId;
                // this.key = data.key;
                // timeIntervalInstance = setInterval(() => {
                //     refreshApex(this.wiredResult);
                // }, 1000);
            }else {
                this.isLoadingCompleted = true;
            }
            // this.result = this.transformData(data.result);
        
            // const filteredDataOne = this.result.filter(
            //     row => row.dateDocument && Object.keys(row.dateDocument).length > 0
            // );
            // this.result = filteredDataOne;
            if (this.isLoadingResult) return;
            this.isLoadingResult = true;
            this.totalRecords = data.total;
            this.allData = this.transformData(data.result);
            this.loadInitialData();
            console.log('TRANS' + JSON.stringify(this.displayedRecords.length));
            
            console.log('TRANS' + JSON.stringify(this.displayedRecords));
            this.isLoadingResult = false;
            this.urlList = data.urlList;
            console.log('URL' + JSON.stringify(data.urlList));
            console.log('Size' + JSON.stringify(data.urlList.length));
            this.isCanDownload = this.urlList.length > 0;
            this.isShowSpinner = false;
        })
        .catch(error => {
            this.isShowSpinner = false;
            this.isLoadingCompleted = true;
        });
    }

    transformData(data) {
        return data.map(dateInfo => {
                // 将 dateDocument 的对象结构转换为数组
                const dateDocumentArray = Object.entries(dateInfo.dateDocument).map(([itemType, checkResults]) => ({
                    itemType, // Item_Type__c 的值
                    checkResults // 对应的 CheckResult__c 记录数组
                }));
                const show = Object.keys(dateInfo.dateDocument).length > 0;
                return {
                    ...dateInfo,
                    show,
                    dateDocument: dateDocumentArray // 替换为转换后的数组
                };
            }).filter(dateInfo => dateInfo.show); // 过滤掉 show 为 false 的数据
    }


    @track allData = []; // 存储所有数据
    @track displayedRecords = []; // 当前显示的数据
    initialLoadSize = 50; // 初始加载的数据量
    loadSize = 20; // 每次加载的数据量
    isLoadResulting = false; // 是否正在加载数据
    currentOffset = 0; // 当前已加载的数据偏移量
    isAllDataLoaded = false; // 是否所有数据都已加载完毕

    // 加载初始数据
    loadInitialData() {
    if (this.isLoadResulting) return;

    this.isLoadResulting = true;
    this.displayedRecords = this.paginateData(this.allData, this.initialLoadSize, 0);
    this.currentOffset = this.displayedRecords.reduce((acc, dateInfo) => {
        return acc + dateInfo.dateDocument.reduce((subAcc, itemTypeGroup) => {
            return subAcc + itemTypeGroup.checkResults.length;
        }, 0);
    }, 0); // 更新 currentOffset 为初始加载的数据量
    this.isLoadResulting = false;
}

    // 分页数据
paginateData(data, limit, offset) {
    console.log('paginateData', { data, limit, offset });
    let result = [];
    let totalLoaded = 0; // 用于跟踪已加载的 checkResults 条数

    // 遍历数据，直到达到限制或处理完所有数据
    for (let dateInfo of data) {
        let dateDocument = [];
        let dateInfoCheckResultsCount = 0; // 当前 dateInfo 的 checkResults 总条数

        for (let itemTypeGroup of dateInfo.dateDocument) {
            let checkResults = itemTypeGroup.checkResults;

            // 如果加载的 checkResults 条数已经超过限制，则截取剩余部分
            if (totalLoaded + checkResults.length > limit) {
                checkResults = checkResults.slice(0, limit - totalLoaded);
            }

            dateDocument.push({
                ...itemTypeGroup,
                checkResults
            });

            totalLoaded += checkResults.length;
            dateInfoCheckResultsCount += checkResults.length;

            // 如果已加载的 checkResults 条数已经达到限制，则停止处理
            if (totalLoaded >= limit) break;
        }

        // 如果当前 dateInfo 的 checkResults 总条数大于 0，则添加到结果中
        if (dateInfoCheckResultsCount > 0) {
            result.push({
                ...dateInfo,
                dateDocument
            });
        }

        // 如果已加载的 checkResults 条数已经达到限制，则停止处理
        if (totalLoaded >= limit) break;
    }

    // 如果已经加载了足够的数据，返回结果
    if (totalLoaded >= limit) {
        console.log('paginateData: Limit reached');
        return result;
    }

    // 如果没有加载足够的数据，检查是否已经处理完所有数据
    if (totalLoaded < limit && totalLoaded + offset >= this.allData.reduce((acc, dateInfo) => {
        return acc + dateInfo.dateDocument.reduce((subAcc, itemTypeGroup) => {
            return subAcc + itemTypeGroup.checkResults.length;
        }, 0);
    }, 0)) {
        console.log('paginateData: All data loaded');
        this.isAllDataLoaded = true; // 标记所有数据都已加载完毕
    }

    console.log('paginateData result', result);
    return result;
}

    loadMoreData() {
    if (this.isLoadResulting || this.isAllDataLoaded) return;

    this.isLoadResulting = true;
    console.log('loadMoreData', { currentOffset: this.currentOffset, loadSize: this.loadSize });
    let nextRecords = this.paginateData(this.allData, this.loadSize, this.currentOffset);
    console.log('nextRecords length', nextRecords.length);

    if (nextRecords.length > 0) {
        this.displayedRecords = [...this.displayedRecords, ...nextRecords];
        this.currentOffset += nextRecords.reduce((acc, dateInfo) => {
            return acc + dateInfo.dateDocument.reduce((subAcc, itemTypeGroup) => {
                return subAcc + itemTypeGroup.checkResults.length;
            }, 0);
        }, 0); // 更新 currentOffset 为实际加载的数据量
    } else {
        this.isAllDataLoaded = true; // 标记所有数据都已加载完毕
    }
    this.isLoadResulting = false;
}

// 监听滚动事件
handleScroll(event) {
    const element = event.target;
    const { scrollTop, scrollHeight, clientHeight } = element;

    // 检查是否滚动到底部
    if (scrollTop + clientHeight >= scrollHeight - 5 && !this.isAllDataLoaded && !this.isLoadResulting) {
        this.loadMoreData();
    }
}

// 获取滚动容器
get scrollContainer() {
    return this.template.querySelector('.scroll-container');
}

// 添加滚动事件监听器
renderedCallback() {
    const scrollContainer = this.scrollContainer;
    if (scrollContainer) {
        scrollContainer.addEventListener('scroll', this.handleScroll.bind(this));
    }
}

// 移除滚动事件监听器
disconnectedCallback() {
    const scrollContainer = this.scrollContainer;
    if (scrollContainer) {
        scrollContainer.removeEventListener('scroll', this.handleScroll.bind(this));
    }
}

    // 加载初始数据
    // loadInitialData() {
    //     if (this.isLoadResulting) return;

    //     this.isLoadResulting = true;
    //     this.displayedRecords = this.paginateData(this.allData, this.initialLoadSize);
    //     this.isLoadResulting = false;
    // }

    // 分页数据
    // paginateData(data, limit) {
    //     let totalLoaded = 0;
    //     let result = [];

    //     for (let dateInfo of data) {
    //         let dateDocument = [];
    //         for (let itemTypeGroup of dateInfo.dateDocument) {
    //             let checkResults = itemTypeGroup.checkResults.slice(0, limit - totalLoaded);
    //             totalLoaded += checkResults.length;
    //             dateDocument.push({
    //                 ...itemTypeGroup,
    //                 checkResults
    //             });
    //             if (totalLoaded >= limit) break;
    //         }
    //         result.push({
    //             ...dateInfo,
    //             dateDocument
    //         });
    //         if (totalLoaded >= limit) break;
    //     }

    //     return result;
    // }
    

    // 监听滚动事件
    // handleScroll(event) {
    //     const element = event.target;
    //     const { scrollTop, scrollHeight, clientHeight } = element;

    //     // 检查是否滚动到底部
    //     if (scrollTop + clientHeight >= scrollHeight - 5) {
    //         this.loadMoreData();
    //     }
    // }

    // 加载更多数据
    // loadMoreData() {
    //     if (this.isLoadResulting) return;

    //     this.isLoadResulting = true;
    //     let nextRecords = this.paginateData(this.allData, this.currentOffset + this.loadSize);
    //     if (nextRecords.length > 0) {
    //         this.displayedRecords = [...this.displayedRecords, ...nextRecords];
    //         this.currentOffset += this.loadSize;
    //     }
    //     this.isLoadResulting = false;
    // }


    

    // wiredResult
    // @wire(checkBatchProgress, { batchId: "$batchId"})
    // checkBatchProgress(result) {
    //     if(!this.judgeFieldValueEmpty(this.batchId)){
    //         this.wiredResult = result;
    //         this.isLoadingProgess = result.data.isLoadingProgess;
    //         if(result.data.Status == 'Completed'){
    //             this.isLoadingCompleted = true;
    //             this.isCanSearch = true;
    //             this.isCanDownload = true;
    //             clearInterval(timeIntervalInstance);
    //         }
    //     }
    // }
    
    // @track option;
    // @wire(getDataResult)
    // wiredChannelList(result) {
    //     if (result.data) {
    //         // 如果有数据，提取 channelList
    //         // this.shopId = result.data.initShop;
    //         // this.option = result.data.channel || [];
    //         this.channelOptions = result.data.channel || [];
    //         this.ownerDataOptions = result.data.owner || [];
    //         this.walkerOptions = result.data.owner || [];
    //         console.log(this.channelOptions);
    //         // this.getResultByStore();
    //         this.error = undefined; 
    //     } else if (result.error) {
    //         console.error('Error fetching channel list:', result.error);
    //         this.error = result.error;
    //         this.channelOptions = []; // 清空选项
    //     }
    // }

    getParamResult() {
        getParamResult({
            dateStart: this.dateStart,
            dateEnd: this.dateEnd,
        })
        .then(data => {
            console.log('X1' + JSON.stringify(data));
            
            // 如果有数据，提取 channelList
            // this.shopId = result.data.initShop;
            // this.option = result.data.channel || [];
            var option = data.channel;
            var owner = data.owner;
            this.channelOptions = option || [];
            this.ownerDataOptions = owner || [];
            this.walkerOptions = owner || [];
            this.forceRender = !this.forceRender; 
            console.log('---in---'+ JSON.stringify(this.channelOptions));
            // this.getResultByStore();
            this.error = undefined; 
        })
        .catch(error => {
            this.isShowSpinner = false;
            this.isLoadingCompleted = true;
        });
    }

    // 点击下载按钮
    // handleClickDownloadZip(){
    //     this.isShowSpinner = true;
    //     getDownloadFileList({
    //         key: this.key,
    //     })
    //     .then(data => {
    //         if(data){
    //             this.downloadFiles(data);
    //         }
    //         this.isShowSpinner = false;
    //     })
    //     .catch(error => {
    //         this.isShowSpinner = false;
    //     });
    // }

    downloadFiles(fileUrls) {
        // fileUrls.forEach((url, index) => {
        //     setTimeout(() => {
        //         this.downloadFile(url);
        //     }, index * 1000 + 1000);

        // });

        fileUrls.forEach((url, index) => {
            // 创建一个新的 iframe 元素
            let iframe = document.createElement('iframe');
            // 将 iframe 的 'src' 属性设置为文件的 URL
            iframe.src = url.VersionDataUrl;
            // 设置 iframe 的 'id' 以便稍后移除
            iframe.id = 'download_iframe__' + index;
            // 将 iframe 设置为隐藏
            iframe.style.display = 'none';
            // 将 iframe 添加到页面中
            document.body.appendChild(iframe);
        });
    }


    downloadFile(fileUrl) {
        var link = document.createElement('a');
        link.href = fileUrl.VersionDataUrl + '?t=' + new Date().getTime();
        link.download = fileUrl.PathOnClient; // 设置文件名
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        link = null;
    }

    // 是否不为空
	judgeFieldValueEmpty(fieldValue){
        if(fieldValue == undefined || fieldValue == null || fieldValue == "") {
            return true;
        }else{
            return false;
        }
    }

    // 点击按钮时触发的事件处理器
    handleDownload() {
        this.downloadNextFile();
        // this.downloadUrlsSequentially();
        // this.downloadFiles(this.urlList);
    }

    downloadFiles(fileUrls) {
        fileUrls.forEach((url, index) => {
            fetch(url)
                .then(response => response.blob())
                .then(blob => {
                    const link = document.createElement('a');
                    link.href = URL.createObjectURL(blob);
                    link.download = url.split('/').pop(); // 使用URL的最后一部分作为文件名
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                    URL.revokeObjectURL(link.href); // 释放内存
                })
                .catch(console.error);
        });
    }

    downloadIndex = 0;
// downloadNextFile() {
//     if (this.downloadIndex < this.urlList.length) {
//         const downloadUrl = this.urlList[this.downloadIndex];
//         const link = document.createElement('a');
//         link.href = downloadUrl;
//         link.download = '文件名' + (this.downloadIndex + 1); // 设置下载文件的默认名称
//         link.style.display = 'none'; // 隐藏链接
//         link.id = `download-link-${this.downloadIndex}`; // 添加唯一的标识符
//         document.body.appendChild(link);

//         console.log(`Starting download for index ${this.downloadIndex} with URL ${downloadUrl}`);

//         // 触发点击事件
//         link.click();

//         // 等待下载完成
//         this.waitForDownload(link).then(() => {
//             document.body.removeChild(link); // 移除链接
//             console.log(`Download completed for index ${this.downloadIndex}`);
//             this.downloadIndex++;
//             setTimeout(() => {
//                 this.downloadNextFile(); // 递归调用下载下一个文件
//             }, 10000); // 增加2秒延迟
//         });
//     } else {
//         console.log('All downloads completed');
//     }
// }

// waitForDownload(link) {
//     return new Promise((resolve) => {
//         const observer = new MutationObserver((mutations) => {
//             mutations.forEach((mutation) => {
//                 if (mutation.removedNodes.length > 0) {
//                     mutation.removedNodes.forEach((node) => {
//                         if (node.id === link.id) {
//                             observer.disconnect(); // 停止监听
//                             console.log(`Link with ID ${link.id} removed, resolving promise`);
//                             resolve();
//                         }
//                     });
//                 }
//             });
//         });

//         observer.observe(document.body, { childList: true });
//         console.log(`MutationObserver set up for link with ID ${link.id}`);
//     });
// }

    downloadNextFile() {
        if (this.downloadIndex < this.urlList.length) {
            const downloadUrl = this.urlList[this.downloadIndex];
            const link = document.createElement('a');
            link.href = downloadUrl;
            link.download = '文件名' + (this.downloadIndex + 1); // 设置下载文件的默认名称
            link.style.display = 'none'; // 隐藏链接
            link.id = `download-link-${this.downloadIndex}`; // 添加唯一的标识符
            document.body.appendChild(link);
            link.click(); // 触发点击事件

            // 设置定时器监听下载状态
            let interval;
            let timeout;

            const checkDownload = () => {
                const activeLink = document.getElementById(link.id);
                if (!activeLink) {
                    clearInterval(interval); // 清除定时器
                    clearTimeout(timeout); // 清除超时
                    document.body.removeChild(link); // 移除链接
                    this.downloadIndex++;
                    this.downloadNextFile(); // 触发下一个下载
                }
            };

            interval = setInterval(checkDownload, 2000); // 每秒检查一次

            // 设置超时机制
            timeout = setTimeout(() => {
                clearInterval(interval); // 清除定时器
                document.body.removeChild(link); // 移除链接
                this.downloadIndex++;
                this.downloadNextFile(); // 触发下一个下载
            }, 20000); // 5秒后超时
        }
    }

    changePhotoName() {
        changePhotoName({})
        .then(data => {
            if(data){
                
            }
            this.isShowSpinner = false;
        })
        .catch(error => {
            this.isShowSpinner = false;
        });
    }

    refreshData(ele) {
        clearInterval(timeIntervalInstance);
    }

    disconnectedCallback() {
        console.log('Component disconnected from the DOM');
        clearInterval(timeIntervalInstance);
        
    }

    

}