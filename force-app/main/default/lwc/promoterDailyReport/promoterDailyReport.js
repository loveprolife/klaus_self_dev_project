import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin , CurrentPageReference } from 'lightning/navigation';
import initReportInfo from '@salesforce/apex/PromoterDailyReportActionController.initReportInfo';
import saveReport from '@salesforce/apex/PromoterDailyReportActionController.saveReport';
import judgeCountry from '@salesforce/apex/NewPromoterDailyReportActionController.judgeCountry';

import CheckInCheckOut_QUERY from '@salesforce/label/c.CheckInCheckOut_QUERY';
import PromoterDailyReport_NO_CHOOSE_MORE_THAN_TODAY from '@salesforce/label/c.PromoterDailyReport_NO_CHOOSE_MORE_THAN_TODAY';
import PromoterDailyReport_PRODUCT_PRICE_ONE from '@salesforce/label/c.PromoterDailyReport_PRODUCT_PRICE_ONE';
import PromoterDailyReport_SAVE_SUCCESS from '@salesforce/label/c.PromoterDailyReport_SAVE_SUCCESS';
import PromoterDailyReport_NOT_EMPTY_STORE_DATE from '@salesforce/label/c.PromoterDailyReport_NOT_EMPTY_STORE_DATE';
import PromoterDailyReport_CHECK_FIELD_ERROR from '@salesforce/label/c.PromoterDailyReport_CHECK_FIELD_ERROR';
import CheckInCheckOut_RETAIL_SALE from '@salesforce/label/c.CheckInCheckOut_RETAIL_SALE';
import PromoterDailyReport_CHECK_IN_STATUS from '@salesforce/label/c.PromoterDailyReport_CHECK_IN_STATUS';
import PromoterDailyReport_WEEK_PROBLEM from '@salesforce/label/c.PromoterDailyReport_WEEK_PROBLEM';
import PromoterDailyReport_PRODUCT_PRICE from '@salesforce/label/c.PromoterDailyReport_PRODUCT_PRICE';
import PromoterDailyReport_CHECK_EMPTY from '@salesforce/label/c.PromoterDailyReport_CHECK_EMPTY';
import PromoterDailyReportLabel from '@salesforce/label/c.PromoterDailyReport';
import PromoterDailyReport_WEEK_PROBLEM_EMPTY from '@salesforce/label/c.PromoterDailyReport_WEEK_PROBLEM_EMPTY';
import PromoterDailyReport_ALL_REPORT from '@salesforce/label/c.PromoterDailyReport_ALL_REPORT';
import PromoterDailyReport_SAVE_REPORT from '@salesforce/label/c.PromoterDailyReport_SAVE_REPORT';
import PromoterDailyReport_CONFIRM_SAVE from '@salesforce/label/c.PromoterDailyReport_CONFIRM_SAVE';
import PromoterDailyReport_HAS_CHANGE from '@salesforce/label/c.PromoterDailyReport_HAS_CHANGE';
import PromoterDailyReport_DISCARD from '@salesforce/label/c.PromoterDailyReport_DISCARD';
import PromoterDailyReport_SAVE_JUMP from '@salesforce/label/c.PromoterDailyReport_SAVE_JUMP';
import PromoterDailyReport_PROMOTER from '@salesforce/label/c.PromoterDailyReport_PROMOTER';
import PromoterDailyReport_No_Performance from '@salesforce/label/c.PromoterDailyReport_No_Performance';
import PromoterDailyReport_WITHOUT_REPORT from '@salesforce/label/c.PromoterDailyReport_WITHOUT_REPORT';
import PromoterDailyReport_NOT_ALLOW_EDIT from '@salesforce/label/c.PromoterDailyReport_NOT_ALLOW_EDIT';
import PromoterDailyReport_REQUIRED_FIELD from '@salesforce/label/c.PromoterDailyReport_REQUIRED_FIELD';
import PromoterDailyReport_ADD_ITEM from '@salesforce/label/c.PromoterDailyReport_ADD_ITEM';
import PromoterDailyReport_DISPLAY_COMPETITIVE from '@salesforce/label/c.PromoterDailyReport_DISPLAY_COMPETITIVE';
import PromoterDailyReport_HIDE_COMPETITIVE from '@salesforce/label/c.PromoterDailyReport_HIDE_COMPETITIVE';
import PromoterDailyReport_BRAND from '@salesforce/label/c.PromoterDailyReport_BRAND';
import PromoterDailyReport_TYPE from '@salesforce/label/c.PromoterDailyReport_TYPE';
import PromoterDailyReport_PRICE from '@salesforce/label/c.PromoterDailyReport_PRICE';
import PromoterDailyReport_DISCOUNT from '@salesforce/label/c.PromoterDailyReport_DISCOUNT';
import PromoterDailyReport_POINT from '@salesforce/label/c.PromoterDailyReport_POINT';
import PromoterDailyReport_ACTION from '@salesforce/label/c.PromoterDailyReport_ACTION';
import PromoterDailyReport_CHECK_INFO from '@salesforce/label/c.PromoterDailyReport_CHECK_INFO';
import PromoterDailyReport_CHECK_OUT_TODAY from '@salesforce/label/c.PromoterDailyReport_CHECK_OUT_TODAY';
import PromoterDailyReport_ADD_CHECK_INFO from '@salesforce/label/c.PromoterDailyReport_ADD_CHECK_INFO';
import PromoterDailyReport_ADD_CHECK_IN from '@salesforce/label/c.PromoterDailyReport_ADD_CHECK_IN';
import PromoterDailyReport_CHECK_TAB from '@salesforce/label/c.PromoterDailyReport_CHECK_TAB';
import PromoterDailyReport_SAVE_FAIL from '@salesforce/label/c.PromoterDailyReport_SAVE_FAIL';
import PromoterDailyReport_WEEK_PROBLEM_UNACTIVE from '@salesforce/label/c.PromoterDailyReport_WEEK_PROBLEM_UNACTIVE';
import Competing_Msg from '@salesforce/label/c.COMPETING_MSG';
import WeekResearch_UNACTIVE from '@salesforce/label/c.WeekResearch_UNACTIVE';
import WeekResearch_EXAMPLE_Product from '@salesforce/label/c.EXAMPLE_Product';
import WeekResearch_EXAMPLE_Price from '@salesforce/label/c.EXAMPLE_Price';
import WeekResearch_EXAMPLE_DiscountPrice from '@salesforce/label/c.EXAMPLE_DiscountPrice';
import PromoterDailyReport_CURRENT_EXIST_PRODUCT_NOT_REPERTION from '@salesforce/label/c.CURRENT_EXIST_PRODUCT_NOT_REPERTION';
import promoterModelTypeAdd from '@salesforce/label/c.PromoterModelTypeAdd';
import promoterModelTypeDelete from '@salesforce/label/c.PromoterModelTypeDelete';
import promoterDailyReport_DEL_ITEM from '@salesforce/label/c.PromoterDailyReport_DEL_ITEM';
export default class PromoterDailyReport extends NavigationMixin(LightningElement) {

