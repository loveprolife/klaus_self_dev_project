/*
 * @Author: YYL
 * @LastEditors: TJP
 */
import { wire , track, api} from 'lwc';
import { LightningNavigationElement, readFile } from 'c/lwcUtils'
import { refreshApex } from '@salesforce/apex';
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Inspection_Completed from '@salesforce/label/c.Inspection_Completed';
import INSPECTION_REPORT_SUBMIT from '@salesforce/label/c.INSPECTION_REPORT_SUBMIT';
import Patrol_Mode_Switch from '@salesforce/label/c.Patrol_Mode_Switch';
import INSPECTION_REPORT_BACK from '@salesforce/label/c.INSPECTION_REPORT_BACK';
import submitInspectionProductItem from '@salesforce/apex/NewInspectionDailyReportPageController.submitInspectionProductItem';
import getProductLineCheckItemNumber from '@salesforce/apex/NewInspectionDailyReportPageController.getProductLineCheckItemNumber';
import changeInspectionProductItem from '@salesforce/apex/NewInspectionDailyReportPageController.changeInspectionProductItem';
import upsertPatrolMode from '@salesforce/apex/NewInspectionDailyReportPageController.upsertPatrolMode';
import getCategoryType from '@salesforce/apex/newCheckItemController.getCategoryType';
import Inspection_Ticket from '@salesforce/label/c.Inspection_Ticket';
import Inspection_Booth from '@salesforce/label/c.Inspection_Booth';
import Inspection_Competing_Goods from '@salesforce/label/c.Inspection_Competing_Goods';
import Inspection_Material from '@salesforce/label/c.Inspection_Material';
import Inspection_Prototype from '@salesforce/label/c.Inspection_Prototype';
import Inspection_Prototype_Booth from '@salesforce/label/c.Inspection_Prototype_Booth';
import Inspection_Dishwasher from '@salesforce/label/c.Inspection_Dishwasher';
import Inspection_WM from '@salesforce/label/c.Inspection_WM';
import Inspection_TV from '@salesforce/label/c.Inspection_TV';
import Inspection_Laser_TV from '@salesforce/label/c.Inspection_Laser_TV';
import Inspection_Cooking from '@salesforce/label/c.Inspection_Cooking';
import Inspection_Refrigerator from '@salesforce/label/c.Inspection_Refrigerator';
import Inspection_Freezer from '@salesforce/label/c.Inspection_Freezer';
import Inspection_Sound_Bar  from '@salesforce/label/c.Inspection_Sound_Bar';
import Inspection_Switching_Template  from '@salesforce/label/c.Inspection_Switching_Template';
import Inspection_Speak_With_the_Store_Leader_Check  from '@salesforce/label/c.Inspection_Speak_With_the_Store_Leader_Check';
import Inspection_Competing_Goods_Check  from '@salesforce/label/c.Inspection_Competing_Goods_Check';
import Inspection_Prototype_Check  from '@salesforce/label/c.Inspection_Prototype_Check';
import Inspection_Booth_Check  from '@salesforce/label/c.Inspection_Booth_Check';
import Inspection_Material_Check  from '@salesforce/label/c.Inspection_Material_Check';
import Inspection_Ticket_Check  from '@salesforce/label/c.Inspection_Ticket_Check';
import Inspection_Prototype_Booth_Check  from '@salesforce/label/c.Inspection_Prototype_Booth_Check';
import Inspection_Sampling_Inspection_Check  from '@salesforce/label/c.Inspection_Sampling_Inspection_Check';
import Inspection_Save_Page  from '@salesforce/label/c.Inspection_Save_Page';
import Inspection_Save_This_Page  from '@salesforce/label/c.Inspection_Save_This_Page';
import CHECK_PRODUCT_LINE_MSG_SUBMIT from '@salesforce/label/c.CHECK_PRODUCT_LINE_MSG_SUBMIT';
import All_Product_Lines from '@salesforce/label/c.All_Product_Lines';



export default class NewInspectorReportProductDetailPageLwc extends LightningNavigationElement {

    label = {
        Inspection_Completed,
        INSPECTION_REPORT_SUBMIT,
        INSPECTION_REPORT_BACK,
        Patrol_Mode_Switch,
        Inspection_Ticket,
        Inspection_Booth,
        Inspection_Competing_Goods,
        Inspection_Material, 
        Inspection_Prototype,
        Inspection_Prototype_Booth,
        Inspection_Dishwasher,
        Inspection_WM,
        Inspection_TV,
        Inspection_Laser_TV,
        Inspection_Cooking,
        Inspection_Refrigerator,
        Inspection_Freezer, 
        Inspection_Sound_Bar,
        Inspection_Switching_Template,
        Inspection_Speak_With_the_Store_Leader_Check,
        Inspection_Ticket_Check,
        Inspection_Prototype_Booth_Check,
        Inspection_Material_Check,
        Inspection_Booth_Check,
        Inspection_Prototype_Check,
        Inspection_Competing_Goods_Check,
        Inspection_Sampling_Inspection_Check,
        Inspection_Save_Page,
        Inspection_Save_This_Page,
        CHECK_PRODUCT_LINE_MSG_SUBMIT,
        All_Product_Lines
    }

    @api productLine;
    @api recordId;
    @api recordItemId;
    @api storeId;
    @api status;
    @api uniteLaserTV;

    @track showSubmit = true;
    @track showSwitch = true;

    // 是否提交
    @track isSubmit = false;
    @track showProductLine = true;
    @track showItemIssues = false;

    @track isShowSpinner = false;

    @track hasEdit = false;

    @track inspectionItemlabel;
    @track inspectionItemName;

    // TJP 20241107 新增页面TITLE 文案
    @track inspectionTitlelabel;

    // 必填项未填写检查项名称
    @track checkRequiredItem = ['Sales'];
    @track categoryType;//可展示的大类信息 YYL 20250310

    // 展示检查项
    @track showInspectionItem = false;

