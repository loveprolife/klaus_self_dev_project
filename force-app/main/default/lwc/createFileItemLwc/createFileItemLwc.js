import { LightningElement, track, api, wire } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { LightningElementEx } from 'c/lwcUtils';

import getPackages from '@salesforce/apex/UploadFilesController.getPackages';

export default class CreateFileItemLwc extends LightningElementEx {

    SFSPLIT = 'SFFileSplit_';
    SFALL = 'SFFileAll_';
    @api isSpecified;
    needUploadPackageIds = [];
    itemRecordTypeId;

    @wire(getObjectInfo, { objectApiName: 'FileItem__c' })
    wiredFileItemInfo({ error, data }) {
        if (data) {
            var recordTypeIds = Object.keys(data.recordTypeInfos);
            for (let i = 0; i < recordTypeIds.length; i++) {
                var recordTypeId = recordTypeIds[i];
                if (data.recordTypeInfos[recordTypeId].name == 'Item') {
                    this.itemRecordTypeId = recordTypeId;
                    continue;
                }
            }
        } else if (error) {
            this.itemRecordTypeId = 'error';
            console.log(error);
        }
    }

    connectedCallback() {
        // 切片上传
        this.checkItemRecordTypeId();
        // File item head检查
        if (!this.isSpecified) {
            this.checkFileItemHead();
        }
    }

    @api
    newNeedUpload(packageIds) {
        if (!this.isSpecified) {
            return;
        }
        if (packageIds && packageIds.length>0) {
            this.needUploadPackageIds.push(...packageIds);
            this.checkFileItemHeadIds();
        }
    }

    checkFileItemHeadIds() {
        console.log('checkFileItemHeadIds');
        if (this.needUploadPackageIds.length>0) {
            setTimeout(() => {
                var packageMaps = {};
                for (let i = 0; i < this.needUploadPackageIds.length; i++) {
                    var getKey = this.SFALL + this.needUploadPackageIds[i];
                    var getVal = localStorage.getItem(getKey);
                    if (getVal) {
                        var fileItem = JSON.parse(getVal);
                        packageMaps[this.needUploadPackageIds[i]] = fileItem;
                    }
                }
                getPackages({
                    packageIds : this.needUploadPackageIds
                }).then(result => {
                    if (result.isSuccess) {
                        var completedfiles = {};
                        let b_comp = false;
                        for (let index = 0; index < result.data.length; index++) {
                            const element = result.data[index];
                            if (packageMaps[element.PackageId__c] && element.CompleteDateTime__c && element.ContentBodyId__c && element.ContentDocumentId__c && element.ContentVersionId__c) {
                                packageMaps[element.PackageId__c]['CompleteDateTime'] = element.CompleteDateTime__c;
                                packageMaps[element.PackageId__c]['ContentBodyId'] = element.ContentBodyId__c;
                                packageMaps[element.PackageId__c]['ContentDocumentId'] = element.ContentDocumentId__c;
                                packageMaps[element.PackageId__c]['ContentVersionId'] = element.ContentVersionId__c;
                                packageMaps[element.PackageId__c]['base64'] = '';
                                completedfiles[element.PackageId__c] = (packageMaps[element.PackageId__c]);
                                b_comp = true;
                                localStorage.setItem(this.SFALL+element.PackageId__c, JSON.stringify(packageMaps[element.PackageId__c]));

                                var newids = [];
                                this.needUploadPackageIds.forEach(obj => {
                                    if (obj!=element.PackageId__c) {
                                        newids.push(obj);
                                    }
                                });
                                this.needUploadPackageIds = newids;
                            }
                        }
                        if (b_comp) {
                            this.dispatchEvent(new CustomEvent('completedfiles',{
                                detail: {
                                    records : completedfiles
                                }
                            }));
                        }
                    } else {
                        console.log(result.message);
                    }
                    this.checkFileItemHeadIds();
                }).catch(error => {
                    console.log(this.getErrorMessage(error));
                    this.checkFileItemHeadIds();
                })
                
            }, 3000);
        }
    }

