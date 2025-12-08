const MovieCard = ({ movie, onEdit, onDelete }) => {
  return (
    <div className="movie-card">
      <div className="movie-ranking">#{movie.ranking}</div>
      <div className="movie-poster">
        {movie.img_url ? (
          <img src={movie.img_url} alt={movie.title} />
        ) : (
          <div className="no-poster">No Image</div>
        )}
      </div>
      <div className="movie-info">
        <h2>{movie.title}</h2>
        <p className="movie-year">{movie.year}</p>
        <p className="movie-description">{movie.description}</p>
        {movie.rating && (
          <div className="movie-rating">
            <span className="rating-label">Rating:</span>
            <span className="rating-value">{movie.rating}/10</span>
          </div>
        )}
        {movie.review && (
          <div className="movie-review">
            <span className="review-label">Review:</span>
            <p className="review-text">{movie.review}</p>
          </div>
        )}
        <div className="movie-actions">
          <button onClick={() => onEdit(movie)} className="btn-edit">
            Edit
          </button>
          <button onClick={() => onDelete(movie)} className="btn-delete">
            Delete
          </button>
        </div>
      </div>
    </div>
  );
};

export default MovieCard;
