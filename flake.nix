{
  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  outputs =
    { self, nixpkgs }:

    let
      system = "aarch64-darwin";
    in
    {
      packages.${system}.default =
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.python311.withPackages (
          ps: with ps; [
            jupyterlab
            numpy
            pip
            (ps.buildPythonPackage rec {
              version = "2.4.0";
              pname = "cadquery";
              format = "wheel";
              src = pkgs.fetchPypi rec {
                inherit pname version format;
                python = "py3";
                dist = python;
                hash = "sha256-ZshlseXbIFuBpd3IUz1HQVdykSks8tyAsQSunjCFsZU=";
              };
              propagatedBuildInputs = with ps; [
                ezdxf
                multimethod
                nptyping
                numpy
                pyparsing
                typing-extensions
                typish

                (toPythonModule (
                  pkgs.nlopt.overrideAttrs (prev: {
                    configureFlags = builtins.filter (each: each != "--without-python") prev.configureFlags or [ ];
                    buildInputs = prev.buildInputs or [ ] ++ [ pkgs.swig ];
                    propagatedBuildInputs = prev.propagatedBuildInputs or [ ] ++ [ numpy ];
                    nativeCheckInputs = prev.nativeCheckInputs or [ ] ++ [
                      (ps.python.withPackages (ps: [ ps.numpy ]))
                      ps.pythonImportsCheckHook
                    ];
                    doCheck = true;
                    pythonImportsCheck = [ "nlopt" ];
                  })
                ))

                (toPythonModule (
                  stdenv.mkDerivation {
                    version = "3.6.4";
                    name = "casadi";
                    buildInputs = [
                      python
                      pkgs.swig4
                    ];
                    nativeBuildInputs = [ pkgs.cmake ];
                    nativeCheckImports = [ pythonImportsCheckHook ];
                    propagatedBuildInputs = [ numpy ];
                    cmakeFlags = [
                      "-DWITH_PYTHON=ON"
                      "-DWITH_PYTHON3=ON"
                      "-DPYTHON_PREFIX=${placeholder "out"}/${ps.python.sitePackages}"
                      # Fails with:
                      # Broken paths found in a .pc file! /nix/path/to/lib/pkgconfig/tinyxml2.pc
                      "-DWITH_TINYXML=OFF"
                    ];
                    src = pkgs.fetchFromGitHub {
                      "owner" = "casadi";
                      "repo" = "casadi";
                      rev = "3.6.4";
                      hash = "sha256-BfUpSXbllQUNn5BsBQ+ZmQ15OLOp/QegT8igOxSgukE=";
                    };
                    pythonImportsCheck = [ "casadi-fake" ];
                  }
                ))

                (buildPythonPackage rec {
                  version = "7.7.2.0";
                  pname = "cadquery-ocp";
                  format = "wheel";
                  src = pkgs.fetchurl {
                    url = "https://github.com/CadQuery/ocp-build-system/releases/download/${version}/cadquery_ocp-7.7.2-cp311-cp311-macosx_11_0_arm64.whl";
                    hash = "sha256-ak0r11nMKACskWZDV+VauoicmWx0kr1ZXtY7DFF4adM=";
                  };
                  pythonImportsCheck = [ "OCP" ];
                })
              ];
              pythonImportsCheck = [ "cadquery" ];
            })
          ]
        );
    };
}
