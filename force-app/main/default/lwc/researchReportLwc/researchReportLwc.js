import { LightningElement, track, api, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import getInitData from '@salesforce/apex/ResearchReportController.getInitData';
import saveData from '@salesforce/apex/ResearchReportController.saveData';
import saveDailySalesData from '@salesforce/apex/ResearchReportController.saveDailySalesData';
import saveGoodsReceivingData from '@salesforce/apex/ResearchReportController.saveGoodsReceivingData';
import saveIntelligenceData from '@salesforce/apex/ResearchReportController.saveIntelligenceData';
import refreshData from '@salesforce/apex/ResearchReportController.refreshData';
import autoShowProductDes from '@salesforce/apex/ResearchReportController.autoShowProductDes';
import getProductSpiv from '@salesforce/apex/ResearchReportController.getProductSpiv';
import judgeCountry from '@salesforce/apex/ResearchReportController.judgeCountry';
import createData from '@salesforce/apex/ResearchReportController.createData';
import LightningConfirm from 'lightning/confirm';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import common3 from '@salesforce/resourceUrl/common3';

import PromoterDailyReportLabel from '@salesforce/label/c.PromoterDailyReport';
import PromoterDailyReport_SAVE from '@salesforce/label/c.PromoterDailyReport_SAVE';
import PromoterDailyReport_NOT_HAVE_REPORT from '@salesforce/label/c.PromoterDailyReport_NOT_HAVE_REPORT';
import PromoterDailyReport_DISPLAY_COMPETITIVE from '@salesforce/label/c.PromoterDailyReport_DISPLAY_COMPETITIVE';
import PromoterDailyReport_HIDE_COMPETITIVE from '@salesforce/label/c.PromoterDailyReport_HIDE_COMPETITIVE';
//new add标签
import PromoterDailyReport_OWNER from '@salesforce/label/c.PromoterDailyReport_OWNER';
import PromoterDailyReport_REPORT_NUMBER from '@salesforce/label/c.PromoterDailyReport_REPORT_NUMBER';
import PromoterDailyReport_DTAE from '@salesforce/label/c.PromoterDailyReport_DTAE';
import PromoterDailyReport_DATE_HELP_TEXT from '@salesforce/label/c.PromoterDailyReport_DATE_HELP_TEXT';
import PromoterDailyReport_STORE from '@salesforce/label/c.PromoterDailyReport_STORE';
import PromoterDailyReport_NEW from '@salesforce/label/c.PromoterDailyReport_NEW';
import PromoterDailyReport_NO from '@salesforce/label/c.PromoterDailyReport_NO';
import PromoterDailyReport_PRODUCT from '@salesforce/label/c.PromoterDailyReport_PRODUCT';
import PromoterDailyReport_DESCRIPTION from '@salesforce/label/c.PromoterDailyReport_DESCRIPTION';
import PromoterDailyReport_SPIV from '@salesforce/label/c.PromoterDailyReport_SPIV';
import PromoterDailyReport_KIOSK from '@salesforce/label/c.PromoterDailyReport_KIOSK';
import PromoterDailyReport_UNIT_PRICE from '@salesforce/label/c.PromoterDailyReport_UNIT_PRICE';
import PromoterDailyReport_QUANTITY from '@salesforce/label/c.PromoterDailyReport_QUANTITY';
import PromoterDailyReport_STORE_DELIVERY from '@salesforce/label/c.PromoterDailyReport_STORE_DELIVERY';
import PromoterDailyReport_TOTAL from '@salesforce/label/c.PromoterDailyReport_TOTAL';
import PromoterDailyReport_HAS_GIFT from '@salesforce/label/c.PromoterDailyReport_HAS_GIFT';
import PromoterDailyReport_GIFT from '@salesforce/label/c.PromoterDailyReport_GIFT';
import PromoterDailyReport_GIFT_QUANTITY from '@salesforce/label/c.PromoterDailyReport_GIFT_QUANTITY';
import PromoterDailyReport_COMMENT from '@salesforce/label/c.PromoterDailyReport_COMMENT';
import PromoterDailyReport_ATTACHMENT from '@salesforce/label/c.PromoterDailyReport_ATTACHMENT';
import PromoterDailyReport_ACTIONS from '@salesforce/label/c.PromoterDailyReport_ACTIONS';
import PromoterDailyReport_NUMBER from '@salesforce/label/c.PromoterDailyReport_NUMBER';
import PromoterDailyReport_Brands from '@salesforce/label/c.PromoterDailyReport_Brands';
import PromoterDailyReport_NEW_PRODUCT from '@salesforce/label/c.PromoterDailyReport_NEW_PRODUCT';
import PromoterDailyReport_NEW_PRODUCT_HELP_TEXT from '@salesforce/label/c.PromoterDailyReport_NEW_PRODUCT_HELP_TEXT';
import NewPromoterDailyReport_PRICE from '@salesforce/label/c.NewPromoterDailyReport_PRICE';
import PromoterDailyReport_OFF from '@salesforce/label/c.PromoterDailyReport_OFF';
import PromoterDailyReport_OFF_HELP_TEXT from '@salesforce/label/c.PromoterDailyReport_OFF_HELP_TEXT';
import PromoterDailyReport_VALUE_OFF from '@salesforce/label/c.PromoterDailyReport_VALUE_OFF';
import PromoterDailyReport_COMMISSION from '@salesforce/label/c.PromoterDailyReport_COMMISSION';
import PromoterDailyReport_CAMP_TYPE from '@salesforce/label/c.PromoterDailyReport_CAMP_TYPE';
import PromoterDailyReport_CAMP_DES from '@salesforce/label/c.PromoterDailyReport_CAMP_DES';
import PromoterDailyReport_ITEM_ACTION from '@salesforce/label/c.PromoterDailyReport_ITEM_ACTION';
import PromoterDailyReport_SUBMIT_REPORT from '@salesforce/label/c.PromoterDailyReport_SUBMIT_REPORT';
import PromoterDailyReport_DAILY_SALES from '@salesforce/label/c.PromoterDailyReport_DAILY_SALES';
import PromoterDailyReport_GOODS_RECEIVING from '@salesforce/label/c.PromoterDailyReport_GOODS_RECEIVING';
import PromoterDailyReport_TICKET from '@salesforce/label/c.PromoterDailyReport_TICKET';
import PromoterDailyReport_INTELLIGENCE from '@salesforce/label/c.PromoterDailyReport_INTELLIGENCE';
import PromoterDailyReport_MARKET_INSGHT from '@salesforce/label/c.PromoterDailyReport_MARKET_INSGHT';
import PromoterDailyReport_STORE_VIEW from '@salesforce/label/c.PromoterDailyReport_STORE_VIEW';
import PromoterDailyReport_PROMO_COURT from '@salesforce/label/c.PromoterDailyReport_PROMO_COURT';
import PromoterDailyReport_IN_HOUSE_SHARE from '@salesforce/label/c.PromoterDailyReport_IN_HOUSE_SHARE';
import PromoterDailyReport_SHELF_SHARE from '@salesforce/label/c.PromoterDailyReport_SHELF_SHARE';
import PromoterDailyReport_Consumer_Trait_Research from '@salesforce/label/c.PromoterDailyReport_Consumer_Trait_Research';
import PromoterDailyReport_Foot_Count_Inquiry from '@salesforce/label/c.PromoterDailyReport_Foot_Count_Inquiry';
import PromoterDailyReport_Returns_And_Credit from '@salesforce/label/c.PromoterDailyReport_Returns_And_Credit';
import PromoterDailyReport_GoodsReceivingError from '@salesforce/label/c.PromoterDailyReport_GoodsReceivingError';
import PromoterDailyReport_SubmitReminder from '@salesforce/label/c.PromoterDailyReport_SubmitReminder';
import PromoterDailyReport_RequiredCheck from '@salesforce/label/c.PromoterDailyReport_RequiredCheck';
import PromoterDailyReport_DeleteReminder from '@salesforce/label/c.PromoterDailyReport_DeleteReminder';
import PromoterDailyReport_FutureDate from '@salesforce/label/c.PromoterDailyReport_FutureDate';
import PromoterDailyReport_Spiv_Requied from '@salesforce/label/c.PromoterDailyReport_Spiv_Requied';
import PromoterDailyReport_MSG_SUBMIT_REPORT from '@salesforce/label/c.PromoterDailyReport_MSG_SUBMIT_REPORT';
import To_New_Page from '@salesforce/label/c.To_New_Page';
import Monthly_Report_Title from '@salesforce/label/c.Monthly_Report_Title';

import INSPECTION_REPORT_EDIT from '@salesforce/label/c.INSPECTION_REPORT_EDIT';
import PromoterDailyReport_Market_Report from '@salesforce/label/c.PromoterDailyReport_Market_Report';
import PromoterDailyReport_Research_Report from '@salesforce/label/c.PromoterDailyReport_Research_Report';

export default class ResearchReportLwc extends LightningNavigationElement {
    /**
     * 初始化 Research__c 标签
     */
    @track researchInfo = {
        OwnerId: '',
        Name: '',
        Report_Date__c: '',
        Shop__c: '',
        Status__c: '',
    };
    @wire(getObjectInfo, { objectApiName: 'Research__c' })
    wiredResearchInfo({ error, data }) {
        if (data) {
            this.researchInfo = {
                OwnerId: data.fields.OwnerId.label,
                Name: data.fields.Name.label,
                Report_Date__c: data.fields.Report_Date__c.label,
                Shop__c: data.fields.Shop__c.label,
                Status__c: data.fields.Status__c.label,
            }
        } else if (error) {
            console.log(error);
            this.showError('Research__c getInformation error');
        }
    }
    /**
     * 初始化 Promoter_Daily_Report__c 标签
     */
    @track dailyReportInfo = {
        OwnerId: '',
        Name: '',
        Report_Date__c: '',
        Shop__c: '',
        Status__c: '',
    };
    @wire(getObjectInfo, { objectApiName: 'Promoter_Daily_Report__c' })
    wiredDailyReportInfo({ error, data }) {
        if (data) {
            this.dailyReportInfo = {
                OwnerId: data.fields.OwnerId.label,
                Name: data.fields.Name.label,
                Report_Date__c: data.fields.Report_Date__c.label,
                Shop__c: data.fields.Shop__c.label,
                Status__c: data.fields.Status__c.label,
            }
        } else if (error) {
            console.log(error);
            this.showError('Promoter_Daily_Report__c getInformation error');
        }
    }
    /**
     * 初始化 Retail_Number__c 标签
     */
    @track retailNumberInfo = {
        Product__c: '',
        Description__c: '',
        SPIV__c: '',
        Kiosk__c: '',
        Price__c: '',
        Number__c:'',
        StoreDelivery__c:'',
        TotalPrice__c:'',
        HasGift__c:'',
        Gift__c:'',
        GiftQuantity__c:'',
        Comments__c:''
    };
    @wire(getObjectInfo, { objectApiName: 'Retail_Number__c' })
    wiredretailNumberInfo({ error, data }) {
        if (data) {
            this.retailNumberInfo = {
                Product__c: data.fields.Product__c.label,
                Description__c: data.fields.Description__c.label,
                SPIV__c: data.fields.SPIV__c.label,
                Kiosk__c: data.fields.Kiosk__c.label,
                Price__c: data.fields.Price__c.label,
                Number__c: data.fields.Number__c.label,
                StoreDelivery__c: data.fields.StoreDelivery__c.label,
                TotalPrice__c: data.fields.TotalPrice__c.label,
                HasGift__c: data.fields.HasGift__c.label,
                Gift__c: data.fields.Gift__c.label,
                GiftQuantity__c: data.fields.GiftQuantity__c.label,
                Comments__c: data.fields.Comments__c.label,
            }
        } else if (error) {
            console.log(error);
            this.showError('Retail_Number__c getInformation error');
        }
    }
    /**
     * 初始化 GoodsInOut__c 标签
     */
    @track goodsReceivingInfo = {
        ProductModel__c: '',
        Description__c: '',
        Quantities__c: '',
    };
    @wire(getObjectInfo, { objectApiName: 'GoodsInOut__c' })
    wiredGoodsReceivingInfo({ error, data }) {
        if (data) {
            this.goodsReceivingInfo = {
                ProductModel__c: data.fields.ProductModel__c.label,
                Description__c: data.fields.Description__c.label,
                Quantities__c: data.fields.Quantities__c.label,
            }
        } else if (error) {
            console.log(error);
            this.showError('GoodsInOut__c getInformation error');
        }
    }
    /**
     * 初始化 Shop_Retail_Detail__c 标签
     */
    @track intelligenceInfo = {
        Brand__c: '',
        Product__c: '',
        NewProduct__c: '',
        Price__c:'',
        Discount__c:'',
        DiscountPrice__c:'',
        Commission__c:'',
        CampaignType__c:'',
        CampaignDescription__c:''
    };
    @wire(getObjectInfo, { objectApiName: 'Shop_Retail_Detail__c' })
    wiredIntelligenceInfo({ error, data }) {
        if (data) {
            this.intelligenceInfo = {
                Brand__c: data.fields.Brand__c.label,
                Product__c: data.fields.Product__c.label,
                NewProduct__c: data.fields.NewProduct__c.label,
                Price__c:data.fields.Price__c.label,
                Discount__c: data.fields.Discount__c.label,
                DiscountPrice__c: data.fields.DiscountPrice__c.label,
                Commission__c:data.fields.Commission__c.label,
                CampaignType__c: data.fields.CampaignType__c.label,
                CampaignDescription__c: data.fields.CampaignDescription__c.label,
            }
        } else if (error) {
            console.log(error);
            this.showError('Shop_Retail_Detail__c getInformation error');
        }
    }

    label ={
        PromoterDailyReport_OWNER,//owner
        PromoterDailyReport_REPORT_NUMBER,//日报编号
        PromoterDailyReport_DTAE,//日报日期
        PromoterDailyReport_DATE_HELP_TEXT,//日期的help text
        PromoterDailyReport_STORE,//门店
        PromoterDailyReport_NEW,//新建按钮
        PromoterDailyReport_NO,//序号
        PromoterDailyReport_PRODUCT,//产品
        PromoterDailyReport_DESCRIPTION,//描述
        PromoterDailyReport_SPIV,//SPIV
        PromoterDailyReport_KIOSK,//Kiosk
        PromoterDailyReport_UNIT_PRICE,//Unit Price
        PromoterDailyReport_QUANTITY,//数量
        PromoterDailyReportLabel,//促销员日报
        PromoterDailyReport_SAVE,//保存
        PromoterDailyReport_STORE_DELIVERY,//门第运输数量
        PromoterDailyReport_TOTAL,//数量与价格的乘积形成的总价
        PromoterDailyReport_HAS_GIFT,//礼物的展示选择
        PromoterDailyReport_GIFT,//礼物
        PromoterDailyReport_NOT_HAVE_REPORT,//当前门店报告日期无促销员日报
        PromoterDailyReport_GIFT_QUANTITY,//礼物数量
        PromoterDailyReport_COMMENT,//描述
        PromoterDailyReport_DISPLAY_COMPETITIVE,//显示竞品
        PromoterDailyReport_HIDE_COMPETITIVE,//隐藏竞品
        PromoterDailyReport_ATTACHMENT,//附件
        PromoterDailyReport_ACTIONS,//操作
        PromoterDailyReport_NUMBER,//竞品处序号
        PromoterDailyReport_Brands,//品牌
        PromoterDailyReport_NEW_PRODUCT,//新产品
        PromoterDailyReport_NEW_PRODUCT_HELP_TEXT,//新产品的help text
        NewPromoterDailyReport_PRICE,//售价
        PromoterDailyReport_OFF,//折扣百分比
        PromoterDailyReport_OFF_HELP_TEXT,//折扣百分比的help text
        PromoterDailyReport_VALUE_OFF,//折扣金额
        PromoterDailyReport_COMMISSION,//Commission
        PromoterDailyReport_CAMP_TYPE,//Camp. Type
        PromoterDailyReport_CAMP_DES,//Camp. Des.
        PromoterDailyReport_ITEM_ACTION,//子item操作

        PromoterDailyReport_SUBMIT_REPORT,//提交
        PromoterDailyReport_DAILY_SALES,//Daily Sales
        PromoterDailyReport_GOODS_RECEIVING,//Goods Receiving
        PromoterDailyReport_TICKET,//Ticket
        PromoterDailyReport_INTELLIGENCE,//Intelligence

         PromoterDailyReport_STORE_VIEW,//Store view
         PromoterDailyReport_MARKET_INSGHT, 
         PromoterDailyReport_PROMO_COURT, 
         PromoterDailyReport_IN_HOUSE_SHARE, 
         PromoterDailyReport_SHELF_SHARE,
         PromoterDailyReport_Consumer_Trait_Research, 
         PromoterDailyReport_Foot_Count_Inquiry, 
         PromoterDailyReport_Returns_And_Credit,
         PromoterDailyReport_GoodsReceivingError,//goodsreceiving相同提示
         PromoterDailyReport_SubmitReminder,//提交提醒
         PromoterDailyReport_RequiredCheck,//必填验证
         PromoterDailyReport_DeleteReminder,//删除提醒
         PromoterDailyReport_FutureDate,//未来日期提示
         PromoterDailyReport_Spiv_Requied,//spiv确认存在
         PromoterDailyReport_MSG_SUBMIT_REPORT,//是否提交当前日报
         
        INSPECTION_REPORT_EDIT,                 // 修改
        PromoterDailyReport_Market_Report,      // Market Report
        PromoterDailyReport_Research_Report,    // Research Report
     }

    @track activeSections = [];

    @track newTicket = false;
    @track isAllowEdit = false;
    @track reportDate;//前端变更，需考虑日期格式
    @api shopId;//a260l0000016L0nAAE

    @track changeShopId;

    @track status = '已签到签退';
    @track signInTime = '2023-06-12 09:00:00';
    @track signOutTime = '2023-06-12 18:23:00';
    
    @track productPriceList = [];

    @track promoterItem = {};

    lwcName = this.label.PromoterDailyReport_Research_Report;
    @track isShowSpinner
    @api recordId;
    @track hisenseAccId;
    @track isTitleReadOnly = true;
    
    @track itemRespIsSuccess = true;
    @track itemRespErrorMsg = '';

    @track oldReportDate;
    @track oldReportDateShow = true;

    @track record={};
    retailNumber={};
    @track retailNumberList = [];
    ticketList = [];
    @track status;
    @track goodsReceivingList = [];
    @track intelligenceList = [];

    @track retailNumberFilesMap = {};
    @track goodsReceivingFilesMap = {};
    @track intelligenceFilesMap = {};
    @track isShowGoodsReceiving = true;
    @track isShowStoreView = true;
    @track isShowMarketInsight = true;
    @track isShowKiosk = true;
    @track isShowHasGift = true;
    @track isShowStoreDelivery = true;
    @track isShowNewProduct = true;
    @track isShowCampTypeAndDes = true;
    @track isShowPCRF = true;
    @track isShowSPIV  = false;
    @track isShowStockShare =true;
    @track dailySalesLen = 0;
    @track goodsReceivingLen =0;
    @track intelligenceLen = 0;
    @track isSouthAfrica = false;

    @track showNewButton = false;

    @track fieldReadOnly = true;
    @track viewMode = true;
    @track isEditPage = false; 
    get viewStyle(){
        var style = '';
        if(this.viewMode){
            return 'background: unset;cursor: no-drop;border: 0;box-shadow: none;';
        }else if(this.isTitleReadOnly){
            return 'background: unset;cursor: no-drop;border: 0;box-shadow: none;';
        }else if(this.recordDisabled){
            return 'background: unset;cursor: no-drop;border: 0;box-shadow: none;'; 
        }else if(this.fieldReadOnly){
            return 'background: unset;cursor: no-drop;border: 0;box-shadow: none;';
        }
        return style;
    }

    get shopOptions() {
        var options = [];
        if (this.responsiblePersonList) {
            for (let i = 0; i < this.responsiblePersonList.length; i++) {
                var rp = this.responsiblePersonList[i];
                options.push({label: rp.Shop_Name__r.Name, value: rp.Shop_Name__c});
            }
        }
        return options;
    };

    get recordNotNull() {
        return this.recordId != null && this.record.Id != null;
    }

    get recordDisabled() {
        return this.record.Status__c != 'New' || this.record.Id == null;
        // return true;
    }

    get goodsReceivingAgain() {
        var isDisabled = true;
        if (this.goodsReceivingList.length==0) {
            return true;
        }
        for (let i = 0; i < this.goodsReceivingList.length; i++) {
            if (this.goodsReceivingList[i].Status__c == 'New') {
                isDisabled = false;
            }
            
        }
        return isDisabled;
    }

    get submitDisabled() {
        if (this.recordDisabled == false) {
            return false;
        }

        return this.goodsReceivingAgain;

        // return this.recordDisabled && this.goodsReceivingAgain;
    }

    // 取消下拉刷新
    disablePullToRefresh() {
        const disable_ptr_event = new CustomEvent("updateScrollSettings", {
          detail: {
            isPullToRefreshEnabled: false,
          },
          bubbles: true,
          composed: true,
        });
        this.dispatchEvent(disable_ptr_event);
    }

    connectedCallback() {
        // setInterval(()=>{
        //     this.style = FORM_FACTOR == 'Small' ? 'max-height: ' + (document.documentElement.clientHeight - 70) + 'px;' : '';
        // }, 200);

        loadStyle(this, common3);
        this.viewMode = true;
        this.isShowSpinner = true;
        console.log('record>>>>>>>'+JSON.stringify(this.record));
        console.log('recordId>>>>>>>'+JSON.stringify(this.recordId));
        this.disablePullToRefresh();
        judgeCountry().then(data => {
            console.log('进入data.SouthAfrica>>>>>');
            if (data.isSuccess) {
                console.log('data.SouthAfrica111>>>>>'+JSON.stringify(data.data));
                if(data.data.SouthAfrica){
                    this.isSouthAfrica = true;
                    this.isShowGoodsReceiving = false;
                    //this.isShowStoreView = false;
                    //this.isShowMarketInsight = false;
                    this.isShowKiosk = false;
                    this.isShowHasGift = false;
                    this.isShowStoreDelivery = false;
                    this.isShowNewProduct = false;
                    this.isShowCampTypeAndDes = false;
                    this.isShowSpinner = false;

                    this.showWarning(To_New_Page.format(Monthly_Report_Title));
                }else if(data.data.Chile){
                    this.isShowStoreView = false;
                    this.isShowPCRF = false;
                    this.isShowSPIV = false;
                    this.isShowSpinner = false;

                    this.showWarning(To_New_Page.format(Monthly_Report_Title));
                }else if(data.data.Indonesia){
                    this.isShowPCRF = false;
                    //this.isShowStockShare = false;
                    this.isShowSPIV = false;
                    this.isShowKiosk = false;
                    this.isShowCampTypeAndDes = false;
                    this.isShowSpinner = false;

                    this.showWarning(To_New_Page.format(Monthly_Report_Title));
                }       
                
                
                this.isShowSpinner = true;
                getInitData({
                    recordId : this.recordId
                }).then(data => {
                    if (data.isSuccess) {
                        for (let key in data.data) {
                            this[key] = data.data[key];
                        }
                        console.log('data.data>>>>>>>'+JSON.stringify(data.data));

                        // if (this.recordId==null && data.data.record.Id!=null) {
                        //     this.goToRecord(data.data.record.Id);
                        // }

                        // 初始化选择的门店，判断是否为不再负责的门店数据
                        if (data.data.responsiblePersonList) {
                            var filterList = data.data.responsiblePersonList.filter(obj => obj.Shop_Name__c == this.record.Shop__c);
                            if (filterList.length>0) {
                                this.isTitleReadOnly = false;
                            } else {
                                this.responsiblePersonList.push({Shop_Name__c: this.recordShopName.Id, Shop_Name__r: {Name: this.recordShopName.Name}});
                            }
                        }

                        // 存在recordId，有历史数据
                        if (data.data.record.Id) {
                            this.recordId = data.data.record.Id;
                        }
                        // 格式化页面数据
                        if(this.recordId){
                            // 储存旧的ReportDate值
                            this.oldReportDate = data.data.record.Report_Date__c;

                            this.infoDate(data);
                        } else {
                            this.oldReportDate = data.data.todayDate;
                        }
                        this.refreshStyle();
                        
                        if (this.shopId) {
                            this.hasShopId();
                        }
                        this.isShowSpinner = false;
                    } else {
                        this.isShowSpinner = false;
                        this.showError(data.message);
                    }
                }).catch(error => {
                    this.isShowSpinner = false;
                    this.catchError(error);
                })

            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            this.isShowSpinner = false;
            this.catchError(error);
        })

    }
    hasShopId() {
        var currentDate = new Date();
        var year = currentDate.getFullYear();
        var month = ('0' + (currentDate.getMonth() + 1)).slice(-2);
        var day = ('0' + currentDate.getDate()).slice(-2);
        this.record.Report_Date__c = year + '-' + month + '-' + day;
        this.record.Shop__c = this.shopId;
        this.handleRefreshData();
    }
    // 自定义弹框
    @track modalMsg;
    @track modalType;
    @track modalHelper;
    @track modelHelper;
    handleShow(msg, type, hepler,helper2) {
        let ele = this.template.querySelector('c-modal-lwc');
        if (ele!=null) {
            this.modalMsg = msg;
            this.modalType = type;
            this.modalHelper = hepler;
            this.modelHelper = helper2
            ele.showModal(this.template);
        } else {
            console.log('c-modal-lwc is null');
        }
    }
    handleOk() {
        this.template.querySelector('c-modal-lwc').closeModal();
        this[this.modalType](this.modalHelper,this.modelHelper);
    }

    // 信息导入
    infoDate(data) {
        // 零售信息初始化
        let retailList = [];
        if (data.data.retailNumberList) {
            retailList = data.data.retailNumberList;
            if(retailList.length > 0){
                this.retailNumberList = data.data.retailNumberList;
                for (let index = 0; index < this.retailNumberList.length; index++) { 
                    this.retailNumberList[index].Id = this.retailNumberList[index].Id; 
                    console.log('Id>>>>>>'+this.retailNumberList[index].Id);                 
                    this.retailNumberList[index].index = index+1;         
                    console.log('index>>>>>>'+this.retailNumberList[index].index);
                    this.retailNumberList[index].number = index+1;         
                    console.log('number>>>>>>'+this.retailNumberList[index].number);
                    this.retailNumberList[index].files = ['dailySale_'+(index+1)];
                }
            }
            this.dailySalesLen = retailList.length;
        }
        // 入库信息初始化
        let gooodsList = [];
        if (data.data.goodsReceivingList) {
            gooodsList = data.data.goodsReceivingList;
            if(gooodsList.length > 0){
                this.goodsReceivingList = data.data.goodsReceivingList;
                for (let index = 0; index < this.goodsReceivingList.length; index++) { 
                    this.goodsReceivingList[index].Id = this.goodsReceivingList[index].Id; 
                    console.log('Id>>>>>>'+this.goodsReceivingList[index].Id);                 
                    this.goodsReceivingList[index].index = index+1;         
                    console.log('index>>>>>>'+this.goodsReceivingList[index].index);
                    this.goodsReceivingList[index].number = index+1;         
                    console.log('index>>>>>>'+this.goodsReceivingList[index].number);
                    if (this.goodsReceivingList[index].Status__c != 'New') {
                        this.goodsReceivingList[index].disabled = true;
                    } else {
                        this.goodsReceivingList[index].disabled = false;
                    }
                    console.log('disabled>>>>>>'+this.goodsReceivingList[index].disabled);
                    this.status = this.goodsReceivingList[index].Status__c;
                    this.goodsReceivingList[index].files = ['goodsReceiving_'+(index+1)];
                }
            }
            this.goodsReceivingLen = gooodsList.length;
        }
        // 竞品信息初始化
        let intelligenceList = [];
        if (data.data.intelligenceList) {
            let beforeFormat = data.data.intelligenceList;
            console.log(' data.data.intelligenceList>>>>'+JSON.stringify(data.data.intelligenceList));
            if(beforeFormat.length > 0){
                // 主数据配置
                for (let index = 0; index < beforeFormat.length; index++) {
                    var item = beforeFormat[index];
                    if (item.HisenseShopRetailDetail__c==null) {
                        var fileValue = 'intelligence_'+(intelligenceList.length+1)+'_1';
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
                            Item: [item]};
    
                        intelligenceList.push(intelligence);
                    }
                    //this.intelligenceLen = intelligenceList.length;
                }
                // 竞品数据配置
                for (let index = 0; index < beforeFormat.length; index++) {
                    var item = beforeFormat[index];
                    if (item.HisenseShopRetailDetail__c!=null) {
                        var mainDetailList = intelligenceList.filter(obj => obj.Id == item.HisenseShopRetailDetail__c);
                        var mainDetail = mainDetailList[0];
                        
                        var fileValue = 'intelligence_'+mainDetail.index+'_'+(mainDetail.Item.length+1);
                        
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
    
    // 零售信息转JSON前转换
    dailySaleBeforeSave() {
        var inputjson = [];
        for (let i = 0; i < this.retailNumberList.length; i++) {
            var item = this.retailNumberList[i];

            let filesInfo = [];
            if (item.files && Array.isArray(item.files)) {
                filesInfo.push(...item.files);
                delete item['files'];
            }

            var dataInfo = {dailySaleDataInfo: item, filesInfo: filesInfo};
            inputjson.push(dataInfo);
        }
        return inputjson;
    }
    
    // 入库信息转JSON前转换
    goodsReceivingBeforeSave() {
        var inputjson = [];
        for (let i = 0; i < this.goodsReceivingList.length; i++) {
            var item = this.goodsReceivingList[i];

            let filesInfo = [];
            if (item.files && Array.isArray(item.files)) {
                filesInfo.push(...item.files);
                delete item['files'];
            }

            var dataInfo = {goodsReceivingDataInfo: item, filesInfo: filesInfo};
            inputjson.push(dataInfo);
        }
        return inputjson;
    }

    // 竞品信息转JSON前转换
    intelligenceBeforeSave() {
        var intelligenceList = [];
        console.log('竞品信息转JSON前转换:'+JSON.stringify(this.intelligenceList));
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
    
                var dataInfo = {intelligenceDataInfo: info, filesInfo: filesInfo};

                infoList.push(dataInfo);
            }
            intelligenceList.push(infoList);
        }
        return intelligenceList;
    }


    // 更改门店
    handleChangeShopOption(event) {
        console.log(event.detail.value);
        this.record.Shop__c = event.detail.value;
        this.handleRefreshData();
        
        this.refreshStyle();
    }
    //跳转到门店
    handleStore(){
        window.location.href = '/lightning/r/Shop__c/'+ this.record.Shop__c+ '/view';
        //window.open('/lightning/r/Shop__c/'+ this.record.Shop__c+ '/view','_self');
    }

    // 新建按钮click
    handleNew() {
        // this.saveReportCore(false,'new');
        var checkResp = {alltrue: true, msg: ''};
        if (this.checkRequiredPromoterDailyReport().alltrue == false) {
            checkResp = this.checkRequiredPromoterDailyReport();        
        }

        if (checkResp.alltrue == false) {
            this.showWarning(this.label.PromoterDailyReport_RequiredCheck + checkResp.msg);
            this.lwcName = this.label.PromoterDailyReportLabel;
            return;
        }
        
        this.isShowSpinner = true;
        createData({
            recordJson: JSON.stringify(this.record)
        }).then(data => {
            console.log('data.data>>>data>>>'+data.data);
            if (data.isSuccess) {
                for (let key in data.data) {
                    this[key] = data.data[key];
                }
                this.isShowSpinner = false;
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            this.isShowSpinner = false;
            this.catchError(error);
        })
    }
    // 保存按钮click
    handleSave() {

        if (this.checkRepeatGoodsReceiving().alltrue == false) {
            // const result = await LightningConfirm.open({
            //     //message: 'Goods receiving record for this store on '+this.record.Report_Date__c+' has already created, do you still want to submit?',
            //     message:this.label.PromoterDailyReport_GoodsReceivingError.format(this.record.Report_Date__c),
            //     variant: 'headerless',
            //     label: 'This is the aria-label value',
            // });
            // if (!result) {
            //     return;
            // }
            //var isSubmit = true;
            this.handleShow(this.label.PromoterDailyReport_GoodsReceivingError.format(this.record.Report_Date__c),'saveReportCore',true,'submit')
        }

        this.saveReportCore(false,'save');
    }

    // 提交按钮click
    handleSubmit() {
        // const resultSubmit = await LightningConfirm.open({
        //      message:this.label.PromoterDailyReport_MSG_SUBMIT_REPORT,
        //      variant: 'headerless',
        //      label: 'This is the aria-label value',
        //      // label value isn't visible in the headerless variant
        // });
        
        // if (!resultSubmit) {
        //     return;
        // }
        //var isSubmit = true;
        this.handleShow(this.label.PromoterDailyReport_MSG_SUBMIT_REPORT,'handleSubmitCheck',true,'submit')

    }
    handleSubmitCheck(isSubmit,type){
        if (this.checkRepeatGoodsReceiving().alltrue == false) {
            // const result = await LightningConfirm.open({
            //     //message: 'Goods receiving record for this store on '+this.record.Report_Date__c+' has already created, do you still want to submit?',
            //     message:this.label.PromoterDailyReport_GoodsReceivingError.format(this.record.Report_Date__c),
            //     variant: 'headerless',
            //     label: 'This is the aria-label value',
            // });
            // if (!result) {
            //     return;
            // }
            this.handleShow(this.label.PromoterDailyReport_GoodsReceivingError.format(this.record.Report_Date__c),'saveReportCore',true,'submit')
        }else{
            console.log('零售业绩的列表长度:'+this.retailNumberList.length);
            if(this.retailNumberList.length == 0){
        
                // const result = await LightningConfirm.open({
                //      //message: 'Are you sure submit the report? You are not currently submitting Daily Sales',
                //      message:this.label.PromoterDailyReport_SubmitReminder,
                //      variant: 'headerless',
                //      label: 'This is the aria-label value',
                //      // label value isn't visible in the headerless variant
                // });
                // console.log('result>>>>>>>>'+result)
                
                // if (result) {
                //     this.saveReportCore(true,'submit');
                // }
                this.handleShow(this.label.PromoterDailyReport_SubmitReminder,'saveReportCore',true,'submit')
            } else {
                this.saveReportCore(true,'submit');
                //  if(this.judgementDailySalesSpiv() == true){
                //     this.saveReportCore(true,'submit');
                //  }else{
                //     this.showError(this.label.PromoterDailyReport_Spiv_Requied);
                //  }
            }
        }
    

    }

    //判断南非DailySales的Spiv是否符合要求（不合法不能提交）
    // judgementDailySalesSpiv(){
    //     if(this.isSouthAfrica){
    //         var flag = false;
    //         this.retailNumberList.forEach(dailySales => {
    //             if(dailySales.SPIV__c == 0 && dailySales.Number__c > 0 ){
    //                 flag = true;
    //             }
    //         });
    //         if(flag){
    //             return false;
    //         }else{
    //             return true;
    //         }  
    //     }else{
    //         return true;
    //     }
    // }

    saveReportCore(isSubmit, type) {
        console.log('isSubmit----------'+isSubmit);
        console.log('type------------'+type);
        console.log('this.checkRequiredPromoterDailyReport()'+this.checkRequiredPromoterDailyReport())
        console.log('this.checkRequiredDailySale()'+this.checkRequiredDailySale())
        console.log('this.checkRequiredGoodsReceiving()'+this.checkRequiredGoodsReceiving())
        console.log('this.checkRequiredIntelligence()'+this.checkRequiredIntelligence())
        
        var checkResp = {alltrue: true, msg: ''};
        if (this.checkRequiredPromoterDailyReport().alltrue == false) {
            checkResp = this.checkRequiredPromoterDailyReport();
        } else if (this.checkRequiredDailySale().alltrue == false) {
            checkResp = this.checkRequiredDailySale();
        } else if (this.checkRequiredGoodsReceiving().alltrue == false) {
            checkResp = this.checkRequiredGoodsReceiving();
        } else if (this.checkRequiredIntelligence().alltrue == false) {
            checkResp = this.checkRequiredIntelligence();
        }

        if (checkResp.alltrue == false) {
            this.showError(this.label.PromoterDailyReport_RequiredCheck + checkResp.msg);
            return;
        }

        if (type!='new') {
            var errorMsg = '';
            if (this.storeViewCheckData()!='') {
                errorMsg = this.storeViewCheckData();
            } else if (this.marketInsightCheckData()!='') {
                errorMsg = this.marketInsightCheckData();
            } else if (this.promoCourtCheckData()!='') {
                errorMsg = this.promoCourtCheckData();
            } else if (this.inHouseShareCheckData()!='') {
                errorMsg = this.inHouseShareCheckData();
            } else if (this.shelfShareCheckData()!='') {
                errorMsg = this.shelfShareCheckData();
            } else if (this.consumerTraitResearchCheckData()!='') {
                errorMsg = this.consumerTraitResearchCheckData();
                this.lwcName = PromoterDailyReport_ITEM_ACTION;
                this.lwcName = this.label.PromoterDailyReport_Consumer_Trait_Research;
            } else if (this.returnsAndCreditCheckData()!='') {
                errorMsg = this.returnsAndCreditCheckData();
                this.lwcName = this.label.PromoterDailyReport_Returns_And_Credit;
            } else if (this.footCountInquiryCheckData()!='') {
                this.lwcName = PromoterDailyReport_Foot_Count_Inquiry;
                errorMsg = this.footCountInquiryCheckData();
                this.lwcName = this.label.PromoterDailyReport_Foot_Count_Inquiry;
            }

            if (errorMsg != '') {
                this.showWarning(errorMsg);
                this.lwcName = PromoterDailyReport_Market_Report;
                return;
            }
        }
        var reportDate = new Date(this.record.Report_Date__c);
        var today = new Date(this.todayDate);
        if (reportDate>today) {
            this.showError(this.label.PromoterDailyReport_FutureDate);
            return;
        }

        

        this.isShowSpinner = true;
        console.log('record>'+JSON.stringify(this.record));
        console.log('retailNumberJson'+JSON.stringify(this.retailNumberList));
        console.log('goodsReceivingJson'+JSON.stringify(this.goodsReceivingList));
        console.log('intelligenceJson保存'+JSON.stringify(this.intelligenceList));
        console.log('retailNumberFilesMapJson'+JSON.stringify(this.retailNumberFilesMap));
        console.log('goodsReceivingFilesMapJson'+JSON.stringify(this.goodsReceivingFilesMap));
        console.log('intelligenceFilesMapJson'+JSON.stringify(this.intelligenceFilesMap));
        // if(this.record.Id == null || this.record.Id == ''){
        //     this.record.Status__c = '';
        // }
        // console.log('recordJson status'+JSON.stringify(this.record.Status__c));

        // 保存信息需要整理
        var retailNumberJson = this.dailySaleBeforeSave();
        var goodsReceivingJson = this.goodsReceivingBeforeSave();
        var intelligenceJson = this.intelligenceBeforeSave();
        
        this.itemRespIsSuccess = true;
        this.itemRespErrorMsg = '';
        saveData({
            recordJson: JSON.stringify(this.record),
            retailNumberJson: JSON.stringify(retailNumberJson),
            goodsReceivingJson: JSON.stringify(goodsReceivingJson),
            intelligenceJson: JSON.stringify(intelligenceJson),
            isSubmit: isSubmit,
            retailNumberFilesMapJson: JSON.stringify(this.retailNumberFilesMap),
            goodsReceivingFilesMapJson: JSON.stringify(this.goodsReceivingFilesMap),
            intelligenceFilesMapJson: JSON.stringify(this.intelligenceFilesMap)
        }).then(data => {
            if (data.isSuccess) {
                console.log('data.data>>>data>>>'+data.data);
                for (let key in data.data) {
                    this[key] = data.data[key];
                }

                console.log('data.data>>>>>>>'+JSON.stringify(data.data));

                if (data.data.record && data.data.record.Id) {
                    this.recordId = data.data.record.Id;
                } else {
                    this.recordId = null;
                    this.record.Id = null;
                }

                if(this.recordId && type != 'new'){

                    this.infoDate(data);
                }
                // this.isShowSpinner = false;
                // console.log('保存信息提示>>>>');
                // this.showSuccess('success');
                // this.goToRecord(data.data);

            } else {
                // this.isShowSpinner = false;
                //  this.showError(data.message);
            }

            
            //if (!data) {
                this.itemRespIsSuccess = data.isSuccess;
                this.itemRespErrorMsg += ' ' + data.message;
            //}

            // 调用链
            // 主数据（daily sales、Goods Receiving、Intelligence） → 
            // Ticket → 
            // store view → 
            // marketInsight → 
            // promoCourt → 
            // inHouseShare → 
            // shelfShare → 
            // Consumer Trait Research → 
            // Returns And Credit →
            // Foot Count Inquiry
            if (type != 'new') {
                this.saveTickets();
            } else {
                if (this.itemRespIsSuccess) {
                    this.showSuccess('success');
                } else {
                    this.showError(this.itemRespErrorMsg);
                }
            }
            this.isShowSpinner = false;
            
            this.refreshStyle();

        }).catch(error => {
            this.isShowSpinner = false;
            this.catchError(error);
        })
    }

    // 零售保存
    dailySaleSave() {
        // if (!this.checkRequiredPromoterDailyReport() || 
        //     !this.checkRequiredDailySale()) {
        //     this.showError('Required information haven’t been maintained. Please fulfil required information first.');
        //     return;
        // }
        var checkResp = {alltrue: true, msg: ''};
        if (this.checkRequiredPromoterDailyReport().alltrue == false) {
            checkResp = this.checkRequiredPromoterDailyReport();
        } else if (this.checkRequiredDailySale().alltrue == false) {
            checkResp = this.checkRequiredDailySale();
        }

        if (checkResp.alltrue == false) {
            this.showError(this.label.PromoterDailyReport_RequiredCheck + checkResp.msg);
            return;
        }
        this.isShowSpinner = true;

        // var inputjson = [];
        // for (let i = 0; i < this.retailNumberList.length; i++) {
        //     var item = this.retailNumberList[i];

        //     let filesInfo = [];
        //     filesInfo.push(...item.files);
        //     delete item['files'];

        //     var dataInfo = {dailySaleDataInfo: item, filesInfo: filesInfo};
        //     inputjson.push(dataInfo);
        // }
        var inputjson = this.dailySaleBeforeSave();
        console.log('inputjson--->'+JSON.stringify(inputjson));

        saveDailySalesData({
            recordJson : JSON.stringify(this.record),
            // retailNumberJson: JSON.stringify(this.retailNumberList)
            retailNumberJson: JSON.stringify(inputjson)
        }).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    this[key] = data.data[key];
                }
                console.log('data.data>>>>>>>'+JSON.stringify(data.data));

                this.infoDate(data);

                this.isShowSpinner = false;
                this.showSuccess('success');
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            this.isShowSpinner = false;
            this.catchError(error);
        })
    }

    // 入库保存
    goodsReceivingSave() {
        // if (!this.checkRequiredPromoterDailyReport() || 
        //     !this.checkRequiredGoodsReceiving()) {
        //     this.showError('Required information haven’t been maintained. Please fulfil required information first.');
        //     return;
        // }
        var checkResp = {alltrue: true, msg: ''};
        if (this.checkRequiredPromoterDailyReport().alltrue == false) {
            checkResp = this.checkRequiredPromoterDailyReport();
        } else if (this.checkRequiredGoodsReceiving().alltrue == false) {
            checkResp = this.checkRequiredGoodsReceiving();
        }

        if (checkResp.alltrue == false) {
            this.showError(this.label.PromoterDailyReport_RequiredCheck + checkResp.msg);
            return;
        }
        this.isShowSpinner = true;

        // var inputjson = [];
        // for (let i = 0; i < this.goodsReceivingList.length; i++) {
        //     var item = this.goodsReceivingList[i];

        //     let filesInfo = [];
        //     filesInfo.push(...item.files);
        //     delete item['files'];

        //     var dataInfo = {goodsReceivingDataInfo: item, filesInfo: filesInfo};
        //     inputjson.push(dataInfo);
        // }
        var inputjson = this.goodsReceivingBeforeSave();
        console.log('inputjson--->'+JSON.stringify(inputjson));

        saveGoodsReceivingData({
            recordJson : JSON.stringify(this.record),
            goodsReceivingJson: JSON.stringify(inputjson)
        }).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    this[key] = data.data[key];
                }
                console.log('data.data>>>>>>>'+JSON.stringify(data.data));

                this.infoDate(data);

                this.isShowSpinner = false;
                this.showSuccess('success');
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            this.isShowSpinner = false;
            this.catchError(error);
        })
    }

    // 竞品保存
    intelligenceSave() {
        // if (!this.checkRequiredPromoterDailyReport() || 
        //     !this.checkRequiredIntelligence()) {
        //     this.showError('Required information haven’t been maintained. Please fulfil required information first.');
        //     return;
        // }
        var checkResp = {alltrue: true, msg: ''};
        if (this.checkRequiredPromoterDailyReport().alltrue == false) {
            checkResp = this.checkRequiredPromoterDailyReport();
        } else if (this.checkRequiredIntelligence().alltrue == false) {
            checkResp = this.checkRequiredIntelligence();
        }

        if (checkResp.alltrue == false) {
            this.showError(this.label.PromoterDailyReport_RequiredCheck + checkResp.msg);
            return;
        }

        this.isShowSpinner = true;

        // 竞品数据需要整理
        // var intelligenceList = [];
        // for (let i = 0; i < this.intelligenceList.length; i++) {
        //     var intelligenceItem = this.intelligenceList[i].Item;
        //     var infoList = [];
        //     for (let j = 0; j < intelligenceItem.length; j++) {
        //         var info = this.intelligenceList[i].Item[j];

        //         let filesInfo = [];
        //         filesInfo.push(...info.files);
        //         delete info['files'];
    
        //         var dataInfo = {intelligenceDataInfo: info, filesInfo: filesInfo};

        //         infoList.push(dataInfo);
        //     }
        //     intelligenceList.push(infoList);
        // }
        var intelligenceList = this.intelligenceBeforeSave();
        console.log('intelligenceList'+JSON.stringify(intelligenceList));
        saveIntelligenceData({
            recordJson : JSON.stringify(this.record),
            intelligenceJson: JSON.stringify(intelligenceList)
        }).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    this[key] = data.data[key];
                }
                console.log('data.data>>>>>>>'+JSON.stringify(data.data));

                this.infoDate(data);

                this.isShowSpinner = false;
                this.showSuccess('success');
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            this.isShowSpinner = false;
            this.catchError(error);
        })
    }
    
    // 检查必填字段
    // 日报必填字段
    checkRequiredPromoterDailyReport() {

        if (this.record.Shop__c == null || this.record.Shop__c == '') {
            return {alltrue: false, msg: '- Date'};
        } else if (this.record.Report_Date__c==null || this.record.Report_Date__c=='') {
            return {alltrue: false, msg: '- Store'};
        } else {
            return {alltrue: true, msg: ''};
        }
        // if (this.record.Shop__c == null || this.record.Shop__c == '' || 
        //     this.record.Report_Date__c==null || this.record.Report_Date__c=='') {
        //     return {alltrue: false, msg: 'Store'};
        // } else {
        //     return true;
        // }
    }
    
    // 零售必填字段
    checkRequiredDailySale () {
        // var alltrue = true;
        // if (this.retailNumberList && this.retailNumberList.length>0) {
        //     console.log('进入零售字段验证：');
        //     for (let i = 0; i < this.retailNumberList.length; i++) {
        //         var retailNumber = this.retailNumberList[i];
        //         if (retailNumber.Product__c == null || retailNumber.Product__c == '' || 
        //             //retailNumber.NewProduct__c == null || retailNumber.NewProduct__c == '' || 
        //             retailNumber.Price__c == null || retailNumber.Price__c == '' || 
        //             retailNumber.Number__c == null || retailNumber.Number__c == '' || 
        //             retailNumber.StoreDelivery__c == null || retailNumber.StoreDelivery__c == '' ||
        //             (retailNumber.HasGift__c == true && (retailNumber.Gift__c == null || retailNumber.Gift__c == '')) || 
        //             (retailNumber.HasGift__c == true && (retailNumber.GiftQuantity__c == null || retailNumber.GiftQuantity__c == ''))) {

        //             alltrue = false;
        //             return alltrue;
        //         }
        //     }
        // }

        // return alltrue;
        var resp = {alltrue: true, msg: ''};
        if (this.retailNumberList && this.retailNumberList.length>0) {
            for (let i = 0; i < this.retailNumberList.length; i++) {
                var retailNumber = this.retailNumberList[i];

                if (retailNumber.Product__c == null || retailNumber.Product__c == '') {
                    resp.alltrue = false;
                    resp.msg = 'Product';
                    return resp;
                } else if (retailNumber.Price__c == null || retailNumber.Price__c == '') {
                    resp.alltrue = false;
                    resp.msg = 'Unit Price';
                    return resp;
                } else if (retailNumber.Number__c == null || retailNumber.Number__c == '') {
                    resp.alltrue = false;
                    resp.msg = 'Quantity';
                    return resp;
                } else if ((retailNumber.StoreDelivery__c == null || (retailNumber.StoreDelivery__c === '')) && this.isShowStoreDelivery) {
                    resp.alltrue = false;
                    resp.msg = 'Store Delivery';
                    return resp;
                } else if (retailNumber.HasGift__c == true && (retailNumber.Gift__c == null || retailNumber.Gift__c == '')) {
                    resp.alltrue = false;
                    resp.msg = 'Gift';
                    return resp;
                } else if (retailNumber.HasGift__c == true && (retailNumber.GiftQuantity__c == null || retailNumber.GiftQuantity__c == '')) {
                    resp.alltrue = false;
                    resp.msg = 'Gift Quantity';
                    return resp;
                }
            }
        }
        return resp;
    }

    // 入库必填字段
    checkRequiredGoodsReceiving () {
        // var alltrue = true;
        // console.log('goodsReceivingList======>'+JSON.stringify(this.goodsReceivingList));
        // console.log('this.goodsReceivingList.length'+this.goodsReceivingList.length);
        // if (this.goodsReceivingList && this.goodsReceivingList.length>0) {
        //     console.log('进入入库必填字段验证：');
        //     for (let i = 0; i < this.goodsReceivingList.length; i++) {
        //         var goodsReceiving = this.goodsReceivingList[i];
        //         console.log('this.goodsReceivingList.ProductModel__c'+goodsReceiving.ProductModel__c);
        //         console.log('this.goodsReceivingList.Quantities__c'+goodsReceiving.Quantities__c);
        //         if (goodsReceiving.ProductModel__c == null || goodsReceiving.ProductModel__c == '' || 
        //             goodsReceiving.Quantities__c == null || goodsReceiving.Quantities__c == '') {

        //             alltrue = false;
        //             return alltrue;
        //         }
        //     }
        // }

        // return alltrue;
        var resp = {alltrue: true, msg: ''};
        if (this.goodsReceivingList && this.goodsReceivingList.length>0) {
            for (let i = 0; i < this.goodsReceivingList.length; i++) {
                var goodsReceiving = this.goodsReceivingList[i];

                if (goodsReceiving.ProductModel__c == null || goodsReceiving.ProductModel__c == '') {
                    resp.alltrue = false;
                    resp.msg = 'Product';
                    return resp;
                } else if (goodsReceiving.Quantities__c == null || goodsReceiving.Quantities__c == '') {
                    resp.alltrue = false;
                    resp.msg = 'Quantity';
                    return resp;
                }
            }
        }
        return resp;
    }

    // 竞品必填字段
    checkRequiredIntelligence() {
        // var alltrue = true;
        // if (this.intelligenceList && this.intelligenceList.length>0) {
        //     console.log('进入竞品必填字段验证：');
        //     for (let i = 0; i < this.intelligenceList.length; i++) {
        //         console.log('进入竞品必填字段验证：intelligenceList'+JSON.stringify(this.intelligenceList));
        //         var intelligence = this.intelligenceList[i].Item;
        //         console.log('进入竞品必填字段验证：intelligence'+JSON.stringify(intelligence));

        //         for (let j = 0; j < intelligence.length; j++) {
        //             var info = this.intelligenceList[i].Item[j];

        //             console.log('进入竞品必填字段验证：item.Brand__c'+info.Brand__c);
        //             console.log('进入竞品必填字段验证：item.Product__c'+info.Product__c);
        //             // if(info.Brand__c == this.hisenseAccId){
        //             if(j == 0){
        //                 if (info.Brand__c == null || info.Brand__c == '' ||
        //                     info.Product__c == null || info.Product__c == '' || 
        //                     info.NewProduct__c == null || info.NewProduct__c == '') {

        //                     alltrue = false;
        //                     return alltrue;
        //                 }
        //            }else{
        //                 if (info.Brand__c == null || info.Brand__c == '' ||
        //                     info.ProductInformation__c == null || info.ProductInformation__c == '' || 
        //                     info.NewProduct__c == null || info.NewProduct__c == '') {

        //                     alltrue = false;
        //                     return alltrue;
        //                 }
        //            }
                    
        //         }
        //     }
        // }

        // return alltrue;
        var resp = {alltrue: true, msg: ''};
        if (this.intelligenceList && this.intelligenceList.length>0) {
            for (let i = 0; i < this.intelligenceList.length; i++) {
                var intelligence = this.intelligenceList[i].Item;

                for (let j = 0; j < intelligence.length; j++) {
                    var info = this.intelligenceList[i].Item[j];

                    if(j == 0){
                        if (info.Product__c == null || info.Product__c == '') {
                            resp.alltrue = false;
                            resp.msg = 'Product';
                            return resp;
                        }
                   }else{
                        if (info.ProductInformation__c == null || info.ProductInformation__c == '') {
                            resp.alltrue = false;
                            resp.msg = 'Product';
                            return resp;
                        } 
                   }
                   if (info.Brand__c == null || info.Brand__c == '') {
                       resp.alltrue = false;
                       resp.msg = 'Brand';
                       return resp;
                   } else if (info.NewProduct__c == null || info.NewProduct__c == '') {
                       resp.alltrue = false;
                       resp.msg = 'New Product';
                       return resp;
                   }
                }
            }
        }
        return resp;
    }

    // 检查重复的入库产品
    checkRepeatGoodsReceiving() {
        var resp = {alltrue: true, msg: ''};
        var productList = [];
        if (this.goodsReceivingList && this.goodsReceivingList.length>0) {
            for (let i = 0; i < this.goodsReceivingList.length; i++) {
                var goodsReceiving = this.goodsReceivingList[i];

                if (productList.includes(goodsReceiving.ProductModel__c)) {
                    resp.alltrue = false;
                    resp.msg = goodsReceiving.ProductModel__c;
                    return resp;
                } else {
                    productList.push(goodsReceiving.ProductModel__c);
                }
            }
        }
        return resp;
    }
    // 刷新页面信息
    handleRefreshData() {
        this.isShowSpinner = true;
        console.log('record>'+JSON.stringify(this.record));
        refreshData({
            reportDate : this.record.Report_Date__c,
            ShopId : this.record.Shop__c,
        }).then(data => {
            if (data.isSuccess) {
                for (let key in data.data) {
                    this[key] = data.data[key];
                }
                console.log('data.data>>>>>>>'+JSON.stringify(data.data));

                if (data.data.record && data.data.record.Id) {
                    // this.recordId = data.data.record.Id;
                    this.goToComponent('c__LWCWrapper',{
                        'lwcName' : 'ResearchReportLwc',
                        'recordId' : data.data.record.Id
                    });
                    return;
                } else {
                    this.recordId = null;
                    this.record.Id = null;
                    this.record.Status__c = 'New';
                }

                if(this.recordId){

                    this.infoDate(data);
                }
                
                this.refreshStyle();
                this.isShowSpinner = false;
            } else {
                this.isShowSpinner = false;
                this.showError(data.message);
            }
        }).catch(error => {
            this.isShowSpinner = false;
            this.catchError(error);
        })

    }
    // 日期 && 门店 专用onchange 
    handleReportChange(event) {
        console.log('event.target.fieldName'+event.target.fieldName);
        console.log('event.target.value'+event.target.value);

        // if (!this.checkRequiredPromoterDailyReport() || event.target.value==null || event.target.value=='') {
        //     this.showError('Required information haven’t been maintained. Please fulfil required information first.');
        //     return;
        // }

        if (event.target.fieldName == 'Report_Date__c') {
            console.log('event.target.fieldName'+event.target.fieldName);

            var reportDate = new Date(event.target.value);
            var today = new Date(this.todayDate);
            if (reportDate>today) {
                this.record.Report_Date__c = this.oldReportDate;
                if (this.oldReportDateShow) {
                    this.oldReportDateShow = false;
                } else {
                    this.oldReportDateShow = true;
                }
                // event.target.value = this.oldReportDate;
                this.showError(this.label.PromoterDailyReport_FutureDate);
                return;
            } else {
                this.oldReportDate = event.target.value;
                this.record[event.target.fieldName] = event.target.value;
                // this.record[event.target.fieldName] = event.target.value;
                // this.oldReportDate = this.record.Report_Date__c;
            }
        } else {
            this.record[event.target.fieldName] = event.target.value;
        }
        // this.record[event.target.fieldName] = event.target.value;

        this.handleRefreshData();
    }
    handleReportChange1(event) {
        let index = event.target.dataset.recordid;
        console.log('index==========>'+index);
        console.log('event.target.dataset.fieldName'+event.target.dataset.fieldName);
        this.retailNumberList[index][event.target.dataset.fieldName] = event.target.value;
        console.log('event.target.value'+event.target.value);
        
        this.refreshStyle();
    }
    handleReportChange2(event) {
        let index = event.target.dataset.recordid;
        this.retailNumberList[index][event.target.fieldName] = event.target.value;
        if(event.target.fieldName == 'Product__c'){
            //如果修改product，重置spiv
            this.retailNumberList[index].SPIV__c = 0;

            let product = event.target.value;
            autoShowProductDes({ product :product
            }).then(data => {
                if(data.isSuccess){
                    console.log('product信息：'+JSON.stringify(data.data));
                    this.retailNumberList[index].Description__c = data.data;
                    console.log('产品信息'+JSON.stringify(this.retailNumberList[index].Description__c));
                }                             
            })            
        }
        if(event.target.fieldName == 'Number__c'){
            getProductSpiv({
                product :this.retailNumberList[index].Product__c
            }).then(data => {
                if(data.isSuccess){
                    console.log('product提成信息：'+JSON.stringify(data.data));
                    console.log('看weiwiewiewwii');
                    console.log('看看：'+JSON.stringify(this.retailNumberList[index].Number__c));
                    this.retailNumberList[index].SPIV__c = data.data * this.retailNumberList[index].Number__c;
                    console.log('零售信息总提成信息'+JSON.stringify(this.retailNumberList[index].SPIV__c));
                }
            })
        }
        var price = this.retailNumberList[index].Price__c;
        var quantity = this.retailNumberList[index].Number__c;
        if(event.target.fieldName == 'Price__c'){
            if(price == null || price=='' || quantity == null || quantity == ''){
                this.retailNumberList[index].TotalPrice__c = '-';
            }else {
                this.retailNumberList[index].TotalPrice__c = this.retailNumberList[index].Price__c * this.retailNumberList[index].Number__c;
            }
        }else if(event.target.fieldName == 'Number__c'){
            if(price == null || price=='' || quantity == null || quantity == ''){
                this.retailNumberList[index].TotalPrice__c = '-';
            }else {
                this.retailNumberList[index].TotalPrice__c = this.retailNumberList[index].Price__c * this.retailNumberList[index].Number__c;
            }
        }

        console.log('TotalPrice__c'+this.retailNumberList[index].TotalPrice__c);
        console.log('event.target.value'+event.target.value);

        this.refreshStyle();
    }
    handleGiftChange(event) {
        let index = event.target.dataset.recordid;
        this.retailNumberList[index].HasGift__c = event.target.checked;
        console.log('HasGift__c.checked>'+event.target.checked);
        
        this.refreshStyle();
    }
    handleKioskChange(event) {
        let index = event.target.dataset.recordid;
        this.retailNumberList[index].Kiosk__c = event.target.checked;
        console.log('Kiosk__c.checked>'+event.target.checked);
        
        this.refreshStyle();
    }
    handleGoodsReceivingChange1(event) {
        let index = event.target.dataset.recordid;
        console.log('index==========>'+index);
        console.log('event.target.dataset.fieldName'+event.target.dataset.fieldName);
        this.goodsReceivingList[index][event.target.dataset.fieldName] = event.target.value;
        console.log('event.target.value'+event.target.value);
        
        this.refreshStyle();
    }
    handleGoodsReceivingChange2(event) {
        let index = event.target.dataset.recordid;
        this.goodsReceivingList[index][event.target.fieldName] = event.target.value;
        if(event.target.fieldName == 'ProductModel__c'){
            let product = event.target.value;
            autoShowProductDes({ product :product
            }).then(data => {
                if(data.isSuccess){
                    console.log('gift product信息：'+JSON.stringify(data.data));
                    this.goodsReceivingList[index].Description__c = data.data;
                    console.log('gift 产品信息'+JSON.stringify(this.goodsReceivingList[index].Description__c));
                }                             
            })
        }
        console.log('event.target.value'+event.target.value);
        
        this.refreshStyle();
    }

