@isTest
private class GetSellOutInventoryTest {
    static testMethod void testMethod1() {
        TestDataUtility.createCustomSettings();

        Test.startTest();
        
        String json = '{"DATA":[{"vendor":"0000009224","ch_store_no":"123","vendor_name":"HISENSE SA SALES HOLDINGS","create_dt":"2024-02-29 00:00:00","p_term":"T30N","future_promo":null,"seq_no":"4100","article":"850001176","none1":"0","article_desc":"HISENSE 7KG F/LOADER W/MACHINE S/STEEL","barcode":"6901101828897","bmc":"GFBD02","bmc_description":"Front Load Washers","class":null,"pbc":null,"order_unit":1,"week_l4":0,"week_l3":0,"week_l2":10,"week_l1":4,"week_current":4,"week_n1":2,"week_ly":0,"curr_ys":6,"uom":"EA","compo":1,"site":"M24","site_name":"Alberton Main Store","status":null,"rp":"Z4","soh":13,"soo":0,"sit":0,"pr_qty":0,"mac":4217,"stock_margin":11.81,"list_price":"4694","net_cost":"4694","end_date":"311299","product_margin":1.83,"planned_margin":0,"incl_sp":"5999","prom_sp":5499,"sb":"X","tb":"X","free_stock":null,"ret_ord":0,"plan_dsc":0,"act_dsc":72.626,"rr":"1","last_recv":"2023-11-19 00:00:00","last_sold":"2024-02-03 00:00:00","so_qty":0,"atp":0,"dist_prof":null,"week":"5","loaddt":"2024-02-05T17:48:11Z","datatime":"29.01.2024to04.02.2024","load_dt":"2024-04-24T04:03:08Z"}]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));

        GetSellOutInventory.GetSellOutInventory('20240229', '20240301', 5000, 0, true, '', '');
        GetSellOutInventory.GetSellOutInventory('20240229', '20240301', 5000, 0, false, '', '');

       
        Test.stopTest();
    }

    static testMethod void testMethod2() {
        TestDataUtility.createCustomSettings();

        Test.startTest();
        
        String json1 = '{"DATA":[]}';
        Test.setMock(HttpCalloutMock.class, new CalloutMock(json1));

        GetSellOutInventory.GetSellOutInventory('20240229', '20240301', 5000, 0, true, '', '');
        GetSellOutInventory.GetSellOutInventory('20240229', '20240301', 5000, 0, false, '', '');

        Test.stopTest();
    }

    // static testMethod void testMethod2() {
    //     TestDataUtility.createCustomSettings();

    //     Test.startTest();
    	
    //     String item = '{"vendor":"0000009224","ch_store_no":"123","vendor_name":"HISENSE SA SALES HOLDINGS","create_dt":"2024-02-29 00:00:00","p_term":"T30N","future_promo":null,"seq_no":"4100","article":"850001176","none1":"0","article_desc":"HISENSE 7KG F/LOADER W/MACHINE S/STEEL","barcode":"6901101828897","bmc":"GFBD02","bmc_description":"Front Load Washers","class":null,"pbc":null,"order_unit":1,"week_l4":0,"week_l3":0,"week_l2":10,"week_l1":4,"week_current":4,"week_n1":2,"week_ly":0,"curr_ys":6,"uom":"EA","compo":1,"site":"M24","site_name":"Alberton Main Store","status":null,"rp":"Z4","soh":13,"soo":0,"sit":0,"pr_qty":0,"mac":4217,"stock_margin":11.81,"list_price":"4694","net_cost":"4694","end_date":"311299","product_margin":1.83,"planned_margin":0,"incl_sp":"5999","prom_sp":5499,"sb":"X","tb":"X","free_stock":null,"ret_ord":0,"plan_dsc":0,"act_dsc":72.626,"rr":"1","last_recv":"2023-11-19 00:00:00","last_sold":"2024-02-03 00:00:00","so_qty":0,"atp":0,"dist_prof":null,"week":"5","loaddt":"2024-02-05T17:48:11Z","datatime":"29.01.2024to04.02.2024","load_dt":"2024-04-24T04:03:08Z"}';
    //     String json = '{"DATA":[';
    //     for(Integer i = 0; i < 1000; i++){
    //         json = json + item;
    //     }
    //     json = json + ']}';

    //     Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
    //     GetSellOutInventory.saveText(json, '2024-02-29 00:00:00');

    //     GetSellOutInventory.readTextAndInsert('2024-02-29 00:00:00');
    //     Test.stopTest();
    // }
}