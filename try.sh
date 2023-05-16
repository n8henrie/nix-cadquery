#!/usr/bin/env bash

set -Eeuf -o pipefail
shopt -s inherit_errexit
set -x

main() {
  pushd OCP

  PREFIX=/Library/Developer/CommandLineTools
  SDK=SDKs/MacOSX12.sdk
  CPP_INC=$PREFIX/$SDK/usr/include/c++/v1/
  C_INC=$PREFIX/$SDK/usr/include/

  # fatal error: 'type_traits' file not found
  # -i "$(nix path-info nixpkgs#llvmPackages_14.libcxx.dev)/include/c++/v1" \

  # fatal error: 'stddef.h' file not found
  # -i "$(nix path-info nixpkgs#llvmPackages_14.libclang.lib)/lib/clang/14.0.6/include" \

  # -i "$(nix path-info nixpkgs#llvmPackages_14.libcxx.dev)/include/c++/v1" \
  # pywrapFlags = builtins.concatStringsSep " " (
  #     map (p: ''-i '' + p) [
  #       "${rapidjson}/include"
  #       "${vtk_9}/include/vtk-${vtk_main_version}/"
  #       "${xorg.xorgproto}/include"
  #       "${xorg.libX11.dev}/include"
  #       "${libglvnd.dev}/include"
  #       "${stdenv.cc.cc}/include/c++/${stdenv.cc.version}"
  #       "${stdenv.cc.cc}/include/c++/${stdenv.cc.version}/x86_64-unknown-linux-gnu"
  #       "${stdenv.cc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${stdenv.cc.version}/include-fixed"
  #       "${stdenv.cc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${stdenv.cc.version}/include"
  #     ]
  #   );

  # -i "$(nix path-info nixpkgs#llvmPackages.stdenv.cc.cc.lib)/lib" \
  # -i "$(nix path-info github:nixos/nixpkgs/master#darwin.apple_sdk.MacOSX-SDK)
  # -l "$(nix path-info github:nixos/nixpkgs/master#darwin.apple_sdk.MacOSX-SDK)
  # -l "$(nix path-info nixpkgs#llvmPackages_14.clang-unwrapped.lib)/lib/libclang.dylib" \

  pywrap -c -v \
    -l /Library/Developer/CommandLineTools/usr/lib/libclang.dylib \
    all ocp.toml
}
main "$@"
