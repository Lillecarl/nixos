function stopkubeadm
    set --export CONTAINERD_ADDRESS /run/containerd/containerd.sock
    sudo systemctl stop kubelet.service
    sudo crictl stop $(sudo crictl ps --quiet) >/dev/null
    sudo systemctl stop containerd.service
end
