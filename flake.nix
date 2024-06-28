{
  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  outputs =
    { self, nixpkgs }:

    let
      systems = [
        # "x86_64-darwin"
        "aarch64-darwin"
        "x86_64-linux"
        # "aarch64-linux"
      ];
      eachSystem =
        with nixpkgs.lib;
        f: foldAttrs mergeAttrs { } (map (s: mapAttrs (_: v: { ${s} = v; }) (f s)) systems);
    in
    eachSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = self.outputs.packages.${system}.jupyterlab-with-cadquery;
          jupyterlab-with-cadquery = pkgs.python311.withPackages (
            ps: with ps; [
              self.outputs.packages.${system}.cadquery
              jupyterlab
            ]
          );
          cadquery = pkgs.callPackage ./cadquery { };
        };
      }
    );
}
