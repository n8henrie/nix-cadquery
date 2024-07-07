{
  stdenv,
  fetchFromGitHub,
  fetchurl,
  fetchzip,
  cmake,
  gfortran,
  lapack,
  mpi,
  scalapack,
}:
# https://github.com/coin-or/Ipopt/pull/744/files
# https://github.com/dzmitry-lahoda-forks/mumps/blob/dz/1/flake.nix
let
  version = "5.7.2";
  sha256 = "1362d377ce7422fc886c55212b4a4d2c381918b5ca4478f682a22d0627a8fbf8";
  mumps-src = fetchurl {
    url = "https://mumps-solver.org/MUMPS_${version}.tar.gz";
    inherit sha256;
  };
  mumps-src-unzip = fetchzip {
    url = "https://mumps-solver.org/MUMPS_${version}.tar.gz";
    hash = "sha256-8El59ljlxryQF1HsbWzUxquRNuGg7QlKDZ47RyuX/R4=";
  };
in
stdenv.mkDerivation {
  name = "mumps";
  inherit version;
  nativeBuildInputs = [ cmake ];
  buildInputs = [
    gfortran
    lapack
    mpi
    scalapack
  ];
  # enableParallelBuilding = true;
  src = fetchFromGitHub {
    owner = "scivision";
    repo = "mumps";
    rev = "v${version}.0";
    hash = "sha256-IoVByeXHjxx2a0+rvJqTFl4nngo8XLc1vp//LO4khqk=";
  };
  patchPhase = ''
    mkdir -p build/mumps-subbuild/mumps-populate-prefix/src
    cp ${mumps-src} build/mumps-subbuild/mumps-populate-prefix/src/MUMPS_${version}.tar.gz
    substituteInPlace CMakeLists.txt \
      --replace "FetchContent_Populate(\''${PROJECT_NAME}" "FetchContent_Populate(\''${PROJECT_NAME} URL_HASH SHA256=${sha256}"

    # set -x
    # mkdir -p build/mumps_src
    # cp --dereference --no-preserve=mode,ownership --recursive --force ${mumps-src-unzip}/** build/mumps_src/
  '';
  cmakeFlags = [
    # Seems like this *should* work but can't figure it out
    # https://cmake.org/cmake/help/latest/module/FetchContent.html#variable:FETCHCONTENT_SOURCE_DIR_%3CuppercaseName%3E

    # "-D FETCHCONTENT_SOURCE_DIR_MUMPS=${mumps-src-unzip}"
    "-D MUMPS_UPSTREAM_VERSION=${version}"
    # "-D BUILD_SHARED_LIBS=on"
  ];
}
