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
import "../pages/Logic.js" as Logic

CoverBackground {
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
            for (var index = 0; index < (rawModel.count > 4 ? 5 : rawModel.count); index++) {
                var item = rawModel.get(index);
                if (item.favourited){
                    filteredData.push(item)
                }
            }

            while (count > filteredData.length) {
                remove(filteredData.length)
            }
            for (index = 0; index < filteredData.length; index++) {
                if (index < count) {
                    setProperty(index, "id", filteredData[index].id)
                    setProperty(index, "name", filteredData[index].name)
                    setProperty(index, "empty_slots", filteredData[index].empty_slots)
                    setProperty(index, "free_bikes", filteredData[index].free_bikes)
                } else {
                    append(filteredData[index])
                }
            }
        }
    }
    Label {
        visible: !filteredModel.count
        x: Theme.paddingLarge
        y: parent.height - Theme.paddingLarge - height
        text: "City Bikes"
        font.pixelSize: Theme.fontSizeLarge
        color: Theme.highlightColor
        truncationMode: TruncationMode.Fade
    }
    SilicaListView {
        model: filteredModel
        anchors{
            fill: parent
            topMargin: Theme.paddingLarge
            bottomMargin: Theme.paddingLarge
            leftMargin: Theme.paddingSmall
            rightMargin: Theme.paddingLarge
        }
        delegate: Item {
            width: parent.width
            height: Theme.itemSizeSmall
            Rectangle {
                id: rect
                radius: 2
                width: 4
                height: parent.height-4
                y: 2
                color: (free_bikes == 0 ? '#E33033' : (free_bikes/(free_bikes+empty_slots) < 0.25 ? '#FFB43F' : '#093'))
            }
            Column {
                width: parent.width
                anchors {
                    verticalCenter: parent.verticalCenter
                }

                Label {
                    id: lbl
                    x: Theme.paddingLarge
                    text: name
                    font.pixelSize: Theme.fontSizeSmall
                    width: parent.width - Theme.paddingLarge
                    color: Theme.primaryColor
                    truncationMode: TruncationMode.Fade
                }
                Label {
                    x: lbl.x

                    text: free_bikes +' / '+ empty_slots
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.highlightColor
                    truncationMode: TruncationMode.Fade
                }
            }
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Active) {
            myWorker.sendMessage({ 'model': rawModel, 'action': 'fetchStations', 'cnf': Logic.conf})
        }
    }
}
