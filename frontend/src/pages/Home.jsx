import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { moviesAPI } from "../services/api";
import MovieCard from "../components/MovieCard";

const Home = () => {
  const [movies, setMovies] = useState([]);
  const [filteredMovies, setFilteredMovies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [searchTerm, setSearchTerm] = useState("");
  const [minRating, setMinRating] = useState("");
  const [maxRating, setMaxRating] = useState("");
  const [minYear, setMinYear] = useState("");
  const [maxYear, setMaxYear] = useState("");
  const [sortBy, setSortBy] = useState("rating");
  const [showFilters, setShowFilters] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    fetchMovies();
  }, []);

  useEffect(() => {
    applyFilters();
  }, [movies, searchTerm, minRating, maxRating, minYear, maxYear, sortBy]);

  const fetchMovies = async () => {
    try {
      setLoading(true);
      const response = await moviesAPI.getAll();
      setMovies(response.data);
      setError("");
    } catch (err) {
      setError("Failed to load movies. Please try again.");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const applyFilters = () => {
    let filtered = [...movies];

    // Search by title
    if (searchTerm) {
      filtered = filtered.filter((movie) =>
        movie.title.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    // Filter by rating
    if (minRating) {
      filtered = filtered.filter(
        (movie) => movie.rating >= parseFloat(minRating)
      );
    }
    if (maxRating) {
      filtered = filtered.filter(
        (movie) => movie.rating <= parseFloat(maxRating)
      );
    }

    // Filter by year
    if (minYear) {
      filtered = filtered.filter((movie) => movie.year >= parseInt(minYear));
    }
    if (maxYear) {
      filtered = filtered.filter((movie) => movie.year <= parseInt(maxYear));
    }

    // Sort
    switch (sortBy) {
      case "rating":
        filtered.sort((a, b) => (b.rating || 0) - (a.rating || 0));
        break;
      case "rating-asc":
        filtered.sort((a, b) => (a.rating || 0) - (b.rating || 0));
        break;
      case "year":
        filtered.sort((a, b) => b.year - a.year);
        break;
      case "year-asc":
        filtered.sort((a, b) => a.year - b.year);
        break;
      case "title":
        filtered.sort((a, b) => a.title.localeCompare(b.title));
        break;
      case "title-desc":
        filtered.sort((a, b) => b.title.localeCompare(a.title));
        break;
      default:
        break;
    }

    setFilteredMovies(filtered);
  };

  const clearFilters = () => {
    setSearchTerm("");
    setMinRating("");
    setMaxRating("");
    setMinYear("");
    setMaxYear("");
    setSortBy("rating");
  };

  const handleEdit = (movie) => {
    navigate(`/edit/${movie.id}`);
  };

  const handleDelete = async (movie) => {
    if (window.confirm(`Are you sure you want to delete "${movie.title}"?`)) {
      try {
        await moviesAPI.delete(movie.id);
        setMovies(movies.filter((m) => m.id !== movie.id));
      } catch (err) {
        setError("Failed to delete movie. Please try again.");
        console.error(err);
      }
    }
  };

  if (loading) {
    return <div className="loading">Loading movies...</div>;
  }

  return (
    <div className="container">
      <div className="page-header">
        <h1>My Movies</h1>
        <button onClick={() => navigate("/add")} className="btn-primary">
          Add New Movie
        </button>
      </div>

      {error && <div className="error-message">{error}</div>}

      {movies.length === 0 ? (
        <div className="empty-state">
          <p>You haven't added any movies yet.</p>
          <button onClick={() => navigate("/add")} className="btn-primary">
            Add Your First Movie
          </button>
        </div>
      ) : (
        <>
          <div className="filters-toggle-container">
            <button
              onClick={() => setShowFilters(!showFilters)}
              className="btn-toggle-filters"
            >
              {showFilters ? "🔼 Hide" : "🔽 Show"} Search & Filters
            </button>
          </div>

          {showFilters && (
            <div className="filters-section">
            <div className="filters-header">
              <h3>🔍 Search & Filter</h3>
              <button onClick={clearFilters} className="btn-clear-filters">
                Clear All
              </button>
            </div>

            <div className="filters-grid">
              {/* Search */}
              <div className="filter-group full-width">
                <label>Search by Title</label>
                <input
                  type="text"
                  placeholder="Search movies..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="filter-input"
                />
              </div>

              {/* Rating Filter */}
              <div className="filter-group">
                <label>Min Rating</label>
                <input
                  type="number"
                  min="0"
                  max="10"
                  step="0.1"
                  placeholder="0"
                  value={minRating}
                  onChange={(e) => setMinRating(e.target.value)}
                  className="filter-input"
                />
              </div>

              <div className="filter-group">
                <label>Max Rating</label>
                <input
                  type="number"
                  min="0"
                  max="10"
                  step="0.1"
                  placeholder="10"
                  value={maxRating}
                  onChange={(e) => setMaxRating(e.target.value)}
                  className="filter-input"
                />
              </div>

              {/* Year Filter */}
              <div className="filter-group">
                <label>From Year</label>
                <input
                  type="number"
                  placeholder="e.g., 2000"
                  value={minYear}
                  onChange={(e) => setMinYear(e.target.value)}
                  className="filter-input"
                />
              </div>

              <div className="filter-group">
                <label>To Year</label>
                <input
                  type="number"
                  placeholder="e.g., 2024"
                  value={maxYear}
                  onChange={(e) => setMaxYear(e.target.value)}
                  className="filter-input"
                />
              </div>

              {/* Sort */}
              <div className="filter-group">
                <label>Sort By</label>
                <select
                  value={sortBy}
                  onChange={(e) => setSortBy(e.target.value)}
                  className="filter-select"
                >
                  <option value="rating">Rating (High to Low)</option>
                  <option value="rating-asc">Rating (Low to High)</option>
                  <option value="year">Year (Newest First)</option>
                  <option value="year-asc">Year (Oldest First)</option>
                  <option value="title">Title (A-Z)</option>
                  <option value="title-desc">Title (Z-A)</option>
                </select>
              </div>
            </div>

            <div className="results-count">
              Showing {filteredMovies.length} of {movies.length} movies
            </div>
            </div>
          )}

          {filteredMovies.length === 0 ? (
            <div className="no-results">
              <p>No movies match your filters.</p>
              <button onClick={clearFilters} className="btn-secondary">
                Clear Filters
              </button>
            </div>
          ) : (
            <div className="movies-grid">
              {filteredMovies.map((movie) => (
                <MovieCard
                  key={movie.id}
                  movie={movie}
                  onEdit={handleEdit}
                  onDelete={handleDelete}
                />
              ))}
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default Home;
