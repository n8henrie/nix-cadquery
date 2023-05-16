- Using libclang from nix instead of
`/Library/Developer/CommandLineTools/usr/lib/libclang.dylib` results in `'stdarg.h' file not found`
    - Maybe including `/Library/Developer/CommandLineTools/usr/lib/clang/14.0.3/include/stdarg.h`

Can't seem to find
```console
$ ls "$(nix path-info github:nixos/nixpkgs#darwin.apple_sdk)"
```

Using `-l /Library/Developer/CommandLineTools/usr/lib/libclang.dylib`
