Connects to Azure Queue service through Ballerina.

# Module Overview

## Compatibility
| Ballerina Language Version 
| -------------------------- 
| 0.990.0                    

## Sample

```ballerina
import ballerina/config;
import ballerina/io;
import wso2/azurequeue;

azurequeue:Configuration config = {
    accessKey: config:getAsString("ACCESS_KEY"),
    account: config:getAsString("ACCOUNT")
};

azurequeue:Client queueClient = new(config);

public function main(string... args) {
}
```
