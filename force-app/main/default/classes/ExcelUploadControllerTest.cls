@isTest
public class ExcelUploadControllerTest{
    @isTest
    public static void testExcelUploadController(){

        Channel_item__c channelItem  = new Channel_item__c();
        channelItem.Channel_Name__c = 'Game';
        channelItem.SBU__c = 'Hisense South Africa';
        insert channelItem;

        Shop__c shop1 = new Shop__c();
        shop1.Channel_Item__c = channelItem.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';    
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        shop1.Sales_Region__c = 'Hisense South Africa';
        Insert shop1;

        Promoter_Attendance_Rule__c par = new Promoter_Attendance_Rule__c();
        par.Start_time__c = Time.newInstance(9,0,0,0);
        par.End_time__c = Time.newInstance(18,0,0,0);
        par.Time_buffer__c = 15;
        insert par;

        //Responsible_Person__c
        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = UserInfo.getUserId();
        rp.Shop_Name__c = shop1.Id;
        rp.RecordType__c = '促销员';
        rp.Promoter_Attendance_Rule__c = par.Id;
        insert rp;

        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.Name = '32A40G';
        insert pro;

        List<String[]> fileLines = new List<String[]>();
        String[] line1 = new String[0];
        line1.add('Hisense South Africa');
        line1.add('Game');
        line1.add('WK3');
        line1.add('TV');
        line1.add('32A40G');
        line1.add('19999');
        line1.add('12');
        fileLines.add(line1);
        String[] line11 = new String[0];
        line11.add('Hisense South Africa');
        line11.add('Game');
        line11.add('WK3');
        line11.add('TV');
        line11.add('32A40G');
        line11.add('19999');
        line11.add('12');
        fileLines.add(line11);

        Test.startTest();

        ExcelUploadController.saveWeeklySalesTarget('test.xls', fileLines);

        Test.stopTest();
    }

    @isTest
    public static void testExcelUploadController2(){
        Channel_item__c channelItem  = new Channel_item__c();
        channelItem.Channel_Name__c = 'Game';
        channelItem.SBU__c = 'Hisense South Africa';
        insert channelItem;

        Shop__c shop1 = new Shop__c();
        shop1.Channel_Item__c = channelItem.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';    
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        shop1.Sales_Region__c = 'Hisense South Africa';
        Insert shop1;

        Promoter_Attendance_Rule__c par = new Promoter_Attendance_Rule__c();
        par.Start_time__c = Time.newInstance(9,0,0,0);
        par.End_time__c = Time.newInstance(18,0,0,0);
        par.Time_buffer__c = 15;
        insert par;

        //Responsible_Person__c
        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = UserInfo.getUserId();
        rp.Shop_Name__c = shop1.Id;
        rp.RecordType__c = '促销员';
        rp.Promoter_Attendance_Rule__c = par.Id;
        insert rp;

        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.Name = '32A40G';
        insert pro;

        List<String[]> fileLines = new List<String[]>();
        String[] line1 = new String[0];
        line1.add('Hisense South Africa');
        line1.add('Game');
        line1.add('WK3');
        line1.add('TV');
        line1.add('32A40G');
        line1.add('19999');
        line1.add('12');
        fileLines.add(line1);
        String[] line11 = new String[0];
        line11.add('Hisense South Africa');
        line11.add('Game');
        line11.add('WK3');
        line11.add('TV');
        line11.add('32A40G');
        line11.add('19999');
        line11.add('12');
        line11.add('Example');
        fileLines.add(line11);

        Test.startTest();

        ExcelUploadController.saveWeeklySalesTarget('test.xls', fileLines);

        Test.stopTest();
    }

    @isTest
    public static void testExcelUploadController3(){

        Channel_item__c channelItem  = new Channel_item__c();
        channelItem.Channel_Name__c = 'Game';
        channelItem.SBU__c = 'Hisense South Africa';
        insert channelItem;

        Shop__c shop1 = new Shop__c();
        shop1.Channel_Item__c = channelItem.Id;
        shop1.Shop_Level__c = 'A';
        shop1.Name = '可乐店';
        shop1.City__c = '北京市';    
        shop1.Shop_Center_Location__Latitude__s = 29.4545;
        shop1.Shop_Center_Location__Longitude__s = 106.509;
        shop1.Sales_Region__c = 'Hisense South Africa';
        Insert shop1;

        Promoter_Attendance_Rule__c par = new Promoter_Attendance_Rule__c();
        par.Start_time__c = Time.newInstance(9,0,0,0);
        par.End_time__c = Time.newInstance(18,0,0,0);
        par.Time_buffer__c = 15;
        insert par;

        //Responsible_Person__c
        Responsible_Person__c rp = new Responsible_Person__c();
        rp.Principal__c = UserInfo.getUserId();
        rp.Shop_Name__c = shop1.Id;
        rp.RecordType__c = '促销员';
        rp.Promoter_Attendance_Rule__c = par.Id;
        insert rp;

        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.Name = '32A40G';
        insert pro;

        List<String[]> fileLines = new List<String[]>();
        String[] line1 = new String[0];
        line1.add('Hisense South Africa');
        line1.add('Game');
        line1.add('WK3');
        line1.add('TV');
        line1.add('32A40G');
        line1.add('19999');
        line1.add('12');
        fileLines.add(line1);
        String[] line11 = new String[0];
        line11.add('');
        line11.add('');
        line11.add('');
        line11.add('');
        line11.add('');
        line11.add('AAA');
        line11.add('');
        fileLines.add(line11);

        Test.startTest();

        ExcelUploadController.saveWeeklySalesTarget('test.xls', fileLines);

        Test.stopTest();
    }