//     /**-----------------Button function---------------*/
    handleSectionToggle(event) {
        console.log(event.detail.openSections);
        let openSections = event.detail.openSections;
        let sections = this.template.querySelectorAll(
            "lightning-accordion-section"
        );
        console.log('openSections>>>>>>>'+openSections);
        console.log('sections>>>>>>>'+sections);
        this.activeSections = [];      
        sections.forEach((section) => {
            if(openSections.indexOf(section.name) > -1){
                // if(this.noPerformance && section.name == 'retailSale'){
                //     console.log(this.noPerformance);
                // }else {
                    this.activeSections.push(section.name);
                //}
            }  
        });
        
        this.refreshStyle();
    }
    // Ticket
    saveTickets(event) {
        if (this.template.querySelector('c-new-tickets-lwc2')!=null) {
            this.template.querySelector('c-new-tickets-lwc2').saveData();
        } else {
            this.storeViewSaveButton();
        }
    }

    addTicket(event) {
        this.template.querySelector('c-new-tickets-lwc2').addTicket();
        this.refreshStyle();
        this.activeSections = ['ticket']; 
        
    }
    
    ticketSaveData(resp) {
        if (!resp.detail.result.isSuccess) {
            this.itemRespIsSuccess = resp.detail.result.isSuccess;
            this.itemRespErrorMsg += ' ' + resp.detail.result.message;
        }
        this.storeViewSaveButton();
    }

    // ticketCheckData(result) {
    //     console.log(result);
    // }

    //store view 
    storeViewSaveButton(){
        let ele = this.template.querySelector('c-store-view-lwc');
        if (ele!=null) {
            ele.saveData();
        } else {
            this.marketInsightSaveButton();
        }
    }

    addStoreViewItem() {
        let ele = this.template.querySelector('c-store-view-lwc');
        ele.addStoreViewItem();
        this.refreshStyle();
        this.activeSections = ['storeView']; 
        
    }

    storeViewSaveData(resp){
        if (!resp.detail.result.isSuccess) {
            this.itemRespIsSuccess = resp.detail.result.isSuccess;
            this.itemRespErrorMsg += ' ' + resp.detail.result.message;
        }
        this.marketInsightSaveButton();
    }

    storeViewCheckData() {
        let ele = this.template.querySelector('c-store-view-lwc');
        if(ele == null || ele == ''){
            return '';
        }else{
            return ele.checkData();
        }
        
        
    }

    // marketInsight
    marketInsightSaveButton(){
        let ele = this.template.querySelector('c-market-insight-lwc');
        if (ele!=null) {
            ele.saveData();
        } else {
            this.promoCourtSaveButton();
        }
    }

    addMarketInsightItem() {
        let ele = this.template.querySelector('c-market-insight-lwc');
        ele.itemAddHandler();
        this.refreshStyle();
        this.activeSections = ['marketInsght']; 
        
    }

    marketInsightSaveData(resp){
        if (!resp.detail.result.isSuccess) {
            this.itemRespIsSuccess = resp.detail.result.isSuccess;
            this.itemRespErrorMsg += ' ' + resp.detail.result.message;
        }
        this.promoCourtSaveButton();
    }

    marketInsightCheckData() {
        let ele = this.template.querySelector('c-market-insight-lwc');
        if(ele == null || ele == ''){
            return '';
        }else{
            return ele.checkData();
        }
        //return ele.checkData();
    }

    // promoCourt
    promoCourtSaveButton(){
        let ele = this.template.querySelector('c-promo-court-lwc');
        if (ele!=null) {
            ele.saveData();
        } else {
            this.inHouseShareSaveButton();
        }
    }

    addPromoCourtItem() {
        let ele = this.template.querySelector('c-promo-court-lwc');
        ele.itemAddHandler();
        this.refreshStyle();
        this.activeSections = ['promoCourt']; 
        
    }

    promoCourtSaveData(resp){
        if (!resp.detail.result.isSuccess) {
            this.itemRespIsSuccess = resp.detail.result.isSuccess;
            this.itemRespErrorMsg += ' ' + resp.detail.result.message;
        }
        this.inHouseShareSaveButton();
    }

    promoCourtCheckData() {
        let ele = this.template.querySelector('c-promo-court-lwc');
        if(ele == null || ele == ''){
            return '';
        }else{
            return ele.checkData();
        }
        //return ele.checkData();
    }

    // inHouseShare
    inHouseShareSaveButton(){
        let ele = this.template.querySelector('c-in-house-share-lwc');
        if (ele!=null) {
            ele.saveData();
        } else {
            this.shelfShareSaveButton();
        }
    }

    addInHouseShareItem() {
        let ele = this.template.querySelector('c-in-house-share-lwc');
        ele.itemAddHandler();
        this.refreshStyle();
        this.activeSections = ['inHouseShare']; 
        
    }

    inHouseShareSaveData(resp){
        if (!resp.detail.result.isSuccess) {
            this.itemRespIsSuccess = resp.detail.result.isSuccess;
            this.itemRespErrorMsg += ' ' + resp.detail.result.message;
        }
        this.shelfShareSaveButton();
    }

    inHouseShareCheckData() {
        let ele = this.template.querySelector('c-in-house-share-lwc');
        if(ele == null){
            return '';
        }else{
            return ele.checkData();
        }
    }

    // shelfShare
    shelfShareSaveButton(){
        let ele = this.template.querySelector('c-shelf-share-lwc');
        if (ele!=null) {
            ele.saveData();
        } else {
            this.consumerTraitResearchSaveButton();
        }
    }

    addShelfShareItem() {
        let ele = this.template.querySelector('c-shelf-share-lwc');
        ele.itemAddHandler();
        this.refreshStyle();
        this.activeSections = ['shelfShare']; 
        
    }

    shelfShareSaveData(resp){
        if (!resp.detail.result.isSuccess) {
            this.itemRespIsSuccess = resp.detail.result.isSuccess;
            this.itemRespErrorMsg += ' ' + resp.detail.result.message;
        }

        this.consumerTraitResearchSaveButton();
    }

    shelfShareCheckData() {
        let ele = this.template.querySelector('c-shelf-share-lwc');
        if(ele == null){
            return '';
        }else{
            return ele.checkData();
        }
    }

    // Consumer Trait Research
    consumerTraitResearchSaveButton() {
        let ele = this.template.querySelector('c-consumer-trait-research-lwc');
        if (ele!=null) {
            ele.saveData();
        } else {
            this.returnsAndCreditSaveButton();
        }
    }

    addConsumerTraitResearchItem() {
        let ele = this.template.querySelector('c-consumer-trait-research-lwc');
        ele.itemAddHandler();
        this.activeSections = ['consumerTraitResearch'];
    }

    consumerTraitResearchSaveData(resp){
        if (!resp.detail.result.isSuccess) {
            this.itemRespIsSuccess = resp.detail.result.isSuccess;
            this.itemRespErrorMsg += ' ' + resp.detail.result.message;
        }
        this.returnsAndCreditSaveButton();
    }

    consumerTraitResearchCheckData() {
        let ele = this.template.querySelector('c-consumer-trait-research-lwc');
        if(ele == null){
            return '';
        }else{
            return ele.checkData();
        }
    }

    // Returns And Credit
    returnsAndCreditSaveButton() {
        let ele = this.template.querySelector('c-returns-and-credit-lwc');
        if (ele!=null) {
            ele.saveData();
        } else {
            this.footCountInquirySaveButton();
        }
    }

    addReturnsAndCreditItem() {
        let ele = this.template.querySelector('c-returns-and-credit-lwc');
        ele.itemAddHandler();
        this.activeSections = ['returnsAndCredit'];
    }

    returnsAndCreditSaveData(resp){
        if (!resp.detail.result.isSuccess) {
            this.itemRespIsSuccess = resp.detail.result.isSuccess;
            this.itemRespErrorMsg += ' ' + resp.detail.result.message;
        }
        this.footCountInquirySaveButton();
    }

    returnsAndCreditCheckData() {
        let ele = this.template.querySelector('c-returns-and-credit-lwc');
        if(ele == null){
            return '';
        }else{
            return ele.checkData();
        }
    }
    // Foot Count Inquiry
    footCountInquirySaveButton() {
        let ele = this.template.querySelector('c-foot-count-inquiry-lwc');
        if (ele!=null) {
            ele.saveData();
        } else {
            if (this.itemRespIsSuccess) {
                this.showSuccess('success');
                this.isEditPage = false;
                this.viewMode = true;
            } else {
                this.showError(this.itemRespErrorMsg);
            }
        }
    }

    footCountInquirySaveData(resp){
        if (!resp.detail.result.isSuccess) {
            this.itemRespIsSuccess = resp.detail.result.isSuccess;
            this.itemRespErrorMsg += ' ' + resp.detail.result.message;
        }

        if (this.itemRespIsSuccess) {
            this.showSuccess('success');
            this.isEditPage = false;
            this.viewMode = true;
        } else {
            this.showError(this.itemRespErrorMsg);
        }
    }

    footCountInquiryCheckData() {
        let ele = this.template.querySelector('c-foot-count-inquiry-lwc');
        if(ele == null){
            return '';
        }else{
            return ele.checkData();
        }
    }

    //end

    //返回按钮
    handleReturn() {
        this.navi('Promoter_Daily_Report__c');
    }

    /**START 零售业绩 */
    //添加
    addRetailSaleItem(event) {
        console.log(JSON.stringify(this.retailNumberList));
        console.log('进入添加新新增零售业绩>>>>>>');
        console.log('length>>>>>>'+this.retailNumberList.length);
        // if (this.recordDisabled) {
        //     return;
        // }
        // if (!this.checkRequiredDailySale()) {
        //     this.showError('Required information haven’t been maintained. Please fulfil required information first.');
        //     return;
        // }
        var checkResp = {alltrue: true, msg: ''};
        if (this.checkRequiredDailySale().alltrue == false) {
            checkResp = this.checkRequiredDailySale();
        }

        if (checkResp.alltrue == false) {
            this.showError(this.label.PromoterDailyReport_RequiredCheck + checkResp.msg);
            return;
        }
        this.retailNumberList.push({
            Id:null,
            index: this.retailNumberList.length + 1,
            number: this.retailNumberList.length + 1,
            Product__c:'',
            Description__c:'',
            Price__c:null,
            Number__c:null,
            Kiosk__c:false,
            TotalPrice__c:'',
            StoreDelivery__c:'',
            HasGift__c:false,
            Gift__c:'',
            GiftQuantity__c:null,
            Comments__c:'',
            //SPIV__c:null,
            SPIV__c:0,
            files:['dailySale_'+(this.retailNumberList.length + 1)]
        })
        this.refreshStyle();
        this.activeSections = ['dailySale'];
        
     }

    //删除零售业绩
    async deleteRetailSalesRow(event) {
        var index = event.target.dataset.recordid;
    //     const result = await LightningConfirm.open({
    //         message: this.label.PromoterDailyReport_DeleteReminder,
    //         variant: 'headerless',
    //         label: 'This is the aria-label value',
    //         // label value isn't visible in the headerless variant
    //    });
    //    console.log('result>>>>>>>>'+result)
       
    //     if (result) {
    //         this.activeSections = ['dailySale'];
    //         this.deleteRetailSalesRowHelper(index);
    //     }
    this.handleShow(this.label.PromoterDailyReport_DeleteReminder,'deleteRetailSalesRowHelper',index,null);
        
        this.refreshStyle();
    }
    deleteRetailSalesRowHelper(index){
        try{
            let new_list = [];
            let new_file_map = {};
            for (let i = 0; i < this.retailNumberList.length; i++) {
                if (i!=index) {
                    new_list.push(this.retailNumberList[i]);
                }
            }
            for (let i = 0; i < new_list.length; i++) {
                new_list[i].number = i+1;

                var data_key = new_list[i].files[0].split('_')[0]+'_'+new_list[i].number;

                new_file_map[data_key] = this.retailNumberFilesMap[new_list[i].files[0]];
                new_list[i].files[0] = data_key;
            }
            if(new_list.length ==0){
                this.activeSections = [];
            }
            
            this.retailNumberList = new_list;  
            this.retailNumberFilesMap = new_file_map;
            
        }catch(err){
            console.log(err);
        }
     
    }
    //添加goods receiving
    addGoodsReceivingItem() {
        console.log('进入添加新新增零售业绩>>>>>>');

        // if (!this.checkRequiredGoodsReceiving()) {
        //     this.showError('Required information haven’t been maintained. Please fulfil required information first.');
        //     return;
        // }
        var checkResp = {alltrue: true, msg: ''};
        if (this.checkRequiredGoodsReceiving().alltrue == false) {
            checkResp = this.checkRequiredGoodsReceiving();
        }

        if (checkResp.alltrue == false) {
            this.showError(this.label.PromoterDailyReport_RequiredCheck + checkResp.msg);
            return;
        }

        this.goodsReceivingList.push({
            Id:null,
            index: this.goodsReceivingList.length + 1,
            number: this.goodsReceivingList.length + 1,
            ProductModel__c:'',
            Description__c:'',
            Quantities__c:null,
            Status__c:'New',
            disabled:false,
            files:['goodsReceiving_'+(this.goodsReceivingList.length + 1)]
        })
        this.refreshStyle();
        this.activeSections = ['goodsReceiving'];  
        console.log('gooods rece>>>>'+this.activeSections);
        
     }
     //删除goods receiving
    async deleteGoodsReceivingRow(event) {
        var index = event.target.dataset.recordid;
        // const result = await LightningConfirm.open({
        //     message: this.label.PromoterDailyReport_DeleteReminder,
        //     variant: 'headerless',
        //     label: 'This is the aria-label value',
        //     // label value isn't visible in the headerless variant
        // });
        // console.log('result>>>>>>>>'+result)
        
        // if (result) {
        //     this.activeSections = ['goodsReceiving'];
        //     this.deleteGoodsReceivingRowHelper(index);
        // }
        this.handleShow(this.label.PromoterDailyReport_DeleteReminder,'deleteGoodsReceivingRowHelper',index,null);
        
        this.refreshStyle();
    }
    deleteGoodsReceivingRowHelper(index){
        try{
            let new_list = [];
            let new_file_map = {};
            for (let i = 0; i < this.goodsReceivingList.length; i++) {
                if (i!=index) {
                    new_list.push(this.goodsReceivingList[i]);
                }
            }
            for (let i = 0; i < new_list.length; i++) {
                new_list[i].number = i+1;
                // new_list[i].files[0] = new_list[i].files[0].split('_')[0]+'_'+new_list[i].number;

                var data_key = new_list[i].files[0].split('_')[0]+'_'+new_list[i].number;

                new_file_map[data_key] = this.goodsReceivingFilesMap[new_list[i].files[0]];
                new_list[i].files[0] = data_key;
            }
            if(new_list.length ==0){
                this.activeSections = [];
            }
            
            this.goodsReceivingList = new_list;  
            this.goodsReceivingFilesMap = new_file_map;
        
            this.refreshStyle();
            
        }catch(err){
            console.log(err);
        }
     
    }
    //intelligence
    /**START 门店价格调查 */
    handleToggle(event) {
        let index = event.target.dataset.id;
        var item = this.intelligenceList[index].Item;
        for (let i = 0; i < item.length; i++) {
            if (item[i].idx!=1 ) {
                item[i].isShow = event.target.checked;
            }
        }
        this.intelligenceList[index].Item = item;
        
        this.refreshStyle();

    }
    //新增竞品信息
    addIntelligence(){
        console.log('this.record.Shop__c======>'+this.record.Shop__c);

        // if (!this.checkRequiredIntelligence()) {
        //     this.showError('Required information haven’t been maintained. Please fulfil required information first.');
        //     return;
        // }
        var checkResp = {alltrue: true, msg: ''};
        if (this.checkRequiredIntelligence().alltrue == false) {
            checkResp = this.checkRequiredIntelligence();
        }

        if (checkResp.alltrue == false) {
            this.showError(this.label.PromoterDailyReport_RequiredCheck + checkResp.msg);
            return;
        }

        var filesValue = 'intelligence_'+(this.intelligenceList.length+1)+'_1';
        this.intelligenceList.push({
            Id:null,
            index: this.intelligenceList.length + 1,
            number: this.intelligenceList.length + 1,
            IsActive: true,
            isDisabled:false,
            Item: [{
                idx:1, 
                number:1, 
                Brand__c:this.hisenseAccId,
                Product__c:null,
                //ProductInformation__c:'',
                Price__c:'',
                Discount__c:'',
                Commission__c :'',
                NewProduct__c:'No',
                DiscountPrice__c:'',
                CampaignType__c:null, 
                CampaignDescription__c:'',
                isFirst:true, 
                isShow:true,
                isDisabled:false,
                Shop__c:this.record.Shop__c,
                files: [filesValue],
            }],
        })
        this.refreshStyle();
        this.activeSections = ['intelligence'];  
        
    }
    //删除竞品
    async deleteIntelligenceRow(event) {
        var index = event.target.dataset.id;
    //     const result = await LightningConfirm.open({
    //         message: this.label.PromoterDailyReport_DeleteReminder,
    //         variant: 'headerless',
    //         label: 'This is the aria-label value',
    //         // label value isn't visible in the headerless variant
    //    });
    //    console.log('result>>>>>>>>'+result)
       
    //     if (result) {
    //         this.activeSections = ['intelligence'];  
    //         this.deleteIntelligenceRowHelper(index);
    //     }
    this.handleShow(this.label.PromoterDailyReport_DeleteReminder,'deleteIntelligenceRowHelper',index,null);
        
        this.refreshStyle();
    }
    deleteIntelligenceRowHelper(index){
        try{
            let new_list = [];
            let new_file_map = {};
            for (let i = 0; i < this.intelligenceList.length; i++) {
                if (i!=index) {
                    new_list.push(this.intelligenceList[i]);
                }
            }
            for (let i = 0; i < new_list.length; i++) {
                new_list[i].number = i+1;
                for (let j = 0; j < new_list[i].Item.length; j++) {
                    // new_list[i].Item[j].files[0] = new_list[i].Item[j].files[0].split('_')[0]+'_'+(i+1)+'_'+new_list[i].Item[j].files[0].split('_')[2];

                    var data_key = new_list[i].Item[j].files[0].split('_')[0]+'_'+(i+1)+'_'+new_list[i].Item[j].files[0].split('_')[2];
                    
                    new_file_map[data_key] = this.intelligenceFilesMap[new_list[i].Item[j].files[0]];
                    new_list[i].Item[j].files[0] = data_key;
                }
            }
            if(new_list.length ==0){
                this.activeSections = [];
            }
            console.log('new_list>>>>>>>>'+JSON.stringify(new_list));
            this.intelligenceList = new_list;  
            console.log('intelligenceList----------new_list>>>>>>>>'+JSON.stringify(this.intelligenceList));
            this.intelligenceFilesMap = new_file_map;
            
        }catch(err){
            console.log(err);
        }
     
    }
    //新增海信产品价格调查
    addHisenseProduct(event) {
        // if (!this.checkRequiredIntelligence()) {
        //     this.showError('Required information haven’t been maintained. Please fulfil required information first.');
        //     return;
        // }
        var checkResp = {alltrue: true, msg: ''};
        if (this.checkRequiredIntelligence().alltrue == false) {
            checkResp = this.checkRequiredIntelligence();
        }

        if (checkResp.alltrue == false) {
            this.showError(this.label.PromoterDailyReport_RequiredCheck + checkResp.msg);
            return;
        }

        let index = event.target.dataset.tableindex;
        var intelligence = this.intelligenceList[index];
        
        var itemSize = intelligence.Item.length + 1;
        
        // tabel index
        // item idx
        var fileValue = 'intelligence_'+(Number(index)+1)+'_'+itemSize;
        var item = {
            idx:itemSize,
            number:itemSize,
            Brand__c:null,
            Product__c:null,
            ProductInformation__c:'',
            NewProduct__c:'No',
            Price__c:'',
            Discount__c:'',
            DiscountPrice__c:'',
            Commission__c :'',
            CampaignType__c:null, 
            CampaignDescription__c:'',
            isFirst:false, 
            isShow:intelligence.IsActive,
            isDisabled:false,
            files:[fileValue],
        }
        this.intelligenceList[index].Item.push(item);
        
        this.refreshStyle();
    }
    //处理海信产品价格变更
    handleHisenseProductInputChange(event) {
        let idx = event.target.dataset.id;
        let index = event.target.dataset.tableindex;
        console.log('idx==========>'+idx);
        console.log('index==========>'+index);

        this.intelligenceList[index].Item[idx][event.target.fieldName] = event.target.value;

        var price = this.intelligenceList[Number(index)].Item[Number(idx)].Price__c;
        var discount = this.intelligenceList[Number(index)].Item[Number(idx)].Discount__c;
        var discountPrice = this.intelligenceList[Number(index)].Item[Number(idx)].DiscountPrice__c;
        if (event.target.fieldName == 'Price__c') {
            if (price==null || price=='') {
                this.intelligenceList[Number(index)].Item[Number(idx)].Discount__c = '';
                this.intelligenceList[Number(index)].Item[Number(idx)].DiscountPrice__c = '';
            } else if (discount!=null && discount!='') {
                this.intelligenceList[Number(index)].Item[Number(idx)].DiscountPrice__c = (discount*1/100*price).toString();
            } else if (discountPrice!=null && discountPrice!='') {
                this.intelligenceList[Number(index)].Item[Number(idx)].Discount__c = Math.round(discountPrice/price*100).toString();
            }
        } else if (event.target.fieldName == 'Discount__c') {
            if (discount==null || discount=='') {
                this.intelligenceList[Number(index)].Item[Number(idx)].DiscountPrice__c = '';
            } else if (price!=null && price!='') {
                this.intelligenceList[Number(index)].Item[Number(idx)].DiscountPrice__c = (discount*1/100*price).toString();
            }
        } else if (event.target.fieldName == 'DiscountPrice__c') {
            if (discountPrice==null || discountPrice=='') {
                this.intelligenceList[Number(index)].Item[Number(idx)].Discount__c = '';
            } else if (price!=null && price!='') {
                this.intelligenceList[Number(index)].Item[Number(idx)].Discount__c = Math.round(discountPrice/price*100).toString();
            }
        }


        console.log('intelligenceList=====>'+JSON.stringify(this.intelligenceList));
        
        this.refreshStyle();
    }
    
    //删除海信产品价格调查
    deleteHisenseProduct(event) {
        try{
            let idx = event.target.dataset.id;
            let index = event.target.dataset.tableindex;

            
            let new_list = [];
            let new_file_map = {};
            for (let i = 0; i < this.intelligenceList[index].Item.length; i++) {
                if (i!=idx) {
                    new_list.push(this.intelligenceList[index].Item[i]);
                }
            }
            for (let i = 0; i < new_list.length; i++) {
                new_list[i].number = i+1;
                // new_list[i].files[0] = new_list[i].files[0].split('_')[0]+'_'+(Number(index)+1)+'_'+(i+1);
                
                var data_key = new_list[i].files[0].split('_')[0]+'_'+(Number(index)+1)+'_'+(i+1);

                new_file_map[data_key] = this.intelligenceFilesMap[new_list[i].files[0]];
                new_list[i].files[0] = data_key;
            }
            
            for (let i = 0; i < this.intelligenceList.length; i++) {
                if (i!=index) {
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
        }catch(err){
            console.log(err);
        }
    }
    
    // //处理删除Id
    // handleDeleteRecord(item) {
    //     this.isEdit = true;
    //     if(this.deleteIdList.indexOf(item.Id)>=0 || item.Id == null || item.Id == undefined || item.Id == ""){
    //         return;
    //     }else{
    //         this.deleteIdList.push(item.Id);
    //         console.log(this.deleteIdList.indexOf(item.Id));
    //     }
    //     console.log(JSON.stringify(this.deleteIdList) );
    // }

    // 附件部分
    handleSelectFiles(event) {
        console.log('event.currentTarget.dataset.type===>'+event.currentTarget.dataset.type);
        console.log('event.currentTarget.dataset.recordid===>'+event.currentTarget.dataset.recordid);
        var type = event.currentTarget.dataset.type;
        var index = event.currentTarget.dataset.recordid;

        var indexNumber = Number(index)+1;
        if (type=='dailySale') {
            // this.retailNumberList[index].files = [type+'_'+index];
            // for (let i = 0; i < event.detail.records.length; i++) {
            //     this.retailNumberList[index].files.push(event.detail.records[i].src);
            // }
            this.retailNumberFilesMap[type+'_'+indexNumber] = event.detail.records;
        } else if (type=='goodsReceiving') {
            // this.goodsReceivingList[index].files = [type+'_'+index];
            // for (let i = 0; i < event.detail.records.length; i++) {
            //     this.goodsReceivingList[index].files.push(event.detail.records[i].src);
            // }
            this.goodsReceivingFilesMap[type+'_'+indexNumber] = event.detail.records;
        } else if (type=='intelligence') {
            var itemId = event.currentTarget.dataset.itemid;
            var itemIdNumber = Number(itemId)+1;
            // this.intelligenceList[index].Item[itemId].files = [type+'_'+(index+1)+'_'+(itemId+1)];
            // for (let i = 0; i < event.detail.records.length; i++) {
            //     this.intelligenceList[index].Item[itemId].files.push(event.detail.records[i].src);
            // }
            // this.intelligenceList[index].Item[itemId].files = [type+'_'+(index+1)+'_'+(itemId+1)];
            this.intelligenceFilesMap[type+'_'+indexNumber+'_'+itemIdNumber] = event.detail.records;
        }
        
        this.refreshStyle();
    }

    @track style =  '';
    refreshStyle() {
        // this.style =  FORM_FACTOR == 'Small' ? 'max-height: ' + (document.documentElement.clientHeight - 130) + 'px;' : '';
    }

    // @track helptextStyle = FORM_FACTOR == 'Small' ? 'padding: 100px; min-height: 0px; min-width: 0px; height: 100px; width: 100px;' : '';
    //产品的lookup
    handleChangeProductOption(event) {
        let index = event.target.dataset.recordid;
        let fieldName = event.target.dataset.fieldName;
        let selectRecord = event.detail.selectedRecord;
        if(fieldName == 'Product__c'){
            //如果修改product，重置spiv
            this.retailNumberList[index].SPIV__c = 0;

            let product = selectRecord.Id;
            autoShowProductDes({ product :product
            }).then(data => {
                if(data.isSuccess){
                    console.log('product信息：'+JSON.stringify(data.data));
                    this.retailNumberList[index].Description__c = data.data;
                    console.log('产品信息'+JSON.stringify(this.retailNumberList[index].Description__c));
                }                             
            })            
        }
        if(fieldName == 'ProductModel__c'){
            let product = selectRecord.Id;
            autoShowProductDes({ product :product
            }).then(data => {
                if(data.isSuccess){
                    console.log('product信息：'+JSON.stringify(data.data));
                    this.goodsReceivingList[index].Description__c = data.data;
                }                             
            })            
        }
        if(fieldName == 'Product__c'){
            if (selectRecord==undefined) {
                this.retailNumberList[index].Product__c = null;;
            } else {
                this.retailNumberList[index].Product__c = selectRecord.Id;
            }
        }
        if(fieldName == 'ProductModel__c'){
            if (selectRecord==undefined) {
                this.goodsReceivingList[index].ProductModel__c = null;;
            } else {
                this.goodsReceivingList[index].ProductModel__c = selectRecord.Id;
            }
        }
        if(fieldName == 'Gift__c'){
            if (selectRecord==undefined) {
                this.retailNumberList[index].Gift__c = null;;
            } else {
                this.retailNumberList[index].Gift__c = selectRecord.Id;
            }
        }
    }
    // 添加产品（自定义lookupFilter）
    lookupFilter = {
        'lookup' : 'CustomLookupProvider.ProductAllFilter'
    }
    handleChangeIntelligenceOption(event){
        let idx = event.target.dataset.id;
        let index = event.target.dataset.tableindex;
        let fieldName = event.target.dataset.fieldName;
        let selectRecord = event.detail.selectedRecord;
        console.log('selectRecord>>>>>>'+selectRecord);
        // console.log('selectRecordId>>>>>>'+selectRecord.id);
        if(fieldName == 'Brand__c'){
            if (selectRecord==undefined) {
                this.intelligenceList[Number(index)].Item[Number(idx)].Brand__c = null;
            } else {
                this.intelligenceList[Number(index)].Item[Number(idx)].Brand__c = selectRecord.Id;
                console.log('intelligenceList>>>brand>>>'+this.intelligenceList[Number(index)].Item[Number(idx)].Brand__c);
            }
        }
        if(fieldName == 'Product__c'){
            if (selectRecord==undefined) {
                this.intelligenceList[Number(index)].Item[Number(idx)].Product__c = null;;
            } else {
                this.intelligenceList[Number(index)].Item[Number(idx)].Product__c = selectRecord.Id;
            }
        }
    }
    //添加customer（自定义lookupFilter）
    lookupAccountFilter = {
        'lookup' : 'CustomLookupProvider.BrandContainsHisense'
    }
    //gift
    ProductGift = {
        'lookup' : 'CustomLookupProvider.ProductGift'
    }
    
    @track isShowDailySalesAction = true;
    handleEdit() {
        console.log('==========>Edit click');
        this.isEditPage = true;
        this.isTitleReadOnly = false;
        this.viewMode = false;
        if(this.recordDisabled == false){   
            console.log('recordDisabled>>>>>'+this.recordDisabled);   
            this.isShowDailySalesAction = false;
        }
    }
    @track hiddenPart = true;

    
    get recordDatereadonly() {
        if (this.isTitleReadOnly) {
            return true;
        } else if (this.isEditPage) {
            return true;
        } else {
            return false;
        }
    }
    
    get recordDateClass() {
        if (this.recordDatereadonly) {
            return 'disabled-input';
        } else {
            return '';
        }
    }
}