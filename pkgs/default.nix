final: prev: {
  xonsh-direnv = prev.callPackage ../pkgs/xonsh-direnv { };
  xontrib-fzf-widgets = prev.callPackage ../pkgs/xontrib-fzf-widgets { };
  xontrib-sh = prev.callPackage ../pkgs/xontrib-sh { };
  xontrib-argcomplete = prev.callPackage ../pkgs/xontrib-argcomplete { };
  xontrib-output-search = prev.callPackage ../pkgs/xontrib-output-search { };
  xontrib-jump-to-dir = prev.callPackage ../pkgs/xontrib-jump-to-dir { };
  xonsh-joined-deps = prev.callPackage ../pkgs/xonsh-joined-deps { };
  xonsh-autoxsh = prev.callPackage ../pkgs/xonsh-autoxsh { };
  tokenize-output = prev.callPackage ../pkgs/tokenize-output { };
  lazyasd = prev.callPackage ../pkgs/lazyasd { };
  splunk-otel-collector = prev.callPackage ../pkgs/splunk-otel-collector { };
  acme-dns = prev.callPackage ../pkgs/acme-dns { };
  vscode-extensions = prev.vscode-extensions // {
    jnoortheen.xonsh = prev.callPackage ../pkgs/vscode-extensions/jnoortheen.xonsh { };
    EditorConfig.EditorConfig = prev.callPackage ../pkgs/vscode-extensions/EditorConfig.EditorConfig { };
  };
  nodePackages = prev.nodePackages // (prev.callPackages ./node-packages {});
}
