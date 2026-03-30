@isTest
public class FieldDependencyTest{
    @isTest
    static void testGetAllFieldDependencies(){
        // 执行测试
        Test.startTest();
        Map<String, List<FieldDependencyController.FieldDependencyInfo>> dependencies = FieldDependencyController.getAllFieldDependencies();
        Test.stopTest();

        // 验证结果
        System.assertNotEquals(null, dependencies, '依赖关系映射不应为空');
        System.debug('Found dependencies for ' + dependencies.size() + ' objects');
    }

    @isTest
    static void testGetObjectFieldDependencies(){
        // 测试标准对象（如Account）
        Test.startTest();
        List<FieldDependencyController.FieldDependencyInfo> accountDependencies = FieldDependencyController.getObjectFieldDependencies('Account');
        Test.stopTest();

        System.assertNotEquals(null, accountDependencies, 'Account对象依赖关系不应为空');
    }

    @isTest
    static void testInvalidObjectDependencies(){
        // 测试无效对象名
        Test.startTest();
        List<FieldDependencyController.FieldDependencyInfo> invalidDependencies = FieldDependencyController.getObjectFieldDependencies('InvalidObject');
        Test.stopTest();

        System.assertEquals(0, invalidDependencies.size(), '无效对象应返回空列表');
    }

}