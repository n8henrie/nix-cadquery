# nix-cadquery [![CI](https://github.com/n8henrie/nix-cadquery/actions/workflows/ci.yml/badge.svg)](https://github.com/n8henrie/nix-cadquery/actions/workflows/ci.yml)

My attempt to build and run [cadquery] with minimal headaches on aarch64-darwin.

NB: this is for aarch64-darwin only; if looking for Linux you might be
interested in https://github.com/vinszent/cq-flake/

Currently leaning on [an existing wheel][0] for [OCP]. I would love to make it so that:

- OCP was built from source, likely using [pywrap](https://github.com/CadQuery/
pywrap) instead of just downloading a binary wheel
- casadi was built with ipopt support, which I think would make it so a good
number of the currently disabled tests could pass

If anyone thinks they could help with the above, PRs are appreciated! I have
left the groundwork for some of this laying around, disabled by the `buildIpopt`
option.

Some of my attempts and struggles:
https://discourse.nixos.org/t/hoping-to-make-a-aarch64-darwin-flake-for-cadquery-ocp-libclang-dylib-woes/28261/2

[cadquery]: https://github.com/CadQuery/cadquery
[OCP]: https://github.com/CadQuery/OCP
[0]: https://github.com/CadQuery/ocp-build-system
