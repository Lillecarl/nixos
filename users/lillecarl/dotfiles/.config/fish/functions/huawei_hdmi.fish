function huawei_hdmi
    # Set the HDMI input of a Huawei monitor to 0x11 which is the HDMI input
    ddcutil setvcp 0x60 0x11
end
