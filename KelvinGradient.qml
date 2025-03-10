import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
// Remove the QtQuick.Effects import which is causing issues

Rectangle {
    id: root
    
    property int minKelvin: 1800
    property int maxKelvin: 15000
    property int currentKelvin: 6500
    
    signal kelvinSelected(int kelvin)
    
    height: 50
    border.color: "black"
    border.width: 1
    
    // Container for gradient segments
    Row {
        id: gradientRow
        anchors.fill: parent
        
        // Generate gradient segments
        Repeater {
            model: 100 // Number of segments for smooth gradient
            
            Rectangle {
                width: root.width / 100
                height: root.height
                
                // Calculate the kelvin temperature for this segment
                property int segmentKelvin: Math.round(root.minKelvin + (index / 99) * (root.maxKelvin - root.minKelvin))
                
                // Use a temporary ColorModel instance to get the RGB color for this kelvin value
                property QtObject tempColorModel: QtObject {
                    property int kelvin: segmentKelvin
                    property color rgbColor: {
                        // This simplified conversion provides an approximation for the gradient
                        // The real conversion happens in the C++ model when clicking
                        let temp = kelvin / 100.0;
                        let r, g, b;
                        
                        if (temp <= 66) {
                            r = 255;
                            g = Math.min(255, Math.max(0, Math.round(99.4708025861 * Math.log(temp) - 161.1195681661)));
                            b = temp <= 19 ? 0 : Math.min(255, Math.max(0, Math.round(138.5177312231 * Math.log(temp - 10) - 305.0447927307)));
                        } else {
                            r = Math.min(255, Math.max(0, Math.round(329.698727446 * Math.pow(temp - 60, -0.1332047592))));
                            g = Math.min(255, Math.max(0, Math.round(288.1221695283 * Math.pow(temp - 60, -0.0755148492))));
                            b = 255;
                        }
                        
                        return Qt.rgba(r/255, g/255, b/255, 1);
                    }
                }
                
                color: tempColorModel.rgbColor
            }
        }
    }
    
    // Indicator for current kelvin position
    Rectangle {
        id: currentIndicator
        width: 3
        height: parent.height
        color: "black"
        x: {
            // Calculate position based on current kelvin value
            let ratio = (currentKelvin - minKelvin) / (maxKelvin - minKelvin);
            return Math.max(0, Math.min(parent.width - width, ratio * parent.width));
        }
    }
    
    // Enhanced handle for better interaction
    Rectangle {
        id: handleRect
        width: 15
        height: parent.height + 10
        radius: 5
        y: -5
        x: currentIndicator.x - width/2 + currentIndicator.width/2
        color: "transparent"
        border.color: "#808080"
        border.width: 1
        visible: mouseArea.containsMouse || mouseArea.pressed
        
        Rectangle {
            width: 1
            height: parent.height - 10
            anchors.centerIn: parent
            color: "#808080"
        }
    }
    
    // Hover information popup
    Rectangle {
        id: hoverInfo
        visible: false
        color: "#2D2D2D" // Dark background for the popup
        border.color: "#555555"
        border.width: 1
        width: hoverLayout.implicitWidth + 20
        height: hoverLayout.implicitHeight + 10
        radius: 5
        z: 100 // Ensure the popup appears above all other elements
        
        // Improved shadow effect using nested rectangles (no external dependencies)
        Rectangle {
            z: -1
            anchors.fill: parent
            anchors.margins: -2
            color: "transparent"
            border.color: "#40000000"
            border.width: 1
            radius: 7
        }
        
        Rectangle {
            z: -2
            anchors.fill: parent
            anchors.margins: -4
            color: "transparent" 
            border.color: "#20000000"
            border.width: 1
            radius: 9
        }
        
        ColumnLayout {
            id: hoverLayout
            anchors.centerIn: parent
            spacing: 2
            
            Label {
                id: kelvinLabel
                font.pixelSize: 12
                color: "#E0E0E0" // Light text color
            }
            
            Label {
                id: rgbLabel
                font.pixelSize: 12
                color: "#E0E0E0" // Light text color
            }
            
            Label {
                id: hexLabel
                font.pixelSize: 12
                color: "#E0E0E0" // Light text color
            }
            
            Label {
                id: hsbLabel
                font.pixelSize: 12
                color: "#E0E0E0" // Light text color
            }
        }
    }
    
    // Mouse area for interaction - enhanced for slider functionality
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        function calculateKelvinAtPosition(mouseX) {
            // Convert mouse position to kelvin value - now without rounding to step
            let positionRatio = Math.max(0, Math.min(1, mouseX / width));
            return Math.round(root.minKelvin + positionRatio * (root.maxKelvin - root.minKelvin));
        }
        
        onMouseXChanged: {
            if (containsMouse) {
                let kelvin = calculateKelvinAtPosition(mouseX);
                
                // Get color for this kelvin - this is temporary for preview, actual values will be handled by the model
                let temp = kelvin / 100.0;
                let r, g, b;
                
                if (temp <= 66) {
                    r = 255;
                    g = Math.min(255, Math.max(0, Math.round(99.4708025861 * Math.log(temp) - 161.1195681661)));
                    b = temp <= 19 ? 0 : Math.min(255, Math.max(0, Math.round(138.5177312231 * Math.log(temp - 10) - 305.0447927307)));
                } else {
                    r = Math.min(255, Math.max(0, Math.round(329.698727446 * Math.pow(temp - 60, -0.1332047592))));
                    g = Math.min(255, Math.max(0, Math.round(288.1221695283 * Math.pow(temp - 60, -0.0755148492))));
                    b = 255;
                }
                
                // Calculate hex
                let hexColor = "#" + 
                    r.toString(16).padStart(2, '0') + 
                    g.toString(16).padStart(2, '0') + 
                    b.toString(16).padStart(2, '0');
                hexColor = hexColor.toUpperCase();
                
                // Calculate temporary HSB (will be replaced by model values when clicking)
                let max = Math.max(r, g, b) / 255;
                let min = Math.min(r, g, b) / 255;
                let delta = max - min;
                let h = 0;
                let s = max === 0 ? 0 : delta / max;
                let v = max;
                
                if (delta > 0) {
                    if (max === r/255) {
                        h = ((g/255 - b/255) / delta) % 6;
                    } else if (max === g/255) {
                        h = (b/255 - r/255) / delta + 2;
                    } else {
                        h = (r/255 - g/255) / delta + 4;
                    }
                    h *= 60;
                    if (h < 0) h += 360;
                }
                
                // Update tooltip content with more information
                kelvinLabel.text = "Kelvin: " + kelvin + "K";
                rgbLabel.text = "RGB: " + r + ", " + g + ", " + b;
                hexLabel.text = "HEX: " + hexColor;
                hsbLabel.text = "HSB: " + Math.round(h) + "°, " + Math.round(s*100) + "%, " + Math.round(v*100) + "%";
                
                // Position tooltip above cursor and ensure it's visible
                hoverInfo.x = Math.min(Math.max(0, mouseX - hoverInfo.width/2), width - hoverInfo.width);
                hoverInfo.y = -hoverInfo.height - 10; // More distance from the slider
                hoverInfo.visible = true;
                
                // If pressed, update the current kelvin value (slider behavior)
                if (pressed) {
                    root.currentKelvin = kelvin;
                    root.kelvinSelected(kelvin);
                }
            }
        }
        
        onPressed: {
            let kelvin = calculateKelvinAtPosition(mouseX);
            root.currentKelvin = kelvin;
            root.kelvinSelected(kelvin);
        }
        
        onPositionChanged: {
            if (pressed) {
                let kelvin = calculateKelvinAtPosition(mouseX);
                root.currentKelvin = kelvin;
                root.kelvinSelected(kelvin);
            }
        }
        
        onExited: {
            hoverInfo.visible = false;
        }
        
        onClicked: {
            let kelvin = calculateKelvinAtPosition(mouseX);
            root.currentKelvin = kelvin;
            root.kelvinSelected(kelvin);
        }
    }
}
