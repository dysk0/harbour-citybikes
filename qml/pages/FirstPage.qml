/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "Logic.js" as Logic


Page {
    id: firstPage
    property string categoryDescription: ""
    property bool isLazyLoading: false
    property bool showHints: false
    property real readedOpacity: 0.6
    property variant readed: []
    function getConf(cnf) {
        console.log(JSON.stringify(cnf))
        horizontalFlick.stop()
        if (!cnf.href){
            console.log("no previous conf!")
            indicator.running = false;
            horizontalFlick.direction = TouchInteraction.Left
            horizontalFlick.start()
            showHints = true;
        }


        settings.clear()
        settings.append(cnf)
    }

    ListModel {
        id: settings
        ListElement {
            href: "/v2/networks/bicing"
            refresh: false
            name: "Mjau"
        }
    }

    function updateData() {
        console.log("CONFIG")
        var source = ""

        var _city = settings.get(0).city;
        var _company= settings.get(0).company;
        var _href = settings.get(0).href;


        var _refresh = settings.get(0).refresh;
        categoryDescription = settings.get(0).city;
        if (_refresh) {
            articles.model.clear();
            settings.setProperty(0, "refresh", false);
        }

        if (settings.get(0).href !== "")
            source  ='https://api.citybik.es'+_href;

        articles.source = source;
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            pageStack.pushAttached(Qt.resolvedUrl("Categories.qml"), {"settings": settings})
            updateData()
            //myWorker.sendMessage({ 'model': articles, 'action': 'fetch', 'category': settings.get(0).category, 'page': settings.get(0).page})
        }
    }
    Component.onCompleted: {
        Logic.initialize();

    }
    Component.onDestruction: {
        Logic.saveData()
    }

    BusyIndicator {
        id: indicator
        running: articles.count == 0
        size: BusyIndicatorSize.Large
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
    SilicaGridView {
        visible: articles.count !== 0
        leftMargin: Theme.paddingLarge
        id: listView
        width: parent.width;
        cellWidth: firstPage.width / (isLandscape ? 4 : 2)
        cellHeight: cellWidth
        anchors.fill: parent
        PullDownMenu {
            id: pullDownMenu
            MenuItem {
                //: Pull menu item for list reload
                //% Refresh
                text: "Remove default location"
                onClicked: {
                    Logic.saveConfig("conf", JSON.stringify({}));
                    articles.model.clear()
                    settings.clear();
                    getConf()
                    updateData();
                }
            }
            MenuItem {
                text: "Mark all unread"

                onClicked: {
                    Logic.clearReaded();
                    articles.model.clear()
                    settings.setProperty(0, "refresh", false);
                    settings.setProperty(0, "page", 1);
                    updateData();
                }
            }
            MenuItem {
                //: Pull menu item for list reload
                //% Refresh
                text: "Reload"
                onClicked: {
                    articles.model.clear()
                    settings.setProperty(0, "refresh", false);
                    settings.setProperty(0, "page", 1);
                    updateData();
                }
            }
        }
        header: PageHeader {
            title: categoryDescription
            //: header title
            //% City Bikes
            description: qsTrId("City Bikes")
        }
        JSONListModel {
            id: articles
            source: ""
            query: "$.network.stations[*]"
        }
        model: articles.model
        //section.delegate: sectionDelegate


        delegate: MyGridDelegate {
            //width: parent.width
            title: name
            subtitle: free_bikes+' / '+empty_slots
            pillColor: (free_bikes == 0 ? '#E33033' : (free_bikes/(free_bikes+empty_slots) < 0.25 ? '#FFB43F' : '#093'))
            height: width
            texture: true
            //    width: (appWindow.orientation === Orientation.Portrait) ? (GridView.view.width / columnsPortrait) : (GridView.view.width / columnsLandscape)
            columnsPortrait: 2
            columnsLandscape: 4

            onClicked: {
                console.debug(index)
                console.debug(free_bikes/(free_bikes+empty_slots))
                console.debug('bikes ' + free_bikes + "\t  slots: "+ empty_slots)
            }
        }



        VerticalScrollDecorator {}




    }

    InteractionHintLabel {
        id: horizontalFlick2
        anchors.bottom: parent.bottom
        visible: (articles.count == 0) && showHints
        Behavior on opacity { FadeAnimation { duration: 1000 } }
        text: "Flick left to select default location"
    }
    TouchInteractionHint {
        id: horizontalFlick
        visible: (articles.count == 0) && showHints
        loops: Animation.Infinite
        anchors.verticalCenter: parent.verticalCenter
    }

}


