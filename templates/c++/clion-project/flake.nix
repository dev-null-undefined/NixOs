{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell/main";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshell,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devshell.overlays.default];
      };
      libs = with pkgs; [
        libjpeg_original
        ncurses
        libpng12
        zlib
      ];
      dev-deps = with pkgs; [glibc libcxx doxygen graphviz];
      package-config = rec {
        pname = "PROJECT-NAME";
        packages-name = pname;
        version = "v0.0.0";
        src = ./.;
      };
      packages = {
        ${package-config.packages-name} = pkgs.stdenv.mkDerivation rec {
          inherit (package-config) pname version src;

          nativeBuildInputs = with pkgs; [cmake];
          buildInputs = libs;

          cmakeFlags = [
            "-DENABLE_INSTALL=ON"
          ];

          meta = with pkgs.lib; {
            homepage = "";
            description = "";
            longDescription = "";
            platforms = platforms.linux;
          };
        };
        default = self.packages.${system}.${package-config.packages-name};
      };
      default-app = {
        type = "app";
        program = self.packages.${system}.default + "/bin/${package-config.pname}";
      };
    in {
      apps.default = default-app;
      devShell = pkgs.devshell.mkShell {
        name = package-config.pname;
        imports = ["${devshell}/extra/language/c.nix"];
        packages = dev-deps;

        language.c = {
          libraries = libs;
          includes = libs;
          compiler = pkgs.gcc;
        };
        commands = [
          {
            name = "compile";
            category = "c++";
            help = "Build the project using cmake";
            command = ''
              ${pkgs.cmake}/bin/cmake -S . -B build
              ${pkgs.cmake}/bin/cmake --build build
            '';
          }
        ];
        bash = {
          interactive = "zsh";
          extra = ''
            export CPLUS_INCLUDE_PATH="$C_INCLUDE_PATH"
            export LIBRARY_PATH="$LD_LIBRARY_PATH"
          '';
        };
      };

      defaultPackage = self.packages.${system}.default;

      inherit packages;
    });
}
