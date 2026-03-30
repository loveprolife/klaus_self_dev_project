@isTest
private class GetAUAvailableInventoryFromSAPTest {
    static testMethod void testMethod1() {
        TestDataUtility.createCustomSettings();

        Test.startTest();
    	
        String json = '{' +
            '"ITAB": [' +
                '{' +
                    '"EAN11": 6943634889525,' +
                    '"ZCUSMODEL": "HYXE-VA01A",' +
                    '"LGORT": "M003",' +
                    '"WERKS": 8140,' +
                    '"MATNR": "GKH128NC2012",' +
                    '"CHARG": "HR210461",' +
                    '"ERSDA": "2022-06-22",' +
                    '"LABST": "4950.000",' +
                    '"ZKYKC": "4950.000",' +
                    '"SOQTY": 0,' +
                    '"DNQTY": 0,' +
                    '"BRQTY": 0,' +
                    '"UBQTY": 0,' +
                    '"MTART": "FERT"' +
                '}' +
            ']' +
        '}';

        Test.setMock(HttpCalloutMock.class, new CalloutMock(json));
        GetAUAvailableInventoryFromSAP.getAUAvailableInventoryFromSAP();
        Test.stopTest();
    }
}