variable "hcloud_token" {
  type      = string
  sensitive = true
  description = "API Token per autenticare su Hetzner Cloud"
}

variable "ssh_key_name" {
  type        = list(string)
  description = "Elenco delle chiavi SSH caricate su Hetzner Cloud"
}

variable "image" {
  type        = string
  description = "Immagine del sistema operativo da utilizzare (es. ubuntu-22.04)"
  default     = "ubuntu-24.04"
}

variable "location" {
  type        = string
  description = "Datacenter Hetzner (es. nbg1, hel1, fsn1)"
  default     = "nbg1"
}

variable "server_type" {
  type        = string
  description = "Tipo di server Hetzner (es. cx22, cax11)"
  default     = "cx22"
}

variable "count_x" {
  type        = number
  description = "Numero di server da creare"
  default     = 3
}

