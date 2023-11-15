{
  pkgs,
  config,
  self,
  ...
}: let
  sshKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQChXUkYH6ENZDu2BN3vja77Iiz6ZQ/+NePLmRO/q4pkj02lOjpgK+1A/WkrvdQrC+dnoFl6p9GLG07tzXebYlsnqnl3LpPzNKAPRpwB4XNQ6NDCgQYHMSx7cTct8wmKZy2J9E3F8a03RutcFxmr9xyhGS/J/FGwkRJfJrq7fkD1gBdUvQ1ISqDJKMaL9oJ5NZgJbxutHkeBkSP78qA1lGwX+fkSyl5pr0bEDBAEo46b4zRm0QBA7tavoJgqozekGHE+3JhKw/RZlv0LcXzeTUquQyQgYwvHYJ9NVjN9R0sguKOBsMBf9G1yjetr1WLkRrf5ZkiOuwqq8MpEW9CgyV4j18zJcBNvTvGTYVkPcNNcAjCyHESgoCwwQw5zL4Fe4y2q2E16nmnwXRsaUmJ3bZ6sua6887cWm7X9UdrBdg9SO2Fr+ncME3ohFJ+kuQSNZoAQZB249/lF+LTheTjA9zz/hmT+wuFGMTAioEqLAOoC0zNhIhKjnccjmTLntLi1QMs= ntb@merica-ntb";
in {
  users.users.lomohov = {
    isNormalUser = true;
    extraGroups = self.lib'.internal.groupIfExist config [
      "network"
      "video"
      "networkmanager"
      "wireshark"
      "mysql"
      "docker"
      "libvirtd"
      "vboxusers"
      "git"
    ];
    shell = pkgs.zsh;
    useDefaultShell = false;
    openssh.authorizedKeys.keys = [sshKey];
  };
}
