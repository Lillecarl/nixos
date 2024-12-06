_: {
  xdg.configFile."fd/ignore".text = ''
    .git
    .hg
    .svn
    .stack-work
    .idea
    .vscode
    .vagrant
    .DS_Store
    .cabal-sandbox
    cabal.sandbox.config
    .vagrant
    .stack-work
  '';
}
