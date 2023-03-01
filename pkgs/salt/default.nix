{ lib
, stdenv
, python3
, openssl
, fetchpatch
, extraInputs ? []
}:

python3.pkgs.buildPythonApplication rec {
  pname = "salt";
  version = "master";

  src = /home/lillecarl/Code/nent/saltstack;

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
    pytest-shell-utilities
    pytest-skip-markers
    pytest-salt-factories
    pytest-helpers-namespace
    typing-extensions
    mock
  ];

  propagatedBuildInputs = with python3.pkgs; [
    distro
    jinja2
    jmespath
    markupsafe
    msgpack
    psutil
    pycryptodomex
    pyyaml
    pyzmq25
    requests
    looseversion
    packaging
  ] ++ extraInputs;

  patches = [
    ./fix-libcrypto-loading.patch
  ];

  postPatch = ''
    substituteInPlace "salt/utils/rsax931.py" \
      --subst-var-by "libcrypto" "${lib.getLib openssl}/lib/libcrypto${stdenv.hostPlatform.extensions.sharedLibrary}"
    substituteInPlace requirements/base.txt \
      --replace contextvars ""

    # Don't require optional dependencies on Darwin, let's use
    # `extraInputs` like on any other platform
    echo -n > "requirements/darwin.txt"
  '';

  # Don't use fixed dependencies on Darwin
  USE_STATIC_REQUIREMENTS = "0";

  # The tests fail due to socket path length limits at the very least;
  # possibly there are more issues but I didn't leave the test suite running
  # as is it rather long.
  #doCheck = true;

  meta = with lib; {
    homepage = "https://saltproject.io/";
    changelog = "https://docs.saltproject.io/en/latest/topics/releases/${version}.html";
    description = "Portable, distributed, remote execution and configuration management system";
    maintainers = with maintainers; [ Flakebi ];
    license = licenses.asl20;
  };
}
