import QtQuick 2.0
import Sailfish.Silica 1.0


Item {
    visible: true
    property string title: '27'
    property string description: 'BIKES'
    clip: true

    Column {
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.paddingLarge
            //verticalCenter: parent.verticalCenter
        }
        width: parent.width
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeExtraLarge*1.2
            text: title
        }
    }

    Column {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.paddingLarge
            bottomMargin: Theme.paddingLarge
        }
        width: parent.width
        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            color: Theme.secondaryHighlightColor
            font.pixelSize: Theme.fontSizeSmall
            text: description.toUpperCase()
        }
    }


    Rectangle {
        visible: false
        rotation: 45
        width: parent.width * 1.412136
        height: parent.height * 1.412136
        x: parent.width - width

        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0) }
            GradientStop { position: 1.0; color: Theme.rgba(Theme.primaryColor, 0.05) }
        }
    }
}
