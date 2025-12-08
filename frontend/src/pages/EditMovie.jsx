import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { moviesAPI } from "../services/api";

const EditMovie = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [movie, setMovie] = useState(null);
  const [rating, setRating] = useState("");
  const [review, setReview] = useState("");
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    fetchMovie();
  }, [id]);

  const fetchMovie = async () => {
    try {
      setLoading(true);
      const response = await moviesAPI.getOne(id);
      setMovie(response.data);
      setRating(response.data.rating || "");
      setReview(response.data.review || "");
      setError("");
    } catch (err) {
      setError("Failed to load movie. Please try again.");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    setError("");

    try {
      const updateData = {
        rating: rating ? parseFloat(rating) : null,
        review: review || null,
      };

      await moviesAPI.update(id, updateData);
      navigate("/");
    } catch (err) {
      setError("Failed to update movie. Please try again.");
      console.error(err);
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return <div className="loading">Loading movie...</div>;
  }

  if (!movie) {
    return <div className="error-message">Movie not found</div>;
  }

  return (
    <div className="container">
      <div className="page-header">
        <h1>Edit Movie</h1>
      </div>

      {error && <div className="error-message">{error}</div>}

      <div className="edit-container">
        <div className="movie-preview">
          <div className="preview-poster">
            {movie.img_url ? (
              <img src={movie.img_url} alt={movie.title} />
            ) : (
              <div className="no-poster">No Image</div>
            )}
          </div>
          <div className="preview-info">
            <h2>{movie.title}</h2>
            <p className="preview-year">{movie.year}</p>
            <p className="preview-description">{movie.description}</p>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="edit-form">
          <div className="form-group">
            <label htmlFor="rating">Your Rating (0-10)</label>
            <input
              type="number"
              id="rating"
              value={rating}
              onChange={(e) => setRating(e.target.value)}
              min="0"
              max="10"
              step="0.1"
              placeholder="e.g., 7.5"
            />
          </div>

          <div className="form-group">
            <label htmlFor="review">Your Review</label>
            <textarea
              id="review"
              value={review}
              onChange={(e) => setReview(e.target.value)}
              rows="5"
              placeholder="Write your review here..."
            />
          </div>

          <div className="form-actions">
            <button type="submit" disabled={saving} className="btn-primary">
              {saving ? "Saving..." : "Save Changes"}
            </button>
            <button
              type="button"
              onClick={() => navigate("/")}
              className="btn-secondary"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default EditMovie;
