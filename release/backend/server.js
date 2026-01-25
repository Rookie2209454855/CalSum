const express = require('express');
const cors = require('cors');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcryptjs'); // 用于密码加密
const jwt = require('jsonwebtoken'); // 用于生成认证令牌
const app = express();

// Serve static files from the 'dist' folder (where Vue builds to)
app.use(express.static(path.join(__dirname, 'dist')));

// Enable CORS for all routes
app.use(cors());

// Parse JSON bodies
app.use(express.json());

// JWT Secret
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

// SQLite database initialization
const dbPath = path.join(__dirname, 'database.sqlite');
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error(err.message);
  } else {
    console.log('Connected to the SQLite database.');
  }
});

// Create tables if they don't exist
db.serialize(() => {
  // Users table
  db.run(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Foods table with user_id foreign key
  db.run(`
    CREATE TABLE IF NOT EXISTS foods (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      caloriesPer100g REAL,
      weight REAL,
      meal_type TEXT,
      date TEXT,
      timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users (id)
    )
  `);

  // Exercises table with user_id foreign key
  db.run(`
    CREATE TABLE IF NOT EXISTS exercises (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      caloriesPerHour REAL,
      duration REAL,
      caloriesBurned REAL,
      sets INTEGER,
      completed BOOLEAN DEFAULT 1,
      date TEXT,
      timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users (id)
    )
  `);
});

// Middleware to verify JWT token
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: 'Access denied. No token provided.' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid token.' });
    }
    req.user = user;
    next();
  });
}

// Helper function to convert database rows to objects with string IDs
function rowToObject(row) {
  const obj = { ...row };
  // Convert numeric ID to string to match frontend expectations
  obj.id = String(obj.id);
  if (obj.user_id) obj.user_id = String(obj.user_id);
  return obj;
}

// Helper function to format food object for frontend
function formatFoodForFrontend(row) {
  const obj = { ...row };
  obj.id = String(obj.id);
  obj.user_id = String(obj.user_id);
  
  // 计算总热量 - 确保即使字段为null或undefined也能正确处理
  let calories = 0;
  if (obj.calories !== null && obj.calories !== undefined && 
      obj.weight !== null && obj.weight !== undefined && 
      !isNaN(obj.calories) && !isNaN(obj.weight)) {
    calories = parseFloat(((obj.calories * obj.weight) / 100).toFixed(2));
  }
  
  obj.calories = calories;
  
  // 映射数据库字段到前端期望的字段名
  if (obj.meal_type) obj.mealType = obj.meal_type;
  
  // 确保日期格式正确
  obj.date = obj.date || (obj.timestamp ? new Date(obj.timestamp).toISOString().split('T')[0] : '');
  
  return obj;
}

// Helper function to format exercise object for frontend
function formatExerciseForFrontend(row) {
  const obj = { ...row };
  obj.id = String(obj.id);
  obj.user_id = String(obj.user_id);
  
  // 直接使用数据库中的caloriesBurned字段
  obj.caloriesBurned = obj.caloriesBurned || 0;
  
  // 确保日期格式正确
  obj.date = obj.date || (obj.timestamp ? new Date(obj.timestamp).toISOString().split('T')[0] : '');
  
  return obj;
}

// User registration endpoint
app.post('/api/register', (req, res) => {
  const { username, email, password } = req.body;

  // Hash the password
  const saltRounds = 10;
  bcrypt.hash(password, saltRounds, (err, hashedPassword) => {
    if (err) {
      return res.status(500).json({ error: 'Error hashing password' });
    }

    const sql = 'INSERT INTO users (username, email, password) VALUES (?, ?, ?)';
    db.run(sql, [username, email, hashedPassword], function(err) {
      if (err) {
        if (err.message.includes('UNIQUE constraint failed')) {
          return res.status(400).json({ error: 'Username or email already exists' });
        }
        return res.status(500).json({ error: err.message });
      }

      // Generate JWT token
      const token = jwt.sign(
        { id: this.lastID, username },
        JWT_SECRET,
        { expiresIn: '7d' }
      );

      res.json({ 
        id: this.lastID, 
        username, 
        email, 
        token,
        message: 'User registered successfully' 
      });
    });
  });
});

