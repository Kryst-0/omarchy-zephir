# Zephir

Six themed fan designs for the Omarchy bar, with live Linux fan RPM, CPU temperature and rotating English/Italian captions. Click the icon to open; use the arrows to change the model. Captions scroll upward every five seconds while the panel is open.

## Hardware readings

Zephir 1.4.1 reads `/sys/class/hwmon` every two seconds while its panel is open, using Python 3 (standard library only). It displays the fastest exposed fan and prefers CPU temperatures (`coretemp`, `k10temp`, `zenpower`, `cpu_thermal`), then ACPI, then other available temperatures. Within the preferred sensor group it displays the highest reading. Temperature and RPM may come from different devices.

The rotor has three manual animation speeds and a pause/start button. It runs independently of the hardware readings, including on laptops that do not expose fan RPM. Omarchy's disabled animations setting is respected.

**Zephir only reads sensors; its speed buttons control the animation, never the physical fan.** Missing RPM displays “RPM unavailable”; missing temperatures display “unavailable”. Many laptops, including some HP models, expose temperatures without exposing fan RPM. Zephir never estimates RPM from temperature or loads hardware drivers.

No network requests, account, extra Python packages, or persistent background service. Requires a recent Omarchy Quickshell shell with `qs.Ui` and Python 3.

## Install or update

```sh
omarchy plugin add https://github.com/Kryst-0/omarchy-zephir.git --enable
# For an existing git-managed install:
omarchy plugin update krysto.zephir
```

## Remove

```sh
omarchy plugin remove krysto.zephir
```

Escape closes the panel. Sensors and caption timers stop when it closes.

## Validation

```sh
omarchy plugin validate .
python3 -m unittest discover -s tests -v
python3 sensors.py
```

## License

MIT. Copyright (c) 2026 Krysto.
