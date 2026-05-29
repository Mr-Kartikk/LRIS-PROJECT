from difflib import SequenceMatcher
from ..models import LostItem, FoundItem, Notification
from django.db.models import Q
from django.utils import timezone


class ItemMatchingService:
    """
    Service to match lost and found items and create notifications
    """

    def __init__(self):
        self.match_threshold = 0.6  # 60% similarity threshold

    def calculate_similarity(self, lost_item, found_item):
        """
        Calculate similarity score between lost and found items
        """
        scores = []
        weights = {
            'title': 0.3,
            'description': 0.2,
            'brand': 0.15,
            'color': 0.15,
            'category': 0.2
        }

        # Title similarity
        if lost_item.title and found_item.title:
            title_score = SequenceMatcher(
                None,
                lost_item.title.lower(),
                found_item.title.lower()
            ).ratio()
            scores.append(title_score * weights['title'])

        # Description similarity
        if lost_item.description and found_item.description:
            desc_score = SequenceMatcher(
                None,
                lost_item.description.lower()[:200],
                found_item.description.lower()[:200]
            ).ratio()
            scores.append(desc_score * weights['description'])

        # Brand match
        if lost_item.brand and found_item.brand:
            brand_match = 1.0 if lost_item.brand.lower() == found_item.brand.lower() else 0.0
            scores.append(brand_match * weights['brand'])

        # Color match
        if lost_item.color and found_item.color:
            color_match = 1.0 if lost_item.color.lower() == found_item.color.lower() else 0.0
            scores.append(color_match * weights['color'])

        # Category match
        if lost_item.category and found_item.category:
            category_match = 1.0 if lost_item.category_id == found_item.category_id else 0.0
            scores.append(category_match * weights['category'])

        # Calculate total score
        total_score = sum(scores) / sum(weights.values()) if scores else 0
        return round(total_score, 2)

    def find_matches_for_lost_item(self, lost_item):
        """
        Find potential matches for a specific lost item
        """
        matches = []

        # Query potential found items
        potential_matches = FoundItem.objects.filter(
            status='pending',
            category=lost_item.category if lost_item.category else None
        ).exclude(user=lost_item.user)

        for found_item in potential_matches:
            score = self.calculate_similarity(lost_item, found_item)
            if score >= self.match_threshold:
                matches.append({
                    'found_item': found_item,
                    'score': score
                })

        # Sort by score descending
        matches.sort(key=lambda x: x['score'], reverse=True)
        return matches

    def find_matches_for_found_item(self, found_item):
        """
        Find potential matches for a specific found item
        """
        matches = []

        # Query potential lost items
        potential_matches = LostItem.objects.filter(
            status='pending',
            category=found_item.category if found_item.category else None
        ).exclude(user=found_item.user)

        for lost_item in potential_matches:
            score = self.calculate_similarity(lost_item, found_item)
            if score >= self.match_threshold:
                matches.append({
                    'lost_item': lost_item,
                    'score': score
                })

        # Sort by score descending
        matches.sort(key=lambda x: x['score'], reverse=True)
        return matches

    def create_match_notifications(self, found_item):
        """
        Create notifications for all potential matches of a found item
        """
        notifications_created = []
        matches = self.find_matches_for_found_item(found_item)

        for match in matches:
            lost_item = match['lost_item']
            score = match['score']

            # Create notification for the lost item owner
            notification = Notification.objects.create(
                user=lost_item.user,
                title="Potential Match Found! 🎯",
                message=f"We found a potential match for your lost item '{lost_item.title}'. "
                        f"A similar item was reported found with {int(score * 100)}% match.",
                notification_type='match',
                lost_item=lost_item,
                found_item=found_item
            )

            notifications_created.append(notification)

        return notifications_created

    def check_for_matches_on_lost_report(self, lost_item):
        """
        Check for matches when a new lost item is reported
        """
        notifications_created = []
        matches = self.find_matches_for_lost_item(lost_item)

        for match in matches:
            found_item = match['found_item']
            score = match['score']

            # Create notification for the lost item owner
            notification = Notification.objects.create(
                user=lost_item.user,
                title="Item Found! 🎉",
                message=f"Good news! A found item matching your '{lost_item.title}' "
                        f"({int(score * 100)}% match) has been reported.",
                notification_type='found_report',
                lost_item=lost_item,
                found_item=found_item
            )

            notifications_created.append(notification)

            # Also notify the finder
            finder_notification = Notification.objects.create(
                user=found_item.user,
                title="Someone Might Be Looking for This!",
                message=f"The lost item '{lost_item.title}' matches an item you found. "
                        f"Check if it belongs to them.",
                notification_type='match',
                lost_item=lost_item,
                found_item=found_item
            )

            notifications_created.append(finder_notification)

        return notifications_created