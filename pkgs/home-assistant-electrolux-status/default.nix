{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  aiofiles,
  pyelectroluxocp,
}:
buildHomeAssistantComponent rec {
  owner = "albaintor";
  domain = "electrolux_status";
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "albaintor";
    repo = "homeassistant_electrolux_status";
    rev = "v${version}";
    hash = "sha256-NSgX20AKEsxXRRlcM1nr7FyZ3+JjqiO/UubV6J+pFdA=";
  };

  dependencies = [
    aiofiles
    pyelectroluxocp
  ];

  dontBuild = true;

  meta = {
    changelog = "https://github.com/albaintor/homeassistant_electrolux_status/releases/tag/v${version}";
    description = "Electrolux/AEG connected appliances (washer, dryer, dishwasher) via Electrolux OCP cloud API";
    homepage = "https://github.com/albaintor/homeassistant_electrolux_status";
    license = lib.licenses.mit;
  };
}
