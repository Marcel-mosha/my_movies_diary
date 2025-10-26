from django import forms
from .models import Movie

class MovieForm(forms.ModelForm):
    class Meta:
        model = Movie
        fields = ['rating', 'review']
        widgets = {
            'rating': forms.NumberInput(attrs={
                'class': 'form-control',
                'placeholder': 'Your rating out of 10 e.g 7.5',
                'step': '0.1',
                'min': '0',
                'max': '10'
            }),
            'review': forms.Textarea(attrs={
                'class': 'form-control',
                'placeholder': 'Your review',
                'rows': 3
            }),
        }

class AddMovieForm(forms.Form):
    title = forms.CharField(
        max_length=250,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'Movie Title'
        })
    )