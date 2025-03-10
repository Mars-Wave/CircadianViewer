import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    
    property int value: 6500
    property int minimum: 1800
    property int maximum: 15000
    
    signal valueEdited(int newValue)
    
    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth
    
    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 10
        
        TextField {
            id: valueInput
            Layout.preferredWidth: 70
            text: root.value.toString()
            horizontalAlignment: TextInput.AlignRight
            color: "#E0E0E0"
            
            // Use proper styling
            palette.text: "#E0E0E0"
            palette.base: "#404040"
            palette.highlight: "#6A6AFF"
            
            background: Rectangle {
                implicitWidth: 70
                implicitHeight: 30
                color: "#404040"
                border.color: valueInput.activeFocus ? "#6A6AFF" : "#555555"
                border.width: 1
                radius: 3
            }
            
            validator: IntValidator {
                bottom: root.minimum
                top: root.maximum
            }
            
            onEditingFinished: {
                let newValue = parseInt(text)
                if (!isNaN(newValue)) {
                    // Just clamp to min/max without rounding to steps
                    let clampedValue = Math.max(root.minimum, Math.min(root.maximum, newValue))
                    
                    if (root.value !== clampedValue) {
                        root.value = clampedValue
                        root.valueEdited(clampedValue)
                    }
                    
                    text = clampedValue.toString()
                } else {
                    text = root.value.toString()
                }
            }
            
            // Make sure the text always shows the current value
            Connections {
                target: root
                function onValueChanged() {
                    valueInput.text = root.value.toString()
                }
            }
        }
        
        Label {
            text: "K"
            color: "#E0E0E0"
        }
    }
    
    // Update our value when the external value changes
    function updateValue(newValue) {
        if (root.value !== newValue) {
            root.value = newValue
            valueInput.text = newValue.toString()
        }
    }
}
