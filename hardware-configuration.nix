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
    initrd.kernelModules = [
      "qcom_cpufreq_hw"
      "sha1_ce"
      "smp2p"
      "rmtfs_mem"
      "smem"
      "uio_pdrv_genirq"
      "uio"
      "sch_fq_codel"
      "ppdev"
      "lp"
      "parport"
      "ip_tables"
      "x_tables"
      "autofs4"
      "overlay"
      "nls_utf8"
      "isofs"
      "nls_iso8859_1"
      "dm_mirror"
      "dm_region_hash"
      "dm_log"
      "regmap_spmi"
      "qcom_glink_rpm"
      #"qcom_glink_native"
      "rpmsg_core"
      "uas"
      "usb_storage"
      "hid_generic"
      "xhci_plat_hcd"
      "i2c_hid"
      "dwc3"
      "hid"
      "ulpi"
      "udc_core"
      "i2c_qcom_geni"
      "videocc_sdm845"
      "dwc3_qcom"
      "qcom_geni_se"
      "ufs_qcom"
      "ufshcd_pltfrm"
      "nvmem_qfprom"
      "dispcc_sdm845"
      "gpucc_sdm845"
      "spmi_pmic_arb"
      "spmi"
      "ufshcd_core"
      "phy_qcom_qusb2"
      "pinctrl_sdm845"
      "clk_rpmh"
      "qcom_rpmh_regulator"
      "gcc_sdm845"
      "clk_qcom"
      #"qcom_apc_ipc_mailbox"
      "phy_qcom_qmp"

      "bnep"
      "hci_uart"
      "btqca"
      "uvcvideo"
      "btrtl"
      "btbcm"
      "btintel"
      "videobuf2_vmalloc"
      "videobuf2_memops"
      "videobuf2_v4l2"
      "bluetooth"
      "videobuf2_common"
      "videodev"
      "pm8941_pwrkey"
      "qcom_spmi_temp_alarm"
      "qcom_spmi_adc5"
      "qcom_vadc_common"
      #"media"
      "industrialio"
      "qcom_pon"
      "pinctrl_spmi_gpio"
      "reboot_mode"
      "rtc_pm8xxx"
      "ecdh_generic"
      "ecc"
      #"aes_ce_blk"
      "crypto_simd"
      "cryptd"
      "input_leds"
      "qcom_spmi_pmic"
      "joydev"
      "reset_qcom_pdc"
      "hid_multitouch"
      "aes_ce_cipher"
      "qcom_geni_serial"
      "qcom_tsens"
      "crct10dif_ce"
      "ghash_ce"
      "aes_arm64"
      "qnoc_sdm845"
      "icc_core"
      "sha2_ce"
      "qcom_hwspinlock"
      "sha256_arm64"
      "qcom_rng"


      ### Probably all that's needed
      # qcom_smd_regulator
      # smd_rpm
      # rpmsg_core
      # qcom_glink_rpm
      # qcom_glink_native
      # qcom_apcs_ipc_mailbox
      # spmi
      # spmi_pmic_arb
      # regmap_spmi
      # qcom_spmi_pmic
      # pinctrl_spmi_gpio
      # nvmem_qfprom

    ];
    supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
  };
  hardware.firmware = lib.mkBefore [ fw ];
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
  services.upower.enable = true;
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
  systemd.package = pkgs.systemd.override { withHwdb = false; };
}
