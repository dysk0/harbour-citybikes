.import QtQuick.LocalStorage 2.0 as LS
var db = LS.LocalStorage.openDatabaseSync("dyskoctbikes", "", "dyskoctbikes", 100000);
var conf = {
    favourites: [],
    showSearch: false
};
function initialize() {
    console.log("db.version: "+db.version);
    if(db.version === '') {
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS settings ('
                          + ' key TEXT UNIQUE, '
                          + ' value TEXT '
                          +');');
            tx.executeSql('INSERT INTO settings (key, value) VALUES (?, ?)', ["favourite", ""]);
            tx.executeSql('INSERT INTO settings (key, value) VALUES (?, ?)', ["conf", "{}"]);
        });
        db.changeVersion('', '0.1', function(tx) {

        });
    }
    if(db.version === '0.1')
        db.changeVersion('0.1', '0.2', function(tx) {
            tx.executeSql('DELETE FROM settings WHERE key= "readed" ');
            tx.executeSql('INSERT INTO settings (key, value) VALUES (?, ?)', ["favourite", ""]);
        });
    if(db.version === '0.2')
        db.changeVersion('0.2', '0.3', function(tx) {
            tx.executeSql('DELETE FROM settings WHERE key= "favourite" ');
            tx.executeSql('INSERT INTO settings (key, value) VALUES (?, ?)', ["favourite", "[]"]);
        });

    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT * FROM settings;');
        for (var i = 0; i < rs.rows.length; i++) {
            //var json = JSON.parse(rs.rows.item(i).value);
            console.log("READED "+rs.rows.item(i).key+" in DB: "+rs.rows.item(i).value)
            //if ( rs.rows.item(i).key === "favourite" && rs.rows.item(i).value !== null)
            //    favouriteItems = JSON.parse(rs.rows.item(i).value);
            if ( rs.rows.item(i).key === "conf" && rs.rows.item(i).value !== null){
                conf= JSON.parse(rs.rows.item(i).value);
            }
        }
        console.log("FAV: "+JSON.stringify(conf));
        firstPage.getConf(conf)
    });
}

function test() {
    console.log("SUPER TEST!")
}
function getConfig() {
    return conf;
}
function setConfig(c) {
    conf = c;
    console.log('setConfig '+JSON.stringify(conf))
}

function isFavourite(id) {
    if (conf.favourites && conf.favourites.indexOf(id) > -1){
        return true;
    } else {
        return false;
    }
}



function saveData() {
    db.transaction(function(tx) {
        //var rs = tx.executeSql('UPDATE settings SET value = ? WHERE key = ?', [ JSON.stringify(favouriteItems), "favourite"]);
        var rs2 = tx.executeSql('UPDATE settings SET value = ? WHERE key = ?', [JSON.stringify(conf), "conf"]);
        //console.log("Saving... "+JSON.stringify(favouriteItems)+"\n"+JSON.stringify(rs))
        //console.log("Saving... "+JSON.stringify(conf)+"\n"+JSON.stringify(rs2))
    });
}

function saveConfig(key, value) {
    db.transaction(function(tx) {
        var rs = tx.executeSql('UPDATE settings SET value = ? WHERE key = ?', [value, key]);
        console.log("Saving 2 DB... "+key+"\n"+value+"\n"+JSON.stringify(rs))
    });
}

