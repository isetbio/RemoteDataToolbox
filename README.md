# remoteDataToolbox
Matlab utilities for managing reading and writing of data files stored on a remote ftp-site.

The functionality will be based on the urlwrite() function, 
which in the most modern releases is superceded by websave.  Perhaps we
will also use the ftp object for some purposes.  Much to learn about permissions
writing and so forth from within Matlab.

It is possible we should create a remote data object (rdo) and interact
with that.  Or perhaps we just create a bunch of functions here and
let each toolbox use these functions in its own way.  For example, ISET
and ISETBIO could both interact with these functions and create different
remote data objects.  Same with VISTASOFT.

The first site we will be interacting with is http://scarlet.stanford.edu/validation

Brian
Michael
Nicolas
David
