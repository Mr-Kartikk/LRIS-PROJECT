import os
from pathlib import Path
from django.conf import settings

try:
    import aiml
except ImportError:
    aiml = None


class AIMLBot:
    """Simple AIML chatbot wrapper."""

    def __init__(self):
        self.kernel = None
        self._load_kernel()

    def _load_kernel(self):
        # Try to import aiml at runtime in case it wasn't available
        # when the module was first imported (helps when packages
        # are installed after the process started).
        global aiml
        if aiml is None:
            try:
                import importlib
                aiml = importlib.import_module('aiml')
            except Exception:
                return

        self.kernel = aiml.Kernel()
        self.aiml_dir = Path(settings.BASE_DIR) / 'chatbot' / 'aiml'
        self.brain_file = Path(settings.BASE_DIR) / 'chatbot' / 'bot_brain.brn'

        if self.brain_file.exists():
            self.kernel.loadBrain(str(self.brain_file))
        else:
            aiml_files = sorted(self.aiml_dir.glob('*.aiml'))
            for aiml_file in aiml_files:
                self.kernel.learn(str(aiml_file))
            self.kernel.saveBrain(str(self.brain_file))

    def ask(self, text: str) -> str:
        if aiml is None:
            return (
                'AIML library is not installed. Install it in the backend environment with `pip install python-aiml`.'
            )

        if not self.kernel:
            return 'AIML bot is not initialized.'

        return self.kernel.respond(text)


chatbot = AIMLBot()
