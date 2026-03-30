import { api, track, wire } from 'lwc';
import { LightningNavigationElement } from 'c/lwcUtils'
import { createRecord, deleteRecord, getRecord, getFieldValue  } from 'lightning/uiRecordApi';
import checkAuthorEmail from '@salesforce/apex/TrainingDocumentController.checkAuthorEmail';
import checkUploadExtraPerson from '@salesforce/apex/TrainingDocumentController.checkUploadExtraPerson';
import editExtrPerson from '@salesforce/apex/TrainingDocumentController.editExtrPerson';
import NAME_FIELD from "@salesforce/schema/Learning_Platform_Management__c.Name";
import AUTHOR from "@salesforce/schema/Learning_Platform_Management__c.Author__c";

export default class LearningPlatformManagementNewLwc extends LightningNavigationElement {

    @api recordId;

    @track isNew = false;
    @track isShowSpinner = false;
    // @track isNotHaveFile = false;
    // @track isHaveFile = false;
    @track isErrorAuthor = false;
    @track isErrorExtraPerson = false;
    @track isErrorExtraPersonMessage = '';
    @track fileName = '';
    @track author = '';
    
    filesUploaded = [];
    file;
    fileContents;
    fileReader;

    options = [
        { label: 'Ross', value: 'option1' },
        { label: 'Rachel', value: 'option2' },
    ];

    // Select option1 by default
    value = 'option1';

    handleChange(event) {
        const selectedOption = event.detail.value;
        console.log('wwww: ' + selectedOption);
    }

    // isDoc = false;
    // isEXCEL = false;
    // isTEXT = false;
    // isJPG = false;
    // isCSV = false;
    // isPDF = false;
    // isPPT = false;
    // isMP4 = false;
    // isUnkown = false;

