{
  den.aspects.shell._.cli.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # System Utilities
        bat # Cat clone with syntax highlighting
        uutils-coreutils-noprefix # Rust implementation of GNU coreutils
        curl # Data transfer tool for URLs
        wget # File retrieval from web servers
        unzip # Extract ZIP archives
        zip # Create ZIP archives
        ffmpeg # Multimedia framework
        mkpasswd # Make password hash

        # Disk Usage Analyzers
        dua # Disk usage analyzer with TUI
        gdu # Fast disk usage analyzer
        dust # More intuitive du replacement

        # Process & System Monitoring
        procs # Modern process viewer (ps alternative)

        # File Searching
        fd # User-friendly find alternative
        ripgrep # Ultra-fast grep alternative

        # Version Control
        git # Distributed version control system
        git-lfs # Large file support
        gh # GitHub CLI
        delta # Syntax-highlighting pager
        tig # Text-mode interface for Git
        lazygit # Terminal UI for Git
        gitui # Another terminal UI for Git

        # TUI
        epy # Epub reader

        # Android Development
        scrcpy # Android device mirroring
        android-tools # Android platform tools
      ];
    };
}
