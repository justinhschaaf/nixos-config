{ inputs, lib, config, pkgs, ... }: {

    options = {
        js.programs.desktop.enable = lib.mkEnableOption "desktop applications";
    };

    config = lib.mkIf config.js.programs.desktop.enable {

        environment.systemPackages = with pkgs; [

            # System Utils
            kitty
            gparted
            naps2
            overskride
            pwvucontrol
            resources
            wdisplays

            # File Viewers
            file-roller
            xreader
            mpv
            nomacs

            # Browsers
            ungoogled-chromium

        ];

        # mpv scripts
        nixpkgs.overlays = [
            (self: super: {
                mpv = super.mpv-unwrapped.wrapper {
                    mpv = pkgs.mpv-unwrapped;
                    scripts = with self.mpvScripts; [
                        mpris
                        uosc
                        visualizer
                        vr-reversal
                    ];
                    extraMakeWrapperArgs = [ "--add-flags" "--keep-open=always" ];
                };
            })
        ];

        # Flatpak config
        services.flatpak.remotes.flathub = "https://dl.flathub.org/repo/flathub.flatpakrepo";

        # Allow running AppImages https://wiki.nixos.org/wiki/Appimage
        boot.binfmt.registrations.appimage = {
            wrapInterpreterInShell = false;
            interpreter = "${pkgs.appimage-run}/bin/appimage-run";
            recognitionType = "magic";
            offset = 0;
            mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
            magicOrExtension = ''\x7fELF....AI\x02'';
        };

        # enable localsend, airdrop alternative
        programs.localsend.enable = true;
        programs.localsend.openFirewall = true;

        # obs for screen recording, must be system-level for virtual camera
        programs.obs-studio.enable = true;
        programs.obs-studio.enableVirtualCamera = true;

        # Firefox web browser
        programs.firefox = {

            enable = true;

            wrapperConfig.pipewireSupport = true;

            preferences = {

                # Make Firefox use the xdg portal picker
                # Setting GDK_USE_PORTAL for everything fucks everything up
                "widget.use-xdg-desktop-portal.file-picker" = 1;

                # Make sure the bookmarks toolbar never shows up
                "browser.toolbars.bookmarks.visibility" = "never";
                "browser.toolbars.bookmarks.showOtherBookmarks" = false;

            };

            policies = {

                #
                # PERSONAL PREFS
                #

                PromptForDownloadLocation = true;

                # Set the homepage
                Homepage = {
                    Locked = true;
                    URL = "https://justinschaaf.com";
                    StartPage = "previous-session";
                };

                # Disable Firefox Home on the new tab
                NewTabPage = false;

                # Set Default Search Engine. Available in all versions of Firefox since 139
                SearchEngines.Default = "DuckDuckGo";

                # Add NixOS-related search engines. Available in all versions of Firefox since 139
                SearchEngines.Add = [{
                    Name = "Nix Packages";
                    URLTemplate = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
                    Method = "GET";
                    IconURL = "https://search.nixos.org/favicon.png";
                    Alias = "@np";
                    Description = "Search for packages in the nixpkgs repo.";
                } {
                    Name = "Nix Options";
                    URLTemplate = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
                    Method = "GET";
                    IconURL = "https://search.nixos.org/favicon.png";
                    Alias = "@no";
                    Description = "Search for NixOS module options.";
                } {
                    Name = "Home Manager Options";
                    URLTemplate = "https://home-manager-options.extranix.com/?release=master&query={searchTerms}";
                    Method = "GET";
                    IconURL = "https://home-manager-options.extranix.com/images/favicon.png";
                    Alias = "@hm";
                    Description = "Search for Nix Home Manager module options.";
                } {
                    Name = "NixOS Wiki";
                    URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
                    Method = "GET";
                    IconURL = "https://wiki.nixos.org/nixos.png";
                    Alias = "@nw";
                    Description = "Search the NixOS Wiki.";
                }];

                #
                # PRIVACY
                #

                # Get rid of unnecessary Mozilla stuff
                DisablePocket = true;
                DisableFirefoxStudies = true;
                DisableTelemetry = true;

                # Get rid of suggestions
                FirefoxSuggest = {
                    Locked = true;
                    WebSuggestions = false;
                    SponsoredSuggestions = false;
                    ImproveSuggest = false;
                };

                #
                # NUISANCES
                #

                DisableSetDesktopBackground = true;
                DisableProfileImport = true;
                DontCheckDefaultBrowser = true;
                NoDefaultBookmarks = true;

                # Disable autofill and saving form data
                AutofillAddressEnabled = false;
                AutofillCreditCardEnabled = false;
                PasswordManagerEnabled = false;
                DisableMasterPasswordCreation = true;
                DisableFormHistory = true;
                OfferToSaveLogins = false;

                # Disable first run and update pages
                OverrideFirstRunPage = "";
                OverridePostUpdatePage = "";

                # Get rid of some nagging
                UserMessaging = {
                    Locked = true;
                    ExtensionRecommendations = false;
                    FeatureRecommendations = false;
                    UrlbarInterventions = false;
                    SkipOnboarding = true;
                    MoreFromMozilla = false;
                    FirefoxLabs = true;
                };

                #
                # SECURITY
                #

                HttpsOnlyMode = "force_enabled";

            };
        };

        # Chromium policies, it has to be installed above
        # Goal is to be not far off from vanilla as I use it for testing and anything Firefox is broken for
        programs.chromium = {

            enable = true;
            homepageLocation = "https://justinschaaf.com";

            # Set default search engine
            defaultSearchProviderEnabled = true;
            defaultSearchProviderSearchURL = "https://duckduckgo.com/?q=%s";
            defaultSearchProviderSuggestURL = "https://duckduckgo.com/ac/?q=%s&type=list";

            extraOpts = {

                # Clear cookies and browsing data upon exit
                DefaultCookiesSetting = 4;
                SavingBrowserHistoryDisabled = true;

                # Deny all requests to show notifs
                DefaultNotificationsSetting = 2;

                # Enable Manifest v2 while you still can
                ExtensionManifestV2Availability = 2;

                # Fuck your AI
                GenAiDefaultSettings = 2;

                # Disable switching to legacy browsers
                BrowserSwitcherEnabled = false;

                # Use system notifs
                AllowSystemNotifications = true;

                # HTTPS only
                HttpsOnlyMode = "force_balanced_enabled";

                # Disable autofill
                AutofillAddressEnabled = false;
                AutofillCreditCardEnabled = false;
                PasswordManagerEnabled = false;

                # Disable import
                ImportAutofillFormData = false;
                ImportBookmarks = false;
                ImportHistory = false;
                ImportHomepage = false;
                ImportSavedPasswords = false;
                ImportSearchEngine = false;

                PromptForDownloadLocation = true;

                # Fuck Privacy Sandbox
                PrivacySandboxPromptEnabled = false;
                PrivacySandboxSiteEnabledAdsEnabled = false;
                PrivacySandboxAdMeasurementEnabled = false;
                PrivacySandboxAdTopicsEnabled = false;

                # Fuck your trackers
                AdsSettingForIntrusiveAdsSites = 2;
                BrowserSignin = 0;
                CloudReportingEnabled = false;
                FirstPartySetsEnabled = false;
                GoogleWorkspaceCloudUpload = "disallowed";
                MicrosoftOfficeCloudUpload = "disallowed";
                MetricsReportingEnabled = false;
                UserFeedbackAllowed = false;

                # Fuck your bloat
                BookmarkBarEnabled = false;
                ShoppingListEnabled = false;
                SpellcheckEnabled = false;

            };

        };

    };

}
