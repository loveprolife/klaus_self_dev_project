@isTest
public class MapResponseTest {
	@isTest
    static void Test1() {
        MapResponse mr = new MapResponse();
        mr.put('data', new Account());
        if(mr.containsKey('data') && mr.isSuccess){
            mr.get('data');
        }
    }
}