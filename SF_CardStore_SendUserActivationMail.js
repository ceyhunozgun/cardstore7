{
  "Comment": "Step function to send user activation mail",	
  "StartAt": "GetActivationStatus",
  "States": {
    "GetActivationStatus": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:eu-central-1:AWS_ACCOUNT_ID:function:LF_CardStore_GetUserActivationStatus",
      "Next": "CheckActivationStatus",
      "ResultPath": "$.activationStatus"
    },
    "CheckActivationStatus": {
      "Type" : "Choice",
      "Choices": [
        {
          "Variable": "$.activationStatus",
          "StringEquals": "NONE",
          "Next": "SendActivationMail"
        }
      ],
      "Default": "MailSent"
    },
    "SendActivationMail": {
      "Type" : "Task",
      "Resource": "arn:aws:lambda:eu-central-1:AWS_ACCOUNT_ID:function:LF_CardStore_SendUserActivationMail",
      "Next": "MailSent"
    },
    "MailSent": {
      "Type": "Pass",
      "End": true
    }
  }
}
