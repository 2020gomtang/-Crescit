from django.conf import settings
from django.core.validators import MinValueValidator
from django.db import models

from trips.models import Trip


class PaymentChannel(models.Model):
    trip = models.OneToOneField(
        Trip,
        on_delete=models.CASCADE,
        related_name="payment_channel",
    )
    kakaopay_link = models.TextField(blank=True, null=True)
    updated_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="payment_channels_updated",
    )
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"PaymentChannel for Trip {self.trip_id}"


class Receipt(models.Model):
    STATUS_CHOICES = [
        ("PENDING", "PENDING"),
        ("CONFIRMED", "CONFIRMED"),
    ]

    trip = models.OneToOneField(
        Trip,
        on_delete=models.CASCADE,
        related_name="receipt",
    )
    uploaded_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="receipts_uploaded",
    )
    image_url = models.TextField()
    total_amount = models.IntegerField(validators=[MinValueValidator(0)])
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="PENDING")
    confirmed_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Receipt for Trip {self.trip_id}"


class Settlement(models.Model):
    STATUS_CHOICES = [
        ("REQUESTED", "REQUESTED"),
        ("PAID_SELF", "PAID_SELF"),
        ("CONFIRMED", "CONFIRMED"),
        ("DISPUTED", "DISPUTED"),
        ("OVERDUE", "OVERDUE"),
        ("CANCELED", "CANCELED"),
    ]

    trip = models.ForeignKey(
        Trip,
        on_delete=models.CASCADE,
        related_name="settlements",
    )
    receipt = models.ForeignKey(
        Receipt,
        on_delete=models.CASCADE,
        related_name="settlements",
    )
    payer_user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="settlements_to_pay",
    )
    payee_user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="settlements_to_receive",
    )
    share_amount = models.IntegerField(validators=[MinValueValidator(0)])
    memo_code = models.CharField(max_length=20, blank=True, null=True)

    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="REQUESTED")
    requested_at = models.DateTimeField(auto_now_add=True)
    paid_self_at = models.DateTimeField(blank=True, null=True)
    confirmed_at = models.DateTimeField(blank=True, null=True)
    due_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["receipt", "payer_user"],
                name="unique_receipt_payer_settlement",
            )
        ]

    def __str__(self):
        return f"Settlement {self.id}"


class SettlementProof(models.Model):
    settlement = models.ForeignKey(
        Settlement,
        on_delete=models.CASCADE,
        related_name="proofs",
    )
    uploaded_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="settlement_proofs_uploaded",
    )
    image_url = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Proof for Settlement {self.settlement_id}"