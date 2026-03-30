/**
 * @description List Query Utils, implementions of Lisq interface
 * @author Bright Xu
 * Modifications Log
 * Ver	Date		Author		Modification
 * 1.0	2019-02-10	Bright Xu	Initial Version
*/
public class LisqUtils {

    /**
     * Filter list item in des list
     */
    public class InList implements Lisq.IFilter{
        List<object> des;
        boolean in_or_not;
        public InList(List<object> des){
            this(des,true);
        }
        
        public InList(List<object> des, boolean in_or_not){
            this.des = des;
            this.in_or_not = in_or_not;
        }
        
        public boolean fun(object t)
        {
            boolean b = des.contains(t);
            return in_or_not ? b : !b ;
        }
    }
    
    
    static integer Compare(object f1,object f2){
        if(f1 == f2){
                return 0;
        }

        if(f1 == null){
            return -1;
        }

        if(f2 == null){
            return 1;
        }
        
        if(f1.equals(f2))return 0;

        if(CommonUtils.IsNumberic(f1)){
            Decimal f3 = (Decimal)f1 - (Decimal)f2;
            if (Math.abs(f3) < 0.00000000001) {
                return 0;
            }
            else if( f3 > 0){
                return 1;
            }
            else{
                return -1;
            }
        }
        else{
            string s1 = f1+'';
            string s2 = f2+'';
            if(s1 == s2){
                return 0;
            }
            else if(s1 < s2){
                return -1;
            }
            else{
                return 1;
            }
        }
    }

    /**
     * convert a sobject to a number with a field
     */
    public class ConvertToNumber implements Lisq.IWeight
    {
        string field = null;

        public ConvertToNumber(){
        }

        public ConvertToNumber(string field){
            this.field = field;
        }
        
        public double fun(object t)
        {
            if (field == null) {
                return Double.valueOf(t);
            }

            return (double)(GetSObjectField(t, field));
        }
    }
    
    /**
     * select a new array with each item's one field
     */
    public class SObjectSelectField implements Lisq.ISelect
    {
        string field;
        public SObjectSelectField(string field){
            this.field = field;
        }
        
        public object fun(object t)
        {
            return GetSObjectField(t, field);
        }
    }
    
    /**
     * select a sobject with each item's fields map
     */
    public class SObjectSelectObject implements Lisq.ISelect
    {
        string class_name;
        Map<string,string> field_mapping;
        boolean skip_null;
        
        
        public SObjectSelectObject(string class_name, Map<string,string> field_mapping,boolean skip_null ){
            this.class_name = class_name;
            this.field_mapping = field_mapping;
            this.skip_null = skip_null;
        }
        
        public object fun(object t)
        {
            if(skip_null && t == null )return null;
            SObject so = (SObject)(Type.forName(class_name).newInstance());
                        
            for(string f : field_mapping.keySet()){
                so.put(f,((SObject)t).get(field_mapping.get(f)));
            }
            return so;
        }
    }

    /**
     * select a new string with join items one
     */
    public class SObjectJoinField implements Lisq.ISelect
    {
        string[] fields;
        string separator;

        public SObjectJoinField(string[] fields, String separator){
            this.fields = fields;
            this.separator = separator;
        }
        
        public object fun(object t)
        {
            List<Object> temp = new List<Object>();
            for (String field : fields) {
                temp.add(GetSObjectField(t, field));
            }
            return String.join(temp, separator);
        }
    }

    public class BooleanFilter implements Lisq.IFilter
    {
        Boolean b = null;
        public BooleanFilter(Boolean b)
        {
            this.b = b;
        }

        public boolean fun(object o){
            return b;
        }
    }

    /**
     * filter the field value compare to the key with a operator
     */
    public class FieldCompare implements Lisq.IFilter
    {
        object key = null;
        string field = null;
        Lisq.ISelect selecter = null;
        string op = null;
        FieldNotEqual ne = null;

        /**
         * operator:< <= = > >= != IN NOTIN NOTBLANK ISBLANK ISCHANGED NOTCHANGED REGEX
         */
        public FieldCompare(string field, string operator,object key){
            this.op = operator.toUpperCase();
            this.field = field;
            this.key = key;
            ne = new FieldNotEqual(field,key);
        }

        public FieldCompare(Lisq.ISelect selecter, string operator,object key){
            this.op = operator.toUpperCase();
            this.selecter = selecter;
            this.key = key;
            ne = new FieldNotEqual(field,key);
        }

