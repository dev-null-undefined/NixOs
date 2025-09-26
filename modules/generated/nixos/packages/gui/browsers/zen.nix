{ inputs, config, ... }:
{
  environment.systemPackages = [ inputs.zen-browser.${config.system}.zen ];
}
