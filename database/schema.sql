-- =================================================================================
-- SCHÉMA DE BASE DE DONNÉES - Hunger-Talk
-- =================================================================================
-- Ce fichier contient la définition complète du schéma de la base de données
-- Les migrations Alembic utiliseront ce schéma comme référence
-- =================================================================================

-- Extension pour générer des UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =================================================================================
-- TABLE: users
-- =================================================================================
-- Stocke les informations des utilisateurs
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITH TIME ZONE
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- =================================================================================
-- TABLE: categories
-- =================================================================================
-- Catégories de produits alimentaires
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    icon VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insertion des catégories de base
INSERT INTO categories (name, icon, description) VALUES
('Fruits', '🍎', 'Fruits frais et secs'),
('Légumes', '🥕', 'Légumes frais et conserves'),
('Viande', '🥩', 'Viande, volaille, poisson'),
('Produits laitiers', '🥛', 'Lait, fromage, yaourt'),
('Céréales', '🌾', 'Pâtes, riz, pain, céréales'),
('Épicerie', '🧂', 'Condiments, épices, sauces'),
('Surgelés', '❄️', 'Produits surgelés'),
('Boissons', '🥤', 'Eau, jus, sodas, alcool'),
('Snacks', '🍫', 'Biscuits, chips, bonbons'),
('Autres', '📦', 'Autres produits')
ON CONFLICT (name) DO NOTHING;

-- =================================================================================
-- TABLE: stock_items
-- =================================================================================
-- Éléments du stock alimentaire de l'utilisateur
CREATE TABLE IF NOT EXISTS stock_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL DEFAULT 0,
    unit VARCHAR(50) NOT NULL DEFAULT 'unité',
    category_id INTEGER REFERENCES categories(id),
    expiry_date DATE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    
    CONSTRAINT chk_quantity_positive CHECK (quantity >= 0)
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_stock_items_user_id ON stock_items(user_id);
CREATE INDEX IF NOT EXISTS idx_stock_items_category_id ON stock_items(category_id);
CREATE INDEX IF NOT EXISTS idx_stock_items_expiry_date ON stock_items(expiry_date);
CREATE INDEX IF NOT EXISTS idx_stock_items_user_expiry ON stock_items(user_id, expiry_date);

-- =================================================================================
-- TABLE: recipes
-- =================================================================================
-- Recettes disponibles
CREATE TABLE IF NOT EXISTS recipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    preparation_time INTEGER, -- en minutes
    cooking_time INTEGER, -- en minutes
    total_time INTEGER, -- en minutes
    difficulty VARCHAR(20) CHECK (difficulty IN ('Facile', 'Moyen', 'Difficile')),
    servings INTEGER DEFAULT 4,
    image_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Index pour la recherche
CREATE INDEX IF NOT EXISTS idx_recipes_name ON recipes(name);
CREATE INDEX IF NOT EXISTS idx_recipes_difficulty ON recipes(difficulty);
CREATE INDEX IF NOT EXISTS idx_recipes_total_time ON recipes(total_time);

-- =================================================================================
-- TABLE: recipe_ingredients
-- =================================================================================
-- Ingrédients nécessaires pour chaque recette
CREATE TABLE IF NOT EXISTS recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    ingredient_name VARCHAR(255) NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(50) NOT NULL DEFAULT 'unité',
    optional BOOLEAN DEFAULT FALSE,
    order_index INTEGER DEFAULT 0
);

-- Index
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_recipe_id ON recipe_ingredients(recipe_id);
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_name ON recipe_ingredients(ingredient_name);

-- =================================================================================
-- TABLE: recipe_steps
-- =================================================================================
-- Étapes de préparation pour chaque recette
CREATE TABLE IF NOT EXISTS recipe_steps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    step_number INTEGER NOT NULL,
    instruction TEXT NOT NULL,
    image_url VARCHAR(500)
);

