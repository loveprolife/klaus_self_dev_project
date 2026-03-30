@IsTest
private class Batch_CustomerAddressUploadTest{

    @IsTest
    static void test(){
        Account a = new Account(
            Name = 'Test Acc',
            SAP_Customer_Code__c = 'test111'
        );
        insert a;

        Country_State__c countryState = new Country_State__c(
            Name__c = 'Test State',
            Belong_To__c = 'CN'
        );
        Insert countryState;

        TaxCountryMapping__c tcm1 = new TaxCountryMapping__c();
        tcm1.name = '8120';
        tcm1.Country__c = 'US';
        insert tcm1;

        List<Account> accounts = new List<Account>();
        Account target = new Account();
        target.SAP_Customer_Code__c = 'test111';
        target.Name = 'test123';
        target.Customer_Name_Local_Language__c = 'test123';
        target.Customer_Short_Name__c = 'test123';
        target.CurrencyIsoCode = 'AUD';
        target.Guarantor_Country_Code__c = 'CA';
        target.Province_State__c = countryState.Id;
        target.Street_2__c = '123';
        target.Hisense_Entity__c = '8120';
        target.Hisense_Entity_Sales__c = '8120';
        target.Shipping_Conditions__c = '02';
        accounts.add(target);

        Batch_CustomerAddressUpload ss = new Batch_CustomerAddressUpload(accounts);
        Database.executeBatch(ss, 1);
    }

}