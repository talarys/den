{
  shell,
  ...
}:
{
  # Single source of truth for session-wide environment variables.
  shell.env.homeManager =
    { config, ... }:
    {
      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        GIT_EDITOR = "nvim";
        PAGER = "less";
        TERMINAL = "ghostty";
        BROWSER = "zen";
        AUDIO_PLAYER = "mpv";
        VIDEO_PLAYER = "mpv";
        NH_OS_FLAKE = "${config.home.homeDirectory}/den";
      };

      home.sessionPath = [
        "${config.home.homeDirectory}/.bun/bin"
        "${config.home.homeDirectory}/.npm-global/bin"
        "${config.home.homeDirectory}/.local/bin"
      ];
    };
}
