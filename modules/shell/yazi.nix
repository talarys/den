{
  den.aspects.shell._.yazi.homeManager =
    { pkgs, ... }:
    let
      flavors = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "flavors";
        rev = "c02c804bb7c8873da8182745654fb57dc63b7348";
        sha256 = "sha256-ZXJx4iwGCAi6qqDiLSuJvX3UL6XzypxSO7ptspDD/Yw=";
      };
    in
    {
      home.packages = with pkgs; [
        yazi
        rich-cli
        glow
      ];
      programs = {
        yazi = {
          enable = true;
          enableFishIntegration = true;
          enableNushellIntegration = true;
          shellWrapperName = "y";
          flavors = {
            catppuccin-mocha = "${flavors}/flavors/catppuccin-mocha.yazi";
            catppuccin-macchiato = "${flavors}/catppuccin-macchiato.yazi";
          };
          theme = {
            flavor = {
              use = "catppuccin-mocha";
            };
          };
          plugins = {
            glow = pkgs.fetchFromGitHub {
              owner = "Reledia";
              repo = "glow.yazi";
              rev = "main";
              hash = "sha256-mzW/ut/LTEriZiWF8YMRXG9hZ70OOC0irl5xObTNO40=";
            };
            rich-preview = pkgs.fetchFromGitHub {
              owner = "AnirudhG07";
              repo = "rich-preview.yazi";
              rev = "main";
              hash = "sha256-KHmjff7tHFLkPqOs8IdWQ0mCliSZn/mIKYof+ulnddk=";
            };
          };
          settings = {
            opener = {
              epy = [
                {
                  run = "epy \"$@\"";
                  block = true;
                  desc = "Open with epy";
                }
              ];
            };
            prepend-rules = [
              {
                mime = "application/epub+zip";
                use = "epy";
              }
              {
                name = "*.epub";
                use = "epy";
              }
            ];
            mgr = {
              show-hidden = true;
            };
            plugin = {
              prepend-previewers = [
                # { name = "*.md"; run = "glow"; }
                {
                  name = "*.csv";
                  run = "rich-preview";
                  mime = "text/csv";
                } # for csv files
                {
                  name = "*.md";
                  run = "rich-preview";
                  mime = "text/x-markdown";
                } # for markdown (.md) files
                {
                  name = "*.rst";
                  run = "rich-preview";
                  mime = "text/x-rst";
                } # for restructured text (.rst) files
                {
                  name = "*.ipynb";
                  run = "rich-preview";
                  mime = "application/x-ipynb+json";
                } # for jupyter notebooks (.ipynb)
                {
                  name = "*.json";
                  run = "rich-preview";
                  mime = "application/json";
                } # for json (.json) files
                #    { name = "*.lang_type"; run = "rich-preview"} # for particular language files eg. .py, .go., .lua, etc.
              ];
            };
          };
        };
      };
    };
}
