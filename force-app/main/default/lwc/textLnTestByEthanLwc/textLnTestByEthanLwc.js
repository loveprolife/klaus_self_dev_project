import { LightningElement, track, wire, api } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils';
import { createRecord } from 'lightning/uiRecordApi';

import apex_createRecord from '@salesforce/apex/TextLnController.createRecord';
import getExhibitionOptions from '@salesforce/apex/TextLnController.getExhibitionOptions';

import LANG from '@salesforce/i18n/lang';
import FAX from '@salesforce/schema/ExpoApplyInfo__c.Fax__c';
import DUTY from '@salesforce/schema/ExpoApplyInfo__c.Duty__c';
import URL from '@salesforce/schema/ExpoApplyInfo__c.Url__c';
import ADDRESS from '@salesforce/schema/ExpoApplyInfo__c.Address__c';
import DEPARTMENT from '@salesforce/schema/ExpoApplyInfo__c.Department__c';
import WORL_TEL from '@salesforce/schema/ExpoApplyInfo__c.WorkTel__c';
import QQ_WECHAT_NUMBER from '@salesforce/schema/ExpoApplyInfo__c.QqWechatNumber__c';
import OTHER_INFO from '@salesforce/schema/ExpoApplyInfo__c.OtherInfo__c';
import FIRST_NAME_CN from '@salesforce/schema/ExpoApplyInfo__c.FirstNameCN__c';
import FIRST_NAME_EN from '@salesforce/schema/ExpoApplyInfo__c.FirstNameEN__c';
import LAST_NAME_CN from '@salesforce/schema/ExpoApplyInfo__c.LastNameCN__c';
import LAST_NAME_EN from '@salesforce/schema/ExpoApplyInfo__c.LastNameEN__c';
import TELEPHONE from '@salesforce/schema/ExpoApplyInfo__c.Telephone__c';
import EMAIL from '@salesforce/schema/ExpoApplyInfo__c.Email__c';
import COMPANY_CN from '@salesforce/schema/ExpoApplyInfo__c.CompanyCN__c';
import COMPANY_EN from '@salesforce/schema/ExpoApplyInfo__c.CompanyEN__c';
import IS_PRESENT from '@salesforce/schema/ExpoApplyInfo__c.Is_Present__c';
import AGREE_PRIVATE_POLICY from '@salesforce/schema/ExpoApplyInfo__c.AgreePrivatePolicy__c';
import AGREE_STORED from '@salesforce/schema/ExpoApplyInfo__c.AgreeStored__c';
import EXHIBITION_MANGEMENT from '@salesforce/schema/ExpoApplyInfo__c.ExpoId__c';

import CARD_SCAN_SAVE_BTN from '@salesforce/label/c.Exhibition_Scan_Image_Save_Btn';
import CARD_SCAN_RESET_BTN from '@salesforce/label/c.Exhibition_Scan_Image_Reset_Btn';

// /lightning/r/Account/
// window.location.href=res; 
// window.open(res.url, '_self');

export default class textLnTestByEthanLwc extends LightningNavigationElement {
	@api recordId;
	objectApiName = 'ExpoApplyInfo__c';//SObject
	//custome field
	FAX = FAX; DUTY = DUTY; URL = URL; ADDRESS = ADDRESS; DEPARTMENT = DEPARTMENT; WORL_TEL = WORL_TEL; QQ_WECHAT_NUMBER = QQ_WECHAT_NUMBER;
	FIRST_NAME_CN = FIRST_NAME_CN; FIRST_NAME_EN = FIRST_NAME_EN; LAST_NAME_CN = LAST_NAME_CN; LAST_NAME_EN = LAST_NAME_EN; TELEPHONE = TELEPHONE; EMAIL = EMAIL;
	EXHIBITION_MANGEMENT = EXHIBITION_MANGEMENT; COMPANY_CN = COMPANY_CN; COMPANY_EN = COMPANY_EN;
	IS_PRESENT = IS_PRESENT; AGREE_PRIVATE_POLICY = AGREE_PRIVATE_POLICY; AGREE_STORED = AGREE_STORED;

	@track textLnTypeStr = 'business_card'//控制子组件
	@track isApplied = false;//控制子组件
	@track businessCardInfo = {}
	@track isShowAllInfo = false
	@track isShowBt = false;
	@track btlabel = 'show'
	@track nameValidityMsg = '';
	@track companyValidityMsg = '';
	@track contactValidityMsg = '';
	@track isShowSpinner = false;

