import { updateStatus } from '../utils/redis-client.js';
import { sendMessage } from '../utils/sqs-client.js';

export const handler = async (event: any) => {
    for (const record of event.Records) {
        const { cardId, service, traceId } = JSON.parse(record.body);
        // Retraso obligatorio de 5 segundos
        await new Promise(r => setTimeout(r, 5000));
        // Registra el inicio del proceso en Redis
        await updateStatus(traceId, 'INITIAL', { cardId, service });
        // Propaga el traceId a la siguiente etapa
        await sendMessage(process.env.CHECK_BALANCE_QUEUE_URL!, { traceId, cardId, service });
    }
};