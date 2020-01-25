x = StieglFreund('rosh-pit@cnpr.at');
x = x.login('5678KJUI');

try
    x.uploadCode('DV3SX67ND');
    disp('Added successfully');
catch e
    disp(e.message);
end
x = x.logout();