/*
 * @Author: WFC
 * @Date: 2024-04-18 11:45:18
 * @LastEditors: WFC
 * @LastEditTime: 2024-04-18 11:46:14
 * @Description: 
 * @FilePath: \hisenseall-231026\force-app\main\default\lwc\dailySalesNoUploadLwc\dailySalesNoUploadLwc.js
 */
import { LightningElement } from 'lwc';

export default class DailySalesNoUploadLwc extends LightningElement {

    back(){
        window.history.go(-1);
        const closeModal = new CustomEvent('refreshView');
        this.dispatchEvent(closeModal);
    }
}