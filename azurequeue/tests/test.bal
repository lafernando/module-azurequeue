// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/config;
import ballerina/test;
import ballerina/io;

Configuration config = {
    accessKey: config:getAsString("ACCESS_KEY"),
    account: config:getAsString("ACCOUNT")
};

Client queueClient = new(config);

@test:Config
function testCreateQueue() {
    var result = queueClient->createQueueIfNotExists("queuex1");
    if (result is error) {
        test:assertFail(msg = <string> result.detail().message);
    }
}

@test:Config {
    dependsOn: ["testCreateQueue"]
}
function testPutMessage() {
    var result = queueClient->putMessage("queuex1", "MSG1");
    if (result is error) {
        test:assertFail(msg = <string> result.detail().message);
    }
}

@test:Config {
    dependsOn: ["testPutMessage"]
}
function testGetMessages() {
    var result = queueClient->getMessages("queuex1");
    if (result is error) {
        test:assertFail(msg = <string> result.detail().message);
    } else {
        test:assertTrue(result.messages.length() == 1);
        test:assertTrue(result.messages[0].messageText == "MSG1");
    }
}

@test:Config {
    dependsOn: ["testGetMessages"]
}
function testDeleteMessage() {
    var pr = queueClient->putMessage("queuex1", "MSG2");
    if (pr is error) {
        test:assertFail(msg = <string> pr.detail().message);
    } else {
        var gr = queueClient->getMessages("queuex1", count = 2);
        if (gr is GetMessagesResult) {
            var dr = queueClient->deleteMessage("queuex1", gr.messages[0].messageId, gr.messages[0].popReceipt);
            if (dr is error) {
                test:assertFail(msg = <string> dr.detail().message);
            }
        } else {
            test:assertFail(msg = <string> gr.detail().message);     
        }
    }
}

@test:Config {
    dependsOn: ["testDeleteMessage"]
}
function testListQueues() {
    var result = queueClient->listQueues();
    if (result is error) {
        test:assertFail(msg = <string> result.detail().message);
    } else {
        test:assertTrue(result.queues.length() > 0);
    }
}

@test:Config {
    dependsOn: ["testListQueues"]
}
function testDeleteQueue() {
    var result = queueClient->deleteQueue("queuex1");
    if (result is error) {
        test:assertFail(msg = <string> result.detail().message);
    }
}