	//Sys_Lang
	sysLang = LANG;
	@track langIsCN = false;

	//field value
	@track expoId;
	@track lastNameCN;
	@track lastNameEN;
	@track firstNameCN;
	@track firstNameEN;
	@track telphone;
	@track email;
	@track wordTel;
	@track qqWechatNumber;
	@track fax;
	@track duty;
	@track department;
	@track address;
	@track url;
	@track companyCN;
	@track companyEN;
	// init field value
	@track isMyStylePresent;
	@track agreePrivatePolicy;
	@track agreeStored;
	//按钮翻译
	@track saveLabel = CARD_SCAN_SAVE_BTN;
	@track resetLabel = CARD_SCAN_RESET_BTN;


	@track fields = {};
	@track recordInfo = {};
	@track exhibitionOptions = [];
	@track countryOptions = [];
	@track countryListMap = {};

	@track showPersonInfo = false;
	@track personInfo = '';

	connectedCallback() {
		this.isShowSpinner = true;
		console.log('recordId----' + this.recordId);
		console.log('Lang---->' + this.sysLang);
		let strSaveLabel = this.saveLabel;
		console.log('===>' + strSaveLabel);
		console.log(this.isChn(strSaveLabel));

		getExhibitionOptions().then(data => {
			if (data.isSuccess) {
				for (let key in data.data) {
					this[key] = data.data[key];
				}
				if (this.exhibitionOptions.length > 0) {
					this.recordInfo.ExpoId__c = this.exhibitionOptions[0].value;
				}

				for (let country in this.countryListMap) {
					this.countryOptions = this.countryOptions.concat(this.countryListMap[country]);
				}
			}
		})

		setTimeout(() => {
			if (this.isChn(strSaveLabel)) { this.langIsCN = true }
			this.isShowSpinner = false;
		}
			, 1000);


		this.setDefaultValue();
		this.isApplied = false;
	}

	onHandlerStartScan() {
		console.log('onHandlerStartScan=======');
		this.isShowSpinner = true;
	}

	onGetBusinessCardInfo(event) {
		this.isShowSpinner = false;

		const inputFields = this.template.querySelectorAll(
			'lightning-input-field'
		);
		if (inputFields) {
			inputFields.forEach(field => {
				field.reset();
			});
		}
		this.isMyStylePresent = true;
		this.agreePrivatePolicy = true;
		this.agreeStored = true;


		// console.log('businessCardInfo-->'+this.businessCardInfo);
		this.businessCardInfo = event.detail.BusinessCardInfos;
		// console.log('event.detail.BusinessCardInfos-->1'+JSON.stringify(event.detail.BusinessCardInfos));
		// console.log('myVale-->'+this.myVale[0].key);
		if (this.businessCardInfo.code == 200) {
			this.businessCardInfo = JSON.stringify(this.businessCardInfo.dataList);
			// this.isShowAllInfo = true
			this.isShowBt = true;
			this.showSuccess('scan Success!');
			//Automatically match values
			// this.businessCardInfo = ;
			for (let i = JSON.parse(this.businessCardInfo).length - 1; i >= 0; i--) {
				let singleCard = JSON.parse(this.businessCardInfo)[i];
				if ('url' == singleCard.bcKey) this.url = '' + singleCard.bcValue;
				if ('QQ' == singleCard.bcKey) this.qqWechatNumber = '' + singleCard.bcValue;
				if ('address' == singleCard.bcKey) this.address = '' + singleCard.bcValue;
				if ('title' == singleCard.bcKey) this.duty = '' + singleCard.bcValue;
				if ('department' == singleCard.bcKey) this.department = '' + singleCard.bcValue;
				if ('company' == singleCard.bcKey && this.isChn(singleCard.bcValue)) this.companyCN = '' + singleCard.bcValue;
				if ('company' == singleCard.bcKey && !this.isChn(singleCard.bcValue)) this.companyEN = '' + singleCard.bcValue;
				if ('fax' == singleCard.bcKey) this.fax = '' + singleCard.bcValue;
				if ('work_tel' == singleCard.bcKey) this.wordTel = '' + singleCard.bcValue;
				if ('email' == singleCard.bcKey) this.email = '' + singleCard.bcValue;
				if ('telphone' == singleCard.bcKey) this.telphone = '' + singleCard.bcValue;
				if ('family_name' == singleCard.bcKey && this.isChn(singleCard.bcValue)) this.lastNameCN = '' + singleCard.bcValue;
				if ('family_name' == singleCard.bcKey && !this.isChn(singleCard.bcValue)) this.lastNameEN = '' + singleCard.bcValue;
				if ('given_name' == singleCard.bcKey && this.isChn(singleCard.bcValue)) this.firstNameCN = '' + singleCard.bcValue;
				if ('given_name' == singleCard.bcKey && !this.isChn(singleCard.bcValue)) this.firstNameEN = '' + singleCard.bcValue;

				// console.log('---->'+singleCard);
			}
			this.isApplied = true;
			// this.isShowSpinner = false;
			// setTimeout(()=>{this.isShowSpinner = false;},1000);
		} else {
			let errorCode = JSON.stringify(this.businessCardInfo.code);
			let errorMsg = JSON.stringify(this.businessCardInfo.msg);
			this.showError('识别异常！异常代码：' + errorCode + '；异常信息：' + errorMsg);
			// setTimeout(()=>{this.isShowSpinner = false;},1000);
		}
	}

