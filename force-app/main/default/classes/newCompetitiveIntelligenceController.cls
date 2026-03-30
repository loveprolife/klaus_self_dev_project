public class newCompetitiveIntelligenceController {

    @AuraEnabled
    public static ConResponse getCompetitiveIntelligence(String recordId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        // List<Competitive_Intelligence_Brand__c> brandNameTotal = new List<Competitive_Intelligence_Brand__c>();
        List<Competitive_Intelligence_Brand__c> brandNameTotal;
        List<Competitive_Intelligence_Brand__c> brandNamePrice;
        
        // 查询对应的竞品信息
        List<Competitive_Intelligence__c> intelligence = getCompetitiveIntelligenceInfo(recordId);
        Competitive_Intelligence__c competitiveIntelligence;

        // 数据为空，初始化竞品信息
        if(intelligence != null && intelligence.size() > 0){
            competitiveIntelligence = intelligence.get(0);
        }else{
            Competitive_Intelligence__c comp = new Competitive_Intelligence__c();
            comp.Inspection_Product_Item__c = recordId;
            Database.insert(comp);

            competitiveIntelligence = comp;
        }

        // 查询竞品信息品牌统计数据
        List<Competitive_Intelligence_Brand__c> brandNameTotalData = getCompetitiveIntelligenceBrandInfo(competitiveIntelligence.Id,'Total');
        List<Competitive_Intelligence_Brand__c> brandNamePriceData = getCompetitiveIntelligenceBrandInfo(competitiveIntelligence.Id,'Price');

        if(brandNameTotalData != null && brandNameTotalData.size() > 0){
            brandNameTotal = brandNameTotalData;
        }

        if(brandNamePriceData != null && brandNamePriceData.size() > 0){
            brandNamePrice = brandNamePriceData;
        }

        // 根据当前id查询是否已上传附件
        List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : competitiveIntelligence.Id];
        if(cdlList != null && cdlList.size() > 0){
            mso.put('photosCompetitive', true);
        }else{
            mso.put('photosCompetitive', false);
        }

        mso.put('competitionIntelligenceInfo', competitiveIntelligence);
        mso.put('brandNameTotalOpenInfo', brandNameTotal);
        mso.put('brandNamePriceOpenInfo', brandNamePrice);

        return resp;
    }

    @AuraEnabled
    public static ConResponse getCompetitiveIntelligenceCanada(String recordId){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;
        
        // 查询对应的竞品信息
        List<Competitive_Intelligence__c> intelligence = getCompetitiveIntelligenceInfo(recordId);
        Competitive_Intelligence__c competitiveIntelligence;

        // 数据为空，初始化竞品信息
        if(intelligence != null && intelligence.size() > 0){
            competitiveIntelligence = intelligence.get(0);
        }else{
            Competitive_Intelligence__c comp = new Competitive_Intelligence__c();
            comp.Inspection_Product_Item__c = recordId;
            Database.insert(comp);

            // 通过查询获取币种编码
            competitiveIntelligence = getCompetitiveIntelligenceInfo(recordId).get(0);
        }

        // 查询竞品信息品牌统计数据
        List<Competitive_Intelligence_Brand__c> competitorsModelsData = getCompetitiveIntelligenceBrandInfo(competitiveIntelligence.Id,'Model');
        List<Competitive_Intelligence_Brand__c> performingBrandsData = getCompetitiveIntelligenceBrandInfo(competitiveIntelligence.Id,'Brand');

        // 初始化竞品信息关联品牌型号
        if(competitorsModelsData == null || competitorsModelsData.size() == 0){
            List<Competitive_Intelligence_Brand__c> modelList = new List<Competitive_Intelligence_Brand__c>();
            // 固定三条关联数据
            for (Integer i = 0; i < 3; i++) {
                Competitive_Intelligence_Brand__c model = new Competitive_Intelligence_Brand__c();
                model.Competitive_Intelligence__c = competitiveIntelligence.Id;
                model.Status__c = 'Model';
                modelList.add(model);
            }

            Database.insert(modelList);

            competitorsModelsData = modelList;
        }

        // 初始化竞品信息管理品牌
        if(performingBrandsData == null || performingBrandsData.size() == 0){
            List<Competitive_Intelligence_Brand__c> brandList = new List<Competitive_Intelligence_Brand__c>();
            // 固定三条关联数据
            for (Integer i = 0; i < 3; i++) {
                Competitive_Intelligence_Brand__c brand = new Competitive_Intelligence_Brand__c();
                brand.Competitive_Intelligence__c = competitiveIntelligence.Id;
                brand.Status__c = 'Brand';
                brandList.add(brand);
            }

            Database.insert(brandList);

            performingBrandsData = brandList;
        }

        // 根据当前id查询是否已上传附件
        List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : competitiveIntelligence.Id];
        if(cdlList != null && cdlList.size() > 0){
            mso.put('photosCompetitive', true);
        }else{
            mso.put('photosCompetitive', false);
        }

        mso.put('competitionIntelligenceInfo', competitiveIntelligence);
        mso.put('competitorsModelsInfo', competitorsModelsData);
        mso.put('performingBrandsInfo', performingBrandsData);

        return resp;
    }

    @AuraEnabled
    public static ConResponse  saveCompetitiveIntelligence(String competitionIntelligenceInfoJson,
                                            String brandNameTotalOpenInfoJson,String brandNamePriceOpenInfoJson,
                                            String brandNameTotalOpenDelJson,String brandNamePriceOpenDelJson){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        Competitive_Intelligence__c competitiveIntelligence = (Competitive_Intelligence__c)JSON.deserializeStrict(competitionIntelligenceInfoJson, Competitive_Intelligence__c.class);
        Database.upsert(competitiveIntelligence);
        System.debug('wwwwcompetitiveIntelligence' + JSON.serialize(competitiveIntelligence));

        // 处理数量相关的品牌信息
        List<Competitive_Intelligence_Brand__c> totalUpsert = new List<Competitive_Intelligence_Brand__c>();
        
        if(!String.isEmpty(brandNameTotalOpenInfoJson)){
            List<Competitive_Intelligence_Brand__c> brandTotal = (List<Competitive_Intelligence_Brand__c>)JSON.deserializeStrict(brandNameTotalOpenInfoJson, List<Competitive_Intelligence_Brand__c>.class);
            for(Competitive_Intelligence_Brand__c totalItem : brandTotal){
                // if(totalItem.Brand__c != '' && totalItem.Brand_Total__c != null){
                    
                // }
                if(String.isEmpty(totalItem.Id)){
                    totalItem.Competitive_Intelligence__c = competitiveIntelligence.Id;
                    totalItem.Status__c = 'Total';
                    totalUpsert.add(totalItem);
                }else if(!String.isEmpty(totalItem.Id)){
                    totalUpsert.add(totalItem);
                }
            }
            Database.upsert(totalUpsert);
        }

        System.debug('wwwwbrandTotal' + JSON.serialize(totalUpsert));

        // 处理价格相关的品牌信息
        List<Competitive_Intelligence_Brand__c> priceUpsert = new List<Competitive_Intelligence_Brand__c>();
        if(!String.isEmpty(brandNamePriceOpenInfoJson)){
            List<Competitive_Intelligence_Brand__c> brandPrice = (List<Competitive_Intelligence_Brand__c>)JSON.deserializeStrict(brandNamePriceOpenInfoJson, List<Competitive_Intelligence_Brand__c>.class);
            for(Competitive_Intelligence_Brand__c priceItem : brandPrice){
                // if(priceItem.Brand__c != '' && priceItem.Brand_Total__c != null){
                    
                // }
                if(String.isEmpty(priceItem.Id)){
                    priceItem.Competitive_Intelligence__c = competitiveIntelligence.Id;
                    priceItem.Status__c = 'Price';
                    priceUpsert.add(priceItem);
                }else if(!String.isEmpty(priceItem.Id)){
                    priceUpsert.add(priceItem);
                }
            }
            Database.upsert(priceUpsert);
        }
        System.debug('wwwwbrandPrice' + JSON.serialize(priceUpsert));
        
        List<Competitive_Intelligence_Brand__c> brandTotalDel = (List<Competitive_Intelligence_Brand__c>)JSON.deserializeStrict(brandNameTotalOpenDelJson, List<Competitive_Intelligence_Brand__c>.class);
        
        // 存放满足删除条件的数据
        List<Competitive_Intelligence_Brand__c> brandTotalDelList = new List<Competitive_Intelligence_Brand__c>();
        if(brandTotalDel != null && brandTotalDel.size() > 0){
            for(Competitive_Intelligence_Brand__c item : brandTotalDel){
                if(item.Id != null){
                    brandTotalDelList.add(item);
                }
            }
            Database.delete(brandTotalDelList);
        }

        System.debug('wwwwwbrandTotalDelList' + JSON.serialize(brandTotalDelList));

        List<Competitive_Intelligence_Brand__c> brandPriceDel = (List<Competitive_Intelligence_Brand__c>)JSON.deserializeStrict(brandNamePriceOpenDelJson, List<Competitive_Intelligence_Brand__c>.class);
        // 存放满足删除条件的数据
        List<Competitive_Intelligence_Brand__c> brandPriceDelList = new List<Competitive_Intelligence_Brand__c>();
        if(brandPriceDel != null && brandPriceDel.size() > 0){
            for(Competitive_Intelligence_Brand__c item : brandPriceDel){
                if(item.Id != null){
                    brandPriceDelList.add(item);
                }
            }
            Database.delete(brandPriceDelList);
        }

        System.debug('wwwwwbrandPriceDelList' + JSON.serialize(brandPriceDelList));
        
        return resp;
    }

    @AuraEnabled
    public static ConResponse  saveCompetitiveIntelligenceCanada(String competitionIntelligenceInfoJson,
                                            String competitorsModelsInfoJson,
                                            String performingBrandsInfoJson){
        ConResponse resp = new ConResponse();
        Map<String, Object> mso = new Map<String, Object>();
        resp.data = mso;

        Competitive_Intelligence__c competitiveIntelligence = (Competitive_Intelligence__c)JSON.deserializeStrict(competitionIntelligenceInfoJson, Competitive_Intelligence__c.class);
        Database.upsert(competitiveIntelligence);
        System.debug('wwwwcompetitiveIntelligence' + JSON.serialize(competitiveIntelligence));

        // 处理数量相关的品牌信息
        List<Competitive_Intelligence_Brand__c> totalUpsert = (List<Competitive_Intelligence_Brand__c>)JSON.deserializeStrict(competitorsModelsInfoJson, List<Competitive_Intelligence_Brand__c>.class);
        Database.upsert(totalUpsert);

        // 处理价格相关的品牌信息
        List<Competitive_Intelligence_Brand__c> brandUpsert = (List<Competitive_Intelligence_Brand__c>)JSON.deserializeStrict(performingBrandsInfoJson, List<Competitive_Intelligence_Brand__c>.class);
        Database.upsert(brandUpsert);
        
        return resp;
    }

    // 查询当前日报产品线竞品信息已检查数和检查总数
    public static Map<String,Integer> getCompetitiveIntelligenceCheckNumber(String recordId){

        Map<String,Integer> check = new Map<String,Integer>();

        // 根据日报产品线id查询竞品信息
        List<Competitive_Intelligence__c> competitive = getCompetitiveIntelligenceInfo(recordId);
        Integer checkNumber = 0;
        if(competitive != null && competitive.size() > 0){
            Competitive_Intelligence__c intelligence = competitive.get(0);

            // Total_Number_Of_Competitors__c
            if(!String.isEmpty(intelligence.Total_Number_Of_Competitors__c)){
                if(Integer.valueOf(intelligence.Total_Number_Of_Competitors__c) >= 0){
                    ++checkNumber;
                }
            }
            System.debug('wwwwwIntelligence.Total_Number_Of_Competitors__c' + intelligence.Total_Number_Of_Competitors__c);
            // 判断问题答案是否空，计算已检查项
            if(!String.isEmpty(intelligence.Competitive_Brand__c)){
                ++checkNumber;
            }

            if(!String.isEmpty(intelligence.Competition_Something__c)){
                ++checkNumber;
            }

            // 根据当前id查询是否已上传附件
            List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : intelligence.Id];
            if(cdlList != null && cdlList.size() > 0){
                ++checkNumber;
            }

            List<Competitive_Intelligence_Brand__c> brandNameTotal = getCompetitiveIntelligenceBrandInfo(intelligence.Id,'Total');
            if(brandNameTotal != null && brandNameTotal.size() > 0){
                Boolean isAddNumber = false;
                for(Competitive_Intelligence_Brand__c item : brandNameTotal){
                    if(!String.isEmpty(item.Brand__c) && !String.isEmpty(item.Brand_Total__c)){
                        isAddNumber = true;
                    }else{

                        // 如果存在空数据跳出循环
                        isAddNumber = false;
                        break;
                    }
                }

                if(isAddNumber){
                    ++checkNumber;
                }
                
            }

            List<Competitive_Intelligence_Brand__c> brandNamePrice = getCompetitiveIntelligenceBrandInfo(intelligence.Id,'Price');
            if(brandNamePrice != null && brandNamePrice.size() > 0){
                Boolean isAddNumber = false;
                for(Competitive_Intelligence_Brand__c item : brandNamePrice){
                    if(!String.isEmpty(item.Brand__c) && !String.isEmpty(item.Brand_Total__c)){
                        isAddNumber = true;
                    }else{
                        // 如果存在空数据跳出循环
                        isAddNumber = false;
                        break;
                    }
                }

                if(isAddNumber){
                    ++checkNumber;
                }
            }
        }

        check.put('checkTotal', 6);
        check.put('checkNumber', checkNumber);

        return check;
    }

    // 查询当前日报产品线竞品信息已检查数和检查总数
    public static Map<String,Integer> getCompetitiveIntelligenceCheckCanadaNumber(String recordId){

        Map<String,Integer> check = new Map<String,Integer>();

        // 根据日报产品线id查询竞品信息
        List<Competitive_Intelligence__c> competitive = getCompetitiveIntelligenceInfo(recordId);
        Integer checkNumber = 0;
        if(competitive != null && competitive.size() > 0){
            Competitive_Intelligence__c intelligence = competitive.get(0);

            System.debug('wwwwwIntelligence.Total_Number_Of_Competitors__c' + intelligence.Total_Number_Of_Competitors__c);
            // 判断问题答案是否空，计算已检查项
            if(!String.isEmpty(intelligence.Competitor_Activities__c)){
                ++checkNumber;
            }

            // 根据当前id查询是否已上传附件
            List<ContentDocumentLink> cdlList = [SELECT Id,ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = : intelligence.Id];
            if(cdlList != null && cdlList.size() > 0){
                ++checkNumber;
            }

            List<Competitive_Intelligence_Brand__c> modelList = getCompetitiveIntelligenceBrandInfo(intelligence.Id,'Model');
            if(modelList != null && modelList.size() > 0){
                Boolean isAddNumber = false;
                for(Competitive_Intelligence_Brand__c item : modelList){
                    if(!String.isEmpty(item.Brand__c) && !String.isEmpty(item.Model__c) && !String.isEmpty(item.Price__c)){
                        isAddNumber = true;
                    }else{

                        // 如果存在空数据跳出循环
                        isAddNumber = false;
                        break;
                    }
                }

                if(isAddNumber){
                    ++checkNumber;
                }
                
            }

            List<Competitive_Intelligence_Brand__c> brandList = getCompetitiveIntelligenceBrandInfo(intelligence.Id,'Brand');
            if(brandList != null && brandList.size() > 0){
                Boolean isAddNumber = false;
                for(Competitive_Intelligence_Brand__c item : brandList){
                    if(!String.isEmpty(item.Brand__c)){
                        isAddNumber = true;
                    }else{
                        // 如果存在空数据跳出循环
                        isAddNumber = false;
                        break;
                    }
                }

                if(isAddNumber){
                    ++checkNumber;
                }
            }
        }

        check.put('checkTotal', 4);
        check.put('checkNumber', checkNumber);

        return check;
    }

    public static List<Competitive_Intelligence__c> getCompetitiveIntelligenceInfo(String recordId){
        return [SELECT Id,
                       CurrencyIsoCode,
                       Inspection_Product_Item__c,
                       Competitive_Brand__c,
                       Total_Number_Of_Competitors__c,
                       Competition_Something__c,
                       Photos_Competitive__c,
                       Competitor_Activities__c
                       FROM Competitive_Intelligence__c
                       WHERE Inspection_Product_Item__c =: recordId];
    }

    public static List<Competitive_Intelligence_Brand__c> getCompetitiveIntelligenceBrandInfo(String intelligenceId,String status){
        return [SELECT Id,
                       Brand__c,
                       Brand_Total__c,
                       Competitive_Intelligence__c,
                       Status__c,
                       Model__c,
                       Price__c
                       FROM Competitive_Intelligence_Brand__c
                       WHERE Competitive_Intelligence__c =: intelligenceId
                       AND Status__c =: status];
    }

}