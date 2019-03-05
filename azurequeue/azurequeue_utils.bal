//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
//

function decodeListQueuesXML(xml payload) returns ListQueueResult {
    QueueInfo[] queues = [];
    int index = 0;
    foreach var item in payload.Queues.Queue {
        if (item is xml) {
            QueueInfo queue = { name: item.Name.getTextValue() };
            queues[index] = queue;
            index = index + 1;
        }
    }
    ListQueueResult result = { queues: queues };
    return result;
}

function decodeGetMessagesXML(xml payload) returns GetMessagesResult|error {
    QueueMessage[] messages = [];
    int index = 0;
    foreach var item in payload.QueueMessage {
        if (item is xml) {
            QueueMessage message = { messageId: item.MessageId.getTextValue(), 
                                     messageText: item.MessageText.getTextValue(),
                                     popReceipt: item.PopReceipt.getTextValue(),
                                     insertionTime: item.InsertionTime.getTextValue(),
                                     expirationTime: item.ExpirationTime.getTextValue() };
            messages[index] = message;
            index = index + 1;
        }
    }
    GetMessagesResult result = { messages: messages };
    return result;
}

function decodePutMessageXML(xml payload) returns PutMessageResult|error {
    
    PutMessageResult result = { messageId: payload.QueueMessage.MessageId.getTextValue(),
                                popReceipt: payload.QueueMessage.PopReceipt.getTextValue(),
                                insertionTime: payload.QueueMessage.InsertionTime.getTextValue(),
                                expirationTime: payload.QueueMessage.ExpirationTime.getTextValue() };
    return untaint result;
}


