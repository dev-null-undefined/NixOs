{
  pkgs,
  lib,
  ...
}: let
  config = {
    "$schema" = "https://opencode.ai/config.json";
    lsp = true;
    model = "dp/chat-large-xhigh";

    # Auto-approve everything: never prompt for edits, shell, web fetches, or
    # access outside the project directory.
    permission = {
      edit = "allow";
      bash = "allow";
      webfetch = "allow";
      external_directory = "allow";
    };

    # DataPacket OpenAI-compatible provider.
    provider.dp = {
      npm = "@ai-sdk/openai-compatible";
      name = "DataPacket";
      # baseURL kept out of this public repo: opencode resolves {file:...} at
      # load time from the sops secret (NixOS sops.secrets."opencode-dp-baseurl",
      # owner martin). Decrypted only on the personal hosts that declare it.
      options.baseURL = "{file:/run/secrets/opencode-dp-baseurl}";
      models = {
        "chat-large" = {
          name = "Chat Large";
          limit = {
            context = 256000;
            output = 128000;
          };
        };
        "chat-large-high" = {
          name = "Chat Large High";
          limit = {
            context = 256000;
            output = 128000;
          };
        };
        "chat-large-xhigh" = {
          name = "Chat Large XHigh";
          limit = {
            context = 256000;
            output = 128000;
          };
        };
        "heretic" = {
          name = "Unhinged Qwen coder";
          limit = {
            context = 256000;
            output = 128000;
          };
        };
      };
    };

    mcp.slack = {
      type = "local";
      # Run the nix-packaged server over stdio instead of npx.
      command = [(lib.getExe pkgs.slack-mcp-server) "--transport" "stdio"];
      enabled = true;
      environment = {
        # Browser session tokens, taken from opencode's own environment at
        # config load — set SLACK_MCP_XOXC_TOKEN (xoxc-…) and SLACK_MCP_XOXD_TOKEN
        # (the `d` cookie, xoxd-…) in your shell. Nothing secret is committed to
        # the Nix config.
        SLACK_MCP_XOXC_TOKEN = "{env:SLACK_MCP_XOXC_TOKEN}";
        SLACK_MCP_XOXD_TOKEN = "{env:SLACK_MCP_XOXD_TOKEN}";
        # Message posting stays disabled unless SLACK_MCP_ADD_MESSAGE_TOOL is
        # explicitly set in the environment (unset → empty string → read-only).
        SLACK_MCP_ADD_MESSAGE_TOOL = "{env:SLACK_MCP_ADD_MESSAGE_TOOL}";
      };
    };

    # Mail/contacts/calendar via the local Thunderbird add-on. The bridge
    # auto-discovers the add-on's localhost server + bearer token from a
    # connection file in tmpdir, so no credentials live here; it reuses
    # Thunderbird's own authenticated accounts. Requires Thunderbird to be
    # running with the companion add-on installed. Read-only vs compose/send is
    # controlled in the add-on's Options page.
    mcp.thunderbird = {
      type = "local";
      command = [(lib.getExe pkgs.thunderbird-mcp)];
      enabled = true;
    };
  };
in {
  home.packages = [pkgs.opencode];

  home.file.".config/opencode/opencode.json".source =
    (pkgs.formats.json {}).generate "opencode.json" config;
}