    label ={
        CheckInCheckOut_QUERY,
        PromoterDailyReport_NO_CHOOSE_MORE_THAN_TODAY,//不能选择大于今日的日期
        PromoterDailyReport_PRODUCT_PRICE_ONE,//竞品价格调查必须至少填写一项
        PromoterDailyReport_SAVE_SUCCESS,//保存成功
        PromoterDailyReport_NOT_EMPTY_STORE_DATE,//促销员日报的报告日期和门店不可为空
        PromoterDailyReport_CHECK_FIELD_ERROR,//请检查字段错误
        CheckInCheckOut_RETAIL_SALE,//零售业绩
        PromoterDailyReport_CHECK_IN_STATUS,//考勤情况
        PromoterDailyReport_WEEK_PROBLEM,//周报告问题
        PromoterDailyReport_PRODUCT_PRICE,//门店价格调查
        PromoterDailyReport_CHECK_EMPTY,//保存日报时，签到时间为空，签到补签时间不可为空
        PromoterDailyReport_WEEK_PROBLEM_EMPTY,//报表日期为周日，周报反馈不可为空
        PromoterDailyReportLabel,//促销员日报
        PromoterDailyReport_ALL_REPORT,//全部日报
        PromoterDailyReport_SAVE_REPORT,//保存
        PromoterDailyReport_CONFIRM_SAVE,//确认是否保存修改后内容
        PromoterDailyReport_HAS_CHANGE,//
        PromoterDailyReport_DISCARD,//放弃保存并跳转
        PromoterDailyReport_SAVE_JUMP,//保存修改并跳转
        PromoterDailyReport_PROMOTER,//促销员
        PromoterDailyReport_WITHOUT_REPORT,//当前门店报告日期无促销员日报
        PromoterDailyReport_NOT_ALLOW_EDIT,//当前报告日期已逾期不可补填,仅允许七天内补填
        PromoterDailyReport_REQUIRED_FIELD,//请填写必填字段
        PromoterDailyReport_ADD_ITEM,//添加价格调查
        PromoterDailyReport_DISPLAY_COMPETITIVE,//显示竞品
        PromoterDailyReport_HIDE_COMPETITIVE,//隐藏竞品
        PromoterDailyReport_BRAND,//品牌
        PromoterDailyReport_TYPE,//型番
        PromoterDailyReport_PRICE,//售价
        PromoterDailyReport_DISCOUNT,//折扣
        PromoterDailyReport_POINT,//返点
        PromoterDailyReport_ACTION,//操作
        PromoterDailyReport_CHECK_INFO,//考勤信息
        PromoterDailyReport_CHECK_OUT_TODAY,//请在当日工作完成后在打卡处签退。
        PromoterDailyReport_ADD_CHECK_INFO,//补签信息
        PromoterDailyReport_ADD_CHECK_IN,//签到补签
        PromoterDailyReport_CHECK_TAB,//签退信息需要更改或补签，请前往'考勤'选项卡提交补签申请。
        PromoterDailyReport_SAVE_FAIL,//记录保存失败，请检查页面错误信息.
        PromoterDailyReport_WEEK_PROBLEM_UNACTIVE,//问题已失效，不可编辑
        Competing_Msg, //竞品信息 JA:競合機種情報
        WeekResearch_UNACTIVE,//门店调查要求已失效，问题不可回复
        WeekResearch_EXAMPLE_Product,
        WeekResearch_EXAMPLE_Price,
        WeekResearch_EXAMPLE_DiscountPrice,
        PromoterDailyReport_CURRENT_EXIST_PRODUCT_NOT_REPERTION,
        PromoterDailyReport_No_Performance,//当日実績なし
        promoterModelTypeAdd,
        promoterModelTypeDelete,
        promoterDailyReport_DEL_ITEM
    }

