% Method to prompt for a user's credentials and authenticate on the server
function authenticateUser(obj)

    %userName = input(sprintf('Username for server ''%s'' [%s]:', obj.serverName, obs.serverName), 's');
    password = input(sprintf('Enter password for user ''%s@%s'': ', obj.userName, obj.serverName), 's');
    
    isAuthenticated = obj.channelOBJ.authenticateWithPassword(obj.userName,password);
    if (~isAuthenticated)
        error('Could not authenticate user %s on server ''%s''', obj.userName, obj.serverName);
    else
       fprintf('User ''%s'' authenticated by server ''%s''\n', obj.userName, obj.serverName); 
    end
end