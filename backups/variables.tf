variable "cron_yearly_april_1" {
  type        = string
  default     = "cron(0 6 1 4 ? *)"
  description = "At 06:00 AM, on day 1 of the month, only in April"
}

variable "cron_yearly_jan_1" {
  type        = string
  default     = "cron(0 6 1 1 ? *)"
  description = "At 06:00 AM, on day 1 of the month, only in January"
}

variable "cron_monthly" {
  type        = string
  default     = "cron(0 6 1 * ? *)"
  description = "At 06:00 AM, on day 1 of the month"
}