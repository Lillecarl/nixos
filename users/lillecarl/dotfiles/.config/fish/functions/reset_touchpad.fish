function reset_touchpad
    sudo modprobe -r i2c_hid_acpi
    sudo modprobe -r i2c_hid
    sudo modprobe -r i2c_dev
    sudo modprobe i2c_hid_acpi
    sudo modprobe i2c-dev
end
