import { DynamoDB } from 'aws-sdk';
import { updateStatus } from '../utils/redis-client.js';

const dynamo = new DynamoDB.DocumentClient();

export const handler = async (event: any) => {
    for (const record of event.Records) {
        const { traceId, cardId, service } = JSON.parse(record.body);
        
        // Retraso obligatorio de 5 segundos
        await new Promise(r => setTimeout(r, 5000));

        // Persiste el pago final en DynamoDB usando el nombre del proyecto
        await dynamo.put({
            TableName: 'sistema-pagos-logicapagos-payments', // <--- CAMBIADO AQUÍ
            Item: { 
                traceId, 
                cardId, 
                service, 
                status: 'FINISH', 
                timestamp: Date.now() 
            }
        }).promise();

        // Marca la transacción como completada en Redis para el polling
        await updateStatus(traceId, 'FINISH', { cardId, service });
    }
};