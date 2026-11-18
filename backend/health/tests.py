from unittest.mock import patch

from django.db import OperationalError, connection
from django.test import SimpleTestCase, TestCase, override_settings
from django.urls import reverse


class HealthTests(SimpleTestCase):
    def test_healthy_database(self):
        with patch("health.views.connection") as database:
            response = self.client.get(reverse("health"))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {"status": "ok", "database": "ok"})
        self.assertEqual(response["Cache-Control"], "no-store")
        database.cursor.return_value.__enter__.return_value.execute.assert_called_once_with(
            "SELECT 1"
        )

    def test_unavailable_database_does_not_expose_error(self):
        with patch("health.views.connection") as database:
            database.cursor.side_effect = OperationalError("secret-host:password")
            response = self.client.get(reverse("health"))
        self.assertEqual(response.status_code, 503)
        self.assertEqual(
            response.json(), {"status": "unavailable", "database": "unavailable"}
        )
        self.assertNotIn("secret", response.content.decode())
        self.assertEqual(response["Cache-Control"], "no-store")

    @override_settings(CORS_ALLOWED_ORIGINS=["http://localhost:8000"])
    def test_allowed_origin_receives_cors_header(self):
        with patch("health.views.connection"):
            response = self.client.get(
                reverse("health"), HTTP_ORIGIN="http://localhost:8000"
            )
        self.assertEqual(response["Access-Control-Allow-Origin"], "http://localhost:8000")
        self.assertNotIn("Access-Control-Allow-Credentials", response)

    @override_settings(CORS_ALLOWED_ORIGINS=["http://localhost:8000"])
    def test_unknown_origin_has_no_cors_permission(self):
        with patch("health.views.connection"):
            response = self.client.get(
                reverse("health"), HTTP_ORIGIN="https://unknown.example"
            )
        self.assertNotIn("Access-Control-Allow-Origin", response)

    @override_settings(CORS_ALLOWED_ORIGINS=["http://localhost:8000"])
    def test_cors_preflight(self):
        response = self.client.options(
            reverse("health"),
            HTTP_ORIGIN="http://localhost:8000",
            HTTP_ACCESS_CONTROL_REQUEST_METHOD="GET",
            HTTP_ACCESS_CONTROL_REQUEST_HEADERS="content-type",
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response["Access-Control-Allow-Origin"], "http://localhost:8000")
        self.assertIn("GET", response["Access-Control-Allow-Methods"])

    def test_post_is_not_allowed(self):
        self.assertEqual(self.client.post(reverse("health")).status_code, 405)


class PostgresHealthTests(TestCase):
    def test_real_database_connection(self):
        self.assertEqual(connection.vendor, "postgresql")
        response = self.client.get(reverse("health"))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {"status": "ok", "database": "ok"})
