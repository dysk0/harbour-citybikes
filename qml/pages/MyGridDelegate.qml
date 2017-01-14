import QtQuick 2.0
import Sailfish.Silica 1.0

import "."

/**************************************************************************
 *   Butaca
 *   Copyright (C) 2011 - 2012 Simon Pena <spena@igalia.com>
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 **************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0


BackgroundItem {
    id: delegate
    property string pillColor: ''
    property string title: ''
    property bool fav: false
    property int titleSize: Theme.fontSizeMedium
    property int titleWeight: Font.Normal
    property string titleFontFamily: Theme.fontFamily
    property color titleColor: Theme.primaryColor
    property bool titleWraps: true

    property string subtitle: ''
    property int subtitleSize: Theme.fontSizeExtraSmall
    property int subtitleWeight: Font.Normal
    property string subtitleFontFamily: Theme.fontFamily
    property color subtitleColor: Theme.secondaryColor
    property bool subtitleWraps: false

    property string iconSource: ''
    property bool smallSize: false

    property bool expandable: false
    property bool expanded: false

    property alias texture: textureItem.visible

    property int defaultSize: smallSize ?
                                  Theme.itemSizeSmall :
                                  Theme.itemSizeMedium
    property int columnsPortrait: 1
    property int columnsLandscape: 1
    width: GridView.view.cellWidth
//    width: (appWindow.orientation === Orientation.Portrait) ? (GridView.view.width / columnsPortrait) : (GridView.view.width / columnsLandscape)
    height: Theme.itemSizeLarge
    Rectangle {
        id: rect
        radius: (fav ? 3 : 0)
        width: parent.height*0.05
        height: width
        y: parent.height - height - Theme.paddingLarge
        x: Theme.paddingLarge
        color: pillColor
    }

    Item {
        id: textureItem
        visible: false
        anchors.fill: parent
        clip: true

        Rectangle {
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

    Image {
        id: delegateImage
        anchors {
            left: parent.left
            leftMargin: Theme.paddingLarge
            verticalCenter: parent.verticalCenter
        }
        source: iconSource
        fillMode: Image.PreserveAspectFit
        width: Theme.itemSizeLarge
        height: Theme.itemSizeLarge
        visible: iconSource
    }

    Column {
        id: delegateColumn
        anchors {
            left: delegateImage.visible ? delegateImage.right : parent.left
            leftMargin: Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.paddingLarge
            verticalCenter: parent.verticalCenter
        }
        width: parent.width -
               (delegateImage.visible ? (delegateImage.width + Theme.paddingLarge) : 0) - Theme.paddingLarge

        Label {
            id: delegateTitleLabel
            font.weight: titleWeight
            font.pixelSize: titleSize
            color: titleColor
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: titleWraps ? Text.WordWrap : Text.NoWrap
            elide: titleWraps ? Text.ElideNone : Text.ElideRight

            text: title
        }
    }
    Label {
        id: delegateSubtitleLabel
        font.weight: subtitleWeight
        color: subtitleColor
        font.pixelSize: subtitleSize
        width: parent.width-Theme.paddingLarge
        y:Theme.paddingLarge
        anchors {

            rightMargin: Theme.paddingLarge
            topMargin: Theme.paddingLarge
            bottomMargin: Theme.paddingLarge
        }
        horizontalAlignment: Text.AlignRight
        wrapMode: Text.WordWrap
        elide: subtitleWraps ? Text.ElideNone : Text.ElideRight
        visible: subtitle
        text: subtitle
    }
}


