from django.contrib import admin

from .models import ChatRoom, ChatMessage


@admin.register(ChatRoom)
class ChatRoomAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "trip",
        "created_at",
    )
    search_fields = ("trip__depart_name", "trip__arrive_name")


@admin.register(ChatMessage)
class ChatMessageAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "room",
        "sender_user",
        "sent_at",
    )
    search_fields = (
        "sender_user__email",
        "sender_user__nickname",
        "room__trip__depart_name",
        "room__trip__arrive_name",
    )