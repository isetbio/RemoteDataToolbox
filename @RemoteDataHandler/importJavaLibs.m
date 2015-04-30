% Method to import the necessary Java Libs
function importJavaLibs(obj)

    % Add the SSH2Lib to the JavaPath
    jarFileName = 'ganymed-ssh2-build250.jar';
    jarFilePath = fullfile(remoteDataToolboxRootPath, 'external', 'ganymed-ssh2-build250');
    addSSH2LibToJavaPath(jarFileName, jarFilePath);
end


function addSSH2LibToJavaPath(jarFileName, jarFilePath)
   
    javapath = javaclasspath('-all');
    addToJavaPath = true;
    for i = 1:numel(javapath)
        if (any(strfind(javapath{i}, jarFileName)))
            addToJavaPath = false;
            break;
        end
    end

    if (addToJavaPath)
       javaaddpath(fullfile(jarFilePath, jarFileName));
       fprintf('Added ''%s'' to the java path.\n', jarFileName);
    else
       fprintf('''%s'' already on the java path.\n', jarFileName);
    end
end

