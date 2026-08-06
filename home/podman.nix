{ pkgs, ... }:
{
  home = {
    packages = [
      pkgs.podman
      pkgs.vfkit # VM provider used by `podman machine` on macOS
    ];
  };

  # Start the podman machine VM at login. Containers with a restart policy
  # (e.g. the MySQL dev service) are then brought up by podman-restart.service
  # inside the VM, which is enabled there via `systemctl --user`.
  launchd.agents.podman-machine = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.podman}/bin/podman"
        "machine"
        "start"
      ];
      RunAtLoad = true;
      StandardOutPath = "/tmp/podman-machine-start.log";
      StandardErrorPath = "/tmp/podman-machine-start.log";
    };
  };
}
