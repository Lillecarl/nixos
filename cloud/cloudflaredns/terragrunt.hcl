terraform {
  source = "."
}

exclude {
  if      = true
  actions = ["destroy"]
}

inputs = {
  mailgun_api_key = get_env("MAILGUN_API_KEY")
}
