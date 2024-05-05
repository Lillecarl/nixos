function rebuild-both
    rebuild-os || begin
        echo "Failed to rebuild OS"
        return 1
    end
    rebuild-home || begin
        echo "Failed to rebuild home"
        return 1
    end
end
