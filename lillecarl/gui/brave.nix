{ config
, pkgs
, ...
}: {
  programs.chromium = {
    enable = true;
    package = pkgs.brave;

    extensions = [
      { id = "hompjdfbfmmmgflfjdlnkohcplmboaeo"; } # Allow Right-Click
      { id = "occjjkgifpmdgodlplnacmkejpdionan"; } # AutoScroll
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # BitWarden
      { id = "lckanjgmijmafbedllaakclkaicjfmnk"; } # ClearURLs
      { id = "mdjildafknihdffpkfmmpnpoiajfjnjd"; } # Consent-O-Matic
      { id = "fhcgjolkccmbidfldomjliifgaodjagh"; } # Cookie AutoDelete
      { id = "ldpochfccmkkmhdbclfhpagapcfdljkj"; } # Decentraleyes
      { id = "omkfmpieigblcllmkgbflkikinpkodlk"; } # enhanced-h264ify
      { id = "fllaojicojecljbmefodhfapmkghcbnh"; } # Google Analytics Opt-out
      { id = "gbiekjoijknlhijdjbaadobpkdhmoebb"; } # IBA Opt-out
      { id = "chklaanhfefbnpoihckbnefhakgolnmc"; } # JSONVue
      { id = "cdglnehniifkbagbbombnjghhcihifij"; } # Kagi for Chrome
      { id = "mmpokgfcmbkfdeibafoafkiijdbfblfg"; } # Merge Windows
      { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } # Plasma Integrations
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # YouTube SponsorBlock
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # Vimium
      { id = "fcphghnknhkimeagdglkljinmpbagone"; } # YouTube Auto HD + FPS
    ];
  };
}
