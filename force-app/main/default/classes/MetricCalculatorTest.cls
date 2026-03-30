@isTest
private class MetricCalculatorTest {
    static testMethod void testMethod1() {
        Test.startTest();

        MetricCalculator.calculateAllMetrics(9,8,1,1);
        Test.stopTest();
    }
}