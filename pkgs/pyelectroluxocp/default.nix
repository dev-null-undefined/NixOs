{
  lib,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
  aiohttp,
  aiohttp-retry,
}:
buildPythonPackage rec {
  pname = "pyelectroluxocp";
  version = "0.1.3";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-zr8vMGgU1RqqpHrAeSusJ6x5wS1wF79SLB68wc7UAgk=";
  };

  build-system = [poetry-core];

  dependencies = [
    aiohttp
    aiohttp-retry
  ];

  pythonImportsCheck = ["pyelectroluxocp"];

  meta = {
    description = "Electrolux OneApp OCP API client";
    homepage = "https://github.com/Woyken/py-electrolux-ocp";
    license = lib.licenses.mit;
  };
}
