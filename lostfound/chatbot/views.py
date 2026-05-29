from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .bot import chatbot


class ChatQueryView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        message = request.data.get('message', '')

        if not isinstance(message, str) or not message.strip():
            return Response(
                {'success': False, 'error': 'The request must include a non-empty `message` field.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        reply = chatbot.ask(message.strip())

        return Response(
            {
                'success': True,
                'message': message.strip(),
                'reply': reply,
            }
        )