        /**
         * operator:< <= = > >= != IN NOTIN NOTBLANK ISBLANK ISCHANGED NOTCHANGED REGEX
         */
        public FieldCompare(string field, string operator){
            this.op = operator.toUpperCase();
            this.field = field;
            this.key = '';
            ne = new FieldNotEqual(field,key);
        }

        public FieldCompare(Lisq.ISelect selecter, string operator){
            this.op = operator.toUpperCase();
            this.selecter = selecter;
            this.key = '';
            ne = new FieldNotEqual(field,key);
        }
        
        public boolean fun(object o)
        {

            if (!(o instanceof sobject)) {
                return false;
            }

            object t = null;
            if (string.isBlank(field)) {
                t = selecter.fun(o);
            }
            else{
                t = GetSObjectField(o, field);
            }
            
            //Log(field+' = '+ t);
            
            if (op == '<') {
                return Compare(t,key) < 0;
            }
            else if(op == '<='){
                return Compare(t,key) <= 0;
            }
            else if(op == '=' || op == '==' || op == '==='){
                return Compare(t,key) == 0;
            }
            else if(op == '>'){
                return Compare(t,key) > 0;
            }
            else if(op == '>='){
                return Compare(t,key) >= 0;
            }
            else if(op == '!=' || op == '<>'){
                return ne.fun(o);
            }
            else if(op == 'IN' || op == 'NOTIN'){
                Boolean b = (key != null && key instanceof object[]) ? ((object[])key).contains(t) : false;
                if (op == 'NOTIN') {
                    b = !b;
                }
                Lisq.Log(field+' = '+t+' is '+ b);
                return b;
            }
            else if(op == 'NOTBLANK' || op == 'ISNOTBLANK'){
                return !String.isBlank(CommonUtils.GetStr(t));
            }
            else if(op == 'ISBLANK'){
                return String.isBlank(CommonUtils.GetStr(t));
            }
            else if(op == 'ISCHANGED' || op == 'NOTCHANGED' || op == 'ISNOTCHANGED'){
                
                Boolean b = null;
                do {
                    // 如果没有id，不能对比，视为不变
                    Id iid = ((sobject)o).Id;
                    if (iid == null) {
                        b = false;
                        break;
                    }

                    // 如果数据为空或者数据非法，视为改变
                    if (key == null) {
                        b = true;
                        break;
                    }
                    Map<Id,Sobject> mio = null;
                    if(key instanceof List<Sobject>) {
                        mio = new Map<Id,Sobject>((List<Sobject>)key);
                    }
                    if(key instanceof Map<Id,Sobject>) {
                        mio = (Map<Id,Sobject>)key;
                    }
                    b = (mio != null && mio.containsKey(iid)) ? 
                        GetSObjectField(mio.get(iid), field) != t 
                        : true;
					// system.debug('3');
                } while (false);
                
                if (op == 'NOTCHANGED') {
                    b = !b;
                }
                return b;
            }
            else if(op == 'PATTERN' || op == 'REG' || op == 'REGEX' ){
                FieldPattern fp = new FieldPattern(field,key+'');
                return fp.fun(o);
            }
            else{
                return false;
            }
        }
    }
	
	class FieldNotEqual implements Lisq.IFilter
    {
        object key = null;
        string field = null;
        
        public FieldNotEqual(string field, object key){
            this.field = field;
            this.key = key;
        }
        
        public boolean fun(object o)
        {
            object obj = GetSObjectField(o, field);
            boolean b = null;
            if(obj == null && key == null){
                b = false;
            }
            else if(obj != null){
                b = !obj.equals(key);
            }
            else{
               b = !key.equals(obj);
            }
            system.debug('field('+field+')='+obj+',key='+key+',result='+b);
            return b;
        }
    }
    
    /**
     * 正则表达式匹配
     */
    class FieldPattern implements Lisq.IFilter
    {
        Pattern pttn = null;
        string field = null;
        
        public FieldPattern(string field, string pattern_str){
            this.field = field;
            pttn = Pattern.compile(pattern_str);
        }
        
        public boolean fun(object o)
        {
            object obj = GetSObjectField(o, field);
            Lisq.Log(obj);
            boolean b = null;
            if(obj == null ){
                b = false;
            }
            else{
                
                Matcher MyMatcher = pttn.matcher(obj+'');
               b = MyMatcher.find();
            }
            Lisq.Log(obj + ' match '+ b);
            return b;
        }
    }
    
    public class AndFilters implements Lisq.IFilter
    {
        List<Lisq.IFilter> filters = null;

        public AndFilters(Lisq.IFilter filter1,Lisq.IFilter filter2){
            this(filter1,filter2,null);
        }

