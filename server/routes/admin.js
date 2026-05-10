const express = require('express');
const router = express.Router();
const { pool, ALLOWED_ADMIN_EMAILS } = require('../config/database');
const { authenticate } = require('../middleware/auth');

// Вход в админку
router.post('/api/admin/login', async (req, res) => {
  try {
    console.log('Получены данные для входа:', req.body);
    
    const { username, email, password } = req.body;
    const loginIdentifier = email || username;
    
    console.log('Попытка входа с идентификатором:', loginIdentifier);
    
    if (!loginIdentifier || !password) {
      return res.status(400).json({
        success: false,
        message: 'Имя пользователя/email и пароль обязательны'
      });
    }

    const [users] = await pool.execute(
      'SELECT * FROM users WHERE email = ? OR username = ?',
      [loginIdentifier, loginIdentifier]
    );
    
    if (users.length === 0) {
      console.log(`Пользователь с идентификатором ${loginIdentifier} не найден`);
      return res.status(401).json({
        success: false,
        message: 'Неверные учетные данные'
      });
    }
    
    const user = users[0];
  
    if (!ALLOWED_ADMIN_EMAILS.includes(user.email)) {
      console.log(`Попытка входа с неразрешенного email: ${user.email}`);
      return res.status(403).json({
        success: false,
        message: 'Доступ запрещен. У вас нет прав для доступа к админке.'
      });
    }
    
    // проверяем пароль "daria" или "admin123"
    if (password === 'daria' || password === 'admin123') {
      // Создаем токен с информацией о пользователе
      const tokenData = Buffer.from(JSON.stringify({
        username: user.username,
        email: user.email,
        role: user.role,
        timestamp: Date.now()
      })).toString('base64');
      
      const token = `admin_token_${tokenData}`;
      
      console.log(`Успешный вход: ${user.email}`);
      
      res.json({
        success: true,
        message: 'Вход выполнен успешно',
        token: token,
        user: {
          username: user.username,
          email: user.email,
          role: user.role
        }
      });
    } else {
      console.log(`Неверный пароль для: ${user.email}`);
      res.status(401).json({
        success: false,
        message: 'Неверные учетные данные'
      });
    }
  } catch (error) {
    console.error('Ошибка входа:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера'
    });
  }
});

// Получение статистики
router.get('/api/admin/statistics', authenticate, async (req, res) => {
  try {
    console.log('Запрос статистики от:', req.user.email);
    
    // Статистика по заявкам
    const [[bookingStats]] = await pool.execute(`
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN status = 'new' THEN 1 ELSE 0 END) as new,
        SUM(CASE WHEN status = 'contacted' THEN 1 ELSE 0 END) as contacted,
        SUM(CASE WHEN status = 'confirmed' THEN 1 ELSE 0 END) as confirmed,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled
      FROM bookings
    `);

    // Статистика по отзывам
    const [[reviewStats]] = await pool.execute(`
      SELECT 
        COUNT(*) as total,
        ROUND(AVG(rating), 1) as avg_rating,
        SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
        SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
        SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected
      FROM reviews
    `);

    const statistics = {
      bookings: {
        total: parseInt(bookingStats.total) || 0,
        new: parseInt(bookingStats.new) || 0,
        contacted: parseInt(bookingStats.contacted) || 0,
        confirmed: parseInt(bookingStats.confirmed) || 0,
        completed: parseInt(bookingStats.completed) || 0,
        cancelled: parseInt(bookingStats.cancelled) || 0
      },
      reviews: {
        total: parseInt(reviewStats.total) || 0,
        avgRating: parseFloat(reviewStats.avg_rating) || 0,
        pending: parseInt(reviewStats.pending) || 0,
        approved: parseInt(reviewStats.approved) || 0,
        rejected: parseInt(reviewStats.rejected) || 0
      }
    };

    console.log('Статистика:', statistics);
    
    res.json({
      success: true,
      data: statistics,
      user: req.user // Возвращаем информацию о текущем пользователе
    });
  } catch (error) {
    console.error('Ошибка при получении статистики:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера'
    });
  }
});

