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

    # Creates a queue.
    # + queue - The queue name
    # + return - If successful, returns `()`, else returns an `error` object
    public remote function createQueue(string queue) returns error?;

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

remote function Client.createQueue(string queue) returns error? {
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
        if (statusCode != http:CREATED_201) {
            return generateError(resp);
        }
        return ();
    } else {
        return resp;
    }
}

# Azure Blog Service configuration.
# + accessKey - The Azure access key
# + account   - The Azure container account name
public type Configuration record {
    string accessKey;
    string account;
};


