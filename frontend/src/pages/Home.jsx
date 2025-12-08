import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { moviesAPI } from "../services/api";
import MovieCard from "../components/MovieCard";

const Home = () => {
  const [movies, setMovies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    fetchMovies();
  }, []);

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
        <div className="movies-grid">
          {movies.map((movie) => (
            <MovieCard
              key={movie.id}
              movie={movie}
              onEdit={handleEdit}
              onDelete={handleDelete}
            />
          ))}
        </div>
      )}
    </div>
  );
};

export default Home;
