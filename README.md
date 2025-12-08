# 🎬 My Movies Diary

A modern, full-stack movie diary application with a beautiful React frontend and powerful Django REST API backend. Track your favorite movies, rate them, write reviews, and discover new films through seamless TMDB integration.

![React](https://img.shields.io/badge/React-18.3.1-61DAFB?logo=react) ![Django](https://img.shields.io/badge/Django-5.2.7-092E20?logo=django) ![DRF](https://img.shields.io/badge/DRF-3.15.2-red?logo=django) ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-4169E1?logo=postgresql) ![Vite](https://img.shields.io/badge/Vite-6.0.3-646CFF?logo=vite)

## ✨ Features

### 🎬 Core Functionality
- **JWT Authentication** - Secure token-based registration, login, and logout
- **TMDB Integration** - Search and add movies from The Movie Database
- **Rate & Review** - Personal ratings (0-10) and detailed reviews
- **Full CRUD Operations** - Create, read, update, and delete movies
- **Automatic Ranking** - Movies ranked automatically by your ratings
- **User-Specific Collections** - Private movie diary for each user

### 🎨 Modern UI/UX
- **Professional Design** - Gradient themes and smooth animations
- **Fully Responsive** - Desktop (1400px), Tablet (1024px), Mobile (768px), Small (480px)
- **Dark Theme** - Emerald green and purple gradients on dark slate background
- **Movie Posters** - High-quality, fully visible images (450px on home, 400px in search, 500px in edit)
- **Sticky Navigation** - Backdrop blur effect with gradient logo
- **Interactive Cards** - Hover animations, shadows, and transformations
- **Smooth Transitions** - All interactions feel fluid and professional

### 🔒 Security
- **JWT Tokens** - Access tokens (5h lifetime), Refresh tokens (7d lifetime)
- **Protected Routes** - Automatic redirect for unauthorized users
- **Auto Token Refresh** - Seamless experience with automatic renewal
- **CORS Configured** - Secure cross-origin resource sharing

## 🏗️ Architecture

### Project Structure
```
my_movies_diary/
├── base/                    # Django app
│   ├── api_views.py        # REST API viewsets
│   ├── api_urls.py         # API routing
│   ├── serializers.py      # DRF serializers
│   ├── models.py           # Database models
│   └── management/         # Custom commands
├── my_movies_diary/        # Django settings
│   ├── settings.py         # DRF + JWT + CORS config
│   └── urls.py             # Main URL routing
├── frontend/               # React application
│   ├── src/
│   │   ├── components/    # Navbar, Footer, MovieCard, PrivateRoute
│   │   ├── pages/         # Home, Login, Register, AddMovie, EditMovie
│   │   ├── context/       # AuthContext for global auth state
│   │   ├── services/      # API client with interceptors
│   │   ├── App.jsx        # Main app with routing
│   │   └── App.css        # Modern professional styling
│   ├── index.html         # HTML with movie icon
│   ├── package.json       # Dependencies
│   └── vite.config.js     # Vite config
├── .env                   # Environment variables
└── requirements.txt       # Python dependencies
```

## 🚀 Technology Stack

### Backend
- **Django 5.2.7** - Python web framework
- **Django REST Framework 3.15.2** - RESTful API toolkit
- **Simple JWT 5.4.0** - JWT authentication
- **Django CORS Headers 4.6.0** - CORS support
- **PostgreSQL** - Production database
- **Requests 2.32.5** - TMDB API integration

### Frontend
- **React 18.3.1** - UI library
- **React Router DOM 6.28.0** - Client-side routing
- **Axios 1.7.9** - HTTP client with interceptors
- **Vite 6.0.3** - Build tool and dev server

### External APIs
- **TMDB API** - Movie data and poster images

## 📋 Prerequisites

- **Python 3.8+**
- **Node.js 18+**
- **PostgreSQL**
- **TMDB API Key** (free from [themoviedb.org](https://www.themoviedb.org/settings/api))

## 🛠️ Installation & Setup

### Backend Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/Marcel-mosha/my_movies_diary.git
   cd my_movies_diary
   ```

2. **Create and activate virtual environment**

   ```bash
   python -m venv venv

   # Windows
   venv\Scripts\activate

   # macOS/Linux
   source venv/bin/activate
   ```

3. **Install Python dependencies**

   ```bash
   pip install -r requirements.txt
   ```

4. **Set up PostgreSQL database**

   ```sql
   CREATE DATABASE movie_diary;
   CREATE USER movie_user WITH PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE movie_diary TO movie_user;
   ```

5. **Configure environment variables**

   Create a `.env` file in the project root:

   ```env
   SECRET_KEY=your_django_secret_key
   DEBUG=True
   DB_NAME=movie_diary
   DB_USER=movie_user
   DB_PASSWORD=your_password
   DB_HOST=localhost
   DB_PORT=5432
   TMDB_API_KEY=your_tmdb_api_key
   ```

6. **Run migrations**

   ```bash
   python manage.py migrate
   ```

7. **Create superuser (optional)**

   ```bash
   python manage.py createsuperuser
   ```

8. **Start Django server**

   ```bash
   python manage.py runserver
   ```

   Backend will run on `http://localhost:8000`

### Frontend Setup

1. **Navigate to frontend directory**

   ```bash
   cd frontend
   ```

2. **Install Node dependencies**

   ```bash
   npm install
   ```

3. **Start development server**

   ```bash
   npm run dev
   ```

   Frontend will run on `http://localhost:5173`

4. **Access the application**

   Open your browser and navigate to: `http://localhost:5173`

## 📡 API Endpoints

### Authentication

- `POST /api/register/` - Register new user
  ```json
  {
    "username": "string",
    "email": "string",
    "password": "string",
    "password2": "string"
  }
  ```

- `POST /api/login/` - Login user
  ```json
  {
    "username": "string",
    "password": "string"
  }
  ```
  Returns: `{ "access": "token", "refresh": "token" }`

- `POST /api/token/refresh/` - Refresh access token
  ```json
  {
    "refresh": "token"
  }
  ```

- `GET /api/user/` - Get current user info (requires auth)

### Movies

- `GET /api/movies/` - List all movies for authenticated user
- `GET /api/movies/{id}/` - Get specific movie details
- `POST /api/movies/` - Create new movie
  ```json
  {
    "title": "string",
    "year": "string",
    "description": "string",
    "img_url": "string",
    "rating": 0.0,
    "review": "string"
  }
  ```
- `PATCH /api/movies/{id}/` - Update movie rating/review
- `DELETE /api/movies/{id}/` - Delete movie

### TMDB Integration

- `GET /api/movies/search_tmdb/?query=<movie_title>` - Search TMDB
- `GET /api/movies/fetch_tmdb_details/?movie_id=<tmdb_id>` - Get movie details

## 🎯 Usage

### Getting Started

1. **Register**: Create your account at `/register`
2. **Login**: Sign in at `/login`
3. **Add Movies**: Click "Add Movie" to search TMDB
4. **Rate & Review**: Select a movie, add your rating (0-10) and review
5. **View Collection**: Your movies appear ranked on the home page
6. **Edit/Delete**: Manage your ratings and reviews anytime

### Features in Action

- **Automatic Ranking**: Movies are automatically ranked based on your ratings
- **Real-time Updates**: Changes reflect immediately without page refresh
- **User-Specific Collections**: Each user has their own private movie list
- **TMDB Integration**: Search from millions of movies with posters and details
- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices

## 🎨 Design Highlights

### Color Palette

- **Primary**: Emerald Green (#10b981) - Main actions and highlights
- **Accent**: Purple (#8b5cf6) - Secondary actions and accents
- **Gradients**: Dynamic color transitions throughout the UI
- **Shadows**: Multi-layered shadows for depth (emerald, purple, black)

### Movie Poster Display

- **Home Page**: 450px height - Full poster visibility with hover effects
- **Search Results**: 400px height - Grid layout with select buttons
- **Edit Page**: 500px height - Large preview for rating/review

### Responsive Breakpoints

- **Desktop**: 1024px+ (3-column grid)
- **Tablet**: 768px-1024px (2-column grid)
- **Mobile**: <768px (single column, optimized navigation)

### UI Components

- **Glass-morphism**: Frosted glass effects on navbar and footer
- **Animations**: Smooth transitions, hover effects, and fade-ins
- **Loading States**: Visual feedback during data fetching
- **Error Handling**: User-friendly error messages throughout

## 🔧 Configuration

### Database Settings

The project uses PostgreSQL with configuration from environment variables. Edit `.env`:

```env
DB_NAME=movie_diary
DB_USER=movie_user
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
```

For other databases, modify `my_movies_diary/settings.py`:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('DB_NAME', 'movie_diary'),
        'USER': os.getenv('DB_USER', 'movie_user'),
        'PASSWORD': os.getenv('DB_PASSWORD'),
        'HOST': os.getenv('DB_HOST', 'localhost'),
        'PORT': os.getenv('DB_PORT', '5432'),
    }
}
```

### TMDB API Setup

1. Register at [themoviedb.org](https://www.themoviedb.org/)
2. Go to Settings → API → Request an API Key
3. Add to your `.env` file: `TMDB_API_KEY=your_api_key_here`

### CORS Configuration

Frontend (localhost:5173) is pre-configured in `settings.py`:

```python
CORS_ALLOWED_ORIGINS = [
    "http://localhost:5173",
    "http://localhost:3000",
]
```

Add production URLs when deploying.

### JWT Token Settings

Token lifetimes configured in `settings.py`:

```python
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(hours=5),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
}
```

## 📊 Database Models

### Movie Model

```python
class Movie(models.Model):
    title = models.CharField(max_length=250)
    year = models.CharField(max_length=10)
    description = models.TextField()
    rating = models.FloatField(default=0.0, null=True, blank=True)
    ranking = models.IntegerField(default=0, null=True, blank=True)
    review = models.TextField(null=True, blank=True)
    img_url = models.URLField(max_length=500)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
```

**Fields:**
- `title`: Movie title (max 250 chars)
- `year`: Release year
- `description`: Plot summary
- `rating`: User rating 0.0-10.0 (optional)
- `ranking`: Auto-calculated position (updated on save)
- `review`: User review text (optional)
- `img_url`: TMDB poster URL
- `user`: Owner (Foreign Key to User model)

## 🛠️ Development Notes

### API Response Format

The `MovieViewSet.create()` method returns the full `MovieSerializer` data including the `id` field, ensuring the frontend can navigate to the edit page immediately after movie creation.

```python
def create(self, request, *args, **kwargs):
    serializer = self.get_serializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    movie = serializer.save()
    headers = self.get_success_headers(serializer.data)
    return Response(MovieSerializer(movie).data, status=status.HTTP_201_CREATED, headers=headers)
```

### Axios Interceptors

The frontend uses response interceptors to automatically refresh JWT tokens on 401 errors:

```javascript
api.interceptors.response.use(
  response => response,
  async error => {
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      const refreshToken = localStorage.getItem('refreshToken');
      const { data } = await api.post('/token/refresh/', { refresh: refreshToken });
      localStorage.setItem('accessToken', data.access);
      return api(originalRequest);
    }
    return Promise.reject(error);
  }
);
```

### Movie Ranking System

Rankings are automatically updated on movie save, ordered by rating (highest first):

```python
def save(self, *args, **kwargs):
    super().save(*args, **kwargs)
    user_movies = Movie.objects.filter(user=self.user).order_by('-rating')
    for index, movie in enumerate(user_movies, start=1):
        if movie.ranking != index:
            movie.ranking = index
            movie.save(update_fields=['ranking'])
```

## 🐛 Troubleshooting

### Backend Issues

**Port 8000 already in use:**
```bash
# Windows
netstat -ano | findstr :8000
taskkill /PID <process_id> /F

# macOS/Linux
lsof -ti:8000 | xargs kill -9
```

**Database connection error:**
- Verify PostgreSQL is running
- Check `.env` credentials match database setup
- Ensure database `movie_diary` exists

**TMDB API errors:**
- Verify API key is correct in `.env`
- Check TMDB API status at [themoviedb.org](https://www.themoviedb.org/)
- Ensure API key has appropriate permissions

### Frontend Issues

**Port 5173 already in use:**
```bash
# Kill process on port 5173
npx kill-port 5173
```

**API connection errors:**
- Verify Django backend is running on `localhost:8000`
- Check CORS settings in `settings.py`
- Clear browser cache and localStorage
- Check browser console for detailed error messages

**Authentication issues:**
- Clear localStorage: `localStorage.clear()` in browser console
- Verify tokens are being stored (check Application tab in DevTools)
- Ensure JWT tokens haven't expired (access token: 5h, refresh: 7d)

**Movie selection redirect to undefined:**
- This was fixed by updating `MovieViewSet.create()` to return full movie data with ID
- If issue persists, check browser console for detailed logs
- Verify API response includes `id` field

### Common Development Issues

**Module not found errors:**
```bash
# Backend
pip install -r requirements.txt

# Frontend
cd frontend && npm install
```

**Database migrations out of sync:**
```bash
python manage.py migrate --run-syncdb
```

**Static files not loading:**
```bash
python manage.py collectstatic --noinput
```

## 📸 Screenshots

### Home Page
- Modern gradient background with animated effects
- Movie cards displaying posters (450px height), titles, ratings, and reviews
- Automatic ranking badges with gradient colors
- Responsive grid layout (3/2/1 columns)

### Add Movie Page
- TMDB search interface with real-time results
- Movie posters (400px height) with select buttons
- Loading states for each movie selection
- Error handling with user-friendly messages

### Edit Movie Page
- Large movie poster preview (500px height)
- Rating input (0-10 scale)
- Review textarea with validation
- Save/Cancel actions with immediate feedback

### Authentication
- Modern login/register forms with gradient buttons
- Glass-morphism effects
- Animated input fields
- Error display for validation

## 🚀 Deployment

### Backend Deployment (Example: Railway/Render)

1. **Update settings for production**

   ```python
   # settings.py
   DEBUG = False
   ALLOWED_HOSTS = ['your-domain.com']
   CORS_ALLOWED_ORIGINS = [
       "https://your-frontend-domain.com",
   ]
   ```

2. **Set environment variables** on hosting platform

3. **Configure static files**

   ```bash
   python manage.py collectstatic --noinput
   ```

4. **Run migrations** on production database

   ```bash
   python manage.py migrate
   ```

### Frontend Deployment (Example: Vercel/Netlify)

1. **Update API base URL**

   ```javascript
   // frontend/src/services/api.js
   const api = axios.create({
     baseURL: 'https://your-backend-domain.com/api',
   });
   ```

2. **Build for production**

   ```bash
   cd frontend
   npm run build
   ```

3. **Deploy** the `dist` folder to hosting platform

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- **Backend**: Follow PEP 8 Python style guide
- **Frontend**: Use ESLint with React conventions
- **Commits**: Use clear, descriptive commit messages

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👏 Acknowledgments

- **[The Movie Database (TMDB)](https://www.themoviedb.org/)** - Movie data and poster images API
- **[Django REST Framework](https://www.django-rest-framework.org/)** - Powerful REST API toolkit
- **[React](https://react.dev/)** - Modern UI library
- **[Vite](https://vite.dev/)** - Lightning-fast build tool
- **Community Contributors** - Thanks to all who have contributed!

## 📧 Support & Contact

**Developer**: Marcel Mosha

**GitHub**: [@Marcel-mosha](https://github.com/Marcel-mosha)

**Project Repository**: [https://github.com/Marcel-mosha/my_movies_diary](https://github.com/Marcel-mosha/my_movies_diary)

### Report Issues

Found a bug or have a feature request? Please open an issue on GitHub with:
- Detailed description
- Steps to reproduce (for bugs)
- Expected vs actual behavior
- Screenshots (if applicable)

### Questions?

For questions or discussions:
- Open a GitHub Discussion
- Check existing issues for solutions
- Review the troubleshooting section above

---

⭐ **If this project helped you, consider giving it a star!**

---

**Built with ❤️ using Django, React, and TMDB API**
