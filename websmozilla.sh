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

Ruta_Source="webs-mozilla"
Ruta_Target="prox-webs-mozilla/source"

function getMozillaOrg(){
	cd ${Ruta_Root}
	if [ -d ${Ruta_Root}/${Ruta_Target}/www.mozilla.org/ ]; then
		rm -r ./${Ruta_Target}/www.mozilla.org
	fi
	mkdir ${Ruta_Target}/www.mozilla.org
	cp -r ./webs-mozilla/www.mozilla.org/gl/* ./${Ruta_Target}/www.mozilla.org/
}

function getEngagement(){
	cd ${Ruta_Root}
	if [ -d ${Ruta_Root}/${Ruta_Target}/engagement-l10n/ ]; then
		rm -r ./${Ruta_Target}/engagement-l10n
	fi
	mkdir ${Ruta_Target}/engagement-l10n
	cp -r ./webs-mozilla/engagement-l10n/gl/* ./${Ruta_Target}/engagement-l10n/
}

function getAppstores(){
	cd ${Ruta_Root}
	if [ -d ${Ruta_Root}/${Ruta_Target}/appstores/ ]; then
		rm -r ./${Ruta_Target}/appstores
	fi
	mkdir ${Ruta_Target}/appstores
	cp -r ./webs-mozilla/appstores/gl/* ./${Ruta_Target}/appstores/
}

function getFirefoxiOS(){
	cd ${Ruta_Root}
	if [ -d ${Ruta_Root}/${Ruta_Target}/firefoxios-l10n/ ]; then
		rm -r ./${Ruta_Target}/firefoxios-l10n
	fi
	mkdir ${Ruta_Target}/firefoxios-l10n
	cp -r ./webs-mozilla/firefoxios-l10n/gl/* ./${Ruta_Target}/firefoxios-l10n/
}


param=$1
[ $param = "" ] && exit 0
[ $param = getMoz ] && getMozillaOrg
[ $param = getEng ] && getEngagement
[ $param = getApp ] && getAppstores
[ $param = getFxiOS ] && getFirefoxiOS
[ $param = getAll ] && getMozillaOrg && getEngagement && getAppstores

#.EOF
