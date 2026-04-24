import { SQS } from 'aws-sdk';
const sqs = new SQS();

export const sendMessage = async (queueUrl: string, body: any) => {
    // Envía el mensaje a la cola especificada
    return sqs.sendMessage({
        QueueUrl: queueUrl,
        MessageBody: JSON.stringify(body)
    }).promise();
};