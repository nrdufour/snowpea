{ fetchFromGitHub, stdenvNoCC, ... }: stdenvNoCC.mkDerivation {
    pname = "orangepi-firmware";
    version = "2024.10.09";
    dontBuild = true;
    dontFixup = true;
    compressFirmware = false;

    src = fetchFromGitHub {
        owner = "orangepi-xunlong";
        repo = "firmware";
        # latest as of 2025/01/28 - version committed on 2024/10/09
        rev = "75ea6fc5f3c454861b39b33823cb6876f3eca598";
        hash = "";
    };

    installPhase = ''
        runHook preInstall

        mkdir -p $out/lib/firmware
        cp -a * $out/lib/firmware/

        runHook postInstall
    '';
}
