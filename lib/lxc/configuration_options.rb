module LXC
  module ConfigurationOptions
    VALID_OPTIONS = [
      "lxc.utsname",
      "lxc.network.type",
      "lxc.network.flags",
      "lxc.network.link",
      "lxc.network.name",
      "lxc.network.hwaddr",
      "lxc.network.ipv4",
      "lxc.network.ipv6",
      "lxc.pts",
      "lxc.tty",
      "lxc.mount",
      "lxc.mount.entry",
      "lxc.rootfs",
      "lxc.cgroup",
      "lxc.cap.drop"
    ]

    protected

    def valid_option?(name)
      VALID_OPTIONS.include?(name) || name =~ /^lxc.cgroup/
    end
  end
end