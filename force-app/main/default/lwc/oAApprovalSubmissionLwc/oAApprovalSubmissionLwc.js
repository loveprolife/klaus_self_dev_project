import { LightningElement, track, wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { RefreshEvent } from "lightning/refresh";
import { NavigationMixin } from 'lightning/navigation';
import saveOAApp from '@salesforce/apex/oAApprovalSubmissionController.saveOAApp';
import selIntList from '@salesforce/apex/oAApprovalSubmissionController.selIntList';
import getDepartment from '@salesforce/apex/ExhibitionSSOVerifyController.getDepartment';
import getCompanyAbbr from '@salesforce/apex/ExhibitionSSOVerifyController.getCompanyAbbr';
import getCompany from '@salesforce/apex/ExhibitionSSOVerifyController.getCompany';
import getSecondApprover from '@salesforce/apex/ExhibitionSSOVerifyController.getSecondApprover';
import getOAapprover from '@salesforce/apex/ExhibitionSSOVerifyController.getOAapprover';      
import getExhibition from '@salesforce/apex/ExhibitionSSOVerifyController.getExhibition';

export default class oAApprovalSubmissionLwc extends NavigationMixin(LightningElement) {

	@api recordId;
    @track isShowSpinner = false;
	@track approverList = [];
    @track approverOneList = [];
    @track oneAppVal = '';
    @track twoAppVal = '';
    @track areaAppVal = '';
    @track statusAppVal = '';
    @track deapAppVal = '';
    @track opinion = '';

    @track isDetailPage = true;//是否是在详情页面
    @track isChooseExpo = false;//是否选择了展会信息
    @track saveStatus = true;

    @track isShowOneApp = true;
    @track isShowTwoApp = true;
    @track inputValue;

    @track dataList = [];
    @track deapList = [];
    @track expoList = [];
    @track areaList = []; //TJP
    @track statusList = [{label:'',value:''},{label:'All',value:'All'},{label:'未审批',value:'未审批'},{label:'审批驳回',value:'审批驳回'}];

    @track saveList =[];

    @track oneAppList = ['总部|HQ'];//仅展示一级审批人
    // @track oneAppList = ['VIDAA'];//仅展示一级审批人

    // @track twoAppList = ['欧洲区|Europe','东盟区|ASEAN','日本|Japn'];//仅展示二级审批人
    @track twoAppList = [];//仅展示二级审批人


	connectedCallback(){
        console.log('recordId===>'+this.recordId);
        this.isShowSpinner = true;
        if (this.recordId == undefined || this.recordId == '' || this.recordId == '') {
            this.isDetailPage = false;
            this.recordId = null;
            getExhibition().then(res=>{
            if (res.isSuccess) {
                this.expoList = JSON.parse(res.msg);
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: res.msg,
                        variant: 'error',
                    }));
                    // this.dispatchEvent(new CustomEvent('closemodal'));
                    // this.dispatchEvent(new CustomEvent('refreshview')); 
                    this.closePage();
                    this.refreshPage();
            }
        })
        };
		let opMap = [{label:'',value:''},{label:'cuijie3',value:'cuijie3'}];
        // for(let key in result.salesUnitMap){
        //     opMap.push({label: result.salesUnitMap[key],value: result.salesUnitMap[key]});
        // }
        // this.approverList = opMap;

        let deapMap = [{label:'',value:''},{label:'营销',value:'营销'}];
        // for(let key in result.salesUnitMap){
        //     opMap.push({label: result.salesUnitMap[key],value: result.salesUnitMap[key]});
        // }
        // Modified By Ethan 20230824 部门动态获取 二级审批人动态获取
        // getDepartment({recordId : this.recordId}).then(res=>{
        //     if (res.isSuccess) {
        //         this.deapList = JSON.parse(res.msg);
        //     }
        //     else{
        //         this.dispatchEvent(new ShowToastEvent({
        //                 title: 'Error',
        //                 message: res.msg,
        //                 variant: 'error',
        //             }));
        //             // this.dispatchEvent(new CustomEvent('closemodal'));
        //             // this.dispatchEvent(new CustomEvent('refreshview')); 
        //             this.closePage();
        //             this.refreshPage();
        //     }
        // })
        // #展会优化 修改为匹配companyAbbr add by DTT-Bright 20240803 
        // 优化 根据选择大区获取对应 companyAbbr TJP
        getCompanyAbbr({recordId : this.recordId, company : this.areaAppVal}).then(res=>{
            if (res.isSuccess) {
                this.deapList = this.dataPrep(JSON.parse(res.msg));
                // this.deapList = JSON.parse(res.msg);
                // console.log('部门' + (this.deapList));
                // console.log('bumen' + res.msg);
                for (let index = 0; index < this.deapList.length; index++) {
                    let element = this.deapList[index];
                    if (!element.label) {
                        element.label = 'All'
                        // element.value = 'All'

                    }
                }
            }
            
            else{
                this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: res.msg,
                        variant: 'error',
                    }));
                    // this.dispatchEvent(new CustomEvent('closemodal'));
                    // this.dispatchEvent(new CustomEvent('refreshview')); 
                    this.closePage();
                    this.refreshPage();
            }
        })
        getCompany({recordId : this.recordId}).then(res=>{
            if (res.isSuccess) {
                this.areaList = JSON.parse(res.msg);
            }
            else{
                this.handlerShowToast('Error', '系统错误！'+res.msg, 'error');
                this.refreshPage();
            }
        })
        getSecondApprover({type: '部门'}).then(res=>{
            if (res.isSuccess) {
                this.approverList = JSON.parse(res.msg);
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: res.msg,
                        variant: 'error',
                    }));
                    // this.dispatchEvent(new CustomEvent('closemodal'));
                    // this.dispatchEvent(new CustomEvent('refreshview')); 
                    this.closePage();
                    this.refreshPage();
            }
        })

        getOAapprover({type: '大区'}).then(res=>{
            if (res.isSuccess) {
                this.approverOneList = JSON.parse(res.msg);
                console.log('this.approverOneList' + JSON.stringify(this.approverOneList));
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: res.msg,
                        variant: 'error',
                    }));
                    // this.dispatchEvent(new CustomEvent('closemodal'));
                    // this.dispatchEvent(new CustomEvent('refreshview')); 
                    this.closePage();
                    this.refreshPage();
            }
        })


        // this.deapList = deapMap;

        console.log('Id:'+this.recordId);
        this.isShowSpinner = false;
	}
    // 添加用户（自定义lookupFilter）
    lookupUserFilter = {
        'lookup' : 'CustomLookupProvider.ApprovalFliter'
    }

    handleChildValue(event) {
        console.log('父类取数' + event.detail);
        // this.receivedValue = event.detail;
        // this.oneAppVal = event.detail;
        // let newValue = event.detail;
        // // this.inputValue = event.detail;
        // if (newValue) {
        //     // 检查已有值是否存在
        //     if (this.inputValue) {
        //         // 如果已有值，拼接新值，用英文分号分隔
        //         this.inputValue = `${this.inputValue};${newValue}`;
        //     } else {
        //         // 如果没有值，直接赋值
        //         this.inputValue = newValue;
        //     }
        //     this.oneAppVal = this.inputValue;
        //     // 清空输入框
        //     this.removeLookup('onRegistrations');
        // }
    }
 
    handleChangeOption(resp) {
        var selectId;
        console.log('1');
        if (resp.detail.selectedRecord==undefined || resp.detail.selectedRecord == null || resp.detail.selectedRecord == '') {
            this.oneAppVal = '';
        } else {
            console.log('4');
            selectId = resp.detail.selectedRecord.Id;
            console.log('selectId' + selectId);
            console.log('resp' + JSON.stringify(resp.detail));
            var region;
            // const matchedRecord = this.approverOneList.find(record => record.Id === selectId);
            // if (matchedRecord) {
                console.log('5');
            //    var xhNumber = matchedRecord.XHNumber__c;
            var xhNumber = resp.detail.selectedRecord.XHNumber__c;
            //    region = matchedRecord.Region__c;
            //    this.oneAppVal = xhNumber;
               console.log('选中人员' + xhNumber);
               console.log('6');
               if (this.inputValue) {
                console.log('7');
                    const values = this.inputValue.split(';');
                    if (!values.includes(xhNumber)) {
                        // 如果不包含，进行拼接
                        this.inputValue = `${this.inputValue};${xhNumber}`;
                    }
                } else {
                    console.log('8');
                    // 如果没有值，直接赋值
                    this.inputValue = xhNumber;
                }
                console.log('9');
                this.oneAppVal = this.inputValue;
                console.log('参数' + this.oneAppVal);
                // 清空输入框
                console.log('1');
                this.handleRemoveLookup('onRegistrations',null); 
            // } 

        }
    }

    // @track selectedApprover = null;
    // @track selectedApprovers = [];
    // @track selectedApproversString = ''; // 用于存储拼接后的字符串

    // handleComboboxChange(event) {
    //     const selectedValue = event.detail.value;
    //     if (!this.selectedApprovers.includes(selectedValue)) {
    //         this.selectedApprovers.push(selectedValue);
    //     }
    //     this.selectedApprover = null; // 清空当前选择，以便重新选择
    //     this.updateSelectedApproversString();
    // }

    // updateSelectedApproversString() {
    //     this.selectedApproversString = this.selectedApprovers.join(';');
    //     this.isDeleteButtonDisabled = this.selectedApprovers.length === 0;
    // }

    // handleDeleteLast() {
    //     if (this.selectedApprovers.length > 0) {
    //         this.selectedApprovers.pop();
    //         this.updateSelectedApproversString();
    //     }
    // }

    // @track inputValue = ''; // 用于绑定输入框的值
     // 删除按钮的点击事件处理
    handleDelete() {
        // 按照英文分号分割输入框的内容
        const values = this.inputValue.split(';');
        
        // 删除最后一个参数
        if (values.length > 0) {
            values.pop();
        }

        // 将剩余的内容重新拼接，并更新输入框的值
        this.inputValue = values.join(';');
        this.oneAppVal = this.inputValue;
    }

    handleRemoveLookup(type, index) {
        let alllookup = this.template.querySelectorAll('c-lookup-lwc');
        for (let i = 0; i < alllookup.length; i++) {
            var lookup = alllookup[i];
            if (lookup.name == type && (index == null || lookup.getAttribute('data-index') == index)) {
                lookup.handleRemove();
            }
        }
    }

    cancel(event) {
        this.dispatchEvent(new CustomEvent('closemodal')); 
    }

    changeData(event){
        let name = event.target.name;
        let value = event.target.value;
        console.log('event'+ JSON.stringify(event.target));
        console.log('name'+name);
        console.log('value'+value);
        if (name == 'opinion') {
            this.opinion = value;
        }
        if (name == 'twoApp') {
            this.twoAppVal = value;
        }
        if(name == 'areaApp') {
            this.areaAppVal = value;
            console.log('value' + value);
            console.log('this.areaAppVal' + this.areaAppVal);
            if(value != '') {
                var list = [];
                list.push({"value": null,"region":"","label":""});
                var list2 = [];
                list2 = this.findMatchesByRegion(this.approverOneList, value);
                console.log('WWW' + JSON.stringify(this.findMatchesByRegion(this.approverOneList, value)));
                if(list2.length > 0) {
                    for (let index = 0; index < list2.length; index++) {
                        let element = list2[index];
                        list.push(element);
                    }
                }
                this.approverOneList = list;
                // this.approverOneList.push({"value":"","region":"","label":""});
            }
            getCompanyAbbr({recordId : this.recordId,company : this.areaAppVal}).then(res=>{
                if (res.isSuccess) {
                    this.deapList = JSON.parse(res.msg);
                    for (let index = 0; index < this.deapList.length; index++) {
                        let element = this.deapList[index];
                        if (!element.label) {
                            element.label = 'All'
                        }
                    }
                    // if(this.areaAppVal == '总部|HQ') {
                    //     this.deapList.push({"value":null,"region": this.areaAppVal,"label":"All"});
                    // }
                    
                }
                else{
                    this.handlerShowToast('Error', '系统错误！'+res.msg, 'error');
                    this.refreshPage();
                }
            })
        }
        if (name == 'deapApp') {
            // this.deapAppVal = value;
            console.log('value' + value);
            this.isShowSpinner = true;
            this.saveList = [];
            if(value == '') {
                this.deapAppVal = null;
            } else {
                this.deapAppVal = value;
            }
            if(this.areaAppVal == '') {
                this.areaAppVal = null;
            }
            if(this.oneAppVal == '') {
                this.oneAppVal = null;
            }
            if(this.statusAppVal == '') {
                this.statusAppVal = null;
            }
            console.log('value' +':'+ value + '==' + 'region' + ':' + this.areaAppVal +'this.oneAppVal'+ this.oneAppVal +'companyAbbr' + value);
            selIntList({
                companyAbbr : this.deapAppVal,
                exhId : this.recordId,
                region : this.areaAppVal,
                approval : this.oneAppVal,
                approvalStatus : this.statusAppVal
            }).then(result => {
                console.log('result:'+JSON.stringify(result));
                if (result.isSuccess) {
                    this.dataList = result.data.intList;
                    for(let i = 0 ; i < this.dataList.length ; i++){
                        this.dataList[i].isSelect = false;
                    }
                    this.isShowSpinner = false;
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: '系统错误!'+result.message,
                        variant: 'error',
                    }));
                    this.dataList = [];
                    this.isShowSpinner = false;
                }
            }).catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: '系统错误!'+JSON.stringify(error),
                    variant: 'error',
                }));
                this.dataList = [];
                this.isShowSpinner = false;
            });

        }

        if (name == 'statusApp') {
            this.statusAppVal = value;
            
            if(value == '') {
                this.statusAppVal = null;
            }
            if(this.areaAppVal == '') {
                this.areaAppVal = null;
            }
            if(this.oneAppVal == '') {
                this.oneAppVal = null;
            }
            if(this.deapAppVal == '') {
                this.deapAppVal = null;
            }
            console.log('statusApp' + this.statusAppVal);
            console.log('deapAppVal' +':'+ this.deapAppVal + '==' + 'region' + ':' + this.areaAppVal +'this.oneAppVal'+ this.oneAppVal +'companyAbbr' + value);
            selIntList({
                companyAbbr : this.deapAppVal,
                exhId : this.recordId,
                region : this.areaAppVal,
                approval : this.oneAppVal,
                approvalStatus : this.statusAppVal
            }).then(result => {
                console.log('result:'+JSON.stringify(result));
                if (result.isSuccess) {
                    this.dataList = result.data.intList;
                    for(let i = 0 ; i < this.dataList.length ; i++){
                        this.dataList[i].isSelect = false;
                    }
                    this.isShowSpinner = false;
                }else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'error',
                        message: '系统错误!'+result.message,
                        variant: 'error',
                    }));
                    this.dataList = [];
                    this.isShowSpinner = false;
                }
            }).catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'error',
                    message: '系统错误!'+JSON.stringify(error),
                    variant: 'error',
                }));
                this.dataList = [];
                this.isShowSpinner = false;
            });

        }
    }

    saveData(){
        this.isShowSpinner = true;
        console.log('一级审批人' + this.oneAppVal);
        console.log('二级审批人' + this.twoAppVal);
        console.log('处理意见' + this.opinion);
        
        if(!this.recordId){
            this.handlerShowToast('Error',  '参数不能为空!', 'error');
            this.isShowSpinner = false;
        } else if (!this.oneAppVal&& !this.twoAppVal) {
            this.handlerShowToast('Error',  '参数不能为空!', 'error');
            this.isShowSpinner = false;
        } else if(this.saveList.length==0) {
            this.handlerShowToast('Error',  '参数不能为空!', 'error');
            this.isShowSpinner = false;
        } else if(this.saveList.length > 0){
            //暂停商证必填校验
            // for (let index = 0; index < this.saveList.length; index++) {
            //     const element = this.saveList[index];
                
            //     const param = this.getCertificateTypeById(this.dataList,element)
            //     console.log('商证数据' +JSON.stringify(param));
            //     if(param == null || param == '无|None' || param == 'None|无'){
            //         this.saveStatus = false;
            //         this.dispatchEvent(new ShowToastEvent({
            //             title: 'error',
            //             message: '审批人证件类型不能为空',
            //             variant: 'error',
            //         }));
            //         this.isShowSpinner = false;
            //     } 
            // }
            if(this.saveStatus) {
                // this.isShowSpinner = false;
                console.log('WWW2触发审批流');
                saveOAApp({
                    id : this.recordId,
                    oneApp : this.oneAppVal,
                    twoApp : this.twoAppVal,
                    opinion : this.opinion,
                    ids : this.saveList,
                }).then(result => {
                    console.log('result:'+JSON.stringify(result));
                    if (result.isSuccess) {
                        this.handlerShowToast('Success',  '提交审批成功！', 'Success');
                        // this.closePage();
                        this.isShowSpinner = false;
                        this.refreshPage();
                        this.handercancel();
                    }else{
                        this.handlerShowToast('Error',  '系统错误!'+result.message, 'error');
                        this.isShowSpinner = false;
                    }
                }).catch(error => {
                    this.handlerShowToast('Error',  '系统错误!'+JSON.stringify(error), 'error');
                    this.isShowSpinner = false;
                });
            }
        }
        
    }

    //全选
    selectAllQuoteProducts(event){
        var isCheck = event.target.checked;
        let selectedRows = this.template.querySelectorAll('lightning-input');
        
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox' && selectedRows[i].name !="disabled") {
                selectedRows[i].checked = event.target.checked;
            }
        }

        if(isCheck){
            let resList = [];
            for(let a = 0; a < this.dataList.length; a++){
                resList.push(this.dataList[a].Id);
            }
            this.saveList = resList;
        }else{
            this.saveList = [];
        }
        console.log('this.saveList',JSON.stringify(this.saveList));
    }

    selectData(event) {
        var isCheck = event.target.checked;
        var value = event.target.value;
        // var param = event.target.dataset.fieldName;
        console.log('value=='+value);
        if (isCheck) {
            for (var i = 0; i<this.dataList.length; i++) {
                if (this.dataList[i].Id === value) {
                    this.dataList[i].isSelect = true;
                    this.saveList.push(value);
                    break;
                }
            }
            if (this.saveList.length===this.dataList.length) {
                let selectedRows = this.template.querySelectorAll('[data-id="checkBoxAll"]');
                selectedRows[0].checked = true;     
            }
        } else {
            this.saveList = this.saveList.filter(item=>item != value);
            let selectedRows = this.template.querySelectorAll('[data-id="checkBoxAll"]');
            selectedRows[0].checked = false;    
            for (var i = 0; i<this.dataList.length; i++) {
                if (this.dataList[i].Id === value) {
                    this.dataList[i].isSelect = false;
                    break;
                }
            }
        }
        console.log('this.saveList',JSON.stringify(this.saveList));
    }

    //选择展会信息
    changeExpo(event) {
        let value_str = event.target.value;
        if (value_str == undefined || value_str == '' || value_str == '') {
            this.recordId == null;
            this.isChooseExpo = false;
            return;
        }

        this.recordId = value_str;
        this.isChooseExpo = true;
        // getDepartment({recordId : this.recordId}).then(res=>{
        //     if (res.isSuccess) {
        //         this.deapList = JSON.parse(res.msg);
        //     }
        //     else{
        //         this.handlerShowToast('Error', '系统错误！'+res.msg, 'error');
        //         this.refreshPage();
        //     }
        // })
        getCompany({recordId : this.recordId}).then(res=>{
            if (res.isSuccess) {
                this.areaList = JSON.parse(res.msg);
            }
            else{
                this.handlerShowToast('Error', '系统错误！'+res.msg, 'error');
                this.refreshPage();
            }
        })
        // #展会优化 修改为companyAbbr匹配 add by DTT-Bright 20240803
        this.saveList = [];
        getCompanyAbbr({recordId : this.recordId,company : this.areaAppVal}).then(res=>{
            if (res.isSuccess) {
                // this.deapList = JSON.parse(res.msg);
                this.deapList = this.dataPrep(JSON.parse(res.msg));
                for (let index = 0; index < this.deapList.length; index++) {
                    let element = this.deapList[index];
                    if (!element.label) {
                        element.label = 'All'
                    }
                }
            }
            else{
                this.handlerShowToast('Error', '系统错误！'+res.msg, 'error');
                this.refreshPage();
            }
        })

    }

    //
    handlesaveData(){
        this.isShowSpinner = true;
        console.log('一级审批人' + this.oneAppVal);
        console.log('二级审批人' + this.twoAppVal);

        if(!this.recordId){
            this.handlerShowToast('Error',  '参数不能为空!', 'error');
            this.isShowSpinner = false;
        } else if (!this.oneAppVal&& !this.twoAppVal) {
            this.handlerShowToast('Error',  '参数不能为空!', 'error');
            this.isShowSpinner = false;
        } else if(this.saveList.length==0) {
            this.handlerShowToast('Error',  '参数不能为空!', 'error');
            this.isShowSpinner = false;
        } else if(this.saveList.length > 0){
            // for (let index = 0; index < this.saveList.length; index++) {
            //     const element = this.saveList[index];
                
            //     const param = this.getCertificateTypeById(this.dataList,element)
            //     console.log('商证数据' +JSON.stringify(param));
            //     if(param == null || param == '无|None' || param == 'None|无'){
            //         this.saveStatus = false;
            //         this.dispatchEvent(new ShowToastEvent({
            //             title: 'error',
            //             message: '审批人证件类型不能为空',
            //             variant: 'error',
            //         }));
            //         this.isShowSpinner = false;
            //     } 
            // }
            if(this.saveStatus) {
                // this.isShowSpinner = false;
                console.log('WWW1触发审批流');
                saveOAApp({
                    id : this.recordId,
                    oneApp : this.oneAppVal,
                    twoApp : this.twoAppVal,
                    opinion : this.opinion,
                    ids : this.saveList,
                }).then(result => {
                    console.log('result:'+JSON.stringify(result));
                    if (result.isSuccess) {
                        this.handlerShowToast('Success',  '提交审批成功！', 'Success');
                        // this.closePage();
                        this.isShowSpinner = false;
                        this.refreshPage();
                        this.handercancel();
                    }else{
                        this.handlerShowToast('Error',  '系统错误!'+result.message, 'error');
                        this.isShowSpinner = false;
                    }
                }).catch(error => {
                    this.handlerShowToast('Error',  '系统错误!'+JSON.stringify(error), 'error');
                    this.isShowSpinner = false;
                });
            }
            
        } 
        
    }
    //返回到参展员工列表视图
    handercancel(){
        console.log('back===');
        this.refreshPage();
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Internal_Registration__c',
                actionName: 'list'
            }
        });
    }
    refreshPage(){
        setTimeout(()=>{
            window.location.reload();
            
    }
    ,1000);}

    closePage() {
            this.dispatchEvent(new CloseActionScreenEvent());
        }  

    handlerShowToast(selfTitle, selfMsg, selfVar) {
        this.dispatchEvent(new ShowToastEvent({
                                    title: selfTitle,
                                    message: selfMsg,
                                    variant: selfVar,
                                }));
    }

    //查找符合数据
    findRegionByValue(data, value) {
        const item = data.find(item => item.value === value);
        this.regionBySelect = item ? item.region : null;
    }
    
    //过滤集合数据
    findMatchesByRegion(data, region) {
        return data.filter(item => item.region === region);
    }

    //数据预处理
    dataPrep(data) {
        data.forEach(item => {
            if (item.label && item.label !== "") {
                const backslashCount = (item.label.match(/\\/g) || []).length;

                if (backslashCount >= 2) {
                  const secondBackslashIndex = item.label.indexOf("\\", item.label.indexOf("\\") + 1);
                  // 如果找到了第二个反斜杠 \
                  if (secondBackslashIndex !== -1) {
                    // 去掉第二个反斜杠 \ 及其之前的内容
                    item.label = item.label.substring(secondBackslashIndex + 1);
                  }
                }
              }
            });
            
            console.log('MMMM' + JSON.stringify(data)); 

            return data;
    }

    getCertificateTypeById(data, targetId) {

        const record = data.find(item => item.Id === targetId);
        return record ? record.Certificate_Type__c : null;
    }



}