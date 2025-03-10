#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "ColorModel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Set the style to Fusion which supports customization
    QQuickStyle::setStyle("Fusion");

    ColorModel colorModel;
    
    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    
    engine.rootContext()->setContextProperty("colorModel", &colorModel);
    engine.loadFromModule("kelvinToRGB", "Main");

    return app.exec();
}
