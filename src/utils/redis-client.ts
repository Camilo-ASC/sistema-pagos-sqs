import { createClient } from 'redis';

const client = createClient({ url: process.env.REDIS_URL! });
client.on('error', (err) => console.log('Redis Error', err));

export const updateStatus = async (traceId: string, status: string, data: any = {}) => {
    // Actualiza el estado y datos del pago en Redis
    if (!client.isOpen) await client.connect();
    await client.set(traceId, JSON.stringify({ status, ...data, timestamp: Date.now() }));
};