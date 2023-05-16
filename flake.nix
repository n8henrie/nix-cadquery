{
  description = "WIP: Flake to built and run CadQuery in JupyterLab on M1 Mac";

  # inputs.nixpkgs.url = "github:nixos/nixpkgs/release-22.11";
  # Required for apple_sdk 12.0
  # inputs.nixpkgs.url = "github:nixos/nixpkgs/master";
  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "aarch64-darwin";
  in {
    packages.${system} = let
      pkgs = import nixpkgs {inherit system;};
      stdenv = pkgs.darwin.apple_sdk.clang14Stdenv;
      inherit (pkgs) lib;
    in {
      default = self.outputs.packages.${system}.ocp;

      clang-python = with pkgs.python3Packages;
        buildPythonPackage rec {
          inherit stdenv;
          inherit (stdenv.cc.cc) version;
          pname = "clang";

          src = "${stdenv.cc.cc.src}/clang/bindings/python";
          propagatedBuildInputs = [setuptools];
          # CLANG_LIBRARY_PATH = lib.makeLibraryPath [libclang.lib];
          format = "pyproject";
          postUnpack = let
            pyproject_toml = pkgs.writeText "pyproject.toml" ''
              [build-system]
              requires = [ "setuptools>=42", "wheel" ]
              build-backend = "setuptools.build_meta"

              [project]
              name = "clang"
              version = "${version}"
            '';
          in ''
            cp '${pyproject_toml}' $sourceRoot/pyproject.toml
          '';
          # unpackPhase = let
          #   pyproject_toml = pkgs.writeText "pyproject.toml" ''
          #     [build-system]
          #     requires = [ "setuptools>=42", "wheel" ]
          #     build-backend = "setuptools.build_meta"

          #     [project]
          #     name = "clang"
          #     version = "${version}"
          #   '';
          # in ''
          #   export sourceRoot=$PWD/source
          #   mkdir $sourceRoot
          #   tar xf ${stdenv.cc.cc.src}
          #   cp -rv --no-preserve=mode clang-${stdenv.cc.version}.src/bindings/python/* $sourceRoot/
          #   cp '${pyproject_toml}' $sourceRoot/pyproject.toml
          # '';
        };

      pywrap = with pkgs.python3Packages;
        buildPythonPackage {
          inherit stdenv;
          pname = "pywrap";
          version = "07f85fc";

          src = pkgs.fetchFromGitHub {
            owner = "CadQuery";
            repo = "pywrap";
            rev = "07f85fc";
            sha256 = "ktyIDnmF+gGLtBquGJ4wgxU2bjPe85Yv6na99ZIUC7k=";
          };

          propagatedBuildInputs = [
            click
            jinja2
            joblib
            logzero
            pandas
            path
            pybind11
            pyparsing
            schema
            toml
            toposort
            tqdm

            self.packages.${system}.clang-python
          ];

          meta = {
            homepage = "https://github.com/CadQuery/pywrap";
            description = "PyWrap is a C++ binding generator using pybind11, libclang and jinja.";
            license = lib.licenses.asl20;
            maintainers = with maintainers; [];
          };
        };

      ocp = let
        pythonWithPywrap = pkgs.python3.withPackages (ps:
          with ps; [
            joblib
            setuptools
            pybind11
            self.packages.${system}.pywrap
          ]);
      in
        stdenv.mkDerivation {
          pname = "OCP";
          version = "7.5.3.0";

          src = pkgs.fetchFromGitHub {
            owner = "CadQuery";
            repo = "OCP";
            rev = "7.5.3.0";
            sha256 = "jaZVsbMWSuLNnLlRzDp4ZEKqZLXC8OAp+i8/jKbMRJg=";
          };

          buildInputs = with pkgs; [
            llvmPackages_14.libclang
            llvmPackages_14.libcxxClang
            # boost
            cmake
            darwin.apple_sdk.frameworks.OpenGL
            opencascade-occt
            # (opencascade-occt.override {vtk = vtk_9;})
            pythonWithPywrap
            pkg-config
            rapidjson
            vtk_9
          ];

          # type_traits: -i "$(nix path-info github:nixos/nixpkgs#llvmPackages_14.libcxx.dev)/include/c++/v1" \
          # -l "$(nix path-info github:nixos/nixpkgs#llvmPackages_14.libcxxStdenv.cc.cc.lib)/lib/libclang.dylib" \
          configurePhase = ''
            pywrap \
            -i "$(nix path-info github:nixos/nixpkgs#llvmPackages_14.libcxx.dev)/include/c++/v1" \
            -l "$(nix path-info github:nixos/nixpkgs#llvmPackages_14.libcxxStdenv.cc.cc.lib)/lib/libclang.dylib" \
              all ocp.toml
          '';

          buildPhase = ''
            cmake -S OCP -B build
            cmake --build build
          '';

          # BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${llvmPackages.libclang.lib}/lib/clang/${lib.getVersion clang}/include";

          # cmakeFlags = [
          #   "-DPYTHON_EXECUTABLE=${python}/bin/python"
          # ];
          #   "-DOCE_INSTALL_PREFIX=${placeholder "out"}"
          #   "-DOCE_WITH_FREEIMAGE=ON"
          #   "-DOCE_WITH_VTK=ON"
          #   "-DOCE_WITH_GL2PS=ON"
          #   "-DOCE_MULTITHREAD_LIBRARY=TBB"
          # ];
          meta = {
            homepage = "https://github.com/CadQuery/OCP";
            description = "Python wrapper for OCCT generated using pywrap.";
            license = lib.licenses.asl20;
            maintainers = with pkgs.maintainers; [];
          };
        };
    };
  };
}
