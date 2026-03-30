/**
 * @description List Query Basic Definition
 * @author Bright Xu
 * Modifications Log
 * Ver	Date		Author		Modification
 * 1.0	2019-02-10	Bright Xu	Initial Version
*/
public class Lisq {
    public static Boolean enableLog = false;
    
    public static void Log(object obj){
        if(!enableLog) return;
        system.debug(getClassName(2) + ':' + obj);
    }
    
    static void LogCore(object obj){
        if(!enableLog) return;
        system.debug(getClassName(1) + ':' + obj);
    }
    
    static String getClassName(Integer i)
    {
        String className = '';
        try {
            throw new DMLException('');
        } catch (Exception e) {
            String[] ss = e.getStackTraceString().split('\n');
            system.debug(ss);
            if (ss.size() > 1) {
                className = ss[i];
            }
        }
        return className;
    }

    public interface IWeight
    {
        Double fun(object t );
    }

    public interface IComparable
    {
        integer fun(object t1,object t2);
    }
    
    public interface IFilter
    {
        boolean fun(object t );
    }
      
    public interface ISelect
    {
        object fun(object t);
    }
    
    public static double Sum(List<object> source, IWeight fun)
    {
        double res =0;
        for(object o : source)
        {
            double d = fun.fun(o);
            if(d == null) d=0;
            res += d;
        }
        return res;
    }
    
    public static double Average(List<object> source, IWeight fun)
    {
        if(source == null)return null;
        if(source.size() == 0)return 0;
        return Sum(source,fun) / source.size();
    }
    
    public static object FirstOrNull(List<object> source, IFilter fun)
    {
        for(object o : source)
        {
            if(fun.fun(o))
            {
                return o;
            }
        }
        
        return null;
    }
    
    public static boolean All(List<object> source, IFilter fun)
    {
        for(object o : source)
        {
            if(!fun.fun(o))
            {
                return false;
            }
        }
        
        return true;
    }
    
    // 集合中任一元素满足条件则返回true，否则返回false
    public static boolean Any(List<object> source, IFilter fun)
    {
        return FirstOrNull(source, fun) != null;
    }
    
    
    // 返回集合中满足条件的元素
    public static List<object> Filter(List<object> source, IFilter filter)
    {
        List<object> temp = new List<object>();
        
        for(object o : source)
        {
            if(filter.fun(o))
            {
                temp.add(o);
            }
        }
        
        return temp;
    }
    
    
    // 返回元素的键值对，重复会替代之前的值
    public static Map<object,object> ToMap(List<object> source, ISelect mapper )
    {
        return ToMap(source, mapper, true, true);
    }
    
    public static Map<object,object> ToMap(List<object> source, ISelect mapper, boolean key_null_to_continue, boolean allow_duplicate )
    {
        Map<object,object> moo = new Map<object,object>();
        
        for(object o : source)
        {
            object key = mapper.fun(o);
            if(key == null && key_null_to_continue)continue;
            
            if(!allow_duplicate && moo.containsKey(key))
            {
                Exception e = new NullPointerException();
                e.setMessage('duplicate key \''+ key +'\'');
                throw e;
            }
            
            moo.put(key, o);
        }
        
        return moo;
    }
    
    public static Map<object,List<object>> GroupBy(List<object> source, ISelect mapper)
    {
        return GroupBy(source,mapper,true);
    }
    
    public static Map<object,List<object>> GroupBy(List<object> source, ISelect mapper, boolean skip_null_key)
    {
        Map<object,List<object>> moo = new Map<object,List<object>>();
        
        for(object o : source)
        {
            object key = mapper.fun(o);  
            if(skip_null_key && key == null )continue;
            if( moo.containsKey(key))
            {
                moo.get(key).add(o);
            }
            else
            {
                List<object> lo = new List<object>();
                lo.add(o);
                moo.put(key,lo);
            }
            
        }
        
        return moo;
    }
    
    // 用原有集合返回新的集合
    public static List<object> SelectNew(List<object> source, ISelect selector)
    {
        return SelectNew(source, selector,null);
    }

    public static List<object> SelectNew(List<object> source, ISelect selector,IFilter filter)
    {
        List<object> temp = new List<object>();
        
        for(object o : source)
        {
            if (filter == null || filter.fun(o)) {
                temp.add(selector.fun(o));
            }
        }
        
        return temp;
    }


    
    // 返回降序结果
    public static List<object> OrderByDesc(List<object> source)
    {
        List<object> t = null;
        if (source == null) {
            return t;
        }
        
        
        t = new List<object>();
        for(Integer i = 0; i<source.size();i++){
            t.add(source[source.size()-1-i]);
        }

        return t;
    }

    
    public static List<object> Distinct(List<object> source){
        return new List<object>(new Set<object>(source));
    }
    
    public static boolean AllMatch(List<object> list1,List<object> list2){
        return AllMatch(list1,list2,false);
    }
    
    public static boolean AllMatch(List<object> list1,List<object> list2, boolean order){
        if(list1 == list2 )return true;
        if(list1 == null )return false;
        if(list2 == null )return false;
        if(list1.size() != list2.size())return false;
        List<object> l1 = new List<object>(list1);
        List<object> l2 = new List<object>(list2);
        if(!order){
            l1.sort();
        	l2.sort();
            system.debug(l1);
            system.debug(l2);
        }
        for(integer i = 0; i < l1.size(); i++){
            if(l1.get(i) != l2.get(i)){
                system.debug(i);
                return false;
            }
        }
        return true;
    }

}