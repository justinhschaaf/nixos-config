{ inputs, lib, config, pkgs, ... }: {

    options.js.hardware.amd = {
        cpu.enable = lib.mkEnableOption "AMD CPU support";
        gpu.enable = lib.mkEnableOption "AMD GPU support";
    };

    # Guess what? The following code does not work:
    #
    # ```nix
    # config = lib.mkIf config.js.hardware.amd.cpu.enable {
    #     ...
    # } // lib.mkIf config.js.hardware.amd.gpu.enable {
    #     ...
    # };
    # ```
    #
    # that's because if cpu is enabled and gpu is disabled, it evaluates to
    # this:
    #
    # ```nix
    # {
    #     _type = "if";
    #     condition = false;
    #     content = { ... };
    # }
    # ```
    #
    # that's right! nothing is real in this stupid fucking language. "well,
    # there MUST be a better way, right?" you may be yelling at your computer
    # screen. how about the following?
    #
    # - replacing lib.mkIf with a normal if/then/else statment does not work.
    #   using "config" in the condition causes an infinite recursion error.
    # - separating the "config =" into two separate statements does not work.
    #   you can't duplicate your keys like that.
    #
    # so how did i figure out to use lib.mkMerge? i asked an llm--which i hate
    # doing. looking up lib.mkMerge after the fact, documentation on it is
    # (naturally) near impossible to find unless you already know exactly what
    # you're looking for.
    #
    # - it certainly isn't where i usually go to figure out if nix has a
    #   function for something: https://teu5us.github.io/nix-lib.html
    # - it apparently *is* mentioned in the manual, once, here
    #   https://nixos.org/manual/nixos/stable/#sec-option-definitions-merging
    #   to all the people who say "read the fucking manual," do you have any
    #   idea how long it is? 69,908 words, or roughly 4 hours 14 minutes of
    #   reading (without stopping)
    # - it isn't even used once on the wiki.
    #
    # i love everything nix stands for but my god is the programming language
    # a fucking abomination designed by sadists who want to inflict pain on you
    # for trying to do anything or figure out anything.
    #
    # i am sorry, i am absolutely livid rn...
    config = lib.mkMerge [
        (lib.mkIf config.js.hardware.amd.cpu.enable {
            boot.kernelModules = [ "kvm-amd" ];
            nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
            hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        })

        (lib.mkIf config.js.hardware.amd.gpu.enable {
            hardware.amdgpu.initrd.enable = true;

            # Install GPU overclock controller https://wiki.nixos.org/wiki/AMD_GPU#GUI_tools
            environment.systemPackages = with pkgs; [ lact ];
            systemd.packages = with pkgs; [ lact ];
            systemd.services.lactd.wantedBy = [ "multi-user.target" ];
        })
    ];

}