    @api recordId; //日报Id


    @track existRecordId;

    @track activeSections = [];
    @track isPageReadOnly = false;;
    @track isNew = false;

    @track isToday = false;
    @track isAllowEdit = false;
    @track isAllowEditAddCheckTime = false;
    @track isShowChangeConfirm = false;//日报是否跳转
    @track isEdit = false;//是否编辑过

    @track thisDay; //apex传值，日期格式不用考虑
    @track reportDate;//前端变更，需考虑日期格式
    @track shopId;
    @track productLine;

    @track changeReportDate;//前端变更，需考虑日期格式
    @track changeShopId;

    @track changeShopId;

    @track retailSaleList = [];
    @track retailSaleListError;

    //门店价格调查
    @track productPriceList;
    @track productPriceListError;
    @track isShowTableRequiredError = false;

    @track promoterItem = {};
    @track supplementaryItem = {};
    @track promoterItemError;


    @track deleteIdList = [];

    @track dayOfWeek;
    /*
    @track questionList = [];
    @track answerList = [];
    */
    @track researchResponseId;
    @track responseList = [];
    @track responseListError;

    @track isResetInput = false;

    @track isWeekLastDay = false;

    @track noPerformance = false;

    @track isJapan = false;

    @track addButtonLabel = "競合機種追加"

    //页面初始化方法
    connectedCallback() {
        this.judgeIsNew();
        this.callInitReportInfo();

        judgeCountry().then(data => {
            console.log("data.isSuccess" + data.isSuccess);
            console.log("ddata.data.Japan" + data.data.Japan);
            if (data.isSuccess) {
                if(data.data.Japan){
                    this.isJapan = true;
                }   
            } else {
            }
        }).catch(error => {
        })
    }

