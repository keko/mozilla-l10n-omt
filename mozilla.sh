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
	cd $root_path
	if [ -d $1 ]
		then
			rm -r $1
		fi
}

# Check if a folder exist. In case afirmativ, it deletes the folder. It always creates the folder.
function if_exist_delete_create(){
	cd $root_path
	if [ -d $1 ]
		then
			rm -r $1
		fi
	mkdir -p $1
}

# Remove all files into the target folder of the OmegaT project.
function remove_target_files(){
	cd $root_path
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
	cd $root_path

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

	cd $root_path

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

	cd $root_path

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

# Get the .xliff and .lang files from repositories cloned in local with the cloneRepo task and
# copy the files into the source folder of the OmegaT project. For the following projects:
#	mozilla.org
#	engagement-l10n
#	appstores
#	fhr-l10n
#	firefoxios-l10n
#	focusios-l10n
#############################################################################################
function get_l10n(){
	# $1: (project)repository name
	local reponame="$1"

	cd $root_path

	## Added support for the firefoxios and focusios projects
	if [ $reponame == "firefoxios-l10n" ] || [ $reponame == "focusios-l10n" ]
		then
			locale_code="en-US"
		fi


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

			## Added support for the firefoxios and focusios projects
			if [ $locale_code="en-US" ]
				then
					for i in $( find ./$omt_path/source/$reponame -name "*.xliff" ); do
						sed -i $i -e 's/target-language="en"/target-language="gl"/';
					done
				fi
		else
			echored "Error: The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneRepo $reponame to clone the project."
		fi
}

#############################################################################################
function return_l10n(){
	# $1: (project)repository name
	local reponame="$1"

	cd $root_path

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

# Get the .pot files from repositories cloned in local with the cloneRepo task and initialize
# the .pot files into the source folder of the OmegaT project. For the following projects:
#	zerda-android-l10n
#	firefoxtv-l10n
#	focus-android-l10n
#	mdn-l10n
#	sumo-l10n
#	mozillians-l10n
#############################################################################################
function get_l10n_pot(){
	# $1: (project)repository name
	local reponame="$1"

	cd $root_path

	if [ $reponame == "zerda-android-l10n" ] || [ $reponame == "firefoxtv-l10n" ] || [ $reponame == "focus-android-l10n" ]
		then
			locale_code="locales/templates"
		else
			locale_code="templates"
		fi

	if [ -d ./$git_path/$reponame/.git ]
		then
			if [ -d ./$git_path/$reponame/$locale_code ]
				then
					echogreen "Copying l10n files for the $reponame project into OmegaT Project."
					if_exist_delete_create ./$omt_path/source/$reponame

					cp -r ./$git_path/$reponame/$locale_code/* ./$omt_path/source/$reponame/


					for i in $( find ./$omt_path/source/$reponame -name "*.pot" ); do
						local target=${i%t}
						msginit -i $i -o $target;
						rm $i;
					done

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

#############################################################################################
function return_l10n_pot(){
	# $1: (project)repository name
	local reponame="$1"
	local locale="$locale_code"

	cd $root_path

	if [ $reponame == "zerda-android-l10n" ] || [ $reponame == "firefoxtv-l10n" ] || [ $reponame == "focus-android-l10n" ]
		then
			locale_code="locales/$locale"
		fi

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
							echoyellow "Execute ./mozilla.sh getL10nPot $reponame to copy the l10n files into OmegaT."
					fi
				else
					echored "The $reponame repository exist, but your locale is not actived."
					echoyellow "Contact with the Mozilla l10n team to activate the project for your locale."
				fi
		else
			echored "Error: The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneRepo $reponame to clone the project."
			echoyellow "Then ./mozilla.sh getL10nPot $reponame to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh returnL10nPot $reponame again."
		fi
}

#############################################################################################


# Funcións para clonar, actualizar, obter os ficheiros l10n e devolvelos traducidos para
# os proxectos de Mozilla nos repositorios Mercurial para a canle Central.
#############################################################################################

# Clona o repositorio l10n-central para o locale definido na variable locale_code.
function clone_hg_repo(){
	local reponame="l10n-central"
	local locale=$locale_code

	cd $root_path

	local url="$mode/$mozilla_url/$reponame/$locale"

	if exist_hg_repo $url
		then
			if [ ! -d ./$hg_path/$reponame ]
				then
					mkdir -p ./$hg_path/$reponame
				fi

			if [ -d ./$hg_path/$reponame/$locale/.hg ]
				then
					echoyellow "The $reponame/$locale repository already exist."
					echoyellow "Try ./mozilla.sh updateHg to update the $reponame/$locale repository."
				else
					echogreen "Cloning the $reponame/$locale repository."
					cd $hg_path/$reponame
					hg clone $url
					cd $root_path
					echogreen "Cloned the $reponame/$locale repository."
				fi
		else
			echored "Error: Unable to read from $url"
			echored "Seems that the $reponame/$locale repository does not exist."
		fi
}

function update_hg_repo(){
	local reponame="l10n-central"
	local locale=$locale_code

	cd $root_path

	if [ -d ./$hg_path/$reponame/$locale/.hg ]
		then
			echogreen "Updating the $reponame/$locale repository."
			cd $hg_path/$reponame/$locale
			hg pull -u
			cd $root_path
			echogreen "Updated the $reponame/$locale repository."
		else
			echored "Error: The $reponame/$locale repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg to clone the $reponame/$locale repository."
		fi
}


function clone_hg_l10n(){
	mode="https:/"
	local reponame="l10n/gecko-strings"

	cd $root_path

	local url="$mode/$mozilla_url/$reponame"

	if exist_hg_repo $url
		then
			if [ ! -d ./$hg_path/l10n ]
				then
					mkdir -p ./$hg_path/l10n
				fi

			if [ -d ./$hg_path/$reponame/.hg ]
				then
					echoyellow "The $reponame repository already exist."
					echoyellow "Try ./mozilla.sh updateL10n to update the repository."
				else
					echogreen "Cloning the $reponame repository."
					cd $hg_path/l10n
					hg clone $url
					cd $root_path
					echogreen "Cloned the $reponame repository."
				fi
		else
			echored "Error: Unable to read from $url"
			echored "Seems that the $reponame repository does not exist."
		fi
}


function update_hg_l10n(){
	mode="https:/"
	local reponame="l10n/gecko-strings"

	cd $root_path

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Updating the $reponame repository."
			cd $hg_path/$reponame
			hg pull -u
			cd $root_path
			echogreen "Updated the $reponame repository."
		else
			echored "Error: The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneL10n to clone the $reponame repository."
		fi
}


function clone_hg_channel(){
	mode="https:/"
	local reponame="comm-central"

	cd $root_path

	local url="$mode/$mozilla_url/$reponame"

	if exist_hg_repo $url
		then
			if [ -d ./$hg_path/$reponame/.hg ]
				then
					echoyellow "The $reponame repository already exist."
					echoyellow "Try ./mozilla.sh updateChannel to update the $reponame repository."
				else
					echogreen "Cloning the $reponame repository."
					cd $hg_path
					hg clone $url
					cd $reponame
					python client.py checkout
					cd $root_path
					echogreen "Cloned the $reponame repository."

				fi
		else
			echored "Error: Unable to read from $url"
			echored "Seems that the $reponame repository does not exist."
		fi

}

function update_hg_channel(){
	local reponame="comm-central"

	cd $root_path

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Updating the $reponame repository."
			cd ./$hg_path/$reponame
			python client.py checkout
			cd $root_path
			echogreen "Updated the $reponame repository."
		else
			echored "Error: The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel to clone the $reponame repository."
		fi
}

#############################################################################################




#############################################################################################
function get_ftl_files(){
	cd $root_path
	# To delete the .ftl files (OmegaT do not support this type of files)
	cd ./$omt_path/source
	find . -name "*.ftl" -exec cp {} /home/keko/prox-flt-files/source \;
}

function get_files_browser(){
	local reponame="l10n/gecko-strings"

	cd $root_path

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $reponame repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/browser
			cp -r ./$hg_path/$reponame/browser/* ./$omt_path/source/browser
			if_exist_delete_create ./$omt_path/source/devtools
			cp -r ./$hg_path/$reponame/devtools/* ./$omt_path/source/devtools

			# Files to exclude of OmegaT
			# Bug 1276740 - Centralize all search plugins into mozilla-central
			# rm -r ./$omt_path/source/$reponame/browser/searchplugins
			rm -r ./$omt_path/source/browser/chrome/browser-region
			rm -r ./$omt_path/source/browser/defines.inc
			rm -r ./$omt_path/source/browser/firefox-l10n.js
			# To delete the bookmarks.inc file
			rm -r ./$omt_path/source/browser/profile
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneL10n to clone the $reponame repository."
		fi
}

function get_files_browser_u(){
	local reponame="mozilla-unified"

	cd $root_path

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $reponame repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/browser
			cp -r ./$hg_path/$reponame/browser/${Ruta_Locales}/* ./$omt_path/source/browser
			mkdir -p ./$omt_path/source/browser/extensions/formautofill
			cp -r ./$hg_path/$reponame/browser/extensions/formautofill/${Ruta_Locales}/* ./$omt_path/source/browser/extensions/formautofill
			mkdir -p ./$omt_path/source/browser/extensions/webcompat-reporter
			cp -r ./$hg_path/$reponame/browser/extensions/webcompat-reporter/${Ruta_Locales}/* ./$omt_path/source/browser/extensions/webcompat-reporter
			mkdir -p ./$omt_path/source/devtools/client
			mkdir -p ./$omt_path/source/devtools/shared
			mkdir -p ./$omt_path/source/devtools/startup
			cp -r ./$hg_path/$reponame/devtools/client/${Ruta_Locales}/* ./$omt_path/source/devtools/client
			cp -r ./$hg_path/$reponame/devtools/shared/${Ruta_Locales}/* ./$omt_path/source/devtools/shared
			cp -r ./$hg_path/$reponame/devtools/startup/${Ruta_Locales}/* ./$omt_path/source/devtools/startup
			mkdir -p ./$omt_path/source/browser/branding/official
			cp -r ./$hg_path/$reponame/browser/branding/official/${Ruta_Locales}/* ./$omt_path/source/browser/branding/official
			# Files to exclude of OmegaT
			# Bug 1276740 - Centralize all search plugins into mozilla-central
			# rm -r ./$omt_path/source/$reponame/browser/searchplugins
			rm -r ./$omt_path/source/browser/chrome/browser-region
			rm -r ./$omt_path/source/browser/defines.inc
			rm -r ./$omt_path/source/browser/firefox-l10n.js
			# To delete o bookmarks.inc file
			rm -r ./$omt_path/source/browser/profile
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel to clone the $reponame repository."
		fi
}

function move_files_browser(){
	local reponame="l10n-central"

	cd $root_path


	if [ -d ./$hg_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/browser ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					## if_exist_delete ./$hg_path/$reponame/$locale_code/browser/branding
					## if_exist_delete ./$hg_path/$reponame/$locale_code/browser/crashreporter
					## if_exist_delete ./$hg_path/$reponame/$locale_code/browser/installer
					## if_exist_delete ./$hg_path/$reponame/$locale_code/browser/pdfviewer
					## if_exist_delete ./$hg_path/$reponame/$locale_code/browser/updater
					## if_exist_delete ./$hg_path/$reponame/$locale_code/browser/chrome/browser
					## if_exist_delete ./$hg_path/$reponame/$locale_code/browser/chrome/overrides
					## if_exist_delete ./$hg_path/$reponame/$locale_code/browser/extensions
					## if_exist_delete ./$hg_path/$reponame/$locale_code/devtools
					cp -r ./$omt_path/target/browser/* ./$hg_path/$reponame/$locale_code/browser/

					cp -r ./$omt_path/target/devtools/* ./$hg_path/$reponame/$locale_code/devtools/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getBrowser to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg clone the $reponame repository."
			echoyellow "Then ./mozilla.sh getBrowser to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveBrowser again."
		fi
}

function get_files_toolkit(){
	local reponame="l10n/gecko-strings"

	cd $root_path

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $reponame repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/toolkit
			cp -r ./$hg_path/$reponame/toolkit/* ./$omt_path/source/toolkit

			# Files to exclude of OmegaT
			rm -r ./$omt_path/source/toolkit/defines.inc
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneL10n to clone the $reponame repository."
		fi
}

function get_files_toolkit_u(){
	local reponame="mozilla-unified"

	cd $root_path

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $reponame repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/toolkit
			cp -r ./$hg_path/$reponame/toolkit/${Ruta_Locales}/* ./$omt_path/source/toolkit

			# Files to exclude of OmegaT
			rm -r ./$omt_path/source/toolkit/defines.inc
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel to clone the $reponame repository."
		fi
}

function move_files_toolkit(){
	local reponame="l10n-central"

	cd $root_path

	if [ -d ./$hg_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/toolkit ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					## if_exist_delete ./$hg_path/$reponame/$locale_code/toolkit/chrome
					## if_exist_delete ./$hg_path/$reponame/$locale_code/toolkit/crashreporter
					cp -r ./$omt_path/target/toolkit/* ./$hg_path/$reponame/$locale_code/toolkit/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getBrowser to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg clone the $reponame repository."
			echoyellow "Then ./mozilla.sh getBrowser to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveBrowser again."
		fi
}

function get_files_mobile(){
	local reponame="l10n/gecko-strings"

	cd $root_path

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $reponame repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/mobile
			cp -r ./$hg_path/$reponame/mobile/* ./$omt_path/source/mobile
			# Files to exclude of OmegaT
			rm -r ./$omt_path/source/mobile/chrome
			rm -r ./$omt_path/source/mobile/android/defines.inc
			rm -r ./$omt_path/source/mobile/android/mobile-l10n.js
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneL10n to clone the $reponame repository."
		fi
}

function move_files_mobile(){
	local reponame="l10n-central"

	cd $root_path

	if [ -d ./$hg_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/mobile ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					# if_exist_delete ./$hg_path/$reponame/$locale_code/mobile/android/base
					# if_exist_delete ./$hg_path/$reponame/$locale_code/mobile/android/chrome
					# if_exist_delete ./$hg_path/$reponame/$locale_code/mobile/overrides
					# if_exist_delete ./$hg_path/$reponame/$locale_code/mobile/xul
					cp -r ./$omt_path/target/mobile/* ./$hg_path/$reponame/$locale_code/mobile/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getFennec to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg clone the $reponame repository."
			echoyellow "Then ./mozilla.sh getFennec to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveFennec again."
		fi
}

function get_files_editor(){
	local reponame="l10n/gecko-strings"

	cd $root_path

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $reponame repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/editor
			cp -r ./$hg_path/$reponame/editor/* ./$omt_path/source/editor
			# Files to exclude of OmegaT
			rm -r ./$omt_path/source/editor/ui/chrome/region
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneL10n to clone the $reponame repository."
		fi
}

function move_files_editor(){
	local reponame="l10n-central"

	cd $root_path

	if [ -d ./$hg_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/editor ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					if_exist_delete ./$hg_path/$reponame/$locale_code/editor/ui/chrome/composer
					if_exist_delete ./$hg_path/$reponame/$locale_code/editor/ui/chrome/dialogs
					cp -r ./$omt_path/target/editor/* ./$hg_path/$reponame/$locale_code/editor/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getThunderbird to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg clone the $reponame repository."
			echoyellow "Then ./mozilla.sh getThunderbird to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveThunderbird again."
		fi
}

function get_files_mail(){
	local reponame="l10n/gecko-strings"

	cd $root_path

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $reponame repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/mail
			cp -r ./$hg_path/$reponame/mail/* ./$omt_path/source/mail

			# Files to exclude of OmegaT
			rm -r ./$omt_path/source/mail/searchplugins
			rm -r ./$omt_path/source/mail/chrome/messenger-region
			rm -r ./$omt_path/source/mail/defines.inc
			rm -r ./$omt_path/source/mail/all-l10n.js
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneL10n to clone the $reponame repository."
		fi
}

function move_files_mail(){
	local reponame="l10n-central"

	cd $root_path

	if [ -d ./$hg_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/mail ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					if_exist_delete ./$hg_path/$reponame/$locale_code/mail/feedback
					if_exist_delete ./$hg_path/$reponame/$locale_code/mail/installer
					if_exist_delete ./$hg_path/$reponame/$locale_code/mail/updater
					if_exist_delete ./$hg_path/$reponame/$locale_code/mail/communicator
					if_exist_delete ./$hg_path/$reponame/$locale_code/mail/messenger
					if_exist_delete ./$hg_path/$reponame/$locale_code/mail/messenger-mapi
					if_exist_delete ./$hg_path/$reponame/$locale_code/mail/messenger-newsblog
					if_exist_delete ./$hg_path/$reponame/$locale_code/mail/messenger-smime
					if_exist_delete ./$hg_path/$reponame/$locale_code/mail/mozldap
					if_exist_delete ./$hg_path/$reponame/$locale_code/mail/overrides
					cp -r ./$omt_path/target/mail/* ./$hg_path/$reponame/$locale_code/mail/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getThunderbird to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg clone the $reponame repository."
			echoyellow "Then ./mozilla.sh getThunderbird to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveThunderbird again."
		fi
}

function get_files_calendar(){
	local reponame="l10n/gecko-strings"

	cd $root_path

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $reponame repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/calendar
			cp -r ./$hg_path/$reponame/calendar/* ./$omt_path/source/calendar

			# Files to exclude of OmegaT
			rm -r ./$omt_path/source/calendar/lightning-l10n.js
			rm -r ./$omt_path/source/calendar/README.txt
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneL10n to clone the $reponame repository."
		fi
}

function move_files_calendar(){
	local reponame="l10n-central"

	cd $root_path

	if [ -d ./$hg_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/calendar ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					if_exist_delete ./$hg_path/$reponame/$locale_code/calendar/chrome
					cp -r ./$omt_path/target/calendar/* ./$hg_path/$reponame/$locale_code/calendar/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getThunderbird to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg clone the $reponame repository."
			echoyellow "Then ./mozilla.sh getThunderbird to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveThunderbird again."
		fi
}

function get_files_chat(){
	local reponame="l10n/gecko-strings"

	cd $root_path

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $reponame repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/chat
			cp -r ./$hg_path/$reponame/chat/* ./$omt_path/source/chat
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneL10n to clone the $reponame repository."
		fi
}

function move_files_chat(){
	local reponame="l10n-central"

	cd $root_path

	if [ -d ./$hg_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/chat ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					if_exist_delete ./$hg_path/$reponame/$locale_code/chat
					cp -r ./$omt_path/target/chat ./$hg_path/$reponame/$locale_code/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getThunderbird to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg clone the $reponame repository."
			echoyellow "Then ./mozilla.sh getThunderbird to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveThunderbird again."
		fi
}

function get_files_rest(){
	local reponame="l10n/gecko-strings"

	cd $root_path

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $reponame repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/dom
			cp -r ./$hg_path/$reponame/dom/* ./$omt_path/source/dom

			if_exist_delete_create ./$omt_path/source/netwerk
			cp -r ./$hg_path/$reponame/netwerk/* ./$omt_path/source/netwerk

			if_exist_delete_create ./$omt_path/source/security
			cp -r ./$hg_path/$reponame/security/* ./$omt_path/source/security

			if_exist_delete_create ./$omt_path/source/services
			cp -r ./$hg_path/$reponame/services/* ./$omt_path/source/services
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneL10n to clone the $reponame repository."
		fi
}

function get_files_rest_u(){
	local reponame="mozilla-unified"

	cd $root_path

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $reponame repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/dom
			cp -r ./$hg_path/$reponame/dom/${Ruta_Locales}/* ./$omt_path/source/dom

			if_exist_delete_create ./$omt_path/source/netwerk
			cp -r ./$hg_path/$reponame/netwerk/${Ruta_Locales}/* ./$omt_path/source/netwerk

			if_exist_delete_create ./$omt_path/source/security
			mkdir -p ./$omt_path/source/security/manager
			cp -r ./$hg_path/$reponame/security/manager/${Ruta_Locales}/* ./$omt_path/source/security/manager

			if_exist_delete_create ./$omt_path/source/services
			mkdir -p ./$omt_path/source/services/sync
			cp -r ./$hg_path/$reponame/services/sync/${Ruta_Locales}/* ./$omt_path/source/services/sync
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel to clone the $reponame repository."
		fi
}

function move_files_rest(){
	local reponame="l10n-central"

	cd $root_path

	if [ -d ./$hg_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."
					## if_exist_delete ./$hg_path/$reponame/$locale_code/dom
					## if_exist_delete ./$hg_path/$reponame/$locale_code/netwerk
					## if_exist_delete ./$hg_path/$reponame/$locale_code/other-licenses
					## if_exist_delete ./$hg_path/$reponame/$locale_code/security
					## if_exist_delete ./$hg_path/$reponame/$locale_code/services

					cp -r ./$omt_path/target/dom ./$hg_path/$reponame/$locale_code/
					cp -r ./$omt_path/target/netwerk ./$hg_path/$reponame/$locale_code/
					cp -r ./$omt_path/target/security ./$hg_path/$reponame/$locale_code/
					cp -r ./$omt_path/target/services ./$hg_path/$reponame/$locale_code/
					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getFirefox to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg clone the $reponame repository."
			echoyellow "Then ./mozilla.sh getFirefox to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveFirefox again."
		fi
}

function get_files_suite(){
	local reponame="l10n/gecko-strings"

	cd $root_path

	if [ -d ./$hg_path/$reponame/.hg ]
		then
			echogreen "Copying l10n files for the $reponame repository into OmegaT Project."
			if_exist_delete_create ./$omt_path/source/suite
			cp -r ./$hg_path/$reponame/suite/* ./$omt_path/source/suite

			# Files to exclude of OmegaT
			rm -r ./$omt_path/source/suite/searchplugins
			rm -r ./$omt_path/source/suite/suite-l10n.js
			rm -r ./$omt_path/source/suite/defines.inc
			rm -r ./$omt_path/source/suite/profile
			rm -r ./$omt_path/source/suite/chrome/browser/region.properties
			rm -r ./$omt_path/source/suite/chrome/common/region.properties
			rm -r ./$omt_path/source/suite/chrome/mailnews/region.properties
			rm -r ./$omt_path/source/suite/chrome/common/help
			echogreen "Copied l10n files into OmegaT."
		else
			echoyellow "The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneL10n to clone the $reponame repository."
		fi
}

function move_files_suite(){
	local reponame="l10n-central"

	cd $root_path

	if [ -d ./$hg_path/$reponame/$locale_code/.hg ]
		then
			if [ -d ./$omt_path/target/suite ]
				then
					echogreen "Updating the translations of $reponame/$locale_code repository."

					mv ./$hg_path/$reponame/$locale_code/suite/chrome/browser/region.properties ./$hg_path/$reponame/$locale_code/regionbrowser.properties
					mv ./$hg_path/$reponame/$locale_code/suite/chrome/common/region.properties ./$hg_path/$reponame/$locale_code/regioncommon.properties
					mv ./$hg_path/$reponame/$locale_code/suite/chrome/mailnews/region.properties ./$hg_path/$reponame/$locale_code/regionmailnews.properties
					mv ./$hg_path/$reponame/$locale_code/suite/chrome/common/help ./$hg_path/$reponame/$locale_code/

					if_exist_delete ./$hg_path/$reponame/$locale_code/suite/crashreporter
					if_exist_delete ./$hg_path/$reponame/$locale_code/suite/installer
					if_exist_delete ./$hg_path/$reponame/$locale_code/suite/updater
					if_exist_delete ./$hg_path/$reponame/$locale_code/suite/chrome
					cp -r ./$omt_path/target/suite/* ./$hg_path/$reponame/$locale_code/suite/

					mv ./$hg_path/$reponame/$locale_code/regionbrowser.properties ./$hg_path/$reponame/$locale_code/suite/chrome/browser/region.properties
					mv ./$hg_path/$reponame/$locale_code/regioncommon.properties ./$hg_path/$reponame/$locale_code/suite/chrome/common/region.properties
					mv ./$hg_path/$reponame/$locale_code/regionmailnews.properties ./$hg_path/$reponame/$locale_code/suite/chrome/mailnews/region.properties
					mv ./$hg_path/$reponame/$locale_code/help ./$hg_path/$reponame/$locale_code/suite/chrome/common/

					echogreen "Updated the translations of repository."
				else
					echored "Error: There is no translations. Do not exist the project into target folder."
					echoyellow "Create the translated files with OmegaT and if the project does not exist into source folder:"
					echoyellow "Execute ./mozilla.sh getSeaMonkey to copy the l10n files into OmegaT."
				fi
		else
			echored "Error: The $reponame/$locale_code repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg clone the $reponame repository."
			echoyellow "Then ./mozilla.sh getSeaMonkey to copy the l10n files into OmegaT."
			echoyellow "Finally create the translated files with OmegaT and execute ./mozilla.sh moveSeaMonkey again."
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
	echo "	getL10n		Get the l10n files for the selected repository (projects with .lang and .xliff files)."
	echo "			Copy the l10n files of project selected into source folder in the OmegaT project."
	echo "			Works with the cloned repositories with the 'cloneRepo' task."
	echo "	returnL10n	Send the translated l10n files from the OmegaT project to the local repository."
	echo "	getL10nPot	Get the l10n files for the selected repository (projects with .po files). Similar to"
	echo "			getL10n but with other type of projects."
	echo "	returnL10nPot	Send the translated l10n files from the OmegaT project to the local repository."
	echo "			Similar to returnL10n but with other type of projects."
	echo ""
	echo "	cloneHg		Clone the l10n-central/$locale_code repository in the framework."
	echo "			The cloned repository has only l10n files."
	echo "			Example of usage: ./mozilla.sh cloneHg l10n-central"
	echo "	updateHg	Update the l10n-central/$locale_code repository in the framework."
	echo "			Update the cloned repository with the 'cloneHg' task."
	echo ""
	echo "	cloneL10n	Clone the gecko-strings repository in the framework."
	echo "	updateL10n	Update the gecko-strings repository in the framework."
	echo ""
	echo "	cloneChannel	Clone the comm-central repository in the framework."
	echo "			The cloned repository has source code and l10n files."
	echo "			Example of usage: ./mozilla.sh cloneChannel."
	echo "	updateChannel	Updates the comm-central repository in the framework."
	echo "	getFirefox	Get the l10n files for the Firefox product from the gecko-strings repository. Copy the"
	echo "			l10n files into source folder in the OmegaT project."
	echo "	moveFirefox	Send the translated l10n files from the OmegaT project to the local l10n-central/$locale_code repository."
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
		[ $param = getL10nPot ] && get_l10n_pot $2
		[ $param = returnL10nPot ] && return_l10n_pot $2
		[ $param = cloneHg ] && clone_hg_repo
		[ $param = updateHg ] && update_hg_repo
		[ $param = cloneL10n ] && clone_hg_l10n
		[ $param = updateL10n ] && update_hg_l10n
		[ $param = cloneChannel ] && clone_hg_channel
		[ $param = updateChannel ] && update_hg_channel
		[ $param = getFirefox ] && get_files_browser && get_files_toolkit && get_files_rest && get_ftl_files
		[ $param = getFirefoxU ] && get_files_browser_u && get_files_toolkit_u && get_files_rest_u && get_ftl_files
		[ $param = moveFirefox ] && move_files_browser && move_files_toolkit && move_files_rest
		[ $param = getFennec ] && get_files_mobile && get_ftl_files
		[ $param = moveFennec ] && move_files_mobile
		[ $param = getThunderbird ] && get_files_mail && get_files_editor && get_files_chat && get_files_calendar && get_ftl_files
		[ $param = moveThunderbird ] && move_files_mail && move_files_editor && move_files_chat && move_files_calendar
		[ $param = getSeaMonkey ] && get_files_suite
		[ $param = moveSeaMonkey ] && move_files_suite
		[ $param = removeAll ] && remove_target_files
	fi

#.EOF
