cmake_minimum_required(VERSION 3.16)

project(kelvinToRGB VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appkelvinToRGB
    main.cpp
    ColorModel.h
    ColorModel.cpp
)

qt_add_qml_module(appkelvinToRGB
    URI kelvinToRGB
    VERSION 1.0
    QML_FILES
        Main.qml
        KelvinInput.qml
        KelvinGradient.qml
)

target_link_libraries(appkelvinToRGB
    PRIVATE Qt6::Quick Qt6::QuickControls2
)

include(GNUInstallDirs)