// Получение заявок (админ)
router.get('/api/admin/bookings', authenticate, async (req, res) => {
  try {
    console.log('📋 Запрос заявок от:', req.user.email);
    
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit) || 10));
    const offset = (page - 1) * limit;
    const { status } = req.query;
    
    let query = 'SELECT * FROM bookings';
    let countQuery = 'SELECT COUNT(*) as total FROM bookings';
    const params = [];
    const countParams = [];

    if (status && status !== 'all') {
      query += ' WHERE status = ?';
      countQuery += ' WHERE status = ?';
      params.push(status);
      countParams.push(status);
    }

    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    const [bookings] = await pool.execute(query, params);
    const [[{ total }]] = await pool.execute(countQuery, countParams);

    res.json({
      success: true,
      data: {
        bookings,
        pagination: {
          total,
          page,
          limit,
          pages: Math.ceil(total / limit)
        }
      },
      user: req.user
    });
  } catch (error) {
    console.error('Ошибка при получении заявок:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера'
    });
  }
});

// Обновление статуса заявки
router.put('/api/admin/bookings/:id/status', authenticate, async (req, res) => {
  try {
    console.log(`Изменение статуса заявки #${req.params.id} от:`, req.user.email);
    
    const { id } = req.params;
    const { status } = req.body;

    const validStatuses = ['new', 'contacted', 'confirmed', 'completed', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Недопустимый статус'
      });
    }

    await pool.execute(
      'UPDATE bookings SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [status, id]
    );

    res.json({
      success: true,
      message: 'Статус заявки обновлен'
    });
  } catch (error) {
    console.error('Ошибка при обновлении статуса:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера'
    });
  }
});

// Удаление заявки
router.delete('/api/admin/bookings/:id', authenticate, async (req, res) => {
  try {
    console.log(`Удаление заявки #${req.params.id} от:`, req.user.email);
    
    const { id } = req.params;
    
    await pool.execute('DELETE FROM bookings WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Заявка удалена'
    });
  } catch (error) {
    console.error('Ошибка при удалении заявки:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера'
    });
  }
});

// Получение отзывов (админ)
router.get('/api/admin/reviews', authenticate, async (req, res) => {
  try {
    console.log('Запрос отзывов для админки от:', req.user.email);
    
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit) || 10));
    const offset = (page - 1) * limit;
    const { status } = req.query;
    
    console.log('📋 Запрос отзывов для админки:', { page, limit, status });
    
    let query = 'SELECT * FROM reviews';
    let countQuery = 'SELECT COUNT(*) as total FROM reviews';
    const params = [];
    const countParams = [];

    if (status && status !== 'all') {
      query += ' WHERE status = ?';
      countQuery += ' WHERE status = ?';
      params.push(status);
      countParams.push(status);
    }

    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    const [reviews] = await pool.execute(query, params);
    const [[{ total }]] = await pool.execute(countQuery, countParams);

    console.log(`Найдено отзывов: ${reviews.length}`);
    
    res.json({
      success: true,
      data: {
        reviews,
        pagination: {
          total,
          page,
          limit,
          pages: Math.ceil(total / limit)
        }
      },
      user: req.user
    });
  } catch (error) {
    console.error('Ошибка при получении отзывов:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера'
    });
  }
});

// Обновление статуса отзыва
router.put('/api/admin/reviews/:id/status', authenticate, async (req, res) => {
  try {
    console.log(`Изменение статуса отзыва #${req.params.id} от:`, req.user.email);
    
    const { id } = req.params;
    const { status } = req.body;

    console.log(`Изменение статуса отзыва #${id} на ${status}`);

    if (!['pending', 'approved', 'rejected'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Недопустимый статус'
      });
    }

    await pool.execute(
      'UPDATE reviews SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [status, id]
    );

    res.json({
      success: true,
      message: `Отзыв ${status === 'approved' ? 'одобрен' : 'отклонен'}`
    });
  } catch (error) {
    console.error('Ошибка при обновлении статуса:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера'
    });
  }
});

// Удаление отзыва
router.delete('/api/admin/reviews/:id', authenticate, async (req, res) => {
  try {
    console.log(`Удаление отзыва #${req.params.id} от:`, req.user.email);
    
    const { id } = req.params;
    
    await pool.execute('DELETE FROM reviews WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Отзыв удален'
    });
  } catch (error) {
    console.error('Ошибка при удалении отзыва:', error);
    res.status(500).json({
      success: false,
      message: 'Ошибка сервера'
    });
  }
});

module.exports = router;