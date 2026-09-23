{
  lib,
  stdenv,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  copyDesktopItems,
  makeDesktopItem,
  esbuild,
  fontconfig,
  libGL,
  libice,
  libsm,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxrandr,
  net-tools,
  xdg-utils,
  nix-update-script,
}:

buildDotnetModule (finalAttrs: {
  pname = "apps2samsung";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "Apps2Samsung";
    repo = "Apps2Samsung";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LkeZbbicAW2apHbw1OO64BIJq7+Ju5NYQD3Gy2UPrXQ=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  projectFile = "Jellyfin2Samsung-CrossOS/Apps2Samsung.csproj";
  nugetDeps = ./deps.json;
  executables = [ "Apps2Samsung" ];
  dotnetFlags = [ "-p:PublishSingleFile=false" ];

  patches = [ ./disable-auto-update.patch ];

  postPatch = ''
    substituteInPlace Apps2Samsung.Core/Core/EsbuildHelper.cs \
      --replace-fail 'PlatformService.GetEsbuildPath(Path.Combine(baseDir, "Assets", "esbuild"))' \
        '"${lib.getExe esbuild}"'
  '';

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ copyDesktopItems ];

  runtimeDeps = lib.optionals stdenv.hostPlatform.isLinux [
    fontconfig
    libGL
    libice
    libsm
    libx11
    libxcursor
    libxext
    libxi
    libxrandr
  ];

  makeWrapperArgs = lib.optionals stdenv.hostPlatform.isLinux [
    "--prefix PATH : ${
      lib.makeBinPath [
        net-tools
        xdg-utils
      ]
    }"
  ];

  desktopItems = lib.optionals stdenv.hostPlatform.isLinux [
    (makeDesktopItem {
      name = "apps2samsung";
      desktopName = "Apps2Samsung";
      exec = "Apps2Samsung";
      icon = "apps2samsung";
      comment = finalAttrs.meta.description;
      categories = [ "Utility" ];
    })
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    install -Dm644 Jellyfin2Samsung-CrossOS/Assets/jelly2sams.png \
      $out/share/icons/hicolor/256x256/apps/apps2samsung.png
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    appDir="$out/Applications/Apps2Samsung.app/Contents"
    mkdir -p "$appDir/MacOS" "$appDir/Resources"
    ln -s "$out/bin/Apps2Samsung" "$appDir/MacOS/Apps2Samsung"
    install -m644 Jellyfin2Samsung-CrossOS/Assets/jelly2sams.icns "$appDir/Resources/"
    # Use upstream's bundle metadata, adding the network permission from its release workflow.
    substitute Jellyfin2Samsung-CrossOS/Info.plist "$appDir/Info.plist" \
      --replace-fail '<string>10.15</string>' '<string>11.0</string>' \
      --replace-fail '</dict>' '<key>CFBundleShortVersionString</key>
      <string>${finalAttrs.version}</string>
      <key>NSLocalNetworkUsageDescription</key>
      <string>Apps2Samsung scans your local network to find Samsung TVs in Developer Mode.</string>
    </dict>'
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Install apps on Samsung TVs, projectors and smart monitors";
    homepage = "https://github.com/Apps2Samsung/Apps2Samsung";
    changelog = "https://github.com/Apps2Samsung/Apps2Samsung/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "Apps2Samsung";
    maintainers = with lib.maintainers; [ schembriaiden ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
