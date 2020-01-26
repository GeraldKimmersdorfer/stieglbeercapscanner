function caps = uploadCodes(caps, username, password)
%UPLOADCODES Uploads the positive recognised codes in the given caps array
%to the Stiegl-Freundeskreis-Account with the given username and password
%
% @author: Gerald Kimmersdorfer

x = StieglFreund(username);
x = x.login(password);

for i = 1:length(caps)
    if ~isempty(caps{i}.code)
        try
            x.uploadCode(caps{i}.code);
        catch e
            if contains(e.message, "wurde bereits")
                caps{i} = caps{i}.setError(BottlecapError.AlreadyUsed, e.message);
            else
                caps{i} = caps{i}.setError(BottlecapError.Upload, e.message);
            end
        end
    end
end

x.logout();
end

