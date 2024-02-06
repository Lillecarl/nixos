{ vimUtils
, fetchFromGitHub
, python3
, buildEnv
, lib
}:
let
  pname = "copilotchat-nvim";
  version = "1.0.0";
  #src = fetchFromGitHub {
  #  owner = "CopilotC-Nvim";
  #  repo = "CopilotChat.nvim";
  #  rev = "96b8ebfff439cbb00f44331578c88019da45f543";
  #  sha256 = "sha256-fyxizla1Sz5UX07HaIlletKSMkPcBiFyxQkI4766dus=";
  #};
  src = /home/lillecarl/Code/carl/CopilotChat.nvim;
  meta = {
    description = "Chat with GitHub Copilot in Neovim ";
    homepage = "https://github.com/CopilotC-Nvim/CopilotChat.nvim/";
    license = lib.licenses.gpl3;
  };
  lua = vimUtils.buildVimPlugin {
    pname = "${pname}-lua";
    inherit src version meta;
  };
  python = (python3.withPackages (ps: with ps; [
    python-dotenv
    requests
    prompt-toolkit
    tiktoken
  ]));
in
buildEnv {
  name = pname;

  paths = [
    lua
    python
  ];
}
