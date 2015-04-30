function terminateSFTPsession(obj)
    if (~isempty(obj.sFTPClientOBJ))
        obj.sFTPClientOBJ.close();
        obj.sFTPClientOBJ = [];
        fprintf('Closed sFTPclient.\n');
    end
end
