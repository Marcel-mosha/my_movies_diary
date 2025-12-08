# Quick Start Guide

## Prerequisites Check

- [ ] Python 3.8+ installed
- [ ] Node.js 18+ installed
- [ ] PostgreSQL running
- [ ] TMDB API key obtained from https://www.themoviedb.org/settings/api

## Setup Steps

### Terminal 1 - Backend (Django)

```bash
# Navigate to project root
cd my_movies_diary

# Create virtual environment
python -m venv venv

# Activate virtual environment (Windows)
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Apply migrations
python manage.py migrate

# Start Django server
python manage.py runserver
```

Backend runs at: **http://localhost:8000**

### Terminal 2 - Frontend (React)

```bash
# Navigate to frontend directory
cd my_movies_diary/frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

Frontend runs at: **http://localhost:5173**

## Test the Application

1. Open browser to `http://localhost:5173`
2. Click "Register" to create an account
3. Login with your credentials
4. Click "Add Movie" to search for a movie
5. Select a movie and add your rating/review
6. View your movie collection on the home page

## Important Files Modified

### Backend

- `requirements.txt` - Added DRF, CORS, JWT packages
- `my_movies_diary/settings.py` - Added REST framework config
- `my_movies_diary/urls.py` - Added API routes
- `base/serializers.py` - NEW: DRF serializers
- `base/api_views.py` - NEW: REST API views
- `base/api_urls.py` - NEW: API URL routing

### Frontend (All NEW)

- `frontend/` - Complete React application
- `frontend/src/services/api.js` - API client
- `frontend/src/context/AuthContext.jsx` - Authentication
- `frontend/src/pages/` - All page components
- `frontend/src/components/` - Reusable components

## Common Issues

**Backend won't start:**

- Check PostgreSQL is running
- Verify `.env` file exists with correct credentials
- Run migrations: `python manage.py migrate`

**Frontend won't start:**

- Delete `node_modules` and run `npm install` again
- Check Node.js version: `node --version` (should be 18+)

**CORS errors:**

- Ensure backend is running on port 8000
- Ensure frontend is running on port 5173
- Check CORS settings in `settings.py`

**401 Unauthorized:**

- Clear browser localStorage
- Login again

## Next Steps

1. Create a superuser: `python manage.py createsuperuser`
2. Access admin panel: `http://localhost:8000/admin`
3. Customize the UI in `frontend/src/App.css`
4. Add more features!
