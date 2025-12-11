from django.db import models
from django.contrib.auth.models import User

class Movie(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='movies')
    title = models.CharField(max_length=250)
    year = models.IntegerField()
    description = models.TextField(max_length=1000)
    rating = models.FloatField(null=True, blank=True)
    ranking = models.IntegerField(null=True, blank=True)
    review = models.TextField(max_length=250, null=True, blank=True)
    img_url = models.URLField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-rating']
        unique_together = ['user', 'title']  # Users can't have duplicate movie titles

    def __str__(self):
        return f"{self.title} ({self.year}) - {self.user.username}"