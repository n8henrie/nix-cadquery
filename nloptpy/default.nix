{
  nlopt,
  python3Packages,
  swig,
}:
let
  inherit (python3Packages) python toPythonModule pythonImportsCheckHook;
in
toPythonModule (
  nlopt.overrideAttrs (prev: {
    configureFlags = builtins.filter (flag: flag != "--without-python") prev.configureFlags or [ ];
    buildInputs = prev.buildInputs or [ ] ++ [ swig ];
    propagatedBuildInputs = prev.propagatedBuildInputs or [ ] ++ [ python3Packages.numpy ];
    nativeCheckInputs = prev.nativeCheckInputs or [ ] ++ [
      (python.withPackages (ps: [ ps.numpy ]))
      pythonImportsCheckHook
    ];
    doCheck = true;
    pythonImportsCheck = [ "nlopt" ];
  })
)
