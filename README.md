# RemoteDataToolbox
Matlab utilities for reading and publishing artifacts (aka data files) stored in a Maven repository.

### Gradle
RemoteDataToolbox includes utilities that invoke [Gradle](http://gradle.org/) as the Maven client.  Gradle takes care of:
 * web connections and authentication
 * reading and publishing artifacts with Maven metadata
 * client-side caching of artifacts

The RemoteDataToolbox distribution includes the [Gradle Wrapper](https://docs.gradle.org/current/userguide/gradle_wrapper.html) which means you don't have to install Gradle yourself -- it happens automatically.

### Archiva Queries
Also includes utilities for querying the repository.  These assume that the Maven repository is running [Archiva](https://archiva.apache.org/index.cgi) because they rely on Archiva's RESTful API.  On the client side, these utilities use Matlab's `webread()` function.  These take care of:
 * listing artifacts and groups
 * searching for artifacts by group, id, version, or fuzzy text matching

### JSON Project Configuration
All RemoteDataToolbox functions can be used "as is", by passing in explicit configuration in the form of a struct.  This configuration would incluld things like the url of the Maven repository.

Alternatively, project-specific configuration can be placed in a JSON configuration file.  RemoteDataToolbox functions will search the current folder, its parent folder and so on, and the Matlab path until finding a file named `rdt-config-myproject.json` (where `myproject` can be any project name).  This file must contain configuration, such as the url of the Maven repository.

The RemoteDataToolbox distribution includes [JSONlab](http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files-in-matlab-octave) for converting JSON data to and from Matlab structs.

[JDK/JRE] - You must have a java run environment installed on your computer. Matlab sends you to an Oracle site where this can be downloaded if you do not already have the JRE/JDK installed.

# Examples
We have several [examples](https://github.com/isetbio/RemoteDataToolbox/tree/master/examples) in the form of Matlab scripts.

# Have Fun!
Brian
Michael
Nicolas
David
Ben