    @isTest
    public static void testExcelUploadController4(){

        List<String[]> fileLines = new List<String[]>();
        String[] line1 = new String[0];
        line1.add('类型recordtypeid');
        line1.add('类型recordtypecode');
        line1.add('年份Year_c');
        line1.add('月份month_c');
        line1.add('销售地区Sales Region');
        line1.add('金额amounts__c');
        line1.add('货币ISO代码currencyisocode');
        line1.add('品牌Brand');
        line1.add('产品线Product Line');
        line1.add('门店覆盖率Store Coverage Rate');
        line1.add('number');
        String[] line2 = new String[0];
        line2.add('Sellout金额');
        line2.add('1');
        line2.add('2025');
        line2.add('2');
        line2.add('Hisense Thailand');
        line2.add('900000000');
        line2.add('CNY');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        String[] line3 = new String[0];
        line3.add('店效');
        line3.add('2');
        line3.add('2025');
        line3.add('2');
        line3.add('Hisense Thailand');
        line3.add('900000000');
        line3.add('CNY');
        line3.add('');
        line3.add('');
        line3.add('');
        line3.add('');
        String[] line4 = new String[0];
        line4.add('Sellout金额');
        line4.add('3');
        line4.add('2025');
        line4.add('2');
        line4.add('Hisense Thailand');
        line4.add('900000000');
        line4.add('CNY');
        line4.add('');
        line4.add('');
        line4.add('');
        line4.add('');
        String[] line5 = new String[0];
        line5.add('Sellout金额');
        line5.add('4');
        line5.add('2025');
        line5.add('2');
        line5.add('Hisense Thailand');
        line5.add('900000000');
        line5.add('CNY');
        line5.add('HISENSE');
        line5.add('TV');
        line5.add('');
        line5.add('10');
        String[] line6 = new String[0];
        line6.add('Sellout金额');
        line6.add('5');
        line6.add('2025');
        line6.add('2');
        line6.add('Hisense Thailand');
        line6.add('900000000');
        line6.add('CNY');
        line6.add('HISENSE');
        line6.add('TV');
        line6.add('');
        line6.add('');
        String[] line7 = new String[0];
        line7.add('Sellout金额');
        line7.add('6');
        line7.add('2025');
        line7.add('2');
        line7.add('Hisense Thailand');
        line7.add('900000000');
        line7.add('CNY');
        line7.add('HISENSE');
        line7.add('TV');
        line7.add('');
        line7.add('');
        String[] line8 = new String[0];
        line8.add('Sellout金额');
        line8.add('7');
        line8.add('2025');
        line8.add('2');
        line8.add('Hisense Thailand');
        line8.add('');
        line8.add('');
        line8.add('');
        line8.add('');
        line8.add('70%');
        line8.add('');
        fileLines.add(line1);
        fileLines.add(line2);
        fileLines.add(line3);
        fileLines.add(line4);
        fileLines.add(line5);
        fileLines.add(line6);
        fileLines.add(line7);
        fileLines.add(line8);

        Test.startTest();

        ExcelUploadController.saveTargetOther('test.xls', fileLines);

        Test.stopTest();
    }

    @isTest
    public static void testExcelUploadController5(){

        List<String[]> fileLines = new List<String[]>();
        String[] line1 = new String[0];
        line1.add('类型recordtypeid');
        line1.add('类型recordtypecode');
        line1.add('年份Year_c');
        line1.add('月份month_c');
        line1.add('销售地区Sales Region');
        line1.add('金额amounts__c');
        line1.add('货币ISO代码currencyisocode');
        line1.add('品牌Brand');
        line1.add('产品线Product Line');
        line1.add('门店覆盖率Store Coverage Rate');
        line1.add('数量');
        String[] line2 = new String[0];
        line2.add('Sellout金额');
        line2.add('5');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        String[] line3 = new String[0];
        line3.add('Sellout金额');
        line3.add('4');
        line3.add('');
        line3.add('');
        line3.add('');
        line3.add('');
        line3.add('');
        line3.add('');
        line3.add('');
        line3.add('');
        line3.add('');
        String[] line4 = new String[0];
        line4.add('Sellout金额');
        line4.add('');
        line4.add('');
        line4.add('');
        line4.add('');
        line4.add('');
        line4.add('');
        line4.add('');
        line4.add('');
        line4.add('');
        line4.add('');
        fileLines.add(line1);
        fileLines.add(line2);
        fileLines.add(line3);
        fileLines.add(line4);

        Test.startTest();

        ExcelUploadController.saveTargetOther('test.xls', fileLines);

        Test.stopTest();
    }

    @isTest
    public static void testExcelUploadController6(){

        List<String[]> fileLines = new List<String[]>();

        String[] line1 = new String[0];
        line1.add('销售地区Sales Region');
        line1.add('品牌Brand');
        line1.add('品线Product line');
        line1.add('year');
        line1.add('month');
        line1.add('门店数Store number');
        line1.add('总促销员数量Promoter number');
        line1.add('S数量 S Promoter number');
        line1.add('A数量 A Promoter number');
        line1.add('B数量 B Promoter number');
        line1.add('C数量 C Promoter number');
        String[] line2 = new String[0];
        line2.add('Hisense Thailand');
        line2.add('HISENSE');
        line2.add('TV');
        line2.add('2025');
        line2.add('4');
        line2.add('4');
        line2.add('4');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');

        fileLines.add(line1);
        fileLines.add(line2);

        Test.startTest();

        ExcelUploadController.saveActualAchievement('test.xls', fileLines, 'Store');
        ExcelUploadController.saveActualAchievement('test.xls', fileLines, 'Customer');

        Test.stopTest();
    }

    @isTest
    public static void testExcelUploadController7(){

        List<String[]> fileLines = new List<String[]>();

        String[] line1 = new String[0];
        line1.add('销售地区Sales Region');
        line1.add('品牌Brand');
        line1.add('品线Product line');
        line1.add('year');
        line1.add('month');
        line1.add('门店数Store number');
        line1.add('总促销员数量Promoter number');
        line1.add('S数量 S Promoter number');
        line1.add('A数量 A Promoter number');
        line1.add('B数量 B Promoter number');
        line1.add('C数量 C Promoter number');
        String[] line2 = new String[0];
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');

        fileLines.add(line1);
        fileLines.add(line2);

        Test.startTest();

        ExcelUploadController.saveActualAchievement('test.xls', fileLines, 'Store');
        ExcelUploadController.saveActualAchievement('test.xls', fileLines, 'Customer');

        Test.stopTest();
    }

    @isTest
    public static void testExcelUploadController8(){
        String productType = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.Name = '32A40G';
        pro.RecordTypeId = productType;
        pro.sales_region__c = 'Hisense USA';
        insert pro;

        Channel_item__c channelItem = new Channel_item__c();
        channelItem.Channel_Name__c = '海信';
        channelItem.SBU__c = 'Hisense USA';
        insert channelItem;


        List<String[]> fileLines = new List<String[]>();

        String[] line1 = new String[0];
        line1.add('销售地区Sales Region');
        line1.add('渠道Channel（必填）');
        line1.add('产品Product（必填）');
        line1.add('价格Price（必填）');
        line1.add('货币Currency');
        String[] line2 = new String[0];
        line2.add('Hisense USA');
        line2.add('海信');
        line2.add('32A40G');
        line2.add('30');
        line2.add('USD');

        fileLines.add(line1);
        fileLines.add(line2);

        Test.startTest();

        ExcelUploadController.saveChannelProductPrice('test.xls', fileLines);

        Test.stopTest();
    }

