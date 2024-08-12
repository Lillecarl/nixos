{ lib
, stdenv
, fetchFromGitHub
, autoPatchelfHook
, postgresql
, lua ? throw "lua is required"
}:
let
  jit = lua.pname == "luajit";
in
stdenv.mkDerivation {
  name = "pllua";

  src = fetchFromGitHub {
    owner = "pllua";
    repo = "pllua";
    rev = "f1d32581014a6e4e532a63d1c1ca79dddfa25336";
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

  #postFixup = ''
  #  # Patch elf, add lua rpath and needed.
  #  patchelf \
  #    --add-rpath ${lua}/lib/liblua.so \
  #    --add-needed ${lua}/lib/liblua.so \
  #    $out/lib/pllua.so
  #'';

  propagatedBuildInputs = [
    lua
    postgresql
  ];

  nativeBuildInputs = [
    autoPatchelfHook
  ];
}
