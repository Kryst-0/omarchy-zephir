import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('zephir_sensors', Path(__file__).resolve().parents[1] / 'sensors.py')
sensors = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sensors)


class SensorsTest(unittest.TestCase):
    def setUp(self):
        self.folder = tempfile.TemporaryDirectory()
        self.addCleanup(self.folder.cleanup)
        self.base = Path(self.folder.name)

    def device(self, index, **files):
        folder = self.base / f'hwmon{index}'
        folder.mkdir()
        for name, value in files.items():
            (folder / name).write_text(str(value))
        return folder

    def test_cpu_temperature_preferred_over_hot_disk(self):
        self.device(0, name='nvme', temp1_input=85000)
        self.device(1, name='coretemp', temp1_input=54000, temp2_input=57000)
        self.assertEqual(sensors.sample(self.base), {'rpm': None, 'temperature': 57.0})

    def test_fastest_fan_and_stopped_fan(self):
        fan = self.device(0, name='test', fan1_input=0, fan2_input=2400)
        self.assertEqual(sensors.sample(self.base)['rpm'], 2400)
        (fan / 'fan2_input').unlink()
        self.assertEqual(sensors.sample(self.base)['rpm'], 0)
        (fan / 'fan1_input').unlink()
        self.assertIsNone(sensors.sample(self.base)['rpm'])

    def test_invalid_and_out_of_range_values(self):
        self.device(0, name='test', fan1_input='bad', fan2_input=-1, fan3_input=100001,
                    temp1_input='bad', temp2_input=999999)
        self.assertEqual(sensors.sample(self.base), {'rpm': None, 'temperature': None})

    def test_missing_sensors_and_temperature_fallback(self):
        self.assertEqual(sensors.sample(self.base), {'rpm': None, 'temperature': None})
        self.device(0, name='acpitz', temp1_input=42000)
        self.assertEqual(sensors.sample(self.base)['temperature'], 42.0)


if __name__ == '__main__':
    unittest.main()
