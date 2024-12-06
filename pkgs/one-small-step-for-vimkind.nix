{
  vimUtils,
  fetchFromGitHub,
}:
let
  pname = "one-small-step-for-vimkind";
in
vimUtils.buildVimPlugin {
  inherit pname;
  version = "master";

  src = fetchFromGitHub {
    owner = "jbyuki";
    repo = "one-small-step-for-vimkind";
    rev = "aaee281bdaa3141d9d0cdb3dec468532da61124f";
    sha256 = "sha256-VACSEN50FSzQmAjpFW45yXvc68wnRhzfboYvps3sOBE=";
  };
}
