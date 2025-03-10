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
    explicit ColorModel(QObject *parent = nullptr);
    
    QColor rgbColor() const;
    int kelvin() const;
    int hue() const;
    int saturation() const;
    int brightness() const;
    QString hexColor() const;
    
public slots:
    void setKelvin(int kelvin);
    
signals:
    void rgbColorChanged();
    void kelvinChanged();
    void hsbChanged();
    
private:
    void updateRgbColor();
    void updateHSB();
    double clamp(double x, double min, double max);
    
    int m_kelvin = 6500; // Default to a neutral white
    QColor m_rgbColor;
    int m_hue = 0;
    int m_saturation = 0;
    int m_brightness = 0;
};

#endif // COLORMODEL_H
