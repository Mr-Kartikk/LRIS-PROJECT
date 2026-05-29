import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'lostfound.settings')
django.setup()

from items.models import Category

categories = [
    {'name': 'Electronics', 'icon': 'phone_android', 'description': 'Mobile phones, laptops, tablets, cameras, etc.'},
    {'name': 'Documents', 'icon': 'description', 'description': 'ID cards, passports, certificates, etc.'},
    {'name': 'Wallets & Purses', 'icon': 'account_balance_wallet', 'description': 'Wallets, purses, money bags'},
    {'name': 'Keys', 'icon': 'vpn_key', 'description': 'House keys, car keys, lockers'},
    {'name': 'Jewelry', 'icon': 'diamond', 'description': 'Rings, necklaces, bracelets, watches'},
    {'name': 'Clothing', 'icon': 'checkroom', 'description': 'Jackets, shirts, bags, shoes'},
    {'name': 'Eyewear', 'icon': 'visibility', 'description': 'Glasses, sunglasses, contact lenses'},
    {'name': 'Accessories', 'icon': 'watch', 'description': 'Watches, hats, scarves, belts'},
    {'name': 'Books', 'icon': 'menu_book', 'description': 'Books, notebooks, magazines'},
    {'name': 'Toys', 'icon': 'toys', 'description': 'Toys, stuffed animals, games'},
    {'name': 'Sports', 'icon': 'sports', 'description': 'Sports equipment, gear, accessories'},
    {'name': 'Other', 'icon': 'category', 'description': 'Other items'},
]

for cat in categories:
    Category.objects.get_or_create(
        name=cat['name'],
        defaults={
            'icon': cat['icon'],
            'description': cat['description']
        }
    )
    print(f"Created category: {cat['name']}")

print("✅ Categories populated successfully!")