    /**-----------------Button function---------------*/
    handleSectionToggle(event) {
        console.log(event.detail.openSections);
        // 在促销员，新增"当日実績なし"勾选项。勾选后日业绩下拉框不能打开。(wfc)
        let openSections = event.detail.openSections;
        let sections = this.template.querySelectorAll(
            "lightning-accordion-section"
        );
        this.activeSections = [];      
        sections.forEach((section) => {
            if(openSections.indexOf(section.name) > -1){
                if(this.noPerformance && section.name == 'retailSale'){
                    console.log(this.noPerformance);
                }else {
                    this.activeSections.push(section.name);
                }
            }  
        });
    }
    //返回按钮
    handleReturn() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Promoter_Daily_Report__c',
                actionName: 'home'
            }
        });
    }
    //保存按钮
    handleSave() {
        this.callSaveReport(true);
    }
    //日报日期选择
    handleReportDateChange(event) {
        this.changeReportDate = this.handleDateFormat(event.target.value);
        this.changeShopId = this.shopId;
        var emptyVar1 = this.judgeFieldValueEmpty(this.changeReportDate );
        if(this.changeReportDate > this.thisDay) {
            this.showNotification("error",this.label.PromoterDailyReport_NO_CHOOSE_MORE_THAN_TODAY,"error");
            this.handleResetInputChange();
        }else if(this.changeReportDate == this.reportDate || emptyVar1){
            //日期未变，或置空，则不做额外判断
            this.handleSuccessInputChange();
            return;
        }else{

            this.handleJudgeEditShowConfirmPageOrNot();
            //this.callGetCurrentUserDuplicateInfo();
        }
    }
    //判断是否显示跳转页面
    handleJudgeEditShowConfirmPageOrNot() {
        if(this.isEdit && this.isAllowEdit) {
            this.isShowChangeConfirm = true;
        }else{
            this.handleJumpPage();
        }
    }
    //直接跳转
    handleJumpPage() {
        this.callGetCurrentUserDuplicateInfo();
    }
    //保存后调转
    handleSaveRecordJumpPage() {
        this.callSaveReport(false);
    }
    //日报门店选择
    handleShopIdChange(event) {
        this.changeShopId = event.target.value;
        this.changeReportDate = this.reportDate;
        var emptyVar1 = this.judgeFieldValueEmpty(this.changeShopId );
        if( emptyVar1 ){
            this.handleSuccessInputChange();
            //门店置空，则不做额外判断
            return;
        }else{
            this.handleJudgeEditShowConfirmPageOrNot();
            //this.isShowChangeConfirm = true;
            //this.callGetCurrentUserDuplicateInfo();
        }
    }

    //产品线选择
    handleProductLineChange(event) {
        this.productLine = event.target.value;
    }

    /**START 零售业绩 */
    //添加
    addRetailSaleItem() {
        // 在促销员，新增"当日実績なし"勾选项。勾选后不能“+”当日业绩。(wfc)
        if(this.noPerformance) return false;
        //var index = this.retailSaleList.length;
        let item = {
            Id: null
        };
        this.retailSaleList.push( item );
        this.activeSections = ['retailSale'];
    }
    //删除
    delRetailSaleItem(event) {
        //a用event.currentTarget, input用event.target
        var index = event.currentTarget.dataset.id;
        var deleteItem = this.retailSaleList[index];
        this.retailSaleList.splice(index, 1);
        this.handleDeleteRecord(deleteItem);
    }
    //数据变更
    handleRetailSaleInputChange(event) {
        //this.xxx 不可直接添加对象属性，只能通过变量的方式添加，反向赋值
        this.retailSaleList = this.handleAddObjectKey(this.retailSaleList, event.target.dataset.id, event.target.fieldName, event.target.value);
    }
    /**END 零售业绩 */

    /**START 门店价格调查 */
    handleToggle(event) {
        console.log("event.target.name :" + event.target.name);
        var itemList = this.productPriceList;
        for(var i = 0; i < itemList.length; i++){
            if (event.target.dataset.id == i) { 
                itemList[i][event.target.name] = event.target.checked;
                break;
            }
        }
        // itemList[event.target.dataset.id][event.target.name] = event.target.checked;
        // this.productPriceList = this.handleAddObjectKey(this.productPriceList, event.target.dataset.id, event.target.name, event.target.checked);

        setTimeout(function(){
            this.productPriceList = itemList;
        }.bind(this), 1000);
    }
    //"在促销员，新增""当日実績なし""勾选项。勾选后不能“+”当日业绩。勾选后，保存时，需要生成一条业绩为0的数据"(wfc)
    noPerformanceCheck(event) {
        console.log("noPerformance:" + event.target.checked);
        this.noPerformance = event.target.checked;
        // 勾选 则打不开日业绩框
        if(this.noPerformance){
            var activeAccordion = this.activeSections;
            this.activeSections = [];
            activeAccordion.forEach(aa => {
                if(aa != 'retailSale'){
                    this.activeSections.push(aa);
                }
            });
        }
    }
    //新增海信产品价格调查
    addHisenseProduct() {
        let item = {
            Index: this.productPriceList.length,
            IsActive : true,
            RetailDetail : {
                Id : null,
                Product__c : null,
                Price__c : null,
                DiscountPrice__c : null,
                Point__c : null,
            },
            ComtitiveShopRetailDetails : [
                {
                    Id : null,
                    CP_Brand__c : null,
                    CompetitiveProduct__c : null,
                    Price__c : null,
                    DiscountPrice__c : null,
                    Point__c : null,
                },
            ],
        };
        this.productPriceList.splice(0, 0, item);
        this.activeSections = ['productPrice'];
        console.log(this.productPriceList);
        //this.handleTableRefresh();
    }
    //处理海信产品价格变更
    handleHisenseProductInputChange(event) {

        //检查产品是否已存在当前价格调查
        let isNull = false;
        let inputValue = event.target.value;
        let index = event.currentTarget.dataset.id;
        let productPriceListAtCurrent = this.productPriceList;
        for (let i = 0; i < this.productPriceList.length; i++) {
            var currentObj = this.productPriceList[i].RetailDetail;
            if (currentObj["Product__c"] != null && currentObj["Product__c"] != undefined && inputValue == currentObj["Product__c"]) { 
                this.isShowSpinner = true;
                this.showNotification("warning", this.label.PromoterDailyReport_CURRENT_EXIST_PRODUCT_NOT_REPERTION, "warning");
                isNull = true;
            }
        }
        if (isNull) {
            productPriceListAtCurrent[index].RetailDetail = this.handleAddObjectItemKey(productPriceListAtCurrent[index].RetailDetail, event.target.fieldName, null);
            this.productPriceList = [];
            setTimeout(function(){
                this.isShowSpinner = false;
                this.productPriceList = productPriceListAtCurrent;
            }.bind(this), 1000);
        } else { 
            this.productPriceList[index].RetailDetail = this.handleAddObjectItemKey(this.productPriceList[index].RetailDetail, event.target.fieldName, event.target.value);
        }
    }
    //删除海信产品价格调查
    deleteHisenseProduct(event) {
        var index = event.currentTarget.dataset.id;
        var deleteItem = this.productPriceList[index];
        this.productPriceList.splice(index, 1);
        this.handleDeleteRecord(deleteItem);
    }
    //添加竞品价格调查
    addCompetitiveProduct(event) {
        var index = event.currentTarget.dataset.id;
        let item = {
            Id : null,
            CP_Brand__c : null,
            CompetitiveProduct__c : null,
            Price__c : null,
            DiscountPrice__c : null,
            Point__c : null,
        };
        if(this.judgeFieldValueEmpty(this.productPriceList[index].ComtitiveShopRetailDetails) ){
            this.productPriceList[index].ComtitiveShopRetailDetails = [];
        }
        this.productPriceList[index].ComtitiveShopRetailDetails.splice(0, 0, item );
        this.activeSections = ['productPrice'];
        this.productPriceList[index].IsActive = true;
    }
    //处理竞品价格调查变更
    handleCompetitiveProductInputChange(event) {
        var index = event.target.accessKey;
        // var productPriceList = this.productPriceList;
        // console.log("indexget: " + indexget);
        // console.log("event.target.dataset.id: " + event.target.dataset.id);
        // console.log("event.target.fieldName: " + event.target.fieldName);
        // console.log("event.target.value: " + event.target.value);

        // for (let index = 0; index < productPriceList.length; index++) {
        //     if (indexget == index) {
        //         for (let i = 0; i < productPriceList[index].ComtitiveShopRetailDetails.length; i++) {
        //             if (event.target.dataset.id == i) {
        //                 productPriceList[index].ComtitiveShopRetailDetails[i][event.target.fieldName] == event.target.value;
        //             }
        //         }
        //     }
        // }
        this.productPriceList[index].ComtitiveShopRetailDetails = this.handleAddObjectKey(this.productPriceList[index].ComtitiveShopRetailDetails, event.target.dataset.id, event.target.name, event.target.value);
        // this.productPriceList = productPriceList;
    }
    //删除竞品价格调查
    deleteCompetitiveProduct(event) {
        var comoetitiveIndex = event.currentTarget.dataset.id;
        var index = event.currentTarget.name;
        if(this.productPriceList[index].ComtitiveShopRetailDetails.length <=1){
            this.showNotification("error",this.label.PromoterDailyReport_PRODUCT_PRICE_ONE,"error");
            return;
        }
        var deleteItem = this.productPriceList[index].ComtitiveShopRetailDetails[comoetitiveIndex];
        this.productPriceList[index].ComtitiveShopRetailDetails.splice(comoetitiveIndex, 1);
        this.handleDeleteRecord(deleteItem);
    }
    /**END 门店价格调查 */
 
    //考勤
    handlePromoterAttandenceChange(event) {
        this.supplementaryItem = this.handleAddObjectItemKey(this.supplementaryItem, event.target.fieldName, event.target.value );
    }
    //周报问题回答
    handleQuestionAnswerChange(event) {
        this.responseList = this.handleAddObjectKey(this.responseList, event.target.dataset.id, "Response__c", event.target.value);
    }

    handleCloseModal(event) {
        if(this.isNew) {
            this.reportDate = null;
            this.shopId = null;
            this.productLine = null;
        }
        this.handleResetInputChange();
    }

    handleChangeConfirmCloseModal() {
        this.isShowChangeConfirm = false;
    }

    handleJumpExistRecord(){
        this.isShowSpinner = true;
        //this.isShowChangeConfirm = false;
        this.isShowTableRequiredError = false;
        //this.retailDetailListError = null;
        this.handleResetErrorMsg();
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.existRecordId,
                objectApiName: 'Promoter_Daily_Report__c',
                actionName: 'view'
            }
        });
        this.isShowSpinner = false;
    }

    /**-----------------Button function---------------*/

    /**--------------Callout-----------------*/
    callInitReportInfo() {
        this.isShowSpinner = true;
        initReportInfo({
            recordId : this.recordId,
            reportDate : this.reportDate,
            shopId : this.shopId,
            productLine : this.productLine
        }).then(
            result=>{
                this.isShowSpinner = false;
                console.log(result);
                if(result.isSuccess) {
                    this.existRecordId = result.existRecordId;
                    this.handleDuplicateCondition();
                    this.handleInitResult(result);
                    if(this.judgeFieldValueEmpty(this.recordId) && this.judgeFieldValueEmpty(this.productLine)){
                        this.productLine = 'TV';
                    }
                }else{
                    this.showNotification("", result.failMessage ,"error");
                }
        }).catch(error => {
            console.log("callInitReportInfo"+ error);
            this.isShowSpinner = false;
            this.showNotification("", error.message ,"error");
        });
    }

    callGetCurrentUserDuplicateInfo() {
        let emptyVar1 = this.judgeFieldValueEmpty(this.changeShopId);
        let emptyVar2 = this.judgeFieldValueEmpty(this.changeReportDate);
        if(emptyVar1 || emptyVar2) {
            this.handleSuccessInputChange();
            return;
        }
        this.isShowSpinner = true;
        initReportInfo({
            recordId: this.recordId, 
            shopId: this.changeShopId, 
            reportDate: this.changeReportDate,
            productLine : this.productLine
        }).then(
            result=>{
                this.isShowSpinner = false;
                console.log(result);
                if(result.isSuccess) {
                    this.existRecordId = result.existRecordId;
                    this.handleDuplicateCondition();
                    this.handleInitResult(result);
                }else{
                    this.showNotification("", result.failMessage ,"error");
                }
        }).catch(error => {
            console.log("callInitReportInfo"+ error);
            this.isShowSpinner = false;
            this.showNotification("", error.message ,"error");
        });
    }

    callSaveReport(refreshPage) {
        if(this.judgeSaveReportRequirdFieldValue()){
            this.isShowSpinner = true;
            let productPriceListJson = JSON.stringify(this.productPriceList);
            if(this.noPerformance == undefined) this.noPerformance = false;
            if(this.noPerformance){
                this.retailSaleList = [];
            }
            
            saveReport({
                recordId : this.recordId, 
                shopId : this.shopId, 
                reportDate : this.reportDate, 
                productLine : this.productLine, 
                retailSaleList : this.retailSaleList, 
                productPriceListJson : productPriceListJson,
                deleteIdList : this.deleteIdList,
                promoterItem : this.promoterItem,
                researchResponseId : this.researchResponseId,
                responseList : this.responseList,
                supplementaryItem : this.supplementaryItem,
                noPerformance : this.noPerformance // 勾选参数(wfc)
            }).then(
                result=>{
                    console.log(result);
                    if(result.isSuccess) {
                        this.showNotification("", this.label.PromoterDailyReport_SAVE_SUCCESS ,"success");
                        if(refreshPage){
                            this.existRecordId = result.existRecordId;
                            this.recordId = result.existRecordId;
                            this.handleJumpExistRecord();
                        }else{
                            this.callGetCurrentUserDuplicateInfo();
                        }
                    }else{
                        this.promoterItemError = result.promoterItemError;
                        this.retailSaleListError = result.retailSaleListError;
                        this.productPriceListError = result.productPriceListError;
                        this.responseListError = result.responseListError;
                        this.showNotification("", result.failMessage ,"error");
                        this.isShowSpinner = false;
                    }
            }).catch(error => {
                console.log(error);
                this.isShowSpinner = false;
                this.showNotification("", error.message ,"error");
            });
        }else{
            this.handleResetInputChange();
        }
    }

    /**--------------Callout-----------------*/

    /**-----------------Function----------------------*/
    /**
    Name : showNotification
    Purpose : 
    Params :  title, message,
    variant : error,warning,success,info
    Author : Chiara
    Date : 2021/07/26
    **/
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            //title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleResetErrorMsg() {
        this.retailSaleListError = null;
        this.productPriceListError = null;
        this.promoterItemError = null;
        this.responseListError = null;
    }

    handleInitResult(result) {
    
        this.handleResetErrorMsg();
        /**促销员日报 */
        this.thisDay = result.thisDay;
        this.reportDate = result.reportDate;
        this.shopId = result.shopId;
        this.isAllowEdit = result.isAllowEdit = true;
        this.isShowChangeConfirm = false;
        this.isEdit = false;
        this.noPerformance = result.noPerformance;// (wfc)

        /**零售业绩*/
        if(!this.noPerformance){ // wfc
            this.retailSaleList = result.retailSaleList;
        }
        
        //门店价格调查
        //this.productPriceList = result.productPriceList;
        if(!this.judgeFieldValueEmpty(result.productPriceListJson)  ){
            this.productPriceList = JSON.parse(result.productPriceListJson);
            console.log( "this.productPriceList:"+ this.productPriceList);
        }

        if(this.isAllowEdit && this.productPriceList.length <= 0){
            if(this.judgeFieldValueEmpty(this.recordId)) {
                // 去掉默认第一条
                // this.addHisenseProduct();
            }
        }

        /**考勤 */
        if(!this.judgeFieldValueEmpty(result.promoterItem)){
            this.promoterItem = result.promoterItem;
        }else{
            this.promoterItem = this.handleAddObjectItemKey(this.promoterItem, 'Id', null);
            this.promoterItem = this.handleAddObjectItemKey(this.promoterItem, 'CheckInStatus__c', '未签到');
            this.promoterItem = this.handleAddObjectItemKey(this.promoterItem, 'CheckIn_Date__c', this.reportDate);
        };

        this.judgeIsAllowEditAddCheckTime();
        //this.isAllowEditAddCheckTime = this.judgeIsAllowEditAddCheckTime();
        /**周报 */
        //this.questionList = result.questionList;
        this.researchResponseId = this.researchResponseId;
        this.responseList = result.responseList;

        this.dayOfWeek = result.dayOfWeek;
        this.judgeIsLastDayOfWeek();
    }

    handleResetInputChange() {
        this.debugVariable("handleResetInputChange");
        //console.log("handleResetInputChange_reportDate:" + this.reportDate);
        this.existRecordId = null;
        this.changeReportDate = this.reportDate;
        this.changeShopId = this.shopId;
        if(this.isResetInput) {
            this.isResetInput = false;
        }else{
            this.isResetInput = true;
        }
    }

    handleSuccessInputChange() {
        //仅当新建时可正常更新
        //切换日期的时候，页面重新初始话
        this.recordId = null;
        this.reportDate = this.changeReportDate;
        this.shopId = this.changeShopId;

        //this.handleJumpNewWithChange();
    }

    handleDateFormat(dateItem) {
        if(this.judgeFieldValueEmpty(dateItem)){
            return null;
        }else{
            let dateList = dateItem.split("-");
            if(dateList[1].length == 1){
                dateList[1] = "0" + dateList[1];
            }
            if(dateList[2].length == 1){
                dateList[2] = "0" + dateList[2];
            }    
            return dateList.join("-");
        }

    }

    handleDuplicateCondition() {
        if(this.existRecordId == undefined || this.existRecordId == null || this.existRecordId ==""){
            this.recordId = null;
        }else{
            this.recordId = this.existRecordId;
        }
    }

    judgeIsNew() {
        if( 
            this.recordId == "" 
            || this.recordId == null 
            || this.recordId == undefined 
            ) {
            this.isNew = true;//新建或今日数据可编辑
        }else {
            this.isNew = false;
        }
    }

    judgeSaveReportRequirdFieldValue() {
        this.isShowTableRequiredError = true;
        this.retailSaleListError = null;
        this.productPriceListError = null;
        this.promoterItemError = null;
        this.responseListError = null;

        let errorFlag = false; //零售业绩，门店产品价格调查,周报反馈
        let errorStr = "";

        let activeSectionList = [];
        //保存时，报表日期和门店必填
        if(this.judgeFieldValueEmpty(this.reportDate) || this.judgeFieldValueEmpty(this.shopId)) {
            errorStr = errorStr + this.label.PromoterDailyReport_NOT_EMPTY_STORE_DATE + ";";
            errorFlag = true;
            //this.showNotification("", this.label.PromoterDailyReport_NOT_EMPTY_STORE_DATE, "error");
            //return false;
        }

        //零售业绩,Product__c,Number__c
        this.retailSaleList.forEach(item=> {
            // 当日実績なし勾选 不验证日业绩 （wfc）
            // if(!this.noPerformance){
                if(this.judgeFieldValueEmpty(item.Product__c)
                || this.judgeFieldValueEmpty(item.Number__c)){
                    this.retailSaleListError = this.label.PromoterDailyReport_CHECK_FIELD_ERROR ;
                    return false;
                }
            // }
           
        });


        if(this.retailSaleListError) {
            errorStr = errorStr + this.label.CheckInCheckOut_RETAIL_SALE + ";";
            errorFlag = true;
        }

        //门店产品价格调查，海信：Product__c,Price__c, 竞品：CP_Brand__c,CompetitiveProduct__c,Price__c必填
        let index = 1;
        this.productPriceList.forEach(item => {
            let cIndex = 1;
            item.IsActive = false;
            if(this.judgeFieldValueEmpty(item.RetailDetail.Product__c)
                || this.judgeFieldValueEmpty(item.RetailDetail.Price__c)
                || item.RetailDetail.Price__c == 0
                ) {
                this.productPriceListError = this.label.PromoterDailyReport_CHECK_FIELD_ERROR ;
                errorFlag = true;
            }
            item.ComtitiveShopRetailDetails.forEach(cItem => {
                if(this.judgeFieldValueEmpty(cItem.CP_Brand__c)
                    || this.judgeFieldValueEmpty(cItem.CompetitiveProduct__c)
                    || this.judgeFieldValueEmpty(cItem.Price__c)
                    || cItem.Price__c == 0
                    ) {
                    this.productPriceListError = this.label.PromoterDailyReport_CHECK_FIELD_ERROR ;
                    item.IsActive = true;
                    errorFlag = true;
                }
                cIndex ++;
            });
            index ++;
        })
        if(this.productPriceListError) {
            errorStr = errorStr + this.label.PromoterDailyReport_PRODUCT_PRICE + ";";
            errorFlag = true;
        }

        //考勤 如果允许编辑签到补签清空下，签到时间为空，则签到补签必填，若该情况签到补签为空则提示填写
        if(!this.isJapan && this.isAllowEdit && this.isAllowEditAddCheckTime 
            && (this.judgeFieldValueEmpty(this.promoterItem) || this.judgeFieldValueEmpty(this.promoterItem.SignInTime__c) )
            //&& (this.judgeFieldValueEmpty(this.promoterItem) || this.promoterItem.CheckInStatus__c != '已签到签退' && this.promoterItem.CheckInStatus__c != '已签到') 
            &&  (this.judgeFieldValueEmpty(this.supplementaryItem) || this.judgeFieldValueEmpty(this.supplementaryItem.Supplementary_SignIn_Time__c))) {
                this.promoterItemError = this.label.PromoterDailyReport_CHECK_EMPTY;
                errorStr = errorStr + this.label.PromoterDailyReport_CHECK_IN_STATUS + ";";
                errorFlag = true;
                console.log('isJapan' + this.isJapan);
            }

        //周调查
        // if(this.isWeekLastDay) {
            this.responseList.forEach(item=>{
                if(this.judgeFieldValueEmpty(item.Response__c) || this.judgeFieldValueEmpty(item.Response__c.trim())){
                    //允许编辑时，报表日期为星期最后一天 ，周报反馈必填    20240426,每日必填
                    this.responseListError = this.label.PromoterDailyReport_WEEK_PROBLEM_EMPTY ;
                    return false;
                }
            });
        // }
        if(this.responseListError) {
            errorStr = errorStr + this.label.PromoterDailyReport_WEEK_PROBLEM_EMPTY;
            errorFlag = true;
        }

        if(errorFlag) {
            this.showNotification("",this.label.PromoterDailyReport_SAVE_FAIL + "：" + errorStr,"error");
            return false;
        }
        return true;
    }

    judgeFieldValueEmpty(fieldValue){
        if(fieldValue == undefined || fieldValue == null || fieldValue == "") {
            return true;
        }else{
            return false;
        }
    }
    //处理数组对象字段值变更
    handleAddObjectKey(itemList, index , fieldName, fieldValue) {
        this.isEdit = true;
        itemList[index][fieldName] = fieldValue;
        console.log("After change:");
        console.log(JSON.stringify( itemList) );
        return itemList;
    }
    //处理对象字段值变更
    handleAddObjectItemKey(item, fieldName, fieldValue) {
        this.isEdit = true;
        item[fieldName] = fieldValue;
        console.log("After change:");
        console.log(JSON.stringify( item) );
        return item
    }
    //处理删除Id
    handleDeleteRecord(item) {
        this.isEdit = true;
        if(this.deleteIdList.indexOf(item.Id)>=0 || item.Id == null || item.Id == undefined || item.Id == ""){
            return;
        }else{
            this.deleteIdList.push(item.Id);
            console.log(this.deleteIdList.indexOf(item.Id));
        }
        console.log(JSON.stringify(this.deleteIdList) );
    }

    judgeIsRelatedToRecord(){
        
        if(!this.judgeFieldValueEmpty(this.promoterItem.Id)&&!this.judgeFieldValueEmpty()){
            
        }
    }

    judgeIsAllowEditAddCheckTime(){
        if(this.reportDate == this.thisDay) {
            this.isToday = true;
        }
        if(this.isAllowEdit == true && 
            (this.judgeFieldValueEmpty(this.promoterItem.ApprovalStatus__c) || this.promoterItem.ApprovalStatus__c == '未创建' || this.promoterItem.ApprovalStatus__c == '补签申请审批通过')) {
            this.isAllowEditAddCheckTime = true;
        }
    }

    judgeIsLastDayOfWeek() {
        if( this.dayOfWeek==7 ){
            this.activeSections = ['weeklyReportQuestions'];
            this.isWeekLastDay = true;
        }else{
            this.isWeekLastDay = false;
        }
        this.isWeekLastDay = false;
    }


    debugVariable(functionName) {
        console.log("----------------"+functionName+"------------------");
        console.log("this.shopId:" + this.shopId);
        console.log("this.recordId:" + this.recordId);
        console.log("this.reportDate:" + this.reportDate);
        console.log("this.changeShopId:" + this.changeShopId);
        console.log("this.changeReportDate:" + this.changeReportDate);
        console.log("this.isJapan" + this.isJapan);
    }

    

}