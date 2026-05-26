import unittest

from catia_assistant.ai_provider import parse_json_object
from catia_assistant.config import AppConfig
from catia_assistant.runner import parse_ok_paths
from catia_assistant.templates import render_template


class CoreTests(unittest.TestCase):
    def test_default_config_is_valid(self):
        cfg = AppConfig()
        cfg.validate()
        self.assertEqual(cfg.drawing.product_name, "MiniDrone.CATProduct")
        self.assertEqual(cfg.explosion.explosion_multiplier, 0.65)

    def test_parse_ok_paths(self):
        paths = parse_ok_paths("OK: C:\\temp\\a.pdf\nWARN: nope\nOK: D:\\b.CATDrawing")
        self.assertEqual(len(paths), 2)
        self.assertEqual(str(paths[0]), "C:\\temp\\a.pdf")

    def test_render_status_template(self):
        text = render_template("status.vbs", {})
        self.assertIn("CATIA.Application", text)

    def test_render_exploded_template_with_scale(self):
        text = render_template(
            "exploded.vbs",
            {
                "PRODUCT_NAME": "MiniDrone.CATProduct",
                "EXPLODED_BASE_NAME": "MiniDrone_exploded_multiview",
                "EXPLOSION_SCALE": 0.55,
            },
        )
        self.assertIn('explosionScale = CDbl("0.55")', text)

    def test_parse_json_object_from_fenced_text(self):
        data = parse_json_object('```json\n{"risks":[]}\n```')
        self.assertEqual(data["risks"], [])


if __name__ == "__main__":
    unittest.main()
