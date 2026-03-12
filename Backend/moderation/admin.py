from django.contrib import admin

from .models import Review, Penalty, Report


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "trip",
        "from_user",
        "to_user",
        "rating",
        "created_at",
    )
    search_fields = (
        "from_user__email",
        "to_user__email",
        "from_user__nickname",
        "to_user__nickname",
    )


@admin.register(Penalty)
class PenaltyAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "user",
        "trip",
        "type",
        "points",
        "created_at",
    )
    search_fields = ("user__email", "user__nickname", "type")


@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "trip",
        "reporter_user",
        "reported_user",
        "reason",
        "status",
        "created_at",
    )
    list_filter = ("status",)
    search_fields = (
        "reporter_user__email",
        "reported_user__email",
        "reason",
    )