    @isTest
    public static void testExcelUploadController9(){
        String productType = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.Name = '32A40G';
        pro.RecordTypeId = productType;
        pro.sales_region__c = 'Hisense USA';
        insert pro;

        Channel_item__c channelItem = new Channel_item__c();
        channelItem.Channel_Name__c = '海信';
        channelItem.SBU__c = 'Hisense USA';
        insert channelItem;


        List<String[]> fileLines = new List<String[]>();

        String[] line1 = new String[0];
        line1.add('销售地区Sales Region');
        line1.add('渠道Channel（必填）');
        line1.add('产品Product（必填）');
        line1.add('价格Price（必填）');
        line1.add('货币Currency');
        String[] line2 = new String[0];
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');

        fileLines.add(line1);
        fileLines.add(line2);

        Test.startTest();

        ExcelUploadController.saveChannelProductPrice('test.xls', fileLines);

        Test.stopTest();
    }

    @isTest
    public static void testExcelUploadController10(){
        String productType = Schema.SobjectType.Product__c.getRecordTypeInfosByDeveloperName().get('RegionalProduct').getRecordTypeId();
        Product__c pro = new Product__c();
        pro.Level__c = 'A';
        pro.Name = '32A40G';
        pro.RecordTypeId = productType;
        pro.sales_region__c = 'Hisense USA';
        insert pro;

        List<String[]> fileLines = new List<String[]>();

        String[] line1 = new String[0];
        line1.add('销售地区Sales Region');
        line1.add('产品Product（必填）');
        line1.add('date（必填）');
        String[] line2 = new String[0];
        line2.add('');
        line2.add('');
        line2.add('');

        fileLines.add(line1);
        fileLines.add(line2);

        List<String[]> fileLines1 = new List<String[]>();

        String[] line4 = new String[0];
        line4.add('vdfvdf');
        line4.add('vdvd');
        line4.add('vdfvdf');

        fileLines1.add(line1);
        fileLines1.add(line4);

        List<String[]> fileLines2 = new List<String[]>();

        String[] line6 = new String[0];
        line6.add('Hisense USA');
        line6.add('32A40G');
        line6.add('2025-08');

        fileLines1.add(line1);
        fileLines1.add(line6);

        Test.startTest();

        ExcelUploadController.saveKeyModel('test.xls', fileLines);
        ExcelUploadController.saveKeyModel('test.xls', fileLines1);
        ExcelUploadController.saveKeyModel('test.xls', fileLines2);

        Test.stopTest();
    }

