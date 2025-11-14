# 🎬 MovieDiary

A modern, full-featured Django web application for tracking, rating, and reviewing your favorite movies. MovieDiary integrates with The Movie Database (TMDb) API to provide comprehensive movie information and beautiful poster images.

![Python](https://img.shields.io/badge/Python-3.12-blue.svg)
![Django](https://img.shields.io/badge/Django-5.2.7-green.svg)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-blue.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## ✨ Features

- 🔐 **User Authentication**: Secure registration, login, and logout functionality
- 🔍 **Smart Movie Search**: Search and add movies from TMDb database
- ⭐ **Rate & Review**: Add personal ratings (0-10) and detailed reviews
- 🏆 **Automatic Rankings**: Movies automatically ranked based on your ratings
- 🎨 **Modern UI**: Beautiful gradient backgrounds with glass-morphism effects
- 📱 **Responsive Design**: Fully responsive layout for all devices
- 🖼️ **Full Poster Display**: Movie posters displayed in optimized 400px containers
- ✨ **Smooth Animations**: Engaging hover effects and transitions
- 👤 **User-Specific Collections**: Each user maintains their own movie list

## 🚀 Tech Stack

- **Backend**: Django 5.2.7
- **Database**: PostgreSQL with psycopg2-binary
- **Frontend**: Bootstrap 5.3.0, Custom CSS with CSS Variables
- **Icons**: Font Awesome 6.4.0
- **Fonts**: Google Fonts (Poppins)
- **API**: The Movie Database (TMDb) API v3

## 📋 Prerequisites

- Python 3.12+
- PostgreSQL
- TMDb API Key (free from [themoviedb.org](https://www.themoviedb.org/settings/api))

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Marcel-mosha/Movie-Diary.git
   cd Movie-Diary
   ```

2. **Create and activate virtual environment**
   ```bash
   python -m venv venv
   
   # Windows
   venv\Scripts\activate
   
   # macOS/Linux
   source venv/bin/activate
   ```

3. **Install dependencies**
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

8. **Run the development server**
   ```bash
   python manage.py runserver
   ```

9. **Access the application**
   
   Open your browser and navigate to: `http://127.0.0.1:8000/`

## 📁 Project Structure

```
my_movies_diary/
├── base/                           # Main application
│   ├── management/commands/        # Custom Django commands
│   ├── migrations/                 # Database migrations
│   ├── admin.py                    # Admin interface configuration
│   ├── forms.py                    # Form definitions
│   ├── models.py                   # Database models
│   ├── urls.py                     # URL routing
│   └── views.py                    # View functions
├── my_movies_diary/                # Project settings
│   ├── settings.py                 # Django settings
│   ├── urls.py                     # Main URL configuration
│   └── wsgi.py                     # WSGI configuration
├── static/css/                     # Static CSS files
│   └── styles.css                  # Main stylesheet
├── templates/                      # HTML templates
│   ├── registration/               # Auth templates
│   │   ├── login.html
│   │   └── register.html
│   ├── add.html                    # Add movie page
│   ├── base.html                   # Base template
│   ├── edit.html                   # Edit rating page
│   ├── index.html                  # Home page
│   └── select.html                 # Movie selection page
├── manage.py                       # Django management script
└── README.md                       # This file
```

## 🎯 Usage

### For Users

1. **Register an Account**: Create your account on the registration page
2. **Login**: Sign in with your credentials
3. **Search for Movies**: Use the "Add Movie" button to search TMDb
4. **Add Movies**: Select movies from search results to add to your collection
5. **Rate & Review**: Edit movies to add your personal rating (0-10) and review
6. **View Collection**: See your ranked collection on the home page
7. **Edit/Delete**: Manage your movie ratings and reviews anytime

### For Administrators

Access the Django admin panel at `/admin/` to:
- Manage users
- View all movies
- Assign movies to users
- Monitor database

## 🎨 UI Highlights

- **Animated Gradient Background**: Beautiful shifting gradients
- **Glass-Morphism**: Frosted glass effects on navbar and footer
- **Movie Cards**: Professional cards with hover animations
- **Responsive Design**: Optimized for desktop, tablet, and mobile
- **Modern Forms**: Stylized input fields with focus effects
- **Icon Integration**: Font Awesome icons throughout

## 🔧 Configuration

### Database Settings

Edit `my_movies_diary/settings.py`:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'movie_diary',
        'USER': 'movie_user',
        'PASSWORD': 'your_password',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

### TMDb API Setup

1. Register at [themoviedb.org](https://www.themoviedb.org/)
2. Request an API key in your account settings
3. Add the key to your environment variables or `settings.py`

## 📊 Database Models

### Movie Model
- `title`: Movie title
- `year`: Release year
- `description`: Plot summary
- `rating`: User rating (0-10)
- `ranking`: Auto-calculated ranking
- `review`: User review text
- `img_url`: TMDb poster URL
- `user`: Foreign key to User

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👏 Acknowledgments

- [The Movie Database (TMDb)](https://www.themoviedb.org/) for providing the movie data API
- [Bootstrap](https://getbootstrap.com/) for the responsive framework
- [Font Awesome](https://fontawesome.com/) for the icon library
- [Google Fonts](https://fonts.google.com/) for the Poppins typeface

## 📧 Contact

Marcel Mosha - [@Marcel-mosha](https://github.com/Marcel-mosha)

Project Link: [https://github.com/Marcel-mosha/Movie-Diary](https://github.com/Marcel-mosha/Movie-Diary)

---

⭐ **Star this repository if you find it helpful!**
