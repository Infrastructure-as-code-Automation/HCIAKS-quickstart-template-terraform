variable "enable_insights" {
  description = "Whether to enable Azure Monitor Insights."
  type        = bool
  default     = false
}

variable "enable_alerts" {
  description = "Whether to enable Azure Monitor Alerts."
  type        = bool
  default     = false
}