	handleCreated() {
		//step1: Validity
		if (this.recordInfo.ExpoId__c == '' || this.recordInfo.ExpoId__c == null || this.recordInfo.ExpoId__c == undefined) {
			let errorMsg = this.langIsCN ? '展会信息必填！' : 'Exhibition Information is required!';
			this.showError(errorMsg);
			return;
		}
		if (this.checkNameValidity()) { this.showError(this.nameValidityMsg); return; }
		if (this.checkCompanyValidity()) { this.showError(this.companyValidityMsg); return; }
		if (this.checkContactValidity()) { this.showError(this.contactValidityMsg); return; }
		apex_createRecord({
			expoId: this.recordInfo.ExpoId__c,
			lastNameCN: this.lastNameCN,
			lastNameEN: this.lastNameEN,
			firstNameCN: this.firstNameCN,
			firstNameEN: this.firstNameEN,
			telphone: this.telphone,
			email: this.email,
			wordTel: this.wordTel,
			qqWechatNumber: this.qqWechatNumber,
			fax: this.fax,
			duty: this.duty,
			department: this.department,
			address: this.address,
			url: this.url,
			companyCN: this.companyCN,
			companyEN: this.companyEN,
			isPresent: this.isMyStylePresent,
			email: this.email,
			dataJson: JSON.stringify(this.recordInfo)
		}).then(result => {
			console.log('result:' + JSON.stringify(result));
			if (result.isSuccess) {
				this.showSuccess('success');

				this.recordInfo.Id = result.recordId;
				if (result.message != '') {
					// LightningPrompt.open({
					// 	label: '现场接待人员信息', // this is the header text
					// 	message: '接待人员信息',
					// 	defaultValue: result.message, //this is optional
					// }).then((promptResult) => {
					// 	this.goToRecord(result.recordId);
					// });

					this.showPersonInfo = true;
					this.personInfo = result.message;
				} else {
					this.goToRecord(result.recordId);
				}
			} else {
				this.showError(result.message);
			}

		}).catch(error => {
			console.log('error--->' + JSON.stringify(error));
			this.showError(JSON.stringify(error));
		});
	}

	// show card message
	// handerClick(){
	// 	this.isShowAllInfo = !this.isShowAllInfo
	// 	this.btlabel = this.isShowAllInfo ? 'hidden': 'show';

	// }
	//设置默认字段
	setDefaultValue() {
		this.isMyStylePresent = true;
		this.agreePrivatePolicy = true;
		this.agreeStored = true;
	}

	//重置
	handleReset(event) {
		const inputFields = this.template.querySelectorAll(
			'lightning-input-field'
		);
		if (inputFields) {
			inputFields.forEach(field => {
				field.reset();
			});
		}
		// setTimeout(()=>{
		this.setDefaultValue();

		// }
		// ,500);
	}
	//返回列表
	handleCancel() {
		window.open('/lightning/o/ExpoApplyInfo__c/list?filterName=Recent', '_self');

	}

	//创建成功
	handleRecordCreated(event) {
		this.showSuccess(JSON.stringify(event.detail));
		console.log('--->' + JSON.stringify(event.detail));
	}
	//创建失败
	handleError(event) {
		this.showError(JSON.stringify(event.detail));
	}

	// 是否含有汉字，若有返回 true
	isChn(str) {
		if (/.*[\u4e00-\u9fa5]+.*$/.test(str)) return true;
		return false;
	}

