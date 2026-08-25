CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(80) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  phone VARCHAR(30),
  password_hash VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE user_preferences (
  user_id BIGINT PRIMARY KEY,
  budget_min INT NOT NULL DEFAULT 0,
  budget_max INT NOT NULL DEFAULT 150,
  distance_limit_meters INT NOT NULL DEFAULT 1000,
  waste_reduction_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_preferences_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
);

CREATE TABLE preference_tags (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  tag VARCHAR(40) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_preference_tags_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT uk_preference_tag UNIQUE (user_id, tag)
);

CREATE TABLE stores (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  address VARCHAR(255) NOT NULL,
  business_hours VARCHAR(80),
  contact_phone VARCHAR(30),
  latitude DECIMAL(10, 7),
  longitude DECIMAL(10, 7),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE foods (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  store_id BIGINT NOT NULL,
  name VARCHAR(120) NOT NULL,
  price INT NOT NULL,
  original_price INT,
  discount_label VARCHAR(40),
  category VARCHAR(40) NOT NULL,
  stock_count INT NOT NULL DEFAULT 0,
  expires_at DATETIME,
  eco_priority_score DECIMAL(4, 3) NOT NULL DEFAULT 0,
  recommendation_reason VARCHAR(255),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_foods_store
    FOREIGN KEY (store_id) REFERENCES stores(id)
    ON DELETE CASCADE
);

CREATE TABLE food_tags (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  food_id BIGINT NOT NULL,
  tag VARCHAR(40) NOT NULL,
  tag_type ENUM('preference', 'nutrition', 'ingredient') NOT NULL,
  CONSTRAINT fk_food_tags_food
    FOREIGN KEY (food_id) REFERENCES foods(id)
    ON DELETE CASCADE,
  CONSTRAINT uk_food_tag UNIQUE (food_id, tag, tag_type)
);

CREATE TABLE favorites (
  user_id BIGINT NOT NULL,
  food_id BIGINT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, food_id),
  CONSTRAINT fk_favorites_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_favorites_food
    FOREIGN KEY (food_id) REFERENCES foods(id)
    ON DELETE CASCADE
);

CREATE TABLE browsing_history (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  food_id BIGINT NOT NULL,
  viewed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_browsing_history_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_browsing_history_food
    FOREIGN KEY (food_id) REFERENCES foods(id)
    ON DELETE CASCADE,
  INDEX idx_browsing_history_user_viewed_at (user_id, viewed_at)
);

CREATE TABLE search_logs (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT,
  keyword VARCHAR(120),
  category VARCHAR(40),
  tags VARCHAR(255),
  max_price INT,
  max_distance_meters INT,
  expiring_only BOOLEAN NOT NULL DEFAULT FALSE,
  result_count INT NOT NULL DEFAULT 0,
  searched_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_search_logs_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE SET NULL
);

CREATE TABLE recommendation_logs (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  food_id BIGINT NOT NULL,
  preference_score DECIMAL(5, 3) NOT NULL DEFAULT 0,
  distance_score DECIMAL(5, 3) NOT NULL DEFAULT 0,
  budget_score DECIMAL(5, 3) NOT NULL DEFAULT 0,
  eco_priority_score DECIMAL(5, 3) NOT NULL DEFAULT 0,
  final_score DECIMAL(5, 3) NOT NULL DEFAULT 0,
  recommendation_reason VARCHAR(255),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_recommendation_logs_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_recommendation_logs_food
    FOREIGN KEY (food_id) REFERENCES foods(id)
    ON DELETE CASCADE
);

CREATE TABLE recommendation_feedback (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  food_id BIGINT NOT NULL,
  action_type ENUM('view', 'favorite', 'unfavorite', 'purchase', 'rating') NOT NULL,
  rating TINYINT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_recommendation_feedback_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_recommendation_feedback_food
    FOREIGN KEY (food_id) REFERENCES foods(id)
    ON DELETE CASCADE
);
