var aws = require('aws-sdk');

var ses = new aws.SES({
    region: 'eu-west-1' 
});

var docClient = new aws.DynamoDB.DocumentClient();

var table = "User";
var fromAddress = process.env.FROM_ADDRESS;

function markActivationStatus(username, activationStatus, callback) {
    var params = {
        TableName: table,
        Key:{
            "username": username
        },
        UpdateExpression: "set activationStatus = :status",
        ExpressionAttributeValues:{
            ":status": activationStatus
        },
        ReturnValues:"UPDATED_NEW"
    };
    
    console.log("Updating the item...");
    docClient.update(params, function(err, data) {
        if (err) {
            console.error("Unable to update item. Error JSON:", JSON.stringify(err, null, 2));
            callback(null, {"result": "Can't mark activationStatus: " + JSON.stringify(err, null, 2)})
        } else {
            console.log("UpdateItem succeeded:", JSON.stringify(data, null, 2));
            callback(null, {"result": "OK"})
        }
    });
}

function sendEmail(user, activationUrlBase, callback) {
    
    var activationUrl = activationUrlBase + "?username=" + user.username + "&token=" + user.activationToken;
    
    var to = user.email;
    var subject = "Activate your Digital Card Store account";
    var mailBody = '<html><body><br/>Dear ' + user.name + '<br/><a href="' + activationUrl
				+ '">Please click to activate your user account ' + user.username + "</a><br/>"
				+ "</body></html>";

    var eParams = {
        Destination: {
            ToAddresses: [to]
        },
        Message: {
            Body: {
                Html: {
                    Data: mailBody
                }
            },
            Subject: {
                Data: subject
            }
        },
        Source: fromAddress
    };

    console.log('>>> SENDING EMAIL');
    var email = ses.sendEmail(eParams, function(err, data){
        if (err) {
            console.log(err);
            callback(null, {"result": "Can't send email:" + err});
        }
        else {
            console.log(">>> EMAIL SENT");
            markActivationStatus(user.username, "MAIL_SENT", callback);
        }
    });
}

function findUser(username, callback) {
    var params = {
        TableName: table,
        Key:{
            "username": username
        }
    };
    
    docClient.get(params, function(err, data) {
        if (err) {
            console.error("Unable to read item. Error JSON:", JSON.stringify(err, null, 2));
            callback(null, {"result": "Unable to read item. Error JSON:" + JSON.stringify(err, null, 2)});
        } else {
            console.log("GetItem succeeded:", JSON.stringify(data, null, 2));
            
            var user = data.Item;
            var activationStatus = user == null ? "" : user.activationStatus;
            var activationUrlBase = user == null ? "" : user.activationUrlBase;
            
            if (activationStatus === "NONE")
                sendEmail(data.Item, activationUrlBase, callback);
            else
                callback(null, {"result": "Activation status of user " + username + " is not appropriate. It is " + activationStatus});
        }
    });
}

exports.handler = (event, context, callback) => {
    console.log("Incoming: ", event);

    var username = event.username;

    findUser(username, callback);
};
