import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import kelvinToRGB 1.0

Window {
    width: 750
    height: 600
    visible: true
    title: qsTr("Kelvin to RGB Converter")
    color: "#2D2D2D" // Dark gray background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 25

        // Color display with label
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            
            Rectangle {
                id: colorDisplay
                anchors.fill: parent
                color: colorModel.rgbColor
                border.color: "#404040"
                border.width: 1
                
                // Add "Resulting Color" label to top right
                Label {
                    id: resultLabel
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 10
                    text: "Resulting Color"
                    color: getBrightness(colorModel.rgbColor) > 0.95 ? "#000000" : "#FFFFFF"
                    font.pixelSize: 16
                    font.bold: true

                    // Add smooth color transition
                    Behavior on color {
                        ColorAnimation {
                            duration: 150 // 0.15 seconds
                            easing.type: Easing.OutQuad // Smooth easing curve
                        }
                    }

                    // Black background padding for better visibility on any color
                    Rectangle {
                        z: -1
                        anchors.fill: parent
                        anchors.margins: -5
                        color: "#80000000"
                        radius: 3
                        opacity: 0.7
                    }
                }
            }
        }
        
        // Color Temperature control with label on right
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            
            RowLayout {
                anchors.fill: parent
                spacing: 15
                
                // Color temperature slider
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    KelvinGradient {
                        id: kelvinGradient
                        anchors.fill: parent
                        minKelvin: 1800
                        maxKelvin: 15000
                        currentKelvin: colorModel.kelvin
                        onKelvinSelected: function(kelvin) {
                            colorModel.kelvin = kelvin
                        }
                    }
                }
                
                // Input field and label
                ColumnLayout {
                    Layout.alignment: Qt.AlignTop
                    spacing: 8
                    
                    Label {
                        text: "Color Temperature"
                        color: "#E0E0E0"
                        font.bold: true
                    }
                    
                    KelvinInput {
                        id: kelvinInput
                        Layout.preferredWidth: 100
                        minimum: 1800
                        maximum: 15000
                        value: colorModel.kelvin
                        onValueEdited: function(newValue) {
                            colorModel.kelvin = newValue
                        }
                    }
                }
            }
        }

        // Color values with label on right
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            
            RowLayout {
                anchors.fill: parent
                spacing: 15
                
                // Color values grid
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#353535"
                    border.color: "#404040"
                    border.width: 1
                    radius: 4
                    
                    GridLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 15
                        
                        Label {
                            text: "Kelvin:"
                            font.bold: true
                            color: "#E0E0E0"
                        }
                        
                        Label {
                            text: colorModel.kelvin + " K"
                            Layout.preferredWidth: 160
                            Layout.fillWidth: false
                            font.family: "Courier"
                            horizontalAlignment: Text.AlignLeft
                            color: "#E0E0E0"
                        }
                        
                        Label {
                            text: "RGB:"
                            font.bold: true
                            color: "#E0E0E0"
                        }
                        
                        Label {
                            text: Math.round(colorModel.rgbColor.r * 255) + ", " + 
                                  Math.round(colorModel.rgbColor.g * 255) + ", " + 
                                  Math.round(colorModel.rgbColor.b * 255)
                            Layout.preferredWidth: 160
                            Layout.fillWidth: false
                            font.family: "Courier"
                            horizontalAlignment: Text.AlignLeft
                            color: "#E0E0E0"
                        }
                        
                        Label {
                            text: "Hex:"
                            font.bold: true
                            color: "#E0E0E0"
                        }
                        
                        Label {
                            text: colorModel.hexColor
                            Layout.preferredWidth: 160
                            Layout.fillWidth: false
                            font.family: "Courier"
                            horizontalAlignment: Text.AlignLeft
                            color: "#E0E0E0"
                        }
                        
                        Label {
                            text: "HSB:"
                            font.bold: true
                            color: "#E0E0E0"
                        }
                        
                        Label {
                            text: colorModel.hue + "°, " + colorModel.saturation + "%, " + colorModel.brightness + "%"
                            Layout.preferredWidth: 160
                            Layout.fillWidth: false
                            font.family: "Courier"
                            horizontalAlignment: Text.AlignLeft
                            color: "#E0E0E0"
                        }
                    }
                }
                

            }
        }

        // Add attribution with clickable URL at the bottom
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 5
            text: "Huge thanks to <a href='https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html'>Tanner Helland</a>"
            color: "#B0B0B0"
            linkColor: "#6A9AFF"
            textFormat: Text.RichText
            font.pixelSize: 12
            onLinkActivated: function(link) { 
                Qt.openUrlExternally(link)
            }
            
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    Connections {
        target: colorModel
        function onKelvinChanged() {
            kelvinInput.updateValue(colorModel.kelvin)
            kelvinGradient.currentKelvin = colorModel.kelvin
        }
    }
    
    // Helper function to determine if we should use black or white text
    //     max around 0.999...
    //     min around 0.57
    function getBrightness(color) {
        return (0.299 * color.r + 0.587 * color.g + 0.114 * color.b);
    }
}
