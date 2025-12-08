const Footer = () => {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="footer">
      <div className="footer-container">
        <p className="footer-text">
          © {currentYear} My Movies Diary. All rights reserved.
        </p>
        <p className="footer-credits">
          Movie data provided by{" "}
          <a
            href="https://www.themoviedb.org/"
            target="_blank"
            rel="noopener noreferrer"
            className="footer-link"
          >
            TMDB
          </a>
        </p>
      </div>
    </footer>
  );
};

export default Footer;
