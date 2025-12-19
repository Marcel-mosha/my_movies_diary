import { Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { useNavigate } from "react-router-dom";
import { useEffect } from "react";

const LandingPage = () => {
  const { user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    // If user is already logged in, redirect to home
    if (user) {
      navigate("/movies");
    }
  }, [user, navigate]);

  const features = [
    {
      icon: "🎬",
      title: "Track Your Movies",
      description:
        "Keep a comprehensive diary of all the movies you've watched. Never forget that hidden gem again.",
    },
    {
      icon: "⭐",
      title: "Rate & Review",
      description:
        "Share your thoughts and ratings. Build your personal movie database with detailed reviews.",
    },
    {
      icon: "🔍",
      title: "Search & Filter",
      description:
        "Quickly find movies by title, year, or rating. Advanced filters help you discover patterns in your viewing habits.",
    },
    {
      icon: "📊",
      title: "Organize Your Collection",
      description:
        "Sort and categorize your movies. Track when you watched them and build your viewing history.",
    },
  ];

  return (
    <div className="landing-page">
      {/* Hero Section */}
      <section className="hero-section">
        <div className="hero-content">
          <div className="hero-text">
            <h1 className="hero-title">
              Your Personal
              <span className="gradient-text"> Movie Diary</span>
            </h1>
            <p className="hero-subtitle">
              Track, rate, and review every movie you watch. Build your
              cinematic journey and never lose track of your favorite films.
            </p>
            <div className="hero-buttons">
              <Link to="/register" className="btn btn-primary btn-large">
                Get Started Free
              </Link>
              <Link to="/login" className="btn btn-secondary btn-large">
                Sign In
              </Link>
            </div>
          </div>
          <div className="hero-image">
            <div className="movie-card-demo">
              <div className="demo-card">
                <div className="demo-poster">🎬</div>
                <div className="demo-info">
                  <h3>The Shawshank Redemption</h3>
                  <div className="demo-rating">
                    <span className="stars">⭐⭐⭐⭐⭐</span>
                    <span className="rating-number">5.0</span>
                  </div>
                  <p className="demo-year">1994</p>
                </div>
              </div>
              <div className="demo-card">
                <div className="demo-poster">🎭</div>
                <div className="demo-info">
                  <h3>The Dark Knight</h3>
                  <div className="demo-rating">
                    <span className="stars">⭐⭐⭐⭐⭐</span>
                    <span className="rating-number">4.8</span>
                  </div>
                  <p className="demo-year">2008</p>
                </div>
              </div>
              <div className="demo-card">
                <div className="demo-poster">🌟</div>
                <div className="demo-info">
                  <h3>Inception</h3>
                  <div className="demo-rating">
                    <span className="stars">⭐⭐⭐⭐⭐</span>
                    <span className="rating-number">4.9</span>
                  </div>
                  <p className="demo-year">2010</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="features-section">
        <div className="features-container">
          <h2 className="section-title">Everything You Need to Track Movies</h2>
          <p className="section-subtitle">
            Simple, powerful tools to manage your movie watching experience
          </p>
          <div className="features-grid">
            {features.map((feature, index) => (
              <div key={index} className="feature-card">
                <div className="feature-icon">{feature.icon}</div>
                <h3 className="feature-title">{feature.title}</h3>
                <p className="feature-description">{feature.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="stats-section">
        <div className="stats-container">
          <div className="stat-item">
            <div className="stat-number">10,000+</div>
            <div className="stat-label">Movies Tracked</div>
          </div>
          <div className="stat-item">
            <div className="stat-number">500+</div>
            <div className="stat-label">Active Users</div>
          </div>
          <div className="stat-item">
            <div className="stat-number">50,000+</div>
            <div className="stat-label">Reviews Written</div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="cta-section">
        <div className="cta-container">
          <h2 className="cta-title">Ready to Start Your Movie Journey?</h2>
          <p className="cta-subtitle">
            Join thousands of movie enthusiasts tracking their cinematic
            adventures
          </p>
          <Link to="/register" className="btn btn-primary btn-large">
            Create Your Free Account
          </Link>
        </div>
      </section>
    </div>
  );
};

export default LandingPage;
