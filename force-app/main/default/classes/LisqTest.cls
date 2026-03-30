@isTest
public class LisqTest {
	@isTest
    static void TestAllFun(){
        Datetime dt = Datetime.now();

        List<Lead> la = new List<lead>(new lead[]
        {
            new Lead(DoNotCall = true,Title='abc'),
                new Lead(DoNotCall = false,NumberOfEmployees = 1,Title='abc'),
                new Lead(DoNotCall = false,NumberOfEmployees = 2,Title='abc'),
                new Lead(DoNotCall = true,NumberOfEmployees = 3,Title='abc')
        });
        
        Lisq.All(la, new LisqUtils.FieldCompare('Id','NotBlank',''));
        Lisq.All(la, new LisqUtils.FieldCompare('Id','IsBlank',''));
        LisqHelper.ToMap(la, 'Id');
        Lisq.ToMap(la, new LisqUtils.SObjectSelectField('Id'));
        Lisq.Distinct(la);
        LisqHelper.ToS(LisqHelper.ToIds(la));
        LisqHelper.ToIds(la);
        system.debug(Lisq.Filter(la,new LisqUtils.FieldCompare('DoNotCall','=',true)));
        system.debug(la);
        system.debug(LisqHelper.Sum(la, 'NumberOfEmployees'));
        system.debug(LisqHelper.Average(la, 'NumberOfEmployees'));
        system.debug(Lisq.Filter(la, new LisqUtils.FieldCompare('NumberOfEmployees','>=',3)));
        string s ='fds';
        Pattern p = Pattern.compile('fds');
    }
    
    
    @isTest
    static void TestSort1(){
        List<integer> li = new List<integer>{1,2,5,6,4,3};
        Lisq.OrderByDesc(li);
        Lisq.AllMatch(li, new List<integer>{1,3,2,5,6,4});
        LisqHelper.OrderByDesc(li);
    }
    
    @isTest
    static void TestSort2(){
        Datetime dt = Datetime.now();

        List<Lead> la = new List<lead>(new lead[]
        {
            new Lead(DoNotCall = true,Title='abc'),
                new Lead(DoNotCall = false,NumberOfEmployees = 100,Title='abc'),
                new Lead(DoNotCall = false,NumberOfEmployees = 200,Title='abc'),
                new Lead(DoNotCall = true,NumberOfEmployees = 300,Title='abc')
        });
        
        LisqHelper.GroupByS(la, 'Name');
        LisqHelper.ToMapS(la, 'Name');
        system.debug(Lisq.Filter(la, 
                                 new LisqUtils.AndFilters(new Lisq.IFilter[]{
                                     new LisqUtils.FieldCompare('NumberOfEmployees','>=',10)
                                         ,new LisqUtils.FieldCompare('NumberOfEmployees','<',1000)
                                         ,new LisqUtils.FieldCompare('NumberOfEmployees','=',100)
                                         ,new LisqUtils.FieldCompare('NumberOfEmployees','!=',50)
                                         })));
        system.debug(Lisq.Filter(la, 
        new LisqUtils.AndFilters(
            new LisqUtils.FieldCompare('NumberOfEmployees','>=',10)
                ,new LisqUtils.FieldCompare('NumberOfEmployees','<',1000)
                )));
        system.debug(Lisq.Filter(la, 
                                 new LisqUtils.OrFilters(new Lisq.IFilter[]{
                                     new LisqUtils.FieldCompare('NumberOfEmployees','=',100)
                                         ,new LisqUtils.FieldCompare('NumberOfEmployees','<',20)
                                         })));

    }
    
    @isTest
    static void TestSort3(){

        Datetime dt = Datetime.now();

        List<Lead> la = new List<lead>(new lead[]
        {
            new Lead(DoNotCall = true,Title='abc'),
                new Lead(DoNotCall = false,NumberOfEmployees = 100,City = 'asd',Title='abc'),
                new Lead(DoNotCall = false,NumberOfEmployees = 200,City = 'asdfds',Title='abc'),
                new Lead(DoNotCall = true,NumberOfEmployees = 300,City = 'asdwe',Title='abc')
        });

        LisqContainer lc = new LisqContainer(la);
        lc.ToIds();
        lc.GroupByS(new LisqUtils.SObjectSelectField('Title'));
        lc.ToSobjectList();
        lc.OrderBy('NumberOfEmployees');
        lc.OrderByDesc('NumberOfEmployees');
        lc.SelectField('NumberOfEmployees').ToS();
        lc.SelectField('NumberOfEmployees',new object[]{
            'DoNotCall','=',true
        }).ToS();
        lc.SelectField('NumberOfEmployees',new LisqUtils.BooleanFilter(true)).ToS();
        lc.GroupByS('City');
        lc.ToMapS('City');
    }
    
    @isTest
    static void Test4()
    {
        List<Lead> la = new List<lead>(new lead[]
        {
            new Lead(DoNotCall = true,LastName='qwe',Title='abc'),
                new Lead(DoNotCall = false,LastName='asd',NumberOfEmployees = 1,Title='abc'),
                new Lead(DoNotCall = false,LastName='zxc',NumberOfEmployees = 3,Title='abc'),
                new Lead(DoNotCall = true,LastName='rty',NumberOfEmployees = 2,Title='abc')
        });
        system.debug(LisqHelper.OrderByDesc(la, 'NumberOfEmployees'));
        system.debug(LisqHelper.OrderBy(la, 'NumberOfEmployees'));
        system.debug(la);
    }
    
    
    
