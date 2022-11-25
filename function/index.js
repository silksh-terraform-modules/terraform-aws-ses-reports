const aws = require('aws-sdk');
const s3 = new aws.S3({apiVersion: '2006-03-01'});
const fileExtension = '.json';
const bucketName = process.env.S3_BUCKET_NAME;
// const bucketName = 'S3-BUCKET-NAME' // set your bucket name here
const path = process.env.BUCKET_PATH;

exports.handler = (sns, context) => {
  //retrieve the events from the sns json
  const message = sns.Records[0].Sns.Message;
  //extract the date to use in the file names
  const timestamp = sns.Records[0].Sns.Timestamp;
  // default file name in case we cannot find any email in the message
  let filename = 'unknown/' + timestamp + '-unknow-email' + fileExtension;
  // let' parse the message to find the destination email and put it in the filename
  const parsedMessage = JSON.parse(message);
  if (parsedMessage.mail && parsedMessage.mail.destination && parsedMessage.mail.destination[0]) {
    // bounce/2020-08-07T07:58:08.070Z-destination@email.com.json
    filename = path + '/' + timestamp + '-' + parsedMessage.mail.destination[0] + fileExtension;
  }
  const params = {
    Bucket: bucketName,
    Key: filename,
    Body: message,
  };
  // create document in the S3
  s3.putObject(params, function(err) {
    if (err) console.log(err, err.stack); // an error occurred
  });
};