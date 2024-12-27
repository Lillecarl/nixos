locals {
  astring = <<TEXT
$THIS
$NAMESPACE
$TEST
TEXT
}

output "areplacedstring" {
  value = local.areplacedstring
}


locals {
  areplacedstring = provider::string-functions::multi_replace(local.astring, {
    "$NAMESPACE" = "nejmspejs"
  })
}
