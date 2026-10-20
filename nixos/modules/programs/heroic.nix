{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.heroic;
in
{
  options.programs.heroic = {
    enable = lib.mkEnableOption "Heroic Games Launcher";

    package = lib.mkPackageOption pkgs "heroic" { } // {
      apply =
        heroic:
        heroic.override (previous: {
          extraCompatPackages = (previous.extraCompatPackages or [ ]) ++ cfg.extraCompatPackages;
        });
    };

    extraCompatPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.proton-ge-bin ]";
      description = ''
        Extra Proton compatibility tools to make available in Heroic's Wine
        version selector. These packages must have a `steamcompattool` output.

        This is configured independently of
        {option}`programs.steam.extraCompatPackages`. Both launchers can use
        the same packages without duplicating their installation.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };

  meta.maintainers = [ ];
}
