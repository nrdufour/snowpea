{
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation {
  pname = "mali-g610-firmware";
  version = "g24p0-3";

  src = fetchurl {
    url = "https://github.com/JeffyCN/mirrors/raw/refs/heads/libmali/firmware/g610/mali_csffw.bin";
    hash = "sha256-YP+jdu3sjEAtwO6TV8aF2DXsLg+z0HePMD0IqYAtV/E=";
  };

  buildCommand = ''
    install -Dm444 $src $out/lib/firmware/mali_csffw.bin
  '';
}