// User login endpoint
app.post('/api/login', (req, res) => {
  const { username, password } = req.body;

  const sql = 'SELECT * FROM users WHERE username = ?';
  db.get(sql, [username], (err, user) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }

    if (!user) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    // Compare the provided password with the hashed password
    bcrypt.compare(password, user.password, (err, isMatch) => {
      if (err) {
        return res.status(500).json({ error: 'Error comparing passwords' });
      }

      if (!isMatch) {
        return res.status(400).json({ error: 'Invalid credentials' });
      }

      // Generate JWT token
      const token = jwt.sign(
        { id: user.id, username: user.username },
        JWT_SECRET,
        { expiresIn: '7d' }
      );

      res.json({
        id: user.id,
        username: user.username,
        email: user.email,
        token,
        message: 'Login successful'
      });
    });
  });
});

// Routes for managing foods (with authentication)
app.get('/api/foods', authenticateToken, (req, res) => {
  const sql = 'SELECT * FROM foods WHERE user_id = ? ORDER BY timestamp DESC';
  db.all(sql, [req.user.id], (err, rows) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    const foods = rows.map(formatFoodForFrontend);
    res.json(foods);
  });
});

app.post('/api/foods', authenticateToken, (req, res) => {
  const { name, calories, weight, mealType, date, timestamp = new Date().toISOString() } = req.body;
  
  const sql = 'INSERT INTO foods (user_id, name, calories, weight, meal_type, date, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?)';
  const params = [req.user.id, name, calories, weight, mealType, date, timestamp];
  
  db.run(sql, params, function(err) {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    
    const selectSql = 'SELECT * FROM foods WHERE id = ?';
    db.get(selectSql, [this.lastID], (err, row) => {
      if (err) {
        res.status(500).json({ error: err.message });
        return;
      }
      res.json(formatFoodForFrontend(row));
    });
  });
});

app.put('/api/foods/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  const { name, calories, weight, mealType, date } = req.body;
  
  // First check if the food belongs to the authenticated user
  const checkSql = 'SELECT * FROM foods WHERE id = ? AND user_id = ?';
  db.get(checkSql, [id, req.user.id], (err, row) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    
    if (!row) {
      return res.status(403).json({ error: 'Access denied. Food does not belong to user.' });
    }
    
    const sql = 'UPDATE foods SET name = ?, calories = ?, weight = ?, meal_type = ?, date = ? WHERE id = ?';
    const params = [name, calories, weight, mealType, date, id];
    
    db.run(sql, params, function(err) {
      if (err) {
        res.status(500).json({ error: err.message });
        return;
      }
      
      if (this.changes === 0) {
        res.status(404).json({ error: 'Food not found' });
        return;
      }
      
      const selectSql = 'SELECT * FROM foods WHERE id = ?';
      db.get(selectSql, [id], (err, updatedRow) => {
        if (err) {
          res.status(500).json({ error: err.message });
          return;
        }
        res.json(formatFoodForFrontend(updatedRow));
      });
    });
  });
});

app.delete('/api/foods/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  
  // First check if the food belongs to the authenticated user
  const checkSql = 'SELECT * FROM foods WHERE id = ? AND user_id = ?';
  db.get(checkSql, [id, req.user.id], (err, row) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    
    if (!row) {
      return res.status(403).json({ error: 'Access denied. Food does not belong to user.' });
    }
    
    const sql = 'DELETE FROM foods WHERE id = ?';
    db.run(sql, id, function(err) {
      if (err) {
        res.status(500).json({ error: err.message });
        return;
      }
      
      if (this.changes === 0) {
        res.status(404).json({ error: 'Food not found' });
        return;
      }
      
      res.json({ message: 'Food deleted successfully' });
    });
  });
});

// Routes for managing exercises (with authentication)
app.get('/api/exercises', authenticateToken, (req, res) => {
  const sql = 'SELECT * FROM exercises WHERE user_id = ? ORDER BY timestamp DESC';
  db.all(sql, [req.user.id], (err, rows) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    const exercises = rows.map(formatExerciseForFrontend);
    res.json(exercises);
  });
});

