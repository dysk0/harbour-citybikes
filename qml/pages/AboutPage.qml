import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    allowedOrientations : Orientation.All
    id: about

    SilicaFlickable {
        VerticalScrollDecorator {}
        anchors.fill: parent
        contentHeight: column.height
        Column {
            id: column
            width: parent.width
            spacing: 20
            PageHeader {
                title: "About"
                description: "City Bikes"
            }


            Label {
                anchors.left: parent.left; anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right; anchors.rightMargin: Theme.paddingLarge
                color: Theme.primaryColor
                text: 'City Bike supports more than 400 cities and the Citybikes API is the most widely used dataset for building bike sharing transportation projects.'
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
            }

            Label {
                anchors.left: parent.left; anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right; anchors.rightMargin: Theme.paddingLarge
                color: Theme.secondaryHighlightColor
                text: 'If you have some problems with application, please feel free to contact me via Twitter. Also, if you want to show some appreciation use Donate button or help me on the GitHub.'
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
            }
            Label {
                anchors.left: parent.left; anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right; anchors.rightMargin: Theme.paddingLarge
                color: Theme.secondaryHighlightColor
                text: 'Also, I am avaiable for some freelance work, so check me out on the LinkedIn. :)'
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
            }
            Column {
                spacing: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                SectionHeader {
                    anchors.left: parent.left; anchors.leftMargin: Theme.paddingLarge
                    anchors.right: parent.right; anchors.rightMargin: Theme.paddingLarge
                    text: "Credits"
                }

                Button {
                    text: "Translate App"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: Qt.openUrlExternally("https://www.transifex.com/dysko/citybikes/translate/")
                }
                Button {
                    text: "Twitter"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: Qt.openUrlExternally("https://www.twitter.com/dysko")
                }
                Button {
                    text: "LinkedIn"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: Qt.openUrlExternally("https://www.linkedin.com/in/angirevic")
                }
                Button {
                    text: "GitHub"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: Qt.openUrlExternally("https://github.com/dysk0/harbour-citybikes")
                }
                Button {
                    text: "Development"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: Qt.openUrlExternally("http://www.grave-design.com/")
                }
                Button {
                    text: "Donate"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: Theme.paddingLarge
                    onClicked: {
                        Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=RSKSSS83DMYRJ")
                    }
                }
            }
            Column {
                spacing: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
            }
        }
    }
}