-- Index et contrainte unique
CREATE INDEX IF NOT EXISTS idx_recipe_steps_recipe_id ON recipe_steps(recipe_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_recipe_steps_recipe_step ON recipe_steps(recipe_id, step_number);

-- =================================================================================
-- TABLE: nutrition_data
-- =================================================================================
-- Données nutritionnelles pour chaque recette
CREATE TABLE IF NOT EXISTS nutrition_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    calories DECIMAL(10, 2) NOT NULL DEFAULT 0,
    proteins DECIMAL(10, 2) NOT NULL DEFAULT 0, -- en grammes
    carbohydrates DECIMAL(10, 2) NOT NULL DEFAULT 0, -- en grammes
    fats DECIMAL(10, 2) NOT NULL DEFAULT 0, -- en grammes
    fiber DECIMAL(10, 2) DEFAULT 0, -- en grammes
    sugar DECIMAL(10, 2) DEFAULT 0, -- en grammes
    sodium DECIMAL(10, 2) DEFAULT 0, -- en milligrammes
    per_serving BOOLEAN DEFAULT TRUE -- Si les valeurs sont par portion ou totales
    
    CONSTRAINT chk_calories_positive CHECK (calories >= 0),
    CONSTRAINT chk_proteins_positive CHECK (proteins >= 0),
    CONSTRAINT chk_carbs_positive CHECK (carbohydrates >= 0),
    CONSTRAINT chk_fats_positive CHECK (fats >= 0)
);

-- Index
CREATE INDEX IF NOT EXISTS idx_nutrition_data_recipe_id ON nutrition_data(recipe_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_nutrition_data_recipe_unique ON nutrition_data(recipe_id);

-- =================================================================================
-- TABLE: user_preferences
-- =================================================================================
-- Préférences et restrictions alimentaires de l'utilisateur
CREATE TABLE IF NOT EXISTS user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Restrictions alimentaires (JSON array)
    dietary_restrictions TEXT[], -- Ex: ['halal', 'vegan', 'vegetarian', 'gluten-free']
    
    -- Allergies (JSON array)
    allergies TEXT[], -- Ex: ['peanuts', 'lactose', 'shellfish']
    
    -- Objectifs nutritionnels
    daily_calorie_goal DECIMAL(10, 2),
    daily_protein_goal DECIMAL(10, 2), -- en grammes
    daily_carb_goal DECIMAL(10, 2), -- en grammes
    daily_fat_goal DECIMAL(10, 2), -- en grammes
    
    -- Préférences de cuisine
    preferred_cuisines TEXT[], -- Ex: ['french', 'italian', 'asian']
    disliked_ingredients TEXT[],
    
    -- Préférences de temps
    max_prep_time INTEGER, -- en minutes
    max_cooking_time INTEGER, -- en minutes
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_calorie_goal_positive CHECK (daily_calorie_goal IS NULL OR daily_calorie_goal > 0)
);

-- Index
CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id ON user_preferences(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_preferences_user_unique ON user_preferences(user_id);

-- =================================================================================
-- TABLE: chat_messages
-- =================================================================================
-- Historique des messages de chat avec l'IA
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    response TEXT,
    context_used TEXT, -- Contexte RAG utilisé (JSON)
    recipes_suggested UUID[], -- IDs des recettes suggérées
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    model_used VARCHAR(100) DEFAULT 'llama3.1:8b',
    response_time_ms INTEGER -- Temps de réponse en millisecondes
);

-- Index
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_timestamp ON chat_messages(timestamp);
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_timestamp ON chat_messages(user_id, timestamp DESC);

-- =================================================================================
-- TABLE: shopping_list
-- =================================================================================
-- Liste de courses de l'utilisateur
CREATE TABLE IF NOT EXISTS shopping_list (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_name VARCHAR(255) NOT NULL,
    quantity DECIMAL(10, 2) DEFAULT 1,
    unit VARCHAR(50) DEFAULT 'unité',
    category_id INTEGER REFERENCES categories(id),
    is_purchased BOOLEAN DEFAULT FALSE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    purchased_at TIMESTAMP WITH TIME ZONE,
    notes TEXT
);

-- Index
CREATE INDEX IF NOT EXISTS idx_shopping_list_user_id ON shopping_list(user_id);
CREATE INDEX IF NOT EXISTS idx_shopping_list_purchased ON shopping_list(user_id, is_purchased);
CREATE INDEX IF NOT EXISTS idx_shopping_list_category_id ON shopping_list(category_id);

-- =================================================================================
-- TABLE: notifications
-- =================================================================================
-- Notifications pour l'utilisateur
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- 'expiry', 'recipe_suggestion', 'nutrition_reminder', etc.
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    related_item_id UUID, -- ID de l'item lié (stock_item, recipe, etc.)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP WITH TIME ZONE
);

