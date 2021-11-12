{config, lib, pkgs, ...}:

with lib;

{
    environment.systemPackages = with pkgs; [
        git
        tmux
    ];
    users.users.root.openssh.authorizedKeys.keyFiles = [
        (pkgs.copyPathToStore ./authorized_keys)
    ];
}