app.post('/api/exercises', authenticateToken, (req, res) => {
  const { name, caloriesPerHour, duration, caloriesBurned, date, sets, completed, timestamp = new Date().toISOString() } = req.body;
  
  const sql = 'INSERT INTO exercises (user_id, name, caloriesPerHour, duration, caloriesBurned, date, sets, completed, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)';
  const params = [req.user.id, name, caloriesPerHour, duration, caloriesBurned, date, sets, completed, timestamp];
  
  db.run(sql, params, function(err) {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    
    const selectSql = 'SELECT * FROM exercises WHERE id = ?';
    db.get(selectSql, [this.lastID], (err, row) => {
      if (err) {
        res.status(500).json({ error: err.message });
        return;
      }
      res.json(formatExerciseForFrontend(row));
    });
  });
});

app.put('/api/exercises/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  const { name, caloriesPerHour, duration, caloriesBurned, date, sets, completed } = req.body;
  
  // First check if the exercise belongs to the authenticated user
  const checkSql = 'SELECT * FROM exercises WHERE id = ? AND user_id = ?';
  db.get(checkSql, [id, req.user.id], (err, row) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    
    if (!row) {
      return res.status(403).json({ error: 'Access denied. Exercise does not belong to user.' });
    }
    
    const sql = 'UPDATE exercises SET name = ?, caloriesPerHour = ?, duration = ?, caloriesBurned = ?, date = ?, sets = ?, completed = ? WHERE id = ?';
    const params = [name, caloriesPerHour, duration, caloriesBurned, date, sets, completed, id];
    
    db.run(sql, params, function(err) {
      if (err) {
        res.status(500).json({ error: err.message });
        return;
      }
      
      if (this.changes === 0) {
        res.status(404).json({ error: 'Exercise not found' });
        return;
      }
      
      const selectSql = 'SELECT * FROM exercises WHERE id = ?';
      db.get(selectSql, [id], (err, updatedRow) => {
        if (err) {
          res.status(500).json({ error: err.message });
          return;
        }
        res.json(formatExerciseForFrontend(updatedRow));
      });
    });
  });
});

app.delete('/api/exercises/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  
  // First check if the exercise belongs to the authenticated user
  const checkSql = 'SELECT * FROM exercises WHERE id = ? AND user_id = ?';
  db.get(checkSql, [id, req.user.id], (err, row) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    
    if (!row) {
      return res.status(403).json({ error: 'Access denied. Exercise does not belong to user.' });
    }
    
    const sql = 'DELETE FROM exercises WHERE id = ?';
    db.run(sql, id, function(err) {
      if (err) {
        res.status(500).json({ error: err.message });
        return;
      }
      
      if (this.changes === 0) {
        res.status(404).json({ error: 'Exercise not found' });
        return;
      }
      
      res.json({ message: 'Exercise deleted successfully' });
    });
  });
});

// Get both foods and exercises for the authenticated user
app.get('/api/data', authenticateToken, (req, res) => {
  const foodsSql = 'SELECT * FROM foods WHERE user_id = ? ORDER BY timestamp DESC';
  const exercisesSql = 'SELECT * FROM exercises WHERE user_id = ? ORDER BY timestamp DESC';
  
  // Using Promise to handle both queries
  const foodsPromise = new Promise((resolve, reject) => {
    db.all(foodsSql, [req.user.id], (err, rows) => {
      if (err) reject(err);
      else resolve(rows.map(formatFoodForFrontend));
    });
  });
  
  const exercisesPromise = new Promise((resolve, reject) => {
    db.all(exercisesSql, [req.user.id], (err, rows) => {
      if (err) reject(err);
      else resolve(rows.map(formatExerciseForFrontend));
    });
  });
  
  Promise.all([foodsPromise, exercisesPromise])
    .then(([foods, exercises]) => {
      res.json({
        foods: foods,
        exercises: exercises
      });
    })
    .catch(err => {
      res.status(500).json({ error: err.message });
    });
});

// Get current user profile
app.get('/api/profile', authenticateToken, (req, res) => {
  const sql = 'SELECT id, username, email, created_at FROM users WHERE id = ?';
  db.get(sql, [req.user.id], (err, user) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(user);
  });
});

// ADMIN ROUTES - User management (should only be accessible by admin)
// For simplicity, we'll allow all authenticated users to see users list
// In a real application, you would add role checks here

