#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>

# © Enrique Estévez Fernández <keko.gl[fix@]gmail[fix.]com>
# © Proxecto Trasno <proxecto[fix@]trasno[fix.]net>
# xuño 2013 - outubro 2015 - novembro 2016

## -

# execute « [bash |./]mozilla TASK [REPOSITORY(or project)] »

## Script pretende permitir a creación dun proxecto en OmegaT para traducir as páxinas webs e outros servizos-proxectos de Mozilla e a xestión de actualización da tradución


# Path to the folder where the projects are placed
root_path="/home/keko/mozilla"

Ruta_Locales="locales/en-US"

# Change by the name of the project. In this case, prox-omt-moz
omt_path="prox-omt-moz"

# Identifica o idioma ao que se traducirán os proxectos de Mozilla.
# Hai que modificar o seu valor, polo código de locale do seu idioma.
locale_code="gl"

# Note: replace "ssh:/" with "https:/" if you don't have SSH access to hg.mozilla.org
mode="ssh:/"
mozilla_url="hg.mozilla.org"

# "https://github.com/mozilla-l10n/$reponame.git"
github_url="git@github.com:mozilla-l10n"

git_path="git"
hg_path="hg"
exist_repo=false


## Código reutilizado dun script de Francesco Flodolo (Membro do equipo l10n de Mozilla)
## https://github.com/flodolo/scripts/blob/master/mozilla_l10n/update_central.sh
#############################################################################################
function interrupt_code()
# This code runs if user hits control-c
{
  echored "*** Setup interrupted ***"
  exit $?
}

# Trap keyboard interrupt (control-c)
trap interrupt_code SIGINT

# Pretty printing functions
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2; tput bold)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)

function echored() {
    echo -e "$RED$*$NORMAL"
}

function echogreen() {
    echo -e "$GREEN$*$NORMAL"
}

function echoyellow() {
    echo -e "$YELLOW$*$NORMAL"
}

#############################################################################################

function exist_hg_repo(){
	hg identify $1 &> /dev/null
	if [ $? -eq 0 ]
		then
			return 0
		else
			return 1
		fi
}

function exist_git_repo(){
	git ls-remote $1 &> /dev/null
	if [ "$?" -eq 0 ]
		then
			return 0
		else
			return 1
		fi
}

# Check if a folder exist. In case afirmativ, it deletes the folder.
function if_exist_delete(){
	if [ -d $1 ]
		then
			rm -r $1
		fi
}

# Check if a folder exist. In case afirmativ, it deletes the folder. It always creates the folder.
function if_exist_delete_create(){
	if [ -d $1 ]
		then
			rm -r $1
		fi
	mkdir -p $1
}

