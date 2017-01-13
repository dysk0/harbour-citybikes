.import QtQuick.LocalStorage 2.0 as LS
var db = LS.LocalStorage.openDatabaseSync("ctybikes", "", "ctybikes", 100000);
var readedItems = [];
var conf = { };
function initialize() {
    console.log("db.version: "+db.version);
    if(db.version === '') {
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS settings ('
                          + ' key TEXT UNIQUE, '
                          + ' value TEXT '
                          +');');
            tx.executeSql('INSERT INTO settings (key, value) VALUES (?, ?)', ["readed", ""]);
            tx.executeSql('INSERT INTO settings (key, value) VALUES (?, ?)', ["conf", "{}"]);
        });
        db.changeVersion('', '0.1', function(tx) {

        });
    }
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM settings;');
        for (var i = 0; i < rs.rows.length; i++) {
            //var json = JSON.parse(rs.rows.item(i).value);
            console.log("READED "+rs.rows.item(i).key+" in DB: "+rs.rows.item(i).value)
            if ( rs.rows.item(i).key === "readed" && rs.rows.item(i).value !== null)
                readedItems = rs.rows.item(i).value.split(",")
            if ( rs.rows.item(i).key === "conf" && rs.rows.item(i).value !== null){
                conf= JSON.parse(rs.rows.item(i).value);
            }
        }
        firstPage.getConf(conf)
    });
}


function getConfig() {
    return conf;
}
function setConfig(c) {
    conf = c;
    console.log('setConfig '+JSON.stringify(conf))
}
function getReaded() {
    return readedItems;
}
function clearReaded() {
    readedItems = [];
}
function isReaded(id) {
    if (readedItems.indexOf(id+"") !== -1){
        return true;
    } else {
        return false;
    }
}

function markReaded(id) {
    readedItems.push(id)
}

function saveData() {
    db.transaction(function(tx) {
        var rs = tx.executeSql('UPDATE settings SET value = ? WHERE key = ?', [readedItems.join(","), "readed"]);
        //var rs2 = tx.executeSql('UPDATE settings SET value = ? WHERE key = ?', [JSON.stringify(conf), "conf"]);
        console.log("Saving... "+JSON.stringify(readedItems)+"\n"+JSON.stringify(rs))
        //console.log("Saving... "+JSON.stringify(conf)+"\n"+JSON.stringify(rs2))
    });
}

function saveConfig(key, value) {
    db.transaction(function(tx) {
        var rs = tx.executeSql('UPDATE settings SET value = ? WHERE key = ?', [value, key]);
        console.log("Saving 2 DB... "+key+"\n"+value+"\n"+JSON.stringify(rs))
    });
}

