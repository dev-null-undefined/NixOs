{lib, ...}: let
  sshKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAG7FcqMB3VmekSsunDI1LWdiMJrItK25Y0klffjjsd5G50Xakbd2L/zdSLLlz+UtWD/CbgZXdO399gjXPVadNoboXOiELbEhzDZqOWZ4TA9ZWzsn+JRNIgZViLqNmFNFLsesAElRFjzNryEcjwUcB1yUyMMu4WdBrVBCeqomCRNY94NvBx/8xxjg0Huldyf+VBZMx2J8rmghEjxCQs573mmLibc62XmTYlvg7RGjgdJPRPyY7VvcB0X8SbzIHocVV6cGW6iyZi8WzeXAZMpH7euFeeTP2eTFBBmaWzbh71Ep9WBGDrG6fnZXokipBlVHl9i+TWEAJtW9171COAXAPOJEm74WQrrpin0VFFLa0iNT1eFjPCsz67Ll2ykO6hAcH4KpXWXlMT1R5BgIQE1QwqA++g7npq18D0iWWr/BKP4q7YQgyapseU6Vzpp8i/GX2o7+qeuxgus2Kk49yZStxHtDs4aNJ1EMtkRqq83YiCiYvTUq18doRidfsX42g32GnA4a0yAXOvg/5IDln9Y7iVwjylVQagJjy3TcWYaPqdbTnpTp7GUNK3XOccsqZZrvwNGbe6LXjCoLWaooaQXw4dE1AoUooo9J9GDIAK0AAuXWmzGcrj+V7dULdiG9hPVpabN29/aJUpxlkP0khGhaoX8Of+NDLFgmWWy8NXCPinw== cardno:19 716 313"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDy3QrJeu3E0ai/Jx7jAZTUlFef9EG+TXqhALpl1rkb/eIZpcGjg4WqAIQ9OmmCdc7IC4SDg6zamK8yDdnRVaEX3ISk5PbALmWtc5F/AjbvylcKmMMG15GiX7W5nj1V4HAmRXN/iKZjtoHec5rxa3A4E6EH6OC8WtlnDCFpWtUxRZcT9Vx2cgpYvUA1rYyfWQQFO29wPeQY26yYiYp37jNLMgdg5tb5nym0Q5NBDwMb84hav8Lz0EhCwTHgE/vRru0Im+mmSVoIJvi+Q68+JIVwu8FzuZCrBIRdO7KqDB/Vwzo0ZZR8bKoUcy77QYI9YeNyarPVTon3xLZXqu1ENeuZnvCbJkr8OKQoQxMUkACvKpu9vyQXamLLkbnv7ZgjsrEC7kHJji4avVgv0WZmcjvzb1YZPq/bhZIPgDaI7DlnkZ0GBX/HWNHhfHT/uCcsFeMcUVaoJo6agMPRZY6PxAVW97zj4ZctmfTts+Zra4zgSrV/5ZdMfaLfVHuxYE51PnYnASqcjTGBdicAdgHiohc5BHbUa+0eJlBM1mCbZvDmQhrKpfrK/lRqBw7kwxr1lgf8JkPajvbqAj4vpkD3uYBBGUXziyYsXiB28DtHWlNQDo+5+dzZTX1wTEWSZoTp2fr3s/RU0BLJhzcOy344ywyiJm17Nub3GYjE8LgZrTJpWQ== openpgp:0xC23BC2B3"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ/lPlb+q+FMf1o/oQg4S+9xscvXoB1zUSmoZUA4MFQt martin@x1"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKp+3o03aaozSpWfjP+/ivQQxKpanR242QL5vadF9kN2 martin@honey"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH60p2f6pQ92kILoLI962PLZcFiTgNb/TxU7vs6rkzoR marti@bee"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBUNcxn0s/dQ7ZPNQVWKyNwHkxIlpbqUiVleIcco5Ar martin@xps"
  ];
in {
  services.openssh = {
    enable = true;
    ports = [22 8022];
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      X11Forwarding = true;
    };
  };

  users.users = {
    root.openssh.authorizedKeys.keys = sshKeys;
  };
}
