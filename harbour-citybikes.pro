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

DISTFILES += qml/harbour-citybikes.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    rpm/harbour-citybikes.changes \
    rpm/harbour-citybikes.changes.run.in \
    rpm/harbour-citybikes.spec \
    rpm/harbour-citybikes.yaml \
    translations/*.ts \
    harbour-citybikes.desktop \
    rpm/harbour-citybikes.changes

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-citybikes-de.ts
TRANSLATIONS += translations/harbour-citybikes-es.ts
TRANSLATIONS += translations/harbour-citybikes-fr.ts
TRANSLATIONS += translations/harbour-citybikes-it.ts
TRANSLATIONS += translations/harbour-citybikes-nl.ts
TRANSLATIONS += translations/harbour-citybikes-bl_BE.ts
TRANSLATIONS += translations/harbour-citybikes-oc.ts
TRANSLATIONS += translations/harbour-citybikes-ru.ts