    @isTest
    static void test6()
    {
        List<Lead> la1 = new List<lead>(new lead[]
        {
            new Lead(DoNotCall = true,LastName='qwe',Company='sadsa',Title='abc'),
                new Lead(DoNotCall = false,LastName='asd',NumberOfEmployees = 1,Company='sadsa',Title='abc'),
                new Lead(DoNotCall = false,LastName='zxc',NumberOfEmployees = 3,Company='sadsa1',Title='abc'),
                new Lead(DoNotCall = true,LastName='rty',NumberOfEmployees = 2,Company='sadsa2',Title='abc')
        });
        
        List<Lead> la2 = new List<lead>(new lead[]
        {
            new Lead(DoNotCall = true,LastName='qwe',Company='sadsa',Title='abc'),
                new Lead(DoNotCall = false,LastName='asd',NumberOfEmployees = 1,Company='sadsa',Title='abc'),
                new Lead(DoNotCall = false,LastName='zxc',NumberOfEmployees = 3,Company='sadsa',Title='abc'),
                new Lead(DoNotCall = true,LastName='rty',NumberOfEmployees = 2,Company='sadsa',Title='abc')
        });
        LisqContainer lc = new LisqContainer(la1);
        
        // la1的Company字段在la2中
        lc.Filter(new LisqUtils.InList(la2));
        
        //Lisq.OrderByDesc(la1,new LisqUtils.ObjectComparable('NumberOfEmployees'));
    }

    @isTest
    static void Test7(){

        List<Lead> leadlist = new List<lead>{
            new Lead(Id='00QN000000ARO4nMAH',DoNotCall = true,NumberOfEmployees = 0,Title='abc'),
            new Lead(Id='00QN000000ARO4nMBH',DoNotCall = false,NumberOfEmployees = 1,City = 'asd',Title='bcd'),
            new Lead(Id='00QN000000ARO4nMCH',DoNotCall = false,NumberOfEmployees = 2,City = 'asdfds',Title='cde'),
            new Lead(Id='00QN000000ARO4nMDH',DoNotCall = true,NumberOfEmployees = 4,City = 'asdwe',Title='def'),
            new Lead(Id='00QN000000ARO4nMEH',DoNotCall = true,NumberOfEmployees = 8,City = 'asdwe',Title='efg'),
            new Lead(Id='00QN000000ARO4nMFH',DoNotCall = true,NumberOfEmployees = 16,City = 'asdwe',Title='fgh')
        };

        List<Lead> leadlist2 = new List<lead>{
            new Lead(Id='00QN000000ARO4nMEH',DoNotCall = true,NumberOfEmployees = 8,City = 'Shanghai',Title='efg'),
            new Lead(Id='00QN000000ARO4nMFH',DoNotCall = true,NumberOfEmployees = 16,City = 'asdwe',Title='fgh')
        };

        LisqContainer lc = new LisqContainer(leadlist);

        LisqContainer temp = lc.WhereOne('NumberOfEmployees', '<', 8);//在leadlist中找出NumberOfEmployees小于8的所有lead
        System.debug(temp);
        System.assertEquals(4, temp.Size());


        temp = lc.WhereOne('City', 'IsChanged', new Map<Id,Lead>(leadlist2));//在leadlist中找出City发生改变的lead
        System.debug(temp);
        System.assertEquals(5, temp.Size());

        temp = lc.WhereOne('City', 'NotChanged', new Map<Id,Lead>(leadlist2));//在leadlist中找出City发生改变的lead
        System.debug(temp);
        System.assertEquals(1, temp.Size());

        // 找出leadlist中同时满足以下条件
        // NumberOfEmployees小于等于16，Title
        // City在new string[]{'ac'}中
        // City非空
        // Title的值按照正则表达式c能匹配
       temp = lc.WhereAnd(new object[]{
            'NumberOfEmployees','<=',16,
            'City','in',new string[]{'asdwe'},
            'City','NotBlank','',
            'Title','REGEX','e'
        });
        
        System.debug(temp);
        System.assertEquals(2, temp.Size());

        // 找出NumberOfEmployees大于10或City是空的元素
        temp = lc.WhereOr(new object[]{
            'City','IsBlank','',
            'Title','=','efg',
			'NumberOfEmployees', '>', 10             
        });
		System.debug(temp);
        System.assertEquals(3, temp.Size());
        

        // 找出leadlist中满足以下条件
        // (NumberOfEmployees>=1 && DoNotCall) || string.IsNotBlank(City) || (new string[]{'ac'}).contains(Title)
        temp = lc.WhereCustom(new LisqUtils.OrFilters(
            new LisqUtils.AndFilters(new Object[]{
                'NumberOfEmployees','>=',1,
                'DoNotCall','=',true
            }),
            new LisqUtils.FieldCompare('City','NotBlank',''),
            new LisqUtils.FieldCompare('Title','in',new string[]{'def','efg'})
        ));
        System.debug(temp);
        System.assertEquals(5, temp.Size());

        // 找出leadlist中满足以下条件
        // (NumberOfEmployees!=16 || DoNotCall) && string.IsNotBlank(City) && !((new string[]{'ac'}).contains(Title))
        temp = lc.WhereCustom(new LisqUtils.AndFilters(
            new LisqUtils.OrFilters(new Object[]{
                'NumberOfEmployees','!=',16,
                'City','!=','asdwe'
            }),
            new LisqUtils.FieldCompare('City','NotBlank',''),
            new LisqUtils.FieldCompare('Title','NotIn',new string[]{'bcd','cde'})
        ));
        
        System.debug(temp);
        System.assertEquals(2, temp.Size());

        // this is fault example
        System.debug(lc.WhereOr(new object[]{
            'NumberOfEmployees','>',100,
            'Title','REGEX'
        }));

        temp = lc.Where1('NumberOfEmployees', '>', 2)
                .SelectField('NumberOfEmployees')
                .OrderBy();
        System.assertEquals('4,8,16', String.join(temp.Source, ','));
        
    }
}