    checkItemRecordTypeId () {
        if (this.itemRecordTypeId==undefined || this.itemRecordTypeId==null) {
            setTimeout(() => {
                this.checkItemRecordTypeId();
            }, 100);
        } else if (this.itemRecordTypeId != 'error') {
            this.createFileItem();
            
        } else {
            console.log('bug');
        }
    }

    createFileItem() {
        try {
            console.log('createFileItem');
            // console.log('itemRecordTypeId');
            // console.log(this.itemRecordTypeId);
            var len = window.localStorage.length;
            // console.log(len);
            let arr = [];
            let arrPackageIds = [];
            for (let i = 0; i < len; i++) {
                var getKey = localStorage.key(i);
                console.log('createFileItem -> '+getKey);
                if (getKey.substring(0,12) == this.SFSPLIT) {
                    var getVal = localStorage.getItem(getKey);
                    if (getVal == null) {
                        continue;
                    }
                    // console.log(getVal);
                    var fileItem = JSON.parse(getVal);

                    if (this.isSpecified && !(this.needUploadPackageIds.indexOf(fileItem.packageId)>-1)) {
                        continue;
                    }

                    const recordInput = {
                        apiName: 'FileItem__c',
                        fields: {
                            PackageId__c : fileItem.packageId,
                            ItemId__c : fileItem.packageItemId,
                            FileName__c : fileItem.fileName,
                            RecordId__c : fileItem.recordId,
                            Base64__c : fileItem.base64,
                            Index__c : fileItem.count,
                            IndexMax__c : fileItem.countMax,
                            RecordTypeId : this.itemRecordTypeId
                        }
                    };

                    arr.push(createRecord(recordInput));
                    arrPackageIds.push(fileItem.packageItemId);
                    // createRecord(recordInput).then(result => {
                    //     window.localStorage.removeItem(this.SFSPLIT+result.fields.ItemId__c.value);
                    //     this.removeFile(result.fields.PackageId__c.value)
                    // }).catch(e => {
                    //     console.log('error='+JSON.stringify(e));
                    // })
                }
            }
            Promise.all(arr.map(p => p.catch(e => {
                var eJson = JSON.stringify(e);
                console.log(`pe=`+eJson); 
                if (eJson.indexOf('"errorCode":"DUPLICATE_VALUE"')>-1) {
                    return 1;
                }
                return -1;
            })))
            .then(res => {
                //   console.log(`map res=${res}`);
                for (let i=0; i<res.length; ++i) {
                    if (res[i]) {
                        if (res[i]==-1) {
                            //b_comp = false;
                            continue;
                        }
                        if (res[i]==1) {
                            window.localStorage.removeItem(this.SFSPLIT+arrPackageIds[i]);
                            this.checkLastFileItem(arrPackageIds[i]);
                        } else {
                            //   console.log(`map res[${i}]=${res[i]}`);
                            window.localStorage.removeItem(this.SFSPLIT+res[i].fields.ItemId__c.value);
                            this.checkLastFileItem(res[i].fields.PackageId__c.value);
                        }
                    }
                }
                // this.dispatchEvent(new CustomEvent('completedfiles',{
                //     detail: {
                //         records : completedfiles
                //     }
                // }));
                setTimeout(() => {
                    this.createFileItem();
                }, 3000);
            })
            .catch(err => {
                console.log(`map err=${err}`);
                
                setTimeout(() => {
                    this.createFileItem();
                }, 3000);
            });
        } catch (error) {
            console.log(error);
            setTimeout(() => {
                this.createFileItem();
            }, 3000);
        }
    }

