from django.contrib import admin

from .models import PaymentChannel, Receipt, Settlement, SettlementProof


@admin.register(PaymentChannel)
class PaymentChannelAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "trip",
        "updated_by",
        "updated_at",
    )
    search_fields = ("trip__depart_name", "trip__arrive_name", "updated_by__email")


@admin.register(Receipt)
class ReceiptAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "trip",
        "uploaded_by",
        "total_amount",
        "status",
        "confirmed_at",
        "created_at",
    )
    list_filter = ("status",)
    search_fields = ("trip__depart_name", "trip__arrive_name", "uploaded_by__email")


@admin.register(Settlement)
class SettlementAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "trip",
        "receipt",
        "payer_user",
        "payee_user",
        "share_amount",
        "status",
        "requested_at",
        "confirmed_at",
        "due_at",
    )
    list_filter = ("status",)
    search_fields = (
        "payer_user__email",
        "payee_user__email",
        "trip__depart_name",
        "trip__arrive_name",
    )


@admin.register(SettlementProof)
class SettlementProofAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "settlement",
        "uploaded_by",
        "created_at",
    )
    search_fields = ("uploaded_by__email",)