# dotnet-mgr
A simple dotnet version manager (dnm)

## Installation
``` sh
git clone https://github.com/phillsv87/dotnet-mgr
cd dotnet-mgr

# list installable versions. See the [ Adding installable versions ] section on how to add 
# installable versions to the list
./dotnet-mgr.ps1 -list

# Initialize using a version for the printed list.
./dotnet-mgr.ps1 -init <version-name>
```
Once initialization is complete you can start using the dnm command

<br/>
<br/>

## Installing additional dotnet versions
``` sh
# list versions
dnm -list

# Install a new version
dnm -install <version-name>

# Set current dotnet version
dnm -setVersion <version-name>


# The two above commands can also be combined into a single command
# to both install and set the current dotnet version
dnm -installCurrent <version-name>
```

<br/>
<br/>

## Adding installable versions
The version list returned by dmn -list is defined by the dotnet-versions.json file which contains
a named list of download links to dotnet sdk and runtime binaries. You can add installable versions
by appending new versions to the json file.

Binary download can be found at https://dotnet.microsoft.com/en-us/download/dotnet

<br/>

### dotnet-versions.json
``` json
[
    {
        "name":"dotnet-sdk-6.0.200-osx-arm64",
        "download":"https://download.visualstudio.microsoft.com/.../dotnet-sdk-6.0.200-osx-arm64.tar.gz"
    },
    {
        "name":"dotnet-sdk-5.0.405-osx-x64",
        "download":"https://download.visualstudio.microsoft.com/.../dotnet-sdk-5.0.405-osx-x64.tar.gz"
    },
    {
        "name":"dotnet-sdk-3.1.416-osx-x64",
        "download":"https://download.visualstudio.microsoft.com/.../dotnet-sdk-3.1.416-osx-x64.tar.gz"
    }
]
```

<br/>
<br/>

## Manual shell configuration
Currently dnm will auto configure bash and zsh shells by adding the current dotnet version to the 
user's path and setting the DOTNET_ROOT and DOTNET_MGR_ROOT environment variables. To configuration
other shells and the following ( replace {FULL_PATH_TO_DOTNET_MGR} with the full path to the root of this repo)

``` sh
###_dotnet_mgr_config_###
export PATH=$PATH:{FULL_PATH_TO_DOTNET_MGR}/versions/current:{FULL_PATH_TO_DOTNET_MGR}/tools
export DOTNET_ROOT={FULL_PATH_TO_DOTNET_MGR}/versions/current
export DOTNET_MGR_ROOT={FULL_PATH_TO_DOTNET_MGR}
###_end_dotnet_mgr_config_###
```

<br/>
<br/>

## Version sourcing
Each installed dotnet version will have a source script that can be used to set the version of dotnet
for the current running script. This is helpfully for when you need to run different versions of
dotnet on the same machine at the same time.

### Example
``` sh

# print the current dotnet version
dotnet --version
# output: 6.0.200

# Set the current version to 5.0.405 for only this script
. dnv-dotnet-sdk-5.0.405-osx-x64

dotnet --version
# output: 5.0.405


```

<br/>
<br/>

## CLI Arguments

| Argument name  | value   | Description                                                                                                                 |
|----------------|---------|-----------------------------------------------------------------------------------------------------------------------------|
| list           |         | List all installable versions contained in the dotnet-versions.json file                                                    |
| help           |         | Print help                                                                                                                  |
| install        | version | Installs a dotnet version                                                                                                   |
| installAll     |         | Install all dotnet versions in dotnet-versions.json                                                                         |
| installCurrent | version | Installs a dotnet version and sets it as the current version                                                                |
| init           | version | Initializes the dmn command and installs the initial dotnet version                                                         |
| noCache        |         | When used with -install cached files are deleted                                                                            |
| initProfile    |         | Initializes the users shell profiles. Currently bash and zsh are supported. See manual shell configuration for other shells |
| setVersion     | version | Sets the current dotnet version                                                                                             |
| clean          |         | Deletes all installed versions and cached files                                                                             |