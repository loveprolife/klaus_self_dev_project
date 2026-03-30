public without sharing class CurrencyRateHelper {
    
    static Map<String, Sobject>  currencyMap = new LisqContainer([SELECT Id, IsoCode, ConversionRate, DecimalPlaces, IsActive, IsCorporate, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp FROM CurrencyType]).ToMapS('IsoCode');

    /**
     *@description 获取货币汇率，乘法用
     *@param	source	源货币
     *@param	target	目标货币
     *@return	Decimal	汇率
    */
    public static Decimal getConversionRate(String source, String target) {
        if (
            String.isBlank(source) || String.isBlank(target) 
            || source == target
            || !currencyMap.containsKey(source) || !currencyMap.containsKey(target)
        ) {
            return 1;
        }

        CurrencyType sType = (CurrencyType)currencyMap.get(source);
        CurrencyType tType = (CurrencyType)currencyMap.get(target);
        decimal d = sType.ConversionRate < 0.0000000000000001 ? 0 : tType.ConversionRate / sType.ConversionRate;
        System.debug(source + ' convert rate to ' + target + ' is ' + d);
        return d;
    }
}