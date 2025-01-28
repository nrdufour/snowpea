{
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation {
  pname = "mali-g610-firmware";
  version = "g24p0-3";

  src = fetchurl {
    url = "https://github.com/JeffyCN/mirrors/raw/refs/heads/libmali/firmware/g610/mali_csffw.bin";
    hash = "";
  };

  buildCommand = ''
    install -Dm444 $src $out/lib/firmware/mali_csffw.bin
  '';
}
