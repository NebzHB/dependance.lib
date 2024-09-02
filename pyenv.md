# Python dependencies management

This is an extension of the dependance lib to manage python dependencies in a venv.
This lib manages also the installation of pyenv to get a dedicated version of python if required.

This has been done by @Mips2648 & @TiTidom-RC base on the great work of @NebzHB

For any question or issue regarding *pyenv.lib*, please contact @Mips2648 via <https://github.com/NebzHB/dependance.lib> or [jeedom community](https://community.jeedom.com/)

## Prerequisites

You will need to create two files in your plugin:

- `install_apt.sh` - classic script file use by Jeedom core to install your dependencies (see dev doc how to manage plugin dependencies)
- `requirements.txt` - must be in the same folder than `install_apt.sh` and must contain python dependencies requirements, this is also a very common file in python development (see python/pip doc)

Example of content:

```txt
aiohttp>=3.8.0
paho-mqtt>=2.0.0
```

## Quick start

Here is the minimal content you will need in your `install_apt.sh` file:

```bash
######################### INCLUSION LIB ##########################
BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
wget https://raw.githubusercontent.com/NebzHB/dependance.lib/master/dependance.lib --no-cache -O ${BASE_DIR}/dependance.lib &>/dev/null
PLUGIN=$(basename "$(realpath ${BASE_DIR}/..)")
LANG_DEP=en
. ${BASE_DIR}/dependance.lib
##################################################################
wget https://raw.githubusercontent.com/NebzHB/dependance.lib/master/pyenv.lib --no-cache -O ${BASE_DIR}/pyenv.lib &>/dev/null
. ${BASE_DIR}/pyenv.lib
##################################################################

# TARGET_PYTHON_VERSION="3.11"
# VENV_DIR=${BASE_DIR}/venv
# APT_PACKAGES="first1 second2"

launchInstall
```

And that's all, nothing else is needed !

### Explanations

The two first sections are the inclusion of both libs:

- dependance.lib is the one created by @NebzHB (see README)
- pyenv.lib is the extension to manage python venv

`launchInstall` is self-explanatory, it launches the installation process!
If you have followed pre-requisites, it will install dependencies defined in `requirements.txt`.

### Optionals parameters

#### TARGET_PYTHON_VERSION

`TARGET_PYTHON_VERSION` allow you to specify the minimal requested python version. If not specified, it will be at least python 3.9 (no support of 3.7) or the version coming by default with current Debian version if > 3.9.

The lib try to optimize installation time: if several plugins are using this lib and require the same or compatible python version, installation will be done only once for all (but each one will get is own "copy" to avoid side impacts between plugins)

It might be that you end up with a higher python version than the target, you can see it as the minimum needed version.

Take into account than installing a specific python version can take an hour or more on slow hardware so to avoid impacting too much end-user with very long installation time, it is recommended to only specify *minor* version (e.g. "3.11") and not *patch* (e.g. "3.11.8") so the lib can optimize the usage of python version cross plugins.

So if you explicitly requires version "3.11.8" for example, this will likely force an installation while maybe version "3.11.2" would have been fine and already available so installation process would have been much faster because a new installation is not needed.

#### VENV_DIR

`VENV_DIR` allow you to specify where to install your dependencies for your plugin: with this lib, python dependencies are not shared across plugins anymore; this is made by leveraging usage of python venv.

By default it will be installed in sub-folder `./venv` relative to the location of `install_apt.sh` which is most probably located in the `resources` folder in your plugin. So full path will be (relative to your plugin folder): `resources/venv`.

This is important because in your eqLogic class you will need to call `resources/venv/bin/python3` (which will be the version dedicated to your plugin) and not `python3` (which is system wide) whenever needed.

#### APT_PACKAGES

This one allow you to install apt packages (system wide of course). This will generate an instruction like this: `apt-get install -y first1 second2`.
Nothing specific about this but sometimes we need to install extra apt package.

## Advanced usage

Below explanations assume you are already familiar with the general usage of dependance.lib. If not, please read README file first.

### Semi-manage setup of venv

If you have some additional steps to do before or after the venv creation & python dependencies installation (more than installing few apt packages) (or if you just want to "control" each steps) then using the simplified version of `launchInstall` won't work.

It's not a problem, this use case has been foreseen: you are free to implement your own flow, here is an example:

```bash
######################### INCLUSION LIB ##########################
BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
wget https://raw.githubusercontent.com/NebzHB/dependance.lib/master/dependance.lib --no-cache -O ${BASE_DIR}/dependance.lib &>/dev/null
PLUGIN=$(basename "$(realpath ${BASE_DIR}/..)")
LANG_DEP=en
. ${BASE_DIR}/dependance.lib
##################################################################
wget https://raw.githubusercontent.com/NebzHB/dependance.lib/master/pyenv.lib --no-cache -O ${BASE_DIR}/pyenv.lib &>/dev/null
. ${BASE_DIR}/pyenv.lib
##################################################################

pre
step 5 "Clean apt"
try apt-get clean
step 10 "Update apt"
try apt-get update

autoSetupVenv

step 80 "Install the required python packages"
try ${VENV_DIR}/bin/python3 -m pip install -r ${BASE_DIR}/requirements.txt

step 90 "Summary of installed packages"
${VENV_DIR}/bin/python3 -m pip freeze

post
```

