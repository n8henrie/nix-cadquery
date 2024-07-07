{
  lib,
  python3Packages,
  fetchurl,
}:
let
  version = "7.7.2.0";
in
python3Packages.buildPythonPackage {
  pname = "cadquery-ocp";
  inherit version;
  format = "wheel";
  src =
    let
      pyVer =
        let
          inherit (python3Packages.python.sourceVersion) major minor;
        in
        "${major}${minor}";
      shortVer =
        with lib;
        concatStringsSep "." (reverseList (drop 1 (reverseList (splitString "." version))));
    in
    fetchurl {
      url = "https://github.com/CadQuery/ocp-build-system/releases/download/${version}/cadquery_ocp-${shortVer}-cp${pyVer}-cp${pyVer}-macosx_11_0_arm64.whl";
      hash = "sha256-ak0r11nMKACskWZDV+VauoicmWx0kr1ZXtY7DFF4adM=";
      # python312
      # hash = "sha256-Uf+81tNW1PDC5fnhWBImEhzXMP5FIeq6wF6dceakP28=";
    };
  pythonImportsCheck = [ "OCP" ];
}
