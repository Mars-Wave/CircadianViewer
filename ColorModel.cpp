#include "ColorModel.h"
#include <QtMath>

static uint8_t clampDoubleToUint8(double x, double min, double max)
{
    if (x < min)
        return min;
    if (x > max)
        return max;
    return x;
}

void ColorModel::setKelvin(uint16_t kelvin)
{
    if (m_kelvin != kelvin) {
        m_kelvin = kelvin;
        updateRgbColor();
        emit kelvinChanged();
    }
}

void ColorModel::updateRgbColor()
{
    const auto temp = m_kelvin / 100.0;
    float red, green, blue;

    if (temp <= 66) {
        red = 255;
        
        green = temp;
        green = 99.4708025861 * qLn(green) - 161.1195681661;
        
        if (temp <= 19) {
            blue = 0;
        } else {
            blue = temp - 10;
            blue = 138.5177312231 * qLn(blue) - 305.0447927307;
        }
    } else {
        red = temp - 60;
        red = 329.698727446 * qPow(red, -0.1332047592);
        
        green = temp - 60;
        green = 288.1221695283 * qPow(green, -0.0755148492);
        
        blue = 255;
    }

    QColor newColor(clampDoubleToUint8(red, 0, 255), clampDoubleToUint8(green, 0, 255), clampDoubleToUint8(blue, 0, 255));
    if (m_rgbColor != newColor) {
        m_rgbColor = newColor;
        updateHSB();
        emit rgbColorChanged();
    }
}

void ColorModel::updateHSB()
{
    const auto r = m_rgbColor.redF();
    const auto g = m_rgbColor.greenF();
    const auto b = m_rgbColor.blueF();
    
    const auto max = qMax(qMax(r, g), b);
    const auto min = qMin(qMin(r, g), b);
    const auto delta = max - min;

    hsb newHsb;

    // Calculate brightness
    newHsb.b = qRound(max * 100);
    
    // Calculate saturation
    newHsb.s = max == 0 ? 0 : qRound((delta / max) * 100);
    
    // Calculate hue
    newHsb.h = 0;
    if (delta > 0) {
        if (max == r) {
            newHsb.h = qRound(60.0 * (fmod(((g - b) / delta), 6)));
        } else if (max == g) {
            newHsb.h = qRound(60.0 * (((b - r) / delta) + 2));
        } else {
            newHsb.h = qRound(60.0 * (((r - g) / delta) + 4));
        }
        
        if (newHsb.h < 0) {
            newHsb.h += 360;
        }
    }

    // Update properties if changed
    if (m_hsb != newHsb) {
        m_hsb = newHsb;
        emit hsbChanged();
    }
}
