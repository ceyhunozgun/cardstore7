var aws = require('aws-sdk');

var docClient = new aws.DynamoDB.DocumentClient();

var table = "User";

exports.handler = (event, context, callback) => {
    var username = event.username;
    var activationStatus = "";
    
    if (!username || username === "") {
        callback(null, activationStatus);
        return;
    }
    
    var params = {
        TableName: table,
        Key: {
            "username": username
        }
    };
    
    docClient.get(params, function(err, data) {
        if (err) {
            console.error("Unable to read item. Error JSON:", JSON.stringify(err, null, 2));
            callback(null, activationStatus);
        } else {
            console.log("GetItem succeeded:", JSON.stringify(data, null, 2));
			
            var user = data.Item;
            activationStatus = user == null ? "" : user.activationStatus;
            
            callback(null, activationStatus);
        }
    });
};
