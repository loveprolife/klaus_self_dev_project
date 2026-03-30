import { LightningElement, api, track, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import { getRecordNotifyChange, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import saveShop from '@salesforce/apex/LocationController.saveShop';
import searchShop from '@salesforce/apex/LocationController.searchShop';
import getAddress from '@salesforce/apex/LocationController.getAddress';
import getShopDetail from '@salesforce/apex/LocationController.getShopDetail';
import getCustomChannel from '@salesforce/apex/LocationController.getCustomChannel';
import getCountryStateId from '@salesforce/apex/LocationController.getCountryStateId';
import getUserInfo from '@salesforce/apex/LocationController.getUserInfo';
import Permission_Denied from '@salesforce/label/c.Permission_Denied';
export default class NewStorePageLwc extends LightningNavigationElement {

    @track isProvinceRequired = false;
    @track isShowSpinner = false;
    @track isJapan = false;
    @track isLocationOpen = false;

    @track currentLat;
    @track currentLong;
    @track storeAddress;
    @track addressDetails = {};
    @track googleMapUrl;
    @track provinceSelectId;

    @track locationRecord = {};
    @track record = {};
    @track openLocationPage = false;
    @track lookupStoreFilter;
    @track sapCodeId;
    @track channelId;
    @track latitude;
    @track longitude;
    @track provincePickListShow = true;
    @track salesRegionReadonly = false;
    @api recordId;

    // @track shopLabelInfo = {
    //     Guarantor_Country_Code__c: '',
    //     Company_Registration_Number__c: '',
    //     provinceStateLabel: '',
    //     cityCNLabel: '',
    //     districtCNLabel: '',
    //     townshipCNLabel: '',
    // };
    // @wire(getObjectInfo, { objectApiName: 'Account' })
    // wiredAccountInfo({ error, data }) {
    //     if (data) {
    //         this.shopLabelInfo = {
    //             Guarantor_Country_Code__c: data.fields.Guarantor_Country_Code__c.label,
    //             Company_Registration_Number__c: data.fields.Company_Registration_Number__c.label,
    //             provinceStateLabel: data.fields.Province_State__c.label,
    //             cityCNLabel: data.fields.City_CN__c.label,
    //             districtCNLabel: data.fields.District_CN__c.label,    
    //             townshipCNLabel: data.fields.Township_CN__c.label,
    //         }
    //     } else if (error) {
    //         console.log(error);
    //         this.showError('Store getInformation error');
    //     }
    // }
    label = { Permission_Denied };
    getUserInfo(){
        getUserInfo({}).then(result => {
            if(result.Profile.Name.includes('System') || result.Profile.Name.includes('HQ')) {
                this.salesRegionReadonly = false;
            } else {
                this.salesRegionReadonly = true;
            }
            console.log('获取结果'+ this.salesRegionReadonly);  
        })
    }

    countryMapping = {
         'Afghanistan':	 'AF',
         'Albania':	 'AL',
         'Algeria':	 'DZ',
         'Andorran':	 'AD',
         'Angola':	 'AO',
         'Antigua/Barbuda':	 'AG',
         'Argentina':	 'AR',
         'Armenia':	 'AM',
         'Australia':	 'AU',
         'Austria':	 'AT',
         'Azerbaijan':	 'AZ',
         'Bahamas':	 'BS',
         'Bahrain':	 'BH',
         'Bangladesh':	 'BD',
         'Barbados':	 'BB',
         'Belarus':	 'BY',
         'Belgium':	 'BE',
         'Belize':	 'BZ',
         'Benin':	 'BJ',
         'Bolivia':	 'BO',
         'Bosnia-Herz.':	 'BA',
         'Botswana':	 'BW',
         'Brazil':	 'BR',
         'Brit.Ind.Oc.Ter':	 'IO',
         'Brunei Daruss.':	 'BN',
         'Bulgaria':	 'BG',
         'Burkina Faso':	 'BF',
         'Burundi':	 'BI',
         'Cambodia':	 'KH',
         'Cameroon':	 'CM',
         'Canada':	 'CA',
         'Cape Verde':	 'CV',
         'CAR':	 'CF',
         'Chile':	 'CL',
         'China':	 'CN',
         'Colombia':	 'CO',
         'Comoros':	 'KM',
         'Cook Islands':	 'CK',
         'Costa Rica':	 'CR',
         "Cote d'Ivoire":	 'CI',
         'Croatia':	 'HR',
         'Cuba':	 'CU',
         'Cyprus':	 'CY',
         'Czech Republic':	 'CZ',
         'Dem. Rep. Congo':	 'CD',
         'Denmark':	 'DK',
         'Djibouti':	 'DJ',
         'Dominica':	 'DM',
         'Dominican Rep.':	 'DO',
         'Ecuador':	 'EC',
         'Egypt':	 'EG',
         'Equatorial Guin':	 'GQ',
         'Estonia':	 'EE',
         'Ethiopia':	 'ET',
         'Fiji':	 'FJ',
         'Finland':	 'FI',
         'France':	 'FR',
         'Gabon':	 'GA',
         'Gambia':	 'GM',
         'Georgia':	 'GE',
         'Germany':	 'DE',
         'Ghana':	 'GH',
         'Greece':	 'GR',
         'Guam':	 'GU',
         'Guatemala':	 'GT',
         'Guinea':	 'GN',
         'Guyana':	 'GY',
         'Haiti':	 'HT',
         'Honduras':	 'HN',
         'Hong Kong':	 'HK',
         'Hungary':	 'HU',
         'India':	 'IN',
         'Indonesia':	 'ID',
         'Iraq':	 'IQ',
         'Ireland':	 'IE',
         'Israel':	 'IL',
         'Italy':	 'IT',
         'Jamaica':	 'JM',
         'Japan':	 'JP',
         'Jordan':	 'JO',
         'Kazakhstan':	 'KZ',
         'Kenya':	 'KE',
         'Kuwait':	 'KW',
         'Kyrgyzstan':	 'KG',
         'Laos':	 'LA',
         'Latvia':	 'LV',
         'Lebanon':	 'LB',
         'Liberia':	 'LR',
         'Libya':	 'LY',
         'Lithuania':	 'LT',
         'Luxembourg':	 'LU',
         'Macau':	 'MO',
         'Madagascar':	 'MG',
         'Malawi':	 'MW',
         'Malaysia':	 'MY',
         'Maldives':	 'MV',
         'Malta':	 'MT',
         'Mauretania':	 'MR',
         'Mauritius':	 'MU',
         'Mexico':	 'MX',
         'Moldova':	 'MD',
         'Monaco':	 'MC',
         'Mongolia':	 'MN',
         'Morocco':	 'MA',
         'Mozambique':	 'MZ',
         'Myanmar':	 'MM',
         'Namibia':	 'NA',
         'Nepal':	 'NP',
         'Netherlands':	 'NL',
         'New Zealand':	 'NZ',
         'Nicaragua':	 'NI',
         'Nigeria':	 'NG',
         'Norway':	 'NO',
         'Oman':	 'OM',
         'Pakistan':	 'PK',
         'Panama':	 'PA',
         'Pap. New Guinea':	 'PG',
         'Paraguay':	 'PY',
         'Peru':	 'PE',
         'Philippines':	 'PH',
         'Poland':	 'PL',
         'Portugal':	 'PT',
         'Puerto Rico':	 'PR',
         'Qatar':	 'QA',
         'Reunion':	 'RE',
         'Romania':	 'RO',
         'Russian Fed.':	 'RU',
         'Rwanda':	 'RW',
         'Salvador':	 'SV',
         'Samoa, America':	 'AS',
         'Saudi Arabia':	 'SA',
         'Senegal':	 'SN',
         'Serbia/Monten.':	 'CS',
         'Seychelles':	 'SC',
         'Sierra Leone':	 'SL',
         'Singapore':	 'SG',
         'Slovakia':	 'SK',
         'Slovenia':	 'SI',
         'South Africa':	 'ZA',
         'South Korea':	 'KR',
         'South Sudan':	 'SS',
         'Spain':	 'ES',
         'Sri Lanka':	 'LK',
         'Sudan':	 'SD',
         'Suriname':	 'SR',
         'Swaziland':	 'SZ',
         'Sweden':	 'SE',
         'Switzerland':	 'CH',
         'Syria':	 'SY',
         'Taiwan':	 'TW',
         'Tajikistan':	 'TJ',
         'Tanzania':	 'TZ',
         'Thailand':	 'TH',
         'Togo':	 'TG',
         'Trinidad,Tobago':	 'TT',
         'Tunisia':	 'TN',
         'Turkey':	 'TR',
         'Turkmenistan':	 'TM',
         'Uganda':	 'UG',
         'Ukraine':	 'UA',
         'United Arab Emirates':	 'AE',
         'United Kingdom':	 'GB',
         'Uruguay':	 'UY',
         'USA':	 'US',
         'Uzbekistan':	 'UZ',
         'Vanuatu':	 'VU',
         'Venezuela':	 'VE',
         'Vietnam':	 'VN',
         'Yemen':	 'YE',
         'YL':	 'IR',
         'Zimbabwe':	 'ZW',
         'ZZ':	 'ZZ',
         'MP':	 'MP',
         'GI':	 'GI',
         'SX':	 'SX',
         'CW':	 'CW',
         'ZM':	 'ZM',
         'RS':	 'RS',
         'TO':	 'TO',
         'ME':	 'ME',
         'AW':	 'AW',
         'Iceland':	 'IS'

    };

    getCountryCode(countryName) {
        return this.countryMapping[countryName] || null; // 如果没有找到，返回 null
    }

    connectedCallback(){
        console.log('connectedCallback' + this.recordId);
        this.wiredChannelOne();
        if(this.recordId == null || this.recordId == '' || this.status == 'edit'){
            this.isEditPage = true;
        }

        if (this.recordId) {
            this.handleGetShop();
        }
        this.getUserInfo();
    }

    @track customChannelOne = true;
    // @wire(getCustomChannel)
    wiredChannelOne() {
        getCustomChannel({}).then(result => {
            this.customChannelOne = result;
        }).catch(error => {
             console.error('Error fetching channel list:', error);
        });
    }

    getCountryStateId(param1,param2) {
        getCountryStateId({
            countryCode : param1,
            ProvinceName : param2
        }).then(result => {
            console.log('RETURN' + String.toString(result));
            return String.toString(result);
        })
    }

    
    handleGetShop() {
        getShopDetail({
            shopId : this.recordId
        }).then(result => {
            this.record = result.data.shopDetail;
            console.log('获取结果' + JSON.stringify(result));
            this.channelId = this.record['Account__c'];
            // this.sapCodeId = this.record['SAP_Code__c'];
            this.latitude = this.record['Shop_Center_Location__c'].latitude;
            this.longitude = this.record['Shop_Center_Location__c'].longitude;
            this.showAddressFlag = this.judgeNotEmpty(this.record['Country__c']);
            requestAnimationFrame(() => {
                this.updateLookup('.AccountProvince');
                // todo 解决Channel Item没有选项问题
                this.updateLookupChannelAllFilter();
                
            });
            this.provinceSelectId = result.data.provinceId;
            
        }).catch(error => {
        });
    }
    // todo 解决Channel Item没有选项问题
    updateLookupChannelAllFilter(){
        var cmps = this.template.querySelectorAll('.channelItem c-lookup-lwc');
        for (let i = 0; i < cmps.length; i++) {
            var lookup = cmps[i];
            lookup.updateOption({
                'lookup': 'CustomLookupProvider.ChannelAllFilter',
                'salesRegion': this.record.Sales_Region__c
            });
        }  
    }

    lookupChannelFilter = {
        'lookup': 'CustomLookupProvider.CustomerChannelFliter'
    }

    lookupChannelAll = {
        'lookup': 'CustomLookupProvider.ChannelAllFilter'
    }

    lookupSapCodeFilter = {
        'lookup': 'CustomLookupProvider.CustomerSapCodeFliter'
    }

    lookupCountryState = {
        'lookup': 'CustomLookupProvider.CountryStateFilter',
    }

    lookUpChangeProvinceStateHandler(event){
        let targetName = event.target.dataset.fieldName;
        if (event.detail.selectedRecord.Id === undefined || targetName == '') {
            this.record[targetName] = null;
        } else {
            // this.provinceSelectId = event.detail.selectedRecord.Id;
            this.record['State_Province__c'] = event.detail.selectedRecord.Name;
            this.record[targetName] = event.detail.selectedRecord.Id;
            // if(targetName === 'Province_State__c'){
            //     requestAnimationFrame(() => {
            //         this.updateLookup('.AccountCity');
            //     });
            // }
        }
    }

    updateLookup(name) {
        var cmps = this.template.querySelectorAll(name + ' c-account-look-up-lwc');
        for (let i = 0; i < cmps.length; i++) {
            var lookup = cmps[i];
            if(name === '.AccountCity'){
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.CountryStateFilter',
                    'belongToProvince': this.record.State_Province__c,
                });
            }else if(name === '.AccountProvince'){
                lookup.updateOption({
                    'lookup': 'CustomLookupProvider.CountryStateFilter',
                    'belongTo': this.record.Country__c,
                });
                lookup.parentSelectedRecord(this.record.Province_State__c);
            }
            return;
        }
    }
    removeLookup(name) {
        var cmps = this.template.querySelectorAll(name + ' c-account-look-up-lwc');
        for (let i = 0; i < cmps.length; i++) {
            var lookup = cmps[i];
            lookup.handleRemove();
        }
    }

    handleChannelChange(event) {
        console.log('-Channel--'+JSON.stringify(event.detail));
        let channel = event.detail.selectedRecord;
        if (channel==undefined || channel=='') {
            this.channelId = null;
        } else {
            this.channelId = channel.Id;
        }
        this.record.Account__c = this.channelId;
    }

    handleSapCodeChange(event) {
        console.log('-SapCode--'+JSON.stringify(event.detail));
        if (event.detail.selectedRecord==undefined) {
            this.sapCodeId = null;
        } else {
            this.sapCodeId = event.detail.selectedRecord.Id;
            if(this.sapCodeId != ''){
                this.handleGetAddress();
            }
        }
        // this.record.SAP_Code__c = this.sapCodeId;
    }

    @track addresult = {};
    handleGetAddress() {
        getAddress({
            sapCodeId : this.sapCodeId
        }).then(result => {
            console.log('getAdress' + JSON.stringify(result));
            this.addresult = result;
            let city = this.addresult.City__c == undefined ? null : this.addresult.City__c;
            let address = this.addresult.Address__c == undefined ? null : this.addresult.Address__c;
            let nationality = null;
            let name = null;
            console.log(JSON.stringify(this.addresult.Province_State__r) != undefined);
            console.log(JSON.stringify(this.addresult.Province_State__r));
            if(JSON.stringify(this.addresult.Province_State__r) != undefined) {
                const province = this.addresult.Province_State__r;
                if(province.Nationality__c) {
                    nationality = province.Nationality__c;
                }
                console.log(JSON.stringify(province.Name) != undefined);
                if(province.Name) {
                    name = province.Name;
                }
            }
            this.record.Country__c = nationality;
            this.record.State_Province__c = name;
            this.record.City__c = city;
            this.record.Address1__c = address;
            this.record.Shop_Center_Location__c = {};
        }).catch(error => {
            console.log('Error' + JSON.stringify(error));
        });
    }

    handleLatitudeChange(event) {
        this.latitude = event.target.value;
        this.record.Shop_Center_Location__Latitude__s = this.latitude;
        this.record.Shop_Center_Location__c = {};
    }

    handleLongitudeChange(event) {
        this.longitude = event.target.value;
        this.record.Shop_Center_Location__Longitude__s = this.longitude;
        this.record.Shop_Center_Location__c = {};
    }

    // 关闭弹出框
    closeModal(event){
        this.clearRecord();
        if(this.recordId) {
            this.goToRecordEdit(this.recordId);
        } else {
            this.goToObject('Shop__c');
        }
    }

    clearRecord(){
        this.channelId = '';
        this.sapCodeId = '';
        var lookup = this.template.querySelector('c-lookup-lwc');
        lookup.handleRemove();
        Object.keys(this.record).forEach(key => {
            this.record[key] = '';
        });
        this.record.Shop_Center_Location__c = {};

        console.log('页面数据' + JSON.stringify(this.record)); 
    }

    @track showAddressFlag = false;
    // new shop
    handleChange(event){
        const fieldName = event.target.dataset.fieldName;
        const fieldValue = event.target.value;
        if(fieldValue != null && fieldName != '') {
            const trans = this.capitalizeIfEnglish(fieldValue);
            this.record[fieldName] = trans;
        } else {
            this.record[fieldName] = fieldValue;
        }
        console.log(fieldName + 'Changed' + this.record[fieldName]);
        if(fieldName === 'Country__c'){
            if(this.judgeNotEmpty(fieldValue)){
                this.showAddressFlag = true;
                this.record.State_Province__c = '';
                this.template.querySelectorAll('.AccountProvince c-account-look-up-lwc').forEach(element => {
                    element.handleRemove();
                });
                requestAnimationFrame(() => {
                    this.updateLookup('.AccountProvince');
                });
            }else {
                this.showAddressFlag = false;
            }
            
        }
        // todo 解决Channel Item没有选项问题
        if(fieldName === 'Sales_Region__c'){
            requestAnimationFrame(() => {
                this.updateLookupChannelAllFilter();
            });
        }
    }

    // 保存
    handleSave(){
        this.saveShop(false);
    }
    // save & new
    handleSaveAndNew(){
        this.saveShop(true);
    }
    //
    saveShop(flag){
        this.isShowSpinner = true;
        console.log('SAVE' + JSON.stringify(this.record));
        if (this.validation()) {
            saveShop({
                recordJson : JSON.stringify(this.record),
            }).then(result => {
                if (result.isSuccess) {
                    this.showSuccess('Save Success!');
                    if(flag){
                        this.recordId == null;
                        this.clearRecord();
                    }else {
                        this.closeModal();
                    }
                    notifyRecordUpdateAvailable([{ recordId: this.recordId }]); // 刷新 LDS 缓存
                    // this.dispatchEvent(new CustomEvent('refreshView')); 
                }else{
                    const returnText  = result.message.substring(0, 255);
                    const keyword = '门店数据不允许创建';
                    if(returnText.includes(keyword)) {
                        this.showError(Permission_Denied);
                    } else {
                        this.showError(result.message);
                    }
                }
                this.isShowSpinner = false;
            }).catch(error => {
                this.showError('Save Failure!' + JSON.stringify(error));
                this.isShowSpinner = false;
            });
        }else {
            this.isShowSpinner = false;
        }
    }

    validation() {
        let allValid = true; 
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if(!element.reportValidity()){
                allValid = false;
            }
        });
        return allValid;
    }
    
    handleHasEdit(event){
        // 获取子级页面信息
        this.locationRecord = event.detail.location;
        console.log('locationRecord' + JSON.stringify(this.locationRecord)); 
        for (const key in this.locationRecord) {
            if(key == 'Country__c') {
                const countryApi = this.getCountryCode(this.locationRecord['Country__c']);
                this.locationRecord['Country__c'] = countryApi;
            }
            if (this.locationRecord[key]) { // 检查值是否非空
                this.record[key] = this.locationRecord[key]; // 将非空值放入 record 中
            }
        }
        if(this.judgeNotEmpty(this.locationRecord['Country__c']) && this.judgeNotEmpty(this.locationRecord['State_Province__c'])) {
            const provinceId = getCountryStateId(this.locationRecord['Country__c'],this.locationRecord['State_Province__c']);
            console.log('ID' + provinceId);
            if(this.judgeNotEmpty(provinceId)) {
                this.provincePickListShow = true;
                requestAnimationFrame(() => {
                    this.updateLookup('.AccountProvince');
                });
                this.provinceSelectId = provinceId;
            } else {
                this.provincePickListShow = false;
            }
        } 
        this.showAddressFlag = this.judgeNotEmpty(this.locationRecord['Country__c']);
        this.latitude = this.record['Shop_Center_Location__c'].latitude;
        this.longitude = this.record['Shop_Center_Location__c'].longitude;
        this.record['Shop_Center_Location__Latitude__s'] = this.latitude;
        this.record['Shop_Center_Location__Longitude__s'] = this.longitude;
        console.log('Updated record:', JSON.stringify(this.record));
    }

    handleCloseLocation() {
        this.openLocationPage = false;
    }

    openLocation(){
        this.openLocationPage = true;
    }

    handleRefreshData() {
        console.log('--------');
    }

    capitalizeIfEnglish(text) {
        //检查是否只包含英文字母和空格
        const isEnglish = /^[a-zA-Z\s]*$/.test(text);
        if (isEnglish) {
            return text.charAt(0).toUpperCase() + text.slice(1);
        }
        return text;
    }

    judgeNotEmpty(fieldValue){
        if(fieldValue != undefined && fieldValue != null && fieldValue != "") {
            return true;
        }else{
            return false;
        }
    }


}