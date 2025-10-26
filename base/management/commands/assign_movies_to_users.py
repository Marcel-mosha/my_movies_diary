from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from base.models import Movie  # Changed from base.models to movies.models

class Command(BaseCommand):
    help = 'Assign existing movies to a specific user'

    def add_arguments(self, parser):
        parser.add_argument(
            '--username',
            type=str,
            help='Username of the user to assign movies to',
            required=True
        )

    def handle(self, *args, **options):
        username = options['username']
        
        try:
            # Get the specific user
            user = User.objects.get(username=username)
            self.stdout.write(self.style.SUCCESS(f'Found user: {user.username}'))
            
            # Assign movies without user to this specific user
            movies_without_user = Movie.objects.filter(user__isnull=True)
            count = movies_without_user.update(user=user)
            
            self.stdout.write(
                self.style.SUCCESS(f'Successfully assigned {count} movies to user: {user.username}')
            )
            
        except User.DoesNotExist:
            self.stdout.write(
                self.style.ERROR(f'User with username "{username}" does not exist.')
            )
            self.stdout.write(
                self.style.WARNING('Available users: ' + 
                                ', '.join(User.objects.values_list('username', flat=True)))
            )