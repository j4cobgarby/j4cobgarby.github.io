with import <nixpkgs> {};

mkShell {
  buildInputs = [
    bundler
    caddy
  ];
}
