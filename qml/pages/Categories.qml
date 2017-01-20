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
import "Logic.js" as Logic

Page {
    id: searchPage
    property ListModel settings
    property string searchString
    property bool keepSearchFieldFocus
    property string activeView: "list"

    onSearchStringChanged: listModel.update()
    Component.onCompleted: listModel.update()

    Loader {
        anchors.fill: parent
        sourceComponent: activeView == "list" ? listViewComponent : gridViewComponent
    }

    Column {
        id: headerContainer

        width: searchPage.width

        PageHeader {
            title: qsTr("Networks")
        }

        SearchField {
            id: searchField
            width: parent.width

            Binding {
                target: searchPage
                property: "searchString"
                value: searchField.text.toLowerCase().trim()
            }
        }
    }

    Component {
        id: gridViewComponent
        SilicaGridView {
            id: gridView
            model: listModel
            anchors.fill: parent
            currentIndex: -1
            header: Item {
                id: header
                width: headerContainer.width
                height: headerContainer.height
                Component.onCompleted: headerContainer.parent = header
            }

            cellWidth: gridView.width / 3
            cellHeight: cellWidth

            PullDownMenu {
                MenuItem {
                    text: "Switch to list"
                    onClicked: {
                        keepSearchFieldFocus = searchField.activeFocus
                        activeView = "list"
                    }
                }
            }

            delegate: BackgroundItem {
                id: rectangle
                width: gridView.cellWidth
                height: gridView.cellHeight
                GridView.onAdd: AddAnimation {
                    target: rectangle
                }
                GridView.onRemove: RemoveAnimation {
                    target: rectangle
                }

                OpacityRampEffect {
                    sourceItem: label
                    offset: 0.5
                }

                Label {
                    id: label
                    x: Theme.paddingMedium; y: Theme.paddingLarge
                    width: parent.width - y
                    textFormat: Text.StyledText
                    color: searchString.length > 0 ? (highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                                                   : (highlighted ? Theme.highlightColor : Theme.primaryColor)

                    text: Theme.highlightText(model.text, searchString, Theme.highlightColor)
                    font {
                        pixelSize: Theme.fontSizeLarge
                        family: Theme.fontFamilyHeading
                    }
                }
            }

            VerticalScrollDecorator {}

            Component.onCompleted: {
                if (keepSearchFieldFocus) {
                    searchField.forceActiveFocus()
                }
                keepSearchFieldFocus = false
            }
        }
    }

    Component {
        id: listViewComponent
        SilicaListView {
            model: listModel
            anchors.fill: parent
            currentIndex: -1 // otherwise currentItem will steal focus
            header:  Item {
                id: header
                width: headerContainer.width
                height: headerContainer.height
                Component.onCompleted: headerContainer.parent = header
            }

            ViewPlaceholder {
                enabled: listModel.count == 0
                text: rawModel.count==0 ? qsTr("Please wait...") : qsTr("No results found!")
                hintText: rawModel.count==0 ? qsTr("Loading networks to display") : ("Please change your inquiry")
            }

            section {
                property: 'section'
                delegate: SectionHeader {
                    text: section
                    height: Theme.itemSizeSmall
                }
            }

            delegate: BackgroundItem {
                id: backgroundItem
                height: Theme.itemSizeLarge


                ListView.onAdd: AddAnimation {
                    target: backgroundItem
                }
                ListView.onRemove: RemoveAnimation {
                    target: backgroundItem
                }

                Column {
                    width: parent.width
                    anchors {
                        left: parent.left
                        leftMargin: searchField.textLeftMargin
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }

                    Label {
                        width: parent.width
                        color: searchString.length > 0 ? (highlighted ? Theme.secondaryHighlightColor : Theme.primaryColor)
                                                       : (highlighted ? Theme.highlightColor : Theme.primaryColor)
                        textFormat: Text.StyledText
                        text: Theme.highlightText(model.city, searchString, Theme.highlightColor)
                    }
                    Label {
                        width: parent.width
                        color: searchString.length > 0 ? (highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                                                       : (highlighted ? Theme.highlightColor : Theme.secondaryColor)
                        textFormat: Text.StyledText
                        text: Theme.highlightText(model.name, searchString, Theme.highlightColor)
                        font.pixelSize: Theme.fontSizeExtraSmall
                    }
                }
                onClicked: {
                    console.log("Clicked " + model.href)
                    //{"city":"","country":"","href":"","name":""}
                    if (settings.get(0).href !== model.href){
                        settings.setProperty(0, "refresh", true);
                        settings.setProperty(0, "href", model.href);
                        settings.setProperty(0, "city", model.city);
                        settings.setProperty(0, "company", model.name);

                        Logic.conf = {
                            "refresh": true,
                            "city": model.city,
                            "company": model.name,
                            "href": model.href,
                            "favourites": []
                        }
                    }
                    pageStack.navigateBack()
                }
            }

            VerticalScrollDecorator {}

            Component.onCompleted: {
                if (keepSearchFieldFocus) {
                    searchField.forceActiveFocus()
                }
                keepSearchFieldFocus = false
            }
        }
    }
    ListModel {
        id: rawModel
        function sortModel() {
            for(var i=0; i<count; i++) {
                for(var j=0; j<i; j++) {
                    if(get(i).section <= get(j).section)
                        move(i,j,1)
                    break
                }
            }

        }
    }
    ListModel {
        id: listModel

        function update() {

            var filteredData = [];
            for (var index = 0; index < rawModel.count; index++) {
                var item = rawModel.get(index);
                if ((item.city+item.name).toLowerCase().indexOf(searchString) !== -1){
                    filteredData.push(item)
                }
            }

            while (count > filteredData.length) {
                remove(filteredData.length)
            }
            for (index = 0; index < filteredData.length; index++) {
                if (index < count) {
                    setProperty(index, "city", filteredData[index].city)
                    setProperty(index, "company", filteredData[index].company)
                    setProperty(index, "href", filteredData[index].href)
                    setProperty(index, "name", filteredData[index].name)
                    setProperty(index, "section", filteredData[index].section)
                } else {
                    append(filteredData[index])
                }
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            var xmlHttp = new XMLHttpRequest();
            xmlHttp.onreadystatechange = function() {
                if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
                    try {
                        var json = JSON.parse(xmlHttp.responseText);
                        var filteredData = {}
                        for(var i = 0; i < json.networks.length; i++){
                            var item = json.networks[i];
                            var _item = {
                                'name' : item.name,
                                'href' : item.href,
                                'city' : item.location.city,
                                'section' : item.location.country,
                                'company' : Array.isArray(item.company) ? item.company.join(", ") : item.company
                            }
                            console.log(_item);
                            if (!filteredData.hasOwnProperty(_item.section)){
                                filteredData[_item.section] = [];
                            }
                            filteredData[_item.section].push(_item);
                            //rawModel.append(_item);
                        }
                        //rawModel.sortModel();
                        var k, keys = [];
                        for (k in filteredData) {
                            if (filteredData.hasOwnProperty(k)) {
                                keys.push(k);
                            }
                        }
                        keys.sort();
                        var _filteredData = [];

                        // sort u sekciji
                        for (i = 0; i < keys.length; i++) {
                            k = keys[i];
                            filteredData[k].sort(function(a, b){
                                if(a.city < b.city) return -1;
                                if(a.city > b.city) return 1;
                                return 0;
                            })
                        }


                        for (i = 0; i < keys.length; i++) {
                            k = keys[i];
                            for (var j = 0; j < filteredData[k].length; j++) {
                                _filteredData.push(filteredData[k][j]);
                            }
                        }
                        filteredData = _filteredData;
                        _filteredData = 0;
                        for (var index = 0; index < filteredData.length; index++) {
                            item = filteredData[index];
                            //console.log([item.city, item.section])
                        }
                        //console.log(JSON.stringify(filteredData))
                        rawModel.clear();
                        for (var index = 0; index < filteredData.length; index++) {
                            rawModel.append(filteredData[index]);
                        }
                        listModel.update();

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
}
