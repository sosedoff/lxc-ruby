module LXC::Utils
  module Debootstrap
    def self.generate(options={})
      variant     = options[:variant]     || 'minbase'
      components  = options[:components]  || 'main,universe'
      packages    = options[:packages]    || 'dialog,apt,apt-utils,aptitude,gpgv,resolvconf,iproute,inetutils-ping,dhcp3-client,ssh,lsb-release,lxcguest'
      ubuntu      = options[:ubuntu]      || 'natty'
      ubuntu_arch = options[:ubuntu_arch] || 'amd64'
      dir         = options[:dir]         || "/var/cache/debootstrap/#{ubuntu}/rootfs-#{ubuntu_arch}"

      # Make a dir first
      FileUtils.mkdir_p(dir)

      params = [
        "--verbose",
        "--variant=#{variant}",
        "--components=#{components}",
        "--include=#{packages}",
        "--arch=#{ubuntu_arch}",
        ubuntu,
        dir
      ]

      "debootstrap #{params.join(' ')}"
    end
  end
end