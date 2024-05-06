# Python dependencies management

This is an extension of the dependance lib to manage python dependencies in a venv.
This lib manages also the installation of pyenv to get a dedicated version of python if required.

## pre-requisites

You will need to create two files in your plugin:

- `install_apt.sh` - classic script file use by Jeedom core to install your dependencies (see dev doc how to manage plugin dependencies)
- `requirements.txt` - must be in the same folder than `install_apt.sh` and must contain python dependencies requirements, this is also a very common file in python development (see python/pip doc)

Example of content:

```txt
aiohttp>=3.8.0
paho-mqtt>=2.0.0
```

## Quick start

Here is the typical content you will need in your `install_apt.sh` file:

```bash
######################### INCLUSION LIB ##########################
BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
wget https://raw.githubusercontent.com/Mips2648/dependance.lib/master/dependance.lib --no-cache -O ${BASE_DIR}/dependance.lib &>/dev/null
PLUGIN=$(basename "$(realpath ${BASE_DIR}/..)")
LANG_DEP=en
. ${BASE_DIR}/dependance.lib
##################################################################
wget https://raw.githubusercontent.com/Mips2648/dependance.lib/master/pyenv.lib --no-cache -O ${BASE_DIR}/pyenv.lib &>/dev/null
. ${BASE_DIR}/pyenv.lib
##################################################################

# TARGET_PYTHON_VERSION="3.11"
# VENV_DIR=${BASE_DIR}/venv
# APT_PACKAGES="first1 second2"

launchInstall
```

And that's all, nothing else is needed !

### A few explanation

The two first sections are the inclusion of both libs:

- dependance.lib is the one created by @Nebz (see README)
- pyenv.lib is the extension to manage python venv

`launchInstall` is self-explanatory, it launches the installation process!
If you have followed pre-requisites, it will install dependencies defined in `requirements.txt`.

### Optionals parameters

#### TARGET_PYTHON_VERSION

`TARGET_PYTHON_VERSION` allow you to specify the minimal requested python version. If not specified, it will be the version coming by default with Debian.

The lib try to optimize installation time: if several plugins are using this lib and require the same or compatible python version, installation will be done only once for all (but each one will get is own "copy" to avoid side impacts between plugins)

Take into account than installing a specific python version can take an hour or more on slow hardware so to avoid impacting too much end-user with very long installation time, it is recommended to only specify *minor* version (e.g. "3.11") and not *patch* (e.g. "3.11.8") so the lib can optimize the usage of python version cross plugins.

So if you explicitly requires version "3.11.8" for example, this will likely force an installation while maybe version "3.11.2" would have been fine and already available so installation process would be much faster because a new installation is not needed.

#### VENV_DIR

`VENV_DIR` allow you to specify where to install your dependencies for your plugin: with this lib, python dependencies are not shared across plugins anymore; this is made by leveraging usage of python venv.

By default it will be installed in sub-folder `./venv` relative to the location of `install_apt.sh` which is most probably located in the `resources` folder in your plugin. So full path will be (relative to your plugin folder): `resources/venv`.

This is important because in your eqLogic class you will need to call `resources/venv/bin/python3` (which will be the version dedicated to your plugin) and not `python3` (which is system wide) whenever needed.

#### APT_PACKAGES

This one allow you to install apt packages (system wide of course). This will generate an instruction like this: `apt-get install -y first1 second2`.
Nothing specific about this but sometimes we need to install extra apt package.

## Advanced usage

t.b.d
