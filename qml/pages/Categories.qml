import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page
    property ListModel settings
    onStatusChanged: {
        if (status === PageStatus.Active) {
            var xmlHttp = new XMLHttpRequest();
            xmlHttp.onreadystatechange = function() {
                if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
                    try {
                        var json = JSON.parse(xmlHttp.responseText);
                        for(var i = 0; i < json.networks.length; i++){
                            var item = json.networks[i];
                            modelCategories.append(item);
                        }

                    } catch(e) {
                        console.log(e)
                        console.log(xmlHttp.responseText)
                        console.log(" ######## CATEGORIES ######## ");
                    }
                }
                if (xmlHttp.readyState == 4 && xmlHttp.status == 403) {
                    console.log(" ######## CATEGORIES ERROR ######## ");
                }
            }

            xmlHttp.open('GET', 'https://api.citybik.es/v2/networks')
            xmlHttp.send();
        }
    }
    ListModel {
        id: modelCategories
    }
    BusyIndicator {
        running: modelCategories.count == 0
        size: BusyIndicatorSize.Large
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
    SilicaListView {
        id: listView
        model: modelCategories
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Kategorije")
        }
        section {
            property: 'section'
            delegate: SectionHeader {
                text: model.location.country
                height: Theme.itemSizeSmall
            }
        }
        delegate: BackgroundItem {
            id: delegate

            Label {
                x: Theme.paddingLarge
                text: model.name
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            Label {
                x: Theme.paddingLarge
                text: model.location.country
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                color: delegate.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            }
            onClicked: {
                console.log("Clicked " + model.id)
                if (settings.get(0).category !== model.id){
                    settings.setProperty(0, "refresh", true);
                    settings.setProperty(0, "page", 1);
                    settings.setProperty(0, "label", model.location.city);
                    settings.setProperty(0, "category", model.href);
                }
                pageStack.navigateBack()
            }
        }
        VerticalScrollDecorator {}
    }
}


