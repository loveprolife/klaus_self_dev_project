/*
 * @Author: WFC
 * @Date: 2025-06-26 16:23:39
 * @LastEditors: WFC
 * @LastEditTime: 2025-06-26 16:26:05
 * @Description: 按照参考表排序
 * @FilePath: \testuat\force-app\main\default\classes\CustomSorterContoller.cls
 */
public with sharing class CustomSorterContoller {
    // 主排序方法
    public static List<String> sortByReference(
        List<String> toSort, 
        List<String> referenceList
    ) {
        // 创建元素到索引的映射
        Map<String, Integer> indexMap = new Map<String, Integer>();
        for(Integer i = 0; i < referenceList.size(); i++) {
            indexMap.put(referenceList[i], i);
        }
        
        // 自定义比较器
        CustomComparator comp = new CustomComparator(indexMap);
        List<String> result = new List<String>(toSort);
        result.sort(comp);
        return result;
    }
    
    // 自定义比较器类
    private class CustomComparator implements System.Comparator<String> {
        private Map<String, Integer> indexMap;
        
        public CustomComparator(Map<String, Integer> tempMap) {
            this.indexMap = tempMap;
        }
        
        public Integer compare(String a, String b) {
            Integer indexA = indexMap.containsKey(a) ? indexMap.get(a) : 999;
            Integer indexB = indexMap.containsKey(b) ? indexMap.get(b) : 999;
            return indexA - indexB;
        }
    }
}