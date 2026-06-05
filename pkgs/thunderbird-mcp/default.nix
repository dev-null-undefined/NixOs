{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nodejs,
  makeWrapper,
}:
# MCP bridge for Thunderbird (TKasperczyk/thunderbird-mcp). The bridge is a
# single dependency-free Node CommonJS script that talks over localhost to the
# companion Thunderbird add-on (an HTTP server embedded in the extension), so
# packaging only needs node + the script — no node_modules / buildNpmPackage.
#
# Two things still happen outside Nix:
#   1. Install the add-on XPI (shipped at $out/share/thunderbird-mcp/thunderbird-mcp.xpi).
#      It is unsigned, so Thunderbird needs xpinstall.signatures.required=false.
#   2. Thunderbird must be running, and read-only vs compose/send tool access is
#      set in the add-on's Options page (not configurable from here).
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "thunderbird-mcp";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "TKasperczyk";
    repo = "thunderbird-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wewuXZV6tjSJ3gjmUkIoRFWwGbqVUc7xxEt1kp9dWSM=";
  };

  nativeBuildInputs = [makeWrapper];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/thunderbird-mcp
    # mcp-bridge.cjs reads ./package.json at runtime for its version string.
    cp mcp-bridge.cjs package.json $out/share/thunderbird-mcp/
    # Ship the add-on XPI alongside for the manual Thunderbird install.
    cp dist/thunderbird-mcp.xpi $out/share/thunderbird-mcp/

    makeWrapper ${lib.getExe nodejs} $out/bin/thunderbird-mcp \
      --add-flags $out/share/thunderbird-mcp/mcp-bridge.cjs

    runHook postInstall
  '';

  meta = {
    description = "MCP server bridge for Thunderbird — email, contacts and calendar access via a companion add-on";
    homepage = "https://github.com/TKasperczyk/thunderbird-mcp";
    license = lib.licenses.mit;
    mainProgram = "thunderbird-mcp";
  };
})
