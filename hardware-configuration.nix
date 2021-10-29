{config, pkgs, ...}:

let
  dbfw = pkgs.fetchzip {
    url = "http://releases.linaro.org/96boards/dragonboard845c/qualcomm/firmware/RB3_firmware_20190529180356-v4.zip";
    sha256 = "1apw6aarc5hqjzigrpygbh4rv0r953dhidjwsfscspvl8yqiv6p5";
  };
  fw = pkgs.runCommand "c630-fw" {inherit dbfw;} ''
    mkdir -p $out/lib/firmware
    cp $dbfw/18-adreno-fw/a630_sqe.fw $out/lib/firmware
    cp $dbfw/18-adreno-fw/a630_gmu.fw $out/lib/firmware
  '';
in {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };
}
