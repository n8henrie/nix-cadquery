{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-scalapack.url = "github:nixos/nixpkgs/70f835f9aac39630643391f152d67d111303c128";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-scalapack,
    }:

    let
      systems = [
        # "x86_64-darwin"
        "aarch64-darwin"
        # "x86_64-linux"
        # "aarch64-linux"
      ];
      eachSystem =
        with nixpkgs.lib;
        f: foldAttrs mergeAttrs { } (map (s: mapAttrs (_: v: { ${s} = v; }) (f s)) systems);
    in
    eachSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (_: _: { inherit (nixpkgs-scalapack.legacyPackages.${system}) scalapack; }) ];
        };
        python = pkgs.python311;
        overrides.python3Packages = python.pkgs;
      in
      {
        packages = {
          default = self.outputs.packages.${system}.jupyterlab-with-cadquery;
          jupyterlab-with-cadquery = python.withPackages (
            ps: with ps; [
              self.outputs.packages.${system}.cadquery
              jupyterlab
            ]
          );
          cadquery = pkgs.callPackage ./cadquery (
            overrides
            // {
              inherit (self.outputs.packages.${system}) casadipy nloptpy ocp;
              buildIpopt = false;
              # ocp = self.outputs.packages.${system}.ocp-from-conda;
            }
          );
          ocp = pkgs.callPackage ./ocp overrides;
          ocp-from-conda = pkgs.callPackage ./ocp-from-conda overrides;
          nloptpy = pkgs.callPackage ./nloptpy overrides;
          casadipy = pkgs.callPackage ./casadipy (
            overrides // { inherit (self.outputs.packages.${system}) mumps; }
          );
          mumps = pkgs.callPackage ./mumps { };
        };
      }
    );
}
