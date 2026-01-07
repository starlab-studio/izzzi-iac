# modules/firewall/tags.tf
resource "digitalocean_tag" "common_tags" {
  for_each = toset([
    "project:${var.project_name}",
    "managedby:terraform",
    "environment:${var.environment}",
  ])
  
  name = each.value
}

resource "digitalocean_tag" "firewall_tags" {
  for_each = toset([
    "firewall:web",
    "firewall:internal", 
    "firewall:management",
    "type:public",
    "type:private",
    "type:admin"
  ])
  
  name = each.value
}