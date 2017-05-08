const AWS = require('aws-sdk');

var stepFunctionArn = process.env.STEP_FUNCTION_ARN;

function startSendUserActivationMailStepFunctionExecution(username, callback) {
  console.log("Starting SendUserActivationMail StepFunction Execution for user " + username);
  
  const stepfunctions = new AWS.StepFunctions();
  const params = {
    stateMachineArn: stepFunctionArn,
    input: JSON.stringify({ "username": username })
  };

  // start a state machine
  stepfunctions.startExecution(params, (err, data) => {
    if (err) {
      callback(err, null);
      return;
    }
    
    console.log(data);

    callback(null, 'Started SendUserActivationMail StepFunction Execution for user ' + username);
  });
}


exports.handler = (event, context, callback) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    event.Records.forEach((record) => {
        console.log(record.eventName);
        console.log('DynamoDB Record: %j', record.dynamodb);

        if (record.eventName === "INSERT") {
            var username = record.dynamodb.NewImage.username;

            if (username)
                startSendUserActivationMailStepFunctionExecution(username.S, callback);
        }
    });
};
