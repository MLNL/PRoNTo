function pronto_check_update()
% Function to check if there is a newer version of PRoNTo available.
% The 'latest_version.txt' needs to updated to the latest version of PRoNTo after each update.

[latest_version, server_status] = urlread('http://www.mlnl.cs.ucl.ac.uk/pronto/pronto_versions/latest_version.txt');

if server_status == 1
    
    txt_old = sprintf(['\n===========================================================================\n'...
        ' There might be a newer version of PRoNTo available. Users are strongly advised\n to switch to'...
        ' that version. You can find the latest version on our servers\n in http://www.mlnl.cs.ucl.ac.uk/.'...
        'pronto/pronto_versions/\n===========================================================================\n']);
    
    try
        current_version = fileread('pronto_current_version.txt'); % need to change the path
        l_vers = latest_version(9:13); l_vers = strrep(l_vers, '.', ' '); l_vers = str2num(l_vers);
        c_vers = current_version(9:13); c_vers = strrep(c_vers, '.', ' '); c_vers = str2num(c_vers);
        
        txt_dev = sprintf(['\n======================================================================\n'...
            ' You might be using a developer version of PRoNTo. These versions can\n be unstable. Please consider'...
            ' switching to the latest stable version\n as indicated in http://www.mlnl.cs.ucl.ac.uk/pronto/pronto_versions/\n' ...
            '======================================================================']);
        
        if l_vers(1) == c_vers(1)
            if l_vers(2) == c_vers(2)
                if l_vers(3) > c_vers(3)
                    disp(txt_old);
                elseif l_vers(3) < c_vers(3)
                    disp(txt_dev);
                end
            elseif l_vers(2) > c_vers(2)
                disp(txt_old);
            elseif l_vers(2) < c_vers(2)
                disp(txt_dev);
            end
        elseif l_vers(1) > c_vers(1)
            disp(txt_old);
        elseif l_vers(1) < c_vers(1)
            disp(txt_dev);
        end
        
    catch
        disp(txt_old);
    end
    
else
    disp(sprintf(['\n===================================================================\n Cannot access the PRoNTo server. '...
        'No version check was run. Please\n check the PRoNTo website for news regarding the latest updates.\n'...
        '===================================================================']));
end

end