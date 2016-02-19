all: installer-zip

installer-zip: installer
	rm -f ./dist/@PROJECT_NAME@-source.zip
	cd ./dist && zip -r -9 ./@PROJECT_NAME@-source.zip ./@PROJECT_NAME@-source

installer: fainstall/make.sh
	./fx-meta-installer/scripts/make_installer.sh "@PROJECT_NAME@" "addon1" "addon2"

fainstall/make.sh:
	git submodule update --init
