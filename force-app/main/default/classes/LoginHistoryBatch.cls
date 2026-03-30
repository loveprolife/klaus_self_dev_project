/**************************************************************************************************
 * Name:LoginHistoryBatch
 * Purpose: 登录历史记录
 * Author: WFC
 * Create Date: 2021-02-24
 * 执行方法 Database.executeBatch(new LoginHistoryBatch(0),200);
***************************************************************************************************/
global class LoginHistoryBatch implements Database.Batchable<sObject> {
    public String query;
    public Integer type;
    public String year;
    public String month;
    public Datetime currentTime;
    public Datetime lastMonth;
    public String apiId = '0050o00000VK8f1AAD';

    global LoginHistoryBatch (Integer type, String year, String month) {
        if(type == 0){
            this.year = year;
            this.month = month;
            if (Integer.valueOf(this.month) < 10) {
                this.month = '0'+this.month;
            }
            this.currentTime = Datetime.valueOf(this.year + '-' + this.month + '-01 00:00:00');
            this.lastMonth = currentTime.addMonths(-1);
            this.query = 'SELECT id,LoginType,SourceIp,LoginTime,UserId,Application, Browser, CipherSuite, status, CountryIso, Platform,LoginUrl ' +
            'from LoginHistory where loginTime < YESTERDAY and loginTime <:currentTime and loginTime >=:lastMonth and UserId != :apiId';
        }else {
            this.query = 'SELECT id,LoginType,SourceIp,LoginTime,UserId,Application, Browser, CipherSuite, status, CountryIso, Platform,LoginUrl ' +
            'from LoginHistory where loginTime >= YESTERDAY and UserId != :apiId';
        }
        
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<LoginHistory> loginHistoryList) {
        List<Login_History__c> addList = new List<Login_History__c>();
        try{
            for(LoginHistory loginHistory : loginHistoryList){
                // LoginHistory loginHistory = (LoginHistory)so;
                Login_History__c lh = new Login_History__c();
                lh.UserId__c = loginHistory.UserId;
                lh.LoginId__c = loginHistory.id;
                lh.LoginTime__c = loginHistory.LoginTime;
                lh.LoginType__c = loginHistory.LoginType;
                lh.SourceIp__c = loginHistory.SourceIp;
                lh.Application__c = loginHistory.Application;
                lh.Browser__c = loginHistory.Browser;
                lh.CipherSuite__c = loginHistory.CipherSuite;
                lh.Status__c = loginHistory.Status;
                lh.CountryIso__c = loginHistory.CountryIso;
                lh.Platform__c = loginHistory.Platform;
                lh.LoginUrl__c = loginHistory.LoginUrl;
                addList.add(lh);
                
            }
           
            Database.insert(addList, false);
        }catch(Exception e){
            system.debug('www error message: '+e.getMessage());
            system.debug('www line number: '+e.getLineNumber());
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
  
}