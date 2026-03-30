/*
 * @Author: WFC
 * @Date: 2024-03-06 15:07:22
 * @LastEditors: WFC
 * @LastEditTime: 2024-03-06 17:38:26
 * @Description: 
 * @FilePath: \hisenseall-231026\force-app\main\default\lwc\customDataTypes\customDataTypes.js
 */
import LightningDatatable from 'lightning/datatable';
import customText from './customText.html';
export default class CustomDataTypes extends LightningDatatable {
    static customTypes = {
        customTextType: {
            template: customText,
            standardCellLayout: true,
            typeAttributes: ['comments']
        }
        // Other Custom Types
    };
}