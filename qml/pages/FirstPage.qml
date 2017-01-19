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
    property string pageTitle: ""
    property string pageDescription: ""

    property bool isLazyLoading: false
    property bool showHints: false
    property string searchString
    onSearchStringChanged: filteredModel.update()

    WorkerScript {
        id: myWorker
        source: "../worker.js"
        onMessage: {
            console.log(messageObject.reply)
            if (messageObject.reply == "modelUpdate"){
                rawModel.update()
            }

            if (messageObject.error){

            }
        }
    }
    function getConf() {
        console.log("-------------getConf")
        pageTitle = Logic.conf.city;
        pageDescription = Logic.conf.company;

        myWorker.sendMessage({ 'model': rawModel, 'action': 'fetchStations', 'cnf': Logic.conf})
        horizontalFlick.stop()
        if (!Logic.conf.href || Logic.conf.href == ""){
            console.log("no previous conf!")
            indicator.running = false;
            horizontalFlick.direction = TouchInteraction.Left
            horizontalFlick.start()
            showHints = true;
        }
        settings.clear()
        settings.append(Logic.conf)
    }



    function updateData() {
        Logic.conf.refresh = (settings.get(0).refresh ? true : false);
        if (settings.get(0).city){
            Logic.conf.city = settings.get(0).city;
            Logic.conf.company = settings.get(0).company;
        }
        if (settings.get(0).href !== '') {
            Logic.conf.href = settings.get(0).href
        }
        getConf()
    }

    ListModel {
        id: settings
        ListElement {
            href: ""
            refresh: false
            name: ""
            favourites: ''
        }
    }
    ListModel {
        id: rawModel
        function update() {
            filteredModel.update()
        }
    }
    ListModel {
        id: filteredModel
        function update() {

            var filteredData = [];
            for (var index = 0; index < rawModel.count; index++) {
                var item = rawModel.get(index);
                if ((item.city+item.name).toLowerCase().indexOf(searchString) !== -1){
                    filteredData.push(item)
                }
            }
            var fav = [];
            var unFav = [];
            for (index = 0; index < filteredData.length; index++) {
                item = filteredData[index];
                if (filteredData[index].favourited)
                    fav.push(filteredData[index])
                else
                    unFav.push(filteredData[index])
            }
            filteredData = fav.concat(unFav)

            while (count > filteredData.length) {
                remove(filteredData.length)
            }
            for (index = 0; index < filteredData.length; index++) {
                if (index < count) {
                    setProperty(index, "id", filteredData[index].id)
                    setProperty(index, "empty_slots", filteredData[index].empty_slots)
                    setProperty(index, "free_bikes", filteredData[index].free_bikes)
                    setProperty(index, "latitude", filteredData[index].latitude)
                    setProperty(index, "longitude", filteredData[index].longitude)
                    setProperty(index, "name", filteredData[index].name)
                    setProperty(index, "timestamp", filteredData[index].timestamp)
                    setProperty(index, "favourited", filteredData[index].favourited)
                } else {
                    append(filteredData[index])
                }
            }
        }
    }


    onStatusChanged: {
        if (status === PageStatus.Active) {
            pageStack.pushAttached(Qt.resolvedUrl("Categories.qml"), {"settings": settings})
            updateData()
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
        running: rawModel.count == 0
        size: BusyIndicatorSize.Large
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Column {
        id: headerContainer
        width: firstPage.width
        PageHeader {
            title: pageTitle
            description: pageDescription
        }
        SearchField {
            id: searchField
            visible: false
            width: parent.width

            Binding {
                target: firstPage
                property: "searchString"
                value: searchField.text.toLowerCase().trim()
            }
        }
    }

    SilicaGridView {
        visible: rawModel.count !== 0
        leftMargin: Theme.paddingLarge
        id: listView
        width: parent.width;
        cellWidth: firstPage.width / (isLandscape ? 4 : 2)
        cellHeight: cellWidth
        anchors.fill: parent
        header: Item {
            id: header
            width: headerContainer.width
            height: headerContainer.height
            Component.onCompleted: headerContainer.parent = header
        }
        PullDownMenu {
            id: pullDownMenu
            MenuItem {
                //: Pull menu item for list reload
                //% Refresh
                text: qsTrId("Remove default location")
                onClicked: {
                    showHints = true;
                    Logic.conf = {}
                    settings.setProperty(0, "city",'');
                    settings.setProperty(0, "href",'');
                    settings.setProperty(0, "favourites",' ');
                    //getConf({})
                    filteredModel.clear()
                    rawModel.clear()
                    updateData();
                }
            }
            MenuItem {
                //% About
                text: qsTrId("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"), data)
                }
            }

            MenuItem {
                //% Refresh
                text: qsTrId("Refresh")
                onClicked: {
                    getConf()
                }
            }

            MenuItem {
                //: Pull menu item for list Search
                //% Search
                text: (searchField.visible ? qsTrId("Hide search") : qsTrId("Show search"))
                onClicked: {
                    searchField.visible = !searchField.visible
                    if (!searchField.visible){
                        searchString = ""
                    }
                }
            }

        }

        model: filteredModel
        //section.delegate: sectionDelegate
        ViewPlaceholder {
            enabled: searchField.visible && filteredModel.count == 0
            text: qsTrId("No results found!")
            hintText: qsTrId("Please change your inquiry")
        }


        delegate: MyGridDelegate {
            //width: parent.width
            title: Theme.highlightText(model.name, searchString, Theme.highlightColor)
            titleColor: searchString.length > 0 ? (highlighted ? Theme.secondaryHighlightColor : Theme.primaryColor)
                                                : (highlighted ? Theme.highlightColor : Theme.primaryColor)
            fav: favourited
            _free_bike: {
                return ( typeof free_bikes != "undefined" ? free_bikes : 0)
            }
            _empty_slots: {
                return ( typeof empty_slots != "undefined" ? empty_slots : 0)
            }
            subtitle: _free_bike + ' / ' + _empty_slots
            pillColor: {
                return (_free_bike == 0 ? '#E33033' : (_free_bike/(_free_bike+_empty_slots) < 0.25 ? '#FFB43F' : '#093'))
            }
            height: width
            texture: true
            columnsPortrait: 2
            columnsLandscape: 4

            onClicked: {
                var data = {
                    stationId: id,
                    company: settings.get(0).company,
                    city: settings.get(0).city,
                    href: settings.get(0).href,
                    name: name,
                    free_bikes: _free_bike,
                    empty_slots: _empty_slots,
                    latitude: latitude,
                    longitude: longitude,
                    timestamp: timestamp,
                    settings: settings
                }
                pageStack.push(Qt.resolvedUrl("Station.qml"), data)
            }
        }



        VerticalScrollDecorator {}




    }

    InteractionHintLabel {
        id: horizontalFlick2
        anchors.bottom: parent.bottom
        visible: (rawModel.count == 0) && showHints
        Behavior on opacity { FadeAnimation { duration: 1000 } }
        text: "Flick left to select default location"
    }
    TouchInteractionHint {
        id: horizontalFlick
        visible: (rawModel.count == 0) && showHints
        loops: Animation.Infinite
        anchors.verticalCenter: parent.verticalCenter
    }

}


