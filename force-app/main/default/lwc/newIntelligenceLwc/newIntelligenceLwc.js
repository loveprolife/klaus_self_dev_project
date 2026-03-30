import { LightningElement, track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import LightningConfirm from 'lightning/confirm';

import PromoterDailyReport_INTELLIGENCE from '@salesforce/label/c.PromoterDailyReport_INTELLIGENCE';
import PromoterDailyReport_DISPLAY_COMPETITIVE from '@salesforce/label/c.PromoterDailyReport_DISPLAY_COMPETITIVE';
import PromoterDailyReport_HIDE_COMPETITIVE from '@salesforce/label/c.PromoterDailyReport_HIDE_COMPETITIVE';
import PromoterDailyReport_NEW_PRODUCT from '@salesforce/label/c.PromoterDailyReport_NEW_PRODUCT';
import PromoterDailyReport_NEW_PRODUCT_HELP_TEXT from '@salesforce/label/c.PromoterDailyReport_NEW_PRODUCT_HELP_TEXT';
import PromoterDailyReport_OFF from '@salesforce/label/c.PromoterDailyReport_OFF';
import PromoterDailyReport_OFF_HELP_TEXT from '@salesforce/label/c.PromoterDailyReport_OFF_HELP_TEXT';
import PromoterDailyReport_VALUE_OFF from '@salesforce/label/c.PromoterDailyReport_VALUE_OFF';
import PromoterDailyReport_CAMP_TYPE from '@salesforce/label/c.PromoterDailyReport_CAMP_TYPE';
import PromoterDailyReport_CAMP_DES from '@salesforce/label/c.PromoterDailyReport_CAMP_DES';
import PromoterDailyReport_ITEM_ACTION from '@salesforce/label/c.PromoterDailyReport_ITEM_ACTION';
import PromoterDailyReport_NUMBER from '@salesforce/label/c.PromoterDailyReport_NUMBER';



import PromoterDailyReport_ATTACHMENT from '@salesforce/label/c.PromoterDailyReport_ATTACHMENT';
import PromoterDailyReport_ACTIONS from '@salesforce/label/c.PromoterDailyReport_ACTIONS';
import PromoterDailyReport_RequiredCheck from '@salesforce/label/c.PromoterDailyReport_RequiredCheck';
import PromoterDailyReport_DeleteReminder from '@salesforce/label/c.PromoterDailyReport_DeleteReminder';
import PromoterDailyReport_AddItemCheck from '@salesforce/label/c.PromoterDailyReport_AddItemCheck';
import PromoterDailyReport_AddNewItemSuccess from '@salesforce/label/c.PromoterDailyReport_AddNewItemSuccess';

import getInitData from '@salesforce/apex/IntelligenceController.getInitData';
import saveRecord from '@salesforce/apex/IntelligenceController.saveRecord';

export default class NewIntelligenceLwc extends LightningNavigationElement {

    @api lwcName = PromoterDailyReport_INTELLIGENCE;

    @api type;
    @api recordId;
    @api viewMode;

    @track isShowSpinner;
    @track recordList = [];
    @track intelligenceList = [];
    @track deleteRecordList = [];
    @track fields = {};
    @track intelligenceFilesMap = {};

    @track isChile = false;
    @track isShowNewProduct = true;

    whitePriceMap = {};

    label = {
        PromoterDailyReport_INTELLIGENCE, PromoterDailyReport_DISPLAY_COMPETITIVE, PromoterDailyReport_HIDE_COMPETITIVE, PromoterDailyReport_NEW_PRODUCT,
        PromoterDailyReport_NEW_PRODUCT_HELP_TEXT, PromoterDailyReport_OFF, PromoterDailyReport_OFF_HELP_TEXT, PromoterDailyReport_VALUE_OFF,
        PromoterDailyReport_CAMP_TYPE, PromoterDailyReport_CAMP_DES, PromoterDailyReport_ATTACHMENT, PromoterDailyReport_ACTIONS, PromoterDailyReport_ITEM_ACTION,
        PromoterDailyReport_DeleteReminder, PromoterDailyReport_NUMBER
    };

    @track style = '';
    refreshStyle() {
        // this.style =  FORM_FACTOR == 'Small' ? 'max-height: ' + (document.documentElement.clientHeight - 130) + 'px;' : '';
    }

    infoDate(data) {
        // 竞品信息初始化
        let intelligenceList = [];
        if (data.data.intelligenceList) {
            let beforeFormat = data.data.intelligenceList;
            console.log(' data.data.intelligenceList>>>>' + JSON.stringify(data.data.intelligenceList));
            if (beforeFormat.length > 0) {
                // 主数据配置
                for (let index = 0; index < beforeFormat.length; index++) {
                    var item = beforeFormat[index];

                    // added by Sunny
                    item.hasWhitePrice = item.WhitePrice__c ? true : false;

                    if (item.HisenseShopRetailDetail__c == null) {
                        var fileValue = 'intelligence_' + (intelligenceList.length + 1) + '_1';
                        item.idx = 1;
                        item.number = 1;
                        item.isFirst = true;
                        item.isShow = true;
                        item.isDisabled = true;
                        item.files = [fileValue];
                        var intelligence = {
                            Id: item.Id,
                            index: intelligenceList.length + 1,
                            number: intelligenceList.length + 1,
                            IsActive: true,
                            isDisabled: true,
                            Item: [item]
                        };

                        intelligenceList.push(intelligence);
                    }
                    //this.intelligenceLen = intelligenceList.length;
                }
                // 竞品数据配置
                for (let index = 0; index < beforeFormat.length; index++) {
                    var item = beforeFormat[index];
                    if (item.HisenseShopRetailDetail__c != null) {
                        var mainDetailList = intelligenceList.filter(obj => obj.Id == item.HisenseShopRetailDetail__c);
                        var mainDetail = mainDetailList[0];

                        var fileValue = 'intelligence_' + mainDetail.index + '_' + (mainDetail.Item.length + 1);

                        item.idx = mainDetail.Item.length + 1;
                        item.number = mainDetail.Item.length + 1;
                        item.isFirst = false;
                        item.isShow = true;
                        item.isDisabled = true;
                        item.files = [fileValue];
                        mainDetail.Item.push(item);
                    }
                }
                // 格式化后数据覆盖
                this.intelligenceList = intelligenceList;
            }
        }
    }

    connectedCallback() {
        this.isShowSpinner = true;
        console.log('connectedCallback!! ——> recordId：' + this.recordId);
        getInitData({
            recordId: this.recordId,
        }).then(data => {
            console.log('getInitData : ');
            for (let key in data.data) {
                this[key] = data.data[key];
            }
            if (data.isSuccess) {
                if (data.data.isSouthAfrica) {
                    this.isShowNewProduct = false;
                }
                // 竞品信息初始化
                this.infoDate(data);
            } else {
                this.showError(data.message);
            }
            this.isShowSpinner = false;
        }).catch(error => {
            this.catchError(error);
            this.isShowSpinner = false;
        });
        this.isShowSpinner = false;
    }


    isFilledOut(content) {
        if (typeof content == "undefined") {
            return false;
        } else if (content == '' || content == null) {
            return false;
        } else if (typeof content == "number") {
            return !isNaN(content);
        }
        return true;
    }

    //新增竞品信息
    @api
    itemAddHandler(event) {
        let result = this.checkRequiredIntelligence();
        console.log('result.alltrue : ' + result.alltrue);
        if (result.alltrue) {
            var filesValue = 'intelligence_' + (this.intelligenceList.length + 1) + '_1';
            console.log('filesValue : ' + filesValue);
            this.intelligenceList.push({
                Id: null,
                index: this.intelligenceList.length + 1,
                number: this.intelligenceList.length + 1,
                IsActive: true,
                isDisabled: false,
                Item: [{
                    idx: 1,
                    number: 1,
                    Brands__c: this.hisenseAccId,
                    Product__c: null,
                    //ProductInformation__c:'',
                    Price__c: '',
                    Discount__c: '',
                    Commission__c: '',
                    NewProduct__c: 'No',
                    DiscountPrice__c: '',
                    CampaignType__c: null,
                    CampaignDescription__c: '',
                    isFirst: true,
                    isShow: true,
                    isDisabled: false,
                    // Shop__c: this.record.Shop__c,
                    files: [filesValue],
                }],
            })
            this.showSuccess(PromoterDailyReport_AddNewItemSuccess);
        } else {
            this.showWarning(result.msg);
        }
        this.activeSections = ['intelligence'];
    }

    //新增海信产品价格调查
    addHisenseProduct(event) {

        let result = this.checkRequiredIntelligence();
        console.log('result.alltrue : ' + result.alltrue);
        if (result.alltrue) {
            let index = event.target.dataset.tableindex;
            var intelligence = this.intelligenceList[index];

            var itemSize = intelligence.Item.length + 1;

            var fileValue = 'intelligence_' + (Number(index) + 1) + '_' + itemSize;
            var item = {
                idx: itemSize,
                number: itemSize,
                Brands__c: null,
                Product__c: null,
                ProductInformation__c: '',
                NewProduct__c: 'No',
                Price__c: '',
                Discount__c: '',
                DiscountPrice__c: '',
                Commission__c: '',
                CampaignType__c: null,
                CampaignDescription__c: '',
                isFirst: false,
                isShow: intelligence.IsActive,
                isDisabled: false,
                files: [fileValue],
            }
            this.intelligenceList[index].Item.push(item);
            this.showSuccess(PromoterDailyReport_AddNewItemSuccess);
        } else {
            this.showWarning(result.msg);
        }
    }

    // 竞品信息转JSON前转换
    intelligenceBeforeSave() {
        var intelligenceList = [];
        console.log('竞品信息转JSON前转换:' + JSON.stringify(this.intelligenceList));
        for (let i = 0; i < this.intelligenceList.length; i++) {
            var intelligenceItem = this.intelligenceList[i].Item;
            var infoList = [];
            for (let j = 0; j < intelligenceItem.length; j++) {
                var info = this.intelligenceList[i].Item[j];

                let filesInfo = [];
                // if (item.files && Array.isArray(item.files)) {
                //     filesInfo.push(...item.files);
                //     delete item['files'];
                // }
                if (info.files && Array.isArray(info.files)) {
                    filesInfo.push(...info.files);
                    delete info['files'];
                }

                var dataInfo = { intelligenceDataInfo: info, filesInfo: filesInfo };

                infoList.push(dataInfo);
            }
            intelligenceList.push(infoList);
        }
        return intelligenceList;
    }


    @api
    saveData() {
        this.isShowSpinner = true;
        this.deleteLastIntelligence();
        var intelligenceJson = this.intelligenceBeforeSave();
        console.log('intelligenceJson : ' + intelligenceJson);
        saveRecord({
            recordId: this.recordId,
            intelligenceJson: JSON.stringify(intelligenceJson),
            intelligenceFilesMapJson: JSON.stringify(this.intelligenceFilesMap)
        }).then(data => {
            this.isShowSpinner = false;
            if (data.isSuccess) {
                for (let key in data.data) {
                    this[key] = data.data[key];
                }
                this.infoDate(data);
                let eles = this.template.querySelectorAll('c-upload-files-lwc');
                for (let index = 0; eles && index < eles.length; index++) {
                    let ele = eles[index];
                    ele.refresh();
                }
            } else {
                console.log('data.message : ' + data.message);
                // this.showError(data.message);
            }
            this.dispatchEvent(new CustomEvent('savedata', {
                detail: {
                    result: data
                }
            }));
            console.log('intelligenceLwc saveRecord end');
        }).catch(error => {
            this.catchError(error);
            this.isShowSpinner = false;
        });
        this.isShowSpinner = false;
    }


    @api
    checkData() {
        return this.checkRequiredIntelligence().msg;
    }

    // 竞品必填字段
    checkRequiredIntelligence() {
        var resp = {
            alltrue: true,
            msg: ''
        };
        if (this.intelligenceList && this.intelligenceList.length > 0) {
            const missFields = new Set();
            console.log('missFields : ' + missFields);
            for (let i = 0; i < this.intelligenceList.length; i++) {
                var intelligence = this.intelligenceList[i].Item;

                for (let j = 0; j < intelligence.length; j++) {
                    var info = this.intelligenceList[i].Item[j];

                    if (!this.isFilledOut(info.Brands__c)) {
                        resp.alltrue = false;
                        missFields.add(this.fields.Brands__c);
                    }
                    if (j == 0) {
                        if (!this.isFilledOut(info.Product__c)) {
                            resp.alltrue = false;
                            missFields.add(this.fields.Product__c);
                        }
                    } else {
                        if (!this.isFilledOut(info.ProductInformation__c)) {
                            resp.alltrue = false;
                            missFields.add(this.fields.ProductInformation__c);
                        }
                    }
                    if (!this.isFilledOut(info.NewProduct__c)) {
                        resp.alltrue = false;
                        missFields.add(this.fields.NewProduct__c);
                    }
                }
            }

            console.log('missFields : ' + missFields);
            let missFieldsList = Array.from(missFields.keys());
            if (missFieldsList.length > 0) {
                resp.msg += '[' + this.lwcName + ' — ';
                for (let index = 0; index < missFieldsList.length; index++) {
                    if (index == missFieldsList.length - 1) {
                        resp.msg += missFieldsList[index] + ']';
                    } else {
                        resp.msg += missFieldsList[index] + '/';
                    }
                }
            }
        }
        return resp;
    }

    productLookupFilter = {
        'lookup': 'CustomLookupProvider.ProductAllFilter'
    }

    brandLookupFilter = {
        'lookup': 'CustomLookupProvider.BrandContainsHisense'
    }


    handleChangeIntelligenceOption(event) {

        let idx = event.target.dataset.id;
        let index = event.target.dataset.tableindex;
        let fieldName = event.target.dataset.fieldName;
        let selectRecord = event.detail.selectedRecord;

        if (selectRecord == undefined) {
            this.intelligenceList[Number(index)].Item[Number(idx)][fieldName] = null;;
        } else {
            this.intelligenceList[Number(index)].Item[Number(idx)][fieldName] = selectRecord.Id;
        }

        // white price
        if (fieldName == 'Product__c') {
            let intelligenceItem = this.intelligenceList[Number(index)].Item[Number(idx)];
            if (this.whitePriceMap && (intelligenceItem.Product__c in this.whitePriceMap)) {
                intelligenceItem.WhitePrice__c = this.whitePriceMap[intelligenceItem.Product__c];
                intelligenceItem.hasWhitePrice = true;
            } else {
                intelligenceItem.hasWhitePrice = false;
            }
        }
    }

    //处理海信产品价格变更
    handleHisenseProductInputChange(event) {
        let idx = event.target.dataset.id;
        let index = event.target.dataset.tableindex;
        let value = event.target.value.replace(/\s+/g, "").toUpperCase() //去除产品型号空格并转换字母为大写 BY yyl 20231102
        console.log('idx==========>' + idx);
        console.log('index==========>' + index);
        console.log('去除空格后转换大写字母的value==========>' + value);

        // this.intelligenceList[index].Item[idx][event.target.fieldName] = event.target.value;
        this.intelligenceList[index].Item[idx][event.target.fieldName] = value;//去除产品型号空格并转换字母为大写 BY yyl 20231102

        var price = this.intelligenceList[Number(index)].Item[Number(idx)].Price__c;
        var discount = this.intelligenceList[Number(index)].Item[Number(idx)].Discount__c;
        var discountPrice = this.intelligenceList[Number(index)].Item[Number(idx)].DiscountPrice__c;
        if (event.target.fieldName == 'Price__c') {
            if (price == null || price == '') {
                this.intelligenceList[Number(index)].Item[Number(idx)].Discount__c = '';
                this.intelligenceList[Number(index)].Item[Number(idx)].DiscountPrice__c = '';
            } else if (discount != null && discount != '') {
                this.intelligenceList[Number(index)].Item[Number(idx)].DiscountPrice__c = (discount * 1 / 100 * price).toString();
            } else if (discountPrice != null && discountPrice != '') {
                this.intelligenceList[Number(index)].Item[Number(idx)].Discount__c = Math.round(discountPrice / price * 100).toString();
            }
        } else if (event.target.fieldName == 'Discount__c') {
            if (discount == null || discount == '') {
                this.intelligenceList[Number(index)].Item[Number(idx)].DiscountPrice__c = '';
            } else if (price != null && price != '') {
                this.intelligenceList[Number(index)].Item[Number(idx)].DiscountPrice__c = (discount * 1 / 100 * price).toString();
            }
        } else if (event.target.fieldName == 'DiscountPrice__c') {
            if (discountPrice == null || discountPrice == '') {
                this.intelligenceList[Number(index)].Item[Number(idx)].Discount__c = '';
            } else if (price != null && price != '') {
                this.intelligenceList[Number(index)].Item[Number(idx)].Discount__c = Math.round(discountPrice / price * 100).toString();
            }
        }
        console.log('intelligenceList=====>' + JSON.stringify(this.intelligenceList));

        this.refreshStyle();
    }

    // 自定义弹框
    // @track modalMsg;
    // @track modalType;
    // @track modalHelper;
    // @track modelHelper;
    // handleShow(msg, type, hepler, helper2) {
    //     let ele = this.template.querySelector('c-modal-lwc');
    //     if (ele != null) {
    //         this.modalMsg = msg;
    //         this.modalType = type;
    //         this.modalHelper = hepler;
    //         this.modelHelper = helper2
    //         ele.showModal(this.template);
    //     } else {
    //         console.log('c-modal-lwc is null');
    //     }
    // }

    // handleOk() {
    //     this.template.querySelector('c-modal-lwc').closeModal();
    //     this[this.modalType](this.modalHelper, this.modelHelper);
    // }

    //删除竞品
    async deleteIntelligenceRow(event) {
        var index = event.target.dataset.id;
        // this.handleShow(this.label.PromoterDailyReport_DeleteReminder, 'deleteIntelligenceRowHelper', index, null);

        const deleteResult = await LightningConfirm.open({
            // message: 'Information will be deleted if you click "OK"; click "Cancel" to cancel.',
            message: PromoterDailyReport_DeleteReminder,
            variant: 'headerless',
            label: 'This is the aria-label value',
        });
        if (deleteResult) {
            this.deleteIntelligenceRowHelper(index);
        }

    }

    // 附件部分
    handleSelectFiles(event) {
        console.log('event.currentTarget.dataset.type===>' + event.currentTarget.dataset.type);
        console.log('event.currentTarget.dataset.recordid===>' + event.currentTarget.dataset.recordid);
        var type = event.currentTarget.dataset.type;
        var index = event.currentTarget.dataset.recordid;

        var indexNumber = Number(index) + 1;
        if (type == 'intelligence') {
            var itemId = event.currentTarget.dataset.itemid;
            var itemIdNumber = Number(itemId) + 1;
            this.intelligenceFilesMap[type + '_' + indexNumber + '_' + itemIdNumber] = event.detail.records;
        }
    }

    deleteIntelligenceRowHelper(index) {
        try {
            let new_list = [];
            let new_file_map = {};
            for (let i = 0; i < this.intelligenceList.length; i++) {
                if (i != index) {
                    new_list.push(this.intelligenceList[i]);
                }
            }
            for (let i = 0; i < new_list.length; i++) {
                new_list[i].number = i + 1;
                for (let j = 0; j < new_list[i].Item.length; j++) {
                    // new_list[i].Item[j].files[0] = new_list[i].Item[j].files[0].split('_')[0]+'_'+(i+1)+'_'+new_list[i].Item[j].files[0].split('_')[2];

                    var data_key = new_list[i].Item[j].files[0].split('_')[0] + '_' + (i + 1) + '_' + new_list[i].Item[j].files[0].split('_')[2];

                    new_file_map[data_key] = this.intelligenceFilesMap[new_list[i].Item[j].files[0]];
                    new_list[i].Item[j].files[0] = data_key;
                }
            }
            if (new_list.length == 0) {
                this.activeSections = [];
            }
            console.log('new_list>>>>>>>>' + JSON.stringify(new_list));
            this.intelligenceList = new_list;
            console.log('intelligenceList----------new_list>>>>>>>>' + JSON.stringify(this.intelligenceList));
            this.intelligenceFilesMap = new_file_map;

        } catch (err) {
            console.log(err);
        }

    }

    // 删除海信产品价格调查
    async deleteHisenseProduct(event) {
        let deleteRowIndex = event.target.dataset.id;
        let deleteItemIndex = event.target.dataset.tableindex;
        console.log('deleteHisenseProduct -------> deleteRowIndex : ' + deleteRowIndex);
        console.log('deleteHisenseProduct -------> deleteItemIndex : ' + deleteItemIndex);
        // this.handleShow(this.label.PromoterDailyReport_DeleteReminder, 'deleteHisenseProductHelper', deleteRowIndex, deleteItemIndex);
        
        const deleteResult = await LightningConfirm.open({
            // message: 'Information will be deleted if you click "OK"; click "Cancel" to cancel.',
            message: PromoterDailyReport_DeleteReminder,
            variant: 'headerless',
            label: 'This is the aria-label value',
        });
        if (deleteResult) {
            this.deleteHisenseProductHelper(deleteRowIndex, deleteItemIndex);
        }
    }

    //删除海信产品价格调查
    deleteHisenseProductHelper(deleteRowIndex, deleteItemIndex) {
        console.log('deleteHisenseProductHelper -------> Start : ');
        try {
            // let idx = event.target.dataset.id;
            // let index = event.target.dataset.tableindex;

            let idx = deleteRowIndex;
            let index = deleteItemIndex;

            let new_list = [];
            let new_file_map = {};
            for (let i = 0; i < this.intelligenceList[index].Item.length; i++) {
                if (i != idx) {
                    new_list.push(this.intelligenceList[index].Item[i]);
                }
            }
            for (let i = 0; i < new_list.length; i++) {
                new_list[i].number = i + 1;
                // new_list[i].files[0] = new_list[i].files[0].split('_')[0]+'_'+(Number(index)+1)+'_'+(i+1);

                var data_key = new_list[i].files[0].split('_')[0] + '_' + (Number(index) + 1) + '_' + (i + 1);

                new_file_map[data_key] = this.intelligenceFilesMap[new_list[i].files[0]];
                new_list[i].files[0] = data_key;
            }

            for (let i = 0; i < this.intelligenceList.length; i++) {
                if (i != index) {
                    for (let j = 0; j < this.intelligenceList[i].Item.length; j++) {
                        var intelligence = this.intelligenceList[i].Item[j];

                        var data_key = intelligence.files[0];

                        new_file_map[data_key] = this.intelligenceFilesMap[data_key];
                    }
                }

            }

            this.intelligenceList[index].Item = new_list;
            this.intelligenceFilesMap = new_file_map;

            this.refreshStyle();
        } catch (err) {
            console.log(err);
        }
    }

    // Deloitte Yin Mingjie 20231030 start
    deleteLastIntelligence() {
        if (this.intelligenceList && this.intelligenceList.length > 0) {
            var lastIntelligenceList = this.intelligenceList[this.intelligenceList.length - 1];
            var lastItemLength = lastIntelligenceList.Item.length - 1;
            var lastIntelligence = lastIntelligenceList.Item[lastItemLength];

            if (lastItemLength == 0) {
                if ((lastIntelligence.Product__c == null ||
                    lastIntelligence.Product__c == '' ||
                    lastIntelligence.Product__c == undefined)
                    &&
                    (
                        ((lastIntelligence.Price__c == null ||
                            lastIntelligence.Price__c == '' ||
                            lastIntelligence.Price__c == undefined) &&
                            (lastIntelligence.Discount__c == null ||
                                lastIntelligence.Discount__c == '' ||
                                lastIntelligence.Discount__c == undefined) &&
                            (lastIntelligence.DiscountPrice__c == null ||
                                lastIntelligence.DiscountPrice__c == '' ||
                                lastIntelligence.DiscountPrice__c == undefined) && !this.isChile) ||
                        this.isChile
                    )
                    &&
                    (
                        ((lastIntelligence.WhitePrice__c == null ||
                            lastIntelligence.WhitePrice__c == '' ||
                            lastIntelligence.WhitePrice__c == undefined) &&
                            (lastIntelligence.DebitPrice__c == null ||
                                lastIntelligence.DebitPrice__c == '' ||
                                lastIntelligence.DebitPrice__c == undefined) &&
                            (lastIntelligence.CrebitPrice__c == null ||
                                lastIntelligence.CrebitPrice__c == '' ||
                                lastIntelligence.CrebitPrice__c == undefined) && this.isChile) ||
                        !this.isChile
                    )
                    &&
                    (lastIntelligence.Commission__c == null ||
                        lastIntelligence.Commission__c == '' ||
                        lastIntelligence.Commission__c == undefined)
                    &&
                    (
                        ((lastIntelligence.CampaignType__c == null ||
                            lastIntelligence.CampaignType__c == '' ||
                            lastIntelligence.CampaignType__c == undefined) &&
                            (lastIntelligence.CampaignDescription__c == null ||
                                lastIntelligence.CampaignDescription__c == '' ||
                                lastIntelligence.CampaignDescription__c == undefined) && this.isShowCampTypeAndDes) ||
                        !this.isShowCampTypeAndDes
                    )
                ) {
                    this.deleteIntelligenceRowHelper(this.intelligenceList.length - 1);
                }
            } else {
                if ((lastIntelligence.Brands__c == null ||
                    lastIntelligence.Brands__c == '' ||
                    lastIntelligence.Brands__c == undefined)
                    &&
                    (lastIntelligence.ProductInformation__c == null ||
                        lastIntelligence.ProductInformation__c == '' ||
                        lastIntelligence.ProductInformation__c == undefined)
                    &&
                    (
                        ((lastIntelligence.Price__c == null ||
                            lastIntelligence.Price__c == '' ||
                            lastIntelligence.Price__c == undefined) &&
                            (lastIntelligence.Discount__c == null ||
                                lastIntelligence.Discount__c == '' ||
                                lastIntelligence.Discount__c == undefined) &&
                            (lastIntelligence.DiscountPrice__c == null ||
                                lastIntelligence.DiscountPrice__c == '' ||
                                lastIntelligence.DiscountPrice__c == undefined) && !this.isChile) ||
                        this.isChile
                    )
                    &&
                    (
                        ((lastIntelligence.WhitePrice__c == null ||
                            lastIntelligence.WhitePrice__c == '' ||
                            lastIntelligence.WhitePrice__c == undefined) &&
                            (lastIntelligence.DebitPrice__c == null ||
                                lastIntelligence.DebitPrice__c == '' ||
                                lastIntelligence.DebitPrice__c == undefined) &&
                            (lastIntelligence.CrebitPrice__c == null ||
                                lastIntelligence.CrebitPrice__c == '' ||
                                lastIntelligence.CrebitPrice__c == undefined) && this.isChile) ||
                        !this.isChile
                    )
                    &&
                    (lastIntelligence.Commission__c == null ||
                        lastIntelligence.Commission__c == '' ||
                        lastIntelligence.Commission__c == undefined)
                    &&
                    (
                        ((lastIntelligence.CampaignType__c == null ||
                            lastIntelligence.CampaignType__c == '' ||
                            lastIntelligence.CampaignType__c == undefined) &&
                            (lastIntelligence.CampaignDescription__c == null ||
                                lastIntelligence.CampaignDescription__c == '' ||
                                lastIntelligence.CampaignDescription__c == undefined) && this.isShowCampTypeAndDes) ||
                        !this.isShowCampTypeAndDes
                    )
                ) {
                    this.deleteHisenseProduct({
                        target: {
                            dataset: {
                                id: lastItemLength,
                                tableindex: this.intelligenceList.length - 1
                            }
                        }
                    })
                }

            }
        }
    }

    //intelligence
    /**START 门店价格调查 */
    handleToggle(event) {
        let index = event.target.dataset.id;
        var item = this.intelligenceList[index].Item;
        for (let i = 0; i < item.length; i++) {
            if (item[i].idx != 1) {
                item[i].isShow = event.target.checked;
            }
        }
        this.intelligenceList[index].Item = item;

        this.refreshStyle();

    }

}