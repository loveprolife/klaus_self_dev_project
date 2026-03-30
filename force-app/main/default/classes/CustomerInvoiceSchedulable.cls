global class CustomerInvoiceSchedulable implements Schedulable {

   public List<String> companyCodeList = new List<String>();

   global CustomerInvoiceSchedulable(String companyCode){
         this.companyCodeList = companyCode.split(',');
   }

   global void execute(SchedulableContext SC) {

      // 所有的客户
      List<Account> accountList = [SELECT id,Active_Flag__c,ParentId from account where Hisense_Entity__c in: companyCodeList];
      // 所有客户的map集合
      Map<Id, Account> allMap = new Map<Id, Account>();
      // 客户更新的map集合
      Map<Id, Account> accountMap = new Map<Id, Account>();
      // Flag为T的客户
      Map<Id, Account> accountTMap = new Map<Id, Account>();
      // Flag为F的客户
      Map<Id, Account> accountFMap = new Map<Id, Account>();
      // 用作父级关联客户标记由false改为true的客户
      List<Account> accountPList = new List<Account>();
      // 用作父级的map
      Map<Id, List<Account>> accountPmap = new Map<Id, List<Account>>();

      for(Account a : accountList){
         allMap.put(a.Id, a);
         if (a.Active_Flag__c) {
            accountTMap.put(a.Id, a);
         }else {
            accountFMap.put(a.Id, a);
         }
         // a.Active_Flag__c = false;
         // accountMap.put(a.Id, a);
         if(a.ParentId != null){
            if (accountPmap.containsKey(a.ParentId)) {
               a.Active_Flag__c = true;
               accountPmap.get(a.ParentId).add(a);
            }else{
                  a.Active_Flag__c = true;
                  accountPmap.put(a.ParentId, new List<Account>{a});
            }
         }
      }

      // label配置N个月前数据
      Datetime n = Datetime.now();
      Datetime d = n.addMonths(Integer.valueOf(Label.Customer_Invoice_Date));
      // 查询发票invoice
      List<AggregateResult> invoiceList = [SELECT sum(Total_Amount_Inc_Tax__c) amount,Customer__c from Invoice__c 
                                       where Invoice_Date__c >= :d.date() and Customer__r.Hisense_Entity__c in: companyCodeList
                                       group by Customer__c];

      for(AggregateResult ar : invoiceList){
         // 客户
         Id cid = Id.valueOf(String.valueOf(ar.get('Customer__c')));
         // 金额
         Decimal amount = Double.valueOf(ar.get('amount'));

         Account tAccount = accountTMap.get(cid);
         Account fAccount = accountFMap.get(cid);
         // 如果满足条件则更改account的值
         if(amount >= Double.valueOf(Label.Customer_Invoice_Amount)){
            // Account udAccount = accountMap.get(cid);
            // udAccount.Active_Flag__c = true;
            // accountMap.put(cid, udAccount);
            if(tAccount != null){
               accountTMap.remove(cid);
               accountPList.add(tAccount);
            }else if(fAccount != null){
               fAccount.Active_Flag__c = true;
               accountMap.put(cid, fAccount);
               accountPList.add(fAccount);
            }
            
         }else {
            if(tAccount != null){
               tAccount.Active_Flag__c = false;
               accountMap.put(cid, tAccount);
               accountTMap.remove(cid);
            }
         }

      }

      // 更新客户表
      List<Account> upList = accountMap.values();
      // invoice没有的客户
      List<Account> tList = accountTMap.values();
      for(Account t : tList){
         t.Active_Flag__c = false;
         upList.add(t);
      }
      Database.update(uplist, false);

      List<Account> upPAccount = new List<Account>();
      // 遍历父级list查询所有子客户
      for(Account p : accountPList){
         // 如果list为父级客户
         if(accountPmap.containsKey(p.id)){
            upPAccount.addAll(accountPmap.get(p.id));
            // 将父级客户也赋值为true
            Account pAccount = allMap.get(p.Id);
            pAccount.Active_Flag__c = true;
            upPAccount.add(pAccount);
         }else if(accountPmap.containsKey(p.ParentId)){
            upPAccount.addAll(accountPmap.get(p.ParentId));
            // 将父级客户也赋值为true
            Account pAccount = allMap.get(p.ParentId);
            pAccount.Active_Flag__c = true;
            upPAccount.add(pAccount);
         }
      }
      Database.update(upPAccount, false);

      //日志内容
      InterfaceLog__c ic = new InterfaceLog__c();
      ic.Class__c = 'CustomerInvoiceSchedulable';
      ic.Time__c = System.Now();
      ic.ReturnCode__c = '1';
      ic.Req_Json__c = companyCodeList.toString();
      insert ic;
   
   }

}