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
    property int coverIndex: 3
    property bool shouldAnimate: false
    onShouldAnimateChanged: {
        console.log(shouldAnimate)
        updateTimer.running = shouldAnimate
    }


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
            displayModel.clear()
            filteredModel.update()
        }
    }
    ListModel {
        id: displayModel
    }
    ListModel {
        id: filteredModel
        function update() {
            clear();
            var filteredData = [];
            for (var index = 0; index < rawModel.count; index++) {
                var item = rawModel.get(index);
                if (item.favourited){
                    filteredData.push(item)
                }
            }

            while (count > filteredData.length) {
                remove(filteredData.length)
            }
            for (index = 0; index < filteredData.length; index++) {
                append(filteredData[index])
            }
            for (index = 0; index < filteredData.length; index++) {
                if (index < 3)
                    displayModel.append(filteredData[index])
                append(filteredData[index])
            }
            if (filteredData.length > 3){
                console.log(filteredData.length )
                shouldAnimate = true;
            } else{
                shouldAnimate = false;}
        }
    }
    Label {
        visible: true
        width: parent.width-2*Theme.paddingMedium
        x: Theme.paddingMedium
        y: parent.height - Theme.paddingMedium - height
        text: "City Bikes"
        font.pixelSize: Theme.fontSizeMedium
        horizontalAlignment : Text.AlignRight
        color: Theme.highlightColor
        truncationMode: TruncationMode.Fade
    }



    Timer {
        id: updateTimer
        interval: 4000;
        running: shouldAnimate;
        repeat: true
        onTriggered: {
            if (coverIndex < filteredModel.count-1){
                coverIndex++
            } else {
                coverIndex = 0
            }
            if (displayModel.count > 2){
                displayModel.remove(0)
            }
            displayModel.append(filteredModel.get(coverIndex))

            //list.positionViewAtIndex(coverIndex, ListView.Beginning)

        }
    }

    SilicaListView {
        id: list
        clip: true
        width: parent.width
        height: Theme.itemSizeSmall*3
        x: Theme.paddingSmall
        y: Theme.paddingLarge
        //anchors.bottom: parent.bottom
        //anchors.bottomMargin: 10
        snapMode: ListView.SnapToItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightFollowsCurrentItem: true

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 800 }
            NumberAnimation { property: "scale"; from: 0; to: 1.0; duration: 800 }
        }

        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 800; easing.type: Easing.InOutBack }
        }
        model: displayModel


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
        shouldAnimate = false;
        if (status === PageStatus.Active) {
            myWorker.sendMessage({ 'model': rawModel, 'action': 'fetchStations', 'cnf': Logic.conf})
        }
        if (filteredModel.count < 4)
            shouldAnimate = false;
    }
}
