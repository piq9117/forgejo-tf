{
  description = "forgejo-tf";
  
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;

  inputs.forgejo-tf-gen.url = "git+ssh://git@git.piq9117.com:2222/piq9117/forgejo-tf-gen.git";
  outputs = {self, nixpkgs, forgejo-tf-gen}: 
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
          forgejo-tf-gen = pkgs.buildGoModule {
            pname = "forgejo-tf-gen";
            version = "0.1.0";
            src = forgejo-tf-gen;
            vendorHash = "sha256-ELU8TiKtj/2LEtO9hKQXAswjiy7nzLSKUIbLuZAwghY=";
          };
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
            self.packages.${system}.forgejo-tf-gen
          ];
          shellHook = ''
            export PS1='[$PWD]\n❄ '
          '';
          };
        });
    };
}
