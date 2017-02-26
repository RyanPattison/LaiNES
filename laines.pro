UBUNTU_MANIFEST_FILE=manifest.json.in

UBUNTU_TRANSLATION_DOMAIN="laines.rpattison"

UBUNTU_TRANSLATION_SOURCES+= \
    $$files(*.qml,true) \
    $$files(*.js,true)  \
    $$files(*.cpp,true) \
    $$files(*.h,true) \
    $$files(*.desktop,true)


UBUNTU_PO_FILES+=$$files(po/*.po)

TEMPLATE = app
TARGET = laines

load(ubuntu-click)

QT += core gui widgets multimedia qml quick
CONFIG += c++11 

RESOURCES += laines.qrc

QML_FILES += $$files(*.qml,true) \
             $$files(*.js,true)

CONF_FILES +=  laines.apparmor \
	       laines-content.json \
               laines.png 

OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               laines.rpattison.desktop 

#specify where the qml/js files are installed to
qml_files.path = /laines
qml_files.files += $${QML_FILES}

#specify where the config files are installed to
config_files.path = /
config_files.files += $${CONF_FILES}

desktop_file.path = /
desktop_file.files = $$OUT_PWD/laines.rpattison.desktop 
desktop_file.CONFIG += no_check_exist 

INCLUDEPATH += ./lib/include
INCLUDEPATH += ./src/include

SOURCES += \ 
	./lib/apu_snapshot.cpp\
	./lib/Blip_Buffer.cpp\
	./lib/Multi_Buffer.cpp\
	./lib/Nes_Apu.cpp\
	./lib/Nes_Namco.cpp\
	./lib/Nes_Oscs.cpp\
	./lib/Nes_Vrc6.cpp\
	./lib/Nonlinear_Buffer.cpp\
	./lib/Sound_Queue.cpp\
	./src/apu.cpp\
	./src/cartridge.cpp\
	./src/cpu.cpp\
	./src/joypad.cpp\
	./src/main.cpp\
	./src/mapper.cpp\
	./src/NESEmulator.cpp\
	./src/EmulationRunner.cpp\
	./src/PixelRenderer.cpp\
	./lib/RingBuffer.cpp\
	./src/ppu.cpp\
	./src/mappers/mapper1.cpp\
	./src/mappers/mapper2.cpp\
	./src/mappers/mapper3.cpp\
	./src/mappers/mapper4.cpp\


HEADERS  += \
	./lib/include/apu_snapshot.h \
	./lib/include/blargg_common.h\ 
	./lib/include/blargg_source.h\
	./lib/include/Blip_Buffer.h\
	./lib/include/Blip_Synth.h\
	./lib/include/Multi_Buffer.h\
	./lib/include/Nes_Apu.h\
	./lib/include/Nes_Namco.h\
	./lib/include/Nes_Oscs.h\
	./lib/include/Nes_Vrc6.h\
	./lib/include/Nonlinear_Buffer.h\
	./lib/include/Sound_Queue.h\
	./lib/include/RingBuffer.h\
	./src/include/apu.hpp\
	./src/include/cartridge.hpp\
	./src/include/common.hpp\
	./src/include/cpu.hpp\
	./src/include/joypad.hpp\
	./src/include/mapper.hpp\
	./src/include/ppu.hpp\
	./src/include/EmulationRunner.h\
	./src/include/PixelRenderer.h\
	./src/include/NESEmulator.h\

target.path = $${UBUNTU_CLICK_BINARY_PATH}

INSTALLS += target config_files qml_files desktop_file 
