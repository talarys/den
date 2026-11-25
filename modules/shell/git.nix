{
  shell,
  ...
}:
{
  shell.git.homeManager = _: {
    programs.difftastic.enable = true;

    programs.git = {
      enable = true;
      lfs.enable = true;

      signing = {
        format = "ssh";
        key = "~/.ssh/id_ed25519.pub";
        signByDefault = true;
      };

      settings = {
        user.name = "talarys";
        user.email = "d.simon.ssx0@gmail.com";
        init.defaultBranch = "main";
        pull.rebase = true;
        rerere.enabled = true;
        column.ui = "auto";
        fetch.prune = true;
        interactive.singlekey = true;
      };
    };
  };
}
