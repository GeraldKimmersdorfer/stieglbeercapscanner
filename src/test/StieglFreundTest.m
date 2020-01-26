x = StieglFreund(Parameters.STIEGL_USERNAME);
x = x.login(Parameters.STIEGL_PASSWORD);

try
    x.uploadCode('DV3SX67ND');
    disp('Added successfully');
catch e
    disp(e.message);
end
x = x.logout();