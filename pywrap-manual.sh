#!/usr/bin/env bash

set -Eeuf -o pipefail
shopt -s inherit_errexit
set -x

main() {
  # MAMBA_INC=$CONDA_/Library/Developer/CommandLineTools/include

  pushd OCP

  mkdir -p include
  rm -f ./include/OpenGL
  ln -s /Library/Developer/CommandLineTools/SDKs/MacOSX12.sdk/System/Library/Frameworks/OpenGL.framework/Versions/A/Headers/ ./include/OpenGL

  nix build ..#pywrap
  ./result/bin/pywrap \
    -c -v -n 1 \
    -i /Library/Developer/CommandLineTools/SDKs/MacOSX12.sdk/usr/include/c++/v1 \
    -i /Library/Developer/CommandLineTools/SDKs/MacOSX12.sdk/usr/include \
    -i /opt/homebrew/Caskroom/miniconda/base/envs/cadquery/include/vtk-9.2 \
    -l /Library/Developer/CommandLineTools/usr/lib/libclang.dylib \
    all ocp.toml
}
main "$@"
