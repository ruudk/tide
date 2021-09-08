function _tide_pwd
    set -l split_pwd (string replace -- $HOME '~' $PWD | string split /)

    if not test -w $PWD
        set -g tide_pwd_icon $tide_pwd_icon_unwritable' '
    else if test $PWD = $HOME
        set -g tide_pwd_icon $tide_pwd_icon_home' '
    else
        set -g tide_pwd_icon $tide_pwd_icon' '
    end

    # Anchor first and last directories (which may be the same)
    if test -n "$split_pwd[1]" # ~/foo/bar, hightlight ~
        set split_pwd_for_output "$_tide_reset_to_color_dirs$tide_pwd_icon"$_tide_color_anchors$split_pwd[1]$_tide_reset_to_color_dirs $split_pwd[2..]
    else # /foo/bar, hightlight foo not empty string
        set split_pwd_for_output "$_tide_reset_to_color_dirs$tide_pwd_icon"'' $_tide_color_anchors$split_pwd[2]$_tide_reset_to_color_dirs $split_pwd[3..]
    end
    set split_pwd_for_output[-1] $_tide_color_anchors$split_pwd[-1]$_tide_reset_to_color_dirs

    string join / $split_pwd_for_output | string length --visible | read -g pwd_length

    i=1 for dir_section in $split_pwd[2..-2]
        string join -- / $split_pwd[..$i] | string replace '~' $HOME | read -l parent_dir # Uses i before increment

        math $i+1 | read i

        # Returns true if any markers exist in dir_section
        if test -z false (string split --max 2 " " -- "-o -e "$parent_dir/$dir_section/$tide_pwd_markers)
            set split_pwd_for_output[$i] $_tide_color_anchors$dir_section$_tide_reset_to_color_dirs
        else if test $pwd_length -gt $dist_btwn_sides
            while set -l truncation_length (math $truncation_length +1) &&
                    set -l truncated (string sub --length $truncation_length -- $dir_section) &&
                    test $truncated != $dir_section -a (count $parent_dir/$truncated*/) -gt 1
            end
            set split_pwd_for_output[$i] $_tide_color_truncated_dirs$truncated$_tide_reset_to_color_dirs
            string join / $split_pwd_for_output | string length --visible | read -g pwd_length
        end
    end

    string join -- / $split_pwd_for_output
end
