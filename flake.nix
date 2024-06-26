{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-24.05";

    tinycmmc.url = "github:grumbel/tinycmmc";
    tinycmmc.inputs.nixpkgs.follows = "nixpkgs";

    libmikmod-win32.url = "github:grumnix/libmikmod-win32";
    libmikmod-win32.inputs.nixpkgs.follows = "nixpkgs";
    libmikmod-win32.inputs.tinycmmc.follows = "tinycmmc";

    libogg-win32.url = "github:grumnix/libogg-win32";
    libogg-win32.inputs.nixpkgs.follows = "nixpkgs";
    libogg-win32.inputs.tinycmmc.follows = "tinycmmc";

    libvorbis-win32.url = "github:grumnix/libvorbis-win32";
    libvorbis-win32.inputs.nixpkgs.follows = "nixpkgs";
    libvorbis-win32.inputs.tinycmmc.follows = "tinycmmc";
    libvorbis-win32.inputs.libogg.follows = "libogg-win32";

    SDL-win32.url = "github:grumnix/SDL-win32";
    SDL-win32.inputs.nixpkgs.follows = "nixpkgs";
    SDL-win32.inputs.tinycmmc.follows = "tinycmmc";

    SDL_mixer_src.url = "https://github.com/libsdl-org/SDL_mixer/archive/refs/tags/release-1.2.12.tar.gz";
    SDL_mixer_src.flake = false;
  };

  outputs = { self, nixpkgs, tinycmmc, libmikmod-win32, libogg-win32, libvorbis-win32, SDL-win32, SDL_mixer_src }:
    tinycmmc.lib.eachWin32SystemWithPkgs (pkgs:
      {
        packages = rec {
          default = SDL_mixer;

          SDL_mixer = pkgs.stdenv.mkDerivation {
            pname = "SDL_mixer";
            version = "1.2.12";

            src = SDL_mixer_src;

            LIBMIKMOD_CONFIG = "${libmikmod-win32.packages.${pkgs.system}.default}/bin/libmikmod-config";

            postPatch = ''
              # Fix undefined reference to WinMain@16 due to library ordering
              substituteInPlace Makefile.in \
                --replace '$(SDL_CFLAGS) $(SDL_LIBS) $(objects)/$(TARGET)' \
                          '$(objects)/$(TARGET) $(SDL_CFLAGS) $(SDL_LIBS)'
            '';

            postFixup = ''
              ln -sfv ${libmikmod-win32.packages.${pkgs.system}.default}/bin/*.dll $out/bin/
              ln -sfv ${libogg-win32.packages.${pkgs.system}.default}/bin/*.dll $out/bin/
              ln -sfv ${libvorbis-win32.packages.${pkgs.system}.default}/bin/*.dll $out/bin/
            '';

            nativeBuildInputs = [
              pkgs.buildPackages.pkg-config
            ];

            buildInputs = [
              SDL-win32.packages.${pkgs.system}.default

              libogg-win32.packages.${pkgs.system}.default
              libvorbis-win32.packages.${pkgs.system}.default
              libmikmod-win32.packages.${pkgs.system}.default
            ];
          };
        };
      }
    );
}
