global class SAPGetFOBSchedulable implements Schedulable {

    global void execute(SchedulableContext sc) {
        
        SAPGetFOB.getFOBFromSAP(System.now().format('yyyyMMdd'));
    }
}