# 🚀 PigBank - Payment Microservice (AWS Serverless)

Este microservicio gestiona el flujo transaccional de pagos de la plataforma **PigBank** de manera asíncrona. Utiliza un sistema de tuberías basado en colas para garantizar la escalabilidad y el procesamiento por etapas, asegurando que cada pago pase por validaciones de seguridad y saldo antes de su ejecución final.

---

## 🛠️ Tecnologías y Arquitectura
* **Lenguaje:** TypeScript / Node.js
* **Infraestructura:** Terraform (IaC)
* **Base de Datos:** DynamoDB (Persistencia final) y Redis (Estado en tiempo real/Polling)
* **Mensajería:** AWS SQS (Arquitectura orientada a eventos con 3 etapas)
* **Red:** Despliegue en VPC privada para comunicación segura con clúster de Redis
* **Patrón de Diseño:** Pipeline & Filters (Procesamiento por etapas con retrasos de 5s)

---

## 📌 Flujo del Sistema (Asíncrono)

El proceso no es síncrono; el cliente envía la solicitud y consulta el estado mediante el `traceId`.

### 1. 📥 Inicio de Pago (`Start Payment`)
* **Entrada**: Mensaje en `start-payment-queue`.
* **Acción**: Registra el estado `INITIAL` en Redis.
* **Siguiente**: Envía el relevo a la cola de validación.

### 2. ⚖️ Validación de Saldo (`Check Balance`)
* **Entrada**: Mensaje en `check-balance-queue`.
* **Acción**: Simula validación de fondos y actualiza estado a `IN_PROGRESS` en Redis.
* **Siguiente**: Envía el relevo a la ejecución de transacción.

### 3. 💳 Ejecución de Transacción (`Transaction`)
* **Entrada**: Mensaje en `transaction-queue`.
* **Acción**: Persiste el registro final en **DynamoDB** y marca el estado como `FINISH` en Redis.

---
