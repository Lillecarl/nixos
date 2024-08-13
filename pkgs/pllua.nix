{ stdenv
, fetchFromGitHub
, autoPatchelfHook
, postgresql
, lua ? throw "lua is required"
}:
let
  name = "pllua";
  version = "REL_2_0_12";
  jit = lua.pname == "luajit";
in
stdenv.mkDerivation {
  inherit name;

  src = fetchFromGitHub {
    owner = name;
    repo = name;
    rev = version;
    sha256 = "sha256-xzfuSTzobNT3q4HlJXov1v9OgF8uzaxVFsvl5xBxoEI=";
  };

  makeFlags = [
    # Use PGXS
    "USE_PGXS=1"
    # PGXS only supports installing to postgresql prefix so we need to redirect this
    "DESTDIR=${placeholder "out"}"
    # Lua paths
    "LUA_INCDIR=${lua}/include"
    "LUALIB=-L${lua}/lib" # Set where Lua is installed
  ] ++ (
    if jit then
      [
        "LUAJIT=${lua}/bin/luajit"
      ]
    else
      [
        "LUAC=${lua}/bin/luac"
        "LUA=${lua}/bin/lua"
      ]
  );

  # Workaround for stupid pllua Makefile
  NIX_LDFLAGS =
    if jit then
      [ "-lluajit-${lua.luaversion}" ]
    else
      [
        "-llua"
      ];

  NIX_DEBUG = "1";

  postInstall = ''
    # Move the redirected to proper directory.
    # There appear to be no references to the install directories
    # so changing them does not cause issues.
    mv "$out/nix/store"/*/* "$out"
    rmdir "$out/nix/store"/* "$out/nix/store" "$out/nix"
  '';

  propagatedBuildInputs = [
    lua
    postgresql
  ];

  nativeBuildInputs = [
    autoPatchelfHook
  ];
}
