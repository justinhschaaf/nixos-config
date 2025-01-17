{ inputs, lib, config, pkgs, system, ... }: {

    imports = [ inputs.disko.nixosModules.disko ];

    options.js.disks = {
        enable = lib.mkEnableOption "automatic boot drive partitioning";
        device = lib.mkOption {
            type = lib.types.str;
            description = "The boot device to format and partition.";
        };
        encrypt = lib.mkOption {
            type = lib.types.bool;
            description = "Whether to encrypt the swap and root partitions.";
            default = false;
        };
        swap.enable = lib.mkEnableOption "the swap partition";
        swap.size = lib.mkOption {
            type = lib.types.str;
            description = "How large to make the swap partition, in sgdisk format.";
            default = "16G";
        };
    };

    # disko your documentation is utter dogshit omfg
    # pointing us to a folder of uncommented "examples" that are designed as tests for the application is not useful whatsoever
    # and only later did I find https://github.com/nix-community/disko-templates WHICH STILL HAS NOTHING USEFUL
    config.disko.devices.disk.main = let

        # how big the MBR boot partition should be
        mbrBootSize = "1M";

        # how big the GPT boot partition (the ESP) should be
        # this is technically the endpoint of the ESP, not the size, but idgaf
        gptBootSize = "512M";

        # the default config for the btrfs system root
        rootContent = {
            type = "filesystem";
            format = "btrfs";
            mountpoint = "/";
        };

    in lib.mkIf config.js.disks.enable {

        # the disk we're trying to manage here
        device = config.js.disks.device;

        # this is a disk
        type = "disk";

        # this isn't actually the disk table type, but rather the config type
        # use "gpt", never use "table"
        content.type = "gpt";

        # Boot partitions, I was planning to make one or the other but it's almost 2025 we have the space for both
        # https://github.com/nix-community/disko-templates/blob/6b12e5fe81fc0c06989a58bd0b01f4a2efca4906/single-disk-ext4/disko-config.nix#L15-L28

        # MBR boot partition, will be created first no matter what
        # https://mbrserver.com/
        content.partitions.boot = {
            type = "EF02";
            size = mbrBootSize;
        };

        # GPT boot partition (EFI System Partition)
        content.partitions.ESP = {
            type = "EF00";
            start = mbrBootSize;
            end = gptBootSize;
            priority = 3000;
            content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
            };
        };

        # Create the swap partition at the end of the disk, if enabled
        content.partitions.swap = lib.mkIf config.js.disks.swap.enable {
            start = "-${config.js.disks.swap.size}";
            size = "100%";
            priority = 2000;
            content = {
                type = "swap";
                randomEncryption = true;
            };
        };

        # Create the data partition
        content.partitions.root = {

            # Leave enough space for both boot partitions at the start
            start = gptBootSize;

            # If we have a swap partition, leave space for it at the end
            # https://github.com/nix-community/disko/blob/3a4de9fa3a78ba7b7170dda6bd8b4cdab87c0b21/lib/types/gpt.nix#L116-L127
            end = if config.js.disks.swap.enable
                then "-${config.js.disks.swap.size}"
                else "-0";

            priority = 1000;

            # Encrypt the disk, if necessary. should prompt you to set the encryption key during setup
            # https://github.com/nix-community/disko-templates/blob/6b12e5fe81fc0c06989a58bd0b01f4a2efca4906/single-ext4-luks-and-double-zfs-mirror/disko-config.nix#L27-L42
            content = if config.js.disks.encrypt then {
                type = "luks";
                name = "cryptos";
                settings.allowDiscards = true;
                content = rootContent;
            } else rootContent;

        };

    };

}
