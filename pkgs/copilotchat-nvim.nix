{ vimUtils
, fetchFromGitHub
, lib
}:
let
  self = vimUtils.buildVimPlugin {
    pname = "copilotchat-nvim";
    version = "2.4.0";

    src = fetchFromGitHub {
      owner = "CopilotC-Nvim";
      repo = "CopilotChat.nvim";
      rev = "v${self.version}";
      sha256 = "sha256-X2UvtIgcD5O0gNW89droUZ/4j4P1DiY2NIJaSKXl74Y=";
    };

    meta = {
      description = "Chat with GitHub Copilot in Neovim";
      homepage = "https://github.com/CopilotC-Nvim/CopilotChat.nvim/";
      license = lib.licenses.gpl3;
    };
  };
in
self