	//中英文姓名至少填写一组！
	checkNameValidity() {
		if (((this.lastNameCN != '' && this.lastNameCN != null && this.lastNameCN != undefined) && (this.firstNameCN != '' && this.firstNameCN != null && this.firstNameCN != undefined))
			|| ((this.lastNameEN != '' && this.lastNameEN != null && this.lastNameEN != undefined) && (this.firstNameEN != '' && this.firstNameEN != null && this.firstNameEN != undefined))) {
			console.log('中英文姓名至少已填一组');
			this.nameValidityMsg = '';
			return false;
		} else {
			let errorMsg = this.langIsCN ? '中英文姓名至少填写一组！ ' : 'Fill in at least one set of names in both English and Chinese! ';
			this.nameValidityMsg = errorMsg;
			return true;
		}
	}
	//中英文公司至少填写一组！
	checkCompanyValidity() {

		if ((this.companyCN != '' && this.companyCN != null && this.companyCN != undefined) || (this.companyEN != '' && this.companyEN != null && this.companyEN != undefined)) {
			console.log('中英文公司名称至少已填一组');
			this.companyValidityMsg = '';
			return false;
		} else {
			let errorMsg = this.langIsCN ? '中英文公司名称至少填写一组！ ' : 'Chinese and English company name fill in at least one group! ';
			this.companyValidityMsg = errorMsg;
			return true;
		}
	}

	//电话、工作电话、邮箱至少一个
	checkContactValidity() {

		if ((this.email != '' && this.email != null && this.email != undefined) ||
			(this.telphone != '' && this.telphone != null && this.telphone != undefined)
			|| (this.wordTel != '' && this.wordTel != null && this.wordTel != undefined)) {
			console.log('电话、工作电话、邮箱至少已填一组');
			this.contactValidityMsg = '';
			return false;
		} else {
			let errorMsg = this.langIsCN ? '电话、工作电话、邮箱 至少填写一组！ ' : 'Pone, work phone, email at least fill in a group! ';
			this.contactValidityMsg = errorMsg;
			return true;
		}
	}


	// handerCreateNew() {
	// 	const fields = {
	// 		Name: accountName.value,
	// 	};

	// 	const recordInput = { apiName: ExpoApplyInfo__c.objectApiName, fields };
	// }
	handleLastNameCN(evt) { this.lastNameCN = evt.detail.value; }
	handleLastNameEN(evt) { this.lastNameEN = evt.detail.value; }
	handerFirstNameCN(evt) { this.firstNameCN = evt.detail.value; }
	handerFirstNameEN(evt) { this.firstNameEN = evt.detail.value; }
	handerTelphone(evt) { this.telphone = evt.detail.value; }
	handerEmail(evt) { this.email = evt.detail.value; }
	handerWorkTel(evt) { this.wordTel = evt.detail.value; }
	handerQqWechatNumber(evt) { this.qqWechatNumber = evt.detail.value; }
	handerFax(evt) { this.fax = evt.detail.value; }
	handerDuty(evt) { this.duty = evt.detail.value; }
	handerUrl(evt) { this.url = evt.detail.value; }
	handerAddress(evt) { this.address = evt.detail.value; }
	handerDepartment(evt) { this.department = evt.detail.value; }
	handerCompanyCN(evt) { this.companyCN = evt.detail.value; }
	handerCompanyEN(evt) { this.companyEN = evt.detail.value; }
	handlerExpoId(evt) { this.expoId = evt.detail.value.toString(); }
	handerIsPresent(evt) {
		// this.isMyStylePresent = evt.detail.value;
		this.isMyStylePresent = evt.detail.checked;
	}

	inputChangeHandler(event) {
		let fieldName = event.target.dataset.fieldName;
		let fieldValue = event.target.value;

		if (fieldName == 'CountryRegionCN__c') {
			this.recordInfo[fieldName] = event.detail.value;
		} else {
			this.recordInfo[fieldName] = fieldValue;

			if (fieldName == 'Region__c') {
				this.countryOptions = (this.recordInfo[fieldName] in this.countryListMap) ? this.countryListMap[this.recordInfo[fieldName]] : [];
			}
		}

		console.log('inputChangeHandler ---> fieldName : ' + fieldName);
		console.log('inputChangeHandler ---> fieldValue : ' + this.recordInfo[fieldName]);
	}


	handleConfirm() {
		this.goToRecord(this.recordInfo.Id);
	}

	handleBack() {
		location.reload()
	}

}