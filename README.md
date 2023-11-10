# nixos-config

So I'm playing around with NixOS. You probably don't want to use these configs, at least not yet. I'm still working on them. I'm still learning how they work. 

Right now, the main goal of this repo is to have a record of how my config evolves over time. Especially to have as a reference if I fuck anything up.

Eventually, I'd like to have these in a usable state where I can easily deploy them to any new computer I need them to, but that's a little ways down the road. I'd also eventually like to document everything here and why I setup things the way I do because there isn't really a good reference for how tf you're supposed to do anything other than the basics--and even the documentation for that is an incomprehensible wall of text.

Right now, this is targeted at a home theater PC; more accurately, an old Dell Optiplex I intend to hook up to my bedroom TV so I can watch Youtube on it without ads. Eventually, I'd like to have all my systems running NixOS so setting them up is a breeze. I'm doing all this work now so eventually I don't have to, my computers run themselves and I never have to think about updating or backups and the like. That's the goal, at least.

For now, if you're interested enough to see what I'm making here, feel free to stick around and enjoy the ride.

## Goals / To Do

- [x] Have this file hosted in a GitHub repo justinhschaaf/nixos-config
- [x] Actually comment shit so I know what it does
- [ ] Have a local flake that uses system.autoUpgrade to automatically update the system from the remote flake
- [x] Perhaps have separate configs for each machine defined, need some way to specify which profile to build
- [ ] Host eww in a separate GitHub repo and have it auto pull upon rebuilding the system
- [x] Use the on-disk hardware-configuration.nix instead of having to pull it from GitHub
- [x] Setup Home Manager
- [x] Configure hyprland through home manager
- [x] Declarative Flatpaks
- [ ] Mimetypes https://mipmip.github.io/home-manager-option-search/?query=mime https://github.com/nix-community/home-manager/issues/96 https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types
- [ ] Zsh config https://nixos.wiki/wiki/Zsh
