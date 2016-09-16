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
# outubro 2015

## -

# execute « [bash |./]mozilla [getMoz|getEng|getApp] »

## Script pretende permitir a creación dun proxecto en OmegaT para traducir as páxinas webs e outros servizos-proxectos de Mozilla e a xestión de actualización da tradución


# Path to the folder where the projects are placed
Ruta_Root="/home/ana/Dropbox/localizacion/mozilla"

# Change by the name of the project. In this case, prox-omt-moz
omt_path="prox-webs-mozilla"

# Identifica o idioma ao que se traducirán os proxectos de Mozilla.
# Hai que modificar o seu valor, polo código de locale do seu idioma.
locale_code="gl"

# Note: replace "ssh:/" with "https:/" if you don't have SSH access to hg.mozilla.org
mode="https:/"
mozilla_url="hg.mozilla.org"

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
			echogreen "The $omt_path project of OmegaT does not exist."
			echogreen "Launch OmegaT and create the $omt_path project using the user manual."
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
			# "https://github.com/mozilla-l10n/$reponame.git"
			local url="git@github.com:mozilla-l10n/$reponame.git"

			if exist_git_repo $url
				then
					echogreen "Cloning the $reponame repository."
					cd $git_path
					git clone $url
					cd $Ruta_Root
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
			cd $Ruta_Root
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
					if [ -d ./$omt_path/source/$reponame ]
						then
							rm -r ./$omt_path/source/$reponame
						fi
					echogreen "Copying l10n files for the $reponame project into OmegaT Project."
					mkdir $omt_path/source/$reponame
					cp -r ./$git_path/$reponame/$locale_code/* ./$omt_path/source/$reponame/
					echogreen "Copied l10n files into OmegaT."
				else
					echored "The $reponame repository exist, but your locale is not actived."
					echoyellow "Contact with the Mozilla l10n team to activate the project for your locale."
				fi
		else
			echoyellow "The $reponame repository does not exist."
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
					echoyellow "Try ./mozilla.sh '''ALGO''' $1 $locale to update the repository."
				else
					echogreen "Cloning the $1/$locale repository."
					cd $hg_path/$reponame
					hg clone $url
					cd $Ruta_Root
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
			cd $Ruta_Root
			echogreen "Updated the $1/$locale repository."
		else
			echored "Error: The $1/$locale repository does not exist."
			echoyellow "Try ./mozilla.sh cloneHg $1 $locale to clone the repository."
		fi
}

function get_l10n_Gaia(){

	if [ -d ./$hg_path/gaia-l10n/en-US/.hg ]
		then
			if [ -d ./$omt_path/source/gaia-l10n ]
				then
					rm -r ./$omt_path/source/gaia-l10n
				fi
			echogreen "Copying l10n files for the gaia-l10n repository into OmegaT Project."
			mkdir $omt_path/source/gaia-l10n
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
					echoyellow "Try ./mozilla.sh '''ALGO''' $1 to update the repository."
				else
					echogreen "Cloning the $1 repository."
					mkdir -p $hg_path/$repo_path
					cd $hg_path/$repo_path
					hg clone $url
					cd $1
					python client.py checkout
					cd $Ruta_Root
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
			cd $Ruta_Root
			echogreen "Updated the $1 repository."
		else
			echored "Error: The $reponame repository does not exist."
			echoyellow "Try ./mozilla.sh cloneChannel $reponame to clone the repository."
		fi
}

#############################################################################################

param=$1
[ $param = "" ] && exit 0
[ $param = init ] && init
[ $param = cloneRepo ] && clone_repo_mozilla_l10n $2
[ $param = updateRepo ] && update_repo_mozilla_l10n $2
[ $param = getL10n ] && get_l10n $2
[ $param = returnL10n ] && return_l10n $2
[ $param = cloneHg ] && clone_hg_repos $2 $3
[ $param = updateHg ] && update_hg_repos $2 $3
[ $param = getGaia ] && get_l10n_Gaia
[ $param = returnGaia ]&& return_l10n_Gaia
[ $param = cloneChannel ] && clone_hg_channel $2
[ $param = updateChannel ] && update_hg_channel $2

#.EOF
