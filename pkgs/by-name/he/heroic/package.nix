{
  lib,
  steam,
  heroic-unwrapped,
  extraCompatPackages ? [ ],
  extraPkgs ? pkgs: [ ],
  extraLibraries ? pkgs: [ ],
  extraEnv ? { },
}:

steam.buildRuntimeEnv {
  pname = "heroic";
  inherit (heroic-unwrapped) version meta;

  runScript = "heroic";

  extraPkgs = pkgs: [ heroic-unwrapped ] ++ extraPkgs pkgs;
  inherit extraLibraries;
  extraEnv =
    lib.optionalAttrs (extraCompatPackages != [ ]) {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = lib.makeSearchPathOutput "steamcompattool" "" extraCompatPackages;
    }
    // extraEnv;

  extraInstallCommands = ''
    mkdir -p $out/share
    ln -s ${heroic-unwrapped}/share/applications $out/share
    ln -s ${heroic-unwrapped}/share/icons $out/share
  '';

  privateTmp = false;
}
