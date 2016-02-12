all: installer

installer: fainstall/make.sh
	./fx-meta-installer/scripts/make_installer.sh "@PROJECT_NAME@" "addon1" "addon2"

fainstall/make.sh:
	git submodule update --init
