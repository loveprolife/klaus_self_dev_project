global with sharing abstract class LinkedListBatch implements Database.Batchable<sObject>, Database.stateful{
    
    global Database.Batchable<sObject> nextBatch = null;

    global virtual void finish(Database.BatchableContext BC) {
        if (nextBatch != null) {
            Database.executeBatch(nextBatch);
        }
    }

    global static void executeBatches(LinkedListBatch[] batches) {
        if (batches == null || batches.size() == 0) {
            return;
        }

        for (Integer i = 0; i < batches.size(); i++) {
            if (i + 1 < batches.size()) {
                batches.get(i).nextBatch = batches.get(i + 1);
            }
        }

        Database.executeBatch(batches.get(0));
    }
}