    get acceptedType() {
        return ['.docx', '.doc', '.ppt', '.pptx', '.xls', '.xlsx', '.txt', '.mp4', '.pdf', '.png', '.jpg', '.jpeg', '.csv'];
    }

    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD, AUTHOR], })
    trainingDocument;

    get recordName() {
        return getFieldValue(this.trainingDocument.data, NAME_FIELD);
    }

    connectedCallback(){
        console.log('wwwww--recordId-' + this.recordId);
        this.dispatchEvent(new CustomEvent('refreshview')); 
        if(this.dataIsNull(this.recordId)){
            this.isNew = true;
        }else {
            editExtrPerson({ 
                recordId: this.recordId
            })
            .then(result => {
                if(result){

                    console.log('wwwww--' + JSON.stringify(result));
                    result.forEach(item => {
                        console.log('wwwww--' + JSON.stringify(item));
                        this.extraPersonPill(item.Username, item.FullPhotoUrl);
                     });
                }
            }).catch(error => {
                
            });
            this.author = getFieldValue(this.trainingDocument.data, AUTHOR);
            this.isNew = false;
        }
    }

    // handleFilesClick(){
    //     this.isNotHaveFile = false;
    // }

    // clearFileType(){
    //     this.isDoc = false;
    //     this.isEXCEL = false;
    //     this.isTEXT = false;
    //     this.isJPG = false;
    //     this.isCSV = false;
    //     this.isPDF = false;
    //     this.isPPT = false;
    //     this.isMP4 = false;
    //     this.isUnkown = false;
    // }

    // handleFilesChange(event) {
    //     if(event.target.files.length > 0) {
    //         this.filesUploaded = event.target.files;
    //         this.fileName = event.target.files[0].name;
    //         const flieArr = event.target.files[0].name.split('.');
	// 		this.fileType = (flieArr[flieArr.length - 1] + '').toLowerCase();
    //         this.clearFileType();
    //         if(this.fileType.indexOf('doc') !== -1){
    //             this.isDoc = true;
    //         }else if(this.fileType.indexOf('xls') !== -1){
    //             this.isEXCEL = true;
    //         }else if(this.fileType.indexOf('txt') !== -1){
    //             this.isTEXT = true;
    //         }else if(this.fileType.indexOf('jpg') !== -1 || this.fileType.indexOf('jpeg') !== -1 || this.fileType.indexOf('png') !== -1){
    //             this.isJPG = true;
    //         }else if(this.fileType.indexOf('csv') !== -1){
    //             this.isCSV = true;
    //         }else if(this.fileType.indexOf('pdf') !== -1){
    //             this.isPDF = true;
    //         }else if(this.fileType.indexOf('ppt') !== -1){
    //             this.isPPT = true;
    //         }else if(this.fileType.indexOf('mp4') !== -1){
    //             this.isMP4 = true;
    //         }else {
    //             this.isUnkown = true;
    //         }
    //         this.isHaveFile = true;
    //     }
    // }

    // 查询作者名称
    checkAuthorEmail(event){
        this.isErrorAuthor = false;
        const authorEmail = event.target.value;
        console.log('wwwww--authorEmail-' + authorEmail);
        checkAuthorEmail({ 
            authorEmail: authorEmail.trim()
        })
        .then(result => {
            console.log('wwwww--result-' + JSON.stringify(result));
            console.log('wwwww--result-' + result.isSuccess);
            if(result.isSuccess){
                this.author = result.author;
            }else {
                this.author = '';
            }
        }).catch(error => {
            this.author = '';
        });
    }


    handleCancelClick(){
        this.dispatchEvent(new CustomEvent('refreshview')); 
        window.history.go(-1);
    }

    handleSaveClick(event){
        event.preventDefault();       // stop the form from submitting
        let fields = event.detail.fields;
        let flag = true;
        if(this.author == ''){
            this.isErrorAuthor = true;
            flag = false;
        }
        // if(!this.isHaveFile){
        //     this.isNotHaveFile = true;
        //     flag = false;
        // }
        if(flag){
            this.isShowSpinner = true;
            fields.Author__c = this.author;
            fields.Extra_Person__c = this.pillToText();
            console.log('wwww--fields-' + JSON.stringify(fields));
            try{
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }catch (e) {
                this.isShowSpinner = false;
            }
            
        }
        
    }

    handleSuccessClick(event){
        this.recordId = event.detail.id;
        this.isShowSpinner = false;
        this.showSuccess('Save Success');
        this.goToRecord(this.recordId);
        // 保存文件
        // this.readFileAsDataURL();
        
    }

    // readFileAsDataURL() {
    //     this.file = this.filesUploaded[0];
    //     const reader = new FileReader();
    //     reader.onload = () => {
    //         this.fileContents = reader.result.split(',')[1]; // 获取 Base64 编码的文件内容
    //         this.saveToFile();
    //     };
    //     reader.readAsDataURL(this.file);
    // }

    // saveToFile() {
    //     // 创建 ContentVersion 记录
    //     const recordInput = { 
    //         apiName: 'ContentVersion', 
    //         fields : {
    //             "PathOnClient": this.file.name,
    //             "Title": this.file.name,
    //             "VersionData": this.fileContents,
    //             "FirstPublishLocationId" : this.recordId
    //         } 
    //     };

    //     createRecord(recordInput)
    //         .then(contentVersion => {
    //             this.isShowSpinner = false;
    //             this.showSuccess('Create Success');
    //             this.dispatchEvent(new CustomEvent('refreshview')); 
    //         })
    //         .catch(error => {
    //             this.isShowSpinner = false;
    //             console.log('wwww--error--' + JSON.stringify(error));
    //             this.showError('Create Error');
    //             this.deleteRecord();
    //         });
    // }

    // deleteRecord(){
    //     deleteRecord(this.recordId);
    // }

    @track items = [
        // {
        //     type: 'avatar',
        //     href: '',
        //     label: 'Avatar Pill 1',
        //     src: '',
        //     fallbackIconName: 'standard:user',
        //     variant: 'circle',
        //     alternativeText: 'User avatar',
        //     isLink: true,
        // },
    ];

    // addExtraPerson
    // handlePersonText(event){
    //     this.addExtraPerson = event.target.value;
    //     this.isErrorExtraPerson = false;
    // }

    // handleAddPersonClick(){
    //     console.log('wwww--addExtraPerson-' + this.addExtraPerson);
    //     if(this.dataIsNull(this.addExtraPerson)){
    //         this.isErrorExtraPerson = true;
    //         this.isErrorExtraPersonMessage = 'The Extra Person cannot be empty';
    //         return; 
    //      }
    //     // 查询系统用户
    //     checkAuthorEmail({ 
    //         authorEmail: this.addExtraPerson.trim()
    //     })
    //     .then(result => {
    //         if(result.isSuccess){
    //             this.isErrorExtraPerson = false;
    //             this.extraPersonPill(this.addExtraPerson, result.photoUrl);
    //         }else {
    //             this.isErrorExtraPerson = true;
    //             this.isErrorExtraPersonMessage = 'The Extra Person does not exist';
    //         }
    //     }).catch(error => {
    //         this.isErrorExtraPerson = true;
    //         this.isErrorExtraPersonMessage = 'The Extra Person does not exist';
    //     });
    // }

    // 插入信息到pill
    extraPersonPill(extraPerson, photoUrl){
        if(this.dataIsNull(this.items)){
            this.pushPill(extraPerson, photoUrl);
        }else {
            let sameItem = this.items.filter(obj => obj.name == this.addExtraPerson);
            if(this.dataIsNull(sameItem)){
                this.pushPill(extraPerson, photoUrl);
            }
        }
    }

    pushPill(extraPerson, photoUrl){
        let pill = {
            type: 'avatar',
            href: '',
            label: extraPerson,
            name: extraPerson,
            src: photoUrl,
            fallbackIconName: 'standard:user',
            variant: 'circle',
            isLink: true,
        };
        this.items.push(pill);
    }

    pillToText(){
        let extraPerson = '';
        this.items.forEach(item =>{
            if(!this.dataIsNull(item.name)){
                extraPerson += item.name + ','
            }
        });
        return extraPerson.substring(0, extraPerson.length - 1);
    }

    handleExtraPersonFile(event){
        if(event.target.files.length > 0) {
            this.isShowSpinner = true;
            this.filesUploaded = event.target.files;
            this.handleSavePersonFile();
        }
    }

    handleSavePersonFile() {
        this.file = this.filesUploaded[0];
        this.fileReader= new FileReader();
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            let base64 = 'base64,';
            this.content = this.fileContents.indexOf(base64) + base64.length;
            this.fileContents = this.fileContents.substring(this.content);
            this.checkUploadExtraPerson();
        });
        this.fileReader.readAsDataURL(this.file);
    }
    
    checkUploadExtraPerson() {
        checkUploadExtraPerson({fileName: this.file.name, base64Data: encodeURIComponent(this.fileContents)})
        .then(result => {
            this.isErrorExtraPerson = false;
            this.items = [];
            // 前端展示
            let rightUser = result.rightUser;
            let wrongUser = result.wrongUser;

            rightUser.forEach(item => {
               this.extraPersonPill(item.Username, item.FullPhotoUrl);
            });
            
            if(!this.dataIsNull(wrongUser)){
                console.log('wwww----' + wrongUser);
                this.isErrorExtraPerson = true;
                this.isErrorExtraPersonMessage = wrongUser.toString();
            }
            this.isShowSpinner = false;
            this.showSuccess('Upload Success');
        })
        .catch(error => {
            this.isShowSpinner = false;
            this.showError('Upload Error');
        });
    }



    handleItemRemove(event) {
        const name = event.detail.item.name;
        console.log('wwww--name111-' + JSON.stringify(event.detail.item));
        console.log('wwww--name-' + name);
        const index = event.detail.index;
        this.items.splice(index, 1);
    }

    dataIsNull(info){
        if(info == null || info == '' || info == undefined){
            return true;
        }else {
            return false;
        }
    }
}