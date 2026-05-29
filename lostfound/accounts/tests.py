from django.test import TestCase
from rest_framework.test import APIClient
from django.urls import reverse


class RegistrationTests(TestCase):
	def setUp(self):
		self.client = APIClient()
		self.url = reverse('register')

	def test_register_success(self):
		payload = {
			'phone_number': '+919999999999',
			'full_name': 'Test User',
			'password': 'Aa123456!',
			'confirm_password': 'Aa123456!'
		}
		response = self.client.post(self.url, payload, format='json')
		self.assertEqual(response.status_code, 201)
		self.assertIn('token', response.data)
		self.assertTrue(response.data.get('success'))

	def test_register_duplicate(self):
		payload = {
			'phone_number': '+919999999999',
			'full_name': 'Test User',
			'password': 'Aa123456!',
			'confirm_password': 'Aa123456!'
		}
		# First registration
		r1 = self.client.post(self.url, payload, format='json')
		self.assertEqual(r1.status_code, 201)

		# Duplicate registration should return 400 and error string
		r2 = self.client.post(self.url, payload, format='json')
		self.assertEqual(r2.status_code, 400)
		self.assertFalse(r2.data.get('success', True))
		self.assertIsInstance(r2.data.get('error'), str)
