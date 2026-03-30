public class FieldDependencyController {
    
    /**
     * 查询所有对象的字段依赖关系
     * @return Map<String, List<FieldDependencyInfo>> 对象名到依赖关系列表的映射
     */
    public static Map<String, List<FieldDependencyInfo>> getAllFieldDependencies() {
        Map<String, List<FieldDependencyInfo>> objectDependencies = new Map<String, List<FieldDependencyInfo>>();
        
        // 获取所有对象
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        
        for (String objectName : globalDescribe.keySet()) {
            Schema.SObjectType objType = globalDescribe.get(objectName);
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            
            // 获取对象的所有字段
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            List<FieldDependencyInfo> dependencies = new List<FieldDependencyInfo>();
            
            for (String fieldName : fieldMap.keySet()) {
                Schema.SObjectField field = fieldMap.get(fieldName);
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                
                // 检查字段是否有控制字段（依赖关系）
                if (fieldDescribe.getController() != null) {
                    FieldDependencyInfo dependency = new FieldDependencyInfo();
                    dependency.dependentField = fieldDescribe.getName();
                    dependency.controllingField = fieldDescribe.getController().getDescribe().getName();
                    dependency.objectName = objDescribe.getName();
                    dependency.fieldLabel = fieldDescribe.getLabel();
                    dependency.controllingFieldLabel = fieldDescribe.getController().getDescribe().getLabel();
                    
                    // 获取依赖值映射（Picklist依赖）
                    if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
                        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
                        for (Schema.PicklistEntry entry : picklistEntries) {
                            if (entry.isActive()) {
                                // dependency.validFor = entry.getValidFor();
                            }
                        }
                    }
                    
                    dependencies.add(dependency);
                }
            }
            
            if (!dependencies.isEmpty()) {
                objectDependencies.put(objDescribe.getName(), dependencies);
            }
        }
        
        return objectDependencies;
    }
    
    /**
     * 查询特定对象的字段依赖关系
     * @param objectName 对象API名称
     * @return List<FieldDependencyInfo> 该对象的字段依赖关系列表
     */
    public static List<FieldDependencyInfo> getObjectFieldDependencies(String objectName) {
        List<FieldDependencyInfo> dependencies = new List<FieldDependencyInfo>();
        
        try {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            if (objType != null) {
                Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
                Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            
                for (String fieldName : fieldMap.keySet()) {
                    Schema.SObjectField field = fieldMap.get(fieldName);
                    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                    
                    if (fieldDescribe.getController() != null) {
                        FieldDependencyInfo dependency = new FieldDependencyInfo();
                        dependency.dependentField = fieldDescribe.getName();
                        dependency.controllingField = fieldDescribe.getController().getDescribe().getName();
                        dependency.objectName = objDescribe.getName();
                        dependency.fieldLabel = fieldDescribe.getLabel();
                        dependency.controllingFieldLabel = fieldDescribe.getController().getDescribe().getLabel();
                        dependencies.add(dependency);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error retrieving dependencies for object: ' + objectName + ' - ' + e.getMessage());
        }
        
        return dependencies;
    }
    
    /**
     * 字段依赖信息包装类
     */
    public class FieldDependencyInfo {
        public String objectName { get; set; }
        public String dependentField { get; set; }
        public String controllingField { get; set; }
        public String fieldLabel { get; set; }
        public String controllingFieldLabel { get; set; }
        public String validFor { get; set; }
    }
}