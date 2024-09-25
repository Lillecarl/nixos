{ uuid
, name
, memory
, vcpu
, threads ? 1
, ...
}:
let
  memoryKiB = builtins.mul memory 1024;
  xmlComment = comment: "<!-- " + comment + " -->";
  xc = xmlComment;
in
  /* xml */ ''
  <domain type='kvm'>
    <name>${toString name}</name>
    <uuid>${toString uuid}</uuid>
    <metadata>
      <libosinfo:libosinfo xmlns:libosinfo="http://libosinfo.org/xmlns/libvirt/domain/1.0">
        <libosinfo:os id="http://microsoft.com/win/11"/>
      </libosinfo:libosinfo>
    </metadata>
    <resource>
      <partition>/machine/${toString name}</partition>${xc "default cgroup name is dumb"}
    </resource>
    <memory unit='KiB'>${toString memoryKiB}</memory>
    <currentMemory unit='KiB'>${toString memoryKiB}</currentMemory>
    <memoryBacking>
      <hugepages>
        <page size='2048' unit='KiB'/>
      </hugepages>
      <source type='memfd'/>
      <access mode='shared'/>
      <discard/>
    </memoryBacking>
    <vcpu placement='static'>${toString vcpu}</vcpu>
    <os>
      <type arch='x86_64' machine='pc-q35-9.0'>hvm</type>
      <loader readonly='yes' type='pflash'>/run/libvirt/nix-ovmf/OVMF_CODE.fd</loader>
      <nvram template='/run/libvirt/nix-ovmf/OVMF_VARS.fd'>/var/lib/libvirt/qemu/nvram/win11-4_VARS.fd</nvram>
      <bootmenu enable='yes'/>
    </os>
    <features>
      <acpi/>
      <apic/>
      <hyperv mode='custom'>
        <relaxed state='on'/>
        <vapic state='on'/>
        <spinlocks state='on' retries='8191'/>
        <vpindex state='on'/>
        <runtime state='on'/>
        <synic state='on'/>
        <stimer state='on'/>
        <reset state='on'/>
        <vendor_id state='on' value='KVM Hv'/>
        <frequencies state='on'/>
        <reenlightenment state='on'/>
        <tlbflush state='on'/>
        <ipi state='on'/>
      </hyperv>
      <vmport state='off'/>
    </features>
    <cpu mode='host-passthrough' check='none' migratable='on'>
      <topology sockets='1' dies='1' clusters='1' cores='${toString (builtins.div vcpu threads)}' threads='${toString threads}'/>
    </cpu>
    <clock offset='localtime'>
      <timer name='rtc' tickpolicy='catchup'/>
      <timer name='pit' tickpolicy='delay'/>
      <timer name='hpet' present='no'/>
      <timer name='hypervclock' present='yes'/>
    </clock>
    <on_poweroff>destroy</on_poweroff>
    <on_reboot>restart</on_reboot>
    <on_crash>destroy</on_crash>
    <pm>
      <suspend-to-mem enabled='no'/>
      <suspend-to-disk enabled='no'/>
    </pm>
    <devices>
      <emulator>/run/libvirt/nix-emulators/qemu-system-x86_64</emulator>
      <disk type='block' device='disk'>
        <driver name='qemu' type='raw' cache='none' io='native' discard='unmap'/>
        <source dev='/dev/pool/windows11_24'/>
        <target dev='vda' bus='virtio'/>
        <boot order='1'/>
        <address type='pci' domain='0x0000' bus='0x04' slot='0x00' function='0x0'/>
      </disk>
      <disk type='file' device='cdrom'>
        <driver name='qemu' type='raw'/>
        <target dev='sdb' bus='sata'/>
        <readonly/>
        <address type='drive' controller='0' bus='0' target='0' unit='1'/>
      </disk>
      <controller type='usb' index='0' model='qemu-xhci' ports='15'>
        <address type='pci' domain='0x0000' bus='0x02' slot='0x00' function='0x0'/>
      </controller>
      <controller type='pci' index='0' model='pcie-root'/>
      <controller type='pci' index='1' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='1' port='0x10'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0' multifunction='on'/>
      </controller>
      <controller type='pci' index='2' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='2' port='0x11'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x1'/>
      </controller>
      <controller type='pci' index='3' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='3' port='0x12'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x2'/>
      </controller>
      <controller type='pci' index='4' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='4' port='0x13'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x3'/>
      </controller>
      <controller type='pci' index='5' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='5' port='0x14'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x4'/>
      </controller>
      <controller type='pci' index='6' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='6' port='0x15'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x5'/>
      </controller>
      <controller type='pci' index='7' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='7' port='0x16'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x6'/>
      </controller>
      <controller type='pci' index='8' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='8' port='0x17'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x7'/>
      </controller>
      <controller type='pci' index='9' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='9' port='0x18'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0' multifunction='on'/>
      </controller>
      <controller type='pci' index='10' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='10' port='0x19'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x1'/>
      </controller>
      <controller type='pci' index='11' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='11' port='0x1a'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x2'/>
      </controller>
      <controller type='pci' index='12' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='12' port='0x1b'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x3'/>
      </controller>
      <controller type='pci' index='13' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='13' port='0x1c'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x4'/>
      </controller>
      <controller type='pci' index='14' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='14' port='0x1d'/>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x5'/>
      </controller>
      <controller type='sata' index='0'>
        <address type='pci' domain='0x0000' bus='0x00' slot='0x1f' function='0x2'/>
      </controller>
      <filesystem type='mount' accessmode='passthrough'>
        <driver type='virtiofs'/>
        <source dir='/home/lillecarl'/>
        <target dir='/lillecarl'/>
        <address type='pci' domain='0x0000' bus='0x03' slot='0x00' function='0x0'/>
      </filesystem>
      <interface type='bridge'>
        <mac address='52:54:00:29:5b:d6'/>
        <source bridge='br13'/>
        <model type='virtio'/>
        <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
      </interface>
      <input type='mouse' bus='ps2'/>
      <input type='keyboard' bus='ps2'/>
      <tpm model='tpm-crb'>
        <backend type='emulator' version='2.0'/>
      </tpm>
      <graphics type='spice' autoport='yes'>
        <listen type='address'/>
        <image compression='off'/>
      </graphics>
      <audio id='1' type='spice'/>
      <video>
        <model type='none'/>
      </video>
      <hostdev mode='subsystem' type='pci' managed='yes'>
        <source>
          <address domain='0x0000' bus='0x09' slot='0x00' function='0x0'/>
        </source>
        <rom bar='on'/>
        <address type='pci' domain='0x0000' bus='0x06' slot='0x00' function='0x0'/>
      </hostdev>
      <hostdev mode='subsystem' type='pci' managed='yes'>
        <source>
          <address domain='0x0000' bus='0x09' slot='0x00' function='0x1'/>
        </source>
        <address type='pci' domain='0x0000' bus='0x07' slot='0x00' function='0x0'/>
      </hostdev>
      <redirdev bus='usb' type='spicevmc'>
        <address type='usb' bus='0' port='2'/>
      </redirdev>
      <redirdev bus='usb' type='spicevmc'>
        <address type='usb' bus='0' port='3'/>
      </redirdev>
      <watchdog model='itco' action='reset'/>
      <memballoon model='virtio'>
        <address type='pci' domain='0x0000' bus='0x05' slot='0x00' function='0x0'/>
      </memballoon>
    </devices>
  </domain>
''
