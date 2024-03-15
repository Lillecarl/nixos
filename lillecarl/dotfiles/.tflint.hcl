plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
    enabled = true
    version = "0.29.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Remove when we know what to do about our gazillion provider blocks
rule "terraform_required_providers" {
  enabled = false
}

# Untypes variables are strings and that's not going to change.
rule "terraform_typed_variables" {
  enabled = false
}
