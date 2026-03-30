public without sharing class OandMScript {
    public static void DeleteInspectorDailyReport(String recordString, Boolean isDelete) {
        try {
            Daily_Inspection_Report__c record = [SELECT Id, Name, Store__c, Store__r.Name, Report_Date__c, OwnerId, Owner.Name FROM Daily_Inspection_Report__c WHERE Id = :recordString OR Name = :recordString LIMIT 1];
            if (record==null) {
                system.debug('Inspector Report does not exist');
                return;
            }
            if (!PhaseIIIUtility.isPhaseIIIData(record.Id)) {
                system.debug('Inspector Report is not South Africa/Indonesia/Chile data');
                return;
            }

            System.debug('Inspection Report Info');
            System.debug('  Id ---------->'+record.Id);
            System.debug('  Name -------->'+record.Name);
            System.debug('  StoreId ----->'+record.Store__c);
            System.debug('  StoreName --->'+record.Store__r.Name);
            System.debug('  ReportDate -->'+record.Report_Date__c);
            System.debug('  OwnerId ----->'+record.OwnerId);
            System.debug('  OwnerName --->'+record.Owner.Name);
            System.debug('=============================================');

            List<Sampling_Inspection__c> siList = [SELECT Id, Name, Shop__c, Shop__r.Name, Inspection_Date__c, OwnerId, Owner.Name FROM Sampling_Inspection__c WHERE Shop__c = :record.Store__c AND Inspection_Date__c = :record.Report_Date__c AND OwnerId = :record.OwnerId];
            if (siList.size()==0) {
                System.debug('Sampling Inspection Size : '+'0');
            } else {
                System.debug('Sampling Inspection Size : '+siList.size());
                System.debug('↓↓↓ Sampling Inspection Info ↓↓↓');
                System.debug('--------------------------------');
                Integer i = 1;
                for (Sampling_Inspection__c si : siList) {
                    System.debug('Info '+i);
                    System.debug('  Id -------------->'+si.Id);
                    System.debug('  Name ------------>'+si.Name);
                    System.debug('  StoreId --------->'+si.Shop__c);
                    System.debug('  StoreName ------->'+si.Shop__r.Name);
                    System.debug('  InspectionDate -->'+si.Inspection_Date__c);
                    System.debug('  OwnerId --------->'+si.OwnerId);
                    System.debug('  OwnerName ------->'+si.Owner.Name);
                    System.debug('--------------------------------');
                    i++;
                }
            }

            if (isDelete) {
                delete record;
                System.debug('Deleted Inspection Report');
                if (siList.size()>0) {
                    delete siList;
                    System.debug('Deleted Sampling Inspection');
                }
            } else {
                System.debug('To confirm deletion, please enter the True command');
            }

        } catch (Exception e) {
            System.debug('The input parameter is wrong, please confirm that the input parameter is Inspection Report Id/Name and True/False');
        }
    }
}