{
  description = "forgejo-tf";
  
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
  outputs = {self, nixpkgs}: 
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      nixpkgsFor = forAllSystems(system: import nixpkgs {
        inherit system;
      });
    in {
      packages = forAllSystems(system: 
        let
          pkgs = nixpkgsFor.${system};
          cluster-name = "forgejo-tf";
        in {
          launch-k3d = pkgs.writeScriptBin "launch-k3d" ''
            ${pkgs.k3d}/bin/k3d cluster create ${cluster-name}
            ${pkgs.k3d}/bin/k3d kubeconfig get ${cluster-name} > kubeconfig
          '';
          destroy-cluster = pkgs.writeScriptBin "destroy-cluster" ''
            ${pkgs.k3d}/bin/k3d cluster delete ${cluster-name}
          '';
        });

      devShells = forAllSystems(system: 
        let
          pkgs = nixpkgsFor.${system};
        in {
          default = pkgs.mkShell {
          buildInputs = with pkgs; [
            k3d
            self.packages.${system}.launch-k3d
            self.packages.${system}.destroy-cluster
            kubectl
            k9s
            opentofu
            treefmt
            velero
          ];
          shellHook = ''
            export PS1='[$PWD]\n❄ '
          '';
          };
        });
    };
}
