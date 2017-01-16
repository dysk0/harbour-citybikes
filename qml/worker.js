WorkerScript.onMessage = function(msg) {
    console.log("\n\n ######## WorkerScript ######## ");
    console.log("\n "+msg.action);
    if (msg.action === 'fetchStations') {
        fetchStations(msg)
    }
    WorkerScript.sendMessage({ 'reply': 'Hi from worker!' })
}


function fetchStations(msg){
    console.log(" ######## fetchStations ######## ");
    print(JSON.stringify(msg))
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = function() {
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
            try {
                var json = JSON.parse(xmlHttp.responseText);
                var data = []
                var stations = json.network.stations;
                for(var i = 0; i < stations.length; i++){
                    if (msg.cnf.favourites && msg.cnf.favourites.indexOf(stations[i].id) > -1 ){
                        stations[i].favourited = true;
                    } else {
                        stations[i].favourited = false;
                    }
                    data.push(stations[i]);
                }
                data.sort(function(a, b){
                    if(a.name < b.name) return -1;
                    if(a.name > b.name) return 1;
                    return 0;
                })

                msg.model.clear();
                for(i = 0; i < data.length; i++){
                    msg.model.append(data[i]);
                }
                msg.model.sync();
                WorkerScript.sendMessage({ 'reply': 'modelUpdate', 'model':msg.model })
            } catch(e) {
                console.log(e)
            }
        }
        if (xmlHttp.readyState == 4 && xmlHttp.status == 403) {
            console.log(" ######## ERROR ######## ");
        }
    }
    if(msg && msg.cnf && msg.cnf.href && msg.cnf.href !== "")
    xmlHttp.open('GET', 'https://api.citybik.es/' + msg.cnf.href)
    xmlHttp.send();
}
