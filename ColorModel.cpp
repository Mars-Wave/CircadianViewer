#include "ColorModel.h"
#include <QtMath>

ColorModel::ColorModel(QObject *parent) : QObject(parent)
{
    updateRgbColor();
}

QColor ColorModel::rgbColor() const
{
    return m_rgbColor;
}

int ColorModel::kelvin() const
{
    return m_kelvin;
}

int ColorModel::hue() const
{
    return m_hue;
}

int ColorModel::saturation() const
{
    return m_saturation;
}

int ColorModel::brightness() const
{
    return m_brightness;
}

QString ColorModel::hexColor() const
{
    return m_rgbColor.name(QColor::HexRgb).toUpper();
}

void ColorModel::setKelvin(int kelvin)
{
    if (m_kelvin != kelvin) {
        m_kelvin = kelvin;
        updateRgbColor();
        emit kelvinChanged();
    }
}

void ColorModel::updateRgbColor()
{
    double temp = m_kelvin / 100.0;
    double red, green, blue;

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

    int r = clamp(red, 0, 255);
    int g = clamp(green, 0, 255);
    int b = clamp(blue, 0, 255);
    
    QColor newColor(r, g, b);
    if (m_rgbColor != newColor) {
        m_rgbColor = newColor;
        updateHSB();
        emit rgbColorChanged();
    }
}

void ColorModel::updateHSB()
{
    double r = m_rgbColor.redF();
    double g = m_rgbColor.greenF();
    double b = m_rgbColor.blueF();
    
    double max = qMax(qMax(r, g), b);
    double min = qMin(qMin(r, g), b);
    double delta = max - min;
    
    // Calculate brightness
    int newBrightness = qRound(max * 100);
    
    // Calculate saturation
    int newSaturation = max == 0 ? 0 : qRound((delta / max) * 100);
    
    // Calculate hue
    int newHue = 0;
    if (delta > 0) {
        if (max == r) {
            newHue = qRound(60.0 * (fmod(((g - b) / delta), 6)));
        } else if (max == g) {
            newHue = qRound(60.0 * (((b - r) / delta) + 2));
        } else {
            newHue = qRound(60.0 * (((r - g) / delta) + 4));
        }
        
        if (newHue < 0) {
            newHue += 360;
        }
    }
    
    // Update properties if changed
    bool changed = false;
    if (m_hue != newHue) {
        m_hue = newHue;
        changed = true;
    }
    if (m_saturation != newSaturation) {
        m_saturation = newSaturation;
        changed = true;
    }
    if (m_brightness != newBrightness) {
        m_brightness = newBrightness;
        changed = true;
    }
    
    if (changed) {
        emit hsbChanged();
    }
}

double ColorModel::clamp(double x, double min, double max)
{
    if (x < min) return min;
    if (x > max) return max;
    return x;
}
