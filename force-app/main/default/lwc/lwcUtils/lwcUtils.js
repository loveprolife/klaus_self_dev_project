import LightningElementEx from './lightningElementEx';
import LightningNavigationElement from './lightningNavigationElement';
import GoogleMapApi from './googleMapApi';
import FileHandle from './fileHandle';

const formatPrice = (num) =>{
    // if( !num ) return '0.00'
    try {
        let numStr = num.toFixed(2);
        let arr = numStr.split('.');
        return parseInt(arr[0]).toLocaleString()+'.'+arr[1];
    } catch (error) {
        console.log(error);
        return '0.00'
    } 
}

String.prototype.format = function() {
    var args = arguments;
    return this.replace(/{(\d+)}/g, function(match, number) {
        return typeof args[number] != undefined ? args[number] : "";
    });
}

Date.prototype.format = function (fmt) {
    //author: meizz
    var o = {
      "M+": this.getMonth() + 1, //月份
      "d+": this.getDate(), //日
      "h+": this.getHours(), //小时
      "m+": this.getMinutes(), //分
      "s+": this.getSeconds(), //秒
      "q+": Math.floor((this.getMonth() + 3) / 3), //季度
      S: this.getMilliseconds() //毫秒
    };
    if (/(y+)/.test(fmt))
        fmt = fmt.replace(
        RegExp.$1,
        (this.getFullYear() + "").substr(4 - RegExp.$1.length)
        );
    for (var k in o)
        if (new RegExp("(" + k + ")").test(fmt))
        fmt = fmt.replace(
            RegExp.$1,
            RegExp.$1.length == 1 ? o[k] : ("00" + o[k]).substr(("" + o[k]).length)
        );
    return fmt;
};

if (!Array.prototype.indexOf) {
    Array.prototype.indexOf = function(item) {
        if ( this === undefined || this === null ) {
            throw new TypeError( '"this" is null or not defined' );
        }
     
        for (let fromIndex = 0; fromIndex < this.length; fromIndex++) {
            if (this[fromIndex] === item) {
                return fromIndex;
            }
        }
     
        return -1;
    }
}

const readFile = (file) => {
    // 获取上传图片的base64
    return new Promise(resolve => {
        // 文件读取
        var reader = new FileReader();
        reader.onload = (e) => {
            var base64 = e.target.result;
            resolve(base64);
        };
        reader.readAsDataURL(file);
    });
}

export { formatPrice, LightningElementEx, LightningNavigationElement, GoogleMapApi, FileHandle, readFile };