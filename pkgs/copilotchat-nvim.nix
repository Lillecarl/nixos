{ vimUtils
, fetchFromGitHub
, lib
}:
vimUtils.buildVimPlugin {
  pname = "copilotchat-nvim";
  version = "2.0.0";
  src = fetchFromGitHub {
    owner = "CopilotC-Nvim";
    repo = "CopilotChat.nvim";
    rev = "4811cdd91b35345358da89f0eedd1f2b92c8bf04";
    sha256 = "sha256-YRfe53MfqmRkgM2YgdYjps1FvhcDeqiSwuPe7YMIM7k=";
  };
  meta = {
    description = "Chat with GitHub Copilot in Neovim ";
    homepage = "https://github.com/CopilotC-Nvim/CopilotChat.nvim/";
    license = lib.licenses.gpl3;
  };
}
