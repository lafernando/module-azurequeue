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

import ballerina/http;

# Object to initialize the connection with Azure Queue Service.
#
# + accessKey - The Azure access key
# + account   - The Azure container account name
public type Client client object {

    public string accessKey;
    public string account;

    public function __init(Configuration config) {
        self.accessKey = config.accessKey;
        self.account = config.account;
    }

    # Lists all the queues in the current account.
    # + return - If successful, returns `ListQueueResult`, else returns an `error` value
    public remote function listQueues() returns ListQueueResult|error;

    # Creates a queue if it doesn't exists already.
    # + queue - The queue name
    # + return - If successful, returns `()`, else returns an `error` object
    public remote function createQueueIfNotExists(string queue) returns error?;

    # Deletes a queue.
    # + queue - The queue name
    # + return - If successful, returns `()`, else returns an `error` object
    public remote function deleteQueue(string queue) returns error?;

    # Adds a message to a given queue, where the message lives forever by default.
    # + queue - The queue name
    # + message - The message
    # + ttlSeconds - The time-to-live value in seconds for a message to live in the queue, 
    #                the default value of -1 represents infinity
    # + return - If successful, returns `PutMessageResult`, else returns an `error` object
    public remote function putMessage(string queue, string message, 
                                      int ttlSeconds = -1) returns PutMessageResult|error;

    # Gets messages from a given queue.
    # + queue - The queue name
    # + count - The number of messages to retrieve from the queue, the default is 1
    # + visibilityTimeoutSecs - The visibility timeout in seconds, the default is 30
    # + return - If successful, returns `GetMessagesResult`, else returns an `error` object
    public remote function getMessages(string queue, int count = 1, 
                                       int visibilityTimeoutSecs = -1) returns GetMessagesResult|error;

    # Deletes a message in a queue.
    # + queue - The queue name
    # + messageId - The message id
    # + popReceipt - The popReceipt value returned from an earlier `getMessages` operation
    # + return - If successful, returns `()`, else returns an `error` object
    public remote function deleteMessage(string queue, string messageId, string popReceipt) returns error?;

};

remote function Client.listQueues() returns ListQueueResult|error {
    http:Client clientEP = new("https://" + self.account + "." + AZURE_QUEUE_SERVICE_DOMAIN);
    string verb = "GET";
    map<string> headers = generateCommonHeaders();
    string canonicalizedResource = "/" + check http:encode(self.account, "UTF8") + "/?comp=list";
    populateAuthorizationHeader(self.account, self.accessKey, canonicalizedResource, verb, headers);

    http:Request req = new;
    populateRequestHeaders(req, headers);

    var resp = clientEP->get("/?comp=list", message = req);

    if (resp is http:Response) {
        int statusCode = resp.statusCode;
        if (statusCode != http:OK_200) {
            return generateError(resp);
        }
        return decodeListQueuesXML(check resp.getXmlPayload());
    } else {
        return resp;
    }
}

remote function Client.createQueueIfNotExists(string queue) returns error? {
    http:Client clientEP = new("https://" + self.account + "." + AZURE_QUEUE_SERVICE_DOMAIN);
    string verb = "PUT";
    map<string> headers = generateCommonHeaders();
    string canonicalizedResource = "/" + check http:encode(self.account, "UTF8") + "/" + 
                                         check http:encode(queue, "UTF8");
    populateAuthorizationHeader(self.account, self.accessKey, canonicalizedResource, verb, headers);

    http:Request req = new;
    populateRequestHeaders(req, headers);

    var resp = clientEP->put("/" + untaint queue, req);

    if (resp is http:Response) {
        int statusCode = resp.statusCode;
        if (statusCode != http:CREATED_201 && statusCode != http:NO_CONTENT_204) {
            return generateError(resp);
        }
        return ();
    } else {
        return resp;
    }
}