In this script you see the usual usage of `pre`, `try`, `tryOrStop`, `post` ... statements coming from dependance.lib so I won't explain them further.

The interesting part is `autoSetupVenv` which do the following:

- install needed apt packages for venv creation
- init pyenv and check if a new version of python must be installed or updated (based on `TARGET_PYTHON_VERSION` as before)
- setup the venv (in `VENV_DIR` as before) with pyenv if required

### Fully manual setup of venv

If you want or need to control in detail each steps (or if you don't want to benefit from dependance.lib) then you can use individually each of the following functions (that are actually used by `autoSetupVenv`)

In this case, you have the responsibility to call these functions in the correct order.

- `initPython3` - will install following apt packages: "python3 python3-pip python3-dev python3-venv" and test if python3 is correctly installed; these are the required package to setup the venv
- `isPyEnvNeeded` - will test if pyenv (and extra python version) is needed; i.e. if python version coming with Debian is greater or equal the `TARGET_PYTHON_VERSION`
- `installOrUpdatePyEnv` - will install or update pyenv and all required packages
- `installPython3WithPyEnv` - will install a python version greater or equal `TARGET_PYTHON_VERSION` unless one exists already
- `createVenv` - will actually create or update the venv to match the `TARGET_PYTHON_VERSION` (2 preceding steps are required before)

Do not hesitate to take a look at functions `launchInstall` & `autoSetupVenv` to understand how to use them but I discourage usage of this "low level" functions. Usage of `launchInstall` or `autoSetupVenv` should be sufficient and if not, let discuss first ;-)

## Additional adaptations of in your plugin

### Usage of python bin (mandatory)

You must use the python bin of the venv of your plugin and not the one of the system.
The path will be `__DIR__ . '/../../resources/venv/bin/python3'` (if default folder used) instead of `python3` or `/usr/bin/python3`.

### Exclude venv dir from backup (mandatory)

The drawback of having a virtual environment is the fact that dependencies will take a little more space on storage (because each plugin has its own version of the libs). This is not really a big deal versus the benefit but let's not include these files in the backup of Jeedom.

On top, in case of restore, if venv dir is include, this will failed at next daemon start because the symbolic links will be broken.

To do this, you need to add such function in your eqLogic class and the core will take care of the exclusion (you need to adapt path if you decide to change the default folder):

```PHP
    public static function backupExclude() {
        return [
            'resources/venv'
        ];
    }
```

### Adapt plugin info.json (recommended)

As said before, installing specific python version might take a very long time on small configuration, so don't forget to adapt `info.json` file to increase `maxDependancyInstallTime` parameter to at least 60 min if you request a specific python version:

```JSON
    "hasDependency": true,
    "hasOwnDeamon": true,
    "maxDependancyInstallTime": 60,
```

### Dependencies check (recommended)

Because we use a `requirements.txt` to manage dependencies version, it would be beneficial to use it as well for the dependencies check to avoid copy/pasting list of librairies in the PHP code.

So here is an example of `dependancy_info()` function compatible with this lib. This is an example with default paths, you need to adapt them to match your plugin structure if you didn't followed the default:

```PHP
public static function dependancy_info() {
    $return = array();
    $return['log'] = log::getPathToLog(__CLASS__ . '_update');
    $return['progress_file'] = jeedom::getTmpFolder(__CLASS__) . '/dependance';
    $return['state'] = 'ok';
    if (file_exists(jeedom::getTmpFolder(__CLASS__) . '/dependance')) {
        $return['state'] = 'in_progress';
    } elseif (!self::pythonRequirementsInstalled(__DIR__ . '/../../resources/venv/bin/python3', __DIR__ . '/../../resources/requirements.txt')) {
        $return['state'] = 'nok';
    }
    return $return;
}
```

and the `pythonRequirementsInstalled()` function (also available in <https://github.com/Mips2648/jeedom-tools>):

```PHP
private static function pythonRequirementsInstalled(string $pythonPath, string $requirementsPath) {
    if (!file_exists($pythonPath) || !file_exists($requirementsPath)) {
        return false;
    }
    exec("{$pythonPath} -m pip freeze", $packages_installed);
    $packages = join("||", $packages_installed);
    exec("cat {$requirementsPath}", $packages_needed);
    foreach ($packages_needed as $line) {
        if (preg_match('/([^\s]+)[\s]*([>=~]=)[\s]*([\d+\.?]+)$/', $line, $need) === 1) {
            if (preg_match('/' . $need[1] . '==([\d+\.?]+)/', $packages, $install) === 1) {
                if ($need[2] == '==' && $need[3] != $install[1]) {
                    return false;
                } elseif (version_compare($need[3], $install[1], '>')) {
                    return false;
                }
            } else {
                return false;
            }
        }
    }
    return true;
}
```

Attention, it supports only following syntax: `==`, `~=`, `>=`.

Examples:

```txt
jeedomdaemon~=0.10.1
jeedomdaemon>=0.10.1
jeedomdaemon==0.10.1
```

Feel free to reuse them as you which.
