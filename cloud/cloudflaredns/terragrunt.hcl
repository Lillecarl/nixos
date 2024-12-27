terraform {
  source = "."
}

inputs = {
  mailgun_api_key = get_env("MAILGUN_API_KEY")
}
