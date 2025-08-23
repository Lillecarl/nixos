{
  uuid,
  name,
  memory,
  pkgs,
  ...
}:
let
  memoryKiB = builtins.mul memory 1024;
in
# xml
''
  <domain type='kvm'>
    <name>${toString name}</name>
    <uuid>${toString uuid}</uuid>
    <metadata>
      <libosinfo:libosinfo xmlns:libosinfo="http://libosinfo.org/xmlns/libvirt/domain/1.0">
        <libosinfo:os id="http://microsoft.com/win/11"/>
      </libosinfo:libosinfo>
    </metadata>
    <resource>
      <!-- default cgroup name is dumb -->
      <partition>/machine/${toString name}</partition>
    </resource>
    <memory unit='KiB'>${toString memoryKiB}</memory>
    <currentMemory unit='KiB'>${toString memoryKiB}</currentMemory>
    <memoryBacking>
      <!--
        Hugepages are good for performance, we would use transparent hugepages (THP)
        but it doesn't work with shared memory, which is a requirement for virtiofs
        and Looking Glass.
      -->
      <hugepages>
        <page size='2048' unit='KiB'/>
      </hugepages>
      <source type='memfd'/>
      <!-- Shared memory is required for virtiofs and Looking Glass -->
      <access mode='shared'/>
      <discard/>
    </memoryBacking>
    <!-- 2 threads not allocated to the guest, use them for IO -->
    <iothreads>2</iothreads>
    <vcpu placement='static'>10</vcpu> <!-- 5 cores with 2 threads each -->
    <!-- Guest CPU model = host CPU model, don't support live migration -->
    <cpu mode='host-passthrough' check='none' migratable='off'>
      <topology sockets='1' dies='1' clusters='1' cores='5' threads='2'/>
      <!-- Enable SMT in the guest, disabled by default since timing attacks became a thing -->
      <feature policy='require' name='topoext'/>
      <!-- Enable nested virtualisation "svm" on AMD "vmx" on Intel -->
      <feature policy='require' name='svm'/>
    </cpu>
    <cputune>
      <!-- Pin QEMU threads to cores not passed to guest -->
      <emulatorpin cpuset='5,11'/>
      <iothreadpin iothread='1' cpuset='5,11'/>
      <iothreadpin iothread='2' cpuset='5,11'/>
      <!--
        Pin CPU's by their SMT topology,
        vcpu = guest index, cpuset = host core index.
        Both start from 0
      -->
      <vcpupin vcpu='0' cpuset='0'/>
      <vcpupin vcpu='2' cpuset='1'/>
      <vcpupin vcpu='4' cpuset='2'/>
      <vcpupin vcpu='6' cpuset='3'/>
      <vcpupin vcpu='8' cpuset='4'/>

      <vcpupin vcpu='1' cpuset='6'/>
      <vcpupin vcpu='3' cpuset='7'/>
      <vcpupin vcpu='5' cpuset='8'/>
      <vcpupin vcpu='7' cpuset='9'/>
      <vcpupin vcpu='9' cpuset='10'/>
    </cputune>
    <os>
      <type arch='x86_64' machine='pc-q35-9.0'>hvm</type>
      <loader readonly='yes' type='pflash'>${pkgs.OVMFFull.fd}/FV/OVMF_CODE.ms.fd</loader>
      <nvram template='${pkgs.OVMFFull.fd}/FV/OVMF_VARS.ms.fd'>/var/lib/libvirt/qemu/nvram/win11-4_VARS.fd</nvram>
      <bootmenu enable='yes'/>
    </os>
    <features>
      <acpi/>
      <apic/>
      <hyperv mode='passthrough'/>
      <ps2 state='off'/>
      <kvm>
        <hint-dedicated state='on'/>
        <poll-control state='on'/>
        <pv-ipi state='on'/>
      </kvm>
      <vmport state='off'/>
    </features>
    <clock offset='localtime'>
      <timer name='rtc' tickpolicy='catchup'/>
      <timer name='pit' tickpolicy='delay'/>
      <timer name='hpet' present='no'/>
      <timer name='hypervclock' present='yes'/>
      <timer name='tsc' present='yes' mode='native'/>
    </clock>
    <on_poweroff>destroy</on_poweroff>
    <on_reboot>restart</on_reboot>
    <on_crash>destroy</on_crash>
    <pm>
      <suspend-to-mem enabled='no'/>
      <suspend-to-disk enabled='no'/>
    </pm>
    <devices>
      <sound model='ich9'>
        <codec type='micro'/>
        <audio id='1'/>
      </sound>
      <audio id='1' type='pipewire' runtimeDir='/run'>
        <input mixingEngine='no' streamName='vminput'/>
        <output mixingEngine='no' streamName='vmoutput'/>
      </audio>
      <emulator>/run/libvirt/nix-emulators/qemu-system-x86_64</emulator>
      <disk type='block' device='disk'>
        <driver name='qemu' type='raw' cache='none' io='native' discard='unmap'/>
        <source dev='/dev/pool/winthin'/>
        <target dev='vda' bus='virtio'/>
        <boot order='1'/>
      </disk>
      <disk type='file' device='cdrom'>
        <driver name='qemu' type='raw'/>
        <target dev='sdb' bus='sata'/>
        <readonly/>
      </disk>
      <controller type='usb' index='0' model='qemu-xhci' ports='15'>
      </controller>
      <controller type='pci' index='0' model='pcie-root'/>
      <controller type='pci' index='1' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='1' port='0x10'/>
      </controller>
      <controller type='pci' index='2' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='2' port='0x11'/>
      </controller>
      <controller type='pci' index='3' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='3' port='0x12'/>
      </controller>
      <controller type='pci' index='4' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='4' port='0x13'/>
      </controller>
      <controller type='pci' index='5' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='5' port='0x14'/>
      </controller>
      <controller type='pci' index='6' model='pcie-root-port'>
        <model name='pcie-root-port'/>
        <target chassis='6' port='0x15'/>
      </controller>
      <controller type='sata' index='0'>
      </controller>
      <filesystem type='mount' accessmode='passthrough'>
        <driver type='virtiofs'/>
        <source dir='/home/lillecarl'/>
        <target dir='/lillecarl'/>
      </filesystem>
      <interface type='bridge'>
        <mac address='02:00:00:12:34:57'/>
        <source bridge='br0'/>
        <model type='virtio'/>
      </interface>
      <tpm model='tpm-crb'>
        <backend type='emulator' version='2.0'/>
      </tpm>
      <!-- PCI-E passthrough NVIDIA GPU -->
      <hostdev mode='subsystem' type='pci' managed='yes'>
        <source>
          <address domain='0x0000' bus='0x09' slot='0x00' function='0x0'/>
        </source>
        <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
        <rom bar='on'/>
      </hostdev>
      <!-- PCI-E passthrough NVIDIA soundcard -->
      <hostdev mode='subsystem' type='pci' managed='yes'>
        <source>
          <address domain='0x0000' bus='0x09' slot='0x00' function='0x1'/>
        </source>
        <address type='pci' domain='0x0000' bus='0x02' slot='0x00' function='0x0'/>
      </hostdev>
    </devices>
  </domain>
''
