flake := "/etc/nixos#april"

# rebuild and switch to new config
switch:
    sudo nixos-rebuild switch --flake {{flake}} \
        && notify-send -u normal "NixOS" "Switch succeeded" \
        || { notify-send -u critical "NixOS" "Switch failed"; exit 1; }


# rebuild, switch, then git commit with generation info in the message
commit: switch
    gen=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -1 | awk '{print $1}') && \
    git -C /etc/nixos commit -m "nixos: switch to generation $gen"


# build and set as next boot target (no immediate activation)
boot:
    sudo nixos-rebuild boot --flake {{flake}} \
        && notify-send -u normal "NixOS" "Boot build succeeded" \
        || { notify-send -u critical "NixOS" "Boot build failed"; exit 1; }


# show what would change without building
dry:
    sudo nixos-rebuild dry-run --flake {{flake}} \
        && notify-send -u normal "NixOS" "Dry-run succeeded" \
        || { notify-send -u critical "NixOS" "Dry-run failed"; exit 1; }


# update all flake inputs then switch, showing package diff
update:
    sudo nix flake update --flake /etc/nixos \
        && sudo nixos-rebuild switch --flake {{flake}} \
        && notify-send -u normal "NixOS" "Update succeeded" \
        || { notify-send -u critical "NixOS" "Update failed"; exit 1; }


# update a single input: just bump nixpkgs
bump input:
    sudo nix flake update --flake /etc/nixos {{input}} \
        && sudo nixos-rebuild switch --flake {{flake}} \
        && notify-send -u normal "NixOS" "Bump of '{{input}}' succeeded" \
        || { notify-send -u critical "NixOS" "Bump of '{{input}}' failed"; exit 1; }


# rollback to previous generation
rollback:
    sudo nixos-rebuild switch --rollback


# list system generations
generations:
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system


# run garbage collection (removes generations older than 14d)
gc:
    sudo nix-collect-garbage --delete-older-than 14d


# hard clean: remove all old generations then gc
clean:
    sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system
    sudo nix-collect-garbage -d
    sudo nix store optimise
