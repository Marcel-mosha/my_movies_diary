# My Movies Diary - React + Django REST API

A full-stack movie diary application with React frontend and Django REST API backend.

## Project Structure

```
my_movies_diary/
├── backend/                 # Django project (existing files)
│   ├── base/               # Django app
│   │   ├── api_views.py    # REST API views
│   │   ├── api_urls.py     # API URL routing
│   │   ├── serializers.py  # DRF serializers
│   │   ├── models.py       # Database models
│   │   └── ...
│   ├── my_movies_diary/    # Django settings
│   ├── manage.py
│   └── requirements.txt
│
└── frontend/               # React application
    ├── src/
    │   ├── components/     # React components
    │   ├── pages/          # Page components
    │   ├── context/        # Auth context
    │   ├── services/       # API services
    │   └── App.jsx
    ├── package.json
    └── vite.config.js
```

## Features

- ✅ User authentication (register, login, logout) with JWT
- ✅ Add movies from TMDB API
- ✅ Rate and review movies
- ✅ Edit and delete movies
- ✅ Automatic ranking based on ratings
- ✅ Modern React UI with dark theme
- ✅ Protected routes
- ✅ Token refresh mechanism

## Prerequisites

- Python 3.8+
- Node.js 18+
- PostgreSQL
- TMDB API Key

## Backend Setup

### 1. Create and activate virtual environment

```bash
cd my_movies_diary
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

### 2. Install Python dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure environment variables

Create a `.env` file in the root directory:

```env
DJANGO_KEY=your-secret-key
DB=movies
DB_USER=postgres
DB_PASSWORD=your-password
DB_HOST=localhost
DB_PORT=5432
API_KEY=your-tmdb-api-key
MOVIE_ENDPOINT=https://api.themoviedb.org/3/search/movie
```

### 4. Run migrations

```bash
python manage.py migrate
```

### 5. Create superuser (optional)

```bash
python manage.py createsuperuser
```

### 6. Start Django development server

```bash
python manage.py runserver
```

Backend will run at: `http://localhost:8000`

## Frontend Setup

### 1. Navigate to frontend directory

```bash
cd frontend
```

### 2. Install Node dependencies

```bash
npm install
```

### 3. Start development server

```bash
npm run dev
```

Frontend will run at: `http://localhost:5173`

## API Endpoints

### Authentication

- `POST /api/register/` - Register new user
- `POST /api/login/` - Login user
- `POST /api/token/refresh/` - Refresh JWT token
- `GET /api/user/` - Get current user

### Movies

- `GET /api/movies/` - List all user's movies
- `POST /api/movies/` - Create a movie
- `GET /api/movies/{id}/` - Get movie details
- `PATCH /api/movies/{id}/` - Update movie (rating/review)
- `DELETE /api/movies/{id}/` - Delete movie
- `GET /api/movies/search_tmdb/?title=...` - Search TMDB
- `GET /api/movies/fetch_tmdb_details/?id=...` - Get TMDB movie details

## Usage

1. **Register/Login**: Create an account or login
2. **Add Movie**: Search for a movie using TMDB API
3. **Rate & Review**: Add your rating (0-10) and review
4. **Manage Movies**: Edit or delete your movies
5. **View Rankings**: Movies are automatically ranked by rating

## Technology Stack

### Backend

- Django 5.2.7
- Django REST Framework
- Django CORS Headers
- Simple JWT
- PostgreSQL
- python-dotenv

### Frontend

- React 18
- React Router DOM
- Axios
- Vite

## Development Notes

### CORS Configuration

The backend is configured to accept requests from:

- `http://localhost:5173` (Vite default)
- `http://localhost:3000` (Alternative React port)

Modify `CORS_ALLOWED_ORIGINS` in `settings.py` for production.

### JWT Token Configuration

- Access token lifetime: 5 hours
- Refresh token lifetime: 7 days

Modify `SIMPLE_JWT` settings in `settings.py` as needed.

### Backward Compatibility

The old Django template-based views are preserved in `base/views.py` and `base/urls.py` but are not currently routed. To use them, uncomment the line in `my_movies_diary/urls.py`.

## Production Deployment

### Backend

1. Set `DEBUG = False` in settings.py
2. Update `ALLOWED_HOSTS`
3. Use proper secret key
4. Set up static files serving
5. Use production database
6. Configure HTTPS

### Frontend

1. Build production bundle: `npm run build`
2. Serve the `dist` folder
3. Update API base URL in `src/services/api.js`
4. Update CORS settings in Django

## Troubleshooting

### CORS Errors

- Ensure Django CORS middleware is properly configured
- Check `CORS_ALLOWED_ORIGINS` includes your frontend URL

### 401 Unauthorized

- Check if JWT token is valid
- Try logging in again
- Check token refresh mechanism

### TMDB API Issues

- Verify API key is correct
- Check API endpoint URLs
- Ensure you have internet connection

## License

This project is for educational purposes.

## Credits

- Movie data provided by [TMDB API](https://www.themoviedb.org/)
