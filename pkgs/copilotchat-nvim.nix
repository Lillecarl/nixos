{
  vimUtils,
  fetchFromGitHub,
  lib,
}:
let
  self = vimUtils.buildVimPlugin {
    pname = "copilotchat-nvim";
    version = "2.4.2";

    src = fetchFromGitHub {
      owner = "CopilotC-Nvim";
      repo = "CopilotChat.nvim";
      rev = "v${self.version}";
      sha256 = "sha256-Nuy5OzzxuW81+exUhbkW1g4kEvBtJB2xolrThOoPl9k=";
    };

    meta = {
      description = "Chat with GitHub Copilot in Neovim";
      homepage = "https://github.com/CopilotC-Nvim/CopilotChat.nvim/";
      license = lib.licenses.gpl3;
    };
  };
in
self