    @track showCompetitive = false;
    @track showInventory = false;
    @track showSamplingInspection = false;
    @track showCheckListItem = false; //20241029 TJP
    @track showTicket = false;

    @track intelligenceCheckNumber;
    @track intelligenceCanadaCheck;
    @track inventoryCheckNumber;
    @track speakWithCheckInfo;
    @track trainingCheckInfo;
    @track salesCheckInfo;
    @track weeklyCheckInfo;
    @track brandCheckInfo;
    @track sampleCondtionCheckInfo;
    @track materialDisplayCheckInfo;
    @track boothCheckInfo;
    @track samplingCheckInfo;
    @track ticketCheckInfo;

    // 是否已检查完毕
    @track isIntelligenceCheck = true;
    @track isIntelligenceCanadaCheck = true;
    @track isInventoryCheck = true;
    @track isSpeakWithCheck = true;
    @track isTrainingCheck = true;
    @track isSalesCheck = true;
    @track isWeeklyCheck = true;
    @track isBrandCheck = true;
    @track isSampleCondtionCheck = true;
    @track isMaterialDisplayCheck = true;
    @track isBoothCheck = true;
    @track isSamplingCheck = true;
    @track isTicketCheck = true;

    // 是否展示检查项
    @track isShowSpeakWithCheck;
    @track isShowTrainingCheck;
    @track isShowCheckList;
    @track isShowSalesCheck;
    @track isShowWeeklyCheck;
    @track isShowBrandCheck;
    @track isShowSampleConditionCheck;
    @track isShowMaterialDisplayCheck;
    @track isShowBoothCheck;
    @track isShowIntelligenceCheck;
    @track isShowIntelligenceCanadaCheck;
    @track isShowInventoryCheck;
    @track isShowSamplingCheck;
    @track isShowTicketCheck;

    // 20241029 TJP 新增
    @track isShowPrototypeCheck;
    @track isShowMaterialCheck;
    @track isShowCompetingGoodsCheck;
    @track prototypeCheckInfo;
    @track materialCheckInfo;
    @track competingGoodsCheckInfo;
    @track isMaterialCheck = true;
    @track isPrototypeCheck = true;
    @track isCompetingGoodsCheck = true;
    @track isUnitCheck = true;
    @track isCompetingGoodsCheckFillIn;
    @track isMaterialCheckFillIn;
    @track isPrototypeCheckFillIn;
    @track isBoothCheckFillIn;
    @track isShowPrototypeAndBoothCheck;
    @track isPrototypeAndBoothFillIn;
    @track PrototypeAndBoothCheckInfo;

    //20250218 TJP 新增
    @track isShowXPlanCheck;
    //新增照片大类 YYL 20250220 
    @track isShowPhotoCheck;
    @track xPlanCheckInfo = '('+ 0 +'/'+ 0 +')';


    @track isTicketCheckFillIn;
    @track isSamplingCheckFillIn;

    @track itemType;
    @track region;

    @track isInitCheckResult = {}; //TJP 检查项是否触发过初始化

    // 自定义弹框
    @track modalMsg;
    @track modalType;
    @track modalHelper;
    handleShow(msg, type, hepler) {
        console.log('handleShow');
        let ele = this.template.querySelector('c-modal-lwc');
        if (ele!=null) {
            this.modalMsg = msg;
            this.modalType = type;
            this.modalHelper = hepler;
            ele.showModal(this.template);
        } else {
            console.log('c-modal-lwc is null');
        }
    }
    handleOk() {
        this.template.querySelector('c-modal-lwc').closeModal();

        // 调用子页面保存方法
        this.template.querySelector(this.modalHelper).handleSave();
        this.hasEdit = false;
        this[this.modalType]();
    }

