# RemoteDataToolbox
Matlab utilities for reading and publishing artifacts (aka data files) stored in a Maven repository.

### Gradle
Uses [Gradle](http://gradle.org/) as the Maven client.  This takes care of:
 * web connections and authentication
 * reading and publishing artifacts with Maven metadata
 * client-side caching of artifacts

Includes the [Gradle Wrapper](https://docs.gradle.org/current/userguide/gradle_wrapper.html) which means you don't have to install Gradle yourself.  It just happens.

### Archiva Queries
Also includes utilities for querying the repository.  These assume that the Maven repository is running [Archiva](https://archiva.apache.org/index.cgi) because they rely on Archiva's RESTful API.  On the client side, these utilities use Matlab's `webread()` function.  These take care of:
 * listing artifacts and groups
 * searching for artifacts by group, id, version, or fuzzy text matching

### JSON Project Configuration
All RemoteDataToolbox functions can be used "as is", by passing in explicit configuration in the form of a struct.  This configuration would incluld things like the url of the Maven repository.

Alternatively, project-specific configuration can be placed in a JSON configuration file.  RemoteDataToolbox functions will search the current folder, its parent folder, and so on, until finding a file named `remote-data-toolbox.json`.  This file must contain configuration, such as the url of the Maven repository.

Inclues [JSONlab](http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files-in-matlab-octave) for converting JSON data to and from Matlab structs.

# Examples

### Read an Artifact
TODO...

### Publish an Artifact
TODO...

### Query the Repository
TODO...

### JSON configuration
TODO...

# Have Fun!
Brian
Michael
Nicolas
David
Ben