    checkFileItemHead() {
        
        setTimeout(() => {
            console.log('checkFileItemHead');
            var len = window.localStorage.length;
            // console.log(len);
            var files = [];
            for (let i = 0; i < len; i++) {
                var getKey = localStorage.key(i);
                console.log('checkFileItemHead -> '+getKey);
                if (getKey.substring(0,10) == this.SFALL) {
                    var getVal = localStorage.getItem(getKey);
                    // console.log(getVal);
                    var fileItem = JSON.parse(getVal);
                    files.push(fileItem);
                }
            }

            var packageIds = [];
            var packageMaps = {};
            for (let i = 0; i < files.length; i++) {
                var fileItem = files[i];
                if (fileItem.ContentBodyId && fileItem.ContentDocumentId && fileItem.ContentVersionId && fileItem.CompleteDateTime) {
                    // 有附件Id并且时间大于一小时
                    if (Date.now()-new Date(fileItem.CompleteDateTime)>3600000) {
                        localStorage.removeItem(this.SFALL+fileItem.packageId);
                    }
                } else {
                    packageIds.push(fileItem.packageId);
                    packageMaps[fileItem.packageId] = fileItem;
                }
            }

            if (packageIds.length>0) {
                
                getPackages({
                    packageIds : packageIds
                }).then(result => {
                    if (result.isSuccess) {
                        // let dataMap = {}
                        var completedfiles = {};
                        let b_comp = false;
                        for (let index = 0; index < result.data.length; index++) {
                            const element = result.data[index];
                            // dataMap[element.PackageId__c] = element;
                            if (packageMaps[element.PackageId__c] && element.CompleteDateTime__c && element.ContentBodyId__c && element.ContentDocumentId__c && element.ContentVersionId__c) {
                                packageMaps[element.PackageId__c]['CompleteDateTime'] = element.CompleteDateTime__c;
                                packageMaps[element.PackageId__c]['ContentBodyId'] = element.ContentBodyId__c;
                                packageMaps[element.PackageId__c]['ContentDocumentId'] = element.ContentDocumentId__c;
                                packageMaps[element.PackageId__c]['ContentVersionId'] = element.ContentVersionId__c;
                                packageMaps[element.PackageId__c]['base64'] = '';
                                completedfiles[element.PackageId__c] = (packageMaps[element.PackageId__c]);
                                b_comp = true;
                                localStorage.setItem(this.SFALL+element.PackageId__c, JSON.stringify(packageMaps[element.PackageId__c]));
                            }
                        }
                        if (b_comp) {
                            this.dispatchEvent(new CustomEvent('completedfiles',{
                                detail: {
                                    records : completedfiles
                                }
                            }));
                        }
                    } else {
                        console.log(result.message);
                    }
                    this.checkFileItemHead();
                }).catch(error => {
                    console.log(this.getErrorMessage(error));
                    this.checkFileItemHead();
                })
            } else {
                this.checkFileItemHead();
            }
        }, 3000);
    }

    checkLastFileItem(packageId) {
        var len = window.localStorage.length;
        // console.log(len);
        var keySet = [];
        for (let i = 0; i < len; i++) {
            var getKey = localStorage.key(i);
            keySet.push(getKey);
        }
        console.log('keySet->'+keySet);
        if (keySet.filter(obj => obj.includes(this.SFSPLIT+packageId,0)).length==0 && window.localStorage.getItem(this.SFALL+packageId)!=null) {
            var fileHead = JSON.parse(localStorage.getItem(this.SFALL+packageId));
            var completedfiles = {};
            completedfiles[packageId] = fileHead;
            this.dispatchEvent(new CustomEvent('completedfiles',{
                detail: {
                    records : completedfiles
                }
            }));
            // this.checkPackage(packageId);
        }
    }

    /*
    checkPackage(packageId) {
        checkPackage({
            packageId : packageId
        }).then(result => {
            
            console.log(result);
            if (result=='updated' || result=='insert') {
                console.log(result);
                window.localStorage.removeItem(this.SFALL+packageId);
            }

        }).catch(e => {
            console.log('error');
            console.log(JSON.stringify(e));
        })
    }
    */
}