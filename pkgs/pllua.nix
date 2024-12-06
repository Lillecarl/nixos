{
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  postgresql,
  lua ? throw "lua is required",
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
    sha256 = "sha256-6GDTnS0aj23irITDrR4ykMpR5ATTbe7YCc8f/KzLagI=";
  };

  makeFlags =
    [
      # Use PGXS
      "USE_PGXS=1"
      # PGXS only supports installing to postgresql prefix so we need to redirect this
      "DESTDIR=${placeholder "out"}"
      # Lua paths
      "LUA_INCDIR=${lua}/include"
      "LUALIB=-L${lua}/lib" # Set where Lua is installed
    ]
    ++ (
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

  postInstall = ''
    # Move the redirected to proper directory.
    # There appear to be no references to the install directories
    # so changing them does not cause issues.
    mv "$out/nix/store"/*/* "$out"
    rmdir "$out/nix/store"/* "$out/nix/store" "$out/nix"
  '';

  passthru = {
    shared_preload_library = "pllua";
  };

  propagatedBuildInputs = [
    lua
    postgresql
  ];

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  meta = {
    inherit (postgresql.meta) platforms;
  };
}