-- Index
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(user_id, created_at DESC);

-- =================================================================================
-- TABLE: cooking_history
-- =================================================================================
-- Historique des recettes cuisinées
CREATE TABLE IF NOT EXISTS cooking_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    cooked_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    servings_made INTEGER,
    rating INTEGER CHECK (rating IS NULL OR (rating >= 1 AND rating <= 5)),
    notes TEXT
);

-- Index
CREATE INDEX IF NOT EXISTS idx_cooking_history_user_id ON cooking_history(user_id);
CREATE INDEX IF NOT EXISTS idx_cooking_history_recipe_id ON cooking_history(recipe_id);
CREATE INDEX IF NOT EXISTS idx_cooking_history_cooked_at ON cooking_history(user_id, cooked_at DESC);

-- =================================================================================
-- TRIGGERS POUR UPDATED_AT
-- =================================================================================

-- Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour les tables avec updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_stock_items_updated_at BEFORE UPDATE ON stock_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_recipes_updated_at BEFORE UPDATE ON recipes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =================================================================================
-- VUES UTILES
-- =================================================================================

-- Vue pour les produits expirant bientôt (dans les 3 prochains jours)
CREATE OR REPLACE VIEW products_expiring_soon AS
SELECT 
    si.*,
    u.email as user_email,
    c.name as category_name,
    (si.expiry_date - CURRENT_DATE) as days_until_expiry
FROM stock_items si
JOIN users u ON si.user_id = u.id
LEFT JOIN categories c ON si.category_id = c.id
WHERE si.expiry_date IS NOT NULL
    AND si.expiry_date >= CURRENT_DATE
    AND si.expiry_date <= CURRENT_DATE + INTERVAL '3 days'
    AND si.quantity > 0
ORDER BY si.expiry_date ASC;

-- Vue pour les statistiques nutritionnelles quotidiennes
CREATE OR REPLACE VIEW daily_nutrition_stats AS
SELECT 
    u.id as user_id,
    DATE(ch.cooked_at) as date,
    COUNT(DISTINCT ch.recipe_id) as recipes_count,
    SUM(nd.calories * COALESCE(ch.servings_made, nd.servings) / NULLIF(nd.servings, 0)) as total_calories,
    SUM(nd.proteins * COALESCE(ch.servings_made, nd.servings) / NULLIF(nd.servings, 0)) as total_proteins,
    SUM(nd.carbohydrates * COALESCE(ch.servings_made, nd.servings) / NULLIF(nd.servings, 0)) as total_carbohydrates,
    SUM(nd.fats * COALESCE(ch.servings_made, nd.servings) / NULLIF(nd.servings, 0)) as total_fats
FROM users u
LEFT JOIN cooking_history ch ON u.id = ch.user_id
LEFT JOIN nutrition_data nd ON ch.recipe_id = nd.recipe_id
WHERE ch.cooked_at >= CURRENT_DATE
GROUP BY u.id, DATE(ch.cooked_at);

-- =================================================================================
-- COMMENTAIRES SUR LES TABLES
-- =================================================================================

COMMENT ON TABLE users IS 'Utilisateurs de l''application';
COMMENT ON TABLE categories IS 'Catégories de produits alimentaires';
COMMENT ON TABLE stock_items IS 'Éléments du stock alimentaire par utilisateur';
COMMENT ON TABLE recipes IS 'Recettes disponibles dans l''application';
COMMENT ON TABLE recipe_ingredients IS 'Ingrédients nécessaires pour chaque recette';
COMMENT ON TABLE recipe_steps IS 'Étapes de préparation de chaque recette';
COMMENT ON TABLE nutrition_data IS 'Données nutritionnelles pour chaque recette';
COMMENT ON TABLE user_preferences IS 'Préférences et restrictions alimentaires des utilisateurs';
COMMENT ON TABLE chat_messages IS 'Historique des conversations avec l''IA';
COMMENT ON TABLE shopping_list IS 'Liste de courses des utilisateurs';
COMMENT ON TABLE notifications IS 'Notifications pour les utilisateurs';
COMMENT ON TABLE cooking_history IS 'Historique des recettes cuisinées par les utilisateurs';

-- =================================================================================
-- FIN DU SCHÉMA
-- =================================================================================