remote function Client.deleteQueue(string queue) returns error? {
    http:Client clientEP = new("https://" + self.account + "." + AZURE_QUEUE_SERVICE_DOMAIN);
    string verb = "DELETE";
    map<string> headers = generateCommonHeaders();
    string canonicalizedResource = "/" + check http:encode(self.account, "UTF8") + "/" + 
                                         check http:encode(queue, "UTF8");
    populateAuthorizationHeader(self.account, self.accessKey, canonicalizedResource, verb, headers);

    http:Request req = new;
    populateRequestHeaders(req, headers);

    var resp = clientEP->delete("/" + untaint queue, req);

    if (resp is http:Response) {
        int statusCode = resp.statusCode;
        if (statusCode != http:NO_CONTENT_204) {
            return generateError(resp);
        }
        return ();
    } else {
        return resp;
    }
}

remote function Client.putMessage(string queue, string message, int ttlSeconds = -1) returns PutMessageResult|error {
    http:Client clientEP = new("https://" + self.account + "." + AZURE_QUEUE_SERVICE_DOMAIN);
    string verb = "POST";
    map<string> headers = generateCommonHeaders();
    headers["Content-Type"] = "application/xml";
    string canonicalizedResource = "/" + check http:encode(self.account, "UTF8") + "/" + 
                                         check http:encode(queue, "UTF8") + "/messages";
    populateAuthorizationHeader(self.account, self.accessKey, canonicalizedResource, verb, headers);
	
    http:Request req = new;
    populateRequestHeaders(req, headers);
    req.setXmlPayload(xml `<QueueMessage><MessageText>{{(untaint message)}}</MessageText></QueueMessage>`);

    var resp = clientEP->post("/" + untaint queue + "/messages?messagettl=" + untaint ttlSeconds, req);

    if (resp is http:Response) {
        int statusCode = resp.statusCode;
        if (statusCode != http:CREATED_201) {
            return generateError(resp);
        }
        return decodePutMessageXML(check resp.getXmlPayload());
    } else {
        return resp;
    }
}

remote function Client.getMessages(string queue, int count = 1,
                                   int visibilityTimeoutSecs = 30) returns GetMessagesResult|error {
    http:Client clientEP = new("https://" + self.account + "." + AZURE_QUEUE_SERVICE_DOMAIN);
    string verb = "GET";
    map<string> headers = generateCommonHeaders();
    string canonicalizedResource = "/" + check http:encode(self.account, "UTF8") + "/" + 
                                         check http:encode(queue, "UTF8") + "/messages";
    populateAuthorizationHeader(self.account, self.accessKey, canonicalizedResource, verb, headers);
	
    http:Request req = new;
    populateRequestHeaders(req, headers);

    var resp = clientEP->get("/" + untaint queue + "/messages?numofmessages=" + untaint count + 
                              "&visibilitytimeout=" + untaint visibilityTimeoutSecs, message = req);

    if (resp is http:Response) {
        int statusCode = resp.statusCode;
        if (statusCode != http:OK_200) {
            return generateError(resp);
        }
        return decodeGetMessagesXML(check resp.getXmlPayload());
    } else {
        return resp;
    }
}

remote function Client.deleteMessage(string queue, string messageId, string popReceipt) returns error? {
    http:Client clientEP = new("https://" + self.account + "." + AZURE_QUEUE_SERVICE_DOMAIN);
    string verb = "DELETE";
    map<string> headers = generateCommonHeaders();
    string canonicalizedResource = "/" + check http:encode(self.account, "UTF8") + "/" + 
                                         check http:encode(queue, "UTF8") + "/messages/" + messageId;
    populateAuthorizationHeader(self.account, self.accessKey, canonicalizedResource, verb, headers);

    http:Request req = new;
    populateRequestHeaders(req, headers);

    var resp = clientEP->delete("/" + untaint queue + "/messages/" + untaint messageId + 
                                "?popreceipt=" + untaint popReceipt, req);

    if (resp is http:Response) {
        int statusCode = resp.statusCode;
        if (statusCode != http:NO_CONTENT_204) {
            return generateError(resp);
        }
        return ();
    } else {
        return resp;
    }
}

# Azure Queue Service configuration.
# + accessKey - The Azure access key
# + account   - The Azure container account name
public type Configuration record {
    string accessKey;
    string account;
};


