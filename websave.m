function outfilename = websave(filename,url)
% This file is a wrapper that has the same syntax as websave in 2015
%
%
% Older versions of Matlab need to use urlwrite, because websave doesn't
% exist.  I foresee a future in which websave exists.  So, I am going to
% write with this synatx so that when we move forward in time we can use
% the Matlab function without have to re-write any of our other code.
%
% I will try to figure out wrappers for the other future Matlab commands.
%
%

outfilename = urlwrite(url, filename);

end
