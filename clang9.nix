{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = [ 
        pkgs.clang_9
        pkgs.llvmPackages_9.openmp
    ];
}
