/**
 * @description       : 
 * @author            : chenpeng@deloitte.com.cn
 * @group             : 
 * @last modified on  : 03-20-2022
 * @last modified by  : chenpeng@deloitte.com.cn
**/
public with sharing class ShopSalesDataCreateController {
    @AuraEnabled
    public static columnsData getcolumnsData() {
        columnsData cd = new columnsData();
        List<hisenseColumns> hisenseColumnsList = new List<hisenseColumns>();
        hisenseColumns hisenseColumns1 = new hisenseColumns();
        hisenseColumns1.hisense1 = 'OLED4K';
        hisenseColumns1.hisense2 = '10000.00';
        hisenseColumns1.hisense3 = '9900.00';
        hisenseColumns1.hisense4 = '9900.00';
        hisenseColumns1.hisense5 = '9800.00';
        hisenseColumns1.hisense6 = '90%';
        hisenseColumns1.hisense7 = 'Homeplus本石町店';
        hisenseColumnsList.add(hisenseColumns1);
        
        List<competingColumns> competingColumnsList = new List<competingColumns>();
        competingColumns competingColumns1 = new competingColumns();
        competingColumns1.competing1 = 'OLED4K';
        competingColumns1.competing2 = '11000.00';
        competingColumns1.competing3 = '9900.00';
        competingColumns1.competing4 = '9900.00';
        competingColumns1.competing5 = '9800.00';
        competingColumns1.competing6 = '89%';
        competingColumns1.competing7 = 'Homeplus本石町店';
        competingColumnsList.add(competingColumns1);

        cd.competingColumnsList = competingColumnsList;
        cd.hisenseColumnsList = hisenseColumnsList;
        return cd;
    }

    /**
    * @description 长文本换行
    * @author chenpeng@deloitte.com.cn | 09-27-2021 
    * @param str 
    * @param num 
    * @param issegmentation 
    * @return String 
    **/
    @AuraEnabled
    public static String ConvertString(String str, Integer num) {
        List<String> proDecList = new List<String>();
        if (String.isBlank(str)) {
            return '';
        }
        proDecList.add(str);

        String converStr = '';
        for (String proDec : proDecList) {
            String strword = proDec;
            Decimal leng = 0;
            String tmp = '';
            Integer j = 1;
            Integer k = 0;
            Decimal z = num;
            
            for (Integer i=0; i < strword.length(); i++) {
                if ((strword.charAt(i) >= 19968 && 
                    strword.charAt(i) <= 171941) || 
                    (strword.charAt(i) == 64) || 
                    (strword.charAt(i) == 12289)) {
                      leng = leng + 2;
                } else if (strword.charAt(i) == 109) {
                    leng = leng + 1.5;
                } else if ((strword.charAt(i) >= 60 && strword.charAt(i) <= 122 ) ){
                    leng = leng + 1.6;
                } else if ((strword.charAt(i) == 49) || 
                           (strword.charAt(i) == 105) || 
                           (strword.charAt(i) == 106) || 
                           (strword.charAt(i) == 108)  || 
                           (strword.charAt(i) == 116)){
                    leng = leng + 0.6;
                }
                  else if ((strword.charAt(i) == 46) || (strword.charAt(i) == 58)){
                    leng = leng + 0.4;
                } else if (strword.charAt(i) >= 48 && strword.charAt(i) <= 57){
                    leng = leng + 1.1;
                } else if (strword.charAt(i) == 95){
                    leng = leng + 1;
                } else {
                    leng = leng + 1.1;
                }

                //如果数据大与给定的Number增加<br/>
                if (leng >= z){     
                    tmp = tmp + strword.mid(k,j) + '\n';
                    leng = 0;
                    j = 0;
                    k = i+1;
                }

                
                if (i == (strword.length() - 1)) {
                    tmp = tmp + strword.mid(k,j+1);
                }

                // if (issegmentation) {
                //     String w = strword.substring(i, i+1);
                //     String reg =';';
                //     if(w==reg){
                //         tmp = tmp + strword.mid(k,j) + '\n';
                //         leng = 0;
                //         j = 0;
                //         k = i+1;
                //     }
                // }

                j++;
            }
            converStr += tmp;
        }

        return converStr;
    }

    public class columnsData{
        @AuraEnabled public List<hisenseColumns> hisenseColumnsList;
        @AuraEnabled public List<competingColumns> competingColumnsList;
        @AuraEnabled public String test;
    }

    public class hisenseColumns{
        @AuraEnabled public String hisense1; 
        @AuraEnabled public String hisense2; 
        @AuraEnabled public String hisense3; 
        @AuraEnabled public String hisense4; 
        @AuraEnabled public String hisense5; 
        @AuraEnabled public String hisense6; 
        @AuraEnabled public String hisense7; 
    }

    public class competingColumns{
        @AuraEnabled public String competing1; 
        @AuraEnabled public String competing2; 
        @AuraEnabled public String competing3; 
        @AuraEnabled public String competing4; 
        @AuraEnabled public String competing5; 
        @AuraEnabled public String competing6; 
        @AuraEnabled public String competing7; 
    }
}