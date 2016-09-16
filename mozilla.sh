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
# xuño 2013

## -

# Código e estrutura do script baseado noutro de Miguel Bouzada

# execute « [bash |./]mozilla [getBrowser|getMobile|getDom|getToolkit|getNetwerk|getSecurity|getServices|getCalendar|getChat|getSuite|getMail|getEditor|getOther|getAllFiles] »

## Script que usando outras utilidades xa existentes ou desenvoltas a medida para este proxecto, pretende permitir a creación dun proxecto en OmegaT para traducir os aplicativos de Mozilla e a xestión de actualización da tradución. 
## Nestes momentos o script está nunha fase inicial, e supón que vostede vai traballar nun cartafol chamado mozilla que está dentro doutro cartafol chamado code no seu cartafol de usuario. Dentro dese cartafol de traballo terá que descargar o repositorio comm-central de mozilla e crear un proxecto en OmegaT chamado prox-mozilla. O script permite importar todos os ficheiros que vai traducir.

Ruta_Root="~/code/mozilla"
Ruta_Source="prox-mozilla/source"
Ruta_Target="prox-proba-mozilla/target"
Ruta_Repo="comm-central"
Ruta_Locales="locales/en-US"
Ruta_Browser="mozilla/browser"


function getFilesBrowser(){
	cd ${Ruta_Root}
	rm -r ./${Ruta_Source}/browser
	mkdir ./${Ruta_Source}/browser
	mkdir -p ./${Ruta_Source}/browser/branding/official
	cp -r ./${Ruta_Repo}/mozilla/browser/${Ruta_Locales}/* ./${Ruta_Source}/browser
	cp -r ./${Ruta_Repo}/mozilla/browser/branding/official/${Ruta_Locales}/* ./${Ruta_Source}/browser/branding/official
	rm -r ./${Ruta_Source}/browser/searchplugins
}


function getFilesMobile(){
	cd ${Ruta_Root}
	rm -r ./${Ruta_Source}/mobile
	mkdir ./${Ruta_Source}/mobile
	mkdir -p ./${Ruta_Source}/mobile/android
	mkdir -p ./${Ruta_Source}/mobile/android/base
	cp -r ./${Ruta_Repo}/mozilla/mobile/${Ruta_Locales}/* ./${Ruta_Source}/mobile
	cp -r ./${Ruta_Repo}/mozilla/mobile/android/${Ruta_Locales}/* ./${Ruta_Source}/mobile/android
	cp -r ./${Ruta_Repo}/mozilla/mobile/android/base/${Ruta_Locales}/* ./${Ruta_Source}/mobile/android/base
	rm -r ./${Ruta_Source}/mobile/searchplugins
}


function getFilesCalendar(){
	cd ${Ruta_Root}
	rm -r ./${Ruta_Source}/calendar
	mkdir ./${Ruta_Source}/calendar
	cp -r ./${Ruta_Repo}/calendar/${Ruta_Locales}/* ./${Ruta_Source}/calendar
}


function getFilesChat(){
	cd ${Ruta_Root}
	rm -r ./${Ruta_Source}/chat
	mkdir ./${Ruta_Source}/chat
	cp -r ./${Ruta_Repo}/chat/${Ruta_Locales}/* ./${Ruta_Source}/chat
}


function getFilesSuite(){
	cd ${Ruta_Root}
	rm -r ./${Ruta_Source}/suite
	mkdir ./${Ruta_Source}/suite
	cp -r ./${Ruta_Repo}/suite/${Ruta_Locales}/* ./${Ruta_Source}/suite
	rm -r ./${Ruta_Source}/suite/searchplugins
	rm -r ./${Ruta_Source}/suite/chrome/common/help/images/*.png
	rm -r ./${Ruta_Source}/suite/chrome/common/help/images/*.gif
}


function getFilesMail(){
	cd ${Ruta_Root}
	rm -r ./${Ruta_Source}/mail
	mkdir ./${Ruta_Source}/mail
	cp -r ./${Ruta_Repo}/mail/${Ruta_Locales}/* ./${Ruta_Source}/mail
	rm -r ./${Ruta_Source}/mail/searchplugins
}


function getFilesEditor(){
	cd ${Ruta_Root}
	rm -r ./${Ruta_Source}/editor
	mkdir -p ./${Ruta_Source}/editor/ui
	cp -r ./${Ruta_Repo}/editor/ui/${Ruta_Locales}/* ./${Ruta_Source}/editor/ui
}


function getFilesDom(){
	cd ${Ruta_Root}
	rm -r ./${Ruta_Source}/dom
	mkdir ./${Ruta_Source}/dom
	cp -r ./${Ruta_Repo}/mozilla/dom/${Ruta_Locales}/* ./${Ruta_Source}/dom
}


function getFilesToolkit(){
	cd ${Ruta_Root}
	rm -r ./${Ruta_Source}/toolkit
	mkdir ./${Ruta_Source}/toolkit
	cp -r ./${Ruta_Repo}/mozilla/toolkit/${Ruta_Locales}/* ./${Ruta_Source}/toolkit
}


function getFilesSecurity(){
	cd ${Ruta_Root}
	rm -r ./${Ruta_Source}/security
	mkdir -p ./${Ruta_Source}/security/manager
	cp -r ./${Ruta_Repo}/mozilla/security/manager/${Ruta_Locales}/* ./${Ruta_Source}/security/manager
}


function getFilesServices(){
	cd ${Ruta_Root}
	rm -r ./${Ruta_Source}/services
	mkdir -p ./${Ruta_Source}/services/sync
	cp -r ./${Ruta_Repo}/mozilla/services/sync/${Ruta_Locales}/* ./${Ruta_Source}/services/sync
}


function getFilesNetwerk(){
	cd ${Ruta_Root}
	rm -r ./${Ruta_Source}/netwerk
	mkdir ./${Ruta_Source}/netwerk
	cp -r ./${Ruta_Repo}/mozilla/netwerk/${Ruta_Locales}/* ./${Ruta_Source}/netwerk
}


function getFilesOtherLicenses(){
	cd ${Ruta_Root}
	rm -r ./${Ruta_Source}/other-licenses
	mkdir -p ./${Ruta_Source}/other-licenses/branding/thunderbird
	cp -r ./${Ruta_Repo}/other-licenses/branding/thunderbird/${Ruta_Locales}/* ./${Ruta_Source}/other-licenses/branding/thunderbird
}



param=$1
[ $param = "" ] && exit 0
[ $param = getBrowser ] && getFilesBrowser
[ $param = getMobile ] && getFilesMobile
[ $param = getDom ] && getFilesDom
[ $param = getToolkit ] && getFilesToolkit
[ $param = getNetwerk ] && getFilesNetwerk
[ $param = getSecurity ] && getFilesSecurity
[ $param = getServices ] && getFilesServices
[ $param = getCalendar ] && getFilesCalendar
[ $param = getChat ] && getFilesChat
[ $param = getSuite ] && getFilesSuite
[ $param = getMail ] && getFilesMail
[ $param = getEditor ] && getFilesEditor
[ $param = getOther ] && getFilesOtherLicenses
[ $param = getAllFiles ] && getFilesBrowser && getFilesMobile && getFilesDom && getFilesToolkit && getFilesNetwerk && getFilesSecurity && getFilesServices && getFilesCalendar && getFilesChat && getFilesSuite && getFilesMail && getFilesEditor && getFilesOtherLicenses

#.EOF
