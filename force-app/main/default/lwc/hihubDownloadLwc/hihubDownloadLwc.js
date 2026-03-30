/*
 * @Author: WFC
 * @Date: 2026-01-23 09:55:00
 * @LastEditors: Do not edit
 * @LastEditTime: 2026-01-23 14:32:51
 * @Description: 
 * @FilePath: \testuat\force-app\main\default\lwc\hihubDownloadLwc\hihubDownloadLwc.js
 */
import { LightningElement, api, track, wire } from 'lwc';
import hiwsDownload from '@salesforce/resourceUrl/hihubDownload';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

export default class HihubDownloadLwc extends NavigationMixin(LightningElement) {
    @api height = '100vh';
    @track isLoading = true;
    @track hasError = false;
    errorMessage;

    get iframeSrc() {
        // 直接获取完整URL
        const fullUrl = window.location.href;
        console.log('wwww--fullUrl-' + fullUrl);
        // 判断site站点是哪个页面
        if (fullUrl.includes('/HihubHMDownload')){
            // 指向静态资源zip内的 down.html
            return `${hiwsDownload}/hmDown.html`;
        }else {
            // 指向静态资源zip内的 down.html
            return `${hiwsDownload}/down.html`;
        }
    }

    get computedStyle() {
        // 允许传入像素或百分比，最小宽度100%
        const h = this.height || '100vh';
        return `width: 100%; height: ${h}; border: 0;`;
    }

    handleIframeLoad() {
        this.isLoading = false;
        this.hasError = false;
    }

    handleIframeError() {
        this.isLoading = false;
        this.hasError = true;
        this.errorMessage = '内容加载失败，请联系管理员或稍后再试。';
    }

    getCurrentUrlManually() {
        // 直接获取完整URL
        const fullUrl = window.location.href;
        // 解析URL中的参数（示例）
        const urlParams = new URLSearchParams(window.location.search);
        const recordId = urlParams.get('recordId'); // 获取URL中的recordId参数
        
    }
}