    @isTest
    public static void testExcelUploadController11(){
        Country_State__c countryState = new Country_State__c(
            Name__c = 'Test State',
            Belong_To__c = 'CN',
            ex_id__c = '10CA'
        );
        Insert countryState;

        List<String[]> fileLines = new List<String[]>();

        String[] line1 = new String[0];
        line1.add('销售地区Sales Region');
        line1.add('产品Product（必填）');
        line1.add('date（必填）');
        line1.add('销售地区Sales Region');
        line1.add('产品Product（必填）');
        line1.add('date（必填）');
        line1.add('销售地区Sales Region');
        line1.add('产品Product（必填）');
        line1.add('date（必填）');
        line1.add('销售地区Sales Region');
        line1.add('产品Product（必填）');
        line1.add('date（必填）');
        line1.add('产品Product（必填）');
        line1.add('date（必填）');
        line1.add('date（必填）');
        String[] line2 = new String[0];
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');
        line2.add('');

        fileLines.add(line1);
        fileLines.add(line1);
        fileLines.add(line1);
        fileLines.add(line1);
        fileLines.add(line2);

        List<String[]> fileLines1 = new List<String[]>();

        String[] line4 = new String[0];
        line4.add('test');
        line4.add('vdtestvd');
        line4.add('vdfvdf');
        line4.add('vdfvdf');
        line4.add('CA');
        line4.add('10');
        line4.add('vdfvdf');
        line4.add('vdvd');
        line4.add('vdfvdf');
        line4.add('vdfvdf');
        line4.add('vdvd');
        line4.add('vdfvdf');
        line4.add('vdfvdf');
        line4.add('vdfvdf');
        line4.add('vdfvdf');

        fileLines1.add(line1);
        fileLines1.add(line1);
        fileLines1.add(line1);
        fileLines1.add(line1);
        fileLines1.add(line4);

        Test.startTest();

        ExcelUploadController.saveCustomerAddress('test.xls', fileLines);
        ExcelUploadController.saveCustomerAddress('test.xls', fileLines1);

        Test.stopTest();
    }

//     {
// 	"IV_INPUT": {
// 		"USMD_CREQ_TEXT": "",
// 		"TEST": "",
// 		"SENDER": "S0218",
// 		"PMODE": "M",
// 		"PCOMPANY": "810",
// 		"INSTID": "0010o00002P6yPzAAJ20251209092931",
// 		"DATA": {
// 			"ZZZJLX_X": true,
// 			"ZZZJLX": "Z25",
// 			"ZZVAT_X": true,
// 			"ZZVAT": "107-86-14075",
// 			"ZZRENO_X": true,
// 			"ZZRENO": "107-86-14075",
// 			"ZZREFD_X": true,
// 			"ZZREFD": null,
// 			"ZZPDFD_X": true,
// 			"ZZPDFD": null,
// 			"ZZMXLX": "10",
// 			"ZZLINE_X": true,
// 			"ZZLINE": "30",
// 			"ZZLERE_X": true,
// 			"ZZLERE": "",
// 			"ZZINSUB_X": null,
// 			"ZZINSUB": null,
// 			"ZZINCAT_X": null,
// 			"ZZINCAT": null,
// 			"ZZIFCM_X": true,
// 			"ZZIFCM": false,
// 			"ZZHWKHFJ_X": true,
// 			"ZZHWKHFJ": "",
// 			"ZZFONM_X": true,
// 			"ZZFONM": "",
// 			"ZZFHYY_X": true,
// 			"ZZFHYY": "",
// 			"ZZFHLX_X": true,
// 			"ZZFHLX": "",
// 			"ZZEMCN_X": true,
// 			"ZZEMCN": null,
// 			"ZZDUNS_X": true,
// 			"ZZDUNS": "",
// 			"ZZCVCO_X": true,
// 			"ZZCVCO": "",
// 			"ZZCUSTA_X": true,
// 			"ZZCUSTA": "",
// 			"ZZCUSRITY_X": true,
// 			"ZZCUSRITY": "",
// 			"ZZCUSRISL_X": true,
// 			"ZZCUSRISL": "",
// 			"ZZCUSGR_X": true,
// 			"ZZCUSGR": "",
// 			"ZZCRERAT_X": true,
// 			"ZZCRERAT": "",
// 			"ZZCMCO_X": true,
// 			"ZZCMCO": "",
// 			"ZZCMAT_X": true,
// 			"ZZCMAT": "",
// 			"ZZCHMACLA_X": true,
// 			"ZZCHMACLA": "10",
// 			"ZZCHCUSSU_X": true,
// 			"ZZCHCUSSU": "101",
// 			"ZZCHCUSCA_X": true,
// 			"ZZCHCUSCA": "10",
// 			"ZZBNAR_X": true,
// 			"ZZBNAR": "Consumer Electronics",
// 			"ZZBLED_X": null,
// 			"ZZBLED": null,
// 			"ZZANRE_X": true,
// 			"ZZANRE": "",
// 			"ZTAX_JUR_X": true,
// 			"ZTAX_JUR": "",
// 			"ZTAX_CODE4_X": true,
// 			"ZTAX_CODE4": "",
// 			"ZTAX_CODE3_X": true,
// 			"ZTAX_CODE3": "",
// 			"ZTAX_CODE2_X": true,
// 			"ZTAX_CODE2": "",
// 			"ZTAX_CODE1_X": true,
// 			"ZTAX_CODE1": "",
// 			"ZSORT2_X": true,
// 			"ZSORT2": "",
// 			"ZLIFNR_X": true,
// 			"ZLIFNR": "0000421855",
// 			"ZKATR3_X": true,
// 			"ZKATR3": "",
// 			"ZKATR2_X": true,
// 			"ZKATR2": "",
// 			"URI_ADDR_X": true,
// 			"URI_ADDR": "",
// 			"TEL_NUMBER_X": true,
// 			"TEL_NUMBER": "",
// 			"SMTP_ADDR_X": true,
// 			"SMTP_ADDR": "",
// 			"SALES": [
// 				{
// 					"ZTERM_X": true,
// 					"ZTERM": "OA30",
// 					"ZKVGR5_X": true,
// 					"ZKVGR5": "",
// 					"ZKVGR4_X": true,
// 					"ZKVGR4": "",
// 					"ZKVGR3_X": true,
// 					"ZKVGR3": "",
// 					"ZKVGR1_X": true,
// 					"ZKVGR1": "",
// 					"WAERS_X": true,
// 					"WAERS": "USD",
// 					"VWERK_X": true,
// 					"VWERK": "",
// 					"VTWEG": "11",
// 					"VSBED_X": true,
// 					"VSBED": "01",
// 					"VKORG": "8010",
// 					"VKGRP_X": true,
// 					"VKGRP": "",
// 					"VKBUR_X": true,
// 					"VKBUR": "",
// 					"TAXCODN": [
// 						{
// 							"TAXKD_X": true,
// 							"TAXKD": "0",
// 							"TATYP": "MWST",
// 							"ALAND": "CN"
// 						}
// 					],
// 					"SPART": "00",
// 					"PYKUR_X": true,
// 					"PYKUR": "0020132000",
// 					"PODKZ_X": true,
// 					"PODKZ": false,
// 					"PLTYP_X": true,
// 					"PLTYP": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVGR2_X": true,
// 					"KVGR2": "",
// 					"KTGRD_X": true,
// 					"KTGRD": "Z1",
// 					"KONDA_X": true,
// 					"KONDA": "",
// 					"KDGRP_X": true,
// 					"KDGRP": "",
// 					"KALKS_X": true,
// 					"KALKS": "X",
// 					"INCO3_L_X": null,
// 					"INCO3_L": null,
// 					"INCO2_L_X": true,
// 					"INCO2_L": "",
// 					"INCO1_X": true,
// 					"INCO1": "",
// 					"EIKTO_X": true,
// 					"EIKTO": "",
// 					"BZIRK_X": null,
// 					"BZIRK": null,
// 					"BPKUR_X": true,
// 					"BPKUR": "0020132000",
// 					"AUFSD_X": true,
// 					"AUFSD": ""
// 				},
// 				{
// 					"ZTERM_X": true,
// 					"ZTERM": "OA30",
// 					"ZKVGR5_X": true,
// 					"ZKVGR5": "",
// 					"ZKVGR4_X": true,
// 					"ZKVGR4": "",
// 					"ZKVGR3_X": true,
// 					"ZKVGR3": "",
// 					"ZKVGR1_X": true,
// 					"ZKVGR1": "",
// 					"WAERS_X": true,
// 					"WAERS": "USD",
// 					"VWERK_X": true,
// 					"VWERK": "",
// 					"VTWEG": "11",
// 					"VSBED_X": true,
// 					"VSBED": "01",
// 					"VKORG": "8040",
// 					"VKGRP_X": true,
// 					"VKGRP": "",
// 					"VKBUR_X": true,
// 					"VKBUR": "",
// 					"TAXCODN": [
// 						{
// 							"TAXKD_X": true,
// 							"TAXKD": "0",
// 							"TATYP": "MWST",
// 							"ALAND": "HK"
// 						}
// 					],
// 					"SPART": "00",
// 					"PYKUR_X": true,
// 					"PYKUR": "0020132000",
// 					"PODKZ_X": true,
// 					"PODKZ": false,
// 					"PLTYP_X": true,
// 					"PLTYP": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVGR2_X": true,
// 					"KVGR2": "",
// 					"KTGRD_X": true,
// 					"KTGRD": "Z1",
// 					"KONDA_X": true,
// 					"KONDA": "",
// 					"KDGRP_X": true,
// 					"KDGRP": "",
// 					"KALKS_X": true,
// 					"KALKS": "X",
// 					"INCO3_L_X": null,
// 					"INCO3_L": null,
// 					"INCO2_L_X": true,
// 					"INCO2_L": "",
// 					"INCO1_X": true,
// 					"INCO1": "",
// 					"EIKTO_X": true,
// 					"EIKTO": "",
// 					"BZIRK_X": null,
// 					"BZIRK": null,
// 					"BPKUR_X": true,
// 					"BPKUR": "0020132000",
// 					"AUFSD_X": true,
// 					"AUFSD": ""
// 				},
// 				{
// 					"ZTERM_X": true,
// 					"ZTERM": "OA30",
// 					"ZKVGR5_X": true,
// 					"ZKVGR5": "",
// 					"ZKVGR4_X": true,
// 					"ZKVGR4": "",
// 					"ZKVGR3_X": true,
// 					"ZKVGR3": "",
// 					"ZKVGR1_X": true,
// 					"ZKVGR1": "",
// 					"WAERS_X": true,
// 					"WAERS": "USD",
// 					"VWERK_X": true,
// 					"VWERK": "",
// 					"VTWEG": "11",
// 					"VSBED_X": true,
// 					"VSBED": "01",
// 					"VKORG": "8050",
// 					"VKGRP_X": true,
// 					"VKGRP": "",
// 					"VKBUR_X": true,
// 					"VKBUR": "",
// 					"TAXCODN": [
// 						{
// 							"TAXKD_X": true,
// 							"TAXKD": "0",
// 							"TATYP": "MWST",
// 							"ALAND": "HK"
// 						}
// 					],
// 					"SPART": "00",
// 					"PYKUR_X": true,
// 					"PYKUR": "0020132000",
// 					"PODKZ_X": true,
// 					"PODKZ": false,
// 					"PLTYP_X": true,
// 					"PLTYP": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVGR2_X": true,
// 					"KVGR2": "",
// 					"KTGRD_X": true,
// 					"KTGRD": "Z1",
// 					"KONDA_X": true,
// 					"KONDA": "",
// 					"KDGRP_X": true,
// 					"KDGRP": "",
// 					"KALKS_X": true,
// 					"KALKS": "X",
// 					"INCO3_L_X": null,
// 					"INCO3_L": null,
// 					"INCO2_L_X": true,
// 					"INCO2_L": "",
// 					"INCO1_X": true,
// 					"INCO1": "",
// 					"EIKTO_X": true,
// 					"EIKTO": "",
// 					"BZIRK_X": null,
// 					"BZIRK": null,
// 					"BPKUR_X": true,
// 					"BPKUR": "0020132000",
// 					"AUFSD_X": true,
// 					"AUFSD": ""
// 				},
// 				{
// 					"ZTERM_X": true,
// 					"ZTERM": "OA30",
// 					"ZKVGR5_X": true,
// 					"ZKVGR5": "",
// 					"ZKVGR4_X": true,
// 					"ZKVGR4": "",
// 					"ZKVGR3_X": true,
// 					"ZKVGR3": "",
// 					"ZKVGR1_X": true,
// 					"ZKVGR1": "",
// 					"WAERS_X": true,
// 					"WAERS": "USD",
// 					"VWERK_X": true,
// 					"VWERK": "",
// 					"VTWEG": "11",
// 					"VSBED_X": true,
// 					"VSBED": "01",
// 					"VKORG": "80B0",
// 					"VKGRP_X": true,
// 					"VKGRP": "",
// 					"VKBUR_X": true,
// 					"VKBUR": "",
// 					"TAXCODN": [
// 						{
// 							"TAXKD_X": true,
// 							"TAXKD": "0",
// 							"TATYP": "ZWST",
// 							"ALAND": "SG"
// 						}
// 					],
// 					"SPART": "00",
// 					"PYKUR_X": true,
// 					"PYKUR": "0020132000",
// 					"PODKZ_X": true,
// 					"PODKZ": false,
// 					"PLTYP_X": true,
// 					"PLTYP": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVGR2_X": true,
// 					"KVGR2": "",
// 					"KTGRD_X": true,
// 					"KTGRD": "Z1",
// 					"KONDA_X": true,
// 					"KONDA": "",
// 					"KDGRP_X": true,
// 					"KDGRP": "",
// 					"KALKS_X": true,
// 					"KALKS": "X",
// 					"INCO3_L_X": null,
// 					"INCO3_L": null,
// 					"INCO2_L_X": true,
// 					"INCO2_L": "",
// 					"INCO1_X": true,
// 					"INCO1": "",
// 					"EIKTO_X": true,
// 					"EIKTO": "",
// 					"BZIRK_X": null,
// 					"BZIRK": null,
// 					"BPKUR_X": true,
// 					"BPKUR": "0020132000",
// 					"AUFSD_X": true,
// 					"AUFSD": ""
// 				},
// 				{
// 					"ZTERM_X": true,
// 					"ZTERM": "",
// 					"ZKVGR5_X": true,
// 					"ZKVGR5": "",
// 					"ZKVGR4_X": true,
// 					"ZKVGR4": "",
// 					"ZKVGR3_X": true,
// 					"ZKVGR3": "",
// 					"ZKVGR1_X": true,
// 					"ZKVGR1": "",
// 					"WAERS_X": true,
// 					"WAERS": "USD",
// 					"VWERK_X": true,
// 					"VWERK": "",
// 					"VTWEG": "11",
// 					"VSBED_X": true,
// 					"VSBED": "02",
// 					"VKORG": "8650",
// 					"VKGRP_X": true,
// 					"VKGRP": "",
// 					"VKBUR_X": true,
// 					"VKBUR": "PA06",
// 					"TAXCODN": [
// 						{
// 							"TAXKD_X": true,
// 							"TAXKD": "0",
// 							"TATYP": "ZWST",
// 							"ALAND": "PA"
// 						}
// 					],
// 					"SPART": "00",
// 					"PYKUR_X": true,
// 					"PYKUR": "0020132000",
// 					"PODKZ_X": true,
// 					"PODKZ": false,
// 					"PLTYP_X": true,
// 					"PLTYP": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVGR2_X": true,
// 					"KVGR2": "",
// 					"KTGRD_X": true,
// 					"KTGRD": "Z1",
// 					"KONDA_X": true,
// 					"KONDA": "",
// 					"KDGRP_X": true,
// 					"KDGRP": "P3",
// 					"KALKS_X": true,
// 					"KALKS": "X",
// 					"INCO3_L_X": null,
// 					"INCO3_L": null,
// 					"INCO2_L_X": true,
// 					"INCO2_L": "",
// 					"INCO1_X": true,
// 					"INCO1": "",
// 					"EIKTO_X": true,
// 					"EIKTO": "",
// 					"BZIRK_X": null,
// 					"BZIRK": null,
// 					"BPKUR_X": true,
// 					"BPKUR": "0020132000",
// 					"AUFSD_X": true,
// 					"AUFSD": ""
// 				},
// 				{
// 					"ZTERM_X": true,
// 					"ZTERM": "OA30",
// 					"ZKVGR5_X": true,
// 					"ZKVGR5": "",
// 					"ZKVGR4_X": true,
// 					"ZKVGR4": "",
// 					"ZKVGR3_X": true,
// 					"ZKVGR3": "",
// 					"ZKVGR1_X": true,
// 					"ZKVGR1": "",
// 					"WAERS_X": true,
// 					"WAERS": "USD",
// 					"VWERK_X": true,
// 					"VWERK": "",
// 					"VTWEG": "11",
// 					"VSBED_X": true,
// 					"VSBED": "01",
// 					"VKORG": "8910",
// 					"VKGRP_X": true,
// 					"VKGRP": "",
// 					"VKBUR_X": true,
// 					"VKBUR": "",
// 					"TAXCODN": [
// 						{
// 							"TAXKD_X": true,
// 							"TAXKD": "0",
// 							"TATYP": "MWST",
// 							"ALAND": "HK"
// 						}
// 					],
// 					"SPART": "00",
// 					"PYKUR_X": true,
// 					"PYKUR": "0020132000",
// 					"PODKZ_X": true,
// 					"PODKZ": false,
// 					"PLTYP_X": true,
// 					"PLTYP": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVGR2_X": true,
// 					"KVGR2": "",
// 					"KTGRD_X": true,
// 					"KTGRD": "Z1",
// 					"KONDA_X": true,
// 					"KONDA": "",
// 					"KDGRP_X": true,
// 					"KDGRP": "",
// 					"KALKS_X": true,
// 					"KALKS": "X",
// 					"INCO3_L_X": null,
// 					"INCO3_L": null,
// 					"INCO2_L_X": true,
// 					"INCO2_L": "",
// 					"INCO1_X": true,
// 					"INCO1": "",
// 					"EIKTO_X": true,
// 					"EIKTO": "",
// 					"BZIRK_X": null,
// 					"BZIRK": null,
// 					"BPKUR_X": true,
// 					"BPKUR": "0020132000",
// 					"AUFSD_X": true,
// 					"AUFSD": ""
// 				},
// 				{
// 					"ZTERM_X": true,
// 					"ZTERM": "OA30",
// 					"ZKVGR5_X": true,
// 					"ZKVGR5": "",
// 					"ZKVGR4_X": true,
// 					"ZKVGR4": "",
// 					"ZKVGR3_X": true,
// 					"ZKVGR3": "",
// 					"ZKVGR1_X": true,
// 					"ZKVGR1": "",
// 					"WAERS_X": true,
// 					"WAERS": "USD",
// 					"VWERK_X": true,
// 					"VWERK": "",
// 					"VTWEG": "11",
// 					"VSBED_X": true,
// 					"VSBED": "01",
// 					"VKORG": "8999",
// 					"VKGRP_X": true,
// 					"VKGRP": "",
// 					"VKBUR_X": true,
// 					"VKBUR": "",
// 					"TAXCODN": [
// 						{
// 							"TAXKD_X": true,
// 							"TAXKD": "0",
// 							"TATYP": "MWST",
// 							"ALAND": "HK"
// 						}
// 					],
// 					"SPART": "00",
// 					"PYKUR_X": true,
// 					"PYKUR": "0020132000",
// 					"PODKZ_X": true,
// 					"PODKZ": false,
// 					"PLTYP_X": true,
// 					"PLTYP": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVGR2_X": true,
// 					"KVGR2": "",
// 					"KTGRD_X": true,
// 					"KTGRD": "Z1",
// 					"KONDA_X": true,
// 					"KONDA": "",
// 					"KDGRP_X": true,
// 					"KDGRP": "",
// 					"KALKS_X": true,
// 					"KALKS": "X",
// 					"INCO3_L_X": null,
// 					"INCO3_L": null,
// 					"INCO2_L_X": true,
// 					"INCO2_L": "",
// 					"INCO1_X": true,
// 					"INCO1": "",
// 					"EIKTO_X": true,
// 					"EIKTO": "",
// 					"BZIRK_X": null,
// 					"BZIRK": null,
// 					"BPKUR_X": true,
// 					"BPKUR": "0020132000",
// 					"AUFSD_X": true,
// 					"AUFSD": ""
// 				},
// 				{
// 					"ZTERM_X": true,
// 					"ZTERM": "OA30",
// 					"ZKVGR5_X": true,
// 					"ZKVGR5": "",
// 					"ZKVGR4_X": true,
// 					"ZKVGR4": "",
// 					"ZKVGR3_X": true,
// 					"ZKVGR3": "",
// 					"ZKVGR1_X": true,
// 					"ZKVGR1": "",
// 					"WAERS_X": true,
// 					"WAERS": "USD",
// 					"VWERK_X": true,
// 					"VWERK": "",
// 					"VTWEG": "11",
// 					"VSBED_X": true,
// 					"VSBED": "01",
// 					"VKORG": "8000",
// 					"VKGRP_X": true,
// 					"VKGRP": "",
// 					"VKBUR_X": true,
// 					"VKBUR": "",
// 					"TAXCODN": [
// 						{
// 							"TAXKD_X": true,
// 							"TAXKD": "0",
// 							"TATYP": "MWST",
// 							"ALAND": "CN"
// 						}
// 					],
// 					"SPART": "00",
// 					"PYKUR_X": true,
// 					"PYKUR": "",
// 					"PODKZ_X": true,
// 					"PODKZ": false,
// 					"PLTYP_X": true,
// 					"PLTYP": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVGR2_X": true,
// 					"KVGR2": "",
// 					"KTGRD_X": true,
// 					"KTGRD": "Z1",
// 					"KONDA_X": true,
// 					"KONDA": "",
// 					"KDGRP_X": true,
// 					"KDGRP": "",
// 					"KALKS_X": true,
// 					"KALKS": "X",
// 					"INCO3_L_X": null,
// 					"INCO3_L": null,
// 					"INCO2_L_X": true,
// 					"INCO2_L": "",
// 					"INCO1_X": true,
// 					"INCO1": "",
// 					"EIKTO_X": true,
// 					"EIKTO": "",
// 					"BZIRK_X": null,
// 					"BZIRK": null,
// 					"BPKUR_X": true,
// 					"BPKUR": "",
// 					"AUFSD_X": true,
// 					"AUFSD": ""
// 				}
// 			],
// 			"PARTNER": "0020132000",
// 			"NAME_ORG4_X": true,
// 			"NAME_ORG4": "",
// 			"NAME_ORG3_X": true,
// 			"NAME_ORG3": "",
// 			"NAME_ORG2_X": true,
// 			"NAME_ORG2": "",
// 			"NAME_ORG1_X": true,
// 			"NAME_ORG1": "LG ELECTRONICS",
// 			"NAME_LO_X": true,
// 			"NAME_LO": "LG ELECTRONICS",
// 			"NAME_EN_X": true,
// 			"NAME_EN": "",
// 			"LZONE_X": true,
// 			"LZONE": "",
// 			"IND_SECTOR_X": true,
// 			"IND_SECTOR": "",
// 			"FOUND_DAT_X": null,
// 			"FOUND_DAT": null,
// 			"FAX_NUMBER_X": true,
// 			"FAX_NUMBER": "",
// 			"CUTSOMER_TYPE": [
// 				{
// 					"ZZCUSTY": "10",
// 					"PARTNER": null
// 				}
// 			],
// 			"COMPANY": [
// 				{
// 					"ZZSORT2_X": true,
// 					"ZZSORT2": "",
// 					"ZZSORT1_X": true,
// 					"ZZSORT1": "",
// 					"ZZSH_X": true,
// 					"ZZSH": "",
// 					"ZZLINE_X": null,
// 					"ZZLINE": null,
// 					"ZZLGORT_X": true,
// 					"ZZLGORT": "",
// 					"ZWELS_X": true,
// 					"ZWELS": "",
// 					"ZVALID_TO_X": null,
// 					"ZVALID_TO": null,
// 					"ZTV_X": true,
// 					"ZTV": "",
// 					"ZTERM_X": true,
// 					"ZTERM": "OA30",
// 					"ZKHFL_X": true,
// 					"ZKHFL": "",
// 					"SREGL_X": true,
// 					"SREGL": "",
// 					"PACKAGING_TYPE_X": true,
// 					"PACKAGING_TYPE": "",
// 					"NODEL_X": true,
// 					"NODEL": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVERM_X": true,
// 					"KVERM": "",
// 					"EDI_TYPE_X": true,
// 					"EDI_TYPE": "",
// 					"BUKRS": "8010",
// 					"AKONT_X": true,
// 					"AKONT": "1122020101"
// 				},
// 				{
// 					"ZZSORT2_X": true,
// 					"ZZSORT2": "",
// 					"ZZSORT1_X": true,
// 					"ZZSORT1": "",
// 					"ZZSH_X": true,
// 					"ZZSH": "",
// 					"ZZLINE_X": null,
// 					"ZZLINE": null,
// 					"ZZLGORT_X": true,
// 					"ZZLGORT": "",
// 					"ZWELS_X": true,
// 					"ZWELS": "",
// 					"ZVALID_TO_X": null,
// 					"ZVALID_TO": null,
// 					"ZTV_X": true,
// 					"ZTV": "",
// 					"ZTERM_X": true,
// 					"ZTERM": "OA30",
// 					"ZKHFL_X": true,
// 					"ZKHFL": "",
// 					"SREGL_X": true,
// 					"SREGL": "",
// 					"PACKAGING_TYPE_X": true,
// 					"PACKAGING_TYPE": "",
// 					"NODEL_X": true,
// 					"NODEL": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVERM_X": true,
// 					"KVERM": "",
// 					"EDI_TYPE_X": true,
// 					"EDI_TYPE": "",
// 					"BUKRS": "8040",
// 					"AKONT_X": true,
// 					"AKONT": "1122020101"
// 				},
// 				{
// 					"ZZSORT2_X": true,
// 					"ZZSORT2": "",
// 					"ZZSORT1_X": true,
// 					"ZZSORT1": "",
// 					"ZZSH_X": true,
// 					"ZZSH": "",
// 					"ZZLINE_X": null,
// 					"ZZLINE": null,
// 					"ZZLGORT_X": true,
// 					"ZZLGORT": "",
// 					"ZWELS_X": true,
// 					"ZWELS": "",
// 					"ZVALID_TO_X": null,
// 					"ZVALID_TO": null,
// 					"ZTV_X": true,
// 					"ZTV": "",
// 					"ZTERM_X": true,
// 					"ZTERM": "OA30",
// 					"ZKHFL_X": true,
// 					"ZKHFL": "",
// 					"SREGL_X": true,
// 					"SREGL": "",
// 					"PACKAGING_TYPE_X": true,
// 					"PACKAGING_TYPE": "",
// 					"NODEL_X": true,
// 					"NODEL": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVERM_X": true,
// 					"KVERM": "",
// 					"EDI_TYPE_X": true,
// 					"EDI_TYPE": "",
// 					"BUKRS": "8050",
// 					"AKONT_X": true,
// 					"AKONT": "1122020101"
// 				},
// 				{
// 					"ZZSORT2_X": true,
// 					"ZZSORT2": "",
// 					"ZZSORT1_X": true,
// 					"ZZSORT1": "",
// 					"ZZSH_X": true,
// 					"ZZSH": "",
// 					"ZZLINE_X": null,
// 					"ZZLINE": null,
// 					"ZZLGORT_X": true,
// 					"ZZLGORT": "",
// 					"ZWELS_X": true,
// 					"ZWELS": "",
// 					"ZVALID_TO_X": null,
// 					"ZVALID_TO": null,
// 					"ZTV_X": true,
// 					"ZTV": "",
// 					"ZTERM_X": true,
// 					"ZTERM": "OA30",
// 					"ZKHFL_X": true,
// 					"ZKHFL": "",
// 					"SREGL_X": true,
// 					"SREGL": "",
// 					"PACKAGING_TYPE_X": true,
// 					"PACKAGING_TYPE": "",
// 					"NODEL_X": true,
// 					"NODEL": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVERM_X": true,
// 					"KVERM": "",
// 					"EDI_TYPE_X": true,
// 					"EDI_TYPE": "",
// 					"BUKRS": "80B0",
// 					"AKONT_X": true,
// 					"AKONT": "1122020101"
// 				},
// 				{
// 					"ZZSORT2_X": true,
// 					"ZZSORT2": "",
// 					"ZZSORT1_X": true,
// 					"ZZSORT1": "",
// 					"ZZSH_X": true,
// 					"ZZSH": "",
// 					"ZZLINE_X": null,
// 					"ZZLINE": null,
// 					"ZZLGORT_X": true,
// 					"ZZLGORT": "",
// 					"ZWELS_X": true,
// 					"ZWELS": "",
// 					"ZVALID_TO_X": null,
// 					"ZVALID_TO": null,
// 					"ZTV_X": true,
// 					"ZTV": "",
// 					"ZTERM_X": true,
// 					"ZTERM": "G007",
// 					"ZKHFL_X": true,
// 					"ZKHFL": "",
// 					"SREGL_X": true,
// 					"SREGL": "",
// 					"PACKAGING_TYPE_X": true,
// 					"PACKAGING_TYPE": "",
// 					"NODEL_X": true,
// 					"NODEL": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVERM_X": true,
// 					"KVERM": "",
// 					"EDI_TYPE_X": true,
// 					"EDI_TYPE": "",
// 					"BUKRS": "8650",
// 					"AKONT_X": true,
// 					"AKONT": "1122020101"
// 				},
// 				{
// 					"ZZSORT2_X": true,
// 					"ZZSORT2": "",
// 					"ZZSORT1_X": true,
// 					"ZZSORT1": "",
// 					"ZZSH_X": true,
// 					"ZZSH": "",
// 					"ZZLINE_X": null,
// 					"ZZLINE": null,
// 					"ZZLGORT_X": true,
// 					"ZZLGORT": "",
// 					"ZWELS_X": true,
// 					"ZWELS": "",
// 					"ZVALID_TO_X": null,
// 					"ZVALID_TO": null,
// 					"ZTV_X": true,
// 					"ZTV": "",
// 					"ZTERM_X": true,
// 					"ZTERM": "OA30",
// 					"ZKHFL_X": true,
// 					"ZKHFL": "",
// 					"SREGL_X": true,
// 					"SREGL": "",
// 					"PACKAGING_TYPE_X": true,
// 					"PACKAGING_TYPE": "",
// 					"NODEL_X": true,
// 					"NODEL": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVERM_X": true,
// 					"KVERM": "",
// 					"EDI_TYPE_X": true,
// 					"EDI_TYPE": "",
// 					"BUKRS": "8910",
// 					"AKONT_X": true,
// 					"AKONT": "1122020101"
// 				},
// 				{
// 					"ZZSORT2_X": true,
// 					"ZZSORT2": "",
// 					"ZZSORT1_X": true,
// 					"ZZSORT1": "",
// 					"ZZSH_X": true,
// 					"ZZSH": "",
// 					"ZZLINE_X": null,
// 					"ZZLINE": null,
// 					"ZZLGORT_X": true,
// 					"ZZLGORT": "",
// 					"ZWELS_X": true,
// 					"ZWELS": "",
// 					"ZVALID_TO_X": null,
// 					"ZVALID_TO": null,
// 					"ZTV_X": true,
// 					"ZTV": "",
// 					"ZTERM_X": true,
// 					"ZTERM": "OA30",
// 					"ZKHFL_X": true,
// 					"ZKHFL": "",
// 					"SREGL_X": true,
// 					"SREGL": "",
// 					"PACKAGING_TYPE_X": true,
// 					"PACKAGING_TYPE": "",
// 					"NODEL_X": true,
// 					"NODEL": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVERM_X": true,
// 					"KVERM": "",
// 					"EDI_TYPE_X": true,
// 					"EDI_TYPE": "",
// 					"BUKRS": "8999",
// 					"AKONT_X": true,
// 					"AKONT": "1122020101"
// 				},
// 				{
// 					"ZZSORT2_X": true,
// 					"ZZSORT2": "",
// 					"ZZSORT1_X": true,
// 					"ZZSORT1": "",
// 					"ZZSH_X": true,
// 					"ZZSH": "",
// 					"ZZLINE_X": null,
// 					"ZZLINE": null,
// 					"ZZLGORT_X": true,
// 					"ZZLGORT": "",
// 					"ZWELS_X": true,
// 					"ZWELS": "",
// 					"ZVALID_TO_X": null,
// 					"ZVALID_TO": null,
// 					"ZTV_X": true,
// 					"ZTV": "",
// 					"ZTERM_X": true,
// 					"ZTERM": "OA30",
// 					"ZKHFL_X": true,
// 					"ZKHFL": "",
// 					"SREGL_X": true,
// 					"SREGL": "",
// 					"PACKAGING_TYPE_X": true,
// 					"PACKAGING_TYPE": "",
// 					"NODEL_X": true,
// 					"NODEL": "",
// 					"LOEVM_X": true,
// 					"LOEVM": false,
// 					"KVERM_X": true,
// 					"KVERM": "",
// 					"EDI_TYPE_X": true,
// 					"EDI_TYPE": "",
// 					"BUKRS": "8000",
// 					"AKONT_X": true,
// 					"AKONT": "1122020101"
// 				}
// 			],
// 			"BUBKZ_X": true,
// 			"BUBKZ": "0",
// 			"BU_SORT1_X": true,
// 			"BU_SORT1": "LG",
// 			"BU_LANGU_X": true,
// 			"BU_LANGU": "EN",
// 			"BU_GROUP": "H002",
// 			"BBSNR_X": true,
// 			"BBSNR": "00000",
// 			"BBBNR_X": true,
// 			"BBBNR": "0000000",
// 			"BANKDETAIL": [
// 				{
// 					"ZZWAERS_X": true,
// 					"ZZWAERS": "USD",
// 					"ZZACCNAME_X": true,
// 					"ZZACCNAME": "WOORI BANK TWIN TOWER CORPORAT",
// 					"PMODE": "",
// 					"IBAN_X": null,
// 					"IBAN": null,
// 					"BKONT_X": true,
// 					"BKONT": null,
// 					"BANKS": "KR",
// 					"BANKN": "LGE98349835",
// 					"BANKL": "H016384901",
// 					"ACCNAME_X": true,
// 					"ACCNAME": "LG ELECTRONICS"
// 				}
// 			],
// 			"ADDR": [
// 				{
// 					"ZZTOWN_X": true,
// 					"ZZTOWN": "",
// 					"ZZADTY": "01",
// 					"STR_SUPPL4_X": true,
// 					"STR_SUPPL4": "",
// 					"STR_SUPPL3_X": true,
// 					"STR_SUPPL3": "",
// 					"STR_SUPPL2_X": true,
// 					"STR_SUPPL2": "LG Twin Towers,128, Yeoui-daero,",
// 					"STR_LOCATION_X": true,
// 					"STR_LOCATION": "",
// 					"REGIO_X": true,
// 					"REGIO": "13",
// 					"POST_CODE1_X": true,
// 					"POST_CODE1": "",
// 					"ORT02_X": true,
// 					"ORT02": "",
// 					"ORT01_X": true,
// 					"ORT01": "Yeongdeungpo-gu",
// 					"LAND1_X": true,
// 					"LAND1": "KR",
// 					"FSTRAS_X": true,
// 					"FSTRAS": "76 Seongsan-dong Changwon CityGyeongnam 641-713 Korea"
// 				}
// 			]
// 		},
// 		"BU_LANGU": ""
// 	}
// }
}