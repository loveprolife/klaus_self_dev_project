/*
 * @Author: WFC
 * @Date: 2024-11-05 16:01:18
 * @LastEditors: WFC
 * @LastEditTime: 2024-11-07 11:18:46
 * @Description: 
 * @FilePath: \hisense005\force-app\main\default\lwc\wasLwc\wasLwc.js
 */
import { LightningElement, api, track } from 'lwc';

export default class WasLwc extends LightningElement {

    @api recordId;
    
    @api documentTitle;// 页面配置信息

    @track flag = true;

    // 手机端
    get isMobile() {
        var userAgent = navigator.userAgent;
        if (/iphone|iPhone|ipad|iPad|ipod|iPod|iOS|ios/.test(userAgent) || /android|Android/.test(userAgent)) {  
            return true;
        } else { 
            return false;
        }
    }

    handleIframeLoad(event) {
        let addUrl = window.location.href;
        // 判断地址是否是Edit page：含有 /visualEditor/appBuilder.app和/flexipageEditor/surface.app
        if(this.flag && addUrl.indexOf('/visualEditor/appBuilder.app') == -1 && addUrl.indexOf('/flexipageEditor/surface.app') == -1){
            // 判断是否为移动端
            if (this.isMobile) {
                // 截取/native/bridge.app，拼接地址
                let appUrl = '/native/bridge.app';
                addUrl = addUrl.substring(0, addUrl.indexOf(appUrl)) + appUrl + '/' + this.documentTitle;
            }
            // else if(this.recordId != null && this.recordId != '' && this.recordId != undefined){
            //     // 拆分地址
            //     addUrl = addUrl.substring(0, addUrl.indexOf(this.recordId) - 1);
            // }
            // 构造要传递的数据
            const message = {
                customUrl: addUrl,
                documentTitle: this.documentTitle,
            };
            // 当 iframe 加载完成时，可以发送消息
            const iframe = event.target;
            iframe.contentWindow.postMessage(message, '*');
            this.flag = false;
        }
        
    }

    connectedCallback(){
        this.flag = true;
    }

}