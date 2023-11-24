{
  description = "a very simple and friendly flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells = rec {
          default = pkgs.mkShell {
            packages = [ pkgs.python38 ];
          };
        };
        packages = rec {
          hello = pkgs.stdenv.mkDerivation rec {
            name = "run-web-server";

            src = ./.;

            unpackPhase = "true";

            buildPhase = ":";

            installPhase = ''
              mkdir -p $out/bin
              echo '#!${pkgs.python38}/bin/python3' > $out/bin/run-web-server
              echo 'import http.server' >> $out/bin/run-web-server
              echo 'import socketserver' >> $out/bin/run-web-server
              echo 'port = 8000' >> $out/bin/run-web-server
              echo 'handler = http.server.SimpleHTTPRequestHandler' >> $out/bin/run-web-server
              echo 'with socketserver.TCPServer(("", port), handler) as httpd:' >> $out/bin/run-web-server
              echo '    print(f"Server started at http://localhost:{port}/")' >> $out/bin/run-web-server
              echo '    httpd.serve_forever()' >> $out/bin/run-web-server
              chmod +x $out/bin/run-web-server
            '';
          };
          default = hello;
        };

        apps = rec {
          hello = flake-utils.lib.mkApp { drv = self.packages.${system}.hello; };
          default = hello;
        };
      }
    );
}

