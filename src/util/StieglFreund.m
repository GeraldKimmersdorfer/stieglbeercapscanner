classdef StieglFreund
    %STIEGLFREUND A Class that represents a user on
    %https://www.stiegl-shop.at/freundeskreis/ and offers functionality to
    %add new stiegl bottlecap codes to that users profile
    %
    %@author Gerald Kimmersdorfer, 01326608
    
    properties
        user
        sid = ''
    end
    
    methods
        function obj = StieglFreund(email)
            %STIEGLFREUND Constructs a new instance of the class which
            %initializes the user-variable with the given email-address
            assert(~strcmp(strtrim(email), ''), 'email has to be set');
            obj.user = email;
        end
        
        function obj = login(obj, password)
            %LOGIN Logs the user (username set at initialization) into the
            %stiegl freundeskreis platform with the given password and 
            %retrieves the session id which is needed for adding/uploading new codes
            
            % general parameter check
            assert(~strcmp(strtrim(password), ''), 'password has to be set');
            
            % initialize private variables, encode password and email
            url = 'https://www.stiegl-shop.at/freundeskreis/?action=shop_login';
            email = urlencode(obj.user);
            pw = urlencode(password);
          
            % constructs the request message, you can verify it by adding show(request) at the end
            body = matlab.net.http.MessageBody(strcat('action=shop_login&input_email=',email,'&input_password=',pw));
            contentTypeHeader = matlab.net.http.field.ContentTypeField('application/x-www-form-urlencoded');
            acceptHeader = matlab.net.http.field.AcceptField('*/*');
            header = [acceptHeader contentTypeHeader];
            method = matlab.net.http.RequestMethod.POST;
            request = matlab.net.http.RequestMessage(method, header, body);
            
            % sets connection parameters
            options = matlab.net.http.HTTPOptions('ConnectTimeout', 500);
            
            % initializes URI object based on the previous set path
            uri = matlab.net.URI(url);
            % sends request and stores response in response-variable
            [response, ~, ~] = request.send(uri, options);
            
            % look for cookies to set
            cookieFields = response.getFields('Set-Cookie');
            if isempty(cookieFields)
                error('error during login, cookie field not set');
            end
            
            % look through all the cookies and search for 'sidfreundeskreis' - it contains the id that we need
            cookieData = cookieFields.convert();
            cookies = [cookieData.Cookie];
            for i = 1:length(cookies)
                if cookies(i).Name == "sidfreundeskreis"
                    obj.sid = char(cookies(i).Value);
                end
            end
            if strcmp(obj.sid, '')
                error('error during login, couldnt extract session id');
            end
        end
        
        function obj = logout(obj)
            %LOGOUT Logs the currently authenticated user out of the system
           
            % check if actually logged in
            if isempty(obj.sid)
                error('error user is not logged in, no session id set');
            end
            
            % set private parameters
            url = 'https://www.stiegl-shop.at/freundeskreis/?action=shop_logout';
            
            % constructs the request message with the needed Cookie-Header
            body = matlab.net.http.MessageBody('action=shop_logout');
            contentTypeHeader = matlab.net.http.field.ContentTypeField('application/x-www-form-urlencoded');
            acceptHeader = matlab.net.http.field.AcceptField('*/*');
            sidCookie = matlab.net.http.Cookie('sidfreundeskreis', obj.sid);
            cookieHeader = matlab.net.http.field.CookieField(sidCookie);
            header = [acceptHeader contentTypeHeader cookieHeader];
            method = matlab.net.http.RequestMethod.POST;
            request = matlab.net.http.RequestMessage(method, header, body);
            
            % sets connection options
            options = matlab.net.http.HTTPOptions('ConnectTimeout', 500);
            
            % initializes uri-object by given url
            uri = matlab.net.URI(url);
            
            % sends the logout-request (we just assume it worked)
            request.send(uri, options);
            % delete saved session id since its not valid anymore
            obj.sid = '';
        end
        
        function uploadCode(obj, code)
            %UPLOADCODE Tries to add the point to the logged in user, will
            %throw an error if, for whatever reason the upload failed.
            assert(~strcmp(strtrim(code), ''), 'code has to be set');
            assert(length(code) == 9, 'code needs to be 9 letters long');
            
            % check if user is logged in
            if isempty(obj.sid)
                error('error user is not logged in, no session id set');
            end
            
            % set connection options and private parameters
            url = 'https://www.stiegl-shop.at/module/mysydeshop/b2c/ajax.php';
            options = weboptions('RequestMethod', 'post');
            % send code and retrieve result as string
            data = webread(url, ...
                'function', 'checkCodeSingle', ...
                'sid', obj.sid, ...
                'site_language', 'at', ...
                'customer_no', '', ...
                'shop_code', 'STIEGL-FK', ...
                'company', 'GSG-Stiegl Getränke u. Service', ...
                'input_fk_code', code, ...
                options);
            % simply check respond string
            if contains(data, 'color-red', 'IgnoreCase', true)
                msg = strrep(strrep(data, 'color-red,', ''), 'color-red', '');
                msg = strrep(msg, '  ', ' ');
                if contains(msg, 'query')
                    error('not accepted: maybe the login failed?');
                end
                error(strcat('not accepted: ', msg));
            elseif ~contains(data, 'color-green', 'IgnoreCase', true)
                error(strcat('interpretation of ', data, ' failed'));
            end
        end
        
    end
end

