{ ... }:

{
  imports = [
    ./base.nix
    ./python.nix
    ./rust.nix
    ./go.nix
    ./node.nix
    ./dotnet.nix
    ./java.nix
    ./c.nix
    ./db.nix
    ./infra.nix
  ];
}
