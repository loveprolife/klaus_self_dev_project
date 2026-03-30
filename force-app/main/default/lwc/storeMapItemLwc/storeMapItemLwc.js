import { LightningElement, api ,track} from 'lwc';
import {LightningNavigationElement} from 'c/lwcUtils'
import INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION from '@salesforce/label/c.INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION';
import STORE_MAP_SEARCH_PLACEHOLDER from '@salesforce/label/c.STORE_MAP_SEARCH_PLACEHOLDER';
import STORE_MAP_SEARCH_NO_RECORD_MSG from '@salesforce/label/c.STORE_MAP_SEARCH_NO_RECORD_MSG';
import STORE_MAP_SEARCH_RESULTS from '@salesforce/label/c.STORE_MAP_SEARCH_RESULTS';
import STORE_MAP_INSPECTION_REPORT_COUNT from '@salesforce/label/c.STORE_MAP_INSPECTION_REPORT_COUNT';
import STORE_MAP_SELL_OUT from '@salesforce/label/c.STORE_MAP_SELL_OUT';
import STORE_MAP_NO_STORE from '@salesforce/label/c.STORE_MAP_NO_STORE';

import STORE_MAP_STORE_LIST from '@salesforce/label/c.STORE_MAP_STORE_LIST';
import STORE_MAP_PROMOTER from '@salesforce/label/c.STORE_MAP_PROMOTER';
import STORE_MAP_MARKET from '@salesforce/label/c.STORE_MAP_MARKET';
import STORE_MAP_MONTH from '@salesforce/label/c.STORE_MAP_MONTH';
import STORE_MAP_FLOORWALKER from '@salesforce/label/c.STORE_MAP_FLOORWALKER';
import STORE_MAP_STORE from '@salesforce/label/c.STORE_MAP_STORE';
import Store_Map_Distance from '@salesforce/label/c.Store_Map_Distance';
import Store_Map_Goto_Report from '@salesforce/label/c.Store_Map_Goto_Report';
import Store_Map_Detail from '@salesforce/label/c.Store_Map_Detail';
import Store_Map_Review from '@salesforce/label/c.Store_Map_Review';


export default class StoreMapItemLwc extends LightningNavigationElement {

    label = {
        INSPECTION_REPORT_MSG_DONOT_SUPPORT_LOCATION,   // 当前设备不支持定位功能
        STORE_MAP_SEARCH_PLACEHOLDER,                   // 请输入网格渠道或门店名
        STORE_MAP_SEARCH_NO_RECORD_MSG,                 // 未找到数据
        STORE_MAP_SEARCH_RESULTS,                       // 搜索结果来自于{0}
        STORE_MAP_INSPECTION_REPORT_COUNT,              // 巡店日报总数
        STORE_MAP_SELL_OUT,                             // 销售总额
        STORE_MAP_NO_STORE,                             // 当前位置附近没有门店

        STORE_MAP_STORE_LIST,                           // 门店列表
        STORE_MAP_PROMOTER,                             // 促销员日报
        STORE_MAP_MARKET,                               // 促销员周报
        STORE_MAP_MONTH,                                // 促销员月报
        STORE_MAP_FLOORWALKER,                          // 巡店员报告
        STORE_MAP_STORE,                                // 门店
        Store_Map_Distance,
        Store_Map_Goto_Report,
        Store_Map_Detail,
        Store_Map_Review
    }
    
    @api info;
    @api storeInfoDatas;
    @api objectAccessible;

     // 新增逻辑根据门店的salesregion跳转对应的三期四期巡店页面 20241121 YYL
    @track salesRegionFilter = ['Hisense USA','Hisense Canada','Hisense Peru'];


    // 是否存在巡店日报
    get reportIsNull() {
        console.log('CCCC' + JSON.stringify(this.info));
        console.log('value' + JSON.stringify(this.info.value.inspectionReportCount));
        console.log('IdDetail' + JSON.stringify(this.info.value.inspectionReportId));
        if (this.info.value.inspectionReportCount>0) {
            return true;
        } else {
            return false;
        }
    }

    goToStore(event) {
        event.stopPropagation();
        let store = this.storeInfoDatas[event.currentTarget.dataset.index];
        if (store) {
            this.goToRecord(store.Id);
        }
    }

    goToPromoterReport(event) {
        event.stopPropagation();
        let store = this.storeInfoDatas[event.currentTarget.dataset.index];
        if (store) {
            this.goToLwc('newPromoterDailyReportLwc', {
                'shopId' : store.Id
            });
        }
    }

    goToFloorwalkerReport(event) {
        event.stopPropagation();
        let store = this.storeInfoDatas[event.currentTarget.dataset.index];

        if (store) {
            // 新增逻辑根据门店的salesregion跳转对应的三期四期巡店页面 20241121 YYL
            var salesRegion = store.object.Sales_Region__c;
            var label = 'newInspectorDailyReportLwc';
            if(salesRegion){
                if(this.salesRegionFilter.indexOf(salesRegion) !== -1){
                    label = 'newInspectorReportHomePageLwc';                   
                }
            }

            this.goToLwc(label, {
                'storeId' : store.Id
            });
        }

    }

    goToFloorwalkerReportDetail(event) {
        event.stopPropagation();
        let store = this.storeInfoDatas[event.currentTarget.dataset.index];
        //获取 Report 的 Id
        let reportId = this.info.value.inspectionReportId;
        if (store && reportId) {
            // this.goToLwc('newInspectorDailyReportLwc', {
            //     'storeId' : store.Id
            // });
            // Daily_Inspection_Report__c
            this.goToRecordBySkip(reportId);
        }

    }

    goToDailySales(event) {
        event.stopPropagation();
        let store = this.storeInfoDatas[event.currentTarget.dataset.index];
        if (store) {
            this.goToRelatedList('Shop__c', store.Id, 'Shop_Retail_Number__r');
        }
    }

    goToInspectionReport(event) {
        event.stopPropagation();
        let store = this.storeInfoDatas[event.currentTarget.dataset.index];
        if (store) {
            this.goToRelatedList('Shop__c', store.Id, 'DailyInspectionReports__r');
        }
    }
}