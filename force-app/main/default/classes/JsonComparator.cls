/*
 * @Author: WFC
 * @Date: 2025-05-15 18:09:59
 * @LastEditors: WFC
 * @LastEditTime: 2025-05-21 16:35:45
 * @Description: 比较两个json不同处
 * @FilePath: \HiTest20250422\force-app\main\default\classes\JsonComparator.cls
 */
public without sharing class JsonComparator{
    // 比较两个 JSON 字符串并返回不同的字段及其值
    public static Map<String, Object> compareJson(String json1, String json2){
        // 解析 JSON 字符串为 Map 类型
        Map<String, Object> map1 = (Map<String, Object>)JSON.deserializeUntyped(json1);
        Map<String, Object> map2 = (Map<String, Object>)JSON.deserializeUntyped(json2);

        // 用来存储不同的字段及其值
        Map<String, Object> differences = new Map<String, Object>();

        // 排除字段
        List<String> excludeList = Label.Comparator_Exclude.split(',');

        // 遍历 map1，查找与 map2 中不同的值
        for (String key : map1.keySet()){
            // 去除排除字段
            if (!excludeList.contains(key)){
                // 如果 map2 不包含该 key 或者值不同
                if (!map2.containsKey(key) || !map1.get(key).equals(map2.get(key))){
                    differences.put(key, new Map<String, Object>{ 'json1' => map1.get(key), 'json2' => map2.get(key) });
                }
            }
        }

        // 遍历 map2，查找 map1 中没有的字段
        for (String key : map2.keySet()){
            // 去除排除字段
            if (!excludeList.contains(key)){
                // 如果 map1 不包含该 key
                if (!map1.containsKey(key)){
                    differences.put(key, new Map<String, Object>{ 'json1' => null, 'json2' => map2.get(key) });
                }
            }
        }

        return differences;
    }

}