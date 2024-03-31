# nixos-config

So I'm playing around with NixOS. You probably don't want to use these configs, at least not yet. I'm still working on them. I'm still learning how they work. 

Right now, the main goal of this repo is to have a record of how my config evolves over time. Especially to have as a reference if I fuck anything up.

Eventually, I'd like to have these in a usable state where I can easily deploy them to any new computer I need them to, but that's a little ways down the road. I'd also eventually like to document everything here and why I setup things the way I do because there isn't really a good reference for how tf you're supposed to do anything other than the basics--and even the documentation for that is an incomprehensible wall of text.

Right now, this is targeted at a home theater PC; more accurately, an old Dell Optiplex I intend to hook up to my bedroom TV so I can watch Youtube on it without ads. Eventually, I'd like to have all my systems running NixOS so setting them up is a breeze. I'm doing all this work now so eventually I don't have to, my computers run themselves and I never have to think about updating or backups and the like. That's the goal, at least.

For now, if you're interested enough to see what I'm making here, feel free to stick around and enjoy the ride.

## Goals / To Do

- [x] Have this file hosted in a GitHub repo justinhschaaf/nixos-config
- [x] Actually comment shit so I know what it does
- [x] Automatic updates which pull from the GitHub repo
- [x] Perhaps have separate configs for each machine defined, need some way to specify which profile to build
- [x] Use the on-disk hardware-configuration.nix instead of having to pull it from GitHub
- [x] Setup Home Manager
- [x] Configure hyprland through home manager
- [x] Declarative Flatpaks
- [x] Mimetypes https://mipmip.github.io/home-manager-option-search/?query=mime https://github.com/nix-community/home-manager/issues/96 https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types
- [x] Fish config https://nixos.wiki/wiki/Fish
- [ ] Frosted glass for theming. maybe soft rainbow gradients too?
- [ ] EWW vertical taskbar, control center, and maybe notification daemon (history at least)
- [ ] Mako notification config https://github.com/emersion/mako/issues/91#issuecomment-1750748445
- [x] Migrate from Blackbox to Kitty and make it as beautiful as Blackbox https://sw.kovidgoyal.net/kitty/conf/ (kangawabones color theme)
- [ ] Make Anyrun look like Spotlight Search but two column results
- [x] Dark theme, make sure it works in Thunar
- [ ] Add generic user for TV config
- [x] Japanese keyboard

## References

### Technical

- [davidak/nixos-config](https://github.com/davidak/nixos-config/tree/master)
- [MayNiklas/nixos](https://github.com/MayNiklas/nixos)

### Aesthetics

- [[Hyprland] vertical waybar, foot, swaync, neovim and tofi](https://www.reddit.com/r/unixporn/comments/179kz17/hyprland_vertical_waybar_foot_swaync_neovim_and/)
- [[AwesomeWM] Vertical Stuff!](https://www.reddit.com/r/unixporn/comments/xzknn3/awesomewm_vertical_stuff/)
- [[hyprland] Mocha ~](https://www.reddit.com/r/unixporn/comments/zos11o/hyprland_mocha/)
- [[hyprland] glassmorphism?](https://www.reddit.com/r/unixporn/comments/ys4nfs/hyprland_glassmorphism/)
- [linkfrg's Hyprland(and eww!) dotfiles](https://github.com/linkfrg/dotfiles/tree/main)
- [1amSimp1e's Dot Files](https://github.com/1amSimp1e/dots)
