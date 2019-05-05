Connects to Azure Queue service through Ballerina.

# Module Overview

## Compatibility
| Ballerina Language Version 
| -------------------------- 
| 0.991.0                    

## Sample

```ballerina
import ballerina/config;
import ballerina/io;
import wso2/azurequeue;

azurequeue:Configuration config = {
    accessKey: config:getAsString("ACCESS_KEY2"),
    account: config:getAsString("ACCOUNT2")
};

azurequeue:Client queueClient = new(config);

public function main(string... args) returns error? {
    check queueClient->createQueueIfNotExists("queue1");
    check queueClient->putMessage("queue1", "MSG1");
    var result = queueClient->getMessages("queue1");
    if (result is azurequeue:GetMessagesResult) {
        io:println(result);
        check queueClient->deleteMessage("queue1", result.messages[0].messageId, result.messages[0].popReceipt);
    }
}
```