    handleCancel() {
        this.template.querySelector('c-modal-lwc').closeModal();
        this.hasEdit = false;
        this[this.modalType]();
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
    
    // 初始化
    connectedCallback() {
        this.isShowSpinner = true;
        console.log('productline    ' + this.productLine);
        console.log('recordId    ' + this.recordId);
        console.log('storeId    ' + this.storeId);
        console.log('status    ' + this.status);
        console.log('uniteLaserTV    ' + this.uniteLaserTV);

        console.log('fffffff-----' + this.recordId);
        console.log('fffffff-----' + this.recordItemId);
        console.log('fffffff-----' + this.storeId);
        console.log('fffffff-----' + this.productLine);
        console.log('fffffff-----' + this.inspectionItemlabel);
        console.log('fffffff-----' + this.inspectionItemName);
        console.log('fffffff-----' + this.status);
        console.log('fffffff-----' + this.isSubmit);

        // 取消下拉刷新
        this.disablePullToRefresh();
        this.handleSetLinesOption(this.productLine);

        // 根据状态判断是否展示提交按钮
        if(this.status == 'Submitted'){
            this.isSubmit = true;
            this.showSubmit = false;
            this.showSwitch = false;
        }

        this.getCategoryTypeInfo();
        // this.getCheckItemNumber();
        
    }

    @track pickList;
    // 获取当前检查项展示的大类信息 YYL 20250310
    getCategoryTypeInfo(){
        getCategoryType({
            recordId:this.recordItemId,
            productLine:this.productLine,
            storeId:this.storeId,
            status:this.status
        }).then(data => {
            console.log('wwwwgetCategoryType' + JSON.stringify(data.data));
            if(data.data.category){
                this.categoryType = data.data.category;

                // 处理展示数据 YYL 20250311
                this.pickList = data.data.pickList;
                this.categoryType.forEach(item => {
                    let category = item.categoryRelationship.Category_Type__c;
                    let categoryLabel = this.pickList[category];
                    item.name = categoryLabel;
                });
            }

            var salesRegion = data.data.salesRegion;
                
            this.region = salesRegion;
            if(salesRegion == 'Hisense International' && this.uniteLaserTV){
                upsertPatrolMode({
                    recordId: this.recordItemId,
                    patrolMode: this.uniteLaserTV
                }).then(data => {
                    console.log('upsertPatrolMode' + JSON.stringify(data));
                });
            }

            if(salesRegion != 'Hisense International'){
                this.showSwitch = false;
            }

            this.isShowSpinner = false;

        }).catch(error => {
            this.isShowSpinner = false;
            this.catchError(error);
        })
    }

    getCheckItemNumber(){
        console.log('getCheckItemNumber');
        this.isShowSpinner = true;
        getProductLineCheckItemNumber({
            recordId:this.recordItemId,
            productLine:this.productLine,
            storeId:this.storeId
        }).then(data => {

            var salesRegion = data.data.salesRegion;
            this.region = salesRegion;
            console.log('获取SalesRegion' + salesRegion);
            if(salesRegion == 'Hisense International' && this.uniteLaserTV){
                upsertPatrolMode({
                    recordId: this.recordItemId,
                    patrolMode: this.uniteLaserTV
                }).then(data => {
                    console.log('upsertPatrolMode' + JSON.stringify(data));
                });
            }

            if(salesRegion == 'Hisense X') {
                let MaterialsNumber = data.data.MaterialNumber;
                let MaterialsCheckTotal = MaterialsNumber.checkTotal;
                let MaterialsCheckNumber = MaterialsNumber.checkNumber;

                let ticketCheck = data.data.ticketCheckNumber;
                let ticketCheckTotal = ticketCheck.checkTotal;
                let ticketCheckNumber = ticketCheck.checkNumber;

                this.isShowMaterialCheck = true;
                this.isShowXPlanCheck = true;
                this.isShowPhotoCheck = true;
                this.isShowTicketCheck = true;
                this.showSwitch = false;

            } else 
            //对总部代码进行包裹
            if(salesRegion == 'Hisense International') {
                //Material TJP 20241030 
                let MaterialsNumber = data.data.MaterialNumber;
                let MaterialsCheckTotal = MaterialsNumber.checkTotal;
                let MaterialsCheckNumber = MaterialsNumber.checkNumber;
                
                let PrototypeNumber = data.data.PrototypeNumber;
                let PrototypeCheckTotal = PrototypeNumber.checkTotal;
                let PrototypeCheckNumber = PrototypeNumber.checkNumber;
                
                let samplingCheckListNumbers = data.data.samplingCheckListNumber;
                let samplingCheckListTotal = samplingCheckListNumbers.checkTotal;
                let samplingCheckListNumber = samplingCheckListNumbers.checkNumber;
                
                let CompetingGoodsNumber = data.data.CompetingGoodsNumber;
                let CompetingGoodCheckTotal = CompetingGoodsNumber.checkTotal;
                let CompetingGoodCheckNumber = CompetingGoodsNumber.checkNumber;
                
                // this.isPrototypeAndBoothFillIn
                let samplingUniteNumber = data.data.samplingUniteNumber;
                let samplingUniteCheckTotal = samplingUniteNumber.checkTotal;
                let samplingUniteCheckNumber = samplingUniteNumber.checkNumber;

                    // Booth
                let BoothNumber = data.data.BoothNumber;
                let BoothCheckTotal = BoothNumber.checkTotal;
                let BoothCheckNumber = BoothNumber.checkNumber;

                // Ticket
                let ticketCheck = data.data.ticketCheckNumber;
                let ticketCheckTotal = ticketCheck.checkTotal;
                let ticketCheckNumber = ticketCheck.checkNumber;
                
                console.log('samplingCheckListNumbers' + JSON.stringify(samplingCheckListNumbers));
                console.log('PrototypeNumber' + JSON.stringify(PrototypeNumber));
                console.log('MaterialsNumber' + JSON.stringify(MaterialsNumber));
                console.log('BoothNumber' + JSON.stringify(BoothNumber));
                console.log('CompetingGoodNumber' + JSON.stringify(CompetingGoodsNumber));

                if(salesRegion == 'Hisense International') {
                    if(this.uniteLaserTV == 'Routine') {
                        //展示Ticket ，样机，物料，展台
                        this.isShowPrototypeCheck = true;
                        this.isShowMaterialCheck = true;
                        this.isShowBoothCheck = true;
                        this.isShowTicketCheck = true;
                        this.isShowPrototypeAndBoothCheck = false;
                    } else {
                        this.isShowPrototypeCheck = false;
                        this.isShowMaterialCheck = false;
                        this.isShowBoothCheck = false;
                        this.isShowPrototypeAndBoothCheck = true;
                        this.isShowTicketCheck = false;
                    }

                    if(this.productLine == 'Laser TV' || this.productLine == 'Sound Bar') {
                        this.isShowCompetingGoodsCheck = true;
                    } else {
                        this.isShowCompetingGoodsCheck = false;
                    }
                } 

                //TJP 20250218 进行四期页面 增加
                // if(salesRegion == 'Hisense X') {
                    // this.isShowXPlanCheck = true;
                // } else {
                //     this.isShowXPlanCheck = false;
                // }

                if(this.isShowTicketCheck){
                    this.ticketCheckInfo = '('+ ticketCheckNumber +'/'+ ticketCheckTotal +')';
    
                    // 根据检查数和总数检验是否有未检查必填项
                    if(parseInt(ticketCheckNumber) == parseInt(ticketCheckTotal)){
                        this.isTicketCheck = true;
                        this.isTicketCheckFillIn = true;
                        if(parseInt(ticketCheckTotal) == 0 ){
                            this.isTicketCheckFillIn = false;
                        }
                        
                    }else{
                        this.isTicketCheck = false;
                        this.isTicketCheckFillIn = false;
                    }
                }

                if(this.isShowBoothCheck){
                    this.boothCheckInfo = '('+ BoothCheckNumber +'/'+ BoothCheckTotal +')';
    
                    // 根据检查数和总数检验是否有未检查必填项
                    if(parseInt(BoothCheckNumber) == parseInt(BoothCheckTotal)){
                        this.isBoothCheck = true;
                        this.isBoothCheckFillIn = true;
                        if(parseInt(BoothCheckTotal) == 0 ){
                            this.isBoothCheckFillIn = false;
                        }
                    }else{
                        this.isBoothCheck = false;
                        this.isBoothCheckFillIn = false;
                    }
    
                } else {
                    this.isBoothCheck = true;
                }
                
                if(this.isShowMaterialCheck){
    
                    this.materialCheckInfo = '('+ MaterialsCheckNumber +'/'+ MaterialsCheckTotal +')';
    
                    // 根据检查数和总数检验是否有未检查必填项
                    if(parseInt(MaterialsCheckNumber) == parseInt(MaterialsCheckTotal)){
                        this.isMaterialCheck = true;
                        this.isMaterialCheckFillIn = true;
                        if(parseInt(MaterialsCheckTotal) == 0 ){
                            this.isMaterialCheckFillIn = false;
                        }
                    }else{
                        this.isMaterialCheck = false;
                        this.isMaterialCheckFillIn = false;
    
                    }
                } else {
                    this.isMaterialCheck = true;
                }
    
                
                if(this.isShowPrototypeCheck){
    
                    this.prototypeCheckInfo = '('+ (parseInt(PrototypeCheckNumber) + parseInt(samplingCheckListNumber)) +'/'+ (parseInt(PrototypeCheckTotal) + parseInt(samplingCheckListTotal)) +')';
    
                    // 根据检查数和总数检验是否有未检查必填项
                    if(parseInt(PrototypeCheckNumber) == parseInt(PrototypeCheckTotal)){
                        this.isPrototypeCheck = true;
                        this.isPrototypeCheckFillIn = true;
                        if(parseInt(PrototypeCheckTotal) == 0 ){
                            this.isPrototypeCheckFillIn = false;
                        }
                    }else{
                        this.isPrototypeCheck = false;
                        this.isPrototypeCheckFillIn = false;
                    }
                } else {
                    this.isPrototypeCheck = true;
                }
    
                if(this.isShowCompetingGoodsCheck){
    
                    this.competingGoodsCheckInfo = '('+ CompetingGoodCheckNumber +'/'+ CompetingGoodCheckTotal +')';
    
                    // 根据检查数和总数检验是否有未检查必填项
                    if(parseInt(CompetingGoodCheckNumber) == parseInt(CompetingGoodCheckTotal)){
                        this.isCompetingGoodsCheck = true;
                        this.isCompetingGoodsCheckFillIn = true;
                        if(parseInt(CompetingGoodCheckTotal) == 0 ){
                            this.isCompetingGoodsCheckFillIn = false;
                        }
                    }else{
                        this.isCompetingGoodsCheck = false;
                        this.isCompetingGoodsCheckFillIn = false;
    
                    }
                }
    
                if(this.isShowPrototypeAndBoothCheck){
    
                    this.PrototypeAndBoothCheckInfo = '('+ samplingUniteCheckNumber +'/'+ samplingUniteCheckTotal +')';
    
                    // 根据检查数和总数检验是否有未检查必填项
                    if(parseInt(samplingUniteCheckNumber) == parseInt(samplingUniteCheckTotal)){
                        this.isUnitCheck = true;
                        this.isPrototypeAndBoothFillIn = true;
                        if(parseInt(CompetingGoodCheckTotal) == 0 ){
                            this.isPrototypeAndBoothFillIn = false;
                        }
                    }else{
                        this.isUnitCheck = false;
                        this.isPrototypeAndBoothFillIn = false;
    
                    }
                }

            }  else {
            this.showSwitch = false;

            // Competition Intelligence
            // 设置检查项已检查数和总数
            let intelligenceCheck = data.data.intelligenceCheckNumber;
            // 需检查总数
            let intelligenceCheckTotal = intelligenceCheck.checkTotal;
            // 已检查数
            let intelligenceCheckNumber = intelligenceCheck.checkNumber;

            // Competition Intelligence Canada
            let intelligenceCanadaCheck = data.data.intelligenceCanadaCheck;
            let intelligenceCanadaCheckTotal = intelligenceCanadaCheck.checkTotal;
            let intelligenceCanadaCheckNumber = intelligenceCanadaCheck.checkNumber;

            // Inventory
            let inventoryCheck = data.data.inventoryCheckNumber;
            let inventoryCheckTotal = inventoryCheck.checkTotal;
            let inventoryCheckNumber = inventoryCheck.checkNumber;

            // Speak With the Store Leader
            let speakWithCheck = data.data.speakWithCheckNumber;
            let speakWithCheckTotal = speakWithCheck.checkTotal;
            let speakWithCheckNumber = speakWithCheck.checkNumber;

            // Training
            let trainingCheck = data.data.trainingCheckNumber;
            let trainingCheckTotal = trainingCheck.checkTotal;
            let trainingCheckNumber = trainingCheck.checkNumber;

            // Sales
            let salesCheck = data.data.salesCheckNumber;
            let salesCheckTotal = salesCheck.checkTotal;
            let salesCheckNumber = salesCheck.checkNumber;

            // Weekly Asks from Best Buy
            let weeklyCheck = data.data.weeklyCheckNumber;
            let weeklyCheckTotal = weeklyCheck.checkTotal;
            let weeklyCheckNumber = weeklyCheck.checkNumber;

            // Brand Feedback
            let brandFeedBackCheckNumber = data.data.brandFeedBackCheckNumber;
            let brandCheckTotal = brandFeedBackCheckNumber.checkTotal;
            let brandCheckNumber = brandFeedBackCheckNumber.checkNumber;

            // Sample Condition
            let sampleConditionNumber = data.data.sampleConditionCheckNumber;
            let sampleConditionCheckTotal = sampleConditionNumber.checkTotal;
            let sampleConditionCheckNumber = sampleConditionNumber.checkNumber;

            // Material Display
            let materialDisplayCheckNumber = data.data.materialDisplayCheckNumber;
            let materialCheckTotal = materialDisplayCheckNumber.checkTotal;
            let materialCheckNumber = materialDisplayCheckNumber.checkNumber;

            // Booth
            let BoothNumber = data.data.BoothNumber;
            let BoothCheckTotal = BoothNumber.checkTotal;
            let BoothCheckNumber = BoothNumber.checkNumber;

            // Sampling Inspection
            let samplingCheck = data.data.samplingCheckNumber;
            let samplingCheckTotal = samplingCheck.checkTotal;
            let samplingCheckNumber = samplingCheck.checkNumber;

            // Ticket
            let ticketCheck = data.data.ticketCheckNumber;
            let ticketCheckTotal = ticketCheck.checkTotal;
            let ticketCheckNumber = ticketCheck.checkNumber;

            // 根据问题总数判断是否展示检查项
            if(parseInt(speakWithCheckTotal) > 0){

                this.isShowSpeakWithCheck = true;

                this.speakWithCheckNumber = '('+ speakWithCheckNumber +'/'+ speakWithCheckTotal +')';

                console.log('speakWithCheckNumber' + this.speakWithCheckNumber);

                // 根据检查数和总数检验是否有未检查必填项
                if(parseInt(speakWithCheckNumber) == parseInt(speakWithCheckTotal)){
                    this.isSpeakWithCheck = true;
                }else{
                    this.isSpeakWithCheck = false;
                }

            }else{
                this.isShowSpeakWithCheck = false;
            }

            if(parseInt(trainingCheckTotal) > 0){

                this.isShowTrainingCheck = true;

                this.trainingCheckInfo = '('+ trainingCheckNumber +'/'+ trainingCheckTotal +')';

                // 根据检查数和总数检验是否有未检查必填项
                if(parseInt(trainingCheckNumber) == parseInt(trainingCheckTotal)){
                    this.isTrainingCheck = true;
                }else{
                    this.isTrainingCheck = false;
                }

            }else{
                this.isShowTrainingCheck = false;
            }

            if(parseInt(salesCheckTotal) > 0){

                this.isShowSalesCheck = true;

                this.salesCheckInfo = '('+ salesCheckNumber +'/'+ salesCheckTotal +')';

                // 根据检查数和总数检验是否有未检查必填项
                if(parseInt(salesCheckNumber) == parseInt(salesCheckTotal)){
                    this.isSalesCheck = true;
                }else{
                    this.isSalesCheck = false;
                }

            }else{
                this.isShowSalesCheck = false;
            }

            if(parseInt(weeklyCheckTotal) > 0){

                this.isShowWeeklyCheck = true;

                this.weeklyCheckInfo = '('+ weeklyCheckNumber +'/'+ weeklyCheckTotal +')';

                // 根据检查数和总数检验是否有未检查必填项
                if(parseInt(weeklyCheckNumber) == parseInt(weeklyCheckTotal)){
                    this.isWeeklyCheck = true;
                }else{
                    this.isWeeklyCheck = false;
                }

            }else{
                this.isShowWeeklyCheck = false;
            }

            if(parseInt(brandCheckTotal) > 0){

                this.isShowBrandCheck = true;

                this.brandCheckInfo = '('+ brandCheckNumber +'/'+ brandCheckTotal +')';

                // 根据检查数和总数检验是否有未检查必填项
                if(parseInt(brandCheckNumber) == parseInt(brandCheckTotal)){
                    this.isBrandCheck = true;
                }else{
                    this.isBrandCheck = false;
                }

            }else{
                this.isShowBrandCheck = false;
            }

            if(parseInt(sampleConditionCheckTotal) > 0){

                this.isShowSampleConditionCheck = true;

                this.sampleCondtionCheckInfo = '('+ sampleConditionCheckNumber +'/'+ sampleConditionCheckTotal +')';

                console.log('sampleCondtionCheckInfo' + this.sampleCondtionCheckInfo);
                // 根据检查数和总数检验是否有未检查必填项
                if(parseInt(sampleConditionCheckNumber) == parseInt(sampleConditionCheckTotal)){
                    this.isSampleCondtionCheck = true;
                }else{
                    this.isSampleCondtionCheck = false;
                }

            }else{
                this.isShowSampleConditionCheck = false;
            }

            if(parseInt(materialCheckTotal) > 0){

                this.isShowMaterialDisplayCheck = true;

                this.materialDisplayCheckInfo = '('+ materialCheckNumber +'/'+ materialCheckTotal +')';

                // 根据检查数和总数检验是否有未检查必填项
                if(parseInt(materialCheckNumber) == parseInt(materialCheckTotal)){
                    this.isMaterialDisplayCheck = true;
                }else{
                    this.isMaterialDisplayCheck = false;
                }

            }else{
                this.isShowMaterialDisplayCheck = false;
            }

            //TJP 20241105 edit 保持原计算值逻辑 非总部的情况下 用于展示或隐藏booth 新逻辑按照的总部salesRegion直接展示
            if(salesRegion != 'Hisense International'){
                if(parseInt(BoothCheckTotal) > 0){

                    this.isShowBoothCheck = true;

                    this.boothCheckInfo = '('+ BoothCheckNumber +'/'+ BoothCheckTotal +')';

                    // 根据检查数和总数检验是否有未检查必填项
                    if(parseInt(BoothCheckNumber) == parseInt(BoothCheckTotal)){
                        this.isBoothCheck = true;
                    }else{
                        this.isBoothCheck = false;
                    }

                }else{
                    this.isShowBoothCheck = false;
                }
            }

            // 根据产品线和salesregion信息设置checkitem之外检查项展示权限
            if(salesRegion == 'Hisense USA'){
                this.isShowSamplingCheck = true;
                this.isShowTicketCheck = true;
                this.isShowIntelligenceCanadaCheck = false;
                if(this.productLine == 'TV'){
                    this.isShowIntelligenceCheck = true;
                    this.isShowInventoryCheck = true;
                }else{
                    this.isShowIntelligenceCheck = false;
                    this.isShowInventoryCheck = false;
                }
            }else if(salesRegion == 'Hisense Canada'){
                this.isShowSamplingCheck = true;
                this.isShowTicketCheck = true;
                this.isShowIntelligenceCheck = false;
                this.isShowIntelligenceCanadaCheck = true;
                this.isShowInventoryCheck = false;
            }else if(salesRegion == 'Hisense Peru'){
                this.isShowIntelligenceCheck = false;
                this.isShowInventoryCheck = false;
                this.isShowIntelligenceCanadaCheck = false;
                // 秘鲁新增ticket检查项 20241121 YYL
                this.isShowTicketCheck = true;
                this.isShowSamplingCheck = true;
                this.isShowSampleConditionCheck = true;
                this.isShowMaterialDisplayCheck = true;
                this.isShowBoothCheck = true;
                
            } //20241029 TJP 新增 总部巡店
            else if(salesRegion == 'Hisense International') {
                if(this.uniteLaserTV == 'Routine') {
                    //展示Ticket ，样机，物料，展台
                    this.isShowPrototypeCheck = true;
                    this.isShowMaterialCheck = true;
                    this.isShowBoothCheck = true;
                    this.isShowCompetingGoodsCheck = true;
                    this.isShowTicketCheck = true;
                    this.isShowPrototypeAndBoothCheck = false;
                } else {
                    this.isShowPrototypeCheck = false;
                    this.isShowMaterialCheck = false;
                    this.isShowBoothCheck = false;
                    this.isShowCompetingGoodsCheck = true;
                    this.isShowPrototypeAndBoothCheck = true;
                    this.isShowTicketCheck = false;
                }
            }if(salesRegion == 'Hisense Mexico'){//YYL 新增墨西哥模块 20250228
                this.isShowSamplingCheck = true;
                this.isShowTicketCheck = true;
                this.isShowIntelligenceCanadaCheck = false;
                if(this.productLine == 'TV'){
                    this.isShowIntelligenceCheck = true;
                    this.isShowInventoryCheck = true;
                }else{
                    this.isShowIntelligenceCheck = false;
                    this.isShowInventoryCheck = false;
                }
            }

            if(this.isShowIntelligenceCheck){
                // 拼接展示数字
                this.intelligenceCheckNumber = '('+ intelligenceCheckNumber +'/'+ intelligenceCheckTotal +')';

                // 根据检查数和总数检验是否有未检查必填项
                if(parseInt(intelligenceCheckNumber) == parseInt(intelligenceCheckTotal)){
                    this.isIntelligenceCheck = true;
                }else{
                    this.isIntelligenceCheck = false;
                }
            }

            if(this.isShowIntelligenceCanadaCheck){
                // 拼接展示数字
                this.intelligenceCanadaCheck = '('+ intelligenceCanadaCheckNumber +'/'+ intelligenceCanadaCheckTotal +')';

                // 根据检查数和总数检验是否有未检查必填项
                if(parseInt(intelligenceCanadaCheckNumber) == parseInt(intelligenceCanadaCheckTotal)){
                    this.isIntelligenceCanadaCheck = true;
                }else{
                    this.isIntelligenceCanadaCheck = false;
                }
            }

            if(this.isShowInventoryCheck){
                this.inventoryCheckNumber = '('+ inventoryCheckNumber +'/'+ inventoryCheckTotal +')';

                // 根据检查数和总数检验是否有未检查必填项
                if(parseInt(inventoryCheckNumber) == parseInt(inventoryCheckTotal)){
                    this.isInventoryCheck = true;
                }else{
                    this.isInventoryCheck = false;
                }
            }

            if(this.isShowSamplingCheck){
                this.samplingCheckInfo = '('+ samplingCheckNumber +'/'+ samplingCheckTotal +')';

                // 根据检查数和总数检验是否有未检查必填项
                if(parseInt(samplingCheckNumber) == parseInt(samplingCheckTotal)){
                    this.isSamplingCheck = true;
                    this.isSamplingCheckFillIn = true;
                    if(parseInt(samplingCheckTotal) == 0 ){
                        this.isSamplingCheckFillIn = false;
                    }
                }else{
                    this.isSamplingCheck = false;
                    this.isSamplingCheckFillIn = false;
                }
            }

            if(this.isShowTicketCheck){
                this.ticketCheckInfo = '('+ ticketCheckNumber +'/'+ ticketCheckTotal +')';

                // 根据检查数和总数检验是否有未检查必填项
                if(parseInt(ticketCheckNumber) == parseInt(ticketCheckTotal)){
                    this.isTicketCheck = true;
                    this.isTicketCheckFillIn = true;
                    if(parseInt(ticketCheckTotal) == 0 ){
                        this.isTicketCheckFillIn = false;
                    }
                    
                }else{
                    this.isTicketCheck = false;
                    this.isTicketCheckFillIn = false;
                }
            }

            }

            console.log('isShowBrandCheck' + this.isShowBrandCheck);

            this.isShowSpinner = false;
        })
    }

    handleShowInspectionItem(event) {
        let label = event.target.dataset.name;
        let name = this.pickList[label];
        console.log('wwwwwhandleShowInspectionItem' + label);
        console.log('wwwwwhandleShowInspectionItem' + name);
        this.inspectionItemlabel = label;
        this.inspectionItemName = name;
        if(label == 'Ticket'){
            this.handleShowTicket(); 
        }else if(label == 'Sampling Product Check'){
            this.handleShowSamplingInspection();
        }else{
            if(this.region == 'Hisense International') {
                this.showProductLine = false;
                this.showCheckListItem = true;
                this.handleSwitchTitleLanguage(name);
                console.log('mingzi' + name);
            } else {
                this.showProductLine = false;
                this.showInspectionItem = true;
                console.log('当前选择的Label名称' + name);
            }
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        flag : false
                    }
                })
            );
        }
    }

    handleCloseInspectionItem() {

        if(this.hasEdit){
            this.handleShow(Inspection_Save_Page,'handleCloseInspectionItem','c-new-inspection-item-page-lwc');
        }else{
            this.showProductLine = true;
            this.showInspectionItem = false;

            // 返回父级元素页面
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        flag : true
                    }
                })
            );

            // 刷新数据
            // refreshApex(this.wiredResult);
        }
    }

    // 20241029 TJP 关闭子页面
    handleCloseCheckListItem() {

        if(this.hasEdit){
            this.handleShow(Inspection_Save_This_Page,'handleCloseCheckListItem','c-new-inspection-check-list-lwc2');
        }else{
            this.showProductLine = true;
            this.showCheckListItem = false;

            // 返回父级元素页面
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        flag : true
                    }
                })
            );

            // 刷新数据
            // refreshApex(this.wiredResult);
        }
    }

    handleHasEdit(event){
        // 获取子级页面是否填写必填项信息
        this.hasEdit = event.detail.hasEdit;
        console.log('hasEdit1' + this.hasEdit);

        //TJP 监听是否已经加载
        // let checkResult = event.detail.isInitCheckResult;
        // if(checkResult != undefined) {
        //     this.isInitCheckResult = checkResult;
        //     console.log('isInitCheckResult' + this.isInitCheckResult);
        // }
        if (event.detail.isInitCheckResult) {
            const { isInitCheckResult } = event.detail;
            const label = Object.keys(isInitCheckResult)[0]; // 获取动态键名
            const value = isInitCheckResult[label]; // 获取对应的值
            console.log(`Label "${label}" has initialization check result:`, value);
            // 根据 label 和 value 更新 dataArray
            this.isInitCheckResult[label] = value;
        }

        // 设置保存返回
        let saveFlag = event.detail.saveFlag;
        if(saveFlag == 'inventory'){
            this.handleCloseInventory();
        }else if(saveFlag == 'competitionIntelligence'){
            this.handleCloseCompetitive();
        }else if(saveFlag == 'inspectionItem'){
            this.handleCloseInspectionItem();
        }else if(saveFlag == 'samplingInspection'){
            this.handleCloseSamplingInspection();
        }else if(saveFlag == 'ticket'){
            this.handleCloseTicket();
        }
    }

    handleShowCompetitive() {
        console.log('hasEdit2' + this.hasEdit);
        this.showProductLine = false;
        this.showCompetitive = true;
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    flag : false
                }
            })
        );
    }

    handleCloseCompetitive() {
        console.log('hasEdit3' + this.hasEdit);
        if(this.hasEdit){
            this.handleShow(Inspection_Save_This_Page,'handleCloseCompetitive','c-new-competitive-intelligence-page-lwc');
        }else{
            this.showProductLine = true;
            this.showCompetitive = false;
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        flag : true
                    }
                })
            );
        }
        refreshApex(this.wiredResult);
    }

    handleShowInventory() {
        this.showProductLine = false;
        this.showInventory = true;
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    flag : false
                }
            })
        );
    }

    handleCloseInventory() {
        if(this.hasEdit){
            this.handleShow(Inspection_Save_This_Page,'handleCloseInventory','c-new-inventory-page-lwc');
        }else{
            this.showProductLine = true;
            this.showInventory = false;
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        flag : true
                    }
                })
            );
        }
        // refreshApex(this.wiredResult);
    }

    handleShowSamplingInspection() {
        this.showProductLine = false;
        this.showSamplingInspection = true;
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    flag : false
                }
            })
        );
    }

    handleShowXPlan() {
        this.showProductLine = false;
        this.showXPlan = true;
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    flag : false
                }
            })
        );
    }

    handleShowPhoto() {
        this.showProductLine = false;
        this.showXPlan = true;
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    flag : false
                }
            })
        );
    }

    // 20241028 TJP修改
    handleShowCheckListItem(event) {
        let name = event.target.dataset.name;
        this.showProductLine = false;
        this.showCheckListItem = true;
        this.inspectionItemlabel = name;
        this.handleSwitchTitleLanguage(name);
        console.log('mingzi' + name);
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    flag : false
                }
            })
        );
    }

    handleCloseSamplingInspection() {
        if(this.hasEdit){
            this.handleShow(Inspection_Save_This_Page,'handleCloseSamplingInspection','c-new-sampling-product-line-lwc');
        }else{
            this.showProductLine = true;
            this.showSamplingInspection = false;
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        flag : true
                    }
                })
            );
        }
        // refreshApex(this.wiredResult);
    }
    
    handleShowTicket() {
        this.showProductLine = false;
        this.showTicket = true;
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    flag : false
                }
            })
        );
    }

    handleCloseTicket() {
        if(this.hasEdit){
            this.handleShow(Inspection_Save_This_Page,'handleCloseTicket','c-new-inspector-daily-report-ticket-lwc');
        }else{
            this.showProductLine = true;
            this.showTicket = false;
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        flag : true
                    }
                })
            );
        }
        // refreshApex(this.wiredResult);
    }

    handleCloseXPlan() {
        if(this.hasEdit){
            this.handleShow(Inspection_Save_This_Page,'handleCloseXPlan','c-new-inspection-not-online-lwc');
        }else{
            this.showProductLine = true;
            this.showXPlan = false;
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        flag : true
                    }
                })
            );
        }
        // refreshApex(this.wiredResult);
    }

    @track showCompetitiveCanada = false;
    handleShowCompetitiveCanada() {
        this.showProductLine = false;
        this.showCompetitiveCanada = true;
        this.dispatchEvent(new CustomEvent(
            "select", {
                detail: {
                    flag : false
                }
            })
        );
    }

    handleCloseCompetitiveCanada() {
        if(this.hasEdit){
            this.handleShow(Inspection_Save_This_Page,'handleCloseCompetitiveCanada','c-new-competitive-intelligence-canada-page-lwc');
        }else{
            this.showProductLine = true;
            this.showCompetitiveCanada = false;
            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        flag : true
                    }
                })
            );
        }
        // refreshApex(this.wiredResult);
    }

    @track showAlert = false;
    handleSubmit(){
        // 校验所有检查项必填项是否填写
        let checkRequired = false;
        // 检查项是否检查完毕 YYL 20250323
        this.categoryType.forEach(data => {
            if(!checkRequired){
                if(!data.isCheck){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'error',
                            message: this.label.CHECK_PRODUCT_LINE_MSG_SUBMIT + ' --- ' + data.name,
                            variant: 'error'
                        })
                    );
                    checkRequired = true;
                }
            }
        });

        console.log('handleSave Ok');
        if(!checkRequired){
            // Ai 校验
            this.showAlert = true;
        }
    }
    submitRecord(createTicket){
        this.isShowSpinner = true;
        // 提交当前产品线日报
        submitInspectionProductItem({
            recordId:this.recordItemId
        }).then(data => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: data.message,
                    variant: 'success'
                })
            );

            this.dispatchEvent(new CustomEvent(
                "select", {
                    detail: {
                        flag : true,
                        submitFlag : true,
                        createTicket : createTicket
                    }
                })
            );
        })
        this.isShowSpinner = false;
    }
    // 关闭Ai弹出框
    handleAlertClose(event){
        this.isShowSpinner  = false;
        this.showAlert = false;
    }
    // 关闭Ai弹出框，提交数据
    handleContinue(event){
        this.showAlert = false;
        this.submitRecord(false);
    }
    // 跳转新建Ticket页面
    handleCreateTicket(event){
        this.showAlert = false;
        this.submitRecord(true);
    }

    handleBack(){
        this.dispatchEvent(new CustomEvent('goback'));
    }

    handleRefreshData(){
        // this.getCheckItemNumber();
        this.getCategoryTypeInfo();
    }

    async handleReplaceTemplate(event) {
        var index = event.target.dataset.index;
        const result = await LightningConfirm.open({
            message: Inspection_Switching_Template,
            variant: 'headerless',
            label: 'this is the aria-label value',
            // setting theme would have no effect
        });
    if (result) {
        // todo 选ok逻辑 删除所有关联数据 并根据逻辑展示不同条例重新初始化数据
        console.log('wwww---选ok逻辑---' + index);
        console.log('wwww---当前的模式数据---' + this.uniteLaserTV);
        var patrolModeOne;
        if(this.uniteLaserTV == 'Routine') {
            patrolModeOne = 'Unite';
        } else if(this.uniteLaserTV == 'Unite'){
            patrolModeOne = 'Routine';
        }
        // var patrolModeOne = this.uniteLaserTV[index];
        changeInspectionProductItem({
            recordId: this.recordItemId,
            patrolMode: patrolModeOne
        }).then(data => {
            this.uniteLaserTV = patrolModeOne;
            console.log(data);
            console.log('wwww---切换后的模式数据---'+ patrolModeOne +':' + this.uniteLaserTV);

            // this.getCheckItemNumber();
            this.getCategoryTypeInfo();
            // if(this.uniteLaserTV == 'Routine') {
            //     //展示Ticket ，样机，物料，展台
            //     this.isShowPrototypeCheck = true;
            //     this.isShowMaterialCheck = true;
            //     this.isShowBoothCheck = true;
            //     this.isShowCompetingGoodsCheck = true;
            //     this.isShowTicketCheck = true;
            // } else {
            //     this.isShowCompetingGoodsCheck = true;
            // }

        });
        
        // this.dispatchEvent(new CustomEvent(
        //     "select", {
        //         detail: {
        //             hasEdit : true
        //         }
        //     })
        // );
        }else {
            // todo 选cancel逻辑
            console.log('wwww---选cancel逻辑----' + index);
        }
    }
    //新增一个用于给与页面Title 的多语言
    handleSwitchTitleLanguage(title) {
        if(title == 'Prototype') {
            this.inspectionTitlelabel = Inspection_Prototype;
        } else if(title == 'Material ') {
            this.inspectionTitlelabel = Inspection_Material;
        } else if(title == 'PrototypeAndBooth ') {
            this.inspectionTitlelabel = Inspection_Prototype_Booth;
        }
        // } else if(title == 'Training') {
        //     this.inspectionTitlelabel = Inspection_Training;
        // } else if(title == 'Sales') {
        //     this.inspectionTitlelabel = Inspection_Material;
        // } else if(title == 'Weekly Asks') {
        //     this.inspectionTitlelabel = Inspection_Material;
        // } else if(title == 'Brand Feedback') {
        //     this.inspectionTitlelabel = Inspection_Material;
        // } else if(title == 'Sample Condition') {
        //     this.inspectionTitlelabel = Inspection_Material;
        // } else if(title == 'Material Display') {
        //     this.inspectionTitlelabel = Inspection_Material;
        // } else if(title == 'Speak With the Store Leader') {
        //     this.inspectionTitlelabel = '';
        // } 
        else if(title == 'Booth') {
            this.inspectionTitlelabel = Inspection_Booth;
        } else if(title == 'Competing Goods') {
            this.inspectionTitlelabel = Inspection_Competing_Goods;
        } else {
            this.inspectionTitlelabel = title;
        }

    }
    handleSetLinesOption(data) {
        if(data == 'TV') {
            this.LineLabel = Inspection_TV;
        } else if(data == 'Laser TV') {
            this.LineLabel = Inspection_Laser_TV;
        }  else if(data == 'Cooking') {
            this.LineLabel = Inspection_Cooking;
        }  else if(data == 'WM') {
            this.LineLabel = Inspection_WM;
        }  else if(data == 'Refrigerator') {
            this.LineLabel = Inspection_Refrigerator;
        }  else if(data == 'Freezer') {
            this.LineLabel = Inspection_Freezer;
        }  else if(data == 'Sound Bar') {
            this.LineLabel = Inspection_Sound_Bar;
        }  else if(data == 'Dishwasher') {
            this.LineLabel = Inspection_Dishwasher;
        } else if(data == 'All') {
            this.LineLabel = All_Product_Lines;
        } else {
            this.LineLabel = data;
        }
        console.log('Label' + this.LineLabel);

    }


}