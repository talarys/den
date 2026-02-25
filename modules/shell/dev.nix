{
  den.aspects.shell._.dev.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Editors
        neovim

        # Development Tools
        hyperfine # Command-line benchmarking tool
        just # Command runner (make alternative)
        devenv # Reproducible development environments
        devbox # Development environment manager
        watchexec # Run commands when files change
        entr # Run commands when files change
        zlib # Compression library
        opencode # LLM TUI

        # Typescript
        nodejs # JavaScript runtime
        bun # JavaScript runtime & toolkit
        biome # JavaScript and Typescript lsp

        # Golang
        go # Go programming language
        gopls # Go lsp

        #Rust
        cargo # Rust package manager
        rustc # Rust compiler
        rustfmt # Rust formatter

        #Zig
        zig # Zig programming language
        zls # Zig lsp

        # Haskell
        stack # Haskell build tool
        cabal-install # Haskell package manager
        ghc # Glasgow Haskell Compiler
        hpack # Haskell package manager
        haskell-language-server # Haskell language server
        ghciwatch # GHCi file watcher

        # Lua
        lua
        stylua # Lua formatter
        lua-language-server # Lua language server

        # C C++
        gcc # GNU Compiler Collection
        gnumake # GNU Make
        clang-tools # Clang tools

        # Python
        uv # Python package manager
        ruff # Python linter & formatter
        basedpyright # Python lsp

        # Nix
        deadnix # Dead code detection for Nix
        statix # Nix linter & suggestions
        nixd # Nix language server
        nil # Nix language server
        nixfmt # Nix formatter (RFC style)
      ];
    };
}