// Get all users with pagination and search
app.get('/api/admin/users', authenticateToken, (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const offset = (page - 1) * limit;
  const search = req.query.search ? `%${req.query.search}%` : '%';
  
  // Count total users for pagination info
  let countSql = 'SELECT COUNT(*) as total FROM users';
  let usersSql = `
    SELECT id, username, email, created_at 
    FROM users 
    WHERE username LIKE ? OR email LIKE ?
    ORDER BY created_at DESC 
    LIMIT ? OFFSET ?
  `;
  
  if (search === '%') {
    // If no search term, don't filter by username/email
    countSql = 'SELECT COUNT(*) as total FROM users';
    usersSql = `
      SELECT id, username, email, created_at 
      FROM users 
      ORDER BY created_at DESC 
      LIMIT ? OFFSET ?
    `;
  }
  
  // Execute the count query
  db.get(countSql, [], (countErr, countResult) => {
    if (countErr) {
      return res.status(500).json({ error: countErr.message });
    }
    
    const total = countResult.total;
    
    // Execute the users query
    const sqlParams = search === '%' 
      ? [limit, offset] 
      : [search, search, limit, offset];
    
    db.all(usersSql, sqlParams, (err, rows) => {
      if (err) {
        res.status(500).json({ error: err.message });
        return;
      }
      const users = rows.map(rowToObject);
      
      res.json({
        users: users,
        total: total,
        page: page,
        totalPages: Math.ceil(total / limit)
      });
    });
  });
});

// Get user with their data counts
app.get('/api/admin/users/:id', authenticateToken, (req, res) => {
  const userId = req.params.id;
  
  // Get user details
  const userSql = 'SELECT id, username, email, created_at FROM users WHERE id = ?';
  
  // Get counts for foods and exercises
  const foodsCountSql = 'SELECT COUNT(*) as foods_count FROM foods WHERE user_id = ?';
  const exercisesCountSql = 'SELECT COUNT(*) as exercises_count FROM exercises WHERE user_id = ?';
  
  db.get(userSql, [userId], (err, user) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    db.get(foodsCountSql, [userId], (err, foodsCountResult) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }
      
      db.get(exercisesCountSql, [userId], (err, exercisesCountResult) => {
        if (err) {
          return res.status(500).json({ error: err.message });
        }
        
        const userDetails = {
          ...rowToObject(user),
          foods_count: foodsCountResult ? foodsCountResult.foods_count : 0,
          exercises_count: exercisesCountResult ? exercisesCountResult.exercises_count : 0
        };
        
        res.json(userDetails);
      });
    });
  });
});

// Delete a user and all their data
app.delete('/api/admin/users/:id', authenticateToken, (req, res) => {
  const userId = req.params.id;
  
  // First check if the user exists
  const checkUserSql = 'SELECT id FROM users WHERE id = ?';
  db.get(checkUserSql, [userId], (err, user) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    // Delete all related data first
    const deleteFoodsSql = 'DELETE FROM foods WHERE user_id = ?';
    const deleteExercisesSql = 'DELETE FROM exercises WHERE user_id = ?';
    const deleteUserSql = 'DELETE FROM users WHERE id = ?';
    
    db.serialize(() => {
      // Delete foods
      db.run(deleteFoodsSql, [userId], (err) => {
        if (err) {
          return res.status(500).json({ error: err.message });
        }
        
        // Delete exercises
        db.run(deleteExercisesSql, [userId], (err) => {
          if (err) {
            return res.status(500).json({ error: err.message });
          }
          
          // Finally delete the user
          db.run(deleteUserSql, [userId], function(err) {
            if (err) {
              return res.status(500).json({ error: err.message });
            }
            
            if (this.changes === 0) {
              return res.status(404).json({ error: 'User not found' });
            }
            
            res.json({ message: 'User and all related data deleted successfully' });
          });
        });
      });
    });
  });
});

// Catch-all route to serve the Vue app for any non-API routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist/index.html'));
});

// Close the database connection when the server stops
process.on('SIGINT', () => {
  db.close((err) => {
    if (err) {
      console.error(err.message);
    } else {
      console.log('Close the database connection.');
    }
    process.exit(0);
  });
});

// 添加数据库连接成功后的日志
db.on('open', () => {
  console.log('Connected to the SQLite database.');
});

// 从环境变量获取端口，如果没有则默认使用8080
const PORT = process.env.PORT || 8080;

app.listen(PORT, () => {
  console.log(`Fullstack server running at http://localhost:${PORT}`);
});