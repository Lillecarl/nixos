terraform {
  source = "."
}
include "root" {
  path = find_in_parent_folders("root.hcl")
}
exclude {
  if      = true
  actions = ["destroy"]
}
inputs = {
  mailgun_api_key = get_env("MAILGUN_API_KEY")
}
