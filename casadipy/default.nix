{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  cmake,
  pkg-config,
  blas,
  gfortran,
  ipopt,
  lapack,
  metis,
  mpi,
  mumps,
  # scotch, # not packaged for macos
  swig4,
  runPytestTests ? false,
}:
let
  inherit (python3Packages) python toPythonModule pythonImportsCheckHook;
  version = "3.6.4";
in
toPythonModule (
  stdenv.mkDerivation {
    name = "casadi";
    nativeBuildInputs = [
      cmake
      pkg-config
    ];
    buildInputs =
      [
        ipopt
        swig4
      ]
      ++ (lib.optionals runPytestTests [
        blas
        lapack
        metis
        mpi
        mumps
        python
        (ipopt.overrideAttrs (prev: {
          configureFlags = prev.configureFlags or [ ] ++ [
            # "--disable-mpiinit"
            "--with-mumps-cflags='-I${mumps}/include'"
            "--with-mumps-lflags=-ldmumps"
          ];
          preConfigure = ''
            configureFlagsArray+=("--with-mumps-lflags='-L${mumps}/lib -ldmumps -lmumps_common -lpord -L${metis}/lib -lmetis'")
          '';
          buildInputs = prev.buildInputs ++ [
            metis
            mpi
            mumps
            gfortran
            # scotch
          ];
        }))
      ]);
    enableParallelBuilding = true;
    nativeCheckInputs = [ pythonImportsCheckHook ];
    propagatedBuildInputs = [ python3Packages.numpy ];
    cmakeFlags =
      [
        "-DWITH_PYTHON=ON"
        "-DWITH_PYTHON3=ON"
        "-DPYTHON_PREFIX=${placeholder "out"}/${python.sitePackages}"
        # Fails with:
        # Broken paths found in a .pc file! /nix/path/to/lib/pkgconfig/tinyxml2.pc
        "-DWITH_TINYXML=OFF"
      ]
      ++ lib.optionals runPytestTests [
        "-DWITH_IPOPT=ON"
        "-DWITH_MUMPS=ON"
        "-DMUMPS_LIBRARIES=${mumps}/lib"
      ];
    src = fetchFromGitHub {
      "owner" = "casadi";
      "repo" = "casadi";
      rev = version;
      hash = "sha256-BfUpSXbllQUNn5BsBQ+ZmQ15OLOp/QegT8igOxSgukE=";
    };
    doCheck = true;
    pythonImportsCheck = [ "casadi" ];
  }
  // lib.mkIf runPytestTests { MUMPS = lib.toString mumps; }
)
