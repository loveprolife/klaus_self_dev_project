/*
 * @Author: WFC
 * @Date: 2024-11-22 14:28:35
 * @LastEditors: WFC
 * @LastEditTime: 2024-12-04 14:46:37
 * @Description: powerbi正式
 * @FilePath: \hisense005\force-app\main\default\lwc\powerBiReport\powerBiReport.js
 */
import { LightningElement, api, wire } from 'lwc';
import getEmbeddingDataForReport from '@salesforce/apex/PowerBiEmbedManager.getEmbeddingDataForReport';
import powerbijs from '@salesforce/resourceUrl/powerbijs';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';


export default class PowerBiReport extends LightningElement {
    @api WorkspaceId = '';
    @api ReportId =' ';
    // @api Height;

    _height = '480px';

    @api
    set Height(value) {
       this._height = value + 'px';
    }
    get Height() {
        return this._height;
    }
    
      
    @wire(getEmbeddingDataForReport,{
      WorkspaceId: "$WorkspaceId",
      ReportId: "$ReportId"
    }) report;
  
      renderedCallback() {
         console.log('renderedCallback exectuting');
         console.log('wwwww---' + this.Height);
          Promise.all([ loadScript(this, powerbijs ) ]).then(() => { 
  
            console.log('renderedCallback 2');
            console.log("this.report", this.report);
  
              if(this.report.data){
  
                if(this.report.data.embedUrl && this.report.data.embedToken){
                  var reportContainer = this.template.querySelector('[data-id="embed-container"');
                  reportContainer.style.height = this.Height;
  
                  var reportId = this.report.data.reportId;
                  var embedUrl = this.report.data.embedUrl;
                  var token = this.report.data.embedToken;
                
                  var config = {
                    type: 'report',
                    id: reportId,
                    embedUrl: embedUrl,
                    accessToken: token,
                    tokenType: 1,
                    settings: {
                      filterPaneEnabled: true,
                      navContentPaneEnabled: true,
                      // panes: {
                      //   filters: { expanded: false, visible: true },
                      //   pageNavigation: { visible: false }
                      // }
                    }
                  };
                
                  // Embed the report and display it within the div container.
                  var report = powerbi.embed(reportContainer, config);
  
                  console.log(powerbi);
  
                }
                else {
                  console.log('no embedUrl or embedToken');
                }
                  
                }
                else{
                    console.log('no report.data yet');
                }
         
  
          });
  
      }
    
}