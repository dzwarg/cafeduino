# Caféduino

A coffee maker assistant, using the Arduino platform and Pachube.com to detect
the state of the coffee maker. Originally installed in the offices of [Azavea](http://www.azavea.com/)

## Requirements

An [Arduino](http://www.arduino.cc/) with an ethernet shield, and a Pachube.com
account. The Arduino configuration:

 * Pin 2: tare button
 * Pin 3: full button
 * Pin 4: piezo 2
 * Pin 5: piezo 1
 * Pin 6: led 1
 * Pin 9: led 2
 * Pin 10: led3

The ethernet shield configuration:

 * MAC Address: 0xDEADBEEFBABE
 * IP Address: 192.168.1.96
 * Gateway: 192.168.1.1
 * Subnet: 255.255.255.0
 * Pachube.com: 209.40.205.190
 
Coffee Maker:

 * [Zojirushi EC-BD15BAFresh Brew Thermal Carafe Coffee Maker](http://www.amazon.com/Zojirushi-EC-BD15BAFresh-Thermal-Carafe-Coffee/dp/B0000X7CMQ)

## Usage

This sketch was accompanied by a platform and encloser upon which the coffee
maker sat upon, and plugged into the wired ethernet network.

The system worked by measuring the weight distribution of the coffee maker. With a fulcrum installed between the carafe and the reservoir, it was possible to measure the following:

 * Force of an empty pot of coffee & and empty reservoir
 * Force of a full reservoir and an empty carafe
 * Force of a full carafe and an empty reservoir
 
With these points of reference, the automated systems to interrogate the coffee maker could determine the volume of coffee, and where it was in the brewing cycle.

## Diagrams

In this repository are a few diagrams/sketches that I made while building this widget:

 * [Sketch #1](https://raw.github.com/dzwarg/cafeduino/master/idea_sketch_1.jpg): An initial diagram with a force sensor and ideas about what kind of HTTP response I would expect.
 * [Sketch #2](https://raw.github.com/dzwarg/cafeduino/master/idea_sketch_2.jpg): A secondary sketch, using a fulcrum and two piezo sensors, closely resembling the actual wiring in the platform.
 * [Wiring](https://raw.github.com/dzwarg/cafeduino/master/wiring.jpg): A wiring diagram with digital input (DIx), digital output (DOx), and analog input (AIx) leads notated.
