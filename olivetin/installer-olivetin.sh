#!/bin/bash
appDirectory="/usr/local/bin/"
appConfigDirectory="/etc/OliveTin"
appWebDirectory="/var/www/olivetin"
serviceDirectory="/etc/systemd/system/"
appDownloadUrl="https://github.com/OliveTin/OliveTin/releases/download/2022-01-06/OliveTin-2022-01-06-linux-amd64.tar.gz"
tempDirectory="/var/tmp/Olivetin"

#   Checking for URL Override
! [[ "${inputUrl}" ]] || appDownloadUrl="${inputUrl}"

function downloadApp()  {
    echo    "INFO: Downloading Application, Version: "
    mkdir -p "${tempDirectory}"
    curl -Lo "${tempDirectory}/${appDownloadUrl##*/}" "${appDownloadUrl}"
    echo "${tempDirectory}/${appDownloadUrl##*/}"
    tar xf "${tempDirectory}/${appDownloadUrl##*/}" -C "${tempDirectory}"
}

function installApp()   {
    installFiles="$(find "${tempDirectory}" -maxdepth 1 -mindepth 1 -type d)"
    currentUser="$(whoami)"
    [[ -d "${appConfigDirectory}" ]] || mkdir -p "${appConfigDirectory}"
    [[ -d "${appWebDirectory}" ]] || mkdir -p "${appWebDirectory}"
    cp -R "${installFiles}/webui" "${appWebDirectory}"
    cp "${installFiles}/OliveTin" "${appDirectory}/OliveTin"
    cp "${installFiles}/OliveTin.service" "${serviceDirectory}/OliveTin.service"
    cp "${installFiles}/config.yaml" "${appConfigDirectory}"
    chown "${currentUser}":"${currentUser}" "${appDirectory}/OliveTin" "${appConfigDirectory}/config.yaml"
    chown -R "${currentUser}":"${currentUser}" "${appWebDirectory}"
    systemctl enable OliveTin.service
    sudo systemctl start OliveTin
}

function cleanUp()  {
    rm -R "${tempDirectory}"
}

# ------- Read Parameters --------
for params in "$@"; do
    case $params in
        --url=*)
			inputUrl="${params#*=}"
			shift # Next Argument
			;;
		--help)
			showHelp
			shift # Next Argument
			;;
    esac
done

downloadApp || eval 'echo "ERROR:	Download Failed" 1>&2;'
installApp || eval 'echo "ERROR:	Install Failed" 1>&2;'
cleanUp