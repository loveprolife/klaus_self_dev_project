@isTest
public class CommonUtilsTest {
	@isTest
    static void testMethod1(){
        Long testLong;
        Decimal testDecimal;
        Double testDou;
        List<String> testList;
        Map<String,Object> testMap = new Map<String,Object>();
        
        String testStr = 'sdjsadfsidfigosgoasg';
        String testStr2 = 'sdjsagosgoasg';
        
        testMap.put(testStr,testStr2);
        
        Test.startTest();
        CommonUtils.AppendStr(testStr, testStr2);
        CommonUtils.subStr(testStr, 5);
        CommonUtils.subStr(testStr, 2, 8);
        CommonUtils.GetStr(testStr);
        CommonUtils.JsonSerializeObject(testMap);
        CommonUtils.GetType(testLong);
        CommonUtils.GetType(testDecimal);
        CommonUtils.GetType(testDou);
        CommonUtils.GetType(testList);
        Test.stopTest();
        
    }
}