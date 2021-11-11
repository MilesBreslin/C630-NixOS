{config, pkgs, lib, ...}:

let
  dbfw = pkgs.fetchzip {
    url = "http://releases.linaro.org/96boards/dragonboard845c/qualcomm/firmware/RB3_firmware_20190529180356-v4.zip";
    sha256 = "1apw6aarc5hqjzigrpygbh4rv0r953dhidjwsfscspvl8yqiv6p5";
    stripRoot = false;
  };
  fw = pkgs.runCommand "c630-fw" {inherit dbfw aarch64Laptops;} ''
    mkdir -p $out/lib/firmware
    cp $dbfw/18-adreno-fw/a630_sqe.fw $out/lib/firmware
    cp $aarch64Laptops/misc/lenovo-yoga-c630/gpu/firmware/a630_gmu.bin $out/lib/firmware
  '';
  aarch64Laptops = pkgs.fetchzip {
    url = "https://github.com/aarch64-laptops/build/archive/dfce25bc12655713c7e1e0422b191e9c944e4fb2.zip";
    sha256 = "0cffp3h3jrf0r1qg1xjmwadwds12nnab3crh3r1xdv6mmk72597f";
  };
  kernel = pkgs.linux_latest;
in {
  boot = {
    kernelPackages = pkgs.linuxPackagesFor kernel;
    kernelParams = [
      "efi=novamap"
      "ignore_loglevel"
      "clk_ignore_unused"
      "pd_ignore_unused"
      "console=tty0"
    ];
    supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
  };
  hardware.firmware = [ fw ];
  hardware.enableRedistributableFirmware = true;
  hardware.deviceTree = {
    enable = true;
    filter = "sdm850-lenovo-yoga-c630.*";
  };
  isoImage.contents = [
    {
      source = "${config.hardware.deviceTree.package}";
      target = "dt";
    }
    {
      source = ./laptop-lenovo-yoga-c630.dtb;
      target = "laptop-lenovo-yoga-c630.dtb";
    }
  ];
#  hardware.deviceTree.overlays = [
#    {
#      name = "GPU";
#      dtboFile = aarch64Laptops + "/misc/lenovo-yoga-c630/gpu/dtb/sdm850-lenovo-yoga-c630.dtb";
#    }
#    {
#      name = "C630";
#      dtsFile = aarch64Laptops + "/misc/lenovo-yoga-c630/laptop-lenovo-yoga-c630.dts";
#    }
#  ];
}
