# Heroic Games Launcher {#sec-heroic}

The `heroic` package provides an FHS environment for running games from Heroic.
On NixOS, enable Heroic and make compatibility tools available in its Wine
version selector with:

```nix
programs.heroic = {
  enable = true;
  extraCompatPackages = [ pkgs.proton-ge-bin ];
};
```

The module installs Heroic automatically, so it does not need to be added to
`environment.systemPackages` separately. The `programs.heroic.package` option
can select a customized Heroic package.

The package can also be configured directly through `extraCompatPackages`:

```nix
environment.systemPackages = [
  (pkgs.heroic.override {
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  })
];
```

This uses each package's `steamcompattool` output and exposes it through
`STEAM_EXTRA_COMPAT_TOOLS_PATHS`. Heroic also discovers Proton installations
listed in that environment variable when it is set externally.

`programs.steam.extraCompatPackages` configures Steam separately; it does not
make those tools available to Heroic.
