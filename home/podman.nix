{ pkgs, ... }:
{
  home = {
    packages = [
      pkgs.podman
      pkgs.vfkit # VM provider used by `podman machine` on macOS
    ];

    sessionVariables = {
      # Point Docker API clients at the podman machine socket. The value must
      # contain "podman.sock": testcontainers-go keys its podman provider
      # detection on that substring, and without it the reaper tries to join
      # docker's "bridge" network, which podman rejects.
      DOCKER_HOST = "unix://$HOME/.local/share/containers/podman/machine/podman.sock";

      # Ryuk (the testcontainers reaper) bind-mounts the daemon socket from
      # inside the machine VM, where the rootless socket lives under the host
      # user's uid — not the DOCKER_HOST path, which only exists on the host.
      TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = "/run/user/501/podman/podman.sock";

      # Rootless podman refuses ryuk's socket access unless privileged.
      TESTCONTAINERS_RYUK_CONTAINER_PRIVILEGED = "true";
    };
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
