# nix-cadquery

My attempt to build and run [cadquery] with minimal headaches on aarch64-darwin.

NB: this is for aarch64-darwin only; if looking for Linux you might be interested in https://github.com/vinszent/cq-flake/

Currently leaning on [an existing wheel][0] for [OCP]; Struggles trying to build from source: https://discourse.nixos.org/t/hoping-to-make-a-aarch64-darwin-flake-for-cadquery-ocp-libclang-dylib-woes/28261/2

[cadquery]: https://github.com/CadQuery/cadquery
[OCP]: https://github.com/CadQuery/OCP
[0]: https://github.com/CadQuery/ocp-build-system
