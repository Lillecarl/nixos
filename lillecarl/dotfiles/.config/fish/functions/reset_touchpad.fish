function reset_touchpad
    sudo rmmod i2c_hid_acpi
    sudo rmmod i2c_hid
    sudo rmmod i2c_dev
    sudo modprobe i2c_hid_acpi
end
