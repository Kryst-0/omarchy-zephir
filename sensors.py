"""Read Linux hwmon sensors without changing fan controls or loading drivers."""
import json
from pathlib import Path


def read_number(path, minimum, maximum):
    try:
        raw = path.read_text()[:64].strip()
        value = int(raw)
        return value if minimum <= value <= maximum else None
    except (OSError, ValueError):
        return None


def sample(base=Path('/sys/class/hwmon')):
    fans = []
    temperatures = []
    for device in sorted(base.glob('hwmon*'))[:128]:
        try:
            name = (device / 'name').read_text()[:128].strip().lower()
        except OSError:
            name = ''
        for path in sorted(device.glob('fan*_input'))[:32]:
            value = read_number(path, 0, 100000)
            if value is not None:
                fans.append(value)
        for path in sorted(device.glob('temp*_input'))[:64]:
            value = read_number(path, -20000, 150000)
            if value is not None:
                # Prefer the CPU package/core sensor over disks and ambient sensors.
                priority = 0 if name in ('coretemp', 'k10temp', 'zenpower', 'cpu_thermal') else 1 if name == 'acpitz' else 2
                temperatures.append((priority, value / 1000))
    best_priority = min((priority for priority, _ in temperatures), default=None)
    return {
        'rpm': max(fans) if fans else None,
        'temperature': max((value for priority, value in temperatures if priority == best_priority), default=None),
    }


if __name__ == '__main__':
    print(json.dumps(sample(), allow_nan=False))
