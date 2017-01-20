# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-citybikes

CONFIG += sailfishapp

SOURCES += src/harbour-citybikes.cpp

OTHER_FILES += qml/harbour-citybikes.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-citybikes.changes.in \
    rpm/harbour-citybikes.spec \
    rpm/harbour-citybikes.yaml \
    translations/*.ts \
    harbour-citybikes.desktop



SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.

TRANSLATIONS += translations/harbour-citybikes-fr.ts

DISTFILES += \
    qml/pages/Categories.qml \
    qml/pages/JSONListModel.qml \
    qml/pages/jsonpath.js \
    qml/pages/Logic.js \
    qml/pages/Station.qml \
    qml/pages/MyGridDelegate.qml \
    qml/pages/CmpDisplayElement.qml \
    qml/worker.js \
    qml/pages/AboutPage.qml

HEADERS +=

