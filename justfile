rebuild:
    nh os switch .

up:
    nix flake update

upp target:
    nix flake update {{ target }}

repl:
    nh os repl

clean:
    sudo nix-collect-garbage -d

check:
    nix flake check

fmt:
    nix fmt

anywhere host target:
    nix run github:nix-community/nixos-anywhere -- --flake {{ host }} --host-target {{ target }}

disko-install host diskConfig diskTarget:
    sudo nix --extra-experimental-features "nix-command flakes" run 'github:nix-community/disko/latest#disko-install' -- --flake .#{{ host }} --disk {{ diskConfig }} {{ diskTarget }}

disko-format diskConfig:
    sudo nix --extra-experimental-features "nix-command flakes" run 'github:nix-community/disko/latest' -- --mode destroy,format,mount {{ diskConfig }}
