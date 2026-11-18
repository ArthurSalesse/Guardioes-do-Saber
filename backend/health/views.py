import logging

from django.db import DatabaseError, connection
from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response

logger = logging.getLogger(__name__)


@api_view(["GET"])
@authentication_classes([])
@permission_classes([AllowAny])
def health(request):
    """Readiness público: confirma acesso ao banco sem expor seus dados."""
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
    except DatabaseError:
        logger.warning("Health check: banco indisponível")
        response = Response(
            {"status": "unavailable", "database": "unavailable"}, status=503
        )
    else:
        response = Response({"status": "ok", "database": "ok"})
    response["Cache-Control"] = "no-store"
    return response
