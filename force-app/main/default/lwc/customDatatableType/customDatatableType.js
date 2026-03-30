/*
 * @Author: WFC
 * @Date: 2025-05-20 11:07:23
 * @LastEditors: WFC
 * @LastEditTime: 2025-05-20 11:07:34
 * @Description: 
 * @FilePath: \HiTest20250422\force-app\main\default\lwc\customDatatableType\customDatatableType.js
 */
import LightningDatatable from 'lightning/datatable';
import picklistColumn from './picklistColumn.html';
import pickliststatic from './pickliststatic.html'


export default class CustomDatatableType extends LightningDatatable {
    static customTypes = {
        picklistColumn: {
            template: pickliststatic,
            editTemplate: picklistColumn,
            standardCellLayout: true,
            typeAttributes: [
                'label',
                'placeholder',
                'options',
                'value',
                'context',
                'variant',
                'name'
            ]
        }
    };
}