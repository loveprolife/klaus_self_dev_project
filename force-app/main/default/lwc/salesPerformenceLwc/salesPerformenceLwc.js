import { LightningElementEx } from "c/lwcUtils";
import { loadScript } from 'lightning/platformResourceLoader';
import ECHARTS from "@salesforce/resourceUrl/echarts";
import getTargetAndCompletedAmount from "@salesforce/apex/PersonalTargetController.getTargetAndCompletedAmountCore";

import Sales_Target_Report_No_Datas_Error from '@salesforce/label/c.Sales_Target_Report_No_Datas_Error';
import Sales_Target_Report_Mothly_Complete from '@salesforce/label/c.Sales_Target_Report_Mothly_Complete';

export default class SalesPerformenceLwc extends LightningElementEx {

    lwcName = 'SalesPerformenceLwc';
    isShowSpinner;
    max;
    current;

    label = {
        Sales_Target_Report_No_Datas_Error,
        Sales_Target_Report_Mothly_Complete
    }
    get per() {
        return this.max ? (this.current * 100 / this.max).toFixed(0) + '%' : '';
    }
  initializeEcharts = false; //Variable to load check if echarts is initialize
  //renderedCallback Use it to perform logic after a component has finished the rendering phase
  renderedCallback() {
    if (this.initializeEcharts) {
      return;
    }

    this.isShowSpinner = true;
    this.initializeEcharts = true;
    getTargetAndCompletedAmount({
        "UserId":null,//"0059D000005Mg46QAC"
        "startDate":null,
        "endDate":null,
    }).then(result => {
        if (result.isSuccess) {
            this.max = result.data.targetAmount;
            this.current = result.data.completedAmount;
            this.isShowSpinner = false;
            if (this.max > 0) {
                //loadscript loads our echartjs which we add in our resource folder-
                //and return a promise when loaded, once the script is loaded we initialize our echart variable to true
                //and runEcharts function which will load our echarts to the frontend
                Promise.all([loadScript(this, ECHARTS)]).then(() => {
                    this.runEcharts();

                });
            }
            
        } else {
            
        }
    }).catch(error => {
        this.catchError(error);
    });
    
  }
  runEcharts() {
    var myChart = echarts.init(this.template.querySelector('div.main')); //to select the div to embed the chart

    // specify chart configuration item and data
    var option = {
    //   tooltip: {
    //       formatter: '{a} <br/>{b} : {c}%'
    //   },
      series: [
          {
              name: 'Pressure',
              type: 'gauge',
              progress: {
                  show: true
              },
              detail: {
                  valueAnimation: true,
                  formatter: '{value}'
              },
              max: this.max,
              data: [
                  {
                      value: this.current,
                      name: this.label.Sales_Target_Report_Mothly_Complete+'\n' + this.per
                  }
              ]
          }
      ]
  };


    // use configuration item and data specified to show chart
    myChart.setOption(option);
    window.addEventListener('resize', myChart.resize);
}
}