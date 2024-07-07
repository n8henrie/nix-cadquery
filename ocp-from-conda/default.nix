{
  stdenv,
  fetchurl,
  unzip,
  zstd,
  python3Packages,
}:
let
  version = "7.7.2.1";
  pyVer = builtins.replaceStrings [ "." ] [ "" ] python3Packages.python.pythonVersion;
  srcmap = {
    "311" = {
      url = "https://anaconda.org/conda-forge/ocp/${version}/download/osx-arm64/ocp-${version}-py${pyVer}hc15e398_0.conda";
      hash = "sha256-Hri2aSjP4UuzpfNEchXb6812x9H8KRD/pDSyPO2bmIc=";
    };
    "312" = {
      url = "https://anaconda.org/conda-forge/ocp/${version}/download/osx-arm64/ocp-${version}-py${pyVer}h61b92f9_0.conda";
      hash = "sha256-bNvsLScLZ9tSOOWflYj/ing6XdWsUeotnC0WAbkXVJc=";
    };
  };
  inherit (python3Packages) toPythonModule;
  inherit (python3Packages.python) sitePackages;
in
toPythonModule (
  stdenv.mkDerivation {
    name = "cadquery-conda";
    inherit version;
    src = fetchurl srcmap.${pyVer};
    dontUnpack = true;
    nativeBuildInputs = [
      unzip
      zstd
    ];
    buildPhase = ''
      unzip $src
      tar -xf pkg-ocp-${version}-*.tar.zst

      dest=$out/${sitePackages}
      mkdir -p $dest
      cp ${sitePackages}/OCP.cpython-${pyVer}-darwin.so $dest
      cp -r ${sitePackages}/OCP-stubs $dest
    '';
  }
)
