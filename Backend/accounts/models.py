from decimal import Decimal

from django.contrib.auth.base_user import BaseUserManager
from django.contrib.auth.models import AbstractUser
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class UserManager(BaseUserManager):
    use_in_migrations = True

    def _create_user(self, email, password, **extra_fields):
        if not email:
            raise ValueError("The given email must be set")

        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_user(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", False)
        extra_fields.setdefault("is_superuser", False)
        return self._create_user(email, password, **extra_fields)

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)

        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")

        return self._create_user(email, password, **extra_fields)


class User(AbstractUser):
    username = None

    email = models.EmailField(unique=True)
    email_verified = models.BooleanField(default=False)
    nickname = models.CharField(max_length=20, unique=True)
    profile_image_url = models.TextField(blank=True, null=True)

    trust_score = models.DecimalField(
        max_digits=3,
        decimal_places=1,
        default=Decimal("36.5"),
        validators=[
            MinValueValidator(Decimal("0.0")),
            MaxValueValidator(Decimal("99.9")),
        ],
    )

    penalty_points = models.IntegerField(default=0)
    is_suspended = models.BooleanField(default=False)
    suspended_until = models.DateTimeField(blank=True, null=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["nickname"]

    objects = UserManager()

    def __str__(self):
        return self.email


class EmailVerification(models.Model):
    STATUS_CHOICES = [
        ("PENDING", "PENDING"),
        ("VERIFIED", "VERIFIED"),
        ("EXPIRED", "EXPIRED"),
        ("FAILED", "FAILED"),
    ]

    user = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="email_verifications",
    )
    email = models.EmailField()
    code_hash = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="PENDING")
    expires_at = models.DateTimeField()
    verified_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.email} - {self.status}"