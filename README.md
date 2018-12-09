# Ballerina Azure Queue Service Connector

This connector allows to use the Azure Queue service through Ballerina. The following section provide you the details on connector operations.

## Compatibility
| Ballerina Language Version 
| -------------------------- 
| 0.990.0                    


The following sections provide you with information on how to use the Azure Queue Service Connector.

- [Contribute To Develop](#contribute-to-develop)
- [Working with Azure Queue Service Connector actions](#working-with-azure-queue-service-connector)
- [Sample](#sample)

### Contribute To develop

Clone the repository by running the following command 
```shell
git clone https://github.com/lafernando/module-azurequeue.git
```

### Working with Azure Queue Service Connector

First, import the `wso2/azurequeue` module into the Ballerina project.

```ballerina
import wso2/azurequeue;
```

In order for you to use the Azure Queue Service Connector, first you need to create an Azure Queue Service Connector client.

```ballerina
azurequeue:Configuration config = {
    accessKey: config:getAsString("ACCESS_KEY"),
    account: config:getAsString("ACCOUNT")
};

azurequeue:Client queueClient = new(config);
```

##### Sample

```ballerina
import ballerina/config;
import ballerina/io;
import wso2/azurequeue;

azurequeue:Configuration config = {
    accessKey: config:getAsString("ACCESS_KEY2"),
    account: config:getAsString("ACCOUNT2")
};

azurequeue:Client queueClient = new(config);

public function main(string... args) {
    _ = queueClient->createQueueIfNotExists("queue1");
    _ = queueClient->putMessage("queue1", "MSG1");
    var result = queueClient->getMessages("queue1");
    if (result is azurequeue:GetMessagesResult) {
        io:println(result);
        _ = queueClient->deleteMessage("queue1", result.messages[0].messageId, result.messages[0].popReceipt);
    }
}
```
