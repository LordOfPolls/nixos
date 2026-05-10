{ pkgs, ... }:

{
  home.packages = with pkgs; [
    docker-compose
    minikube
  ];
}
