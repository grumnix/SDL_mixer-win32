{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

    tinycmmc.url = "github:grumbel/tinycmmc";
    tinycmmc.inputs.nixpkgs.follows = "nixpkgs";

    SDL-win32.url = "github:grumnix/SDL-win32";
    SDL-win32.inputs.nixpkgs.follows = "nixpkgs";
    SDL-win32.inputs.tinycmmc.follows = "tinycmmc";

    SDL_mixer_src.url = "https://github.com/libsdl-org/SDL_mixer/archive/refs/tags/release-1.2.12.tar.gz";
    SDL_mixer_src.flake = false;
  };

  outputs = { self, nixpkgs, tinycmmc, SDL-win32, SDL_mixer_src }:
    tinycmmc.lib.eachWin32SystemWithPkgs (pkgs:
      {
        packages = rec {
          default = SDL_mixer;

          SDL_mixer = pkgs.stdenv.mkDerivation {
            pname = "SDL_mixer";
            version = "1.2.12";

            src = SDL_mixer_src;

            postPatch = ''
              # Fix undefined reference to WinMain@16 due to library ordering
              substituteInPlace Makefile.in \
                --replace '$(SDL_CFLAGS) $(SDL_LIBS) $(objects)/$(TARGET)' \
                          '$(objects)/$(TARGET) $(SDL_CFLAGS) $(SDL_LIBS)'
            '';

            nativeBuildInputs = [
              pkgs.buildPackages.pkgconfig
            ];

            buildInputs = [
              SDL-win32.packages.${pkgs.system}.default
            ];
          };
        };
      }
    );
}
