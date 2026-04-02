# Документація з розгортання Fitness API

## Передумови

- Docker та Docker Compose встановлені на сервері
- Git встановлений
- SSH доступ до сервера

## 1. Клонування проекту

```bash
git clone https://github.com/MironAlikc/service-fitness-training.git
cd service-fitness-training
```

## 2. Налаштування середовища

### 2.1. Створення .env файлу

Створіть файл `.env` на основі `.env_src`:

```bash
cp .env_src .env
```

### 2.2. Редагування .env файлу

Відредагуйте `.env` файл з наступними налаштуваннями:

```env
# Mail Configuration
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password
MAIL_FROM=your_email@gmail.com
MAIL_FROM_NAME=Fitness App
ADMIN_EMAIL=admin@example.com

# Security
SECRET=your-secret-key-here
AUTH0_CLIENT_ID=fitness-api-01
AUTH0_CLIENT_SECRET=fitness-api-secret-01
AUTH0_DOMAIN=http://your-domain.com:8000

# Redis
REDIS_URL=redis://redis:6379/0

# Admin Credentials
ADMIN=admin@example.com
PWR=your-admin-password

# JWT
SECRET_KEY=your-super-secret-key-change-in-production
ACCESS_TOKEN_EXPIRE_MINUTES=11520
ACCESS_TOKEN_EXPIRE_MINUTES_LONG=11520

# Database Configuration
DATABASE_URL=postgresql://postgres:postgres@db:5432/fitness
DB_HOST=db
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_NAME=fitness
DB_PORT=5432

# API
API_V1_STR=/api/v1
```

## 3. Docker Compose налаштування

### 3.1. Перевірка docker-compose.yml

Переконайтеся, що в `docker-compose.yml` правильні налаштування бази даних:

```yaml
db:
  image: postgres:latest
  container_name: fitness_db
  environment:
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: postgres
    POSTGRES_DB: fitness
```

## 4. Розгортання

### 4.1. Запуск контейнерів

```bash
docker compose up --build -d
```

### 4.2. Перевірка статусу

```bash
docker compose ps
```

Усі контейнери мають бути в статусі "Up".

### 4.3. Перевірка логів

```bash
docker compose logs -f
```

Натисніть `Ctrl+C` для виходу з режиму перегляду логів.

## 5. Ініціалізація бази даних

### 5.1. Створення таблиць

```bash
docker compose exec api python -c "from app.models import *; from app.db.base_class import Base; from app.db.session import engine; print('Available tables:', list(Base.metadata.tables.keys())); Base.metadata.create_all(bind=engine); print('Tables created')"
```

### 5.2. Перевірка створення таблиць

```bash
docker compose exec db psql -U postgres -d fitness -c "\dt"
```

Повинно показати наступні таблиці:

- coach
- logs
- machine
- program
- program_machine
- tasks
- trainee
- users
- workoutappointment
- workout_sessions

## 6. Перевірка роботи

### 6.1. Тест API

```bash
curl http://localhost:8000/
```

### 6.2. Доступ до адмін панелі

Відкрийте в браузері: `http://your-server-ip:8000/admin`

### 6.3. Перевірка бази даних

```bash
docker compose exec db psql -U postgres -d fitness
```

В psql консолі можете виконувати SQL запити:

```sql
\dt                    -- показати всі таблиці
\d table_name         -- показати структуру таблиці
SELECT COUNT(*) FROM coach;  -- перевірити кількість записів
\q                    -- вийти
```

## 7. Управління сервісом

### 7.1. Зупинка сервісу

```bash
docker compose down
```

### 7.2. Запуск сервісу

```bash
docker compose up -d
```

### 7.3. Перезапуск сервісу

```bash
docker compose restart
```

### 7.4. Перебудова і запуск

```bash
docker compose up --build -d
```

### 7.5. Перегляд логів

```bash
# Всі сервіси
docker compose logs -f

# Конкретний сервіс
docker compose logs -f api
docker compose logs -f db
docker compose logs -f redis
```

## 8. Резервне копіювання

### 8.1. Створення backup бази даних

```bash
docker compose exec db pg_dump -U postgres fitness > backup_$(date +%Y%m%d_%H%M%S).sql
```

### 8.2. Відновлення з backup

```bash
docker compose exec -i db psql -U postgres fitness < backup_file.sql
```

## 9. Оновлення проекту

### 9.1. Отримання нових змін

```bash
git pull origin main
```

### 9.2. Перебудова контейнерів

```bash
docker compose up --build -d
```

### 9.3. Застосування міграцій (якщо є)

```bash
docker compose exec api python -c "from app.models import *; from app.db.base_class import Base; from app.db.session import engine; Base.metadata.create_all(bind=engine); print('Tables updated')"
```

## 10. Troubleshooting

### 10.1. Проблеми з базою даних

Якщо виникають проблеми з підключенням до БД:

```bash
# Перевірити статус контейнера БД
docker compose ps db

# Переглянути логи БД
docker compose logs db

# Перезапустити БД
docker compose restart db
```

### 10.2. Очищення бази даних

Якщо потрібно повністю очистити БД:

```bash
docker compose down
docker volume rm service-fitness-training_db_data
docker compose up -d
```

Після цього потрібно заново створити таблиці (крок 5.1).

### 10.3. Проблеми з портами

Якщо порти зайняті:

```bash
# Перевірити які процеси використовують порти
lsof -i :8000
lsof -i :5432

# Змінити порти в docker-compose.yml якщо потрібно
```

### 10.4. Перевірка мережі

```bash
# Перевірити Docker мережі
docker network ls

# Перевірити підключення між контейнерами
docker compose exec api ping db
```

## 11. Моніторинг

### 11.1. Використання ресурсів

```bash
docker stats
```

### 11.2. Розмір даних

```bash
docker system df
docker volume ls
```

### 11.3. Логи системи

```bash
# Розмір логів
docker system events

# Очищення старих образів
docker image prune -a
```

## 12. Безпека

### 12.1. Зміна паролів

Не забудьте змінити:

- Паролі в .env файлі
- SECRET ключі
- Паролі адміністратора

### 12.2. Firewall

Налаштуйте firewall для обмеження доступу:

```bash
# Дозволити тільки необхідні порти
ufw allow 22    # SSH
ufw allow 8000  # API
ufw enable
```

### 12.3. SSL/HTTPS

Для продакшн середовища налаштуйте HTTPS через nginx або traefik.

---

## Контакти

У разі проблем з розгортанням, зверніться до команди розробки.
