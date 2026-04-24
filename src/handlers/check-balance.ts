import { updateStatus } from '../utils/redis-client.js';
import { sendMessage } from '../utils/sqs-client.js';

export const handler = async (event: any) => {
    for (const record of event.Records) {
        const { traceId, cardId, service } = JSON.parse(record.body);
        // Retraso obligatorio de 5 segundos
        await new Promise(r => setTimeout(r, 5000));
        // Actualiza estado a progreso tras validación simulada
        await updateStatus(traceId, 'IN_PROGRESS');
        // Envía a la cola final de ejecución
        await sendMessage(process.env.TRANSACTION_QUEUE_URL!, { traceId, cardId, service });
    }
};