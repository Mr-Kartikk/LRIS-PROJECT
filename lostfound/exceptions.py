from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status


def _flatten_errors(detail):
    """Recursively convert DRF error detail structures into a single readable string."""
    if isinstance(detail, dict):
        parts = []
        for key, value in detail.items():
            if isinstance(value, (list, tuple)):
                for item in value:
                    if isinstance(item, (dict, list, tuple)):
                        parts.append(f"{key}: {_flatten_errors(item)}")
                    else:
                        parts.append(f"{key}: {str(item)}")
            elif isinstance(value, (dict, list, tuple)):
                parts.append(f"{key}: {_flatten_errors(value)}")
            else:
                parts.append(f"{key}: {str(value)}")
        return '. '.join(parts)
    if isinstance(detail, (list, tuple)):
        parts = []
        for item in detail:
            if isinstance(item, (dict, list, tuple)):
                parts.append(_flatten_errors(item))
            else:
                parts.append(str(item))
        return '. '.join(parts)
    return str(detail)


def custom_exception_handler(exc, context):
    """Custom DRF exception handler that returns errors as a single string.

    Response format:
      {"success": False, "error": "...human readable string..."}
    """
    response = exception_handler(exc, context)

    # If DRF didn't handle the exception, return a generic 500 with the exception string
    if response is None:
        return Response({'success': False, 'error': str(exc)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    # Flatten the default response data into a single string
    error_string = _flatten_errors(response.data)

    return Response({'success': False, 'error': error_string}, status=response.status_code)
