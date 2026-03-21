from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

from .models import User, EmailVerification


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    model = User
    ordering = ("id",)
    list_display = (
        "id",
        "email",
        "nickname",
        "email_verified",
        "trust_score",
        "penalty_points",
        "is_suspended",
        "is_staff",
        "is_superuser",
    )
    list_filter = (
        "email_verified",
        "is_suspended",
        "is_staff",
        "is_superuser",
    )
    search_fields = ("email", "nickname")

    fieldsets = (
        (None, {"fields": ("email", "password")}),
        ("Profile", {"fields": ("nickname", "profile_image_url")}),
        (
            "Status",
            {
                "fields": (
                    "email_verified",
                    "trust_score",
                    "penalty_points",
                    "is_suspended",
                    "suspended_until",
                )
            },
        ),
        (
            "Permissions",
            {
                "fields": (
                    "is_active",
                    "is_staff",
                    "is_superuser",
                    "groups",
                    "user_permissions",
                )
            },
        ),
        ("Important dates", {"fields": ("last_login", "created_at", "updated_at")}),
    )

    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": (
                    "email",
                    "nickname",
                    "password1",
                    "password2",
                    "is_staff",
                    "is_superuser",
                ),
            },
        ),
    )

    readonly_fields = ("created_at", "updated_at")


@admin.register(EmailVerification)
class EmailVerificationAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "email",
        "user",
        "status",
        "expires_at",
        "verified_at",
        "created_at",
    )
    list_filter = ("status",)
    search_fields = ("email",)