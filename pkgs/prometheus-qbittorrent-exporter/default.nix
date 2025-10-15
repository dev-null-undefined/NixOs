{
  lib,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonApplication {
  pname = "prometheus-qbittorrent-exporter";
  version = "1.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dev-null-undefined";
    repo = "prometheus-qbittorrent-exporter";
    rev = "b1642dc2a9adbe50827d7e4d43970b7bc4e027e4";
    hash = "sha256-hBsSI36njlYDFsPj8xjj8VIwYd475A7MaPhz9aHqXtU=";
  };

  nativeBuildInputs = [python3.pkgs.pdm-backend];

  propagatedBuildInputs = with python3.pkgs; [
    prometheus-client
    python-json-logger
    qbittorrent-api
  ];

  pythonImportsCheck = ["qbittorrent_exporter"];

  meta = with lib; {
    description = "A prometheus exporter for qbittorrent written in Python. Simple. Works. Docker image";
    homepage = "https://github.com/esanchezm/prometheus-qbittorrent-exporter";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [];
    mainProgram = "qbittorrent-exporter";
  };
}
