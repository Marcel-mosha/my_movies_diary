import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { moviesAPI } from "../services/api";

const AddMovie = () => {
  const [searchTitle, setSearchTitle] = useState("");
  const [searchResults, setSearchResults] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [searching, setSearching] = useState(false);
  const [selectingMovieId, setSelectingMovieId] = useState(null);
  const navigate = useNavigate();

  const handleSearch = async (e) => {
    e.preventDefault();
    if (!searchTitle.trim()) return;

    setSearching(true);
    setError("");
    setLoading(true);

    try {
      const response = await moviesAPI.searchTMDB(searchTitle);
      setSearchResults(response.data);
      if (response.data.length === 0) {
        setError("No movies found. Try a different search.");
      }
    } catch (err) {
      setError("Failed to search movies. Please try again.");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleSelectMovie = async (movieId) => {
    setSelectingMovieId(movieId);
    setError("");

    try {
      console.log("Step 1: Fetching movie details for TMDB ID:", movieId);

      // First fetch the movie details from TMDB
      const detailsResponse = await moviesAPI.fetchTMDBDetails(movieId);
      console.log("Step 2: Movie details received:", detailsResponse.data);
      const movieData = detailsResponse.data;

      if (!movieData.title) {
        throw new Error("Invalid movie data received from TMDB");
      }

      // Create the movie
      console.log("Step 3: Creating movie with data:", movieData);
      const createResponse = await moviesAPI.create(movieData);
      console.log(
        "Step 4: Movie created successfully with ID:",
        createResponse.data.id
      );

      // Navigate to edit page to add rating and review
      console.log("Step 5: Navigating to edit page...");
      navigate(`/edit/${createResponse.data.id}`, { replace: true });
    } catch (err) {
      console.error("Error occurred at some step:", err);
      console.error("Error response data:", err.response?.data);
      console.error("Error status:", err.response?.status);

      let errorMsg = "Failed to add movie. Please try again.";

      if (err.response?.data) {
        if (typeof err.response.data === "string") {
          errorMsg = err.response.data;
        } else if (err.response.data.error) {
          errorMsg = err.response.data.error;
        } else if (err.response.data.detail) {
          errorMsg = err.response.data.detail;
        } else {
          // Try to extract any field errors
          const errors = Object.values(err.response.data).flat();
          if (errors.length > 0) {
            errorMsg = errors.join(", ");
          }
        }
      } else if (err.message) {
        errorMsg = err.message;
      }

      setError(errorMsg);
      setSelectingMovieId(null);
    }
  };

  return (
    <div className="container">
      <div className="page-header">
        <h1>Add Movie</h1>
      </div>

      {error && <div className="error-message">{error}</div>}

      <div className="search-section">
        <form onSubmit={handleSearch} className="search-form">
          <input
            type="text"
            placeholder="Enter movie title..."
            value={searchTitle}
            onChange={(e) => setSearchTitle(e.target.value)}
            className="search-input"
            autoFocus
          />
          <button type="submit" disabled={loading} className="btn-primary">
            {loading ? "Searching..." : "Search"}
          </button>
        </form>
      </div>

      {searching && searchResults.length > 0 && (
        <div className="search-results">
          <h2>Search Results</h2>
          <div className="results-grid">
            {searchResults.map((movie) => (
              <div key={movie.id} className="search-result-card">
                <div className="result-poster">
                  {movie.poster_path ? (
                    <img
                      src={`https://image.tmdb.org/t/p/w200${movie.poster_path}`}
                      alt={movie.title}
                    />
                  ) : (
                    <div className="no-poster">No Image</div>
                  )}
                </div>
                <div className="result-info">
                  <h3>{movie.title}</h3>
                  <p className="result-year">
                    {movie.release_date
                      ? new Date(movie.release_date).getFullYear()
                      : "N/A"}
                  </p>
                  <p className="result-overview">
                    {movie.overview || "No description available"}
                  </p>
                  <button
                    onClick={() => handleSelectMovie(movie.id)}
                    disabled={selectingMovieId !== null}
                    className="btn-select"
                  >
                    {selectingMovieId === movie.id ? "Adding..." : "Select"}
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default AddMovie;