        public AndFilters(Lisq.IFilter filter1,Lisq.IFilter filter2,Lisq.IFilter filter3){
            this(filter1,filter2,filter3,null);
        }

        public AndFilters(Lisq.IFilter filter1,Lisq.IFilter filter2,Lisq.IFilter filter3,Lisq.IFilter filter4){
            this(filter1,filter2,filter3,filter4,null);
        }

        public AndFilters(Lisq.IFilter filter1,Lisq.IFilter filter2,Lisq.IFilter filter3,Lisq.IFilter filter4,Lisq.IFilter filter5){
            filters = new List<Lisq.IFilter>();
            filters.add(filter1);
            filters.add(filter2);
            filters.add(filter3);
            filters.add(filter4);
            filters.add(filter5);
        }

        public AndFilters(List<Lisq.IFilter> filters){
            this.filters = filters;
        }

        public AndFilters(object[] parameters){
            this.filters = ParametersToFilters(parameters);
        }
        
        public boolean fun(object o){
            for(Lisq.IFilter filter : filters){
                if(filter!= null && !filter.fun(o)){
                    return false;
                }
            }
            return true;
        }
    }
    
    public class OrFilters implements Lisq.IFilter
    {
        List<Lisq.IFilter> filters = null;

        public OrFilters(Lisq.IFilter filter1,Lisq.IFilter filter2){
            filters = new List<Lisq.IFilter>();
            filtersadd(filter1);
            filtersadd(filter2);
        }

        public OrFilters(Lisq.IFilter filter1,Lisq.IFilter filter2,Lisq.IFilter filter3){
            this(filter1,filter2);
            filtersadd(filter3);
        }

        public OrFilters(Lisq.IFilter filter1,Lisq.IFilter filter2,Lisq.IFilter filter3,Lisq.IFilter filter4){
            this(filter1,filter2,filter3);
            filtersadd(filter4);
        }

        public OrFilters(Lisq.IFilter filter1,Lisq.IFilter filter2,Lisq.IFilter filter3,Lisq.IFilter filter4,Lisq.IFilter filter5){
            this(filter1,filter2,filter3,filter4);
            filtersadd(filter5);
        }
        
        private void filtersadd(Lisq.IFilter filter1) {
            if(filter1 != null) {
                filters.add(filter1);
            }
        }

        public OrFilters(List<Lisq.IFilter> filters){
            this.filters = filters;
        }

        public OrFilters(object[] parameters){
            this.filters = ParametersToFilters(parameters);
        }
        
        public boolean fun(object o){
            if(filters== null || filters.size() == 0) {
                return true;
            }
            
            for(Lisq.IFilter filter : filters){
                if(filter.fun(o)){
                    return true;
                }
            }
            
            return false;
        }
    }

    public class NotFilter implements Lisq.IFilter {

        Lisq.IFilter filter;
        public NotFilter(Lisq.IFilter filter) {
            this.filter = filter;
        }

        public boolean fun(object o){
            return !filter.fun(o);
        } 
    }

    static List<Lisq.IFilter> ParametersToFilters( object[] parameters )
    {
        List<Lisq.IFilter> ands = new List<Lisq.IFilter>();
        if (parameters == null || parameters.size() == 0) {
            return ands;
        }

        if (Math.mod(parameters.size(), 3) != 0) {
            System.debug('parameters\' size must be mod 3, skip');
            ands.add(new LisqUtils.BooleanFilter(false));
            return ands;
        }

        for (Integer i = 0; i < parameters.size(); i+=3) {
            object field_or_selecter = parameters[i];
            if (field_or_selecter instanceof Lisq.ISelect) {
                if (field_or_selecter == null) {
                    System.debug('field_or_selecter is blank, skip');
                    continue;
                }
                ands.add(new LisqUtils.FieldCompare((Lisq.ISelect)field_or_selecter,CommonUtils.GetStr(parameters[i+1]),parameters[i+2]));
            }
            else{
                string field = CommonUtils.GetStr(field_or_selecter);
                if (string.isBlank(field)) {
                    System.debug('field is blank, skip');
                    continue;
                }
                ands.add(new LisqUtils.FieldCompare(field,CommonUtils.GetStr(parameters[i+1]),parameters[i+2]));
            }
        }
        return ands;
    }
    
    /**
     * get sobject field value, support forign field if it was queried
     * e.g. GetSObjectField(lead_obj,'Owner.Name')
     */
    private static object GetSObjectField(object o,string f_str){
        return GetSObjectField((sobject)o,f_str);
    }
    
    private static object GetSObjectField(sobject o,string f_str){        
        return o.get(f_str);
    }    
}