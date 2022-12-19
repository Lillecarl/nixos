# This is just a copy of the zabbix.agent2 derivation from nixpkgs with changed version and hashes.
# We should be able to achieve the same with an overlay with a packageoverride, but Go packages are a pain in the ass.
# Eventually we'll use whatever is mainline in nixpkgs anyways for simplicity.

{ lib
, buildGoModule
, fetchurl
, autoreconfHook
, pkg-config
, libiconv
, openssl
, pcre
, zlib
}:

buildGoModule {
  pname = "zabbix-agent2";
  version = "5.4.11";

  src = fetchurl {
    url = "https://cdn.zabbix.com/zabbix/sources/oldstable/5.4/zabbix-5.4.11.tar.gz";
    sha256 = "sha256-mxEsUFlnDB8MHWX6zWZaETNzNW6ut9ro28hXGG490kQ=";
  };

  modRoot = "src/go";

  vendorSha256 = "sha256-ha5itQClbBVyDKVD0AGox3PUhTbSv+7WmFHCCtjBK4U=";

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [ libiconv openssl pcre zlib ];

  inherit (buildGoModule.go) GOOS GOARCH;

  # need to provide GO* env variables & patch for reproducibility
  postPatch = ''
    substituteInPlace src/go/Makefile.am \
      --replace '`go env GOOS`' "$GOOS" \
      --replace '`go env GOARCH`' "$GOARCH" \
      --replace '`date +%H:%M:%S`' "00:00:00" \
      --replace '`date +"%b %_d %Y"`' "Jan 1 1970"
  '';

  # manually configure the c dependencies
  preConfigure = ''
    ./configure \
      --prefix=${placeholder "out"} \
      --enable-agent2 \
      --enable-ipv6 \
      --with-iconv \
      --with-libpcre \
      --with-openssl=${openssl.dev}
  '';

  # zabbix build process is complex to get right in nix...
  # use automake to build the go project ensuring proper access to the go vendor directory
  buildPhase = ''
    cd ../..
    make
  '';

  installPhase = ''
    mkdir -p $out/sbin
    install -Dm0644 src/go/conf/zabbix_agent2.conf $out/etc/zabbix_agent2.conf
    install -Dm0755 src/go/bin/zabbix_agent2 $out/bin/zabbix_agent2
    # create a symlink which is compatible with the zabbixAgent module
    ln -s $out/bin/zabbix_agent2 $out/sbin/zabbix_agentd
  '';

  meta = with lib; {
    description = "An enterprise-class open source distributed monitoring solution (client-side agent)";
    homepage = "https://www.zabbix.com/";
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.aanderse ];
    platforms = platforms.linux;
  };
}
