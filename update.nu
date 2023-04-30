#! /usr/bin/env nu

def updatevscode [] {
  cd ~/Code/nixos

  let extpath = "./pkgs/vscodeExtensions.json"
  print $extpath

  let $data = ($extpath | open)

  let $updated_data = ($data | par-each {|it|
    $"Processing ($it.publisher)-($it.name)" | print
    let URL = $"https://($it.publisher).gallery.vsassets.io/_apis/public/gallery/publisher/($it.publisher)/extension/($it.name)/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
    let NAME = $"($it.publisher)-($it.name)"

    let nix_output = (do { nix-prefetch-url --name $NAME --print-path $URL } | complete)

    let hash = ($nix_output.stdout | lines).0
    let pkgpath = ($nix_output.stdout | lines).1

    let it = (if $it.sha256 != $hash {
      $"Updating ($it.publisher)-($it.name) sha256 from ($it.sha256) to ($hash)" | print
      $it | update sha256 $hash
    } else $it)

    let version = ((unzip -qc $pkgpath "extension/package.json") | from json).version

    let it = (if $it.version != $version {
      $"Updating ($it.publisher)-($it.name) version from ($it.version) to ($version)" | print
      $it | update version $version
    } else $it)

    $it
  })

  $updated_data | print
  $updated_data | to json | save -f ($extpath)
}

updatevscode
