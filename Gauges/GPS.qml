import QtQuick 2.8
import QtLocation 5.9
import QtPositioning 5.9
import QtQuick.Controls 2.1

Rectangle {
    id: mapItem
    anchors.fill: parent

    property int count: 0

    Connections {
        target: Dashboard
        onGpsLatitudeChanged: {
            pos.poschanged()
        }
        onGpsLongitudeChanged: {
            pos.poschanged()
        }
    }

    Rectangle {
        anchors.fill: parent
        Plugin {
            id: mapPlugin
            name: "osm"
            //Offline directory for Map Tiles
            PluginParameter {
                name: "osm.useragent"
                value: "PowerTune"
            }
            PluginParameter {
                name: 'osm.mapping.offline.directory'
                //value: ':/GPSTracks/'
                value: "/home/pi/maptiles/"
            }

            /*
                       PluginParameter {
                          name: "osm.mapping.providersrepository.address"
                          //value: 'qrc:/GPSTracks/'
                          value: "/home/pi/maptiles/"
                       }*/
        }

        Map {
            id: map
            height: parent.height
            width: parent.width * 0.55
            plugin: mapPlugin
            zoomLevel: 16
            activeMapType: map.supportedMapTypes[1]
            copyrightsVisible: false
            gesture.enabled: false
            tilt: 0
            bearing: Dashboard.gpsbearing
            color: "black"

            // Draw a small red circle for current Vehicle Location
            MapQuickItem {
                id: marker
                anchorPoint.x: 10
                anchorPoint.y: 10
                width: 15
                coordinate: QtPositioning.coordinate(Dashboard.gpsLatitude,
                                                     Dashboard.gpsLongitude)
                sourceItem: Rectangle {
                    id: image
                    width: 20
                    height: width
                    radius: width * 0.5
                    color: "red"
                }
            }
        }
        ComboBox {
            id: countryselect
            width: parent.width * 0.21//170
            height: parent.height * 0.0625//30
            anchors.left: map.right
            font.pixelSize: parent.width * 0.025 //20
            //model: [ "Current Position","Australia","Germany","New Zealand","South Africa","United Kingdom","USA"]
            model: ["Current Position", "Australia", "Germany", "New Zealand", "South Africa"]
            delegate: ItemDelegate {
                width: countryselect.width
                height: countryselect.height
                text: countryselect.textRole ? (Array.isArray(
                                                    control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
                font.weight: countryselect.currentIndex === index ? Font.DemiBold : Font.Normal
                font.family: countryselect.font.family
                font.pixelSize: countryselect.font.pixelSize
                highlighted: countryselect.highlightedIndex === index
                hoverEnabled: countryselect.hoverEnabled
            }
            onCurrentIndexChanged: changecountry.change()
        }
        ComboBox {
            id: trackselect
            width: parent.width * 0.24//230
            height: parent.height * 0.0625//30
            anchors.left: countryselect.right
            font.pixelSize: parent.width * 0.025//20
            model: ["Wakefield Park"]
            delegate: ItemDelegate {
                width: trackselect.width
                height: trackelect.height
                text: trackselect.textRole ? (Array.isArray(
                                                  control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
                font.weight: trackselect.currentIndex === index ? Font.DemiBold : Font.Normal
                font.family: trackselect.font.family
                font.pixelSize: trackselect.font.pixelSize
                highlighted: trackselect.highlightedIndex === index
                hoverEnabled: trackselect.hoverEnabled
            }
            onCurrentIndexChanged: changetrack.change()
        }
        Grid {
            rows: 10
            columns: 2
            spacing: 5
            anchors.left: map.right
            anchors.top: countryselect.bottom

            Text {
                text: "Current Time: "
                font.pixelSize: mapItem.width * 0.025 //20
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                id:dateTime
                text: Dashboard.gpsTime
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
                Component.onCompleted: {
                    console.log("Date time 2: " + dateTime.text)
                }
            }
            Text {
                text: "GPS Speed: "
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                text: Dashboard.gpsSpeed
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                text: "Altitude: "
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                text: Dashboard.gpsAltitude
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                text: "Latitude: "
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                text: Dashboard.gpsLatitude.toFixed(6)
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                text: "Longitude: "
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                text: Dashboard.gpsLongitude.toFixed(6)
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                text: "Visible Satelites: "
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                text: Dashboard.gpsVisibleSatelites
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                text: "GPS Bearing: "
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                text: Dashboard.gpsbearing
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                text: "GPS HDOP: "
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                text: (Dashboard.gpsHDOP).toFixed(2)
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                text: "GPS FIX type: "
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }
            Text {
                text: Dashboard.gpsFIXtype
                font.pixelSize: mapItem.width * 0.025
                font.bold: true
                font.family: "Eurostile"
            }

        }

        Item {
            id: changecountry
            function change() {

                if (countryselect.textAt(
                            countryselect.currentIndex) == "Current Position") {
                    trackselect.model = ["Tilt 0", "Tilt 45"],map.center = QtPositioning.coordinate(
                                -25.804219, 28.300091)
                }
                ;
                //if (countryselect.textAt(countryselect.currentIndex) == "Current Position"){trackselect.model = ["Tilt 0", "Tilt 45"],map.center= QtPositioning.coordinate(Dashboard.gpsLatitude,Dashboard.gpsLongitude)};
                if (countryselect.textAt(
                            countryselect.currentIndex) == "Australia") {
                    trackselect.model = ["Carrnell Raceway", "Wakefield Park"]
                }
                ;
                if (countryselect.textAt(
                            countryselect.currentIndex) == "Germany") {
                    trackselect.model = ["Hockenheim", "Nürburgring"]
                }
                ;
                if (countryselect.textAt(
                            countryselect.currentIndex) == "New Zealand") {
                    trackselect.model = ["Pukekohe Park"]
                }
                ;
                if (countryselect.textAt(
                            countryselect.currentIndex) == "South Africa") {
                    trackselect.model = ["Dezzi", "Midvaal", "Phakisa", "Redstar", "Zwartkops"]
                }
                ;
                //if (countryselect.textAt(countryselect.currentIndex) == "United Kingdom"){trackselect.model = ["Silverstone"]};
                //if (countryselect.textAt(countryselect.currentIndex) == "USA"){trackselect.model = ["Utah Motorsport Park"]};
                console.log(countryselect.textAt(countryselect.currentIndex))
                changetrack.change()
            }
        }

        Item {
            id: changetrack
            function change() {
                console.log(trackselect.textAt(trackselect.currentIndex))
                if (trackselect.textAt(trackselect.currentIndex) === "Tilt 0") {
                    map.tilt = 0
                }
                ;
                if (trackselect.textAt(
                            trackselect.currentIndex) === "Tilt 45") {
                    map.tilt = 45
                }
                ;
                if (trackselect.textAt(
                            trackselect.currentIndex) === "Bruce McLaren Motorsport Park") {
                    map.center = QtPositioning.coordinate(
                                -38.666331, 176.1430453,
                                17),map.zoomLevel = 15.6,map.bearing = 43,map.tilt = 0
                }
                ;
                if (trackselect.textAt(
                            trackselect.currentIndex) === "Redstar") {
                    map.center = QtPositioning.coordinate(
                                -26.074283,
                                28.751711),map.zoomLevel = 16,map.bearing
                            = 0,map.tilt = 0,GPS.defineFinishLine(-26.075097,
                                                                28.755060,
                                                                -26.075111,
                                                                28.755229)
                }
                ;
                if (trackselect.textAt(
                            trackselect.currentIndex) === "Utah Motorsport Park") {
                    map.center = QtPositioning.coordinate(
                                40.579618, -112.3805621,
                                398),map.zoomLevel = 15.1,map.bearing = 90,map.tilt = 0
                }
                ;
                if (trackselect.textAt(
                            trackselect.currentIndex) === "Wakefield Park") {
                    map.center = QtPositioning.coordinate(
                                -34.840764,
                                149.686800),map.zoomLevel = 16,map.tilt
                            = 0,map.bearing = 0,GPS.defineFinishLine(-34.840111,
                                                                   149.685229,
                                                                   -34.840172,
                                                                   149.685433)
                }
                ;
                if (trackselect.textAt(
                            trackselect.currentIndex) === "Nürburgring") {
                    map.center = QtPositioning.coordinate(
                                50.358917,
                                6.965215),map.zoomLevel = 16,map.bearing = 0,map.tilt = 0
                }
                ;
                if (trackselect.textAt(
                            trackselect.currentIndex) === "Zwartkops") {
                    map.center = QtPositioning.coordinate(
                                -25.809960,
                                28.111175),map.zoomLevel = 16.6,map.bearing
                            = 0,map.tilt = 0,GPS.defineFinishLine(-25.809477,
                                                                28.112105,
                                                                -25.809404,
                                                                28.112276)
                }
                ;
                if (trackselect.textAt(
                            trackselect.currentIndex) === "Pukekohe Park") {
                    map.center = QtPositioning.coordinate(
                                -37.215300,
                                174.919707),map.zoomLevel = 15.6,map.tilt
                            = 0,map.bearing = 0,GPS.defineFinishLine(-37.215564,
                                                                   174.915710,
                                                                   -37.215510,
                                                                   174.915914)
                }
                if (trackselect.textAt(
                            trackselect.currentIndex) === "Carrnell Raceway") {
                    map.center = QtPositioning.coordinate(
                                -28.685079,
                                151.938694),map.zoomLevel = 17,map.tilt = 0,map.bearing = 22
                }
                if (trackselect.textAt(
                            trackselect.currentIndex) === "Phakisa") {
                    map.center = QtPositioning.coordinate(
                                -27.904231,
                                26.713996),map.zoomLevel = 15.6,map.tilt = 0,map.bearing = 22
                }
                if (trackselect.textAt(
                            trackselect.currentIndex) === "Midvaal") {
                    map.center = QtPositioning.coordinate(
                                -26.612376, 28.059484),map.zoomLevel = 16,map.tilt
                            = 0,map.bearing = 22,GPS.defineFinishLine(-26.613392,
                                                                    28.058586,
                                                                    -26.613509,
                                                                    28.058717)
                }
                if (trackselect.textAt(trackselect.currentIndex) === "Dezzi") {
                    map.center = QtPositioning.coordinate(
                                -30.770474,
                                30.426004),map.zoomLevel = 16,map.tilt = 0,map.bearing = 22
                }
            }
        }

        Item {
            //Needed to permanently update the Map Center if Current Position view is selected
            id: pos
            function poschanged() {
                if (countryselect.textAt(
                            countryselect.currentIndex) == "Current Position") {
                    map.center = QtPositioning.coordinate(
                                Dashboard.gpsLatitude, Dashboard.gpsLongitude)
                }
                ;
            }
        }
    }
}
