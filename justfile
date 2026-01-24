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
