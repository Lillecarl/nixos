{ vimUtils
, fetchFromGitHub
, python3
, buildEnv
, lib
}:
let
  pname = "copilotchat-nvim";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "CopilotC-Nvim";
    repo = "CopilotChat.nvim";
    rev = "847a35457106e9d6ec7a9675b25cf8f90f8e84cc";
    sha256 = "sha256-i/ME8djXqPH2lTtxhf+rmUiVBP06CLKAp+ReJ4v27Os=";
  };
  meta = {
    description = "Chat with GitHub Copilot in Neovim ";
    homepage = "https://github.com/CopilotC-Nvim/CopilotChat.nvim/";
    license = lib.licenses.gpl3;
  };
  lua = vimUtils.buildVimPlugin {
    pname = "${pname}-lua";
    inherit src version meta;
  };
  python = python3.withPackages (ps: with ps; [
    python-dotenv
    requests
    prompt-toolkit
    tiktoken
  ]);
in
buildEnv {
  name = pname;

  paths = [
    lua
    python
  ];
}
