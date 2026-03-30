export default class FileHandle {

    FILE_All = 'SFFileAll_';
    FILE_SPLIT = 'SFFileSplit_';

    split(file, MAX_COUNT_LENGTH) {
        if (!MAX_COUNT_LENGTH) {
            MAX_COUNT_LENGTH = 131000;
        }
        let msg = null;
        try {
            /**
             * file : {
             *      packageId,      packageId
             *      recordId,       recordId
             *      name,           文件名
             *      base64          base64字节流
             * }
             * 
             * MAX_COUNT_LENGTH ： 切片大小
             */
            
            // 生成 packageId (uuid)
            // var packageId = this.newPackageId(16,16)+'_'+this.getDateNowYYYYMMDDHHMMSS();
            var packageId = file.packageId;
            // 切片分组
            var fileBase64Count = Math.ceil(file.base64.length / MAX_COUNT_LENGTH);
    
            // 获取localstorage对象
            var storage = window.localStorage;
            // 储存总数据
            storage.setItem(this.FILE_All+file.packageId, JSON.stringify(file));
            // 切片起始位置
            var startIdx = 0;
            // 切片结束位置
            var endIdx = fileBase64Count==1 ? file.base64.length : startIdx+MAX_COUNT_LENGTH;
            for (let i = 0; i < fileBase64Count; i++) {
                
                var fileItem = {
                    packageId : packageId,
                    packageItemId : packageId+'_'+fileBase64Count+'_'+(i+1),
                    fileName : file.name,
                    recordId : file.recordId,
                    base64 : file.base64.substring(startIdx,endIdx),
                    count : (i+1),
                    countMax : fileBase64Count
                }
    
                storage.setItem(this.FILE_SPLIT+fileItem.packageItemId, JSON.stringify(fileItem));
    
                startIdx = endIdx;
                endIdx = i==(fileBase64Count-1) ? file.base64.length : endIdx+MAX_COUNT_LENGTH;
            }
    
            console.log('Files Saved');
            return msg;
        } catch (error) {
            msg = JSON.stringify(error);
            return msg;
        }

    }

    delFiles(packageId) {
        if (!packageId) {
            return;
        }
        localStorage.removeItem(this.FILE_All+packageId);
        var len = window.localStorage.length;
        console.log(len);
        for (let i = 0; i < len; i++) {
            var getKey = localStorage.key(i);
            console.log(getKey);
            if (getKey.substring(0,(12+packageId.length)) == (this.FILE_SPLIT+packageId)) {
                localStorage.removeItem(getKey);
            }
        }
    }

    getFiles(packageIds) {
        var len = window.localStorage.length;
        console.log(len);
        var files = [];
        for (let i = 0; i < len; i++) {
            var getKey = localStorage.key(i);
            console.log(getKey);
            if (getKey.substring(0,10) == this.FILE_All && (!packageIds || packageIds.indexOf(getKey.replace(this.FILE_All, '')) > -1)) {
                var getVal = localStorage.getItem(getKey);
                var fileItem = JSON.parse(getVal);
                files.push(fileItem);
            }
        }

        return files;
    }

    clearAllItems() {
        var len = window.localStorage.length;
        console.log(len);
        for (let i = 0; i < len; i++) {
            var getKey = localStorage.key(i);
            console.log(getKey);
            if (getKey.substring(0,10) == this.FILE_All || getKey.substring(0,12) == this.FILE_SPLIT) {
                localStorage.removeItem(getKey);
            }
        }
    }

    getMimeType(dataUrl) {
        return dataUrl.substring(0, dataUrl.indexOf('base64,')).replace('data:', '').replace(';', '');
    }
    
    isUploading(packageId) {
        // 获取localstorage对象
        var storage = window.localStorage;
        var packageItem = storage.getItem(this.FILE_SPLIT+packageId);
        if (packageItem) {
            return true;
        } else {
            return false;
        }
    }

    newPackageId(len, radix) {
        if (len==undefined||len==null) {
            len = 16;
        }
        
        if (radix==undefined||radix==null) {
            radix = 16;
        }

        var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
        var uuid = [],
            i;
        radix = radix || chars.length;
     
        if (len) {
            for (i = 0; i < len; i++) uuid[i] = chars[0 | Math.random() * radix];
        } else {
            var r;
            uuid[8] = uuid[13] = uuid[18] = uuid[23] = '-';
            uuid[14] = '4';
            for (i = 0; i < 36; i++) {
                if (!uuid[i]) {
                    r = 0 | Math.random() * 16;
                    uuid[i] = chars[(i == 19) ? (r & 0x3) | 0x8 : r];
                }
            }
        }

        return uuid.join('') + '_' + this.getDateNowYYYYMMDDHHMMSS();
    }

    getDateNowYYYYMMDDHHMMSS() {
        var d = new Date();
        var year = d.getFullYear().toString();
        var month = (d.getMonth()+1).toString().length == 1 ? '0'+(d.getMonth()+1).toString() : (d.getMonth()+1).toString();
        var day = d.getDate().toString().length == 1 ? '0'+d.getDate().toString() : d.getDate().toString();
        var hour = d.getHours().toString().length == 1 ? '0'+d.getHours().toString() : d.getHours().toString();
        var minutes = d.getMinutes().toString().length == 1 ? '0'+d.getMinutes().toString() : d.getMinutes().toString();
        var seconds = d.getSeconds().toString().length == 1 ? '0'+d.getSeconds().toString() : d.getSeconds().toString();
        var milliseconds = d.getMilliseconds().toString().length == 1 ? '00'+d.getMilliseconds().toString() : (d.getMilliseconds().toString().length == 2 ? '0'+d.getMilliseconds().toString() : d.getMilliseconds().toString());

        return year+month+day+hour+minutes+seconds+milliseconds;
    }
}