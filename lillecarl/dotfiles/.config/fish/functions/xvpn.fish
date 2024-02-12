function xvpn --argument unit_name action
    switch $action
        case start
            sudo systemctl start $unit_name
            echo "Started $unit_name"
        case stop
            sudo systemctl stop $unit_name
            echo "Stopped $unit_name"
        case '*'
            if test (sudo systemctl is-active $unit_name) = active
                sudo systemctl stop $unit_name
                echo "Stopped $unit_name"
            else
                sudo systemctl start $unit_name
                echo "Started $unit_name"
            end
    end
end
