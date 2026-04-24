variable "redis_url" {
  description = "URL de conexión al clúster de Redis ElastiCache"
  type        = string
  default     = "redis://master.sistema-pagos-cluster.oofk4z.use1.cache.amazonaws.com:6379"
}