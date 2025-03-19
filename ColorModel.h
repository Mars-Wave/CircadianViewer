#ifndef COLORMODEL_H
#define COLORMODEL_H

#include <QObject>
#include <QColor>

class ColorModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor rgbColor READ rgbColor NOTIFY rgbColorChanged)
    Q_PROPERTY(int kelvin READ kelvin WRITE setKelvin NOTIFY kelvinChanged)
    Q_PROPERTY(int hue READ hue NOTIFY hsbChanged)
    Q_PROPERTY(int saturation READ saturation NOTIFY hsbChanged)
    Q_PROPERTY(int brightness READ brightness NOTIFY hsbChanged)
    Q_PROPERTY(QString hexColor READ hexColor NOTIFY rgbColorChanged)
    
public:
    explicit inline ColorModel(QObject *parent = nullptr) : QObject(parent) { updateRgbColor(); }

    QColor   inline rgbColor()   const { return m_rgbColor; }
    uint16_t inline kelvin()     const { return m_kelvin; }
    uint16_t inline hue()        const { return m_hsb.h; }
    uint16_t inline saturation() const { return m_hsb.s; }
    uint16_t inline brightness() const { return m_hsb.b; }
    QString  inline hexColor()   const { return m_rgbColor.name(QColor::HexRgb).toUpper(); }

public slots:
    void setKelvin(uint16_t kelvin);
    
signals:
    void rgbColorChanged();
    void kelvinChanged();
    void hsbChanged();
    
private:
    void updateRgbColor();
    void updateHSB();

    struct hsb {
        uint8_t h = 0;
        uint8_t s = 0;
        uint8_t b = 0;
        inline bool operator!=(const hsb& rhs) {
            return h != rhs.h || s != rhs.s || b != rhs.b;
        }
    };

    uint16_t m_kelvin =  6500; // Default is a neutral white
    QColor m_rgbColor = {0,0,0};
    hsb m_hsb         = {0,0,0};
};

#endif // COLORMODEL_H
