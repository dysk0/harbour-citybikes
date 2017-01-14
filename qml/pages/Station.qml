/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Joona Petrell <joona.petrell@jollamobile.com>
** All rights reserved.
**
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0
import QtPositioning 5.2

import "Logic.js" as Logic

Page {
    id: pageStation
    property string stationId: ''
    property string company: ''
    property string city: ''
    property string href: ''
    property int free_bikes: 0
    property int empty_slots: 0
    property double latitude
    property double longitude
    property double timestamp
    property string name: ''
    property string extra: ''


    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    PositionSource {
        id: positionSource
        active: true
        updateInterval: 120000 // 2 mins
        property variant fromCoordinate: QtPositioning.coordinate(latitude, longitude)
        onPositionChanged:  {
            var currentPosition = positionSource.position.coordinate
            var _distance = currentPosition.distanceTo(fromCoordinate)
            console.log("distance:" + _distance)
            if (_distance < 1000){
                _distance = _distance + ' m'
            } else {
                _distance = Math.round(_distance/1000) + ' km'
            }
            distance.title = _distance;
        }
    }

    DockedPanel {
        id: controlPanel

        width: pageStation.isPortrait ? parent.width : Theme.itemSizeExtraLarge + Theme.paddingLarge
        height: pageStation.isPortrait ? Theme.itemSizeExtraLarge + Theme.paddingLarge : parent.height

        dock: pageStation.isPortrait ? Dock.Top : Dock.Left

        Flow {
            width: isPortrait ? undefined : Theme.itemSizeExtraLarge

            anchors.centerIn: parent

            Switch {
                icon.source: "image://theme/icon-l-shuffle"
            }
            Switch {
                icon.source: "image://theme/icon-l-repeat"
            }
            Switch {
                icon.source: "image://theme/icon-l-share"
            }
        }
    }

    Drawer {
        id: drawer

        anchors.fill: parent
        dock: pageStation.isPortrait ? Dock.Top : Dock.Left

        background: WebView {
            id: wv
            anchors.fill: parent
            url: 'http://api.grave-design.com/citybike.php?latitude='+latitude+'&longitude='+longitude
            x: 0
            y: 0
            smooth: false

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            onLoadingChanged: {
                if (loadRequest.status == WebView.LoadSucceededStatus)
                drawer.open = true
            }

            Component.onCompleted: {


            }
        }

        SilicaFlickable {
            anchors {
                fill: parent
                leftMargin: pageStation.isPortrait ? 0 : controlPanel.visibleSize
                topMargin: pageStation.isPortrait ? controlPanel.visibleSize : 0
                rightMargin: pageStation.isPortrait ? 0 : progressPanel.visibleSize
                bottomMargin: pageStation.isPortrait ? progressPanel.visibleSize : 0
            }

            contentHeight: column.height + Theme.paddingLarge

            VerticalScrollDecorator {}

            MouseArea {
                enabled: true //drawer.open
                anchors.fill: parent
                onClicked: drawer.open = !drawer.open
            }


            Column {
                id: column
                spacing: Theme.paddingLarge
                width: parent.width
                enabled: !drawer.opened

                PageHeader {
                    title: city
                    description: name
                }
                Row {
                    spacing: Theme.paddingLarge
                    width: parent.width
                    height: parent.width/2

                    CmpDisplayElement {
                        id: smComp
                        width: (parent.width-2*Theme.paddingLarge)/2
                        height: width
                        title: free_bikes
                        description: free_bikes == 1 ? qsTrId("Free Bike") : qsTrId("Free Bikes")
                    }

                    CmpDisplayElement {
                        width: smComp.width
                        height: width
                        title: empty_slots
                        description: qsTrId("Empty slots")
                    }

                }
                CmpDisplayElement {
                    id: distance
                    width: parent.width
                    height: smComp.width
                    title:  '∞'
                    description: qsTrId("Far away")
                }

                Button {
                    visible: false
                    text: controlPanel.open ? "Hide controls" : "Show controls"
                    onClicked: controlPanel.open = !controlPanel.open
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    visible: false
                    text: progressPanel.open ? "Hide progress" : "Show progress"
                    onClicked: progressPanel.open = !progressPanel.open
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    visible: false
                    text: "Open drawer " + empty_slots + ' ' +  free_bikes
                    onClicked: drawer.open = true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

        }
        Component.onCompleted: {
            //Logic.initialize();
            //drawer.open = true
        }

    }

    DockedPanel {
        id: progressPanel

        width: pageStation.isPortrait ? parent.width : Theme.itemSizeExtraLarge + Theme.paddingLarge
        height: pageStation.isPortrait ? Theme.itemSizeExtraLarge + Theme.paddingLarge : parent.height

        dock: pageStation.isPortrait ? Dock.Bottom : Dock.Right

        ProgressCircle {
            id: progressCircle

            anchors.centerIn: parent

            NumberAnimation on value {
                from: 0
                to: 1
                duration: 1000
                running: progressPanel.expanded
                loops: Animation.Infinite
            }
        }
    }
}