# Remove all files into the target folder of the OmegaT project.
function remove_target_files(){
	if [ -d ./$omt_path/target ]
		then
			[ "$(ls -A ./$omt_path/target)" ] && rm -r ./$omt_path/target/*
		else
			echored "Error: The target folder does not exist."
			echoyellow "Isto significa:"
			echoyellow "	- Ou ben non existe o proxecto de OmegaT no marco de traballo. Ten que crealo."
			echoyellow "	- Ou o proxecto está mal creado. Volva a crealo ou modifique a configuración do proxecto."
		fi
}
#############################################################################################

function init(){

	if [ -d ./$git_path ]
		then
			echoyellow "The $git_path folder already exists."
			echoyellow "This folder stores the projects host in git repositories."
		else
			mkdir -p $git_path
			echogreen "Created the $git_path folder."
			echogreen "This folder will store the projects host in git repositories."
		fi

	if [ -d ./$hg_path ]
		then
			echoyellow "The $hg_path folder already exists."
			echoyellow "This folder stores the projects host in hg repositories."
		else
			mkdir -p $hg_path
			echogreen "Created the $hg_path folder."
			echogreen "This folder will store the projects host in hg repositories."
		fi

	if [ -d ./$omt_path ]
		then
			echoyellow "The $omt_path folder already exists."
			echoyellow "Then, the OmegaT project is already created."
		else
			echored "Error: The $omt_path project of OmegaT does not exist."
			echoyellow "Launch OmegaT and create the $omt_path project using the user manual."
		fi


}

# Funcións para clonar, actualizar, obter os ficheiros l10n e devolvelos traducidos para
# os proxectos de Mozilla na conta GitHub do equipo de localización de Mozilla.
#############################################################################################
function clone_repo_mozilla_l10n(){
	# $1: (project)repository name
	local reponame="$1"

	if [ -d ./$git_path/$reponame/.git ]
		then
			echoyellow "The $reponame repository already exists."
			echoyellow "Try ./mozilla.sh updateRepo $reponame to update the repository."
		else
			local url="$github_url/$reponame.git"

			if exist_git_repo $url
				then
					echogreen "Cloning the $reponame repository."
					cd $git_path
					git clone $url
					cd $root_path
					echogreen "Cloned the $reponame repository."
				else
					echored "Error: Unable to read from $url"
					echored "Seems that the $reponame repository does not exist."
				fi
		fi
}

function update_repo_mozilla_l10n(){
	# $1: (project)repository name
	local reponame="$1"

	if [ -d ./$git_path/$reponame/.git ]
		then
			echogreen "Updating the $reponame repository."
			cd ./$git_path/$reponame
			git pull
			cd $root_path
			echogreen "Updated the $reponame repository."
		else
			echored "Error: The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneRepo $reponame to clone the project."
		fi
}

function get_l10n(){
	# $1: (project)repository name
	local reponame="$1"

	if [ -d ./$git_path/$reponame/.git ]
		then
			if [ -d ./$git_path/$reponame/$locale_code ]
				then
					echogreen "Copying l10n files for the $reponame project into OmegaT Project."
					if_exist_delete_create ./$omt_path/source/$reponame

					cp -r ./$git_path/$reponame/$locale_code/* ./$omt_path/source/$reponame/
					echogreen "Copied l10n files into OmegaT."
				else
					echored "The $reponame repository exist, but your locale is not actived."
					echoyellow "Contact with the Mozilla l10n team to activate the project for your locale."
				fi
		else
			echored "Error: The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneRepo $reponame to clone the project."
		fi
}

function return_l10n(){
	# $1: (project)repository name
	local reponame="$1"

	if [ -d ./$git_path/$reponame/.git ]
		then
			if [ -d ./$git_path/$reponame/$locale_code ]
				then
					if [ -d ./$omt_path/target/$reponame ]
						then
							echogreen "Updating the translations of $reponame project."
							rm -r ./$git_path/$reponame/$locale_code/*
							cp -r ./$omt_path/target/$reponame/* ./$git_path/$reponame/$locale_code/
							echogreen "Updated the translations of project."
						else
							echored "Error: There is no translations. Do not exist the project into target folder."
							echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
							echoyellow "Execute ./mozilla.sh getL10n $reponame to copy the l10n files into OmegaT."
					fi
				else
					echored "The $reponame repository exist, but your locale is not actived."
					echoyellow "Contact with the Mozilla l10n team to activate the project for your locale."
				fi
		else
			echored "Error: The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneRepo $reponame to clone the project."
			echoyellow "Then ./mozilla.sh getL10n $reponame to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh returnL10n $reponame again."
		fi
}

#############################################################################################


# Funcións para clonar, actualizar, obter os ficheiros l10n e devolvelos traducidos para
# os proxectos de Mozilla nos repositorios Mercurial.
# A función clone_hg_repos() clonar o repositorio central para o locale definido na variable
# ou para o que se lle pase como parámetro. Útil, para coa mesma función clonar o repositorio
# en-US para Gaia.
#############################################################################################
# Clona os repositorios l10n-central, mozilla-aurora, mozilla-beta e gaia-l10n para o locale
# definido na variable locale_code. Tamén clona o repositorio gaia-l10n para o locale pasado
# por parámetro, pensado para en-US (fontes). Clónao sen permisos de escrita.
function clone_hg_repos(){
	# $1: (project)repository name
	local reponame="$1"
	local locale=""

	if [ $# -eq 2 ]
		then
			locale=$2
			mode="https:/"

		else
			locale=$locale_code
		fi

	if [ $reponame == "mozilla-aurora" ] || [ $reponame == "mozilla-beta" ]
		then
			reponame="releases/l10n/$reponame"
		fi

	local url="$mode/$mozilla_url/$reponame/$locale"

	if exist_hg_repo $url
		then
			if [ ! -d ./$hg_path/$reponame ]
				then
					mkdir -p ./$hg_path/$reponame
				fi

			if [ -d ./$hg_path/$reponame/$locale/.hg ]
				then
					echoyellow "The $1/$locale repository already exist."
					echoyellow "Try ./mozilla.sh updateHg $1 $locale to update the repository."
				else
					echogreen "Cloning the $1/$locale repository."
					cd $hg_path/$reponame
					hg clone $url
					cd $root_path
					echogreen "Cloned the $1/$locale repository."
				fi
		else
			echored "Error: Unable to read from $url"
			echored "Seems that the $1/$locale repository does not exist."
		fi
}

function update_hg_repos(){
	# $1: (project)repository name
	local reponame="$1"
	local locale=""

	if [ $# -eq 2 ]
		then
			locale=$2
			mode="https:/"

		else
			locale=$locale_code
		fi

	if [ $reponame == "mozilla-aurora" ] || [ $reponame == "mozilla-beta" ]
		then
			reponame="releases/l10n/$reponame"
		fi

	if [ -d ./$hg_path/$reponame/$locale/.hg ]
		then
			echogreen "Updating the $1/$locale repository."
			cd $hg_path/$reponame/$locale
			hg pull -u
			cd $root_path
			echogreen "Updated the $1/$locale repository."
		else
			echored "Error: The $1/$locale repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg $1 $locale to clone the repository."
		fi
}

function get_l10n_Gaia(){

	if [ -d ./$hg_path/gaia-l10n/en-US/.hg ]
		then
			echogreen "Copying l10n files for the gaia-l10n repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/gaia-l10n
			cp -r ./$hg_path/gaia-l10n/en-US/* ./$omt_path/source/gaia-l10n/
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The gaia-l10n/en-US repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg gaia-l10n en-US to clone the repository."
		fi
}

function return_l10n_Gaia(){

	if [ -d ./$hg_path/gaia-l10n/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/gaia-l10n ]
				then
						echogreen "Updating the translations of gaia-l10n/$locale_code repository."
						rm -r ./$hg_path/gaia-l10n/$locale_code/*
						cp -r ./$omt_path/target/gaia-l10n/* ./$hg_path/gaia-l10n/$locale_code/
						echogreen "Updated the translations of project."
					else
						echored "Error: There is no translations. Do not exist the project into target folder."
						echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
						echoyellow "Execute ./mozilla.sh getGaia to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The gaia-l10n/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg gaia-l10n clone the repository."
			echoyellow "Then ./mozilla.sh getGaia to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh returnGaia again."
		fi
}

function clone_hg_channel(){
	# $1: (project)repository name
	local reponame="$1"
	local repo_path="."

	if [ $reponame == "comm-aurora" ] || [ $reponame == "comm-beta" ]
		then
			reponame="releases/$reponame"
			repo_path="releases"
		fi

	local url="https://$mozilla_url/$reponame"

	if exist_hg_repo $url
		then
			if [ -d ./$hg_path/$reponame/.hg ]
				then
					echoyellow "The $1 repository already exist."
					echoyellow "Try ./mozilla.sh updateChannel $1 to update the repository."
				else
					echogreen "Cloning the $1 repository."
					mkdir -p $hg_path/$repo_path
					cd $hg_path/$repo_path
					hg clone $url
					cd $1
					python client.py checkout
					cd $root_path
					echogreen "Cloned the $1 repository."

				fi
		else
			echored "Error: Unable to read from $url"
			echored "Seems that the $1 repository does not exist."
		fi

}

function update_hg_channel(){
	# $1: (project)repository name
	local reponame="$1"

	if [ $reponame == "comm-aurora" ] || [ $reponame == "comm-beta" ]
		then
			reponame="releases/$reponame"
		fi

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Updating the $1 repository."
			cd ./$hg_path/$reponame
			python client.py checkout
			cd $root_path
			echogreen "Updated the $1 repository."
		else
			echored "Error: The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel $reponame to clone the repository."
		fi
}

#############################################################################################




#############################################################################################
function get_files_browser(){
	# $1: (project)repository name
	local reponame="$1"

	if [ $reponame == "comm-aurora" ] || [ $reponame == "comm-beta" ]
		then
			reponame="releases/$reponame"
		fi

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $1 repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/$reponame/browser
			cp -r ./$hg_path/$reponame/mozilla/browser/${Ruta_Locales}/* ./$omt_path/source/$reponame/browser
			mkdir -p ./$omt_path/source/$reponame/devtools/client
			mkdir -p ./$omt_path/source/$reponame/devtools/shared
			cp -r ./$hg_path/$reponame/mozilla/devtools/client/${Ruta_Locales}/* ./$omt_path/source/$reponame/devtools/client
			cp -r ./$hg_path/$reponame/mozilla/devtools/shared/${Ruta_Locales}/* ./$omt_path/source/$reponame/devtools/shared
			mkdir -p ./$omt_path/source/$reponame/browser/branding/official
			cp -r ./$hg_path/$reponame/mozilla/browser/branding/official/${Ruta_Locales}/* ./$omt_path/source/$reponame/browser/branding/official
			# Files to exclude of OmegaT
			# Bug 1276740 - Centralize all search plugins into mozilla-central
			# rm -r ./$omt_path/source/$reponame/browser/searchplugins
			rm -r ./$omt_path/source/$reponame/browser/chrome/browser-region
			rm -r ./$omt_path/source/$reponame/browser/defines.inc
			rm -r ./$omt_path/source/$reponame/browser/firefox-l10n.js
			# To delete o bookmarks.inc file
			rm -r ./$omt_path/source/$reponame/browser/profile
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $1 repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel $1 to clone the repository."
		fi
}

function move_files_browser(){
	# $1: (project)repository name
	local reponame="$1"
	local path="."
	local target_path="."

	if [ $reponame == "aurora" ] || [ $reponame == "beta" ]
		then
			target_path="releases/l10n"
			path="releases"
			reponame="mozilla-$reponame"
		else
			reponame="l10n-$reponame"
		fi

	if [ -d ./$hg_path/$target_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/$path/comm-$1/browser ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/browser/branding
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/browser/crashreporter
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/browser/installer
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/browser/pdfviewer
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/browser/updater
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/browser/chrome/browser
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/browser/chrome/overrides
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/devtools
					cp -r ./$omt_path/target/$path/comm-$1/browser/* ./$hg_path/$target_path/$reponame/$locale_code/browser/
					cp -r ./$omt_path/target/$path/comm-$1/devtools ./$hg_path/$target_path/$reponame/$locale_code/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg $reponame clone the repository."
			echoyellow "Then ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveBrowser $1 again."
		fi
}

function get_files_toolkit(){
	# $1: (project)repository name
	local reponame="$1"

	if [ $reponame == "comm-aurora" ] || [ $reponame == "comm-beta" ]
		then
			reponame="releases/$reponame"
		fi

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $1 repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/$reponame/toolkit
			cp -r ./$hg_path/$reponame/mozilla/toolkit/${Ruta_Locales}/* ./$omt_path/source/$reponame/toolkit

			# Files to exclude of OmegaT
			rm -r ./$omt_path/source/$reponame/toolkit/defines.inc
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $1 repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel $1 to clone the repository."
		fi
}

function move_files_toolkit(){
	# $1: (project)repository name
	local reponame="$1"
	local path="."
	local target_path="."

	if [ $reponame == "aurora" ] || [ $reponame == "beta" ]
		then
			target_path="releases/l10n"
			path="releases"
			reponame="mozilla-$reponame"
		else
			reponame="l10n-$reponame"
		fi

	if [ -d ./$hg_path/$target_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/$path/comm-$1/toolkit ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/toolkit/chrome
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/toolkit/crashreporter
					cp -r ./$omt_path/target/$path/comm-$1/toolkit/* ./$hg_path/$target_path/$reponame/$locale_code/toolkit/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg $reponame clone the repository."
			echoyellow "Then ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveBrowser $1 again."
		fi
}

function get_files_mobile(){
	# $1: (project)repository name
	local reponame="$1"

	if [ $reponame == "comm-aurora" ] || [ $reponame == "comm-beta" ]
		then
			reponame="releases/$reponame"
		fi

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $1 repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/$reponame/mobile
			cp -r ./$hg_path/$reponame/mozilla/mobile/${Ruta_Locales}/* ./$omt_path/source/$reponame/mobile
			mkdir -p ./$omt_path/source/$reponame/mobile/android
			cp -r ./$hg_path/$reponame/mozilla/mobile/android/${Ruta_Locales}/* ./$omt_path/source/$reponame/mobile/android
			mkdir -p ./$omt_path/source/$reponame/mobile/android/base
			cp -r ./$hg_path/$reponame/mozilla/mobile/android/base/${Ruta_Locales}/* ./$omt_path/source/$reponame/mobile/android/base
			# Files to exclude of OmegaT
			rm -r ./$omt_path/source/$reponame/mobile/searchplugins
			rm -r ./$omt_path/source/$reponame/mobile/chrome
			rm -r ./$omt_path/source/$reponame/mobile/android/defines.inc
			rm -r ./$omt_path/source/$reponame/mobile/android/mobile-l10n.js
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $1 repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel $1 to clone the repository."
		fi
}

function move_files_mobile(){
	# $1: (project)repository name
	local reponame="$1"
	local path="."
	local target_path="."

	if [ $reponame == "aurora" ] || [ $reponame == "beta" ]
		then
			target_path="releases/l10n"
			path="releases"
			reponame="mozilla-$reponame"
		else
			reponame="l10n-$reponame"
		fi

	if [ -d ./$hg_path/$target_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/$path/comm-$1/mobile ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/mobile/android/base
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/mobile/android/chrome
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/mobile/overrides
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/mobile/xul
					cp -r ./$omt_path/target/$path/comm-$1/mobile/* ./$hg_path/$target_path/$reponame/$locale_code/mobile/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg $reponame clone the repository."
			echoyellow "Then ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveBrowser $1 again."
		fi
}

function get_files_editor(){
	# $1: (project)repository name
	local reponame="$1"

	if [ $reponame == "comm-aurora" ] || [ $reponame == "comm-beta" ]
		then
			reponame="releases/$reponame"
		fi

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $1 repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/$reponame/editor
			mkdir -p ./$omt_path/source/$reponame/editor/ui
			cp -r ./$hg_path/$reponame/editor/ui/${Ruta_Locales}/* ./$omt_path/source/$reponame/editor/ui
			# Files to exclude of OmegaT
			rm -r ./$omt_path/source/$reponame/editor/ui/chrome/region
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $1 repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel $1 to clone the repository."
		fi
}

function move_files_editor(){
	# $1: (project)repository name
	local reponame="$1"
	local path="."
	local target_path="."

	if [ $reponame == "aurora" ] || [ $reponame == "beta" ]
		then
			target_path="releases/l10n"
			path="releases"
			reponame="mozilla-$reponame"
		else
			reponame="l10n-$reponame"
		fi

	if [ -d ./$hg_path/$target_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/$path/comm-$1/editor ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/editor/ui/chrome/composer
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/editor/ui/chrome/dialogs
					cp -r ./$omt_path/target/$path/comm-$1/editor/* ./$hg_path/$target_path/$reponame/$locale_code/editor/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg $reponame clone the repository."
			echoyellow "Then ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveBrowser $1 again."
		fi
}

function get_files_mail(){
	# $1: (project)repository name
	local reponame="$1"

	if [ $reponame == "comm-aurora" ] || [ $reponame == "comm-beta" ]
		then
			reponame="releases/$reponame"
		fi

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $1 repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/$reponame/mail
			cp -r ./$hg_path/$reponame/mail/${Ruta_Locales}/* ./$omt_path/source/$reponame/mail

			# Files to exclude of OmegaT
			rm -r ./$omt_path/source/$reponame/mail/searchplugins
			rm -r ./$omt_path/source/$reponame/mail/chrome/messenger-region
			rm -r ./$omt_path/source/$reponame/mail/defines.inc
			rm -r ./$omt_path/source/$reponame/mail/all-l10n.js
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $1 repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel $1 to clone the repository."
		fi
}

function move_files_mail(){
	# $1: (project)repository name
	local reponame="$1"
	local path="."
	local target_path="."

	if [ $reponame == "aurora" ] || [ $reponame == "beta" ]
		then
			target_path="releases/l10n"
			path="releases"
			reponame="mozilla-$reponame"
		else
			reponame="l10n-$reponame"
		fi

	if [ -d ./$hg_path/$target_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/$path/comm-$1/mail ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/mail/feedback
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/mail/installer
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/mail/updater
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/mail/communicator
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/mail/messenger
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/mail/messenger-mapi
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/mail/messenger-newsblog
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/mail/messenger-smime
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/mail/mozldap
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/mail/overrides
					cp -r ./$omt_path/target/$path/comm-$1/mail/* ./$hg_path/$target_path/$reponame/$locale_code/mail/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg $reponame clone the repository."
			echoyellow "Then ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveBrowser $1 again."
		fi
}

function get_files_calendar(){
	# $1: (project)repository name
	local reponame="$1"

	if [ $reponame == "comm-aurora" ] || [ $reponame == "comm-beta" ]
		then
			reponame="releases/$reponame"
		fi

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $1 repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/$reponame/calendar
			cp -r ./$hg_path/$reponame/calendar/${Ruta_Locales}/* ./$omt_path/source/$reponame/calendar

			# Files to exclude of OmegaT
			rm -r ./$omt_path/source/$reponame/calendar/lightning-l10n.js
			rm -r ./$omt_path/source/$reponame/calendar/README.txt
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $1 repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel $1 to clone the repository."
		fi
}

function move_files_calendar(){
	# $1: (project)repository name
	local reponame="$1"
	local path="."
	local target_path="."

	if [ $reponame == "aurora" ] || [ $reponame == "beta" ]
		then
			target_path="releases/l10n"
			path="releases"
			reponame="mozilla-$reponame"
		else
			reponame="l10n-$reponame"
		fi

	if [ -d ./$hg_path/$target_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/$path/comm-$1/calendar ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/calendar/chrome
					cp -r ./$omt_path/target/$path/comm-$1/calendar/* ./$hg_path/$target_path/$reponame/$locale_code/calendar/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg $reponame clone the repository."
			echoyellow "Then ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveBrowser $1 again."
		fi
}

function get_files_chat(){
	# $1: (project)repository name
	local reponame="$1"

	if [ $reponame == "comm-aurora" ] || [ $reponame == "comm-beta" ]
		then
			reponame="releases/$reponame"
		fi

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $1 repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/$reponame/chat
			cp -r ./$hg_path/$reponame/chat/${Ruta_Locales}/* ./$omt_path/source/$reponame/chat
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $1 repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel $1 to clone the repository."
		fi
}

function move_files_chat(){
	# $1: (project)repository name
	local reponame="$1"
	local path="."
	local target_path="."

	if [ $reponame == "aurora" ] || [ $reponame == "beta" ]
		then
			target_path="releases/l10n"
			path="releases"
			reponame="mozilla-$reponame"
		else
			reponame="l10n-$reponame"
		fi

	if [ -d ./$hg_path/$target_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/$path/comm-$1/chat ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/chat
					cp -r ./$omt_path/target/$path/comm-$1/chat ./$hg_path/$target_path/$reponame/$locale_code/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg $reponame clone the repository."
			echoyellow "Then ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveBrowser $1 again."
		fi
}

function get_files_dom(){
	# $1: (project)repository name
	local reponame="$1"

	if [ $reponame == "comm-aurora" ] || [ $reponame == "comm-beta" ]
		then
			reponame="releases/$reponame"
		fi

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $1 repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/$reponame/dom
			cp -r ./$hg_path/$reponame/mozilla/dom/${Ruta_Locales}/* ./$omt_path/source/$reponame/dom
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $1 repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel $1 to clone the repository."
		fi
}

function get_files_netwerk(){
	# $1: (project)repository name
	local reponame="$1"

	if [ $reponame == "comm-aurora" ] || [ $reponame == "comm-beta" ]
		then
			reponame="releases/$reponame"
		fi

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $1 repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/$reponame/netwerk
			cp -r ./$hg_path/$reponame/mozilla/netwerk/${Ruta_Locales}/* ./$omt_path/source/$reponame/netwerk
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $1 repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel $1 to clone the repository."
		fi
}

function get_files_otherlicenses(){
	# $1: (project)repository name
	local reponame="$1"

	if [ $reponame == "comm-aurora" ] || [ $reponame == "comm-beta" ]
		then
			reponame="releases/$reponame"
		fi

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $1 repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/$reponame/other-licenses/branding/thunderbird
			cp -r ./$hg_path/$reponame/other-licenses/branding/thunderbird/${Ruta_Locales}/* ./$omt_path/source/$reponame/other-licenses/branding/thunderbird
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $1 repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel $1 to clone the repository."
		fi
}

function get_files_security(){
	# $1: (project)repository name
	local reponame="$1"

	if [ $reponame == "comm-aurora" ] || [ $reponame == "comm-beta" ]
		then
			reponame="releases/$reponame"
		fi

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $1 repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/$reponame/security
			mkdir -p ./$omt_path/source/$reponame/security/manager
			cp -r ./$hg_path/$reponame/mozilla/security/manager/${Ruta_Locales}/* ./$omt_path/source/$reponame/security/manager
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $1 repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel $1 to clone the repository."
		fi
}

function get_files_services(){
	# $1: (project)repository name
	local reponame="$1"

	if [ $reponame == "comm-aurora" ] || [ $reponame == "comm-beta" ]
		then
			reponame="releases/$reponame"
		fi

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $1 repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/$reponame/services
			mkdir -p ./$omt_path/source/$reponame/services/sync
			cp -r ./$hg_path/$reponame/mozilla/services/sync/${Ruta_Locales}/* ./$omt_path/source/$reponame/services/sync
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $1 repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel $1 to clone the repository."
		fi
}

function move_files_rest(){
	# $1: (project)repository name
	local reponame="$1"
	local path="."
	local target_path="."

	if [ $reponame == "aurora" ] || [ $reponame == "beta" ]
		then
			target_path="releases/l10n"
			path="releases"
			reponame="mozilla-$reponame"
		else
			reponame="l10n-$reponame"
		fi

	if [ -d ./$hg_path/$target_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/$path/comm-$1 ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/dom
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/netwerk
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/other-licenses
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/security
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/services

					cp -r ./$omt_path/target/$path/comm-$1/dom ./$hg_path/$target_path/$reponame/$locale_code/
					cp -r ./$omt_path/target/$path/comm-$1/netwerk ./$hg_path/$target_path/$reponame/$locale_code/
					cp -r ./$omt_path/target/$path/comm-$1/other-licenses ./$hg_path/$target_path/$reponame/$locale_code/
					cp -r ./$omt_path/target/$path/comm-$1/security ./$hg_path/$target_path/$reponame/$locale_code/
					cp -r ./$omt_path/target/$path/comm-$1/services ./$hg_path/$target_path/$reponame/$locale_code/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg $reponame clone the repository."
			echoyellow "Then ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveBrowser $1 again."
		fi
}

function get_files_suite(){
	# $1: (project)repository name
	local reponame="$1"

	if [ $reponame == "comm-aurora" ] || [ $reponame == "comm-beta" ]
		then
			reponame="releases/$reponame"
		fi

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $1 repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/$reponame/suite
			cp -r ./$hg_path/$reponame/suite/${Ruta_Locales}/* ./$omt_path/source/$reponame/suite

			# Files to exclude of OmegaT
			rm -r ./$omt_path/source/$reponame/suite/searchplugins
			rm -r ./$omt_path/source/$reponame/suite/suite-l10n.js
			rm -r ./$omt_path/source/$reponame/suite/defines.inc
			rm -r ./$omt_path/source/$reponame/suite/extra-jar.mn
			rm -r ./$omt_path/source/$reponame/suite/profile
			rm -r ./$omt_path/source/$reponame/suite/chrome/browser/region.properties
			rm -r ./$omt_path/source/$reponame/suite/chrome/common/region.properties
			rm -r ./$omt_path/source/$reponame/suite/chrome/mailnews/region.properties
			rm -r ./$omt_path/source/$reponame/suite/chrome/common/help
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $1 repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel $1 to clone the repository."
		fi
}

function move_files_suite(){
	# $1: (project)repository name
	local reponame="$1"
	local path="."
	local target_path="."

	if [ $reponame == "aurora" ] || [ $reponame == "beta" ]
		then
			target_path="releases/l10n"
			path="releases"
			reponame="mozilla-$reponame"
		else
			reponame="l10n-$reponame"
		fi

	if [ -d ./$hg_path/$target_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/$path/comm-$1/suite ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."

					mv ./$hg_path/$target_path/$reponame/$locale_code/suite/chrome/browser/region.properties ./$hg_path/$target_path/$reponame/$locale_code/regionbrowser.properties
					mv ./$hg_path/$target_path/$reponame/$locale_code/suite/chrome/common/region.properties ./$hg_path/$target_path/$reponame/$locale_code/regioncommon.properties
					mv ./$hg_path/$target_path/$reponame/$locale_code/suite/chrome/mailnews/region.properties ./$hg_path/$target_path/$reponame/$locale_code/regionmailnews.properties
					mv ./$hg_path/$target_path/$reponame/$locale_code/suite/chrome/common/help ./$hg_path/$target_path/$reponame/$locale_code/

					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/suite/crashreporter
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/suite/installer
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/suite/updater
					if_exist_delete ./$hg_path/$target_path/$reponame/$locale_code/suite/chrome
					cp -r ./$omt_path/target/$path/comm-$1/suite/* ./$hg_path/$target_path/$reponame/$locale_code/suite/

					mv ./$hg_path/$target_path/$reponame/$locale_code/regionbrowser.properties ./$hg_path/$target_path/$reponame/$locale_code/suite/chrome/browser/region.properties
					mv ./$hg_path/$target_path/$reponame/$locale_code/regioncommon.properties ./$hg_path/$target_path/$reponame/$locale_code/suite/chrome/common/region.properties
					mv ./$hg_path/$target_path/$reponame/$locale_code/regionmailnews.properties ./$hg_path/$target_path/$reponame/$locale_code/suite/chrome/mailnews/region.properties
					mv ./$hg_path/$target_path/$reponame/$locale_code/help ./$hg_path/$target_path/$reponame/$locale_code/suite/chrome/common/

					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg $reponame clone the repository."
			echoyellow "Then ./mozilla.sh getBrowser comm-$1 to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveBrowser $1 again."
		fi
}
#############################################################################################



#############################################################################################
function usage(){
	echogreen "Usage: ./mozilla.sh TASK [REPOSITORY(or project)]"
	echo ""
	echo "For more information, execute ./mozilla.sh --help"
}

function simple_help(){
	echogreen "Usage: ./mozilla.sh TASK [REPOSITORY(or project)]"
	echo ""
	echo "The script can execute the following tasks:"
	echo "	init		Initialize the framework. It creates the hg and git folders, if the"
	echo "			folders do not exist. It indicates whether the OmegaT project is created."
	echo ""
	echo "	cloneRepo	Clone the selected repository in the framework. Only supports git"
	echo "			repositories for l10n-mozilla GitHub account."
	echo "			Example of usage: ./mozilla.sh cloneRepo www.mozilla.org"
	echo "	updateRepo	Updates the selected repository in the framework. Updates the cloned repositories"
	echo "			with the 'cloneRepo' task."
	echo "	getL10n		Get the l10n files for the selected repository. Copy the l10n files of project"
	echo "			selected into source folder in the OmegaT project. Works with the cloned repositories"
	echo "			with the 'cloneRepo' task."
	echo "	returnL10n	Send the translated l10n files from the OmegaT project to the local repository."
	echo ""
	echo "	cloneHg		Clone the repository selected in the framework. Only supports hg repositories."
	echo "			The cloned repositories have only l10n files."
	echo "			Example of usage: ./mozilla.sh cloneHg l10n-central"
	echo "	updateHg	Updates the selected repository in the framework. Updates the cloned repositories"
	echo "			with the 'cloneHg' task."
	echo ""
	echo "	getGaia		Get the l10n files for the Gaia project (repository). Copy the l10n files of Gaia"
	echo "			into source folder in the OmegaT project. Works with the cloned repositories"
	echo "			with the 'cloneHg' task."
	echo "			Example of usage: ./mozilla.sh getGaia"
	echo "	returnGaia	Send the translated l10n files from the OmegaT project to the local repository."
	echo ""
	echo "	cloneChannel	Clone the selected repository in the framework. Only supports hg repositories."
	echo "			The cloned repositories have source code and l10n files."
	echo "			Example of usage: ./mozilla.sh cloneChannel comm-central."
	echo "	updateChannel	Updates the selected repository in the framework. Updates the cloned repositories"
	echo "			with the 'cloneChannel' task."
	echo "	getFirefox	Get the l10n files for the Firefox product from the selected repository. Copy the"
	echo "			l10n files into source folder in the OmegaT project."
	echo "	moveFirefox	Send the translated l10n files from the OmegaT project to the selected local repository."
	echo "	getFennec	Similar to the 'getFirefox' task but for the Fennec project."
	echo "	moveFennec	Similar to the 'moveFirefox' task but for the Fennec project."
	echo "	getThunderbird	Similar to the 'getFirefox' task but for the Thunderbird project."
	echo "	moveThunderbird	Similar to the 'moveFirefox' task but for the Thunderbird project."
	echo "	getSeaMonkey	Similar to the 'getFirefox' task but for the SeaMonkey project."
	echo "	moveSeaMonkey	Similar to the 'moveFirefox' task but for the SeaMonkey project."
	echo ""
	echo "	removeAll	Delete all l10n files in the target folder of the OmegaT project."
	echo ""
	echo "For more information for each task, see the user manual."

}
#############################################################################################

if [ $# -eq 0 ]
	then
		usage
	else
		param=$1
		[ $param = --help ] && simple_help
		[ $param = init ] && init
		[ $param = cloneRepo ] && clone_repo_mozilla_l10n $2
		[ $param = updateRepo ] && update_repo_mozilla_l10n $2
		[ $param = getL10n ] && get_l10n $2
		[ $param = returnL10n ] && return_l10n $2
		[ $param = cloneHg ] && clone_hg_repos $2 $3
		[ $param = updateHg ] && update_hg_repos $2 $3
		[ $param = getGaia ] && get_l10n_Gaia
		[ $param = returnGaia ] && return_l10n_Gaia
		[ $param = cloneChannel ] && clone_hg_channel $2
		[ $param = updateChannel ] && update_hg_channel $2
		[ $param = getFirefox ] && get_files_browser $2 && get_files_toolkit $2 && get_files_dom $2 && get_files_netwerk $2 && get_files_otherlicenses $2 && get_files_security $2 && get_files_services $2
		[ $param = moveFirefox ] && move_files_browser $2 && move_files_toolkit $2 && move_files_rest $2
		[ $param = getFennec ] && get_files_mobile $2
		[ $param = moveFennec ] && move_files_mobile $2
		[ $param = getThunderbird ] && get_files_mail $2 && get_files_editor $2 && get_files_chat $2 && get_files_calendar $2
		[ $param = moveThunderbird ] && move_files_mail $2 && move_files_editor $2 && move_files_chat $2 && move_files_calendar $2
		[ $param = getSeaMonkey ] && get_files_suite $2
		[ $param = moveSeaMonkey ] && move_files_suite $2
		[ $param = removeAll ] && remove_target_files
	fi

#.EOF
